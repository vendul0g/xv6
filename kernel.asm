
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc d0 56 11 80       	mov    $0x801156d0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 99 29 10 80       	mov    $0x80102999,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	57                   	push   %edi
80100038:	56                   	push   %esi
80100039:	53                   	push   %ebx
8010003a:	83 ec 18             	sub    $0x18,%esp
8010003d:	89 c6                	mov    %eax,%esi
8010003f:	89 d7                	mov    %edx,%edi
  struct buf *b;

  acquire(&bcache.lock);
80100041:	68 20 a5 10 80       	push   $0x8010a520
80100046:	e8 a4 3a 00 00       	call   80103aef <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004b:	8b 1d 70 ec 10 80    	mov    0x8010ec70,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb 1c ec 10 80    	cmp    $0x8010ec1c,%ebx
8010005f:	74 2e                	je     8010008f <bget+0x5b>
    if(b->dev == dev && b->blockno == blockno){
80100061:	39 73 04             	cmp    %esi,0x4(%ebx)
80100064:	75 f0                	jne    80100056 <bget+0x22>
80100066:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100069:	75 eb                	jne    80100056 <bget+0x22>
      b->refcnt++;
8010006b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010006e:	40                   	inc    %eax
8010006f:	89 43 4c             	mov    %eax,0x4c(%ebx)
      release(&bcache.lock);
80100072:	83 ec 0c             	sub    $0xc,%esp
80100075:	68 20 a5 10 80       	push   $0x8010a520
8010007a:	e8 d5 3a 00 00       	call   80103b54 <release>
      acquiresleep(&b->lock);
8010007f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100082:	89 04 24             	mov    %eax,(%esp)
80100085:	e8 56 38 00 00       	call   801038e0 <acquiresleep>
      return b;
8010008a:	83 c4 10             	add    $0x10,%esp
8010008d:	eb 4c                	jmp    801000db <bget+0xa7>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010008f:	8b 1d 6c ec 10 80    	mov    0x8010ec6c,%ebx
80100095:	eb 03                	jmp    8010009a <bget+0x66>
80100097:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009a:	81 fb 1c ec 10 80    	cmp    $0x8010ec1c,%ebx
801000a0:	74 43                	je     801000e5 <bget+0xb1>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
801000a2:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801000a6:	75 ef                	jne    80100097 <bget+0x63>
801000a8:	f6 03 04             	testb  $0x4,(%ebx)
801000ab:	75 ea                	jne    80100097 <bget+0x63>
      b->dev = dev;
801000ad:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
801000b0:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000b3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000b9:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000c0:	83 ec 0c             	sub    $0xc,%esp
801000c3:	68 20 a5 10 80       	push   $0x8010a520
801000c8:	e8 87 3a 00 00       	call   80103b54 <release>
      acquiresleep(&b->lock);
801000cd:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d0:	89 04 24             	mov    %eax,(%esp)
801000d3:	e8 08 38 00 00       	call   801038e0 <acquiresleep>
      return b;
801000d8:	83 c4 10             	add    $0x10,%esp
    }
  }
  panic("bget: no buffers");
}
801000db:	89 d8                	mov    %ebx,%eax
801000dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e0:	5b                   	pop    %ebx
801000e1:	5e                   	pop    %esi
801000e2:	5f                   	pop    %edi
801000e3:	5d                   	pop    %ebp
801000e4:	c3                   	ret    
  panic("bget: no buffers");
801000e5:	83 ec 0c             	sub    $0xc,%esp
801000e8:	68 20 67 10 80       	push   $0x80106720
801000ed:	e8 4f 02 00 00       	call   80100341 <panic>

801000f2 <binit>:
{
801000f2:	55                   	push   %ebp
801000f3:	89 e5                	mov    %esp,%ebp
801000f5:	53                   	push   %ebx
801000f6:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000f9:	68 31 67 10 80       	push   $0x80106731
801000fe:	68 20 a5 10 80       	push   $0x8010a520
80100103:	e8 b0 38 00 00       	call   801039b8 <initlock>
  bcache.head.prev = &bcache.head;
80100108:	c7 05 6c ec 10 80 1c 	movl   $0x8010ec1c,0x8010ec6c
8010010f:	ec 10 80 
  bcache.head.next = &bcache.head;
80100112:	c7 05 70 ec 10 80 1c 	movl   $0x8010ec1c,0x8010ec70
80100119:	ec 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010011c:	83 c4 10             	add    $0x10,%esp
8010011f:	bb 54 a5 10 80       	mov    $0x8010a554,%ebx
80100124:	eb 37                	jmp    8010015d <binit+0x6b>
    b->next = bcache.head.next;
80100126:	a1 70 ec 10 80       	mov    0x8010ec70,%eax
8010012b:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010012e:	c7 43 50 1c ec 10 80 	movl   $0x8010ec1c,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100135:	83 ec 08             	sub    $0x8,%esp
80100138:	68 38 67 10 80       	push   $0x80106738
8010013d:	8d 43 0c             	lea    0xc(%ebx),%eax
80100140:	50                   	push   %eax
80100141:	e8 67 37 00 00       	call   801038ad <initsleeplock>
    bcache.head.next->prev = b;
80100146:	a1 70 ec 10 80       	mov    0x8010ec70,%eax
8010014b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010014e:	89 1d 70 ec 10 80    	mov    %ebx,0x8010ec70
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100154:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
8010015a:	83 c4 10             	add    $0x10,%esp
8010015d:	81 fb 1c ec 10 80    	cmp    $0x8010ec1c,%ebx
80100163:	72 c1                	jb     80100126 <binit+0x34>
}
80100165:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100168:	c9                   	leave  
80100169:	c3                   	ret    

8010016a <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
8010016a:	55                   	push   %ebp
8010016b:	89 e5                	mov    %esp,%ebp
8010016d:	53                   	push   %ebx
8010016e:	83 ec 04             	sub    $0x4,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	8b 45 08             	mov    0x8(%ebp),%eax
80100177:	e8 b8 fe ff ff       	call   80100034 <bget>
8010017c:	89 c3                	mov    %eax,%ebx
  if((b->flags & B_VALID) == 0) {
8010017e:	f6 00 02             	testb  $0x2,(%eax)
80100181:	74 07                	je     8010018a <bread+0x20>
    iderw(b);
  }
  return b;
}
80100183:	89 d8                	mov    %ebx,%eax
80100185:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100188:	c9                   	leave  
80100189:	c3                   	ret    
    iderw(b);
8010018a:	83 ec 0c             	sub    $0xc,%esp
8010018d:	50                   	push   %eax
8010018e:	e8 f1 1b 00 00       	call   80101d84 <iderw>
80100193:	83 c4 10             	add    $0x10,%esp
  return b;
80100196:	eb eb                	jmp    80100183 <bread+0x19>

80100198 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100198:	55                   	push   %ebp
80100199:	89 e5                	mov    %esp,%ebp
8010019b:	53                   	push   %ebx
8010019c:	83 ec 10             	sub    $0x10,%esp
8010019f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001a2:	8d 43 0c             	lea    0xc(%ebx),%eax
801001a5:	50                   	push   %eax
801001a6:	e8 bf 37 00 00       	call   8010396a <holdingsleep>
801001ab:	83 c4 10             	add    $0x10,%esp
801001ae:	85 c0                	test   %eax,%eax
801001b0:	74 14                	je     801001c6 <bwrite+0x2e>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001b2:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001b5:	83 ec 0c             	sub    $0xc,%esp
801001b8:	53                   	push   %ebx
801001b9:	e8 c6 1b 00 00       	call   80101d84 <iderw>
}
801001be:	83 c4 10             	add    $0x10,%esp
801001c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c4:	c9                   	leave  
801001c5:	c3                   	ret    
    panic("bwrite");
801001c6:	83 ec 0c             	sub    $0xc,%esp
801001c9:	68 3f 67 10 80       	push   $0x8010673f
801001ce:	e8 6e 01 00 00       	call   80100341 <panic>

801001d3 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001d3:	55                   	push   %ebp
801001d4:	89 e5                	mov    %esp,%ebp
801001d6:	56                   	push   %esi
801001d7:	53                   	push   %ebx
801001d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001db:	8d 73 0c             	lea    0xc(%ebx),%esi
801001de:	83 ec 0c             	sub    $0xc,%esp
801001e1:	56                   	push   %esi
801001e2:	e8 83 37 00 00       	call   8010396a <holdingsleep>
801001e7:	83 c4 10             	add    $0x10,%esp
801001ea:	85 c0                	test   %eax,%eax
801001ec:	74 69                	je     80100257 <brelse+0x84>
    panic("brelse");

  releasesleep(&b->lock);
801001ee:	83 ec 0c             	sub    $0xc,%esp
801001f1:	56                   	push   %esi
801001f2:	e8 38 37 00 00       	call   8010392f <releasesleep>

  acquire(&bcache.lock);
801001f7:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801001fe:	e8 ec 38 00 00       	call   80103aef <acquire>
  b->refcnt--;
80100203:	8b 43 4c             	mov    0x4c(%ebx),%eax
80100206:	48                   	dec    %eax
80100207:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010020a:	83 c4 10             	add    $0x10,%esp
8010020d:	85 c0                	test   %eax,%eax
8010020f:	75 2f                	jne    80100240 <brelse+0x6d>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100211:	8b 43 54             	mov    0x54(%ebx),%eax
80100214:	8b 53 50             	mov    0x50(%ebx),%edx
80100217:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010021a:	8b 43 50             	mov    0x50(%ebx),%eax
8010021d:	8b 53 54             	mov    0x54(%ebx),%edx
80100220:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100223:	a1 70 ec 10 80       	mov    0x8010ec70,%eax
80100228:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010022b:	c7 43 50 1c ec 10 80 	movl   $0x8010ec1c,0x50(%ebx)
    bcache.head.next->prev = b;
80100232:	a1 70 ec 10 80       	mov    0x8010ec70,%eax
80100237:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010023a:	89 1d 70 ec 10 80    	mov    %ebx,0x8010ec70
  }
  
  release(&bcache.lock);
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 20 a5 10 80       	push   $0x8010a520
80100248:	e8 07 39 00 00       	call   80103b54 <release>
}
8010024d:	83 c4 10             	add    $0x10,%esp
80100250:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100253:	5b                   	pop    %ebx
80100254:	5e                   	pop    %esi
80100255:	5d                   	pop    %ebp
80100256:	c3                   	ret    
    panic("brelse");
80100257:	83 ec 0c             	sub    $0xc,%esp
8010025a:	68 46 67 10 80       	push   $0x80106746
8010025f:	e8 dd 00 00 00       	call   80100341 <panic>

80100264 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100264:	55                   	push   %ebp
80100265:	89 e5                	mov    %esp,%ebp
80100267:	57                   	push   %edi
80100268:	56                   	push   %esi
80100269:	53                   	push   %ebx
8010026a:	83 ec 28             	sub    $0x28,%esp
8010026d:	8b 7d 08             	mov    0x8(%ebp),%edi
80100270:	8b 75 0c             	mov    0xc(%ebp),%esi
80100273:	8b 5d 10             	mov    0x10(%ebp),%ebx
  uint target;
  int c;

  iunlock(ip);
80100276:	57                   	push   %edi
80100277:	e8 51 13 00 00       	call   801015cd <iunlock>
  target = n;
8010027c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
8010027f:	c7 04 24 20 ef 10 80 	movl   $0x8010ef20,(%esp)
80100286:	e8 64 38 00 00       	call   80103aef <acquire>
  while(n > 0){
8010028b:	83 c4 10             	add    $0x10,%esp
8010028e:	85 db                	test   %ebx,%ebx
80100290:	0f 8e 8c 00 00 00    	jle    80100322 <consoleread+0xbe>
    while(input.r == input.w){
80100296:	a1 00 ef 10 80       	mov    0x8010ef00,%eax
8010029b:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
801002a1:	75 47                	jne    801002ea <consoleread+0x86>
      if(myproc()->killed){
801002a3:	e8 7e 2e 00 00       	call   80103126 <myproc>
801002a8:	83 78 2c 00          	cmpl   $0x0,0x2c(%eax)
801002ac:	75 17                	jne    801002c5 <consoleread+0x61>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002ae:	83 ec 08             	sub    $0x8,%esp
801002b1:	68 20 ef 10 80       	push   $0x8010ef20
801002b6:	68 00 ef 10 80       	push   $0x8010ef00
801002bb:	e8 24 33 00 00       	call   801035e4 <sleep>
801002c0:	83 c4 10             	add    $0x10,%esp
801002c3:	eb d1                	jmp    80100296 <consoleread+0x32>
        release(&cons.lock);
801002c5:	83 ec 0c             	sub    $0xc,%esp
801002c8:	68 20 ef 10 80       	push   $0x8010ef20
801002cd:	e8 82 38 00 00       	call   80103b54 <release>
        ilock(ip);
801002d2:	89 3c 24             	mov    %edi,(%esp)
801002d5:	e8 33 12 00 00       	call   8010150d <ilock>
        return -1;
801002da:	83 c4 10             	add    $0x10,%esp
801002dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801002e5:	5b                   	pop    %ebx
801002e6:	5e                   	pop    %esi
801002e7:	5f                   	pop    %edi
801002e8:	5d                   	pop    %ebp
801002e9:	c3                   	ret    
    c = input.buf[input.r++ % INPUT_BUF];
801002ea:	8d 50 01             	lea    0x1(%eax),%edx
801002ed:	89 15 00 ef 10 80    	mov    %edx,0x8010ef00
801002f3:	89 c2                	mov    %eax,%edx
801002f5:	83 e2 7f             	and    $0x7f,%edx
801002f8:	8a 92 80 ee 10 80    	mov    -0x7fef1180(%edx),%dl
801002fe:	0f be ca             	movsbl %dl,%ecx
    if(c == C('D')){  // EOF
80100301:	80 fa 04             	cmp    $0x4,%dl
80100304:	74 12                	je     80100318 <consoleread+0xb4>
    *dst++ = c;
80100306:	8d 46 01             	lea    0x1(%esi),%eax
80100309:	88 16                	mov    %dl,(%esi)
    --n;
8010030b:	4b                   	dec    %ebx
    if(c == '\n')
8010030c:	83 f9 0a             	cmp    $0xa,%ecx
8010030f:	74 11                	je     80100322 <consoleread+0xbe>
    *dst++ = c;
80100311:	89 c6                	mov    %eax,%esi
80100313:	e9 76 ff ff ff       	jmp    8010028e <consoleread+0x2a>
      if(n < target){
80100318:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
8010031b:	73 05                	jae    80100322 <consoleread+0xbe>
        input.r--;
8010031d:	a3 00 ef 10 80       	mov    %eax,0x8010ef00
  release(&cons.lock);
80100322:	83 ec 0c             	sub    $0xc,%esp
80100325:	68 20 ef 10 80       	push   $0x8010ef20
8010032a:	e8 25 38 00 00       	call   80103b54 <release>
  ilock(ip);
8010032f:	89 3c 24             	mov    %edi,(%esp)
80100332:	e8 d6 11 00 00       	call   8010150d <ilock>
  return target - n;
80100337:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010033a:	29 d8                	sub    %ebx,%eax
8010033c:	83 c4 10             	add    $0x10,%esp
8010033f:	eb a1                	jmp    801002e2 <consoleread+0x7e>

80100341 <panic>:
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
80100344:	53                   	push   %ebx
80100345:	83 ec 34             	sub    $0x34,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
80100348:	fa                   	cli    
  cons.locking = 0;
80100349:	c7 05 54 ef 10 80 00 	movl   $0x0,0x8010ef54
80100350:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
80100353:	e8 92 1f 00 00       	call   801022ea <lapicid>
80100358:	83 ec 08             	sub    $0x8,%esp
8010035b:	50                   	push   %eax
8010035c:	68 4d 67 10 80       	push   $0x8010674d
80100361:	e8 74 02 00 00       	call   801005da <cprintf>
  cprintf(s);
80100366:	83 c4 04             	add    $0x4,%esp
80100369:	ff 75 08             	push   0x8(%ebp)
8010036c:	e8 69 02 00 00       	call   801005da <cprintf>
  cprintf("\n");
80100371:	c7 04 24 03 71 10 80 	movl   $0x80107103,(%esp)
80100378:	e8 5d 02 00 00       	call   801005da <cprintf>
  getcallerpcs(&s, pcs);
8010037d:	83 c4 08             	add    $0x8,%esp
80100380:	8d 45 d0             	lea    -0x30(%ebp),%eax
80100383:	50                   	push   %eax
80100384:	8d 45 08             	lea    0x8(%ebp),%eax
80100387:	50                   	push   %eax
80100388:	e8 46 36 00 00       	call   801039d3 <getcallerpcs>
  for(i=0; i<10; i++)
8010038d:	83 c4 10             	add    $0x10,%esp
80100390:	bb 00 00 00 00       	mov    $0x0,%ebx
80100395:	eb 15                	jmp    801003ac <panic+0x6b>
    cprintf(" %p", pcs[i]);
80100397:	83 ec 08             	sub    $0x8,%esp
8010039a:	ff 74 9d d0          	push   -0x30(%ebp,%ebx,4)
8010039e:	68 61 67 10 80       	push   $0x80106761
801003a3:	e8 32 02 00 00       	call   801005da <cprintf>
  for(i=0; i<10; i++)
801003a8:	43                   	inc    %ebx
801003a9:	83 c4 10             	add    $0x10,%esp
801003ac:	83 fb 09             	cmp    $0x9,%ebx
801003af:	7e e6                	jle    80100397 <panic+0x56>
  panicked = 1; // freeze other CPU
801003b1:	c7 05 58 ef 10 80 01 	movl   $0x1,0x8010ef58
801003b8:	00 00 00 
  for(;;)
801003bb:	eb fe                	jmp    801003bb <panic+0x7a>

801003bd <cgaputc>:
{
801003bd:	55                   	push   %ebp
801003be:	89 e5                	mov    %esp,%ebp
801003c0:	57                   	push   %edi
801003c1:	56                   	push   %esi
801003c2:	53                   	push   %ebx
801003c3:	83 ec 0c             	sub    $0xc,%esp
801003c6:	89 c3                	mov    %eax,%ebx
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003c8:	bf d4 03 00 00       	mov    $0x3d4,%edi
801003cd:	b0 0e                	mov    $0xe,%al
801003cf:	89 fa                	mov    %edi,%edx
801003d1:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003d2:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
801003d7:	89 ca                	mov    %ecx,%edx
801003d9:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
801003da:	0f b6 f0             	movzbl %al,%esi
801003dd:	c1 e6 08             	shl    $0x8,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003e0:	b0 0f                	mov    $0xf,%al
801003e2:	89 fa                	mov    %edi,%edx
801003e4:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003e5:	89 ca                	mov    %ecx,%edx
801003e7:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
801003e8:	0f b6 c8             	movzbl %al,%ecx
801003eb:	09 f1                	or     %esi,%ecx
  if(c == '\n')
801003ed:	83 fb 0a             	cmp    $0xa,%ebx
801003f0:	74 5a                	je     8010044c <cgaputc+0x8f>
  else if(c == BACKSPACE){
801003f2:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
801003f8:	74 62                	je     8010045c <cgaputc+0x9f>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801003fa:	0f b6 c3             	movzbl %bl,%eax
801003fd:	8d 59 01             	lea    0x1(%ecx),%ebx
80100400:	80 cc 07             	or     $0x7,%ah
80100403:	66 89 84 09 00 80 0b 	mov    %ax,-0x7ff48000(%ecx,%ecx,1)
8010040a:	80 
  if(pos < 0 || pos > 25*80)
8010040b:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
80100411:	77 56                	ja     80100469 <cgaputc+0xac>
  if((pos/80) >= 24){  // Scroll up.
80100413:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100419:	7f 5b                	jg     80100476 <cgaputc+0xb9>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010041b:	be d4 03 00 00       	mov    $0x3d4,%esi
80100420:	b0 0e                	mov    $0xe,%al
80100422:	89 f2                	mov    %esi,%edx
80100424:	ee                   	out    %al,(%dx)
  outb(CRTPORT+1, pos>>8);
80100425:	0f b6 c7             	movzbl %bh,%eax
80100428:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
8010042d:	89 ca                	mov    %ecx,%edx
8010042f:	ee                   	out    %al,(%dx)
80100430:	b0 0f                	mov    $0xf,%al
80100432:	89 f2                	mov    %esi,%edx
80100434:	ee                   	out    %al,(%dx)
80100435:	88 d8                	mov    %bl,%al
80100437:	89 ca                	mov    %ecx,%edx
80100439:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
8010043a:	66 c7 84 1b 00 80 0b 	movw   $0x720,-0x7ff48000(%ebx,%ebx,1)
80100441:	80 20 07 
}
80100444:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100447:	5b                   	pop    %ebx
80100448:	5e                   	pop    %esi
80100449:	5f                   	pop    %edi
8010044a:	5d                   	pop    %ebp
8010044b:	c3                   	ret    
    pos += 80 - pos%80;
8010044c:	bb 50 00 00 00       	mov    $0x50,%ebx
80100451:	89 c8                	mov    %ecx,%eax
80100453:	99                   	cltd   
80100454:	f7 fb                	idiv   %ebx
80100456:	29 d3                	sub    %edx,%ebx
80100458:	01 cb                	add    %ecx,%ebx
8010045a:	eb af                	jmp    8010040b <cgaputc+0x4e>
    if(pos > 0) --pos;
8010045c:	85 c9                	test   %ecx,%ecx
8010045e:	7e 05                	jle    80100465 <cgaputc+0xa8>
80100460:	8d 59 ff             	lea    -0x1(%ecx),%ebx
80100463:	eb a6                	jmp    8010040b <cgaputc+0x4e>
  pos |= inb(CRTPORT+1);
80100465:	89 cb                	mov    %ecx,%ebx
80100467:	eb a2                	jmp    8010040b <cgaputc+0x4e>
    panic("pos under/overflow");
80100469:	83 ec 0c             	sub    $0xc,%esp
8010046c:	68 65 67 10 80       	push   $0x80106765
80100471:	e8 cb fe ff ff       	call   80100341 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100476:	83 ec 04             	sub    $0x4,%esp
80100479:	68 60 0e 00 00       	push   $0xe60
8010047e:	68 a0 80 0b 80       	push   $0x800b80a0
80100483:	68 00 80 0b 80       	push   $0x800b8000
80100488:	e8 84 37 00 00       	call   80103c11 <memmove>
    pos -= 80;
8010048d:	83 eb 50             	sub    $0x50,%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100490:	b8 80 07 00 00       	mov    $0x780,%eax
80100495:	29 d8                	sub    %ebx,%eax
80100497:	8d 94 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%edx
8010049e:	83 c4 0c             	add    $0xc,%esp
801004a1:	01 c0                	add    %eax,%eax
801004a3:	50                   	push   %eax
801004a4:	6a 00                	push   $0x0
801004a6:	52                   	push   %edx
801004a7:	e8 ef 36 00 00       	call   80103b9b <memset>
801004ac:	83 c4 10             	add    $0x10,%esp
801004af:	e9 67 ff ff ff       	jmp    8010041b <cgaputc+0x5e>

801004b4 <consputc>:
  if(panicked){
801004b4:	83 3d 58 ef 10 80 00 	cmpl   $0x0,0x8010ef58
801004bb:	74 03                	je     801004c0 <consputc+0xc>
  asm volatile("cli");
801004bd:	fa                   	cli    
    for(;;)
801004be:	eb fe                	jmp    801004be <consputc+0xa>
{
801004c0:	55                   	push   %ebp
801004c1:	89 e5                	mov    %esp,%ebp
801004c3:	53                   	push   %ebx
801004c4:	83 ec 04             	sub    $0x4,%esp
801004c7:	89 c3                	mov    %eax,%ebx
  if(c == BACKSPACE){
801004c9:	3d 00 01 00 00       	cmp    $0x100,%eax
801004ce:	74 18                	je     801004e8 <consputc+0x34>
    uartputc(c);
801004d0:	83 ec 0c             	sub    $0xc,%esp
801004d3:	50                   	push   %eax
801004d4:	e8 7d 4c 00 00       	call   80105156 <uartputc>
801004d9:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801004dc:	89 d8                	mov    %ebx,%eax
801004de:	e8 da fe ff ff       	call   801003bd <cgaputc>
}
801004e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801004e6:	c9                   	leave  
801004e7:	c3                   	ret    
    uartputc('\b'); uartputc(' '); uartputc('\b');
801004e8:	83 ec 0c             	sub    $0xc,%esp
801004eb:	6a 08                	push   $0x8
801004ed:	e8 64 4c 00 00       	call   80105156 <uartputc>
801004f2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801004f9:	e8 58 4c 00 00       	call   80105156 <uartputc>
801004fe:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100505:	e8 4c 4c 00 00       	call   80105156 <uartputc>
8010050a:	83 c4 10             	add    $0x10,%esp
8010050d:	eb cd                	jmp    801004dc <consputc+0x28>

8010050f <printint>:
{
8010050f:	55                   	push   %ebp
80100510:	89 e5                	mov    %esp,%ebp
80100512:	57                   	push   %edi
80100513:	56                   	push   %esi
80100514:	53                   	push   %ebx
80100515:	83 ec 2c             	sub    $0x2c,%esp
80100518:	89 d6                	mov    %edx,%esi
8010051a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  if(sign && (sign = xx < 0))
8010051d:	85 c9                	test   %ecx,%ecx
8010051f:	74 0c                	je     8010052d <printint+0x1e>
80100521:	89 c7                	mov    %eax,%edi
80100523:	c1 ef 1f             	shr    $0x1f,%edi
80100526:	89 7d d4             	mov    %edi,-0x2c(%ebp)
80100529:	85 c0                	test   %eax,%eax
8010052b:	78 35                	js     80100562 <printint+0x53>
    x = xx;
8010052d:	89 c1                	mov    %eax,%ecx
  i = 0;
8010052f:	bb 00 00 00 00       	mov    $0x0,%ebx
    buf[i++] = digits[x % base];
80100534:	89 c8                	mov    %ecx,%eax
80100536:	ba 00 00 00 00       	mov    $0x0,%edx
8010053b:	f7 f6                	div    %esi
8010053d:	89 df                	mov    %ebx,%edi
8010053f:	43                   	inc    %ebx
80100540:	8a 92 90 67 10 80    	mov    -0x7fef9870(%edx),%dl
80100546:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
8010054a:	89 ca                	mov    %ecx,%edx
8010054c:	89 c1                	mov    %eax,%ecx
8010054e:	39 d6                	cmp    %edx,%esi
80100550:	76 e2                	jbe    80100534 <printint+0x25>
  if(sign)
80100552:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100556:	74 1a                	je     80100572 <printint+0x63>
    buf[i++] = '-';
80100558:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
8010055d:	8d 5f 02             	lea    0x2(%edi),%ebx
80100560:	eb 10                	jmp    80100572 <printint+0x63>
    x = -xx;
80100562:	f7 d8                	neg    %eax
80100564:	89 c1                	mov    %eax,%ecx
80100566:	eb c7                	jmp    8010052f <printint+0x20>
    consputc(buf[i]);
80100568:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
8010056d:	e8 42 ff ff ff       	call   801004b4 <consputc>
  while(--i >= 0)
80100572:	4b                   	dec    %ebx
80100573:	79 f3                	jns    80100568 <printint+0x59>
}
80100575:	83 c4 2c             	add    $0x2c,%esp
80100578:	5b                   	pop    %ebx
80100579:	5e                   	pop    %esi
8010057a:	5f                   	pop    %edi
8010057b:	5d                   	pop    %ebp
8010057c:	c3                   	ret    

8010057d <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
8010057d:	55                   	push   %ebp
8010057e:	89 e5                	mov    %esp,%ebp
80100580:	57                   	push   %edi
80100581:	56                   	push   %esi
80100582:	53                   	push   %ebx
80100583:	83 ec 18             	sub    $0x18,%esp
80100586:	8b 7d 0c             	mov    0xc(%ebp),%edi
80100589:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
8010058c:	ff 75 08             	push   0x8(%ebp)
8010058f:	e8 39 10 00 00       	call   801015cd <iunlock>
  acquire(&cons.lock);
80100594:	c7 04 24 20 ef 10 80 	movl   $0x8010ef20,(%esp)
8010059b:	e8 4f 35 00 00       	call   80103aef <acquire>
  for(i = 0; i < n; i++)
801005a0:	83 c4 10             	add    $0x10,%esp
801005a3:	bb 00 00 00 00       	mov    $0x0,%ebx
801005a8:	eb 0a                	jmp    801005b4 <consolewrite+0x37>
    consputc(buf[i] & 0xff);
801005aa:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801005ae:	e8 01 ff ff ff       	call   801004b4 <consputc>
  for(i = 0; i < n; i++)
801005b3:	43                   	inc    %ebx
801005b4:	39 f3                	cmp    %esi,%ebx
801005b6:	7c f2                	jl     801005aa <consolewrite+0x2d>
  release(&cons.lock);
801005b8:	83 ec 0c             	sub    $0xc,%esp
801005bb:	68 20 ef 10 80       	push   $0x8010ef20
801005c0:	e8 8f 35 00 00       	call   80103b54 <release>
  ilock(ip);
801005c5:	83 c4 04             	add    $0x4,%esp
801005c8:	ff 75 08             	push   0x8(%ebp)
801005cb:	e8 3d 0f 00 00       	call   8010150d <ilock>

  return n;
}
801005d0:	89 f0                	mov    %esi,%eax
801005d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801005d5:	5b                   	pop    %ebx
801005d6:	5e                   	pop    %esi
801005d7:	5f                   	pop    %edi
801005d8:	5d                   	pop    %ebp
801005d9:	c3                   	ret    

801005da <cprintf>:
{
801005da:	55                   	push   %ebp
801005db:	89 e5                	mov    %esp,%ebp
801005dd:	57                   	push   %edi
801005de:	56                   	push   %esi
801005df:	53                   	push   %ebx
801005e0:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
801005e3:	a1 54 ef 10 80       	mov    0x8010ef54,%eax
801005e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(locking)
801005eb:	85 c0                	test   %eax,%eax
801005ed:	75 10                	jne    801005ff <cprintf+0x25>
  if (fmt == 0)
801005ef:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801005f3:	74 1c                	je     80100611 <cprintf+0x37>
  argp = (uint*)(void*)(&fmt + 1);
801005f5:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801005f8:	be 00 00 00 00       	mov    $0x0,%esi
801005fd:	eb 25                	jmp    80100624 <cprintf+0x4a>
    acquire(&cons.lock);
801005ff:	83 ec 0c             	sub    $0xc,%esp
80100602:	68 20 ef 10 80       	push   $0x8010ef20
80100607:	e8 e3 34 00 00       	call   80103aef <acquire>
8010060c:	83 c4 10             	add    $0x10,%esp
8010060f:	eb de                	jmp    801005ef <cprintf+0x15>
    panic("null fmt");
80100611:	83 ec 0c             	sub    $0xc,%esp
80100614:	68 7f 67 10 80       	push   $0x8010677f
80100619:	e8 23 fd ff ff       	call   80100341 <panic>
      consputc(c);
8010061e:	e8 91 fe ff ff       	call   801004b4 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100623:	46                   	inc    %esi
80100624:	8b 55 08             	mov    0x8(%ebp),%edx
80100627:	0f b6 04 32          	movzbl (%edx,%esi,1),%eax
8010062b:	85 c0                	test   %eax,%eax
8010062d:	0f 84 ac 00 00 00    	je     801006df <cprintf+0x105>
    if(c != '%'){
80100633:	83 f8 25             	cmp    $0x25,%eax
80100636:	75 e6                	jne    8010061e <cprintf+0x44>
    c = fmt[++i] & 0xff;
80100638:	46                   	inc    %esi
80100639:	0f b6 1c 32          	movzbl (%edx,%esi,1),%ebx
    if(c == 0)
8010063d:	85 db                	test   %ebx,%ebx
8010063f:	0f 84 9a 00 00 00    	je     801006df <cprintf+0x105>
    switch(c){
80100645:	83 fb 70             	cmp    $0x70,%ebx
80100648:	74 2e                	je     80100678 <cprintf+0x9e>
8010064a:	7f 22                	jg     8010066e <cprintf+0x94>
8010064c:	83 fb 25             	cmp    $0x25,%ebx
8010064f:	74 69                	je     801006ba <cprintf+0xe0>
80100651:	83 fb 64             	cmp    $0x64,%ebx
80100654:	75 73                	jne    801006c9 <cprintf+0xef>
      printint(*argp++, 10, 1);
80100656:	8d 5f 04             	lea    0x4(%edi),%ebx
80100659:	8b 07                	mov    (%edi),%eax
8010065b:	b9 01 00 00 00       	mov    $0x1,%ecx
80100660:	ba 0a 00 00 00       	mov    $0xa,%edx
80100665:	e8 a5 fe ff ff       	call   8010050f <printint>
8010066a:	89 df                	mov    %ebx,%edi
      break;
8010066c:	eb b5                	jmp    80100623 <cprintf+0x49>
    switch(c){
8010066e:	83 fb 73             	cmp    $0x73,%ebx
80100671:	74 1d                	je     80100690 <cprintf+0xb6>
80100673:	83 fb 78             	cmp    $0x78,%ebx
80100676:	75 51                	jne    801006c9 <cprintf+0xef>
      printint(*argp++, 16, 0);
80100678:	8d 5f 04             	lea    0x4(%edi),%ebx
8010067b:	8b 07                	mov    (%edi),%eax
8010067d:	b9 00 00 00 00       	mov    $0x0,%ecx
80100682:	ba 10 00 00 00       	mov    $0x10,%edx
80100687:	e8 83 fe ff ff       	call   8010050f <printint>
8010068c:	89 df                	mov    %ebx,%edi
      break;
8010068e:	eb 93                	jmp    80100623 <cprintf+0x49>
      if((s = (char*)*argp++) == 0)
80100690:	8d 47 04             	lea    0x4(%edi),%eax
80100693:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100696:	8b 1f                	mov    (%edi),%ebx
80100698:	85 db                	test   %ebx,%ebx
8010069a:	75 10                	jne    801006ac <cprintf+0xd2>
        s = "(null)";
8010069c:	bb 78 67 10 80       	mov    $0x80106778,%ebx
801006a1:	eb 09                	jmp    801006ac <cprintf+0xd2>
        consputc(*s);
801006a3:	0f be c0             	movsbl %al,%eax
801006a6:	e8 09 fe ff ff       	call   801004b4 <consputc>
      for(; *s; s++)
801006ab:	43                   	inc    %ebx
801006ac:	8a 03                	mov    (%ebx),%al
801006ae:	84 c0                	test   %al,%al
801006b0:	75 f1                	jne    801006a3 <cprintf+0xc9>
      if((s = (char*)*argp++) == 0)
801006b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801006b5:	e9 69 ff ff ff       	jmp    80100623 <cprintf+0x49>
      consputc('%');
801006ba:	b8 25 00 00 00       	mov    $0x25,%eax
801006bf:	e8 f0 fd ff ff       	call   801004b4 <consputc>
      break;
801006c4:	e9 5a ff ff ff       	jmp    80100623 <cprintf+0x49>
      consputc('%');
801006c9:	b8 25 00 00 00       	mov    $0x25,%eax
801006ce:	e8 e1 fd ff ff       	call   801004b4 <consputc>
      consputc(c);
801006d3:	89 d8                	mov    %ebx,%eax
801006d5:	e8 da fd ff ff       	call   801004b4 <consputc>
      break;
801006da:	e9 44 ff ff ff       	jmp    80100623 <cprintf+0x49>
  if(locking)
801006df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801006e3:	75 08                	jne    801006ed <cprintf+0x113>
}
801006e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801006e8:	5b                   	pop    %ebx
801006e9:	5e                   	pop    %esi
801006ea:	5f                   	pop    %edi
801006eb:	5d                   	pop    %ebp
801006ec:	c3                   	ret    
    release(&cons.lock);
801006ed:	83 ec 0c             	sub    $0xc,%esp
801006f0:	68 20 ef 10 80       	push   $0x8010ef20
801006f5:	e8 5a 34 00 00       	call   80103b54 <release>
801006fa:	83 c4 10             	add    $0x10,%esp
}
801006fd:	eb e6                	jmp    801006e5 <cprintf+0x10b>

801006ff <consoleintr>:
{
801006ff:	55                   	push   %ebp
80100700:	89 e5                	mov    %esp,%ebp
80100702:	57                   	push   %edi
80100703:	56                   	push   %esi
80100704:	53                   	push   %ebx
80100705:	83 ec 18             	sub    $0x18,%esp
80100708:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&cons.lock);
8010070b:	68 20 ef 10 80       	push   $0x8010ef20
80100710:	e8 da 33 00 00       	call   80103aef <acquire>
  while((c = getc()) >= 0){
80100715:	83 c4 10             	add    $0x10,%esp
  int c, doprocdump = 0;
80100718:	be 00 00 00 00       	mov    $0x0,%esi
  while((c = getc()) >= 0){
8010071d:	eb 13                	jmp    80100732 <consoleintr+0x33>
    switch(c){
8010071f:	83 ff 08             	cmp    $0x8,%edi
80100722:	0f 84 d1 00 00 00    	je     801007f9 <consoleintr+0xfa>
80100728:	83 ff 10             	cmp    $0x10,%edi
8010072b:	75 25                	jne    80100752 <consoleintr+0x53>
8010072d:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
80100732:	ff d3                	call   *%ebx
80100734:	89 c7                	mov    %eax,%edi
80100736:	85 c0                	test   %eax,%eax
80100738:	0f 88 eb 00 00 00    	js     80100829 <consoleintr+0x12a>
    switch(c){
8010073e:	83 ff 15             	cmp    $0x15,%edi
80100741:	0f 84 8d 00 00 00    	je     801007d4 <consoleintr+0xd5>
80100747:	7e d6                	jle    8010071f <consoleintr+0x20>
80100749:	83 ff 7f             	cmp    $0x7f,%edi
8010074c:	0f 84 a7 00 00 00    	je     801007f9 <consoleintr+0xfa>
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100752:	85 ff                	test   %edi,%edi
80100754:	74 dc                	je     80100732 <consoleintr+0x33>
80100756:	a1 08 ef 10 80       	mov    0x8010ef08,%eax
8010075b:	89 c2                	mov    %eax,%edx
8010075d:	2b 15 00 ef 10 80    	sub    0x8010ef00,%edx
80100763:	83 fa 7f             	cmp    $0x7f,%edx
80100766:	77 ca                	ja     80100732 <consoleintr+0x33>
        c = (c == '\r') ? '\n' : c;
80100768:	83 ff 0d             	cmp    $0xd,%edi
8010076b:	0f 84 ae 00 00 00    	je     8010081f <consoleintr+0x120>
        input.buf[input.e++ % INPUT_BUF] = c;
80100771:	8d 50 01             	lea    0x1(%eax),%edx
80100774:	89 15 08 ef 10 80    	mov    %edx,0x8010ef08
8010077a:	83 e0 7f             	and    $0x7f,%eax
8010077d:	89 f9                	mov    %edi,%ecx
8010077f:	88 88 80 ee 10 80    	mov    %cl,-0x7fef1180(%eax)
        consputc(c);
80100785:	89 f8                	mov    %edi,%eax
80100787:	e8 28 fd ff ff       	call   801004b4 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010078c:	83 ff 0a             	cmp    $0xa,%edi
8010078f:	74 15                	je     801007a6 <consoleintr+0xa7>
80100791:	83 ff 04             	cmp    $0x4,%edi
80100794:	74 10                	je     801007a6 <consoleintr+0xa7>
80100796:	a1 00 ef 10 80       	mov    0x8010ef00,%eax
8010079b:	83 e8 80             	sub    $0xffffff80,%eax
8010079e:	39 05 08 ef 10 80    	cmp    %eax,0x8010ef08
801007a4:	75 8c                	jne    80100732 <consoleintr+0x33>
          input.w = input.e;
801007a6:	a1 08 ef 10 80       	mov    0x8010ef08,%eax
801007ab:	a3 04 ef 10 80       	mov    %eax,0x8010ef04
          wakeup(&input.r);
801007b0:	83 ec 0c             	sub    $0xc,%esp
801007b3:	68 00 ef 10 80       	push   $0x8010ef00
801007b8:	e8 9e 2f 00 00       	call   8010375b <wakeup>
801007bd:	83 c4 10             	add    $0x10,%esp
801007c0:	e9 6d ff ff ff       	jmp    80100732 <consoleintr+0x33>
        input.e--;
801007c5:	a3 08 ef 10 80       	mov    %eax,0x8010ef08
        consputc(BACKSPACE);
801007ca:	b8 00 01 00 00       	mov    $0x100,%eax
801007cf:	e8 e0 fc ff ff       	call   801004b4 <consputc>
      while(input.e != input.w &&
801007d4:	a1 08 ef 10 80       	mov    0x8010ef08,%eax
801007d9:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
801007df:	0f 84 4d ff ff ff    	je     80100732 <consoleintr+0x33>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801007e5:	48                   	dec    %eax
801007e6:	89 c2                	mov    %eax,%edx
801007e8:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
801007eb:	80 ba 80 ee 10 80 0a 	cmpb   $0xa,-0x7fef1180(%edx)
801007f2:	75 d1                	jne    801007c5 <consoleintr+0xc6>
801007f4:	e9 39 ff ff ff       	jmp    80100732 <consoleintr+0x33>
      if(input.e != input.w){
801007f9:	a1 08 ef 10 80       	mov    0x8010ef08,%eax
801007fe:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
80100804:	0f 84 28 ff ff ff    	je     80100732 <consoleintr+0x33>
        input.e--;
8010080a:	48                   	dec    %eax
8010080b:	a3 08 ef 10 80       	mov    %eax,0x8010ef08
        consputc(BACKSPACE);
80100810:	b8 00 01 00 00       	mov    $0x100,%eax
80100815:	e8 9a fc ff ff       	call   801004b4 <consputc>
8010081a:	e9 13 ff ff ff       	jmp    80100732 <consoleintr+0x33>
        c = (c == '\r') ? '\n' : c;
8010081f:	bf 0a 00 00 00       	mov    $0xa,%edi
80100824:	e9 48 ff ff ff       	jmp    80100771 <consoleintr+0x72>
  release(&cons.lock);
80100829:	83 ec 0c             	sub    $0xc,%esp
8010082c:	68 20 ef 10 80       	push   $0x8010ef20
80100831:	e8 1e 33 00 00       	call   80103b54 <release>
  if(doprocdump) {
80100836:	83 c4 10             	add    $0x10,%esp
80100839:	85 f6                	test   %esi,%esi
8010083b:	75 08                	jne    80100845 <consoleintr+0x146>
}
8010083d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100840:	5b                   	pop    %ebx
80100841:	5e                   	pop    %esi
80100842:	5f                   	pop    %edi
80100843:	5d                   	pop    %ebp
80100844:	c3                   	ret    
    procdump();  // now call procdump() wo. cons.lock held
80100845:	e8 b0 2f 00 00       	call   801037fa <procdump>
}
8010084a:	eb f1                	jmp    8010083d <consoleintr+0x13e>

8010084c <consoleinit>:

void
consoleinit(void)
{
8010084c:	55                   	push   %ebp
8010084d:	89 e5                	mov    %esp,%ebp
8010084f:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100852:	68 88 67 10 80       	push   $0x80106788
80100857:	68 20 ef 10 80       	push   $0x8010ef20
8010085c:	e8 57 31 00 00       	call   801039b8 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100861:	c7 05 0c f9 10 80 7d 	movl   $0x8010057d,0x8010f90c
80100868:	05 10 80 
  devsw[CONSOLE].read = consoleread;
8010086b:	c7 05 08 f9 10 80 64 	movl   $0x80100264,0x8010f908
80100872:	02 10 80 
  cons.locking = 1;
80100875:	c7 05 54 ef 10 80 01 	movl   $0x1,0x8010ef54
8010087c:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
8010087f:	83 c4 08             	add    $0x8,%esp
80100882:	6a 00                	push   $0x0
80100884:	6a 01                	push   $0x1
80100886:	e8 61 16 00 00       	call   80101eec <ioapicenable>
}
8010088b:	83 c4 10             	add    $0x10,%esp
8010088e:	c9                   	leave  
8010088f:	c3                   	ret    

80100890 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100890:	55                   	push   %ebp
80100891:	89 e5                	mov    %esp,%ebp
80100893:	57                   	push   %edi
80100894:	56                   	push   %esi
80100895:	53                   	push   %ebx
80100896:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
8010089c:	e8 85 28 00 00       	call   80103126 <myproc>
801008a1:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
801008a7:	e8 37 1e 00 00       	call   801026e3 <begin_op>

  if((ip = namei(path)) == 0){
801008ac:	83 ec 0c             	sub    $0xc,%esp
801008af:	ff 75 08             	push   0x8(%ebp)
801008b2:	e8 ba 12 00 00       	call   80101b71 <namei>
801008b7:	83 c4 10             	add    $0x10,%esp
801008ba:	85 c0                	test   %eax,%eax
801008bc:	74 56                	je     80100914 <exec+0x84>
801008be:	89 c3                	mov    %eax,%ebx
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
801008c0:	83 ec 0c             	sub    $0xc,%esp
801008c3:	50                   	push   %eax
801008c4:	e8 44 0c 00 00       	call   8010150d <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
801008c9:	6a 34                	push   $0x34
801008cb:	6a 00                	push   $0x0
801008cd:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
801008d3:	50                   	push   %eax
801008d4:	53                   	push   %ebx
801008d5:	e8 20 0e 00 00       	call   801016fa <readi>
801008da:	83 c4 20             	add    $0x20,%esp
801008dd:	83 f8 34             	cmp    $0x34,%eax
801008e0:	75 0c                	jne    801008ee <exec+0x5e>
    goto bad;
  if(elf.magic != ELF_MAGIC)
801008e2:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
801008e9:	45 4c 46 
801008ec:	74 42                	je     80100930 <exec+0xa0>
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir, 1);
  if(ip){
801008ee:	85 db                	test   %ebx,%ebx
801008f0:	0f 84 d3 02 00 00    	je     80100bc9 <exec+0x339>
    iunlockput(ip);
801008f6:	83 ec 0c             	sub    $0xc,%esp
801008f9:	53                   	push   %ebx
801008fa:	e8 b1 0d 00 00       	call   801016b0 <iunlockput>
    end_op();
801008ff:	e8 5b 1e 00 00       	call   8010275f <end_op>
80100904:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80100907:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010090c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010090f:	5b                   	pop    %ebx
80100910:	5e                   	pop    %esi
80100911:	5f                   	pop    %edi
80100912:	5d                   	pop    %ebp
80100913:	c3                   	ret    
    end_op();
80100914:	e8 46 1e 00 00       	call   8010275f <end_op>
    cprintf("exec: fail\n");
80100919:	83 ec 0c             	sub    $0xc,%esp
8010091c:	68 a1 67 10 80       	push   $0x801067a1
80100921:	e8 b4 fc ff ff       	call   801005da <cprintf>
    return -1;
80100926:	83 c4 10             	add    $0x10,%esp
80100929:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010092e:	eb dc                	jmp    8010090c <exec+0x7c>
  if((pgdir = setupkvm()) == 0)
80100930:	e8 91 5b 00 00       	call   801064c6 <setupkvm>
80100935:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
8010093b:	85 c0                	test   %eax,%eax
8010093d:	0f 84 14 01 00 00    	je     80100a57 <exec+0x1c7>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100943:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  sz = 0;
80100949:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
80100950:	00 00 00 
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100953:	be 00 00 00 00       	mov    $0x0,%esi
80100958:	eb 04                	jmp    8010095e <exec+0xce>
8010095a:	46                   	inc    %esi
8010095b:	8d 47 20             	lea    0x20(%edi),%eax
8010095e:	0f b7 95 50 ff ff ff 	movzwl -0xb0(%ebp),%edx
80100965:	39 f2                	cmp    %esi,%edx
80100967:	0f 8e a1 00 00 00    	jle    80100a0e <exec+0x17e>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
8010096d:	89 c7                	mov    %eax,%edi
8010096f:	6a 20                	push   $0x20
80100971:	50                   	push   %eax
80100972:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100978:	50                   	push   %eax
80100979:	53                   	push   %ebx
8010097a:	e8 7b 0d 00 00       	call   801016fa <readi>
8010097f:	83 c4 10             	add    $0x10,%esp
80100982:	83 f8 20             	cmp    $0x20,%eax
80100985:	0f 85 cc 00 00 00    	jne    80100a57 <exec+0x1c7>
    if(ph.type != ELF_PROG_LOAD || ph.memsz == 0)
8010098b:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100992:	75 c6                	jne    8010095a <exec+0xca>
80100994:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
8010099a:	85 c0                	test   %eax,%eax
8010099c:	74 bc                	je     8010095a <exec+0xca>
    if(ph.memsz < ph.filesz)
8010099e:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
801009a4:	0f 82 ad 00 00 00    	jb     80100a57 <exec+0x1c7>
    if(ph.vaddr + ph.memsz < ph.vaddr)
801009aa:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
801009b0:	0f 82 a1 00 00 00    	jb     80100a57 <exec+0x1c7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
801009b6:	83 ec 04             	sub    $0x4,%esp
801009b9:	50                   	push   %eax
801009ba:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
801009c0:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
801009c6:	e8 98 59 00 00       	call   80106363 <allocuvm>
801009cb:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
801009d1:	83 c4 10             	add    $0x10,%esp
801009d4:	85 c0                	test   %eax,%eax
801009d6:	74 7f                	je     80100a57 <exec+0x1c7>
    if(ph.vaddr % PGSIZE != 0)
801009d8:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
801009de:	a9 ff 0f 00 00       	test   $0xfff,%eax
801009e3:	75 72                	jne    80100a57 <exec+0x1c7>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
801009e5:	83 ec 0c             	sub    $0xc,%esp
801009e8:	ff b5 14 ff ff ff    	push   -0xec(%ebp)
801009ee:	ff b5 08 ff ff ff    	push   -0xf8(%ebp)
801009f4:	53                   	push   %ebx
801009f5:	50                   	push   %eax
801009f6:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
801009fc:	e8 38 58 00 00       	call   80106239 <loaduvm>
80100a01:	83 c4 20             	add    $0x20,%esp
80100a04:	85 c0                	test   %eax,%eax
80100a06:	0f 89 4e ff ff ff    	jns    8010095a <exec+0xca>
80100a0c:	eb 49                	jmp    80100a57 <exec+0x1c7>
  iunlockput(ip);
80100a0e:	83 ec 0c             	sub    $0xc,%esp
80100a11:	53                   	push   %ebx
80100a12:	e8 99 0c 00 00       	call   801016b0 <iunlockput>
  end_op();
80100a17:	e8 43 1d 00 00       	call   8010275f <end_op>
  sz = PGROUNDUP(sz);
80100a1c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100a22:	05 ff 0f 00 00       	add    $0xfff,%eax
80100a27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
 if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a2c:	83 c4 0c             	add    $0xc,%esp
80100a2f:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a35:	52                   	push   %edx
80100a36:	50                   	push   %eax
80100a37:	8b bd f4 fe ff ff    	mov    -0x10c(%ebp),%edi
80100a3d:	57                   	push   %edi
80100a3e:	e8 20 59 00 00       	call   80106363 <allocuvm>
80100a43:	89 c6                	mov    %eax,%esi
80100a45:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100a4b:	83 c4 10             	add    $0x10,%esp
80100a4e:	85 c0                	test   %eax,%eax
80100a50:	75 26                	jne    80100a78 <exec+0x1e8>
  ip = 0;
80100a52:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(pgdir)
80100a57:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100a5d:	85 c0                	test   %eax,%eax
80100a5f:	0f 84 89 fe ff ff    	je     801008ee <exec+0x5e>
    freevm(pgdir, 1);
80100a65:	83 ec 08             	sub    $0x8,%esp
80100a68:	6a 01                	push   $0x1
80100a6a:	50                   	push   %eax
80100a6b:	e8 e0 59 00 00       	call   80106450 <freevm>
80100a70:	83 c4 10             	add    $0x10,%esp
80100a73:	e9 76 fe ff ff       	jmp    801008ee <exec+0x5e>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100a78:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100a7e:	83 ec 08             	sub    $0x8,%esp
80100a81:	50                   	push   %eax
80100a82:	57                   	push   %edi
80100a83:	e8 c5 5a 00 00       	call   8010654d <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100a88:	83 c4 10             	add    $0x10,%esp
80100a8b:	bf 00 00 00 00       	mov    $0x0,%edi
80100a90:	eb 08                	jmp    80100a9a <exec+0x20a>
    ustack[3+argc] = sp;
80100a92:	89 b4 bd 64 ff ff ff 	mov    %esi,-0x9c(%ebp,%edi,4)
  for(argc = 0; argv[argc]; argc++) {
80100a99:	47                   	inc    %edi
80100a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a9d:	8d 1c b8             	lea    (%eax,%edi,4),%ebx
80100aa0:	8b 03                	mov    (%ebx),%eax
80100aa2:	85 c0                	test   %eax,%eax
80100aa4:	74 43                	je     80100ae9 <exec+0x259>
    if(argc >= MAXARG)
80100aa6:	83 ff 1f             	cmp    $0x1f,%edi
80100aa9:	0f 87 10 01 00 00    	ja     80100bbf <exec+0x32f>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100aaf:	83 ec 0c             	sub    $0xc,%esp
80100ab2:	50                   	push   %eax
80100ab3:	e8 73 32 00 00       	call   80103d2b <strlen>
80100ab8:	29 c6                	sub    %eax,%esi
80100aba:	4e                   	dec    %esi
80100abb:	83 e6 fc             	and    $0xfffffffc,%esi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100abe:	83 c4 04             	add    $0x4,%esp
80100ac1:	ff 33                	push   (%ebx)
80100ac3:	e8 63 32 00 00       	call   80103d2b <strlen>
80100ac8:	40                   	inc    %eax
80100ac9:	50                   	push   %eax
80100aca:	ff 33                	push   (%ebx)
80100acc:	56                   	push   %esi
80100acd:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100ad3:	e8 c5 5b 00 00       	call   8010669d <copyout>
80100ad8:	83 c4 20             	add    $0x20,%esp
80100adb:	85 c0                	test   %eax,%eax
80100add:	79 b3                	jns    80100a92 <exec+0x202>
  ip = 0;
80100adf:	bb 00 00 00 00       	mov    $0x0,%ebx
80100ae4:	e9 6e ff ff ff       	jmp    80100a57 <exec+0x1c7>
  ustack[3+argc] = 0;
80100ae9:	89 f1                	mov    %esi,%ecx
80100aeb:	89 c3                	mov    %eax,%ebx
80100aed:	c7 84 bd 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%edi,4)
80100af4:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80100af8:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100aff:	ff ff ff 
  ustack[1] = argc;
80100b02:	89 bd 5c ff ff ff    	mov    %edi,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b08:	8d 14 bd 04 00 00 00 	lea    0x4(,%edi,4),%edx
80100b0f:	89 f0                	mov    %esi,%eax
80100b11:	29 d0                	sub    %edx,%eax
80100b13:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  sp -= (3+argc+1) * 4;
80100b19:	8d 04 bd 10 00 00 00 	lea    0x10(,%edi,4),%eax
80100b20:	29 c1                	sub    %eax,%ecx
80100b22:	89 ce                	mov    %ecx,%esi
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b24:	50                   	push   %eax
80100b25:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100b2b:	50                   	push   %eax
80100b2c:	51                   	push   %ecx
80100b2d:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100b33:	e8 65 5b 00 00       	call   8010669d <copyout>
80100b38:	83 c4 10             	add    $0x10,%esp
80100b3b:	85 c0                	test   %eax,%eax
80100b3d:	0f 88 14 ff ff ff    	js     80100a57 <exec+0x1c7>
  for(last=s=path; *s; s++)
80100b43:	8b 55 08             	mov    0x8(%ebp),%edx
80100b46:	89 d0                	mov    %edx,%eax
80100b48:	eb 01                	jmp    80100b4b <exec+0x2bb>
80100b4a:	40                   	inc    %eax
80100b4b:	8a 08                	mov    (%eax),%cl
80100b4d:	84 c9                	test   %cl,%cl
80100b4f:	74 0a                	je     80100b5b <exec+0x2cb>
    if(*s == '/')
80100b51:	80 f9 2f             	cmp    $0x2f,%cl
80100b54:	75 f4                	jne    80100b4a <exec+0x2ba>
      last = s+1;
80100b56:	8d 50 01             	lea    0x1(%eax),%edx
80100b59:	eb ef                	jmp    80100b4a <exec+0x2ba>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100b5b:	8b bd ec fe ff ff    	mov    -0x114(%ebp),%edi
80100b61:	89 f8                	mov    %edi,%eax
80100b63:	83 c0 74             	add    $0x74,%eax
80100b66:	83 ec 04             	sub    $0x4,%esp
80100b69:	6a 10                	push   $0x10
80100b6b:	52                   	push   %edx
80100b6c:	50                   	push   %eax
80100b6d:	e8 81 31 00 00       	call   80103cf3 <safestrcpy>
  oldpgdir = curproc->pgdir;
80100b72:	8b 5f 0c             	mov    0xc(%edi),%ebx
  curproc->pgdir = pgdir;
80100b75:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100b7b:	89 4f 0c             	mov    %ecx,0xc(%edi)
  curproc->sz = sz;
80100b7e:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100b84:	89 4f 08             	mov    %ecx,0x8(%edi)
  curproc->tf->eip = elf.entry;  // main
80100b87:	8b 47 20             	mov    0x20(%edi),%eax
80100b8a:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100b90:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100b93:	8b 47 20             	mov    0x20(%edi),%eax
80100b96:	89 70 44             	mov    %esi,0x44(%eax)
  curproc->numpages = 0;
80100b99:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	switchuvm(curproc);
80100b9f:	89 3c 24             	mov    %edi,(%esp)
80100ba2:	e8 ce 54 00 00       	call   80106075 <switchuvm>
  freevm(oldpgdir, 1);
80100ba7:	83 c4 08             	add    $0x8,%esp
80100baa:	6a 01                	push   $0x1
80100bac:	53                   	push   %ebx
80100bad:	e8 9e 58 00 00       	call   80106450 <freevm>
  return 0;
80100bb2:	83 c4 10             	add    $0x10,%esp
80100bb5:	b8 00 00 00 00       	mov    $0x0,%eax
80100bba:	e9 4d fd ff ff       	jmp    8010090c <exec+0x7c>
  ip = 0;
80100bbf:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bc4:	e9 8e fe ff ff       	jmp    80100a57 <exec+0x1c7>
  return -1;
80100bc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bce:	e9 39 fd ff ff       	jmp    8010090c <exec+0x7c>

80100bd3 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100bd3:	55                   	push   %ebp
80100bd4:	89 e5                	mov    %esp,%ebp
80100bd6:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100bd9:	68 ad 67 10 80       	push   $0x801067ad
80100bde:	68 60 ef 10 80       	push   $0x8010ef60
80100be3:	e8 d0 2d 00 00       	call   801039b8 <initlock>
}
80100be8:	83 c4 10             	add    $0x10,%esp
80100beb:	c9                   	leave  
80100bec:	c3                   	ret    

80100bed <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100bed:	55                   	push   %ebp
80100bee:	89 e5                	mov    %esp,%ebp
80100bf0:	53                   	push   %ebx
80100bf1:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100bf4:	68 60 ef 10 80       	push   $0x8010ef60
80100bf9:	e8 f1 2e 00 00       	call   80103aef <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100bfe:	83 c4 10             	add    $0x10,%esp
80100c01:	bb 94 ef 10 80       	mov    $0x8010ef94,%ebx
80100c06:	81 fb f4 f8 10 80    	cmp    $0x8010f8f4,%ebx
80100c0c:	73 29                	jae    80100c37 <filealloc+0x4a>
    if(f->ref == 0){
80100c0e:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c12:	74 05                	je     80100c19 <filealloc+0x2c>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c14:	83 c3 18             	add    $0x18,%ebx
80100c17:	eb ed                	jmp    80100c06 <filealloc+0x19>
      f->ref = 1;
80100c19:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100c20:	83 ec 0c             	sub    $0xc,%esp
80100c23:	68 60 ef 10 80       	push   $0x8010ef60
80100c28:	e8 27 2f 00 00       	call   80103b54 <release>
      return f;
80100c2d:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100c30:	89 d8                	mov    %ebx,%eax
80100c32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c35:	c9                   	leave  
80100c36:	c3                   	ret    
  release(&ftable.lock);
80100c37:	83 ec 0c             	sub    $0xc,%esp
80100c3a:	68 60 ef 10 80       	push   $0x8010ef60
80100c3f:	e8 10 2f 00 00       	call   80103b54 <release>
  return 0;
80100c44:	83 c4 10             	add    $0x10,%esp
80100c47:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c4c:	eb e2                	jmp    80100c30 <filealloc+0x43>

80100c4e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100c4e:	55                   	push   %ebp
80100c4f:	89 e5                	mov    %esp,%ebp
80100c51:	53                   	push   %ebx
80100c52:	83 ec 10             	sub    $0x10,%esp
80100c55:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100c58:	68 60 ef 10 80       	push   $0x8010ef60
80100c5d:	e8 8d 2e 00 00       	call   80103aef <acquire>
  if(f->ref < 1)
80100c62:	8b 43 04             	mov    0x4(%ebx),%eax
80100c65:	83 c4 10             	add    $0x10,%esp
80100c68:	85 c0                	test   %eax,%eax
80100c6a:	7e 18                	jle    80100c84 <filedup+0x36>
    panic("filedup");
  f->ref++;
80100c6c:	40                   	inc    %eax
80100c6d:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100c70:	83 ec 0c             	sub    $0xc,%esp
80100c73:	68 60 ef 10 80       	push   $0x8010ef60
80100c78:	e8 d7 2e 00 00       	call   80103b54 <release>
  return f;
}
80100c7d:	89 d8                	mov    %ebx,%eax
80100c7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c82:	c9                   	leave  
80100c83:	c3                   	ret    
    panic("filedup");
80100c84:	83 ec 0c             	sub    $0xc,%esp
80100c87:	68 b4 67 10 80       	push   $0x801067b4
80100c8c:	e8 b0 f6 ff ff       	call   80100341 <panic>

80100c91 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100c91:	55                   	push   %ebp
80100c92:	89 e5                	mov    %esp,%ebp
80100c94:	57                   	push   %edi
80100c95:	56                   	push   %esi
80100c96:	53                   	push   %ebx
80100c97:	83 ec 38             	sub    $0x38,%esp
80100c9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100c9d:	68 60 ef 10 80       	push   $0x8010ef60
80100ca2:	e8 48 2e 00 00       	call   80103aef <acquire>
  if(f->ref < 1)
80100ca7:	8b 43 04             	mov    0x4(%ebx),%eax
80100caa:	83 c4 10             	add    $0x10,%esp
80100cad:	85 c0                	test   %eax,%eax
80100caf:	7e 58                	jle    80100d09 <fileclose+0x78>
    panic("fileclose");
  if(--f->ref > 0){
80100cb1:	48                   	dec    %eax
80100cb2:	89 43 04             	mov    %eax,0x4(%ebx)
80100cb5:	85 c0                	test   %eax,%eax
80100cb7:	7f 5d                	jg     80100d16 <fileclose+0x85>
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100cb9:	8d 7d d0             	lea    -0x30(%ebp),%edi
80100cbc:	b9 06 00 00 00       	mov    $0x6,%ecx
80100cc1:	89 de                	mov    %ebx,%esi
80100cc3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  f->ref = 0;
80100cc5:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100ccc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100cd2:	83 ec 0c             	sub    $0xc,%esp
80100cd5:	68 60 ef 10 80       	push   $0x8010ef60
80100cda:	e8 75 2e 00 00       	call   80103b54 <release>

  if(ff.type == FD_PIPE)
80100cdf:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ce2:	83 c4 10             	add    $0x10,%esp
80100ce5:	83 f8 01             	cmp    $0x1,%eax
80100ce8:	74 44                	je     80100d2e <fileclose+0x9d>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80100cea:	83 f8 02             	cmp    $0x2,%eax
80100ced:	75 37                	jne    80100d26 <fileclose+0x95>
    begin_op();
80100cef:	e8 ef 19 00 00       	call   801026e3 <begin_op>
    iput(ff.ip);
80100cf4:	83 ec 0c             	sub    $0xc,%esp
80100cf7:	ff 75 e0             	push   -0x20(%ebp)
80100cfa:	e8 13 09 00 00       	call   80101612 <iput>
    end_op();
80100cff:	e8 5b 1a 00 00       	call   8010275f <end_op>
80100d04:	83 c4 10             	add    $0x10,%esp
80100d07:	eb 1d                	jmp    80100d26 <fileclose+0x95>
    panic("fileclose");
80100d09:	83 ec 0c             	sub    $0xc,%esp
80100d0c:	68 bc 67 10 80       	push   $0x801067bc
80100d11:	e8 2b f6 ff ff       	call   80100341 <panic>
    release(&ftable.lock);
80100d16:	83 ec 0c             	sub    $0xc,%esp
80100d19:	68 60 ef 10 80       	push   $0x8010ef60
80100d1e:	e8 31 2e 00 00       	call   80103b54 <release>
    return;
80100d23:	83 c4 10             	add    $0x10,%esp
  }
}
80100d26:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100d29:	5b                   	pop    %ebx
80100d2a:	5e                   	pop    %esi
80100d2b:	5f                   	pop    %edi
80100d2c:	5d                   	pop    %ebp
80100d2d:	c3                   	ret    
    pipeclose(ff.pipe, ff.writable);
80100d2e:	83 ec 08             	sub    $0x8,%esp
80100d31:	0f be 45 d9          	movsbl -0x27(%ebp),%eax
80100d35:	50                   	push   %eax
80100d36:	ff 75 dc             	push   -0x24(%ebp)
80100d39:	e8 06 20 00 00       	call   80102d44 <pipeclose>
80100d3e:	83 c4 10             	add    $0x10,%esp
80100d41:	eb e3                	jmp    80100d26 <fileclose+0x95>

80100d43 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100d43:	55                   	push   %ebp
80100d44:	89 e5                	mov    %esp,%ebp
80100d46:	53                   	push   %ebx
80100d47:	83 ec 04             	sub    $0x4,%esp
80100d4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100d4d:	83 3b 02             	cmpl   $0x2,(%ebx)
80100d50:	75 31                	jne    80100d83 <filestat+0x40>
    ilock(f->ip);
80100d52:	83 ec 0c             	sub    $0xc,%esp
80100d55:	ff 73 10             	push   0x10(%ebx)
80100d58:	e8 b0 07 00 00       	call   8010150d <ilock>
    stati(f->ip, st);
80100d5d:	83 c4 08             	add    $0x8,%esp
80100d60:	ff 75 0c             	push   0xc(%ebp)
80100d63:	ff 73 10             	push   0x10(%ebx)
80100d66:	e8 65 09 00 00       	call   801016d0 <stati>
    iunlock(f->ip);
80100d6b:	83 c4 04             	add    $0x4,%esp
80100d6e:	ff 73 10             	push   0x10(%ebx)
80100d71:	e8 57 08 00 00       	call   801015cd <iunlock>
    return 0;
80100d76:	83 c4 10             	add    $0x10,%esp
80100d79:	b8 00 00 00 00       	mov    $0x0,%eax
  }
  return -1;
}
80100d7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d81:	c9                   	leave  
80100d82:	c3                   	ret    
  return -1;
80100d83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100d88:	eb f4                	jmp    80100d7e <filestat+0x3b>

80100d8a <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100d8a:	55                   	push   %ebp
80100d8b:	89 e5                	mov    %esp,%ebp
80100d8d:	56                   	push   %esi
80100d8e:	53                   	push   %ebx
80100d8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100d92:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100d96:	74 70                	je     80100e08 <fileread+0x7e>
    return -1;
  if(f->type == FD_PIPE)
80100d98:	8b 03                	mov    (%ebx),%eax
80100d9a:	83 f8 01             	cmp    $0x1,%eax
80100d9d:	74 44                	je     80100de3 <fileread+0x59>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100d9f:	83 f8 02             	cmp    $0x2,%eax
80100da2:	75 57                	jne    80100dfb <fileread+0x71>
    ilock(f->ip);
80100da4:	83 ec 0c             	sub    $0xc,%esp
80100da7:	ff 73 10             	push   0x10(%ebx)
80100daa:	e8 5e 07 00 00       	call   8010150d <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100daf:	ff 75 10             	push   0x10(%ebp)
80100db2:	ff 73 14             	push   0x14(%ebx)
80100db5:	ff 75 0c             	push   0xc(%ebp)
80100db8:	ff 73 10             	push   0x10(%ebx)
80100dbb:	e8 3a 09 00 00       	call   801016fa <readi>
80100dc0:	89 c6                	mov    %eax,%esi
80100dc2:	83 c4 20             	add    $0x20,%esp
80100dc5:	85 c0                	test   %eax,%eax
80100dc7:	7e 03                	jle    80100dcc <fileread+0x42>
      f->off += r;
80100dc9:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100dcc:	83 ec 0c             	sub    $0xc,%esp
80100dcf:	ff 73 10             	push   0x10(%ebx)
80100dd2:	e8 f6 07 00 00       	call   801015cd <iunlock>
    return r;
80100dd7:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100dda:	89 f0                	mov    %esi,%eax
80100ddc:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100ddf:	5b                   	pop    %ebx
80100de0:	5e                   	pop    %esi
80100de1:	5d                   	pop    %ebp
80100de2:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100de3:	83 ec 04             	sub    $0x4,%esp
80100de6:	ff 75 10             	push   0x10(%ebp)
80100de9:	ff 75 0c             	push   0xc(%ebp)
80100dec:	ff 73 0c             	push   0xc(%ebx)
80100def:	e8 9e 20 00 00       	call   80102e92 <piperead>
80100df4:	89 c6                	mov    %eax,%esi
80100df6:	83 c4 10             	add    $0x10,%esp
80100df9:	eb df                	jmp    80100dda <fileread+0x50>
  panic("fileread");
80100dfb:	83 ec 0c             	sub    $0xc,%esp
80100dfe:	68 c6 67 10 80       	push   $0x801067c6
80100e03:	e8 39 f5 ff ff       	call   80100341 <panic>
    return -1;
80100e08:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e0d:	eb cb                	jmp    80100dda <fileread+0x50>

80100e0f <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100e0f:	55                   	push   %ebp
80100e10:	89 e5                	mov    %esp,%ebp
80100e12:	57                   	push   %edi
80100e13:	56                   	push   %esi
80100e14:	53                   	push   %ebx
80100e15:	83 ec 1c             	sub    $0x1c,%esp
80100e18:	8b 75 08             	mov    0x8(%ebp),%esi
  int r;

  if(f->writable == 0)
80100e1b:	80 7e 09 00          	cmpb   $0x0,0x9(%esi)
80100e1f:	0f 84 cc 00 00 00    	je     80100ef1 <filewrite+0xe2>
    return -1;
  if(f->type == FD_PIPE)
80100e25:	8b 06                	mov    (%esi),%eax
80100e27:	83 f8 01             	cmp    $0x1,%eax
80100e2a:	74 10                	je     80100e3c <filewrite+0x2d>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e2c:	83 f8 02             	cmp    $0x2,%eax
80100e2f:	0f 85 af 00 00 00    	jne    80100ee4 <filewrite+0xd5>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100e35:	bf 00 00 00 00       	mov    $0x0,%edi
80100e3a:	eb 67                	jmp    80100ea3 <filewrite+0x94>
    return pipewrite(f->pipe, addr, n);
80100e3c:	83 ec 04             	sub    $0x4,%esp
80100e3f:	ff 75 10             	push   0x10(%ebp)
80100e42:	ff 75 0c             	push   0xc(%ebp)
80100e45:	ff 76 0c             	push   0xc(%esi)
80100e48:	e8 83 1f 00 00       	call   80102dd0 <pipewrite>
80100e4d:	83 c4 10             	add    $0x10,%esp
80100e50:	e9 82 00 00 00       	jmp    80100ed7 <filewrite+0xc8>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100e55:	e8 89 18 00 00       	call   801026e3 <begin_op>
      ilock(f->ip);
80100e5a:	83 ec 0c             	sub    $0xc,%esp
80100e5d:	ff 76 10             	push   0x10(%esi)
80100e60:	e8 a8 06 00 00       	call   8010150d <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100e65:	ff 75 e4             	push   -0x1c(%ebp)
80100e68:	ff 76 14             	push   0x14(%esi)
80100e6b:	89 f8                	mov    %edi,%eax
80100e6d:	03 45 0c             	add    0xc(%ebp),%eax
80100e70:	50                   	push   %eax
80100e71:	ff 76 10             	push   0x10(%esi)
80100e74:	e8 81 09 00 00       	call   801017fa <writei>
80100e79:	89 c3                	mov    %eax,%ebx
80100e7b:	83 c4 20             	add    $0x20,%esp
80100e7e:	85 c0                	test   %eax,%eax
80100e80:	7e 03                	jle    80100e85 <filewrite+0x76>
        f->off += r;
80100e82:	01 46 14             	add    %eax,0x14(%esi)
      iunlock(f->ip);
80100e85:	83 ec 0c             	sub    $0xc,%esp
80100e88:	ff 76 10             	push   0x10(%esi)
80100e8b:	e8 3d 07 00 00       	call   801015cd <iunlock>
      end_op();
80100e90:	e8 ca 18 00 00       	call   8010275f <end_op>

      if(r < 0)
80100e95:	83 c4 10             	add    $0x10,%esp
80100e98:	85 db                	test   %ebx,%ebx
80100e9a:	78 31                	js     80100ecd <filewrite+0xbe>
        break;
      if(r != n1)
80100e9c:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
80100e9f:	75 1f                	jne    80100ec0 <filewrite+0xb1>
        panic("short filewrite");
      i += r;
80100ea1:	01 df                	add    %ebx,%edi
    while(i < n){
80100ea3:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100ea6:	7d 25                	jge    80100ecd <filewrite+0xbe>
      int n1 = n - i;
80100ea8:	8b 45 10             	mov    0x10(%ebp),%eax
80100eab:	29 f8                	sub    %edi,%eax
80100ead:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(n1 > max)
80100eb0:	3d 00 06 00 00       	cmp    $0x600,%eax
80100eb5:	7e 9e                	jle    80100e55 <filewrite+0x46>
        n1 = max;
80100eb7:	c7 45 e4 00 06 00 00 	movl   $0x600,-0x1c(%ebp)
80100ebe:	eb 95                	jmp    80100e55 <filewrite+0x46>
        panic("short filewrite");
80100ec0:	83 ec 0c             	sub    $0xc,%esp
80100ec3:	68 cf 67 10 80       	push   $0x801067cf
80100ec8:	e8 74 f4 ff ff       	call   80100341 <panic>
    }
    return i == n ? n : -1;
80100ecd:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100ed0:	74 0d                	je     80100edf <filewrite+0xd0>
80100ed2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
80100ed7:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100eda:	5b                   	pop    %ebx
80100edb:	5e                   	pop    %esi
80100edc:	5f                   	pop    %edi
80100edd:	5d                   	pop    %ebp
80100ede:	c3                   	ret    
    return i == n ? n : -1;
80100edf:	8b 45 10             	mov    0x10(%ebp),%eax
80100ee2:	eb f3                	jmp    80100ed7 <filewrite+0xc8>
  panic("filewrite");
80100ee4:	83 ec 0c             	sub    $0xc,%esp
80100ee7:	68 d5 67 10 80       	push   $0x801067d5
80100eec:	e8 50 f4 ff ff       	call   80100341 <panic>
    return -1;
80100ef1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ef6:	eb df                	jmp    80100ed7 <filewrite+0xc8>

80100ef8 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80100ef8:	55                   	push   %ebp
80100ef9:	89 e5                	mov    %esp,%ebp
80100efb:	57                   	push   %edi
80100efc:	56                   	push   %esi
80100efd:	53                   	push   %ebx
80100efe:	83 ec 0c             	sub    $0xc,%esp
80100f01:	89 d6                	mov    %edx,%esi
  char *s;
  int len;

  while(*path == '/')
80100f03:	eb 01                	jmp    80100f06 <skipelem+0xe>
    path++;
80100f05:	40                   	inc    %eax
  while(*path == '/')
80100f06:	8a 10                	mov    (%eax),%dl
80100f08:	80 fa 2f             	cmp    $0x2f,%dl
80100f0b:	74 f8                	je     80100f05 <skipelem+0xd>
  if(*path == 0)
80100f0d:	84 d2                	test   %dl,%dl
80100f0f:	74 4e                	je     80100f5f <skipelem+0x67>
80100f11:	89 c3                	mov    %eax,%ebx
80100f13:	eb 01                	jmp    80100f16 <skipelem+0x1e>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80100f15:	43                   	inc    %ebx
  while(*path != '/' && *path != 0)
80100f16:	8a 13                	mov    (%ebx),%dl
80100f18:	80 fa 2f             	cmp    $0x2f,%dl
80100f1b:	74 04                	je     80100f21 <skipelem+0x29>
80100f1d:	84 d2                	test   %dl,%dl
80100f1f:	75 f4                	jne    80100f15 <skipelem+0x1d>
  len = path - s;
80100f21:	89 df                	mov    %ebx,%edi
80100f23:	29 c7                	sub    %eax,%edi
  if(len >= DIRSIZ)
80100f25:	83 ff 0d             	cmp    $0xd,%edi
80100f28:	7e 11                	jle    80100f3b <skipelem+0x43>
    memmove(name, s, DIRSIZ);
80100f2a:	83 ec 04             	sub    $0x4,%esp
80100f2d:	6a 0e                	push   $0xe
80100f2f:	50                   	push   %eax
80100f30:	56                   	push   %esi
80100f31:	e8 db 2c 00 00       	call   80103c11 <memmove>
80100f36:	83 c4 10             	add    $0x10,%esp
80100f39:	eb 15                	jmp    80100f50 <skipelem+0x58>
  else {
    memmove(name, s, len);
80100f3b:	83 ec 04             	sub    $0x4,%esp
80100f3e:	57                   	push   %edi
80100f3f:	50                   	push   %eax
80100f40:	56                   	push   %esi
80100f41:	e8 cb 2c 00 00       	call   80103c11 <memmove>
    name[len] = 0;
80100f46:	c6 04 3e 00          	movb   $0x0,(%esi,%edi,1)
80100f4a:	83 c4 10             	add    $0x10,%esp
80100f4d:	eb 01                	jmp    80100f50 <skipelem+0x58>
  }
  while(*path == '/')
    path++;
80100f4f:	43                   	inc    %ebx
  while(*path == '/')
80100f50:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80100f53:	74 fa                	je     80100f4f <skipelem+0x57>
  return path;
}
80100f55:	89 d8                	mov    %ebx,%eax
80100f57:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f5a:	5b                   	pop    %ebx
80100f5b:	5e                   	pop    %esi
80100f5c:	5f                   	pop    %edi
80100f5d:	5d                   	pop    %ebp
80100f5e:	c3                   	ret    
    return 0;
80100f5f:	bb 00 00 00 00       	mov    $0x0,%ebx
80100f64:	eb ef                	jmp    80100f55 <skipelem+0x5d>

80100f66 <bzero>:
{
80100f66:	55                   	push   %ebp
80100f67:	89 e5                	mov    %esp,%ebp
80100f69:	53                   	push   %ebx
80100f6a:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, bno);
80100f6d:	52                   	push   %edx
80100f6e:	50                   	push   %eax
80100f6f:	e8 f6 f1 ff ff       	call   8010016a <bread>
80100f74:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80100f76:	8d 40 5c             	lea    0x5c(%eax),%eax
80100f79:	83 c4 0c             	add    $0xc,%esp
80100f7c:	68 00 02 00 00       	push   $0x200
80100f81:	6a 00                	push   $0x0
80100f83:	50                   	push   %eax
80100f84:	e8 12 2c 00 00       	call   80103b9b <memset>
  log_write(bp);
80100f89:	89 1c 24             	mov    %ebx,(%esp)
80100f8c:	e8 7b 18 00 00       	call   8010280c <log_write>
  brelse(bp);
80100f91:	89 1c 24             	mov    %ebx,(%esp)
80100f94:	e8 3a f2 ff ff       	call   801001d3 <brelse>
}
80100f99:	83 c4 10             	add    $0x10,%esp
80100f9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100f9f:	c9                   	leave  
80100fa0:	c3                   	ret    

80100fa1 <balloc>:
{
80100fa1:	55                   	push   %ebp
80100fa2:	89 e5                	mov    %esp,%ebp
80100fa4:	57                   	push   %edi
80100fa5:	56                   	push   %esi
80100fa6:	53                   	push   %ebx
80100fa7:	83 ec 1c             	sub    $0x1c,%esp
80100faa:	89 45 dc             	mov    %eax,-0x24(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80100fad:	be 00 00 00 00       	mov    $0x0,%esi
80100fb2:	eb 5b                	jmp    8010100f <balloc+0x6e>
    bp = bread(dev, BBLOCK(b, sb));
80100fb4:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
80100fba:	eb 61                	jmp    8010101d <balloc+0x7c>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80100fbc:	c1 fa 03             	sar    $0x3,%edx
80100fbf:	8b 7d e0             	mov    -0x20(%ebp),%edi
80100fc2:	8a 4c 17 5c          	mov    0x5c(%edi,%edx,1),%cl
80100fc6:	0f b6 f9             	movzbl %cl,%edi
80100fc9:	85 7d e4             	test   %edi,-0x1c(%ebp)
80100fcc:	74 7e                	je     8010104c <balloc+0xab>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80100fce:	40                   	inc    %eax
80100fcf:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80100fd4:	7f 25                	jg     80100ffb <balloc+0x5a>
80100fd6:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
80100fd9:	3b 1d b4 15 11 80    	cmp    0x801115b4,%ebx
80100fdf:	73 1a                	jae    80100ffb <balloc+0x5a>
      m = 1 << (bi % 8);
80100fe1:	89 c1                	mov    %eax,%ecx
80100fe3:	83 e1 07             	and    $0x7,%ecx
80100fe6:	ba 01 00 00 00       	mov    $0x1,%edx
80100feb:	d3 e2                	shl    %cl,%edx
80100fed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80100ff0:	89 c2                	mov    %eax,%edx
80100ff2:	85 c0                	test   %eax,%eax
80100ff4:	79 c6                	jns    80100fbc <balloc+0x1b>
80100ff6:	8d 50 07             	lea    0x7(%eax),%edx
80100ff9:	eb c1                	jmp    80100fbc <balloc+0x1b>
    brelse(bp);
80100ffb:	83 ec 0c             	sub    $0xc,%esp
80100ffe:	ff 75 e0             	push   -0x20(%ebp)
80101001:	e8 cd f1 ff ff       	call   801001d3 <brelse>
  for(b = 0; b < sb.size; b += BPB){
80101006:	81 c6 00 10 00 00    	add    $0x1000,%esi
8010100c:	83 c4 10             	add    $0x10,%esp
8010100f:	39 35 b4 15 11 80    	cmp    %esi,0x801115b4
80101015:	76 28                	jbe    8010103f <balloc+0x9e>
    bp = bread(dev, BBLOCK(b, sb));
80101017:	89 f0                	mov    %esi,%eax
80101019:	85 f6                	test   %esi,%esi
8010101b:	78 97                	js     80100fb4 <balloc+0x13>
8010101d:	c1 f8 0c             	sar    $0xc,%eax
80101020:	83 ec 08             	sub    $0x8,%esp
80101023:	03 05 cc 15 11 80    	add    0x801115cc,%eax
80101029:	50                   	push   %eax
8010102a:	ff 75 dc             	push   -0x24(%ebp)
8010102d:	e8 38 f1 ff ff       	call   8010016a <bread>
80101032:	89 45 e0             	mov    %eax,-0x20(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101035:	83 c4 10             	add    $0x10,%esp
80101038:	b8 00 00 00 00       	mov    $0x0,%eax
8010103d:	eb 90                	jmp    80100fcf <balloc+0x2e>
  panic("balloc: out of blocks");
8010103f:	83 ec 0c             	sub    $0xc,%esp
80101042:	68 df 67 10 80       	push   $0x801067df
80101047:	e8 f5 f2 ff ff       	call   80100341 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
8010104c:	0b 4d e4             	or     -0x1c(%ebp),%ecx
8010104f:	8b 75 e0             	mov    -0x20(%ebp),%esi
80101052:	88 4c 16 5c          	mov    %cl,0x5c(%esi,%edx,1)
        log_write(bp);
80101056:	83 ec 0c             	sub    $0xc,%esp
80101059:	56                   	push   %esi
8010105a:	e8 ad 17 00 00       	call   8010280c <log_write>
        brelse(bp);
8010105f:	89 34 24             	mov    %esi,(%esp)
80101062:	e8 6c f1 ff ff       	call   801001d3 <brelse>
        bzero(dev, b + bi);
80101067:	89 da                	mov    %ebx,%edx
80101069:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010106c:	e8 f5 fe ff ff       	call   80100f66 <bzero>
}
80101071:	89 d8                	mov    %ebx,%eax
80101073:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101076:	5b                   	pop    %ebx
80101077:	5e                   	pop    %esi
80101078:	5f                   	pop    %edi
80101079:	5d                   	pop    %ebp
8010107a:	c3                   	ret    

8010107b <bmap>:
{
8010107b:	55                   	push   %ebp
8010107c:	89 e5                	mov    %esp,%ebp
8010107e:	57                   	push   %edi
8010107f:	56                   	push   %esi
80101080:	53                   	push   %ebx
80101081:	83 ec 1c             	sub    $0x1c,%esp
80101084:	89 c3                	mov    %eax,%ebx
80101086:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
80101088:	83 fa 0b             	cmp    $0xb,%edx
8010108b:	76 45                	jbe    801010d2 <bmap+0x57>
  bn -= NDIRECT;
8010108d:	8d 72 f4             	lea    -0xc(%edx),%esi
  if(bn < NINDIRECT){
80101090:	83 fe 7f             	cmp    $0x7f,%esi
80101093:	77 7f                	ja     80101114 <bmap+0x99>
    if((addr = ip->addrs[NDIRECT]) == 0)
80101095:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
8010109b:	85 c0                	test   %eax,%eax
8010109d:	74 4a                	je     801010e9 <bmap+0x6e>
    bp = bread(ip->dev, addr);
8010109f:	83 ec 08             	sub    $0x8,%esp
801010a2:	50                   	push   %eax
801010a3:	ff 33                	push   (%ebx)
801010a5:	e8 c0 f0 ff ff       	call   8010016a <bread>
801010aa:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
801010ac:	8d 44 b0 5c          	lea    0x5c(%eax,%esi,4),%eax
801010b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801010b3:	8b 30                	mov    (%eax),%esi
801010b5:	83 c4 10             	add    $0x10,%esp
801010b8:	85 f6                	test   %esi,%esi
801010ba:	74 3c                	je     801010f8 <bmap+0x7d>
    brelse(bp);
801010bc:	83 ec 0c             	sub    $0xc,%esp
801010bf:	57                   	push   %edi
801010c0:	e8 0e f1 ff ff       	call   801001d3 <brelse>
    return addr;
801010c5:	83 c4 10             	add    $0x10,%esp
}
801010c8:	89 f0                	mov    %esi,%eax
801010ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010cd:	5b                   	pop    %ebx
801010ce:	5e                   	pop    %esi
801010cf:	5f                   	pop    %edi
801010d0:	5d                   	pop    %ebp
801010d1:	c3                   	ret    
    if((addr = ip->addrs[bn]) == 0)
801010d2:	8b 74 90 5c          	mov    0x5c(%eax,%edx,4),%esi
801010d6:	85 f6                	test   %esi,%esi
801010d8:	75 ee                	jne    801010c8 <bmap+0x4d>
      ip->addrs[bn] = addr = balloc(ip->dev);
801010da:	8b 00                	mov    (%eax),%eax
801010dc:	e8 c0 fe ff ff       	call   80100fa1 <balloc>
801010e1:	89 c6                	mov    %eax,%esi
801010e3:	89 44 bb 5c          	mov    %eax,0x5c(%ebx,%edi,4)
    return addr;
801010e7:	eb df                	jmp    801010c8 <bmap+0x4d>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
801010e9:	8b 03                	mov    (%ebx),%eax
801010eb:	e8 b1 fe ff ff       	call   80100fa1 <balloc>
801010f0:	89 83 8c 00 00 00    	mov    %eax,0x8c(%ebx)
801010f6:	eb a7                	jmp    8010109f <bmap+0x24>
      a[bn] = addr = balloc(ip->dev);
801010f8:	8b 03                	mov    (%ebx),%eax
801010fa:	e8 a2 fe ff ff       	call   80100fa1 <balloc>
801010ff:	89 c6                	mov    %eax,%esi
80101101:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101104:	89 30                	mov    %esi,(%eax)
      log_write(bp);
80101106:	83 ec 0c             	sub    $0xc,%esp
80101109:	57                   	push   %edi
8010110a:	e8 fd 16 00 00       	call   8010280c <log_write>
8010110f:	83 c4 10             	add    $0x10,%esp
80101112:	eb a8                	jmp    801010bc <bmap+0x41>
  panic("bmap: out of range");
80101114:	83 ec 0c             	sub    $0xc,%esp
80101117:	68 f5 67 10 80       	push   $0x801067f5
8010111c:	e8 20 f2 ff ff       	call   80100341 <panic>

80101121 <iget>:
{
80101121:	55                   	push   %ebp
80101122:	89 e5                	mov    %esp,%ebp
80101124:	57                   	push   %edi
80101125:	56                   	push   %esi
80101126:	53                   	push   %ebx
80101127:	83 ec 28             	sub    $0x28,%esp
8010112a:	89 c7                	mov    %eax,%edi
8010112c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
8010112f:	68 60 f9 10 80       	push   $0x8010f960
80101134:	e8 b6 29 00 00       	call   80103aef <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101139:	83 c4 10             	add    $0x10,%esp
  empty = 0;
8010113c:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101141:	bb 94 f9 10 80       	mov    $0x8010f994,%ebx
80101146:	eb 0a                	jmp    80101152 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101148:	85 f6                	test   %esi,%esi
8010114a:	74 39                	je     80101185 <iget+0x64>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010114c:	81 c3 90 00 00 00    	add    $0x90,%ebx
80101152:	81 fb b4 15 11 80    	cmp    $0x801115b4,%ebx
80101158:	73 33                	jae    8010118d <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010115a:	8b 43 08             	mov    0x8(%ebx),%eax
8010115d:	85 c0                	test   %eax,%eax
8010115f:	7e e7                	jle    80101148 <iget+0x27>
80101161:	39 3b                	cmp    %edi,(%ebx)
80101163:	75 e3                	jne    80101148 <iget+0x27>
80101165:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101168:	39 4b 04             	cmp    %ecx,0x4(%ebx)
8010116b:	75 db                	jne    80101148 <iget+0x27>
      ip->ref++;
8010116d:	40                   	inc    %eax
8010116e:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
80101171:	83 ec 0c             	sub    $0xc,%esp
80101174:	68 60 f9 10 80       	push   $0x8010f960
80101179:	e8 d6 29 00 00       	call   80103b54 <release>
      return ip;
8010117e:	83 c4 10             	add    $0x10,%esp
80101181:	89 de                	mov    %ebx,%esi
80101183:	eb 32                	jmp    801011b7 <iget+0x96>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101185:	85 c0                	test   %eax,%eax
80101187:	75 c3                	jne    8010114c <iget+0x2b>
      empty = ip;
80101189:	89 de                	mov    %ebx,%esi
8010118b:	eb bf                	jmp    8010114c <iget+0x2b>
  if(empty == 0)
8010118d:	85 f6                	test   %esi,%esi
8010118f:	74 30                	je     801011c1 <iget+0xa0>
  ip->dev = dev;
80101191:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
80101193:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101196:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
80101199:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
801011a0:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
801011a7:	83 ec 0c             	sub    $0xc,%esp
801011aa:	68 60 f9 10 80       	push   $0x8010f960
801011af:	e8 a0 29 00 00       	call   80103b54 <release>
  return ip;
801011b4:	83 c4 10             	add    $0x10,%esp
}
801011b7:	89 f0                	mov    %esi,%eax
801011b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011bc:	5b                   	pop    %ebx
801011bd:	5e                   	pop    %esi
801011be:	5f                   	pop    %edi
801011bf:	5d                   	pop    %ebp
801011c0:	c3                   	ret    
    panic("iget: no inodes");
801011c1:	83 ec 0c             	sub    $0xc,%esp
801011c4:	68 08 68 10 80       	push   $0x80106808
801011c9:	e8 73 f1 ff ff       	call   80100341 <panic>

801011ce <readsb>:
{
801011ce:	55                   	push   %ebp
801011cf:	89 e5                	mov    %esp,%ebp
801011d1:	53                   	push   %ebx
801011d2:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
801011d5:	6a 01                	push   $0x1
801011d7:	ff 75 08             	push   0x8(%ebp)
801011da:	e8 8b ef ff ff       	call   8010016a <bread>
801011df:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801011e1:	8d 40 5c             	lea    0x5c(%eax),%eax
801011e4:	83 c4 0c             	add    $0xc,%esp
801011e7:	6a 1c                	push   $0x1c
801011e9:	50                   	push   %eax
801011ea:	ff 75 0c             	push   0xc(%ebp)
801011ed:	e8 1f 2a 00 00       	call   80103c11 <memmove>
  brelse(bp);
801011f2:	89 1c 24             	mov    %ebx,(%esp)
801011f5:	e8 d9 ef ff ff       	call   801001d3 <brelse>
}
801011fa:	83 c4 10             	add    $0x10,%esp
801011fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101200:	c9                   	leave  
80101201:	c3                   	ret    

80101202 <bfree>:
{
80101202:	55                   	push   %ebp
80101203:	89 e5                	mov    %esp,%ebp
80101205:	56                   	push   %esi
80101206:	53                   	push   %ebx
80101207:	89 c3                	mov    %eax,%ebx
80101209:	89 d6                	mov    %edx,%esi
  readsb(dev, &sb);
8010120b:	83 ec 08             	sub    $0x8,%esp
8010120e:	68 b4 15 11 80       	push   $0x801115b4
80101213:	50                   	push   %eax
80101214:	e8 b5 ff ff ff       	call   801011ce <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101219:	89 f0                	mov    %esi,%eax
8010121b:	c1 e8 0c             	shr    $0xc,%eax
8010121e:	83 c4 08             	add    $0x8,%esp
80101221:	03 05 cc 15 11 80    	add    0x801115cc,%eax
80101227:	50                   	push   %eax
80101228:	53                   	push   %ebx
80101229:	e8 3c ef ff ff       	call   8010016a <bread>
8010122e:	89 c3                	mov    %eax,%ebx
  bi = b % BPB;
80101230:	89 f2                	mov    %esi,%edx
80101232:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  m = 1 << (bi % 8);
80101238:	89 f1                	mov    %esi,%ecx
8010123a:	83 e1 07             	and    $0x7,%ecx
8010123d:	b8 01 00 00 00       	mov    $0x1,%eax
80101242:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
80101244:	83 c4 10             	add    $0x10,%esp
80101247:	c1 fa 03             	sar    $0x3,%edx
8010124a:	8a 4c 13 5c          	mov    0x5c(%ebx,%edx,1),%cl
8010124e:	0f b6 f1             	movzbl %cl,%esi
80101251:	85 c6                	test   %eax,%esi
80101253:	74 23                	je     80101278 <bfree+0x76>
  bp->data[bi/8] &= ~m;
80101255:	f7 d0                	not    %eax
80101257:	21 c8                	and    %ecx,%eax
80101259:	88 44 13 5c          	mov    %al,0x5c(%ebx,%edx,1)
  log_write(bp);
8010125d:	83 ec 0c             	sub    $0xc,%esp
80101260:	53                   	push   %ebx
80101261:	e8 a6 15 00 00       	call   8010280c <log_write>
  brelse(bp);
80101266:	89 1c 24             	mov    %ebx,(%esp)
80101269:	e8 65 ef ff ff       	call   801001d3 <brelse>
}
8010126e:	83 c4 10             	add    $0x10,%esp
80101271:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101274:	5b                   	pop    %ebx
80101275:	5e                   	pop    %esi
80101276:	5d                   	pop    %ebp
80101277:	c3                   	ret    
    panic("freeing free block");
80101278:	83 ec 0c             	sub    $0xc,%esp
8010127b:	68 18 68 10 80       	push   $0x80106818
80101280:	e8 bc f0 ff ff       	call   80100341 <panic>

80101285 <iinit>:
{
80101285:	55                   	push   %ebp
80101286:	89 e5                	mov    %esp,%ebp
80101288:	53                   	push   %ebx
80101289:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
8010128c:	68 2b 68 10 80       	push   $0x8010682b
80101291:	68 60 f9 10 80       	push   $0x8010f960
80101296:	e8 1d 27 00 00       	call   801039b8 <initlock>
  for(i = 0; i < NINODE; i++) {
8010129b:	83 c4 10             	add    $0x10,%esp
8010129e:	bb 00 00 00 00       	mov    $0x0,%ebx
801012a3:	eb 1f                	jmp    801012c4 <iinit+0x3f>
    initsleeplock(&icache.inode[i].lock, "inode");
801012a5:	83 ec 08             	sub    $0x8,%esp
801012a8:	68 32 68 10 80       	push   $0x80106832
801012ad:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
801012b0:	89 d0                	mov    %edx,%eax
801012b2:	c1 e0 04             	shl    $0x4,%eax
801012b5:	05 a0 f9 10 80       	add    $0x8010f9a0,%eax
801012ba:	50                   	push   %eax
801012bb:	e8 ed 25 00 00       	call   801038ad <initsleeplock>
  for(i = 0; i < NINODE; i++) {
801012c0:	43                   	inc    %ebx
801012c1:	83 c4 10             	add    $0x10,%esp
801012c4:	83 fb 31             	cmp    $0x31,%ebx
801012c7:	7e dc                	jle    801012a5 <iinit+0x20>
  readsb(dev, &sb);
801012c9:	83 ec 08             	sub    $0x8,%esp
801012cc:	68 b4 15 11 80       	push   $0x801115b4
801012d1:	ff 75 08             	push   0x8(%ebp)
801012d4:	e8 f5 fe ff ff       	call   801011ce <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801012d9:	ff 35 cc 15 11 80    	push   0x801115cc
801012df:	ff 35 c8 15 11 80    	push   0x801115c8
801012e5:	ff 35 c4 15 11 80    	push   0x801115c4
801012eb:	ff 35 c0 15 11 80    	push   0x801115c0
801012f1:	ff 35 bc 15 11 80    	push   0x801115bc
801012f7:	ff 35 b8 15 11 80    	push   0x801115b8
801012fd:	ff 35 b4 15 11 80    	push   0x801115b4
80101303:	68 98 68 10 80       	push   $0x80106898
80101308:	e8 cd f2 ff ff       	call   801005da <cprintf>
}
8010130d:	83 c4 30             	add    $0x30,%esp
80101310:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101313:	c9                   	leave  
80101314:	c3                   	ret    

80101315 <ialloc>:
{
80101315:	55                   	push   %ebp
80101316:	89 e5                	mov    %esp,%ebp
80101318:	57                   	push   %edi
80101319:	56                   	push   %esi
8010131a:	53                   	push   %ebx
8010131b:	83 ec 1c             	sub    $0x1c,%esp
8010131e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101321:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101324:	bb 01 00 00 00       	mov    $0x1,%ebx
80101329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
8010132c:	39 1d bc 15 11 80    	cmp    %ebx,0x801115bc
80101332:	76 3d                	jbe    80101371 <ialloc+0x5c>
    bp = bread(dev, IBLOCK(inum, sb));
80101334:	89 d8                	mov    %ebx,%eax
80101336:	c1 e8 03             	shr    $0x3,%eax
80101339:	83 ec 08             	sub    $0x8,%esp
8010133c:	03 05 c8 15 11 80    	add    0x801115c8,%eax
80101342:	50                   	push   %eax
80101343:	ff 75 08             	push   0x8(%ebp)
80101346:	e8 1f ee ff ff       	call   8010016a <bread>
8010134b:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
8010134d:	89 d8                	mov    %ebx,%eax
8010134f:	83 e0 07             	and    $0x7,%eax
80101352:	c1 e0 06             	shl    $0x6,%eax
80101355:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
80101359:	83 c4 10             	add    $0x10,%esp
8010135c:	66 83 3f 00          	cmpw   $0x0,(%edi)
80101360:	74 1c                	je     8010137e <ialloc+0x69>
    brelse(bp);
80101362:	83 ec 0c             	sub    $0xc,%esp
80101365:	56                   	push   %esi
80101366:	e8 68 ee ff ff       	call   801001d3 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
8010136b:	43                   	inc    %ebx
8010136c:	83 c4 10             	add    $0x10,%esp
8010136f:	eb b8                	jmp    80101329 <ialloc+0x14>
  panic("ialloc: no inodes");
80101371:	83 ec 0c             	sub    $0xc,%esp
80101374:	68 38 68 10 80       	push   $0x80106838
80101379:	e8 c3 ef ff ff       	call   80100341 <panic>
      memset(dip, 0, sizeof(*dip));
8010137e:	83 ec 04             	sub    $0x4,%esp
80101381:	6a 40                	push   $0x40
80101383:	6a 00                	push   $0x0
80101385:	57                   	push   %edi
80101386:	e8 10 28 00 00       	call   80103b9b <memset>
      dip->type = type;
8010138b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010138e:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
80101391:	89 34 24             	mov    %esi,(%esp)
80101394:	e8 73 14 00 00       	call   8010280c <log_write>
      brelse(bp);
80101399:	89 34 24             	mov    %esi,(%esp)
8010139c:	e8 32 ee ff ff       	call   801001d3 <brelse>
      return iget(dev, inum);
801013a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801013a4:	8b 45 08             	mov    0x8(%ebp),%eax
801013a7:	e8 75 fd ff ff       	call   80101121 <iget>
}
801013ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
801013af:	5b                   	pop    %ebx
801013b0:	5e                   	pop    %esi
801013b1:	5f                   	pop    %edi
801013b2:	5d                   	pop    %ebp
801013b3:	c3                   	ret    

801013b4 <iupdate>:
{
801013b4:	55                   	push   %ebp
801013b5:	89 e5                	mov    %esp,%ebp
801013b7:	56                   	push   %esi
801013b8:	53                   	push   %ebx
801013b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801013bc:	8b 43 04             	mov    0x4(%ebx),%eax
801013bf:	c1 e8 03             	shr    $0x3,%eax
801013c2:	83 ec 08             	sub    $0x8,%esp
801013c5:	03 05 c8 15 11 80    	add    0x801115c8,%eax
801013cb:	50                   	push   %eax
801013cc:	ff 33                	push   (%ebx)
801013ce:	e8 97 ed ff ff       	call   8010016a <bread>
801013d3:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801013d5:	8b 43 04             	mov    0x4(%ebx),%eax
801013d8:	83 e0 07             	and    $0x7,%eax
801013db:	c1 e0 06             	shl    $0x6,%eax
801013de:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
801013e2:	8b 53 50             	mov    0x50(%ebx),%edx
801013e5:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801013e8:	66 8b 53 52          	mov    0x52(%ebx),%dx
801013ec:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801013f0:	8b 53 54             	mov    0x54(%ebx),%edx
801013f3:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801013f7:	66 8b 53 56          	mov    0x56(%ebx),%dx
801013fb:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801013ff:	8b 53 58             	mov    0x58(%ebx),%edx
80101402:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101405:	83 c3 5c             	add    $0x5c,%ebx
80101408:	83 c0 0c             	add    $0xc,%eax
8010140b:	83 c4 0c             	add    $0xc,%esp
8010140e:	6a 34                	push   $0x34
80101410:	53                   	push   %ebx
80101411:	50                   	push   %eax
80101412:	e8 fa 27 00 00       	call   80103c11 <memmove>
  log_write(bp);
80101417:	89 34 24             	mov    %esi,(%esp)
8010141a:	e8 ed 13 00 00       	call   8010280c <log_write>
  brelse(bp);
8010141f:	89 34 24             	mov    %esi,(%esp)
80101422:	e8 ac ed ff ff       	call   801001d3 <brelse>
}
80101427:	83 c4 10             	add    $0x10,%esp
8010142a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010142d:	5b                   	pop    %ebx
8010142e:	5e                   	pop    %esi
8010142f:	5d                   	pop    %ebp
80101430:	c3                   	ret    

80101431 <itrunc>:
{
80101431:	55                   	push   %ebp
80101432:	89 e5                	mov    %esp,%ebp
80101434:	57                   	push   %edi
80101435:	56                   	push   %esi
80101436:	53                   	push   %ebx
80101437:	83 ec 1c             	sub    $0x1c,%esp
8010143a:	89 c6                	mov    %eax,%esi
  for(i = 0; i < NDIRECT; i++){
8010143c:	bb 00 00 00 00       	mov    $0x0,%ebx
80101441:	eb 01                	jmp    80101444 <itrunc+0x13>
80101443:	43                   	inc    %ebx
80101444:	83 fb 0b             	cmp    $0xb,%ebx
80101447:	7f 19                	jg     80101462 <itrunc+0x31>
    if(ip->addrs[i]){
80101449:	8b 54 9e 5c          	mov    0x5c(%esi,%ebx,4),%edx
8010144d:	85 d2                	test   %edx,%edx
8010144f:	74 f2                	je     80101443 <itrunc+0x12>
      bfree(ip->dev, ip->addrs[i]);
80101451:	8b 06                	mov    (%esi),%eax
80101453:	e8 aa fd ff ff       	call   80101202 <bfree>
      ip->addrs[i] = 0;
80101458:	c7 44 9e 5c 00 00 00 	movl   $0x0,0x5c(%esi,%ebx,4)
8010145f:	00 
80101460:	eb e1                	jmp    80101443 <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
80101462:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
80101468:	85 c0                	test   %eax,%eax
8010146a:	75 1b                	jne    80101487 <itrunc+0x56>
  ip->size = 0;
8010146c:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
80101473:	83 ec 0c             	sub    $0xc,%esp
80101476:	56                   	push   %esi
80101477:	e8 38 ff ff ff       	call   801013b4 <iupdate>
}
8010147c:	83 c4 10             	add    $0x10,%esp
8010147f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101482:	5b                   	pop    %ebx
80101483:	5e                   	pop    %esi
80101484:	5f                   	pop    %edi
80101485:	5d                   	pop    %ebp
80101486:	c3                   	ret    
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101487:	83 ec 08             	sub    $0x8,%esp
8010148a:	50                   	push   %eax
8010148b:	ff 36                	push   (%esi)
8010148d:	e8 d8 ec ff ff       	call   8010016a <bread>
80101492:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
80101495:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
80101498:	83 c4 10             	add    $0x10,%esp
8010149b:	bb 00 00 00 00       	mov    $0x0,%ebx
801014a0:	eb 01                	jmp    801014a3 <itrunc+0x72>
801014a2:	43                   	inc    %ebx
801014a3:	83 fb 7f             	cmp    $0x7f,%ebx
801014a6:	77 10                	ja     801014b8 <itrunc+0x87>
      if(a[j])
801014a8:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
801014ab:	85 d2                	test   %edx,%edx
801014ad:	74 f3                	je     801014a2 <itrunc+0x71>
        bfree(ip->dev, a[j]);
801014af:	8b 06                	mov    (%esi),%eax
801014b1:	e8 4c fd ff ff       	call   80101202 <bfree>
801014b6:	eb ea                	jmp    801014a2 <itrunc+0x71>
    brelse(bp);
801014b8:	83 ec 0c             	sub    $0xc,%esp
801014bb:	ff 75 e4             	push   -0x1c(%ebp)
801014be:	e8 10 ed ff ff       	call   801001d3 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
801014c3:	8b 06                	mov    (%esi),%eax
801014c5:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
801014cb:	e8 32 fd ff ff       	call   80101202 <bfree>
    ip->addrs[NDIRECT] = 0;
801014d0:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
801014d7:	00 00 00 
801014da:	83 c4 10             	add    $0x10,%esp
801014dd:	eb 8d                	jmp    8010146c <itrunc+0x3b>

801014df <idup>:
{
801014df:	55                   	push   %ebp
801014e0:	89 e5                	mov    %esp,%ebp
801014e2:	53                   	push   %ebx
801014e3:	83 ec 10             	sub    $0x10,%esp
801014e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
801014e9:	68 60 f9 10 80       	push   $0x8010f960
801014ee:	e8 fc 25 00 00       	call   80103aef <acquire>
  ip->ref++;
801014f3:	8b 43 08             	mov    0x8(%ebx),%eax
801014f6:	40                   	inc    %eax
801014f7:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801014fa:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101501:	e8 4e 26 00 00       	call   80103b54 <release>
}
80101506:	89 d8                	mov    %ebx,%eax
80101508:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010150b:	c9                   	leave  
8010150c:	c3                   	ret    

8010150d <ilock>:
{
8010150d:	55                   	push   %ebp
8010150e:	89 e5                	mov    %esp,%ebp
80101510:	56                   	push   %esi
80101511:	53                   	push   %ebx
80101512:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101515:	85 db                	test   %ebx,%ebx
80101517:	74 22                	je     8010153b <ilock+0x2e>
80101519:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
8010151d:	7e 1c                	jle    8010153b <ilock+0x2e>
  acquiresleep(&ip->lock);
8010151f:	83 ec 0c             	sub    $0xc,%esp
80101522:	8d 43 0c             	lea    0xc(%ebx),%eax
80101525:	50                   	push   %eax
80101526:	e8 b5 23 00 00       	call   801038e0 <acquiresleep>
  if(ip->valid == 0){
8010152b:	83 c4 10             	add    $0x10,%esp
8010152e:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101532:	74 14                	je     80101548 <ilock+0x3b>
}
80101534:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101537:	5b                   	pop    %ebx
80101538:	5e                   	pop    %esi
80101539:	5d                   	pop    %ebp
8010153a:	c3                   	ret    
    panic("ilock");
8010153b:	83 ec 0c             	sub    $0xc,%esp
8010153e:	68 4a 68 10 80       	push   $0x8010684a
80101543:	e8 f9 ed ff ff       	call   80100341 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101548:	8b 43 04             	mov    0x4(%ebx),%eax
8010154b:	c1 e8 03             	shr    $0x3,%eax
8010154e:	83 ec 08             	sub    $0x8,%esp
80101551:	03 05 c8 15 11 80    	add    0x801115c8,%eax
80101557:	50                   	push   %eax
80101558:	ff 33                	push   (%ebx)
8010155a:	e8 0b ec ff ff       	call   8010016a <bread>
8010155f:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101561:	8b 43 04             	mov    0x4(%ebx),%eax
80101564:	83 e0 07             	and    $0x7,%eax
80101567:	c1 e0 06             	shl    $0x6,%eax
8010156a:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
8010156e:	8b 10                	mov    (%eax),%edx
80101570:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
80101574:	66 8b 50 02          	mov    0x2(%eax),%dx
80101578:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
8010157c:	8b 50 04             	mov    0x4(%eax),%edx
8010157f:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
80101583:	66 8b 50 06          	mov    0x6(%eax),%dx
80101587:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
8010158b:	8b 50 08             	mov    0x8(%eax),%edx
8010158e:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101591:	83 c0 0c             	add    $0xc,%eax
80101594:	8d 53 5c             	lea    0x5c(%ebx),%edx
80101597:	83 c4 0c             	add    $0xc,%esp
8010159a:	6a 34                	push   $0x34
8010159c:	50                   	push   %eax
8010159d:	52                   	push   %edx
8010159e:	e8 6e 26 00 00       	call   80103c11 <memmove>
    brelse(bp);
801015a3:	89 34 24             	mov    %esi,(%esp)
801015a6:	e8 28 ec ff ff       	call   801001d3 <brelse>
    ip->valid = 1;
801015ab:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
801015b2:	83 c4 10             	add    $0x10,%esp
801015b5:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
801015ba:	0f 85 74 ff ff ff    	jne    80101534 <ilock+0x27>
      panic("ilock: no type");
801015c0:	83 ec 0c             	sub    $0xc,%esp
801015c3:	68 50 68 10 80       	push   $0x80106850
801015c8:	e8 74 ed ff ff       	call   80100341 <panic>

801015cd <iunlock>:
{
801015cd:	55                   	push   %ebp
801015ce:	89 e5                	mov    %esp,%ebp
801015d0:	56                   	push   %esi
801015d1:	53                   	push   %ebx
801015d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801015d5:	85 db                	test   %ebx,%ebx
801015d7:	74 2c                	je     80101605 <iunlock+0x38>
801015d9:	8d 73 0c             	lea    0xc(%ebx),%esi
801015dc:	83 ec 0c             	sub    $0xc,%esp
801015df:	56                   	push   %esi
801015e0:	e8 85 23 00 00       	call   8010396a <holdingsleep>
801015e5:	83 c4 10             	add    $0x10,%esp
801015e8:	85 c0                	test   %eax,%eax
801015ea:	74 19                	je     80101605 <iunlock+0x38>
801015ec:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
801015f0:	7e 13                	jle    80101605 <iunlock+0x38>
  releasesleep(&ip->lock);
801015f2:	83 ec 0c             	sub    $0xc,%esp
801015f5:	56                   	push   %esi
801015f6:	e8 34 23 00 00       	call   8010392f <releasesleep>
}
801015fb:	83 c4 10             	add    $0x10,%esp
801015fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101601:	5b                   	pop    %ebx
80101602:	5e                   	pop    %esi
80101603:	5d                   	pop    %ebp
80101604:	c3                   	ret    
    panic("iunlock");
80101605:	83 ec 0c             	sub    $0xc,%esp
80101608:	68 5f 68 10 80       	push   $0x8010685f
8010160d:	e8 2f ed ff ff       	call   80100341 <panic>

80101612 <iput>:
{
80101612:	55                   	push   %ebp
80101613:	89 e5                	mov    %esp,%ebp
80101615:	57                   	push   %edi
80101616:	56                   	push   %esi
80101617:	53                   	push   %ebx
80101618:	83 ec 18             	sub    $0x18,%esp
8010161b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
8010161e:	8d 73 0c             	lea    0xc(%ebx),%esi
80101621:	56                   	push   %esi
80101622:	e8 b9 22 00 00       	call   801038e0 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101627:	83 c4 10             	add    $0x10,%esp
8010162a:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
8010162e:	74 07                	je     80101637 <iput+0x25>
80101630:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101635:	74 33                	je     8010166a <iput+0x58>
  releasesleep(&ip->lock);
80101637:	83 ec 0c             	sub    $0xc,%esp
8010163a:	56                   	push   %esi
8010163b:	e8 ef 22 00 00       	call   8010392f <releasesleep>
  acquire(&icache.lock);
80101640:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101647:	e8 a3 24 00 00       	call   80103aef <acquire>
  ip->ref--;
8010164c:	8b 43 08             	mov    0x8(%ebx),%eax
8010164f:	48                   	dec    %eax
80101650:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
80101653:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
8010165a:	e8 f5 24 00 00       	call   80103b54 <release>
}
8010165f:	83 c4 10             	add    $0x10,%esp
80101662:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101665:	5b                   	pop    %ebx
80101666:	5e                   	pop    %esi
80101667:	5f                   	pop    %edi
80101668:	5d                   	pop    %ebp
80101669:	c3                   	ret    
    acquire(&icache.lock);
8010166a:	83 ec 0c             	sub    $0xc,%esp
8010166d:	68 60 f9 10 80       	push   $0x8010f960
80101672:	e8 78 24 00 00       	call   80103aef <acquire>
    int r = ip->ref;
80101677:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
8010167a:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101681:	e8 ce 24 00 00       	call   80103b54 <release>
    if(r == 1){
80101686:	83 c4 10             	add    $0x10,%esp
80101689:	83 ff 01             	cmp    $0x1,%edi
8010168c:	75 a9                	jne    80101637 <iput+0x25>
      itrunc(ip);
8010168e:	89 d8                	mov    %ebx,%eax
80101690:	e8 9c fd ff ff       	call   80101431 <itrunc>
      ip->type = 0;
80101695:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
8010169b:	83 ec 0c             	sub    $0xc,%esp
8010169e:	53                   	push   %ebx
8010169f:	e8 10 fd ff ff       	call   801013b4 <iupdate>
      ip->valid = 0;
801016a4:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
801016ab:	83 c4 10             	add    $0x10,%esp
801016ae:	eb 87                	jmp    80101637 <iput+0x25>

801016b0 <iunlockput>:
{
801016b0:	55                   	push   %ebp
801016b1:	89 e5                	mov    %esp,%ebp
801016b3:	53                   	push   %ebx
801016b4:	83 ec 10             	sub    $0x10,%esp
801016b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
801016ba:	53                   	push   %ebx
801016bb:	e8 0d ff ff ff       	call   801015cd <iunlock>
  iput(ip);
801016c0:	89 1c 24             	mov    %ebx,(%esp)
801016c3:	e8 4a ff ff ff       	call   80101612 <iput>
}
801016c8:	83 c4 10             	add    $0x10,%esp
801016cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801016ce:	c9                   	leave  
801016cf:	c3                   	ret    

801016d0 <stati>:
{
801016d0:	55                   	push   %ebp
801016d1:	89 e5                	mov    %esp,%ebp
801016d3:	8b 55 08             	mov    0x8(%ebp),%edx
801016d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
801016d9:	8b 0a                	mov    (%edx),%ecx
801016db:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
801016de:	8b 4a 04             	mov    0x4(%edx),%ecx
801016e1:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
801016e4:	8b 4a 50             	mov    0x50(%edx),%ecx
801016e7:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
801016ea:	66 8b 4a 56          	mov    0x56(%edx),%cx
801016ee:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
801016f2:	8b 52 58             	mov    0x58(%edx),%edx
801016f5:	89 50 10             	mov    %edx,0x10(%eax)
}
801016f8:	5d                   	pop    %ebp
801016f9:	c3                   	ret    

801016fa <readi>:
{
801016fa:	55                   	push   %ebp
801016fb:	89 e5                	mov    %esp,%ebp
801016fd:	57                   	push   %edi
801016fe:	56                   	push   %esi
801016ff:	53                   	push   %ebx
80101700:	83 ec 0c             	sub    $0xc,%esp
  if(ip->type == T_DEV){
80101703:	8b 45 08             	mov    0x8(%ebp),%eax
80101706:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
8010170b:	74 2c                	je     80101739 <readi+0x3f>
  if(off > ip->size || off + n < off)
8010170d:	8b 45 08             	mov    0x8(%ebp),%eax
80101710:	8b 40 58             	mov    0x58(%eax),%eax
80101713:	3b 45 10             	cmp    0x10(%ebp),%eax
80101716:	0f 82 d0 00 00 00    	jb     801017ec <readi+0xf2>
8010171c:	8b 55 10             	mov    0x10(%ebp),%edx
8010171f:	03 55 14             	add    0x14(%ebp),%edx
80101722:	0f 82 cb 00 00 00    	jb     801017f3 <readi+0xf9>
  if(off + n > ip->size)
80101728:	39 d0                	cmp    %edx,%eax
8010172a:	73 06                	jae    80101732 <readi+0x38>
    n = ip->size - off;
8010172c:	2b 45 10             	sub    0x10(%ebp),%eax
8010172f:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101732:	bf 00 00 00 00       	mov    $0x0,%edi
80101737:	eb 55                	jmp    8010178e <readi+0x94>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101739:	66 8b 40 52          	mov    0x52(%eax),%ax
8010173d:	66 83 f8 09          	cmp    $0x9,%ax
80101741:	0f 87 97 00 00 00    	ja     801017de <readi+0xe4>
80101747:	98                   	cwtl   
80101748:	8b 04 c5 00 f9 10 80 	mov    -0x7fef0700(,%eax,8),%eax
8010174f:	85 c0                	test   %eax,%eax
80101751:	0f 84 8e 00 00 00    	je     801017e5 <readi+0xeb>
    return devsw[ip->major].read(ip, dst, n);
80101757:	83 ec 04             	sub    $0x4,%esp
8010175a:	ff 75 14             	push   0x14(%ebp)
8010175d:	ff 75 0c             	push   0xc(%ebp)
80101760:	ff 75 08             	push   0x8(%ebp)
80101763:	ff d0                	call   *%eax
80101765:	83 c4 10             	add    $0x10,%esp
80101768:	eb 6c                	jmp    801017d6 <readi+0xdc>
    memmove(dst, bp->data + off%BSIZE, m);
8010176a:	83 ec 04             	sub    $0x4,%esp
8010176d:	53                   	push   %ebx
8010176e:	8d 44 16 5c          	lea    0x5c(%esi,%edx,1),%eax
80101772:	50                   	push   %eax
80101773:	ff 75 0c             	push   0xc(%ebp)
80101776:	e8 96 24 00 00       	call   80103c11 <memmove>
    brelse(bp);
8010177b:	89 34 24             	mov    %esi,(%esp)
8010177e:	e8 50 ea ff ff       	call   801001d3 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101783:	01 df                	add    %ebx,%edi
80101785:	01 5d 10             	add    %ebx,0x10(%ebp)
80101788:	01 5d 0c             	add    %ebx,0xc(%ebp)
8010178b:	83 c4 10             	add    $0x10,%esp
8010178e:	39 7d 14             	cmp    %edi,0x14(%ebp)
80101791:	76 40                	jbe    801017d3 <readi+0xd9>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101793:	8b 55 10             	mov    0x10(%ebp),%edx
80101796:	c1 ea 09             	shr    $0x9,%edx
80101799:	8b 45 08             	mov    0x8(%ebp),%eax
8010179c:	e8 da f8 ff ff       	call   8010107b <bmap>
801017a1:	83 ec 08             	sub    $0x8,%esp
801017a4:	50                   	push   %eax
801017a5:	8b 45 08             	mov    0x8(%ebp),%eax
801017a8:	ff 30                	push   (%eax)
801017aa:	e8 bb e9 ff ff       	call   8010016a <bread>
801017af:	89 c6                	mov    %eax,%esi
    m = min(n - tot, BSIZE - off%BSIZE);
801017b1:	8b 55 10             	mov    0x10(%ebp),%edx
801017b4:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801017ba:	b8 00 02 00 00       	mov    $0x200,%eax
801017bf:	29 d0                	sub    %edx,%eax
801017c1:	8b 4d 14             	mov    0x14(%ebp),%ecx
801017c4:	29 f9                	sub    %edi,%ecx
801017c6:	89 c3                	mov    %eax,%ebx
801017c8:	83 c4 10             	add    $0x10,%esp
801017cb:	39 c8                	cmp    %ecx,%eax
801017cd:	76 9b                	jbe    8010176a <readi+0x70>
801017cf:	89 cb                	mov    %ecx,%ebx
801017d1:	eb 97                	jmp    8010176a <readi+0x70>
  return n;
801017d3:	8b 45 14             	mov    0x14(%ebp),%eax
}
801017d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017d9:	5b                   	pop    %ebx
801017da:	5e                   	pop    %esi
801017db:	5f                   	pop    %edi
801017dc:	5d                   	pop    %ebp
801017dd:	c3                   	ret    
      return -1;
801017de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801017e3:	eb f1                	jmp    801017d6 <readi+0xdc>
801017e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801017ea:	eb ea                	jmp    801017d6 <readi+0xdc>
    return -1;
801017ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801017f1:	eb e3                	jmp    801017d6 <readi+0xdc>
801017f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801017f8:	eb dc                	jmp    801017d6 <readi+0xdc>

801017fa <writei>:
{
801017fa:	55                   	push   %ebp
801017fb:	89 e5                	mov    %esp,%ebp
801017fd:	57                   	push   %edi
801017fe:	56                   	push   %esi
801017ff:	53                   	push   %ebx
80101800:	83 ec 0c             	sub    $0xc,%esp
  if(ip->type == T_DEV){
80101803:	8b 45 08             	mov    0x8(%ebp),%eax
80101806:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
8010180b:	74 2c                	je     80101839 <writei+0x3f>
  if(off > ip->size || off + n < off)
8010180d:	8b 45 08             	mov    0x8(%ebp),%eax
80101810:	8b 7d 10             	mov    0x10(%ebp),%edi
80101813:	39 78 58             	cmp    %edi,0x58(%eax)
80101816:	0f 82 fd 00 00 00    	jb     80101919 <writei+0x11f>
8010181c:	89 f8                	mov    %edi,%eax
8010181e:	03 45 14             	add    0x14(%ebp),%eax
80101821:	0f 82 f9 00 00 00    	jb     80101920 <writei+0x126>
  if(off + n > MAXFILE*BSIZE)
80101827:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010182c:	0f 87 f5 00 00 00    	ja     80101927 <writei+0x12d>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101832:	bf 00 00 00 00       	mov    $0x0,%edi
80101837:	eb 60                	jmp    80101899 <writei+0x9f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101839:	66 8b 40 52          	mov    0x52(%eax),%ax
8010183d:	66 83 f8 09          	cmp    $0x9,%ax
80101841:	0f 87 c4 00 00 00    	ja     8010190b <writei+0x111>
80101847:	98                   	cwtl   
80101848:	8b 04 c5 04 f9 10 80 	mov    -0x7fef06fc(,%eax,8),%eax
8010184f:	85 c0                	test   %eax,%eax
80101851:	0f 84 bb 00 00 00    	je     80101912 <writei+0x118>
    return devsw[ip->major].write(ip, src, n);
80101857:	83 ec 04             	sub    $0x4,%esp
8010185a:	ff 75 14             	push   0x14(%ebp)
8010185d:	ff 75 0c             	push   0xc(%ebp)
80101860:	ff 75 08             	push   0x8(%ebp)
80101863:	ff d0                	call   *%eax
80101865:	83 c4 10             	add    $0x10,%esp
80101868:	e9 85 00 00 00       	jmp    801018f2 <writei+0xf8>
    memmove(bp->data + off%BSIZE, src, m);
8010186d:	83 ec 04             	sub    $0x4,%esp
80101870:	56                   	push   %esi
80101871:	ff 75 0c             	push   0xc(%ebp)
80101874:	8d 44 13 5c          	lea    0x5c(%ebx,%edx,1),%eax
80101878:	50                   	push   %eax
80101879:	e8 93 23 00 00       	call   80103c11 <memmove>
    log_write(bp);
8010187e:	89 1c 24             	mov    %ebx,(%esp)
80101881:	e8 86 0f 00 00       	call   8010280c <log_write>
    brelse(bp);
80101886:	89 1c 24             	mov    %ebx,(%esp)
80101889:	e8 45 e9 ff ff       	call   801001d3 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010188e:	01 f7                	add    %esi,%edi
80101890:	01 75 10             	add    %esi,0x10(%ebp)
80101893:	01 75 0c             	add    %esi,0xc(%ebp)
80101896:	83 c4 10             	add    $0x10,%esp
80101899:	3b 7d 14             	cmp    0x14(%ebp),%edi
8010189c:	73 40                	jae    801018de <writei+0xe4>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010189e:	8b 55 10             	mov    0x10(%ebp),%edx
801018a1:	c1 ea 09             	shr    $0x9,%edx
801018a4:	8b 45 08             	mov    0x8(%ebp),%eax
801018a7:	e8 cf f7 ff ff       	call   8010107b <bmap>
801018ac:	83 ec 08             	sub    $0x8,%esp
801018af:	50                   	push   %eax
801018b0:	8b 45 08             	mov    0x8(%ebp),%eax
801018b3:	ff 30                	push   (%eax)
801018b5:	e8 b0 e8 ff ff       	call   8010016a <bread>
801018ba:	89 c3                	mov    %eax,%ebx
    m = min(n - tot, BSIZE - off%BSIZE);
801018bc:	8b 55 10             	mov    0x10(%ebp),%edx
801018bf:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801018c5:	b8 00 02 00 00       	mov    $0x200,%eax
801018ca:	29 d0                	sub    %edx,%eax
801018cc:	8b 4d 14             	mov    0x14(%ebp),%ecx
801018cf:	29 f9                	sub    %edi,%ecx
801018d1:	89 c6                	mov    %eax,%esi
801018d3:	83 c4 10             	add    $0x10,%esp
801018d6:	39 c8                	cmp    %ecx,%eax
801018d8:	76 93                	jbe    8010186d <writei+0x73>
801018da:	89 ce                	mov    %ecx,%esi
801018dc:	eb 8f                	jmp    8010186d <writei+0x73>
  if(n > 0 && off > ip->size){
801018de:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801018e2:	74 0b                	je     801018ef <writei+0xf5>
801018e4:	8b 45 08             	mov    0x8(%ebp),%eax
801018e7:	8b 7d 10             	mov    0x10(%ebp),%edi
801018ea:	39 78 58             	cmp    %edi,0x58(%eax)
801018ed:	72 0b                	jb     801018fa <writei+0x100>
  return n;
801018ef:	8b 45 14             	mov    0x14(%ebp),%eax
}
801018f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801018f5:	5b                   	pop    %ebx
801018f6:	5e                   	pop    %esi
801018f7:	5f                   	pop    %edi
801018f8:	5d                   	pop    %ebp
801018f9:	c3                   	ret    
    ip->size = off;
801018fa:	89 78 58             	mov    %edi,0x58(%eax)
    iupdate(ip);
801018fd:	83 ec 0c             	sub    $0xc,%esp
80101900:	50                   	push   %eax
80101901:	e8 ae fa ff ff       	call   801013b4 <iupdate>
80101906:	83 c4 10             	add    $0x10,%esp
80101909:	eb e4                	jmp    801018ef <writei+0xf5>
      return -1;
8010190b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101910:	eb e0                	jmp    801018f2 <writei+0xf8>
80101912:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101917:	eb d9                	jmp    801018f2 <writei+0xf8>
    return -1;
80101919:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010191e:	eb d2                	jmp    801018f2 <writei+0xf8>
80101920:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101925:	eb cb                	jmp    801018f2 <writei+0xf8>
    return -1;
80101927:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010192c:	eb c4                	jmp    801018f2 <writei+0xf8>

8010192e <namecmp>:
{
8010192e:	55                   	push   %ebp
8010192f:	89 e5                	mov    %esp,%ebp
80101931:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101934:	6a 0e                	push   $0xe
80101936:	ff 75 0c             	push   0xc(%ebp)
80101939:	ff 75 08             	push   0x8(%ebp)
8010193c:	e8 36 23 00 00       	call   80103c77 <strncmp>
}
80101941:	c9                   	leave  
80101942:	c3                   	ret    

80101943 <dirlookup>:
{
80101943:	55                   	push   %ebp
80101944:	89 e5                	mov    %esp,%ebp
80101946:	57                   	push   %edi
80101947:	56                   	push   %esi
80101948:	53                   	push   %ebx
80101949:	83 ec 1c             	sub    $0x1c,%esp
8010194c:	8b 75 08             	mov    0x8(%ebp),%esi
8010194f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(dp->type != T_DIR)
80101952:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101957:	75 07                	jne    80101960 <dirlookup+0x1d>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101959:	bb 00 00 00 00       	mov    $0x0,%ebx
8010195e:	eb 1d                	jmp    8010197d <dirlookup+0x3a>
    panic("dirlookup not DIR");
80101960:	83 ec 0c             	sub    $0xc,%esp
80101963:	68 67 68 10 80       	push   $0x80106867
80101968:	e8 d4 e9 ff ff       	call   80100341 <panic>
      panic("dirlookup read");
8010196d:	83 ec 0c             	sub    $0xc,%esp
80101970:	68 79 68 10 80       	push   $0x80106879
80101975:	e8 c7 e9 ff ff       	call   80100341 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
8010197a:	83 c3 10             	add    $0x10,%ebx
8010197d:	39 5e 58             	cmp    %ebx,0x58(%esi)
80101980:	76 48                	jbe    801019ca <dirlookup+0x87>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101982:	6a 10                	push   $0x10
80101984:	53                   	push   %ebx
80101985:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101988:	50                   	push   %eax
80101989:	56                   	push   %esi
8010198a:	e8 6b fd ff ff       	call   801016fa <readi>
8010198f:	83 c4 10             	add    $0x10,%esp
80101992:	83 f8 10             	cmp    $0x10,%eax
80101995:	75 d6                	jne    8010196d <dirlookup+0x2a>
    if(de.inum == 0)
80101997:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
8010199c:	74 dc                	je     8010197a <dirlookup+0x37>
    if(namecmp(name, de.name) == 0){
8010199e:	83 ec 08             	sub    $0x8,%esp
801019a1:	8d 45 da             	lea    -0x26(%ebp),%eax
801019a4:	50                   	push   %eax
801019a5:	57                   	push   %edi
801019a6:	e8 83 ff ff ff       	call   8010192e <namecmp>
801019ab:	83 c4 10             	add    $0x10,%esp
801019ae:	85 c0                	test   %eax,%eax
801019b0:	75 c8                	jne    8010197a <dirlookup+0x37>
      if(poff)
801019b2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801019b6:	74 05                	je     801019bd <dirlookup+0x7a>
        *poff = off;
801019b8:	8b 45 10             	mov    0x10(%ebp),%eax
801019bb:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
801019bd:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
801019c1:	8b 06                	mov    (%esi),%eax
801019c3:	e8 59 f7 ff ff       	call   80101121 <iget>
801019c8:	eb 05                	jmp    801019cf <dirlookup+0x8c>
  return 0;
801019ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
801019cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801019d2:	5b                   	pop    %ebx
801019d3:	5e                   	pop    %esi
801019d4:	5f                   	pop    %edi
801019d5:	5d                   	pop    %ebp
801019d6:	c3                   	ret    

801019d7 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801019d7:	55                   	push   %ebp
801019d8:	89 e5                	mov    %esp,%ebp
801019da:	57                   	push   %edi
801019db:	56                   	push   %esi
801019dc:	53                   	push   %ebx
801019dd:	83 ec 1c             	sub    $0x1c,%esp
801019e0:	89 c3                	mov    %eax,%ebx
801019e2:	89 55 e0             	mov    %edx,-0x20(%ebp)
801019e5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
801019e8:	80 38 2f             	cmpb   $0x2f,(%eax)
801019eb:	74 17                	je     80101a04 <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
801019ed:	e8 34 17 00 00       	call   80103126 <myproc>
801019f2:	83 ec 0c             	sub    $0xc,%esp
801019f5:	ff 70 70             	push   0x70(%eax)
801019f8:	e8 e2 fa ff ff       	call   801014df <idup>
801019fd:	89 c6                	mov    %eax,%esi
801019ff:	83 c4 10             	add    $0x10,%esp
80101a02:	eb 53                	jmp    80101a57 <namex+0x80>
    ip = iget(ROOTDEV, ROOTINO);
80101a04:	ba 01 00 00 00       	mov    $0x1,%edx
80101a09:	b8 01 00 00 00       	mov    $0x1,%eax
80101a0e:	e8 0e f7 ff ff       	call   80101121 <iget>
80101a13:	89 c6                	mov    %eax,%esi
80101a15:	eb 40                	jmp    80101a57 <namex+0x80>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101a17:	83 ec 0c             	sub    $0xc,%esp
80101a1a:	56                   	push   %esi
80101a1b:	e8 90 fc ff ff       	call   801016b0 <iunlockput>
      return 0;
80101a20:	83 c4 10             	add    $0x10,%esp
80101a23:	be 00 00 00 00       	mov    $0x0,%esi
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101a28:	89 f0                	mov    %esi,%eax
80101a2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a2d:	5b                   	pop    %ebx
80101a2e:	5e                   	pop    %esi
80101a2f:	5f                   	pop    %edi
80101a30:	5d                   	pop    %ebp
80101a31:	c3                   	ret    
    if((next = dirlookup(ip, name, 0)) == 0){
80101a32:	83 ec 04             	sub    $0x4,%esp
80101a35:	6a 00                	push   $0x0
80101a37:	ff 75 e4             	push   -0x1c(%ebp)
80101a3a:	56                   	push   %esi
80101a3b:	e8 03 ff ff ff       	call   80101943 <dirlookup>
80101a40:	89 c7                	mov    %eax,%edi
80101a42:	83 c4 10             	add    $0x10,%esp
80101a45:	85 c0                	test   %eax,%eax
80101a47:	74 4a                	je     80101a93 <namex+0xbc>
    iunlockput(ip);
80101a49:	83 ec 0c             	sub    $0xc,%esp
80101a4c:	56                   	push   %esi
80101a4d:	e8 5e fc ff ff       	call   801016b0 <iunlockput>
80101a52:	83 c4 10             	add    $0x10,%esp
    ip = next;
80101a55:	89 fe                	mov    %edi,%esi
  while((path = skipelem(path, name)) != 0){
80101a57:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101a5a:	89 d8                	mov    %ebx,%eax
80101a5c:	e8 97 f4 ff ff       	call   80100ef8 <skipelem>
80101a61:	89 c3                	mov    %eax,%ebx
80101a63:	85 c0                	test   %eax,%eax
80101a65:	74 3c                	je     80101aa3 <namex+0xcc>
    ilock(ip);
80101a67:	83 ec 0c             	sub    $0xc,%esp
80101a6a:	56                   	push   %esi
80101a6b:	e8 9d fa ff ff       	call   8010150d <ilock>
    if(ip->type != T_DIR){
80101a70:	83 c4 10             	add    $0x10,%esp
80101a73:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101a78:	75 9d                	jne    80101a17 <namex+0x40>
    if(nameiparent && *path == '\0'){
80101a7a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101a7e:	74 b2                	je     80101a32 <namex+0x5b>
80101a80:	80 3b 00             	cmpb   $0x0,(%ebx)
80101a83:	75 ad                	jne    80101a32 <namex+0x5b>
      iunlock(ip);
80101a85:	83 ec 0c             	sub    $0xc,%esp
80101a88:	56                   	push   %esi
80101a89:	e8 3f fb ff ff       	call   801015cd <iunlock>
      return ip;
80101a8e:	83 c4 10             	add    $0x10,%esp
80101a91:	eb 95                	jmp    80101a28 <namex+0x51>
      iunlockput(ip);
80101a93:	83 ec 0c             	sub    $0xc,%esp
80101a96:	56                   	push   %esi
80101a97:	e8 14 fc ff ff       	call   801016b0 <iunlockput>
      return 0;
80101a9c:	83 c4 10             	add    $0x10,%esp
80101a9f:	89 fe                	mov    %edi,%esi
80101aa1:	eb 85                	jmp    80101a28 <namex+0x51>
  if(nameiparent){
80101aa3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101aa7:	0f 84 7b ff ff ff    	je     80101a28 <namex+0x51>
    iput(ip);
80101aad:	83 ec 0c             	sub    $0xc,%esp
80101ab0:	56                   	push   %esi
80101ab1:	e8 5c fb ff ff       	call   80101612 <iput>
    return 0;
80101ab6:	83 c4 10             	add    $0x10,%esp
80101ab9:	89 de                	mov    %ebx,%esi
80101abb:	e9 68 ff ff ff       	jmp    80101a28 <namex+0x51>

80101ac0 <dirlink>:
{
80101ac0:	55                   	push   %ebp
80101ac1:	89 e5                	mov    %esp,%ebp
80101ac3:	57                   	push   %edi
80101ac4:	56                   	push   %esi
80101ac5:	53                   	push   %ebx
80101ac6:	83 ec 20             	sub    $0x20,%esp
80101ac9:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101acc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101acf:	6a 00                	push   $0x0
80101ad1:	57                   	push   %edi
80101ad2:	53                   	push   %ebx
80101ad3:	e8 6b fe ff ff       	call   80101943 <dirlookup>
80101ad8:	83 c4 10             	add    $0x10,%esp
80101adb:	85 c0                	test   %eax,%eax
80101add:	75 2d                	jne    80101b0c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101adf:	b8 00 00 00 00       	mov    $0x0,%eax
80101ae4:	89 c6                	mov    %eax,%esi
80101ae6:	39 43 58             	cmp    %eax,0x58(%ebx)
80101ae9:	76 41                	jbe    80101b2c <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101aeb:	6a 10                	push   $0x10
80101aed:	50                   	push   %eax
80101aee:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101af1:	50                   	push   %eax
80101af2:	53                   	push   %ebx
80101af3:	e8 02 fc ff ff       	call   801016fa <readi>
80101af8:	83 c4 10             	add    $0x10,%esp
80101afb:	83 f8 10             	cmp    $0x10,%eax
80101afe:	75 1f                	jne    80101b1f <dirlink+0x5f>
    if(de.inum == 0)
80101b00:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101b05:	74 25                	je     80101b2c <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b07:	8d 46 10             	lea    0x10(%esi),%eax
80101b0a:	eb d8                	jmp    80101ae4 <dirlink+0x24>
    iput(ip);
80101b0c:	83 ec 0c             	sub    $0xc,%esp
80101b0f:	50                   	push   %eax
80101b10:	e8 fd fa ff ff       	call   80101612 <iput>
    return -1;
80101b15:	83 c4 10             	add    $0x10,%esp
80101b18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b1d:	eb 3d                	jmp    80101b5c <dirlink+0x9c>
      panic("dirlink read");
80101b1f:	83 ec 0c             	sub    $0xc,%esp
80101b22:	68 88 68 10 80       	push   $0x80106888
80101b27:	e8 15 e8 ff ff       	call   80100341 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b2c:	83 ec 04             	sub    $0x4,%esp
80101b2f:	6a 0e                	push   $0xe
80101b31:	57                   	push   %edi
80101b32:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101b35:	8d 45 da             	lea    -0x26(%ebp),%eax
80101b38:	50                   	push   %eax
80101b39:	e8 71 21 00 00       	call   80103caf <strncpy>
  de.inum = inum;
80101b3e:	8b 45 10             	mov    0x10(%ebp),%eax
80101b41:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101b45:	6a 10                	push   $0x10
80101b47:	56                   	push   %esi
80101b48:	57                   	push   %edi
80101b49:	53                   	push   %ebx
80101b4a:	e8 ab fc ff ff       	call   801017fa <writei>
80101b4f:	83 c4 20             	add    $0x20,%esp
80101b52:	83 f8 10             	cmp    $0x10,%eax
80101b55:	75 0d                	jne    80101b64 <dirlink+0xa4>
  return 0;
80101b57:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101b5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b5f:	5b                   	pop    %ebx
80101b60:	5e                   	pop    %esi
80101b61:	5f                   	pop    %edi
80101b62:	5d                   	pop    %ebp
80101b63:	c3                   	ret    
    panic("dirlink");
80101b64:	83 ec 0c             	sub    $0xc,%esp
80101b67:	68 78 6e 10 80       	push   $0x80106e78
80101b6c:	e8 d0 e7 ff ff       	call   80100341 <panic>

80101b71 <namei>:

struct inode*
namei(char *path)
{
80101b71:	55                   	push   %ebp
80101b72:	89 e5                	mov    %esp,%ebp
80101b74:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101b77:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101b7a:	ba 00 00 00 00       	mov    $0x0,%edx
80101b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b82:	e8 50 fe ff ff       	call   801019d7 <namex>
}
80101b87:	c9                   	leave  
80101b88:	c3                   	ret    

80101b89 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101b89:	55                   	push   %ebp
80101b8a:	89 e5                	mov    %esp,%ebp
80101b8c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101b8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101b92:	ba 01 00 00 00       	mov    $0x1,%edx
80101b97:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9a:	e8 38 fe ff ff       	call   801019d7 <namex>
}
80101b9f:	c9                   	leave  
80101ba0:	c3                   	ret    

80101ba1 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101ba1:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101ba3:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101ba8:	ec                   	in     (%dx),%al
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101ba9:	88 c2                	mov    %al,%dl
80101bab:	83 e2 c0             	and    $0xffffffc0,%edx
80101bae:	80 fa 40             	cmp    $0x40,%dl
80101bb1:	75 f0                	jne    80101ba3 <idewait+0x2>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101bb3:	85 c9                	test   %ecx,%ecx
80101bb5:	74 09                	je     80101bc0 <idewait+0x1f>
80101bb7:	a8 21                	test   $0x21,%al
80101bb9:	75 08                	jne    80101bc3 <idewait+0x22>
    return -1;
  return 0;
80101bbb:	b9 00 00 00 00       	mov    $0x0,%ecx
}
80101bc0:	89 c8                	mov    %ecx,%eax
80101bc2:	c3                   	ret    
    return -1;
80101bc3:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
80101bc8:	eb f6                	jmp    80101bc0 <idewait+0x1f>

80101bca <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101bca:	55                   	push   %ebp
80101bcb:	89 e5                	mov    %esp,%ebp
80101bcd:	56                   	push   %esi
80101bce:	53                   	push   %ebx
  if(b == 0)
80101bcf:	85 c0                	test   %eax,%eax
80101bd1:	0f 84 85 00 00 00    	je     80101c5c <idestart+0x92>
80101bd7:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101bd9:	8b 58 08             	mov    0x8(%eax),%ebx
80101bdc:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101be2:	0f 87 81 00 00 00    	ja     80101c69 <idestart+0x9f>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101be8:	b8 00 00 00 00       	mov    $0x0,%eax
80101bed:	e8 af ff ff ff       	call   80101ba1 <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101bf2:	b0 00                	mov    $0x0,%al
80101bf4:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101bf9:	ee                   	out    %al,(%dx)
80101bfa:	b0 01                	mov    $0x1,%al
80101bfc:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101c01:	ee                   	out    %al,(%dx)
80101c02:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101c07:	88 d8                	mov    %bl,%al
80101c09:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101c0a:	0f b6 c7             	movzbl %bh,%eax
80101c0d:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101c12:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101c13:	89 d8                	mov    %ebx,%eax
80101c15:	c1 f8 10             	sar    $0x10,%eax
80101c18:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101c1d:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101c1e:	8a 46 04             	mov    0x4(%esi),%al
80101c21:	c1 e0 04             	shl    $0x4,%eax
80101c24:	83 e0 10             	and    $0x10,%eax
80101c27:	c1 fb 18             	sar    $0x18,%ebx
80101c2a:	83 e3 0f             	and    $0xf,%ebx
80101c2d:	09 d8                	or     %ebx,%eax
80101c2f:	83 c8 e0             	or     $0xffffffe0,%eax
80101c32:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101c37:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101c38:	f6 06 04             	testb  $0x4,(%esi)
80101c3b:	74 39                	je     80101c76 <idestart+0xac>
80101c3d:	b0 30                	mov    $0x30,%al
80101c3f:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c44:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
80101c45:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101c48:	b9 80 00 00 00       	mov    $0x80,%ecx
80101c4d:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101c52:	fc                   	cld    
80101c53:	f3 6f                	rep outsl %ds:(%esi),(%dx)
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101c55:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101c58:	5b                   	pop    %ebx
80101c59:	5e                   	pop    %esi
80101c5a:	5d                   	pop    %ebp
80101c5b:	c3                   	ret    
    panic("idestart");
80101c5c:	83 ec 0c             	sub    $0xc,%esp
80101c5f:	68 eb 68 10 80       	push   $0x801068eb
80101c64:	e8 d8 e6 ff ff       	call   80100341 <panic>
    panic("incorrect blockno");
80101c69:	83 ec 0c             	sub    $0xc,%esp
80101c6c:	68 f4 68 10 80       	push   $0x801068f4
80101c71:	e8 cb e6 ff ff       	call   80100341 <panic>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101c76:	b0 20                	mov    $0x20,%al
80101c78:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c7d:	ee                   	out    %al,(%dx)
}
80101c7e:	eb d5                	jmp    80101c55 <idestart+0x8b>

80101c80 <ideinit>:
{
80101c80:	55                   	push   %ebp
80101c81:	89 e5                	mov    %esp,%ebp
80101c83:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101c86:	68 06 69 10 80       	push   $0x80106906
80101c8b:	68 00 16 11 80       	push   $0x80111600
80101c90:	e8 23 1d 00 00       	call   801039b8 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101c95:	83 c4 08             	add    $0x8,%esp
80101c98:	a1 84 17 11 80       	mov    0x80111784,%eax
80101c9d:	48                   	dec    %eax
80101c9e:	50                   	push   %eax
80101c9f:	6a 0e                	push   $0xe
80101ca1:	e8 46 02 00 00       	call   80101eec <ioapicenable>
  idewait(0);
80101ca6:	b8 00 00 00 00       	mov    $0x0,%eax
80101cab:	e8 f1 fe ff ff       	call   80101ba1 <idewait>
80101cb0:	b0 f0                	mov    $0xf0,%al
80101cb2:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101cb7:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101cb8:	83 c4 10             	add    $0x10,%esp
80101cbb:	b9 00 00 00 00       	mov    $0x0,%ecx
80101cc0:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101cc6:	7f 17                	jg     80101cdf <ideinit+0x5f>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101cc8:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101ccd:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101cce:	84 c0                	test   %al,%al
80101cd0:	75 03                	jne    80101cd5 <ideinit+0x55>
  for(i=0; i<1000; i++){
80101cd2:	41                   	inc    %ecx
80101cd3:	eb eb                	jmp    80101cc0 <ideinit+0x40>
      havedisk1 = 1;
80101cd5:	c7 05 e0 15 11 80 01 	movl   $0x1,0x801115e0
80101cdc:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101cdf:	b0 e0                	mov    $0xe0,%al
80101ce1:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101ce6:	ee                   	out    %al,(%dx)
}
80101ce7:	c9                   	leave  
80101ce8:	c3                   	ret    

80101ce9 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101ce9:	55                   	push   %ebp
80101cea:	89 e5                	mov    %esp,%ebp
80101cec:	57                   	push   %edi
80101ced:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101cee:	83 ec 0c             	sub    $0xc,%esp
80101cf1:	68 00 16 11 80       	push   $0x80111600
80101cf6:	e8 f4 1d 00 00       	call   80103aef <acquire>

  if((b = idequeue) == 0){
80101cfb:	8b 1d e4 15 11 80    	mov    0x801115e4,%ebx
80101d01:	83 c4 10             	add    $0x10,%esp
80101d04:	85 db                	test   %ebx,%ebx
80101d06:	74 4a                	je     80101d52 <ideintr+0x69>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101d08:	8b 43 58             	mov    0x58(%ebx),%eax
80101d0b:	a3 e4 15 11 80       	mov    %eax,0x801115e4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101d10:	f6 03 04             	testb  $0x4,(%ebx)
80101d13:	74 4f                	je     80101d64 <ideintr+0x7b>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101d15:	8b 03                	mov    (%ebx),%eax
80101d17:	83 c8 02             	or     $0x2,%eax
80101d1a:	89 03                	mov    %eax,(%ebx)
  b->flags &= ~B_DIRTY;
80101d1c:	83 e0 fb             	and    $0xfffffffb,%eax
80101d1f:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101d21:	83 ec 0c             	sub    $0xc,%esp
80101d24:	53                   	push   %ebx
80101d25:	e8 31 1a 00 00       	call   8010375b <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101d2a:	a1 e4 15 11 80       	mov    0x801115e4,%eax
80101d2f:	83 c4 10             	add    $0x10,%esp
80101d32:	85 c0                	test   %eax,%eax
80101d34:	74 05                	je     80101d3b <ideintr+0x52>
    idestart(idequeue);
80101d36:	e8 8f fe ff ff       	call   80101bca <idestart>

  release(&idelock);
80101d3b:	83 ec 0c             	sub    $0xc,%esp
80101d3e:	68 00 16 11 80       	push   $0x80111600
80101d43:	e8 0c 1e 00 00       	call   80103b54 <release>
80101d48:	83 c4 10             	add    $0x10,%esp
}
80101d4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101d4e:	5b                   	pop    %ebx
80101d4f:	5f                   	pop    %edi
80101d50:	5d                   	pop    %ebp
80101d51:	c3                   	ret    
    release(&idelock);
80101d52:	83 ec 0c             	sub    $0xc,%esp
80101d55:	68 00 16 11 80       	push   $0x80111600
80101d5a:	e8 f5 1d 00 00       	call   80103b54 <release>
    return;
80101d5f:	83 c4 10             	add    $0x10,%esp
80101d62:	eb e7                	jmp    80101d4b <ideintr+0x62>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101d64:	b8 01 00 00 00       	mov    $0x1,%eax
80101d69:	e8 33 fe ff ff       	call   80101ba1 <idewait>
80101d6e:	85 c0                	test   %eax,%eax
80101d70:	78 a3                	js     80101d15 <ideintr+0x2c>
    insl(0x1f0, b->data, BSIZE/4);
80101d72:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101d75:	b9 80 00 00 00       	mov    $0x80,%ecx
80101d7a:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101d7f:	fc                   	cld    
80101d80:	f3 6d                	rep insl (%dx),%es:(%edi)
}
80101d82:	eb 91                	jmp    80101d15 <ideintr+0x2c>

80101d84 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101d84:	55                   	push   %ebp
80101d85:	89 e5                	mov    %esp,%ebp
80101d87:	53                   	push   %ebx
80101d88:	83 ec 10             	sub    $0x10,%esp
80101d8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101d8e:	8d 43 0c             	lea    0xc(%ebx),%eax
80101d91:	50                   	push   %eax
80101d92:	e8 d3 1b 00 00       	call   8010396a <holdingsleep>
80101d97:	83 c4 10             	add    $0x10,%esp
80101d9a:	85 c0                	test   %eax,%eax
80101d9c:	74 37                	je     80101dd5 <iderw+0x51>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101d9e:	8b 03                	mov    (%ebx),%eax
80101da0:	83 e0 06             	and    $0x6,%eax
80101da3:	83 f8 02             	cmp    $0x2,%eax
80101da6:	74 3a                	je     80101de2 <iderw+0x5e>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101da8:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101dac:	74 09                	je     80101db7 <iderw+0x33>
80101dae:	83 3d e0 15 11 80 00 	cmpl   $0x0,0x801115e0
80101db5:	74 38                	je     80101def <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101db7:	83 ec 0c             	sub    $0xc,%esp
80101dba:	68 00 16 11 80       	push   $0x80111600
80101dbf:	e8 2b 1d 00 00       	call   80103aef <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101dc4:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101dcb:	83 c4 10             	add    $0x10,%esp
80101dce:	ba e4 15 11 80       	mov    $0x801115e4,%edx
80101dd3:	eb 2a                	jmp    80101dff <iderw+0x7b>
    panic("iderw: buf not locked");
80101dd5:	83 ec 0c             	sub    $0xc,%esp
80101dd8:	68 0a 69 10 80       	push   $0x8010690a
80101ddd:	e8 5f e5 ff ff       	call   80100341 <panic>
    panic("iderw: nothing to do");
80101de2:	83 ec 0c             	sub    $0xc,%esp
80101de5:	68 20 69 10 80       	push   $0x80106920
80101dea:	e8 52 e5 ff ff       	call   80100341 <panic>
    panic("iderw: ide disk 1 not present");
80101def:	83 ec 0c             	sub    $0xc,%esp
80101df2:	68 35 69 10 80       	push   $0x80106935
80101df7:	e8 45 e5 ff ff       	call   80100341 <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101dfc:	8d 50 58             	lea    0x58(%eax),%edx
80101dff:	8b 02                	mov    (%edx),%eax
80101e01:	85 c0                	test   %eax,%eax
80101e03:	75 f7                	jne    80101dfc <iderw+0x78>
    ;
  *pp = b;
80101e05:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101e07:	39 1d e4 15 11 80    	cmp    %ebx,0x801115e4
80101e0d:	75 1a                	jne    80101e29 <iderw+0xa5>
    idestart(b);
80101e0f:	89 d8                	mov    %ebx,%eax
80101e11:	e8 b4 fd ff ff       	call   80101bca <idestart>
80101e16:	eb 11                	jmp    80101e29 <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101e18:	83 ec 08             	sub    $0x8,%esp
80101e1b:	68 00 16 11 80       	push   $0x80111600
80101e20:	53                   	push   %ebx
80101e21:	e8 be 17 00 00       	call   801035e4 <sleep>
80101e26:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101e29:	8b 03                	mov    (%ebx),%eax
80101e2b:	83 e0 06             	and    $0x6,%eax
80101e2e:	83 f8 02             	cmp    $0x2,%eax
80101e31:	75 e5                	jne    80101e18 <iderw+0x94>
  }


  release(&idelock);
80101e33:	83 ec 0c             	sub    $0xc,%esp
80101e36:	68 00 16 11 80       	push   $0x80111600
80101e3b:	e8 14 1d 00 00       	call   80103b54 <release>
}
80101e40:	83 c4 10             	add    $0x10,%esp
80101e43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101e46:	c9                   	leave  
80101e47:	c3                   	ret    

80101e48 <ioapicread>:
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
80101e48:	8b 15 34 16 11 80    	mov    0x80111634,%edx
80101e4e:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101e50:	a1 34 16 11 80       	mov    0x80111634,%eax
80101e55:	8b 40 10             	mov    0x10(%eax),%eax
}
80101e58:	c3                   	ret    

80101e59 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80101e59:	8b 0d 34 16 11 80    	mov    0x80111634,%ecx
80101e5f:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101e61:	a1 34 16 11 80       	mov    0x80111634,%eax
80101e66:	89 50 10             	mov    %edx,0x10(%eax)
}
80101e69:	c3                   	ret    

80101e6a <ioapicinit>:

void
ioapicinit(void)
{
80101e6a:	55                   	push   %ebp
80101e6b:	89 e5                	mov    %esp,%ebp
80101e6d:	57                   	push   %edi
80101e6e:	56                   	push   %esi
80101e6f:	53                   	push   %ebx
80101e70:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101e73:	c7 05 34 16 11 80 00 	movl   $0xfec00000,0x80111634
80101e7a:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101e7d:	b8 01 00 00 00       	mov    $0x1,%eax
80101e82:	e8 c1 ff ff ff       	call   80101e48 <ioapicread>
80101e87:	c1 e8 10             	shr    $0x10,%eax
80101e8a:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80101e8d:	b8 00 00 00 00       	mov    $0x0,%eax
80101e92:	e8 b1 ff ff ff       	call   80101e48 <ioapicread>
80101e97:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101e9a:	0f b6 15 80 17 11 80 	movzbl 0x80111780,%edx
80101ea1:	39 c2                	cmp    %eax,%edx
80101ea3:	75 07                	jne    80101eac <ioapicinit+0x42>
{
80101ea5:	bb 00 00 00 00       	mov    $0x0,%ebx
80101eaa:	eb 34                	jmp    80101ee0 <ioapicinit+0x76>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101eac:	83 ec 0c             	sub    $0xc,%esp
80101eaf:	68 54 69 10 80       	push   $0x80106954
80101eb4:	e8 21 e7 ff ff       	call   801005da <cprintf>
80101eb9:	83 c4 10             	add    $0x10,%esp
80101ebc:	eb e7                	jmp    80101ea5 <ioapicinit+0x3b>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101ebe:	8d 53 20             	lea    0x20(%ebx),%edx
80101ec1:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101ec7:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101ecb:	89 f0                	mov    %esi,%eax
80101ecd:	e8 87 ff ff ff       	call   80101e59 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101ed2:	8d 46 01             	lea    0x1(%esi),%eax
80101ed5:	ba 00 00 00 00       	mov    $0x0,%edx
80101eda:	e8 7a ff ff ff       	call   80101e59 <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80101edf:	43                   	inc    %ebx
80101ee0:	39 fb                	cmp    %edi,%ebx
80101ee2:	7e da                	jle    80101ebe <ioapicinit+0x54>
  }
}
80101ee4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101ee7:	5b                   	pop    %ebx
80101ee8:	5e                   	pop    %esi
80101ee9:	5f                   	pop    %edi
80101eea:	5d                   	pop    %ebp
80101eeb:	c3                   	ret    

80101eec <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80101eec:	55                   	push   %ebp
80101eed:	89 e5                	mov    %esp,%ebp
80101eef:	53                   	push   %ebx
80101ef0:	83 ec 04             	sub    $0x4,%esp
80101ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101ef6:	8d 50 20             	lea    0x20(%eax),%edx
80101ef9:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80101efd:	89 d8                	mov    %ebx,%eax
80101eff:	e8 55 ff ff ff       	call   80101e59 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101f04:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f07:	c1 e2 18             	shl    $0x18,%edx
80101f0a:	8d 43 01             	lea    0x1(%ebx),%eax
80101f0d:	e8 47 ff ff ff       	call   80101e59 <ioapicwrite>
}
80101f12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101f15:	c9                   	leave  
80101f16:	c3                   	ret    

80101f17 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80101f17:	55                   	push   %ebp
80101f18:	89 e5                	mov    %esp,%ebp
80101f1a:	53                   	push   %ebx
80101f1b:	83 ec 04             	sub    $0x4,%esp
80101f1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80101f21:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80101f27:	75 4c                	jne    80101f75 <kfree+0x5e>
80101f29:	81 fb d0 56 11 80    	cmp    $0x801156d0,%ebx
80101f2f:	72 44                	jb     80101f75 <kfree+0x5e>
80101f31:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80101f37:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80101f3c:	77 37                	ja     80101f75 <kfree+0x5e>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80101f3e:	83 ec 04             	sub    $0x4,%esp
80101f41:	68 00 10 00 00       	push   $0x1000
80101f46:	6a 01                	push   $0x1
80101f48:	53                   	push   %ebx
80101f49:	e8 4d 1c 00 00       	call   80103b9b <memset>

  if(kmem.use_lock)
80101f4e:	83 c4 10             	add    $0x10,%esp
80101f51:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80101f58:	75 28                	jne    80101f82 <kfree+0x6b>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80101f5a:	a1 78 16 11 80       	mov    0x80111678,%eax
80101f5f:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80101f61:	89 1d 78 16 11 80    	mov    %ebx,0x80111678
  if(kmem.use_lock)
80101f67:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80101f6e:	75 24                	jne    80101f94 <kfree+0x7d>
    release(&kmem.lock);
}
80101f70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101f73:	c9                   	leave  
80101f74:	c3                   	ret    
    panic("kfree");
80101f75:	83 ec 0c             	sub    $0xc,%esp
80101f78:	68 86 69 10 80       	push   $0x80106986
80101f7d:	e8 bf e3 ff ff       	call   80100341 <panic>
    acquire(&kmem.lock);
80101f82:	83 ec 0c             	sub    $0xc,%esp
80101f85:	68 40 16 11 80       	push   $0x80111640
80101f8a:	e8 60 1b 00 00       	call   80103aef <acquire>
80101f8f:	83 c4 10             	add    $0x10,%esp
80101f92:	eb c6                	jmp    80101f5a <kfree+0x43>
    release(&kmem.lock);
80101f94:	83 ec 0c             	sub    $0xc,%esp
80101f97:	68 40 16 11 80       	push   $0x80111640
80101f9c:	e8 b3 1b 00 00       	call   80103b54 <release>
80101fa1:	83 c4 10             	add    $0x10,%esp
}
80101fa4:	eb ca                	jmp    80101f70 <kfree+0x59>

80101fa6 <freerange>:
{
80101fa6:	55                   	push   %ebp
80101fa7:	89 e5                	mov    %esp,%ebp
80101fa9:	56                   	push   %esi
80101faa:	53                   	push   %ebx
80101fab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  p = (char*)PGROUNDUP((uint)vstart);
80101fae:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb1:	05 ff 0f 00 00       	add    $0xfff,%eax
80101fb6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80101fbb:	eb 0e                	jmp    80101fcb <freerange+0x25>
    kfree(p);
80101fbd:	83 ec 0c             	sub    $0xc,%esp
80101fc0:	50                   	push   %eax
80101fc1:	e8 51 ff ff ff       	call   80101f17 <kfree>
80101fc6:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80101fc9:	89 f0                	mov    %esi,%eax
80101fcb:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
80101fd1:	39 de                	cmp    %ebx,%esi
80101fd3:	76 e8                	jbe    80101fbd <freerange+0x17>
}
80101fd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101fd8:	5b                   	pop    %ebx
80101fd9:	5e                   	pop    %esi
80101fda:	5d                   	pop    %ebp
80101fdb:	c3                   	ret    

80101fdc <kinit1>:
{
80101fdc:	55                   	push   %ebp
80101fdd:	89 e5                	mov    %esp,%ebp
80101fdf:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
80101fe2:	68 8c 69 10 80       	push   $0x8010698c
80101fe7:	68 40 16 11 80       	push   $0x80111640
80101fec:	e8 c7 19 00 00       	call   801039b8 <initlock>
  kmem.use_lock = 0;
80101ff1:	c7 05 74 16 11 80 00 	movl   $0x0,0x80111674
80101ff8:	00 00 00 
  freerange(vstart, vend);
80101ffb:	83 c4 08             	add    $0x8,%esp
80101ffe:	ff 75 0c             	push   0xc(%ebp)
80102001:	ff 75 08             	push   0x8(%ebp)
80102004:	e8 9d ff ff ff       	call   80101fa6 <freerange>
}
80102009:	83 c4 10             	add    $0x10,%esp
8010200c:	c9                   	leave  
8010200d:	c3                   	ret    

8010200e <kinit2>:
{
8010200e:	55                   	push   %ebp
8010200f:	89 e5                	mov    %esp,%ebp
80102011:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
80102014:	ff 75 0c             	push   0xc(%ebp)
80102017:	ff 75 08             	push   0x8(%ebp)
8010201a:	e8 87 ff ff ff       	call   80101fa6 <freerange>
  kmem.use_lock = 1;
8010201f:	c7 05 74 16 11 80 01 	movl   $0x1,0x80111674
80102026:	00 00 00 
}
80102029:	83 c4 10             	add    $0x10,%esp
8010202c:	c9                   	leave  
8010202d:	c3                   	ret    

8010202e <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
8010202e:	55                   	push   %ebp
8010202f:	89 e5                	mov    %esp,%ebp
80102031:	53                   	push   %ebx
80102032:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
80102035:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
8010203c:	75 21                	jne    8010205f <kalloc+0x31>
    acquire(&kmem.lock);
  r = kmem.freelist;
8010203e:	8b 1d 78 16 11 80    	mov    0x80111678,%ebx
  if(r)
80102044:	85 db                	test   %ebx,%ebx
80102046:	74 07                	je     8010204f <kalloc+0x21>
    kmem.freelist = r->next;
80102048:	8b 03                	mov    (%ebx),%eax
8010204a:	a3 78 16 11 80       	mov    %eax,0x80111678
  if(kmem.use_lock)
8010204f:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80102056:	75 19                	jne    80102071 <kalloc+0x43>
    release(&kmem.lock);
  return (char*)r;
}
80102058:	89 d8                	mov    %ebx,%eax
8010205a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010205d:	c9                   	leave  
8010205e:	c3                   	ret    
    acquire(&kmem.lock);
8010205f:	83 ec 0c             	sub    $0xc,%esp
80102062:	68 40 16 11 80       	push   $0x80111640
80102067:	e8 83 1a 00 00       	call   80103aef <acquire>
8010206c:	83 c4 10             	add    $0x10,%esp
8010206f:	eb cd                	jmp    8010203e <kalloc+0x10>
    release(&kmem.lock);
80102071:	83 ec 0c             	sub    $0xc,%esp
80102074:	68 40 16 11 80       	push   $0x80111640
80102079:	e8 d6 1a 00 00       	call   80103b54 <release>
8010207e:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102081:	eb d5                	jmp    80102058 <kalloc+0x2a>

80102083 <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102083:	ba 64 00 00 00       	mov    $0x64,%edx
80102088:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102089:	a8 01                	test   $0x1,%al
8010208b:	0f 84 b3 00 00 00    	je     80102144 <kbdgetc+0xc1>
80102091:	ba 60 00 00 00       	mov    $0x60,%edx
80102096:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102097:	0f b6 c8             	movzbl %al,%ecx

  if(data == 0xE0){
8010209a:	3c e0                	cmp    $0xe0,%al
8010209c:	74 61                	je     801020ff <kbdgetc+0x7c>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
8010209e:	84 c0                	test   %al,%al
801020a0:	78 6a                	js     8010210c <kbdgetc+0x89>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801020a2:	8b 15 7c 16 11 80    	mov    0x8011167c,%edx
801020a8:	f6 c2 40             	test   $0x40,%dl
801020ab:	74 0f                	je     801020bc <kbdgetc+0x39>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801020ad:	83 c8 80             	or     $0xffffff80,%eax
801020b0:	0f b6 c8             	movzbl %al,%ecx
    shift &= ~E0ESC;
801020b3:	83 e2 bf             	and    $0xffffffbf,%edx
801020b6:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  }

  shift |= shiftcode[data];
801020bc:	0f b6 91 c0 6a 10 80 	movzbl -0x7fef9540(%ecx),%edx
801020c3:	0b 15 7c 16 11 80    	or     0x8011167c,%edx
801020c9:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  shift ^= togglecode[data];
801020cf:	0f b6 81 c0 69 10 80 	movzbl -0x7fef9640(%ecx),%eax
801020d6:	31 c2                	xor    %eax,%edx
801020d8:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  c = charcode[shift & (CTL | SHIFT)][data];
801020de:	89 d0                	mov    %edx,%eax
801020e0:	83 e0 03             	and    $0x3,%eax
801020e3:	8b 04 85 a0 69 10 80 	mov    -0x7fef9660(,%eax,4),%eax
801020ea:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
  if(shift & CAPSLOCK){
801020ee:	f6 c2 08             	test   $0x8,%dl
801020f1:	74 56                	je     80102149 <kbdgetc+0xc6>
    if('a' <= c && c <= 'z')
801020f3:	8d 50 9f             	lea    -0x61(%eax),%edx
801020f6:	83 fa 19             	cmp    $0x19,%edx
801020f9:	77 3d                	ja     80102138 <kbdgetc+0xb5>
      c += 'A' - 'a';
801020fb:	83 e8 20             	sub    $0x20,%eax
801020fe:	c3                   	ret    
    shift |= E0ESC;
801020ff:	83 0d 7c 16 11 80 40 	orl    $0x40,0x8011167c
    return 0;
80102106:	b8 00 00 00 00       	mov    $0x0,%eax
8010210b:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
8010210c:	8b 15 7c 16 11 80    	mov    0x8011167c,%edx
80102112:	f6 c2 40             	test   $0x40,%dl
80102115:	75 05                	jne    8010211c <kbdgetc+0x99>
80102117:	89 c1                	mov    %eax,%ecx
80102119:	83 e1 7f             	and    $0x7f,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
8010211c:	8a 81 c0 6a 10 80    	mov    -0x7fef9540(%ecx),%al
80102122:	83 c8 40             	or     $0x40,%eax
80102125:	0f b6 c0             	movzbl %al,%eax
80102128:	f7 d0                	not    %eax
8010212a:	21 c2                	and    %eax,%edx
8010212c:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
    return 0;
80102132:	b8 00 00 00 00       	mov    $0x0,%eax
80102137:	c3                   	ret    
    else if('A' <= c && c <= 'Z')
80102138:	8d 50 bf             	lea    -0x41(%eax),%edx
8010213b:	83 fa 19             	cmp    $0x19,%edx
8010213e:	77 09                	ja     80102149 <kbdgetc+0xc6>
      c += 'a' - 'A';
80102140:	83 c0 20             	add    $0x20,%eax
  }
  return c;
80102143:	c3                   	ret    
    return -1;
80102144:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102149:	c3                   	ret    

8010214a <kbdintr>:

void
kbdintr(void)
{
8010214a:	55                   	push   %ebp
8010214b:	89 e5                	mov    %esp,%ebp
8010214d:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102150:	68 83 20 10 80       	push   $0x80102083
80102155:	e8 a5 e5 ff ff       	call   801006ff <consoleintr>
}
8010215a:	83 c4 10             	add    $0x10,%esp
8010215d:	c9                   	leave  
8010215e:	c3                   	ret    

8010215f <lapicw>:

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010215f:	8b 0d 80 16 11 80    	mov    0x80111680,%ecx
80102165:	8d 04 81             	lea    (%ecx,%eax,4),%eax
80102168:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010216a:	a1 80 16 11 80       	mov    0x80111680,%eax
8010216f:	8b 40 20             	mov    0x20(%eax),%eax
}
80102172:	c3                   	ret    

80102173 <cmos_read>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102173:	ba 70 00 00 00       	mov    $0x70,%edx
80102178:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102179:	ba 71 00 00 00       	mov    $0x71,%edx
8010217e:	ec                   	in     (%dx),%al
cmos_read(uint reg)
{
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
8010217f:	0f b6 c0             	movzbl %al,%eax
}
80102182:	c3                   	ret    

80102183 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
80102183:	55                   	push   %ebp
80102184:	89 e5                	mov    %esp,%ebp
80102186:	53                   	push   %ebx
80102187:	83 ec 04             	sub    $0x4,%esp
8010218a:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
8010218c:	b8 00 00 00 00       	mov    $0x0,%eax
80102191:	e8 dd ff ff ff       	call   80102173 <cmos_read>
80102196:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
80102198:	b8 02 00 00 00       	mov    $0x2,%eax
8010219d:	e8 d1 ff ff ff       	call   80102173 <cmos_read>
801021a2:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
801021a5:	b8 04 00 00 00       	mov    $0x4,%eax
801021aa:	e8 c4 ff ff ff       	call   80102173 <cmos_read>
801021af:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
801021b2:	b8 07 00 00 00       	mov    $0x7,%eax
801021b7:	e8 b7 ff ff ff       	call   80102173 <cmos_read>
801021bc:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
801021bf:	b8 08 00 00 00       	mov    $0x8,%eax
801021c4:	e8 aa ff ff ff       	call   80102173 <cmos_read>
801021c9:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
801021cc:	b8 09 00 00 00       	mov    $0x9,%eax
801021d1:	e8 9d ff ff ff       	call   80102173 <cmos_read>
801021d6:	89 43 14             	mov    %eax,0x14(%ebx)
}
801021d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801021dc:	c9                   	leave  
801021dd:	c3                   	ret    

801021de <lapicinit>:
  if(!lapic)
801021de:	83 3d 80 16 11 80 00 	cmpl   $0x0,0x80111680
801021e5:	0f 84 fe 00 00 00    	je     801022e9 <lapicinit+0x10b>
{
801021eb:	55                   	push   %ebp
801021ec:	89 e5                	mov    %esp,%ebp
801021ee:	83 ec 08             	sub    $0x8,%esp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801021f1:	ba 3f 01 00 00       	mov    $0x13f,%edx
801021f6:	b8 3c 00 00 00       	mov    $0x3c,%eax
801021fb:	e8 5f ff ff ff       	call   8010215f <lapicw>
  lapicw(TDCR, X1);
80102200:	ba 0b 00 00 00       	mov    $0xb,%edx
80102205:	b8 f8 00 00 00       	mov    $0xf8,%eax
8010220a:	e8 50 ff ff ff       	call   8010215f <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010220f:	ba 20 00 02 00       	mov    $0x20020,%edx
80102214:	b8 c8 00 00 00       	mov    $0xc8,%eax
80102219:	e8 41 ff ff ff       	call   8010215f <lapicw>
  lapicw(TICR, 10000000);
8010221e:	ba 80 96 98 00       	mov    $0x989680,%edx
80102223:	b8 e0 00 00 00       	mov    $0xe0,%eax
80102228:	e8 32 ff ff ff       	call   8010215f <lapicw>
  lapicw(LINT0, MASKED);
8010222d:	ba 00 00 01 00       	mov    $0x10000,%edx
80102232:	b8 d4 00 00 00       	mov    $0xd4,%eax
80102237:	e8 23 ff ff ff       	call   8010215f <lapicw>
  lapicw(LINT1, MASKED);
8010223c:	ba 00 00 01 00       	mov    $0x10000,%edx
80102241:	b8 d8 00 00 00       	mov    $0xd8,%eax
80102246:	e8 14 ff ff ff       	call   8010215f <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010224b:	a1 80 16 11 80       	mov    0x80111680,%eax
80102250:	8b 40 30             	mov    0x30(%eax),%eax
80102253:	c1 e8 10             	shr    $0x10,%eax
80102256:	a8 fc                	test   $0xfc,%al
80102258:	75 7b                	jne    801022d5 <lapicinit+0xf7>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010225a:	ba 33 00 00 00       	mov    $0x33,%edx
8010225f:	b8 dc 00 00 00       	mov    $0xdc,%eax
80102264:	e8 f6 fe ff ff       	call   8010215f <lapicw>
  lapicw(ESR, 0);
80102269:	ba 00 00 00 00       	mov    $0x0,%edx
8010226e:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102273:	e8 e7 fe ff ff       	call   8010215f <lapicw>
  lapicw(ESR, 0);
80102278:	ba 00 00 00 00       	mov    $0x0,%edx
8010227d:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102282:	e8 d8 fe ff ff       	call   8010215f <lapicw>
  lapicw(EOI, 0);
80102287:	ba 00 00 00 00       	mov    $0x0,%edx
8010228c:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102291:	e8 c9 fe ff ff       	call   8010215f <lapicw>
  lapicw(ICRHI, 0);
80102296:	ba 00 00 00 00       	mov    $0x0,%edx
8010229b:	b8 c4 00 00 00       	mov    $0xc4,%eax
801022a0:	e8 ba fe ff ff       	call   8010215f <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801022a5:	ba 00 85 08 00       	mov    $0x88500,%edx
801022aa:	b8 c0 00 00 00       	mov    $0xc0,%eax
801022af:	e8 ab fe ff ff       	call   8010215f <lapicw>
  while(lapic[ICRLO] & DELIVS)
801022b4:	a1 80 16 11 80       	mov    0x80111680,%eax
801022b9:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
801022bf:	f6 c4 10             	test   $0x10,%ah
801022c2:	75 f0                	jne    801022b4 <lapicinit+0xd6>
  lapicw(TPR, 0);
801022c4:	ba 00 00 00 00       	mov    $0x0,%edx
801022c9:	b8 20 00 00 00       	mov    $0x20,%eax
801022ce:	e8 8c fe ff ff       	call   8010215f <lapicw>
}
801022d3:	c9                   	leave  
801022d4:	c3                   	ret    
    lapicw(PCINT, MASKED);
801022d5:	ba 00 00 01 00       	mov    $0x10000,%edx
801022da:	b8 d0 00 00 00       	mov    $0xd0,%eax
801022df:	e8 7b fe ff ff       	call   8010215f <lapicw>
801022e4:	e9 71 ff ff ff       	jmp    8010225a <lapicinit+0x7c>
801022e9:	c3                   	ret    

801022ea <lapicid>:
  if (!lapic)
801022ea:	a1 80 16 11 80       	mov    0x80111680,%eax
801022ef:	85 c0                	test   %eax,%eax
801022f1:	74 07                	je     801022fa <lapicid+0x10>
  return lapic[ID] >> 24;
801022f3:	8b 40 20             	mov    0x20(%eax),%eax
801022f6:	c1 e8 18             	shr    $0x18,%eax
801022f9:	c3                   	ret    
    return 0;
801022fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022ff:	c3                   	ret    

80102300 <lapiceoi>:
  if(lapic)
80102300:	83 3d 80 16 11 80 00 	cmpl   $0x0,0x80111680
80102307:	74 17                	je     80102320 <lapiceoi+0x20>
{
80102309:	55                   	push   %ebp
8010230a:	89 e5                	mov    %esp,%ebp
8010230c:	83 ec 08             	sub    $0x8,%esp
    lapicw(EOI, 0);
8010230f:	ba 00 00 00 00       	mov    $0x0,%edx
80102314:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102319:	e8 41 fe ff ff       	call   8010215f <lapicw>
}
8010231e:	c9                   	leave  
8010231f:	c3                   	ret    
80102320:	c3                   	ret    

80102321 <microdelay>:
}
80102321:	c3                   	ret    

80102322 <lapicstartap>:
{
80102322:	55                   	push   %ebp
80102323:	89 e5                	mov    %esp,%ebp
80102325:	57                   	push   %edi
80102326:	56                   	push   %esi
80102327:	53                   	push   %ebx
80102328:	83 ec 0c             	sub    $0xc,%esp
8010232b:	8b 75 08             	mov    0x8(%ebp),%esi
8010232e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102331:	b0 0f                	mov    $0xf,%al
80102333:	ba 70 00 00 00       	mov    $0x70,%edx
80102338:	ee                   	out    %al,(%dx)
80102339:	b0 0a                	mov    $0xa,%al
8010233b:	ba 71 00 00 00       	mov    $0x71,%edx
80102340:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
80102341:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
80102348:	00 00 
  wrv[1] = addr >> 4;
8010234a:	89 f8                	mov    %edi,%eax
8010234c:	c1 e8 04             	shr    $0x4,%eax
8010234f:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
80102355:	c1 e6 18             	shl    $0x18,%esi
80102358:	89 f2                	mov    %esi,%edx
8010235a:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010235f:	e8 fb fd ff ff       	call   8010215f <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102364:	ba 00 c5 00 00       	mov    $0xc500,%edx
80102369:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010236e:	e8 ec fd ff ff       	call   8010215f <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
80102373:	ba 00 85 00 00       	mov    $0x8500,%edx
80102378:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010237d:	e8 dd fd ff ff       	call   8010215f <lapicw>
  for(i = 0; i < 2; i++){
80102382:	bb 00 00 00 00       	mov    $0x0,%ebx
80102387:	eb 1f                	jmp    801023a8 <lapicstartap+0x86>
    lapicw(ICRHI, apicid<<24);
80102389:	89 f2                	mov    %esi,%edx
8010238b:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102390:	e8 ca fd ff ff       	call   8010215f <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102395:	89 fa                	mov    %edi,%edx
80102397:	c1 ea 0c             	shr    $0xc,%edx
8010239a:	80 ce 06             	or     $0x6,%dh
8010239d:	b8 c0 00 00 00       	mov    $0xc0,%eax
801023a2:	e8 b8 fd ff ff       	call   8010215f <lapicw>
  for(i = 0; i < 2; i++){
801023a7:	43                   	inc    %ebx
801023a8:	83 fb 01             	cmp    $0x1,%ebx
801023ab:	7e dc                	jle    80102389 <lapicstartap+0x67>
}
801023ad:	83 c4 0c             	add    $0xc,%esp
801023b0:	5b                   	pop    %ebx
801023b1:	5e                   	pop    %esi
801023b2:	5f                   	pop    %edi
801023b3:	5d                   	pop    %ebp
801023b4:	c3                   	ret    

801023b5 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801023b5:	55                   	push   %ebp
801023b6:	89 e5                	mov    %esp,%ebp
801023b8:	57                   	push   %edi
801023b9:	56                   	push   %esi
801023ba:	53                   	push   %ebx
801023bb:	83 ec 3c             	sub    $0x3c,%esp
801023be:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801023c1:	b8 0b 00 00 00       	mov    $0xb,%eax
801023c6:	e8 a8 fd ff ff       	call   80102173 <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
801023cb:	83 e0 04             	and    $0x4,%eax
801023ce:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801023d0:	8d 45 d0             	lea    -0x30(%ebp),%eax
801023d3:	e8 ab fd ff ff       	call   80102183 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801023d8:	b8 0a 00 00 00       	mov    $0xa,%eax
801023dd:	e8 91 fd ff ff       	call   80102173 <cmos_read>
801023e2:	a8 80                	test   $0x80,%al
801023e4:	75 ea                	jne    801023d0 <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
801023e6:	8d 75 b8             	lea    -0x48(%ebp),%esi
801023e9:	89 f0                	mov    %esi,%eax
801023eb:	e8 93 fd ff ff       	call   80102183 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801023f0:	83 ec 04             	sub    $0x4,%esp
801023f3:	6a 18                	push   $0x18
801023f5:	56                   	push   %esi
801023f6:	8d 45 d0             	lea    -0x30(%ebp),%eax
801023f9:	50                   	push   %eax
801023fa:	e8 e3 17 00 00       	call   80103be2 <memcmp>
801023ff:	83 c4 10             	add    $0x10,%esp
80102402:	85 c0                	test   %eax,%eax
80102404:	75 ca                	jne    801023d0 <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
80102406:	85 ff                	test   %edi,%edi
80102408:	75 7e                	jne    80102488 <cmostime+0xd3>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010240a:	8b 55 d0             	mov    -0x30(%ebp),%edx
8010240d:	89 d0                	mov    %edx,%eax
8010240f:	c1 e8 04             	shr    $0x4,%eax
80102412:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102415:	01 c0                	add    %eax,%eax
80102417:	83 e2 0f             	and    $0xf,%edx
8010241a:	01 d0                	add    %edx,%eax
8010241c:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
8010241f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80102422:	89 d0                	mov    %edx,%eax
80102424:	c1 e8 04             	shr    $0x4,%eax
80102427:	8d 04 80             	lea    (%eax,%eax,4),%eax
8010242a:	01 c0                	add    %eax,%eax
8010242c:	83 e2 0f             	and    $0xf,%edx
8010242f:	01 d0                	add    %edx,%eax
80102431:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
80102434:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102437:	89 d0                	mov    %edx,%eax
80102439:	c1 e8 04             	shr    $0x4,%eax
8010243c:	8d 04 80             	lea    (%eax,%eax,4),%eax
8010243f:	01 c0                	add    %eax,%eax
80102441:	83 e2 0f             	and    $0xf,%edx
80102444:	01 d0                	add    %edx,%eax
80102446:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
80102449:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010244c:	89 d0                	mov    %edx,%eax
8010244e:	c1 e8 04             	shr    $0x4,%eax
80102451:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102454:	01 c0                	add    %eax,%eax
80102456:	83 e2 0f             	and    $0xf,%edx
80102459:	01 d0                	add    %edx,%eax
8010245b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
8010245e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102461:	89 d0                	mov    %edx,%eax
80102463:	c1 e8 04             	shr    $0x4,%eax
80102466:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102469:	01 c0                	add    %eax,%eax
8010246b:	83 e2 0f             	and    $0xf,%edx
8010246e:	01 d0                	add    %edx,%eax
80102470:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
80102473:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102476:	89 d0                	mov    %edx,%eax
80102478:	c1 e8 04             	shr    $0x4,%eax
8010247b:	8d 04 80             	lea    (%eax,%eax,4),%eax
8010247e:	01 c0                	add    %eax,%eax
80102480:	83 e2 0f             	and    $0xf,%edx
80102483:	01 d0                	add    %edx,%eax
80102485:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
80102488:	8d 75 d0             	lea    -0x30(%ebp),%esi
8010248b:	b9 06 00 00 00       	mov    $0x6,%ecx
80102490:	89 df                	mov    %ebx,%edi
80102492:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
80102494:	81 43 14 d0 07 00 00 	addl   $0x7d0,0x14(%ebx)
}
8010249b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010249e:	5b                   	pop    %ebx
8010249f:	5e                   	pop    %esi
801024a0:	5f                   	pop    %edi
801024a1:	5d                   	pop    %ebp
801024a2:	c3                   	ret    

801024a3 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801024a3:	55                   	push   %ebp
801024a4:	89 e5                	mov    %esp,%ebp
801024a6:	53                   	push   %ebx
801024a7:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801024aa:	ff 35 d4 16 11 80    	push   0x801116d4
801024b0:	ff 35 e4 16 11 80    	push   0x801116e4
801024b6:	e8 af dc ff ff       	call   8010016a <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
801024bb:	8b 58 5c             	mov    0x5c(%eax),%ebx
801024be:	89 1d e8 16 11 80    	mov    %ebx,0x801116e8
  for (i = 0; i < log.lh.n; i++) {
801024c4:	83 c4 10             	add    $0x10,%esp
801024c7:	ba 00 00 00 00       	mov    $0x0,%edx
801024cc:	eb 0c                	jmp    801024da <read_head+0x37>
    log.lh.block[i] = lh->block[i];
801024ce:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
801024d2:	89 0c 95 ec 16 11 80 	mov    %ecx,-0x7feee914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801024d9:	42                   	inc    %edx
801024da:	39 d3                	cmp    %edx,%ebx
801024dc:	7f f0                	jg     801024ce <read_head+0x2b>
  }
  brelse(buf);
801024de:	83 ec 0c             	sub    $0xc,%esp
801024e1:	50                   	push   %eax
801024e2:	e8 ec dc ff ff       	call   801001d3 <brelse>
}
801024e7:	83 c4 10             	add    $0x10,%esp
801024ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801024ed:	c9                   	leave  
801024ee:	c3                   	ret    

801024ef <install_trans>:
{
801024ef:	55                   	push   %ebp
801024f0:	89 e5                	mov    %esp,%ebp
801024f2:	57                   	push   %edi
801024f3:	56                   	push   %esi
801024f4:	53                   	push   %ebx
801024f5:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801024f8:	be 00 00 00 00       	mov    $0x0,%esi
801024fd:	eb 62                	jmp    80102561 <install_trans+0x72>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801024ff:	89 f0                	mov    %esi,%eax
80102501:	03 05 d4 16 11 80    	add    0x801116d4,%eax
80102507:	40                   	inc    %eax
80102508:	83 ec 08             	sub    $0x8,%esp
8010250b:	50                   	push   %eax
8010250c:	ff 35 e4 16 11 80    	push   0x801116e4
80102512:	e8 53 dc ff ff       	call   8010016a <bread>
80102517:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102519:	83 c4 08             	add    $0x8,%esp
8010251c:	ff 34 b5 ec 16 11 80 	push   -0x7feee914(,%esi,4)
80102523:	ff 35 e4 16 11 80    	push   0x801116e4
80102529:	e8 3c dc ff ff       	call   8010016a <bread>
8010252e:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102530:	8d 57 5c             	lea    0x5c(%edi),%edx
80102533:	8d 40 5c             	lea    0x5c(%eax),%eax
80102536:	83 c4 0c             	add    $0xc,%esp
80102539:	68 00 02 00 00       	push   $0x200
8010253e:	52                   	push   %edx
8010253f:	50                   	push   %eax
80102540:	e8 cc 16 00 00       	call   80103c11 <memmove>
    bwrite(dbuf);  // write dst to disk
80102545:	89 1c 24             	mov    %ebx,(%esp)
80102548:	e8 4b dc ff ff       	call   80100198 <bwrite>
    brelse(lbuf);
8010254d:	89 3c 24             	mov    %edi,(%esp)
80102550:	e8 7e dc ff ff       	call   801001d3 <brelse>
    brelse(dbuf);
80102555:	89 1c 24             	mov    %ebx,(%esp)
80102558:	e8 76 dc ff ff       	call   801001d3 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
8010255d:	46                   	inc    %esi
8010255e:	83 c4 10             	add    $0x10,%esp
80102561:	39 35 e8 16 11 80    	cmp    %esi,0x801116e8
80102567:	7f 96                	jg     801024ff <install_trans+0x10>
}
80102569:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010256c:	5b                   	pop    %ebx
8010256d:	5e                   	pop    %esi
8010256e:	5f                   	pop    %edi
8010256f:	5d                   	pop    %ebp
80102570:	c3                   	ret    

80102571 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102571:	55                   	push   %ebp
80102572:	89 e5                	mov    %esp,%ebp
80102574:	53                   	push   %ebx
80102575:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102578:	ff 35 d4 16 11 80    	push   0x801116d4
8010257e:	ff 35 e4 16 11 80    	push   0x801116e4
80102584:	e8 e1 db ff ff       	call   8010016a <bread>
80102589:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
8010258b:	8b 0d e8 16 11 80    	mov    0x801116e8,%ecx
80102591:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102594:	83 c4 10             	add    $0x10,%esp
80102597:	b8 00 00 00 00       	mov    $0x0,%eax
8010259c:	eb 0c                	jmp    801025aa <write_head+0x39>
    hb->block[i] = log.lh.block[i];
8010259e:	8b 14 85 ec 16 11 80 	mov    -0x7feee914(,%eax,4),%edx
801025a5:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
801025a9:	40                   	inc    %eax
801025aa:	39 c1                	cmp    %eax,%ecx
801025ac:	7f f0                	jg     8010259e <write_head+0x2d>
  }
  bwrite(buf);
801025ae:	83 ec 0c             	sub    $0xc,%esp
801025b1:	53                   	push   %ebx
801025b2:	e8 e1 db ff ff       	call   80100198 <bwrite>
  brelse(buf);
801025b7:	89 1c 24             	mov    %ebx,(%esp)
801025ba:	e8 14 dc ff ff       	call   801001d3 <brelse>
}
801025bf:	83 c4 10             	add    $0x10,%esp
801025c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801025c5:	c9                   	leave  
801025c6:	c3                   	ret    

801025c7 <recover_from_log>:

static void
recover_from_log(void)
{
801025c7:	55                   	push   %ebp
801025c8:	89 e5                	mov    %esp,%ebp
801025ca:	83 ec 08             	sub    $0x8,%esp
  read_head();
801025cd:	e8 d1 fe ff ff       	call   801024a3 <read_head>
  install_trans(); // if committed, copy from log to disk
801025d2:	e8 18 ff ff ff       	call   801024ef <install_trans>
  log.lh.n = 0;
801025d7:	c7 05 e8 16 11 80 00 	movl   $0x0,0x801116e8
801025de:	00 00 00 
  write_head(); // clear the log
801025e1:	e8 8b ff ff ff       	call   80102571 <write_head>
}
801025e6:	c9                   	leave  
801025e7:	c3                   	ret    

801025e8 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801025e8:	55                   	push   %ebp
801025e9:	89 e5                	mov    %esp,%ebp
801025eb:	57                   	push   %edi
801025ec:	56                   	push   %esi
801025ed:	53                   	push   %ebx
801025ee:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801025f1:	be 00 00 00 00       	mov    $0x0,%esi
801025f6:	eb 62                	jmp    8010265a <write_log+0x72>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801025f8:	89 f0                	mov    %esi,%eax
801025fa:	03 05 d4 16 11 80    	add    0x801116d4,%eax
80102600:	40                   	inc    %eax
80102601:	83 ec 08             	sub    $0x8,%esp
80102604:	50                   	push   %eax
80102605:	ff 35 e4 16 11 80    	push   0x801116e4
8010260b:	e8 5a db ff ff       	call   8010016a <bread>
80102610:	89 c3                	mov    %eax,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102612:	83 c4 08             	add    $0x8,%esp
80102615:	ff 34 b5 ec 16 11 80 	push   -0x7feee914(,%esi,4)
8010261c:	ff 35 e4 16 11 80    	push   0x801116e4
80102622:	e8 43 db ff ff       	call   8010016a <bread>
80102627:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102629:	8d 50 5c             	lea    0x5c(%eax),%edx
8010262c:	8d 43 5c             	lea    0x5c(%ebx),%eax
8010262f:	83 c4 0c             	add    $0xc,%esp
80102632:	68 00 02 00 00       	push   $0x200
80102637:	52                   	push   %edx
80102638:	50                   	push   %eax
80102639:	e8 d3 15 00 00       	call   80103c11 <memmove>
    bwrite(to);  // write the log
8010263e:	89 1c 24             	mov    %ebx,(%esp)
80102641:	e8 52 db ff ff       	call   80100198 <bwrite>
    brelse(from);
80102646:	89 3c 24             	mov    %edi,(%esp)
80102649:	e8 85 db ff ff       	call   801001d3 <brelse>
    brelse(to);
8010264e:	89 1c 24             	mov    %ebx,(%esp)
80102651:	e8 7d db ff ff       	call   801001d3 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102656:	46                   	inc    %esi
80102657:	83 c4 10             	add    $0x10,%esp
8010265a:	39 35 e8 16 11 80    	cmp    %esi,0x801116e8
80102660:	7f 96                	jg     801025f8 <write_log+0x10>
  }
}
80102662:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102665:	5b                   	pop    %ebx
80102666:	5e                   	pop    %esi
80102667:	5f                   	pop    %edi
80102668:	5d                   	pop    %ebp
80102669:	c3                   	ret    

8010266a <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
8010266a:	83 3d e8 16 11 80 00 	cmpl   $0x0,0x801116e8
80102671:	7f 01                	jg     80102674 <commit+0xa>
80102673:	c3                   	ret    
{
80102674:	55                   	push   %ebp
80102675:	89 e5                	mov    %esp,%ebp
80102677:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
8010267a:	e8 69 ff ff ff       	call   801025e8 <write_log>
    write_head();    // Write header to disk -- the real commit
8010267f:	e8 ed fe ff ff       	call   80102571 <write_head>
    install_trans(); // Now install writes to home locations
80102684:	e8 66 fe ff ff       	call   801024ef <install_trans>
    log.lh.n = 0;
80102689:	c7 05 e8 16 11 80 00 	movl   $0x0,0x801116e8
80102690:	00 00 00 
    write_head();    // Erase the transaction from the log
80102693:	e8 d9 fe ff ff       	call   80102571 <write_head>
  }
}
80102698:	c9                   	leave  
80102699:	c3                   	ret    

8010269a <initlog>:
{
8010269a:	55                   	push   %ebp
8010269b:	89 e5                	mov    %esp,%ebp
8010269d:	53                   	push   %ebx
8010269e:	83 ec 2c             	sub    $0x2c,%esp
801026a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
801026a4:	68 c0 6b 10 80       	push   $0x80106bc0
801026a9:	68 a0 16 11 80       	push   $0x801116a0
801026ae:	e8 05 13 00 00       	call   801039b8 <initlock>
  readsb(dev, &sb);
801026b3:	83 c4 08             	add    $0x8,%esp
801026b6:	8d 45 dc             	lea    -0x24(%ebp),%eax
801026b9:	50                   	push   %eax
801026ba:	53                   	push   %ebx
801026bb:	e8 0e eb ff ff       	call   801011ce <readsb>
  log.start = sb.logstart;
801026c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801026c3:	a3 d4 16 11 80       	mov    %eax,0x801116d4
  log.size = sb.nlog;
801026c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801026cb:	a3 d8 16 11 80       	mov    %eax,0x801116d8
  log.dev = dev;
801026d0:	89 1d e4 16 11 80    	mov    %ebx,0x801116e4
  recover_from_log();
801026d6:	e8 ec fe ff ff       	call   801025c7 <recover_from_log>
}
801026db:	83 c4 10             	add    $0x10,%esp
801026de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801026e1:	c9                   	leave  
801026e2:	c3                   	ret    

801026e3 <begin_op>:
{
801026e3:	55                   	push   %ebp
801026e4:	89 e5                	mov    %esp,%ebp
801026e6:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
801026e9:	68 a0 16 11 80       	push   $0x801116a0
801026ee:	e8 fc 13 00 00       	call   80103aef <acquire>
801026f3:	83 c4 10             	add    $0x10,%esp
801026f6:	eb 15                	jmp    8010270d <begin_op+0x2a>
      sleep(&log, &log.lock);
801026f8:	83 ec 08             	sub    $0x8,%esp
801026fb:	68 a0 16 11 80       	push   $0x801116a0
80102700:	68 a0 16 11 80       	push   $0x801116a0
80102705:	e8 da 0e 00 00       	call   801035e4 <sleep>
8010270a:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
8010270d:	83 3d e0 16 11 80 00 	cmpl   $0x0,0x801116e0
80102714:	75 e2                	jne    801026f8 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102716:	a1 dc 16 11 80       	mov    0x801116dc,%eax
8010271b:	8d 48 01             	lea    0x1(%eax),%ecx
8010271e:	8d 54 80 05          	lea    0x5(%eax,%eax,4),%edx
80102722:	8d 04 12             	lea    (%edx,%edx,1),%eax
80102725:	03 05 e8 16 11 80    	add    0x801116e8,%eax
8010272b:	83 f8 1e             	cmp    $0x1e,%eax
8010272e:	7e 17                	jle    80102747 <begin_op+0x64>
      sleep(&log, &log.lock);
80102730:	83 ec 08             	sub    $0x8,%esp
80102733:	68 a0 16 11 80       	push   $0x801116a0
80102738:	68 a0 16 11 80       	push   $0x801116a0
8010273d:	e8 a2 0e 00 00       	call   801035e4 <sleep>
80102742:	83 c4 10             	add    $0x10,%esp
80102745:	eb c6                	jmp    8010270d <begin_op+0x2a>
      log.outstanding += 1;
80102747:	89 0d dc 16 11 80    	mov    %ecx,0x801116dc
      release(&log.lock);
8010274d:	83 ec 0c             	sub    $0xc,%esp
80102750:	68 a0 16 11 80       	push   $0x801116a0
80102755:	e8 fa 13 00 00       	call   80103b54 <release>
}
8010275a:	83 c4 10             	add    $0x10,%esp
8010275d:	c9                   	leave  
8010275e:	c3                   	ret    

8010275f <end_op>:
{
8010275f:	55                   	push   %ebp
80102760:	89 e5                	mov    %esp,%ebp
80102762:	53                   	push   %ebx
80102763:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102766:	68 a0 16 11 80       	push   $0x801116a0
8010276b:	e8 7f 13 00 00       	call   80103aef <acquire>
  log.outstanding -= 1;
80102770:	a1 dc 16 11 80       	mov    0x801116dc,%eax
80102775:	48                   	dec    %eax
80102776:	a3 dc 16 11 80       	mov    %eax,0x801116dc
  if(log.committing)
8010277b:	8b 1d e0 16 11 80    	mov    0x801116e0,%ebx
80102781:	83 c4 10             	add    $0x10,%esp
80102784:	85 db                	test   %ebx,%ebx
80102786:	75 2c                	jne    801027b4 <end_op+0x55>
  if(log.outstanding == 0){
80102788:	85 c0                	test   %eax,%eax
8010278a:	75 35                	jne    801027c1 <end_op+0x62>
    log.committing = 1;
8010278c:	c7 05 e0 16 11 80 01 	movl   $0x1,0x801116e0
80102793:	00 00 00 
    do_commit = 1;
80102796:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
8010279b:	83 ec 0c             	sub    $0xc,%esp
8010279e:	68 a0 16 11 80       	push   $0x801116a0
801027a3:	e8 ac 13 00 00       	call   80103b54 <release>
  if(do_commit){
801027a8:	83 c4 10             	add    $0x10,%esp
801027ab:	85 db                	test   %ebx,%ebx
801027ad:	75 24                	jne    801027d3 <end_op+0x74>
}
801027af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027b2:	c9                   	leave  
801027b3:	c3                   	ret    
    panic("log.committing");
801027b4:	83 ec 0c             	sub    $0xc,%esp
801027b7:	68 c4 6b 10 80       	push   $0x80106bc4
801027bc:	e8 80 db ff ff       	call   80100341 <panic>
    wakeup(&log);
801027c1:	83 ec 0c             	sub    $0xc,%esp
801027c4:	68 a0 16 11 80       	push   $0x801116a0
801027c9:	e8 8d 0f 00 00       	call   8010375b <wakeup>
801027ce:	83 c4 10             	add    $0x10,%esp
801027d1:	eb c8                	jmp    8010279b <end_op+0x3c>
    commit();
801027d3:	e8 92 fe ff ff       	call   8010266a <commit>
    acquire(&log.lock);
801027d8:	83 ec 0c             	sub    $0xc,%esp
801027db:	68 a0 16 11 80       	push   $0x801116a0
801027e0:	e8 0a 13 00 00       	call   80103aef <acquire>
    log.committing = 0;
801027e5:	c7 05 e0 16 11 80 00 	movl   $0x0,0x801116e0
801027ec:	00 00 00 
    wakeup(&log);
801027ef:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
801027f6:	e8 60 0f 00 00       	call   8010375b <wakeup>
    release(&log.lock);
801027fb:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
80102802:	e8 4d 13 00 00       	call   80103b54 <release>
80102807:	83 c4 10             	add    $0x10,%esp
}
8010280a:	eb a3                	jmp    801027af <end_op+0x50>

8010280c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010280c:	55                   	push   %ebp
8010280d:	89 e5                	mov    %esp,%ebp
8010280f:	53                   	push   %ebx
80102810:	83 ec 04             	sub    $0x4,%esp
80102813:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102816:	8b 15 e8 16 11 80    	mov    0x801116e8,%edx
8010281c:	83 fa 1d             	cmp    $0x1d,%edx
8010281f:	7f 2a                	jg     8010284b <log_write+0x3f>
80102821:	a1 d8 16 11 80       	mov    0x801116d8,%eax
80102826:	48                   	dec    %eax
80102827:	39 c2                	cmp    %eax,%edx
80102829:	7d 20                	jge    8010284b <log_write+0x3f>
    panic("too big a transaction");
  if (log.outstanding < 1)
8010282b:	83 3d dc 16 11 80 00 	cmpl   $0x0,0x801116dc
80102832:	7e 24                	jle    80102858 <log_write+0x4c>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102834:	83 ec 0c             	sub    $0xc,%esp
80102837:	68 a0 16 11 80       	push   $0x801116a0
8010283c:	e8 ae 12 00 00       	call   80103aef <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102841:	83 c4 10             	add    $0x10,%esp
80102844:	b8 00 00 00 00       	mov    $0x0,%eax
80102849:	eb 1b                	jmp    80102866 <log_write+0x5a>
    panic("too big a transaction");
8010284b:	83 ec 0c             	sub    $0xc,%esp
8010284e:	68 d3 6b 10 80       	push   $0x80106bd3
80102853:	e8 e9 da ff ff       	call   80100341 <panic>
    panic("log_write outside of trans");
80102858:	83 ec 0c             	sub    $0xc,%esp
8010285b:	68 e9 6b 10 80       	push   $0x80106be9
80102860:	e8 dc da ff ff       	call   80100341 <panic>
  for (i = 0; i < log.lh.n; i++) {
80102865:	40                   	inc    %eax
80102866:	8b 15 e8 16 11 80    	mov    0x801116e8,%edx
8010286c:	39 c2                	cmp    %eax,%edx
8010286e:	7e 0c                	jle    8010287c <log_write+0x70>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102870:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102873:	39 0c 85 ec 16 11 80 	cmp    %ecx,-0x7feee914(,%eax,4)
8010287a:	75 e9                	jne    80102865 <log_write+0x59>
      break;
  }
  log.lh.block[i] = b->blockno;
8010287c:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010287f:	89 0c 85 ec 16 11 80 	mov    %ecx,-0x7feee914(,%eax,4)
  if (i == log.lh.n)
80102886:	39 c2                	cmp    %eax,%edx
80102888:	74 18                	je     801028a2 <log_write+0x96>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
8010288a:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
8010288d:	83 ec 0c             	sub    $0xc,%esp
80102890:	68 a0 16 11 80       	push   $0x801116a0
80102895:	e8 ba 12 00 00       	call   80103b54 <release>
}
8010289a:	83 c4 10             	add    $0x10,%esp
8010289d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801028a0:	c9                   	leave  
801028a1:	c3                   	ret    
    log.lh.n++;
801028a2:	42                   	inc    %edx
801028a3:	89 15 e8 16 11 80    	mov    %edx,0x801116e8
801028a9:	eb df                	jmp    8010288a <log_write+0x7e>

801028ab <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801028ab:	55                   	push   %ebp
801028ac:	89 e5                	mov    %esp,%ebp
801028ae:	53                   	push   %ebx
801028af:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801028b2:	68 8e 00 00 00       	push   $0x8e
801028b7:	68 8c a4 10 80       	push   $0x8010a48c
801028bc:	68 00 70 00 80       	push   $0x80007000
801028c1:	e8 4b 13 00 00       	call   80103c11 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801028c6:	83 c4 10             	add    $0x10,%esp
801028c9:	bb a0 17 11 80       	mov    $0x801117a0,%ebx
801028ce:	eb 06                	jmp    801028d6 <startothers+0x2b>
801028d0:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801028d6:	8b 15 84 17 11 80    	mov    0x80111784,%edx
801028dc:	8d 04 92             	lea    (%edx,%edx,4),%eax
801028df:	01 c0                	add    %eax,%eax
801028e1:	01 d0                	add    %edx,%eax
801028e3:	c1 e0 04             	shl    $0x4,%eax
801028e6:	05 a0 17 11 80       	add    $0x801117a0,%eax
801028eb:	39 d8                	cmp    %ebx,%eax
801028ed:	76 4c                	jbe    8010293b <startothers+0x90>
    if(c == mycpu())  // We've started already.
801028ef:	e8 9d 07 00 00       	call   80103091 <mycpu>
801028f4:	39 c3                	cmp    %eax,%ebx
801028f6:	74 d8                	je     801028d0 <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801028f8:	e8 31 f7 ff ff       	call   8010202e <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
801028fd:	05 00 10 00 00       	add    $0x1000,%eax
80102902:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102907:	c7 05 f8 6f 00 80 7f 	movl   $0x8010297f,0x80006ff8
8010290e:	29 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102911:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102918:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
8010291b:	83 ec 08             	sub    $0x8,%esp
8010291e:	68 00 70 00 00       	push   $0x7000
80102923:	0f b6 03             	movzbl (%ebx),%eax
80102926:	50                   	push   %eax
80102927:	e8 f6 f9 ff ff       	call   80102322 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010292c:	83 c4 10             	add    $0x10,%esp
8010292f:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102935:	85 c0                	test   %eax,%eax
80102937:	74 f6                	je     8010292f <startothers+0x84>
80102939:	eb 95                	jmp    801028d0 <startothers+0x25>
      ;
  }
}
8010293b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010293e:	c9                   	leave  
8010293f:	c3                   	ret    

80102940 <mpmain>:
{
80102940:	55                   	push   %ebp
80102941:	89 e5                	mov    %esp,%ebp
80102943:	53                   	push   %ebx
80102944:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102947:	e8 a9 07 00 00       	call   801030f5 <cpuid>
8010294c:	89 c3                	mov    %eax,%ebx
8010294e:	e8 a2 07 00 00       	call   801030f5 <cpuid>
80102953:	83 ec 04             	sub    $0x4,%esp
80102956:	53                   	push   %ebx
80102957:	50                   	push   %eax
80102958:	68 04 6c 10 80       	push   $0x80106c04
8010295d:	e8 78 dc ff ff       	call   801005da <cprintf>
  idtinit();       // load idt register
80102962:	e8 c3 24 00 00       	call   80104e2a <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102967:	e8 25 07 00 00       	call   80103091 <mycpu>
8010296c:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010296e:	b8 01 00 00 00       	mov    $0x1,%eax
80102973:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
8010297a:	e8 25 0a 00 00       	call   801033a4 <scheduler>

8010297f <mpenter>:
{
8010297f:	55                   	push   %ebp
80102980:	89 e5                	mov    %esp,%ebp
80102982:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102985:	e8 dd 36 00 00       	call   80106067 <switchkvm>
  seginit();
8010298a:	e8 92 33 00 00       	call   80105d21 <seginit>
  lapicinit();
8010298f:	e8 4a f8 ff ff       	call   801021de <lapicinit>
  mpmain();
80102994:	e8 a7 ff ff ff       	call   80102940 <mpmain>

80102999 <main>:
{
80102999:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010299d:	83 e4 f0             	and    $0xfffffff0,%esp
801029a0:	ff 71 fc             	push   -0x4(%ecx)
801029a3:	55                   	push   %ebp
801029a4:	89 e5                	mov    %esp,%ebp
801029a6:	51                   	push   %ecx
801029a7:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801029aa:	68 00 00 40 80       	push   $0x80400000
801029af:	68 d0 56 11 80       	push   $0x801156d0
801029b4:	e8 23 f6 ff ff       	call   80101fdc <kinit1>
  kvmalloc();      // kernel page table
801029b9:	e8 78 3b 00 00       	call   80106536 <kvmalloc>
  mpinit();        // detect other processors
801029be:	e8 b8 01 00 00       	call   80102b7b <mpinit>
  lapicinit();     // interrupt controller
801029c3:	e8 16 f8 ff ff       	call   801021de <lapicinit>
  seginit();       // segment descriptors
801029c8:	e8 54 33 00 00       	call   80105d21 <seginit>
  picinit();       // disable pic
801029cd:	e8 79 02 00 00       	call   80102c4b <picinit>
  ioapicinit();    // another interrupt controller
801029d2:	e8 93 f4 ff ff       	call   80101e6a <ioapicinit>
  consoleinit();   // console hardware
801029d7:	e8 70 de ff ff       	call   8010084c <consoleinit>
  uartinit();      // serial port
801029dc:	e8 b8 27 00 00       	call   80105199 <uartinit>
  pinit();         // process table
801029e1:	e8 91 06 00 00       	call   80103077 <pinit>
  tvinit();        // trap vectors
801029e6:	e8 42 23 00 00       	call   80104d2d <tvinit>
  binit();         // buffer cache
801029eb:	e8 02 d7 ff ff       	call   801000f2 <binit>
  fileinit();      // file table
801029f0:	e8 de e1 ff ff       	call   80100bd3 <fileinit>
  ideinit();       // disk 
801029f5:	e8 86 f2 ff ff       	call   80101c80 <ideinit>
  startothers();   // start other processors
801029fa:	e8 ac fe ff ff       	call   801028ab <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801029ff:	83 c4 08             	add    $0x8,%esp
80102a02:	68 00 00 00 8e       	push   $0x8e000000
80102a07:	68 00 00 40 80       	push   $0x80400000
80102a0c:	e8 fd f5 ff ff       	call   8010200e <kinit2>
  userinit();      // first user process
80102a11:	e8 33 07 00 00       	call   80103149 <userinit>
  mpmain();        // finish this processor's setup
80102a16:	e8 25 ff ff ff       	call   80102940 <mpmain>

80102a1b <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102a1b:	55                   	push   %ebp
80102a1c:	89 e5                	mov    %esp,%ebp
80102a1e:	56                   	push   %esi
80102a1f:	53                   	push   %ebx
80102a20:	89 c6                	mov    %eax,%esi
  int i, sum;

  sum = 0;
80102a22:	b8 00 00 00 00       	mov    $0x0,%eax
  for(i=0; i<len; i++)
80102a27:	b9 00 00 00 00       	mov    $0x0,%ecx
80102a2c:	eb 07                	jmp    80102a35 <sum+0x1a>
    sum += addr[i];
80102a2e:	0f b6 1c 0e          	movzbl (%esi,%ecx,1),%ebx
80102a32:	01 d8                	add    %ebx,%eax
  for(i=0; i<len; i++)
80102a34:	41                   	inc    %ecx
80102a35:	39 d1                	cmp    %edx,%ecx
80102a37:	7c f5                	jl     80102a2e <sum+0x13>
  return sum;
}
80102a39:	5b                   	pop    %ebx
80102a3a:	5e                   	pop    %esi
80102a3b:	5d                   	pop    %ebp
80102a3c:	c3                   	ret    

80102a3d <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102a3d:	55                   	push   %ebp
80102a3e:	89 e5                	mov    %esp,%ebp
80102a40:	56                   	push   %esi
80102a41:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102a42:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102a48:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102a4a:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102a4c:	eb 03                	jmp    80102a51 <mpsearch1+0x14>
80102a4e:	83 c3 10             	add    $0x10,%ebx
80102a51:	39 f3                	cmp    %esi,%ebx
80102a53:	73 29                	jae    80102a7e <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102a55:	83 ec 04             	sub    $0x4,%esp
80102a58:	6a 04                	push   $0x4
80102a5a:	68 18 6c 10 80       	push   $0x80106c18
80102a5f:	53                   	push   %ebx
80102a60:	e8 7d 11 00 00       	call   80103be2 <memcmp>
80102a65:	83 c4 10             	add    $0x10,%esp
80102a68:	85 c0                	test   %eax,%eax
80102a6a:	75 e2                	jne    80102a4e <mpsearch1+0x11>
80102a6c:	ba 10 00 00 00       	mov    $0x10,%edx
80102a71:	89 d8                	mov    %ebx,%eax
80102a73:	e8 a3 ff ff ff       	call   80102a1b <sum>
80102a78:	84 c0                	test   %al,%al
80102a7a:	75 d2                	jne    80102a4e <mpsearch1+0x11>
80102a7c:	eb 05                	jmp    80102a83 <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102a7e:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102a83:	89 d8                	mov    %ebx,%eax
80102a85:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102a88:	5b                   	pop    %ebx
80102a89:	5e                   	pop    %esi
80102a8a:	5d                   	pop    %ebp
80102a8b:	c3                   	ret    

80102a8c <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102a8c:	55                   	push   %ebp
80102a8d:	89 e5                	mov    %esp,%ebp
80102a8f:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102a92:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102a99:	c1 e0 08             	shl    $0x8,%eax
80102a9c:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102aa3:	09 d0                	or     %edx,%eax
80102aa5:	c1 e0 04             	shl    $0x4,%eax
80102aa8:	74 1f                	je     80102ac9 <mpsearch+0x3d>
    if((mp = mpsearch1(p, 1024)))
80102aaa:	ba 00 04 00 00       	mov    $0x400,%edx
80102aaf:	e8 89 ff ff ff       	call   80102a3d <mpsearch1>
80102ab4:	85 c0                	test   %eax,%eax
80102ab6:	75 0f                	jne    80102ac7 <mpsearch+0x3b>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102ab8:	ba 00 00 01 00       	mov    $0x10000,%edx
80102abd:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102ac2:	e8 76 ff ff ff       	call   80102a3d <mpsearch1>
}
80102ac7:	c9                   	leave  
80102ac8:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102ac9:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102ad0:	c1 e0 08             	shl    $0x8,%eax
80102ad3:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102ada:	09 d0                	or     %edx,%eax
80102adc:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102adf:	2d 00 04 00 00       	sub    $0x400,%eax
80102ae4:	ba 00 04 00 00       	mov    $0x400,%edx
80102ae9:	e8 4f ff ff ff       	call   80102a3d <mpsearch1>
80102aee:	85 c0                	test   %eax,%eax
80102af0:	75 d5                	jne    80102ac7 <mpsearch+0x3b>
80102af2:	eb c4                	jmp    80102ab8 <mpsearch+0x2c>

80102af4 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102af4:	55                   	push   %ebp
80102af5:	89 e5                	mov    %esp,%ebp
80102af7:	57                   	push   %edi
80102af8:	56                   	push   %esi
80102af9:	53                   	push   %ebx
80102afa:	83 ec 1c             	sub    $0x1c,%esp
80102afd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102b00:	e8 87 ff ff ff       	call   80102a8c <mpsearch>
80102b05:	89 c3                	mov    %eax,%ebx
80102b07:	85 c0                	test   %eax,%eax
80102b09:	74 53                	je     80102b5e <mpconfig+0x6a>
80102b0b:	8b 70 04             	mov    0x4(%eax),%esi
80102b0e:	85 f6                	test   %esi,%esi
80102b10:	74 50                	je     80102b62 <mpconfig+0x6e>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102b12:	8d be 00 00 00 80    	lea    -0x80000000(%esi),%edi
  if(memcmp(conf, "PCMP", 4) != 0)
80102b18:	83 ec 04             	sub    $0x4,%esp
80102b1b:	6a 04                	push   $0x4
80102b1d:	68 1d 6c 10 80       	push   $0x80106c1d
80102b22:	57                   	push   %edi
80102b23:	e8 ba 10 00 00       	call   80103be2 <memcmp>
80102b28:	83 c4 10             	add    $0x10,%esp
80102b2b:	85 c0                	test   %eax,%eax
80102b2d:	75 37                	jne    80102b66 <mpconfig+0x72>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102b2f:	8a 86 06 00 00 80    	mov    -0x7ffffffa(%esi),%al
80102b35:	3c 01                	cmp    $0x1,%al
80102b37:	74 04                	je     80102b3d <mpconfig+0x49>
80102b39:	3c 04                	cmp    $0x4,%al
80102b3b:	75 30                	jne    80102b6d <mpconfig+0x79>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102b3d:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
80102b44:	89 f8                	mov    %edi,%eax
80102b46:	e8 d0 fe ff ff       	call   80102a1b <sum>
80102b4b:	84 c0                	test   %al,%al
80102b4d:	75 25                	jne    80102b74 <mpconfig+0x80>
    return 0;
  *pmp = mp;
80102b4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102b52:	89 18                	mov    %ebx,(%eax)
  return conf;
}
80102b54:	89 f8                	mov    %edi,%eax
80102b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102b59:	5b                   	pop    %ebx
80102b5a:	5e                   	pop    %esi
80102b5b:	5f                   	pop    %edi
80102b5c:	5d                   	pop    %ebp
80102b5d:	c3                   	ret    
    return 0;
80102b5e:	89 c7                	mov    %eax,%edi
80102b60:	eb f2                	jmp    80102b54 <mpconfig+0x60>
80102b62:	89 f7                	mov    %esi,%edi
80102b64:	eb ee                	jmp    80102b54 <mpconfig+0x60>
    return 0;
80102b66:	bf 00 00 00 00       	mov    $0x0,%edi
80102b6b:	eb e7                	jmp    80102b54 <mpconfig+0x60>
    return 0;
80102b6d:	bf 00 00 00 00       	mov    $0x0,%edi
80102b72:	eb e0                	jmp    80102b54 <mpconfig+0x60>
    return 0;
80102b74:	bf 00 00 00 00       	mov    $0x0,%edi
80102b79:	eb d9                	jmp    80102b54 <mpconfig+0x60>

80102b7b <mpinit>:

void
mpinit(void)
{
80102b7b:	55                   	push   %ebp
80102b7c:	89 e5                	mov    %esp,%ebp
80102b7e:	57                   	push   %edi
80102b7f:	56                   	push   %esi
80102b80:	53                   	push   %ebx
80102b81:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102b84:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102b87:	e8 68 ff ff ff       	call   80102af4 <mpconfig>
80102b8c:	85 c0                	test   %eax,%eax
80102b8e:	74 19                	je     80102ba9 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102b90:	8b 50 24             	mov    0x24(%eax),%edx
80102b93:	89 15 80 16 11 80    	mov    %edx,0x80111680
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102b99:	8d 50 2c             	lea    0x2c(%eax),%edx
80102b9c:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102ba0:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102ba2:	bf 01 00 00 00       	mov    $0x1,%edi
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102ba7:	eb 20                	jmp    80102bc9 <mpinit+0x4e>
    panic("Expect to run on an SMP");
80102ba9:	83 ec 0c             	sub    $0xc,%esp
80102bac:	68 22 6c 10 80       	push   $0x80106c22
80102bb1:	e8 8b d7 ff ff       	call   80100341 <panic>
    switch(*p){
80102bb6:	bf 00 00 00 00       	mov    $0x0,%edi
80102bbb:	eb 0c                	jmp    80102bc9 <mpinit+0x4e>
80102bbd:	83 e8 03             	sub    $0x3,%eax
80102bc0:	3c 01                	cmp    $0x1,%al
80102bc2:	76 19                	jbe    80102bdd <mpinit+0x62>
80102bc4:	bf 00 00 00 00       	mov    $0x0,%edi
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102bc9:	39 ca                	cmp    %ecx,%edx
80102bcb:	73 4a                	jae    80102c17 <mpinit+0x9c>
    switch(*p){
80102bcd:	8a 02                	mov    (%edx),%al
80102bcf:	3c 02                	cmp    $0x2,%al
80102bd1:	74 37                	je     80102c0a <mpinit+0x8f>
80102bd3:	77 e8                	ja     80102bbd <mpinit+0x42>
80102bd5:	84 c0                	test   %al,%al
80102bd7:	74 09                	je     80102be2 <mpinit+0x67>
80102bd9:	3c 01                	cmp    $0x1,%al
80102bdb:	75 d9                	jne    80102bb6 <mpinit+0x3b>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102bdd:	83 c2 08             	add    $0x8,%edx
      continue;
80102be0:	eb e7                	jmp    80102bc9 <mpinit+0x4e>
      if(ncpu < NCPU) {
80102be2:	a1 84 17 11 80       	mov    0x80111784,%eax
80102be7:	83 f8 07             	cmp    $0x7,%eax
80102bea:	7f 19                	jg     80102c05 <mpinit+0x8a>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102bec:	8d 34 80             	lea    (%eax,%eax,4),%esi
80102bef:	01 f6                	add    %esi,%esi
80102bf1:	01 c6                	add    %eax,%esi
80102bf3:	c1 e6 04             	shl    $0x4,%esi
80102bf6:	8a 5a 01             	mov    0x1(%edx),%bl
80102bf9:	88 9e a0 17 11 80    	mov    %bl,-0x7feee860(%esi)
        ncpu++;
80102bff:	40                   	inc    %eax
80102c00:	a3 84 17 11 80       	mov    %eax,0x80111784
      p += sizeof(struct mpproc);
80102c05:	83 c2 14             	add    $0x14,%edx
      continue;
80102c08:	eb bf                	jmp    80102bc9 <mpinit+0x4e>
      ioapicid = ioapic->apicno;
80102c0a:	8a 42 01             	mov    0x1(%edx),%al
80102c0d:	a2 80 17 11 80       	mov    %al,0x80111780
      p += sizeof(struct mpioapic);
80102c12:	83 c2 08             	add    $0x8,%edx
      continue;
80102c15:	eb b2                	jmp    80102bc9 <mpinit+0x4e>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80102c17:	85 ff                	test   %edi,%edi
80102c19:	74 23                	je     80102c3e <mpinit+0xc3>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102c1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102c1e:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102c22:	74 12                	je     80102c36 <mpinit+0xbb>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c24:	b0 70                	mov    $0x70,%al
80102c26:	ba 22 00 00 00       	mov    $0x22,%edx
80102c2b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c2c:	ba 23 00 00 00       	mov    $0x23,%edx
80102c31:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102c32:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c35:	ee                   	out    %al,(%dx)
  }
}
80102c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c39:	5b                   	pop    %ebx
80102c3a:	5e                   	pop    %esi
80102c3b:	5f                   	pop    %edi
80102c3c:	5d                   	pop    %ebp
80102c3d:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102c3e:	83 ec 0c             	sub    $0xc,%esp
80102c41:	68 3c 6c 10 80       	push   $0x80106c3c
80102c46:	e8 f6 d6 ff ff       	call   80100341 <panic>

80102c4b <picinit>:
80102c4b:	b0 ff                	mov    $0xff,%al
80102c4d:	ba 21 00 00 00       	mov    $0x21,%edx
80102c52:	ee                   	out    %al,(%dx)
80102c53:	ba a1 00 00 00       	mov    $0xa1,%edx
80102c58:	ee                   	out    %al,(%dx)
picinit(void)
{
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102c59:	c3                   	ret    

80102c5a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102c5a:	55                   	push   %ebp
80102c5b:	89 e5                	mov    %esp,%ebp
80102c5d:	57                   	push   %edi
80102c5e:	56                   	push   %esi
80102c5f:	53                   	push   %ebx
80102c60:	83 ec 0c             	sub    $0xc,%esp
80102c63:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102c66:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102c69:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102c6f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102c75:	e8 73 df ff ff       	call   80100bed <filealloc>
80102c7a:	89 03                	mov    %eax,(%ebx)
80102c7c:	85 c0                	test   %eax,%eax
80102c7e:	0f 84 88 00 00 00    	je     80102d0c <pipealloc+0xb2>
80102c84:	e8 64 df ff ff       	call   80100bed <filealloc>
80102c89:	89 06                	mov    %eax,(%esi)
80102c8b:	85 c0                	test   %eax,%eax
80102c8d:	74 7d                	je     80102d0c <pipealloc+0xb2>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102c8f:	e8 9a f3 ff ff       	call   8010202e <kalloc>
80102c94:	89 c7                	mov    %eax,%edi
80102c96:	85 c0                	test   %eax,%eax
80102c98:	74 72                	je     80102d0c <pipealloc+0xb2>
    goto bad;
  p->readopen = 1;
80102c9a:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102ca1:	00 00 00 
  p->writeopen = 1;
80102ca4:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102cab:	00 00 00 
  p->nwrite = 0;
80102cae:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102cb5:	00 00 00 
  p->nread = 0;
80102cb8:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102cbf:	00 00 00 
  initlock(&p->lock, "pipe");
80102cc2:	83 ec 08             	sub    $0x8,%esp
80102cc5:	68 5b 6c 10 80       	push   $0x80106c5b
80102cca:	50                   	push   %eax
80102ccb:	e8 e8 0c 00 00       	call   801039b8 <initlock>
  (*f0)->type = FD_PIPE;
80102cd0:	8b 03                	mov    (%ebx),%eax
80102cd2:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102cd8:	8b 03                	mov    (%ebx),%eax
80102cda:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102cde:	8b 03                	mov    (%ebx),%eax
80102ce0:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102ce4:	8b 03                	mov    (%ebx),%eax
80102ce6:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102ce9:	8b 06                	mov    (%esi),%eax
80102ceb:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102cf1:	8b 06                	mov    (%esi),%eax
80102cf3:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102cf7:	8b 06                	mov    (%esi),%eax
80102cf9:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102cfd:	8b 06                	mov    (%esi),%eax
80102cff:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102d02:	83 c4 10             	add    $0x10,%esp
80102d05:	b8 00 00 00 00       	mov    $0x0,%eax
80102d0a:	eb 29                	jmp    80102d35 <pipealloc+0xdb>

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102d0c:	8b 03                	mov    (%ebx),%eax
80102d0e:	85 c0                	test   %eax,%eax
80102d10:	74 0c                	je     80102d1e <pipealloc+0xc4>
    fileclose(*f0);
80102d12:	83 ec 0c             	sub    $0xc,%esp
80102d15:	50                   	push   %eax
80102d16:	e8 76 df ff ff       	call   80100c91 <fileclose>
80102d1b:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102d1e:	8b 06                	mov    (%esi),%eax
80102d20:	85 c0                	test   %eax,%eax
80102d22:	74 19                	je     80102d3d <pipealloc+0xe3>
    fileclose(*f1);
80102d24:	83 ec 0c             	sub    $0xc,%esp
80102d27:	50                   	push   %eax
80102d28:	e8 64 df ff ff       	call   80100c91 <fileclose>
80102d2d:	83 c4 10             	add    $0x10,%esp
  return -1;
80102d30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102d35:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d38:	5b                   	pop    %ebx
80102d39:	5e                   	pop    %esi
80102d3a:	5f                   	pop    %edi
80102d3b:	5d                   	pop    %ebp
80102d3c:	c3                   	ret    
  return -1;
80102d3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d42:	eb f1                	jmp    80102d35 <pipealloc+0xdb>

80102d44 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102d44:	55                   	push   %ebp
80102d45:	89 e5                	mov    %esp,%ebp
80102d47:	53                   	push   %ebx
80102d48:	83 ec 10             	sub    $0x10,%esp
80102d4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102d4e:	53                   	push   %ebx
80102d4f:	e8 9b 0d 00 00       	call   80103aef <acquire>
  if(writable){
80102d54:	83 c4 10             	add    $0x10,%esp
80102d57:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102d5b:	74 3f                	je     80102d9c <pipeclose+0x58>
    p->writeopen = 0;
80102d5d:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102d64:	00 00 00 
    wakeup(&p->nread);
80102d67:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102d6d:	83 ec 0c             	sub    $0xc,%esp
80102d70:	50                   	push   %eax
80102d71:	e8 e5 09 00 00       	call   8010375b <wakeup>
80102d76:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102d79:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102d80:	75 09                	jne    80102d8b <pipeclose+0x47>
80102d82:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102d89:	74 2f                	je     80102dba <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102d8b:	83 ec 0c             	sub    $0xc,%esp
80102d8e:	53                   	push   %ebx
80102d8f:	e8 c0 0d 00 00       	call   80103b54 <release>
80102d94:	83 c4 10             	add    $0x10,%esp
}
80102d97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102d9a:	c9                   	leave  
80102d9b:	c3                   	ret    
    p->readopen = 0;
80102d9c:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102da3:	00 00 00 
    wakeup(&p->nwrite);
80102da6:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102dac:	83 ec 0c             	sub    $0xc,%esp
80102daf:	50                   	push   %eax
80102db0:	e8 a6 09 00 00       	call   8010375b <wakeup>
80102db5:	83 c4 10             	add    $0x10,%esp
80102db8:	eb bf                	jmp    80102d79 <pipeclose+0x35>
    release(&p->lock);
80102dba:	83 ec 0c             	sub    $0xc,%esp
80102dbd:	53                   	push   %ebx
80102dbe:	e8 91 0d 00 00       	call   80103b54 <release>
    kfree((char*)p);
80102dc3:	89 1c 24             	mov    %ebx,(%esp)
80102dc6:	e8 4c f1 ff ff       	call   80101f17 <kfree>
80102dcb:	83 c4 10             	add    $0x10,%esp
80102dce:	eb c7                	jmp    80102d97 <pipeclose+0x53>

80102dd0 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80102dd0:	55                   	push   %ebp
80102dd1:	89 e5                	mov    %esp,%ebp
80102dd3:	56                   	push   %esi
80102dd4:	53                   	push   %ebx
80102dd5:	83 ec 1c             	sub    $0x1c,%esp
80102dd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102ddb:	53                   	push   %ebx
80102ddc:	e8 0e 0d 00 00       	call   80103aef <acquire>
  for(i = 0; i < n; i++){
80102de1:	83 c4 10             	add    $0x10,%esp
80102de4:	be 00 00 00 00       	mov    $0x0,%esi
80102de9:	3b 75 10             	cmp    0x10(%ebp),%esi
80102dec:	7c 41                	jl     80102e2f <pipewrite+0x5f>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80102dee:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102df4:	83 ec 0c             	sub    $0xc,%esp
80102df7:	50                   	push   %eax
80102df8:	e8 5e 09 00 00       	call   8010375b <wakeup>
  release(&p->lock);
80102dfd:	89 1c 24             	mov    %ebx,(%esp)
80102e00:	e8 4f 0d 00 00       	call   80103b54 <release>
  return n;
80102e05:	83 c4 10             	add    $0x10,%esp
80102e08:	8b 45 10             	mov    0x10(%ebp),%eax
80102e0b:	eb 5c                	jmp    80102e69 <pipewrite+0x99>
      wakeup(&p->nread);
80102e0d:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102e13:	83 ec 0c             	sub    $0xc,%esp
80102e16:	50                   	push   %eax
80102e17:	e8 3f 09 00 00       	call   8010375b <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102e1c:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102e22:	83 c4 08             	add    $0x8,%esp
80102e25:	53                   	push   %ebx
80102e26:	50                   	push   %eax
80102e27:	e8 b8 07 00 00       	call   801035e4 <sleep>
80102e2c:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102e2f:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80102e35:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102e3b:	05 00 02 00 00       	add    $0x200,%eax
80102e40:	39 c2                	cmp    %eax,%edx
80102e42:	75 2c                	jne    80102e70 <pipewrite+0xa0>
      if(p->readopen == 0 || myproc()->killed){
80102e44:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102e4b:	74 0b                	je     80102e58 <pipewrite+0x88>
80102e4d:	e8 d4 02 00 00       	call   80103126 <myproc>
80102e52:	83 78 2c 00          	cmpl   $0x0,0x2c(%eax)
80102e56:	74 b5                	je     80102e0d <pipewrite+0x3d>
        release(&p->lock);
80102e58:	83 ec 0c             	sub    $0xc,%esp
80102e5b:	53                   	push   %ebx
80102e5c:	e8 f3 0c 00 00       	call   80103b54 <release>
        return -1;
80102e61:	83 c4 10             	add    $0x10,%esp
80102e64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102e69:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102e6c:	5b                   	pop    %ebx
80102e6d:	5e                   	pop    %esi
80102e6e:	5d                   	pop    %ebp
80102e6f:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80102e70:	8d 42 01             	lea    0x1(%edx),%eax
80102e73:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80102e79:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e82:	8a 04 30             	mov    (%eax,%esi,1),%al
80102e85:	88 45 f7             	mov    %al,-0x9(%ebp)
80102e88:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80102e8c:	46                   	inc    %esi
80102e8d:	e9 57 ff ff ff       	jmp    80102de9 <pipewrite+0x19>

80102e92 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80102e92:	55                   	push   %ebp
80102e93:	89 e5                	mov    %esp,%ebp
80102e95:	57                   	push   %edi
80102e96:	56                   	push   %esi
80102e97:	53                   	push   %ebx
80102e98:	83 ec 18             	sub    $0x18,%esp
80102e9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102e9e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
80102ea1:	53                   	push   %ebx
80102ea2:	e8 48 0c 00 00       	call   80103aef <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102ea7:	83 c4 10             	add    $0x10,%esp
80102eaa:	eb 13                	jmp    80102ebf <piperead+0x2d>
    if(myproc()->killed){
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80102eac:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102eb2:	83 ec 08             	sub    $0x8,%esp
80102eb5:	53                   	push   %ebx
80102eb6:	50                   	push   %eax
80102eb7:	e8 28 07 00 00       	call   801035e4 <sleep>
80102ebc:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102ebf:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102ec5:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80102ecb:	75 75                	jne    80102f42 <piperead+0xb0>
80102ecd:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80102ed3:	85 f6                	test   %esi,%esi
80102ed5:	74 34                	je     80102f0b <piperead+0x79>
    if(myproc()->killed){
80102ed7:	e8 4a 02 00 00       	call   80103126 <myproc>
80102edc:	83 78 2c 00          	cmpl   $0x0,0x2c(%eax)
80102ee0:	74 ca                	je     80102eac <piperead+0x1a>
      release(&p->lock);
80102ee2:	83 ec 0c             	sub    $0xc,%esp
80102ee5:	53                   	push   %ebx
80102ee6:	e8 69 0c 00 00       	call   80103b54 <release>
      return -1;
80102eeb:	83 c4 10             	add    $0x10,%esp
80102eee:	be ff ff ff ff       	mov    $0xffffffff,%esi
80102ef3:	eb 43                	jmp    80102f38 <piperead+0xa6>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80102ef5:	8d 50 01             	lea    0x1(%eax),%edx
80102ef8:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80102efe:	25 ff 01 00 00       	and    $0x1ff,%eax
80102f03:	8a 44 03 34          	mov    0x34(%ebx,%eax,1),%al
80102f07:	88 04 37             	mov    %al,(%edi,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80102f0a:	46                   	inc    %esi
80102f0b:	3b 75 10             	cmp    0x10(%ebp),%esi
80102f0e:	7d 0e                	jge    80102f1e <piperead+0x8c>
    if(p->nread == p->nwrite)
80102f10:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102f16:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80102f1c:	75 d7                	jne    80102ef5 <piperead+0x63>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80102f1e:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f24:	83 ec 0c             	sub    $0xc,%esp
80102f27:	50                   	push   %eax
80102f28:	e8 2e 08 00 00       	call   8010375b <wakeup>
  release(&p->lock);
80102f2d:	89 1c 24             	mov    %ebx,(%esp)
80102f30:	e8 1f 0c 00 00       	call   80103b54 <release>
  return i;
80102f35:	83 c4 10             	add    $0x10,%esp
}
80102f38:	89 f0                	mov    %esi,%eax
80102f3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f3d:	5b                   	pop    %ebx
80102f3e:	5e                   	pop    %esi
80102f3f:	5f                   	pop    %edi
80102f40:	5d                   	pop    %ebp
80102f41:	c3                   	ret    
80102f42:	be 00 00 00 00       	mov    $0x0,%esi
80102f47:	eb c2                	jmp    80102f0b <piperead+0x79>

80102f49 <wakeup1>:
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80102f49:	ba 54 1d 11 80       	mov    $0x80111d54,%edx
80102f4e:	eb 06                	jmp    80102f56 <wakeup1+0xd>
80102f50:	81 c2 84 00 00 00    	add    $0x84,%edx
80102f56:	81 fa 54 3e 11 80    	cmp    $0x80113e54,%edx
80102f5c:	73 14                	jae    80102f72 <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
80102f5e:	83 7a 14 02          	cmpl   $0x2,0x14(%edx)
80102f62:	75 ec                	jne    80102f50 <wakeup1+0x7>
80102f64:	39 42 28             	cmp    %eax,0x28(%edx)
80102f67:	75 e7                	jne    80102f50 <wakeup1+0x7>
      p->state = RUNNABLE;
80102f69:	c7 42 14 03 00 00 00 	movl   $0x3,0x14(%edx)
80102f70:	eb de                	jmp    80102f50 <wakeup1+0x7>
}
80102f72:	c3                   	ret    

80102f73 <allocproc>:
{
80102f73:	55                   	push   %ebp
80102f74:	89 e5                	mov    %esp,%ebp
80102f76:	53                   	push   %ebx
80102f77:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80102f7a:	68 20 1d 11 80       	push   $0x80111d20
80102f7f:	e8 6b 0b 00 00       	call   80103aef <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80102f84:	83 c4 10             	add    $0x10,%esp
80102f87:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80102f8c:	eb 06                	jmp    80102f94 <allocproc+0x21>
80102f8e:	81 c3 84 00 00 00    	add    $0x84,%ebx
80102f94:	81 fb 54 3e 11 80    	cmp    $0x80113e54,%ebx
80102f9a:	73 76                	jae    80103012 <allocproc+0x9f>
    if(p->state == UNUSED)
80102f9c:	83 7b 14 00          	cmpl   $0x0,0x14(%ebx)
80102fa0:	75 ec                	jne    80102f8e <allocproc+0x1b>
  p->state = EMBRYO;
80102fa2:	c7 43 14 01 00 00 00 	movl   $0x1,0x14(%ebx)
  p->pid = nextpid++;
80102fa9:	a1 04 a0 10 80       	mov    0x8010a004,%eax
80102fae:	8d 50 01             	lea    0x1(%eax),%edx
80102fb1:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
80102fb7:	89 43 18             	mov    %eax,0x18(%ebx)
  release(&ptable.lock);
80102fba:	83 ec 0c             	sub    $0xc,%esp
80102fbd:	68 20 1d 11 80       	push   $0x80111d20
80102fc2:	e8 8d 0b 00 00       	call   80103b54 <release>
  if((p->kstack = kalloc()) == 0){
80102fc7:	e8 62 f0 ff ff       	call   8010202e <kalloc>
80102fcc:	89 43 10             	mov    %eax,0x10(%ebx)
80102fcf:	83 c4 10             	add    $0x10,%esp
80102fd2:	85 c0                	test   %eax,%eax
80102fd4:	74 53                	je     80103029 <allocproc+0xb6>
  sp -= sizeof *p->tf;
80102fd6:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
80102fdc:	89 53 20             	mov    %edx,0x20(%ebx)
  *(uint*)sp = (uint)trapret;
80102fdf:	c7 80 b0 0f 00 00 22 	movl   $0x80104d22,0xfb0(%eax)
80102fe6:	4d 10 80 
  sp -= sizeof *p->context;
80102fe9:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80102fee:	89 43 24             	mov    %eax,0x24(%ebx)
  memset(p->context, 0, sizeof *p->context);
80102ff1:	83 ec 04             	sub    $0x4,%esp
80102ff4:	6a 14                	push   $0x14
80102ff6:	6a 00                	push   $0x0
80102ff8:	50                   	push   %eax
80102ff9:	e8 9d 0b 00 00       	call   80103b9b <memset>
  p->context->eip = (uint)forkret;
80102ffe:	8b 43 24             	mov    0x24(%ebx),%eax
80103001:	c7 40 10 34 30 10 80 	movl   $0x80103034,0x10(%eax)
  return p;
80103008:	83 c4 10             	add    $0x10,%esp
}
8010300b:	89 d8                	mov    %ebx,%eax
8010300d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103010:	c9                   	leave  
80103011:	c3                   	ret    
  release(&ptable.lock);
80103012:	83 ec 0c             	sub    $0xc,%esp
80103015:	68 20 1d 11 80       	push   $0x80111d20
8010301a:	e8 35 0b 00 00       	call   80103b54 <release>
  return 0;
8010301f:	83 c4 10             	add    $0x10,%esp
80103022:	bb 00 00 00 00       	mov    $0x0,%ebx
80103027:	eb e2                	jmp    8010300b <allocproc+0x98>
    p->state = UNUSED;
80103029:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
    return 0;
80103030:	89 c3                	mov    %eax,%ebx
80103032:	eb d7                	jmp    8010300b <allocproc+0x98>

80103034 <forkret>:
{
80103034:	55                   	push   %ebp
80103035:	89 e5                	mov    %esp,%ebp
80103037:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
8010303a:	68 20 1d 11 80       	push   $0x80111d20
8010303f:	e8 10 0b 00 00       	call   80103b54 <release>
  if (first) {
80103044:	83 c4 10             	add    $0x10,%esp
80103047:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
8010304e:	75 02                	jne    80103052 <forkret+0x1e>
}
80103050:	c9                   	leave  
80103051:	c3                   	ret    
    first = 0;
80103052:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
80103059:	00 00 00 
    iinit(ROOTDEV);
8010305c:	83 ec 0c             	sub    $0xc,%esp
8010305f:	6a 01                	push   $0x1
80103061:	e8 1f e2 ff ff       	call   80101285 <iinit>
    initlog(ROOTDEV);
80103066:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010306d:	e8 28 f6 ff ff       	call   8010269a <initlog>
80103072:	83 c4 10             	add    $0x10,%esp
}
80103075:	eb d9                	jmp    80103050 <forkret+0x1c>

80103077 <pinit>:
{
80103077:	55                   	push   %ebp
80103078:	89 e5                	mov    %esp,%ebp
8010307a:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
8010307d:	68 60 6c 10 80       	push   $0x80106c60
80103082:	68 20 1d 11 80       	push   $0x80111d20
80103087:	e8 2c 09 00 00       	call   801039b8 <initlock>
}
8010308c:	83 c4 10             	add    $0x10,%esp
8010308f:	c9                   	leave  
80103090:	c3                   	ret    

80103091 <mycpu>:
{
80103091:	55                   	push   %ebp
80103092:	89 e5                	mov    %esp,%ebp
80103094:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103097:	9c                   	pushf  
80103098:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103099:	f6 c4 02             	test   $0x2,%ah
8010309c:	75 2c                	jne    801030ca <mycpu+0x39>
  apicid = lapicid();
8010309e:	e8 47 f2 ff ff       	call   801022ea <lapicid>
801030a3:	89 c1                	mov    %eax,%ecx
  for (i = 0; i < ncpu; ++i) {
801030a5:	ba 00 00 00 00       	mov    $0x0,%edx
801030aa:	39 15 84 17 11 80    	cmp    %edx,0x80111784
801030b0:	7e 25                	jle    801030d7 <mycpu+0x46>
    if (cpus[i].apicid == apicid)
801030b2:	8d 04 92             	lea    (%edx,%edx,4),%eax
801030b5:	01 c0                	add    %eax,%eax
801030b7:	01 d0                	add    %edx,%eax
801030b9:	c1 e0 04             	shl    $0x4,%eax
801030bc:	0f b6 80 a0 17 11 80 	movzbl -0x7feee860(%eax),%eax
801030c3:	39 c8                	cmp    %ecx,%eax
801030c5:	74 1d                	je     801030e4 <mycpu+0x53>
  for (i = 0; i < ncpu; ++i) {
801030c7:	42                   	inc    %edx
801030c8:	eb e0                	jmp    801030aa <mycpu+0x19>
    panic("mycpu called with interrupts enabled\n");
801030ca:	83 ec 0c             	sub    $0xc,%esp
801030cd:	68 44 6d 10 80       	push   $0x80106d44
801030d2:	e8 6a d2 ff ff       	call   80100341 <panic>
  panic("unknown apicid\n");
801030d7:	83 ec 0c             	sub    $0xc,%esp
801030da:	68 67 6c 10 80       	push   $0x80106c67
801030df:	e8 5d d2 ff ff       	call   80100341 <panic>
      return &cpus[i];
801030e4:	8d 04 92             	lea    (%edx,%edx,4),%eax
801030e7:	01 c0                	add    %eax,%eax
801030e9:	01 d0                	add    %edx,%eax
801030eb:	c1 e0 04             	shl    $0x4,%eax
801030ee:	05 a0 17 11 80       	add    $0x801117a0,%eax
}
801030f3:	c9                   	leave  
801030f4:	c3                   	ret    

801030f5 <cpuid>:
cpuid() {
801030f5:	55                   	push   %ebp
801030f6:	89 e5                	mov    %esp,%ebp
801030f8:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801030fb:	e8 91 ff ff ff       	call   80103091 <mycpu>
80103100:	2d a0 17 11 80       	sub    $0x801117a0,%eax
80103105:	c1 f8 04             	sar    $0x4,%eax
80103108:	8d 0c c0             	lea    (%eax,%eax,8),%ecx
8010310b:	89 ca                	mov    %ecx,%edx
8010310d:	c1 e2 05             	shl    $0x5,%edx
80103110:	29 ca                	sub    %ecx,%edx
80103112:	8d 14 90             	lea    (%eax,%edx,4),%edx
80103115:	8d 0c d0             	lea    (%eax,%edx,8),%ecx
80103118:	89 ca                	mov    %ecx,%edx
8010311a:	c1 e2 0f             	shl    $0xf,%edx
8010311d:	29 ca                	sub    %ecx,%edx
8010311f:	8d 04 90             	lea    (%eax,%edx,4),%eax
80103122:	f7 d8                	neg    %eax
}
80103124:	c9                   	leave  
80103125:	c3                   	ret    

80103126 <myproc>:
myproc(void) {
80103126:	55                   	push   %ebp
80103127:	89 e5                	mov    %esp,%ebp
80103129:	53                   	push   %ebx
8010312a:	83 ec 04             	sub    $0x4,%esp
  pushcli();
8010312d:	e8 e3 08 00 00       	call   80103a15 <pushcli>
  c = mycpu();
80103132:	e8 5a ff ff ff       	call   80103091 <mycpu>
  p = c->proc;
80103137:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010313d:	e8 0e 09 00 00       	call   80103a50 <popcli>
}
80103142:	89 d8                	mov    %ebx,%eax
80103144:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103147:	c9                   	leave  
80103148:	c3                   	ret    

80103149 <userinit>:
{
80103149:	55                   	push   %ebp
8010314a:	89 e5                	mov    %esp,%ebp
8010314c:	53                   	push   %ebx
8010314d:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103150:	e8 1e fe ff ff       	call   80102f73 <allocproc>
80103155:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103157:	a3 54 3e 11 80       	mov    %eax,0x80113e54
  if((p->pgdir = setupkvm()) == 0)
8010315c:	e8 65 33 00 00       	call   801064c6 <setupkvm>
80103161:	89 43 0c             	mov    %eax,0xc(%ebx)
80103164:	85 c0                	test   %eax,%eax
80103166:	0f 84 b7 00 00 00    	je     80103223 <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010316c:	83 ec 04             	sub    $0x4,%esp
8010316f:	68 2c 00 00 00       	push   $0x2c
80103174:	68 60 a4 10 80       	push   $0x8010a460
80103179:	50                   	push   %eax
8010317a:	e8 52 30 00 00       	call   801061d1 <inituvm>
  p->sz = PGSIZE;
8010317f:	c7 43 08 00 10 00 00 	movl   $0x1000,0x8(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103186:	8b 43 20             	mov    0x20(%ebx),%eax
80103189:	83 c4 0c             	add    $0xc,%esp
8010318c:	6a 4c                	push   $0x4c
8010318e:	6a 00                	push   $0x0
80103190:	50                   	push   %eax
80103191:	e8 05 0a 00 00       	call   80103b9b <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103196:	8b 43 20             	mov    0x20(%ebx),%eax
80103199:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010319f:	8b 43 20             	mov    0x20(%ebx),%eax
801031a2:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801031a8:	8b 43 20             	mov    0x20(%ebx),%eax
801031ab:	8b 50 2c             	mov    0x2c(%eax),%edx
801031ae:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801031b2:	8b 43 20             	mov    0x20(%ebx),%eax
801031b5:	8b 50 2c             	mov    0x2c(%eax),%edx
801031b8:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801031bc:	8b 43 20             	mov    0x20(%ebx),%eax
801031bf:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801031c6:	8b 43 20             	mov    0x20(%ebx),%eax
801031c9:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801031d0:	8b 43 20             	mov    0x20(%ebx),%eax
801031d3:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
801031da:	8d 43 74             	lea    0x74(%ebx),%eax
801031dd:	83 c4 0c             	add    $0xc,%esp
801031e0:	6a 10                	push   $0x10
801031e2:	68 90 6c 10 80       	push   $0x80106c90
801031e7:	50                   	push   %eax
801031e8:	e8 06 0b 00 00       	call   80103cf3 <safestrcpy>
  p->cwd = namei("/");
801031ed:	c7 04 24 99 6c 10 80 	movl   $0x80106c99,(%esp)
801031f4:	e8 78 e9 ff ff       	call   80101b71 <namei>
801031f9:	89 43 70             	mov    %eax,0x70(%ebx)
  acquire(&ptable.lock);
801031fc:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103203:	e8 e7 08 00 00       	call   80103aef <acquire>
  p->state = RUNNABLE;
80103208:	c7 43 14 03 00 00 00 	movl   $0x3,0x14(%ebx)
  release(&ptable.lock);
8010320f:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103216:	e8 39 09 00 00       	call   80103b54 <release>
}
8010321b:	83 c4 10             	add    $0x10,%esp
8010321e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103221:	c9                   	leave  
80103222:	c3                   	ret    
    panic("userinit: out of memory?");
80103223:	83 ec 0c             	sub    $0xc,%esp
80103226:	68 77 6c 10 80       	push   $0x80106c77
8010322b:	e8 11 d1 ff ff       	call   80100341 <panic>

80103230 <growproc>:
{
80103230:	55                   	push   %ebp
80103231:	89 e5                	mov    %esp,%ebp
80103233:	56                   	push   %esi
80103234:	53                   	push   %ebx
80103235:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
80103238:	e8 e9 fe ff ff       	call   80103126 <myproc>
8010323d:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;//Tamaño inicial
8010323f:	8b 40 08             	mov    0x8(%eax),%eax
  if(n > 0){
80103242:	85 f6                	test   %esi,%esi
80103244:	7f 1c                	jg     80103262 <growproc+0x32>
  } else if(n < 0){
80103246:	78 37                	js     8010327f <growproc+0x4f>
  curproc->sz = sz;
80103248:	89 43 08             	mov    %eax,0x8(%ebx)
  lcr3(V2P(curproc->pgdir));  // Invalidate TLB. Cambia la tabla de páginas
8010324b:	8b 43 0c             	mov    0xc(%ebx),%eax
8010324e:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80103253:	0f 22 d8             	mov    %eax,%cr3
  return 0;
80103256:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010325b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010325e:	5b                   	pop    %ebx
8010325f:	5e                   	pop    %esi
80103260:	5d                   	pop    %ebp
80103261:	c3                   	ret    
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103262:	83 ec 04             	sub    $0x4,%esp
80103265:	01 c6                	add    %eax,%esi
80103267:	56                   	push   %esi
80103268:	50                   	push   %eax
80103269:	ff 73 0c             	push   0xc(%ebx)
8010326c:	e8 f2 30 00 00       	call   80106363 <allocuvm>
80103271:	83 c4 10             	add    $0x10,%esp
80103274:	85 c0                	test   %eax,%eax
80103276:	75 d0                	jne    80103248 <growproc+0x18>
      return -1;
80103278:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010327d:	eb dc                	jmp    8010325b <growproc+0x2b>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010327f:	83 ec 04             	sub    $0x4,%esp
80103282:	01 c6                	add    %eax,%esi
80103284:	56                   	push   %esi
80103285:	50                   	push   %eax
80103286:	ff 73 0c             	push   0xc(%ebx)
80103289:	e8 45 30 00 00       	call   801062d3 <deallocuvm>
8010328e:	83 c4 10             	add    $0x10,%esp
80103291:	85 c0                	test   %eax,%eax
80103293:	75 b3                	jne    80103248 <growproc+0x18>
      return -1;
80103295:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010329a:	eb bf                	jmp    8010325b <growproc+0x2b>

8010329c <fork>:
{
8010329c:	55                   	push   %ebp
8010329d:	89 e5                	mov    %esp,%ebp
8010329f:	57                   	push   %edi
801032a0:	56                   	push   %esi
801032a1:	53                   	push   %ebx
801032a2:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
801032a5:	e8 7c fe ff ff       	call   80103126 <myproc>
801032aa:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
801032ac:	e8 c2 fc ff ff       	call   80102f73 <allocproc>
801032b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801032b4:	85 c0                	test   %eax,%eax
801032b6:	0f 84 e1 00 00 00    	je     8010339d <fork+0x101>
801032bc:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801032be:	83 ec 08             	sub    $0x8,%esp
801032c1:	ff 73 08             	push   0x8(%ebx)
801032c4:	ff 73 0c             	push   0xc(%ebx)
801032c7:	e8 ad 32 00 00       	call   80106579 <copyuvm>
801032cc:	89 47 0c             	mov    %eax,0xc(%edi)
801032cf:	83 c4 10             	add    $0x10,%esp
801032d2:	85 c0                	test   %eax,%eax
801032d4:	74 2c                	je     80103302 <fork+0x66>
  np->sz = curproc->sz;
801032d6:	8b 43 08             	mov    0x8(%ebx),%eax
801032d9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801032dc:	89 41 08             	mov    %eax,0x8(%ecx)
  np->parent = curproc;
801032df:	89 c8                	mov    %ecx,%eax
801032e1:	89 59 1c             	mov    %ebx,0x1c(%ecx)
  *np->tf = *curproc->tf;
801032e4:	8b 73 20             	mov    0x20(%ebx),%esi
801032e7:	8b 79 20             	mov    0x20(%ecx),%edi
801032ea:	b9 13 00 00 00       	mov    $0x13,%ecx
801032ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
801032f1:	8b 40 20             	mov    0x20(%eax),%eax
801032f4:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
801032fb:	be 00 00 00 00       	mov    $0x0,%esi
80103300:	eb 27                	jmp    80103329 <fork+0x8d>
    kfree(np->kstack);
80103302:	83 ec 0c             	sub    $0xc,%esp
80103305:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103308:	ff 73 10             	push   0x10(%ebx)
8010330b:	e8 07 ec ff ff       	call   80101f17 <kfree>
    np->kstack = 0;
80103310:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
    np->state = UNUSED;
80103317:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
    return -1;
8010331e:	83 c4 10             	add    $0x10,%esp
80103321:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103326:	eb 6b                	jmp    80103393 <fork+0xf7>
  for(i = 0; i < NOFILE; i++)
80103328:	46                   	inc    %esi
80103329:	83 fe 0f             	cmp    $0xf,%esi
8010332c:	7f 1d                	jg     8010334b <fork+0xaf>
    if(curproc->ofile[i])
8010332e:	8b 44 b3 30          	mov    0x30(%ebx,%esi,4),%eax
80103332:	85 c0                	test   %eax,%eax
80103334:	74 f2                	je     80103328 <fork+0x8c>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103336:	83 ec 0c             	sub    $0xc,%esp
80103339:	50                   	push   %eax
8010333a:	e8 0f d9 ff ff       	call   80100c4e <filedup>
8010333f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103342:	89 44 b2 30          	mov    %eax,0x30(%edx,%esi,4)
80103346:	83 c4 10             	add    $0x10,%esp
80103349:	eb dd                	jmp    80103328 <fork+0x8c>
  np->cwd = idup(curproc->cwd);
8010334b:	83 ec 0c             	sub    $0xc,%esp
8010334e:	ff 73 70             	push   0x70(%ebx)
80103351:	e8 89 e1 ff ff       	call   801014df <idup>
80103356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103359:	89 47 70             	mov    %eax,0x70(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010335c:	83 c3 74             	add    $0x74,%ebx
8010335f:	8d 47 74             	lea    0x74(%edi),%eax
80103362:	83 c4 0c             	add    $0xc,%esp
80103365:	6a 10                	push   $0x10
80103367:	53                   	push   %ebx
80103368:	50                   	push   %eax
80103369:	e8 85 09 00 00       	call   80103cf3 <safestrcpy>
  pid = np->pid;
8010336e:	8b 5f 18             	mov    0x18(%edi),%ebx
  acquire(&ptable.lock);
80103371:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103378:	e8 72 07 00 00       	call   80103aef <acquire>
  np->state = RUNNABLE;
8010337d:	c7 47 14 03 00 00 00 	movl   $0x3,0x14(%edi)
  release(&ptable.lock);
80103384:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010338b:	e8 c4 07 00 00       	call   80103b54 <release>
  return pid;
80103390:	83 c4 10             	add    $0x10,%esp
}
80103393:	89 d8                	mov    %ebx,%eax
80103395:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103398:	5b                   	pop    %ebx
80103399:	5e                   	pop    %esi
8010339a:	5f                   	pop    %edi
8010339b:	5d                   	pop    %ebp
8010339c:	c3                   	ret    
    return -1;
8010339d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801033a2:	eb ef                	jmp    80103393 <fork+0xf7>

801033a4 <scheduler>:
{
801033a4:	55                   	push   %ebp
801033a5:	89 e5                	mov    %esp,%ebp
801033a7:	56                   	push   %esi
801033a8:	53                   	push   %ebx
  struct cpu *c = mycpu();
801033a9:	e8 e3 fc ff ff       	call   80103091 <mycpu>
801033ae:	89 c6                	mov    %eax,%esi
  c->proc = 0;
801033b0:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801033b7:	00 00 00 
801033ba:	eb 5d                	jmp    80103419 <scheduler+0x75>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801033bc:	81 c3 84 00 00 00    	add    $0x84,%ebx
801033c2:	81 fb 54 3e 11 80    	cmp    $0x80113e54,%ebx
801033c8:	73 3f                	jae    80103409 <scheduler+0x65>
      if(p->state != RUNNABLE)
801033ca:	83 7b 14 03          	cmpl   $0x3,0x14(%ebx)
801033ce:	75 ec                	jne    801033bc <scheduler+0x18>
      c->proc = p;
801033d0:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
801033d6:	83 ec 0c             	sub    $0xc,%esp
801033d9:	53                   	push   %ebx
801033da:	e8 96 2c 00 00       	call   80106075 <switchuvm>
      p->state = RUNNING;
801033df:	c7 43 14 04 00 00 00 	movl   $0x4,0x14(%ebx)
      swtch(&(c->scheduler), p->context);
801033e6:	83 c4 08             	add    $0x8,%esp
801033e9:	ff 73 24             	push   0x24(%ebx)
801033ec:	8d 46 04             	lea    0x4(%esi),%eax
801033ef:	50                   	push   %eax
801033f0:	e8 4c 09 00 00       	call   80103d41 <swtch>
      switchkvm();
801033f5:	e8 6d 2c 00 00       	call   80106067 <switchkvm>
      c->proc = 0;
801033fa:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103401:	00 00 00 
80103404:	83 c4 10             	add    $0x10,%esp
80103407:	eb b3                	jmp    801033bc <scheduler+0x18>
    release(&ptable.lock);
80103409:	83 ec 0c             	sub    $0xc,%esp
8010340c:	68 20 1d 11 80       	push   $0x80111d20
80103411:	e8 3e 07 00 00       	call   80103b54 <release>
    sti();
80103416:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103419:	fb                   	sti    
    acquire(&ptable.lock);
8010341a:	83 ec 0c             	sub    $0xc,%esp
8010341d:	68 20 1d 11 80       	push   $0x80111d20
80103422:	e8 c8 06 00 00       	call   80103aef <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103427:	83 c4 10             	add    $0x10,%esp
8010342a:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
8010342f:	eb 91                	jmp    801033c2 <scheduler+0x1e>

80103431 <sched>:
{
80103431:	55                   	push   %ebp
80103432:	89 e5                	mov    %esp,%ebp
80103434:	56                   	push   %esi
80103435:	53                   	push   %ebx
  struct proc *p = myproc();
80103436:	e8 eb fc ff ff       	call   80103126 <myproc>
8010343b:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
8010343d:	83 ec 0c             	sub    $0xc,%esp
80103440:	68 20 1d 11 80       	push   $0x80111d20
80103445:	e8 66 06 00 00       	call   80103ab0 <holding>
8010344a:	83 c4 10             	add    $0x10,%esp
8010344d:	85 c0                	test   %eax,%eax
8010344f:	74 4f                	je     801034a0 <sched+0x6f>
  if(mycpu()->ncli != 1)
80103451:	e8 3b fc ff ff       	call   80103091 <mycpu>
80103456:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
8010345d:	75 4e                	jne    801034ad <sched+0x7c>
  if(p->state == RUNNING)
8010345f:	83 7b 14 04          	cmpl   $0x4,0x14(%ebx)
80103463:	74 55                	je     801034ba <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103465:	9c                   	pushf  
80103466:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103467:	f6 c4 02             	test   $0x2,%ah
8010346a:	75 5b                	jne    801034c7 <sched+0x96>
  intena = mycpu()->intena;
8010346c:	e8 20 fc ff ff       	call   80103091 <mycpu>
80103471:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103477:	e8 15 fc ff ff       	call   80103091 <mycpu>
8010347c:	83 ec 08             	sub    $0x8,%esp
8010347f:	ff 70 04             	push   0x4(%eax)
80103482:	83 c3 24             	add    $0x24,%ebx
80103485:	53                   	push   %ebx
80103486:	e8 b6 08 00 00       	call   80103d41 <swtch>
  mycpu()->intena = intena;
8010348b:	e8 01 fc ff ff       	call   80103091 <mycpu>
80103490:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103496:	83 c4 10             	add    $0x10,%esp
80103499:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010349c:	5b                   	pop    %ebx
8010349d:	5e                   	pop    %esi
8010349e:	5d                   	pop    %ebp
8010349f:	c3                   	ret    
    panic("sched ptable.lock");
801034a0:	83 ec 0c             	sub    $0xc,%esp
801034a3:	68 9b 6c 10 80       	push   $0x80106c9b
801034a8:	e8 94 ce ff ff       	call   80100341 <panic>
    panic("sched locks");
801034ad:	83 ec 0c             	sub    $0xc,%esp
801034b0:	68 ad 6c 10 80       	push   $0x80106cad
801034b5:	e8 87 ce ff ff       	call   80100341 <panic>
    panic("sched running");
801034ba:	83 ec 0c             	sub    $0xc,%esp
801034bd:	68 b9 6c 10 80       	push   $0x80106cb9
801034c2:	e8 7a ce ff ff       	call   80100341 <panic>
    panic("sched interruptible");
801034c7:	83 ec 0c             	sub    $0xc,%esp
801034ca:	68 c7 6c 10 80       	push   $0x80106cc7
801034cf:	e8 6d ce ff ff       	call   80100341 <panic>

801034d4 <exit>:
{
801034d4:	55                   	push   %ebp
801034d5:	89 e5                	mov    %esp,%ebp
801034d7:	56                   	push   %esi
801034d8:	53                   	push   %ebx
  struct proc *curproc = myproc(); // curproc = myproc() --> :e proc.h
801034d9:	e8 48 fc ff ff       	call   80103126 <myproc>
  if(curproc == initproc)
801034de:	39 05 54 3e 11 80    	cmp    %eax,0x80113e54
801034e4:	74 09                	je     801034ef <exit+0x1b>
801034e6:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){// Recorre la tabla de descriptores de fichero y los cierra
801034e8:	bb 00 00 00 00       	mov    $0x0,%ebx
801034ed:	eb 22                	jmp    80103511 <exit+0x3d>
    panic("init exiting");
801034ef:	83 ec 0c             	sub    $0xc,%esp
801034f2:	68 db 6c 10 80       	push   $0x80106cdb
801034f7:	e8 45 ce ff ff       	call   80100341 <panic>
      fileclose(curproc->ofile[fd]);
801034fc:	83 ec 0c             	sub    $0xc,%esp
801034ff:	50                   	push   %eax
80103500:	e8 8c d7 ff ff       	call   80100c91 <fileclose>
      curproc->ofile[fd] = 0;
80103505:	c7 44 9e 30 00 00 00 	movl   $0x0,0x30(%esi,%ebx,4)
8010350c:	00 
8010350d:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){// Recorre la tabla de descriptores de fichero y los cierra
80103510:	43                   	inc    %ebx
80103511:	83 fb 0f             	cmp    $0xf,%ebx
80103514:	7f 0a                	jg     80103520 <exit+0x4c>
    if(curproc->ofile[fd]){
80103516:	8b 44 9e 30          	mov    0x30(%esi,%ebx,4),%eax
8010351a:	85 c0                	test   %eax,%eax
8010351c:	75 de                	jne    801034fc <exit+0x28>
8010351e:	eb f0                	jmp    80103510 <exit+0x3c>
  begin_op();
80103520:	e8 be f1 ff ff       	call   801026e3 <begin_op>
  iput(curproc->cwd);
80103525:	83 ec 0c             	sub    $0xc,%esp
80103528:	ff 76 70             	push   0x70(%esi)
8010352b:	e8 e2 e0 ff ff       	call   80101612 <iput>
  end_op();
80103530:	e8 2a f2 ff ff       	call   8010275f <end_op>
  curproc->cwd = 0;//cwd = proceso actual
80103535:	c7 46 70 00 00 00 00 	movl   $0x0,0x70(%esi)
  acquire(&ptable.lock);//bloquea la tabla de procesos global del SO
8010353c:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103543:	e8 a7 05 00 00       	call   80103aef <acquire>
	curproc->exitcode = status;
80103548:	8b 45 08             	mov    0x8(%ebp),%eax
8010354b:	89 46 04             	mov    %eax,0x4(%esi)
	wakeup1(curproc->parent);
8010354e:	8b 46 1c             	mov    0x1c(%esi),%eax
80103551:	e8 f3 f9 ff ff       	call   80102f49 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103556:	83 c4 10             	add    $0x10,%esp
80103559:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
8010355e:	eb 06                	jmp    80103566 <exit+0x92>
80103560:	81 c3 84 00 00 00    	add    $0x84,%ebx
80103566:	81 fb 54 3e 11 80    	cmp    $0x80113e54,%ebx
8010356c:	73 1a                	jae    80103588 <exit+0xb4>
    if(p->parent == curproc){
8010356e:	39 73 1c             	cmp    %esi,0x1c(%ebx)
80103571:	75 ed                	jne    80103560 <exit+0x8c>
      p->parent = initproc;
80103573:	a1 54 3e 11 80       	mov    0x80113e54,%eax
80103578:	89 43 1c             	mov    %eax,0x1c(%ebx)
      if(p->state == ZOMBIE)
8010357b:	83 7b 14 05          	cmpl   $0x5,0x14(%ebx)
8010357f:	75 df                	jne    80103560 <exit+0x8c>
        wakeup1(initproc);
80103581:	e8 c3 f9 ff ff       	call   80102f49 <wakeup1>
80103586:	eb d8                	jmp    80103560 <exit+0x8c>
  deallocuvm(curproc->pgdir, KERNBASE, 0);
80103588:	83 ec 04             	sub    $0x4,%esp
8010358b:	6a 00                	push   $0x0
8010358d:	68 00 00 00 80       	push   $0x80000000
80103592:	ff 76 0c             	push   0xc(%esi)
80103595:	e8 39 2d 00 00       	call   801062d3 <deallocuvm>
  curproc->state = ZOMBIE;
8010359a:	c7 46 14 05 00 00 00 	movl   $0x5,0x14(%esi)
  sched();
801035a1:	e8 8b fe ff ff       	call   80103431 <sched>
  panic("zombie exit");
801035a6:	c7 04 24 e8 6c 10 80 	movl   $0x80106ce8,(%esp)
801035ad:	e8 8f cd ff ff       	call   80100341 <panic>

801035b2 <yield>:
{
801035b2:	55                   	push   %ebp
801035b3:	89 e5                	mov    %esp,%ebp
801035b5:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801035b8:	68 20 1d 11 80       	push   $0x80111d20
801035bd:	e8 2d 05 00 00       	call   80103aef <acquire>
  myproc()->state = RUNNABLE;
801035c2:	e8 5f fb ff ff       	call   80103126 <myproc>
801035c7:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)
  sched();
801035ce:	e8 5e fe ff ff       	call   80103431 <sched>
  release(&ptable.lock);
801035d3:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801035da:	e8 75 05 00 00       	call   80103b54 <release>
}
801035df:	83 c4 10             	add    $0x10,%esp
801035e2:	c9                   	leave  
801035e3:	c3                   	ret    

801035e4 <sleep>:
{
801035e4:	55                   	push   %ebp
801035e5:	89 e5                	mov    %esp,%ebp
801035e7:	56                   	push   %esi
801035e8:	53                   	push   %ebx
801035e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct proc *p = myproc();
801035ec:	e8 35 fb ff ff       	call   80103126 <myproc>
  if(p == 0)
801035f1:	85 c0                	test   %eax,%eax
801035f3:	74 66                	je     8010365b <sleep+0x77>
801035f5:	89 c3                	mov    %eax,%ebx
  if(lk == 0)
801035f7:	85 f6                	test   %esi,%esi
801035f9:	74 6d                	je     80103668 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801035fb:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
80103601:	74 18                	je     8010361b <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103603:	83 ec 0c             	sub    $0xc,%esp
80103606:	68 20 1d 11 80       	push   $0x80111d20
8010360b:	e8 df 04 00 00       	call   80103aef <acquire>
    release(lk);
80103610:	89 34 24             	mov    %esi,(%esp)
80103613:	e8 3c 05 00 00       	call   80103b54 <release>
80103618:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
8010361b:	8b 45 08             	mov    0x8(%ebp),%eax
8010361e:	89 43 28             	mov    %eax,0x28(%ebx)
  p->state = SLEEPING;
80103621:	c7 43 14 02 00 00 00 	movl   $0x2,0x14(%ebx)
  sched();
80103628:	e8 04 fe ff ff       	call   80103431 <sched>
  p->chan = 0;
8010362d:	c7 43 28 00 00 00 00 	movl   $0x0,0x28(%ebx)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103634:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
8010363a:	74 18                	je     80103654 <sleep+0x70>
    release(&ptable.lock);
8010363c:	83 ec 0c             	sub    $0xc,%esp
8010363f:	68 20 1d 11 80       	push   $0x80111d20
80103644:	e8 0b 05 00 00       	call   80103b54 <release>
    acquire(lk);
80103649:	89 34 24             	mov    %esi,(%esp)
8010364c:	e8 9e 04 00 00       	call   80103aef <acquire>
80103651:	83 c4 10             	add    $0x10,%esp
}
80103654:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103657:	5b                   	pop    %ebx
80103658:	5e                   	pop    %esi
80103659:	5d                   	pop    %ebp
8010365a:	c3                   	ret    
    panic("sleep");
8010365b:	83 ec 0c             	sub    $0xc,%esp
8010365e:	68 f4 6c 10 80       	push   $0x80106cf4
80103663:	e8 d9 cc ff ff       	call   80100341 <panic>
    panic("sleep without lk");
80103668:	83 ec 0c             	sub    $0xc,%esp
8010366b:	68 fa 6c 10 80       	push   $0x80106cfa
80103670:	e8 cc cc ff ff       	call   80100341 <panic>

80103675 <wait>:
{
80103675:	55                   	push   %ebp
80103676:	89 e5                	mov    %esp,%ebp
80103678:	57                   	push   %edi
80103679:	56                   	push   %esi
8010367a:	53                   	push   %ebx
8010367b:	83 ec 0c             	sub    $0xc,%esp
8010367e:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct proc *curproc = myproc();
80103681:	e8 a0 fa ff ff       	call   80103126 <myproc>
80103686:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103688:	83 ec 0c             	sub    $0xc,%esp
8010368b:	68 20 1d 11 80       	push   $0x80111d20
80103690:	e8 5a 04 00 00       	call   80103aef <acquire>
80103695:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103698:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010369d:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
801036a2:	eb 61                	jmp    80103705 <wait+0x90>
        pid = p->pid;
801036a4:	8b 73 18             	mov    0x18(%ebx),%esi
        kfree(p->kstack);
801036a7:	83 ec 0c             	sub    $0xc,%esp
801036aa:	ff 73 10             	push   0x10(%ebx)
801036ad:	e8 65 e8 ff ff       	call   80101f17 <kfree>
        p->kstack = 0;
801036b2:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        freevm(p->pgdir, 0); // User zone deleted before
801036b9:	83 c4 08             	add    $0x8,%esp
801036bc:	6a 00                	push   $0x0
801036be:	ff 73 0c             	push   0xc(%ebx)
801036c1:	e8 8a 2d 00 00       	call   80106450 <freevm>
        p->pid = 0;
801036c6:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
        p->parent = 0;
801036cd:	c7 43 1c 00 00 00 00 	movl   $0x0,0x1c(%ebx)
        p->name[0] = 0;
801036d4:	c6 43 74 00          	movb   $0x0,0x74(%ebx)
        p->killed = 0;
801036d8:	c7 43 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
        p->state = UNUSED;
801036df:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        release(&ptable.lock);
801036e6:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801036ed:	e8 62 04 00 00       	call   80103b54 <release>
        return pid;
801036f2:	83 c4 10             	add    $0x10,%esp
}
801036f5:	89 f0                	mov    %esi,%eax
801036f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801036fa:	5b                   	pop    %ebx
801036fb:	5e                   	pop    %esi
801036fc:	5f                   	pop    %edi
801036fd:	5d                   	pop    %ebp
801036fe:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801036ff:	81 c3 84 00 00 00    	add    $0x84,%ebx
80103705:	81 fb 54 3e 11 80    	cmp    $0x80113e54,%ebx
8010370b:	73 17                	jae    80103724 <wait+0xaf>
      if(p->parent != curproc)
8010370d:	39 73 1c             	cmp    %esi,0x1c(%ebx)
80103710:	75 ed                	jne    801036ff <wait+0x8a>
			*status = p->exitcode;
80103712:	8b 43 04             	mov    0x4(%ebx),%eax
80103715:	89 07                	mov    %eax,(%edi)
      if(p->state == ZOMBIE){
80103717:	83 7b 14 05          	cmpl   $0x5,0x14(%ebx)
8010371b:	74 87                	je     801036a4 <wait+0x2f>
      havekids = 1;
8010371d:	b8 01 00 00 00       	mov    $0x1,%eax
80103722:	eb db                	jmp    801036ff <wait+0x8a>
    if(!havekids || curproc->killed){
80103724:	85 c0                	test   %eax,%eax
80103726:	74 06                	je     8010372e <wait+0xb9>
80103728:	83 7e 2c 00          	cmpl   $0x0,0x2c(%esi)
8010372c:	74 17                	je     80103745 <wait+0xd0>
      release(&ptable.lock);
8010372e:	83 ec 0c             	sub    $0xc,%esp
80103731:	68 20 1d 11 80       	push   $0x80111d20
80103736:	e8 19 04 00 00       	call   80103b54 <release>
      return -1;
8010373b:	83 c4 10             	add    $0x10,%esp
8010373e:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103743:	eb b0                	jmp    801036f5 <wait+0x80>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103745:	83 ec 08             	sub    $0x8,%esp
80103748:	68 20 1d 11 80       	push   $0x80111d20
8010374d:	56                   	push   %esi
8010374e:	e8 91 fe ff ff       	call   801035e4 <sleep>
    havekids = 0;
80103753:	83 c4 10             	add    $0x10,%esp
80103756:	e9 3d ff ff ff       	jmp    80103698 <wait+0x23>

8010375b <wakeup>:


// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010375b:	55                   	push   %ebp
8010375c:	89 e5                	mov    %esp,%ebp
8010375e:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103761:	68 20 1d 11 80       	push   $0x80111d20
80103766:	e8 84 03 00 00       	call   80103aef <acquire>
  wakeup1(chan);
8010376b:	8b 45 08             	mov    0x8(%ebp),%eax
8010376e:	e8 d6 f7 ff ff       	call   80102f49 <wakeup1>
  release(&ptable.lock);
80103773:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010377a:	e8 d5 03 00 00       	call   80103b54 <release>
}
8010377f:	83 c4 10             	add    $0x10,%esp
80103782:	c9                   	leave  
80103783:	c3                   	ret    

80103784 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103784:	55                   	push   %ebp
80103785:	89 e5                	mov    %esp,%ebp
80103787:	53                   	push   %ebx
80103788:	83 ec 10             	sub    $0x10,%esp
8010378b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
8010378e:	68 20 1d 11 80       	push   $0x80111d20
80103793:	e8 57 03 00 00       	call   80103aef <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103798:	83 c4 10             	add    $0x10,%esp
8010379b:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
801037a0:	eb 0e                	jmp    801037b0 <kill+0x2c>
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
801037a2:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)
801037a9:	eb 1e                	jmp    801037c9 <kill+0x45>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801037ab:	05 84 00 00 00       	add    $0x84,%eax
801037b0:	3d 54 3e 11 80       	cmp    $0x80113e54,%eax
801037b5:	73 2c                	jae    801037e3 <kill+0x5f>
    if(p->pid == pid){
801037b7:	39 58 18             	cmp    %ebx,0x18(%eax)
801037ba:	75 ef                	jne    801037ab <kill+0x27>
      p->killed = 1;
801037bc:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
      if(p->state == SLEEPING)
801037c3:	83 78 14 02          	cmpl   $0x2,0x14(%eax)
801037c7:	74 d9                	je     801037a2 <kill+0x1e>
      release(&ptable.lock);
801037c9:	83 ec 0c             	sub    $0xc,%esp
801037cc:	68 20 1d 11 80       	push   $0x80111d20
801037d1:	e8 7e 03 00 00       	call   80103b54 <release>
      return 0;
801037d6:	83 c4 10             	add    $0x10,%esp
801037d9:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801037de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801037e1:	c9                   	leave  
801037e2:	c3                   	ret    
  release(&ptable.lock);
801037e3:	83 ec 0c             	sub    $0xc,%esp
801037e6:	68 20 1d 11 80       	push   $0x80111d20
801037eb:	e8 64 03 00 00       	call   80103b54 <release>
  return -1;
801037f0:	83 c4 10             	add    $0x10,%esp
801037f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037f8:	eb e4                	jmp    801037de <kill+0x5a>

801037fa <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801037fa:	55                   	push   %ebp
801037fb:	89 e5                	mov    %esp,%ebp
801037fd:	56                   	push   %esi
801037fe:	53                   	push   %ebx
801037ff:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103802:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80103807:	eb 36                	jmp    8010383f <procdump+0x45>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103809:	b8 0b 6d 10 80       	mov    $0x80106d0b,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
8010380e:	8d 53 74             	lea    0x74(%ebx),%edx
80103811:	52                   	push   %edx
80103812:	50                   	push   %eax
80103813:	ff 73 18             	push   0x18(%ebx)
80103816:	68 0f 6d 10 80       	push   $0x80106d0f
8010381b:	e8 ba cd ff ff       	call   801005da <cprintf>
    if(p->state == SLEEPING){
80103820:	83 c4 10             	add    $0x10,%esp
80103823:	83 7b 14 02          	cmpl   $0x2,0x14(%ebx)
80103827:	74 3c                	je     80103865 <procdump+0x6b>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103829:	83 ec 0c             	sub    $0xc,%esp
8010382c:	68 03 71 10 80       	push   $0x80107103
80103831:	e8 a4 cd ff ff       	call   801005da <cprintf>
80103836:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103839:	81 c3 84 00 00 00    	add    $0x84,%ebx
8010383f:	81 fb 54 3e 11 80    	cmp    $0x80113e54,%ebx
80103845:	73 5f                	jae    801038a6 <procdump+0xac>
    if(p->state == UNUSED)
80103847:	8b 43 14             	mov    0x14(%ebx),%eax
8010384a:	85 c0                	test   %eax,%eax
8010384c:	74 eb                	je     80103839 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010384e:	83 f8 05             	cmp    $0x5,%eax
80103851:	77 b6                	ja     80103809 <procdump+0xf>
80103853:	8b 04 85 6c 6d 10 80 	mov    -0x7fef9294(,%eax,4),%eax
8010385a:	85 c0                	test   %eax,%eax
8010385c:	75 b0                	jne    8010380e <procdump+0x14>
      state = "???";
8010385e:	b8 0b 6d 10 80       	mov    $0x80106d0b,%eax
80103863:	eb a9                	jmp    8010380e <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103865:	8b 43 24             	mov    0x24(%ebx),%eax
80103868:	8b 40 0c             	mov    0xc(%eax),%eax
8010386b:	83 c0 08             	add    $0x8,%eax
8010386e:	83 ec 08             	sub    $0x8,%esp
80103871:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103874:	52                   	push   %edx
80103875:	50                   	push   %eax
80103876:	e8 58 01 00 00       	call   801039d3 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
8010387b:	83 c4 10             	add    $0x10,%esp
8010387e:	be 00 00 00 00       	mov    $0x0,%esi
80103883:	eb 12                	jmp    80103897 <procdump+0x9d>
        cprintf(" %p", pc[i]);
80103885:	83 ec 08             	sub    $0x8,%esp
80103888:	50                   	push   %eax
80103889:	68 61 67 10 80       	push   $0x80106761
8010388e:	e8 47 cd ff ff       	call   801005da <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103893:	46                   	inc    %esi
80103894:	83 c4 10             	add    $0x10,%esp
80103897:	83 fe 09             	cmp    $0x9,%esi
8010389a:	7f 8d                	jg     80103829 <procdump+0x2f>
8010389c:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
801038a0:	85 c0                	test   %eax,%eax
801038a2:	75 e1                	jne    80103885 <procdump+0x8b>
801038a4:	eb 83                	jmp    80103829 <procdump+0x2f>
  }
}
801038a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038a9:	5b                   	pop    %ebx
801038aa:	5e                   	pop    %esi
801038ab:	5d                   	pop    %ebp
801038ac:	c3                   	ret    

801038ad <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801038ad:	55                   	push   %ebp
801038ae:	89 e5                	mov    %esp,%ebp
801038b0:	53                   	push   %ebx
801038b1:	83 ec 0c             	sub    $0xc,%esp
801038b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
801038b7:	68 84 6d 10 80       	push   $0x80106d84
801038bc:	8d 43 04             	lea    0x4(%ebx),%eax
801038bf:	50                   	push   %eax
801038c0:	e8 f3 00 00 00       	call   801039b8 <initlock>
  lk->name = name;
801038c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801038c8:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
801038cb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
801038d1:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
801038d8:	83 c4 10             	add    $0x10,%esp
801038db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038de:	c9                   	leave  
801038df:	c3                   	ret    

801038e0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801038e0:	55                   	push   %ebp
801038e1:	89 e5                	mov    %esp,%ebp
801038e3:	56                   	push   %esi
801038e4:	53                   	push   %ebx
801038e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801038e8:	8d 73 04             	lea    0x4(%ebx),%esi
801038eb:	83 ec 0c             	sub    $0xc,%esp
801038ee:	56                   	push   %esi
801038ef:	e8 fb 01 00 00       	call   80103aef <acquire>
  while (lk->locked) {
801038f4:	83 c4 10             	add    $0x10,%esp
801038f7:	eb 0d                	jmp    80103906 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
801038f9:	83 ec 08             	sub    $0x8,%esp
801038fc:	56                   	push   %esi
801038fd:	53                   	push   %ebx
801038fe:	e8 e1 fc ff ff       	call   801035e4 <sleep>
80103903:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103906:	83 3b 00             	cmpl   $0x0,(%ebx)
80103909:	75 ee                	jne    801038f9 <acquiresleep+0x19>
  }
  lk->locked = 1;
8010390b:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103911:	e8 10 f8 ff ff       	call   80103126 <myproc>
80103916:	8b 40 18             	mov    0x18(%eax),%eax
80103919:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
8010391c:	83 ec 0c             	sub    $0xc,%esp
8010391f:	56                   	push   %esi
80103920:	e8 2f 02 00 00       	call   80103b54 <release>
}
80103925:	83 c4 10             	add    $0x10,%esp
80103928:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010392b:	5b                   	pop    %ebx
8010392c:	5e                   	pop    %esi
8010392d:	5d                   	pop    %ebp
8010392e:	c3                   	ret    

8010392f <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010392f:	55                   	push   %ebp
80103930:	89 e5                	mov    %esp,%ebp
80103932:	56                   	push   %esi
80103933:	53                   	push   %ebx
80103934:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103937:	8d 73 04             	lea    0x4(%ebx),%esi
8010393a:	83 ec 0c             	sub    $0xc,%esp
8010393d:	56                   	push   %esi
8010393e:	e8 ac 01 00 00       	call   80103aef <acquire>
  lk->locked = 0;
80103943:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103949:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103950:	89 1c 24             	mov    %ebx,(%esp)
80103953:	e8 03 fe ff ff       	call   8010375b <wakeup>
  release(&lk->lk);
80103958:	89 34 24             	mov    %esi,(%esp)
8010395b:	e8 f4 01 00 00       	call   80103b54 <release>
}
80103960:	83 c4 10             	add    $0x10,%esp
80103963:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103966:	5b                   	pop    %ebx
80103967:	5e                   	pop    %esi
80103968:	5d                   	pop    %ebp
80103969:	c3                   	ret    

8010396a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010396a:	55                   	push   %ebp
8010396b:	89 e5                	mov    %esp,%ebp
8010396d:	56                   	push   %esi
8010396e:	53                   	push   %ebx
8010396f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103972:	8d 73 04             	lea    0x4(%ebx),%esi
80103975:	83 ec 0c             	sub    $0xc,%esp
80103978:	56                   	push   %esi
80103979:	e8 71 01 00 00       	call   80103aef <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
8010397e:	83 c4 10             	add    $0x10,%esp
80103981:	83 3b 00             	cmpl   $0x0,(%ebx)
80103984:	75 17                	jne    8010399d <holdingsleep+0x33>
80103986:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
8010398b:	83 ec 0c             	sub    $0xc,%esp
8010398e:	56                   	push   %esi
8010398f:	e8 c0 01 00 00       	call   80103b54 <release>
  return r;
}
80103994:	89 d8                	mov    %ebx,%eax
80103996:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103999:	5b                   	pop    %ebx
8010399a:	5e                   	pop    %esi
8010399b:	5d                   	pop    %ebp
8010399c:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
8010399d:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
801039a0:	e8 81 f7 ff ff       	call   80103126 <myproc>
801039a5:	3b 58 18             	cmp    0x18(%eax),%ebx
801039a8:	74 07                	je     801039b1 <holdingsleep+0x47>
801039aa:	bb 00 00 00 00       	mov    $0x0,%ebx
801039af:	eb da                	jmp    8010398b <holdingsleep+0x21>
801039b1:	bb 01 00 00 00       	mov    $0x1,%ebx
801039b6:	eb d3                	jmp    8010398b <holdingsleep+0x21>

801039b8 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801039b8:	55                   	push   %ebp
801039b9:	89 e5                	mov    %esp,%ebp
801039bb:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
801039be:	8b 55 0c             	mov    0xc(%ebp),%edx
801039c1:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801039c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801039ca:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801039d1:	5d                   	pop    %ebp
801039d2:	c3                   	ret    

801039d3 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801039d3:	55                   	push   %ebp
801039d4:	89 e5                	mov    %esp,%ebp
801039d6:	53                   	push   %ebx
801039d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801039da:	8b 45 08             	mov    0x8(%ebp),%eax
801039dd:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
801039e0:	b8 00 00 00 00       	mov    $0x0,%eax
801039e5:	83 f8 09             	cmp    $0x9,%eax
801039e8:	7f 21                	jg     80103a0b <getcallerpcs+0x38>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801039ea:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
801039f0:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
801039f6:	77 13                	ja     80103a0b <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
801039f8:	8b 5a 04             	mov    0x4(%edx),%ebx
801039fb:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
801039fe:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103a00:	40                   	inc    %eax
80103a01:	eb e2                	jmp    801039e5 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103a03:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103a0a:	40                   	inc    %eax
80103a0b:	83 f8 09             	cmp    $0x9,%eax
80103a0e:	7e f3                	jle    80103a03 <getcallerpcs+0x30>
}
80103a10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a13:	c9                   	leave  
80103a14:	c3                   	ret    

80103a15 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103a15:	55                   	push   %ebp
80103a16:	89 e5                	mov    %esp,%ebp
80103a18:	53                   	push   %ebx
80103a19:	83 ec 04             	sub    $0x4,%esp
80103a1c:	9c                   	pushf  
80103a1d:	5b                   	pop    %ebx
  asm volatile("cli");
80103a1e:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103a1f:	e8 6d f6 ff ff       	call   80103091 <mycpu>
80103a24:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103a2b:	74 10                	je     80103a3d <pushcli+0x28>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103a2d:	e8 5f f6 ff ff       	call   80103091 <mycpu>
80103a32:	ff 80 a4 00 00 00    	incl   0xa4(%eax)
}
80103a38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a3b:	c9                   	leave  
80103a3c:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103a3d:	e8 4f f6 ff ff       	call   80103091 <mycpu>
80103a42:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103a48:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103a4e:	eb dd                	jmp    80103a2d <pushcli+0x18>

80103a50 <popcli>:

void
popcli(void)
{
80103a50:	55                   	push   %ebp
80103a51:	89 e5                	mov    %esp,%ebp
80103a53:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103a56:	9c                   	pushf  
80103a57:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103a58:	f6 c4 02             	test   $0x2,%ah
80103a5b:	75 28                	jne    80103a85 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103a5d:	e8 2f f6 ff ff       	call   80103091 <mycpu>
80103a62:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103a68:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103a6b:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103a71:	85 d2                	test   %edx,%edx
80103a73:	78 1d                	js     80103a92 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103a75:	e8 17 f6 ff ff       	call   80103091 <mycpu>
80103a7a:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103a81:	74 1c                	je     80103a9f <popcli+0x4f>
    sti();
}
80103a83:	c9                   	leave  
80103a84:	c3                   	ret    
    panic("popcli - interruptible");
80103a85:	83 ec 0c             	sub    $0xc,%esp
80103a88:	68 8f 6d 10 80       	push   $0x80106d8f
80103a8d:	e8 af c8 ff ff       	call   80100341 <panic>
    panic("popcli");
80103a92:	83 ec 0c             	sub    $0xc,%esp
80103a95:	68 a6 6d 10 80       	push   $0x80106da6
80103a9a:	e8 a2 c8 ff ff       	call   80100341 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103a9f:	e8 ed f5 ff ff       	call   80103091 <mycpu>
80103aa4:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103aab:	74 d6                	je     80103a83 <popcli+0x33>
  asm volatile("sti");
80103aad:	fb                   	sti    
}
80103aae:	eb d3                	jmp    80103a83 <popcli+0x33>

80103ab0 <holding>:
{
80103ab0:	55                   	push   %ebp
80103ab1:	89 e5                	mov    %esp,%ebp
80103ab3:	53                   	push   %ebx
80103ab4:	83 ec 04             	sub    $0x4,%esp
80103ab7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103aba:	e8 56 ff ff ff       	call   80103a15 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103abf:	83 3b 00             	cmpl   $0x0,(%ebx)
80103ac2:	75 11                	jne    80103ad5 <holding+0x25>
80103ac4:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103ac9:	e8 82 ff ff ff       	call   80103a50 <popcli>
}
80103ace:	89 d8                	mov    %ebx,%eax
80103ad0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103ad3:	c9                   	leave  
80103ad4:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103ad5:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103ad8:	e8 b4 f5 ff ff       	call   80103091 <mycpu>
80103add:	39 c3                	cmp    %eax,%ebx
80103adf:	74 07                	je     80103ae8 <holding+0x38>
80103ae1:	bb 00 00 00 00       	mov    $0x0,%ebx
80103ae6:	eb e1                	jmp    80103ac9 <holding+0x19>
80103ae8:	bb 01 00 00 00       	mov    $0x1,%ebx
80103aed:	eb da                	jmp    80103ac9 <holding+0x19>

80103aef <acquire>:
{
80103aef:	55                   	push   %ebp
80103af0:	89 e5                	mov    %esp,%ebp
80103af2:	53                   	push   %ebx
80103af3:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103af6:	e8 1a ff ff ff       	call   80103a15 <pushcli>
  if(holding(lk))
80103afb:	83 ec 0c             	sub    $0xc,%esp
80103afe:	ff 75 08             	push   0x8(%ebp)
80103b01:	e8 aa ff ff ff       	call   80103ab0 <holding>
80103b06:	83 c4 10             	add    $0x10,%esp
80103b09:	85 c0                	test   %eax,%eax
80103b0b:	75 3a                	jne    80103b47 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103b0d:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103b10:	b8 01 00 00 00       	mov    $0x1,%eax
80103b15:	f0 87 02             	lock xchg %eax,(%edx)
80103b18:	85 c0                	test   %eax,%eax
80103b1a:	75 f1                	jne    80103b0d <acquire+0x1e>
  __sync_synchronize();
80103b1c:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103b21:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103b24:	e8 68 f5 ff ff       	call   80103091 <mycpu>
80103b29:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80103b2f:	83 c0 0c             	add    $0xc,%eax
80103b32:	83 ec 08             	sub    $0x8,%esp
80103b35:	50                   	push   %eax
80103b36:	8d 45 08             	lea    0x8(%ebp),%eax
80103b39:	50                   	push   %eax
80103b3a:	e8 94 fe ff ff       	call   801039d3 <getcallerpcs>
}
80103b3f:	83 c4 10             	add    $0x10,%esp
80103b42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b45:	c9                   	leave  
80103b46:	c3                   	ret    
    panic("acquire");
80103b47:	83 ec 0c             	sub    $0xc,%esp
80103b4a:	68 ad 6d 10 80       	push   $0x80106dad
80103b4f:	e8 ed c7 ff ff       	call   80100341 <panic>

80103b54 <release>:
{
80103b54:	55                   	push   %ebp
80103b55:	89 e5                	mov    %esp,%ebp
80103b57:	53                   	push   %ebx
80103b58:	83 ec 10             	sub    $0x10,%esp
80103b5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103b5e:	53                   	push   %ebx
80103b5f:	e8 4c ff ff ff       	call   80103ab0 <holding>
80103b64:	83 c4 10             	add    $0x10,%esp
80103b67:	85 c0                	test   %eax,%eax
80103b69:	74 23                	je     80103b8e <release+0x3a>
  lk->pcs[0] = 0;
80103b6b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103b72:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103b79:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103b7e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103b84:	e8 c7 fe ff ff       	call   80103a50 <popcli>
}
80103b89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b8c:	c9                   	leave  
80103b8d:	c3                   	ret    
    panic("release");
80103b8e:	83 ec 0c             	sub    $0xc,%esp
80103b91:	68 b5 6d 10 80       	push   $0x80106db5
80103b96:	e8 a6 c7 ff ff       	call   80100341 <panic>

80103b9b <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103b9b:	55                   	push   %ebp
80103b9c:	89 e5                	mov    %esp,%ebp
80103b9e:	57                   	push   %edi
80103b9f:	53                   	push   %ebx
80103ba0:	8b 55 08             	mov    0x8(%ebp),%edx
80103ba3:	8b 45 0c             	mov    0xc(%ebp),%eax
  if ((int)dst%4 == 0 && n%4 == 0){
80103ba6:	f6 c2 03             	test   $0x3,%dl
80103ba9:	75 29                	jne    80103bd4 <memset+0x39>
80103bab:	f6 45 10 03          	testb  $0x3,0x10(%ebp)
80103baf:	75 23                	jne    80103bd4 <memset+0x39>
    c &= 0xFF;
80103bb1:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103bb4:	8b 4d 10             	mov    0x10(%ebp),%ecx
80103bb7:	c1 e9 02             	shr    $0x2,%ecx
80103bba:	c1 e0 18             	shl    $0x18,%eax
80103bbd:	89 fb                	mov    %edi,%ebx
80103bbf:	c1 e3 10             	shl    $0x10,%ebx
80103bc2:	09 d8                	or     %ebx,%eax
80103bc4:	89 fb                	mov    %edi,%ebx
80103bc6:	c1 e3 08             	shl    $0x8,%ebx
80103bc9:	09 d8                	or     %ebx,%eax
80103bcb:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103bcd:	89 d7                	mov    %edx,%edi
80103bcf:	fc                   	cld    
80103bd0:	f3 ab                	rep stos %eax,%es:(%edi)
}
80103bd2:	eb 08                	jmp    80103bdc <memset+0x41>
  asm volatile("cld; rep stosb" :
80103bd4:	89 d7                	mov    %edx,%edi
80103bd6:	8b 4d 10             	mov    0x10(%ebp),%ecx
80103bd9:	fc                   	cld    
80103bda:	f3 aa                	rep stos %al,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80103bdc:	89 d0                	mov    %edx,%eax
80103bde:	5b                   	pop    %ebx
80103bdf:	5f                   	pop    %edi
80103be0:	5d                   	pop    %ebp
80103be1:	c3                   	ret    

80103be2 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103be2:	55                   	push   %ebp
80103be3:	89 e5                	mov    %esp,%ebp
80103be5:	56                   	push   %esi
80103be6:	53                   	push   %ebx
80103be7:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103bea:	8b 55 0c             	mov    0xc(%ebp),%edx
80103bed:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103bf0:	eb 04                	jmp    80103bf6 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80103bf2:	41                   	inc    %ecx
80103bf3:	42                   	inc    %edx
  while(n-- > 0){
80103bf4:	89 f0                	mov    %esi,%eax
80103bf6:	8d 70 ff             	lea    -0x1(%eax),%esi
80103bf9:	85 c0                	test   %eax,%eax
80103bfb:	74 10                	je     80103c0d <memcmp+0x2b>
    if(*s1 != *s2)
80103bfd:	8a 01                	mov    (%ecx),%al
80103bff:	8a 1a                	mov    (%edx),%bl
80103c01:	38 d8                	cmp    %bl,%al
80103c03:	74 ed                	je     80103bf2 <memcmp+0x10>
      return *s1 - *s2;
80103c05:	0f b6 c0             	movzbl %al,%eax
80103c08:	0f b6 db             	movzbl %bl,%ebx
80103c0b:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103c0d:	5b                   	pop    %ebx
80103c0e:	5e                   	pop    %esi
80103c0f:	5d                   	pop    %ebp
80103c10:	c3                   	ret    

80103c11 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103c11:	55                   	push   %ebp
80103c12:	89 e5                	mov    %esp,%ebp
80103c14:	56                   	push   %esi
80103c15:	53                   	push   %ebx
80103c16:	8b 75 08             	mov    0x8(%ebp),%esi
80103c19:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c1c:	8b 45 10             	mov    0x10(%ebp),%eax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103c1f:	39 f2                	cmp    %esi,%edx
80103c21:	73 36                	jae    80103c59 <memmove+0x48>
80103c23:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80103c26:	39 f1                	cmp    %esi,%ecx
80103c28:	76 33                	jbe    80103c5d <memmove+0x4c>
    s += n;
    d += n;
80103c2a:	8d 14 06             	lea    (%esi,%eax,1),%edx
    while(n-- > 0)
80103c2d:	eb 08                	jmp    80103c37 <memmove+0x26>
      *--d = *--s;
80103c2f:	49                   	dec    %ecx
80103c30:	4a                   	dec    %edx
80103c31:	8a 01                	mov    (%ecx),%al
80103c33:	88 02                	mov    %al,(%edx)
    while(n-- > 0)
80103c35:	89 d8                	mov    %ebx,%eax
80103c37:	8d 58 ff             	lea    -0x1(%eax),%ebx
80103c3a:	85 c0                	test   %eax,%eax
80103c3c:	75 f1                	jne    80103c2f <memmove+0x1e>
80103c3e:	eb 13                	jmp    80103c53 <memmove+0x42>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103c40:	8a 02                	mov    (%edx),%al
80103c42:	88 01                	mov    %al,(%ecx)
80103c44:	8d 49 01             	lea    0x1(%ecx),%ecx
80103c47:	8d 52 01             	lea    0x1(%edx),%edx
    while(n-- > 0)
80103c4a:	89 d8                	mov    %ebx,%eax
80103c4c:	8d 58 ff             	lea    -0x1(%eax),%ebx
80103c4f:	85 c0                	test   %eax,%eax
80103c51:	75 ed                	jne    80103c40 <memmove+0x2f>

  return dst;
}
80103c53:	89 f0                	mov    %esi,%eax
80103c55:	5b                   	pop    %ebx
80103c56:	5e                   	pop    %esi
80103c57:	5d                   	pop    %ebp
80103c58:	c3                   	ret    
80103c59:	89 f1                	mov    %esi,%ecx
80103c5b:	eb ef                	jmp    80103c4c <memmove+0x3b>
80103c5d:	89 f1                	mov    %esi,%ecx
80103c5f:	eb eb                	jmp    80103c4c <memmove+0x3b>

80103c61 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103c61:	55                   	push   %ebp
80103c62:	89 e5                	mov    %esp,%ebp
80103c64:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80103c67:	ff 75 10             	push   0x10(%ebp)
80103c6a:	ff 75 0c             	push   0xc(%ebp)
80103c6d:	ff 75 08             	push   0x8(%ebp)
80103c70:	e8 9c ff ff ff       	call   80103c11 <memmove>
}
80103c75:	c9                   	leave  
80103c76:	c3                   	ret    

80103c77 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103c77:	55                   	push   %ebp
80103c78:	89 e5                	mov    %esp,%ebp
80103c7a:	53                   	push   %ebx
80103c7b:	8b 55 08             	mov    0x8(%ebp),%edx
80103c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103c81:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103c84:	eb 03                	jmp    80103c89 <strncmp+0x12>
    n--, p++, q++;
80103c86:	48                   	dec    %eax
80103c87:	42                   	inc    %edx
80103c88:	41                   	inc    %ecx
  while(n > 0 && *p && *p == *q)
80103c89:	85 c0                	test   %eax,%eax
80103c8b:	74 0a                	je     80103c97 <strncmp+0x20>
80103c8d:	8a 1a                	mov    (%edx),%bl
80103c8f:	84 db                	test   %bl,%bl
80103c91:	74 04                	je     80103c97 <strncmp+0x20>
80103c93:	3a 19                	cmp    (%ecx),%bl
80103c95:	74 ef                	je     80103c86 <strncmp+0xf>
  if(n == 0)
80103c97:	85 c0                	test   %eax,%eax
80103c99:	74 0d                	je     80103ca8 <strncmp+0x31>
    return 0;
  return (uchar)*p - (uchar)*q;
80103c9b:	0f b6 02             	movzbl (%edx),%eax
80103c9e:	0f b6 11             	movzbl (%ecx),%edx
80103ca1:	29 d0                	sub    %edx,%eax
}
80103ca3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103ca6:	c9                   	leave  
80103ca7:	c3                   	ret    
    return 0;
80103ca8:	b8 00 00 00 00       	mov    $0x0,%eax
80103cad:	eb f4                	jmp    80103ca3 <strncmp+0x2c>

80103caf <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103caf:	55                   	push   %ebp
80103cb0:	89 e5                	mov    %esp,%ebp
80103cb2:	57                   	push   %edi
80103cb3:	56                   	push   %esi
80103cb4:	53                   	push   %ebx
80103cb5:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103cbb:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103cbe:	89 c1                	mov    %eax,%ecx
80103cc0:	eb 04                	jmp    80103cc6 <strncpy+0x17>
80103cc2:	89 fb                	mov    %edi,%ebx
80103cc4:	89 f1                	mov    %esi,%ecx
80103cc6:	89 d6                	mov    %edx,%esi
80103cc8:	4a                   	dec    %edx
80103cc9:	85 f6                	test   %esi,%esi
80103ccb:	7e 10                	jle    80103cdd <strncpy+0x2e>
80103ccd:	8d 7b 01             	lea    0x1(%ebx),%edi
80103cd0:	8d 71 01             	lea    0x1(%ecx),%esi
80103cd3:	8a 1b                	mov    (%ebx),%bl
80103cd5:	88 19                	mov    %bl,(%ecx)
80103cd7:	84 db                	test   %bl,%bl
80103cd9:	75 e7                	jne    80103cc2 <strncpy+0x13>
80103cdb:	89 f1                	mov    %esi,%ecx
    ;
  while(n-- > 0)
80103cdd:	8d 5a ff             	lea    -0x1(%edx),%ebx
80103ce0:	85 d2                	test   %edx,%edx
80103ce2:	7e 0a                	jle    80103cee <strncpy+0x3f>
    *s++ = 0;
80103ce4:	c6 01 00             	movb   $0x0,(%ecx)
  while(n-- > 0)
80103ce7:	89 da                	mov    %ebx,%edx
    *s++ = 0;
80103ce9:	8d 49 01             	lea    0x1(%ecx),%ecx
80103cec:	eb ef                	jmp    80103cdd <strncpy+0x2e>
  return os;
}
80103cee:	5b                   	pop    %ebx
80103cef:	5e                   	pop    %esi
80103cf0:	5f                   	pop    %edi
80103cf1:	5d                   	pop    %ebp
80103cf2:	c3                   	ret    

80103cf3 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103cf3:	55                   	push   %ebp
80103cf4:	89 e5                	mov    %esp,%ebp
80103cf6:	57                   	push   %edi
80103cf7:	56                   	push   %esi
80103cf8:	53                   	push   %ebx
80103cf9:	8b 45 08             	mov    0x8(%ebp),%eax
80103cfc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103cff:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103d02:	85 d2                	test   %edx,%edx
80103d04:	7e 20                	jle    80103d26 <safestrcpy+0x33>
80103d06:	89 c1                	mov    %eax,%ecx
80103d08:	eb 04                	jmp    80103d0e <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103d0a:	89 fb                	mov    %edi,%ebx
80103d0c:	89 f1                	mov    %esi,%ecx
80103d0e:	4a                   	dec    %edx
80103d0f:	85 d2                	test   %edx,%edx
80103d11:	7e 10                	jle    80103d23 <safestrcpy+0x30>
80103d13:	8d 7b 01             	lea    0x1(%ebx),%edi
80103d16:	8d 71 01             	lea    0x1(%ecx),%esi
80103d19:	8a 1b                	mov    (%ebx),%bl
80103d1b:	88 19                	mov    %bl,(%ecx)
80103d1d:	84 db                	test   %bl,%bl
80103d1f:	75 e9                	jne    80103d0a <safestrcpy+0x17>
80103d21:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103d23:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103d26:	5b                   	pop    %ebx
80103d27:	5e                   	pop    %esi
80103d28:	5f                   	pop    %edi
80103d29:	5d                   	pop    %ebp
80103d2a:	c3                   	ret    

80103d2b <strlen>:

int
strlen(const char *s)
{
80103d2b:	55                   	push   %ebp
80103d2c:	89 e5                	mov    %esp,%ebp
80103d2e:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103d31:	b8 00 00 00 00       	mov    $0x0,%eax
80103d36:	eb 01                	jmp    80103d39 <strlen+0xe>
80103d38:	40                   	inc    %eax
80103d39:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103d3d:	75 f9                	jne    80103d38 <strlen+0xd>
    ;
  return n;
}
80103d3f:	5d                   	pop    %ebp
80103d40:	c3                   	ret    

80103d41 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103d41:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103d45:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103d49:	55                   	push   %ebp
  pushl %ebx
80103d4a:	53                   	push   %ebx
  pushl %esi
80103d4b:	56                   	push   %esi
  pushl %edi
80103d4c:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103d4d:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103d4f:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103d51:	5f                   	pop    %edi
  popl %esi
80103d52:	5e                   	pop    %esi
  popl %ebx
80103d53:	5b                   	pop    %ebx
  popl %ebp
80103d54:	5d                   	pop    %ebp
  ret
80103d55:	c3                   	ret    

80103d56 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103d56:	55                   	push   %ebp
80103d57:	89 e5                	mov    %esp,%ebp
80103d59:	53                   	push   %ebx
80103d5a:	83 ec 04             	sub    $0x4,%esp
80103d5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103d60:	e8 c1 f3 ff ff       	call   80103126 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103d65:	8b 40 08             	mov    0x8(%eax),%eax
80103d68:	39 d8                	cmp    %ebx,%eax
80103d6a:	76 18                	jbe    80103d84 <fetchint+0x2e>
80103d6c:	8d 53 04             	lea    0x4(%ebx),%edx
80103d6f:	39 d0                	cmp    %edx,%eax
80103d71:	72 18                	jb     80103d8b <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103d73:	8b 13                	mov    (%ebx),%edx
80103d75:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d78:	89 10                	mov    %edx,(%eax)
  return 0;
80103d7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d82:	c9                   	leave  
80103d83:	c3                   	ret    
    return -1;
80103d84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d89:	eb f4                	jmp    80103d7f <fetchint+0x29>
80103d8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d90:	eb ed                	jmp    80103d7f <fetchint+0x29>

80103d92 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{//va a coger el elemento de la pila  ¡LA PILA ESTÁ EN LA DIRECCIÓN ESP! en el tf
80103d92:	55                   	push   %ebp
80103d93:	89 e5                	mov    %esp,%ebp
80103d95:	53                   	push   %ebx
80103d96:	83 ec 04             	sub    $0x4,%esp
80103d99:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103d9c:	e8 85 f3 ff ff       	call   80103126 <myproc>

  if(addr >= curproc->sz)
80103da1:	39 58 08             	cmp    %ebx,0x8(%eax)
80103da4:	76 24                	jbe    80103dca <fetchstr+0x38>
    return -1;
  *pp = (char*)addr;
80103da6:	8b 55 0c             	mov    0xc(%ebp),%edx
80103da9:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80103dab:	8b 50 08             	mov    0x8(%eax),%edx
  for(s = *pp; s < ep; s++){
80103dae:	89 d8                	mov    %ebx,%eax
80103db0:	eb 01                	jmp    80103db3 <fetchstr+0x21>
80103db2:	40                   	inc    %eax
80103db3:	39 d0                	cmp    %edx,%eax
80103db5:	73 09                	jae    80103dc0 <fetchstr+0x2e>
    if(*s == 0)
80103db7:	80 38 00             	cmpb   $0x0,(%eax)
80103dba:	75 f6                	jne    80103db2 <fetchstr+0x20>
      return s - *pp;
80103dbc:	29 d8                	sub    %ebx,%eax
80103dbe:	eb 05                	jmp    80103dc5 <fetchstr+0x33>
  }
  return -1;
80103dc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103dc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103dc8:	c9                   	leave  
80103dc9:	c3                   	ret    
    return -1;
80103dca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dcf:	eb f4                	jmp    80103dc5 <fetchstr+0x33>

80103dd1 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{//n es el numero de argumento que queremos recuperar. ip es donde lo vamos a guardar
80103dd1:	55                   	push   %ebp
80103dd2:	89 e5                	mov    %esp,%ebp
80103dd4:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80103dd7:	e8 4a f3 ff ff       	call   80103126 <myproc>
80103ddc:	8b 50 20             	mov    0x20(%eax),%edx
80103ddf:	8b 45 08             	mov    0x8(%ebp),%eax
80103de2:	c1 e0 02             	shl    $0x2,%eax
80103de5:	03 42 44             	add    0x44(%edx),%eax
80103de8:	83 ec 08             	sub    $0x8,%esp
80103deb:	ff 75 0c             	push   0xc(%ebp)
80103dee:	83 c0 04             	add    $0x4,%eax
80103df1:	50                   	push   %eax
80103df2:	e8 5f ff ff ff       	call   80103d56 <fetchint>
}
80103df7:	c9                   	leave  
80103df8:	c3                   	ret    

80103df9 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, void **pp, int size)
{
80103df9:	55                   	push   %ebp
80103dfa:	89 e5                	mov    %esp,%ebp
80103dfc:	56                   	push   %esi
80103dfd:	53                   	push   %ebx
80103dfe:	83 ec 10             	sub    $0x10,%esp
80103e01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80103e04:	e8 1d f3 ff ff       	call   80103126 <myproc>
80103e09:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80103e0b:	83 ec 08             	sub    $0x8,%esp
80103e0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103e11:	50                   	push   %eax
80103e12:	ff 75 08             	push   0x8(%ebp)
80103e15:	e8 b7 ff ff ff       	call   80103dd1 <argint>
80103e1a:	83 c4 10             	add    $0x10,%esp
80103e1d:	85 c0                	test   %eax,%eax
80103e1f:	78 25                	js     80103e46 <argptr+0x4d>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80103e21:	85 db                	test   %ebx,%ebx
80103e23:	78 28                	js     80103e4d <argptr+0x54>
80103e25:	8b 56 08             	mov    0x8(%esi),%edx
80103e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e2b:	39 c2                	cmp    %eax,%edx
80103e2d:	76 25                	jbe    80103e54 <argptr+0x5b>
80103e2f:	01 c3                	add    %eax,%ebx
80103e31:	39 da                	cmp    %ebx,%edx
80103e33:	72 26                	jb     80103e5b <argptr+0x62>
    return -1;
  *pp = (void*)i;
80103e35:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e38:	89 02                	mov    %eax,(%edx)
  return 0;
80103e3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103e3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103e42:	5b                   	pop    %ebx
80103e43:	5e                   	pop    %esi
80103e44:	5d                   	pop    %ebp
80103e45:	c3                   	ret    
    return -1;
80103e46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e4b:	eb f2                	jmp    80103e3f <argptr+0x46>
    return -1;
80103e4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e52:	eb eb                	jmp    80103e3f <argptr+0x46>
80103e54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e59:	eb e4                	jmp    80103e3f <argptr+0x46>
80103e5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e60:	eb dd                	jmp    80103e3f <argptr+0x46>

80103e62 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80103e62:	55                   	push   %ebp
80103e63:	89 e5                	mov    %esp,%ebp
80103e65:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80103e68:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103e6b:	50                   	push   %eax
80103e6c:	ff 75 08             	push   0x8(%ebp)
80103e6f:	e8 5d ff ff ff       	call   80103dd1 <argint>
80103e74:	83 c4 10             	add    $0x10,%esp
80103e77:	85 c0                	test   %eax,%eax
80103e79:	78 13                	js     80103e8e <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
80103e7b:	83 ec 08             	sub    $0x8,%esp
80103e7e:	ff 75 0c             	push   0xc(%ebp)
80103e81:	ff 75 f4             	push   -0xc(%ebp)
80103e84:	e8 09 ff ff ff       	call   80103d92 <fetchstr>
80103e89:	83 c4 10             	add    $0x10,%esp
}
80103e8c:	c9                   	leave  
80103e8d:	c3                   	ret    
    return -1;
80103e8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e93:	eb f7                	jmp    80103e8c <argstr+0x2a>

80103e95 <syscall>:
[SYS_dup2]    sys_dup2,
};

void
syscall(void)
{
80103e95:	55                   	push   %ebp
80103e96:	89 e5                	mov    %esp,%ebp
80103e98:	53                   	push   %ebx
80103e99:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80103e9c:	e8 85 f2 ff ff       	call   80103126 <myproc>
80103ea1:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80103ea3:	8b 40 20             	mov    0x20(%eax),%eax
80103ea6:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80103ea9:	8d 50 ff             	lea    -0x1(%eax),%edx
80103eac:	83 fa 16             	cmp    $0x16,%edx
80103eaf:	77 17                	ja     80103ec8 <syscall+0x33>
80103eb1:	8b 14 85 e0 6d 10 80 	mov    -0x7fef9220(,%eax,4),%edx
80103eb8:	85 d2                	test   %edx,%edx
80103eba:	74 0c                	je     80103ec8 <syscall+0x33>
    curproc->tf->eax = syscalls[num]();
80103ebc:	ff d2                	call   *%edx
80103ebe:	89 c2                	mov    %eax,%edx
80103ec0:	8b 43 20             	mov    0x20(%ebx),%eax
80103ec3:	89 50 1c             	mov    %edx,0x1c(%eax)
80103ec6:	eb 1f                	jmp    80103ee7 <syscall+0x52>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80103ec8:	8d 53 74             	lea    0x74(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80103ecb:	50                   	push   %eax
80103ecc:	52                   	push   %edx
80103ecd:	ff 73 18             	push   0x18(%ebx)
80103ed0:	68 bd 6d 10 80       	push   $0x80106dbd
80103ed5:	e8 00 c7 ff ff       	call   801005da <cprintf>
    curproc->tf->eax = -1;
80103eda:	8b 43 20             	mov    0x20(%ebx),%eax
80103edd:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80103ee4:	83 c4 10             	add    $0x10,%esp
  }
}
80103ee7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103eea:	c9                   	leave  
80103eeb:	c3                   	ret    

80103eec <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80103eec:	55                   	push   %ebp
80103eed:	89 e5                	mov    %esp,%ebp
80103eef:	56                   	push   %esi
80103ef0:	53                   	push   %ebx
80103ef1:	83 ec 18             	sub    $0x18,%esp
80103ef4:	89 d6                	mov    %edx,%esi
80103ef6:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80103ef8:	8d 55 f4             	lea    -0xc(%ebp),%edx
80103efb:	52                   	push   %edx
80103efc:	50                   	push   %eax
80103efd:	e8 cf fe ff ff       	call   80103dd1 <argint>
80103f02:	83 c4 10             	add    $0x10,%esp
80103f05:	85 c0                	test   %eax,%eax
80103f07:	78 35                	js     80103f3e <argfd+0x52>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80103f09:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80103f0d:	77 28                	ja     80103f37 <argfd+0x4b>
80103f0f:	e8 12 f2 ff ff       	call   80103126 <myproc>
80103f14:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f17:	8b 44 90 30          	mov    0x30(%eax,%edx,4),%eax
80103f1b:	85 c0                	test   %eax,%eax
80103f1d:	74 18                	je     80103f37 <argfd+0x4b>
    return -1;
  if(pfd)
80103f1f:	85 f6                	test   %esi,%esi
80103f21:	74 02                	je     80103f25 <argfd+0x39>
    *pfd = fd;
80103f23:	89 16                	mov    %edx,(%esi)
  if(pf)
80103f25:	85 db                	test   %ebx,%ebx
80103f27:	74 1c                	je     80103f45 <argfd+0x59>
    *pf = f;
80103f29:	89 03                	mov    %eax,(%ebx)
  return 0;
80103f2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f30:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103f33:	5b                   	pop    %ebx
80103f34:	5e                   	pop    %esi
80103f35:	5d                   	pop    %ebp
80103f36:	c3                   	ret    
    return -1;
80103f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f3c:	eb f2                	jmp    80103f30 <argfd+0x44>
    return -1;
80103f3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f43:	eb eb                	jmp    80103f30 <argfd+0x44>
  return 0;
80103f45:	b8 00 00 00 00       	mov    $0x0,%eax
80103f4a:	eb e4                	jmp    80103f30 <argfd+0x44>

80103f4c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80103f4c:	55                   	push   %ebp
80103f4d:	89 e5                	mov    %esp,%ebp
80103f4f:	53                   	push   %ebx
80103f50:	83 ec 04             	sub    $0x4,%esp
80103f53:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
80103f55:	e8 cc f1 ff ff       	call   80103126 <myproc>
80103f5a:	89 c2                	mov    %eax,%edx

  for(fd = 0; fd < NOFILE; fd++){
80103f5c:	b8 00 00 00 00       	mov    $0x0,%eax
80103f61:	83 f8 0f             	cmp    $0xf,%eax
80103f64:	7f 10                	jg     80103f76 <fdalloc+0x2a>
    if(curproc->ofile[fd] == 0){
80103f66:	83 7c 82 30 00       	cmpl   $0x0,0x30(%edx,%eax,4)
80103f6b:	74 03                	je     80103f70 <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
80103f6d:	40                   	inc    %eax
80103f6e:	eb f1                	jmp    80103f61 <fdalloc+0x15>
      curproc->ofile[fd] = f;
80103f70:	89 5c 82 30          	mov    %ebx,0x30(%edx,%eax,4)
      return fd;
80103f74:	eb 05                	jmp    80103f7b <fdalloc+0x2f>
    }
  }
  return -1;
80103f76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103f7e:	c9                   	leave  
80103f7f:	c3                   	ret    

80103f80 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80103f80:	55                   	push   %ebp
80103f81:	89 e5                	mov    %esp,%ebp
80103f83:	56                   	push   %esi
80103f84:	53                   	push   %ebx
80103f85:	83 ec 10             	sub    $0x10,%esp
80103f88:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80103f8a:	b8 20 00 00 00       	mov    $0x20,%eax
80103f8f:	89 c6                	mov    %eax,%esi
80103f91:	39 43 58             	cmp    %eax,0x58(%ebx)
80103f94:	76 2e                	jbe    80103fc4 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80103f96:	6a 10                	push   $0x10
80103f98:	50                   	push   %eax
80103f99:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103f9c:	50                   	push   %eax
80103f9d:	53                   	push   %ebx
80103f9e:	e8 57 d7 ff ff       	call   801016fa <readi>
80103fa3:	83 c4 10             	add    $0x10,%esp
80103fa6:	83 f8 10             	cmp    $0x10,%eax
80103fa9:	75 0c                	jne    80103fb7 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
80103fab:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
80103fb0:	75 1e                	jne    80103fd0 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80103fb2:	8d 46 10             	lea    0x10(%esi),%eax
80103fb5:	eb d8                	jmp    80103f8f <isdirempty+0xf>
      panic("isdirempty: readi");
80103fb7:	83 ec 0c             	sub    $0xc,%esp
80103fba:	68 40 6e 10 80       	push   $0x80106e40
80103fbf:	e8 7d c3 ff ff       	call   80100341 <panic>
      return 0;
  }
  return 1;
80103fc4:	b8 01 00 00 00       	mov    $0x1,%eax
}
80103fc9:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103fcc:	5b                   	pop    %ebx
80103fcd:	5e                   	pop    %esi
80103fce:	5d                   	pop    %ebp
80103fcf:	c3                   	ret    
      return 0;
80103fd0:	b8 00 00 00 00       	mov    $0x0,%eax
80103fd5:	eb f2                	jmp    80103fc9 <isdirempty+0x49>

80103fd7 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80103fd7:	55                   	push   %ebp
80103fd8:	89 e5                	mov    %esp,%ebp
80103fda:	57                   	push   %edi
80103fdb:	56                   	push   %esi
80103fdc:	53                   	push   %ebx
80103fdd:	83 ec 44             	sub    $0x44,%esp
80103fe0:	89 d7                	mov    %edx,%edi
80103fe2:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
80103fe5:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103fe8:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80103feb:	8d 55 d6             	lea    -0x2a(%ebp),%edx
80103fee:	52                   	push   %edx
80103fef:	50                   	push   %eax
80103ff0:	e8 94 db ff ff       	call   80101b89 <nameiparent>
80103ff5:	89 c6                	mov    %eax,%esi
80103ff7:	83 c4 10             	add    $0x10,%esp
80103ffa:	85 c0                	test   %eax,%eax
80103ffc:	0f 84 32 01 00 00    	je     80104134 <create+0x15d>
    return 0;
  ilock(dp);
80104002:	83 ec 0c             	sub    $0xc,%esp
80104005:	50                   	push   %eax
80104006:	e8 02 d5 ff ff       	call   8010150d <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010400b:	83 c4 0c             	add    $0xc,%esp
8010400e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104011:	50                   	push   %eax
80104012:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104015:	50                   	push   %eax
80104016:	56                   	push   %esi
80104017:	e8 27 d9 ff ff       	call   80101943 <dirlookup>
8010401c:	89 c3                	mov    %eax,%ebx
8010401e:	83 c4 10             	add    $0x10,%esp
80104021:	85 c0                	test   %eax,%eax
80104023:	74 3c                	je     80104061 <create+0x8a>
    iunlockput(dp);
80104025:	83 ec 0c             	sub    $0xc,%esp
80104028:	56                   	push   %esi
80104029:	e8 82 d6 ff ff       	call   801016b0 <iunlockput>
    ilock(ip);
8010402e:	89 1c 24             	mov    %ebx,(%esp)
80104031:	e8 d7 d4 ff ff       	call   8010150d <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104036:	83 c4 10             	add    $0x10,%esp
80104039:	66 83 ff 02          	cmp    $0x2,%di
8010403d:	75 07                	jne    80104046 <create+0x6f>
8010403f:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
80104044:	74 11                	je     80104057 <create+0x80>
      return ip;
    iunlockput(ip);
80104046:	83 ec 0c             	sub    $0xc,%esp
80104049:	53                   	push   %ebx
8010404a:	e8 61 d6 ff ff       	call   801016b0 <iunlockput>
    return 0;
8010404f:	83 c4 10             	add    $0x10,%esp
80104052:	bb 00 00 00 00       	mov    $0x0,%ebx
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104057:	89 d8                	mov    %ebx,%eax
80104059:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010405c:	5b                   	pop    %ebx
8010405d:	5e                   	pop    %esi
8010405e:	5f                   	pop    %edi
8010405f:	5d                   	pop    %ebp
80104060:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
80104061:	83 ec 08             	sub    $0x8,%esp
80104064:	0f bf c7             	movswl %di,%eax
80104067:	50                   	push   %eax
80104068:	ff 36                	push   (%esi)
8010406a:	e8 a6 d2 ff ff       	call   80101315 <ialloc>
8010406f:	89 c3                	mov    %eax,%ebx
80104071:	83 c4 10             	add    $0x10,%esp
80104074:	85 c0                	test   %eax,%eax
80104076:	74 53                	je     801040cb <create+0xf4>
  ilock(ip);
80104078:	83 ec 0c             	sub    $0xc,%esp
8010407b:	50                   	push   %eax
8010407c:	e8 8c d4 ff ff       	call   8010150d <ilock>
  ip->major = major;
80104081:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80104084:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
80104088:	8b 45 c0             	mov    -0x40(%ebp),%eax
8010408b:	66 89 43 54          	mov    %ax,0x54(%ebx)
  ip->nlink = 1;
8010408f:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104095:	89 1c 24             	mov    %ebx,(%esp)
80104098:	e8 17 d3 ff ff       	call   801013b4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
8010409d:	83 c4 10             	add    $0x10,%esp
801040a0:	66 83 ff 01          	cmp    $0x1,%di
801040a4:	74 32                	je     801040d8 <create+0x101>
  if(dirlink(dp, name, ip->inum) < 0)
801040a6:	83 ec 04             	sub    $0x4,%esp
801040a9:	ff 73 04             	push   0x4(%ebx)
801040ac:	8d 45 d6             	lea    -0x2a(%ebp),%eax
801040af:	50                   	push   %eax
801040b0:	56                   	push   %esi
801040b1:	e8 0a da ff ff       	call   80101ac0 <dirlink>
801040b6:	83 c4 10             	add    $0x10,%esp
801040b9:	85 c0                	test   %eax,%eax
801040bb:	78 6a                	js     80104127 <create+0x150>
  iunlockput(dp);
801040bd:	83 ec 0c             	sub    $0xc,%esp
801040c0:	56                   	push   %esi
801040c1:	e8 ea d5 ff ff       	call   801016b0 <iunlockput>
  return ip;
801040c6:	83 c4 10             	add    $0x10,%esp
801040c9:	eb 8c                	jmp    80104057 <create+0x80>
    panic("create: ialloc");
801040cb:	83 ec 0c             	sub    $0xc,%esp
801040ce:	68 52 6e 10 80       	push   $0x80106e52
801040d3:	e8 69 c2 ff ff       	call   80100341 <panic>
    dp->nlink++;  // for ".."
801040d8:	66 8b 46 56          	mov    0x56(%esi),%ax
801040dc:	40                   	inc    %eax
801040dd:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
801040e1:	83 ec 0c             	sub    $0xc,%esp
801040e4:	56                   	push   %esi
801040e5:	e8 ca d2 ff ff       	call   801013b4 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801040ea:	83 c4 0c             	add    $0xc,%esp
801040ed:	ff 73 04             	push   0x4(%ebx)
801040f0:	68 62 6e 10 80       	push   $0x80106e62
801040f5:	53                   	push   %ebx
801040f6:	e8 c5 d9 ff ff       	call   80101ac0 <dirlink>
801040fb:	83 c4 10             	add    $0x10,%esp
801040fe:	85 c0                	test   %eax,%eax
80104100:	78 18                	js     8010411a <create+0x143>
80104102:	83 ec 04             	sub    $0x4,%esp
80104105:	ff 76 04             	push   0x4(%esi)
80104108:	68 61 6e 10 80       	push   $0x80106e61
8010410d:	53                   	push   %ebx
8010410e:	e8 ad d9 ff ff       	call   80101ac0 <dirlink>
80104113:	83 c4 10             	add    $0x10,%esp
80104116:	85 c0                	test   %eax,%eax
80104118:	79 8c                	jns    801040a6 <create+0xcf>
      panic("create dots");
8010411a:	83 ec 0c             	sub    $0xc,%esp
8010411d:	68 64 6e 10 80       	push   $0x80106e64
80104122:	e8 1a c2 ff ff       	call   80100341 <panic>
    panic("create: dirlink");
80104127:	83 ec 0c             	sub    $0xc,%esp
8010412a:	68 70 6e 10 80       	push   $0x80106e70
8010412f:	e8 0d c2 ff ff       	call   80100341 <panic>
    return 0;
80104134:	89 c3                	mov    %eax,%ebx
80104136:	e9 1c ff ff ff       	jmp    80104057 <create+0x80>

8010413b <sys_dup>:
{
8010413b:	55                   	push   %ebp
8010413c:	89 e5                	mov    %esp,%ebp
8010413e:	53                   	push   %ebx
8010413f:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)//Coge el fd (arg 0) del usuario con argint y lo pasa a f con argfd
80104142:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104145:	ba 00 00 00 00       	mov    $0x0,%edx
8010414a:	b8 00 00 00 00       	mov    $0x0,%eax
8010414f:	e8 98 fd ff ff       	call   80103eec <argfd>
80104154:	85 c0                	test   %eax,%eax
80104156:	78 23                	js     8010417b <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0) //fdalloc busca el hueco dentro de la table de df.s y mete el fichero
80104158:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415b:	e8 ec fd ff ff       	call   80103f4c <fdalloc>
80104160:	89 c3                	mov    %eax,%ebx
80104162:	85 c0                	test   %eax,%eax
80104164:	78 1c                	js     80104182 <sys_dup+0x47>
  filedup(f); //lo unico que hace filedup es aumentar el ref de la ftable
80104166:	83 ec 0c             	sub    $0xc,%esp
80104169:	ff 75 f4             	push   -0xc(%ebp)
8010416c:	e8 dd ca ff ff       	call   80100c4e <filedup>
  return fd;
80104171:	83 c4 10             	add    $0x10,%esp
}
80104174:	89 d8                	mov    %ebx,%eax
80104176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104179:	c9                   	leave  
8010417a:	c3                   	ret    
    return -1;
8010417b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104180:	eb f2                	jmp    80104174 <sys_dup+0x39>
    return -1;
80104182:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104187:	eb eb                	jmp    80104174 <sys_dup+0x39>

80104189 <sys_dup2>:
{//Objetivo: duplicar oldfd para meterlo en el lugar de newfd (esté abierto o cerrado)
80104189:	55                   	push   %ebp
8010418a:	89 e5                	mov    %esp,%ebp
8010418c:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0,&oldfd,&old_f) < 0){
8010418f:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104192:	8d 55 f0             	lea    -0x10(%ebp),%edx
80104195:	b8 00 00 00 00       	mov    $0x0,%eax
8010419a:	e8 4d fd ff ff       	call   80103eec <argfd>
8010419f:	85 c0                	test   %eax,%eax
801041a1:	78 5e                	js     80104201 <sys_dup2+0x78>
  if(argint(1, &newfd) < 0){
801041a3:	83 ec 08             	sub    $0x8,%esp
801041a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801041a9:	50                   	push   %eax
801041aa:	6a 01                	push   $0x1
801041ac:	e8 20 fc ff ff       	call   80103dd1 <argint>
801041b1:	83 c4 10             	add    $0x10,%esp
801041b4:	85 c0                	test   %eax,%eax
801041b6:	78 50                	js     80104208 <sys_dup2+0x7f>
  if( newfd<0 || newfd >NOFILE)
801041b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041bb:	83 f8 10             	cmp    $0x10,%eax
801041be:	77 4f                	ja     8010420f <sys_dup2+0x86>
  if(newfd==oldfd)
801041c0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801041c3:	74 3a                	je     801041ff <sys_dup2+0x76>
  if((new_f=myproc()->ofile[newfd]) != 0)//myproc->ofile es el la tabla de df.s abiertos  
801041c5:	e8 5c ef ff ff       	call   80103126 <myproc>
801041ca:	8b 55 ec             	mov    -0x14(%ebp),%edx
801041cd:	8b 44 90 30          	mov    0x30(%eax,%edx,4),%eax
801041d1:	85 c0                	test   %eax,%eax
801041d3:	74 0c                	je     801041e1 <sys_dup2+0x58>
    fileclose(new_f);
801041d5:	83 ec 0c             	sub    $0xc,%esp
801041d8:	50                   	push   %eax
801041d9:	e8 b3 ca ff ff       	call   80100c91 <fileclose>
801041de:	83 c4 10             	add    $0x10,%esp
  myproc()->ofile[newfd] = old_f;
801041e1:	e8 40 ef ff ff       	call   80103126 <myproc>
801041e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041e9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801041ec:	89 54 88 30          	mov    %edx,0x30(%eax,%ecx,4)
  filedup(old_f); 
801041f0:	83 ec 0c             	sub    $0xc,%esp
801041f3:	52                   	push   %edx
801041f4:	e8 55 ca ff ff       	call   80100c4e <filedup>
  return newfd;
801041f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041fc:	83 c4 10             	add    $0x10,%esp
}
801041ff:	c9                   	leave  
80104200:	c3                   	ret    
    return -1;
80104201:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104206:	eb f7                	jmp    801041ff <sys_dup2+0x76>
    return -1;
80104208:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010420d:	eb f0                	jmp    801041ff <sys_dup2+0x76>
    return -1;
8010420f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104214:	eb e9                	jmp    801041ff <sys_dup2+0x76>

80104216 <sys_read>:
{
80104216:	55                   	push   %ebp
80104217:	89 e5                	mov    %esp,%ebp
80104219:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, (void**)&p, n) < 0)
8010421c:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010421f:	ba 00 00 00 00       	mov    $0x0,%edx
80104224:	b8 00 00 00 00       	mov    $0x0,%eax
80104229:	e8 be fc ff ff       	call   80103eec <argfd>
8010422e:	85 c0                	test   %eax,%eax
80104230:	78 43                	js     80104275 <sys_read+0x5f>
80104232:	83 ec 08             	sub    $0x8,%esp
80104235:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104238:	50                   	push   %eax
80104239:	6a 02                	push   $0x2
8010423b:	e8 91 fb ff ff       	call   80103dd1 <argint>
80104240:	83 c4 10             	add    $0x10,%esp
80104243:	85 c0                	test   %eax,%eax
80104245:	78 2e                	js     80104275 <sys_read+0x5f>
80104247:	83 ec 04             	sub    $0x4,%esp
8010424a:	ff 75 f0             	push   -0x10(%ebp)
8010424d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104250:	50                   	push   %eax
80104251:	6a 01                	push   $0x1
80104253:	e8 a1 fb ff ff       	call   80103df9 <argptr>
80104258:	83 c4 10             	add    $0x10,%esp
8010425b:	85 c0                	test   %eax,%eax
8010425d:	78 16                	js     80104275 <sys_read+0x5f>
  return fileread(f, p, n);
8010425f:	83 ec 04             	sub    $0x4,%esp
80104262:	ff 75 f0             	push   -0x10(%ebp)
80104265:	ff 75 ec             	push   -0x14(%ebp)
80104268:	ff 75 f4             	push   -0xc(%ebp)
8010426b:	e8 1a cb ff ff       	call   80100d8a <fileread>
80104270:	83 c4 10             	add    $0x10,%esp
}
80104273:	c9                   	leave  
80104274:	c3                   	ret    
    return -1;
80104275:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010427a:	eb f7                	jmp    80104273 <sys_read+0x5d>

8010427c <sys_write>:
{
8010427c:	55                   	push   %ebp
8010427d:	89 e5                	mov    %esp,%ebp
8010427f:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, (void**)&p, n) < 0)
80104282:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104285:	ba 00 00 00 00       	mov    $0x0,%edx
8010428a:	b8 00 00 00 00       	mov    $0x0,%eax
8010428f:	e8 58 fc ff ff       	call   80103eec <argfd>
80104294:	85 c0                	test   %eax,%eax
80104296:	78 43                	js     801042db <sys_write+0x5f>
80104298:	83 ec 08             	sub    $0x8,%esp
8010429b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010429e:	50                   	push   %eax
8010429f:	6a 02                	push   $0x2
801042a1:	e8 2b fb ff ff       	call   80103dd1 <argint>
801042a6:	83 c4 10             	add    $0x10,%esp
801042a9:	85 c0                	test   %eax,%eax
801042ab:	78 2e                	js     801042db <sys_write+0x5f>
801042ad:	83 ec 04             	sub    $0x4,%esp
801042b0:	ff 75 f0             	push   -0x10(%ebp)
801042b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801042b6:	50                   	push   %eax
801042b7:	6a 01                	push   $0x1
801042b9:	e8 3b fb ff ff       	call   80103df9 <argptr>
801042be:	83 c4 10             	add    $0x10,%esp
801042c1:	85 c0                	test   %eax,%eax
801042c3:	78 16                	js     801042db <sys_write+0x5f>
  return filewrite(f, p, n);
801042c5:	83 ec 04             	sub    $0x4,%esp
801042c8:	ff 75 f0             	push   -0x10(%ebp)
801042cb:	ff 75 ec             	push   -0x14(%ebp)
801042ce:	ff 75 f4             	push   -0xc(%ebp)
801042d1:	e8 39 cb ff ff       	call   80100e0f <filewrite>
801042d6:	83 c4 10             	add    $0x10,%esp
}
801042d9:	c9                   	leave  
801042da:	c3                   	ret    
    return -1;
801042db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042e0:	eb f7                	jmp    801042d9 <sys_write+0x5d>

801042e2 <sys_close>:
{
801042e2:	55                   	push   %ebp
801042e3:	89 e5                	mov    %esp,%ebp
801042e5:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801042e8:	8d 4d f0             	lea    -0x10(%ebp),%ecx
801042eb:	8d 55 f4             	lea    -0xc(%ebp),%edx
801042ee:	b8 00 00 00 00       	mov    $0x0,%eax
801042f3:	e8 f4 fb ff ff       	call   80103eec <argfd>
801042f8:	85 c0                	test   %eax,%eax
801042fa:	78 25                	js     80104321 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
801042fc:	e8 25 ee ff ff       	call   80103126 <myproc>
80104301:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104304:	c7 44 90 30 00 00 00 	movl   $0x0,0x30(%eax,%edx,4)
8010430b:	00 
  fileclose(f);
8010430c:	83 ec 0c             	sub    $0xc,%esp
8010430f:	ff 75 f0             	push   -0x10(%ebp)
80104312:	e8 7a c9 ff ff       	call   80100c91 <fileclose>
  return 0;
80104317:	83 c4 10             	add    $0x10,%esp
8010431a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010431f:	c9                   	leave  
80104320:	c3                   	ret    
    return -1;
80104321:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104326:	eb f7                	jmp    8010431f <sys_close+0x3d>

80104328 <sys_fstat>:
{
80104328:	55                   	push   %ebp
80104329:	89 e5                	mov    %esp,%ebp
8010432b:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010432e:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104331:	ba 00 00 00 00       	mov    $0x0,%edx
80104336:	b8 00 00 00 00       	mov    $0x0,%eax
8010433b:	e8 ac fb ff ff       	call   80103eec <argfd>
80104340:	85 c0                	test   %eax,%eax
80104342:	78 2a                	js     8010436e <sys_fstat+0x46>
80104344:	83 ec 04             	sub    $0x4,%esp
80104347:	6a 14                	push   $0x14
80104349:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010434c:	50                   	push   %eax
8010434d:	6a 01                	push   $0x1
8010434f:	e8 a5 fa ff ff       	call   80103df9 <argptr>
80104354:	83 c4 10             	add    $0x10,%esp
80104357:	85 c0                	test   %eax,%eax
80104359:	78 13                	js     8010436e <sys_fstat+0x46>
  return filestat(f, st);
8010435b:	83 ec 08             	sub    $0x8,%esp
8010435e:	ff 75 f0             	push   -0x10(%ebp)
80104361:	ff 75 f4             	push   -0xc(%ebp)
80104364:	e8 da c9 ff ff       	call   80100d43 <filestat>
80104369:	83 c4 10             	add    $0x10,%esp
}
8010436c:	c9                   	leave  
8010436d:	c3                   	ret    
    return -1;
8010436e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104373:	eb f7                	jmp    8010436c <sys_fstat+0x44>

80104375 <sys_link>:
{
80104375:	55                   	push   %ebp
80104376:	89 e5                	mov    %esp,%ebp
80104378:	56                   	push   %esi
80104379:	53                   	push   %ebx
8010437a:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010437d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104380:	50                   	push   %eax
80104381:	6a 00                	push   $0x0
80104383:	e8 da fa ff ff       	call   80103e62 <argstr>
80104388:	83 c4 10             	add    $0x10,%esp
8010438b:	85 c0                	test   %eax,%eax
8010438d:	0f 88 d1 00 00 00    	js     80104464 <sys_link+0xef>
80104393:	83 ec 08             	sub    $0x8,%esp
80104396:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104399:	50                   	push   %eax
8010439a:	6a 01                	push   $0x1
8010439c:	e8 c1 fa ff ff       	call   80103e62 <argstr>
801043a1:	83 c4 10             	add    $0x10,%esp
801043a4:	85 c0                	test   %eax,%eax
801043a6:	0f 88 b8 00 00 00    	js     80104464 <sys_link+0xef>
  begin_op();
801043ac:	e8 32 e3 ff ff       	call   801026e3 <begin_op>
  if((ip = namei(old)) == 0){
801043b1:	83 ec 0c             	sub    $0xc,%esp
801043b4:	ff 75 e0             	push   -0x20(%ebp)
801043b7:	e8 b5 d7 ff ff       	call   80101b71 <namei>
801043bc:	89 c3                	mov    %eax,%ebx
801043be:	83 c4 10             	add    $0x10,%esp
801043c1:	85 c0                	test   %eax,%eax
801043c3:	0f 84 a2 00 00 00    	je     8010446b <sys_link+0xf6>
  ilock(ip);
801043c9:	83 ec 0c             	sub    $0xc,%esp
801043cc:	50                   	push   %eax
801043cd:	e8 3b d1 ff ff       	call   8010150d <ilock>
  if(ip->type == T_DIR){
801043d2:	83 c4 10             	add    $0x10,%esp
801043d5:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801043da:	0f 84 97 00 00 00    	je     80104477 <sys_link+0x102>
  ip->nlink++;
801043e0:	66 8b 43 56          	mov    0x56(%ebx),%ax
801043e4:	40                   	inc    %eax
801043e5:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801043e9:	83 ec 0c             	sub    $0xc,%esp
801043ec:	53                   	push   %ebx
801043ed:	e8 c2 cf ff ff       	call   801013b4 <iupdate>
  iunlock(ip);
801043f2:	89 1c 24             	mov    %ebx,(%esp)
801043f5:	e8 d3 d1 ff ff       	call   801015cd <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801043fa:	83 c4 08             	add    $0x8,%esp
801043fd:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104400:	50                   	push   %eax
80104401:	ff 75 e4             	push   -0x1c(%ebp)
80104404:	e8 80 d7 ff ff       	call   80101b89 <nameiparent>
80104409:	89 c6                	mov    %eax,%esi
8010440b:	83 c4 10             	add    $0x10,%esp
8010440e:	85 c0                	test   %eax,%eax
80104410:	0f 84 85 00 00 00    	je     8010449b <sys_link+0x126>
  ilock(dp);
80104416:	83 ec 0c             	sub    $0xc,%esp
80104419:	50                   	push   %eax
8010441a:	e8 ee d0 ff ff       	call   8010150d <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010441f:	83 c4 10             	add    $0x10,%esp
80104422:	8b 03                	mov    (%ebx),%eax
80104424:	39 06                	cmp    %eax,(%esi)
80104426:	75 67                	jne    8010448f <sys_link+0x11a>
80104428:	83 ec 04             	sub    $0x4,%esp
8010442b:	ff 73 04             	push   0x4(%ebx)
8010442e:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104431:	50                   	push   %eax
80104432:	56                   	push   %esi
80104433:	e8 88 d6 ff ff       	call   80101ac0 <dirlink>
80104438:	83 c4 10             	add    $0x10,%esp
8010443b:	85 c0                	test   %eax,%eax
8010443d:	78 50                	js     8010448f <sys_link+0x11a>
  iunlockput(dp);
8010443f:	83 ec 0c             	sub    $0xc,%esp
80104442:	56                   	push   %esi
80104443:	e8 68 d2 ff ff       	call   801016b0 <iunlockput>
  iput(ip);
80104448:	89 1c 24             	mov    %ebx,(%esp)
8010444b:	e8 c2 d1 ff ff       	call   80101612 <iput>
  end_op();
80104450:	e8 0a e3 ff ff       	call   8010275f <end_op>
  return 0;
80104455:	83 c4 10             	add    $0x10,%esp
80104458:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010445d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104460:	5b                   	pop    %ebx
80104461:	5e                   	pop    %esi
80104462:	5d                   	pop    %ebp
80104463:	c3                   	ret    
    return -1;
80104464:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104469:	eb f2                	jmp    8010445d <sys_link+0xe8>
    end_op();
8010446b:	e8 ef e2 ff ff       	call   8010275f <end_op>
    return -1;
80104470:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104475:	eb e6                	jmp    8010445d <sys_link+0xe8>
    iunlockput(ip);
80104477:	83 ec 0c             	sub    $0xc,%esp
8010447a:	53                   	push   %ebx
8010447b:	e8 30 d2 ff ff       	call   801016b0 <iunlockput>
    end_op();
80104480:	e8 da e2 ff ff       	call   8010275f <end_op>
    return -1;
80104485:	83 c4 10             	add    $0x10,%esp
80104488:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010448d:	eb ce                	jmp    8010445d <sys_link+0xe8>
    iunlockput(dp);
8010448f:	83 ec 0c             	sub    $0xc,%esp
80104492:	56                   	push   %esi
80104493:	e8 18 d2 ff ff       	call   801016b0 <iunlockput>
    goto bad;
80104498:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
8010449b:	83 ec 0c             	sub    $0xc,%esp
8010449e:	53                   	push   %ebx
8010449f:	e8 69 d0 ff ff       	call   8010150d <ilock>
  ip->nlink--;
801044a4:	66 8b 43 56          	mov    0x56(%ebx),%ax
801044a8:	48                   	dec    %eax
801044a9:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801044ad:	89 1c 24             	mov    %ebx,(%esp)
801044b0:	e8 ff ce ff ff       	call   801013b4 <iupdate>
  iunlockput(ip);
801044b5:	89 1c 24             	mov    %ebx,(%esp)
801044b8:	e8 f3 d1 ff ff       	call   801016b0 <iunlockput>
  end_op();
801044bd:	e8 9d e2 ff ff       	call   8010275f <end_op>
  return -1;
801044c2:	83 c4 10             	add    $0x10,%esp
801044c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044ca:	eb 91                	jmp    8010445d <sys_link+0xe8>

801044cc <sys_unlink>:
{
801044cc:	55                   	push   %ebp
801044cd:	89 e5                	mov    %esp,%ebp
801044cf:	57                   	push   %edi
801044d0:	56                   	push   %esi
801044d1:	53                   	push   %ebx
801044d2:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801044d5:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801044d8:	50                   	push   %eax
801044d9:	6a 00                	push   $0x0
801044db:	e8 82 f9 ff ff       	call   80103e62 <argstr>
801044e0:	83 c4 10             	add    $0x10,%esp
801044e3:	85 c0                	test   %eax,%eax
801044e5:	0f 88 7f 01 00 00    	js     8010466a <sys_unlink+0x19e>
  begin_op();
801044eb:	e8 f3 e1 ff ff       	call   801026e3 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801044f0:	83 ec 08             	sub    $0x8,%esp
801044f3:	8d 45 ca             	lea    -0x36(%ebp),%eax
801044f6:	50                   	push   %eax
801044f7:	ff 75 c4             	push   -0x3c(%ebp)
801044fa:	e8 8a d6 ff ff       	call   80101b89 <nameiparent>
801044ff:	89 c6                	mov    %eax,%esi
80104501:	83 c4 10             	add    $0x10,%esp
80104504:	85 c0                	test   %eax,%eax
80104506:	0f 84 eb 00 00 00    	je     801045f7 <sys_unlink+0x12b>
  ilock(dp);
8010450c:	83 ec 0c             	sub    $0xc,%esp
8010450f:	50                   	push   %eax
80104510:	e8 f8 cf ff ff       	call   8010150d <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104515:	83 c4 08             	add    $0x8,%esp
80104518:	68 62 6e 10 80       	push   $0x80106e62
8010451d:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104520:	50                   	push   %eax
80104521:	e8 08 d4 ff ff       	call   8010192e <namecmp>
80104526:	83 c4 10             	add    $0x10,%esp
80104529:	85 c0                	test   %eax,%eax
8010452b:	0f 84 fa 00 00 00    	je     8010462b <sys_unlink+0x15f>
80104531:	83 ec 08             	sub    $0x8,%esp
80104534:	68 61 6e 10 80       	push   $0x80106e61
80104539:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010453c:	50                   	push   %eax
8010453d:	e8 ec d3 ff ff       	call   8010192e <namecmp>
80104542:	83 c4 10             	add    $0x10,%esp
80104545:	85 c0                	test   %eax,%eax
80104547:	0f 84 de 00 00 00    	je     8010462b <sys_unlink+0x15f>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010454d:	83 ec 04             	sub    $0x4,%esp
80104550:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104553:	50                   	push   %eax
80104554:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104557:	50                   	push   %eax
80104558:	56                   	push   %esi
80104559:	e8 e5 d3 ff ff       	call   80101943 <dirlookup>
8010455e:	89 c3                	mov    %eax,%ebx
80104560:	83 c4 10             	add    $0x10,%esp
80104563:	85 c0                	test   %eax,%eax
80104565:	0f 84 c0 00 00 00    	je     8010462b <sys_unlink+0x15f>
  ilock(ip);
8010456b:	83 ec 0c             	sub    $0xc,%esp
8010456e:	50                   	push   %eax
8010456f:	e8 99 cf ff ff       	call   8010150d <ilock>
  if(ip->nlink < 1)
80104574:	83 c4 10             	add    $0x10,%esp
80104577:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010457c:	0f 8e 81 00 00 00    	jle    80104603 <sys_unlink+0x137>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104582:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104587:	0f 84 83 00 00 00    	je     80104610 <sys_unlink+0x144>
  memset(&de, 0, sizeof(de));
8010458d:	83 ec 04             	sub    $0x4,%esp
80104590:	6a 10                	push   $0x10
80104592:	6a 00                	push   $0x0
80104594:	8d 7d d8             	lea    -0x28(%ebp),%edi
80104597:	57                   	push   %edi
80104598:	e8 fe f5 ff ff       	call   80103b9b <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010459d:	6a 10                	push   $0x10
8010459f:	ff 75 c0             	push   -0x40(%ebp)
801045a2:	57                   	push   %edi
801045a3:	56                   	push   %esi
801045a4:	e8 51 d2 ff ff       	call   801017fa <writei>
801045a9:	83 c4 20             	add    $0x20,%esp
801045ac:	83 f8 10             	cmp    $0x10,%eax
801045af:	0f 85 8e 00 00 00    	jne    80104643 <sys_unlink+0x177>
  if(ip->type == T_DIR){
801045b5:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801045ba:	0f 84 90 00 00 00    	je     80104650 <sys_unlink+0x184>
  iunlockput(dp);
801045c0:	83 ec 0c             	sub    $0xc,%esp
801045c3:	56                   	push   %esi
801045c4:	e8 e7 d0 ff ff       	call   801016b0 <iunlockput>
  ip->nlink--;
801045c9:	66 8b 43 56          	mov    0x56(%ebx),%ax
801045cd:	48                   	dec    %eax
801045ce:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801045d2:	89 1c 24             	mov    %ebx,(%esp)
801045d5:	e8 da cd ff ff       	call   801013b4 <iupdate>
  iunlockput(ip);
801045da:	89 1c 24             	mov    %ebx,(%esp)
801045dd:	e8 ce d0 ff ff       	call   801016b0 <iunlockput>
  end_op();
801045e2:	e8 78 e1 ff ff       	call   8010275f <end_op>
  return 0;
801045e7:	83 c4 10             	add    $0x10,%esp
801045ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
801045f2:	5b                   	pop    %ebx
801045f3:	5e                   	pop    %esi
801045f4:	5f                   	pop    %edi
801045f5:	5d                   	pop    %ebp
801045f6:	c3                   	ret    
    end_op();
801045f7:	e8 63 e1 ff ff       	call   8010275f <end_op>
    return -1;
801045fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104601:	eb ec                	jmp    801045ef <sys_unlink+0x123>
    panic("unlink: nlink < 1");
80104603:	83 ec 0c             	sub    $0xc,%esp
80104606:	68 80 6e 10 80       	push   $0x80106e80
8010460b:	e8 31 bd ff ff       	call   80100341 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104610:	89 d8                	mov    %ebx,%eax
80104612:	e8 69 f9 ff ff       	call   80103f80 <isdirempty>
80104617:	85 c0                	test   %eax,%eax
80104619:	0f 85 6e ff ff ff    	jne    8010458d <sys_unlink+0xc1>
    iunlockput(ip);
8010461f:	83 ec 0c             	sub    $0xc,%esp
80104622:	53                   	push   %ebx
80104623:	e8 88 d0 ff ff       	call   801016b0 <iunlockput>
    goto bad;
80104628:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
8010462b:	83 ec 0c             	sub    $0xc,%esp
8010462e:	56                   	push   %esi
8010462f:	e8 7c d0 ff ff       	call   801016b0 <iunlockput>
  end_op();
80104634:	e8 26 e1 ff ff       	call   8010275f <end_op>
  return -1;
80104639:	83 c4 10             	add    $0x10,%esp
8010463c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104641:	eb ac                	jmp    801045ef <sys_unlink+0x123>
    panic("unlink: writei");
80104643:	83 ec 0c             	sub    $0xc,%esp
80104646:	68 92 6e 10 80       	push   $0x80106e92
8010464b:	e8 f1 bc ff ff       	call   80100341 <panic>
    dp->nlink--;
80104650:	66 8b 46 56          	mov    0x56(%esi),%ax
80104654:	48                   	dec    %eax
80104655:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104659:	83 ec 0c             	sub    $0xc,%esp
8010465c:	56                   	push   %esi
8010465d:	e8 52 cd ff ff       	call   801013b4 <iupdate>
80104662:	83 c4 10             	add    $0x10,%esp
80104665:	e9 56 ff ff ff       	jmp    801045c0 <sys_unlink+0xf4>
    return -1;
8010466a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010466f:	e9 7b ff ff ff       	jmp    801045ef <sys_unlink+0x123>

80104674 <sys_open>:

int
sys_open(void)
{
80104674:	55                   	push   %ebp
80104675:	89 e5                	mov    %esp,%ebp
80104677:	57                   	push   %edi
80104678:	56                   	push   %esi
80104679:	53                   	push   %ebx
8010467a:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010467d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104680:	50                   	push   %eax
80104681:	6a 00                	push   $0x0
80104683:	e8 da f7 ff ff       	call   80103e62 <argstr>
80104688:	83 c4 10             	add    $0x10,%esp
8010468b:	85 c0                	test   %eax,%eax
8010468d:	0f 88 a0 00 00 00    	js     80104733 <sys_open+0xbf>
80104693:	83 ec 08             	sub    $0x8,%esp
80104696:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104699:	50                   	push   %eax
8010469a:	6a 01                	push   $0x1
8010469c:	e8 30 f7 ff ff       	call   80103dd1 <argint>
801046a1:	83 c4 10             	add    $0x10,%esp
801046a4:	85 c0                	test   %eax,%eax
801046a6:	0f 88 87 00 00 00    	js     80104733 <sys_open+0xbf>
    return -1;

  begin_op();
801046ac:	e8 32 e0 ff ff       	call   801026e3 <begin_op>

  if(omode & O_CREATE){
801046b1:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
801046b5:	0f 84 8b 00 00 00    	je     80104746 <sys_open+0xd2>
    ip = create(path, T_FILE, 0, 0);
801046bb:	83 ec 0c             	sub    $0xc,%esp
801046be:	6a 00                	push   $0x0
801046c0:	b9 00 00 00 00       	mov    $0x0,%ecx
801046c5:	ba 02 00 00 00       	mov    $0x2,%edx
801046ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801046cd:	e8 05 f9 ff ff       	call   80103fd7 <create>
801046d2:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801046d4:	83 c4 10             	add    $0x10,%esp
801046d7:	85 c0                	test   %eax,%eax
801046d9:	74 5f                	je     8010473a <sys_open+0xc6>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801046db:	e8 0d c5 ff ff       	call   80100bed <filealloc>
801046e0:	89 c3                	mov    %eax,%ebx
801046e2:	85 c0                	test   %eax,%eax
801046e4:	0f 84 b5 00 00 00    	je     8010479f <sys_open+0x12b>
801046ea:	e8 5d f8 ff ff       	call   80103f4c <fdalloc>
801046ef:	89 c7                	mov    %eax,%edi
801046f1:	85 c0                	test   %eax,%eax
801046f3:	0f 88 a6 00 00 00    	js     8010479f <sys_open+0x12b>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801046f9:	83 ec 0c             	sub    $0xc,%esp
801046fc:	56                   	push   %esi
801046fd:	e8 cb ce ff ff       	call   801015cd <iunlock>
  end_op();
80104702:	e8 58 e0 ff ff       	call   8010275f <end_op>

  f->type = FD_INODE;
80104707:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
8010470d:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104710:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104717:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010471a:	83 c4 10             	add    $0x10,%esp
8010471d:	a8 01                	test   $0x1,%al
8010471f:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104723:	a8 03                	test   $0x3,%al
80104725:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104729:	89 f8                	mov    %edi,%eax
8010472b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010472e:	5b                   	pop    %ebx
8010472f:	5e                   	pop    %esi
80104730:	5f                   	pop    %edi
80104731:	5d                   	pop    %ebp
80104732:	c3                   	ret    
    return -1;
80104733:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104738:	eb ef                	jmp    80104729 <sys_open+0xb5>
      end_op();
8010473a:	e8 20 e0 ff ff       	call   8010275f <end_op>
      return -1;
8010473f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104744:	eb e3                	jmp    80104729 <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104746:	83 ec 0c             	sub    $0xc,%esp
80104749:	ff 75 e4             	push   -0x1c(%ebp)
8010474c:	e8 20 d4 ff ff       	call   80101b71 <namei>
80104751:	89 c6                	mov    %eax,%esi
80104753:	83 c4 10             	add    $0x10,%esp
80104756:	85 c0                	test   %eax,%eax
80104758:	74 39                	je     80104793 <sys_open+0x11f>
    ilock(ip);
8010475a:	83 ec 0c             	sub    $0xc,%esp
8010475d:	50                   	push   %eax
8010475e:	e8 aa cd ff ff       	call   8010150d <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104763:	83 c4 10             	add    $0x10,%esp
80104766:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
8010476b:	0f 85 6a ff ff ff    	jne    801046db <sys_open+0x67>
80104771:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104775:	0f 84 60 ff ff ff    	je     801046db <sys_open+0x67>
      iunlockput(ip);
8010477b:	83 ec 0c             	sub    $0xc,%esp
8010477e:	56                   	push   %esi
8010477f:	e8 2c cf ff ff       	call   801016b0 <iunlockput>
      end_op();
80104784:	e8 d6 df ff ff       	call   8010275f <end_op>
      return -1;
80104789:	83 c4 10             	add    $0x10,%esp
8010478c:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104791:	eb 96                	jmp    80104729 <sys_open+0xb5>
      end_op();
80104793:	e8 c7 df ff ff       	call   8010275f <end_op>
      return -1;
80104798:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010479d:	eb 8a                	jmp    80104729 <sys_open+0xb5>
    if(f)
8010479f:	85 db                	test   %ebx,%ebx
801047a1:	74 0c                	je     801047af <sys_open+0x13b>
      fileclose(f);
801047a3:	83 ec 0c             	sub    $0xc,%esp
801047a6:	53                   	push   %ebx
801047a7:	e8 e5 c4 ff ff       	call   80100c91 <fileclose>
801047ac:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801047af:	83 ec 0c             	sub    $0xc,%esp
801047b2:	56                   	push   %esi
801047b3:	e8 f8 ce ff ff       	call   801016b0 <iunlockput>
    end_op();
801047b8:	e8 a2 df ff ff       	call   8010275f <end_op>
    return -1;
801047bd:	83 c4 10             	add    $0x10,%esp
801047c0:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801047c5:	e9 5f ff ff ff       	jmp    80104729 <sys_open+0xb5>

801047ca <sys_mkdir>:

int
sys_mkdir(void)
{
801047ca:	55                   	push   %ebp
801047cb:	89 e5                	mov    %esp,%ebp
801047cd:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801047d0:	e8 0e df ff ff       	call   801026e3 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801047d5:	83 ec 08             	sub    $0x8,%esp
801047d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801047db:	50                   	push   %eax
801047dc:	6a 00                	push   $0x0
801047de:	e8 7f f6 ff ff       	call   80103e62 <argstr>
801047e3:	83 c4 10             	add    $0x10,%esp
801047e6:	85 c0                	test   %eax,%eax
801047e8:	78 36                	js     80104820 <sys_mkdir+0x56>
801047ea:	83 ec 0c             	sub    $0xc,%esp
801047ed:	6a 00                	push   $0x0
801047ef:	b9 00 00 00 00       	mov    $0x0,%ecx
801047f4:	ba 01 00 00 00       	mov    $0x1,%edx
801047f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047fc:	e8 d6 f7 ff ff       	call   80103fd7 <create>
80104801:	83 c4 10             	add    $0x10,%esp
80104804:	85 c0                	test   %eax,%eax
80104806:	74 18                	je     80104820 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104808:	83 ec 0c             	sub    $0xc,%esp
8010480b:	50                   	push   %eax
8010480c:	e8 9f ce ff ff       	call   801016b0 <iunlockput>
  end_op();
80104811:	e8 49 df ff ff       	call   8010275f <end_op>
  return 0;
80104816:	83 c4 10             	add    $0x10,%esp
80104819:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010481e:	c9                   	leave  
8010481f:	c3                   	ret    
    end_op();
80104820:	e8 3a df ff ff       	call   8010275f <end_op>
    return -1;
80104825:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010482a:	eb f2                	jmp    8010481e <sys_mkdir+0x54>

8010482c <sys_mknod>:

int
sys_mknod(void)
{
8010482c:	55                   	push   %ebp
8010482d:	89 e5                	mov    %esp,%ebp
8010482f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104832:	e8 ac de ff ff       	call   801026e3 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104837:	83 ec 08             	sub    $0x8,%esp
8010483a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010483d:	50                   	push   %eax
8010483e:	6a 00                	push   $0x0
80104840:	e8 1d f6 ff ff       	call   80103e62 <argstr>
80104845:	83 c4 10             	add    $0x10,%esp
80104848:	85 c0                	test   %eax,%eax
8010484a:	78 62                	js     801048ae <sys_mknod+0x82>
     argint(1, &major) < 0 ||
8010484c:	83 ec 08             	sub    $0x8,%esp
8010484f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104852:	50                   	push   %eax
80104853:	6a 01                	push   $0x1
80104855:	e8 77 f5 ff ff       	call   80103dd1 <argint>
  if((argstr(0, &path)) < 0 ||
8010485a:	83 c4 10             	add    $0x10,%esp
8010485d:	85 c0                	test   %eax,%eax
8010485f:	78 4d                	js     801048ae <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104861:	83 ec 08             	sub    $0x8,%esp
80104864:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104867:	50                   	push   %eax
80104868:	6a 02                	push   $0x2
8010486a:	e8 62 f5 ff ff       	call   80103dd1 <argint>
     argint(1, &major) < 0 ||
8010486f:	83 c4 10             	add    $0x10,%esp
80104872:	85 c0                	test   %eax,%eax
80104874:	78 38                	js     801048ae <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104876:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
8010487a:	83 ec 0c             	sub    $0xc,%esp
8010487d:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104881:	50                   	push   %eax
80104882:	ba 03 00 00 00       	mov    $0x3,%edx
80104887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010488a:	e8 48 f7 ff ff       	call   80103fd7 <create>
     argint(2, &minor) < 0 ||
8010488f:	83 c4 10             	add    $0x10,%esp
80104892:	85 c0                	test   %eax,%eax
80104894:	74 18                	je     801048ae <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104896:	83 ec 0c             	sub    $0xc,%esp
80104899:	50                   	push   %eax
8010489a:	e8 11 ce ff ff       	call   801016b0 <iunlockput>
  end_op();
8010489f:	e8 bb de ff ff       	call   8010275f <end_op>
  return 0;
801048a4:	83 c4 10             	add    $0x10,%esp
801048a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048ac:	c9                   	leave  
801048ad:	c3                   	ret    
    end_op();
801048ae:	e8 ac de ff ff       	call   8010275f <end_op>
    return -1;
801048b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048b8:	eb f2                	jmp    801048ac <sys_mknod+0x80>

801048ba <sys_chdir>:

int
sys_chdir(void)
{
801048ba:	55                   	push   %ebp
801048bb:	89 e5                	mov    %esp,%ebp
801048bd:	56                   	push   %esi
801048be:	53                   	push   %ebx
801048bf:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801048c2:	e8 5f e8 ff ff       	call   80103126 <myproc>
801048c7:	89 c6                	mov    %eax,%esi
  
  begin_op();
801048c9:	e8 15 de ff ff       	call   801026e3 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801048ce:	83 ec 08             	sub    $0x8,%esp
801048d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801048d4:	50                   	push   %eax
801048d5:	6a 00                	push   $0x0
801048d7:	e8 86 f5 ff ff       	call   80103e62 <argstr>
801048dc:	83 c4 10             	add    $0x10,%esp
801048df:	85 c0                	test   %eax,%eax
801048e1:	78 52                	js     80104935 <sys_chdir+0x7b>
801048e3:	83 ec 0c             	sub    $0xc,%esp
801048e6:	ff 75 f4             	push   -0xc(%ebp)
801048e9:	e8 83 d2 ff ff       	call   80101b71 <namei>
801048ee:	89 c3                	mov    %eax,%ebx
801048f0:	83 c4 10             	add    $0x10,%esp
801048f3:	85 c0                	test   %eax,%eax
801048f5:	74 3e                	je     80104935 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
801048f7:	83 ec 0c             	sub    $0xc,%esp
801048fa:	50                   	push   %eax
801048fb:	e8 0d cc ff ff       	call   8010150d <ilock>
  if(ip->type != T_DIR){
80104900:	83 c4 10             	add    $0x10,%esp
80104903:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104908:	75 37                	jne    80104941 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
8010490a:	83 ec 0c             	sub    $0xc,%esp
8010490d:	53                   	push   %ebx
8010490e:	e8 ba cc ff ff       	call   801015cd <iunlock>
  iput(curproc->cwd);
80104913:	83 c4 04             	add    $0x4,%esp
80104916:	ff 76 70             	push   0x70(%esi)
80104919:	e8 f4 cc ff ff       	call   80101612 <iput>
  end_op();
8010491e:	e8 3c de ff ff       	call   8010275f <end_op>
  curproc->cwd = ip;
80104923:	89 5e 70             	mov    %ebx,0x70(%esi)
  return 0;
80104926:	83 c4 10             	add    $0x10,%esp
80104929:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010492e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104931:	5b                   	pop    %ebx
80104932:	5e                   	pop    %esi
80104933:	5d                   	pop    %ebp
80104934:	c3                   	ret    
    end_op();
80104935:	e8 25 de ff ff       	call   8010275f <end_op>
    return -1;
8010493a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010493f:	eb ed                	jmp    8010492e <sys_chdir+0x74>
    iunlockput(ip);
80104941:	83 ec 0c             	sub    $0xc,%esp
80104944:	53                   	push   %ebx
80104945:	e8 66 cd ff ff       	call   801016b0 <iunlockput>
    end_op();
8010494a:	e8 10 de ff ff       	call   8010275f <end_op>
    return -1;
8010494f:	83 c4 10             	add    $0x10,%esp
80104952:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104957:	eb d5                	jmp    8010492e <sys_chdir+0x74>

80104959 <sys_exec>:

int
sys_exec(void)
{
80104959:	55                   	push   %ebp
8010495a:	89 e5                	mov    %esp,%ebp
8010495c:	53                   	push   %ebx
8010495d:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104963:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104966:	50                   	push   %eax
80104967:	6a 00                	push   $0x0
80104969:	e8 f4 f4 ff ff       	call   80103e62 <argstr>
8010496e:	83 c4 10             	add    $0x10,%esp
80104971:	85 c0                	test   %eax,%eax
80104973:	78 38                	js     801049ad <sys_exec+0x54>
80104975:	83 ec 08             	sub    $0x8,%esp
80104978:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010497e:	50                   	push   %eax
8010497f:	6a 01                	push   $0x1
80104981:	e8 4b f4 ff ff       	call   80103dd1 <argint>
80104986:	83 c4 10             	add    $0x10,%esp
80104989:	85 c0                	test   %eax,%eax
8010498b:	78 20                	js     801049ad <sys_exec+0x54>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
8010498d:	83 ec 04             	sub    $0x4,%esp
80104990:	68 80 00 00 00       	push   $0x80
80104995:	6a 00                	push   $0x0
80104997:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
8010499d:	50                   	push   %eax
8010499e:	e8 f8 f1 ff ff       	call   80103b9b <memset>
801049a3:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801049a6:	bb 00 00 00 00       	mov    $0x0,%ebx
801049ab:	eb 2a                	jmp    801049d7 <sys_exec+0x7e>
    return -1;
801049ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049b2:	eb 76                	jmp    80104a2a <sys_exec+0xd1>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
801049b4:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
801049bb:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801049bf:	83 ec 08             	sub    $0x8,%esp
801049c2:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
801049c8:	50                   	push   %eax
801049c9:	ff 75 f4             	push   -0xc(%ebp)
801049cc:	e8 bf be ff ff       	call   80100890 <exec>
801049d1:	83 c4 10             	add    $0x10,%esp
801049d4:	eb 54                	jmp    80104a2a <sys_exec+0xd1>
  for(i=0;; i++){
801049d6:	43                   	inc    %ebx
    if(i >= NELEM(argv))
801049d7:	83 fb 1f             	cmp    $0x1f,%ebx
801049da:	77 49                	ja     80104a25 <sys_exec+0xcc>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801049dc:	83 ec 08             	sub    $0x8,%esp
801049df:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801049e5:	50                   	push   %eax
801049e6:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
801049ec:	8d 04 98             	lea    (%eax,%ebx,4),%eax
801049ef:	50                   	push   %eax
801049f0:	e8 61 f3 ff ff       	call   80103d56 <fetchint>
801049f5:	83 c4 10             	add    $0x10,%esp
801049f8:	85 c0                	test   %eax,%eax
801049fa:	78 33                	js     80104a2f <sys_exec+0xd6>
    if(uarg == 0){
801049fc:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104a02:	85 c0                	test   %eax,%eax
80104a04:	74 ae                	je     801049b4 <sys_exec+0x5b>
    if(fetchstr(uarg, &argv[i]) < 0)
80104a06:	83 ec 08             	sub    $0x8,%esp
80104a09:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104a10:	52                   	push   %edx
80104a11:	50                   	push   %eax
80104a12:	e8 7b f3 ff ff       	call   80103d92 <fetchstr>
80104a17:	83 c4 10             	add    $0x10,%esp
80104a1a:	85 c0                	test   %eax,%eax
80104a1c:	79 b8                	jns    801049d6 <sys_exec+0x7d>
      return -1;
80104a1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a23:	eb 05                	jmp    80104a2a <sys_exec+0xd1>
      return -1;
80104a25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104a2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a2d:	c9                   	leave  
80104a2e:	c3                   	ret    
      return -1;
80104a2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a34:	eb f4                	jmp    80104a2a <sys_exec+0xd1>

80104a36 <sys_pipe>:

int
sys_pipe(void)
{
80104a36:	55                   	push   %ebp
80104a37:	89 e5                	mov    %esp,%ebp
80104a39:	53                   	push   %ebx
80104a3a:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104a3d:	6a 08                	push   $0x8
80104a3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a42:	50                   	push   %eax
80104a43:	6a 00                	push   $0x0
80104a45:	e8 af f3 ff ff       	call   80103df9 <argptr>
80104a4a:	83 c4 10             	add    $0x10,%esp
80104a4d:	85 c0                	test   %eax,%eax
80104a4f:	78 79                	js     80104aca <sys_pipe+0x94>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104a51:	83 ec 08             	sub    $0x8,%esp
80104a54:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104a57:	50                   	push   %eax
80104a58:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104a5b:	50                   	push   %eax
80104a5c:	e8 f9 e1 ff ff       	call   80102c5a <pipealloc>
80104a61:	83 c4 10             	add    $0x10,%esp
80104a64:	85 c0                	test   %eax,%eax
80104a66:	78 69                	js     80104ad1 <sys_pipe+0x9b>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104a68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a6b:	e8 dc f4 ff ff       	call   80103f4c <fdalloc>
80104a70:	89 c3                	mov    %eax,%ebx
80104a72:	85 c0                	test   %eax,%eax
80104a74:	78 21                	js     80104a97 <sys_pipe+0x61>
80104a76:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a79:	e8 ce f4 ff ff       	call   80103f4c <fdalloc>
80104a7e:	85 c0                	test   %eax,%eax
80104a80:	78 15                	js     80104a97 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104a82:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a85:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104a87:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a8a:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104a8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a95:	c9                   	leave  
80104a96:	c3                   	ret    
    if(fd0 >= 0)
80104a97:	85 db                	test   %ebx,%ebx
80104a99:	79 20                	jns    80104abb <sys_pipe+0x85>
    fileclose(rf);
80104a9b:	83 ec 0c             	sub    $0xc,%esp
80104a9e:	ff 75 f0             	push   -0x10(%ebp)
80104aa1:	e8 eb c1 ff ff       	call   80100c91 <fileclose>
    fileclose(wf);
80104aa6:	83 c4 04             	add    $0x4,%esp
80104aa9:	ff 75 ec             	push   -0x14(%ebp)
80104aac:	e8 e0 c1 ff ff       	call   80100c91 <fileclose>
    return -1;
80104ab1:	83 c4 10             	add    $0x10,%esp
80104ab4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ab9:	eb d7                	jmp    80104a92 <sys_pipe+0x5c>
      myproc()->ofile[fd0] = 0;
80104abb:	e8 66 e6 ff ff       	call   80103126 <myproc>
80104ac0:	c7 44 98 30 00 00 00 	movl   $0x0,0x30(%eax,%ebx,4)
80104ac7:	00 
80104ac8:	eb d1                	jmp    80104a9b <sys_pipe+0x65>
    return -1;
80104aca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104acf:	eb c1                	jmp    80104a92 <sys_pipe+0x5c>
    return -1;
80104ad1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ad6:	eb ba                	jmp    80104a92 <sys_pipe+0x5c>

80104ad8 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104ad8:	55                   	push   %ebp
80104ad9:	89 e5                	mov    %esp,%ebp
80104adb:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104ade:	e8 b9 e7 ff ff       	call   8010329c <fork>
}
80104ae3:	c9                   	leave  
80104ae4:	c3                   	ret    

80104ae5 <sys_exit>:

int
sys_exit(void)
{ // Recuperamos el valor de salida con argint
80104ae5:	55                   	push   %ebp
80104ae6:	89 e5                	mov    %esp,%ebp
80104ae8:	83 ec 20             	sub    $0x20,%esp
  int status;
  if(argint(0,&status) < 0)
80104aeb:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104aee:	50                   	push   %eax
80104aef:	6a 00                	push   $0x0
80104af1:	e8 db f2 ff ff       	call   80103dd1 <argint>
80104af6:	83 c4 10             	add    $0x10,%esp
80104af9:	85 c0                	test   %eax,%eax
80104afb:	78 1c                	js     80104b19 <sys_exit+0x34>
  {
    return -1;
  }
	status = status << 8;
80104afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b00:	c1 e0 08             	shl    $0x8,%eax
80104b03:	89 45 f4             	mov    %eax,-0xc(%ebp)
  exit(status);
80104b06:	83 ec 0c             	sub    $0xc,%esp
80104b09:	50                   	push   %eax
80104b0a:	e8 c5 e9 ff ff       	call   801034d4 <exit>
  return 0;  // not reached
80104b0f:	83 c4 10             	add    $0x10,%esp
80104b12:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b17:	c9                   	leave  
80104b18:	c3                   	ret    
    return -1;
80104b19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b1e:	eb f7                	jmp    80104b17 <sys_exit+0x32>

80104b20 <sys_wait>:

int
sys_wait(void)
{ //Recuperamos la variable con argptr (int *)
80104b20:	55                   	push   %ebp
80104b21:	89 e5                	mov    %esp,%ebp
80104b23:	83 ec 1c             	sub    $0x1c,%esp
  int *status;
  int size = 4;

  if(argptr(0,(void**) &status,size) < 0)
80104b26:	6a 04                	push   $0x4
80104b28:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b2b:	50                   	push   %eax
80104b2c:	6a 00                	push   $0x0
80104b2e:	e8 c6 f2 ff ff       	call   80103df9 <argptr>
80104b33:	83 c4 10             	add    $0x10,%esp
80104b36:	85 c0                	test   %eax,%eax
80104b38:	78 10                	js     80104b4a <sys_wait+0x2a>
  {
    return -1;
  }
  return wait(status);
80104b3a:	83 ec 0c             	sub    $0xc,%esp
80104b3d:	ff 75 f4             	push   -0xc(%ebp)
80104b40:	e8 30 eb ff ff       	call   80103675 <wait>
80104b45:	83 c4 10             	add    $0x10,%esp
}
80104b48:	c9                   	leave  
80104b49:	c3                   	ret    
    return -1;
80104b4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b4f:	eb f7                	jmp    80104b48 <sys_wait+0x28>

80104b51 <sys_kill>:

int
sys_kill(void)
{
80104b51:	55                   	push   %ebp
80104b52:	89 e5                	mov    %esp,%ebp
80104b54:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104b57:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b5a:	50                   	push   %eax
80104b5b:	6a 00                	push   $0x0
80104b5d:	e8 6f f2 ff ff       	call   80103dd1 <argint>
80104b62:	83 c4 10             	add    $0x10,%esp
80104b65:	85 c0                	test   %eax,%eax
80104b67:	78 10                	js     80104b79 <sys_kill+0x28>
    return -1;
  return kill(pid);
80104b69:	83 ec 0c             	sub    $0xc,%esp
80104b6c:	ff 75 f4             	push   -0xc(%ebp)
80104b6f:	e8 10 ec ff ff       	call   80103784 <kill>
80104b74:	83 c4 10             	add    $0x10,%esp
}
80104b77:	c9                   	leave  
80104b78:	c3                   	ret    
    return -1;
80104b79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b7e:	eb f7                	jmp    80104b77 <sys_kill+0x26>

80104b80 <sys_getpid>:

int
sys_getpid(void)
{
80104b80:	55                   	push   %ebp
80104b81:	89 e5                	mov    %esp,%ebp
80104b83:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104b86:	e8 9b e5 ff ff       	call   80103126 <myproc>
80104b8b:	8b 40 18             	mov    0x18(%eax),%eax
}
80104b8e:	c9                   	leave  
80104b8f:	c3                   	ret    

80104b90 <sys_sbrk>:

int
sys_sbrk(void)
{	
80104b90:	55                   	push   %ebp
80104b91:	89 e5                	mov    %esp,%ebp
80104b93:	57                   	push   %edi
80104b94:	56                   	push   %esi
80104b95:	53                   	push   %ebx
80104b96:	83 ec 1c             	sub    $0x1c,%esp
	uint addr = myproc()->sz; //Devuelvo el tamaño inicial
80104b99:	e8 88 e5 ff ff       	call   80103126 <myproc>
80104b9e:	8b 70 08             	mov    0x8(%eax),%esi
  int n;
	uint oldsz = myproc()->sz;
80104ba1:	e8 80 e5 ff ff       	call   80103126 <myproc>
80104ba6:	8b 78 08             	mov    0x8(%eax),%edi
  uint newsz;

	if(argint(0, &n) < 0)
80104ba9:	83 ec 08             	sub    $0x8,%esp
80104bac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104baf:	50                   	push   %eax
80104bb0:	6a 00                	push   $0x0
80104bb2:	e8 1a f2 ff ff       	call   80103dd1 <argint>
80104bb7:	83 c4 10             	add    $0x10,%esp
80104bba:	85 c0                	test   %eax,%eax
80104bbc:	78 49                	js     80104c07 <sys_sbrk+0x77>
    return -1;
	newsz = oldsz + n; //independientemente del valor de n, actualizamos el newsz
80104bbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104bc1:	8d 1c 38             	lea    (%eax,%edi,1),%ebx
	
	if(n < 0)
80104bc4:	85 c0                	test   %eax,%eax
80104bc6:	78 12                	js     80104bda <sys_sbrk+0x4a>
	{//Si n es negativo ->dealloc, porque la liberación de memoria no es perezosa
		if((newsz = deallocuvm(myproc()->pgdir, oldsz, oldsz + n)) == 0)
   		return -1;
		lcr3(V2P(myproc()->pgdir));  // Invalidate TLB. Cambia la tabla de páginas
  }
	myproc()->sz= newsz; //actualizamos el sz del proceso
80104bc8:	e8 59 e5 ff ff       	call   80103126 <myproc>
80104bcd:	89 58 08             	mov    %ebx,0x8(%eax)

 // if(growproc(n) < 0)//El tamaño nuevo se pone en esta función
 //   return -1;
  return addr;
80104bd0:	89 f0                	mov    %esi,%eax
}
80104bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104bd5:	5b                   	pop    %ebx
80104bd6:	5e                   	pop    %esi
80104bd7:	5f                   	pop    %edi
80104bd8:	5d                   	pop    %ebp
80104bd9:	c3                   	ret    
		if((newsz = deallocuvm(myproc()->pgdir, oldsz, oldsz + n)) == 0)
80104bda:	e8 47 e5 ff ff       	call   80103126 <myproc>
80104bdf:	83 ec 04             	sub    $0x4,%esp
80104be2:	53                   	push   %ebx
80104be3:	57                   	push   %edi
80104be4:	ff 70 0c             	push   0xc(%eax)
80104be7:	e8 e7 16 00 00       	call   801062d3 <deallocuvm>
80104bec:	89 c3                	mov    %eax,%ebx
80104bee:	83 c4 10             	add    $0x10,%esp
80104bf1:	85 c0                	test   %eax,%eax
80104bf3:	74 19                	je     80104c0e <sys_sbrk+0x7e>
		lcr3(V2P(myproc()->pgdir));  // Invalidate TLB. Cambia la tabla de páginas
80104bf5:	e8 2c e5 ff ff       	call   80103126 <myproc>
80104bfa:	8b 40 0c             	mov    0xc(%eax),%eax
80104bfd:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80104c02:	0f 22 d8             	mov    %eax,%cr3
}
80104c05:	eb c1                	jmp    80104bc8 <sys_sbrk+0x38>
    return -1;
80104c07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c0c:	eb c4                	jmp    80104bd2 <sys_sbrk+0x42>
   		return -1;
80104c0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c13:	eb bd                	jmp    80104bd2 <sys_sbrk+0x42>

80104c15 <sys_sleep>:

int
sys_sleep(void)
{
80104c15:	55                   	push   %ebp
80104c16:	89 e5                	mov    %esp,%ebp
80104c18:	53                   	push   %ebx
80104c19:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104c1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c1f:	50                   	push   %eax
80104c20:	6a 00                	push   $0x0
80104c22:	e8 aa f1 ff ff       	call   80103dd1 <argint>
80104c27:	83 c4 10             	add    $0x10,%esp
80104c2a:	85 c0                	test   %eax,%eax
80104c2c:	78 75                	js     80104ca3 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104c2e:	83 ec 0c             	sub    $0xc,%esp
80104c31:	68 80 3e 11 80       	push   $0x80113e80
80104c36:	e8 b4 ee ff ff       	call   80103aef <acquire>
  ticks0 = ticks;
80104c3b:	8b 1d 60 3e 11 80    	mov    0x80113e60,%ebx
  while(ticks - ticks0 < n){
80104c41:	83 c4 10             	add    $0x10,%esp
80104c44:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80104c49:	29 d8                	sub    %ebx,%eax
80104c4b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104c4e:	73 39                	jae    80104c89 <sys_sleep+0x74>
    if(myproc()->killed){
80104c50:	e8 d1 e4 ff ff       	call   80103126 <myproc>
80104c55:	83 78 2c 00          	cmpl   $0x0,0x2c(%eax)
80104c59:	75 17                	jne    80104c72 <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104c5b:	83 ec 08             	sub    $0x8,%esp
80104c5e:	68 80 3e 11 80       	push   $0x80113e80
80104c63:	68 60 3e 11 80       	push   $0x80113e60
80104c68:	e8 77 e9 ff ff       	call   801035e4 <sleep>
80104c6d:	83 c4 10             	add    $0x10,%esp
80104c70:	eb d2                	jmp    80104c44 <sys_sleep+0x2f>
      release(&tickslock);
80104c72:	83 ec 0c             	sub    $0xc,%esp
80104c75:	68 80 3e 11 80       	push   $0x80113e80
80104c7a:	e8 d5 ee ff ff       	call   80103b54 <release>
      return -1;
80104c7f:	83 c4 10             	add    $0x10,%esp
80104c82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c87:	eb 15                	jmp    80104c9e <sys_sleep+0x89>
  }
  release(&tickslock);
80104c89:	83 ec 0c             	sub    $0xc,%esp
80104c8c:	68 80 3e 11 80       	push   $0x80113e80
80104c91:	e8 be ee ff ff       	call   80103b54 <release>
  return 0;
80104c96:	83 c4 10             	add    $0x10,%esp
80104c99:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ca1:	c9                   	leave  
80104ca2:	c3                   	ret    
    return -1;
80104ca3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ca8:	eb f4                	jmp    80104c9e <sys_sleep+0x89>

80104caa <sys_date>:

//Implementación de llamada al sistema date para sacar la fecha actual por pantalla
//Devuelve 0 en caso de acabar correctamente y -1 en caso de fallo
int
sys_date(void)
{
80104caa:	55                   	push   %ebp
80104cab:	89 e5                	mov    %esp,%ebp
80104cad:	83 ec 1c             	sub    $0x1c,%esp
 //Date tiene que recuperar el dato de la pila del usuario
 struct rtcdate *d;//Esto es lo que me pasa el usuario
 //vamos a usar argint para recuperar el argumento
 if(argptr(0, (void **) &d, sizeof(struct rtcdate)) < 0){//Le pasamos el rtcdate para que se rellene
80104cb0:	6a 18                	push   $0x18
80104cb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cb5:	50                   	push   %eax
80104cb6:	6a 00                	push   $0x0
80104cb8:	e8 3c f1 ff ff       	call   80103df9 <argptr>
80104cbd:	83 c4 10             	add    $0x10,%esp
80104cc0:	85 c0                	test   %eax,%eax
80104cc2:	78 15                	js     80104cd9 <sys_date+0x2f>
  return -1;
 }
 //Ahora una vez recuperado el arg -> Implementamos la syscall
 cmostime(d);//Esta función hace las veces de date
80104cc4:	83 ec 0c             	sub    $0xc,%esp
80104cc7:	ff 75 f4             	push   -0xc(%ebp)
80104cca:	e8 e6 d6 ff ff       	call   801023b5 <cmostime>
 return 0;
80104ccf:	83 c4 10             	add    $0x10,%esp
80104cd2:	b8 00 00 00 00       	mov    $0x0,%eax

}
80104cd7:	c9                   	leave  
80104cd8:	c3                   	ret    
  return -1;
80104cd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cde:	eb f7                	jmp    80104cd7 <sys_date+0x2d>

80104ce0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104ce0:	55                   	push   %ebp
80104ce1:	89 e5                	mov    %esp,%ebp
80104ce3:	53                   	push   %ebx
80104ce4:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104ce7:	68 80 3e 11 80       	push   $0x80113e80
80104cec:	e8 fe ed ff ff       	call   80103aef <acquire>
  xticks = ticks;
80104cf1:	8b 1d 60 3e 11 80    	mov    0x80113e60,%ebx
  release(&tickslock);
80104cf7:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
80104cfe:	e8 51 ee ff ff       	call   80103b54 <release>
  return xticks;
}
80104d03:	89 d8                	mov    %ebx,%eax
80104d05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d08:	c9                   	leave  
80104d09:	c3                   	ret    

80104d0a <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104d0a:	1e                   	push   %ds
  pushl %es
80104d0b:	06                   	push   %es
  pushl %fs
80104d0c:	0f a0                	push   %fs
  pushl %gs
80104d0e:	0f a8                	push   %gs
  pushal
80104d10:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104d11:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104d15:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104d17:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104d19:	54                   	push   %esp
  call trap
80104d1a:	e8 2f 01 00 00       	call   80104e4e <trap>
  addl $4, %esp
80104d1f:	83 c4 04             	add    $0x4,%esp

80104d22 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104d22:	61                   	popa   
  popl %gs
80104d23:	0f a9                	pop    %gs
  popl %fs
80104d25:	0f a1                	pop    %fs
  popl %es
80104d27:	07                   	pop    %es
  popl %ds
80104d28:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104d29:	83 c4 08             	add    $0x8,%esp
  iret
80104d2c:	cf                   	iret   

80104d2d <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104d2d:	55                   	push   %ebp
80104d2e:	89 e5                	mov    %esp,%ebp
80104d30:	53                   	push   %ebx
80104d31:	83 ec 04             	sub    $0x4,%esp
  int i;

  for(i = 0; i < 256; i++)
80104d34:	b8 00 00 00 00       	mov    $0x0,%eax
80104d39:	eb 72                	jmp    80104dad <tvinit+0x80>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104d3b:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80104d42:	66 89 0c c5 c0 3e 11 	mov    %cx,-0x7feec140(,%eax,8)
80104d49:	80 
80104d4a:	66 c7 04 c5 c2 3e 11 	movw   $0x8,-0x7feec13e(,%eax,8)
80104d51:	80 08 00 
80104d54:	8a 14 c5 c4 3e 11 80 	mov    -0x7feec13c(,%eax,8),%dl
80104d5b:	83 e2 e0             	and    $0xffffffe0,%edx
80104d5e:	88 14 c5 c4 3e 11 80 	mov    %dl,-0x7feec13c(,%eax,8)
80104d65:	c6 04 c5 c4 3e 11 80 	movb   $0x0,-0x7feec13c(,%eax,8)
80104d6c:	00 
80104d6d:	8a 14 c5 c5 3e 11 80 	mov    -0x7feec13b(,%eax,8),%dl
80104d74:	83 e2 f0             	and    $0xfffffff0,%edx
80104d77:	83 ca 0e             	or     $0xe,%edx
80104d7a:	88 14 c5 c5 3e 11 80 	mov    %dl,-0x7feec13b(,%eax,8)
80104d81:	88 d3                	mov    %dl,%bl
80104d83:	83 e3 ef             	and    $0xffffffef,%ebx
80104d86:	88 1c c5 c5 3e 11 80 	mov    %bl,-0x7feec13b(,%eax,8)
80104d8d:	83 e2 8f             	and    $0xffffff8f,%edx
80104d90:	88 14 c5 c5 3e 11 80 	mov    %dl,-0x7feec13b(,%eax,8)
80104d97:	83 ca 80             	or     $0xffffff80,%edx
80104d9a:	88 14 c5 c5 3e 11 80 	mov    %dl,-0x7feec13b(,%eax,8)
80104da1:	c1 e9 10             	shr    $0x10,%ecx
80104da4:	66 89 0c c5 c6 3e 11 	mov    %cx,-0x7feec13a(,%eax,8)
80104dab:	80 
  for(i = 0; i < 256; i++)
80104dac:	40                   	inc    %eax
80104dad:	3d ff 00 00 00       	cmp    $0xff,%eax
80104db2:	7e 87                	jle    80104d3b <tvinit+0xe>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104db4:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80104dba:	66 89 15 c0 40 11 80 	mov    %dx,0x801140c0
80104dc1:	66 c7 05 c2 40 11 80 	movw   $0x8,0x801140c2
80104dc8:	08 00 
80104dca:	a0 c4 40 11 80       	mov    0x801140c4,%al
80104dcf:	83 e0 e0             	and    $0xffffffe0,%eax
80104dd2:	a2 c4 40 11 80       	mov    %al,0x801140c4
80104dd7:	c6 05 c4 40 11 80 00 	movb   $0x0,0x801140c4
80104dde:	a0 c5 40 11 80       	mov    0x801140c5,%al
80104de3:	83 c8 0f             	or     $0xf,%eax
80104de6:	a2 c5 40 11 80       	mov    %al,0x801140c5
80104deb:	83 e0 ef             	and    $0xffffffef,%eax
80104dee:	a2 c5 40 11 80       	mov    %al,0x801140c5
80104df3:	88 c1                	mov    %al,%cl
80104df5:	83 c9 60             	or     $0x60,%ecx
80104df8:	88 0d c5 40 11 80    	mov    %cl,0x801140c5
80104dfe:	83 c8 e0             	or     $0xffffffe0,%eax
80104e01:	a2 c5 40 11 80       	mov    %al,0x801140c5
80104e06:	c1 ea 10             	shr    $0x10,%edx
80104e09:	66 89 15 c6 40 11 80 	mov    %dx,0x801140c6

  initlock(&tickslock, "time");
80104e10:	83 ec 08             	sub    $0x8,%esp
80104e13:	68 a1 6e 10 80       	push   $0x80106ea1
80104e18:	68 80 3e 11 80       	push   $0x80113e80
80104e1d:	e8 96 eb ff ff       	call   801039b8 <initlock>
}
80104e22:	83 c4 10             	add    $0x10,%esp
80104e25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e28:	c9                   	leave  
80104e29:	c3                   	ret    

80104e2a <idtinit>:

void
idtinit(void)
{
80104e2a:	55                   	push   %ebp
80104e2b:	89 e5                	mov    %esp,%ebp
80104e2d:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104e30:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104e36:	b8 c0 3e 11 80       	mov    $0x80113ec0,%eax
80104e3b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104e3f:	c1 e8 10             	shr    $0x10,%eax
80104e42:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104e46:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104e49:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104e4c:	c9                   	leave  
80104e4d:	c3                   	ret    

80104e4e <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80104e4e:	55                   	push   %ebp
80104e4f:	89 e5                	mov    %esp,%ebp
80104e51:	57                   	push   %edi
80104e52:	56                   	push   %esi
80104e53:	53                   	push   %ebx
80104e54:	83 ec 2c             	sub    $0x2c,%esp
80104e57:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int status = tf->trapno+1;
80104e5a:	8b 43 30             	mov    0x30(%ebx),%eax
80104e5d:	8d 78 01             	lea    0x1(%eax),%edi

  if(tf->trapno == T_SYSCALL){
80104e60:	83 f8 40             	cmp    $0x40,%eax
80104e63:	74 13                	je     80104e78 <trap+0x2a>
    if(myproc()->killed)
      exit(status);
    return;
  }

  switch(tf->trapno){
80104e65:	83 e8 0e             	sub    $0xe,%eax
80104e68:	83 f8 31             	cmp    $0x31,%eax
80104e6b:	0f 87 ee 01 00 00    	ja     8010505f <trap+0x211>
80104e71:	ff 24 85 84 6f 10 80 	jmp    *-0x7fef907c(,%eax,4)
    if(myproc()->killed)
80104e78:	e8 a9 e2 ff ff       	call   80103126 <myproc>
80104e7d:	83 78 2c 00          	cmpl   $0x0,0x2c(%eax)
80104e81:	75 2a                	jne    80104ead <trap+0x5f>
    myproc()->tf = tf;
80104e83:	e8 9e e2 ff ff       	call   80103126 <myproc>
80104e88:	89 58 20             	mov    %ebx,0x20(%eax)
    syscall();
80104e8b:	e8 05 f0 ff ff       	call   80103e95 <syscall>
    if(myproc()->killed)
80104e90:	e8 91 e2 ff ff       	call   80103126 <myproc>
80104e95:	83 78 2c 00          	cmpl   $0x0,0x2c(%eax)
80104e99:	0f 84 8a 00 00 00    	je     80104f29 <trap+0xdb>
      exit(status);
80104e9f:	83 ec 0c             	sub    $0xc,%esp
80104ea2:	57                   	push   %edi
80104ea3:	e8 2c e6 ff ff       	call   801034d4 <exit>
80104ea8:	83 c4 10             	add    $0x10,%esp
    return;
80104eab:	eb 7c                	jmp    80104f29 <trap+0xdb>
      exit(status);
80104ead:	83 ec 0c             	sub    $0xc,%esp
80104eb0:	57                   	push   %edi
80104eb1:	e8 1e e6 ff ff       	call   801034d4 <exit>
80104eb6:	83 c4 10             	add    $0x10,%esp
80104eb9:	eb c8                	jmp    80104e83 <trap+0x35>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80104ebb:	e8 35 e2 ff ff       	call   801030f5 <cpuid>
80104ec0:	85 c0                	test   %eax,%eax
80104ec2:	74 6d                	je     80104f31 <trap+0xe3>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80104ec4:	e8 37 d4 ff ff       	call   80102300 <lapiceoi>
  }//fin switch

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)     
80104ec9:	e8 58 e2 ff ff       	call   80103126 <myproc>
80104ece:	85 c0                	test   %eax,%eax
80104ed0:	74 1b                	je     80104eed <trap+0x9f>
80104ed2:	e8 4f e2 ff ff       	call   80103126 <myproc>
80104ed7:	83 78 2c 00          	cmpl   $0x0,0x2c(%eax)
80104edb:	74 10                	je     80104eed <trap+0x9f>
80104edd:	8b 43 3c             	mov    0x3c(%ebx),%eax
80104ee0:	83 e0 03             	and    $0x3,%eax
80104ee3:	66 83 f8 03          	cmp    $0x3,%ax
80104ee7:	0f 84 0a 02 00 00    	je     801050f7 <trap+0x2a9>
    exit(status);

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80104eed:	e8 34 e2 ff ff       	call   80103126 <myproc>
80104ef2:	85 c0                	test   %eax,%eax
80104ef4:	74 0f                	je     80104f05 <trap+0xb7>
80104ef6:	e8 2b e2 ff ff       	call   80103126 <myproc>
80104efb:	83 78 14 04          	cmpl   $0x4,0x14(%eax)
80104eff:	0f 84 03 02 00 00    	je     80105108 <trap+0x2ba>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104f05:	e8 1c e2 ff ff       	call   80103126 <myproc>
80104f0a:	85 c0                	test   %eax,%eax
80104f0c:	74 1b                	je     80104f29 <trap+0xdb>
80104f0e:	e8 13 e2 ff ff       	call   80103126 <myproc>
80104f13:	83 78 2c 00          	cmpl   $0x0,0x2c(%eax)
80104f17:	74 10                	je     80104f29 <trap+0xdb>
80104f19:	8b 43 3c             	mov    0x3c(%ebx),%eax
80104f1c:	83 e0 03             	and    $0x3,%eax
80104f1f:	66 83 f8 03          	cmp    $0x3,%ax
80104f23:	0f 84 f3 01 00 00    	je     8010511c <trap+0x2ce>
    exit(status);
}
80104f29:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104f2c:	5b                   	pop    %ebx
80104f2d:	5e                   	pop    %esi
80104f2e:	5f                   	pop    %edi
80104f2f:	5d                   	pop    %ebp
80104f30:	c3                   	ret    
      acquire(&tickslock);
80104f31:	83 ec 0c             	sub    $0xc,%esp
80104f34:	68 80 3e 11 80       	push   $0x80113e80
80104f39:	e8 b1 eb ff ff       	call   80103aef <acquire>
      ticks++;
80104f3e:	ff 05 60 3e 11 80    	incl   0x80113e60
      wakeup(&ticks);
80104f44:	c7 04 24 60 3e 11 80 	movl   $0x80113e60,(%esp)
80104f4b:	e8 0b e8 ff ff       	call   8010375b <wakeup>
      release(&tickslock);
80104f50:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
80104f57:	e8 f8 eb ff ff       	call   80103b54 <release>
80104f5c:	83 c4 10             	add    $0x10,%esp
80104f5f:	e9 60 ff ff ff       	jmp    80104ec4 <trap+0x76>
    ideintr();
80104f64:	e8 80 cd ff ff       	call   80101ce9 <ideintr>
    lapiceoi();
80104f69:	e8 92 d3 ff ff       	call   80102300 <lapiceoi>
    break;
80104f6e:	e9 56 ff ff ff       	jmp    80104ec9 <trap+0x7b>
    kbdintr();
80104f73:	e8 d2 d1 ff ff       	call   8010214a <kbdintr>
    lapiceoi();
80104f78:	e8 83 d3 ff ff       	call   80102300 <lapiceoi>
    break;
80104f7d:	e9 47 ff ff ff       	jmp    80104ec9 <trap+0x7b>
    uartintr();
80104f82:	e8 a2 02 00 00       	call   80105229 <uartintr>
    lapiceoi();
80104f87:	e8 74 d3 ff ff       	call   80102300 <lapiceoi>
    break;
80104f8c:	e9 38 ff ff ff       	jmp    80104ec9 <trap+0x7b>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80104f91:	8b 43 38             	mov    0x38(%ebx),%eax
80104f94:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            cpuid(), tf->cs, tf->eip);
80104f97:	8b 73 3c             	mov    0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80104f9a:	e8 56 e1 ff ff       	call   801030f5 <cpuid>
80104f9f:	ff 75 e4             	push   -0x1c(%ebp)
80104fa2:	0f b7 f6             	movzwl %si,%esi
80104fa5:	56                   	push   %esi
80104fa6:	50                   	push   %eax
80104fa7:	68 c4 6e 10 80       	push   $0x80106ec4
80104fac:	e8 29 b6 ff ff       	call   801005da <cprintf>
    lapiceoi();
80104fb1:	e8 4a d3 ff ff       	call   80102300 <lapiceoi>
    break;
80104fb6:	83 c4 10             	add    $0x10,%esp
80104fb9:	e9 0b ff ff ff       	jmp    80104ec9 <trap+0x7b>
		char *mem = kalloc();//Cojo la página física
80104fbe:	e8 6b d0 ff ff       	call   8010202e <kalloc>
80104fc3:	89 c6                	mov    %eax,%esi
		if(mem == 0)
80104fc5:	85 c0                	test   %eax,%eax
80104fc7:	74 54                	je     8010501d <trap+0x1cf>
		memset(mem, 3, PGSIZE);//Pongo todos los bytes de la página a 0
80104fc9:	83 ec 04             	sub    $0x4,%esp
80104fcc:	68 00 10 00 00       	push   $0x1000
80104fd1:	6a 03                	push   $0x3
80104fd3:	50                   	push   %eax
80104fd4:	e8 c2 eb ff ff       	call   80103b9b <memset>
  asm volatile("movl %%cr2,%0" : "=r" (val));
80104fd9:	0f 20 d0             	mov    %cr2,%eax
		if(mappages(myproc()->pgdir, (char *)PGROUNDDOWN(rcr2()), PGSIZE, V2P(mem), PTE_W | PTE_U) <0)
80104fdc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104fe1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80104fe4:	e8 3d e1 ff ff       	call   80103126 <myproc>
80104fe9:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
80104ff0:	81 c6 00 00 00 80    	add    $0x80000000,%esi
80104ff6:	56                   	push   %esi
80104ff7:	68 00 10 00 00       	push   $0x1000
80104ffc:	ff 75 e4             	push   -0x1c(%ebp)
80104fff:	ff 70 0c             	push   0xc(%eax)
80105002:	e8 ea 0f 00 00       	call   80105ff1 <mappages>
80105007:	83 c4 20             	add    $0x20,%esp
8010500a:	85 c0                	test   %eax,%eax
8010500c:	78 30                	js     8010503e <trap+0x1f0>
		myproc()->numpages++;
8010500e:	e8 13 e1 ff ff       	call   80103126 <myproc>
80105013:	8b 10                	mov    (%eax),%edx
80105015:	42                   	inc    %edx
80105016:	89 10                	mov    %edx,(%eax)
		break;
80105018:	e9 ac fe ff ff       	jmp    80104ec9 <trap+0x7b>
			cprintf("panic: kalloc didn't alloc page\n");
8010501d:	83 ec 0c             	sub    $0xc,%esp
80105020:	68 e8 6e 10 80       	push   $0x80106ee8
80105025:	e8 b0 b5 ff ff       	call   801005da <cprintf>
			myproc()->killed = 1;
8010502a:	e8 f7 e0 ff ff       	call   80103126 <myproc>
8010502f:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
			break;
80105036:	83 c4 10             	add    $0x10,%esp
80105039:	e9 8b fe ff ff       	jmp    80104ec9 <trap+0x7b>
			cprintf("mappages: out of memory\n");
8010503e:	83 ec 0c             	sub    $0xc,%esp
80105041:	68 a6 6e 10 80       	push   $0x80106ea6
80105046:	e8 8f b5 ff ff       	call   801005da <cprintf>
			myproc()->killed = 1;
8010504b:	e8 d6 e0 ff ff       	call   80103126 <myproc>
80105050:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
			break;
80105057:	83 c4 10             	add    $0x10,%esp
8010505a:	e9 6a fe ff ff       	jmp    80104ec9 <trap+0x7b>
		if(myproc() == 0 || (tf->cs&3) == 0){
8010505f:	e8 c2 e0 ff ff       	call   80103126 <myproc>
80105064:	85 c0                	test   %eax,%eax
80105066:	74 64                	je     801050cc <trap+0x27e>
80105068:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
8010506c:	74 5e                	je     801050cc <trap+0x27e>
8010506e:	0f 20 d0             	mov    %cr2,%eax
80105071:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    cprintf("_pid %d %s: trap %d err %d on cpu %d "
80105074:	8b 4b 38             	mov    0x38(%ebx),%ecx
80105077:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
8010507a:	e8 76 e0 ff ff       	call   801030f5 <cpuid>
8010507f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105082:	8b 53 34             	mov    0x34(%ebx),%edx
80105085:	89 55 dc             	mov    %edx,-0x24(%ebp)
80105088:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
8010508b:	e8 96 e0 ff ff       	call   80103126 <myproc>
80105090:	8d 48 74             	lea    0x74(%eax),%ecx
80105093:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80105096:	e8 8b e0 ff ff       	call   80103126 <myproc>
    cprintf("_pid %d %s: trap %d err %d on cpu %d "
8010509b:	ff 75 d4             	push   -0x2c(%ebp)
8010509e:	ff 75 e4             	push   -0x1c(%ebp)
801050a1:	ff 75 e0             	push   -0x20(%ebp)
801050a4:	ff 75 dc             	push   -0x24(%ebp)
801050a7:	56                   	push   %esi
801050a8:	ff 75 d8             	push   -0x28(%ebp)
801050ab:	ff 70 18             	push   0x18(%eax)
801050ae:	68 40 6f 10 80       	push   $0x80106f40
801050b3:	e8 22 b5 ff ff       	call   801005da <cprintf>
    myproc()->killed = 1;
801050b8:	83 c4 20             	add    $0x20,%esp
801050bb:	e8 66 e0 ff ff       	call   80103126 <myproc>
801050c0:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
801050c7:	e9 fd fd ff ff       	jmp    80104ec9 <trap+0x7b>
801050cc:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801050cf:	8b 73 38             	mov    0x38(%ebx),%esi
801050d2:	e8 1e e0 ff ff       	call   801030f5 <cpuid>
801050d7:	83 ec 0c             	sub    $0xc,%esp
801050da:	57                   	push   %edi
801050db:	56                   	push   %esi
801050dc:	50                   	push   %eax
801050dd:	ff 73 30             	push   0x30(%ebx)
801050e0:	68 0c 6f 10 80       	push   $0x80106f0c
801050e5:	e8 f0 b4 ff ff       	call   801005da <cprintf>
      panic("trap");
801050ea:	83 c4 14             	add    $0x14,%esp
801050ed:	68 bf 6e 10 80       	push   $0x80106ebf
801050f2:	e8 4a b2 ff ff       	call   80100341 <panic>
    exit(status);
801050f7:	83 ec 0c             	sub    $0xc,%esp
801050fa:	57                   	push   %edi
801050fb:	e8 d4 e3 ff ff       	call   801034d4 <exit>
80105100:	83 c4 10             	add    $0x10,%esp
80105103:	e9 e5 fd ff ff       	jmp    80104eed <trap+0x9f>
  if(myproc() && myproc()->state == RUNNING &&
80105108:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
8010510c:	0f 85 f3 fd ff ff    	jne    80104f05 <trap+0xb7>
    yield();
80105112:	e8 9b e4 ff ff       	call   801035b2 <yield>
80105117:	e9 e9 fd ff ff       	jmp    80104f05 <trap+0xb7>
    exit(status);
8010511c:	83 ec 0c             	sub    $0xc,%esp
8010511f:	57                   	push   %edi
80105120:	e8 af e3 ff ff       	call   801034d4 <exit>
80105125:	83 c4 10             	add    $0x10,%esp
80105128:	e9 fc fd ff ff       	jmp    80104f29 <trap+0xdb>

8010512d <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
8010512d:	83 3d c0 46 11 80 00 	cmpl   $0x0,0x801146c0
80105134:	74 14                	je     8010514a <uartgetc+0x1d>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105136:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010513b:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
8010513c:	a8 01                	test   $0x1,%al
8010513e:	74 10                	je     80105150 <uartgetc+0x23>
80105140:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105145:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105146:	0f b6 c0             	movzbl %al,%eax
80105149:	c3                   	ret    
    return -1;
8010514a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010514f:	c3                   	ret    
    return -1;
80105150:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105155:	c3                   	ret    

80105156 <uartputc>:
  if(!uart)
80105156:	83 3d c0 46 11 80 00 	cmpl   $0x0,0x801146c0
8010515d:	74 39                	je     80105198 <uartputc+0x42>
{
8010515f:	55                   	push   %ebp
80105160:	89 e5                	mov    %esp,%ebp
80105162:	53                   	push   %ebx
80105163:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105166:	bb 00 00 00 00       	mov    $0x0,%ebx
8010516b:	eb 0e                	jmp    8010517b <uartputc+0x25>
    microdelay(10);
8010516d:	83 ec 0c             	sub    $0xc,%esp
80105170:	6a 0a                	push   $0xa
80105172:	e8 aa d1 ff ff       	call   80102321 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105177:	43                   	inc    %ebx
80105178:	83 c4 10             	add    $0x10,%esp
8010517b:	83 fb 7f             	cmp    $0x7f,%ebx
8010517e:	7f 0a                	jg     8010518a <uartputc+0x34>
80105180:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105185:	ec                   	in     (%dx),%al
80105186:	a8 20                	test   $0x20,%al
80105188:	74 e3                	je     8010516d <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010518a:	8b 45 08             	mov    0x8(%ebp),%eax
8010518d:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105192:	ee                   	out    %al,(%dx)
}
80105193:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105196:	c9                   	leave  
80105197:	c3                   	ret    
80105198:	c3                   	ret    

80105199 <uartinit>:
{
80105199:	55                   	push   %ebp
8010519a:	89 e5                	mov    %esp,%ebp
8010519c:	56                   	push   %esi
8010519d:	53                   	push   %ebx
8010519e:	b1 00                	mov    $0x0,%cl
801051a0:	ba fa 03 00 00       	mov    $0x3fa,%edx
801051a5:	88 c8                	mov    %cl,%al
801051a7:	ee                   	out    %al,(%dx)
801051a8:	be fb 03 00 00       	mov    $0x3fb,%esi
801051ad:	b0 80                	mov    $0x80,%al
801051af:	89 f2                	mov    %esi,%edx
801051b1:	ee                   	out    %al,(%dx)
801051b2:	b0 0c                	mov    $0xc,%al
801051b4:	ba f8 03 00 00       	mov    $0x3f8,%edx
801051b9:	ee                   	out    %al,(%dx)
801051ba:	bb f9 03 00 00       	mov    $0x3f9,%ebx
801051bf:	88 c8                	mov    %cl,%al
801051c1:	89 da                	mov    %ebx,%edx
801051c3:	ee                   	out    %al,(%dx)
801051c4:	b0 03                	mov    $0x3,%al
801051c6:	89 f2                	mov    %esi,%edx
801051c8:	ee                   	out    %al,(%dx)
801051c9:	ba fc 03 00 00       	mov    $0x3fc,%edx
801051ce:	88 c8                	mov    %cl,%al
801051d0:	ee                   	out    %al,(%dx)
801051d1:	b0 01                	mov    $0x1,%al
801051d3:	89 da                	mov    %ebx,%edx
801051d5:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801051d6:	ba fd 03 00 00       	mov    $0x3fd,%edx
801051db:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801051dc:	3c ff                	cmp    $0xff,%al
801051de:	74 42                	je     80105222 <uartinit+0x89>
  uart = 1;
801051e0:	c7 05 c0 46 11 80 01 	movl   $0x1,0x801146c0
801051e7:	00 00 00 
801051ea:	ba fa 03 00 00       	mov    $0x3fa,%edx
801051ef:	ec                   	in     (%dx),%al
801051f0:	ba f8 03 00 00       	mov    $0x3f8,%edx
801051f5:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801051f6:	83 ec 08             	sub    $0x8,%esp
801051f9:	6a 00                	push   $0x0
801051fb:	6a 04                	push   $0x4
801051fd:	e8 ea cc ff ff       	call   80101eec <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105202:	83 c4 10             	add    $0x10,%esp
80105205:	bb 4c 70 10 80       	mov    $0x8010704c,%ebx
8010520a:	eb 10                	jmp    8010521c <uartinit+0x83>
    uartputc(*p);
8010520c:	83 ec 0c             	sub    $0xc,%esp
8010520f:	0f be c0             	movsbl %al,%eax
80105212:	50                   	push   %eax
80105213:	e8 3e ff ff ff       	call   80105156 <uartputc>
  for(p="xv6...\n"; *p; p++)
80105218:	43                   	inc    %ebx
80105219:	83 c4 10             	add    $0x10,%esp
8010521c:	8a 03                	mov    (%ebx),%al
8010521e:	84 c0                	test   %al,%al
80105220:	75 ea                	jne    8010520c <uartinit+0x73>
}
80105222:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105225:	5b                   	pop    %ebx
80105226:	5e                   	pop    %esi
80105227:	5d                   	pop    %ebp
80105228:	c3                   	ret    

80105229 <uartintr>:

void
uartintr(void)
{
80105229:	55                   	push   %ebp
8010522a:	89 e5                	mov    %esp,%ebp
8010522c:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
8010522f:	68 2d 51 10 80       	push   $0x8010512d
80105234:	e8 c6 b4 ff ff       	call   801006ff <consoleintr>
}
80105239:	83 c4 10             	add    $0x10,%esp
8010523c:	c9                   	leave  
8010523d:	c3                   	ret    

8010523e <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010523e:	6a 00                	push   $0x0
  pushl $0
80105240:	6a 00                	push   $0x0
  jmp alltraps
80105242:	e9 c3 fa ff ff       	jmp    80104d0a <alltraps>

80105247 <vector1>:
.globl vector1
vector1:
  pushl $0
80105247:	6a 00                	push   $0x0
  pushl $1
80105249:	6a 01                	push   $0x1
  jmp alltraps
8010524b:	e9 ba fa ff ff       	jmp    80104d0a <alltraps>

80105250 <vector2>:
.globl vector2
vector2:
  pushl $0
80105250:	6a 00                	push   $0x0
  pushl $2
80105252:	6a 02                	push   $0x2
  jmp alltraps
80105254:	e9 b1 fa ff ff       	jmp    80104d0a <alltraps>

80105259 <vector3>:
.globl vector3
vector3:
  pushl $0
80105259:	6a 00                	push   $0x0
  pushl $3
8010525b:	6a 03                	push   $0x3
  jmp alltraps
8010525d:	e9 a8 fa ff ff       	jmp    80104d0a <alltraps>

80105262 <vector4>:
.globl vector4
vector4:
  pushl $0
80105262:	6a 00                	push   $0x0
  pushl $4
80105264:	6a 04                	push   $0x4
  jmp alltraps
80105266:	e9 9f fa ff ff       	jmp    80104d0a <alltraps>

8010526b <vector5>:
.globl vector5
vector5:
  pushl $0
8010526b:	6a 00                	push   $0x0
  pushl $5
8010526d:	6a 05                	push   $0x5
  jmp alltraps
8010526f:	e9 96 fa ff ff       	jmp    80104d0a <alltraps>

80105274 <vector6>:
.globl vector6
vector6:
  pushl $0
80105274:	6a 00                	push   $0x0
  pushl $6
80105276:	6a 06                	push   $0x6
  jmp alltraps
80105278:	e9 8d fa ff ff       	jmp    80104d0a <alltraps>

8010527d <vector7>:
.globl vector7
vector7:
  pushl $0
8010527d:	6a 00                	push   $0x0
  pushl $7
8010527f:	6a 07                	push   $0x7
  jmp alltraps
80105281:	e9 84 fa ff ff       	jmp    80104d0a <alltraps>

80105286 <vector8>:
.globl vector8
vector8:
  pushl $8
80105286:	6a 08                	push   $0x8
  jmp alltraps
80105288:	e9 7d fa ff ff       	jmp    80104d0a <alltraps>

8010528d <vector9>:
.globl vector9
vector9:
  pushl $0
8010528d:	6a 00                	push   $0x0
  pushl $9
8010528f:	6a 09                	push   $0x9
  jmp alltraps
80105291:	e9 74 fa ff ff       	jmp    80104d0a <alltraps>

80105296 <vector10>:
.globl vector10
vector10:
  pushl $10
80105296:	6a 0a                	push   $0xa
  jmp alltraps
80105298:	e9 6d fa ff ff       	jmp    80104d0a <alltraps>

8010529d <vector11>:
.globl vector11
vector11:
  pushl $11
8010529d:	6a 0b                	push   $0xb
  jmp alltraps
8010529f:	e9 66 fa ff ff       	jmp    80104d0a <alltraps>

801052a4 <vector12>:
.globl vector12
vector12:
  pushl $12
801052a4:	6a 0c                	push   $0xc
  jmp alltraps
801052a6:	e9 5f fa ff ff       	jmp    80104d0a <alltraps>

801052ab <vector13>:
.globl vector13
vector13:
  pushl $13
801052ab:	6a 0d                	push   $0xd
  jmp alltraps
801052ad:	e9 58 fa ff ff       	jmp    80104d0a <alltraps>

801052b2 <vector14>:
.globl vector14
vector14:
  pushl $14
801052b2:	6a 0e                	push   $0xe
  jmp alltraps
801052b4:	e9 51 fa ff ff       	jmp    80104d0a <alltraps>

801052b9 <vector15>:
.globl vector15
vector15:
  pushl $0
801052b9:	6a 00                	push   $0x0
  pushl $15
801052bb:	6a 0f                	push   $0xf
  jmp alltraps
801052bd:	e9 48 fa ff ff       	jmp    80104d0a <alltraps>

801052c2 <vector16>:
.globl vector16
vector16:
  pushl $0
801052c2:	6a 00                	push   $0x0
  pushl $16
801052c4:	6a 10                	push   $0x10
  jmp alltraps
801052c6:	e9 3f fa ff ff       	jmp    80104d0a <alltraps>

801052cb <vector17>:
.globl vector17
vector17:
  pushl $17
801052cb:	6a 11                	push   $0x11
  jmp alltraps
801052cd:	e9 38 fa ff ff       	jmp    80104d0a <alltraps>

801052d2 <vector18>:
.globl vector18
vector18:
  pushl $0
801052d2:	6a 00                	push   $0x0
  pushl $18
801052d4:	6a 12                	push   $0x12
  jmp alltraps
801052d6:	e9 2f fa ff ff       	jmp    80104d0a <alltraps>

801052db <vector19>:
.globl vector19
vector19:
  pushl $0
801052db:	6a 00                	push   $0x0
  pushl $19
801052dd:	6a 13                	push   $0x13
  jmp alltraps
801052df:	e9 26 fa ff ff       	jmp    80104d0a <alltraps>

801052e4 <vector20>:
.globl vector20
vector20:
  pushl $0
801052e4:	6a 00                	push   $0x0
  pushl $20
801052e6:	6a 14                	push   $0x14
  jmp alltraps
801052e8:	e9 1d fa ff ff       	jmp    80104d0a <alltraps>

801052ed <vector21>:
.globl vector21
vector21:
  pushl $0
801052ed:	6a 00                	push   $0x0
  pushl $21
801052ef:	6a 15                	push   $0x15
  jmp alltraps
801052f1:	e9 14 fa ff ff       	jmp    80104d0a <alltraps>

801052f6 <vector22>:
.globl vector22
vector22:
  pushl $0
801052f6:	6a 00                	push   $0x0
  pushl $22
801052f8:	6a 16                	push   $0x16
  jmp alltraps
801052fa:	e9 0b fa ff ff       	jmp    80104d0a <alltraps>

801052ff <vector23>:
.globl vector23
vector23:
  pushl $0
801052ff:	6a 00                	push   $0x0
  pushl $23
80105301:	6a 17                	push   $0x17
  jmp alltraps
80105303:	e9 02 fa ff ff       	jmp    80104d0a <alltraps>

80105308 <vector24>:
.globl vector24
vector24:
  pushl $0
80105308:	6a 00                	push   $0x0
  pushl $24
8010530a:	6a 18                	push   $0x18
  jmp alltraps
8010530c:	e9 f9 f9 ff ff       	jmp    80104d0a <alltraps>

80105311 <vector25>:
.globl vector25
vector25:
  pushl $0
80105311:	6a 00                	push   $0x0
  pushl $25
80105313:	6a 19                	push   $0x19
  jmp alltraps
80105315:	e9 f0 f9 ff ff       	jmp    80104d0a <alltraps>

8010531a <vector26>:
.globl vector26
vector26:
  pushl $0
8010531a:	6a 00                	push   $0x0
  pushl $26
8010531c:	6a 1a                	push   $0x1a
  jmp alltraps
8010531e:	e9 e7 f9 ff ff       	jmp    80104d0a <alltraps>

80105323 <vector27>:
.globl vector27
vector27:
  pushl $0
80105323:	6a 00                	push   $0x0
  pushl $27
80105325:	6a 1b                	push   $0x1b
  jmp alltraps
80105327:	e9 de f9 ff ff       	jmp    80104d0a <alltraps>

8010532c <vector28>:
.globl vector28
vector28:
  pushl $0
8010532c:	6a 00                	push   $0x0
  pushl $28
8010532e:	6a 1c                	push   $0x1c
  jmp alltraps
80105330:	e9 d5 f9 ff ff       	jmp    80104d0a <alltraps>

80105335 <vector29>:
.globl vector29
vector29:
  pushl $0
80105335:	6a 00                	push   $0x0
  pushl $29
80105337:	6a 1d                	push   $0x1d
  jmp alltraps
80105339:	e9 cc f9 ff ff       	jmp    80104d0a <alltraps>

8010533e <vector30>:
.globl vector30
vector30:
  pushl $0
8010533e:	6a 00                	push   $0x0
  pushl $30
80105340:	6a 1e                	push   $0x1e
  jmp alltraps
80105342:	e9 c3 f9 ff ff       	jmp    80104d0a <alltraps>

80105347 <vector31>:
.globl vector31
vector31:
  pushl $0
80105347:	6a 00                	push   $0x0
  pushl $31
80105349:	6a 1f                	push   $0x1f
  jmp alltraps
8010534b:	e9 ba f9 ff ff       	jmp    80104d0a <alltraps>

80105350 <vector32>:
.globl vector32
vector32:
  pushl $0
80105350:	6a 00                	push   $0x0
  pushl $32
80105352:	6a 20                	push   $0x20
  jmp alltraps
80105354:	e9 b1 f9 ff ff       	jmp    80104d0a <alltraps>

80105359 <vector33>:
.globl vector33
vector33:
  pushl $0
80105359:	6a 00                	push   $0x0
  pushl $33
8010535b:	6a 21                	push   $0x21
  jmp alltraps
8010535d:	e9 a8 f9 ff ff       	jmp    80104d0a <alltraps>

80105362 <vector34>:
.globl vector34
vector34:
  pushl $0
80105362:	6a 00                	push   $0x0
  pushl $34
80105364:	6a 22                	push   $0x22
  jmp alltraps
80105366:	e9 9f f9 ff ff       	jmp    80104d0a <alltraps>

8010536b <vector35>:
.globl vector35
vector35:
  pushl $0
8010536b:	6a 00                	push   $0x0
  pushl $35
8010536d:	6a 23                	push   $0x23
  jmp alltraps
8010536f:	e9 96 f9 ff ff       	jmp    80104d0a <alltraps>

80105374 <vector36>:
.globl vector36
vector36:
  pushl $0
80105374:	6a 00                	push   $0x0
  pushl $36
80105376:	6a 24                	push   $0x24
  jmp alltraps
80105378:	e9 8d f9 ff ff       	jmp    80104d0a <alltraps>

8010537d <vector37>:
.globl vector37
vector37:
  pushl $0
8010537d:	6a 00                	push   $0x0
  pushl $37
8010537f:	6a 25                	push   $0x25
  jmp alltraps
80105381:	e9 84 f9 ff ff       	jmp    80104d0a <alltraps>

80105386 <vector38>:
.globl vector38
vector38:
  pushl $0
80105386:	6a 00                	push   $0x0
  pushl $38
80105388:	6a 26                	push   $0x26
  jmp alltraps
8010538a:	e9 7b f9 ff ff       	jmp    80104d0a <alltraps>

8010538f <vector39>:
.globl vector39
vector39:
  pushl $0
8010538f:	6a 00                	push   $0x0
  pushl $39
80105391:	6a 27                	push   $0x27
  jmp alltraps
80105393:	e9 72 f9 ff ff       	jmp    80104d0a <alltraps>

80105398 <vector40>:
.globl vector40
vector40:
  pushl $0
80105398:	6a 00                	push   $0x0
  pushl $40
8010539a:	6a 28                	push   $0x28
  jmp alltraps
8010539c:	e9 69 f9 ff ff       	jmp    80104d0a <alltraps>

801053a1 <vector41>:
.globl vector41
vector41:
  pushl $0
801053a1:	6a 00                	push   $0x0
  pushl $41
801053a3:	6a 29                	push   $0x29
  jmp alltraps
801053a5:	e9 60 f9 ff ff       	jmp    80104d0a <alltraps>

801053aa <vector42>:
.globl vector42
vector42:
  pushl $0
801053aa:	6a 00                	push   $0x0
  pushl $42
801053ac:	6a 2a                	push   $0x2a
  jmp alltraps
801053ae:	e9 57 f9 ff ff       	jmp    80104d0a <alltraps>

801053b3 <vector43>:
.globl vector43
vector43:
  pushl $0
801053b3:	6a 00                	push   $0x0
  pushl $43
801053b5:	6a 2b                	push   $0x2b
  jmp alltraps
801053b7:	e9 4e f9 ff ff       	jmp    80104d0a <alltraps>

801053bc <vector44>:
.globl vector44
vector44:
  pushl $0
801053bc:	6a 00                	push   $0x0
  pushl $44
801053be:	6a 2c                	push   $0x2c
  jmp alltraps
801053c0:	e9 45 f9 ff ff       	jmp    80104d0a <alltraps>

801053c5 <vector45>:
.globl vector45
vector45:
  pushl $0
801053c5:	6a 00                	push   $0x0
  pushl $45
801053c7:	6a 2d                	push   $0x2d
  jmp alltraps
801053c9:	e9 3c f9 ff ff       	jmp    80104d0a <alltraps>

801053ce <vector46>:
.globl vector46
vector46:
  pushl $0
801053ce:	6a 00                	push   $0x0
  pushl $46
801053d0:	6a 2e                	push   $0x2e
  jmp alltraps
801053d2:	e9 33 f9 ff ff       	jmp    80104d0a <alltraps>

801053d7 <vector47>:
.globl vector47
vector47:
  pushl $0
801053d7:	6a 00                	push   $0x0
  pushl $47
801053d9:	6a 2f                	push   $0x2f
  jmp alltraps
801053db:	e9 2a f9 ff ff       	jmp    80104d0a <alltraps>

801053e0 <vector48>:
.globl vector48
vector48:
  pushl $0
801053e0:	6a 00                	push   $0x0
  pushl $48
801053e2:	6a 30                	push   $0x30
  jmp alltraps
801053e4:	e9 21 f9 ff ff       	jmp    80104d0a <alltraps>

801053e9 <vector49>:
.globl vector49
vector49:
  pushl $0
801053e9:	6a 00                	push   $0x0
  pushl $49
801053eb:	6a 31                	push   $0x31
  jmp alltraps
801053ed:	e9 18 f9 ff ff       	jmp    80104d0a <alltraps>

801053f2 <vector50>:
.globl vector50
vector50:
  pushl $0
801053f2:	6a 00                	push   $0x0
  pushl $50
801053f4:	6a 32                	push   $0x32
  jmp alltraps
801053f6:	e9 0f f9 ff ff       	jmp    80104d0a <alltraps>

801053fb <vector51>:
.globl vector51
vector51:
  pushl $0
801053fb:	6a 00                	push   $0x0
  pushl $51
801053fd:	6a 33                	push   $0x33
  jmp alltraps
801053ff:	e9 06 f9 ff ff       	jmp    80104d0a <alltraps>

80105404 <vector52>:
.globl vector52
vector52:
  pushl $0
80105404:	6a 00                	push   $0x0
  pushl $52
80105406:	6a 34                	push   $0x34
  jmp alltraps
80105408:	e9 fd f8 ff ff       	jmp    80104d0a <alltraps>

8010540d <vector53>:
.globl vector53
vector53:
  pushl $0
8010540d:	6a 00                	push   $0x0
  pushl $53
8010540f:	6a 35                	push   $0x35
  jmp alltraps
80105411:	e9 f4 f8 ff ff       	jmp    80104d0a <alltraps>

80105416 <vector54>:
.globl vector54
vector54:
  pushl $0
80105416:	6a 00                	push   $0x0
  pushl $54
80105418:	6a 36                	push   $0x36
  jmp alltraps
8010541a:	e9 eb f8 ff ff       	jmp    80104d0a <alltraps>

8010541f <vector55>:
.globl vector55
vector55:
  pushl $0
8010541f:	6a 00                	push   $0x0
  pushl $55
80105421:	6a 37                	push   $0x37
  jmp alltraps
80105423:	e9 e2 f8 ff ff       	jmp    80104d0a <alltraps>

80105428 <vector56>:
.globl vector56
vector56:
  pushl $0
80105428:	6a 00                	push   $0x0
  pushl $56
8010542a:	6a 38                	push   $0x38
  jmp alltraps
8010542c:	e9 d9 f8 ff ff       	jmp    80104d0a <alltraps>

80105431 <vector57>:
.globl vector57
vector57:
  pushl $0
80105431:	6a 00                	push   $0x0
  pushl $57
80105433:	6a 39                	push   $0x39
  jmp alltraps
80105435:	e9 d0 f8 ff ff       	jmp    80104d0a <alltraps>

8010543a <vector58>:
.globl vector58
vector58:
  pushl $0
8010543a:	6a 00                	push   $0x0
  pushl $58
8010543c:	6a 3a                	push   $0x3a
  jmp alltraps
8010543e:	e9 c7 f8 ff ff       	jmp    80104d0a <alltraps>

80105443 <vector59>:
.globl vector59
vector59:
  pushl $0
80105443:	6a 00                	push   $0x0
  pushl $59
80105445:	6a 3b                	push   $0x3b
  jmp alltraps
80105447:	e9 be f8 ff ff       	jmp    80104d0a <alltraps>

8010544c <vector60>:
.globl vector60
vector60:
  pushl $0
8010544c:	6a 00                	push   $0x0
  pushl $60
8010544e:	6a 3c                	push   $0x3c
  jmp alltraps
80105450:	e9 b5 f8 ff ff       	jmp    80104d0a <alltraps>

80105455 <vector61>:
.globl vector61
vector61:
  pushl $0
80105455:	6a 00                	push   $0x0
  pushl $61
80105457:	6a 3d                	push   $0x3d
  jmp alltraps
80105459:	e9 ac f8 ff ff       	jmp    80104d0a <alltraps>

8010545e <vector62>:
.globl vector62
vector62:
  pushl $0
8010545e:	6a 00                	push   $0x0
  pushl $62
80105460:	6a 3e                	push   $0x3e
  jmp alltraps
80105462:	e9 a3 f8 ff ff       	jmp    80104d0a <alltraps>

80105467 <vector63>:
.globl vector63
vector63:
  pushl $0
80105467:	6a 00                	push   $0x0
  pushl $63
80105469:	6a 3f                	push   $0x3f
  jmp alltraps
8010546b:	e9 9a f8 ff ff       	jmp    80104d0a <alltraps>

80105470 <vector64>:
.globl vector64
vector64:
  pushl $0
80105470:	6a 00                	push   $0x0
  pushl $64
80105472:	6a 40                	push   $0x40
  jmp alltraps
80105474:	e9 91 f8 ff ff       	jmp    80104d0a <alltraps>

80105479 <vector65>:
.globl vector65
vector65:
  pushl $0
80105479:	6a 00                	push   $0x0
  pushl $65
8010547b:	6a 41                	push   $0x41
  jmp alltraps
8010547d:	e9 88 f8 ff ff       	jmp    80104d0a <alltraps>

80105482 <vector66>:
.globl vector66
vector66:
  pushl $0
80105482:	6a 00                	push   $0x0
  pushl $66
80105484:	6a 42                	push   $0x42
  jmp alltraps
80105486:	e9 7f f8 ff ff       	jmp    80104d0a <alltraps>

8010548b <vector67>:
.globl vector67
vector67:
  pushl $0
8010548b:	6a 00                	push   $0x0
  pushl $67
8010548d:	6a 43                	push   $0x43
  jmp alltraps
8010548f:	e9 76 f8 ff ff       	jmp    80104d0a <alltraps>

80105494 <vector68>:
.globl vector68
vector68:
  pushl $0
80105494:	6a 00                	push   $0x0
  pushl $68
80105496:	6a 44                	push   $0x44
  jmp alltraps
80105498:	e9 6d f8 ff ff       	jmp    80104d0a <alltraps>

8010549d <vector69>:
.globl vector69
vector69:
  pushl $0
8010549d:	6a 00                	push   $0x0
  pushl $69
8010549f:	6a 45                	push   $0x45
  jmp alltraps
801054a1:	e9 64 f8 ff ff       	jmp    80104d0a <alltraps>

801054a6 <vector70>:
.globl vector70
vector70:
  pushl $0
801054a6:	6a 00                	push   $0x0
  pushl $70
801054a8:	6a 46                	push   $0x46
  jmp alltraps
801054aa:	e9 5b f8 ff ff       	jmp    80104d0a <alltraps>

801054af <vector71>:
.globl vector71
vector71:
  pushl $0
801054af:	6a 00                	push   $0x0
  pushl $71
801054b1:	6a 47                	push   $0x47
  jmp alltraps
801054b3:	e9 52 f8 ff ff       	jmp    80104d0a <alltraps>

801054b8 <vector72>:
.globl vector72
vector72:
  pushl $0
801054b8:	6a 00                	push   $0x0
  pushl $72
801054ba:	6a 48                	push   $0x48
  jmp alltraps
801054bc:	e9 49 f8 ff ff       	jmp    80104d0a <alltraps>

801054c1 <vector73>:
.globl vector73
vector73:
  pushl $0
801054c1:	6a 00                	push   $0x0
  pushl $73
801054c3:	6a 49                	push   $0x49
  jmp alltraps
801054c5:	e9 40 f8 ff ff       	jmp    80104d0a <alltraps>

801054ca <vector74>:
.globl vector74
vector74:
  pushl $0
801054ca:	6a 00                	push   $0x0
  pushl $74
801054cc:	6a 4a                	push   $0x4a
  jmp alltraps
801054ce:	e9 37 f8 ff ff       	jmp    80104d0a <alltraps>

801054d3 <vector75>:
.globl vector75
vector75:
  pushl $0
801054d3:	6a 00                	push   $0x0
  pushl $75
801054d5:	6a 4b                	push   $0x4b
  jmp alltraps
801054d7:	e9 2e f8 ff ff       	jmp    80104d0a <alltraps>

801054dc <vector76>:
.globl vector76
vector76:
  pushl $0
801054dc:	6a 00                	push   $0x0
  pushl $76
801054de:	6a 4c                	push   $0x4c
  jmp alltraps
801054e0:	e9 25 f8 ff ff       	jmp    80104d0a <alltraps>

801054e5 <vector77>:
.globl vector77
vector77:
  pushl $0
801054e5:	6a 00                	push   $0x0
  pushl $77
801054e7:	6a 4d                	push   $0x4d
  jmp alltraps
801054e9:	e9 1c f8 ff ff       	jmp    80104d0a <alltraps>

801054ee <vector78>:
.globl vector78
vector78:
  pushl $0
801054ee:	6a 00                	push   $0x0
  pushl $78
801054f0:	6a 4e                	push   $0x4e
  jmp alltraps
801054f2:	e9 13 f8 ff ff       	jmp    80104d0a <alltraps>

801054f7 <vector79>:
.globl vector79
vector79:
  pushl $0
801054f7:	6a 00                	push   $0x0
  pushl $79
801054f9:	6a 4f                	push   $0x4f
  jmp alltraps
801054fb:	e9 0a f8 ff ff       	jmp    80104d0a <alltraps>

80105500 <vector80>:
.globl vector80
vector80:
  pushl $0
80105500:	6a 00                	push   $0x0
  pushl $80
80105502:	6a 50                	push   $0x50
  jmp alltraps
80105504:	e9 01 f8 ff ff       	jmp    80104d0a <alltraps>

80105509 <vector81>:
.globl vector81
vector81:
  pushl $0
80105509:	6a 00                	push   $0x0
  pushl $81
8010550b:	6a 51                	push   $0x51
  jmp alltraps
8010550d:	e9 f8 f7 ff ff       	jmp    80104d0a <alltraps>

80105512 <vector82>:
.globl vector82
vector82:
  pushl $0
80105512:	6a 00                	push   $0x0
  pushl $82
80105514:	6a 52                	push   $0x52
  jmp alltraps
80105516:	e9 ef f7 ff ff       	jmp    80104d0a <alltraps>

8010551b <vector83>:
.globl vector83
vector83:
  pushl $0
8010551b:	6a 00                	push   $0x0
  pushl $83
8010551d:	6a 53                	push   $0x53
  jmp alltraps
8010551f:	e9 e6 f7 ff ff       	jmp    80104d0a <alltraps>

80105524 <vector84>:
.globl vector84
vector84:
  pushl $0
80105524:	6a 00                	push   $0x0
  pushl $84
80105526:	6a 54                	push   $0x54
  jmp alltraps
80105528:	e9 dd f7 ff ff       	jmp    80104d0a <alltraps>

8010552d <vector85>:
.globl vector85
vector85:
  pushl $0
8010552d:	6a 00                	push   $0x0
  pushl $85
8010552f:	6a 55                	push   $0x55
  jmp alltraps
80105531:	e9 d4 f7 ff ff       	jmp    80104d0a <alltraps>

80105536 <vector86>:
.globl vector86
vector86:
  pushl $0
80105536:	6a 00                	push   $0x0
  pushl $86
80105538:	6a 56                	push   $0x56
  jmp alltraps
8010553a:	e9 cb f7 ff ff       	jmp    80104d0a <alltraps>

8010553f <vector87>:
.globl vector87
vector87:
  pushl $0
8010553f:	6a 00                	push   $0x0
  pushl $87
80105541:	6a 57                	push   $0x57
  jmp alltraps
80105543:	e9 c2 f7 ff ff       	jmp    80104d0a <alltraps>

80105548 <vector88>:
.globl vector88
vector88:
  pushl $0
80105548:	6a 00                	push   $0x0
  pushl $88
8010554a:	6a 58                	push   $0x58
  jmp alltraps
8010554c:	e9 b9 f7 ff ff       	jmp    80104d0a <alltraps>

80105551 <vector89>:
.globl vector89
vector89:
  pushl $0
80105551:	6a 00                	push   $0x0
  pushl $89
80105553:	6a 59                	push   $0x59
  jmp alltraps
80105555:	e9 b0 f7 ff ff       	jmp    80104d0a <alltraps>

8010555a <vector90>:
.globl vector90
vector90:
  pushl $0
8010555a:	6a 00                	push   $0x0
  pushl $90
8010555c:	6a 5a                	push   $0x5a
  jmp alltraps
8010555e:	e9 a7 f7 ff ff       	jmp    80104d0a <alltraps>

80105563 <vector91>:
.globl vector91
vector91:
  pushl $0
80105563:	6a 00                	push   $0x0
  pushl $91
80105565:	6a 5b                	push   $0x5b
  jmp alltraps
80105567:	e9 9e f7 ff ff       	jmp    80104d0a <alltraps>

8010556c <vector92>:
.globl vector92
vector92:
  pushl $0
8010556c:	6a 00                	push   $0x0
  pushl $92
8010556e:	6a 5c                	push   $0x5c
  jmp alltraps
80105570:	e9 95 f7 ff ff       	jmp    80104d0a <alltraps>

80105575 <vector93>:
.globl vector93
vector93:
  pushl $0
80105575:	6a 00                	push   $0x0
  pushl $93
80105577:	6a 5d                	push   $0x5d
  jmp alltraps
80105579:	e9 8c f7 ff ff       	jmp    80104d0a <alltraps>

8010557e <vector94>:
.globl vector94
vector94:
  pushl $0
8010557e:	6a 00                	push   $0x0
  pushl $94
80105580:	6a 5e                	push   $0x5e
  jmp alltraps
80105582:	e9 83 f7 ff ff       	jmp    80104d0a <alltraps>

80105587 <vector95>:
.globl vector95
vector95:
  pushl $0
80105587:	6a 00                	push   $0x0
  pushl $95
80105589:	6a 5f                	push   $0x5f
  jmp alltraps
8010558b:	e9 7a f7 ff ff       	jmp    80104d0a <alltraps>

80105590 <vector96>:
.globl vector96
vector96:
  pushl $0
80105590:	6a 00                	push   $0x0
  pushl $96
80105592:	6a 60                	push   $0x60
  jmp alltraps
80105594:	e9 71 f7 ff ff       	jmp    80104d0a <alltraps>

80105599 <vector97>:
.globl vector97
vector97:
  pushl $0
80105599:	6a 00                	push   $0x0
  pushl $97
8010559b:	6a 61                	push   $0x61
  jmp alltraps
8010559d:	e9 68 f7 ff ff       	jmp    80104d0a <alltraps>

801055a2 <vector98>:
.globl vector98
vector98:
  pushl $0
801055a2:	6a 00                	push   $0x0
  pushl $98
801055a4:	6a 62                	push   $0x62
  jmp alltraps
801055a6:	e9 5f f7 ff ff       	jmp    80104d0a <alltraps>

801055ab <vector99>:
.globl vector99
vector99:
  pushl $0
801055ab:	6a 00                	push   $0x0
  pushl $99
801055ad:	6a 63                	push   $0x63
  jmp alltraps
801055af:	e9 56 f7 ff ff       	jmp    80104d0a <alltraps>

801055b4 <vector100>:
.globl vector100
vector100:
  pushl $0
801055b4:	6a 00                	push   $0x0
  pushl $100
801055b6:	6a 64                	push   $0x64
  jmp alltraps
801055b8:	e9 4d f7 ff ff       	jmp    80104d0a <alltraps>

801055bd <vector101>:
.globl vector101
vector101:
  pushl $0
801055bd:	6a 00                	push   $0x0
  pushl $101
801055bf:	6a 65                	push   $0x65
  jmp alltraps
801055c1:	e9 44 f7 ff ff       	jmp    80104d0a <alltraps>

801055c6 <vector102>:
.globl vector102
vector102:
  pushl $0
801055c6:	6a 00                	push   $0x0
  pushl $102
801055c8:	6a 66                	push   $0x66
  jmp alltraps
801055ca:	e9 3b f7 ff ff       	jmp    80104d0a <alltraps>

801055cf <vector103>:
.globl vector103
vector103:
  pushl $0
801055cf:	6a 00                	push   $0x0
  pushl $103
801055d1:	6a 67                	push   $0x67
  jmp alltraps
801055d3:	e9 32 f7 ff ff       	jmp    80104d0a <alltraps>

801055d8 <vector104>:
.globl vector104
vector104:
  pushl $0
801055d8:	6a 00                	push   $0x0
  pushl $104
801055da:	6a 68                	push   $0x68
  jmp alltraps
801055dc:	e9 29 f7 ff ff       	jmp    80104d0a <alltraps>

801055e1 <vector105>:
.globl vector105
vector105:
  pushl $0
801055e1:	6a 00                	push   $0x0
  pushl $105
801055e3:	6a 69                	push   $0x69
  jmp alltraps
801055e5:	e9 20 f7 ff ff       	jmp    80104d0a <alltraps>

801055ea <vector106>:
.globl vector106
vector106:
  pushl $0
801055ea:	6a 00                	push   $0x0
  pushl $106
801055ec:	6a 6a                	push   $0x6a
  jmp alltraps
801055ee:	e9 17 f7 ff ff       	jmp    80104d0a <alltraps>

801055f3 <vector107>:
.globl vector107
vector107:
  pushl $0
801055f3:	6a 00                	push   $0x0
  pushl $107
801055f5:	6a 6b                	push   $0x6b
  jmp alltraps
801055f7:	e9 0e f7 ff ff       	jmp    80104d0a <alltraps>

801055fc <vector108>:
.globl vector108
vector108:
  pushl $0
801055fc:	6a 00                	push   $0x0
  pushl $108
801055fe:	6a 6c                	push   $0x6c
  jmp alltraps
80105600:	e9 05 f7 ff ff       	jmp    80104d0a <alltraps>

80105605 <vector109>:
.globl vector109
vector109:
  pushl $0
80105605:	6a 00                	push   $0x0
  pushl $109
80105607:	6a 6d                	push   $0x6d
  jmp alltraps
80105609:	e9 fc f6 ff ff       	jmp    80104d0a <alltraps>

8010560e <vector110>:
.globl vector110
vector110:
  pushl $0
8010560e:	6a 00                	push   $0x0
  pushl $110
80105610:	6a 6e                	push   $0x6e
  jmp alltraps
80105612:	e9 f3 f6 ff ff       	jmp    80104d0a <alltraps>

80105617 <vector111>:
.globl vector111
vector111:
  pushl $0
80105617:	6a 00                	push   $0x0
  pushl $111
80105619:	6a 6f                	push   $0x6f
  jmp alltraps
8010561b:	e9 ea f6 ff ff       	jmp    80104d0a <alltraps>

80105620 <vector112>:
.globl vector112
vector112:
  pushl $0
80105620:	6a 00                	push   $0x0
  pushl $112
80105622:	6a 70                	push   $0x70
  jmp alltraps
80105624:	e9 e1 f6 ff ff       	jmp    80104d0a <alltraps>

80105629 <vector113>:
.globl vector113
vector113:
  pushl $0
80105629:	6a 00                	push   $0x0
  pushl $113
8010562b:	6a 71                	push   $0x71
  jmp alltraps
8010562d:	e9 d8 f6 ff ff       	jmp    80104d0a <alltraps>

80105632 <vector114>:
.globl vector114
vector114:
  pushl $0
80105632:	6a 00                	push   $0x0
  pushl $114
80105634:	6a 72                	push   $0x72
  jmp alltraps
80105636:	e9 cf f6 ff ff       	jmp    80104d0a <alltraps>

8010563b <vector115>:
.globl vector115
vector115:
  pushl $0
8010563b:	6a 00                	push   $0x0
  pushl $115
8010563d:	6a 73                	push   $0x73
  jmp alltraps
8010563f:	e9 c6 f6 ff ff       	jmp    80104d0a <alltraps>

80105644 <vector116>:
.globl vector116
vector116:
  pushl $0
80105644:	6a 00                	push   $0x0
  pushl $116
80105646:	6a 74                	push   $0x74
  jmp alltraps
80105648:	e9 bd f6 ff ff       	jmp    80104d0a <alltraps>

8010564d <vector117>:
.globl vector117
vector117:
  pushl $0
8010564d:	6a 00                	push   $0x0
  pushl $117
8010564f:	6a 75                	push   $0x75
  jmp alltraps
80105651:	e9 b4 f6 ff ff       	jmp    80104d0a <alltraps>

80105656 <vector118>:
.globl vector118
vector118:
  pushl $0
80105656:	6a 00                	push   $0x0
  pushl $118
80105658:	6a 76                	push   $0x76
  jmp alltraps
8010565a:	e9 ab f6 ff ff       	jmp    80104d0a <alltraps>

8010565f <vector119>:
.globl vector119
vector119:
  pushl $0
8010565f:	6a 00                	push   $0x0
  pushl $119
80105661:	6a 77                	push   $0x77
  jmp alltraps
80105663:	e9 a2 f6 ff ff       	jmp    80104d0a <alltraps>

80105668 <vector120>:
.globl vector120
vector120:
  pushl $0
80105668:	6a 00                	push   $0x0
  pushl $120
8010566a:	6a 78                	push   $0x78
  jmp alltraps
8010566c:	e9 99 f6 ff ff       	jmp    80104d0a <alltraps>

80105671 <vector121>:
.globl vector121
vector121:
  pushl $0
80105671:	6a 00                	push   $0x0
  pushl $121
80105673:	6a 79                	push   $0x79
  jmp alltraps
80105675:	e9 90 f6 ff ff       	jmp    80104d0a <alltraps>

8010567a <vector122>:
.globl vector122
vector122:
  pushl $0
8010567a:	6a 00                	push   $0x0
  pushl $122
8010567c:	6a 7a                	push   $0x7a
  jmp alltraps
8010567e:	e9 87 f6 ff ff       	jmp    80104d0a <alltraps>

80105683 <vector123>:
.globl vector123
vector123:
  pushl $0
80105683:	6a 00                	push   $0x0
  pushl $123
80105685:	6a 7b                	push   $0x7b
  jmp alltraps
80105687:	e9 7e f6 ff ff       	jmp    80104d0a <alltraps>

8010568c <vector124>:
.globl vector124
vector124:
  pushl $0
8010568c:	6a 00                	push   $0x0
  pushl $124
8010568e:	6a 7c                	push   $0x7c
  jmp alltraps
80105690:	e9 75 f6 ff ff       	jmp    80104d0a <alltraps>

80105695 <vector125>:
.globl vector125
vector125:
  pushl $0
80105695:	6a 00                	push   $0x0
  pushl $125
80105697:	6a 7d                	push   $0x7d
  jmp alltraps
80105699:	e9 6c f6 ff ff       	jmp    80104d0a <alltraps>

8010569e <vector126>:
.globl vector126
vector126:
  pushl $0
8010569e:	6a 00                	push   $0x0
  pushl $126
801056a0:	6a 7e                	push   $0x7e
  jmp alltraps
801056a2:	e9 63 f6 ff ff       	jmp    80104d0a <alltraps>

801056a7 <vector127>:
.globl vector127
vector127:
  pushl $0
801056a7:	6a 00                	push   $0x0
  pushl $127
801056a9:	6a 7f                	push   $0x7f
  jmp alltraps
801056ab:	e9 5a f6 ff ff       	jmp    80104d0a <alltraps>

801056b0 <vector128>:
.globl vector128
vector128:
  pushl $0
801056b0:	6a 00                	push   $0x0
  pushl $128
801056b2:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801056b7:	e9 4e f6 ff ff       	jmp    80104d0a <alltraps>

801056bc <vector129>:
.globl vector129
vector129:
  pushl $0
801056bc:	6a 00                	push   $0x0
  pushl $129
801056be:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801056c3:	e9 42 f6 ff ff       	jmp    80104d0a <alltraps>

801056c8 <vector130>:
.globl vector130
vector130:
  pushl $0
801056c8:	6a 00                	push   $0x0
  pushl $130
801056ca:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801056cf:	e9 36 f6 ff ff       	jmp    80104d0a <alltraps>

801056d4 <vector131>:
.globl vector131
vector131:
  pushl $0
801056d4:	6a 00                	push   $0x0
  pushl $131
801056d6:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801056db:	e9 2a f6 ff ff       	jmp    80104d0a <alltraps>

801056e0 <vector132>:
.globl vector132
vector132:
  pushl $0
801056e0:	6a 00                	push   $0x0
  pushl $132
801056e2:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801056e7:	e9 1e f6 ff ff       	jmp    80104d0a <alltraps>

801056ec <vector133>:
.globl vector133
vector133:
  pushl $0
801056ec:	6a 00                	push   $0x0
  pushl $133
801056ee:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801056f3:	e9 12 f6 ff ff       	jmp    80104d0a <alltraps>

801056f8 <vector134>:
.globl vector134
vector134:
  pushl $0
801056f8:	6a 00                	push   $0x0
  pushl $134
801056fa:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801056ff:	e9 06 f6 ff ff       	jmp    80104d0a <alltraps>

80105704 <vector135>:
.globl vector135
vector135:
  pushl $0
80105704:	6a 00                	push   $0x0
  pushl $135
80105706:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010570b:	e9 fa f5 ff ff       	jmp    80104d0a <alltraps>

80105710 <vector136>:
.globl vector136
vector136:
  pushl $0
80105710:	6a 00                	push   $0x0
  pushl $136
80105712:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80105717:	e9 ee f5 ff ff       	jmp    80104d0a <alltraps>

8010571c <vector137>:
.globl vector137
vector137:
  pushl $0
8010571c:	6a 00                	push   $0x0
  pushl $137
8010571e:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80105723:	e9 e2 f5 ff ff       	jmp    80104d0a <alltraps>

80105728 <vector138>:
.globl vector138
vector138:
  pushl $0
80105728:	6a 00                	push   $0x0
  pushl $138
8010572a:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010572f:	e9 d6 f5 ff ff       	jmp    80104d0a <alltraps>

80105734 <vector139>:
.globl vector139
vector139:
  pushl $0
80105734:	6a 00                	push   $0x0
  pushl $139
80105736:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010573b:	e9 ca f5 ff ff       	jmp    80104d0a <alltraps>

80105740 <vector140>:
.globl vector140
vector140:
  pushl $0
80105740:	6a 00                	push   $0x0
  pushl $140
80105742:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80105747:	e9 be f5 ff ff       	jmp    80104d0a <alltraps>

8010574c <vector141>:
.globl vector141
vector141:
  pushl $0
8010574c:	6a 00                	push   $0x0
  pushl $141
8010574e:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105753:	e9 b2 f5 ff ff       	jmp    80104d0a <alltraps>

80105758 <vector142>:
.globl vector142
vector142:
  pushl $0
80105758:	6a 00                	push   $0x0
  pushl $142
8010575a:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010575f:	e9 a6 f5 ff ff       	jmp    80104d0a <alltraps>

80105764 <vector143>:
.globl vector143
vector143:
  pushl $0
80105764:	6a 00                	push   $0x0
  pushl $143
80105766:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010576b:	e9 9a f5 ff ff       	jmp    80104d0a <alltraps>

80105770 <vector144>:
.globl vector144
vector144:
  pushl $0
80105770:	6a 00                	push   $0x0
  pushl $144
80105772:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105777:	e9 8e f5 ff ff       	jmp    80104d0a <alltraps>

8010577c <vector145>:
.globl vector145
vector145:
  pushl $0
8010577c:	6a 00                	push   $0x0
  pushl $145
8010577e:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105783:	e9 82 f5 ff ff       	jmp    80104d0a <alltraps>

80105788 <vector146>:
.globl vector146
vector146:
  pushl $0
80105788:	6a 00                	push   $0x0
  pushl $146
8010578a:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010578f:	e9 76 f5 ff ff       	jmp    80104d0a <alltraps>

80105794 <vector147>:
.globl vector147
vector147:
  pushl $0
80105794:	6a 00                	push   $0x0
  pushl $147
80105796:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010579b:	e9 6a f5 ff ff       	jmp    80104d0a <alltraps>

801057a0 <vector148>:
.globl vector148
vector148:
  pushl $0
801057a0:	6a 00                	push   $0x0
  pushl $148
801057a2:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801057a7:	e9 5e f5 ff ff       	jmp    80104d0a <alltraps>

801057ac <vector149>:
.globl vector149
vector149:
  pushl $0
801057ac:	6a 00                	push   $0x0
  pushl $149
801057ae:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801057b3:	e9 52 f5 ff ff       	jmp    80104d0a <alltraps>

801057b8 <vector150>:
.globl vector150
vector150:
  pushl $0
801057b8:	6a 00                	push   $0x0
  pushl $150
801057ba:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801057bf:	e9 46 f5 ff ff       	jmp    80104d0a <alltraps>

801057c4 <vector151>:
.globl vector151
vector151:
  pushl $0
801057c4:	6a 00                	push   $0x0
  pushl $151
801057c6:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801057cb:	e9 3a f5 ff ff       	jmp    80104d0a <alltraps>

801057d0 <vector152>:
.globl vector152
vector152:
  pushl $0
801057d0:	6a 00                	push   $0x0
  pushl $152
801057d2:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801057d7:	e9 2e f5 ff ff       	jmp    80104d0a <alltraps>

801057dc <vector153>:
.globl vector153
vector153:
  pushl $0
801057dc:	6a 00                	push   $0x0
  pushl $153
801057de:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801057e3:	e9 22 f5 ff ff       	jmp    80104d0a <alltraps>

801057e8 <vector154>:
.globl vector154
vector154:
  pushl $0
801057e8:	6a 00                	push   $0x0
  pushl $154
801057ea:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801057ef:	e9 16 f5 ff ff       	jmp    80104d0a <alltraps>

801057f4 <vector155>:
.globl vector155
vector155:
  pushl $0
801057f4:	6a 00                	push   $0x0
  pushl $155
801057f6:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801057fb:	e9 0a f5 ff ff       	jmp    80104d0a <alltraps>

80105800 <vector156>:
.globl vector156
vector156:
  pushl $0
80105800:	6a 00                	push   $0x0
  pushl $156
80105802:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105807:	e9 fe f4 ff ff       	jmp    80104d0a <alltraps>

8010580c <vector157>:
.globl vector157
vector157:
  pushl $0
8010580c:	6a 00                	push   $0x0
  pushl $157
8010580e:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80105813:	e9 f2 f4 ff ff       	jmp    80104d0a <alltraps>

80105818 <vector158>:
.globl vector158
vector158:
  pushl $0
80105818:	6a 00                	push   $0x0
  pushl $158
8010581a:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010581f:	e9 e6 f4 ff ff       	jmp    80104d0a <alltraps>

80105824 <vector159>:
.globl vector159
vector159:
  pushl $0
80105824:	6a 00                	push   $0x0
  pushl $159
80105826:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010582b:	e9 da f4 ff ff       	jmp    80104d0a <alltraps>

80105830 <vector160>:
.globl vector160
vector160:
  pushl $0
80105830:	6a 00                	push   $0x0
  pushl $160
80105832:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105837:	e9 ce f4 ff ff       	jmp    80104d0a <alltraps>

8010583c <vector161>:
.globl vector161
vector161:
  pushl $0
8010583c:	6a 00                	push   $0x0
  pushl $161
8010583e:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105843:	e9 c2 f4 ff ff       	jmp    80104d0a <alltraps>

80105848 <vector162>:
.globl vector162
vector162:
  pushl $0
80105848:	6a 00                	push   $0x0
  pushl $162
8010584a:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010584f:	e9 b6 f4 ff ff       	jmp    80104d0a <alltraps>

80105854 <vector163>:
.globl vector163
vector163:
  pushl $0
80105854:	6a 00                	push   $0x0
  pushl $163
80105856:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010585b:	e9 aa f4 ff ff       	jmp    80104d0a <alltraps>

80105860 <vector164>:
.globl vector164
vector164:
  pushl $0
80105860:	6a 00                	push   $0x0
  pushl $164
80105862:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105867:	e9 9e f4 ff ff       	jmp    80104d0a <alltraps>

8010586c <vector165>:
.globl vector165
vector165:
  pushl $0
8010586c:	6a 00                	push   $0x0
  pushl $165
8010586e:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105873:	e9 92 f4 ff ff       	jmp    80104d0a <alltraps>

80105878 <vector166>:
.globl vector166
vector166:
  pushl $0
80105878:	6a 00                	push   $0x0
  pushl $166
8010587a:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010587f:	e9 86 f4 ff ff       	jmp    80104d0a <alltraps>

80105884 <vector167>:
.globl vector167
vector167:
  pushl $0
80105884:	6a 00                	push   $0x0
  pushl $167
80105886:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010588b:	e9 7a f4 ff ff       	jmp    80104d0a <alltraps>

80105890 <vector168>:
.globl vector168
vector168:
  pushl $0
80105890:	6a 00                	push   $0x0
  pushl $168
80105892:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105897:	e9 6e f4 ff ff       	jmp    80104d0a <alltraps>

8010589c <vector169>:
.globl vector169
vector169:
  pushl $0
8010589c:	6a 00                	push   $0x0
  pushl $169
8010589e:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801058a3:	e9 62 f4 ff ff       	jmp    80104d0a <alltraps>

801058a8 <vector170>:
.globl vector170
vector170:
  pushl $0
801058a8:	6a 00                	push   $0x0
  pushl $170
801058aa:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801058af:	e9 56 f4 ff ff       	jmp    80104d0a <alltraps>

801058b4 <vector171>:
.globl vector171
vector171:
  pushl $0
801058b4:	6a 00                	push   $0x0
  pushl $171
801058b6:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801058bb:	e9 4a f4 ff ff       	jmp    80104d0a <alltraps>

801058c0 <vector172>:
.globl vector172
vector172:
  pushl $0
801058c0:	6a 00                	push   $0x0
  pushl $172
801058c2:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801058c7:	e9 3e f4 ff ff       	jmp    80104d0a <alltraps>

801058cc <vector173>:
.globl vector173
vector173:
  pushl $0
801058cc:	6a 00                	push   $0x0
  pushl $173
801058ce:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801058d3:	e9 32 f4 ff ff       	jmp    80104d0a <alltraps>

801058d8 <vector174>:
.globl vector174
vector174:
  pushl $0
801058d8:	6a 00                	push   $0x0
  pushl $174
801058da:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801058df:	e9 26 f4 ff ff       	jmp    80104d0a <alltraps>

801058e4 <vector175>:
.globl vector175
vector175:
  pushl $0
801058e4:	6a 00                	push   $0x0
  pushl $175
801058e6:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801058eb:	e9 1a f4 ff ff       	jmp    80104d0a <alltraps>

801058f0 <vector176>:
.globl vector176
vector176:
  pushl $0
801058f0:	6a 00                	push   $0x0
  pushl $176
801058f2:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801058f7:	e9 0e f4 ff ff       	jmp    80104d0a <alltraps>

801058fc <vector177>:
.globl vector177
vector177:
  pushl $0
801058fc:	6a 00                	push   $0x0
  pushl $177
801058fe:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105903:	e9 02 f4 ff ff       	jmp    80104d0a <alltraps>

80105908 <vector178>:
.globl vector178
vector178:
  pushl $0
80105908:	6a 00                	push   $0x0
  pushl $178
8010590a:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010590f:	e9 f6 f3 ff ff       	jmp    80104d0a <alltraps>

80105914 <vector179>:
.globl vector179
vector179:
  pushl $0
80105914:	6a 00                	push   $0x0
  pushl $179
80105916:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010591b:	e9 ea f3 ff ff       	jmp    80104d0a <alltraps>

80105920 <vector180>:
.globl vector180
vector180:
  pushl $0
80105920:	6a 00                	push   $0x0
  pushl $180
80105922:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105927:	e9 de f3 ff ff       	jmp    80104d0a <alltraps>

8010592c <vector181>:
.globl vector181
vector181:
  pushl $0
8010592c:	6a 00                	push   $0x0
  pushl $181
8010592e:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105933:	e9 d2 f3 ff ff       	jmp    80104d0a <alltraps>

80105938 <vector182>:
.globl vector182
vector182:
  pushl $0
80105938:	6a 00                	push   $0x0
  pushl $182
8010593a:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010593f:	e9 c6 f3 ff ff       	jmp    80104d0a <alltraps>

80105944 <vector183>:
.globl vector183
vector183:
  pushl $0
80105944:	6a 00                	push   $0x0
  pushl $183
80105946:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010594b:	e9 ba f3 ff ff       	jmp    80104d0a <alltraps>

80105950 <vector184>:
.globl vector184
vector184:
  pushl $0
80105950:	6a 00                	push   $0x0
  pushl $184
80105952:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105957:	e9 ae f3 ff ff       	jmp    80104d0a <alltraps>

8010595c <vector185>:
.globl vector185
vector185:
  pushl $0
8010595c:	6a 00                	push   $0x0
  pushl $185
8010595e:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105963:	e9 a2 f3 ff ff       	jmp    80104d0a <alltraps>

80105968 <vector186>:
.globl vector186
vector186:
  pushl $0
80105968:	6a 00                	push   $0x0
  pushl $186
8010596a:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010596f:	e9 96 f3 ff ff       	jmp    80104d0a <alltraps>

80105974 <vector187>:
.globl vector187
vector187:
  pushl $0
80105974:	6a 00                	push   $0x0
  pushl $187
80105976:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010597b:	e9 8a f3 ff ff       	jmp    80104d0a <alltraps>

80105980 <vector188>:
.globl vector188
vector188:
  pushl $0
80105980:	6a 00                	push   $0x0
  pushl $188
80105982:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105987:	e9 7e f3 ff ff       	jmp    80104d0a <alltraps>

8010598c <vector189>:
.globl vector189
vector189:
  pushl $0
8010598c:	6a 00                	push   $0x0
  pushl $189
8010598e:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105993:	e9 72 f3 ff ff       	jmp    80104d0a <alltraps>

80105998 <vector190>:
.globl vector190
vector190:
  pushl $0
80105998:	6a 00                	push   $0x0
  pushl $190
8010599a:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010599f:	e9 66 f3 ff ff       	jmp    80104d0a <alltraps>

801059a4 <vector191>:
.globl vector191
vector191:
  pushl $0
801059a4:	6a 00                	push   $0x0
  pushl $191
801059a6:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801059ab:	e9 5a f3 ff ff       	jmp    80104d0a <alltraps>

801059b0 <vector192>:
.globl vector192
vector192:
  pushl $0
801059b0:	6a 00                	push   $0x0
  pushl $192
801059b2:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801059b7:	e9 4e f3 ff ff       	jmp    80104d0a <alltraps>

801059bc <vector193>:
.globl vector193
vector193:
  pushl $0
801059bc:	6a 00                	push   $0x0
  pushl $193
801059be:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801059c3:	e9 42 f3 ff ff       	jmp    80104d0a <alltraps>

801059c8 <vector194>:
.globl vector194
vector194:
  pushl $0
801059c8:	6a 00                	push   $0x0
  pushl $194
801059ca:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801059cf:	e9 36 f3 ff ff       	jmp    80104d0a <alltraps>

801059d4 <vector195>:
.globl vector195
vector195:
  pushl $0
801059d4:	6a 00                	push   $0x0
  pushl $195
801059d6:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801059db:	e9 2a f3 ff ff       	jmp    80104d0a <alltraps>

801059e0 <vector196>:
.globl vector196
vector196:
  pushl $0
801059e0:	6a 00                	push   $0x0
  pushl $196
801059e2:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801059e7:	e9 1e f3 ff ff       	jmp    80104d0a <alltraps>

801059ec <vector197>:
.globl vector197
vector197:
  pushl $0
801059ec:	6a 00                	push   $0x0
  pushl $197
801059ee:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801059f3:	e9 12 f3 ff ff       	jmp    80104d0a <alltraps>

801059f8 <vector198>:
.globl vector198
vector198:
  pushl $0
801059f8:	6a 00                	push   $0x0
  pushl $198
801059fa:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801059ff:	e9 06 f3 ff ff       	jmp    80104d0a <alltraps>

80105a04 <vector199>:
.globl vector199
vector199:
  pushl $0
80105a04:	6a 00                	push   $0x0
  pushl $199
80105a06:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105a0b:	e9 fa f2 ff ff       	jmp    80104d0a <alltraps>

80105a10 <vector200>:
.globl vector200
vector200:
  pushl $0
80105a10:	6a 00                	push   $0x0
  pushl $200
80105a12:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105a17:	e9 ee f2 ff ff       	jmp    80104d0a <alltraps>

80105a1c <vector201>:
.globl vector201
vector201:
  pushl $0
80105a1c:	6a 00                	push   $0x0
  pushl $201
80105a1e:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105a23:	e9 e2 f2 ff ff       	jmp    80104d0a <alltraps>

80105a28 <vector202>:
.globl vector202
vector202:
  pushl $0
80105a28:	6a 00                	push   $0x0
  pushl $202
80105a2a:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105a2f:	e9 d6 f2 ff ff       	jmp    80104d0a <alltraps>

80105a34 <vector203>:
.globl vector203
vector203:
  pushl $0
80105a34:	6a 00                	push   $0x0
  pushl $203
80105a36:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105a3b:	e9 ca f2 ff ff       	jmp    80104d0a <alltraps>

80105a40 <vector204>:
.globl vector204
vector204:
  pushl $0
80105a40:	6a 00                	push   $0x0
  pushl $204
80105a42:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105a47:	e9 be f2 ff ff       	jmp    80104d0a <alltraps>

80105a4c <vector205>:
.globl vector205
vector205:
  pushl $0
80105a4c:	6a 00                	push   $0x0
  pushl $205
80105a4e:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105a53:	e9 b2 f2 ff ff       	jmp    80104d0a <alltraps>

80105a58 <vector206>:
.globl vector206
vector206:
  pushl $0
80105a58:	6a 00                	push   $0x0
  pushl $206
80105a5a:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105a5f:	e9 a6 f2 ff ff       	jmp    80104d0a <alltraps>

80105a64 <vector207>:
.globl vector207
vector207:
  pushl $0
80105a64:	6a 00                	push   $0x0
  pushl $207
80105a66:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105a6b:	e9 9a f2 ff ff       	jmp    80104d0a <alltraps>

80105a70 <vector208>:
.globl vector208
vector208:
  pushl $0
80105a70:	6a 00                	push   $0x0
  pushl $208
80105a72:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105a77:	e9 8e f2 ff ff       	jmp    80104d0a <alltraps>

80105a7c <vector209>:
.globl vector209
vector209:
  pushl $0
80105a7c:	6a 00                	push   $0x0
  pushl $209
80105a7e:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105a83:	e9 82 f2 ff ff       	jmp    80104d0a <alltraps>

80105a88 <vector210>:
.globl vector210
vector210:
  pushl $0
80105a88:	6a 00                	push   $0x0
  pushl $210
80105a8a:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105a8f:	e9 76 f2 ff ff       	jmp    80104d0a <alltraps>

80105a94 <vector211>:
.globl vector211
vector211:
  pushl $0
80105a94:	6a 00                	push   $0x0
  pushl $211
80105a96:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105a9b:	e9 6a f2 ff ff       	jmp    80104d0a <alltraps>

80105aa0 <vector212>:
.globl vector212
vector212:
  pushl $0
80105aa0:	6a 00                	push   $0x0
  pushl $212
80105aa2:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105aa7:	e9 5e f2 ff ff       	jmp    80104d0a <alltraps>

80105aac <vector213>:
.globl vector213
vector213:
  pushl $0
80105aac:	6a 00                	push   $0x0
  pushl $213
80105aae:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105ab3:	e9 52 f2 ff ff       	jmp    80104d0a <alltraps>

80105ab8 <vector214>:
.globl vector214
vector214:
  pushl $0
80105ab8:	6a 00                	push   $0x0
  pushl $214
80105aba:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105abf:	e9 46 f2 ff ff       	jmp    80104d0a <alltraps>

80105ac4 <vector215>:
.globl vector215
vector215:
  pushl $0
80105ac4:	6a 00                	push   $0x0
  pushl $215
80105ac6:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105acb:	e9 3a f2 ff ff       	jmp    80104d0a <alltraps>

80105ad0 <vector216>:
.globl vector216
vector216:
  pushl $0
80105ad0:	6a 00                	push   $0x0
  pushl $216
80105ad2:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105ad7:	e9 2e f2 ff ff       	jmp    80104d0a <alltraps>

80105adc <vector217>:
.globl vector217
vector217:
  pushl $0
80105adc:	6a 00                	push   $0x0
  pushl $217
80105ade:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105ae3:	e9 22 f2 ff ff       	jmp    80104d0a <alltraps>

80105ae8 <vector218>:
.globl vector218
vector218:
  pushl $0
80105ae8:	6a 00                	push   $0x0
  pushl $218
80105aea:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105aef:	e9 16 f2 ff ff       	jmp    80104d0a <alltraps>

80105af4 <vector219>:
.globl vector219
vector219:
  pushl $0
80105af4:	6a 00                	push   $0x0
  pushl $219
80105af6:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105afb:	e9 0a f2 ff ff       	jmp    80104d0a <alltraps>

80105b00 <vector220>:
.globl vector220
vector220:
  pushl $0
80105b00:	6a 00                	push   $0x0
  pushl $220
80105b02:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105b07:	e9 fe f1 ff ff       	jmp    80104d0a <alltraps>

80105b0c <vector221>:
.globl vector221
vector221:
  pushl $0
80105b0c:	6a 00                	push   $0x0
  pushl $221
80105b0e:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105b13:	e9 f2 f1 ff ff       	jmp    80104d0a <alltraps>

80105b18 <vector222>:
.globl vector222
vector222:
  pushl $0
80105b18:	6a 00                	push   $0x0
  pushl $222
80105b1a:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105b1f:	e9 e6 f1 ff ff       	jmp    80104d0a <alltraps>

80105b24 <vector223>:
.globl vector223
vector223:
  pushl $0
80105b24:	6a 00                	push   $0x0
  pushl $223
80105b26:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105b2b:	e9 da f1 ff ff       	jmp    80104d0a <alltraps>

80105b30 <vector224>:
.globl vector224
vector224:
  pushl $0
80105b30:	6a 00                	push   $0x0
  pushl $224
80105b32:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105b37:	e9 ce f1 ff ff       	jmp    80104d0a <alltraps>

80105b3c <vector225>:
.globl vector225
vector225:
  pushl $0
80105b3c:	6a 00                	push   $0x0
  pushl $225
80105b3e:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105b43:	e9 c2 f1 ff ff       	jmp    80104d0a <alltraps>

80105b48 <vector226>:
.globl vector226
vector226:
  pushl $0
80105b48:	6a 00                	push   $0x0
  pushl $226
80105b4a:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105b4f:	e9 b6 f1 ff ff       	jmp    80104d0a <alltraps>

80105b54 <vector227>:
.globl vector227
vector227:
  pushl $0
80105b54:	6a 00                	push   $0x0
  pushl $227
80105b56:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105b5b:	e9 aa f1 ff ff       	jmp    80104d0a <alltraps>

80105b60 <vector228>:
.globl vector228
vector228:
  pushl $0
80105b60:	6a 00                	push   $0x0
  pushl $228
80105b62:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105b67:	e9 9e f1 ff ff       	jmp    80104d0a <alltraps>

80105b6c <vector229>:
.globl vector229
vector229:
  pushl $0
80105b6c:	6a 00                	push   $0x0
  pushl $229
80105b6e:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105b73:	e9 92 f1 ff ff       	jmp    80104d0a <alltraps>

80105b78 <vector230>:
.globl vector230
vector230:
  pushl $0
80105b78:	6a 00                	push   $0x0
  pushl $230
80105b7a:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105b7f:	e9 86 f1 ff ff       	jmp    80104d0a <alltraps>

80105b84 <vector231>:
.globl vector231
vector231:
  pushl $0
80105b84:	6a 00                	push   $0x0
  pushl $231
80105b86:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105b8b:	e9 7a f1 ff ff       	jmp    80104d0a <alltraps>

80105b90 <vector232>:
.globl vector232
vector232:
  pushl $0
80105b90:	6a 00                	push   $0x0
  pushl $232
80105b92:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105b97:	e9 6e f1 ff ff       	jmp    80104d0a <alltraps>

80105b9c <vector233>:
.globl vector233
vector233:
  pushl $0
80105b9c:	6a 00                	push   $0x0
  pushl $233
80105b9e:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105ba3:	e9 62 f1 ff ff       	jmp    80104d0a <alltraps>

80105ba8 <vector234>:
.globl vector234
vector234:
  pushl $0
80105ba8:	6a 00                	push   $0x0
  pushl $234
80105baa:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105baf:	e9 56 f1 ff ff       	jmp    80104d0a <alltraps>

80105bb4 <vector235>:
.globl vector235
vector235:
  pushl $0
80105bb4:	6a 00                	push   $0x0
  pushl $235
80105bb6:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105bbb:	e9 4a f1 ff ff       	jmp    80104d0a <alltraps>

80105bc0 <vector236>:
.globl vector236
vector236:
  pushl $0
80105bc0:	6a 00                	push   $0x0
  pushl $236
80105bc2:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105bc7:	e9 3e f1 ff ff       	jmp    80104d0a <alltraps>

80105bcc <vector237>:
.globl vector237
vector237:
  pushl $0
80105bcc:	6a 00                	push   $0x0
  pushl $237
80105bce:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105bd3:	e9 32 f1 ff ff       	jmp    80104d0a <alltraps>

80105bd8 <vector238>:
.globl vector238
vector238:
  pushl $0
80105bd8:	6a 00                	push   $0x0
  pushl $238
80105bda:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105bdf:	e9 26 f1 ff ff       	jmp    80104d0a <alltraps>

80105be4 <vector239>:
.globl vector239
vector239:
  pushl $0
80105be4:	6a 00                	push   $0x0
  pushl $239
80105be6:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105beb:	e9 1a f1 ff ff       	jmp    80104d0a <alltraps>

80105bf0 <vector240>:
.globl vector240
vector240:
  pushl $0
80105bf0:	6a 00                	push   $0x0
  pushl $240
80105bf2:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105bf7:	e9 0e f1 ff ff       	jmp    80104d0a <alltraps>

80105bfc <vector241>:
.globl vector241
vector241:
  pushl $0
80105bfc:	6a 00                	push   $0x0
  pushl $241
80105bfe:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105c03:	e9 02 f1 ff ff       	jmp    80104d0a <alltraps>

80105c08 <vector242>:
.globl vector242
vector242:
  pushl $0
80105c08:	6a 00                	push   $0x0
  pushl $242
80105c0a:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105c0f:	e9 f6 f0 ff ff       	jmp    80104d0a <alltraps>

80105c14 <vector243>:
.globl vector243
vector243:
  pushl $0
80105c14:	6a 00                	push   $0x0
  pushl $243
80105c16:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105c1b:	e9 ea f0 ff ff       	jmp    80104d0a <alltraps>

80105c20 <vector244>:
.globl vector244
vector244:
  pushl $0
80105c20:	6a 00                	push   $0x0
  pushl $244
80105c22:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105c27:	e9 de f0 ff ff       	jmp    80104d0a <alltraps>

80105c2c <vector245>:
.globl vector245
vector245:
  pushl $0
80105c2c:	6a 00                	push   $0x0
  pushl $245
80105c2e:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105c33:	e9 d2 f0 ff ff       	jmp    80104d0a <alltraps>

80105c38 <vector246>:
.globl vector246
vector246:
  pushl $0
80105c38:	6a 00                	push   $0x0
  pushl $246
80105c3a:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105c3f:	e9 c6 f0 ff ff       	jmp    80104d0a <alltraps>

80105c44 <vector247>:
.globl vector247
vector247:
  pushl $0
80105c44:	6a 00                	push   $0x0
  pushl $247
80105c46:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105c4b:	e9 ba f0 ff ff       	jmp    80104d0a <alltraps>

80105c50 <vector248>:
.globl vector248
vector248:
  pushl $0
80105c50:	6a 00                	push   $0x0
  pushl $248
80105c52:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105c57:	e9 ae f0 ff ff       	jmp    80104d0a <alltraps>

80105c5c <vector249>:
.globl vector249
vector249:
  pushl $0
80105c5c:	6a 00                	push   $0x0
  pushl $249
80105c5e:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105c63:	e9 a2 f0 ff ff       	jmp    80104d0a <alltraps>

80105c68 <vector250>:
.globl vector250
vector250:
  pushl $0
80105c68:	6a 00                	push   $0x0
  pushl $250
80105c6a:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105c6f:	e9 96 f0 ff ff       	jmp    80104d0a <alltraps>

80105c74 <vector251>:
.globl vector251
vector251:
  pushl $0
80105c74:	6a 00                	push   $0x0
  pushl $251
80105c76:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105c7b:	e9 8a f0 ff ff       	jmp    80104d0a <alltraps>

80105c80 <vector252>:
.globl vector252
vector252:
  pushl $0
80105c80:	6a 00                	push   $0x0
  pushl $252
80105c82:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105c87:	e9 7e f0 ff ff       	jmp    80104d0a <alltraps>

80105c8c <vector253>:
.globl vector253
vector253:
  pushl $0
80105c8c:	6a 00                	push   $0x0
  pushl $253
80105c8e:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105c93:	e9 72 f0 ff ff       	jmp    80104d0a <alltraps>

80105c98 <vector254>:
.globl vector254
vector254:
  pushl $0
80105c98:	6a 00                	push   $0x0
  pushl $254
80105c9a:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105c9f:	e9 66 f0 ff ff       	jmp    80104d0a <alltraps>

80105ca4 <vector255>:
.globl vector255
vector255:
  pushl $0
80105ca4:	6a 00                	push   $0x0
  pushl $255
80105ca6:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105cab:	e9 5a f0 ff ff       	jmp    80104d0a <alltraps>

80105cb0 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105cb0:	55                   	push   %ebp
80105cb1:	89 e5                	mov    %esp,%ebp
80105cb3:	57                   	push   %edi
80105cb4:	56                   	push   %esi
80105cb5:	53                   	push   %ebx
80105cb6:	83 ec 0c             	sub    $0xc,%esp
80105cb9:	89 d3                	mov    %edx,%ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105cbb:	c1 ea 16             	shr    $0x16,%edx
80105cbe:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105cc1:	8b 37                	mov    (%edi),%esi
80105cc3:	f7 c6 01 00 00 00    	test   $0x1,%esi
80105cc9:	74 20                	je     80105ceb <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105ccb:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
80105cd1:	81 c6 00 00 00 80    	add    $0x80000000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105cd7:	c1 eb 0c             	shr    $0xc,%ebx
80105cda:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
80105ce0:	8d 04 9e             	lea    (%esi,%ebx,4),%eax
}
80105ce3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105ce6:	5b                   	pop    %ebx
80105ce7:	5e                   	pop    %esi
80105ce8:	5f                   	pop    %edi
80105ce9:	5d                   	pop    %ebp
80105cea:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105ceb:	85 c9                	test   %ecx,%ecx
80105ced:	74 2b                	je     80105d1a <walkpgdir+0x6a>
80105cef:	e8 3a c3 ff ff       	call   8010202e <kalloc>
80105cf4:	89 c6                	mov    %eax,%esi
80105cf6:	85 c0                	test   %eax,%eax
80105cf8:	74 20                	je     80105d1a <walkpgdir+0x6a>
    memset(pgtab, 0, PGSIZE);
80105cfa:	83 ec 04             	sub    $0x4,%esp
80105cfd:	68 00 10 00 00       	push   $0x1000
80105d02:	6a 00                	push   $0x0
80105d04:	50                   	push   %eax
80105d05:	e8 91 de ff ff       	call   80103b9b <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105d0a:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80105d10:	83 c8 07             	or     $0x7,%eax
80105d13:	89 07                	mov    %eax,(%edi)
80105d15:	83 c4 10             	add    $0x10,%esp
80105d18:	eb bd                	jmp    80105cd7 <walkpgdir+0x27>
      return 0;
80105d1a:	b8 00 00 00 00       	mov    $0x0,%eax
80105d1f:	eb c2                	jmp    80105ce3 <walkpgdir+0x33>

80105d21 <seginit>:
{
80105d21:	55                   	push   %ebp
80105d22:	89 e5                	mov    %esp,%ebp
80105d24:	57                   	push   %edi
80105d25:	56                   	push   %esi
80105d26:	53                   	push   %ebx
80105d27:	83 ec 2c             	sub    $0x2c,%esp
  c = &cpus[cpuid()];
80105d2a:	e8 c6 d3 ff ff       	call   801030f5 <cpuid>
80105d2f:	89 c3                	mov    %eax,%ebx
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105d31:	8d 14 80             	lea    (%eax,%eax,4),%edx
80105d34:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
80105d37:	8d 04 01             	lea    (%ecx,%eax,1),%eax
80105d3a:	c1 e0 04             	shl    $0x4,%eax
80105d3d:	66 c7 80 18 18 11 80 	movw   $0xffff,-0x7feee7e8(%eax)
80105d44:	ff ff 
80105d46:	66 c7 80 1a 18 11 80 	movw   $0x0,-0x7feee7e6(%eax)
80105d4d:	00 00 
80105d4f:	c6 80 1c 18 11 80 00 	movb   $0x0,-0x7feee7e4(%eax)
80105d56:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
80105d59:	01 d9                	add    %ebx,%ecx
80105d5b:	c1 e1 04             	shl    $0x4,%ecx
80105d5e:	0f b6 b1 1d 18 11 80 	movzbl -0x7feee7e3(%ecx),%esi
80105d65:	83 e6 f0             	and    $0xfffffff0,%esi
80105d68:	89 f7                	mov    %esi,%edi
80105d6a:	83 cf 0a             	or     $0xa,%edi
80105d6d:	89 fa                	mov    %edi,%edx
80105d6f:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
80105d75:	83 ce 1a             	or     $0x1a,%esi
80105d78:	89 f2                	mov    %esi,%edx
80105d7a:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
80105d80:	83 e6 9f             	and    $0xffffff9f,%esi
80105d83:	89 f2                	mov    %esi,%edx
80105d85:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
80105d8b:	83 ce 80             	or     $0xffffff80,%esi
80105d8e:	89 f2                	mov    %esi,%edx
80105d90:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
80105d96:	0f b6 b1 1e 18 11 80 	movzbl -0x7feee7e2(%ecx),%esi
80105d9d:	83 ce 0f             	or     $0xf,%esi
80105da0:	89 f2                	mov    %esi,%edx
80105da2:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
80105da8:	89 f7                	mov    %esi,%edi
80105daa:	83 e7 ef             	and    $0xffffffef,%edi
80105dad:	89 fa                	mov    %edi,%edx
80105daf:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
80105db5:	83 e6 cf             	and    $0xffffffcf,%esi
80105db8:	89 f2                	mov    %esi,%edx
80105dba:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
80105dc0:	89 f7                	mov    %esi,%edi
80105dc2:	83 cf 40             	or     $0x40,%edi
80105dc5:	89 fa                	mov    %edi,%edx
80105dc7:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
80105dcd:	83 ce c0             	or     $0xffffffc0,%esi
80105dd0:	89 f2                	mov    %esi,%edx
80105dd2:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
80105dd8:	c6 80 1f 18 11 80 00 	movb   $0x0,-0x7feee7e1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105ddf:	66 c7 80 20 18 11 80 	movw   $0xffff,-0x7feee7e0(%eax)
80105de6:	ff ff 
80105de8:	66 c7 80 22 18 11 80 	movw   $0x0,-0x7feee7de(%eax)
80105def:	00 00 
80105df1:	c6 80 24 18 11 80 00 	movb   $0x0,-0x7feee7dc(%eax)
80105df8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80105dfb:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
80105dfe:	c1 e1 04             	shl    $0x4,%ecx
80105e01:	0f b6 b1 25 18 11 80 	movzbl -0x7feee7db(%ecx),%esi
80105e08:	83 e6 f0             	and    $0xfffffff0,%esi
80105e0b:	89 f7                	mov    %esi,%edi
80105e0d:	83 cf 02             	or     $0x2,%edi
80105e10:	89 fa                	mov    %edi,%edx
80105e12:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
80105e18:	83 ce 12             	or     $0x12,%esi
80105e1b:	89 f2                	mov    %esi,%edx
80105e1d:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
80105e23:	83 e6 9f             	and    $0xffffff9f,%esi
80105e26:	89 f2                	mov    %esi,%edx
80105e28:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
80105e2e:	83 ce 80             	or     $0xffffff80,%esi
80105e31:	89 f2                	mov    %esi,%edx
80105e33:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
80105e39:	0f b6 b1 26 18 11 80 	movzbl -0x7feee7da(%ecx),%esi
80105e40:	83 ce 0f             	or     $0xf,%esi
80105e43:	89 f2                	mov    %esi,%edx
80105e45:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
80105e4b:	89 f7                	mov    %esi,%edi
80105e4d:	83 e7 ef             	and    $0xffffffef,%edi
80105e50:	89 fa                	mov    %edi,%edx
80105e52:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
80105e58:	83 e6 cf             	and    $0xffffffcf,%esi
80105e5b:	89 f2                	mov    %esi,%edx
80105e5d:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
80105e63:	89 f7                	mov    %esi,%edi
80105e65:	83 cf 40             	or     $0x40,%edi
80105e68:	89 fa                	mov    %edi,%edx
80105e6a:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
80105e70:	83 ce c0             	or     $0xffffffc0,%esi
80105e73:	89 f2                	mov    %esi,%edx
80105e75:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
80105e7b:	c6 80 27 18 11 80 00 	movb   $0x0,-0x7feee7d9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105e82:	66 c7 80 28 18 11 80 	movw   $0xffff,-0x7feee7d8(%eax)
80105e89:	ff ff 
80105e8b:	66 c7 80 2a 18 11 80 	movw   $0x0,-0x7feee7d6(%eax)
80105e92:	00 00 
80105e94:	c6 80 2c 18 11 80 00 	movb   $0x0,-0x7feee7d4(%eax)
80105e9b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80105e9e:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
80105ea1:	c1 e1 04             	shl    $0x4,%ecx
80105ea4:	0f b6 b1 2d 18 11 80 	movzbl -0x7feee7d3(%ecx),%esi
80105eab:	83 e6 f0             	and    $0xfffffff0,%esi
80105eae:	89 f7                	mov    %esi,%edi
80105eb0:	83 cf 0a             	or     $0xa,%edi
80105eb3:	89 fa                	mov    %edi,%edx
80105eb5:	88 91 2d 18 11 80    	mov    %dl,-0x7feee7d3(%ecx)
80105ebb:	89 f7                	mov    %esi,%edi
80105ebd:	83 cf 1a             	or     $0x1a,%edi
80105ec0:	89 fa                	mov    %edi,%edx
80105ec2:	88 91 2d 18 11 80    	mov    %dl,-0x7feee7d3(%ecx)
80105ec8:	83 ce 7a             	or     $0x7a,%esi
80105ecb:	89 f2                	mov    %esi,%edx
80105ecd:	88 91 2d 18 11 80    	mov    %dl,-0x7feee7d3(%ecx)
80105ed3:	c6 81 2d 18 11 80 fa 	movb   $0xfa,-0x7feee7d3(%ecx)
80105eda:	0f b6 b1 2e 18 11 80 	movzbl -0x7feee7d2(%ecx),%esi
80105ee1:	83 ce 0f             	or     $0xf,%esi
80105ee4:	89 f2                	mov    %esi,%edx
80105ee6:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
80105eec:	89 f7                	mov    %esi,%edi
80105eee:	83 e7 ef             	and    $0xffffffef,%edi
80105ef1:	89 fa                	mov    %edi,%edx
80105ef3:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
80105ef9:	83 e6 cf             	and    $0xffffffcf,%esi
80105efc:	89 f2                	mov    %esi,%edx
80105efe:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
80105f04:	89 f7                	mov    %esi,%edi
80105f06:	83 cf 40             	or     $0x40,%edi
80105f09:	89 fa                	mov    %edi,%edx
80105f0b:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
80105f11:	83 ce c0             	or     $0xffffffc0,%esi
80105f14:	89 f2                	mov    %esi,%edx
80105f16:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
80105f1c:	c6 80 2f 18 11 80 00 	movb   $0x0,-0x7feee7d1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105f23:	66 c7 80 30 18 11 80 	movw   $0xffff,-0x7feee7d0(%eax)
80105f2a:	ff ff 
80105f2c:	66 c7 80 32 18 11 80 	movw   $0x0,-0x7feee7ce(%eax)
80105f33:	00 00 
80105f35:	c6 80 34 18 11 80 00 	movb   $0x0,-0x7feee7cc(%eax)
80105f3c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80105f3f:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
80105f42:	c1 e1 04             	shl    $0x4,%ecx
80105f45:	0f b6 b1 35 18 11 80 	movzbl -0x7feee7cb(%ecx),%esi
80105f4c:	83 e6 f0             	and    $0xfffffff0,%esi
80105f4f:	89 f7                	mov    %esi,%edi
80105f51:	83 cf 02             	or     $0x2,%edi
80105f54:	89 fa                	mov    %edi,%edx
80105f56:	88 91 35 18 11 80    	mov    %dl,-0x7feee7cb(%ecx)
80105f5c:	89 f7                	mov    %esi,%edi
80105f5e:	83 cf 12             	or     $0x12,%edi
80105f61:	89 fa                	mov    %edi,%edx
80105f63:	88 91 35 18 11 80    	mov    %dl,-0x7feee7cb(%ecx)
80105f69:	83 ce 72             	or     $0x72,%esi
80105f6c:	89 f2                	mov    %esi,%edx
80105f6e:	88 91 35 18 11 80    	mov    %dl,-0x7feee7cb(%ecx)
80105f74:	c6 81 35 18 11 80 f2 	movb   $0xf2,-0x7feee7cb(%ecx)
80105f7b:	0f b6 b1 36 18 11 80 	movzbl -0x7feee7ca(%ecx),%esi
80105f82:	83 ce 0f             	or     $0xf,%esi
80105f85:	89 f2                	mov    %esi,%edx
80105f87:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
80105f8d:	89 f7                	mov    %esi,%edi
80105f8f:	83 e7 ef             	and    $0xffffffef,%edi
80105f92:	89 fa                	mov    %edi,%edx
80105f94:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
80105f9a:	83 e6 cf             	and    $0xffffffcf,%esi
80105f9d:	89 f2                	mov    %esi,%edx
80105f9f:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
80105fa5:	89 f7                	mov    %esi,%edi
80105fa7:	83 cf 40             	or     $0x40,%edi
80105faa:	89 fa                	mov    %edi,%edx
80105fac:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
80105fb2:	83 ce c0             	or     $0xffffffc0,%esi
80105fb5:	89 f2                	mov    %esi,%edx
80105fb7:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
80105fbd:	c6 80 37 18 11 80 00 	movb   $0x0,-0x7feee7c9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80105fc4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80105fc7:	01 da                	add    %ebx,%edx
80105fc9:	c1 e2 04             	shl    $0x4,%edx
80105fcc:	81 c2 10 18 11 80    	add    $0x80111810,%edx
  pd[0] = size-1;
80105fd2:	66 c7 45 e2 2f 00    	movw   $0x2f,-0x1e(%ebp)
  pd[1] = (uint)p;
80105fd8:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
  pd[2] = (uint)p >> 16;
80105fdc:	c1 ea 10             	shr    $0x10,%edx
80105fdf:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80105fe3:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105fe6:	0f 01 10             	lgdtl  (%eax)
}
80105fe9:	83 c4 2c             	add    $0x2c,%esp
80105fec:	5b                   	pop    %ebx
80105fed:	5e                   	pop    %esi
80105fee:	5f                   	pop    %edi
80105fef:	5d                   	pop    %ebp
80105ff0:	c3                   	ret    

80105ff1 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105ff1:	55                   	push   %ebp
80105ff2:	89 e5                	mov    %esp,%ebp
80105ff4:	57                   	push   %edi
80105ff5:	56                   	push   %esi
80105ff6:	53                   	push   %ebx
80105ff7:	83 ec 0c             	sub    $0xc,%esp
80105ffa:	8b 7d 0c             	mov    0xc(%ebp),%edi
80105ffd:	8b 75 14             	mov    0x14(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80106000:	89 fb                	mov    %edi,%ebx
80106002:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106008:	03 7d 10             	add    0x10(%ebp),%edi
8010600b:	4f                   	dec    %edi
8010600c:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106012:	b9 01 00 00 00       	mov    $0x1,%ecx
80106017:	89 da                	mov    %ebx,%edx
80106019:	8b 45 08             	mov    0x8(%ebp),%eax
8010601c:	e8 8f fc ff ff       	call   80105cb0 <walkpgdir>
80106021:	85 c0                	test   %eax,%eax
80106023:	74 2e                	je     80106053 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80106025:	f6 00 01             	testb  $0x1,(%eax)
80106028:	75 1c                	jne    80106046 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
8010602a:	89 f2                	mov    %esi,%edx
8010602c:	0b 55 18             	or     0x18(%ebp),%edx
8010602f:	83 ca 01             	or     $0x1,%edx
80106032:	89 10                	mov    %edx,(%eax)
    if(a == last)
80106034:	39 fb                	cmp    %edi,%ebx
80106036:	74 28                	je     80106060 <mappages+0x6f>
      break;
    a += PGSIZE;
80106038:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
8010603e:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106044:	eb cc                	jmp    80106012 <mappages+0x21>
      panic("remap");
80106046:	83 ec 0c             	sub    $0xc,%esp
80106049:	68 54 70 10 80       	push   $0x80107054
8010604e:	e8 ee a2 ff ff       	call   80100341 <panic>
      return -1;
80106053:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80106058:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010605b:	5b                   	pop    %ebx
8010605c:	5e                   	pop    %esi
8010605d:	5f                   	pop    %edi
8010605e:	5d                   	pop    %ebp
8010605f:	c3                   	ret    
  return 0;
80106060:	b8 00 00 00 00       	mov    $0x0,%eax
80106065:	eb f1                	jmp    80106058 <mappages+0x67>

80106067 <switchkvm>:
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106067:	a1 c4 46 11 80       	mov    0x801146c4,%eax
8010606c:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106071:	0f 22 d8             	mov    %eax,%cr3
}
80106074:	c3                   	ret    

80106075 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80106075:	55                   	push   %ebp
80106076:	89 e5                	mov    %esp,%ebp
80106078:	57                   	push   %edi
80106079:	56                   	push   %esi
8010607a:	53                   	push   %ebx
8010607b:	83 ec 1c             	sub    $0x1c,%esp
8010607e:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80106081:	85 f6                	test   %esi,%esi
80106083:	0f 84 21 01 00 00    	je     801061aa <switchuvm+0x135>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80106089:	83 7e 10 00          	cmpl   $0x0,0x10(%esi)
8010608d:	0f 84 24 01 00 00    	je     801061b7 <switchuvm+0x142>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80106093:	83 7e 0c 00          	cmpl   $0x0,0xc(%esi)
80106097:	0f 84 27 01 00 00    	je     801061c4 <switchuvm+0x14f>
    panic("switchuvm: no pgdir");

  pushcli();
8010609d:	e8 73 d9 ff ff       	call   80103a15 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801060a2:	e8 ea cf ff ff       	call   80103091 <mycpu>
801060a7:	89 c3                	mov    %eax,%ebx
801060a9:	e8 e3 cf ff ff       	call   80103091 <mycpu>
801060ae:	8d 78 08             	lea    0x8(%eax),%edi
801060b1:	e8 db cf ff ff       	call   80103091 <mycpu>
801060b6:	83 c0 08             	add    $0x8,%eax
801060b9:	c1 e8 10             	shr    $0x10,%eax
801060bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801060bf:	e8 cd cf ff ff       	call   80103091 <mycpu>
801060c4:	83 c0 08             	add    $0x8,%eax
801060c7:	c1 e8 18             	shr    $0x18,%eax
801060ca:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801060d1:	67 00 
801060d3:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
801060da:	8a 4d e4             	mov    -0x1c(%ebp),%cl
801060dd:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
801060e3:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
801060e9:	83 e2 f0             	and    $0xfffffff0,%edx
801060ec:	88 d1                	mov    %dl,%cl
801060ee:	83 c9 09             	or     $0x9,%ecx
801060f1:	88 8b 9d 00 00 00    	mov    %cl,0x9d(%ebx)
801060f7:	83 ca 19             	or     $0x19,%edx
801060fa:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106100:	83 e2 9f             	and    $0xffffff9f,%edx
80106103:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106109:	83 ca 80             	or     $0xffffff80,%edx
8010610c:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106112:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80106118:	88 d1                	mov    %dl,%cl
8010611a:	83 e1 f0             	and    $0xfffffff0,%ecx
8010611d:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
80106123:	88 d1                	mov    %dl,%cl
80106125:	83 e1 e0             	and    $0xffffffe0,%ecx
80106128:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
8010612e:	83 e2 c0             	and    $0xffffffc0,%edx
80106131:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80106137:	83 ca 40             	or     $0x40,%edx
8010613a:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80106140:	83 e2 7f             	and    $0x7f,%edx
80106143:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80106149:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010614f:	e8 3d cf ff ff       	call   80103091 <mycpu>
80106154:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
8010615a:	83 e2 ef             	and    $0xffffffef,%edx
8010615d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106163:	e8 29 cf ff ff       	call   80103091 <mycpu>
80106168:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010616e:	8b 5e 10             	mov    0x10(%esi),%ebx
80106171:	e8 1b cf ff ff       	call   80103091 <mycpu>
80106176:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010617c:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010617f:	e8 0d cf ff ff       	call   80103091 <mycpu>
80106184:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
8010618a:	b8 28 00 00 00       	mov    $0x28,%eax
8010618f:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106192:	8b 46 0c             	mov    0xc(%esi),%eax
80106195:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010619a:	0f 22 d8             	mov    %eax,%cr3
  popcli();
8010619d:	e8 ae d8 ff ff       	call   80103a50 <popcli>
}
801061a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061a5:	5b                   	pop    %ebx
801061a6:	5e                   	pop    %esi
801061a7:	5f                   	pop    %edi
801061a8:	5d                   	pop    %ebp
801061a9:	c3                   	ret    
    panic("switchuvm: no process");
801061aa:	83 ec 0c             	sub    $0xc,%esp
801061ad:	68 5a 70 10 80       	push   $0x8010705a
801061b2:	e8 8a a1 ff ff       	call   80100341 <panic>
    panic("switchuvm: no kstack");
801061b7:	83 ec 0c             	sub    $0xc,%esp
801061ba:	68 70 70 10 80       	push   $0x80107070
801061bf:	e8 7d a1 ff ff       	call   80100341 <panic>
    panic("switchuvm: no pgdir");
801061c4:	83 ec 0c             	sub    $0xc,%esp
801061c7:	68 85 70 10 80       	push   $0x80107085
801061cc:	e8 70 a1 ff ff       	call   80100341 <panic>

801061d1 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801061d1:	55                   	push   %ebp
801061d2:	89 e5                	mov    %esp,%ebp
801061d4:	56                   	push   %esi
801061d5:	53                   	push   %ebx
801061d6:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
801061d9:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801061df:	77 4b                	ja     8010622c <inituvm+0x5b>
    panic("inituvm: more than a page");
  mem = kalloc();
801061e1:	e8 48 be ff ff       	call   8010202e <kalloc>
801061e6:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
801061e8:	83 ec 04             	sub    $0x4,%esp
801061eb:	68 00 10 00 00       	push   $0x1000
801061f0:	6a 00                	push   $0x0
801061f2:	50                   	push   %eax
801061f3:	e8 a3 d9 ff ff       	call   80103b9b <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801061f8:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
801061ff:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106205:	50                   	push   %eax
80106206:	68 00 10 00 00       	push   $0x1000
8010620b:	6a 00                	push   $0x0
8010620d:	ff 75 08             	push   0x8(%ebp)
80106210:	e8 dc fd ff ff       	call   80105ff1 <mappages>
  memmove(mem, init, sz);
80106215:	83 c4 1c             	add    $0x1c,%esp
80106218:	56                   	push   %esi
80106219:	ff 75 0c             	push   0xc(%ebp)
8010621c:	53                   	push   %ebx
8010621d:	e8 ef d9 ff ff       	call   80103c11 <memmove>
}
80106222:	83 c4 10             	add    $0x10,%esp
80106225:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106228:	5b                   	pop    %ebx
80106229:	5e                   	pop    %esi
8010622a:	5d                   	pop    %ebp
8010622b:	c3                   	ret    
    panic("inituvm: more than a page");
8010622c:	83 ec 0c             	sub    $0xc,%esp
8010622f:	68 99 70 10 80       	push   $0x80107099
80106234:	e8 08 a1 ff ff       	call   80100341 <panic>

80106239 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106239:	55                   	push   %ebp
8010623a:	89 e5                	mov    %esp,%ebp
8010623c:	57                   	push   %edi
8010623d:	56                   	push   %esi
8010623e:	53                   	push   %ebx
8010623f:	83 ec 0c             	sub    $0xc,%esp
80106242:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106245:	89 fb                	mov    %edi,%ebx
80106247:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
8010624d:	74 3c                	je     8010628b <loaduvm+0x52>
    panic("loaduvm: addr must be page aligned");
8010624f:	83 ec 0c             	sub    $0xc,%esp
80106252:	68 54 71 10 80       	push   $0x80107154
80106257:	e8 e5 a0 ff ff       	call   80100341 <panic>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
8010625c:	83 ec 0c             	sub    $0xc,%esp
8010625f:	68 b3 70 10 80       	push   $0x801070b3
80106264:	e8 d8 a0 ff ff       	call   80100341 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106269:	05 00 00 00 80       	add    $0x80000000,%eax
8010626e:	56                   	push   %esi
8010626f:	89 da                	mov    %ebx,%edx
80106271:	03 55 14             	add    0x14(%ebp),%edx
80106274:	52                   	push   %edx
80106275:	50                   	push   %eax
80106276:	ff 75 10             	push   0x10(%ebp)
80106279:	e8 7c b4 ff ff       	call   801016fa <readi>
8010627e:	83 c4 10             	add    $0x10,%esp
80106281:	39 f0                	cmp    %esi,%eax
80106283:	75 47                	jne    801062cc <loaduvm+0x93>
  for(i = 0; i < sz; i += PGSIZE){
80106285:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010628b:	3b 5d 18             	cmp    0x18(%ebp),%ebx
8010628e:	73 2f                	jae    801062bf <loaduvm+0x86>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106290:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
80106293:	b9 00 00 00 00       	mov    $0x0,%ecx
80106298:	8b 45 08             	mov    0x8(%ebp),%eax
8010629b:	e8 10 fa ff ff       	call   80105cb0 <walkpgdir>
801062a0:	85 c0                	test   %eax,%eax
801062a2:	74 b8                	je     8010625c <loaduvm+0x23>
    pa = PTE_ADDR(*pte);
801062a4:	8b 00                	mov    (%eax),%eax
801062a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801062ab:	8b 75 18             	mov    0x18(%ebp),%esi
801062ae:	29 de                	sub    %ebx,%esi
801062b0:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801062b6:	76 b1                	jbe    80106269 <loaduvm+0x30>
      n = PGSIZE;
801062b8:	be 00 10 00 00       	mov    $0x1000,%esi
801062bd:	eb aa                	jmp    80106269 <loaduvm+0x30>
      return -1;
  }
  return 0;
801062bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062c7:	5b                   	pop    %ebx
801062c8:	5e                   	pop    %esi
801062c9:	5f                   	pop    %edi
801062ca:	5d                   	pop    %ebp
801062cb:	c3                   	ret    
      return -1;
801062cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d1:	eb f1                	jmp    801062c4 <loaduvm+0x8b>

801062d3 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801062d3:	55                   	push   %ebp
801062d4:	89 e5                	mov    %esp,%ebp
801062d6:	57                   	push   %edi
801062d7:	56                   	push   %esi
801062d8:	53                   	push   %ebx
801062d9:	83 ec 0c             	sub    $0xc,%esp
801062dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801062df:	39 7d 10             	cmp    %edi,0x10(%ebp)
801062e2:	73 11                	jae    801062f5 <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
801062e4:	8b 45 10             	mov    0x10(%ebp),%eax
801062e7:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801062ed:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801062f3:	eb 17                	jmp    8010630c <deallocuvm+0x39>
    return oldsz;
801062f5:	89 f8                	mov    %edi,%eax
801062f7:	eb 62                	jmp    8010635b <deallocuvm+0x88>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801062f9:	c1 eb 16             	shr    $0x16,%ebx
801062fc:	43                   	inc    %ebx
801062fd:	c1 e3 16             	shl    $0x16,%ebx
80106300:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106306:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010630c:	39 fb                	cmp    %edi,%ebx
8010630e:	73 48                	jae    80106358 <deallocuvm+0x85>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106310:	b9 00 00 00 00       	mov    $0x0,%ecx
80106315:	89 da                	mov    %ebx,%edx
80106317:	8b 45 08             	mov    0x8(%ebp),%eax
8010631a:	e8 91 f9 ff ff       	call   80105cb0 <walkpgdir>
8010631f:	89 c6                	mov    %eax,%esi
    if(!pte)
80106321:	85 c0                	test   %eax,%eax
80106323:	74 d4                	je     801062f9 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
80106325:	8b 00                	mov    (%eax),%eax
80106327:	a8 01                	test   $0x1,%al
80106329:	74 db                	je     80106306 <deallocuvm+0x33>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
8010632b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106330:	74 19                	je     8010634b <deallocuvm+0x78>
        panic("kfree");
      char *v = P2V(pa);
80106332:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106337:	83 ec 0c             	sub    $0xc,%esp
8010633a:	50                   	push   %eax
8010633b:	e8 d7 bb ff ff       	call   80101f17 <kfree>
      *pte = 0;
80106340:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80106346:	83 c4 10             	add    $0x10,%esp
80106349:	eb bb                	jmp    80106306 <deallocuvm+0x33>
        panic("kfree");
8010634b:	83 ec 0c             	sub    $0xc,%esp
8010634e:	68 86 69 10 80       	push   $0x80106986
80106353:	e8 e9 9f ff ff       	call   80100341 <panic>
    }
  }
  return newsz;
80106358:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010635b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010635e:	5b                   	pop    %ebx
8010635f:	5e                   	pop    %esi
80106360:	5f                   	pop    %edi
80106361:	5d                   	pop    %ebp
80106362:	c3                   	ret    

80106363 <allocuvm>:
{
80106363:	55                   	push   %ebp
80106364:	89 e5                	mov    %esp,%ebp
80106366:	57                   	push   %edi
80106367:	56                   	push   %esi
80106368:	53                   	push   %ebx
80106369:	83 ec 1c             	sub    $0x1c,%esp
8010636c:	8b 7d 08             	mov    0x8(%ebp),%edi
  if(newsz >= KERNBASE)
8010636f:	8b 45 10             	mov    0x10(%ebp),%eax
80106372:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106375:	85 c0                	test   %eax,%eax
80106377:	0f 88 c1 00 00 00    	js     8010643e <allocuvm+0xdb>
  if(newsz < oldsz)
8010637d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106380:	39 45 10             	cmp    %eax,0x10(%ebp)
80106383:	72 5c                	jb     801063e1 <allocuvm+0x7e>
  a = PGROUNDUP(oldsz);
80106385:	8b 45 0c             	mov    0xc(%ebp),%eax
80106388:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
8010638e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
80106394:	3b 75 10             	cmp    0x10(%ebp),%esi
80106397:	0f 83 a8 00 00 00    	jae    80106445 <allocuvm+0xe2>
    mem = kalloc();//Cojo la página física
8010639d:	e8 8c bc ff ff       	call   8010202e <kalloc>
801063a2:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
801063a4:	85 c0                	test   %eax,%eax
801063a6:	74 3e                	je     801063e6 <allocuvm+0x83>
    memset(mem, 0, PGSIZE);//Ponemos la página a 0 para vaciarla de datos de cara al usuario 
801063a8:	83 ec 04             	sub    $0x4,%esp
801063ab:	68 00 10 00 00       	push   $0x1000
801063b0:	6a 00                	push   $0x0
801063b2:	50                   	push   %eax
801063b3:	e8 e3 d7 ff ff       	call   80103b9b <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){//mapeo la página en la TP
801063b8:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
801063bf:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801063c5:	50                   	push   %eax
801063c6:	68 00 10 00 00       	push   $0x1000
801063cb:	56                   	push   %esi
801063cc:	57                   	push   %edi
801063cd:	e8 1f fc ff ff       	call   80105ff1 <mappages>
801063d2:	83 c4 20             	add    $0x20,%esp
801063d5:	85 c0                	test   %eax,%eax
801063d7:	78 35                	js     8010640e <allocuvm+0xab>
  for(; a < newsz; a += PGSIZE){
801063d9:	81 c6 00 10 00 00    	add    $0x1000,%esi
801063df:	eb b3                	jmp    80106394 <allocuvm+0x31>
    return oldsz;
801063e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801063e4:	eb 5f                	jmp    80106445 <allocuvm+0xe2>
      cprintf("allocuvm out of memory\n");
801063e6:	83 ec 0c             	sub    $0xc,%esp
801063e9:	68 d1 70 10 80       	push   $0x801070d1
801063ee:	e8 e7 a1 ff ff       	call   801005da <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801063f3:	83 c4 0c             	add    $0xc,%esp
801063f6:	ff 75 0c             	push   0xc(%ebp)
801063f9:	ff 75 10             	push   0x10(%ebp)
801063fc:	57                   	push   %edi
801063fd:	e8 d1 fe ff ff       	call   801062d3 <deallocuvm>
      return 0;
80106402:	83 c4 10             	add    $0x10,%esp
80106405:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010640c:	eb 37                	jmp    80106445 <allocuvm+0xe2>
      cprintf("allocuvm out of memory (2)\n");
8010640e:	83 ec 0c             	sub    $0xc,%esp
80106411:	68 e9 70 10 80       	push   $0x801070e9
80106416:	e8 bf a1 ff ff       	call   801005da <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010641b:	83 c4 0c             	add    $0xc,%esp
8010641e:	ff 75 0c             	push   0xc(%ebp)
80106421:	ff 75 10             	push   0x10(%ebp)
80106424:	57                   	push   %edi
80106425:	e8 a9 fe ff ff       	call   801062d3 <deallocuvm>
      kfree(mem);
8010642a:	89 1c 24             	mov    %ebx,(%esp)
8010642d:	e8 e5 ba ff ff       	call   80101f17 <kfree>
      return 0;
80106432:	83 c4 10             	add    $0x10,%esp
80106435:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010643c:	eb 07                	jmp    80106445 <allocuvm+0xe2>
    return 0;
8010643e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106445:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106448:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010644b:	5b                   	pop    %ebx
8010644c:	5e                   	pop    %esi
8010644d:	5f                   	pop    %edi
8010644e:	5d                   	pop    %ebp
8010644f:	c3                   	ret    

80106450 <freevm>:

// Free a page table and all the physical memory pages
// in the user part if dodeallocuvm is not zero
void
freevm(pde_t *pgdir, int dodeallocuvm)
{
80106450:	55                   	push   %ebp
80106451:	89 e5                	mov    %esp,%ebp
80106453:	56                   	push   %esi
80106454:	53                   	push   %ebx
80106455:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106458:	85 f6                	test   %esi,%esi
8010645a:	74 0d                	je     80106469 <freevm+0x19>
    panic("freevm: no pgdir");
  if (dodeallocuvm)
8010645c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106460:	75 14                	jne    80106476 <freevm+0x26>
{
80106462:	bb 00 00 00 00       	mov    $0x0,%ebx
80106467:	eb 23                	jmp    8010648c <freevm+0x3c>
    panic("freevm: no pgdir");
80106469:	83 ec 0c             	sub    $0xc,%esp
8010646c:	68 05 71 10 80       	push   $0x80107105
80106471:	e8 cb 9e ff ff       	call   80100341 <panic>
    deallocuvm(pgdir, KERNBASE, 0);
80106476:	83 ec 04             	sub    $0x4,%esp
80106479:	6a 00                	push   $0x0
8010647b:	68 00 00 00 80       	push   $0x80000000
80106480:	56                   	push   %esi
80106481:	e8 4d fe ff ff       	call   801062d3 <deallocuvm>
80106486:	83 c4 10             	add    $0x10,%esp
80106489:	eb d7                	jmp    80106462 <freevm+0x12>
  for(i = 0; i < NPDENTRIES; i++){
8010648b:	43                   	inc    %ebx
8010648c:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106492:	77 1f                	ja     801064b3 <freevm+0x63>
    if(pgdir[i] & PTE_P){
80106494:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
80106497:	a8 01                	test   $0x1,%al
80106499:	74 f0                	je     8010648b <freevm+0x3b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010649b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801064a0:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801064a5:	83 ec 0c             	sub    $0xc,%esp
801064a8:	50                   	push   %eax
801064a9:	e8 69 ba ff ff       	call   80101f17 <kfree>
801064ae:	83 c4 10             	add    $0x10,%esp
801064b1:	eb d8                	jmp    8010648b <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
801064b3:	83 ec 0c             	sub    $0xc,%esp
801064b6:	56                   	push   %esi
801064b7:	e8 5b ba ff ff       	call   80101f17 <kfree>
}
801064bc:	83 c4 10             	add    $0x10,%esp
801064bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
801064c2:	5b                   	pop    %ebx
801064c3:	5e                   	pop    %esi
801064c4:	5d                   	pop    %ebp
801064c5:	c3                   	ret    

801064c6 <setupkvm>:
{
801064c6:	55                   	push   %ebp
801064c7:	89 e5                	mov    %esp,%ebp
801064c9:	56                   	push   %esi
801064ca:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
801064cb:	e8 5e bb ff ff       	call   8010202e <kalloc>
801064d0:	89 c6                	mov    %eax,%esi
801064d2:	85 c0                	test   %eax,%eax
801064d4:	74 57                	je     8010652d <setupkvm+0x67>
  memset(pgdir, 0, PGSIZE);
801064d6:	83 ec 04             	sub    $0x4,%esp
801064d9:	68 00 10 00 00       	push   $0x1000
801064de:	6a 00                	push   $0x0
801064e0:	50                   	push   %eax
801064e1:	e8 b5 d6 ff ff       	call   80103b9b <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801064e6:	83 c4 10             	add    $0x10,%esp
801064e9:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
801064ee:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
801064f4:	73 37                	jae    8010652d <setupkvm+0x67>
                (uint)k->phys_start, k->perm) < 0) {
801064f6:	8b 53 04             	mov    0x4(%ebx),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801064f9:	83 ec 0c             	sub    $0xc,%esp
801064fc:	ff 73 0c             	push   0xc(%ebx)
801064ff:	52                   	push   %edx
80106500:	8b 43 08             	mov    0x8(%ebx),%eax
80106503:	29 d0                	sub    %edx,%eax
80106505:	50                   	push   %eax
80106506:	ff 33                	push   (%ebx)
80106508:	56                   	push   %esi
80106509:	e8 e3 fa ff ff       	call   80105ff1 <mappages>
8010650e:	83 c4 20             	add    $0x20,%esp
80106511:	85 c0                	test   %eax,%eax
80106513:	78 05                	js     8010651a <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106515:	83 c3 10             	add    $0x10,%ebx
80106518:	eb d4                	jmp    801064ee <setupkvm+0x28>
      freevm(pgdir, 0);
8010651a:	83 ec 08             	sub    $0x8,%esp
8010651d:	6a 00                	push   $0x0
8010651f:	56                   	push   %esi
80106520:	e8 2b ff ff ff       	call   80106450 <freevm>
      return 0;
80106525:	83 c4 10             	add    $0x10,%esp
80106528:	be 00 00 00 00       	mov    $0x0,%esi
}
8010652d:	89 f0                	mov    %esi,%eax
8010652f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106532:	5b                   	pop    %ebx
80106533:	5e                   	pop    %esi
80106534:	5d                   	pop    %ebp
80106535:	c3                   	ret    

80106536 <kvmalloc>:
{
80106536:	55                   	push   %ebp
80106537:	89 e5                	mov    %esp,%ebp
80106539:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010653c:	e8 85 ff ff ff       	call   801064c6 <setupkvm>
80106541:	a3 c4 46 11 80       	mov    %eax,0x801146c4
  switchkvm();
80106546:	e8 1c fb ff ff       	call   80106067 <switchkvm>
}
8010654b:	c9                   	leave  
8010654c:	c3                   	ret    

8010654d <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010654d:	55                   	push   %ebp
8010654e:	89 e5                	mov    %esp,%ebp
80106550:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106553:	b9 00 00 00 00       	mov    $0x0,%ecx
80106558:	8b 55 0c             	mov    0xc(%ebp),%edx
8010655b:	8b 45 08             	mov    0x8(%ebp),%eax
8010655e:	e8 4d f7 ff ff       	call   80105cb0 <walkpgdir>
  if(pte == 0)
80106563:	85 c0                	test   %eax,%eax
80106565:	74 05                	je     8010656c <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106567:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010656a:	c9                   	leave  
8010656b:	c3                   	ret    
    panic("clearpteu");
8010656c:	83 ec 0c             	sub    $0xc,%esp
8010656f:	68 16 71 10 80       	push   $0x80107116
80106574:	e8 c8 9d ff ff       	call   80100341 <panic>

80106579 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106579:	55                   	push   %ebp
8010657a:	89 e5                	mov    %esp,%ebp
8010657c:	57                   	push   %edi
8010657d:	56                   	push   %esi
8010657e:	53                   	push   %ebx
8010657f:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106582:	e8 3f ff ff ff       	call   801064c6 <setupkvm>
80106587:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010658a:	85 c0                	test   %eax,%eax
8010658c:	0f 84 c6 00 00 00    	je     80106658 <copyuvm+0xdf>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106592:	bb 00 00 00 00       	mov    $0x0,%ebx
80106597:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
8010659a:	0f 83 b8 00 00 00    	jae    80106658 <copyuvm+0xdf>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801065a0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801065a3:	b9 00 00 00 00       	mov    $0x0,%ecx
801065a8:	89 da                	mov    %ebx,%edx
801065aa:	8b 45 08             	mov    0x8(%ebp),%eax
801065ad:	e8 fe f6 ff ff       	call   80105cb0 <walkpgdir>
801065b2:	85 c0                	test   %eax,%eax
801065b4:	74 65                	je     8010661b <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
801065b6:	8b 00                	mov    (%eax),%eax
801065b8:	a8 01                	test   $0x1,%al
801065ba:	74 6c                	je     80106628 <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
801065bc:	89 c6                	mov    %eax,%esi
801065be:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
801065c4:	25 ff 0f 00 00       	and    $0xfff,%eax
801065c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
801065cc:	e8 5d ba ff ff       	call   8010202e <kalloc>
801065d1:	89 c7                	mov    %eax,%edi
801065d3:	85 c0                	test   %eax,%eax
801065d5:	74 6a                	je     80106641 <copyuvm+0xc8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801065d7:	81 c6 00 00 00 80    	add    $0x80000000,%esi
801065dd:	83 ec 04             	sub    $0x4,%esp
801065e0:	68 00 10 00 00       	push   $0x1000
801065e5:	56                   	push   %esi
801065e6:	50                   	push   %eax
801065e7:	e8 25 d6 ff ff       	call   80103c11 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801065ec:	83 c4 04             	add    $0x4,%esp
801065ef:	ff 75 e0             	push   -0x20(%ebp)
801065f2:	8d 87 00 00 00 80    	lea    -0x80000000(%edi),%eax
801065f8:	50                   	push   %eax
801065f9:	68 00 10 00 00       	push   $0x1000
801065fe:	ff 75 e4             	push   -0x1c(%ebp)
80106601:	ff 75 dc             	push   -0x24(%ebp)
80106604:	e8 e8 f9 ff ff       	call   80105ff1 <mappages>
80106609:	83 c4 20             	add    $0x20,%esp
8010660c:	85 c0                	test   %eax,%eax
8010660e:	78 25                	js     80106635 <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
80106610:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106616:	e9 7c ff ff ff       	jmp    80106597 <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
8010661b:	83 ec 0c             	sub    $0xc,%esp
8010661e:	68 20 71 10 80       	push   $0x80107120
80106623:	e8 19 9d ff ff       	call   80100341 <panic>
      panic("copyuvm: page not present");
80106628:	83 ec 0c             	sub    $0xc,%esp
8010662b:	68 3a 71 10 80       	push   $0x8010713a
80106630:	e8 0c 9d ff ff       	call   80100341 <panic>
      kfree(mem);
80106635:	83 ec 0c             	sub    $0xc,%esp
80106638:	57                   	push   %edi
80106639:	e8 d9 b8 ff ff       	call   80101f17 <kfree>
      goto bad;
8010663e:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d, 1);
80106641:	83 ec 08             	sub    $0x8,%esp
80106644:	6a 01                	push   $0x1
80106646:	ff 75 dc             	push   -0x24(%ebp)
80106649:	e8 02 fe ff ff       	call   80106450 <freevm>
  return 0;
8010664e:	83 c4 10             	add    $0x10,%esp
80106651:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106658:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010665b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010665e:	5b                   	pop    %ebx
8010665f:	5e                   	pop    %esi
80106660:	5f                   	pop    %edi
80106661:	5d                   	pop    %ebp
80106662:	c3                   	ret    

80106663 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106663:	55                   	push   %ebp
80106664:	89 e5                	mov    %esp,%ebp
80106666:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106669:	b9 00 00 00 00       	mov    $0x0,%ecx
8010666e:	8b 55 0c             	mov    0xc(%ebp),%edx
80106671:	8b 45 08             	mov    0x8(%ebp),%eax
80106674:	e8 37 f6 ff ff       	call   80105cb0 <walkpgdir>
  if((*pte & PTE_P) == 0)
80106679:	8b 00                	mov    (%eax),%eax
8010667b:	a8 01                	test   $0x1,%al
8010667d:	74 10                	je     8010668f <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
8010667f:	a8 04                	test   $0x4,%al
80106681:	74 13                	je     80106696 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
80106683:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106688:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010668d:	c9                   	leave  
8010668e:	c3                   	ret    
    return 0;
8010668f:	b8 00 00 00 00       	mov    $0x0,%eax
80106694:	eb f7                	jmp    8010668d <uva2ka+0x2a>
    return 0;
80106696:	b8 00 00 00 00       	mov    $0x0,%eax
8010669b:	eb f0                	jmp    8010668d <uva2ka+0x2a>

8010669d <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010669d:	55                   	push   %ebp
8010669e:	89 e5                	mov    %esp,%ebp
801066a0:	57                   	push   %edi
801066a1:	56                   	push   %esi
801066a2:	53                   	push   %ebx
801066a3:	83 ec 0c             	sub    $0xc,%esp
801066a6:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801066a9:	eb 25                	jmp    801066d0 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801066ab:	8b 55 0c             	mov    0xc(%ebp),%edx
801066ae:	29 f2                	sub    %esi,%edx
801066b0:	01 d0                	add    %edx,%eax
801066b2:	83 ec 04             	sub    $0x4,%esp
801066b5:	53                   	push   %ebx
801066b6:	ff 75 10             	push   0x10(%ebp)
801066b9:	50                   	push   %eax
801066ba:	e8 52 d5 ff ff       	call   80103c11 <memmove>
    len -= n;
801066bf:	29 df                	sub    %ebx,%edi
    buf += n;
801066c1:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
801066c4:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
801066ca:	89 45 0c             	mov    %eax,0xc(%ebp)
801066cd:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
801066d0:	85 ff                	test   %edi,%edi
801066d2:	74 2f                	je     80106703 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
801066d4:	8b 75 0c             	mov    0xc(%ebp),%esi
801066d7:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801066dd:	83 ec 08             	sub    $0x8,%esp
801066e0:	56                   	push   %esi
801066e1:	ff 75 08             	push   0x8(%ebp)
801066e4:	e8 7a ff ff ff       	call   80106663 <uva2ka>
    if(pa0 == 0)
801066e9:	83 c4 10             	add    $0x10,%esp
801066ec:	85 c0                	test   %eax,%eax
801066ee:	74 20                	je     80106710 <copyout+0x73>
    n = PGSIZE - (va - va0);
801066f0:	89 f3                	mov    %esi,%ebx
801066f2:	2b 5d 0c             	sub    0xc(%ebp),%ebx
801066f5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
801066fb:	39 df                	cmp    %ebx,%edi
801066fd:	73 ac                	jae    801066ab <copyout+0xe>
      n = len;
801066ff:	89 fb                	mov    %edi,%ebx
80106701:	eb a8                	jmp    801066ab <copyout+0xe>
  }
  return 0;
80106703:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106708:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010670b:	5b                   	pop    %ebx
8010670c:	5e                   	pop    %esi
8010670d:	5f                   	pop    %edi
8010670e:	5d                   	pop    %ebp
8010670f:	c3                   	ret    
      return -1;
80106710:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106715:	eb f1                	jmp    80106708 <copyout+0x6b>
