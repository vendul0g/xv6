
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
8010002d:	b8 a9 29 10 80       	mov    $0x801029a9,%eax
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
80100046:	e8 af 3a 00 00       	call   80103afa <acquire>

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
8010007a:	e8 e0 3a 00 00       	call   80103b5f <release>
      acquiresleep(&b->lock);
8010007f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100082:	89 04 24             	mov    %eax,(%esp)
80100085:	e8 61 38 00 00       	call   801038eb <acquiresleep>
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
801000c8:	e8 92 3a 00 00       	call   80103b5f <release>
      acquiresleep(&b->lock);
801000cd:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d0:	89 04 24             	mov    %eax,(%esp)
801000d3:	e8 13 38 00 00       	call   801038eb <acquiresleep>
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
801000e8:	68 40 69 10 80       	push   $0x80106940
801000ed:	e8 4f 02 00 00       	call   80100341 <panic>

801000f2 <binit>:
{
801000f2:	55                   	push   %ebp
801000f3:	89 e5                	mov    %esp,%ebp
801000f5:	53                   	push   %ebx
801000f6:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000f9:	68 51 69 10 80       	push   $0x80106951
801000fe:	68 20 a5 10 80       	push   $0x8010a520
80100103:	e8 bb 38 00 00       	call   801039c3 <initlock>
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
80100138:	68 58 69 10 80       	push   $0x80106958
8010013d:	8d 43 0c             	lea    0xc(%ebx),%eax
80100140:	50                   	push   %eax
80100141:	e8 72 37 00 00       	call   801038b8 <initsleeplock>
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
8010018e:	e8 01 1c 00 00       	call   80101d94 <iderw>
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
801001a6:	e8 ca 37 00 00       	call   80103975 <holdingsleep>
801001ab:	83 c4 10             	add    $0x10,%esp
801001ae:	85 c0                	test   %eax,%eax
801001b0:	74 14                	je     801001c6 <bwrite+0x2e>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001b2:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001b5:	83 ec 0c             	sub    $0xc,%esp
801001b8:	53                   	push   %ebx
801001b9:	e8 d6 1b 00 00       	call   80101d94 <iderw>
}
801001be:	83 c4 10             	add    $0x10,%esp
801001c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c4:	c9                   	leave  
801001c5:	c3                   	ret    
    panic("bwrite");
801001c6:	83 ec 0c             	sub    $0xc,%esp
801001c9:	68 5f 69 10 80       	push   $0x8010695f
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
801001e2:	e8 8e 37 00 00       	call   80103975 <holdingsleep>
801001e7:	83 c4 10             	add    $0x10,%esp
801001ea:	85 c0                	test   %eax,%eax
801001ec:	74 69                	je     80100257 <brelse+0x84>
    panic("brelse");

  releasesleep(&b->lock);
801001ee:	83 ec 0c             	sub    $0xc,%esp
801001f1:	56                   	push   %esi
801001f2:	e8 43 37 00 00       	call   8010393a <releasesleep>

  acquire(&bcache.lock);
801001f7:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801001fe:	e8 f7 38 00 00       	call   80103afa <acquire>
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
80100248:	e8 12 39 00 00       	call   80103b5f <release>
}
8010024d:	83 c4 10             	add    $0x10,%esp
80100250:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100253:	5b                   	pop    %ebx
80100254:	5e                   	pop    %esi
80100255:	5d                   	pop    %ebp
80100256:	c3                   	ret    
    panic("brelse");
80100257:	83 ec 0c             	sub    $0xc,%esp
8010025a:	68 66 69 10 80       	push   $0x80106966
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
80100277:	e8 61 13 00 00       	call   801015dd <iunlock>
  target = n;
8010027c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
8010027f:	c7 04 24 20 ef 10 80 	movl   $0x8010ef20,(%esp)
80100286:	e8 6f 38 00 00       	call   80103afa <acquire>
  while(n > 0){
8010028b:	83 c4 10             	add    $0x10,%esp
8010028e:	85 db                	test   %ebx,%ebx
80100290:	0f 8e 8c 00 00 00    	jle    80100322 <consoleread+0xbe>
    while(input.r == input.w){
80100296:	a1 00 ef 10 80       	mov    0x8010ef00,%eax
8010029b:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
801002a1:	75 47                	jne    801002ea <consoleread+0x86>
      if(myproc()->killed){
801002a3:	e8 8e 2e 00 00       	call   80103136 <myproc>
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
801002bb:	e8 34 33 00 00       	call   801035f4 <sleep>
801002c0:	83 c4 10             	add    $0x10,%esp
801002c3:	eb d1                	jmp    80100296 <consoleread+0x32>
        release(&cons.lock);
801002c5:	83 ec 0c             	sub    $0xc,%esp
801002c8:	68 20 ef 10 80       	push   $0x8010ef20
801002cd:	e8 8d 38 00 00       	call   80103b5f <release>
        ilock(ip);
801002d2:	89 3c 24             	mov    %edi,(%esp)
801002d5:	e8 43 12 00 00       	call   8010151d <ilock>
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
8010032a:	e8 30 38 00 00       	call   80103b5f <release>
  ilock(ip);
8010032f:	89 3c 24             	mov    %edi,(%esp)
80100332:	e8 e6 11 00 00       	call   8010151d <ilock>
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
80100353:	e8 a2 1f 00 00       	call   801022fa <lapicid>
80100358:	83 ec 08             	sub    $0x8,%esp
8010035b:	50                   	push   %eax
8010035c:	68 6d 69 10 80       	push   $0x8010696d
80100361:	e8 74 02 00 00       	call   801005da <cprintf>
  cprintf(s);
80100366:	83 c4 04             	add    $0x4,%esp
80100369:	ff 75 08             	push   0x8(%ebp)
8010036c:	e8 69 02 00 00       	call   801005da <cprintf>
  cprintf("\n");
80100371:	c7 04 24 73 73 10 80 	movl   $0x80107373,(%esp)
80100378:	e8 5d 02 00 00       	call   801005da <cprintf>
  getcallerpcs(&s, pcs);
8010037d:	83 c4 08             	add    $0x8,%esp
80100380:	8d 45 d0             	lea    -0x30(%ebp),%eax
80100383:	50                   	push   %eax
80100384:	8d 45 08             	lea    0x8(%ebp),%eax
80100387:	50                   	push   %eax
80100388:	e8 51 36 00 00       	call   801039de <getcallerpcs>
  for(i=0; i<10; i++)
8010038d:	83 c4 10             	add    $0x10,%esp
80100390:	bb 00 00 00 00       	mov    $0x0,%ebx
80100395:	eb 15                	jmp    801003ac <panic+0x6b>
    cprintf(" %p", pcs[i]);
80100397:	83 ec 08             	sub    $0x8,%esp
8010039a:	ff 74 9d d0          	push   -0x30(%ebp,%ebx,4)
8010039e:	68 81 69 10 80       	push   $0x80106981
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
8010046c:	68 85 69 10 80       	push   $0x80106985
80100471:	e8 cb fe ff ff       	call   80100341 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100476:	83 ec 04             	sub    $0x4,%esp
80100479:	68 60 0e 00 00       	push   $0xe60
8010047e:	68 a0 80 0b 80       	push   $0x800b80a0
80100483:	68 00 80 0b 80       	push   $0x800b8000
80100488:	e8 8f 37 00 00       	call   80103c1c <memmove>
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
801004a7:	e8 fa 36 00 00       	call   80103ba6 <memset>
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
801004d4:	e8 92 4d 00 00       	call   8010526b <uartputc>
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
801004ed:	e8 79 4d 00 00       	call   8010526b <uartputc>
801004f2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801004f9:	e8 6d 4d 00 00       	call   8010526b <uartputc>
801004fe:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100505:	e8 61 4d 00 00       	call   8010526b <uartputc>
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
80100540:	8a 92 b0 69 10 80    	mov    -0x7fef9650(%edx),%dl
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
8010058f:	e8 49 10 00 00       	call   801015dd <iunlock>
  acquire(&cons.lock);
80100594:	c7 04 24 20 ef 10 80 	movl   $0x8010ef20,(%esp)
8010059b:	e8 5a 35 00 00       	call   80103afa <acquire>
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
801005c0:	e8 9a 35 00 00       	call   80103b5f <release>
  ilock(ip);
801005c5:	83 c4 04             	add    $0x4,%esp
801005c8:	ff 75 08             	push   0x8(%ebp)
801005cb:	e8 4d 0f 00 00       	call   8010151d <ilock>

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
80100607:	e8 ee 34 00 00       	call   80103afa <acquire>
8010060c:	83 c4 10             	add    $0x10,%esp
8010060f:	eb de                	jmp    801005ef <cprintf+0x15>
    panic("null fmt");
80100611:	83 ec 0c             	sub    $0xc,%esp
80100614:	68 9f 69 10 80       	push   $0x8010699f
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
8010069c:	bb 98 69 10 80       	mov    $0x80106998,%ebx
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
801006f5:	e8 65 34 00 00       	call   80103b5f <release>
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
80100710:	e8 e5 33 00 00       	call   80103afa <acquire>
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
801007b8:	e8 a9 2f 00 00       	call   80103766 <wakeup>
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
80100831:	e8 29 33 00 00       	call   80103b5f <release>
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
80100845:	e8 bb 2f 00 00       	call   80103805 <procdump>
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
80100852:	68 a8 69 10 80       	push   $0x801069a8
80100857:	68 20 ef 10 80       	push   $0x8010ef20
8010085c:	e8 62 31 00 00       	call   801039c3 <initlock>

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
80100886:	e8 71 16 00 00       	call   80101efc <ioapicenable>
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
  uint argc, sz, sp, ustack[3+MAXARG+1], stack_end;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
8010089c:	e8 95 28 00 00       	call   80103136 <myproc>
801008a1:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
801008a7:	e8 47 1e 00 00       	call   801026f3 <begin_op>

  if((ip = namei(path)) == 0){
801008ac:	83 ec 0c             	sub    $0xc,%esp
801008af:	ff 75 08             	push   0x8(%ebp)
801008b2:	e8 ca 12 00 00       	call   80101b81 <namei>
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
801008c4:	e8 54 0c 00 00       	call   8010151d <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
801008c9:	6a 34                	push   $0x34
801008cb:	6a 00                	push   $0x0
801008cd:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
801008d3:	50                   	push   %eax
801008d4:	53                   	push   %ebx
801008d5:	e8 30 0e 00 00       	call   8010170a <readi>
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
801008f0:	0f 84 e3 02 00 00    	je     80100bd9 <exec+0x349>
    iunlockput(ip);
801008f6:	83 ec 0c             	sub    $0xc,%esp
801008f9:	53                   	push   %ebx
801008fa:	e8 c1 0d 00 00       	call   801016c0 <iunlockput>
    end_op();
801008ff:	e8 6b 1e 00 00       	call   8010276f <end_op>
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
80100914:	e8 56 1e 00 00       	call   8010276f <end_op>
    cprintf("exec: fail\n");
80100919:	83 ec 0c             	sub    $0xc,%esp
8010091c:	68 c1 69 10 80       	push   $0x801069c1
80100921:	e8 b4 fc ff ff       	call   801005da <cprintf>
    return -1;
80100926:	83 c4 10             	add    $0x10,%esp
80100929:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010092e:	eb dc                	jmp    8010090c <exec+0x7c>
  if((pgdir = setupkvm()) == 0)
80100930:	e8 d4 5c 00 00       	call   80106609 <setupkvm>
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
8010097a:	e8 8b 0d 00 00       	call   8010170a <readi>
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
801009c6:	e8 db 5a 00 00       	call   801064a6 <allocuvm>
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
801009fc:	e8 7b 59 00 00       	call   8010637c <loaduvm>
80100a01:	83 c4 20             	add    $0x20,%esp
80100a04:	85 c0                	test   %eax,%eax
80100a06:	0f 89 4e ff ff ff    	jns    8010095a <exec+0xca>
80100a0c:	eb 49                	jmp    80100a57 <exec+0x1c7>
  iunlockput(ip);
80100a0e:	83 ec 0c             	sub    $0xc,%esp
80100a11:	53                   	push   %ebx
80100a12:	e8 a9 0c 00 00       	call   801016c0 <iunlockput>
  end_op();
80100a17:	e8 53 1d 00 00       	call   8010276f <end_op>
  sz = PGROUNDUP(sz);
80100a1c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100a22:	05 ff 0f 00 00       	add    $0xfff,%eax
80100a27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a2c:	83 c4 0c             	add    $0xc,%esp
80100a2f:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a35:	52                   	push   %edx
80100a36:	50                   	push   %eax
80100a37:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100a3d:	56                   	push   %esi
80100a3e:	e8 63 5a 00 00       	call   801064a6 <allocuvm>
80100a43:	89 c7                	mov    %eax,%edi
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
80100a6b:	e8 23 5b 00 00       	call   80106593 <freevm>
80100a70:	83 c4 10             	add    $0x10,%esp
80100a73:	e9 76 fe ff ff       	jmp    801008ee <exec+0x5e>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100a78:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100a7e:	83 ec 08             	sub    $0x8,%esp
80100a81:	50                   	push   %eax
80100a82:	56                   	push   %esi
80100a83:	e8 08 5c 00 00       	call   80106690 <clearpteu>
	stack_end = sp - PGSIZE;//stack_end = final de la pila
80100a88:	8d 8f 00 f0 ff ff    	lea    -0x1000(%edi),%ecx
80100a8e:	89 8d e8 fe ff ff    	mov    %ecx,-0x118(%ebp)
  for(argc = 0; argv[argc]; argc++) {
80100a94:	83 c4 10             	add    $0x10,%esp
  sp = sz;//sp está al comienzo de la pila
80100a97:	89 fe                	mov    %edi,%esi
  for(argc = 0; argv[argc]; argc++) {
80100a99:	bf 00 00 00 00       	mov    $0x0,%edi
80100a9e:	eb 08                	jmp    80100aa8 <exec+0x218>
    ustack[3+argc] = sp;
80100aa0:	89 b4 bd 64 ff ff ff 	mov    %esi,-0x9c(%ebp,%edi,4)
  for(argc = 0; argv[argc]; argc++) {
80100aa7:	47                   	inc    %edi
80100aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100aab:	8d 1c b8             	lea    (%eax,%edi,4),%ebx
80100aae:	8b 03                	mov    (%ebx),%eax
80100ab0:	85 c0                	test   %eax,%eax
80100ab2:	74 43                	je     80100af7 <exec+0x267>
    if(argc >= MAXARG)
80100ab4:	83 ff 1f             	cmp    $0x1f,%edi
80100ab7:	0f 87 12 01 00 00    	ja     80100bcf <exec+0x33f>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100abd:	83 ec 0c             	sub    $0xc,%esp
80100ac0:	50                   	push   %eax
80100ac1:	e8 70 32 00 00       	call   80103d36 <strlen>
80100ac6:	29 c6                	sub    %eax,%esi
80100ac8:	4e                   	dec    %esi
80100ac9:	83 e6 fc             	and    $0xfffffffc,%esi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100acc:	83 c4 04             	add    $0x4,%esp
80100acf:	ff 33                	push   (%ebx)
80100ad1:	e8 60 32 00 00       	call   80103d36 <strlen>
80100ad6:	40                   	inc    %eax
80100ad7:	50                   	push   %eax
80100ad8:	ff 33                	push   (%ebx)
80100ada:	56                   	push   %esi
80100adb:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100ae1:	e8 d4 5d 00 00       	call   801068ba <copyout>
80100ae6:	83 c4 20             	add    $0x20,%esp
80100ae9:	85 c0                	test   %eax,%eax
80100aeb:	79 b3                	jns    80100aa0 <exec+0x210>
  ip = 0;
80100aed:	bb 00 00 00 00       	mov    $0x0,%ebx
80100af2:	e9 60 ff ff ff       	jmp    80100a57 <exec+0x1c7>
  ustack[3+argc] = 0;
80100af7:	89 f1                	mov    %esi,%ecx
80100af9:	89 c3                	mov    %eax,%ebx
80100afb:	c7 84 bd 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%edi,4)
80100b02:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80100b06:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100b0d:	ff ff ff 
  ustack[1] = argc;
80100b10:	89 bd 5c ff ff ff    	mov    %edi,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b16:	8d 14 bd 04 00 00 00 	lea    0x4(,%edi,4),%edx
80100b1d:	89 f0                	mov    %esi,%eax
80100b1f:	29 d0                	sub    %edx,%eax
80100b21:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  sp -= (3+argc+1) * 4;
80100b27:	8d 04 bd 10 00 00 00 	lea    0x10(,%edi,4),%eax
80100b2e:	29 c1                	sub    %eax,%ecx
80100b30:	89 ce                	mov    %ecx,%esi
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b32:	50                   	push   %eax
80100b33:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100b39:	50                   	push   %eax
80100b3a:	51                   	push   %ecx
80100b3b:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100b41:	e8 74 5d 00 00       	call   801068ba <copyout>
80100b46:	83 c4 10             	add    $0x10,%esp
80100b49:	85 c0                	test   %eax,%eax
80100b4b:	0f 88 06 ff ff ff    	js     80100a57 <exec+0x1c7>
  for(last=s=path; *s; s++)
80100b51:	8b 55 08             	mov    0x8(%ebp),%edx
80100b54:	89 d0                	mov    %edx,%eax
80100b56:	eb 01                	jmp    80100b59 <exec+0x2c9>
80100b58:	40                   	inc    %eax
80100b59:	8a 08                	mov    (%eax),%cl
80100b5b:	84 c9                	test   %cl,%cl
80100b5d:	74 0a                	je     80100b69 <exec+0x2d9>
    if(*s == '/')
80100b5f:	80 f9 2f             	cmp    $0x2f,%cl
80100b62:	75 f4                	jne    80100b58 <exec+0x2c8>
      last = s+1;
80100b64:	8d 50 01             	lea    0x1(%eax),%edx
80100b67:	eb ef                	jmp    80100b58 <exec+0x2c8>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100b69:	8b bd ec fe ff ff    	mov    -0x114(%ebp),%edi
80100b6f:	89 f8                	mov    %edi,%eax
80100b71:	83 c0 74             	add    $0x74,%eax
80100b74:	83 ec 04             	sub    $0x4,%esp
80100b77:	6a 10                	push   $0x10
80100b79:	52                   	push   %edx
80100b7a:	50                   	push   %eax
80100b7b:	e8 7e 31 00 00       	call   80103cfe <safestrcpy>
  oldpgdir = curproc->pgdir;
80100b80:	8b 5f 0c             	mov    0xc(%edi),%ebx
  curproc->pgdir = pgdir;
80100b83:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100b89:	89 4f 0c             	mov    %ecx,0xc(%edi)
  curproc->sz = sz;
80100b8c:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100b92:	89 4f 08             	mov    %ecx,0x8(%edi)
  curproc->tf->eip = elf.entry;  // main
80100b95:	8b 47 20             	mov    0x20(%edi),%eax
80100b98:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100b9e:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100ba1:	8b 47 20             	mov    0x20(%edi),%eax
80100ba4:	89 70 44             	mov    %esi,0x44(%eax)
	curproc->stack_end = stack_end; //end of stack
80100ba7:	8b 8d e8 fe ff ff    	mov    -0x118(%ebp),%ecx
80100bad:	89 0f                	mov    %ecx,(%edi)
  switchuvm(curproc);
80100baf:	89 3c 24             	mov    %edi,(%esp)
80100bb2:	e8 01 56 00 00       	call   801061b8 <switchuvm>
  freevm(oldpgdir, 1);
80100bb7:	83 c4 08             	add    $0x8,%esp
80100bba:	6a 01                	push   $0x1
80100bbc:	53                   	push   %ebx
80100bbd:	e8 d1 59 00 00       	call   80106593 <freevm>
  return 0;
80100bc2:	83 c4 10             	add    $0x10,%esp
80100bc5:	b8 00 00 00 00       	mov    $0x0,%eax
80100bca:	e9 3d fd ff ff       	jmp    8010090c <exec+0x7c>
  ip = 0;
80100bcf:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bd4:	e9 7e fe ff ff       	jmp    80100a57 <exec+0x1c7>
  return -1;
80100bd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bde:	e9 29 fd ff ff       	jmp    8010090c <exec+0x7c>

80100be3 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100be3:	55                   	push   %ebp
80100be4:	89 e5                	mov    %esp,%ebp
80100be6:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100be9:	68 cd 69 10 80       	push   $0x801069cd
80100bee:	68 60 ef 10 80       	push   $0x8010ef60
80100bf3:	e8 cb 2d 00 00       	call   801039c3 <initlock>
}
80100bf8:	83 c4 10             	add    $0x10,%esp
80100bfb:	c9                   	leave  
80100bfc:	c3                   	ret    

80100bfd <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100bfd:	55                   	push   %ebp
80100bfe:	89 e5                	mov    %esp,%ebp
80100c00:	53                   	push   %ebx
80100c01:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c04:	68 60 ef 10 80       	push   $0x8010ef60
80100c09:	e8 ec 2e 00 00       	call   80103afa <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c0e:	83 c4 10             	add    $0x10,%esp
80100c11:	bb 94 ef 10 80       	mov    $0x8010ef94,%ebx
80100c16:	81 fb f4 f8 10 80    	cmp    $0x8010f8f4,%ebx
80100c1c:	73 29                	jae    80100c47 <filealloc+0x4a>
    if(f->ref == 0){
80100c1e:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c22:	74 05                	je     80100c29 <filealloc+0x2c>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c24:	83 c3 18             	add    $0x18,%ebx
80100c27:	eb ed                	jmp    80100c16 <filealloc+0x19>
      f->ref = 1;
80100c29:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100c30:	83 ec 0c             	sub    $0xc,%esp
80100c33:	68 60 ef 10 80       	push   $0x8010ef60
80100c38:	e8 22 2f 00 00       	call   80103b5f <release>
      return f;
80100c3d:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100c40:	89 d8                	mov    %ebx,%eax
80100c42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c45:	c9                   	leave  
80100c46:	c3                   	ret    
  release(&ftable.lock);
80100c47:	83 ec 0c             	sub    $0xc,%esp
80100c4a:	68 60 ef 10 80       	push   $0x8010ef60
80100c4f:	e8 0b 2f 00 00       	call   80103b5f <release>
  return 0;
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c5c:	eb e2                	jmp    80100c40 <filealloc+0x43>

80100c5e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100c5e:	55                   	push   %ebp
80100c5f:	89 e5                	mov    %esp,%ebp
80100c61:	53                   	push   %ebx
80100c62:	83 ec 10             	sub    $0x10,%esp
80100c65:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100c68:	68 60 ef 10 80       	push   $0x8010ef60
80100c6d:	e8 88 2e 00 00       	call   80103afa <acquire>
  if(f->ref < 1)
80100c72:	8b 43 04             	mov    0x4(%ebx),%eax
80100c75:	83 c4 10             	add    $0x10,%esp
80100c78:	85 c0                	test   %eax,%eax
80100c7a:	7e 18                	jle    80100c94 <filedup+0x36>
    panic("filedup");
  f->ref++;
80100c7c:	40                   	inc    %eax
80100c7d:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100c80:	83 ec 0c             	sub    $0xc,%esp
80100c83:	68 60 ef 10 80       	push   $0x8010ef60
80100c88:	e8 d2 2e 00 00       	call   80103b5f <release>
  return f;
}
80100c8d:	89 d8                	mov    %ebx,%eax
80100c8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c92:	c9                   	leave  
80100c93:	c3                   	ret    
    panic("filedup");
80100c94:	83 ec 0c             	sub    $0xc,%esp
80100c97:	68 d4 69 10 80       	push   $0x801069d4
80100c9c:	e8 a0 f6 ff ff       	call   80100341 <panic>

80100ca1 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100ca1:	55                   	push   %ebp
80100ca2:	89 e5                	mov    %esp,%ebp
80100ca4:	57                   	push   %edi
80100ca5:	56                   	push   %esi
80100ca6:	53                   	push   %ebx
80100ca7:	83 ec 38             	sub    $0x38,%esp
80100caa:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100cad:	68 60 ef 10 80       	push   $0x8010ef60
80100cb2:	e8 43 2e 00 00       	call   80103afa <acquire>
  if(f->ref < 1)
80100cb7:	8b 43 04             	mov    0x4(%ebx),%eax
80100cba:	83 c4 10             	add    $0x10,%esp
80100cbd:	85 c0                	test   %eax,%eax
80100cbf:	7e 58                	jle    80100d19 <fileclose+0x78>
    panic("fileclose");
  if(--f->ref > 0){
80100cc1:	48                   	dec    %eax
80100cc2:	89 43 04             	mov    %eax,0x4(%ebx)
80100cc5:	85 c0                	test   %eax,%eax
80100cc7:	7f 5d                	jg     80100d26 <fileclose+0x85>
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100cc9:	8d 7d d0             	lea    -0x30(%ebp),%edi
80100ccc:	b9 06 00 00 00       	mov    $0x6,%ecx
80100cd1:	89 de                	mov    %ebx,%esi
80100cd3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  f->ref = 0;
80100cd5:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100cdc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100ce2:	83 ec 0c             	sub    $0xc,%esp
80100ce5:	68 60 ef 10 80       	push   $0x8010ef60
80100cea:	e8 70 2e 00 00       	call   80103b5f <release>

  if(ff.type == FD_PIPE)
80100cef:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100cf2:	83 c4 10             	add    $0x10,%esp
80100cf5:	83 f8 01             	cmp    $0x1,%eax
80100cf8:	74 44                	je     80100d3e <fileclose+0x9d>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80100cfa:	83 f8 02             	cmp    $0x2,%eax
80100cfd:	75 37                	jne    80100d36 <fileclose+0x95>
    begin_op();
80100cff:	e8 ef 19 00 00       	call   801026f3 <begin_op>
    iput(ff.ip);
80100d04:	83 ec 0c             	sub    $0xc,%esp
80100d07:	ff 75 e0             	push   -0x20(%ebp)
80100d0a:	e8 13 09 00 00       	call   80101622 <iput>
    end_op();
80100d0f:	e8 5b 1a 00 00       	call   8010276f <end_op>
80100d14:	83 c4 10             	add    $0x10,%esp
80100d17:	eb 1d                	jmp    80100d36 <fileclose+0x95>
    panic("fileclose");
80100d19:	83 ec 0c             	sub    $0xc,%esp
80100d1c:	68 dc 69 10 80       	push   $0x801069dc
80100d21:	e8 1b f6 ff ff       	call   80100341 <panic>
    release(&ftable.lock);
80100d26:	83 ec 0c             	sub    $0xc,%esp
80100d29:	68 60 ef 10 80       	push   $0x8010ef60
80100d2e:	e8 2c 2e 00 00       	call   80103b5f <release>
    return;
80100d33:	83 c4 10             	add    $0x10,%esp
  }
}
80100d36:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100d39:	5b                   	pop    %ebx
80100d3a:	5e                   	pop    %esi
80100d3b:	5f                   	pop    %edi
80100d3c:	5d                   	pop    %ebp
80100d3d:	c3                   	ret    
    pipeclose(ff.pipe, ff.writable);
80100d3e:	83 ec 08             	sub    $0x8,%esp
80100d41:	0f be 45 d9          	movsbl -0x27(%ebp),%eax
80100d45:	50                   	push   %eax
80100d46:	ff 75 dc             	push   -0x24(%ebp)
80100d49:	e8 06 20 00 00       	call   80102d54 <pipeclose>
80100d4e:	83 c4 10             	add    $0x10,%esp
80100d51:	eb e3                	jmp    80100d36 <fileclose+0x95>

80100d53 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100d53:	55                   	push   %ebp
80100d54:	89 e5                	mov    %esp,%ebp
80100d56:	53                   	push   %ebx
80100d57:	83 ec 04             	sub    $0x4,%esp
80100d5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100d5d:	83 3b 02             	cmpl   $0x2,(%ebx)
80100d60:	75 31                	jne    80100d93 <filestat+0x40>
    ilock(f->ip);
80100d62:	83 ec 0c             	sub    $0xc,%esp
80100d65:	ff 73 10             	push   0x10(%ebx)
80100d68:	e8 b0 07 00 00       	call   8010151d <ilock>
    stati(f->ip, st);
80100d6d:	83 c4 08             	add    $0x8,%esp
80100d70:	ff 75 0c             	push   0xc(%ebp)
80100d73:	ff 73 10             	push   0x10(%ebx)
80100d76:	e8 65 09 00 00       	call   801016e0 <stati>
    iunlock(f->ip);
80100d7b:	83 c4 04             	add    $0x4,%esp
80100d7e:	ff 73 10             	push   0x10(%ebx)
80100d81:	e8 57 08 00 00       	call   801015dd <iunlock>
    return 0;
80100d86:	83 c4 10             	add    $0x10,%esp
80100d89:	b8 00 00 00 00       	mov    $0x0,%eax
  }
  return -1;
}
80100d8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d91:	c9                   	leave  
80100d92:	c3                   	ret    
  return -1;
80100d93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100d98:	eb f4                	jmp    80100d8e <filestat+0x3b>

80100d9a <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100d9a:	55                   	push   %ebp
80100d9b:	89 e5                	mov    %esp,%ebp
80100d9d:	56                   	push   %esi
80100d9e:	53                   	push   %ebx
80100d9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100da2:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100da6:	74 70                	je     80100e18 <fileread+0x7e>
    return -1;
  if(f->type == FD_PIPE)
80100da8:	8b 03                	mov    (%ebx),%eax
80100daa:	83 f8 01             	cmp    $0x1,%eax
80100dad:	74 44                	je     80100df3 <fileread+0x59>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100daf:	83 f8 02             	cmp    $0x2,%eax
80100db2:	75 57                	jne    80100e0b <fileread+0x71>
    ilock(f->ip);
80100db4:	83 ec 0c             	sub    $0xc,%esp
80100db7:	ff 73 10             	push   0x10(%ebx)
80100dba:	e8 5e 07 00 00       	call   8010151d <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100dbf:	ff 75 10             	push   0x10(%ebp)
80100dc2:	ff 73 14             	push   0x14(%ebx)
80100dc5:	ff 75 0c             	push   0xc(%ebp)
80100dc8:	ff 73 10             	push   0x10(%ebx)
80100dcb:	e8 3a 09 00 00       	call   8010170a <readi>
80100dd0:	89 c6                	mov    %eax,%esi
80100dd2:	83 c4 20             	add    $0x20,%esp
80100dd5:	85 c0                	test   %eax,%eax
80100dd7:	7e 03                	jle    80100ddc <fileread+0x42>
      f->off += r;
80100dd9:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100ddc:	83 ec 0c             	sub    $0xc,%esp
80100ddf:	ff 73 10             	push   0x10(%ebx)
80100de2:	e8 f6 07 00 00       	call   801015dd <iunlock>
    return r;
80100de7:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100dea:	89 f0                	mov    %esi,%eax
80100dec:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100def:	5b                   	pop    %ebx
80100df0:	5e                   	pop    %esi
80100df1:	5d                   	pop    %ebp
80100df2:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100df3:	83 ec 04             	sub    $0x4,%esp
80100df6:	ff 75 10             	push   0x10(%ebp)
80100df9:	ff 75 0c             	push   0xc(%ebp)
80100dfc:	ff 73 0c             	push   0xc(%ebx)
80100dff:	e8 9e 20 00 00       	call   80102ea2 <piperead>
80100e04:	89 c6                	mov    %eax,%esi
80100e06:	83 c4 10             	add    $0x10,%esp
80100e09:	eb df                	jmp    80100dea <fileread+0x50>
  panic("fileread");
80100e0b:	83 ec 0c             	sub    $0xc,%esp
80100e0e:	68 e6 69 10 80       	push   $0x801069e6
80100e13:	e8 29 f5 ff ff       	call   80100341 <panic>
    return -1;
80100e18:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e1d:	eb cb                	jmp    80100dea <fileread+0x50>

80100e1f <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100e1f:	55                   	push   %ebp
80100e20:	89 e5                	mov    %esp,%ebp
80100e22:	57                   	push   %edi
80100e23:	56                   	push   %esi
80100e24:	53                   	push   %ebx
80100e25:	83 ec 1c             	sub    $0x1c,%esp
80100e28:	8b 75 08             	mov    0x8(%ebp),%esi
  int r;

  if(f->writable == 0)
80100e2b:	80 7e 09 00          	cmpb   $0x0,0x9(%esi)
80100e2f:	0f 84 cc 00 00 00    	je     80100f01 <filewrite+0xe2>
    return -1;
  if(f->type == FD_PIPE)
80100e35:	8b 06                	mov    (%esi),%eax
80100e37:	83 f8 01             	cmp    $0x1,%eax
80100e3a:	74 10                	je     80100e4c <filewrite+0x2d>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e3c:	83 f8 02             	cmp    $0x2,%eax
80100e3f:	0f 85 af 00 00 00    	jne    80100ef4 <filewrite+0xd5>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100e45:	bf 00 00 00 00       	mov    $0x0,%edi
80100e4a:	eb 67                	jmp    80100eb3 <filewrite+0x94>
    return pipewrite(f->pipe, addr, n);
80100e4c:	83 ec 04             	sub    $0x4,%esp
80100e4f:	ff 75 10             	push   0x10(%ebp)
80100e52:	ff 75 0c             	push   0xc(%ebp)
80100e55:	ff 76 0c             	push   0xc(%esi)
80100e58:	e8 83 1f 00 00       	call   80102de0 <pipewrite>
80100e5d:	83 c4 10             	add    $0x10,%esp
80100e60:	e9 82 00 00 00       	jmp    80100ee7 <filewrite+0xc8>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100e65:	e8 89 18 00 00       	call   801026f3 <begin_op>
      ilock(f->ip);
80100e6a:	83 ec 0c             	sub    $0xc,%esp
80100e6d:	ff 76 10             	push   0x10(%esi)
80100e70:	e8 a8 06 00 00       	call   8010151d <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100e75:	ff 75 e4             	push   -0x1c(%ebp)
80100e78:	ff 76 14             	push   0x14(%esi)
80100e7b:	89 f8                	mov    %edi,%eax
80100e7d:	03 45 0c             	add    0xc(%ebp),%eax
80100e80:	50                   	push   %eax
80100e81:	ff 76 10             	push   0x10(%esi)
80100e84:	e8 81 09 00 00       	call   8010180a <writei>
80100e89:	89 c3                	mov    %eax,%ebx
80100e8b:	83 c4 20             	add    $0x20,%esp
80100e8e:	85 c0                	test   %eax,%eax
80100e90:	7e 03                	jle    80100e95 <filewrite+0x76>
        f->off += r;
80100e92:	01 46 14             	add    %eax,0x14(%esi)
      iunlock(f->ip);
80100e95:	83 ec 0c             	sub    $0xc,%esp
80100e98:	ff 76 10             	push   0x10(%esi)
80100e9b:	e8 3d 07 00 00       	call   801015dd <iunlock>
      end_op();
80100ea0:	e8 ca 18 00 00       	call   8010276f <end_op>

      if(r < 0)
80100ea5:	83 c4 10             	add    $0x10,%esp
80100ea8:	85 db                	test   %ebx,%ebx
80100eaa:	78 31                	js     80100edd <filewrite+0xbe>
        break;
      if(r != n1)
80100eac:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
80100eaf:	75 1f                	jne    80100ed0 <filewrite+0xb1>
        panic("short filewrite");
      i += r;
80100eb1:	01 df                	add    %ebx,%edi
    while(i < n){
80100eb3:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100eb6:	7d 25                	jge    80100edd <filewrite+0xbe>
      int n1 = n - i;
80100eb8:	8b 45 10             	mov    0x10(%ebp),%eax
80100ebb:	29 f8                	sub    %edi,%eax
80100ebd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(n1 > max)
80100ec0:	3d 00 06 00 00       	cmp    $0x600,%eax
80100ec5:	7e 9e                	jle    80100e65 <filewrite+0x46>
        n1 = max;
80100ec7:	c7 45 e4 00 06 00 00 	movl   $0x600,-0x1c(%ebp)
80100ece:	eb 95                	jmp    80100e65 <filewrite+0x46>
        panic("short filewrite");
80100ed0:	83 ec 0c             	sub    $0xc,%esp
80100ed3:	68 ef 69 10 80       	push   $0x801069ef
80100ed8:	e8 64 f4 ff ff       	call   80100341 <panic>
    }
    return i == n ? n : -1;
80100edd:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100ee0:	74 0d                	je     80100eef <filewrite+0xd0>
80100ee2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
80100ee7:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100eea:	5b                   	pop    %ebx
80100eeb:	5e                   	pop    %esi
80100eec:	5f                   	pop    %edi
80100eed:	5d                   	pop    %ebp
80100eee:	c3                   	ret    
    return i == n ? n : -1;
80100eef:	8b 45 10             	mov    0x10(%ebp),%eax
80100ef2:	eb f3                	jmp    80100ee7 <filewrite+0xc8>
  panic("filewrite");
80100ef4:	83 ec 0c             	sub    $0xc,%esp
80100ef7:	68 f5 69 10 80       	push   $0x801069f5
80100efc:	e8 40 f4 ff ff       	call   80100341 <panic>
    return -1;
80100f01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f06:	eb df                	jmp    80100ee7 <filewrite+0xc8>

80100f08 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80100f08:	55                   	push   %ebp
80100f09:	89 e5                	mov    %esp,%ebp
80100f0b:	57                   	push   %edi
80100f0c:	56                   	push   %esi
80100f0d:	53                   	push   %ebx
80100f0e:	83 ec 0c             	sub    $0xc,%esp
80100f11:	89 d6                	mov    %edx,%esi
  char *s;
  int len;

  while(*path == '/')
80100f13:	eb 01                	jmp    80100f16 <skipelem+0xe>
    path++;
80100f15:	40                   	inc    %eax
  while(*path == '/')
80100f16:	8a 10                	mov    (%eax),%dl
80100f18:	80 fa 2f             	cmp    $0x2f,%dl
80100f1b:	74 f8                	je     80100f15 <skipelem+0xd>
  if(*path == 0)
80100f1d:	84 d2                	test   %dl,%dl
80100f1f:	74 4e                	je     80100f6f <skipelem+0x67>
80100f21:	89 c3                	mov    %eax,%ebx
80100f23:	eb 01                	jmp    80100f26 <skipelem+0x1e>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80100f25:	43                   	inc    %ebx
  while(*path != '/' && *path != 0)
80100f26:	8a 13                	mov    (%ebx),%dl
80100f28:	80 fa 2f             	cmp    $0x2f,%dl
80100f2b:	74 04                	je     80100f31 <skipelem+0x29>
80100f2d:	84 d2                	test   %dl,%dl
80100f2f:	75 f4                	jne    80100f25 <skipelem+0x1d>
  len = path - s;
80100f31:	89 df                	mov    %ebx,%edi
80100f33:	29 c7                	sub    %eax,%edi
  if(len >= DIRSIZ)
80100f35:	83 ff 0d             	cmp    $0xd,%edi
80100f38:	7e 11                	jle    80100f4b <skipelem+0x43>
    memmove(name, s, DIRSIZ);
80100f3a:	83 ec 04             	sub    $0x4,%esp
80100f3d:	6a 0e                	push   $0xe
80100f3f:	50                   	push   %eax
80100f40:	56                   	push   %esi
80100f41:	e8 d6 2c 00 00       	call   80103c1c <memmove>
80100f46:	83 c4 10             	add    $0x10,%esp
80100f49:	eb 15                	jmp    80100f60 <skipelem+0x58>
  else {
    memmove(name, s, len);
80100f4b:	83 ec 04             	sub    $0x4,%esp
80100f4e:	57                   	push   %edi
80100f4f:	50                   	push   %eax
80100f50:	56                   	push   %esi
80100f51:	e8 c6 2c 00 00       	call   80103c1c <memmove>
    name[len] = 0;
80100f56:	c6 04 3e 00          	movb   $0x0,(%esi,%edi,1)
80100f5a:	83 c4 10             	add    $0x10,%esp
80100f5d:	eb 01                	jmp    80100f60 <skipelem+0x58>
  }
  while(*path == '/')
    path++;
80100f5f:	43                   	inc    %ebx
  while(*path == '/')
80100f60:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80100f63:	74 fa                	je     80100f5f <skipelem+0x57>
  return path;
}
80100f65:	89 d8                	mov    %ebx,%eax
80100f67:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f6a:	5b                   	pop    %ebx
80100f6b:	5e                   	pop    %esi
80100f6c:	5f                   	pop    %edi
80100f6d:	5d                   	pop    %ebp
80100f6e:	c3                   	ret    
    return 0;
80100f6f:	bb 00 00 00 00       	mov    $0x0,%ebx
80100f74:	eb ef                	jmp    80100f65 <skipelem+0x5d>

80100f76 <bzero>:
{
80100f76:	55                   	push   %ebp
80100f77:	89 e5                	mov    %esp,%ebp
80100f79:	53                   	push   %ebx
80100f7a:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, bno);
80100f7d:	52                   	push   %edx
80100f7e:	50                   	push   %eax
80100f7f:	e8 e6 f1 ff ff       	call   8010016a <bread>
80100f84:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80100f86:	8d 40 5c             	lea    0x5c(%eax),%eax
80100f89:	83 c4 0c             	add    $0xc,%esp
80100f8c:	68 00 02 00 00       	push   $0x200
80100f91:	6a 00                	push   $0x0
80100f93:	50                   	push   %eax
80100f94:	e8 0d 2c 00 00       	call   80103ba6 <memset>
  log_write(bp);
80100f99:	89 1c 24             	mov    %ebx,(%esp)
80100f9c:	e8 7b 18 00 00       	call   8010281c <log_write>
  brelse(bp);
80100fa1:	89 1c 24             	mov    %ebx,(%esp)
80100fa4:	e8 2a f2 ff ff       	call   801001d3 <brelse>
}
80100fa9:	83 c4 10             	add    $0x10,%esp
80100fac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100faf:	c9                   	leave  
80100fb0:	c3                   	ret    

80100fb1 <balloc>:
{
80100fb1:	55                   	push   %ebp
80100fb2:	89 e5                	mov    %esp,%ebp
80100fb4:	57                   	push   %edi
80100fb5:	56                   	push   %esi
80100fb6:	53                   	push   %ebx
80100fb7:	83 ec 1c             	sub    $0x1c,%esp
80100fba:	89 45 dc             	mov    %eax,-0x24(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80100fbd:	be 00 00 00 00       	mov    $0x0,%esi
80100fc2:	eb 5b                	jmp    8010101f <balloc+0x6e>
    bp = bread(dev, BBLOCK(b, sb));
80100fc4:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
80100fca:	eb 61                	jmp    8010102d <balloc+0x7c>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80100fcc:	c1 fa 03             	sar    $0x3,%edx
80100fcf:	8b 7d e0             	mov    -0x20(%ebp),%edi
80100fd2:	8a 4c 17 5c          	mov    0x5c(%edi,%edx,1),%cl
80100fd6:	0f b6 f9             	movzbl %cl,%edi
80100fd9:	85 7d e4             	test   %edi,-0x1c(%ebp)
80100fdc:	74 7e                	je     8010105c <balloc+0xab>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80100fde:	40                   	inc    %eax
80100fdf:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80100fe4:	7f 25                	jg     8010100b <balloc+0x5a>
80100fe6:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
80100fe9:	3b 1d b4 15 11 80    	cmp    0x801115b4,%ebx
80100fef:	73 1a                	jae    8010100b <balloc+0x5a>
      m = 1 << (bi % 8);
80100ff1:	89 c1                	mov    %eax,%ecx
80100ff3:	83 e1 07             	and    $0x7,%ecx
80100ff6:	ba 01 00 00 00       	mov    $0x1,%edx
80100ffb:	d3 e2                	shl    %cl,%edx
80100ffd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101000:	89 c2                	mov    %eax,%edx
80101002:	85 c0                	test   %eax,%eax
80101004:	79 c6                	jns    80100fcc <balloc+0x1b>
80101006:	8d 50 07             	lea    0x7(%eax),%edx
80101009:	eb c1                	jmp    80100fcc <balloc+0x1b>
    brelse(bp);
8010100b:	83 ec 0c             	sub    $0xc,%esp
8010100e:	ff 75 e0             	push   -0x20(%ebp)
80101011:	e8 bd f1 ff ff       	call   801001d3 <brelse>
  for(b = 0; b < sb.size; b += BPB){
80101016:	81 c6 00 10 00 00    	add    $0x1000,%esi
8010101c:	83 c4 10             	add    $0x10,%esp
8010101f:	39 35 b4 15 11 80    	cmp    %esi,0x801115b4
80101025:	76 28                	jbe    8010104f <balloc+0x9e>
    bp = bread(dev, BBLOCK(b, sb));
80101027:	89 f0                	mov    %esi,%eax
80101029:	85 f6                	test   %esi,%esi
8010102b:	78 97                	js     80100fc4 <balloc+0x13>
8010102d:	c1 f8 0c             	sar    $0xc,%eax
80101030:	83 ec 08             	sub    $0x8,%esp
80101033:	03 05 cc 15 11 80    	add    0x801115cc,%eax
80101039:	50                   	push   %eax
8010103a:	ff 75 dc             	push   -0x24(%ebp)
8010103d:	e8 28 f1 ff ff       	call   8010016a <bread>
80101042:	89 45 e0             	mov    %eax,-0x20(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101045:	83 c4 10             	add    $0x10,%esp
80101048:	b8 00 00 00 00       	mov    $0x0,%eax
8010104d:	eb 90                	jmp    80100fdf <balloc+0x2e>
  panic("balloc: out of blocks");
8010104f:	83 ec 0c             	sub    $0xc,%esp
80101052:	68 ff 69 10 80       	push   $0x801069ff
80101057:	e8 e5 f2 ff ff       	call   80100341 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
8010105c:	0b 4d e4             	or     -0x1c(%ebp),%ecx
8010105f:	8b 75 e0             	mov    -0x20(%ebp),%esi
80101062:	88 4c 16 5c          	mov    %cl,0x5c(%esi,%edx,1)
        log_write(bp);
80101066:	83 ec 0c             	sub    $0xc,%esp
80101069:	56                   	push   %esi
8010106a:	e8 ad 17 00 00       	call   8010281c <log_write>
        brelse(bp);
8010106f:	89 34 24             	mov    %esi,(%esp)
80101072:	e8 5c f1 ff ff       	call   801001d3 <brelse>
        bzero(dev, b + bi);
80101077:	89 da                	mov    %ebx,%edx
80101079:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010107c:	e8 f5 fe ff ff       	call   80100f76 <bzero>
}
80101081:	89 d8                	mov    %ebx,%eax
80101083:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101086:	5b                   	pop    %ebx
80101087:	5e                   	pop    %esi
80101088:	5f                   	pop    %edi
80101089:	5d                   	pop    %ebp
8010108a:	c3                   	ret    

8010108b <bmap>:
{
8010108b:	55                   	push   %ebp
8010108c:	89 e5                	mov    %esp,%ebp
8010108e:	57                   	push   %edi
8010108f:	56                   	push   %esi
80101090:	53                   	push   %ebx
80101091:	83 ec 1c             	sub    $0x1c,%esp
80101094:	89 c3                	mov    %eax,%ebx
80101096:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
80101098:	83 fa 0b             	cmp    $0xb,%edx
8010109b:	76 45                	jbe    801010e2 <bmap+0x57>
  bn -= NDIRECT;
8010109d:	8d 72 f4             	lea    -0xc(%edx),%esi
  if(bn < NINDIRECT){
801010a0:	83 fe 7f             	cmp    $0x7f,%esi
801010a3:	77 7f                	ja     80101124 <bmap+0x99>
    if((addr = ip->addrs[NDIRECT]) == 0)
801010a5:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801010ab:	85 c0                	test   %eax,%eax
801010ad:	74 4a                	je     801010f9 <bmap+0x6e>
    bp = bread(ip->dev, addr);
801010af:	83 ec 08             	sub    $0x8,%esp
801010b2:	50                   	push   %eax
801010b3:	ff 33                	push   (%ebx)
801010b5:	e8 b0 f0 ff ff       	call   8010016a <bread>
801010ba:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
801010bc:	8d 44 b0 5c          	lea    0x5c(%eax,%esi,4),%eax
801010c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801010c3:	8b 30                	mov    (%eax),%esi
801010c5:	83 c4 10             	add    $0x10,%esp
801010c8:	85 f6                	test   %esi,%esi
801010ca:	74 3c                	je     80101108 <bmap+0x7d>
    brelse(bp);
801010cc:	83 ec 0c             	sub    $0xc,%esp
801010cf:	57                   	push   %edi
801010d0:	e8 fe f0 ff ff       	call   801001d3 <brelse>
    return addr;
801010d5:	83 c4 10             	add    $0x10,%esp
}
801010d8:	89 f0                	mov    %esi,%eax
801010da:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010dd:	5b                   	pop    %ebx
801010de:	5e                   	pop    %esi
801010df:	5f                   	pop    %edi
801010e0:	5d                   	pop    %ebp
801010e1:	c3                   	ret    
    if((addr = ip->addrs[bn]) == 0)
801010e2:	8b 74 90 5c          	mov    0x5c(%eax,%edx,4),%esi
801010e6:	85 f6                	test   %esi,%esi
801010e8:	75 ee                	jne    801010d8 <bmap+0x4d>
      ip->addrs[bn] = addr = balloc(ip->dev);
801010ea:	8b 00                	mov    (%eax),%eax
801010ec:	e8 c0 fe ff ff       	call   80100fb1 <balloc>
801010f1:	89 c6                	mov    %eax,%esi
801010f3:	89 44 bb 5c          	mov    %eax,0x5c(%ebx,%edi,4)
    return addr;
801010f7:	eb df                	jmp    801010d8 <bmap+0x4d>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
801010f9:	8b 03                	mov    (%ebx),%eax
801010fb:	e8 b1 fe ff ff       	call   80100fb1 <balloc>
80101100:	89 83 8c 00 00 00    	mov    %eax,0x8c(%ebx)
80101106:	eb a7                	jmp    801010af <bmap+0x24>
      a[bn] = addr = balloc(ip->dev);
80101108:	8b 03                	mov    (%ebx),%eax
8010110a:	e8 a2 fe ff ff       	call   80100fb1 <balloc>
8010110f:	89 c6                	mov    %eax,%esi
80101111:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101114:	89 30                	mov    %esi,(%eax)
      log_write(bp);
80101116:	83 ec 0c             	sub    $0xc,%esp
80101119:	57                   	push   %edi
8010111a:	e8 fd 16 00 00       	call   8010281c <log_write>
8010111f:	83 c4 10             	add    $0x10,%esp
80101122:	eb a8                	jmp    801010cc <bmap+0x41>
  panic("bmap: out of range");
80101124:	83 ec 0c             	sub    $0xc,%esp
80101127:	68 15 6a 10 80       	push   $0x80106a15
8010112c:	e8 10 f2 ff ff       	call   80100341 <panic>

80101131 <iget>:
{
80101131:	55                   	push   %ebp
80101132:	89 e5                	mov    %esp,%ebp
80101134:	57                   	push   %edi
80101135:	56                   	push   %esi
80101136:	53                   	push   %ebx
80101137:	83 ec 28             	sub    $0x28,%esp
8010113a:	89 c7                	mov    %eax,%edi
8010113c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
8010113f:	68 60 f9 10 80       	push   $0x8010f960
80101144:	e8 b1 29 00 00       	call   80103afa <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101149:	83 c4 10             	add    $0x10,%esp
  empty = 0;
8010114c:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101151:	bb 94 f9 10 80       	mov    $0x8010f994,%ebx
80101156:	eb 0a                	jmp    80101162 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101158:	85 f6                	test   %esi,%esi
8010115a:	74 39                	je     80101195 <iget+0x64>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010115c:	81 c3 90 00 00 00    	add    $0x90,%ebx
80101162:	81 fb b4 15 11 80    	cmp    $0x801115b4,%ebx
80101168:	73 33                	jae    8010119d <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010116a:	8b 43 08             	mov    0x8(%ebx),%eax
8010116d:	85 c0                	test   %eax,%eax
8010116f:	7e e7                	jle    80101158 <iget+0x27>
80101171:	39 3b                	cmp    %edi,(%ebx)
80101173:	75 e3                	jne    80101158 <iget+0x27>
80101175:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101178:	39 4b 04             	cmp    %ecx,0x4(%ebx)
8010117b:	75 db                	jne    80101158 <iget+0x27>
      ip->ref++;
8010117d:	40                   	inc    %eax
8010117e:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
80101181:	83 ec 0c             	sub    $0xc,%esp
80101184:	68 60 f9 10 80       	push   $0x8010f960
80101189:	e8 d1 29 00 00       	call   80103b5f <release>
      return ip;
8010118e:	83 c4 10             	add    $0x10,%esp
80101191:	89 de                	mov    %ebx,%esi
80101193:	eb 32                	jmp    801011c7 <iget+0x96>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101195:	85 c0                	test   %eax,%eax
80101197:	75 c3                	jne    8010115c <iget+0x2b>
      empty = ip;
80101199:	89 de                	mov    %ebx,%esi
8010119b:	eb bf                	jmp    8010115c <iget+0x2b>
  if(empty == 0)
8010119d:	85 f6                	test   %esi,%esi
8010119f:	74 30                	je     801011d1 <iget+0xa0>
  ip->dev = dev;
801011a1:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
801011a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801011a6:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
801011a9:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
801011b0:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
801011b7:	83 ec 0c             	sub    $0xc,%esp
801011ba:	68 60 f9 10 80       	push   $0x8010f960
801011bf:	e8 9b 29 00 00       	call   80103b5f <release>
  return ip;
801011c4:	83 c4 10             	add    $0x10,%esp
}
801011c7:	89 f0                	mov    %esi,%eax
801011c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011cc:	5b                   	pop    %ebx
801011cd:	5e                   	pop    %esi
801011ce:	5f                   	pop    %edi
801011cf:	5d                   	pop    %ebp
801011d0:	c3                   	ret    
    panic("iget: no inodes");
801011d1:	83 ec 0c             	sub    $0xc,%esp
801011d4:	68 28 6a 10 80       	push   $0x80106a28
801011d9:	e8 63 f1 ff ff       	call   80100341 <panic>

801011de <readsb>:
{
801011de:	55                   	push   %ebp
801011df:	89 e5                	mov    %esp,%ebp
801011e1:	53                   	push   %ebx
801011e2:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
801011e5:	6a 01                	push   $0x1
801011e7:	ff 75 08             	push   0x8(%ebp)
801011ea:	e8 7b ef ff ff       	call   8010016a <bread>
801011ef:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801011f1:	8d 40 5c             	lea    0x5c(%eax),%eax
801011f4:	83 c4 0c             	add    $0xc,%esp
801011f7:	6a 1c                	push   $0x1c
801011f9:	50                   	push   %eax
801011fa:	ff 75 0c             	push   0xc(%ebp)
801011fd:	e8 1a 2a 00 00       	call   80103c1c <memmove>
  brelse(bp);
80101202:	89 1c 24             	mov    %ebx,(%esp)
80101205:	e8 c9 ef ff ff       	call   801001d3 <brelse>
}
8010120a:	83 c4 10             	add    $0x10,%esp
8010120d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101210:	c9                   	leave  
80101211:	c3                   	ret    

80101212 <bfree>:
{
80101212:	55                   	push   %ebp
80101213:	89 e5                	mov    %esp,%ebp
80101215:	56                   	push   %esi
80101216:	53                   	push   %ebx
80101217:	89 c3                	mov    %eax,%ebx
80101219:	89 d6                	mov    %edx,%esi
  readsb(dev, &sb);
8010121b:	83 ec 08             	sub    $0x8,%esp
8010121e:	68 b4 15 11 80       	push   $0x801115b4
80101223:	50                   	push   %eax
80101224:	e8 b5 ff ff ff       	call   801011de <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101229:	89 f0                	mov    %esi,%eax
8010122b:	c1 e8 0c             	shr    $0xc,%eax
8010122e:	83 c4 08             	add    $0x8,%esp
80101231:	03 05 cc 15 11 80    	add    0x801115cc,%eax
80101237:	50                   	push   %eax
80101238:	53                   	push   %ebx
80101239:	e8 2c ef ff ff       	call   8010016a <bread>
8010123e:	89 c3                	mov    %eax,%ebx
  bi = b % BPB;
80101240:	89 f2                	mov    %esi,%edx
80101242:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  m = 1 << (bi % 8);
80101248:	89 f1                	mov    %esi,%ecx
8010124a:	83 e1 07             	and    $0x7,%ecx
8010124d:	b8 01 00 00 00       	mov    $0x1,%eax
80101252:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
80101254:	83 c4 10             	add    $0x10,%esp
80101257:	c1 fa 03             	sar    $0x3,%edx
8010125a:	8a 4c 13 5c          	mov    0x5c(%ebx,%edx,1),%cl
8010125e:	0f b6 f1             	movzbl %cl,%esi
80101261:	85 c6                	test   %eax,%esi
80101263:	74 23                	je     80101288 <bfree+0x76>
  bp->data[bi/8] &= ~m;
80101265:	f7 d0                	not    %eax
80101267:	21 c8                	and    %ecx,%eax
80101269:	88 44 13 5c          	mov    %al,0x5c(%ebx,%edx,1)
  log_write(bp);
8010126d:	83 ec 0c             	sub    $0xc,%esp
80101270:	53                   	push   %ebx
80101271:	e8 a6 15 00 00       	call   8010281c <log_write>
  brelse(bp);
80101276:	89 1c 24             	mov    %ebx,(%esp)
80101279:	e8 55 ef ff ff       	call   801001d3 <brelse>
}
8010127e:	83 c4 10             	add    $0x10,%esp
80101281:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101284:	5b                   	pop    %ebx
80101285:	5e                   	pop    %esi
80101286:	5d                   	pop    %ebp
80101287:	c3                   	ret    
    panic("freeing free block");
80101288:	83 ec 0c             	sub    $0xc,%esp
8010128b:	68 38 6a 10 80       	push   $0x80106a38
80101290:	e8 ac f0 ff ff       	call   80100341 <panic>

80101295 <iinit>:
{
80101295:	55                   	push   %ebp
80101296:	89 e5                	mov    %esp,%ebp
80101298:	53                   	push   %ebx
80101299:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
8010129c:	68 4b 6a 10 80       	push   $0x80106a4b
801012a1:	68 60 f9 10 80       	push   $0x8010f960
801012a6:	e8 18 27 00 00       	call   801039c3 <initlock>
  for(i = 0; i < NINODE; i++) {
801012ab:	83 c4 10             	add    $0x10,%esp
801012ae:	bb 00 00 00 00       	mov    $0x0,%ebx
801012b3:	eb 1f                	jmp    801012d4 <iinit+0x3f>
    initsleeplock(&icache.inode[i].lock, "inode");
801012b5:	83 ec 08             	sub    $0x8,%esp
801012b8:	68 52 6a 10 80       	push   $0x80106a52
801012bd:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
801012c0:	89 d0                	mov    %edx,%eax
801012c2:	c1 e0 04             	shl    $0x4,%eax
801012c5:	05 a0 f9 10 80       	add    $0x8010f9a0,%eax
801012ca:	50                   	push   %eax
801012cb:	e8 e8 25 00 00       	call   801038b8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
801012d0:	43                   	inc    %ebx
801012d1:	83 c4 10             	add    $0x10,%esp
801012d4:	83 fb 31             	cmp    $0x31,%ebx
801012d7:	7e dc                	jle    801012b5 <iinit+0x20>
  readsb(dev, &sb);
801012d9:	83 ec 08             	sub    $0x8,%esp
801012dc:	68 b4 15 11 80       	push   $0x801115b4
801012e1:	ff 75 08             	push   0x8(%ebp)
801012e4:	e8 f5 fe ff ff       	call   801011de <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801012e9:	ff 35 cc 15 11 80    	push   0x801115cc
801012ef:	ff 35 c8 15 11 80    	push   0x801115c8
801012f5:	ff 35 c4 15 11 80    	push   0x801115c4
801012fb:	ff 35 c0 15 11 80    	push   0x801115c0
80101301:	ff 35 bc 15 11 80    	push   0x801115bc
80101307:	ff 35 b8 15 11 80    	push   0x801115b8
8010130d:	ff 35 b4 15 11 80    	push   0x801115b4
80101313:	68 b8 6a 10 80       	push   $0x80106ab8
80101318:	e8 bd f2 ff ff       	call   801005da <cprintf>
}
8010131d:	83 c4 30             	add    $0x30,%esp
80101320:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101323:	c9                   	leave  
80101324:	c3                   	ret    

80101325 <ialloc>:
{
80101325:	55                   	push   %ebp
80101326:	89 e5                	mov    %esp,%ebp
80101328:	57                   	push   %edi
80101329:	56                   	push   %esi
8010132a:	53                   	push   %ebx
8010132b:	83 ec 1c             	sub    $0x1c,%esp
8010132e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101331:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101334:	bb 01 00 00 00       	mov    $0x1,%ebx
80101339:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
8010133c:	39 1d bc 15 11 80    	cmp    %ebx,0x801115bc
80101342:	76 3d                	jbe    80101381 <ialloc+0x5c>
    bp = bread(dev, IBLOCK(inum, sb));
80101344:	89 d8                	mov    %ebx,%eax
80101346:	c1 e8 03             	shr    $0x3,%eax
80101349:	83 ec 08             	sub    $0x8,%esp
8010134c:	03 05 c8 15 11 80    	add    0x801115c8,%eax
80101352:	50                   	push   %eax
80101353:	ff 75 08             	push   0x8(%ebp)
80101356:	e8 0f ee ff ff       	call   8010016a <bread>
8010135b:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
8010135d:	89 d8                	mov    %ebx,%eax
8010135f:	83 e0 07             	and    $0x7,%eax
80101362:	c1 e0 06             	shl    $0x6,%eax
80101365:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
80101369:	83 c4 10             	add    $0x10,%esp
8010136c:	66 83 3f 00          	cmpw   $0x0,(%edi)
80101370:	74 1c                	je     8010138e <ialloc+0x69>
    brelse(bp);
80101372:	83 ec 0c             	sub    $0xc,%esp
80101375:	56                   	push   %esi
80101376:	e8 58 ee ff ff       	call   801001d3 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
8010137b:	43                   	inc    %ebx
8010137c:	83 c4 10             	add    $0x10,%esp
8010137f:	eb b8                	jmp    80101339 <ialloc+0x14>
  panic("ialloc: no inodes");
80101381:	83 ec 0c             	sub    $0xc,%esp
80101384:	68 58 6a 10 80       	push   $0x80106a58
80101389:	e8 b3 ef ff ff       	call   80100341 <panic>
      memset(dip, 0, sizeof(*dip));
8010138e:	83 ec 04             	sub    $0x4,%esp
80101391:	6a 40                	push   $0x40
80101393:	6a 00                	push   $0x0
80101395:	57                   	push   %edi
80101396:	e8 0b 28 00 00       	call   80103ba6 <memset>
      dip->type = type;
8010139b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010139e:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013a1:	89 34 24             	mov    %esi,(%esp)
801013a4:	e8 73 14 00 00       	call   8010281c <log_write>
      brelse(bp);
801013a9:	89 34 24             	mov    %esi,(%esp)
801013ac:	e8 22 ee ff ff       	call   801001d3 <brelse>
      return iget(dev, inum);
801013b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801013b4:	8b 45 08             	mov    0x8(%ebp),%eax
801013b7:	e8 75 fd ff ff       	call   80101131 <iget>
}
801013bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801013bf:	5b                   	pop    %ebx
801013c0:	5e                   	pop    %esi
801013c1:	5f                   	pop    %edi
801013c2:	5d                   	pop    %ebp
801013c3:	c3                   	ret    

801013c4 <iupdate>:
{
801013c4:	55                   	push   %ebp
801013c5:	89 e5                	mov    %esp,%ebp
801013c7:	56                   	push   %esi
801013c8:	53                   	push   %ebx
801013c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801013cc:	8b 43 04             	mov    0x4(%ebx),%eax
801013cf:	c1 e8 03             	shr    $0x3,%eax
801013d2:	83 ec 08             	sub    $0x8,%esp
801013d5:	03 05 c8 15 11 80    	add    0x801115c8,%eax
801013db:	50                   	push   %eax
801013dc:	ff 33                	push   (%ebx)
801013de:	e8 87 ed ff ff       	call   8010016a <bread>
801013e3:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801013e5:	8b 43 04             	mov    0x4(%ebx),%eax
801013e8:	83 e0 07             	and    $0x7,%eax
801013eb:	c1 e0 06             	shl    $0x6,%eax
801013ee:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
801013f2:	8b 53 50             	mov    0x50(%ebx),%edx
801013f5:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801013f8:	66 8b 53 52          	mov    0x52(%ebx),%dx
801013fc:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101400:	8b 53 54             	mov    0x54(%ebx),%edx
80101403:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101407:	66 8b 53 56          	mov    0x56(%ebx),%dx
8010140b:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010140f:	8b 53 58             	mov    0x58(%ebx),%edx
80101412:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101415:	83 c3 5c             	add    $0x5c,%ebx
80101418:	83 c0 0c             	add    $0xc,%eax
8010141b:	83 c4 0c             	add    $0xc,%esp
8010141e:	6a 34                	push   $0x34
80101420:	53                   	push   %ebx
80101421:	50                   	push   %eax
80101422:	e8 f5 27 00 00       	call   80103c1c <memmove>
  log_write(bp);
80101427:	89 34 24             	mov    %esi,(%esp)
8010142a:	e8 ed 13 00 00       	call   8010281c <log_write>
  brelse(bp);
8010142f:	89 34 24             	mov    %esi,(%esp)
80101432:	e8 9c ed ff ff       	call   801001d3 <brelse>
}
80101437:	83 c4 10             	add    $0x10,%esp
8010143a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010143d:	5b                   	pop    %ebx
8010143e:	5e                   	pop    %esi
8010143f:	5d                   	pop    %ebp
80101440:	c3                   	ret    

80101441 <itrunc>:
{
80101441:	55                   	push   %ebp
80101442:	89 e5                	mov    %esp,%ebp
80101444:	57                   	push   %edi
80101445:	56                   	push   %esi
80101446:	53                   	push   %ebx
80101447:	83 ec 1c             	sub    $0x1c,%esp
8010144a:	89 c6                	mov    %eax,%esi
  for(i = 0; i < NDIRECT; i++){
8010144c:	bb 00 00 00 00       	mov    $0x0,%ebx
80101451:	eb 01                	jmp    80101454 <itrunc+0x13>
80101453:	43                   	inc    %ebx
80101454:	83 fb 0b             	cmp    $0xb,%ebx
80101457:	7f 19                	jg     80101472 <itrunc+0x31>
    if(ip->addrs[i]){
80101459:	8b 54 9e 5c          	mov    0x5c(%esi,%ebx,4),%edx
8010145d:	85 d2                	test   %edx,%edx
8010145f:	74 f2                	je     80101453 <itrunc+0x12>
      bfree(ip->dev, ip->addrs[i]);
80101461:	8b 06                	mov    (%esi),%eax
80101463:	e8 aa fd ff ff       	call   80101212 <bfree>
      ip->addrs[i] = 0;
80101468:	c7 44 9e 5c 00 00 00 	movl   $0x0,0x5c(%esi,%ebx,4)
8010146f:	00 
80101470:	eb e1                	jmp    80101453 <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
80101472:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
80101478:	85 c0                	test   %eax,%eax
8010147a:	75 1b                	jne    80101497 <itrunc+0x56>
  ip->size = 0;
8010147c:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
80101483:	83 ec 0c             	sub    $0xc,%esp
80101486:	56                   	push   %esi
80101487:	e8 38 ff ff ff       	call   801013c4 <iupdate>
}
8010148c:	83 c4 10             	add    $0x10,%esp
8010148f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101492:	5b                   	pop    %ebx
80101493:	5e                   	pop    %esi
80101494:	5f                   	pop    %edi
80101495:	5d                   	pop    %ebp
80101496:	c3                   	ret    
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101497:	83 ec 08             	sub    $0x8,%esp
8010149a:	50                   	push   %eax
8010149b:	ff 36                	push   (%esi)
8010149d:	e8 c8 ec ff ff       	call   8010016a <bread>
801014a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
801014a5:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
801014a8:	83 c4 10             	add    $0x10,%esp
801014ab:	bb 00 00 00 00       	mov    $0x0,%ebx
801014b0:	eb 01                	jmp    801014b3 <itrunc+0x72>
801014b2:	43                   	inc    %ebx
801014b3:	83 fb 7f             	cmp    $0x7f,%ebx
801014b6:	77 10                	ja     801014c8 <itrunc+0x87>
      if(a[j])
801014b8:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
801014bb:	85 d2                	test   %edx,%edx
801014bd:	74 f3                	je     801014b2 <itrunc+0x71>
        bfree(ip->dev, a[j]);
801014bf:	8b 06                	mov    (%esi),%eax
801014c1:	e8 4c fd ff ff       	call   80101212 <bfree>
801014c6:	eb ea                	jmp    801014b2 <itrunc+0x71>
    brelse(bp);
801014c8:	83 ec 0c             	sub    $0xc,%esp
801014cb:	ff 75 e4             	push   -0x1c(%ebp)
801014ce:	e8 00 ed ff ff       	call   801001d3 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
801014d3:	8b 06                	mov    (%esi),%eax
801014d5:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
801014db:	e8 32 fd ff ff       	call   80101212 <bfree>
    ip->addrs[NDIRECT] = 0;
801014e0:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
801014e7:	00 00 00 
801014ea:	83 c4 10             	add    $0x10,%esp
801014ed:	eb 8d                	jmp    8010147c <itrunc+0x3b>

801014ef <idup>:
{
801014ef:	55                   	push   %ebp
801014f0:	89 e5                	mov    %esp,%ebp
801014f2:	53                   	push   %ebx
801014f3:	83 ec 10             	sub    $0x10,%esp
801014f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
801014f9:	68 60 f9 10 80       	push   $0x8010f960
801014fe:	e8 f7 25 00 00       	call   80103afa <acquire>
  ip->ref++;
80101503:	8b 43 08             	mov    0x8(%ebx),%eax
80101506:	40                   	inc    %eax
80101507:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010150a:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101511:	e8 49 26 00 00       	call   80103b5f <release>
}
80101516:	89 d8                	mov    %ebx,%eax
80101518:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010151b:	c9                   	leave  
8010151c:	c3                   	ret    

8010151d <ilock>:
{
8010151d:	55                   	push   %ebp
8010151e:	89 e5                	mov    %esp,%ebp
80101520:	56                   	push   %esi
80101521:	53                   	push   %ebx
80101522:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101525:	85 db                	test   %ebx,%ebx
80101527:	74 22                	je     8010154b <ilock+0x2e>
80101529:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
8010152d:	7e 1c                	jle    8010154b <ilock+0x2e>
  acquiresleep(&ip->lock);
8010152f:	83 ec 0c             	sub    $0xc,%esp
80101532:	8d 43 0c             	lea    0xc(%ebx),%eax
80101535:	50                   	push   %eax
80101536:	e8 b0 23 00 00       	call   801038eb <acquiresleep>
  if(ip->valid == 0){
8010153b:	83 c4 10             	add    $0x10,%esp
8010153e:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101542:	74 14                	je     80101558 <ilock+0x3b>
}
80101544:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101547:	5b                   	pop    %ebx
80101548:	5e                   	pop    %esi
80101549:	5d                   	pop    %ebp
8010154a:	c3                   	ret    
    panic("ilock");
8010154b:	83 ec 0c             	sub    $0xc,%esp
8010154e:	68 6a 6a 10 80       	push   $0x80106a6a
80101553:	e8 e9 ed ff ff       	call   80100341 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101558:	8b 43 04             	mov    0x4(%ebx),%eax
8010155b:	c1 e8 03             	shr    $0x3,%eax
8010155e:	83 ec 08             	sub    $0x8,%esp
80101561:	03 05 c8 15 11 80    	add    0x801115c8,%eax
80101567:	50                   	push   %eax
80101568:	ff 33                	push   (%ebx)
8010156a:	e8 fb eb ff ff       	call   8010016a <bread>
8010156f:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101571:	8b 43 04             	mov    0x4(%ebx),%eax
80101574:	83 e0 07             	and    $0x7,%eax
80101577:	c1 e0 06             	shl    $0x6,%eax
8010157a:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
8010157e:	8b 10                	mov    (%eax),%edx
80101580:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
80101584:	66 8b 50 02          	mov    0x2(%eax),%dx
80101588:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
8010158c:	8b 50 04             	mov    0x4(%eax),%edx
8010158f:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
80101593:	66 8b 50 06          	mov    0x6(%eax),%dx
80101597:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
8010159b:	8b 50 08             	mov    0x8(%eax),%edx
8010159e:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801015a1:	83 c0 0c             	add    $0xc,%eax
801015a4:	8d 53 5c             	lea    0x5c(%ebx),%edx
801015a7:	83 c4 0c             	add    $0xc,%esp
801015aa:	6a 34                	push   $0x34
801015ac:	50                   	push   %eax
801015ad:	52                   	push   %edx
801015ae:	e8 69 26 00 00       	call   80103c1c <memmove>
    brelse(bp);
801015b3:	89 34 24             	mov    %esi,(%esp)
801015b6:	e8 18 ec ff ff       	call   801001d3 <brelse>
    ip->valid = 1;
801015bb:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
801015c2:	83 c4 10             	add    $0x10,%esp
801015c5:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
801015ca:	0f 85 74 ff ff ff    	jne    80101544 <ilock+0x27>
      panic("ilock: no type");
801015d0:	83 ec 0c             	sub    $0xc,%esp
801015d3:	68 70 6a 10 80       	push   $0x80106a70
801015d8:	e8 64 ed ff ff       	call   80100341 <panic>

801015dd <iunlock>:
{
801015dd:	55                   	push   %ebp
801015de:	89 e5                	mov    %esp,%ebp
801015e0:	56                   	push   %esi
801015e1:	53                   	push   %ebx
801015e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801015e5:	85 db                	test   %ebx,%ebx
801015e7:	74 2c                	je     80101615 <iunlock+0x38>
801015e9:	8d 73 0c             	lea    0xc(%ebx),%esi
801015ec:	83 ec 0c             	sub    $0xc,%esp
801015ef:	56                   	push   %esi
801015f0:	e8 80 23 00 00       	call   80103975 <holdingsleep>
801015f5:	83 c4 10             	add    $0x10,%esp
801015f8:	85 c0                	test   %eax,%eax
801015fa:	74 19                	je     80101615 <iunlock+0x38>
801015fc:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101600:	7e 13                	jle    80101615 <iunlock+0x38>
  releasesleep(&ip->lock);
80101602:	83 ec 0c             	sub    $0xc,%esp
80101605:	56                   	push   %esi
80101606:	e8 2f 23 00 00       	call   8010393a <releasesleep>
}
8010160b:	83 c4 10             	add    $0x10,%esp
8010160e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101611:	5b                   	pop    %ebx
80101612:	5e                   	pop    %esi
80101613:	5d                   	pop    %ebp
80101614:	c3                   	ret    
    panic("iunlock");
80101615:	83 ec 0c             	sub    $0xc,%esp
80101618:	68 7f 6a 10 80       	push   $0x80106a7f
8010161d:	e8 1f ed ff ff       	call   80100341 <panic>

80101622 <iput>:
{
80101622:	55                   	push   %ebp
80101623:	89 e5                	mov    %esp,%ebp
80101625:	57                   	push   %edi
80101626:	56                   	push   %esi
80101627:	53                   	push   %ebx
80101628:	83 ec 18             	sub    $0x18,%esp
8010162b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
8010162e:	8d 73 0c             	lea    0xc(%ebx),%esi
80101631:	56                   	push   %esi
80101632:	e8 b4 22 00 00       	call   801038eb <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101637:	83 c4 10             	add    $0x10,%esp
8010163a:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
8010163e:	74 07                	je     80101647 <iput+0x25>
80101640:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101645:	74 33                	je     8010167a <iput+0x58>
  releasesleep(&ip->lock);
80101647:	83 ec 0c             	sub    $0xc,%esp
8010164a:	56                   	push   %esi
8010164b:	e8 ea 22 00 00       	call   8010393a <releasesleep>
  acquire(&icache.lock);
80101650:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101657:	e8 9e 24 00 00       	call   80103afa <acquire>
  ip->ref--;
8010165c:	8b 43 08             	mov    0x8(%ebx),%eax
8010165f:	48                   	dec    %eax
80101660:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
80101663:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
8010166a:	e8 f0 24 00 00       	call   80103b5f <release>
}
8010166f:	83 c4 10             	add    $0x10,%esp
80101672:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101675:	5b                   	pop    %ebx
80101676:	5e                   	pop    %esi
80101677:	5f                   	pop    %edi
80101678:	5d                   	pop    %ebp
80101679:	c3                   	ret    
    acquire(&icache.lock);
8010167a:	83 ec 0c             	sub    $0xc,%esp
8010167d:	68 60 f9 10 80       	push   $0x8010f960
80101682:	e8 73 24 00 00       	call   80103afa <acquire>
    int r = ip->ref;
80101687:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
8010168a:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101691:	e8 c9 24 00 00       	call   80103b5f <release>
    if(r == 1){
80101696:	83 c4 10             	add    $0x10,%esp
80101699:	83 ff 01             	cmp    $0x1,%edi
8010169c:	75 a9                	jne    80101647 <iput+0x25>
      itrunc(ip);
8010169e:	89 d8                	mov    %ebx,%eax
801016a0:	e8 9c fd ff ff       	call   80101441 <itrunc>
      ip->type = 0;
801016a5:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
801016ab:	83 ec 0c             	sub    $0xc,%esp
801016ae:	53                   	push   %ebx
801016af:	e8 10 fd ff ff       	call   801013c4 <iupdate>
      ip->valid = 0;
801016b4:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
801016bb:	83 c4 10             	add    $0x10,%esp
801016be:	eb 87                	jmp    80101647 <iput+0x25>

801016c0 <iunlockput>:
{
801016c0:	55                   	push   %ebp
801016c1:	89 e5                	mov    %esp,%ebp
801016c3:	53                   	push   %ebx
801016c4:	83 ec 10             	sub    $0x10,%esp
801016c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
801016ca:	53                   	push   %ebx
801016cb:	e8 0d ff ff ff       	call   801015dd <iunlock>
  iput(ip);
801016d0:	89 1c 24             	mov    %ebx,(%esp)
801016d3:	e8 4a ff ff ff       	call   80101622 <iput>
}
801016d8:	83 c4 10             	add    $0x10,%esp
801016db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801016de:	c9                   	leave  
801016df:	c3                   	ret    

801016e0 <stati>:
{
801016e0:	55                   	push   %ebp
801016e1:	89 e5                	mov    %esp,%ebp
801016e3:	8b 55 08             	mov    0x8(%ebp),%edx
801016e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
801016e9:	8b 0a                	mov    (%edx),%ecx
801016eb:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
801016ee:	8b 4a 04             	mov    0x4(%edx),%ecx
801016f1:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
801016f4:	8b 4a 50             	mov    0x50(%edx),%ecx
801016f7:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
801016fa:	66 8b 4a 56          	mov    0x56(%edx),%cx
801016fe:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101702:	8b 52 58             	mov    0x58(%edx),%edx
80101705:	89 50 10             	mov    %edx,0x10(%eax)
}
80101708:	5d                   	pop    %ebp
80101709:	c3                   	ret    

8010170a <readi>:
{
8010170a:	55                   	push   %ebp
8010170b:	89 e5                	mov    %esp,%ebp
8010170d:	57                   	push   %edi
8010170e:	56                   	push   %esi
8010170f:	53                   	push   %ebx
80101710:	83 ec 0c             	sub    $0xc,%esp
  if(ip->type == T_DEV){
80101713:	8b 45 08             	mov    0x8(%ebp),%eax
80101716:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
8010171b:	74 2c                	je     80101749 <readi+0x3f>
  if(off > ip->size || off + n < off)
8010171d:	8b 45 08             	mov    0x8(%ebp),%eax
80101720:	8b 40 58             	mov    0x58(%eax),%eax
80101723:	3b 45 10             	cmp    0x10(%ebp),%eax
80101726:	0f 82 d0 00 00 00    	jb     801017fc <readi+0xf2>
8010172c:	8b 55 10             	mov    0x10(%ebp),%edx
8010172f:	03 55 14             	add    0x14(%ebp),%edx
80101732:	0f 82 cb 00 00 00    	jb     80101803 <readi+0xf9>
  if(off + n > ip->size)
80101738:	39 d0                	cmp    %edx,%eax
8010173a:	73 06                	jae    80101742 <readi+0x38>
    n = ip->size - off;
8010173c:	2b 45 10             	sub    0x10(%ebp),%eax
8010173f:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101742:	bf 00 00 00 00       	mov    $0x0,%edi
80101747:	eb 55                	jmp    8010179e <readi+0x94>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101749:	66 8b 40 52          	mov    0x52(%eax),%ax
8010174d:	66 83 f8 09          	cmp    $0x9,%ax
80101751:	0f 87 97 00 00 00    	ja     801017ee <readi+0xe4>
80101757:	98                   	cwtl   
80101758:	8b 04 c5 00 f9 10 80 	mov    -0x7fef0700(,%eax,8),%eax
8010175f:	85 c0                	test   %eax,%eax
80101761:	0f 84 8e 00 00 00    	je     801017f5 <readi+0xeb>
    return devsw[ip->major].read(ip, dst, n);
80101767:	83 ec 04             	sub    $0x4,%esp
8010176a:	ff 75 14             	push   0x14(%ebp)
8010176d:	ff 75 0c             	push   0xc(%ebp)
80101770:	ff 75 08             	push   0x8(%ebp)
80101773:	ff d0                	call   *%eax
80101775:	83 c4 10             	add    $0x10,%esp
80101778:	eb 6c                	jmp    801017e6 <readi+0xdc>
    memmove(dst, bp->data + off%BSIZE, m);
8010177a:	83 ec 04             	sub    $0x4,%esp
8010177d:	53                   	push   %ebx
8010177e:	8d 44 16 5c          	lea    0x5c(%esi,%edx,1),%eax
80101782:	50                   	push   %eax
80101783:	ff 75 0c             	push   0xc(%ebp)
80101786:	e8 91 24 00 00       	call   80103c1c <memmove>
    brelse(bp);
8010178b:	89 34 24             	mov    %esi,(%esp)
8010178e:	e8 40 ea ff ff       	call   801001d3 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101793:	01 df                	add    %ebx,%edi
80101795:	01 5d 10             	add    %ebx,0x10(%ebp)
80101798:	01 5d 0c             	add    %ebx,0xc(%ebp)
8010179b:	83 c4 10             	add    $0x10,%esp
8010179e:	39 7d 14             	cmp    %edi,0x14(%ebp)
801017a1:	76 40                	jbe    801017e3 <readi+0xd9>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801017a3:	8b 55 10             	mov    0x10(%ebp),%edx
801017a6:	c1 ea 09             	shr    $0x9,%edx
801017a9:	8b 45 08             	mov    0x8(%ebp),%eax
801017ac:	e8 da f8 ff ff       	call   8010108b <bmap>
801017b1:	83 ec 08             	sub    $0x8,%esp
801017b4:	50                   	push   %eax
801017b5:	8b 45 08             	mov    0x8(%ebp),%eax
801017b8:	ff 30                	push   (%eax)
801017ba:	e8 ab e9 ff ff       	call   8010016a <bread>
801017bf:	89 c6                	mov    %eax,%esi
    m = min(n - tot, BSIZE - off%BSIZE);
801017c1:	8b 55 10             	mov    0x10(%ebp),%edx
801017c4:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801017ca:	b8 00 02 00 00       	mov    $0x200,%eax
801017cf:	29 d0                	sub    %edx,%eax
801017d1:	8b 4d 14             	mov    0x14(%ebp),%ecx
801017d4:	29 f9                	sub    %edi,%ecx
801017d6:	89 c3                	mov    %eax,%ebx
801017d8:	83 c4 10             	add    $0x10,%esp
801017db:	39 c8                	cmp    %ecx,%eax
801017dd:	76 9b                	jbe    8010177a <readi+0x70>
801017df:	89 cb                	mov    %ecx,%ebx
801017e1:	eb 97                	jmp    8010177a <readi+0x70>
  return n;
801017e3:	8b 45 14             	mov    0x14(%ebp),%eax
}
801017e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017e9:	5b                   	pop    %ebx
801017ea:	5e                   	pop    %esi
801017eb:	5f                   	pop    %edi
801017ec:	5d                   	pop    %ebp
801017ed:	c3                   	ret    
      return -1;
801017ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801017f3:	eb f1                	jmp    801017e6 <readi+0xdc>
801017f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801017fa:	eb ea                	jmp    801017e6 <readi+0xdc>
    return -1;
801017fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101801:	eb e3                	jmp    801017e6 <readi+0xdc>
80101803:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101808:	eb dc                	jmp    801017e6 <readi+0xdc>

8010180a <writei>:
{
8010180a:	55                   	push   %ebp
8010180b:	89 e5                	mov    %esp,%ebp
8010180d:	57                   	push   %edi
8010180e:	56                   	push   %esi
8010180f:	53                   	push   %ebx
80101810:	83 ec 0c             	sub    $0xc,%esp
  if(ip->type == T_DEV){
80101813:	8b 45 08             	mov    0x8(%ebp),%eax
80101816:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
8010181b:	74 2c                	je     80101849 <writei+0x3f>
  if(off > ip->size || off + n < off)
8010181d:	8b 45 08             	mov    0x8(%ebp),%eax
80101820:	8b 7d 10             	mov    0x10(%ebp),%edi
80101823:	39 78 58             	cmp    %edi,0x58(%eax)
80101826:	0f 82 fd 00 00 00    	jb     80101929 <writei+0x11f>
8010182c:	89 f8                	mov    %edi,%eax
8010182e:	03 45 14             	add    0x14(%ebp),%eax
80101831:	0f 82 f9 00 00 00    	jb     80101930 <writei+0x126>
  if(off + n > MAXFILE*BSIZE)
80101837:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010183c:	0f 87 f5 00 00 00    	ja     80101937 <writei+0x12d>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101842:	bf 00 00 00 00       	mov    $0x0,%edi
80101847:	eb 60                	jmp    801018a9 <writei+0x9f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101849:	66 8b 40 52          	mov    0x52(%eax),%ax
8010184d:	66 83 f8 09          	cmp    $0x9,%ax
80101851:	0f 87 c4 00 00 00    	ja     8010191b <writei+0x111>
80101857:	98                   	cwtl   
80101858:	8b 04 c5 04 f9 10 80 	mov    -0x7fef06fc(,%eax,8),%eax
8010185f:	85 c0                	test   %eax,%eax
80101861:	0f 84 bb 00 00 00    	je     80101922 <writei+0x118>
    return devsw[ip->major].write(ip, src, n);
80101867:	83 ec 04             	sub    $0x4,%esp
8010186a:	ff 75 14             	push   0x14(%ebp)
8010186d:	ff 75 0c             	push   0xc(%ebp)
80101870:	ff 75 08             	push   0x8(%ebp)
80101873:	ff d0                	call   *%eax
80101875:	83 c4 10             	add    $0x10,%esp
80101878:	e9 85 00 00 00       	jmp    80101902 <writei+0xf8>
    memmove(bp->data + off%BSIZE, src, m);
8010187d:	83 ec 04             	sub    $0x4,%esp
80101880:	56                   	push   %esi
80101881:	ff 75 0c             	push   0xc(%ebp)
80101884:	8d 44 13 5c          	lea    0x5c(%ebx,%edx,1),%eax
80101888:	50                   	push   %eax
80101889:	e8 8e 23 00 00       	call   80103c1c <memmove>
    log_write(bp);
8010188e:	89 1c 24             	mov    %ebx,(%esp)
80101891:	e8 86 0f 00 00       	call   8010281c <log_write>
    brelse(bp);
80101896:	89 1c 24             	mov    %ebx,(%esp)
80101899:	e8 35 e9 ff ff       	call   801001d3 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010189e:	01 f7                	add    %esi,%edi
801018a0:	01 75 10             	add    %esi,0x10(%ebp)
801018a3:	01 75 0c             	add    %esi,0xc(%ebp)
801018a6:	83 c4 10             	add    $0x10,%esp
801018a9:	3b 7d 14             	cmp    0x14(%ebp),%edi
801018ac:	73 40                	jae    801018ee <writei+0xe4>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801018ae:	8b 55 10             	mov    0x10(%ebp),%edx
801018b1:	c1 ea 09             	shr    $0x9,%edx
801018b4:	8b 45 08             	mov    0x8(%ebp),%eax
801018b7:	e8 cf f7 ff ff       	call   8010108b <bmap>
801018bc:	83 ec 08             	sub    $0x8,%esp
801018bf:	50                   	push   %eax
801018c0:	8b 45 08             	mov    0x8(%ebp),%eax
801018c3:	ff 30                	push   (%eax)
801018c5:	e8 a0 e8 ff ff       	call   8010016a <bread>
801018ca:	89 c3                	mov    %eax,%ebx
    m = min(n - tot, BSIZE - off%BSIZE);
801018cc:	8b 55 10             	mov    0x10(%ebp),%edx
801018cf:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801018d5:	b8 00 02 00 00       	mov    $0x200,%eax
801018da:	29 d0                	sub    %edx,%eax
801018dc:	8b 4d 14             	mov    0x14(%ebp),%ecx
801018df:	29 f9                	sub    %edi,%ecx
801018e1:	89 c6                	mov    %eax,%esi
801018e3:	83 c4 10             	add    $0x10,%esp
801018e6:	39 c8                	cmp    %ecx,%eax
801018e8:	76 93                	jbe    8010187d <writei+0x73>
801018ea:	89 ce                	mov    %ecx,%esi
801018ec:	eb 8f                	jmp    8010187d <writei+0x73>
  if(n > 0 && off > ip->size){
801018ee:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801018f2:	74 0b                	je     801018ff <writei+0xf5>
801018f4:	8b 45 08             	mov    0x8(%ebp),%eax
801018f7:	8b 7d 10             	mov    0x10(%ebp),%edi
801018fa:	39 78 58             	cmp    %edi,0x58(%eax)
801018fd:	72 0b                	jb     8010190a <writei+0x100>
  return n;
801018ff:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101902:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101905:	5b                   	pop    %ebx
80101906:	5e                   	pop    %esi
80101907:	5f                   	pop    %edi
80101908:	5d                   	pop    %ebp
80101909:	c3                   	ret    
    ip->size = off;
8010190a:	89 78 58             	mov    %edi,0x58(%eax)
    iupdate(ip);
8010190d:	83 ec 0c             	sub    $0xc,%esp
80101910:	50                   	push   %eax
80101911:	e8 ae fa ff ff       	call   801013c4 <iupdate>
80101916:	83 c4 10             	add    $0x10,%esp
80101919:	eb e4                	jmp    801018ff <writei+0xf5>
      return -1;
8010191b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101920:	eb e0                	jmp    80101902 <writei+0xf8>
80101922:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101927:	eb d9                	jmp    80101902 <writei+0xf8>
    return -1;
80101929:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010192e:	eb d2                	jmp    80101902 <writei+0xf8>
80101930:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101935:	eb cb                	jmp    80101902 <writei+0xf8>
    return -1;
80101937:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010193c:	eb c4                	jmp    80101902 <writei+0xf8>

8010193e <namecmp>:
{
8010193e:	55                   	push   %ebp
8010193f:	89 e5                	mov    %esp,%ebp
80101941:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101944:	6a 0e                	push   $0xe
80101946:	ff 75 0c             	push   0xc(%ebp)
80101949:	ff 75 08             	push   0x8(%ebp)
8010194c:	e8 31 23 00 00       	call   80103c82 <strncmp>
}
80101951:	c9                   	leave  
80101952:	c3                   	ret    

80101953 <dirlookup>:
{
80101953:	55                   	push   %ebp
80101954:	89 e5                	mov    %esp,%ebp
80101956:	57                   	push   %edi
80101957:	56                   	push   %esi
80101958:	53                   	push   %ebx
80101959:	83 ec 1c             	sub    $0x1c,%esp
8010195c:	8b 75 08             	mov    0x8(%ebp),%esi
8010195f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(dp->type != T_DIR)
80101962:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101967:	75 07                	jne    80101970 <dirlookup+0x1d>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101969:	bb 00 00 00 00       	mov    $0x0,%ebx
8010196e:	eb 1d                	jmp    8010198d <dirlookup+0x3a>
    panic("dirlookup not DIR");
80101970:	83 ec 0c             	sub    $0xc,%esp
80101973:	68 87 6a 10 80       	push   $0x80106a87
80101978:	e8 c4 e9 ff ff       	call   80100341 <panic>
      panic("dirlookup read");
8010197d:	83 ec 0c             	sub    $0xc,%esp
80101980:	68 99 6a 10 80       	push   $0x80106a99
80101985:	e8 b7 e9 ff ff       	call   80100341 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
8010198a:	83 c3 10             	add    $0x10,%ebx
8010198d:	39 5e 58             	cmp    %ebx,0x58(%esi)
80101990:	76 48                	jbe    801019da <dirlookup+0x87>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101992:	6a 10                	push   $0x10
80101994:	53                   	push   %ebx
80101995:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101998:	50                   	push   %eax
80101999:	56                   	push   %esi
8010199a:	e8 6b fd ff ff       	call   8010170a <readi>
8010199f:	83 c4 10             	add    $0x10,%esp
801019a2:	83 f8 10             	cmp    $0x10,%eax
801019a5:	75 d6                	jne    8010197d <dirlookup+0x2a>
    if(de.inum == 0)
801019a7:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
801019ac:	74 dc                	je     8010198a <dirlookup+0x37>
    if(namecmp(name, de.name) == 0){
801019ae:	83 ec 08             	sub    $0x8,%esp
801019b1:	8d 45 da             	lea    -0x26(%ebp),%eax
801019b4:	50                   	push   %eax
801019b5:	57                   	push   %edi
801019b6:	e8 83 ff ff ff       	call   8010193e <namecmp>
801019bb:	83 c4 10             	add    $0x10,%esp
801019be:	85 c0                	test   %eax,%eax
801019c0:	75 c8                	jne    8010198a <dirlookup+0x37>
      if(poff)
801019c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801019c6:	74 05                	je     801019cd <dirlookup+0x7a>
        *poff = off;
801019c8:	8b 45 10             	mov    0x10(%ebp),%eax
801019cb:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
801019cd:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
801019d1:	8b 06                	mov    (%esi),%eax
801019d3:	e8 59 f7 ff ff       	call   80101131 <iget>
801019d8:	eb 05                	jmp    801019df <dirlookup+0x8c>
  return 0;
801019da:	b8 00 00 00 00       	mov    $0x0,%eax
}
801019df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801019e2:	5b                   	pop    %ebx
801019e3:	5e                   	pop    %esi
801019e4:	5f                   	pop    %edi
801019e5:	5d                   	pop    %ebp
801019e6:	c3                   	ret    

801019e7 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801019e7:	55                   	push   %ebp
801019e8:	89 e5                	mov    %esp,%ebp
801019ea:	57                   	push   %edi
801019eb:	56                   	push   %esi
801019ec:	53                   	push   %ebx
801019ed:	83 ec 1c             	sub    $0x1c,%esp
801019f0:	89 c3                	mov    %eax,%ebx
801019f2:	89 55 e0             	mov    %edx,-0x20(%ebp)
801019f5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
801019f8:	80 38 2f             	cmpb   $0x2f,(%eax)
801019fb:	74 17                	je     80101a14 <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
801019fd:	e8 34 17 00 00       	call   80103136 <myproc>
80101a02:	83 ec 0c             	sub    $0xc,%esp
80101a05:	ff 70 70             	push   0x70(%eax)
80101a08:	e8 e2 fa ff ff       	call   801014ef <idup>
80101a0d:	89 c6                	mov    %eax,%esi
80101a0f:	83 c4 10             	add    $0x10,%esp
80101a12:	eb 53                	jmp    80101a67 <namex+0x80>
    ip = iget(ROOTDEV, ROOTINO);
80101a14:	ba 01 00 00 00       	mov    $0x1,%edx
80101a19:	b8 01 00 00 00       	mov    $0x1,%eax
80101a1e:	e8 0e f7 ff ff       	call   80101131 <iget>
80101a23:	89 c6                	mov    %eax,%esi
80101a25:	eb 40                	jmp    80101a67 <namex+0x80>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101a27:	83 ec 0c             	sub    $0xc,%esp
80101a2a:	56                   	push   %esi
80101a2b:	e8 90 fc ff ff       	call   801016c0 <iunlockput>
      return 0;
80101a30:	83 c4 10             	add    $0x10,%esp
80101a33:	be 00 00 00 00       	mov    $0x0,%esi
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101a38:	89 f0                	mov    %esi,%eax
80101a3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a3d:	5b                   	pop    %ebx
80101a3e:	5e                   	pop    %esi
80101a3f:	5f                   	pop    %edi
80101a40:	5d                   	pop    %ebp
80101a41:	c3                   	ret    
    if((next = dirlookup(ip, name, 0)) == 0){
80101a42:	83 ec 04             	sub    $0x4,%esp
80101a45:	6a 00                	push   $0x0
80101a47:	ff 75 e4             	push   -0x1c(%ebp)
80101a4a:	56                   	push   %esi
80101a4b:	e8 03 ff ff ff       	call   80101953 <dirlookup>
80101a50:	89 c7                	mov    %eax,%edi
80101a52:	83 c4 10             	add    $0x10,%esp
80101a55:	85 c0                	test   %eax,%eax
80101a57:	74 4a                	je     80101aa3 <namex+0xbc>
    iunlockput(ip);
80101a59:	83 ec 0c             	sub    $0xc,%esp
80101a5c:	56                   	push   %esi
80101a5d:	e8 5e fc ff ff       	call   801016c0 <iunlockput>
80101a62:	83 c4 10             	add    $0x10,%esp
    ip = next;
80101a65:	89 fe                	mov    %edi,%esi
  while((path = skipelem(path, name)) != 0){
80101a67:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101a6a:	89 d8                	mov    %ebx,%eax
80101a6c:	e8 97 f4 ff ff       	call   80100f08 <skipelem>
80101a71:	89 c3                	mov    %eax,%ebx
80101a73:	85 c0                	test   %eax,%eax
80101a75:	74 3c                	je     80101ab3 <namex+0xcc>
    ilock(ip);
80101a77:	83 ec 0c             	sub    $0xc,%esp
80101a7a:	56                   	push   %esi
80101a7b:	e8 9d fa ff ff       	call   8010151d <ilock>
    if(ip->type != T_DIR){
80101a80:	83 c4 10             	add    $0x10,%esp
80101a83:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101a88:	75 9d                	jne    80101a27 <namex+0x40>
    if(nameiparent && *path == '\0'){
80101a8a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101a8e:	74 b2                	je     80101a42 <namex+0x5b>
80101a90:	80 3b 00             	cmpb   $0x0,(%ebx)
80101a93:	75 ad                	jne    80101a42 <namex+0x5b>
      iunlock(ip);
80101a95:	83 ec 0c             	sub    $0xc,%esp
80101a98:	56                   	push   %esi
80101a99:	e8 3f fb ff ff       	call   801015dd <iunlock>
      return ip;
80101a9e:	83 c4 10             	add    $0x10,%esp
80101aa1:	eb 95                	jmp    80101a38 <namex+0x51>
      iunlockput(ip);
80101aa3:	83 ec 0c             	sub    $0xc,%esp
80101aa6:	56                   	push   %esi
80101aa7:	e8 14 fc ff ff       	call   801016c0 <iunlockput>
      return 0;
80101aac:	83 c4 10             	add    $0x10,%esp
80101aaf:	89 fe                	mov    %edi,%esi
80101ab1:	eb 85                	jmp    80101a38 <namex+0x51>
  if(nameiparent){
80101ab3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101ab7:	0f 84 7b ff ff ff    	je     80101a38 <namex+0x51>
    iput(ip);
80101abd:	83 ec 0c             	sub    $0xc,%esp
80101ac0:	56                   	push   %esi
80101ac1:	e8 5c fb ff ff       	call   80101622 <iput>
    return 0;
80101ac6:	83 c4 10             	add    $0x10,%esp
80101ac9:	89 de                	mov    %ebx,%esi
80101acb:	e9 68 ff ff ff       	jmp    80101a38 <namex+0x51>

80101ad0 <dirlink>:
{
80101ad0:	55                   	push   %ebp
80101ad1:	89 e5                	mov    %esp,%ebp
80101ad3:	57                   	push   %edi
80101ad4:	56                   	push   %esi
80101ad5:	53                   	push   %ebx
80101ad6:	83 ec 20             	sub    $0x20,%esp
80101ad9:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101adc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101adf:	6a 00                	push   $0x0
80101ae1:	57                   	push   %edi
80101ae2:	53                   	push   %ebx
80101ae3:	e8 6b fe ff ff       	call   80101953 <dirlookup>
80101ae8:	83 c4 10             	add    $0x10,%esp
80101aeb:	85 c0                	test   %eax,%eax
80101aed:	75 2d                	jne    80101b1c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101aef:	b8 00 00 00 00       	mov    $0x0,%eax
80101af4:	89 c6                	mov    %eax,%esi
80101af6:	39 43 58             	cmp    %eax,0x58(%ebx)
80101af9:	76 41                	jbe    80101b3c <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101afb:	6a 10                	push   $0x10
80101afd:	50                   	push   %eax
80101afe:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101b01:	50                   	push   %eax
80101b02:	53                   	push   %ebx
80101b03:	e8 02 fc ff ff       	call   8010170a <readi>
80101b08:	83 c4 10             	add    $0x10,%esp
80101b0b:	83 f8 10             	cmp    $0x10,%eax
80101b0e:	75 1f                	jne    80101b2f <dirlink+0x5f>
    if(de.inum == 0)
80101b10:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101b15:	74 25                	je     80101b3c <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b17:	8d 46 10             	lea    0x10(%esi),%eax
80101b1a:	eb d8                	jmp    80101af4 <dirlink+0x24>
    iput(ip);
80101b1c:	83 ec 0c             	sub    $0xc,%esp
80101b1f:	50                   	push   %eax
80101b20:	e8 fd fa ff ff       	call   80101622 <iput>
    return -1;
80101b25:	83 c4 10             	add    $0x10,%esp
80101b28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b2d:	eb 3d                	jmp    80101b6c <dirlink+0x9c>
      panic("dirlink read");
80101b2f:	83 ec 0c             	sub    $0xc,%esp
80101b32:	68 a8 6a 10 80       	push   $0x80106aa8
80101b37:	e8 05 e8 ff ff       	call   80100341 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b3c:	83 ec 04             	sub    $0x4,%esp
80101b3f:	6a 0e                	push   $0xe
80101b41:	57                   	push   %edi
80101b42:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101b45:	8d 45 da             	lea    -0x26(%ebp),%eax
80101b48:	50                   	push   %eax
80101b49:	e8 6c 21 00 00       	call   80103cba <strncpy>
  de.inum = inum;
80101b4e:	8b 45 10             	mov    0x10(%ebp),%eax
80101b51:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101b55:	6a 10                	push   $0x10
80101b57:	56                   	push   %esi
80101b58:	57                   	push   %edi
80101b59:	53                   	push   %ebx
80101b5a:	e8 ab fc ff ff       	call   8010180a <writei>
80101b5f:	83 c4 20             	add    $0x20,%esp
80101b62:	83 f8 10             	cmp    $0x10,%eax
80101b65:	75 0d                	jne    80101b74 <dirlink+0xa4>
  return 0;
80101b67:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101b6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b6f:	5b                   	pop    %ebx
80101b70:	5e                   	pop    %esi
80101b71:	5f                   	pop    %edi
80101b72:	5d                   	pop    %ebp
80101b73:	c3                   	ret    
    panic("dirlink");
80101b74:	83 ec 0c             	sub    $0xc,%esp
80101b77:	68 98 70 10 80       	push   $0x80107098
80101b7c:	e8 c0 e7 ff ff       	call   80100341 <panic>

80101b81 <namei>:

struct inode*
namei(char *path)
{
80101b81:	55                   	push   %ebp
80101b82:	89 e5                	mov    %esp,%ebp
80101b84:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101b87:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101b8a:	ba 00 00 00 00       	mov    $0x0,%edx
80101b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b92:	e8 50 fe ff ff       	call   801019e7 <namex>
}
80101b97:	c9                   	leave  
80101b98:	c3                   	ret    

80101b99 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101b99:	55                   	push   %ebp
80101b9a:	89 e5                	mov    %esp,%ebp
80101b9c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101b9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101ba2:	ba 01 00 00 00       	mov    $0x1,%edx
80101ba7:	8b 45 08             	mov    0x8(%ebp),%eax
80101baa:	e8 38 fe ff ff       	call   801019e7 <namex>
}
80101baf:	c9                   	leave  
80101bb0:	c3                   	ret    

80101bb1 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101bb1:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101bb3:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101bb8:	ec                   	in     (%dx),%al
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101bb9:	88 c2                	mov    %al,%dl
80101bbb:	83 e2 c0             	and    $0xffffffc0,%edx
80101bbe:	80 fa 40             	cmp    $0x40,%dl
80101bc1:	75 f0                	jne    80101bb3 <idewait+0x2>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101bc3:	85 c9                	test   %ecx,%ecx
80101bc5:	74 09                	je     80101bd0 <idewait+0x1f>
80101bc7:	a8 21                	test   $0x21,%al
80101bc9:	75 08                	jne    80101bd3 <idewait+0x22>
    return -1;
  return 0;
80101bcb:	b9 00 00 00 00       	mov    $0x0,%ecx
}
80101bd0:	89 c8                	mov    %ecx,%eax
80101bd2:	c3                   	ret    
    return -1;
80101bd3:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
80101bd8:	eb f6                	jmp    80101bd0 <idewait+0x1f>

80101bda <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101bda:	55                   	push   %ebp
80101bdb:	89 e5                	mov    %esp,%ebp
80101bdd:	56                   	push   %esi
80101bde:	53                   	push   %ebx
  if(b == 0)
80101bdf:	85 c0                	test   %eax,%eax
80101be1:	0f 84 85 00 00 00    	je     80101c6c <idestart+0x92>
80101be7:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101be9:	8b 58 08             	mov    0x8(%eax),%ebx
80101bec:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101bf2:	0f 87 81 00 00 00    	ja     80101c79 <idestart+0x9f>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101bf8:	b8 00 00 00 00       	mov    $0x0,%eax
80101bfd:	e8 af ff ff ff       	call   80101bb1 <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101c02:	b0 00                	mov    $0x0,%al
80101c04:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101c09:	ee                   	out    %al,(%dx)
80101c0a:	b0 01                	mov    $0x1,%al
80101c0c:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101c11:	ee                   	out    %al,(%dx)
80101c12:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101c17:	88 d8                	mov    %bl,%al
80101c19:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101c1a:	0f b6 c7             	movzbl %bh,%eax
80101c1d:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101c22:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101c23:	89 d8                	mov    %ebx,%eax
80101c25:	c1 f8 10             	sar    $0x10,%eax
80101c28:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101c2d:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101c2e:	8a 46 04             	mov    0x4(%esi),%al
80101c31:	c1 e0 04             	shl    $0x4,%eax
80101c34:	83 e0 10             	and    $0x10,%eax
80101c37:	c1 fb 18             	sar    $0x18,%ebx
80101c3a:	83 e3 0f             	and    $0xf,%ebx
80101c3d:	09 d8                	or     %ebx,%eax
80101c3f:	83 c8 e0             	or     $0xffffffe0,%eax
80101c42:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101c47:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101c48:	f6 06 04             	testb  $0x4,(%esi)
80101c4b:	74 39                	je     80101c86 <idestart+0xac>
80101c4d:	b0 30                	mov    $0x30,%al
80101c4f:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c54:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
80101c55:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101c58:	b9 80 00 00 00       	mov    $0x80,%ecx
80101c5d:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101c62:	fc                   	cld    
80101c63:	f3 6f                	rep outsl %ds:(%esi),(%dx)
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101c65:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101c68:	5b                   	pop    %ebx
80101c69:	5e                   	pop    %esi
80101c6a:	5d                   	pop    %ebp
80101c6b:	c3                   	ret    
    panic("idestart");
80101c6c:	83 ec 0c             	sub    $0xc,%esp
80101c6f:	68 0b 6b 10 80       	push   $0x80106b0b
80101c74:	e8 c8 e6 ff ff       	call   80100341 <panic>
    panic("incorrect blockno");
80101c79:	83 ec 0c             	sub    $0xc,%esp
80101c7c:	68 14 6b 10 80       	push   $0x80106b14
80101c81:	e8 bb e6 ff ff       	call   80100341 <panic>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101c86:	b0 20                	mov    $0x20,%al
80101c88:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c8d:	ee                   	out    %al,(%dx)
}
80101c8e:	eb d5                	jmp    80101c65 <idestart+0x8b>

80101c90 <ideinit>:
{
80101c90:	55                   	push   %ebp
80101c91:	89 e5                	mov    %esp,%ebp
80101c93:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101c96:	68 26 6b 10 80       	push   $0x80106b26
80101c9b:	68 00 16 11 80       	push   $0x80111600
80101ca0:	e8 1e 1d 00 00       	call   801039c3 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101ca5:	83 c4 08             	add    $0x8,%esp
80101ca8:	a1 84 17 11 80       	mov    0x80111784,%eax
80101cad:	48                   	dec    %eax
80101cae:	50                   	push   %eax
80101caf:	6a 0e                	push   $0xe
80101cb1:	e8 46 02 00 00       	call   80101efc <ioapicenable>
  idewait(0);
80101cb6:	b8 00 00 00 00       	mov    $0x0,%eax
80101cbb:	e8 f1 fe ff ff       	call   80101bb1 <idewait>
80101cc0:	b0 f0                	mov    $0xf0,%al
80101cc2:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101cc7:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101cc8:	83 c4 10             	add    $0x10,%esp
80101ccb:	b9 00 00 00 00       	mov    $0x0,%ecx
80101cd0:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101cd6:	7f 17                	jg     80101cef <ideinit+0x5f>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101cd8:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101cdd:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101cde:	84 c0                	test   %al,%al
80101ce0:	75 03                	jne    80101ce5 <ideinit+0x55>
  for(i=0; i<1000; i++){
80101ce2:	41                   	inc    %ecx
80101ce3:	eb eb                	jmp    80101cd0 <ideinit+0x40>
      havedisk1 = 1;
80101ce5:	c7 05 e0 15 11 80 01 	movl   $0x1,0x801115e0
80101cec:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101cef:	b0 e0                	mov    $0xe0,%al
80101cf1:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101cf6:	ee                   	out    %al,(%dx)
}
80101cf7:	c9                   	leave  
80101cf8:	c3                   	ret    

80101cf9 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101cf9:	55                   	push   %ebp
80101cfa:	89 e5                	mov    %esp,%ebp
80101cfc:	57                   	push   %edi
80101cfd:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101cfe:	83 ec 0c             	sub    $0xc,%esp
80101d01:	68 00 16 11 80       	push   $0x80111600
80101d06:	e8 ef 1d 00 00       	call   80103afa <acquire>

  if((b = idequeue) == 0){
80101d0b:	8b 1d e4 15 11 80    	mov    0x801115e4,%ebx
80101d11:	83 c4 10             	add    $0x10,%esp
80101d14:	85 db                	test   %ebx,%ebx
80101d16:	74 4a                	je     80101d62 <ideintr+0x69>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101d18:	8b 43 58             	mov    0x58(%ebx),%eax
80101d1b:	a3 e4 15 11 80       	mov    %eax,0x801115e4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101d20:	f6 03 04             	testb  $0x4,(%ebx)
80101d23:	74 4f                	je     80101d74 <ideintr+0x7b>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101d25:	8b 03                	mov    (%ebx),%eax
80101d27:	83 c8 02             	or     $0x2,%eax
80101d2a:	89 03                	mov    %eax,(%ebx)
  b->flags &= ~B_DIRTY;
80101d2c:	83 e0 fb             	and    $0xfffffffb,%eax
80101d2f:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101d31:	83 ec 0c             	sub    $0xc,%esp
80101d34:	53                   	push   %ebx
80101d35:	e8 2c 1a 00 00       	call   80103766 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101d3a:	a1 e4 15 11 80       	mov    0x801115e4,%eax
80101d3f:	83 c4 10             	add    $0x10,%esp
80101d42:	85 c0                	test   %eax,%eax
80101d44:	74 05                	je     80101d4b <ideintr+0x52>
    idestart(idequeue);
80101d46:	e8 8f fe ff ff       	call   80101bda <idestart>

  release(&idelock);
80101d4b:	83 ec 0c             	sub    $0xc,%esp
80101d4e:	68 00 16 11 80       	push   $0x80111600
80101d53:	e8 07 1e 00 00       	call   80103b5f <release>
80101d58:	83 c4 10             	add    $0x10,%esp
}
80101d5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101d5e:	5b                   	pop    %ebx
80101d5f:	5f                   	pop    %edi
80101d60:	5d                   	pop    %ebp
80101d61:	c3                   	ret    
    release(&idelock);
80101d62:	83 ec 0c             	sub    $0xc,%esp
80101d65:	68 00 16 11 80       	push   $0x80111600
80101d6a:	e8 f0 1d 00 00       	call   80103b5f <release>
    return;
80101d6f:	83 c4 10             	add    $0x10,%esp
80101d72:	eb e7                	jmp    80101d5b <ideintr+0x62>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101d74:	b8 01 00 00 00       	mov    $0x1,%eax
80101d79:	e8 33 fe ff ff       	call   80101bb1 <idewait>
80101d7e:	85 c0                	test   %eax,%eax
80101d80:	78 a3                	js     80101d25 <ideintr+0x2c>
    insl(0x1f0, b->data, BSIZE/4);
80101d82:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101d85:	b9 80 00 00 00       	mov    $0x80,%ecx
80101d8a:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101d8f:	fc                   	cld    
80101d90:	f3 6d                	rep insl (%dx),%es:(%edi)
}
80101d92:	eb 91                	jmp    80101d25 <ideintr+0x2c>

80101d94 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101d94:	55                   	push   %ebp
80101d95:	89 e5                	mov    %esp,%ebp
80101d97:	53                   	push   %ebx
80101d98:	83 ec 10             	sub    $0x10,%esp
80101d9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101d9e:	8d 43 0c             	lea    0xc(%ebx),%eax
80101da1:	50                   	push   %eax
80101da2:	e8 ce 1b 00 00       	call   80103975 <holdingsleep>
80101da7:	83 c4 10             	add    $0x10,%esp
80101daa:	85 c0                	test   %eax,%eax
80101dac:	74 37                	je     80101de5 <iderw+0x51>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101dae:	8b 03                	mov    (%ebx),%eax
80101db0:	83 e0 06             	and    $0x6,%eax
80101db3:	83 f8 02             	cmp    $0x2,%eax
80101db6:	74 3a                	je     80101df2 <iderw+0x5e>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101db8:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101dbc:	74 09                	je     80101dc7 <iderw+0x33>
80101dbe:	83 3d e0 15 11 80 00 	cmpl   $0x0,0x801115e0
80101dc5:	74 38                	je     80101dff <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101dc7:	83 ec 0c             	sub    $0xc,%esp
80101dca:	68 00 16 11 80       	push   $0x80111600
80101dcf:	e8 26 1d 00 00       	call   80103afa <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101dd4:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101ddb:	83 c4 10             	add    $0x10,%esp
80101dde:	ba e4 15 11 80       	mov    $0x801115e4,%edx
80101de3:	eb 2a                	jmp    80101e0f <iderw+0x7b>
    panic("iderw: buf not locked");
80101de5:	83 ec 0c             	sub    $0xc,%esp
80101de8:	68 2a 6b 10 80       	push   $0x80106b2a
80101ded:	e8 4f e5 ff ff       	call   80100341 <panic>
    panic("iderw: nothing to do");
80101df2:	83 ec 0c             	sub    $0xc,%esp
80101df5:	68 40 6b 10 80       	push   $0x80106b40
80101dfa:	e8 42 e5 ff ff       	call   80100341 <panic>
    panic("iderw: ide disk 1 not present");
80101dff:	83 ec 0c             	sub    $0xc,%esp
80101e02:	68 55 6b 10 80       	push   $0x80106b55
80101e07:	e8 35 e5 ff ff       	call   80100341 <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e0c:	8d 50 58             	lea    0x58(%eax),%edx
80101e0f:	8b 02                	mov    (%edx),%eax
80101e11:	85 c0                	test   %eax,%eax
80101e13:	75 f7                	jne    80101e0c <iderw+0x78>
    ;
  *pp = b;
80101e15:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101e17:	39 1d e4 15 11 80    	cmp    %ebx,0x801115e4
80101e1d:	75 1a                	jne    80101e39 <iderw+0xa5>
    idestart(b);
80101e1f:	89 d8                	mov    %ebx,%eax
80101e21:	e8 b4 fd ff ff       	call   80101bda <idestart>
80101e26:	eb 11                	jmp    80101e39 <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101e28:	83 ec 08             	sub    $0x8,%esp
80101e2b:	68 00 16 11 80       	push   $0x80111600
80101e30:	53                   	push   %ebx
80101e31:	e8 be 17 00 00       	call   801035f4 <sleep>
80101e36:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101e39:	8b 03                	mov    (%ebx),%eax
80101e3b:	83 e0 06             	and    $0x6,%eax
80101e3e:	83 f8 02             	cmp    $0x2,%eax
80101e41:	75 e5                	jne    80101e28 <iderw+0x94>
  }


  release(&idelock);
80101e43:	83 ec 0c             	sub    $0xc,%esp
80101e46:	68 00 16 11 80       	push   $0x80111600
80101e4b:	e8 0f 1d 00 00       	call   80103b5f <release>
}
80101e50:	83 c4 10             	add    $0x10,%esp
80101e53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101e56:	c9                   	leave  
80101e57:	c3                   	ret    

80101e58 <ioapicread>:
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
80101e58:	8b 15 34 16 11 80    	mov    0x80111634,%edx
80101e5e:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101e60:	a1 34 16 11 80       	mov    0x80111634,%eax
80101e65:	8b 40 10             	mov    0x10(%eax),%eax
}
80101e68:	c3                   	ret    

80101e69 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80101e69:	8b 0d 34 16 11 80    	mov    0x80111634,%ecx
80101e6f:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101e71:	a1 34 16 11 80       	mov    0x80111634,%eax
80101e76:	89 50 10             	mov    %edx,0x10(%eax)
}
80101e79:	c3                   	ret    

80101e7a <ioapicinit>:

void
ioapicinit(void)
{
80101e7a:	55                   	push   %ebp
80101e7b:	89 e5                	mov    %esp,%ebp
80101e7d:	57                   	push   %edi
80101e7e:	56                   	push   %esi
80101e7f:	53                   	push   %ebx
80101e80:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101e83:	c7 05 34 16 11 80 00 	movl   $0xfec00000,0x80111634
80101e8a:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101e8d:	b8 01 00 00 00       	mov    $0x1,%eax
80101e92:	e8 c1 ff ff ff       	call   80101e58 <ioapicread>
80101e97:	c1 e8 10             	shr    $0x10,%eax
80101e9a:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80101e9d:	b8 00 00 00 00       	mov    $0x0,%eax
80101ea2:	e8 b1 ff ff ff       	call   80101e58 <ioapicread>
80101ea7:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101eaa:	0f b6 15 80 17 11 80 	movzbl 0x80111780,%edx
80101eb1:	39 c2                	cmp    %eax,%edx
80101eb3:	75 07                	jne    80101ebc <ioapicinit+0x42>
{
80101eb5:	bb 00 00 00 00       	mov    $0x0,%ebx
80101eba:	eb 34                	jmp    80101ef0 <ioapicinit+0x76>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101ebc:	83 ec 0c             	sub    $0xc,%esp
80101ebf:	68 74 6b 10 80       	push   $0x80106b74
80101ec4:	e8 11 e7 ff ff       	call   801005da <cprintf>
80101ec9:	83 c4 10             	add    $0x10,%esp
80101ecc:	eb e7                	jmp    80101eb5 <ioapicinit+0x3b>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101ece:	8d 53 20             	lea    0x20(%ebx),%edx
80101ed1:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101ed7:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101edb:	89 f0                	mov    %esi,%eax
80101edd:	e8 87 ff ff ff       	call   80101e69 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101ee2:	8d 46 01             	lea    0x1(%esi),%eax
80101ee5:	ba 00 00 00 00       	mov    $0x0,%edx
80101eea:	e8 7a ff ff ff       	call   80101e69 <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80101eef:	43                   	inc    %ebx
80101ef0:	39 fb                	cmp    %edi,%ebx
80101ef2:	7e da                	jle    80101ece <ioapicinit+0x54>
  }
}
80101ef4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101ef7:	5b                   	pop    %ebx
80101ef8:	5e                   	pop    %esi
80101ef9:	5f                   	pop    %edi
80101efa:	5d                   	pop    %ebp
80101efb:	c3                   	ret    

80101efc <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80101efc:	55                   	push   %ebp
80101efd:	89 e5                	mov    %esp,%ebp
80101eff:	53                   	push   %ebx
80101f00:	83 ec 04             	sub    $0x4,%esp
80101f03:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101f06:	8d 50 20             	lea    0x20(%eax),%edx
80101f09:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80101f0d:	89 d8                	mov    %ebx,%eax
80101f0f:	e8 55 ff ff ff       	call   80101e69 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101f14:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f17:	c1 e2 18             	shl    $0x18,%edx
80101f1a:	8d 43 01             	lea    0x1(%ebx),%eax
80101f1d:	e8 47 ff ff ff       	call   80101e69 <ioapicwrite>
}
80101f22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101f25:	c9                   	leave  
80101f26:	c3                   	ret    

80101f27 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80101f27:	55                   	push   %ebp
80101f28:	89 e5                	mov    %esp,%ebp
80101f2a:	53                   	push   %ebx
80101f2b:	83 ec 04             	sub    $0x4,%esp
80101f2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80101f31:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80101f37:	75 4c                	jne    80101f85 <kfree+0x5e>
80101f39:	81 fb d0 56 11 80    	cmp    $0x801156d0,%ebx
80101f3f:	72 44                	jb     80101f85 <kfree+0x5e>
80101f41:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80101f47:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80101f4c:	77 37                	ja     80101f85 <kfree+0x5e>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80101f4e:	83 ec 04             	sub    $0x4,%esp
80101f51:	68 00 10 00 00       	push   $0x1000
80101f56:	6a 01                	push   $0x1
80101f58:	53                   	push   %ebx
80101f59:	e8 48 1c 00 00       	call   80103ba6 <memset>

  if(kmem.use_lock)
80101f5e:	83 c4 10             	add    $0x10,%esp
80101f61:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80101f68:	75 28                	jne    80101f92 <kfree+0x6b>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80101f6a:	a1 78 16 11 80       	mov    0x80111678,%eax
80101f6f:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80101f71:	89 1d 78 16 11 80    	mov    %ebx,0x80111678
  if(kmem.use_lock)
80101f77:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80101f7e:	75 24                	jne    80101fa4 <kfree+0x7d>
    release(&kmem.lock);
}
80101f80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101f83:	c9                   	leave  
80101f84:	c3                   	ret    
    panic("kfree");
80101f85:	83 ec 0c             	sub    $0xc,%esp
80101f88:	68 a6 6b 10 80       	push   $0x80106ba6
80101f8d:	e8 af e3 ff ff       	call   80100341 <panic>
    acquire(&kmem.lock);
80101f92:	83 ec 0c             	sub    $0xc,%esp
80101f95:	68 40 16 11 80       	push   $0x80111640
80101f9a:	e8 5b 1b 00 00       	call   80103afa <acquire>
80101f9f:	83 c4 10             	add    $0x10,%esp
80101fa2:	eb c6                	jmp    80101f6a <kfree+0x43>
    release(&kmem.lock);
80101fa4:	83 ec 0c             	sub    $0xc,%esp
80101fa7:	68 40 16 11 80       	push   $0x80111640
80101fac:	e8 ae 1b 00 00       	call   80103b5f <release>
80101fb1:	83 c4 10             	add    $0x10,%esp
}
80101fb4:	eb ca                	jmp    80101f80 <kfree+0x59>

80101fb6 <freerange>:
{
80101fb6:	55                   	push   %ebp
80101fb7:	89 e5                	mov    %esp,%ebp
80101fb9:	56                   	push   %esi
80101fba:	53                   	push   %ebx
80101fbb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  p = (char*)PGROUNDUP((uint)vstart);
80101fbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc1:	05 ff 0f 00 00       	add    $0xfff,%eax
80101fc6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80101fcb:	eb 0e                	jmp    80101fdb <freerange+0x25>
    kfree(p);
80101fcd:	83 ec 0c             	sub    $0xc,%esp
80101fd0:	50                   	push   %eax
80101fd1:	e8 51 ff ff ff       	call   80101f27 <kfree>
80101fd6:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80101fd9:	89 f0                	mov    %esi,%eax
80101fdb:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
80101fe1:	39 de                	cmp    %ebx,%esi
80101fe3:	76 e8                	jbe    80101fcd <freerange+0x17>
}
80101fe5:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101fe8:	5b                   	pop    %ebx
80101fe9:	5e                   	pop    %esi
80101fea:	5d                   	pop    %ebp
80101feb:	c3                   	ret    

80101fec <kinit1>:
{
80101fec:	55                   	push   %ebp
80101fed:	89 e5                	mov    %esp,%ebp
80101fef:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
80101ff2:	68 ac 6b 10 80       	push   $0x80106bac
80101ff7:	68 40 16 11 80       	push   $0x80111640
80101ffc:	e8 c2 19 00 00       	call   801039c3 <initlock>
  kmem.use_lock = 0;
80102001:	c7 05 74 16 11 80 00 	movl   $0x0,0x80111674
80102008:	00 00 00 
  freerange(vstart, vend);
8010200b:	83 c4 08             	add    $0x8,%esp
8010200e:	ff 75 0c             	push   0xc(%ebp)
80102011:	ff 75 08             	push   0x8(%ebp)
80102014:	e8 9d ff ff ff       	call   80101fb6 <freerange>
}
80102019:	83 c4 10             	add    $0x10,%esp
8010201c:	c9                   	leave  
8010201d:	c3                   	ret    

8010201e <kinit2>:
{
8010201e:	55                   	push   %ebp
8010201f:	89 e5                	mov    %esp,%ebp
80102021:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
80102024:	ff 75 0c             	push   0xc(%ebp)
80102027:	ff 75 08             	push   0x8(%ebp)
8010202a:	e8 87 ff ff ff       	call   80101fb6 <freerange>
  kmem.use_lock = 1;
8010202f:	c7 05 74 16 11 80 01 	movl   $0x1,0x80111674
80102036:	00 00 00 
}
80102039:	83 c4 10             	add    $0x10,%esp
8010203c:	c9                   	leave  
8010203d:	c3                   	ret    

8010203e <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
8010203e:	55                   	push   %ebp
8010203f:	89 e5                	mov    %esp,%ebp
80102041:	53                   	push   %ebx
80102042:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
80102045:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
8010204c:	75 21                	jne    8010206f <kalloc+0x31>
    acquire(&kmem.lock);
  r = kmem.freelist;
8010204e:	8b 1d 78 16 11 80    	mov    0x80111678,%ebx
  if(r)
80102054:	85 db                	test   %ebx,%ebx
80102056:	74 07                	je     8010205f <kalloc+0x21>
    kmem.freelist = r->next;
80102058:	8b 03                	mov    (%ebx),%eax
8010205a:	a3 78 16 11 80       	mov    %eax,0x80111678
  if(kmem.use_lock)
8010205f:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80102066:	75 19                	jne    80102081 <kalloc+0x43>
    release(&kmem.lock);
  return (char*)r;
}
80102068:	89 d8                	mov    %ebx,%eax
8010206a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010206d:	c9                   	leave  
8010206e:	c3                   	ret    
    acquire(&kmem.lock);
8010206f:	83 ec 0c             	sub    $0xc,%esp
80102072:	68 40 16 11 80       	push   $0x80111640
80102077:	e8 7e 1a 00 00       	call   80103afa <acquire>
8010207c:	83 c4 10             	add    $0x10,%esp
8010207f:	eb cd                	jmp    8010204e <kalloc+0x10>
    release(&kmem.lock);
80102081:	83 ec 0c             	sub    $0xc,%esp
80102084:	68 40 16 11 80       	push   $0x80111640
80102089:	e8 d1 1a 00 00       	call   80103b5f <release>
8010208e:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102091:	eb d5                	jmp    80102068 <kalloc+0x2a>

80102093 <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102093:	ba 64 00 00 00       	mov    $0x64,%edx
80102098:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102099:	a8 01                	test   $0x1,%al
8010209b:	0f 84 b3 00 00 00    	je     80102154 <kbdgetc+0xc1>
801020a1:	ba 60 00 00 00       	mov    $0x60,%edx
801020a6:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
801020a7:	0f b6 c8             	movzbl %al,%ecx

  if(data == 0xE0){
801020aa:	3c e0                	cmp    $0xe0,%al
801020ac:	74 61                	je     8010210f <kbdgetc+0x7c>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
801020ae:	84 c0                	test   %al,%al
801020b0:	78 6a                	js     8010211c <kbdgetc+0x89>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801020b2:	8b 15 7c 16 11 80    	mov    0x8011167c,%edx
801020b8:	f6 c2 40             	test   $0x40,%dl
801020bb:	74 0f                	je     801020cc <kbdgetc+0x39>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801020bd:	83 c8 80             	or     $0xffffff80,%eax
801020c0:	0f b6 c8             	movzbl %al,%ecx
    shift &= ~E0ESC;
801020c3:	83 e2 bf             	and    $0xffffffbf,%edx
801020c6:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  }

  shift |= shiftcode[data];
801020cc:	0f b6 91 e0 6c 10 80 	movzbl -0x7fef9320(%ecx),%edx
801020d3:	0b 15 7c 16 11 80    	or     0x8011167c,%edx
801020d9:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  shift ^= togglecode[data];
801020df:	0f b6 81 e0 6b 10 80 	movzbl -0x7fef9420(%ecx),%eax
801020e6:	31 c2                	xor    %eax,%edx
801020e8:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  c = charcode[shift & (CTL | SHIFT)][data];
801020ee:	89 d0                	mov    %edx,%eax
801020f0:	83 e0 03             	and    $0x3,%eax
801020f3:	8b 04 85 c0 6b 10 80 	mov    -0x7fef9440(,%eax,4),%eax
801020fa:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
  if(shift & CAPSLOCK){
801020fe:	f6 c2 08             	test   $0x8,%dl
80102101:	74 56                	je     80102159 <kbdgetc+0xc6>
    if('a' <= c && c <= 'z')
80102103:	8d 50 9f             	lea    -0x61(%eax),%edx
80102106:	83 fa 19             	cmp    $0x19,%edx
80102109:	77 3d                	ja     80102148 <kbdgetc+0xb5>
      c += 'A' - 'a';
8010210b:	83 e8 20             	sub    $0x20,%eax
8010210e:	c3                   	ret    
    shift |= E0ESC;
8010210f:	83 0d 7c 16 11 80 40 	orl    $0x40,0x8011167c
    return 0;
80102116:	b8 00 00 00 00       	mov    $0x0,%eax
8010211b:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
8010211c:	8b 15 7c 16 11 80    	mov    0x8011167c,%edx
80102122:	f6 c2 40             	test   $0x40,%dl
80102125:	75 05                	jne    8010212c <kbdgetc+0x99>
80102127:	89 c1                	mov    %eax,%ecx
80102129:	83 e1 7f             	and    $0x7f,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
8010212c:	8a 81 e0 6c 10 80    	mov    -0x7fef9320(%ecx),%al
80102132:	83 c8 40             	or     $0x40,%eax
80102135:	0f b6 c0             	movzbl %al,%eax
80102138:	f7 d0                	not    %eax
8010213a:	21 c2                	and    %eax,%edx
8010213c:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
    return 0;
80102142:	b8 00 00 00 00       	mov    $0x0,%eax
80102147:	c3                   	ret    
    else if('A' <= c && c <= 'Z')
80102148:	8d 50 bf             	lea    -0x41(%eax),%edx
8010214b:	83 fa 19             	cmp    $0x19,%edx
8010214e:	77 09                	ja     80102159 <kbdgetc+0xc6>
      c += 'a' - 'A';
80102150:	83 c0 20             	add    $0x20,%eax
  }
  return c;
80102153:	c3                   	ret    
    return -1;
80102154:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102159:	c3                   	ret    

8010215a <kbdintr>:

void
kbdintr(void)
{
8010215a:	55                   	push   %ebp
8010215b:	89 e5                	mov    %esp,%ebp
8010215d:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102160:	68 93 20 10 80       	push   $0x80102093
80102165:	e8 95 e5 ff ff       	call   801006ff <consoleintr>
}
8010216a:	83 c4 10             	add    $0x10,%esp
8010216d:	c9                   	leave  
8010216e:	c3                   	ret    

8010216f <lapicw>:

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010216f:	8b 0d 80 16 11 80    	mov    0x80111680,%ecx
80102175:	8d 04 81             	lea    (%ecx,%eax,4),%eax
80102178:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010217a:	a1 80 16 11 80       	mov    0x80111680,%eax
8010217f:	8b 40 20             	mov    0x20(%eax),%eax
}
80102182:	c3                   	ret    

80102183 <cmos_read>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102183:	ba 70 00 00 00       	mov    $0x70,%edx
80102188:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102189:	ba 71 00 00 00       	mov    $0x71,%edx
8010218e:	ec                   	in     (%dx),%al
cmos_read(uint reg)
{
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
8010218f:	0f b6 c0             	movzbl %al,%eax
}
80102192:	c3                   	ret    

80102193 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
80102193:	55                   	push   %ebp
80102194:	89 e5                	mov    %esp,%ebp
80102196:	53                   	push   %ebx
80102197:	83 ec 04             	sub    $0x4,%esp
8010219a:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
8010219c:	b8 00 00 00 00       	mov    $0x0,%eax
801021a1:	e8 dd ff ff ff       	call   80102183 <cmos_read>
801021a6:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
801021a8:	b8 02 00 00 00       	mov    $0x2,%eax
801021ad:	e8 d1 ff ff ff       	call   80102183 <cmos_read>
801021b2:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
801021b5:	b8 04 00 00 00       	mov    $0x4,%eax
801021ba:	e8 c4 ff ff ff       	call   80102183 <cmos_read>
801021bf:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
801021c2:	b8 07 00 00 00       	mov    $0x7,%eax
801021c7:	e8 b7 ff ff ff       	call   80102183 <cmos_read>
801021cc:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
801021cf:	b8 08 00 00 00       	mov    $0x8,%eax
801021d4:	e8 aa ff ff ff       	call   80102183 <cmos_read>
801021d9:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
801021dc:	b8 09 00 00 00       	mov    $0x9,%eax
801021e1:	e8 9d ff ff ff       	call   80102183 <cmos_read>
801021e6:	89 43 14             	mov    %eax,0x14(%ebx)
}
801021e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801021ec:	c9                   	leave  
801021ed:	c3                   	ret    

801021ee <lapicinit>:
  if(!lapic)
801021ee:	83 3d 80 16 11 80 00 	cmpl   $0x0,0x80111680
801021f5:	0f 84 fe 00 00 00    	je     801022f9 <lapicinit+0x10b>
{
801021fb:	55                   	push   %ebp
801021fc:	89 e5                	mov    %esp,%ebp
801021fe:	83 ec 08             	sub    $0x8,%esp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102201:	ba 3f 01 00 00       	mov    $0x13f,%edx
80102206:	b8 3c 00 00 00       	mov    $0x3c,%eax
8010220b:	e8 5f ff ff ff       	call   8010216f <lapicw>
  lapicw(TDCR, X1);
80102210:	ba 0b 00 00 00       	mov    $0xb,%edx
80102215:	b8 f8 00 00 00       	mov    $0xf8,%eax
8010221a:	e8 50 ff ff ff       	call   8010216f <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010221f:	ba 20 00 02 00       	mov    $0x20020,%edx
80102224:	b8 c8 00 00 00       	mov    $0xc8,%eax
80102229:	e8 41 ff ff ff       	call   8010216f <lapicw>
  lapicw(TICR, 10000000);
8010222e:	ba 80 96 98 00       	mov    $0x989680,%edx
80102233:	b8 e0 00 00 00       	mov    $0xe0,%eax
80102238:	e8 32 ff ff ff       	call   8010216f <lapicw>
  lapicw(LINT0, MASKED);
8010223d:	ba 00 00 01 00       	mov    $0x10000,%edx
80102242:	b8 d4 00 00 00       	mov    $0xd4,%eax
80102247:	e8 23 ff ff ff       	call   8010216f <lapicw>
  lapicw(LINT1, MASKED);
8010224c:	ba 00 00 01 00       	mov    $0x10000,%edx
80102251:	b8 d8 00 00 00       	mov    $0xd8,%eax
80102256:	e8 14 ff ff ff       	call   8010216f <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010225b:	a1 80 16 11 80       	mov    0x80111680,%eax
80102260:	8b 40 30             	mov    0x30(%eax),%eax
80102263:	c1 e8 10             	shr    $0x10,%eax
80102266:	a8 fc                	test   $0xfc,%al
80102268:	75 7b                	jne    801022e5 <lapicinit+0xf7>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010226a:	ba 33 00 00 00       	mov    $0x33,%edx
8010226f:	b8 dc 00 00 00       	mov    $0xdc,%eax
80102274:	e8 f6 fe ff ff       	call   8010216f <lapicw>
  lapicw(ESR, 0);
80102279:	ba 00 00 00 00       	mov    $0x0,%edx
8010227e:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102283:	e8 e7 fe ff ff       	call   8010216f <lapicw>
  lapicw(ESR, 0);
80102288:	ba 00 00 00 00       	mov    $0x0,%edx
8010228d:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102292:	e8 d8 fe ff ff       	call   8010216f <lapicw>
  lapicw(EOI, 0);
80102297:	ba 00 00 00 00       	mov    $0x0,%edx
8010229c:	b8 2c 00 00 00       	mov    $0x2c,%eax
801022a1:	e8 c9 fe ff ff       	call   8010216f <lapicw>
  lapicw(ICRHI, 0);
801022a6:	ba 00 00 00 00       	mov    $0x0,%edx
801022ab:	b8 c4 00 00 00       	mov    $0xc4,%eax
801022b0:	e8 ba fe ff ff       	call   8010216f <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801022b5:	ba 00 85 08 00       	mov    $0x88500,%edx
801022ba:	b8 c0 00 00 00       	mov    $0xc0,%eax
801022bf:	e8 ab fe ff ff       	call   8010216f <lapicw>
  while(lapic[ICRLO] & DELIVS)
801022c4:	a1 80 16 11 80       	mov    0x80111680,%eax
801022c9:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
801022cf:	f6 c4 10             	test   $0x10,%ah
801022d2:	75 f0                	jne    801022c4 <lapicinit+0xd6>
  lapicw(TPR, 0);
801022d4:	ba 00 00 00 00       	mov    $0x0,%edx
801022d9:	b8 20 00 00 00       	mov    $0x20,%eax
801022de:	e8 8c fe ff ff       	call   8010216f <lapicw>
}
801022e3:	c9                   	leave  
801022e4:	c3                   	ret    
    lapicw(PCINT, MASKED);
801022e5:	ba 00 00 01 00       	mov    $0x10000,%edx
801022ea:	b8 d0 00 00 00       	mov    $0xd0,%eax
801022ef:	e8 7b fe ff ff       	call   8010216f <lapicw>
801022f4:	e9 71 ff ff ff       	jmp    8010226a <lapicinit+0x7c>
801022f9:	c3                   	ret    

801022fa <lapicid>:
  if (!lapic)
801022fa:	a1 80 16 11 80       	mov    0x80111680,%eax
801022ff:	85 c0                	test   %eax,%eax
80102301:	74 07                	je     8010230a <lapicid+0x10>
  return lapic[ID] >> 24;
80102303:	8b 40 20             	mov    0x20(%eax),%eax
80102306:	c1 e8 18             	shr    $0x18,%eax
80102309:	c3                   	ret    
    return 0;
8010230a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010230f:	c3                   	ret    

80102310 <lapiceoi>:
  if(lapic)
80102310:	83 3d 80 16 11 80 00 	cmpl   $0x0,0x80111680
80102317:	74 17                	je     80102330 <lapiceoi+0x20>
{
80102319:	55                   	push   %ebp
8010231a:	89 e5                	mov    %esp,%ebp
8010231c:	83 ec 08             	sub    $0x8,%esp
    lapicw(EOI, 0);
8010231f:	ba 00 00 00 00       	mov    $0x0,%edx
80102324:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102329:	e8 41 fe ff ff       	call   8010216f <lapicw>
}
8010232e:	c9                   	leave  
8010232f:	c3                   	ret    
80102330:	c3                   	ret    

80102331 <microdelay>:
}
80102331:	c3                   	ret    

80102332 <lapicstartap>:
{
80102332:	55                   	push   %ebp
80102333:	89 e5                	mov    %esp,%ebp
80102335:	57                   	push   %edi
80102336:	56                   	push   %esi
80102337:	53                   	push   %ebx
80102338:	83 ec 0c             	sub    $0xc,%esp
8010233b:	8b 75 08             	mov    0x8(%ebp),%esi
8010233e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102341:	b0 0f                	mov    $0xf,%al
80102343:	ba 70 00 00 00       	mov    $0x70,%edx
80102348:	ee                   	out    %al,(%dx)
80102349:	b0 0a                	mov    $0xa,%al
8010234b:	ba 71 00 00 00       	mov    $0x71,%edx
80102350:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
80102351:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
80102358:	00 00 
  wrv[1] = addr >> 4;
8010235a:	89 f8                	mov    %edi,%eax
8010235c:	c1 e8 04             	shr    $0x4,%eax
8010235f:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
80102365:	c1 e6 18             	shl    $0x18,%esi
80102368:	89 f2                	mov    %esi,%edx
8010236a:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010236f:	e8 fb fd ff ff       	call   8010216f <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102374:	ba 00 c5 00 00       	mov    $0xc500,%edx
80102379:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010237e:	e8 ec fd ff ff       	call   8010216f <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
80102383:	ba 00 85 00 00       	mov    $0x8500,%edx
80102388:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010238d:	e8 dd fd ff ff       	call   8010216f <lapicw>
  for(i = 0; i < 2; i++){
80102392:	bb 00 00 00 00       	mov    $0x0,%ebx
80102397:	eb 1f                	jmp    801023b8 <lapicstartap+0x86>
    lapicw(ICRHI, apicid<<24);
80102399:	89 f2                	mov    %esi,%edx
8010239b:	b8 c4 00 00 00       	mov    $0xc4,%eax
801023a0:	e8 ca fd ff ff       	call   8010216f <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801023a5:	89 fa                	mov    %edi,%edx
801023a7:	c1 ea 0c             	shr    $0xc,%edx
801023aa:	80 ce 06             	or     $0x6,%dh
801023ad:	b8 c0 00 00 00       	mov    $0xc0,%eax
801023b2:	e8 b8 fd ff ff       	call   8010216f <lapicw>
  for(i = 0; i < 2; i++){
801023b7:	43                   	inc    %ebx
801023b8:	83 fb 01             	cmp    $0x1,%ebx
801023bb:	7e dc                	jle    80102399 <lapicstartap+0x67>
}
801023bd:	83 c4 0c             	add    $0xc,%esp
801023c0:	5b                   	pop    %ebx
801023c1:	5e                   	pop    %esi
801023c2:	5f                   	pop    %edi
801023c3:	5d                   	pop    %ebp
801023c4:	c3                   	ret    

801023c5 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801023c5:	55                   	push   %ebp
801023c6:	89 e5                	mov    %esp,%ebp
801023c8:	57                   	push   %edi
801023c9:	56                   	push   %esi
801023ca:	53                   	push   %ebx
801023cb:	83 ec 3c             	sub    $0x3c,%esp
801023ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801023d1:	b8 0b 00 00 00       	mov    $0xb,%eax
801023d6:	e8 a8 fd ff ff       	call   80102183 <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
801023db:	83 e0 04             	and    $0x4,%eax
801023de:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801023e0:	8d 45 d0             	lea    -0x30(%ebp),%eax
801023e3:	e8 ab fd ff ff       	call   80102193 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801023e8:	b8 0a 00 00 00       	mov    $0xa,%eax
801023ed:	e8 91 fd ff ff       	call   80102183 <cmos_read>
801023f2:	a8 80                	test   $0x80,%al
801023f4:	75 ea                	jne    801023e0 <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
801023f6:	8d 75 b8             	lea    -0x48(%ebp),%esi
801023f9:	89 f0                	mov    %esi,%eax
801023fb:	e8 93 fd ff ff       	call   80102193 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102400:	83 ec 04             	sub    $0x4,%esp
80102403:	6a 18                	push   $0x18
80102405:	56                   	push   %esi
80102406:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102409:	50                   	push   %eax
8010240a:	e8 de 17 00 00       	call   80103bed <memcmp>
8010240f:	83 c4 10             	add    $0x10,%esp
80102412:	85 c0                	test   %eax,%eax
80102414:	75 ca                	jne    801023e0 <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
80102416:	85 ff                	test   %edi,%edi
80102418:	75 7e                	jne    80102498 <cmostime+0xd3>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010241a:	8b 55 d0             	mov    -0x30(%ebp),%edx
8010241d:	89 d0                	mov    %edx,%eax
8010241f:	c1 e8 04             	shr    $0x4,%eax
80102422:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102425:	01 c0                	add    %eax,%eax
80102427:	83 e2 0f             	and    $0xf,%edx
8010242a:	01 d0                	add    %edx,%eax
8010242c:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
8010242f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80102432:	89 d0                	mov    %edx,%eax
80102434:	c1 e8 04             	shr    $0x4,%eax
80102437:	8d 04 80             	lea    (%eax,%eax,4),%eax
8010243a:	01 c0                	add    %eax,%eax
8010243c:	83 e2 0f             	and    $0xf,%edx
8010243f:	01 d0                	add    %edx,%eax
80102441:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
80102444:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102447:	89 d0                	mov    %edx,%eax
80102449:	c1 e8 04             	shr    $0x4,%eax
8010244c:	8d 04 80             	lea    (%eax,%eax,4),%eax
8010244f:	01 c0                	add    %eax,%eax
80102451:	83 e2 0f             	and    $0xf,%edx
80102454:	01 d0                	add    %edx,%eax
80102456:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
80102459:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010245c:	89 d0                	mov    %edx,%eax
8010245e:	c1 e8 04             	shr    $0x4,%eax
80102461:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102464:	01 c0                	add    %eax,%eax
80102466:	83 e2 0f             	and    $0xf,%edx
80102469:	01 d0                	add    %edx,%eax
8010246b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
8010246e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102471:	89 d0                	mov    %edx,%eax
80102473:	c1 e8 04             	shr    $0x4,%eax
80102476:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102479:	01 c0                	add    %eax,%eax
8010247b:	83 e2 0f             	and    $0xf,%edx
8010247e:	01 d0                	add    %edx,%eax
80102480:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
80102483:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102486:	89 d0                	mov    %edx,%eax
80102488:	c1 e8 04             	shr    $0x4,%eax
8010248b:	8d 04 80             	lea    (%eax,%eax,4),%eax
8010248e:	01 c0                	add    %eax,%eax
80102490:	83 e2 0f             	and    $0xf,%edx
80102493:	01 d0                	add    %edx,%eax
80102495:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
80102498:	8d 75 d0             	lea    -0x30(%ebp),%esi
8010249b:	b9 06 00 00 00       	mov    $0x6,%ecx
801024a0:	89 df                	mov    %ebx,%edi
801024a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
801024a4:	81 43 14 d0 07 00 00 	addl   $0x7d0,0x14(%ebx)
}
801024ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
801024ae:	5b                   	pop    %ebx
801024af:	5e                   	pop    %esi
801024b0:	5f                   	pop    %edi
801024b1:	5d                   	pop    %ebp
801024b2:	c3                   	ret    

801024b3 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801024b3:	55                   	push   %ebp
801024b4:	89 e5                	mov    %esp,%ebp
801024b6:	53                   	push   %ebx
801024b7:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801024ba:	ff 35 d4 16 11 80    	push   0x801116d4
801024c0:	ff 35 e4 16 11 80    	push   0x801116e4
801024c6:	e8 9f dc ff ff       	call   8010016a <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
801024cb:	8b 58 5c             	mov    0x5c(%eax),%ebx
801024ce:	89 1d e8 16 11 80    	mov    %ebx,0x801116e8
  for (i = 0; i < log.lh.n; i++) {
801024d4:	83 c4 10             	add    $0x10,%esp
801024d7:	ba 00 00 00 00       	mov    $0x0,%edx
801024dc:	eb 0c                	jmp    801024ea <read_head+0x37>
    log.lh.block[i] = lh->block[i];
801024de:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
801024e2:	89 0c 95 ec 16 11 80 	mov    %ecx,-0x7feee914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801024e9:	42                   	inc    %edx
801024ea:	39 d3                	cmp    %edx,%ebx
801024ec:	7f f0                	jg     801024de <read_head+0x2b>
  }
  brelse(buf);
801024ee:	83 ec 0c             	sub    $0xc,%esp
801024f1:	50                   	push   %eax
801024f2:	e8 dc dc ff ff       	call   801001d3 <brelse>
}
801024f7:	83 c4 10             	add    $0x10,%esp
801024fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801024fd:	c9                   	leave  
801024fe:	c3                   	ret    

801024ff <install_trans>:
{
801024ff:	55                   	push   %ebp
80102500:	89 e5                	mov    %esp,%ebp
80102502:	57                   	push   %edi
80102503:	56                   	push   %esi
80102504:	53                   	push   %ebx
80102505:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102508:	be 00 00 00 00       	mov    $0x0,%esi
8010250d:	eb 62                	jmp    80102571 <install_trans+0x72>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010250f:	89 f0                	mov    %esi,%eax
80102511:	03 05 d4 16 11 80    	add    0x801116d4,%eax
80102517:	40                   	inc    %eax
80102518:	83 ec 08             	sub    $0x8,%esp
8010251b:	50                   	push   %eax
8010251c:	ff 35 e4 16 11 80    	push   0x801116e4
80102522:	e8 43 dc ff ff       	call   8010016a <bread>
80102527:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102529:	83 c4 08             	add    $0x8,%esp
8010252c:	ff 34 b5 ec 16 11 80 	push   -0x7feee914(,%esi,4)
80102533:	ff 35 e4 16 11 80    	push   0x801116e4
80102539:	e8 2c dc ff ff       	call   8010016a <bread>
8010253e:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102540:	8d 57 5c             	lea    0x5c(%edi),%edx
80102543:	8d 40 5c             	lea    0x5c(%eax),%eax
80102546:	83 c4 0c             	add    $0xc,%esp
80102549:	68 00 02 00 00       	push   $0x200
8010254e:	52                   	push   %edx
8010254f:	50                   	push   %eax
80102550:	e8 c7 16 00 00       	call   80103c1c <memmove>
    bwrite(dbuf);  // write dst to disk
80102555:	89 1c 24             	mov    %ebx,(%esp)
80102558:	e8 3b dc ff ff       	call   80100198 <bwrite>
    brelse(lbuf);
8010255d:	89 3c 24             	mov    %edi,(%esp)
80102560:	e8 6e dc ff ff       	call   801001d3 <brelse>
    brelse(dbuf);
80102565:	89 1c 24             	mov    %ebx,(%esp)
80102568:	e8 66 dc ff ff       	call   801001d3 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
8010256d:	46                   	inc    %esi
8010256e:	83 c4 10             	add    $0x10,%esp
80102571:	39 35 e8 16 11 80    	cmp    %esi,0x801116e8
80102577:	7f 96                	jg     8010250f <install_trans+0x10>
}
80102579:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010257c:	5b                   	pop    %ebx
8010257d:	5e                   	pop    %esi
8010257e:	5f                   	pop    %edi
8010257f:	5d                   	pop    %ebp
80102580:	c3                   	ret    

80102581 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102581:	55                   	push   %ebp
80102582:	89 e5                	mov    %esp,%ebp
80102584:	53                   	push   %ebx
80102585:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102588:	ff 35 d4 16 11 80    	push   0x801116d4
8010258e:	ff 35 e4 16 11 80    	push   0x801116e4
80102594:	e8 d1 db ff ff       	call   8010016a <bread>
80102599:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
8010259b:	8b 0d e8 16 11 80    	mov    0x801116e8,%ecx
801025a1:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
801025a4:	83 c4 10             	add    $0x10,%esp
801025a7:	b8 00 00 00 00       	mov    $0x0,%eax
801025ac:	eb 0c                	jmp    801025ba <write_head+0x39>
    hb->block[i] = log.lh.block[i];
801025ae:	8b 14 85 ec 16 11 80 	mov    -0x7feee914(,%eax,4),%edx
801025b5:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
801025b9:	40                   	inc    %eax
801025ba:	39 c1                	cmp    %eax,%ecx
801025bc:	7f f0                	jg     801025ae <write_head+0x2d>
  }
  bwrite(buf);
801025be:	83 ec 0c             	sub    $0xc,%esp
801025c1:	53                   	push   %ebx
801025c2:	e8 d1 db ff ff       	call   80100198 <bwrite>
  brelse(buf);
801025c7:	89 1c 24             	mov    %ebx,(%esp)
801025ca:	e8 04 dc ff ff       	call   801001d3 <brelse>
}
801025cf:	83 c4 10             	add    $0x10,%esp
801025d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801025d5:	c9                   	leave  
801025d6:	c3                   	ret    

801025d7 <recover_from_log>:

static void
recover_from_log(void)
{
801025d7:	55                   	push   %ebp
801025d8:	89 e5                	mov    %esp,%ebp
801025da:	83 ec 08             	sub    $0x8,%esp
  read_head();
801025dd:	e8 d1 fe ff ff       	call   801024b3 <read_head>
  install_trans(); // if committed, copy from log to disk
801025e2:	e8 18 ff ff ff       	call   801024ff <install_trans>
  log.lh.n = 0;
801025e7:	c7 05 e8 16 11 80 00 	movl   $0x0,0x801116e8
801025ee:	00 00 00 
  write_head(); // clear the log
801025f1:	e8 8b ff ff ff       	call   80102581 <write_head>
}
801025f6:	c9                   	leave  
801025f7:	c3                   	ret    

801025f8 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801025f8:	55                   	push   %ebp
801025f9:	89 e5                	mov    %esp,%ebp
801025fb:	57                   	push   %edi
801025fc:	56                   	push   %esi
801025fd:	53                   	push   %ebx
801025fe:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102601:	be 00 00 00 00       	mov    $0x0,%esi
80102606:	eb 62                	jmp    8010266a <write_log+0x72>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102608:	89 f0                	mov    %esi,%eax
8010260a:	03 05 d4 16 11 80    	add    0x801116d4,%eax
80102610:	40                   	inc    %eax
80102611:	83 ec 08             	sub    $0x8,%esp
80102614:	50                   	push   %eax
80102615:	ff 35 e4 16 11 80    	push   0x801116e4
8010261b:	e8 4a db ff ff       	call   8010016a <bread>
80102620:	89 c3                	mov    %eax,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102622:	83 c4 08             	add    $0x8,%esp
80102625:	ff 34 b5 ec 16 11 80 	push   -0x7feee914(,%esi,4)
8010262c:	ff 35 e4 16 11 80    	push   0x801116e4
80102632:	e8 33 db ff ff       	call   8010016a <bread>
80102637:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102639:	8d 50 5c             	lea    0x5c(%eax),%edx
8010263c:	8d 43 5c             	lea    0x5c(%ebx),%eax
8010263f:	83 c4 0c             	add    $0xc,%esp
80102642:	68 00 02 00 00       	push   $0x200
80102647:	52                   	push   %edx
80102648:	50                   	push   %eax
80102649:	e8 ce 15 00 00       	call   80103c1c <memmove>
    bwrite(to);  // write the log
8010264e:	89 1c 24             	mov    %ebx,(%esp)
80102651:	e8 42 db ff ff       	call   80100198 <bwrite>
    brelse(from);
80102656:	89 3c 24             	mov    %edi,(%esp)
80102659:	e8 75 db ff ff       	call   801001d3 <brelse>
    brelse(to);
8010265e:	89 1c 24             	mov    %ebx,(%esp)
80102661:	e8 6d db ff ff       	call   801001d3 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102666:	46                   	inc    %esi
80102667:	83 c4 10             	add    $0x10,%esp
8010266a:	39 35 e8 16 11 80    	cmp    %esi,0x801116e8
80102670:	7f 96                	jg     80102608 <write_log+0x10>
  }
}
80102672:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102675:	5b                   	pop    %ebx
80102676:	5e                   	pop    %esi
80102677:	5f                   	pop    %edi
80102678:	5d                   	pop    %ebp
80102679:	c3                   	ret    

8010267a <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
8010267a:	83 3d e8 16 11 80 00 	cmpl   $0x0,0x801116e8
80102681:	7f 01                	jg     80102684 <commit+0xa>
80102683:	c3                   	ret    
{
80102684:	55                   	push   %ebp
80102685:	89 e5                	mov    %esp,%ebp
80102687:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
8010268a:	e8 69 ff ff ff       	call   801025f8 <write_log>
    write_head();    // Write header to disk -- the real commit
8010268f:	e8 ed fe ff ff       	call   80102581 <write_head>
    install_trans(); // Now install writes to home locations
80102694:	e8 66 fe ff ff       	call   801024ff <install_trans>
    log.lh.n = 0;
80102699:	c7 05 e8 16 11 80 00 	movl   $0x0,0x801116e8
801026a0:	00 00 00 
    write_head();    // Erase the transaction from the log
801026a3:	e8 d9 fe ff ff       	call   80102581 <write_head>
  }
}
801026a8:	c9                   	leave  
801026a9:	c3                   	ret    

801026aa <initlog>:
{
801026aa:	55                   	push   %ebp
801026ab:	89 e5                	mov    %esp,%ebp
801026ad:	53                   	push   %ebx
801026ae:	83 ec 2c             	sub    $0x2c,%esp
801026b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
801026b4:	68 e0 6d 10 80       	push   $0x80106de0
801026b9:	68 a0 16 11 80       	push   $0x801116a0
801026be:	e8 00 13 00 00       	call   801039c3 <initlock>
  readsb(dev, &sb);
801026c3:	83 c4 08             	add    $0x8,%esp
801026c6:	8d 45 dc             	lea    -0x24(%ebp),%eax
801026c9:	50                   	push   %eax
801026ca:	53                   	push   %ebx
801026cb:	e8 0e eb ff ff       	call   801011de <readsb>
  log.start = sb.logstart;
801026d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801026d3:	a3 d4 16 11 80       	mov    %eax,0x801116d4
  log.size = sb.nlog;
801026d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801026db:	a3 d8 16 11 80       	mov    %eax,0x801116d8
  log.dev = dev;
801026e0:	89 1d e4 16 11 80    	mov    %ebx,0x801116e4
  recover_from_log();
801026e6:	e8 ec fe ff ff       	call   801025d7 <recover_from_log>
}
801026eb:	83 c4 10             	add    $0x10,%esp
801026ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801026f1:	c9                   	leave  
801026f2:	c3                   	ret    

801026f3 <begin_op>:
{
801026f3:	55                   	push   %ebp
801026f4:	89 e5                	mov    %esp,%ebp
801026f6:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
801026f9:	68 a0 16 11 80       	push   $0x801116a0
801026fe:	e8 f7 13 00 00       	call   80103afa <acquire>
80102703:	83 c4 10             	add    $0x10,%esp
80102706:	eb 15                	jmp    8010271d <begin_op+0x2a>
      sleep(&log, &log.lock);
80102708:	83 ec 08             	sub    $0x8,%esp
8010270b:	68 a0 16 11 80       	push   $0x801116a0
80102710:	68 a0 16 11 80       	push   $0x801116a0
80102715:	e8 da 0e 00 00       	call   801035f4 <sleep>
8010271a:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
8010271d:	83 3d e0 16 11 80 00 	cmpl   $0x0,0x801116e0
80102724:	75 e2                	jne    80102708 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102726:	a1 dc 16 11 80       	mov    0x801116dc,%eax
8010272b:	8d 48 01             	lea    0x1(%eax),%ecx
8010272e:	8d 54 80 05          	lea    0x5(%eax,%eax,4),%edx
80102732:	8d 04 12             	lea    (%edx,%edx,1),%eax
80102735:	03 05 e8 16 11 80    	add    0x801116e8,%eax
8010273b:	83 f8 1e             	cmp    $0x1e,%eax
8010273e:	7e 17                	jle    80102757 <begin_op+0x64>
      sleep(&log, &log.lock);
80102740:	83 ec 08             	sub    $0x8,%esp
80102743:	68 a0 16 11 80       	push   $0x801116a0
80102748:	68 a0 16 11 80       	push   $0x801116a0
8010274d:	e8 a2 0e 00 00       	call   801035f4 <sleep>
80102752:	83 c4 10             	add    $0x10,%esp
80102755:	eb c6                	jmp    8010271d <begin_op+0x2a>
      log.outstanding += 1;
80102757:	89 0d dc 16 11 80    	mov    %ecx,0x801116dc
      release(&log.lock);
8010275d:	83 ec 0c             	sub    $0xc,%esp
80102760:	68 a0 16 11 80       	push   $0x801116a0
80102765:	e8 f5 13 00 00       	call   80103b5f <release>
}
8010276a:	83 c4 10             	add    $0x10,%esp
8010276d:	c9                   	leave  
8010276e:	c3                   	ret    

8010276f <end_op>:
{
8010276f:	55                   	push   %ebp
80102770:	89 e5                	mov    %esp,%ebp
80102772:	53                   	push   %ebx
80102773:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102776:	68 a0 16 11 80       	push   $0x801116a0
8010277b:	e8 7a 13 00 00       	call   80103afa <acquire>
  log.outstanding -= 1;
80102780:	a1 dc 16 11 80       	mov    0x801116dc,%eax
80102785:	48                   	dec    %eax
80102786:	a3 dc 16 11 80       	mov    %eax,0x801116dc
  if(log.committing)
8010278b:	8b 1d e0 16 11 80    	mov    0x801116e0,%ebx
80102791:	83 c4 10             	add    $0x10,%esp
80102794:	85 db                	test   %ebx,%ebx
80102796:	75 2c                	jne    801027c4 <end_op+0x55>
  if(log.outstanding == 0){
80102798:	85 c0                	test   %eax,%eax
8010279a:	75 35                	jne    801027d1 <end_op+0x62>
    log.committing = 1;
8010279c:	c7 05 e0 16 11 80 01 	movl   $0x1,0x801116e0
801027a3:	00 00 00 
    do_commit = 1;
801027a6:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
801027ab:	83 ec 0c             	sub    $0xc,%esp
801027ae:	68 a0 16 11 80       	push   $0x801116a0
801027b3:	e8 a7 13 00 00       	call   80103b5f <release>
  if(do_commit){
801027b8:	83 c4 10             	add    $0x10,%esp
801027bb:	85 db                	test   %ebx,%ebx
801027bd:	75 24                	jne    801027e3 <end_op+0x74>
}
801027bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027c2:	c9                   	leave  
801027c3:	c3                   	ret    
    panic("log.committing");
801027c4:	83 ec 0c             	sub    $0xc,%esp
801027c7:	68 e4 6d 10 80       	push   $0x80106de4
801027cc:	e8 70 db ff ff       	call   80100341 <panic>
    wakeup(&log);
801027d1:	83 ec 0c             	sub    $0xc,%esp
801027d4:	68 a0 16 11 80       	push   $0x801116a0
801027d9:	e8 88 0f 00 00       	call   80103766 <wakeup>
801027de:	83 c4 10             	add    $0x10,%esp
801027e1:	eb c8                	jmp    801027ab <end_op+0x3c>
    commit();
801027e3:	e8 92 fe ff ff       	call   8010267a <commit>
    acquire(&log.lock);
801027e8:	83 ec 0c             	sub    $0xc,%esp
801027eb:	68 a0 16 11 80       	push   $0x801116a0
801027f0:	e8 05 13 00 00       	call   80103afa <acquire>
    log.committing = 0;
801027f5:	c7 05 e0 16 11 80 00 	movl   $0x0,0x801116e0
801027fc:	00 00 00 
    wakeup(&log);
801027ff:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
80102806:	e8 5b 0f 00 00       	call   80103766 <wakeup>
    release(&log.lock);
8010280b:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
80102812:	e8 48 13 00 00       	call   80103b5f <release>
80102817:	83 c4 10             	add    $0x10,%esp
}
8010281a:	eb a3                	jmp    801027bf <end_op+0x50>

8010281c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010281c:	55                   	push   %ebp
8010281d:	89 e5                	mov    %esp,%ebp
8010281f:	53                   	push   %ebx
80102820:	83 ec 04             	sub    $0x4,%esp
80102823:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102826:	8b 15 e8 16 11 80    	mov    0x801116e8,%edx
8010282c:	83 fa 1d             	cmp    $0x1d,%edx
8010282f:	7f 2a                	jg     8010285b <log_write+0x3f>
80102831:	a1 d8 16 11 80       	mov    0x801116d8,%eax
80102836:	48                   	dec    %eax
80102837:	39 c2                	cmp    %eax,%edx
80102839:	7d 20                	jge    8010285b <log_write+0x3f>
    panic("too big a transaction");
  if (log.outstanding < 1)
8010283b:	83 3d dc 16 11 80 00 	cmpl   $0x0,0x801116dc
80102842:	7e 24                	jle    80102868 <log_write+0x4c>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102844:	83 ec 0c             	sub    $0xc,%esp
80102847:	68 a0 16 11 80       	push   $0x801116a0
8010284c:	e8 a9 12 00 00       	call   80103afa <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102851:	83 c4 10             	add    $0x10,%esp
80102854:	b8 00 00 00 00       	mov    $0x0,%eax
80102859:	eb 1b                	jmp    80102876 <log_write+0x5a>
    panic("too big a transaction");
8010285b:	83 ec 0c             	sub    $0xc,%esp
8010285e:	68 f3 6d 10 80       	push   $0x80106df3
80102863:	e8 d9 da ff ff       	call   80100341 <panic>
    panic("log_write outside of trans");
80102868:	83 ec 0c             	sub    $0xc,%esp
8010286b:	68 09 6e 10 80       	push   $0x80106e09
80102870:	e8 cc da ff ff       	call   80100341 <panic>
  for (i = 0; i < log.lh.n; i++) {
80102875:	40                   	inc    %eax
80102876:	8b 15 e8 16 11 80    	mov    0x801116e8,%edx
8010287c:	39 c2                	cmp    %eax,%edx
8010287e:	7e 0c                	jle    8010288c <log_write+0x70>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102880:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102883:	39 0c 85 ec 16 11 80 	cmp    %ecx,-0x7feee914(,%eax,4)
8010288a:	75 e9                	jne    80102875 <log_write+0x59>
      break;
  }
  log.lh.block[i] = b->blockno;
8010288c:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010288f:	89 0c 85 ec 16 11 80 	mov    %ecx,-0x7feee914(,%eax,4)
  if (i == log.lh.n)
80102896:	39 c2                	cmp    %eax,%edx
80102898:	74 18                	je     801028b2 <log_write+0x96>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
8010289a:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
8010289d:	83 ec 0c             	sub    $0xc,%esp
801028a0:	68 a0 16 11 80       	push   $0x801116a0
801028a5:	e8 b5 12 00 00       	call   80103b5f <release>
}
801028aa:	83 c4 10             	add    $0x10,%esp
801028ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801028b0:	c9                   	leave  
801028b1:	c3                   	ret    
    log.lh.n++;
801028b2:	42                   	inc    %edx
801028b3:	89 15 e8 16 11 80    	mov    %edx,0x801116e8
801028b9:	eb df                	jmp    8010289a <log_write+0x7e>

801028bb <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801028bb:	55                   	push   %ebp
801028bc:	89 e5                	mov    %esp,%ebp
801028be:	53                   	push   %ebx
801028bf:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801028c2:	68 8e 00 00 00       	push   $0x8e
801028c7:	68 8c a4 10 80       	push   $0x8010a48c
801028cc:	68 00 70 00 80       	push   $0x80007000
801028d1:	e8 46 13 00 00       	call   80103c1c <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801028d6:	83 c4 10             	add    $0x10,%esp
801028d9:	bb a0 17 11 80       	mov    $0x801117a0,%ebx
801028de:	eb 06                	jmp    801028e6 <startothers+0x2b>
801028e0:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801028e6:	8b 15 84 17 11 80    	mov    0x80111784,%edx
801028ec:	8d 04 92             	lea    (%edx,%edx,4),%eax
801028ef:	01 c0                	add    %eax,%eax
801028f1:	01 d0                	add    %edx,%eax
801028f3:	c1 e0 04             	shl    $0x4,%eax
801028f6:	05 a0 17 11 80       	add    $0x801117a0,%eax
801028fb:	39 d8                	cmp    %ebx,%eax
801028fd:	76 4c                	jbe    8010294b <startothers+0x90>
    if(c == mycpu())  // We've started already.
801028ff:	e8 9d 07 00 00       	call   801030a1 <mycpu>
80102904:	39 c3                	cmp    %eax,%ebx
80102906:	74 d8                	je     801028e0 <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102908:	e8 31 f7 ff ff       	call   8010203e <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
8010290d:	05 00 10 00 00       	add    $0x1000,%eax
80102912:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102917:	c7 05 f8 6f 00 80 8f 	movl   $0x8010298f,0x80006ff8
8010291e:	29 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102921:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102928:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
8010292b:	83 ec 08             	sub    $0x8,%esp
8010292e:	68 00 70 00 00       	push   $0x7000
80102933:	0f b6 03             	movzbl (%ebx),%eax
80102936:	50                   	push   %eax
80102937:	e8 f6 f9 ff ff       	call   80102332 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010293c:	83 c4 10             	add    $0x10,%esp
8010293f:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102945:	85 c0                	test   %eax,%eax
80102947:	74 f6                	je     8010293f <startothers+0x84>
80102949:	eb 95                	jmp    801028e0 <startothers+0x25>
      ;
  }
}
8010294b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010294e:	c9                   	leave  
8010294f:	c3                   	ret    

80102950 <mpmain>:
{
80102950:	55                   	push   %ebp
80102951:	89 e5                	mov    %esp,%ebp
80102953:	53                   	push   %ebx
80102954:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102957:	e8 a9 07 00 00       	call   80103105 <cpuid>
8010295c:	89 c3                	mov    %eax,%ebx
8010295e:	e8 a2 07 00 00       	call   80103105 <cpuid>
80102963:	83 ec 04             	sub    $0x4,%esp
80102966:	53                   	push   %ebx
80102967:	50                   	push   %eax
80102968:	68 24 6e 10 80       	push   $0x80106e24
8010296d:	e8 68 dc ff ff       	call   801005da <cprintf>
  idtinit();       // load idt register
80102972:	e8 c1 24 00 00       	call   80104e38 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102977:	e8 25 07 00 00       	call   801030a1 <mycpu>
8010297c:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010297e:	b8 01 00 00 00       	mov    $0x1,%eax
80102983:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
8010298a:	e8 25 0a 00 00       	call   801033b4 <scheduler>

8010298f <mpenter>:
{
8010298f:	55                   	push   %ebp
80102990:	89 e5                	mov    %esp,%ebp
80102992:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102995:	e8 10 38 00 00       	call   801061aa <switchkvm>
  seginit();
8010299a:	e8 97 34 00 00       	call   80105e36 <seginit>
  lapicinit();
8010299f:	e8 4a f8 ff ff       	call   801021ee <lapicinit>
  mpmain();
801029a4:	e8 a7 ff ff ff       	call   80102950 <mpmain>

801029a9 <main>:
{
801029a9:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801029ad:	83 e4 f0             	and    $0xfffffff0,%esp
801029b0:	ff 71 fc             	push   -0x4(%ecx)
801029b3:	55                   	push   %ebp
801029b4:	89 e5                	mov    %esp,%ebp
801029b6:	51                   	push   %ecx
801029b7:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801029ba:	68 00 00 40 80       	push   $0x80400000
801029bf:	68 d0 56 11 80       	push   $0x801156d0
801029c4:	e8 23 f6 ff ff       	call   80101fec <kinit1>
  kvmalloc();      // kernel page table
801029c9:	e8 ab 3c 00 00       	call   80106679 <kvmalloc>
  mpinit();        // detect other processors
801029ce:	e8 b8 01 00 00       	call   80102b8b <mpinit>
  lapicinit();     // interrupt controller
801029d3:	e8 16 f8 ff ff       	call   801021ee <lapicinit>
  seginit();       // segment descriptors
801029d8:	e8 59 34 00 00       	call   80105e36 <seginit>
  picinit();       // disable pic
801029dd:	e8 79 02 00 00       	call   80102c5b <picinit>
  ioapicinit();    // another interrupt controller
801029e2:	e8 93 f4 ff ff       	call   80101e7a <ioapicinit>
  consoleinit();   // console hardware
801029e7:	e8 60 de ff ff       	call   8010084c <consoleinit>
  uartinit();      // serial port
801029ec:	e8 bd 28 00 00       	call   801052ae <uartinit>
  pinit();         // process table
801029f1:	e8 91 06 00 00       	call   80103087 <pinit>
  tvinit();        // trap vectors
801029f6:	e8 40 23 00 00       	call   80104d3b <tvinit>
  binit();         // buffer cache
801029fb:	e8 f2 d6 ff ff       	call   801000f2 <binit>
  fileinit();      // file table
80102a00:	e8 de e1 ff ff       	call   80100be3 <fileinit>
  ideinit();       // disk 
80102a05:	e8 86 f2 ff ff       	call   80101c90 <ideinit>
  startothers();   // start other processors
80102a0a:	e8 ac fe ff ff       	call   801028bb <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102a0f:	83 c4 08             	add    $0x8,%esp
80102a12:	68 00 00 00 8e       	push   $0x8e000000
80102a17:	68 00 00 40 80       	push   $0x80400000
80102a1c:	e8 fd f5 ff ff       	call   8010201e <kinit2>
  userinit();      // first user process
80102a21:	e8 33 07 00 00       	call   80103159 <userinit>
  mpmain();        // finish this processor's setup
80102a26:	e8 25 ff ff ff       	call   80102950 <mpmain>

80102a2b <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102a2b:	55                   	push   %ebp
80102a2c:	89 e5                	mov    %esp,%ebp
80102a2e:	56                   	push   %esi
80102a2f:	53                   	push   %ebx
80102a30:	89 c6                	mov    %eax,%esi
  int i, sum;

  sum = 0;
80102a32:	b8 00 00 00 00       	mov    $0x0,%eax
  for(i=0; i<len; i++)
80102a37:	b9 00 00 00 00       	mov    $0x0,%ecx
80102a3c:	eb 07                	jmp    80102a45 <sum+0x1a>
    sum += addr[i];
80102a3e:	0f b6 1c 0e          	movzbl (%esi,%ecx,1),%ebx
80102a42:	01 d8                	add    %ebx,%eax
  for(i=0; i<len; i++)
80102a44:	41                   	inc    %ecx
80102a45:	39 d1                	cmp    %edx,%ecx
80102a47:	7c f5                	jl     80102a3e <sum+0x13>
  return sum;
}
80102a49:	5b                   	pop    %ebx
80102a4a:	5e                   	pop    %esi
80102a4b:	5d                   	pop    %ebp
80102a4c:	c3                   	ret    

80102a4d <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102a4d:	55                   	push   %ebp
80102a4e:	89 e5                	mov    %esp,%ebp
80102a50:	56                   	push   %esi
80102a51:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102a52:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102a58:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102a5a:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102a5c:	eb 03                	jmp    80102a61 <mpsearch1+0x14>
80102a5e:	83 c3 10             	add    $0x10,%ebx
80102a61:	39 f3                	cmp    %esi,%ebx
80102a63:	73 29                	jae    80102a8e <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102a65:	83 ec 04             	sub    $0x4,%esp
80102a68:	6a 04                	push   $0x4
80102a6a:	68 38 6e 10 80       	push   $0x80106e38
80102a6f:	53                   	push   %ebx
80102a70:	e8 78 11 00 00       	call   80103bed <memcmp>
80102a75:	83 c4 10             	add    $0x10,%esp
80102a78:	85 c0                	test   %eax,%eax
80102a7a:	75 e2                	jne    80102a5e <mpsearch1+0x11>
80102a7c:	ba 10 00 00 00       	mov    $0x10,%edx
80102a81:	89 d8                	mov    %ebx,%eax
80102a83:	e8 a3 ff ff ff       	call   80102a2b <sum>
80102a88:	84 c0                	test   %al,%al
80102a8a:	75 d2                	jne    80102a5e <mpsearch1+0x11>
80102a8c:	eb 05                	jmp    80102a93 <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102a8e:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102a93:	89 d8                	mov    %ebx,%eax
80102a95:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102a98:	5b                   	pop    %ebx
80102a99:	5e                   	pop    %esi
80102a9a:	5d                   	pop    %ebp
80102a9b:	c3                   	ret    

80102a9c <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102a9c:	55                   	push   %ebp
80102a9d:	89 e5                	mov    %esp,%ebp
80102a9f:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102aa2:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102aa9:	c1 e0 08             	shl    $0x8,%eax
80102aac:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102ab3:	09 d0                	or     %edx,%eax
80102ab5:	c1 e0 04             	shl    $0x4,%eax
80102ab8:	74 1f                	je     80102ad9 <mpsearch+0x3d>
    if((mp = mpsearch1(p, 1024)))
80102aba:	ba 00 04 00 00       	mov    $0x400,%edx
80102abf:	e8 89 ff ff ff       	call   80102a4d <mpsearch1>
80102ac4:	85 c0                	test   %eax,%eax
80102ac6:	75 0f                	jne    80102ad7 <mpsearch+0x3b>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102ac8:	ba 00 00 01 00       	mov    $0x10000,%edx
80102acd:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102ad2:	e8 76 ff ff ff       	call   80102a4d <mpsearch1>
}
80102ad7:	c9                   	leave  
80102ad8:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102ad9:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102ae0:	c1 e0 08             	shl    $0x8,%eax
80102ae3:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102aea:	09 d0                	or     %edx,%eax
80102aec:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102aef:	2d 00 04 00 00       	sub    $0x400,%eax
80102af4:	ba 00 04 00 00       	mov    $0x400,%edx
80102af9:	e8 4f ff ff ff       	call   80102a4d <mpsearch1>
80102afe:	85 c0                	test   %eax,%eax
80102b00:	75 d5                	jne    80102ad7 <mpsearch+0x3b>
80102b02:	eb c4                	jmp    80102ac8 <mpsearch+0x2c>

80102b04 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102b04:	55                   	push   %ebp
80102b05:	89 e5                	mov    %esp,%ebp
80102b07:	57                   	push   %edi
80102b08:	56                   	push   %esi
80102b09:	53                   	push   %ebx
80102b0a:	83 ec 1c             	sub    $0x1c,%esp
80102b0d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102b10:	e8 87 ff ff ff       	call   80102a9c <mpsearch>
80102b15:	89 c3                	mov    %eax,%ebx
80102b17:	85 c0                	test   %eax,%eax
80102b19:	74 53                	je     80102b6e <mpconfig+0x6a>
80102b1b:	8b 70 04             	mov    0x4(%eax),%esi
80102b1e:	85 f6                	test   %esi,%esi
80102b20:	74 50                	je     80102b72 <mpconfig+0x6e>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102b22:	8d be 00 00 00 80    	lea    -0x80000000(%esi),%edi
  if(memcmp(conf, "PCMP", 4) != 0)
80102b28:	83 ec 04             	sub    $0x4,%esp
80102b2b:	6a 04                	push   $0x4
80102b2d:	68 3d 6e 10 80       	push   $0x80106e3d
80102b32:	57                   	push   %edi
80102b33:	e8 b5 10 00 00       	call   80103bed <memcmp>
80102b38:	83 c4 10             	add    $0x10,%esp
80102b3b:	85 c0                	test   %eax,%eax
80102b3d:	75 37                	jne    80102b76 <mpconfig+0x72>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102b3f:	8a 86 06 00 00 80    	mov    -0x7ffffffa(%esi),%al
80102b45:	3c 01                	cmp    $0x1,%al
80102b47:	74 04                	je     80102b4d <mpconfig+0x49>
80102b49:	3c 04                	cmp    $0x4,%al
80102b4b:	75 30                	jne    80102b7d <mpconfig+0x79>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102b4d:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
80102b54:	89 f8                	mov    %edi,%eax
80102b56:	e8 d0 fe ff ff       	call   80102a2b <sum>
80102b5b:	84 c0                	test   %al,%al
80102b5d:	75 25                	jne    80102b84 <mpconfig+0x80>
    return 0;
  *pmp = mp;
80102b5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102b62:	89 18                	mov    %ebx,(%eax)
  return conf;
}
80102b64:	89 f8                	mov    %edi,%eax
80102b66:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102b69:	5b                   	pop    %ebx
80102b6a:	5e                   	pop    %esi
80102b6b:	5f                   	pop    %edi
80102b6c:	5d                   	pop    %ebp
80102b6d:	c3                   	ret    
    return 0;
80102b6e:	89 c7                	mov    %eax,%edi
80102b70:	eb f2                	jmp    80102b64 <mpconfig+0x60>
80102b72:	89 f7                	mov    %esi,%edi
80102b74:	eb ee                	jmp    80102b64 <mpconfig+0x60>
    return 0;
80102b76:	bf 00 00 00 00       	mov    $0x0,%edi
80102b7b:	eb e7                	jmp    80102b64 <mpconfig+0x60>
    return 0;
80102b7d:	bf 00 00 00 00       	mov    $0x0,%edi
80102b82:	eb e0                	jmp    80102b64 <mpconfig+0x60>
    return 0;
80102b84:	bf 00 00 00 00       	mov    $0x0,%edi
80102b89:	eb d9                	jmp    80102b64 <mpconfig+0x60>

80102b8b <mpinit>:

void
mpinit(void)
{
80102b8b:	55                   	push   %ebp
80102b8c:	89 e5                	mov    %esp,%ebp
80102b8e:	57                   	push   %edi
80102b8f:	56                   	push   %esi
80102b90:	53                   	push   %ebx
80102b91:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102b94:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102b97:	e8 68 ff ff ff       	call   80102b04 <mpconfig>
80102b9c:	85 c0                	test   %eax,%eax
80102b9e:	74 19                	je     80102bb9 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102ba0:	8b 50 24             	mov    0x24(%eax),%edx
80102ba3:	89 15 80 16 11 80    	mov    %edx,0x80111680
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102ba9:	8d 50 2c             	lea    0x2c(%eax),%edx
80102bac:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102bb0:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102bb2:	bf 01 00 00 00       	mov    $0x1,%edi
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102bb7:	eb 20                	jmp    80102bd9 <mpinit+0x4e>
    panic("Expect to run on an SMP");
80102bb9:	83 ec 0c             	sub    $0xc,%esp
80102bbc:	68 42 6e 10 80       	push   $0x80106e42
80102bc1:	e8 7b d7 ff ff       	call   80100341 <panic>
    switch(*p){
80102bc6:	bf 00 00 00 00       	mov    $0x0,%edi
80102bcb:	eb 0c                	jmp    80102bd9 <mpinit+0x4e>
80102bcd:	83 e8 03             	sub    $0x3,%eax
80102bd0:	3c 01                	cmp    $0x1,%al
80102bd2:	76 19                	jbe    80102bed <mpinit+0x62>
80102bd4:	bf 00 00 00 00       	mov    $0x0,%edi
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102bd9:	39 ca                	cmp    %ecx,%edx
80102bdb:	73 4a                	jae    80102c27 <mpinit+0x9c>
    switch(*p){
80102bdd:	8a 02                	mov    (%edx),%al
80102bdf:	3c 02                	cmp    $0x2,%al
80102be1:	74 37                	je     80102c1a <mpinit+0x8f>
80102be3:	77 e8                	ja     80102bcd <mpinit+0x42>
80102be5:	84 c0                	test   %al,%al
80102be7:	74 09                	je     80102bf2 <mpinit+0x67>
80102be9:	3c 01                	cmp    $0x1,%al
80102beb:	75 d9                	jne    80102bc6 <mpinit+0x3b>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102bed:	83 c2 08             	add    $0x8,%edx
      continue;
80102bf0:	eb e7                	jmp    80102bd9 <mpinit+0x4e>
      if(ncpu < NCPU) {
80102bf2:	a1 84 17 11 80       	mov    0x80111784,%eax
80102bf7:	83 f8 07             	cmp    $0x7,%eax
80102bfa:	7f 19                	jg     80102c15 <mpinit+0x8a>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102bfc:	8d 34 80             	lea    (%eax,%eax,4),%esi
80102bff:	01 f6                	add    %esi,%esi
80102c01:	01 c6                	add    %eax,%esi
80102c03:	c1 e6 04             	shl    $0x4,%esi
80102c06:	8a 5a 01             	mov    0x1(%edx),%bl
80102c09:	88 9e a0 17 11 80    	mov    %bl,-0x7feee860(%esi)
        ncpu++;
80102c0f:	40                   	inc    %eax
80102c10:	a3 84 17 11 80       	mov    %eax,0x80111784
      p += sizeof(struct mpproc);
80102c15:	83 c2 14             	add    $0x14,%edx
      continue;
80102c18:	eb bf                	jmp    80102bd9 <mpinit+0x4e>
      ioapicid = ioapic->apicno;
80102c1a:	8a 42 01             	mov    0x1(%edx),%al
80102c1d:	a2 80 17 11 80       	mov    %al,0x80111780
      p += sizeof(struct mpioapic);
80102c22:	83 c2 08             	add    $0x8,%edx
      continue;
80102c25:	eb b2                	jmp    80102bd9 <mpinit+0x4e>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80102c27:	85 ff                	test   %edi,%edi
80102c29:	74 23                	je     80102c4e <mpinit+0xc3>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102c2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102c2e:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102c32:	74 12                	je     80102c46 <mpinit+0xbb>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c34:	b0 70                	mov    $0x70,%al
80102c36:	ba 22 00 00 00       	mov    $0x22,%edx
80102c3b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c3c:	ba 23 00 00 00       	mov    $0x23,%edx
80102c41:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102c42:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c45:	ee                   	out    %al,(%dx)
  }
}
80102c46:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c49:	5b                   	pop    %ebx
80102c4a:	5e                   	pop    %esi
80102c4b:	5f                   	pop    %edi
80102c4c:	5d                   	pop    %ebp
80102c4d:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102c4e:	83 ec 0c             	sub    $0xc,%esp
80102c51:	68 5c 6e 10 80       	push   $0x80106e5c
80102c56:	e8 e6 d6 ff ff       	call   80100341 <panic>

80102c5b <picinit>:
80102c5b:	b0 ff                	mov    $0xff,%al
80102c5d:	ba 21 00 00 00       	mov    $0x21,%edx
80102c62:	ee                   	out    %al,(%dx)
80102c63:	ba a1 00 00 00       	mov    $0xa1,%edx
80102c68:	ee                   	out    %al,(%dx)
picinit(void)
{
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102c69:	c3                   	ret    

80102c6a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102c6a:	55                   	push   %ebp
80102c6b:	89 e5                	mov    %esp,%ebp
80102c6d:	57                   	push   %edi
80102c6e:	56                   	push   %esi
80102c6f:	53                   	push   %ebx
80102c70:	83 ec 0c             	sub    $0xc,%esp
80102c73:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102c76:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102c79:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102c7f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102c85:	e8 73 df ff ff       	call   80100bfd <filealloc>
80102c8a:	89 03                	mov    %eax,(%ebx)
80102c8c:	85 c0                	test   %eax,%eax
80102c8e:	0f 84 88 00 00 00    	je     80102d1c <pipealloc+0xb2>
80102c94:	e8 64 df ff ff       	call   80100bfd <filealloc>
80102c99:	89 06                	mov    %eax,(%esi)
80102c9b:	85 c0                	test   %eax,%eax
80102c9d:	74 7d                	je     80102d1c <pipealloc+0xb2>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102c9f:	e8 9a f3 ff ff       	call   8010203e <kalloc>
80102ca4:	89 c7                	mov    %eax,%edi
80102ca6:	85 c0                	test   %eax,%eax
80102ca8:	74 72                	je     80102d1c <pipealloc+0xb2>
    goto bad;
  p->readopen = 1;
80102caa:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102cb1:	00 00 00 
  p->writeopen = 1;
80102cb4:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102cbb:	00 00 00 
  p->nwrite = 0;
80102cbe:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102cc5:	00 00 00 
  p->nread = 0;
80102cc8:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102ccf:	00 00 00 
  initlock(&p->lock, "pipe");
80102cd2:	83 ec 08             	sub    $0x8,%esp
80102cd5:	68 7b 6e 10 80       	push   $0x80106e7b
80102cda:	50                   	push   %eax
80102cdb:	e8 e3 0c 00 00       	call   801039c3 <initlock>
  (*f0)->type = FD_PIPE;
80102ce0:	8b 03                	mov    (%ebx),%eax
80102ce2:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102ce8:	8b 03                	mov    (%ebx),%eax
80102cea:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102cee:	8b 03                	mov    (%ebx),%eax
80102cf0:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102cf4:	8b 03                	mov    (%ebx),%eax
80102cf6:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102cf9:	8b 06                	mov    (%esi),%eax
80102cfb:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102d01:	8b 06                	mov    (%esi),%eax
80102d03:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102d07:	8b 06                	mov    (%esi),%eax
80102d09:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102d0d:	8b 06                	mov    (%esi),%eax
80102d0f:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102d12:	83 c4 10             	add    $0x10,%esp
80102d15:	b8 00 00 00 00       	mov    $0x0,%eax
80102d1a:	eb 29                	jmp    80102d45 <pipealloc+0xdb>

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102d1c:	8b 03                	mov    (%ebx),%eax
80102d1e:	85 c0                	test   %eax,%eax
80102d20:	74 0c                	je     80102d2e <pipealloc+0xc4>
    fileclose(*f0);
80102d22:	83 ec 0c             	sub    $0xc,%esp
80102d25:	50                   	push   %eax
80102d26:	e8 76 df ff ff       	call   80100ca1 <fileclose>
80102d2b:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102d2e:	8b 06                	mov    (%esi),%eax
80102d30:	85 c0                	test   %eax,%eax
80102d32:	74 19                	je     80102d4d <pipealloc+0xe3>
    fileclose(*f1);
80102d34:	83 ec 0c             	sub    $0xc,%esp
80102d37:	50                   	push   %eax
80102d38:	e8 64 df ff ff       	call   80100ca1 <fileclose>
80102d3d:	83 c4 10             	add    $0x10,%esp
  return -1;
80102d40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d48:	5b                   	pop    %ebx
80102d49:	5e                   	pop    %esi
80102d4a:	5f                   	pop    %edi
80102d4b:	5d                   	pop    %ebp
80102d4c:	c3                   	ret    
  return -1;
80102d4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d52:	eb f1                	jmp    80102d45 <pipealloc+0xdb>

80102d54 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102d54:	55                   	push   %ebp
80102d55:	89 e5                	mov    %esp,%ebp
80102d57:	53                   	push   %ebx
80102d58:	83 ec 10             	sub    $0x10,%esp
80102d5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102d5e:	53                   	push   %ebx
80102d5f:	e8 96 0d 00 00       	call   80103afa <acquire>
  if(writable){
80102d64:	83 c4 10             	add    $0x10,%esp
80102d67:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102d6b:	74 3f                	je     80102dac <pipeclose+0x58>
    p->writeopen = 0;
80102d6d:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102d74:	00 00 00 
    wakeup(&p->nread);
80102d77:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102d7d:	83 ec 0c             	sub    $0xc,%esp
80102d80:	50                   	push   %eax
80102d81:	e8 e0 09 00 00       	call   80103766 <wakeup>
80102d86:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102d89:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102d90:	75 09                	jne    80102d9b <pipeclose+0x47>
80102d92:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102d99:	74 2f                	je     80102dca <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102d9b:	83 ec 0c             	sub    $0xc,%esp
80102d9e:	53                   	push   %ebx
80102d9f:	e8 bb 0d 00 00       	call   80103b5f <release>
80102da4:	83 c4 10             	add    $0x10,%esp
}
80102da7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102daa:	c9                   	leave  
80102dab:	c3                   	ret    
    p->readopen = 0;
80102dac:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102db3:	00 00 00 
    wakeup(&p->nwrite);
80102db6:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102dbc:	83 ec 0c             	sub    $0xc,%esp
80102dbf:	50                   	push   %eax
80102dc0:	e8 a1 09 00 00       	call   80103766 <wakeup>
80102dc5:	83 c4 10             	add    $0x10,%esp
80102dc8:	eb bf                	jmp    80102d89 <pipeclose+0x35>
    release(&p->lock);
80102dca:	83 ec 0c             	sub    $0xc,%esp
80102dcd:	53                   	push   %ebx
80102dce:	e8 8c 0d 00 00       	call   80103b5f <release>
    kfree((char*)p);
80102dd3:	89 1c 24             	mov    %ebx,(%esp)
80102dd6:	e8 4c f1 ff ff       	call   80101f27 <kfree>
80102ddb:	83 c4 10             	add    $0x10,%esp
80102dde:	eb c7                	jmp    80102da7 <pipeclose+0x53>

80102de0 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80102de0:	55                   	push   %ebp
80102de1:	89 e5                	mov    %esp,%ebp
80102de3:	56                   	push   %esi
80102de4:	53                   	push   %ebx
80102de5:	83 ec 1c             	sub    $0x1c,%esp
80102de8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102deb:	53                   	push   %ebx
80102dec:	e8 09 0d 00 00       	call   80103afa <acquire>
  for(i = 0; i < n; i++){
80102df1:	83 c4 10             	add    $0x10,%esp
80102df4:	be 00 00 00 00       	mov    $0x0,%esi
80102df9:	3b 75 10             	cmp    0x10(%ebp),%esi
80102dfc:	7c 41                	jl     80102e3f <pipewrite+0x5f>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80102dfe:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102e04:	83 ec 0c             	sub    $0xc,%esp
80102e07:	50                   	push   %eax
80102e08:	e8 59 09 00 00       	call   80103766 <wakeup>
  release(&p->lock);
80102e0d:	89 1c 24             	mov    %ebx,(%esp)
80102e10:	e8 4a 0d 00 00       	call   80103b5f <release>
  return n;
80102e15:	83 c4 10             	add    $0x10,%esp
80102e18:	8b 45 10             	mov    0x10(%ebp),%eax
80102e1b:	eb 5c                	jmp    80102e79 <pipewrite+0x99>
      wakeup(&p->nread);
80102e1d:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102e23:	83 ec 0c             	sub    $0xc,%esp
80102e26:	50                   	push   %eax
80102e27:	e8 3a 09 00 00       	call   80103766 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102e2c:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102e32:	83 c4 08             	add    $0x8,%esp
80102e35:	53                   	push   %ebx
80102e36:	50                   	push   %eax
80102e37:	e8 b8 07 00 00       	call   801035f4 <sleep>
80102e3c:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102e3f:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80102e45:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102e4b:	05 00 02 00 00       	add    $0x200,%eax
80102e50:	39 c2                	cmp    %eax,%edx
80102e52:	75 2c                	jne    80102e80 <pipewrite+0xa0>
      if(p->readopen == 0 || myproc()->killed){
80102e54:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102e5b:	74 0b                	je     80102e68 <pipewrite+0x88>
80102e5d:	e8 d4 02 00 00       	call   80103136 <myproc>
80102e62:	83 78 2c 00          	cmpl   $0x0,0x2c(%eax)
80102e66:	74 b5                	je     80102e1d <pipewrite+0x3d>
        release(&p->lock);
80102e68:	83 ec 0c             	sub    $0xc,%esp
80102e6b:	53                   	push   %ebx
80102e6c:	e8 ee 0c 00 00       	call   80103b5f <release>
        return -1;
80102e71:	83 c4 10             	add    $0x10,%esp
80102e74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102e79:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102e7c:	5b                   	pop    %ebx
80102e7d:	5e                   	pop    %esi
80102e7e:	5d                   	pop    %ebp
80102e7f:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80102e80:	8d 42 01             	lea    0x1(%edx),%eax
80102e83:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80102e89:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e92:	8a 04 30             	mov    (%eax,%esi,1),%al
80102e95:	88 45 f7             	mov    %al,-0x9(%ebp)
80102e98:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80102e9c:	46                   	inc    %esi
80102e9d:	e9 57 ff ff ff       	jmp    80102df9 <pipewrite+0x19>

80102ea2 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80102ea2:	55                   	push   %ebp
80102ea3:	89 e5                	mov    %esp,%ebp
80102ea5:	57                   	push   %edi
80102ea6:	56                   	push   %esi
80102ea7:	53                   	push   %ebx
80102ea8:	83 ec 18             	sub    $0x18,%esp
80102eab:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102eae:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
80102eb1:	53                   	push   %ebx
80102eb2:	e8 43 0c 00 00       	call   80103afa <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102eb7:	83 c4 10             	add    $0x10,%esp
80102eba:	eb 13                	jmp    80102ecf <piperead+0x2d>
    if(myproc()->killed){
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80102ebc:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102ec2:	83 ec 08             	sub    $0x8,%esp
80102ec5:	53                   	push   %ebx
80102ec6:	50                   	push   %eax
80102ec7:	e8 28 07 00 00       	call   801035f4 <sleep>
80102ecc:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102ecf:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102ed5:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80102edb:	75 75                	jne    80102f52 <piperead+0xb0>
80102edd:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80102ee3:	85 f6                	test   %esi,%esi
80102ee5:	74 34                	je     80102f1b <piperead+0x79>
    if(myproc()->killed){
80102ee7:	e8 4a 02 00 00       	call   80103136 <myproc>
80102eec:	83 78 2c 00          	cmpl   $0x0,0x2c(%eax)
80102ef0:	74 ca                	je     80102ebc <piperead+0x1a>
      release(&p->lock);
80102ef2:	83 ec 0c             	sub    $0xc,%esp
80102ef5:	53                   	push   %ebx
80102ef6:	e8 64 0c 00 00       	call   80103b5f <release>
      return -1;
80102efb:	83 c4 10             	add    $0x10,%esp
80102efe:	be ff ff ff ff       	mov    $0xffffffff,%esi
80102f03:	eb 43                	jmp    80102f48 <piperead+0xa6>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80102f05:	8d 50 01             	lea    0x1(%eax),%edx
80102f08:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80102f0e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102f13:	8a 44 03 34          	mov    0x34(%ebx,%eax,1),%al
80102f17:	88 04 37             	mov    %al,(%edi,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80102f1a:	46                   	inc    %esi
80102f1b:	3b 75 10             	cmp    0x10(%ebp),%esi
80102f1e:	7d 0e                	jge    80102f2e <piperead+0x8c>
    if(p->nread == p->nwrite)
80102f20:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102f26:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80102f2c:	75 d7                	jne    80102f05 <piperead+0x63>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80102f2e:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f34:	83 ec 0c             	sub    $0xc,%esp
80102f37:	50                   	push   %eax
80102f38:	e8 29 08 00 00       	call   80103766 <wakeup>
  release(&p->lock);
80102f3d:	89 1c 24             	mov    %ebx,(%esp)
80102f40:	e8 1a 0c 00 00       	call   80103b5f <release>
  return i;
80102f45:	83 c4 10             	add    $0x10,%esp
}
80102f48:	89 f0                	mov    %esi,%eax
80102f4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f4d:	5b                   	pop    %ebx
80102f4e:	5e                   	pop    %esi
80102f4f:	5f                   	pop    %edi
80102f50:	5d                   	pop    %ebp
80102f51:	c3                   	ret    
80102f52:	be 00 00 00 00       	mov    $0x0,%esi
80102f57:	eb c2                	jmp    80102f1b <piperead+0x79>

80102f59 <wakeup1>:
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80102f59:	ba 54 1d 11 80       	mov    $0x80111d54,%edx
80102f5e:	eb 06                	jmp    80102f66 <wakeup1+0xd>
80102f60:	81 c2 84 00 00 00    	add    $0x84,%edx
80102f66:	81 fa 54 3e 11 80    	cmp    $0x80113e54,%edx
80102f6c:	73 14                	jae    80102f82 <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
80102f6e:	83 7a 14 02          	cmpl   $0x2,0x14(%edx)
80102f72:	75 ec                	jne    80102f60 <wakeup1+0x7>
80102f74:	39 42 28             	cmp    %eax,0x28(%edx)
80102f77:	75 e7                	jne    80102f60 <wakeup1+0x7>
      p->state = RUNNABLE;
80102f79:	c7 42 14 03 00 00 00 	movl   $0x3,0x14(%edx)
80102f80:	eb de                	jmp    80102f60 <wakeup1+0x7>
}
80102f82:	c3                   	ret    

80102f83 <allocproc>:
{
80102f83:	55                   	push   %ebp
80102f84:	89 e5                	mov    %esp,%ebp
80102f86:	53                   	push   %ebx
80102f87:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80102f8a:	68 20 1d 11 80       	push   $0x80111d20
80102f8f:	e8 66 0b 00 00       	call   80103afa <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80102f94:	83 c4 10             	add    $0x10,%esp
80102f97:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80102f9c:	eb 06                	jmp    80102fa4 <allocproc+0x21>
80102f9e:	81 c3 84 00 00 00    	add    $0x84,%ebx
80102fa4:	81 fb 54 3e 11 80    	cmp    $0x80113e54,%ebx
80102faa:	73 76                	jae    80103022 <allocproc+0x9f>
    if(p->state == UNUSED)
80102fac:	83 7b 14 00          	cmpl   $0x0,0x14(%ebx)
80102fb0:	75 ec                	jne    80102f9e <allocproc+0x1b>
  p->state = EMBRYO;
80102fb2:	c7 43 14 01 00 00 00 	movl   $0x1,0x14(%ebx)
  p->pid = nextpid++;
80102fb9:	a1 04 a0 10 80       	mov    0x8010a004,%eax
80102fbe:	8d 50 01             	lea    0x1(%eax),%edx
80102fc1:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
80102fc7:	89 43 18             	mov    %eax,0x18(%ebx)
  release(&ptable.lock);
80102fca:	83 ec 0c             	sub    $0xc,%esp
80102fcd:	68 20 1d 11 80       	push   $0x80111d20
80102fd2:	e8 88 0b 00 00       	call   80103b5f <release>
  if((p->kstack = kalloc()) == 0){
80102fd7:	e8 62 f0 ff ff       	call   8010203e <kalloc>
80102fdc:	89 43 10             	mov    %eax,0x10(%ebx)
80102fdf:	83 c4 10             	add    $0x10,%esp
80102fe2:	85 c0                	test   %eax,%eax
80102fe4:	74 53                	je     80103039 <allocproc+0xb6>
  sp -= sizeof *p->tf;
80102fe6:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
80102fec:	89 53 20             	mov    %edx,0x20(%ebx)
  *(uint*)sp = (uint)trapret;
80102fef:	c7 80 b0 0f 00 00 30 	movl   $0x80104d30,0xfb0(%eax)
80102ff6:	4d 10 80 
  sp -= sizeof *p->context;
80102ff9:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80102ffe:	89 43 24             	mov    %eax,0x24(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103001:	83 ec 04             	sub    $0x4,%esp
80103004:	6a 14                	push   $0x14
80103006:	6a 00                	push   $0x0
80103008:	50                   	push   %eax
80103009:	e8 98 0b 00 00       	call   80103ba6 <memset>
  p->context->eip = (uint)forkret;
8010300e:	8b 43 24             	mov    0x24(%ebx),%eax
80103011:	c7 40 10 44 30 10 80 	movl   $0x80103044,0x10(%eax)
  return p;
80103018:	83 c4 10             	add    $0x10,%esp
}
8010301b:	89 d8                	mov    %ebx,%eax
8010301d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103020:	c9                   	leave  
80103021:	c3                   	ret    
  release(&ptable.lock);
80103022:	83 ec 0c             	sub    $0xc,%esp
80103025:	68 20 1d 11 80       	push   $0x80111d20
8010302a:	e8 30 0b 00 00       	call   80103b5f <release>
  return 0;
8010302f:	83 c4 10             	add    $0x10,%esp
80103032:	bb 00 00 00 00       	mov    $0x0,%ebx
80103037:	eb e2                	jmp    8010301b <allocproc+0x98>
    p->state = UNUSED;
80103039:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
    return 0;
80103040:	89 c3                	mov    %eax,%ebx
80103042:	eb d7                	jmp    8010301b <allocproc+0x98>

80103044 <forkret>:
{
80103044:	55                   	push   %ebp
80103045:	89 e5                	mov    %esp,%ebp
80103047:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
8010304a:	68 20 1d 11 80       	push   $0x80111d20
8010304f:	e8 0b 0b 00 00       	call   80103b5f <release>
  if (first) {
80103054:	83 c4 10             	add    $0x10,%esp
80103057:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
8010305e:	75 02                	jne    80103062 <forkret+0x1e>
}
80103060:	c9                   	leave  
80103061:	c3                   	ret    
    first = 0;
80103062:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
80103069:	00 00 00 
    iinit(ROOTDEV);
8010306c:	83 ec 0c             	sub    $0xc,%esp
8010306f:	6a 01                	push   $0x1
80103071:	e8 1f e2 ff ff       	call   80101295 <iinit>
    initlog(ROOTDEV);
80103076:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010307d:	e8 28 f6 ff ff       	call   801026aa <initlog>
80103082:	83 c4 10             	add    $0x10,%esp
}
80103085:	eb d9                	jmp    80103060 <forkret+0x1c>

80103087 <pinit>:
{
80103087:	55                   	push   %ebp
80103088:	89 e5                	mov    %esp,%ebp
8010308a:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
8010308d:	68 80 6e 10 80       	push   $0x80106e80
80103092:	68 20 1d 11 80       	push   $0x80111d20
80103097:	e8 27 09 00 00       	call   801039c3 <initlock>
}
8010309c:	83 c4 10             	add    $0x10,%esp
8010309f:	c9                   	leave  
801030a0:	c3                   	ret    

801030a1 <mycpu>:
{
801030a1:	55                   	push   %ebp
801030a2:	89 e5                	mov    %esp,%ebp
801030a4:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801030a7:	9c                   	pushf  
801030a8:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801030a9:	f6 c4 02             	test   $0x2,%ah
801030ac:	75 2c                	jne    801030da <mycpu+0x39>
  apicid = lapicid();
801030ae:	e8 47 f2 ff ff       	call   801022fa <lapicid>
801030b3:	89 c1                	mov    %eax,%ecx
  for (i = 0; i < ncpu; ++i) {
801030b5:	ba 00 00 00 00       	mov    $0x0,%edx
801030ba:	39 15 84 17 11 80    	cmp    %edx,0x80111784
801030c0:	7e 25                	jle    801030e7 <mycpu+0x46>
    if (cpus[i].apicid == apicid)
801030c2:	8d 04 92             	lea    (%edx,%edx,4),%eax
801030c5:	01 c0                	add    %eax,%eax
801030c7:	01 d0                	add    %edx,%eax
801030c9:	c1 e0 04             	shl    $0x4,%eax
801030cc:	0f b6 80 a0 17 11 80 	movzbl -0x7feee860(%eax),%eax
801030d3:	39 c8                	cmp    %ecx,%eax
801030d5:	74 1d                	je     801030f4 <mycpu+0x53>
  for (i = 0; i < ncpu; ++i) {
801030d7:	42                   	inc    %edx
801030d8:	eb e0                	jmp    801030ba <mycpu+0x19>
    panic("mycpu called with interrupts enabled\n");
801030da:	83 ec 0c             	sub    $0xc,%esp
801030dd:	68 64 6f 10 80       	push   $0x80106f64
801030e2:	e8 5a d2 ff ff       	call   80100341 <panic>
  panic("unknown apicid\n");
801030e7:	83 ec 0c             	sub    $0xc,%esp
801030ea:	68 87 6e 10 80       	push   $0x80106e87
801030ef:	e8 4d d2 ff ff       	call   80100341 <panic>
      return &cpus[i];
801030f4:	8d 04 92             	lea    (%edx,%edx,4),%eax
801030f7:	01 c0                	add    %eax,%eax
801030f9:	01 d0                	add    %edx,%eax
801030fb:	c1 e0 04             	shl    $0x4,%eax
801030fe:	05 a0 17 11 80       	add    $0x801117a0,%eax
}
80103103:	c9                   	leave  
80103104:	c3                   	ret    

80103105 <cpuid>:
cpuid() {
80103105:	55                   	push   %ebp
80103106:	89 e5                	mov    %esp,%ebp
80103108:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010310b:	e8 91 ff ff ff       	call   801030a1 <mycpu>
80103110:	2d a0 17 11 80       	sub    $0x801117a0,%eax
80103115:	c1 f8 04             	sar    $0x4,%eax
80103118:	8d 0c c0             	lea    (%eax,%eax,8),%ecx
8010311b:	89 ca                	mov    %ecx,%edx
8010311d:	c1 e2 05             	shl    $0x5,%edx
80103120:	29 ca                	sub    %ecx,%edx
80103122:	8d 14 90             	lea    (%eax,%edx,4),%edx
80103125:	8d 0c d0             	lea    (%eax,%edx,8),%ecx
80103128:	89 ca                	mov    %ecx,%edx
8010312a:	c1 e2 0f             	shl    $0xf,%edx
8010312d:	29 ca                	sub    %ecx,%edx
8010312f:	8d 04 90             	lea    (%eax,%edx,4),%eax
80103132:	f7 d8                	neg    %eax
}
80103134:	c9                   	leave  
80103135:	c3                   	ret    

80103136 <myproc>:
myproc(void) {
80103136:	55                   	push   %ebp
80103137:	89 e5                	mov    %esp,%ebp
80103139:	53                   	push   %ebx
8010313a:	83 ec 04             	sub    $0x4,%esp
  pushcli();
8010313d:	e8 de 08 00 00       	call   80103a20 <pushcli>
  c = mycpu();
80103142:	e8 5a ff ff ff       	call   801030a1 <mycpu>
  p = c->proc;
80103147:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010314d:	e8 09 09 00 00       	call   80103a5b <popcli>
}
80103152:	89 d8                	mov    %ebx,%eax
80103154:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103157:	c9                   	leave  
80103158:	c3                   	ret    

80103159 <userinit>:
{
80103159:	55                   	push   %ebp
8010315a:	89 e5                	mov    %esp,%ebp
8010315c:	53                   	push   %ebx
8010315d:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103160:	e8 1e fe ff ff       	call   80102f83 <allocproc>
80103165:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103167:	a3 54 3e 11 80       	mov    %eax,0x80113e54
  if((p->pgdir = setupkvm()) == 0)
8010316c:	e8 98 34 00 00       	call   80106609 <setupkvm>
80103171:	89 43 0c             	mov    %eax,0xc(%ebx)
80103174:	85 c0                	test   %eax,%eax
80103176:	0f 84 b7 00 00 00    	je     80103233 <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010317c:	83 ec 04             	sub    $0x4,%esp
8010317f:	68 2c 00 00 00       	push   $0x2c
80103184:	68 60 a4 10 80       	push   $0x8010a460
80103189:	50                   	push   %eax
8010318a:	e8 85 31 00 00       	call   80106314 <inituvm>
  p->sz = PGSIZE;
8010318f:	c7 43 08 00 10 00 00 	movl   $0x1000,0x8(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103196:	8b 43 20             	mov    0x20(%ebx),%eax
80103199:	83 c4 0c             	add    $0xc,%esp
8010319c:	6a 4c                	push   $0x4c
8010319e:	6a 00                	push   $0x0
801031a0:	50                   	push   %eax
801031a1:	e8 00 0a 00 00       	call   80103ba6 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801031a6:	8b 43 20             	mov    0x20(%ebx),%eax
801031a9:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801031af:	8b 43 20             	mov    0x20(%ebx),%eax
801031b2:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801031b8:	8b 43 20             	mov    0x20(%ebx),%eax
801031bb:	8b 50 2c             	mov    0x2c(%eax),%edx
801031be:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801031c2:	8b 43 20             	mov    0x20(%ebx),%eax
801031c5:	8b 50 2c             	mov    0x2c(%eax),%edx
801031c8:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801031cc:	8b 43 20             	mov    0x20(%ebx),%eax
801031cf:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801031d6:	8b 43 20             	mov    0x20(%ebx),%eax
801031d9:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801031e0:	8b 43 20             	mov    0x20(%ebx),%eax
801031e3:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
801031ea:	8d 43 74             	lea    0x74(%ebx),%eax
801031ed:	83 c4 0c             	add    $0xc,%esp
801031f0:	6a 10                	push   $0x10
801031f2:	68 b0 6e 10 80       	push   $0x80106eb0
801031f7:	50                   	push   %eax
801031f8:	e8 01 0b 00 00       	call   80103cfe <safestrcpy>
  p->cwd = namei("/");
801031fd:	c7 04 24 b9 6e 10 80 	movl   $0x80106eb9,(%esp)
80103204:	e8 78 e9 ff ff       	call   80101b81 <namei>
80103209:	89 43 70             	mov    %eax,0x70(%ebx)
  acquire(&ptable.lock);
8010320c:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103213:	e8 e2 08 00 00       	call   80103afa <acquire>
  p->state = RUNNABLE;
80103218:	c7 43 14 03 00 00 00 	movl   $0x3,0x14(%ebx)
  release(&ptable.lock);
8010321f:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103226:	e8 34 09 00 00       	call   80103b5f <release>
}
8010322b:	83 c4 10             	add    $0x10,%esp
8010322e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103231:	c9                   	leave  
80103232:	c3                   	ret    
    panic("userinit: out of memory?");
80103233:	83 ec 0c             	sub    $0xc,%esp
80103236:	68 97 6e 10 80       	push   $0x80106e97
8010323b:	e8 01 d1 ff ff       	call   80100341 <panic>

80103240 <growproc>:
{
80103240:	55                   	push   %ebp
80103241:	89 e5                	mov    %esp,%ebp
80103243:	56                   	push   %esi
80103244:	53                   	push   %ebx
80103245:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
80103248:	e8 e9 fe ff ff       	call   80103136 <myproc>
8010324d:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;//Tamaño inicial
8010324f:	8b 40 08             	mov    0x8(%eax),%eax
  if(n > 0){
80103252:	85 f6                	test   %esi,%esi
80103254:	7f 1c                	jg     80103272 <growproc+0x32>
  } else if(n < 0){
80103256:	78 37                	js     8010328f <growproc+0x4f>
  curproc->sz = sz;
80103258:	89 43 08             	mov    %eax,0x8(%ebx)
  lcr3(V2P(curproc->pgdir));  // Invalidate TLB. Cambia la tabla de páginas
8010325b:	8b 43 0c             	mov    0xc(%ebx),%eax
8010325e:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80103263:	0f 22 d8             	mov    %eax,%cr3
  return 0;
80103266:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010326b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010326e:	5b                   	pop    %ebx
8010326f:	5e                   	pop    %esi
80103270:	5d                   	pop    %ebp
80103271:	c3                   	ret    
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103272:	83 ec 04             	sub    $0x4,%esp
80103275:	01 c6                	add    %eax,%esi
80103277:	56                   	push   %esi
80103278:	50                   	push   %eax
80103279:	ff 73 0c             	push   0xc(%ebx)
8010327c:	e8 25 32 00 00       	call   801064a6 <allocuvm>
80103281:	83 c4 10             	add    $0x10,%esp
80103284:	85 c0                	test   %eax,%eax
80103286:	75 d0                	jne    80103258 <growproc+0x18>
      return -1;
80103288:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010328d:	eb dc                	jmp    8010326b <growproc+0x2b>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010328f:	83 ec 04             	sub    $0x4,%esp
80103292:	01 c6                	add    %eax,%esi
80103294:	56                   	push   %esi
80103295:	50                   	push   %eax
80103296:	ff 73 0c             	push   0xc(%ebx)
80103299:	e8 78 31 00 00       	call   80106416 <deallocuvm>
8010329e:	83 c4 10             	add    $0x10,%esp
801032a1:	85 c0                	test   %eax,%eax
801032a3:	75 b3                	jne    80103258 <growproc+0x18>
      return -1;
801032a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801032aa:	eb bf                	jmp    8010326b <growproc+0x2b>

801032ac <fork>:
{
801032ac:	55                   	push   %ebp
801032ad:	89 e5                	mov    %esp,%ebp
801032af:	57                   	push   %edi
801032b0:	56                   	push   %esi
801032b1:	53                   	push   %ebx
801032b2:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
801032b5:	e8 7c fe ff ff       	call   80103136 <myproc>
801032ba:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
801032bc:	e8 c2 fc ff ff       	call   80102f83 <allocproc>
801032c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801032c4:	85 c0                	test   %eax,%eax
801032c6:	0f 84 e1 00 00 00    	je     801033ad <fork+0x101>
801032cc:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm1(curproc->pgdir, curproc->sz)) == 0){
801032ce:	83 ec 08             	sub    $0x8,%esp
801032d1:	ff 73 08             	push   0x8(%ebx)
801032d4:	ff 73 0c             	push   0xc(%ebx)
801032d7:	e8 ca 34 00 00       	call   801067a6 <copyuvm1>
801032dc:	89 47 0c             	mov    %eax,0xc(%edi)
801032df:	83 c4 10             	add    $0x10,%esp
801032e2:	85 c0                	test   %eax,%eax
801032e4:	74 2c                	je     80103312 <fork+0x66>
  np->sz = curproc->sz;
801032e6:	8b 43 08             	mov    0x8(%ebx),%eax
801032e9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801032ec:	89 41 08             	mov    %eax,0x8(%ecx)
  np->parent = curproc;
801032ef:	89 c8                	mov    %ecx,%eax
801032f1:	89 59 1c             	mov    %ebx,0x1c(%ecx)
  *np->tf = *curproc->tf;
801032f4:	8b 73 20             	mov    0x20(%ebx),%esi
801032f7:	8b 79 20             	mov    0x20(%ecx),%edi
801032fa:	b9 13 00 00 00       	mov    $0x13,%ecx
801032ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
80103301:	8b 40 20             	mov    0x20(%eax),%eax
80103304:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
8010330b:	be 00 00 00 00       	mov    $0x0,%esi
80103310:	eb 27                	jmp    80103339 <fork+0x8d>
    kfree(np->kstack);
80103312:	83 ec 0c             	sub    $0xc,%esp
80103315:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103318:	ff 73 10             	push   0x10(%ebx)
8010331b:	e8 07 ec ff ff       	call   80101f27 <kfree>
    np->kstack = 0;
80103320:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
    np->state = UNUSED;
80103327:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
    return -1;
8010332e:	83 c4 10             	add    $0x10,%esp
80103331:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103336:	eb 6b                	jmp    801033a3 <fork+0xf7>
  for(i = 0; i < NOFILE; i++)
80103338:	46                   	inc    %esi
80103339:	83 fe 0f             	cmp    $0xf,%esi
8010333c:	7f 1d                	jg     8010335b <fork+0xaf>
    if(curproc->ofile[i])
8010333e:	8b 44 b3 30          	mov    0x30(%ebx,%esi,4),%eax
80103342:	85 c0                	test   %eax,%eax
80103344:	74 f2                	je     80103338 <fork+0x8c>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103346:	83 ec 0c             	sub    $0xc,%esp
80103349:	50                   	push   %eax
8010334a:	e8 0f d9 ff ff       	call   80100c5e <filedup>
8010334f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103352:	89 44 b2 30          	mov    %eax,0x30(%edx,%esi,4)
80103356:	83 c4 10             	add    $0x10,%esp
80103359:	eb dd                	jmp    80103338 <fork+0x8c>
  np->cwd = idup(curproc->cwd);
8010335b:	83 ec 0c             	sub    $0xc,%esp
8010335e:	ff 73 70             	push   0x70(%ebx)
80103361:	e8 89 e1 ff ff       	call   801014ef <idup>
80103366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103369:	89 47 70             	mov    %eax,0x70(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010336c:	83 c3 74             	add    $0x74,%ebx
8010336f:	8d 47 74             	lea    0x74(%edi),%eax
80103372:	83 c4 0c             	add    $0xc,%esp
80103375:	6a 10                	push   $0x10
80103377:	53                   	push   %ebx
80103378:	50                   	push   %eax
80103379:	e8 80 09 00 00       	call   80103cfe <safestrcpy>
  pid = np->pid;
8010337e:	8b 5f 18             	mov    0x18(%edi),%ebx
  acquire(&ptable.lock);
80103381:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103388:	e8 6d 07 00 00       	call   80103afa <acquire>
  np->state = RUNNABLE;
8010338d:	c7 47 14 03 00 00 00 	movl   $0x3,0x14(%edi)
  release(&ptable.lock);
80103394:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010339b:	e8 bf 07 00 00       	call   80103b5f <release>
  return pid;
801033a0:	83 c4 10             	add    $0x10,%esp
}
801033a3:	89 d8                	mov    %ebx,%eax
801033a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801033a8:	5b                   	pop    %ebx
801033a9:	5e                   	pop    %esi
801033aa:	5f                   	pop    %edi
801033ab:	5d                   	pop    %ebp
801033ac:	c3                   	ret    
    return -1;
801033ad:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801033b2:	eb ef                	jmp    801033a3 <fork+0xf7>

801033b4 <scheduler>:
{
801033b4:	55                   	push   %ebp
801033b5:	89 e5                	mov    %esp,%ebp
801033b7:	56                   	push   %esi
801033b8:	53                   	push   %ebx
  struct cpu *c = mycpu();
801033b9:	e8 e3 fc ff ff       	call   801030a1 <mycpu>
801033be:	89 c6                	mov    %eax,%esi
  c->proc = 0;
801033c0:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801033c7:	00 00 00 
801033ca:	eb 5d                	jmp    80103429 <scheduler+0x75>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801033cc:	81 c3 84 00 00 00    	add    $0x84,%ebx
801033d2:	81 fb 54 3e 11 80    	cmp    $0x80113e54,%ebx
801033d8:	73 3f                	jae    80103419 <scheduler+0x65>
      if(p->state != RUNNABLE)
801033da:	83 7b 14 03          	cmpl   $0x3,0x14(%ebx)
801033de:	75 ec                	jne    801033cc <scheduler+0x18>
      c->proc = p;
801033e0:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
801033e6:	83 ec 0c             	sub    $0xc,%esp
801033e9:	53                   	push   %ebx
801033ea:	e8 c9 2d 00 00       	call   801061b8 <switchuvm>
      p->state = RUNNING;
801033ef:	c7 43 14 04 00 00 00 	movl   $0x4,0x14(%ebx)
      swtch(&(c->scheduler), p->context);
801033f6:	83 c4 08             	add    $0x8,%esp
801033f9:	ff 73 24             	push   0x24(%ebx)
801033fc:	8d 46 04             	lea    0x4(%esi),%eax
801033ff:	50                   	push   %eax
80103400:	e8 47 09 00 00       	call   80103d4c <swtch>
      switchkvm();
80103405:	e8 a0 2d 00 00       	call   801061aa <switchkvm>
      c->proc = 0;
8010340a:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103411:	00 00 00 
80103414:	83 c4 10             	add    $0x10,%esp
80103417:	eb b3                	jmp    801033cc <scheduler+0x18>
    release(&ptable.lock);
80103419:	83 ec 0c             	sub    $0xc,%esp
8010341c:	68 20 1d 11 80       	push   $0x80111d20
80103421:	e8 39 07 00 00       	call   80103b5f <release>
    sti();
80103426:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103429:	fb                   	sti    
    acquire(&ptable.lock);
8010342a:	83 ec 0c             	sub    $0xc,%esp
8010342d:	68 20 1d 11 80       	push   $0x80111d20
80103432:	e8 c3 06 00 00       	call   80103afa <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103437:	83 c4 10             	add    $0x10,%esp
8010343a:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
8010343f:	eb 91                	jmp    801033d2 <scheduler+0x1e>

80103441 <sched>:
{
80103441:	55                   	push   %ebp
80103442:	89 e5                	mov    %esp,%ebp
80103444:	56                   	push   %esi
80103445:	53                   	push   %ebx
  struct proc *p = myproc();
80103446:	e8 eb fc ff ff       	call   80103136 <myproc>
8010344b:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
8010344d:	83 ec 0c             	sub    $0xc,%esp
80103450:	68 20 1d 11 80       	push   $0x80111d20
80103455:	e8 61 06 00 00       	call   80103abb <holding>
8010345a:	83 c4 10             	add    $0x10,%esp
8010345d:	85 c0                	test   %eax,%eax
8010345f:	74 4f                	je     801034b0 <sched+0x6f>
  if(mycpu()->ncli != 1)
80103461:	e8 3b fc ff ff       	call   801030a1 <mycpu>
80103466:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
8010346d:	75 4e                	jne    801034bd <sched+0x7c>
  if(p->state == RUNNING)
8010346f:	83 7b 14 04          	cmpl   $0x4,0x14(%ebx)
80103473:	74 55                	je     801034ca <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103475:	9c                   	pushf  
80103476:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103477:	f6 c4 02             	test   $0x2,%ah
8010347a:	75 5b                	jne    801034d7 <sched+0x96>
  intena = mycpu()->intena;
8010347c:	e8 20 fc ff ff       	call   801030a1 <mycpu>
80103481:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103487:	e8 15 fc ff ff       	call   801030a1 <mycpu>
8010348c:	83 ec 08             	sub    $0x8,%esp
8010348f:	ff 70 04             	push   0x4(%eax)
80103492:	83 c3 24             	add    $0x24,%ebx
80103495:	53                   	push   %ebx
80103496:	e8 b1 08 00 00       	call   80103d4c <swtch>
  mycpu()->intena = intena;
8010349b:	e8 01 fc ff ff       	call   801030a1 <mycpu>
801034a0:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
801034a6:	83 c4 10             	add    $0x10,%esp
801034a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
801034ac:	5b                   	pop    %ebx
801034ad:	5e                   	pop    %esi
801034ae:	5d                   	pop    %ebp
801034af:	c3                   	ret    
    panic("sched ptable.lock");
801034b0:	83 ec 0c             	sub    $0xc,%esp
801034b3:	68 bb 6e 10 80       	push   $0x80106ebb
801034b8:	e8 84 ce ff ff       	call   80100341 <panic>
    panic("sched locks");
801034bd:	83 ec 0c             	sub    $0xc,%esp
801034c0:	68 cd 6e 10 80       	push   $0x80106ecd
801034c5:	e8 77 ce ff ff       	call   80100341 <panic>
    panic("sched running");
801034ca:	83 ec 0c             	sub    $0xc,%esp
801034cd:	68 d9 6e 10 80       	push   $0x80106ed9
801034d2:	e8 6a ce ff ff       	call   80100341 <panic>
    panic("sched interruptible");
801034d7:	83 ec 0c             	sub    $0xc,%esp
801034da:	68 e7 6e 10 80       	push   $0x80106ee7
801034df:	e8 5d ce ff ff       	call   80100341 <panic>

801034e4 <exit>:
{ 
801034e4:	55                   	push   %ebp
801034e5:	89 e5                	mov    %esp,%ebp
801034e7:	56                   	push   %esi
801034e8:	53                   	push   %ebx
  struct proc *curproc = myproc();
801034e9:	e8 48 fc ff ff       	call   80103136 <myproc>
  if(curproc == initproc)
801034ee:	39 05 54 3e 11 80    	cmp    %eax,0x80113e54
801034f4:	74 09                	je     801034ff <exit+0x1b>
801034f6:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
801034f8:	bb 00 00 00 00       	mov    $0x0,%ebx
801034fd:	eb 22                	jmp    80103521 <exit+0x3d>
    panic("init exiting");
801034ff:	83 ec 0c             	sub    $0xc,%esp
80103502:	68 fb 6e 10 80       	push   $0x80106efb
80103507:	e8 35 ce ff ff       	call   80100341 <panic>
      fileclose(curproc->ofile[fd]);
8010350c:	83 ec 0c             	sub    $0xc,%esp
8010350f:	50                   	push   %eax
80103510:	e8 8c d7 ff ff       	call   80100ca1 <fileclose>
      curproc->ofile[fd] = 0;
80103515:	c7 44 9e 30 00 00 00 	movl   $0x0,0x30(%esi,%ebx,4)
8010351c:	00 
8010351d:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
80103520:	43                   	inc    %ebx
80103521:	83 fb 0f             	cmp    $0xf,%ebx
80103524:	7f 0a                	jg     80103530 <exit+0x4c>
    if(curproc->ofile[fd]){
80103526:	8b 44 9e 30          	mov    0x30(%esi,%ebx,4),%eax
8010352a:	85 c0                	test   %eax,%eax
8010352c:	75 de                	jne    8010350c <exit+0x28>
8010352e:	eb f0                	jmp    80103520 <exit+0x3c>
  begin_op();
80103530:	e8 be f1 ff ff       	call   801026f3 <begin_op>
  iput(curproc->cwd);
80103535:	83 ec 0c             	sub    $0xc,%esp
80103538:	ff 76 70             	push   0x70(%esi)
8010353b:	e8 e2 e0 ff ff       	call   80101622 <iput>
  end_op();
80103540:	e8 2a f2 ff ff       	call   8010276f <end_op>
  curproc->cwd = 0;
80103545:	c7 46 70 00 00 00 00 	movl   $0x0,0x70(%esi)
  acquire(&ptable.lock);
8010354c:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103553:	e8 a2 05 00 00       	call   80103afa <acquire>
  curproc->exitcode = status;
80103558:	8b 45 08             	mov    0x8(%ebp),%eax
8010355b:	89 46 04             	mov    %eax,0x4(%esi)
  wakeup1(curproc->parent);
8010355e:	8b 46 1c             	mov    0x1c(%esi),%eax
80103561:	e8 f3 f9 ff ff       	call   80102f59 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103566:	83 c4 10             	add    $0x10,%esp
80103569:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
8010356e:	eb 06                	jmp    80103576 <exit+0x92>
80103570:	81 c3 84 00 00 00    	add    $0x84,%ebx
80103576:	81 fb 54 3e 11 80    	cmp    $0x80113e54,%ebx
8010357c:	73 1a                	jae    80103598 <exit+0xb4>
    if(p->parent == curproc){
8010357e:	39 73 1c             	cmp    %esi,0x1c(%ebx)
80103581:	75 ed                	jne    80103570 <exit+0x8c>
      p->parent = initproc;
80103583:	a1 54 3e 11 80       	mov    0x80113e54,%eax
80103588:	89 43 1c             	mov    %eax,0x1c(%ebx)
      if(p->state == ZOMBIE)
8010358b:	83 7b 14 05          	cmpl   $0x5,0x14(%ebx)
8010358f:	75 df                	jne    80103570 <exit+0x8c>
        wakeup1(initproc);
80103591:	e8 c3 f9 ff ff       	call   80102f59 <wakeup1>
80103596:	eb d8                	jmp    80103570 <exit+0x8c>
  deallocuvm(curproc->pgdir, KERNBASE, 0);
80103598:	83 ec 04             	sub    $0x4,%esp
8010359b:	6a 00                	push   $0x0
8010359d:	68 00 00 00 80       	push   $0x80000000
801035a2:	ff 76 0c             	push   0xc(%esi)
801035a5:	e8 6c 2e 00 00       	call   80106416 <deallocuvm>
  curproc->state = ZOMBIE;
801035aa:	c7 46 14 05 00 00 00 	movl   $0x5,0x14(%esi)
  sched();
801035b1:	e8 8b fe ff ff       	call   80103441 <sched>
  panic("zombie exit");
801035b6:	c7 04 24 08 6f 10 80 	movl   $0x80106f08,(%esp)
801035bd:	e8 7f cd ff ff       	call   80100341 <panic>

801035c2 <yield>:
{
801035c2:	55                   	push   %ebp
801035c3:	89 e5                	mov    %esp,%ebp
801035c5:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801035c8:	68 20 1d 11 80       	push   $0x80111d20
801035cd:	e8 28 05 00 00       	call   80103afa <acquire>
  myproc()->state = RUNNABLE;
801035d2:	e8 5f fb ff ff       	call   80103136 <myproc>
801035d7:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)
  sched();
801035de:	e8 5e fe ff ff       	call   80103441 <sched>
  release(&ptable.lock);
801035e3:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801035ea:	e8 70 05 00 00       	call   80103b5f <release>
}
801035ef:	83 c4 10             	add    $0x10,%esp
801035f2:	c9                   	leave  
801035f3:	c3                   	ret    

801035f4 <sleep>:
{
801035f4:	55                   	push   %ebp
801035f5:	89 e5                	mov    %esp,%ebp
801035f7:	56                   	push   %esi
801035f8:	53                   	push   %ebx
801035f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct proc *p = myproc();
801035fc:	e8 35 fb ff ff       	call   80103136 <myproc>
  if(p == 0)
80103601:	85 c0                	test   %eax,%eax
80103603:	74 66                	je     8010366b <sleep+0x77>
80103605:	89 c3                	mov    %eax,%ebx
  if(lk == 0)
80103607:	85 f6                	test   %esi,%esi
80103609:	74 6d                	je     80103678 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010360b:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
80103611:	74 18                	je     8010362b <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103613:	83 ec 0c             	sub    $0xc,%esp
80103616:	68 20 1d 11 80       	push   $0x80111d20
8010361b:	e8 da 04 00 00       	call   80103afa <acquire>
    release(lk);
80103620:	89 34 24             	mov    %esi,(%esp)
80103623:	e8 37 05 00 00       	call   80103b5f <release>
80103628:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
8010362b:	8b 45 08             	mov    0x8(%ebp),%eax
8010362e:	89 43 28             	mov    %eax,0x28(%ebx)
  p->state = SLEEPING;
80103631:	c7 43 14 02 00 00 00 	movl   $0x2,0x14(%ebx)
  sched();
80103638:	e8 04 fe ff ff       	call   80103441 <sched>
  p->chan = 0;
8010363d:	c7 43 28 00 00 00 00 	movl   $0x0,0x28(%ebx)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103644:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
8010364a:	74 18                	je     80103664 <sleep+0x70>
    release(&ptable.lock);
8010364c:	83 ec 0c             	sub    $0xc,%esp
8010364f:	68 20 1d 11 80       	push   $0x80111d20
80103654:	e8 06 05 00 00       	call   80103b5f <release>
    acquire(lk);
80103659:	89 34 24             	mov    %esi,(%esp)
8010365c:	e8 99 04 00 00       	call   80103afa <acquire>
80103661:	83 c4 10             	add    $0x10,%esp
}
80103664:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103667:	5b                   	pop    %ebx
80103668:	5e                   	pop    %esi
80103669:	5d                   	pop    %ebp
8010366a:	c3                   	ret    
    panic("sleep");
8010366b:	83 ec 0c             	sub    $0xc,%esp
8010366e:	68 14 6f 10 80       	push   $0x80106f14
80103673:	e8 c9 cc ff ff       	call   80100341 <panic>
    panic("sleep without lk");
80103678:	83 ec 0c             	sub    $0xc,%esp
8010367b:	68 1a 6f 10 80       	push   $0x80106f1a
80103680:	e8 bc cc ff ff       	call   80100341 <panic>

80103685 <wait>:
{
80103685:	55                   	push   %ebp
80103686:	89 e5                	mov    %esp,%ebp
80103688:	56                   	push   %esi
80103689:	53                   	push   %ebx
  struct proc *curproc = myproc();
8010368a:	e8 a7 fa ff ff       	call   80103136 <myproc>
8010368f:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103691:	83 ec 0c             	sub    $0xc,%esp
80103694:	68 20 1d 11 80       	push   $0x80111d20
80103699:	e8 5c 04 00 00       	call   80103afa <acquire>
8010369e:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801036a1:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801036a6:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
801036ab:	eb 68                	jmp    80103715 <wait+0x90>
        *status = p->exitcode;
801036ad:	8b 53 04             	mov    0x4(%ebx),%edx
801036b0:	8b 45 08             	mov    0x8(%ebp),%eax
801036b3:	89 10                	mov    %edx,(%eax)
        pid = p->pid;
801036b5:	8b 73 18             	mov    0x18(%ebx),%esi
        kfree(p->kstack);
801036b8:	83 ec 0c             	sub    $0xc,%esp
801036bb:	ff 73 10             	push   0x10(%ebx)
801036be:	e8 64 e8 ff ff       	call   80101f27 <kfree>
        p->kstack = 0;
801036c3:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        freevm(p->pgdir, 0); // User zone deleted before
801036ca:	83 c4 08             	add    $0x8,%esp
801036cd:	6a 00                	push   $0x0
801036cf:	ff 73 0c             	push   0xc(%ebx)
801036d2:	e8 bc 2e 00 00       	call   80106593 <freevm>
        p->pid = 0;
801036d7:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
        p->parent = 0;
801036de:	c7 43 1c 00 00 00 00 	movl   $0x0,0x1c(%ebx)
        p->name[0] = 0;
801036e5:	c6 43 74 00          	movb   $0x0,0x74(%ebx)
        p->killed = 0;
801036e9:	c7 43 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
        p->state = UNUSED;
801036f0:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        release(&ptable.lock);
801036f7:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801036fe:	e8 5c 04 00 00       	call   80103b5f <release>
        return pid;
80103703:	83 c4 10             	add    $0x10,%esp
}
80103706:	89 f0                	mov    %esi,%eax
80103708:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010370b:	5b                   	pop    %ebx
8010370c:	5e                   	pop    %esi
8010370d:	5d                   	pop    %ebp
8010370e:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010370f:	81 c3 84 00 00 00    	add    $0x84,%ebx
80103715:	81 fb 54 3e 11 80    	cmp    $0x80113e54,%ebx
8010371b:	73 12                	jae    8010372f <wait+0xaa>
      if(p->parent != curproc)
8010371d:	39 73 1c             	cmp    %esi,0x1c(%ebx)
80103720:	75 ed                	jne    8010370f <wait+0x8a>
      if(p->state == ZOMBIE){
80103722:	83 7b 14 05          	cmpl   $0x5,0x14(%ebx)
80103726:	74 85                	je     801036ad <wait+0x28>
      havekids = 1;
80103728:	b8 01 00 00 00       	mov    $0x1,%eax
8010372d:	eb e0                	jmp    8010370f <wait+0x8a>
    if(!havekids || curproc->killed){
8010372f:	85 c0                	test   %eax,%eax
80103731:	74 06                	je     80103739 <wait+0xb4>
80103733:	83 7e 2c 00          	cmpl   $0x0,0x2c(%esi)
80103737:	74 17                	je     80103750 <wait+0xcb>
      release(&ptable.lock);
80103739:	83 ec 0c             	sub    $0xc,%esp
8010373c:	68 20 1d 11 80       	push   $0x80111d20
80103741:	e8 19 04 00 00       	call   80103b5f <release>
      return -1;
80103746:	83 c4 10             	add    $0x10,%esp
80103749:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010374e:	eb b6                	jmp    80103706 <wait+0x81>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103750:	83 ec 08             	sub    $0x8,%esp
80103753:	68 20 1d 11 80       	push   $0x80111d20
80103758:	56                   	push   %esi
80103759:	e8 96 fe ff ff       	call   801035f4 <sleep>
    havekids = 0;
8010375e:	83 c4 10             	add    $0x10,%esp
80103761:	e9 3b ff ff ff       	jmp    801036a1 <wait+0x1c>

80103766 <wakeup>:


// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103766:	55                   	push   %ebp
80103767:	89 e5                	mov    %esp,%ebp
80103769:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
8010376c:	68 20 1d 11 80       	push   $0x80111d20
80103771:	e8 84 03 00 00       	call   80103afa <acquire>
  wakeup1(chan);
80103776:	8b 45 08             	mov    0x8(%ebp),%eax
80103779:	e8 db f7 ff ff       	call   80102f59 <wakeup1>
  release(&ptable.lock);
8010377e:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103785:	e8 d5 03 00 00       	call   80103b5f <release>
}
8010378a:	83 c4 10             	add    $0x10,%esp
8010378d:	c9                   	leave  
8010378e:	c3                   	ret    

8010378f <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010378f:	55                   	push   %ebp
80103790:	89 e5                	mov    %esp,%ebp
80103792:	53                   	push   %ebx
80103793:	83 ec 10             	sub    $0x10,%esp
80103796:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103799:	68 20 1d 11 80       	push   $0x80111d20
8010379e:	e8 57 03 00 00       	call   80103afa <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801037a3:	83 c4 10             	add    $0x10,%esp
801037a6:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
801037ab:	eb 0e                	jmp    801037bb <kill+0x2c>
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
801037ad:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)
801037b4:	eb 1e                	jmp    801037d4 <kill+0x45>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801037b6:	05 84 00 00 00       	add    $0x84,%eax
801037bb:	3d 54 3e 11 80       	cmp    $0x80113e54,%eax
801037c0:	73 2c                	jae    801037ee <kill+0x5f>
    if(p->pid == pid){
801037c2:	39 58 18             	cmp    %ebx,0x18(%eax)
801037c5:	75 ef                	jne    801037b6 <kill+0x27>
      p->killed = 1;
801037c7:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
      if(p->state == SLEEPING)
801037ce:	83 78 14 02          	cmpl   $0x2,0x14(%eax)
801037d2:	74 d9                	je     801037ad <kill+0x1e>
      release(&ptable.lock);
801037d4:	83 ec 0c             	sub    $0xc,%esp
801037d7:	68 20 1d 11 80       	push   $0x80111d20
801037dc:	e8 7e 03 00 00       	call   80103b5f <release>
      return 0;
801037e1:	83 c4 10             	add    $0x10,%esp
801037e4:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801037e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801037ec:	c9                   	leave  
801037ed:	c3                   	ret    
  release(&ptable.lock);
801037ee:	83 ec 0c             	sub    $0xc,%esp
801037f1:	68 20 1d 11 80       	push   $0x80111d20
801037f6:	e8 64 03 00 00       	call   80103b5f <release>
  return -1;
801037fb:	83 c4 10             	add    $0x10,%esp
801037fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103803:	eb e4                	jmp    801037e9 <kill+0x5a>

80103805 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103805:	55                   	push   %ebp
80103806:	89 e5                	mov    %esp,%ebp
80103808:	56                   	push   %esi
80103809:	53                   	push   %ebx
8010380a:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010380d:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80103812:	eb 36                	jmp    8010384a <procdump+0x45>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103814:	b8 2b 6f 10 80       	mov    $0x80106f2b,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103819:	8d 53 74             	lea    0x74(%ebx),%edx
8010381c:	52                   	push   %edx
8010381d:	50                   	push   %eax
8010381e:	ff 73 18             	push   0x18(%ebx)
80103821:	68 2f 6f 10 80       	push   $0x80106f2f
80103826:	e8 af cd ff ff       	call   801005da <cprintf>
    if(p->state == SLEEPING){
8010382b:	83 c4 10             	add    $0x10,%esp
8010382e:	83 7b 14 02          	cmpl   $0x2,0x14(%ebx)
80103832:	74 3c                	je     80103870 <procdump+0x6b>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103834:	83 ec 0c             	sub    $0xc,%esp
80103837:	68 73 73 10 80       	push   $0x80107373
8010383c:	e8 99 cd ff ff       	call   801005da <cprintf>
80103841:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103844:	81 c3 84 00 00 00    	add    $0x84,%ebx
8010384a:	81 fb 54 3e 11 80    	cmp    $0x80113e54,%ebx
80103850:	73 5f                	jae    801038b1 <procdump+0xac>
    if(p->state == UNUSED)
80103852:	8b 43 14             	mov    0x14(%ebx),%eax
80103855:	85 c0                	test   %eax,%eax
80103857:	74 eb                	je     80103844 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103859:	83 f8 05             	cmp    $0x5,%eax
8010385c:	77 b6                	ja     80103814 <procdump+0xf>
8010385e:	8b 04 85 8c 6f 10 80 	mov    -0x7fef9074(,%eax,4),%eax
80103865:	85 c0                	test   %eax,%eax
80103867:	75 b0                	jne    80103819 <procdump+0x14>
      state = "???";
80103869:	b8 2b 6f 10 80       	mov    $0x80106f2b,%eax
8010386e:	eb a9                	jmp    80103819 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103870:	8b 43 24             	mov    0x24(%ebx),%eax
80103873:	8b 40 0c             	mov    0xc(%eax),%eax
80103876:	83 c0 08             	add    $0x8,%eax
80103879:	83 ec 08             	sub    $0x8,%esp
8010387c:	8d 55 d0             	lea    -0x30(%ebp),%edx
8010387f:	52                   	push   %edx
80103880:	50                   	push   %eax
80103881:	e8 58 01 00 00       	call   801039de <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103886:	83 c4 10             	add    $0x10,%esp
80103889:	be 00 00 00 00       	mov    $0x0,%esi
8010388e:	eb 12                	jmp    801038a2 <procdump+0x9d>
        cprintf(" %p", pc[i]);
80103890:	83 ec 08             	sub    $0x8,%esp
80103893:	50                   	push   %eax
80103894:	68 81 69 10 80       	push   $0x80106981
80103899:	e8 3c cd ff ff       	call   801005da <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
8010389e:	46                   	inc    %esi
8010389f:	83 c4 10             	add    $0x10,%esp
801038a2:	83 fe 09             	cmp    $0x9,%esi
801038a5:	7f 8d                	jg     80103834 <procdump+0x2f>
801038a7:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
801038ab:	85 c0                	test   %eax,%eax
801038ad:	75 e1                	jne    80103890 <procdump+0x8b>
801038af:	eb 83                	jmp    80103834 <procdump+0x2f>
  }
}
801038b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038b4:	5b                   	pop    %ebx
801038b5:	5e                   	pop    %esi
801038b6:	5d                   	pop    %ebp
801038b7:	c3                   	ret    

801038b8 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801038b8:	55                   	push   %ebp
801038b9:	89 e5                	mov    %esp,%ebp
801038bb:	53                   	push   %ebx
801038bc:	83 ec 0c             	sub    $0xc,%esp
801038bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
801038c2:	68 a4 6f 10 80       	push   $0x80106fa4
801038c7:	8d 43 04             	lea    0x4(%ebx),%eax
801038ca:	50                   	push   %eax
801038cb:	e8 f3 00 00 00       	call   801039c3 <initlock>
  lk->name = name;
801038d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801038d3:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
801038d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
801038dc:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
801038e3:	83 c4 10             	add    $0x10,%esp
801038e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038e9:	c9                   	leave  
801038ea:	c3                   	ret    

801038eb <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801038eb:	55                   	push   %ebp
801038ec:	89 e5                	mov    %esp,%ebp
801038ee:	56                   	push   %esi
801038ef:	53                   	push   %ebx
801038f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801038f3:	8d 73 04             	lea    0x4(%ebx),%esi
801038f6:	83 ec 0c             	sub    $0xc,%esp
801038f9:	56                   	push   %esi
801038fa:	e8 fb 01 00 00       	call   80103afa <acquire>
  while (lk->locked) {
801038ff:	83 c4 10             	add    $0x10,%esp
80103902:	eb 0d                	jmp    80103911 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103904:	83 ec 08             	sub    $0x8,%esp
80103907:	56                   	push   %esi
80103908:	53                   	push   %ebx
80103909:	e8 e6 fc ff ff       	call   801035f4 <sleep>
8010390e:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103911:	83 3b 00             	cmpl   $0x0,(%ebx)
80103914:	75 ee                	jne    80103904 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103916:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
8010391c:	e8 15 f8 ff ff       	call   80103136 <myproc>
80103921:	8b 40 18             	mov    0x18(%eax),%eax
80103924:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103927:	83 ec 0c             	sub    $0xc,%esp
8010392a:	56                   	push   %esi
8010392b:	e8 2f 02 00 00       	call   80103b5f <release>
}
80103930:	83 c4 10             	add    $0x10,%esp
80103933:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103936:	5b                   	pop    %ebx
80103937:	5e                   	pop    %esi
80103938:	5d                   	pop    %ebp
80103939:	c3                   	ret    

8010393a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010393a:	55                   	push   %ebp
8010393b:	89 e5                	mov    %esp,%ebp
8010393d:	56                   	push   %esi
8010393e:	53                   	push   %ebx
8010393f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103942:	8d 73 04             	lea    0x4(%ebx),%esi
80103945:	83 ec 0c             	sub    $0xc,%esp
80103948:	56                   	push   %esi
80103949:	e8 ac 01 00 00       	call   80103afa <acquire>
  lk->locked = 0;
8010394e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103954:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
8010395b:	89 1c 24             	mov    %ebx,(%esp)
8010395e:	e8 03 fe ff ff       	call   80103766 <wakeup>
  release(&lk->lk);
80103963:	89 34 24             	mov    %esi,(%esp)
80103966:	e8 f4 01 00 00       	call   80103b5f <release>
}
8010396b:	83 c4 10             	add    $0x10,%esp
8010396e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103971:	5b                   	pop    %ebx
80103972:	5e                   	pop    %esi
80103973:	5d                   	pop    %ebp
80103974:	c3                   	ret    

80103975 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103975:	55                   	push   %ebp
80103976:	89 e5                	mov    %esp,%ebp
80103978:	56                   	push   %esi
80103979:	53                   	push   %ebx
8010397a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
8010397d:	8d 73 04             	lea    0x4(%ebx),%esi
80103980:	83 ec 0c             	sub    $0xc,%esp
80103983:	56                   	push   %esi
80103984:	e8 71 01 00 00       	call   80103afa <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103989:	83 c4 10             	add    $0x10,%esp
8010398c:	83 3b 00             	cmpl   $0x0,(%ebx)
8010398f:	75 17                	jne    801039a8 <holdingsleep+0x33>
80103991:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103996:	83 ec 0c             	sub    $0xc,%esp
80103999:	56                   	push   %esi
8010399a:	e8 c0 01 00 00       	call   80103b5f <release>
  return r;
}
8010399f:	89 d8                	mov    %ebx,%eax
801039a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801039a4:	5b                   	pop    %ebx
801039a5:	5e                   	pop    %esi
801039a6:	5d                   	pop    %ebp
801039a7:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
801039a8:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
801039ab:	e8 86 f7 ff ff       	call   80103136 <myproc>
801039b0:	3b 58 18             	cmp    0x18(%eax),%ebx
801039b3:	74 07                	je     801039bc <holdingsleep+0x47>
801039b5:	bb 00 00 00 00       	mov    $0x0,%ebx
801039ba:	eb da                	jmp    80103996 <holdingsleep+0x21>
801039bc:	bb 01 00 00 00       	mov    $0x1,%ebx
801039c1:	eb d3                	jmp    80103996 <holdingsleep+0x21>

801039c3 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801039c3:	55                   	push   %ebp
801039c4:	89 e5                	mov    %esp,%ebp
801039c6:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
801039c9:	8b 55 0c             	mov    0xc(%ebp),%edx
801039cc:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801039cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801039d5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801039dc:	5d                   	pop    %ebp
801039dd:	c3                   	ret    

801039de <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801039de:	55                   	push   %ebp
801039df:	89 e5                	mov    %esp,%ebp
801039e1:	53                   	push   %ebx
801039e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801039e5:	8b 45 08             	mov    0x8(%ebp),%eax
801039e8:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
801039eb:	b8 00 00 00 00       	mov    $0x0,%eax
801039f0:	83 f8 09             	cmp    $0x9,%eax
801039f3:	7f 21                	jg     80103a16 <getcallerpcs+0x38>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801039f5:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
801039fb:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103a01:	77 13                	ja     80103a16 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103a03:	8b 5a 04             	mov    0x4(%edx),%ebx
80103a06:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103a09:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103a0b:	40                   	inc    %eax
80103a0c:	eb e2                	jmp    801039f0 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103a0e:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103a15:	40                   	inc    %eax
80103a16:	83 f8 09             	cmp    $0x9,%eax
80103a19:	7e f3                	jle    80103a0e <getcallerpcs+0x30>
}
80103a1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a1e:	c9                   	leave  
80103a1f:	c3                   	ret    

80103a20 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103a20:	55                   	push   %ebp
80103a21:	89 e5                	mov    %esp,%ebp
80103a23:	53                   	push   %ebx
80103a24:	83 ec 04             	sub    $0x4,%esp
80103a27:	9c                   	pushf  
80103a28:	5b                   	pop    %ebx
  asm volatile("cli");
80103a29:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103a2a:	e8 72 f6 ff ff       	call   801030a1 <mycpu>
80103a2f:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103a36:	74 10                	je     80103a48 <pushcli+0x28>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103a38:	e8 64 f6 ff ff       	call   801030a1 <mycpu>
80103a3d:	ff 80 a4 00 00 00    	incl   0xa4(%eax)
}
80103a43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a46:	c9                   	leave  
80103a47:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103a48:	e8 54 f6 ff ff       	call   801030a1 <mycpu>
80103a4d:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103a53:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103a59:	eb dd                	jmp    80103a38 <pushcli+0x18>

80103a5b <popcli>:

void
popcli(void)
{
80103a5b:	55                   	push   %ebp
80103a5c:	89 e5                	mov    %esp,%ebp
80103a5e:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103a61:	9c                   	pushf  
80103a62:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103a63:	f6 c4 02             	test   $0x2,%ah
80103a66:	75 28                	jne    80103a90 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103a68:	e8 34 f6 ff ff       	call   801030a1 <mycpu>
80103a6d:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103a73:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103a76:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103a7c:	85 d2                	test   %edx,%edx
80103a7e:	78 1d                	js     80103a9d <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103a80:	e8 1c f6 ff ff       	call   801030a1 <mycpu>
80103a85:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103a8c:	74 1c                	je     80103aaa <popcli+0x4f>
    sti();
}
80103a8e:	c9                   	leave  
80103a8f:	c3                   	ret    
    panic("popcli - interruptible");
80103a90:	83 ec 0c             	sub    $0xc,%esp
80103a93:	68 af 6f 10 80       	push   $0x80106faf
80103a98:	e8 a4 c8 ff ff       	call   80100341 <panic>
    panic("popcli");
80103a9d:	83 ec 0c             	sub    $0xc,%esp
80103aa0:	68 c6 6f 10 80       	push   $0x80106fc6
80103aa5:	e8 97 c8 ff ff       	call   80100341 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103aaa:	e8 f2 f5 ff ff       	call   801030a1 <mycpu>
80103aaf:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103ab6:	74 d6                	je     80103a8e <popcli+0x33>
  asm volatile("sti");
80103ab8:	fb                   	sti    
}
80103ab9:	eb d3                	jmp    80103a8e <popcli+0x33>

80103abb <holding>:
{
80103abb:	55                   	push   %ebp
80103abc:	89 e5                	mov    %esp,%ebp
80103abe:	53                   	push   %ebx
80103abf:	83 ec 04             	sub    $0x4,%esp
80103ac2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103ac5:	e8 56 ff ff ff       	call   80103a20 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103aca:	83 3b 00             	cmpl   $0x0,(%ebx)
80103acd:	75 11                	jne    80103ae0 <holding+0x25>
80103acf:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103ad4:	e8 82 ff ff ff       	call   80103a5b <popcli>
}
80103ad9:	89 d8                	mov    %ebx,%eax
80103adb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103ade:	c9                   	leave  
80103adf:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103ae0:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103ae3:	e8 b9 f5 ff ff       	call   801030a1 <mycpu>
80103ae8:	39 c3                	cmp    %eax,%ebx
80103aea:	74 07                	je     80103af3 <holding+0x38>
80103aec:	bb 00 00 00 00       	mov    $0x0,%ebx
80103af1:	eb e1                	jmp    80103ad4 <holding+0x19>
80103af3:	bb 01 00 00 00       	mov    $0x1,%ebx
80103af8:	eb da                	jmp    80103ad4 <holding+0x19>

80103afa <acquire>:
{
80103afa:	55                   	push   %ebp
80103afb:	89 e5                	mov    %esp,%ebp
80103afd:	53                   	push   %ebx
80103afe:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103b01:	e8 1a ff ff ff       	call   80103a20 <pushcli>
  if(holding(lk))
80103b06:	83 ec 0c             	sub    $0xc,%esp
80103b09:	ff 75 08             	push   0x8(%ebp)
80103b0c:	e8 aa ff ff ff       	call   80103abb <holding>
80103b11:	83 c4 10             	add    $0x10,%esp
80103b14:	85 c0                	test   %eax,%eax
80103b16:	75 3a                	jne    80103b52 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103b18:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103b1b:	b8 01 00 00 00       	mov    $0x1,%eax
80103b20:	f0 87 02             	lock xchg %eax,(%edx)
80103b23:	85 c0                	test   %eax,%eax
80103b25:	75 f1                	jne    80103b18 <acquire+0x1e>
  __sync_synchronize();
80103b27:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103b2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103b2f:	e8 6d f5 ff ff       	call   801030a1 <mycpu>
80103b34:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103b37:	8b 45 08             	mov    0x8(%ebp),%eax
80103b3a:	83 c0 0c             	add    $0xc,%eax
80103b3d:	83 ec 08             	sub    $0x8,%esp
80103b40:	50                   	push   %eax
80103b41:	8d 45 08             	lea    0x8(%ebp),%eax
80103b44:	50                   	push   %eax
80103b45:	e8 94 fe ff ff       	call   801039de <getcallerpcs>
}
80103b4a:	83 c4 10             	add    $0x10,%esp
80103b4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b50:	c9                   	leave  
80103b51:	c3                   	ret    
    panic("acquire");
80103b52:	83 ec 0c             	sub    $0xc,%esp
80103b55:	68 cd 6f 10 80       	push   $0x80106fcd
80103b5a:	e8 e2 c7 ff ff       	call   80100341 <panic>

80103b5f <release>:
{
80103b5f:	55                   	push   %ebp
80103b60:	89 e5                	mov    %esp,%ebp
80103b62:	53                   	push   %ebx
80103b63:	83 ec 10             	sub    $0x10,%esp
80103b66:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103b69:	53                   	push   %ebx
80103b6a:	e8 4c ff ff ff       	call   80103abb <holding>
80103b6f:	83 c4 10             	add    $0x10,%esp
80103b72:	85 c0                	test   %eax,%eax
80103b74:	74 23                	je     80103b99 <release+0x3a>
  lk->pcs[0] = 0;
80103b76:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103b7d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103b84:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103b89:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103b8f:	e8 c7 fe ff ff       	call   80103a5b <popcli>
}
80103b94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b97:	c9                   	leave  
80103b98:	c3                   	ret    
    panic("release");
80103b99:	83 ec 0c             	sub    $0xc,%esp
80103b9c:	68 d5 6f 10 80       	push   $0x80106fd5
80103ba1:	e8 9b c7 ff ff       	call   80100341 <panic>

80103ba6 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103ba6:	55                   	push   %ebp
80103ba7:	89 e5                	mov    %esp,%ebp
80103ba9:	57                   	push   %edi
80103baa:	53                   	push   %ebx
80103bab:	8b 55 08             	mov    0x8(%ebp),%edx
80103bae:	8b 45 0c             	mov    0xc(%ebp),%eax
  if ((int)dst%4 == 0 && n%4 == 0){
80103bb1:	f6 c2 03             	test   $0x3,%dl
80103bb4:	75 29                	jne    80103bdf <memset+0x39>
80103bb6:	f6 45 10 03          	testb  $0x3,0x10(%ebp)
80103bba:	75 23                	jne    80103bdf <memset+0x39>
    c &= 0xFF;
80103bbc:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103bbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
80103bc2:	c1 e9 02             	shr    $0x2,%ecx
80103bc5:	c1 e0 18             	shl    $0x18,%eax
80103bc8:	89 fb                	mov    %edi,%ebx
80103bca:	c1 e3 10             	shl    $0x10,%ebx
80103bcd:	09 d8                	or     %ebx,%eax
80103bcf:	89 fb                	mov    %edi,%ebx
80103bd1:	c1 e3 08             	shl    $0x8,%ebx
80103bd4:	09 d8                	or     %ebx,%eax
80103bd6:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103bd8:	89 d7                	mov    %edx,%edi
80103bda:	fc                   	cld    
80103bdb:	f3 ab                	rep stos %eax,%es:(%edi)
}
80103bdd:	eb 08                	jmp    80103be7 <memset+0x41>
  asm volatile("cld; rep stosb" :
80103bdf:	89 d7                	mov    %edx,%edi
80103be1:	8b 4d 10             	mov    0x10(%ebp),%ecx
80103be4:	fc                   	cld    
80103be5:	f3 aa                	rep stos %al,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80103be7:	89 d0                	mov    %edx,%eax
80103be9:	5b                   	pop    %ebx
80103bea:	5f                   	pop    %edi
80103beb:	5d                   	pop    %ebp
80103bec:	c3                   	ret    

80103bed <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103bed:	55                   	push   %ebp
80103bee:	89 e5                	mov    %esp,%ebp
80103bf0:	56                   	push   %esi
80103bf1:	53                   	push   %ebx
80103bf2:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103bf5:	8b 55 0c             	mov    0xc(%ebp),%edx
80103bf8:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103bfb:	eb 04                	jmp    80103c01 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80103bfd:	41                   	inc    %ecx
80103bfe:	42                   	inc    %edx
  while(n-- > 0){
80103bff:	89 f0                	mov    %esi,%eax
80103c01:	8d 70 ff             	lea    -0x1(%eax),%esi
80103c04:	85 c0                	test   %eax,%eax
80103c06:	74 10                	je     80103c18 <memcmp+0x2b>
    if(*s1 != *s2)
80103c08:	8a 01                	mov    (%ecx),%al
80103c0a:	8a 1a                	mov    (%edx),%bl
80103c0c:	38 d8                	cmp    %bl,%al
80103c0e:	74 ed                	je     80103bfd <memcmp+0x10>
      return *s1 - *s2;
80103c10:	0f b6 c0             	movzbl %al,%eax
80103c13:	0f b6 db             	movzbl %bl,%ebx
80103c16:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103c18:	5b                   	pop    %ebx
80103c19:	5e                   	pop    %esi
80103c1a:	5d                   	pop    %ebp
80103c1b:	c3                   	ret    

80103c1c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103c1c:	55                   	push   %ebp
80103c1d:	89 e5                	mov    %esp,%ebp
80103c1f:	56                   	push   %esi
80103c20:	53                   	push   %ebx
80103c21:	8b 75 08             	mov    0x8(%ebp),%esi
80103c24:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c27:	8b 45 10             	mov    0x10(%ebp),%eax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103c2a:	39 f2                	cmp    %esi,%edx
80103c2c:	73 36                	jae    80103c64 <memmove+0x48>
80103c2e:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80103c31:	39 f1                	cmp    %esi,%ecx
80103c33:	76 33                	jbe    80103c68 <memmove+0x4c>
    s += n;
    d += n;
80103c35:	8d 14 06             	lea    (%esi,%eax,1),%edx
    while(n-- > 0)
80103c38:	eb 08                	jmp    80103c42 <memmove+0x26>
      *--d = *--s;
80103c3a:	49                   	dec    %ecx
80103c3b:	4a                   	dec    %edx
80103c3c:	8a 01                	mov    (%ecx),%al
80103c3e:	88 02                	mov    %al,(%edx)
    while(n-- > 0)
80103c40:	89 d8                	mov    %ebx,%eax
80103c42:	8d 58 ff             	lea    -0x1(%eax),%ebx
80103c45:	85 c0                	test   %eax,%eax
80103c47:	75 f1                	jne    80103c3a <memmove+0x1e>
80103c49:	eb 13                	jmp    80103c5e <memmove+0x42>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103c4b:	8a 02                	mov    (%edx),%al
80103c4d:	88 01                	mov    %al,(%ecx)
80103c4f:	8d 49 01             	lea    0x1(%ecx),%ecx
80103c52:	8d 52 01             	lea    0x1(%edx),%edx
    while(n-- > 0)
80103c55:	89 d8                	mov    %ebx,%eax
80103c57:	8d 58 ff             	lea    -0x1(%eax),%ebx
80103c5a:	85 c0                	test   %eax,%eax
80103c5c:	75 ed                	jne    80103c4b <memmove+0x2f>

  return dst;
}
80103c5e:	89 f0                	mov    %esi,%eax
80103c60:	5b                   	pop    %ebx
80103c61:	5e                   	pop    %esi
80103c62:	5d                   	pop    %ebp
80103c63:	c3                   	ret    
80103c64:	89 f1                	mov    %esi,%ecx
80103c66:	eb ef                	jmp    80103c57 <memmove+0x3b>
80103c68:	89 f1                	mov    %esi,%ecx
80103c6a:	eb eb                	jmp    80103c57 <memmove+0x3b>

80103c6c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103c6c:	55                   	push   %ebp
80103c6d:	89 e5                	mov    %esp,%ebp
80103c6f:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80103c72:	ff 75 10             	push   0x10(%ebp)
80103c75:	ff 75 0c             	push   0xc(%ebp)
80103c78:	ff 75 08             	push   0x8(%ebp)
80103c7b:	e8 9c ff ff ff       	call   80103c1c <memmove>
}
80103c80:	c9                   	leave  
80103c81:	c3                   	ret    

80103c82 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103c82:	55                   	push   %ebp
80103c83:	89 e5                	mov    %esp,%ebp
80103c85:	53                   	push   %ebx
80103c86:	8b 55 08             	mov    0x8(%ebp),%edx
80103c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103c8c:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103c8f:	eb 03                	jmp    80103c94 <strncmp+0x12>
    n--, p++, q++;
80103c91:	48                   	dec    %eax
80103c92:	42                   	inc    %edx
80103c93:	41                   	inc    %ecx
  while(n > 0 && *p && *p == *q)
80103c94:	85 c0                	test   %eax,%eax
80103c96:	74 0a                	je     80103ca2 <strncmp+0x20>
80103c98:	8a 1a                	mov    (%edx),%bl
80103c9a:	84 db                	test   %bl,%bl
80103c9c:	74 04                	je     80103ca2 <strncmp+0x20>
80103c9e:	3a 19                	cmp    (%ecx),%bl
80103ca0:	74 ef                	je     80103c91 <strncmp+0xf>
  if(n == 0)
80103ca2:	85 c0                	test   %eax,%eax
80103ca4:	74 0d                	je     80103cb3 <strncmp+0x31>
    return 0;
  return (uchar)*p - (uchar)*q;
80103ca6:	0f b6 02             	movzbl (%edx),%eax
80103ca9:	0f b6 11             	movzbl (%ecx),%edx
80103cac:	29 d0                	sub    %edx,%eax
}
80103cae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103cb1:	c9                   	leave  
80103cb2:	c3                   	ret    
    return 0;
80103cb3:	b8 00 00 00 00       	mov    $0x0,%eax
80103cb8:	eb f4                	jmp    80103cae <strncmp+0x2c>

80103cba <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103cba:	55                   	push   %ebp
80103cbb:	89 e5                	mov    %esp,%ebp
80103cbd:	57                   	push   %edi
80103cbe:	56                   	push   %esi
80103cbf:	53                   	push   %ebx
80103cc0:	8b 45 08             	mov    0x8(%ebp),%eax
80103cc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103cc6:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103cc9:	89 c1                	mov    %eax,%ecx
80103ccb:	eb 04                	jmp    80103cd1 <strncpy+0x17>
80103ccd:	89 fb                	mov    %edi,%ebx
80103ccf:	89 f1                	mov    %esi,%ecx
80103cd1:	89 d6                	mov    %edx,%esi
80103cd3:	4a                   	dec    %edx
80103cd4:	85 f6                	test   %esi,%esi
80103cd6:	7e 10                	jle    80103ce8 <strncpy+0x2e>
80103cd8:	8d 7b 01             	lea    0x1(%ebx),%edi
80103cdb:	8d 71 01             	lea    0x1(%ecx),%esi
80103cde:	8a 1b                	mov    (%ebx),%bl
80103ce0:	88 19                	mov    %bl,(%ecx)
80103ce2:	84 db                	test   %bl,%bl
80103ce4:	75 e7                	jne    80103ccd <strncpy+0x13>
80103ce6:	89 f1                	mov    %esi,%ecx
    ;
  while(n-- > 0)
80103ce8:	8d 5a ff             	lea    -0x1(%edx),%ebx
80103ceb:	85 d2                	test   %edx,%edx
80103ced:	7e 0a                	jle    80103cf9 <strncpy+0x3f>
    *s++ = 0;
80103cef:	c6 01 00             	movb   $0x0,(%ecx)
  while(n-- > 0)
80103cf2:	89 da                	mov    %ebx,%edx
    *s++ = 0;
80103cf4:	8d 49 01             	lea    0x1(%ecx),%ecx
80103cf7:	eb ef                	jmp    80103ce8 <strncpy+0x2e>
  return os;
}
80103cf9:	5b                   	pop    %ebx
80103cfa:	5e                   	pop    %esi
80103cfb:	5f                   	pop    %edi
80103cfc:	5d                   	pop    %ebp
80103cfd:	c3                   	ret    

80103cfe <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103cfe:	55                   	push   %ebp
80103cff:	89 e5                	mov    %esp,%ebp
80103d01:	57                   	push   %edi
80103d02:	56                   	push   %esi
80103d03:	53                   	push   %ebx
80103d04:	8b 45 08             	mov    0x8(%ebp),%eax
80103d07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103d0a:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103d0d:	85 d2                	test   %edx,%edx
80103d0f:	7e 20                	jle    80103d31 <safestrcpy+0x33>
80103d11:	89 c1                	mov    %eax,%ecx
80103d13:	eb 04                	jmp    80103d19 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103d15:	89 fb                	mov    %edi,%ebx
80103d17:	89 f1                	mov    %esi,%ecx
80103d19:	4a                   	dec    %edx
80103d1a:	85 d2                	test   %edx,%edx
80103d1c:	7e 10                	jle    80103d2e <safestrcpy+0x30>
80103d1e:	8d 7b 01             	lea    0x1(%ebx),%edi
80103d21:	8d 71 01             	lea    0x1(%ecx),%esi
80103d24:	8a 1b                	mov    (%ebx),%bl
80103d26:	88 19                	mov    %bl,(%ecx)
80103d28:	84 db                	test   %bl,%bl
80103d2a:	75 e9                	jne    80103d15 <safestrcpy+0x17>
80103d2c:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103d2e:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103d31:	5b                   	pop    %ebx
80103d32:	5e                   	pop    %esi
80103d33:	5f                   	pop    %edi
80103d34:	5d                   	pop    %ebp
80103d35:	c3                   	ret    

80103d36 <strlen>:

int
strlen(const char *s)
{
80103d36:	55                   	push   %ebp
80103d37:	89 e5                	mov    %esp,%ebp
80103d39:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103d3c:	b8 00 00 00 00       	mov    $0x0,%eax
80103d41:	eb 01                	jmp    80103d44 <strlen+0xe>
80103d43:	40                   	inc    %eax
80103d44:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103d48:	75 f9                	jne    80103d43 <strlen+0xd>
    ;
  return n;
}
80103d4a:	5d                   	pop    %ebp
80103d4b:	c3                   	ret    

80103d4c <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103d4c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103d50:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103d54:	55                   	push   %ebp
  pushl %ebx
80103d55:	53                   	push   %ebx
  pushl %esi
80103d56:	56                   	push   %esi
  pushl %edi
80103d57:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103d58:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103d5a:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103d5c:	5f                   	pop    %edi
  popl %esi
80103d5d:	5e                   	pop    %esi
  popl %ebx
80103d5e:	5b                   	pop    %ebx
  popl %ebp
80103d5f:	5d                   	pop    %ebp
  ret
80103d60:	c3                   	ret    

80103d61 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103d61:	55                   	push   %ebp
80103d62:	89 e5                	mov    %esp,%ebp
80103d64:	53                   	push   %ebx
80103d65:	83 ec 04             	sub    $0x4,%esp
80103d68:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103d6b:	e8 c6 f3 ff ff       	call   80103136 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103d70:	8b 40 08             	mov    0x8(%eax),%eax
80103d73:	39 d8                	cmp    %ebx,%eax
80103d75:	76 18                	jbe    80103d8f <fetchint+0x2e>
80103d77:	8d 53 04             	lea    0x4(%ebx),%edx
80103d7a:	39 d0                	cmp    %edx,%eax
80103d7c:	72 18                	jb     80103d96 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103d7e:	8b 13                	mov    (%ebx),%edx
80103d80:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d83:	89 10                	mov    %edx,(%eax)
  return 0;
80103d85:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d8d:	c9                   	leave  
80103d8e:	c3                   	ret    
    return -1;
80103d8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d94:	eb f4                	jmp    80103d8a <fetchint+0x29>
80103d96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d9b:	eb ed                	jmp    80103d8a <fetchint+0x29>

80103d9d <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80103d9d:	55                   	push   %ebp
80103d9e:	89 e5                	mov    %esp,%ebp
80103da0:	53                   	push   %ebx
80103da1:	83 ec 04             	sub    $0x4,%esp
80103da4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103da7:	e8 8a f3 ff ff       	call   80103136 <myproc>

  if(addr >= curproc->sz)
80103dac:	39 58 08             	cmp    %ebx,0x8(%eax)
80103daf:	76 24                	jbe    80103dd5 <fetchstr+0x38>
    return -1;
  *pp = (char*)addr;
80103db1:	8b 55 0c             	mov    0xc(%ebp),%edx
80103db4:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80103db6:	8b 50 08             	mov    0x8(%eax),%edx
  for(s = *pp; s < ep; s++){
80103db9:	89 d8                	mov    %ebx,%eax
80103dbb:	eb 01                	jmp    80103dbe <fetchstr+0x21>
80103dbd:	40                   	inc    %eax
80103dbe:	39 d0                	cmp    %edx,%eax
80103dc0:	73 09                	jae    80103dcb <fetchstr+0x2e>
    if(*s == 0)
80103dc2:	80 38 00             	cmpb   $0x0,(%eax)
80103dc5:	75 f6                	jne    80103dbd <fetchstr+0x20>
      return s - *pp;
80103dc7:	29 d8                	sub    %ebx,%eax
80103dc9:	eb 05                	jmp    80103dd0 <fetchstr+0x33>
  }
  return -1;
80103dcb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103dd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103dd3:	c9                   	leave  
80103dd4:	c3                   	ret    
    return -1;
80103dd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dda:	eb f4                	jmp    80103dd0 <fetchstr+0x33>

80103ddc <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80103ddc:	55                   	push   %ebp
80103ddd:	89 e5                	mov    %esp,%ebp
80103ddf:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80103de2:	e8 4f f3 ff ff       	call   80103136 <myproc>
80103de7:	8b 50 20             	mov    0x20(%eax),%edx
80103dea:	8b 45 08             	mov    0x8(%ebp),%eax
80103ded:	c1 e0 02             	shl    $0x2,%eax
80103df0:	03 42 44             	add    0x44(%edx),%eax
80103df3:	83 ec 08             	sub    $0x8,%esp
80103df6:	ff 75 0c             	push   0xc(%ebp)
80103df9:	83 c0 04             	add    $0x4,%eax
80103dfc:	50                   	push   %eax
80103dfd:	e8 5f ff ff ff       	call   80103d61 <fetchint>
}
80103e02:	c9                   	leave  
80103e03:	c3                   	ret    

80103e04 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, void **pp, int size)
{
80103e04:	55                   	push   %ebp
80103e05:	89 e5                	mov    %esp,%ebp
80103e07:	56                   	push   %esi
80103e08:	53                   	push   %ebx
80103e09:	83 ec 10             	sub    $0x10,%esp
80103e0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80103e0f:	e8 22 f3 ff ff       	call   80103136 <myproc>
80103e14:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80103e16:	83 ec 08             	sub    $0x8,%esp
80103e19:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103e1c:	50                   	push   %eax
80103e1d:	ff 75 08             	push   0x8(%ebp)
80103e20:	e8 b7 ff ff ff       	call   80103ddc <argint>
80103e25:	83 c4 10             	add    $0x10,%esp
80103e28:	85 c0                	test   %eax,%eax
80103e2a:	78 25                	js     80103e51 <argptr+0x4d>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80103e2c:	85 db                	test   %ebx,%ebx
80103e2e:	78 28                	js     80103e58 <argptr+0x54>
80103e30:	8b 56 08             	mov    0x8(%esi),%edx
80103e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e36:	39 c2                	cmp    %eax,%edx
80103e38:	76 25                	jbe    80103e5f <argptr+0x5b>
80103e3a:	01 c3                	add    %eax,%ebx
80103e3c:	39 da                	cmp    %ebx,%edx
80103e3e:	72 26                	jb     80103e66 <argptr+0x62>
    return -1;
  *pp = (void*)i;
80103e40:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e43:	89 02                	mov    %eax,(%edx)
  return 0;
80103e45:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103e4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103e4d:	5b                   	pop    %ebx
80103e4e:	5e                   	pop    %esi
80103e4f:	5d                   	pop    %ebp
80103e50:	c3                   	ret    
    return -1;
80103e51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e56:	eb f2                	jmp    80103e4a <argptr+0x46>
    return -1;
80103e58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e5d:	eb eb                	jmp    80103e4a <argptr+0x46>
80103e5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e64:	eb e4                	jmp    80103e4a <argptr+0x46>
80103e66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e6b:	eb dd                	jmp    80103e4a <argptr+0x46>

80103e6d <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80103e6d:	55                   	push   %ebp
80103e6e:	89 e5                	mov    %esp,%ebp
80103e70:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80103e73:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103e76:	50                   	push   %eax
80103e77:	ff 75 08             	push   0x8(%ebp)
80103e7a:	e8 5d ff ff ff       	call   80103ddc <argint>
80103e7f:	83 c4 10             	add    $0x10,%esp
80103e82:	85 c0                	test   %eax,%eax
80103e84:	78 13                	js     80103e99 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
80103e86:	83 ec 08             	sub    $0x8,%esp
80103e89:	ff 75 0c             	push   0xc(%ebp)
80103e8c:	ff 75 f4             	push   -0xc(%ebp)
80103e8f:	e8 09 ff ff ff       	call   80103d9d <fetchstr>
80103e94:	83 c4 10             	add    $0x10,%esp
}
80103e97:	c9                   	leave  
80103e98:	c3                   	ret    
    return -1;
80103e99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e9e:	eb f7                	jmp    80103e97 <argstr+0x2a>

80103ea0 <syscall>:
[SYS_dup2]		sys_dup2,
};

void
syscall(void)
{
80103ea0:	55                   	push   %ebp
80103ea1:	89 e5                	mov    %esp,%ebp
80103ea3:	53                   	push   %ebx
80103ea4:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80103ea7:	e8 8a f2 ff ff       	call   80103136 <myproc>
80103eac:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80103eae:	8b 40 20             	mov    0x20(%eax),%eax
80103eb1:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80103eb4:	8d 50 ff             	lea    -0x1(%eax),%edx
80103eb7:	83 fa 16             	cmp    $0x16,%edx
80103eba:	77 17                	ja     80103ed3 <syscall+0x33>
80103ebc:	8b 14 85 00 70 10 80 	mov    -0x7fef9000(,%eax,4),%edx
80103ec3:	85 d2                	test   %edx,%edx
80103ec5:	74 0c                	je     80103ed3 <syscall+0x33>
    curproc->tf->eax = syscalls[num]();
80103ec7:	ff d2                	call   *%edx
80103ec9:	89 c2                	mov    %eax,%edx
80103ecb:	8b 43 20             	mov    0x20(%ebx),%eax
80103ece:	89 50 1c             	mov    %edx,0x1c(%eax)
80103ed1:	eb 1f                	jmp    80103ef2 <syscall+0x52>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80103ed3:	8d 53 74             	lea    0x74(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80103ed6:	50                   	push   %eax
80103ed7:	52                   	push   %edx
80103ed8:	ff 73 18             	push   0x18(%ebx)
80103edb:	68 dd 6f 10 80       	push   $0x80106fdd
80103ee0:	e8 f5 c6 ff ff       	call   801005da <cprintf>
    curproc->tf->eax = -1;
80103ee5:	8b 43 20             	mov    0x20(%ebx),%eax
80103ee8:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80103eef:	83 c4 10             	add    $0x10,%esp
  }
}
80103ef2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103ef5:	c9                   	leave  
80103ef6:	c3                   	ret    

80103ef7 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80103ef7:	55                   	push   %ebp
80103ef8:	89 e5                	mov    %esp,%ebp
80103efa:	56                   	push   %esi
80103efb:	53                   	push   %ebx
80103efc:	83 ec 18             	sub    $0x18,%esp
80103eff:	89 d6                	mov    %edx,%esi
80103f01:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80103f03:	8d 55 f4             	lea    -0xc(%ebp),%edx
80103f06:	52                   	push   %edx
80103f07:	50                   	push   %eax
80103f08:	e8 cf fe ff ff       	call   80103ddc <argint>
80103f0d:	83 c4 10             	add    $0x10,%esp
80103f10:	85 c0                	test   %eax,%eax
80103f12:	78 35                	js     80103f49 <argfd+0x52>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80103f14:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80103f18:	77 28                	ja     80103f42 <argfd+0x4b>
80103f1a:	e8 17 f2 ff ff       	call   80103136 <myproc>
80103f1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f22:	8b 44 90 30          	mov    0x30(%eax,%edx,4),%eax
80103f26:	85 c0                	test   %eax,%eax
80103f28:	74 18                	je     80103f42 <argfd+0x4b>
    return -1;
  if(pfd)
80103f2a:	85 f6                	test   %esi,%esi
80103f2c:	74 02                	je     80103f30 <argfd+0x39>
    *pfd = fd;
80103f2e:	89 16                	mov    %edx,(%esi)
  if(pf)
80103f30:	85 db                	test   %ebx,%ebx
80103f32:	74 1c                	je     80103f50 <argfd+0x59>
    *pf = f;
80103f34:	89 03                	mov    %eax,(%ebx)
  return 0;
80103f36:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103f3e:	5b                   	pop    %ebx
80103f3f:	5e                   	pop    %esi
80103f40:	5d                   	pop    %ebp
80103f41:	c3                   	ret    
    return -1;
80103f42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f47:	eb f2                	jmp    80103f3b <argfd+0x44>
    return -1;
80103f49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f4e:	eb eb                	jmp    80103f3b <argfd+0x44>
  return 0;
80103f50:	b8 00 00 00 00       	mov    $0x0,%eax
80103f55:	eb e4                	jmp    80103f3b <argfd+0x44>

80103f57 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80103f57:	55                   	push   %ebp
80103f58:	89 e5                	mov    %esp,%ebp
80103f5a:	53                   	push   %ebx
80103f5b:	83 ec 04             	sub    $0x4,%esp
80103f5e:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
80103f60:	e8 d1 f1 ff ff       	call   80103136 <myproc>
80103f65:	89 c2                	mov    %eax,%edx

  for(fd = 0; fd < NOFILE; fd++){
80103f67:	b8 00 00 00 00       	mov    $0x0,%eax
80103f6c:	83 f8 0f             	cmp    $0xf,%eax
80103f6f:	7f 10                	jg     80103f81 <fdalloc+0x2a>
    if(curproc->ofile[fd] == 0){
80103f71:	83 7c 82 30 00       	cmpl   $0x0,0x30(%edx,%eax,4)
80103f76:	74 03                	je     80103f7b <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
80103f78:	40                   	inc    %eax
80103f79:	eb f1                	jmp    80103f6c <fdalloc+0x15>
      curproc->ofile[fd] = f;
80103f7b:	89 5c 82 30          	mov    %ebx,0x30(%edx,%eax,4)
      return fd;
80103f7f:	eb 05                	jmp    80103f86 <fdalloc+0x2f>
    }
  }
  return -1;
80103f81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103f89:	c9                   	leave  
80103f8a:	c3                   	ret    

80103f8b <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80103f8b:	55                   	push   %ebp
80103f8c:	89 e5                	mov    %esp,%ebp
80103f8e:	56                   	push   %esi
80103f8f:	53                   	push   %ebx
80103f90:	83 ec 10             	sub    $0x10,%esp
80103f93:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80103f95:	b8 20 00 00 00       	mov    $0x20,%eax
80103f9a:	89 c6                	mov    %eax,%esi
80103f9c:	39 43 58             	cmp    %eax,0x58(%ebx)
80103f9f:	76 2e                	jbe    80103fcf <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80103fa1:	6a 10                	push   $0x10
80103fa3:	50                   	push   %eax
80103fa4:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103fa7:	50                   	push   %eax
80103fa8:	53                   	push   %ebx
80103fa9:	e8 5c d7 ff ff       	call   8010170a <readi>
80103fae:	83 c4 10             	add    $0x10,%esp
80103fb1:	83 f8 10             	cmp    $0x10,%eax
80103fb4:	75 0c                	jne    80103fc2 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
80103fb6:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
80103fbb:	75 1e                	jne    80103fdb <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80103fbd:	8d 46 10             	lea    0x10(%esi),%eax
80103fc0:	eb d8                	jmp    80103f9a <isdirempty+0xf>
      panic("isdirempty: readi");
80103fc2:	83 ec 0c             	sub    $0xc,%esp
80103fc5:	68 60 70 10 80       	push   $0x80107060
80103fca:	e8 72 c3 ff ff       	call   80100341 <panic>
      return 0;
  }
  return 1;
80103fcf:	b8 01 00 00 00       	mov    $0x1,%eax
}
80103fd4:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103fd7:	5b                   	pop    %ebx
80103fd8:	5e                   	pop    %esi
80103fd9:	5d                   	pop    %ebp
80103fda:	c3                   	ret    
      return 0;
80103fdb:	b8 00 00 00 00       	mov    $0x0,%eax
80103fe0:	eb f2                	jmp    80103fd4 <isdirempty+0x49>

80103fe2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80103fe2:	55                   	push   %ebp
80103fe3:	89 e5                	mov    %esp,%ebp
80103fe5:	57                   	push   %edi
80103fe6:	56                   	push   %esi
80103fe7:	53                   	push   %ebx
80103fe8:	83 ec 44             	sub    $0x44,%esp
80103feb:	89 d7                	mov    %edx,%edi
80103fed:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
80103ff0:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103ff3:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80103ff6:	8d 55 d6             	lea    -0x2a(%ebp),%edx
80103ff9:	52                   	push   %edx
80103ffa:	50                   	push   %eax
80103ffb:	e8 99 db ff ff       	call   80101b99 <nameiparent>
80104000:	89 c6                	mov    %eax,%esi
80104002:	83 c4 10             	add    $0x10,%esp
80104005:	85 c0                	test   %eax,%eax
80104007:	0f 84 32 01 00 00    	je     8010413f <create+0x15d>
    return 0;
  ilock(dp);
8010400d:	83 ec 0c             	sub    $0xc,%esp
80104010:	50                   	push   %eax
80104011:	e8 07 d5 ff ff       	call   8010151d <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80104016:	83 c4 0c             	add    $0xc,%esp
80104019:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010401c:	50                   	push   %eax
8010401d:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104020:	50                   	push   %eax
80104021:	56                   	push   %esi
80104022:	e8 2c d9 ff ff       	call   80101953 <dirlookup>
80104027:	89 c3                	mov    %eax,%ebx
80104029:	83 c4 10             	add    $0x10,%esp
8010402c:	85 c0                	test   %eax,%eax
8010402e:	74 3c                	je     8010406c <create+0x8a>
    iunlockput(dp);
80104030:	83 ec 0c             	sub    $0xc,%esp
80104033:	56                   	push   %esi
80104034:	e8 87 d6 ff ff       	call   801016c0 <iunlockput>
    ilock(ip);
80104039:	89 1c 24             	mov    %ebx,(%esp)
8010403c:	e8 dc d4 ff ff       	call   8010151d <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104041:	83 c4 10             	add    $0x10,%esp
80104044:	66 83 ff 02          	cmp    $0x2,%di
80104048:	75 07                	jne    80104051 <create+0x6f>
8010404a:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
8010404f:	74 11                	je     80104062 <create+0x80>
      return ip;
    iunlockput(ip);
80104051:	83 ec 0c             	sub    $0xc,%esp
80104054:	53                   	push   %ebx
80104055:	e8 66 d6 ff ff       	call   801016c0 <iunlockput>
    return 0;
8010405a:	83 c4 10             	add    $0x10,%esp
8010405d:	bb 00 00 00 00       	mov    $0x0,%ebx
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104062:	89 d8                	mov    %ebx,%eax
80104064:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104067:	5b                   	pop    %ebx
80104068:	5e                   	pop    %esi
80104069:	5f                   	pop    %edi
8010406a:	5d                   	pop    %ebp
8010406b:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
8010406c:	83 ec 08             	sub    $0x8,%esp
8010406f:	0f bf c7             	movswl %di,%eax
80104072:	50                   	push   %eax
80104073:	ff 36                	push   (%esi)
80104075:	e8 ab d2 ff ff       	call   80101325 <ialloc>
8010407a:	89 c3                	mov    %eax,%ebx
8010407c:	83 c4 10             	add    $0x10,%esp
8010407f:	85 c0                	test   %eax,%eax
80104081:	74 53                	je     801040d6 <create+0xf4>
  ilock(ip);
80104083:	83 ec 0c             	sub    $0xc,%esp
80104086:	50                   	push   %eax
80104087:	e8 91 d4 ff ff       	call   8010151d <ilock>
  ip->major = major;
8010408c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010408f:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
80104093:	8b 45 c0             	mov    -0x40(%ebp),%eax
80104096:	66 89 43 54          	mov    %ax,0x54(%ebx)
  ip->nlink = 1;
8010409a:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
801040a0:	89 1c 24             	mov    %ebx,(%esp)
801040a3:	e8 1c d3 ff ff       	call   801013c4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
801040a8:	83 c4 10             	add    $0x10,%esp
801040ab:	66 83 ff 01          	cmp    $0x1,%di
801040af:	74 32                	je     801040e3 <create+0x101>
  if(dirlink(dp, name, ip->inum) < 0)
801040b1:	83 ec 04             	sub    $0x4,%esp
801040b4:	ff 73 04             	push   0x4(%ebx)
801040b7:	8d 45 d6             	lea    -0x2a(%ebp),%eax
801040ba:	50                   	push   %eax
801040bb:	56                   	push   %esi
801040bc:	e8 0f da ff ff       	call   80101ad0 <dirlink>
801040c1:	83 c4 10             	add    $0x10,%esp
801040c4:	85 c0                	test   %eax,%eax
801040c6:	78 6a                	js     80104132 <create+0x150>
  iunlockput(dp);
801040c8:	83 ec 0c             	sub    $0xc,%esp
801040cb:	56                   	push   %esi
801040cc:	e8 ef d5 ff ff       	call   801016c0 <iunlockput>
  return ip;
801040d1:	83 c4 10             	add    $0x10,%esp
801040d4:	eb 8c                	jmp    80104062 <create+0x80>
    panic("create: ialloc");
801040d6:	83 ec 0c             	sub    $0xc,%esp
801040d9:	68 72 70 10 80       	push   $0x80107072
801040de:	e8 5e c2 ff ff       	call   80100341 <panic>
    dp->nlink++;  // for ".."
801040e3:	66 8b 46 56          	mov    0x56(%esi),%ax
801040e7:	40                   	inc    %eax
801040e8:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
801040ec:	83 ec 0c             	sub    $0xc,%esp
801040ef:	56                   	push   %esi
801040f0:	e8 cf d2 ff ff       	call   801013c4 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801040f5:	83 c4 0c             	add    $0xc,%esp
801040f8:	ff 73 04             	push   0x4(%ebx)
801040fb:	68 82 70 10 80       	push   $0x80107082
80104100:	53                   	push   %ebx
80104101:	e8 ca d9 ff ff       	call   80101ad0 <dirlink>
80104106:	83 c4 10             	add    $0x10,%esp
80104109:	85 c0                	test   %eax,%eax
8010410b:	78 18                	js     80104125 <create+0x143>
8010410d:	83 ec 04             	sub    $0x4,%esp
80104110:	ff 76 04             	push   0x4(%esi)
80104113:	68 81 70 10 80       	push   $0x80107081
80104118:	53                   	push   %ebx
80104119:	e8 b2 d9 ff ff       	call   80101ad0 <dirlink>
8010411e:	83 c4 10             	add    $0x10,%esp
80104121:	85 c0                	test   %eax,%eax
80104123:	79 8c                	jns    801040b1 <create+0xcf>
      panic("create dots");
80104125:	83 ec 0c             	sub    $0xc,%esp
80104128:	68 84 70 10 80       	push   $0x80107084
8010412d:	e8 0f c2 ff ff       	call   80100341 <panic>
    panic("create: dirlink");
80104132:	83 ec 0c             	sub    $0xc,%esp
80104135:	68 90 70 10 80       	push   $0x80107090
8010413a:	e8 02 c2 ff ff       	call   80100341 <panic>
    return 0;
8010413f:	89 c3                	mov    %eax,%ebx
80104141:	e9 1c ff ff ff       	jmp    80104062 <create+0x80>

80104146 <sys_dup>:
{
80104146:	55                   	push   %ebp
80104147:	89 e5                	mov    %esp,%ebp
80104149:	53                   	push   %ebx
8010414a:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
8010414d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104150:	ba 00 00 00 00       	mov    $0x0,%edx
80104155:	b8 00 00 00 00       	mov    $0x0,%eax
8010415a:	e8 98 fd ff ff       	call   80103ef7 <argfd>
8010415f:	85 c0                	test   %eax,%eax
80104161:	78 23                	js     80104186 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
80104163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104166:	e8 ec fd ff ff       	call   80103f57 <fdalloc>
8010416b:	89 c3                	mov    %eax,%ebx
8010416d:	85 c0                	test   %eax,%eax
8010416f:	78 1c                	js     8010418d <sys_dup+0x47>
  filedup(f);
80104171:	83 ec 0c             	sub    $0xc,%esp
80104174:	ff 75 f4             	push   -0xc(%ebp)
80104177:	e8 e2 ca ff ff       	call   80100c5e <filedup>
  return fd;
8010417c:	83 c4 10             	add    $0x10,%esp
}
8010417f:	89 d8                	mov    %ebx,%eax
80104181:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104184:	c9                   	leave  
80104185:	c3                   	ret    
    return -1;
80104186:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010418b:	eb f2                	jmp    8010417f <sys_dup+0x39>
    return -1;
8010418d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104192:	eb eb                	jmp    8010417f <sys_dup+0x39>

80104194 <sys_dup2>:
{
80104194:	55                   	push   %ebp
80104195:	89 e5                	mov    %esp,%ebp
80104197:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0,&oldfd,&old_f) < 0){
8010419a:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010419d:	8d 55 f0             	lea    -0x10(%ebp),%edx
801041a0:	b8 00 00 00 00       	mov    $0x0,%eax
801041a5:	e8 4d fd ff ff       	call   80103ef7 <argfd>
801041aa:	85 c0                	test   %eax,%eax
801041ac:	78 5e                	js     8010420c <sys_dup2+0x78>
  if(argint(1, &newfd) < 0)
801041ae:	83 ec 08             	sub    $0x8,%esp
801041b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801041b4:	50                   	push   %eax
801041b5:	6a 01                	push   $0x1
801041b7:	e8 20 fc ff ff       	call   80103ddc <argint>
801041bc:	83 c4 10             	add    $0x10,%esp
801041bf:	85 c0                	test   %eax,%eax
801041c1:	78 50                	js     80104213 <sys_dup2+0x7f>
  if(newfd==oldfd)
801041c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041c6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801041c9:	74 3f                	je     8010420a <sys_dup2+0x76>
  if( newfd<0 || newfd >NOFILE)
801041cb:	83 f8 10             	cmp    $0x10,%eax
801041ce:	77 4a                	ja     8010421a <sys_dup2+0x86>
  if((new_f=myproc()->ofile[newfd]) != 0)  
801041d0:	e8 61 ef ff ff       	call   80103136 <myproc>
801041d5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801041d8:	8b 44 90 30          	mov    0x30(%eax,%edx,4),%eax
801041dc:	85 c0                	test   %eax,%eax
801041de:	74 0c                	je     801041ec <sys_dup2+0x58>
    fileclose(new_f);
801041e0:	83 ec 0c             	sub    $0xc,%esp
801041e3:	50                   	push   %eax
801041e4:	e8 b8 ca ff ff       	call   80100ca1 <fileclose>
801041e9:	83 c4 10             	add    $0x10,%esp
  myproc()->ofile[newfd] = old_f;
801041ec:	e8 45 ef ff ff       	call   80103136 <myproc>
801041f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041f4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801041f7:	89 54 88 30          	mov    %edx,0x30(%eax,%ecx,4)
  filedup(old_f);
801041fb:	83 ec 0c             	sub    $0xc,%esp
801041fe:	52                   	push   %edx
801041ff:	e8 5a ca ff ff       	call   80100c5e <filedup>
  return newfd;
80104204:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104207:	83 c4 10             	add    $0x10,%esp
}
8010420a:	c9                   	leave  
8010420b:	c3                   	ret    
    return -1;
8010420c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104211:	eb f7                	jmp    8010420a <sys_dup2+0x76>
    return -1;
80104213:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104218:	eb f0                	jmp    8010420a <sys_dup2+0x76>
  	return -1;
8010421a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010421f:	eb e9                	jmp    8010420a <sys_dup2+0x76>

80104221 <sys_read>:
{
80104221:	55                   	push   %ebp
80104222:	89 e5                	mov    %esp,%ebp
80104224:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, (void**)&p, n) < 0)
80104227:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010422a:	ba 00 00 00 00       	mov    $0x0,%edx
8010422f:	b8 00 00 00 00       	mov    $0x0,%eax
80104234:	e8 be fc ff ff       	call   80103ef7 <argfd>
80104239:	85 c0                	test   %eax,%eax
8010423b:	78 43                	js     80104280 <sys_read+0x5f>
8010423d:	83 ec 08             	sub    $0x8,%esp
80104240:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104243:	50                   	push   %eax
80104244:	6a 02                	push   $0x2
80104246:	e8 91 fb ff ff       	call   80103ddc <argint>
8010424b:	83 c4 10             	add    $0x10,%esp
8010424e:	85 c0                	test   %eax,%eax
80104250:	78 2e                	js     80104280 <sys_read+0x5f>
80104252:	83 ec 04             	sub    $0x4,%esp
80104255:	ff 75 f0             	push   -0x10(%ebp)
80104258:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010425b:	50                   	push   %eax
8010425c:	6a 01                	push   $0x1
8010425e:	e8 a1 fb ff ff       	call   80103e04 <argptr>
80104263:	83 c4 10             	add    $0x10,%esp
80104266:	85 c0                	test   %eax,%eax
80104268:	78 16                	js     80104280 <sys_read+0x5f>
  return fileread(f, p, n);
8010426a:	83 ec 04             	sub    $0x4,%esp
8010426d:	ff 75 f0             	push   -0x10(%ebp)
80104270:	ff 75 ec             	push   -0x14(%ebp)
80104273:	ff 75 f4             	push   -0xc(%ebp)
80104276:	e8 1f cb ff ff       	call   80100d9a <fileread>
8010427b:	83 c4 10             	add    $0x10,%esp
}
8010427e:	c9                   	leave  
8010427f:	c3                   	ret    
    return -1;
80104280:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104285:	eb f7                	jmp    8010427e <sys_read+0x5d>

80104287 <sys_write>:
{
80104287:	55                   	push   %ebp
80104288:	89 e5                	mov    %esp,%ebp
8010428a:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, (void**)&p, n) < 0)
8010428d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104290:	ba 00 00 00 00       	mov    $0x0,%edx
80104295:	b8 00 00 00 00       	mov    $0x0,%eax
8010429a:	e8 58 fc ff ff       	call   80103ef7 <argfd>
8010429f:	85 c0                	test   %eax,%eax
801042a1:	78 43                	js     801042e6 <sys_write+0x5f>
801042a3:	83 ec 08             	sub    $0x8,%esp
801042a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801042a9:	50                   	push   %eax
801042aa:	6a 02                	push   $0x2
801042ac:	e8 2b fb ff ff       	call   80103ddc <argint>
801042b1:	83 c4 10             	add    $0x10,%esp
801042b4:	85 c0                	test   %eax,%eax
801042b6:	78 2e                	js     801042e6 <sys_write+0x5f>
801042b8:	83 ec 04             	sub    $0x4,%esp
801042bb:	ff 75 f0             	push   -0x10(%ebp)
801042be:	8d 45 ec             	lea    -0x14(%ebp),%eax
801042c1:	50                   	push   %eax
801042c2:	6a 01                	push   $0x1
801042c4:	e8 3b fb ff ff       	call   80103e04 <argptr>
801042c9:	83 c4 10             	add    $0x10,%esp
801042cc:	85 c0                	test   %eax,%eax
801042ce:	78 16                	js     801042e6 <sys_write+0x5f>
  return filewrite(f, p, n);
801042d0:	83 ec 04             	sub    $0x4,%esp
801042d3:	ff 75 f0             	push   -0x10(%ebp)
801042d6:	ff 75 ec             	push   -0x14(%ebp)
801042d9:	ff 75 f4             	push   -0xc(%ebp)
801042dc:	e8 3e cb ff ff       	call   80100e1f <filewrite>
801042e1:	83 c4 10             	add    $0x10,%esp
}
801042e4:	c9                   	leave  
801042e5:	c3                   	ret    
    return -1;
801042e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042eb:	eb f7                	jmp    801042e4 <sys_write+0x5d>

801042ed <sys_close>:
{
801042ed:	55                   	push   %ebp
801042ee:	89 e5                	mov    %esp,%ebp
801042f0:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801042f3:	8d 4d f0             	lea    -0x10(%ebp),%ecx
801042f6:	8d 55 f4             	lea    -0xc(%ebp),%edx
801042f9:	b8 00 00 00 00       	mov    $0x0,%eax
801042fe:	e8 f4 fb ff ff       	call   80103ef7 <argfd>
80104303:	85 c0                	test   %eax,%eax
80104305:	78 25                	js     8010432c <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
80104307:	e8 2a ee ff ff       	call   80103136 <myproc>
8010430c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010430f:	c7 44 90 30 00 00 00 	movl   $0x0,0x30(%eax,%edx,4)
80104316:	00 
  fileclose(f);
80104317:	83 ec 0c             	sub    $0xc,%esp
8010431a:	ff 75 f0             	push   -0x10(%ebp)
8010431d:	e8 7f c9 ff ff       	call   80100ca1 <fileclose>
  return 0;
80104322:	83 c4 10             	add    $0x10,%esp
80104325:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010432a:	c9                   	leave  
8010432b:	c3                   	ret    
    return -1;
8010432c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104331:	eb f7                	jmp    8010432a <sys_close+0x3d>

80104333 <sys_fstat>:
{
80104333:	55                   	push   %ebp
80104334:	89 e5                	mov    %esp,%ebp
80104336:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104339:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010433c:	ba 00 00 00 00       	mov    $0x0,%edx
80104341:	b8 00 00 00 00       	mov    $0x0,%eax
80104346:	e8 ac fb ff ff       	call   80103ef7 <argfd>
8010434b:	85 c0                	test   %eax,%eax
8010434d:	78 2a                	js     80104379 <sys_fstat+0x46>
8010434f:	83 ec 04             	sub    $0x4,%esp
80104352:	6a 14                	push   $0x14
80104354:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104357:	50                   	push   %eax
80104358:	6a 01                	push   $0x1
8010435a:	e8 a5 fa ff ff       	call   80103e04 <argptr>
8010435f:	83 c4 10             	add    $0x10,%esp
80104362:	85 c0                	test   %eax,%eax
80104364:	78 13                	js     80104379 <sys_fstat+0x46>
  return filestat(f, st);
80104366:	83 ec 08             	sub    $0x8,%esp
80104369:	ff 75 f0             	push   -0x10(%ebp)
8010436c:	ff 75 f4             	push   -0xc(%ebp)
8010436f:	e8 df c9 ff ff       	call   80100d53 <filestat>
80104374:	83 c4 10             	add    $0x10,%esp
}
80104377:	c9                   	leave  
80104378:	c3                   	ret    
    return -1;
80104379:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010437e:	eb f7                	jmp    80104377 <sys_fstat+0x44>

80104380 <sys_link>:
{
80104380:	55                   	push   %ebp
80104381:	89 e5                	mov    %esp,%ebp
80104383:	56                   	push   %esi
80104384:	53                   	push   %ebx
80104385:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104388:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010438b:	50                   	push   %eax
8010438c:	6a 00                	push   $0x0
8010438e:	e8 da fa ff ff       	call   80103e6d <argstr>
80104393:	83 c4 10             	add    $0x10,%esp
80104396:	85 c0                	test   %eax,%eax
80104398:	0f 88 d1 00 00 00    	js     8010446f <sys_link+0xef>
8010439e:	83 ec 08             	sub    $0x8,%esp
801043a1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801043a4:	50                   	push   %eax
801043a5:	6a 01                	push   $0x1
801043a7:	e8 c1 fa ff ff       	call   80103e6d <argstr>
801043ac:	83 c4 10             	add    $0x10,%esp
801043af:	85 c0                	test   %eax,%eax
801043b1:	0f 88 b8 00 00 00    	js     8010446f <sys_link+0xef>
  begin_op();
801043b7:	e8 37 e3 ff ff       	call   801026f3 <begin_op>
  if((ip = namei(old)) == 0){
801043bc:	83 ec 0c             	sub    $0xc,%esp
801043bf:	ff 75 e0             	push   -0x20(%ebp)
801043c2:	e8 ba d7 ff ff       	call   80101b81 <namei>
801043c7:	89 c3                	mov    %eax,%ebx
801043c9:	83 c4 10             	add    $0x10,%esp
801043cc:	85 c0                	test   %eax,%eax
801043ce:	0f 84 a2 00 00 00    	je     80104476 <sys_link+0xf6>
  ilock(ip);
801043d4:	83 ec 0c             	sub    $0xc,%esp
801043d7:	50                   	push   %eax
801043d8:	e8 40 d1 ff ff       	call   8010151d <ilock>
  if(ip->type == T_DIR){
801043dd:	83 c4 10             	add    $0x10,%esp
801043e0:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801043e5:	0f 84 97 00 00 00    	je     80104482 <sys_link+0x102>
  ip->nlink++;
801043eb:	66 8b 43 56          	mov    0x56(%ebx),%ax
801043ef:	40                   	inc    %eax
801043f0:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801043f4:	83 ec 0c             	sub    $0xc,%esp
801043f7:	53                   	push   %ebx
801043f8:	e8 c7 cf ff ff       	call   801013c4 <iupdate>
  iunlock(ip);
801043fd:	89 1c 24             	mov    %ebx,(%esp)
80104400:	e8 d8 d1 ff ff       	call   801015dd <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104405:	83 c4 08             	add    $0x8,%esp
80104408:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010440b:	50                   	push   %eax
8010440c:	ff 75 e4             	push   -0x1c(%ebp)
8010440f:	e8 85 d7 ff ff       	call   80101b99 <nameiparent>
80104414:	89 c6                	mov    %eax,%esi
80104416:	83 c4 10             	add    $0x10,%esp
80104419:	85 c0                	test   %eax,%eax
8010441b:	0f 84 85 00 00 00    	je     801044a6 <sys_link+0x126>
  ilock(dp);
80104421:	83 ec 0c             	sub    $0xc,%esp
80104424:	50                   	push   %eax
80104425:	e8 f3 d0 ff ff       	call   8010151d <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010442a:	83 c4 10             	add    $0x10,%esp
8010442d:	8b 03                	mov    (%ebx),%eax
8010442f:	39 06                	cmp    %eax,(%esi)
80104431:	75 67                	jne    8010449a <sys_link+0x11a>
80104433:	83 ec 04             	sub    $0x4,%esp
80104436:	ff 73 04             	push   0x4(%ebx)
80104439:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010443c:	50                   	push   %eax
8010443d:	56                   	push   %esi
8010443e:	e8 8d d6 ff ff       	call   80101ad0 <dirlink>
80104443:	83 c4 10             	add    $0x10,%esp
80104446:	85 c0                	test   %eax,%eax
80104448:	78 50                	js     8010449a <sys_link+0x11a>
  iunlockput(dp);
8010444a:	83 ec 0c             	sub    $0xc,%esp
8010444d:	56                   	push   %esi
8010444e:	e8 6d d2 ff ff       	call   801016c0 <iunlockput>
  iput(ip);
80104453:	89 1c 24             	mov    %ebx,(%esp)
80104456:	e8 c7 d1 ff ff       	call   80101622 <iput>
  end_op();
8010445b:	e8 0f e3 ff ff       	call   8010276f <end_op>
  return 0;
80104460:	83 c4 10             	add    $0x10,%esp
80104463:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104468:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010446b:	5b                   	pop    %ebx
8010446c:	5e                   	pop    %esi
8010446d:	5d                   	pop    %ebp
8010446e:	c3                   	ret    
    return -1;
8010446f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104474:	eb f2                	jmp    80104468 <sys_link+0xe8>
    end_op();
80104476:	e8 f4 e2 ff ff       	call   8010276f <end_op>
    return -1;
8010447b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104480:	eb e6                	jmp    80104468 <sys_link+0xe8>
    iunlockput(ip);
80104482:	83 ec 0c             	sub    $0xc,%esp
80104485:	53                   	push   %ebx
80104486:	e8 35 d2 ff ff       	call   801016c0 <iunlockput>
    end_op();
8010448b:	e8 df e2 ff ff       	call   8010276f <end_op>
    return -1;
80104490:	83 c4 10             	add    $0x10,%esp
80104493:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104498:	eb ce                	jmp    80104468 <sys_link+0xe8>
    iunlockput(dp);
8010449a:	83 ec 0c             	sub    $0xc,%esp
8010449d:	56                   	push   %esi
8010449e:	e8 1d d2 ff ff       	call   801016c0 <iunlockput>
    goto bad;
801044a3:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
801044a6:	83 ec 0c             	sub    $0xc,%esp
801044a9:	53                   	push   %ebx
801044aa:	e8 6e d0 ff ff       	call   8010151d <ilock>
  ip->nlink--;
801044af:	66 8b 43 56          	mov    0x56(%ebx),%ax
801044b3:	48                   	dec    %eax
801044b4:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801044b8:	89 1c 24             	mov    %ebx,(%esp)
801044bb:	e8 04 cf ff ff       	call   801013c4 <iupdate>
  iunlockput(ip);
801044c0:	89 1c 24             	mov    %ebx,(%esp)
801044c3:	e8 f8 d1 ff ff       	call   801016c0 <iunlockput>
  end_op();
801044c8:	e8 a2 e2 ff ff       	call   8010276f <end_op>
  return -1;
801044cd:	83 c4 10             	add    $0x10,%esp
801044d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044d5:	eb 91                	jmp    80104468 <sys_link+0xe8>

801044d7 <sys_unlink>:
{
801044d7:	55                   	push   %ebp
801044d8:	89 e5                	mov    %esp,%ebp
801044da:	57                   	push   %edi
801044db:	56                   	push   %esi
801044dc:	53                   	push   %ebx
801044dd:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801044e0:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801044e3:	50                   	push   %eax
801044e4:	6a 00                	push   $0x0
801044e6:	e8 82 f9 ff ff       	call   80103e6d <argstr>
801044eb:	83 c4 10             	add    $0x10,%esp
801044ee:	85 c0                	test   %eax,%eax
801044f0:	0f 88 7f 01 00 00    	js     80104675 <sys_unlink+0x19e>
  begin_op();
801044f6:	e8 f8 e1 ff ff       	call   801026f3 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801044fb:	83 ec 08             	sub    $0x8,%esp
801044fe:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104501:	50                   	push   %eax
80104502:	ff 75 c4             	push   -0x3c(%ebp)
80104505:	e8 8f d6 ff ff       	call   80101b99 <nameiparent>
8010450a:	89 c6                	mov    %eax,%esi
8010450c:	83 c4 10             	add    $0x10,%esp
8010450f:	85 c0                	test   %eax,%eax
80104511:	0f 84 eb 00 00 00    	je     80104602 <sys_unlink+0x12b>
  ilock(dp);
80104517:	83 ec 0c             	sub    $0xc,%esp
8010451a:	50                   	push   %eax
8010451b:	e8 fd cf ff ff       	call   8010151d <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104520:	83 c4 08             	add    $0x8,%esp
80104523:	68 82 70 10 80       	push   $0x80107082
80104528:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010452b:	50                   	push   %eax
8010452c:	e8 0d d4 ff ff       	call   8010193e <namecmp>
80104531:	83 c4 10             	add    $0x10,%esp
80104534:	85 c0                	test   %eax,%eax
80104536:	0f 84 fa 00 00 00    	je     80104636 <sys_unlink+0x15f>
8010453c:	83 ec 08             	sub    $0x8,%esp
8010453f:	68 81 70 10 80       	push   $0x80107081
80104544:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104547:	50                   	push   %eax
80104548:	e8 f1 d3 ff ff       	call   8010193e <namecmp>
8010454d:	83 c4 10             	add    $0x10,%esp
80104550:	85 c0                	test   %eax,%eax
80104552:	0f 84 de 00 00 00    	je     80104636 <sys_unlink+0x15f>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104558:	83 ec 04             	sub    $0x4,%esp
8010455b:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010455e:	50                   	push   %eax
8010455f:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104562:	50                   	push   %eax
80104563:	56                   	push   %esi
80104564:	e8 ea d3 ff ff       	call   80101953 <dirlookup>
80104569:	89 c3                	mov    %eax,%ebx
8010456b:	83 c4 10             	add    $0x10,%esp
8010456e:	85 c0                	test   %eax,%eax
80104570:	0f 84 c0 00 00 00    	je     80104636 <sys_unlink+0x15f>
  ilock(ip);
80104576:	83 ec 0c             	sub    $0xc,%esp
80104579:	50                   	push   %eax
8010457a:	e8 9e cf ff ff       	call   8010151d <ilock>
  if(ip->nlink < 1)
8010457f:	83 c4 10             	add    $0x10,%esp
80104582:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104587:	0f 8e 81 00 00 00    	jle    8010460e <sys_unlink+0x137>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010458d:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104592:	0f 84 83 00 00 00    	je     8010461b <sys_unlink+0x144>
  memset(&de, 0, sizeof(de));
80104598:	83 ec 04             	sub    $0x4,%esp
8010459b:	6a 10                	push   $0x10
8010459d:	6a 00                	push   $0x0
8010459f:	8d 7d d8             	lea    -0x28(%ebp),%edi
801045a2:	57                   	push   %edi
801045a3:	e8 fe f5 ff ff       	call   80103ba6 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801045a8:	6a 10                	push   $0x10
801045aa:	ff 75 c0             	push   -0x40(%ebp)
801045ad:	57                   	push   %edi
801045ae:	56                   	push   %esi
801045af:	e8 56 d2 ff ff       	call   8010180a <writei>
801045b4:	83 c4 20             	add    $0x20,%esp
801045b7:	83 f8 10             	cmp    $0x10,%eax
801045ba:	0f 85 8e 00 00 00    	jne    8010464e <sys_unlink+0x177>
  if(ip->type == T_DIR){
801045c0:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801045c5:	0f 84 90 00 00 00    	je     8010465b <sys_unlink+0x184>
  iunlockput(dp);
801045cb:	83 ec 0c             	sub    $0xc,%esp
801045ce:	56                   	push   %esi
801045cf:	e8 ec d0 ff ff       	call   801016c0 <iunlockput>
  ip->nlink--;
801045d4:	66 8b 43 56          	mov    0x56(%ebx),%ax
801045d8:	48                   	dec    %eax
801045d9:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801045dd:	89 1c 24             	mov    %ebx,(%esp)
801045e0:	e8 df cd ff ff       	call   801013c4 <iupdate>
  iunlockput(ip);
801045e5:	89 1c 24             	mov    %ebx,(%esp)
801045e8:	e8 d3 d0 ff ff       	call   801016c0 <iunlockput>
  end_op();
801045ed:	e8 7d e1 ff ff       	call   8010276f <end_op>
  return 0;
801045f2:	83 c4 10             	add    $0x10,%esp
801045f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
801045fd:	5b                   	pop    %ebx
801045fe:	5e                   	pop    %esi
801045ff:	5f                   	pop    %edi
80104600:	5d                   	pop    %ebp
80104601:	c3                   	ret    
    end_op();
80104602:	e8 68 e1 ff ff       	call   8010276f <end_op>
    return -1;
80104607:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010460c:	eb ec                	jmp    801045fa <sys_unlink+0x123>
    panic("unlink: nlink < 1");
8010460e:	83 ec 0c             	sub    $0xc,%esp
80104611:	68 a0 70 10 80       	push   $0x801070a0
80104616:	e8 26 bd ff ff       	call   80100341 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010461b:	89 d8                	mov    %ebx,%eax
8010461d:	e8 69 f9 ff ff       	call   80103f8b <isdirempty>
80104622:	85 c0                	test   %eax,%eax
80104624:	0f 85 6e ff ff ff    	jne    80104598 <sys_unlink+0xc1>
    iunlockput(ip);
8010462a:	83 ec 0c             	sub    $0xc,%esp
8010462d:	53                   	push   %ebx
8010462e:	e8 8d d0 ff ff       	call   801016c0 <iunlockput>
    goto bad;
80104633:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80104636:	83 ec 0c             	sub    $0xc,%esp
80104639:	56                   	push   %esi
8010463a:	e8 81 d0 ff ff       	call   801016c0 <iunlockput>
  end_op();
8010463f:	e8 2b e1 ff ff       	call   8010276f <end_op>
  return -1;
80104644:	83 c4 10             	add    $0x10,%esp
80104647:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010464c:	eb ac                	jmp    801045fa <sys_unlink+0x123>
    panic("unlink: writei");
8010464e:	83 ec 0c             	sub    $0xc,%esp
80104651:	68 b2 70 10 80       	push   $0x801070b2
80104656:	e8 e6 bc ff ff       	call   80100341 <panic>
    dp->nlink--;
8010465b:	66 8b 46 56          	mov    0x56(%esi),%ax
8010465f:	48                   	dec    %eax
80104660:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104664:	83 ec 0c             	sub    $0xc,%esp
80104667:	56                   	push   %esi
80104668:	e8 57 cd ff ff       	call   801013c4 <iupdate>
8010466d:	83 c4 10             	add    $0x10,%esp
80104670:	e9 56 ff ff ff       	jmp    801045cb <sys_unlink+0xf4>
    return -1;
80104675:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010467a:	e9 7b ff ff ff       	jmp    801045fa <sys_unlink+0x123>

8010467f <sys_open>:

int
sys_open(void)
{
8010467f:	55                   	push   %ebp
80104680:	89 e5                	mov    %esp,%ebp
80104682:	57                   	push   %edi
80104683:	56                   	push   %esi
80104684:	53                   	push   %ebx
80104685:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104688:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010468b:	50                   	push   %eax
8010468c:	6a 00                	push   $0x0
8010468e:	e8 da f7 ff ff       	call   80103e6d <argstr>
80104693:	83 c4 10             	add    $0x10,%esp
80104696:	85 c0                	test   %eax,%eax
80104698:	0f 88 a0 00 00 00    	js     8010473e <sys_open+0xbf>
8010469e:	83 ec 08             	sub    $0x8,%esp
801046a1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801046a4:	50                   	push   %eax
801046a5:	6a 01                	push   $0x1
801046a7:	e8 30 f7 ff ff       	call   80103ddc <argint>
801046ac:	83 c4 10             	add    $0x10,%esp
801046af:	85 c0                	test   %eax,%eax
801046b1:	0f 88 87 00 00 00    	js     8010473e <sys_open+0xbf>
    return -1;

  begin_op();
801046b7:	e8 37 e0 ff ff       	call   801026f3 <begin_op>

  if(omode & O_CREATE){
801046bc:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
801046c0:	0f 84 8b 00 00 00    	je     80104751 <sys_open+0xd2>
    ip = create(path, T_FILE, 0, 0);
801046c6:	83 ec 0c             	sub    $0xc,%esp
801046c9:	6a 00                	push   $0x0
801046cb:	b9 00 00 00 00       	mov    $0x0,%ecx
801046d0:	ba 02 00 00 00       	mov    $0x2,%edx
801046d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801046d8:	e8 05 f9 ff ff       	call   80103fe2 <create>
801046dd:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801046df:	83 c4 10             	add    $0x10,%esp
801046e2:	85 c0                	test   %eax,%eax
801046e4:	74 5f                	je     80104745 <sys_open+0xc6>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801046e6:	e8 12 c5 ff ff       	call   80100bfd <filealloc>
801046eb:	89 c3                	mov    %eax,%ebx
801046ed:	85 c0                	test   %eax,%eax
801046ef:	0f 84 b5 00 00 00    	je     801047aa <sys_open+0x12b>
801046f5:	e8 5d f8 ff ff       	call   80103f57 <fdalloc>
801046fa:	89 c7                	mov    %eax,%edi
801046fc:	85 c0                	test   %eax,%eax
801046fe:	0f 88 a6 00 00 00    	js     801047aa <sys_open+0x12b>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104704:	83 ec 0c             	sub    $0xc,%esp
80104707:	56                   	push   %esi
80104708:	e8 d0 ce ff ff       	call   801015dd <iunlock>
  end_op();
8010470d:	e8 5d e0 ff ff       	call   8010276f <end_op>

  f->type = FD_INODE;
80104712:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104718:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
8010471b:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104722:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104725:	83 c4 10             	add    $0x10,%esp
80104728:	a8 01                	test   $0x1,%al
8010472a:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010472e:	a8 03                	test   $0x3,%al
80104730:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104734:	89 f8                	mov    %edi,%eax
80104736:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104739:	5b                   	pop    %ebx
8010473a:	5e                   	pop    %esi
8010473b:	5f                   	pop    %edi
8010473c:	5d                   	pop    %ebp
8010473d:	c3                   	ret    
    return -1;
8010473e:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104743:	eb ef                	jmp    80104734 <sys_open+0xb5>
      end_op();
80104745:	e8 25 e0 ff ff       	call   8010276f <end_op>
      return -1;
8010474a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010474f:	eb e3                	jmp    80104734 <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104751:	83 ec 0c             	sub    $0xc,%esp
80104754:	ff 75 e4             	push   -0x1c(%ebp)
80104757:	e8 25 d4 ff ff       	call   80101b81 <namei>
8010475c:	89 c6                	mov    %eax,%esi
8010475e:	83 c4 10             	add    $0x10,%esp
80104761:	85 c0                	test   %eax,%eax
80104763:	74 39                	je     8010479e <sys_open+0x11f>
    ilock(ip);
80104765:	83 ec 0c             	sub    $0xc,%esp
80104768:	50                   	push   %eax
80104769:	e8 af cd ff ff       	call   8010151d <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
8010476e:	83 c4 10             	add    $0x10,%esp
80104771:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104776:	0f 85 6a ff ff ff    	jne    801046e6 <sys_open+0x67>
8010477c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104780:	0f 84 60 ff ff ff    	je     801046e6 <sys_open+0x67>
      iunlockput(ip);
80104786:	83 ec 0c             	sub    $0xc,%esp
80104789:	56                   	push   %esi
8010478a:	e8 31 cf ff ff       	call   801016c0 <iunlockput>
      end_op();
8010478f:	e8 db df ff ff       	call   8010276f <end_op>
      return -1;
80104794:	83 c4 10             	add    $0x10,%esp
80104797:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010479c:	eb 96                	jmp    80104734 <sys_open+0xb5>
      end_op();
8010479e:	e8 cc df ff ff       	call   8010276f <end_op>
      return -1;
801047a3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801047a8:	eb 8a                	jmp    80104734 <sys_open+0xb5>
    if(f)
801047aa:	85 db                	test   %ebx,%ebx
801047ac:	74 0c                	je     801047ba <sys_open+0x13b>
      fileclose(f);
801047ae:	83 ec 0c             	sub    $0xc,%esp
801047b1:	53                   	push   %ebx
801047b2:	e8 ea c4 ff ff       	call   80100ca1 <fileclose>
801047b7:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801047ba:	83 ec 0c             	sub    $0xc,%esp
801047bd:	56                   	push   %esi
801047be:	e8 fd ce ff ff       	call   801016c0 <iunlockput>
    end_op();
801047c3:	e8 a7 df ff ff       	call   8010276f <end_op>
    return -1;
801047c8:	83 c4 10             	add    $0x10,%esp
801047cb:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801047d0:	e9 5f ff ff ff       	jmp    80104734 <sys_open+0xb5>

801047d5 <sys_mkdir>:

int
sys_mkdir(void)
{
801047d5:	55                   	push   %ebp
801047d6:	89 e5                	mov    %esp,%ebp
801047d8:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801047db:	e8 13 df ff ff       	call   801026f3 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801047e0:	83 ec 08             	sub    $0x8,%esp
801047e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801047e6:	50                   	push   %eax
801047e7:	6a 00                	push   $0x0
801047e9:	e8 7f f6 ff ff       	call   80103e6d <argstr>
801047ee:	83 c4 10             	add    $0x10,%esp
801047f1:	85 c0                	test   %eax,%eax
801047f3:	78 36                	js     8010482b <sys_mkdir+0x56>
801047f5:	83 ec 0c             	sub    $0xc,%esp
801047f8:	6a 00                	push   $0x0
801047fa:	b9 00 00 00 00       	mov    $0x0,%ecx
801047ff:	ba 01 00 00 00       	mov    $0x1,%edx
80104804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104807:	e8 d6 f7 ff ff       	call   80103fe2 <create>
8010480c:	83 c4 10             	add    $0x10,%esp
8010480f:	85 c0                	test   %eax,%eax
80104811:	74 18                	je     8010482b <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104813:	83 ec 0c             	sub    $0xc,%esp
80104816:	50                   	push   %eax
80104817:	e8 a4 ce ff ff       	call   801016c0 <iunlockput>
  end_op();
8010481c:	e8 4e df ff ff       	call   8010276f <end_op>
  return 0;
80104821:	83 c4 10             	add    $0x10,%esp
80104824:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104829:	c9                   	leave  
8010482a:	c3                   	ret    
    end_op();
8010482b:	e8 3f df ff ff       	call   8010276f <end_op>
    return -1;
80104830:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104835:	eb f2                	jmp    80104829 <sys_mkdir+0x54>

80104837 <sys_mknod>:

int
sys_mknod(void)
{
80104837:	55                   	push   %ebp
80104838:	89 e5                	mov    %esp,%ebp
8010483a:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010483d:	e8 b1 de ff ff       	call   801026f3 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104842:	83 ec 08             	sub    $0x8,%esp
80104845:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104848:	50                   	push   %eax
80104849:	6a 00                	push   $0x0
8010484b:	e8 1d f6 ff ff       	call   80103e6d <argstr>
80104850:	83 c4 10             	add    $0x10,%esp
80104853:	85 c0                	test   %eax,%eax
80104855:	78 62                	js     801048b9 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104857:	83 ec 08             	sub    $0x8,%esp
8010485a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010485d:	50                   	push   %eax
8010485e:	6a 01                	push   $0x1
80104860:	e8 77 f5 ff ff       	call   80103ddc <argint>
  if((argstr(0, &path)) < 0 ||
80104865:	83 c4 10             	add    $0x10,%esp
80104868:	85 c0                	test   %eax,%eax
8010486a:	78 4d                	js     801048b9 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
8010486c:	83 ec 08             	sub    $0x8,%esp
8010486f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104872:	50                   	push   %eax
80104873:	6a 02                	push   $0x2
80104875:	e8 62 f5 ff ff       	call   80103ddc <argint>
     argint(1, &major) < 0 ||
8010487a:	83 c4 10             	add    $0x10,%esp
8010487d:	85 c0                	test   %eax,%eax
8010487f:	78 38                	js     801048b9 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104881:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80104885:	83 ec 0c             	sub    $0xc,%esp
80104888:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
8010488c:	50                   	push   %eax
8010488d:	ba 03 00 00 00       	mov    $0x3,%edx
80104892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104895:	e8 48 f7 ff ff       	call   80103fe2 <create>
     argint(2, &minor) < 0 ||
8010489a:	83 c4 10             	add    $0x10,%esp
8010489d:	85 c0                	test   %eax,%eax
8010489f:	74 18                	je     801048b9 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
801048a1:	83 ec 0c             	sub    $0xc,%esp
801048a4:	50                   	push   %eax
801048a5:	e8 16 ce ff ff       	call   801016c0 <iunlockput>
  end_op();
801048aa:	e8 c0 de ff ff       	call   8010276f <end_op>
  return 0;
801048af:	83 c4 10             	add    $0x10,%esp
801048b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048b7:	c9                   	leave  
801048b8:	c3                   	ret    
    end_op();
801048b9:	e8 b1 de ff ff       	call   8010276f <end_op>
    return -1;
801048be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048c3:	eb f2                	jmp    801048b7 <sys_mknod+0x80>

801048c5 <sys_chdir>:

int
sys_chdir(void)
{
801048c5:	55                   	push   %ebp
801048c6:	89 e5                	mov    %esp,%ebp
801048c8:	56                   	push   %esi
801048c9:	53                   	push   %ebx
801048ca:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801048cd:	e8 64 e8 ff ff       	call   80103136 <myproc>
801048d2:	89 c6                	mov    %eax,%esi
  
  begin_op();
801048d4:	e8 1a de ff ff       	call   801026f3 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801048d9:	83 ec 08             	sub    $0x8,%esp
801048dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801048df:	50                   	push   %eax
801048e0:	6a 00                	push   $0x0
801048e2:	e8 86 f5 ff ff       	call   80103e6d <argstr>
801048e7:	83 c4 10             	add    $0x10,%esp
801048ea:	85 c0                	test   %eax,%eax
801048ec:	78 52                	js     80104940 <sys_chdir+0x7b>
801048ee:	83 ec 0c             	sub    $0xc,%esp
801048f1:	ff 75 f4             	push   -0xc(%ebp)
801048f4:	e8 88 d2 ff ff       	call   80101b81 <namei>
801048f9:	89 c3                	mov    %eax,%ebx
801048fb:	83 c4 10             	add    $0x10,%esp
801048fe:	85 c0                	test   %eax,%eax
80104900:	74 3e                	je     80104940 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104902:	83 ec 0c             	sub    $0xc,%esp
80104905:	50                   	push   %eax
80104906:	e8 12 cc ff ff       	call   8010151d <ilock>
  if(ip->type != T_DIR){
8010490b:	83 c4 10             	add    $0x10,%esp
8010490e:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104913:	75 37                	jne    8010494c <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104915:	83 ec 0c             	sub    $0xc,%esp
80104918:	53                   	push   %ebx
80104919:	e8 bf cc ff ff       	call   801015dd <iunlock>
  iput(curproc->cwd);
8010491e:	83 c4 04             	add    $0x4,%esp
80104921:	ff 76 70             	push   0x70(%esi)
80104924:	e8 f9 cc ff ff       	call   80101622 <iput>
  end_op();
80104929:	e8 41 de ff ff       	call   8010276f <end_op>
  curproc->cwd = ip;
8010492e:	89 5e 70             	mov    %ebx,0x70(%esi)
  return 0;
80104931:	83 c4 10             	add    $0x10,%esp
80104934:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104939:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010493c:	5b                   	pop    %ebx
8010493d:	5e                   	pop    %esi
8010493e:	5d                   	pop    %ebp
8010493f:	c3                   	ret    
    end_op();
80104940:	e8 2a de ff ff       	call   8010276f <end_op>
    return -1;
80104945:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010494a:	eb ed                	jmp    80104939 <sys_chdir+0x74>
    iunlockput(ip);
8010494c:	83 ec 0c             	sub    $0xc,%esp
8010494f:	53                   	push   %ebx
80104950:	e8 6b cd ff ff       	call   801016c0 <iunlockput>
    end_op();
80104955:	e8 15 de ff ff       	call   8010276f <end_op>
    return -1;
8010495a:	83 c4 10             	add    $0x10,%esp
8010495d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104962:	eb d5                	jmp    80104939 <sys_chdir+0x74>

80104964 <sys_exec>:

int
sys_exec(void)
{
80104964:	55                   	push   %ebp
80104965:	89 e5                	mov    %esp,%ebp
80104967:	53                   	push   %ebx
80104968:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010496e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104971:	50                   	push   %eax
80104972:	6a 00                	push   $0x0
80104974:	e8 f4 f4 ff ff       	call   80103e6d <argstr>
80104979:	83 c4 10             	add    $0x10,%esp
8010497c:	85 c0                	test   %eax,%eax
8010497e:	78 38                	js     801049b8 <sys_exec+0x54>
80104980:	83 ec 08             	sub    $0x8,%esp
80104983:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104989:	50                   	push   %eax
8010498a:	6a 01                	push   $0x1
8010498c:	e8 4b f4 ff ff       	call   80103ddc <argint>
80104991:	83 c4 10             	add    $0x10,%esp
80104994:	85 c0                	test   %eax,%eax
80104996:	78 20                	js     801049b8 <sys_exec+0x54>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104998:	83 ec 04             	sub    $0x4,%esp
8010499b:	68 80 00 00 00       	push   $0x80
801049a0:	6a 00                	push   $0x0
801049a2:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
801049a8:	50                   	push   %eax
801049a9:	e8 f8 f1 ff ff       	call   80103ba6 <memset>
801049ae:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801049b1:	bb 00 00 00 00       	mov    $0x0,%ebx
801049b6:	eb 2a                	jmp    801049e2 <sys_exec+0x7e>
    return -1;
801049b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049bd:	eb 76                	jmp    80104a35 <sys_exec+0xd1>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
801049bf:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
801049c6:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801049ca:	83 ec 08             	sub    $0x8,%esp
801049cd:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
801049d3:	50                   	push   %eax
801049d4:	ff 75 f4             	push   -0xc(%ebp)
801049d7:	e8 b4 be ff ff       	call   80100890 <exec>
801049dc:	83 c4 10             	add    $0x10,%esp
801049df:	eb 54                	jmp    80104a35 <sys_exec+0xd1>
  for(i=0;; i++){
801049e1:	43                   	inc    %ebx
    if(i >= NELEM(argv))
801049e2:	83 fb 1f             	cmp    $0x1f,%ebx
801049e5:	77 49                	ja     80104a30 <sys_exec+0xcc>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801049e7:	83 ec 08             	sub    $0x8,%esp
801049ea:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801049f0:	50                   	push   %eax
801049f1:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
801049f7:	8d 04 98             	lea    (%eax,%ebx,4),%eax
801049fa:	50                   	push   %eax
801049fb:	e8 61 f3 ff ff       	call   80103d61 <fetchint>
80104a00:	83 c4 10             	add    $0x10,%esp
80104a03:	85 c0                	test   %eax,%eax
80104a05:	78 33                	js     80104a3a <sys_exec+0xd6>
    if(uarg == 0){
80104a07:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104a0d:	85 c0                	test   %eax,%eax
80104a0f:	74 ae                	je     801049bf <sys_exec+0x5b>
    if(fetchstr(uarg, &argv[i]) < 0)
80104a11:	83 ec 08             	sub    $0x8,%esp
80104a14:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104a1b:	52                   	push   %edx
80104a1c:	50                   	push   %eax
80104a1d:	e8 7b f3 ff ff       	call   80103d9d <fetchstr>
80104a22:	83 c4 10             	add    $0x10,%esp
80104a25:	85 c0                	test   %eax,%eax
80104a27:	79 b8                	jns    801049e1 <sys_exec+0x7d>
      return -1;
80104a29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a2e:	eb 05                	jmp    80104a35 <sys_exec+0xd1>
      return -1;
80104a30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104a35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a38:	c9                   	leave  
80104a39:	c3                   	ret    
      return -1;
80104a3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a3f:	eb f4                	jmp    80104a35 <sys_exec+0xd1>

80104a41 <sys_pipe>:

int
sys_pipe(void)
{
80104a41:	55                   	push   %ebp
80104a42:	89 e5                	mov    %esp,%ebp
80104a44:	53                   	push   %ebx
80104a45:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104a48:	6a 08                	push   $0x8
80104a4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a4d:	50                   	push   %eax
80104a4e:	6a 00                	push   $0x0
80104a50:	e8 af f3 ff ff       	call   80103e04 <argptr>
80104a55:	83 c4 10             	add    $0x10,%esp
80104a58:	85 c0                	test   %eax,%eax
80104a5a:	78 79                	js     80104ad5 <sys_pipe+0x94>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104a5c:	83 ec 08             	sub    $0x8,%esp
80104a5f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104a62:	50                   	push   %eax
80104a63:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104a66:	50                   	push   %eax
80104a67:	e8 fe e1 ff ff       	call   80102c6a <pipealloc>
80104a6c:	83 c4 10             	add    $0x10,%esp
80104a6f:	85 c0                	test   %eax,%eax
80104a71:	78 69                	js     80104adc <sys_pipe+0x9b>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a76:	e8 dc f4 ff ff       	call   80103f57 <fdalloc>
80104a7b:	89 c3                	mov    %eax,%ebx
80104a7d:	85 c0                	test   %eax,%eax
80104a7f:	78 21                	js     80104aa2 <sys_pipe+0x61>
80104a81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a84:	e8 ce f4 ff ff       	call   80103f57 <fdalloc>
80104a89:	85 c0                	test   %eax,%eax
80104a8b:	78 15                	js     80104aa2 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104a8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a90:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104a92:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a95:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104a98:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104aa0:	c9                   	leave  
80104aa1:	c3                   	ret    
    if(fd0 >= 0)
80104aa2:	85 db                	test   %ebx,%ebx
80104aa4:	79 20                	jns    80104ac6 <sys_pipe+0x85>
    fileclose(rf);
80104aa6:	83 ec 0c             	sub    $0xc,%esp
80104aa9:	ff 75 f0             	push   -0x10(%ebp)
80104aac:	e8 f0 c1 ff ff       	call   80100ca1 <fileclose>
    fileclose(wf);
80104ab1:	83 c4 04             	add    $0x4,%esp
80104ab4:	ff 75 ec             	push   -0x14(%ebp)
80104ab7:	e8 e5 c1 ff ff       	call   80100ca1 <fileclose>
    return -1;
80104abc:	83 c4 10             	add    $0x10,%esp
80104abf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ac4:	eb d7                	jmp    80104a9d <sys_pipe+0x5c>
      myproc()->ofile[fd0] = 0;
80104ac6:	e8 6b e6 ff ff       	call   80103136 <myproc>
80104acb:	c7 44 98 30 00 00 00 	movl   $0x0,0x30(%eax,%ebx,4)
80104ad2:	00 
80104ad3:	eb d1                	jmp    80104aa6 <sys_pipe+0x65>
    return -1;
80104ad5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ada:	eb c1                	jmp    80104a9d <sys_pipe+0x5c>
    return -1;
80104adc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ae1:	eb ba                	jmp    80104a9d <sys_pipe+0x5c>

80104ae3 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104ae3:	55                   	push   %ebp
80104ae4:	89 e5                	mov    %esp,%ebp
80104ae6:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104ae9:	e8 be e7 ff ff       	call   801032ac <fork>
}
80104aee:	c9                   	leave  
80104aef:	c3                   	ret    

80104af0 <sys_exit>:
	Implementación del código de llamada al sistema para cuando un usuario
	realiza un exit(status)
*/
int
sys_exit(void)
{
80104af0:	55                   	push   %ebp
80104af1:	89 e5                	mov    %esp,%ebp
80104af3:	83 ec 20             	sub    $0x20,%esp
	//Para esta nueva implementación, vamos a recuperar el status
	//que puso el usuario como argumento y lo guardamos 
  int status; 

	//Puesto que es un valor entero, lo recuperamos de la pila (posición 0) con argint
  if(argint(0,&status) < 0)
80104af6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104af9:	50                   	push   %eax
80104afa:	6a 00                	push   $0x0
80104afc:	e8 db f2 ff ff       	call   80103ddc <argint>
80104b01:	83 c4 10             	add    $0x10,%esp
80104b04:	85 c0                	test   %eax,%eax
80104b06:	78 1c                	js     80104b24 <sys_exit+0x34>
    return -1;

	//Desplazamos los  bits 8 posiciones a la izquierda
	status = status << 8;
80104b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0b:	c1 e0 08             	shl    $0x8,%eax
80104b0e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  exit(status);//Llamamos a la función de salida del kernel
80104b11:	83 ec 0c             	sub    $0xc,%esp
80104b14:	50                   	push   %eax
80104b15:	e8 ca e9 ff ff       	call   801034e4 <exit>
  return 0;  // not reached
80104b1a:	83 c4 10             	add    $0x10,%esp
80104b1d:	b8 00 00 00 00       	mov    $0x0,%eax

}
80104b22:	c9                   	leave  
80104b23:	c3                   	ret    
    return -1;
80104b24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b29:	eb f7                	jmp    80104b22 <sys_exit+0x32>

80104b2b <sys_wait>:
/*
	Implementación de la función wait(status) para un usuario
*/
int
sys_wait(void)
{
80104b2b:	55                   	push   %ebp
80104b2c:	89 e5                	mov    %esp,%ebp
80104b2e:	83 ec 1c             	sub    $0x1c,%esp
	*/
  int *status;
  int size = 4;//Tamaño de un entero
    
  //Recuperamos el valor con argptr puesto que no es un entero, sino un puntero a entero
	if(argptr(0,(void**) &status, size) < 0)
80104b31:	6a 04                	push   $0x4
80104b33:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b36:	50                   	push   %eax
80104b37:	6a 00                	push   $0x0
80104b39:	e8 c6 f2 ff ff       	call   80103e04 <argptr>
80104b3e:	83 c4 10             	add    $0x10,%esp
80104b41:	85 c0                	test   %eax,%eax
80104b43:	78 10                	js     80104b55 <sys_wait+0x2a>
    return -1;
  
	//Por último, llamamos a la función wait del kernel
  return wait(status);
80104b45:	83 ec 0c             	sub    $0xc,%esp
80104b48:	ff 75 f4             	push   -0xc(%ebp)
80104b4b:	e8 35 eb ff ff       	call   80103685 <wait>
80104b50:	83 c4 10             	add    $0x10,%esp
}
80104b53:	c9                   	leave  
80104b54:	c3                   	ret    
    return -1;
80104b55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b5a:	eb f7                	jmp    80104b53 <sys_wait+0x28>

80104b5c <sys_kill>:

int
sys_kill(void)
{
80104b5c:	55                   	push   %ebp
80104b5d:	89 e5                	mov    %esp,%ebp
80104b5f:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104b62:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b65:	50                   	push   %eax
80104b66:	6a 00                	push   $0x0
80104b68:	e8 6f f2 ff ff       	call   80103ddc <argint>
80104b6d:	83 c4 10             	add    $0x10,%esp
80104b70:	85 c0                	test   %eax,%eax
80104b72:	78 10                	js     80104b84 <sys_kill+0x28>
    return -1;
  return kill(pid);
80104b74:	83 ec 0c             	sub    $0xc,%esp
80104b77:	ff 75 f4             	push   -0xc(%ebp)
80104b7a:	e8 10 ec ff ff       	call   8010378f <kill>
80104b7f:	83 c4 10             	add    $0x10,%esp
}
80104b82:	c9                   	leave  
80104b83:	c3                   	ret    
    return -1;
80104b84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b89:	eb f7                	jmp    80104b82 <sys_kill+0x26>

80104b8b <sys_getpid>:

int
sys_getpid(void)
{
80104b8b:	55                   	push   %ebp
80104b8c:	89 e5                	mov    %esp,%ebp
80104b8e:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104b91:	e8 a0 e5 ff ff       	call   80103136 <myproc>
80104b96:	8b 40 18             	mov    0x18(%eax),%eax
}
80104b99:	c9                   	leave  
80104b9a:	c3                   	ret    

80104b9b <sys_sbrk>:

int
sys_sbrk(void)
{
80104b9b:	55                   	push   %ebp
80104b9c:	89 e5                	mov    %esp,%ebp
80104b9e:	56                   	push   %esi
80104b9f:	53                   	push   %ebx
80104ba0:	83 ec 10             	sub    $0x10,%esp
	//La dirección que devolvemos siempre será la del tamaño 
	//actual del proceso, que es por donde está el heap 
	//actualmente (dirección de comienzo de la memoria libre)
  int n;//Valor que quiere reservar el usuario
	uint oldsz = myproc()->sz;
80104ba3:	e8 8e e5 ff ff       	call   80103136 <myproc>
80104ba8:	8b 58 08             	mov    0x8(%eax),%ebx
	uint newsz = oldsz;

	//Recuperamos el valor de n de la pila de usuario
  if(argint(0, &n) < 0)
80104bab:	83 ec 08             	sub    $0x8,%esp
80104bae:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104bb1:	50                   	push   %eax
80104bb2:	6a 00                	push   $0x0
80104bb4:	e8 23 f2 ff ff       	call   80103ddc <argint>
80104bb9:	83 c4 10             	add    $0x10,%esp
80104bbc:	85 c0                	test   %eax,%eax
80104bbe:	78 55                	js     80104c15 <sys_sbrk+0x7a>
    return -1;

	//Hacemos comprobación para que solo reserve hasta el KERNBASE
	if(oldsz + n > KERNBASE)
80104bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc3:	8d 34 18             	lea    (%eax,%ebx,1),%esi
80104bc6:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
80104bcc:	77 4e                	ja     80104c1c <sys_sbrk+0x81>
		return -1;
	
	//Actualizamos el nuevo tamaño del proceso
	newsz = oldsz + n;
	
	if(n < 0)
80104bce:	85 c0                	test   %eax,%eax
80104bd0:	78 21                	js     80104bf3 <sys_sbrk+0x58>
	{//Desalojamos las páginas físicas ocupadas hasta ahora
		if((newsz = deallocuvm(myproc()->pgdir, oldsz, newsz)) == 0)
      return -1;
	}
  lcr3(V2P(myproc()->pgdir));  // Invalidate TLB. Cambia la tabla de páginas		
80104bd2:	e8 5f e5 ff ff       	call   80103136 <myproc>
80104bd7:	8b 40 0c             	mov    0xc(%eax),%eax
80104bda:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80104bdf:	0f 22 d8             	mov    %eax,%cr3

	//Ahora cambiamos el tamaño del proceso
	myproc()->sz = newsz;
80104be2:	e8 4f e5 ff ff       	call   80103136 <myproc>
80104be7:	89 70 08             	mov    %esi,0x8(%eax)
  
  return oldsz;
80104bea:	89 d8                	mov    %ebx,%eax
}
80104bec:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104bef:	5b                   	pop    %ebx
80104bf0:	5e                   	pop    %esi
80104bf1:	5d                   	pop    %ebp
80104bf2:	c3                   	ret    
		if((newsz = deallocuvm(myproc()->pgdir, oldsz, newsz)) == 0)
80104bf3:	e8 3e e5 ff ff       	call   80103136 <myproc>
80104bf8:	83 ec 04             	sub    $0x4,%esp
80104bfb:	56                   	push   %esi
80104bfc:	53                   	push   %ebx
80104bfd:	ff 70 0c             	push   0xc(%eax)
80104c00:	e8 11 18 00 00       	call   80106416 <deallocuvm>
80104c05:	89 c6                	mov    %eax,%esi
80104c07:	83 c4 10             	add    $0x10,%esp
80104c0a:	85 c0                	test   %eax,%eax
80104c0c:	75 c4                	jne    80104bd2 <sys_sbrk+0x37>
      return -1;
80104c0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c13:	eb d7                	jmp    80104bec <sys_sbrk+0x51>
    return -1;
80104c15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c1a:	eb d0                	jmp    80104bec <sys_sbrk+0x51>
		return -1;
80104c1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c21:	eb c9                	jmp    80104bec <sys_sbrk+0x51>

80104c23 <sys_sleep>:

int
sys_sleep(void)
{
80104c23:	55                   	push   %ebp
80104c24:	89 e5                	mov    %esp,%ebp
80104c26:	53                   	push   %ebx
80104c27:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104c2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c2d:	50                   	push   %eax
80104c2e:	6a 00                	push   $0x0
80104c30:	e8 a7 f1 ff ff       	call   80103ddc <argint>
80104c35:	83 c4 10             	add    $0x10,%esp
80104c38:	85 c0                	test   %eax,%eax
80104c3a:	78 75                	js     80104cb1 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104c3c:	83 ec 0c             	sub    $0xc,%esp
80104c3f:	68 80 3e 11 80       	push   $0x80113e80
80104c44:	e8 b1 ee ff ff       	call   80103afa <acquire>
  ticks0 = ticks;
80104c49:	8b 1d 60 3e 11 80    	mov    0x80113e60,%ebx
  while(ticks - ticks0 < n){
80104c4f:	83 c4 10             	add    $0x10,%esp
80104c52:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80104c57:	29 d8                	sub    %ebx,%eax
80104c59:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104c5c:	73 39                	jae    80104c97 <sys_sleep+0x74>
    if(myproc()->killed){
80104c5e:	e8 d3 e4 ff ff       	call   80103136 <myproc>
80104c63:	83 78 2c 00          	cmpl   $0x0,0x2c(%eax)
80104c67:	75 17                	jne    80104c80 <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104c69:	83 ec 08             	sub    $0x8,%esp
80104c6c:	68 80 3e 11 80       	push   $0x80113e80
80104c71:	68 60 3e 11 80       	push   $0x80113e60
80104c76:	e8 79 e9 ff ff       	call   801035f4 <sleep>
80104c7b:	83 c4 10             	add    $0x10,%esp
80104c7e:	eb d2                	jmp    80104c52 <sys_sleep+0x2f>
      release(&tickslock);
80104c80:	83 ec 0c             	sub    $0xc,%esp
80104c83:	68 80 3e 11 80       	push   $0x80113e80
80104c88:	e8 d2 ee ff ff       	call   80103b5f <release>
      return -1;
80104c8d:	83 c4 10             	add    $0x10,%esp
80104c90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c95:	eb 15                	jmp    80104cac <sys_sleep+0x89>
  }
  release(&tickslock);
80104c97:	83 ec 0c             	sub    $0xc,%esp
80104c9a:	68 80 3e 11 80       	push   $0x80113e80
80104c9f:	e8 bb ee ff ff       	call   80103b5f <release>
  return 0;
80104ca4:	83 c4 10             	add    $0x10,%esp
80104ca7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104cac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104caf:	c9                   	leave  
80104cb0:	c3                   	ret    
    return -1;
80104cb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cb6:	eb f4                	jmp    80104cac <sys_sleep+0x89>

80104cb8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104cb8:	55                   	push   %ebp
80104cb9:	89 e5                	mov    %esp,%ebp
80104cbb:	53                   	push   %ebx
80104cbc:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104cbf:	68 80 3e 11 80       	push   $0x80113e80
80104cc4:	e8 31 ee ff ff       	call   80103afa <acquire>
  xticks = ticks;
80104cc9:	8b 1d 60 3e 11 80    	mov    0x80113e60,%ebx
  release(&tickslock);
80104ccf:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
80104cd6:	e8 84 ee ff ff       	call   80103b5f <release>
  return xticks;
}
80104cdb:	89 d8                	mov    %ebx,%eax
80104cdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ce0:	c9                   	leave  
80104ce1:	c3                   	ret    

80104ce2 <sys_date>:

//Implementación de llamada al sistema date para sacar la fecha actual por pantalla
//Devuelve 0 en caso de acabar correctamente y -1 en caso de fallo
int
sys_date(void)
{
80104ce2:	55                   	push   %ebp
80104ce3:	89 e5                	mov    %esp,%ebp
80104ce5:	83 ec 1c             	sub    $0x1c,%esp
	//date tiene que recuperar el rtcdate de la pila del usuario
 	struct rtcdate *d;//Aquí vamos a guardar el argumento del usuario

 	//vamos a usar argptr para recuperar el rtcdate
 	if(argptr(0, (void **) &d, sizeof(struct rtcdate)) < 0){
80104ce8:	6a 18                	push   $0x18
80104cea:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ced:	50                   	push   %eax
80104cee:	6a 00                	push   $0x0
80104cf0:	e8 0f f1 ff ff       	call   80103e04 <argptr>
80104cf5:	83 c4 10             	add    $0x10,%esp
80104cf8:	85 c0                	test   %eax,%eax
80104cfa:	78 15                	js     80104d11 <sys_date+0x2f>
  	return -1;
 	}
 	//Ahora una vez recuperado el rtcdate solo tenemos que rellenarlo con los valores oportunos
	//Para ello usamos cmostime, que rellena los valores del rtcdate con la fecha actual 
 cmostime(d);
80104cfc:	83 ec 0c             	sub    $0xc,%esp
80104cff:	ff 75 f4             	push   -0xc(%ebp)
80104d02:	e8 be d6 ff ff       	call   801023c5 <cmostime>

 return 0;
80104d07:	83 c4 10             	add    $0x10,%esp
80104d0a:	b8 00 00 00 00       	mov    $0x0,%eax

}
80104d0f:	c9                   	leave  
80104d10:	c3                   	ret    
  	return -1;
80104d11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d16:	eb f7                	jmp    80104d0f <sys_date+0x2d>

80104d18 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104d18:	1e                   	push   %ds
  pushl %es
80104d19:	06                   	push   %es
  pushl %fs
80104d1a:	0f a0                	push   %fs
  pushl %gs
80104d1c:	0f a8                	push   %gs
  pushal
80104d1e:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104d1f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104d23:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104d25:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104d27:	54                   	push   %esp
  call trap
80104d28:	e8 47 01 00 00       	call   80104e74 <trap>
  addl $4, %esp
80104d2d:	83 c4 04             	add    $0x4,%esp

80104d30 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104d30:	61                   	popa   
  popl %gs
80104d31:	0f a9                	pop    %gs
  popl %fs
80104d33:	0f a1                	pop    %fs
  popl %es
80104d35:	07                   	pop    %es
  popl %ds
80104d36:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104d37:	83 c4 08             	add    $0x8,%esp
  iret
80104d3a:	cf                   	iret   

80104d3b <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104d3b:	55                   	push   %ebp
80104d3c:	89 e5                	mov    %esp,%ebp
80104d3e:	53                   	push   %ebx
80104d3f:	83 ec 04             	sub    $0x4,%esp
  int i;

  for(i = 0; i < 256; i++)
80104d42:	b8 00 00 00 00       	mov    $0x0,%eax
80104d47:	eb 72                	jmp    80104dbb <tvinit+0x80>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104d49:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80104d50:	66 89 0c c5 c0 3e 11 	mov    %cx,-0x7feec140(,%eax,8)
80104d57:	80 
80104d58:	66 c7 04 c5 c2 3e 11 	movw   $0x8,-0x7feec13e(,%eax,8)
80104d5f:	80 08 00 
80104d62:	8a 14 c5 c4 3e 11 80 	mov    -0x7feec13c(,%eax,8),%dl
80104d69:	83 e2 e0             	and    $0xffffffe0,%edx
80104d6c:	88 14 c5 c4 3e 11 80 	mov    %dl,-0x7feec13c(,%eax,8)
80104d73:	c6 04 c5 c4 3e 11 80 	movb   $0x0,-0x7feec13c(,%eax,8)
80104d7a:	00 
80104d7b:	8a 14 c5 c5 3e 11 80 	mov    -0x7feec13b(,%eax,8),%dl
80104d82:	83 e2 f0             	and    $0xfffffff0,%edx
80104d85:	83 ca 0e             	or     $0xe,%edx
80104d88:	88 14 c5 c5 3e 11 80 	mov    %dl,-0x7feec13b(,%eax,8)
80104d8f:	88 d3                	mov    %dl,%bl
80104d91:	83 e3 ef             	and    $0xffffffef,%ebx
80104d94:	88 1c c5 c5 3e 11 80 	mov    %bl,-0x7feec13b(,%eax,8)
80104d9b:	83 e2 8f             	and    $0xffffff8f,%edx
80104d9e:	88 14 c5 c5 3e 11 80 	mov    %dl,-0x7feec13b(,%eax,8)
80104da5:	83 ca 80             	or     $0xffffff80,%edx
80104da8:	88 14 c5 c5 3e 11 80 	mov    %dl,-0x7feec13b(,%eax,8)
80104daf:	c1 e9 10             	shr    $0x10,%ecx
80104db2:	66 89 0c c5 c6 3e 11 	mov    %cx,-0x7feec13a(,%eax,8)
80104db9:	80 
  for(i = 0; i < 256; i++)
80104dba:	40                   	inc    %eax
80104dbb:	3d ff 00 00 00       	cmp    $0xff,%eax
80104dc0:	7e 87                	jle    80104d49 <tvinit+0xe>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104dc2:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80104dc8:	66 89 15 c0 40 11 80 	mov    %dx,0x801140c0
80104dcf:	66 c7 05 c2 40 11 80 	movw   $0x8,0x801140c2
80104dd6:	08 00 
80104dd8:	a0 c4 40 11 80       	mov    0x801140c4,%al
80104ddd:	83 e0 e0             	and    $0xffffffe0,%eax
80104de0:	a2 c4 40 11 80       	mov    %al,0x801140c4
80104de5:	c6 05 c4 40 11 80 00 	movb   $0x0,0x801140c4
80104dec:	a0 c5 40 11 80       	mov    0x801140c5,%al
80104df1:	83 c8 0f             	or     $0xf,%eax
80104df4:	a2 c5 40 11 80       	mov    %al,0x801140c5
80104df9:	83 e0 ef             	and    $0xffffffef,%eax
80104dfc:	a2 c5 40 11 80       	mov    %al,0x801140c5
80104e01:	88 c1                	mov    %al,%cl
80104e03:	83 c9 60             	or     $0x60,%ecx
80104e06:	88 0d c5 40 11 80    	mov    %cl,0x801140c5
80104e0c:	83 c8 e0             	or     $0xffffffe0,%eax
80104e0f:	a2 c5 40 11 80       	mov    %al,0x801140c5
80104e14:	c1 ea 10             	shr    $0x10,%edx
80104e17:	66 89 15 c6 40 11 80 	mov    %dx,0x801140c6

  initlock(&tickslock, "time");
80104e1e:	83 ec 08             	sub    $0x8,%esp
80104e21:	68 c1 70 10 80       	push   $0x801070c1
80104e26:	68 80 3e 11 80       	push   $0x80113e80
80104e2b:	e8 93 eb ff ff       	call   801039c3 <initlock>
}
80104e30:	83 c4 10             	add    $0x10,%esp
80104e33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e36:	c9                   	leave  
80104e37:	c3                   	ret    

80104e38 <idtinit>:

void
idtinit(void)
{
80104e38:	55                   	push   %ebp
80104e39:	89 e5                	mov    %esp,%ebp
80104e3b:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104e3e:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104e44:	b8 c0 3e 11 80       	mov    $0x80113ec0,%eax
80104e49:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104e4d:	c1 e8 10             	shr    $0x10,%eax
80104e50:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104e54:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104e57:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104e5a:	c9                   	leave  
80104e5b:	c3                   	ret    

80104e5c <print_error>:


void
print_error(int code)
{
80104e5c:	55                   	push   %ebp
80104e5d:	89 e5                	mov    %esp,%ebp
80104e5f:	83 ec 10             	sub    $0x10,%esp
	cprintf("\nPage Fault, Error %d\n",code);
80104e62:	ff 75 08             	push   0x8(%ebp)
80104e65:	68 c6 70 10 80       	push   $0x801070c6
80104e6a:	e8 6b b7 ff ff       	call   801005da <cprintf>
}
80104e6f:	83 c4 10             	add    $0x10,%esp
80104e72:	c9                   	leave  
80104e73:	c3                   	ret    

80104e74 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80104e74:	55                   	push   %ebp
80104e75:	89 e5                	mov    %esp,%ebp
80104e77:	57                   	push   %edi
80104e78:	56                   	push   %esi
80104e79:	53                   	push   %ebx
80104e7a:	83 ec 2c             	sub    $0x2c,%esp
80104e7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//Declaramos la variable status, que toma el valor del número de trap
	int status = tf->trapno+1;	
80104e80:	8b 43 30             	mov    0x30(%ebx),%eax
80104e83:	8d 78 01             	lea    0x1(%eax),%edi

  if(tf->trapno == T_SYSCALL){
80104e86:	83 f8 40             	cmp    $0x40,%eax
80104e89:	74 13                	je     80104e9e <trap+0x2a>
    if(myproc()->killed)
      exit(status);
    return;
  }

  switch(tf->trapno){
80104e8b:	83 e8 0e             	sub    $0xe,%eax
80104e8e:	83 f8 31             	cmp    $0x31,%eax
80104e91:	0f 87 dd 02 00 00    	ja     80105174 <trap+0x300>
80104e97:	ff 24 85 f4 71 10 80 	jmp    *-0x7fef8e0c(,%eax,4)
    if(myproc()->killed)
80104e9e:	e8 93 e2 ff ff       	call   80103136 <myproc>
80104ea3:	83 78 2c 00          	cmpl   $0x0,0x2c(%eax)
80104ea7:	75 2a                	jne    80104ed3 <trap+0x5f>
    myproc()->tf = tf;
80104ea9:	e8 88 e2 ff ff       	call   80103136 <myproc>
80104eae:	89 58 20             	mov    %ebx,0x20(%eax)
    syscall();
80104eb1:	e8 ea ef ff ff       	call   80103ea0 <syscall>
    if(myproc()->killed)
80104eb6:	e8 7b e2 ff ff       	call   80103136 <myproc>
80104ebb:	83 78 2c 00          	cmpl   $0x0,0x2c(%eax)
80104ebf:	0f 84 8a 00 00 00    	je     80104f4f <trap+0xdb>
      exit(status);
80104ec5:	83 ec 0c             	sub    $0xc,%esp
80104ec8:	57                   	push   %edi
80104ec9:	e8 16 e6 ff ff       	call   801034e4 <exit>
80104ece:	83 c4 10             	add    $0x10,%esp
    return;
80104ed1:	eb 7c                	jmp    80104f4f <trap+0xdb>
      exit(status);
80104ed3:	83 ec 0c             	sub    $0xc,%esp
80104ed6:	57                   	push   %edi
80104ed7:	e8 08 e6 ff ff       	call   801034e4 <exit>
80104edc:	83 c4 10             	add    $0x10,%esp
80104edf:	eb c8                	jmp    80104ea9 <trap+0x35>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80104ee1:	e8 1f e2 ff ff       	call   80103105 <cpuid>
80104ee6:	85 c0                	test   %eax,%eax
80104ee8:	74 6d                	je     80104f57 <trap+0xe3>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80104eea:	e8 21 d4 ff ff       	call   80102310 <lapiceoi>
  }//fin switch

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104eef:	e8 42 e2 ff ff       	call   80103136 <myproc>
80104ef4:	85 c0                	test   %eax,%eax
80104ef6:	74 1b                	je     80104f13 <trap+0x9f>
80104ef8:	e8 39 e2 ff ff       	call   80103136 <myproc>
80104efd:	83 78 2c 00          	cmpl   $0x0,0x2c(%eax)
80104f01:	74 10                	je     80104f13 <trap+0x9f>
80104f03:	8b 43 3c             	mov    0x3c(%ebx),%eax
80104f06:	83 e0 03             	and    $0x3,%eax
80104f09:	66 83 f8 03          	cmp    $0x3,%ax
80104f0d:	0f 84 f9 02 00 00    	je     8010520c <trap+0x398>
    exit(status);

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80104f13:	e8 1e e2 ff ff       	call   80103136 <myproc>
80104f18:	85 c0                	test   %eax,%eax
80104f1a:	74 0f                	je     80104f2b <trap+0xb7>
80104f1c:	e8 15 e2 ff ff       	call   80103136 <myproc>
80104f21:	83 78 14 04          	cmpl   $0x4,0x14(%eax)
80104f25:	0f 84 f2 02 00 00    	je     8010521d <trap+0x3a9>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104f2b:	e8 06 e2 ff ff       	call   80103136 <myproc>
80104f30:	85 c0                	test   %eax,%eax
80104f32:	74 1b                	je     80104f4f <trap+0xdb>
80104f34:	e8 fd e1 ff ff       	call   80103136 <myproc>
80104f39:	83 78 2c 00          	cmpl   $0x0,0x2c(%eax)
80104f3d:	74 10                	je     80104f4f <trap+0xdb>
80104f3f:	8b 43 3c             	mov    0x3c(%ebx),%eax
80104f42:	83 e0 03             	and    $0x3,%eax
80104f45:	66 83 f8 03          	cmp    $0x3,%ax
80104f49:	0f 84 e2 02 00 00    	je     80105231 <trap+0x3bd>
    exit(status);
}
80104f4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104f52:	5b                   	pop    %ebx
80104f53:	5e                   	pop    %esi
80104f54:	5f                   	pop    %edi
80104f55:	5d                   	pop    %ebp
80104f56:	c3                   	ret    
      acquire(&tickslock);
80104f57:	83 ec 0c             	sub    $0xc,%esp
80104f5a:	68 80 3e 11 80       	push   $0x80113e80
80104f5f:	e8 96 eb ff ff       	call   80103afa <acquire>
      ticks++;
80104f64:	ff 05 60 3e 11 80    	incl   0x80113e60
      wakeup(&ticks);
80104f6a:	c7 04 24 60 3e 11 80 	movl   $0x80113e60,(%esp)
80104f71:	e8 f0 e7 ff ff       	call   80103766 <wakeup>
      release(&tickslock);
80104f76:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
80104f7d:	e8 dd eb ff ff       	call   80103b5f <release>
80104f82:	83 c4 10             	add    $0x10,%esp
80104f85:	e9 60 ff ff ff       	jmp    80104eea <trap+0x76>
    ideintr();
80104f8a:	e8 6a cd ff ff       	call   80101cf9 <ideintr>
    lapiceoi();
80104f8f:	e8 7c d3 ff ff       	call   80102310 <lapiceoi>
    break;
80104f94:	e9 56 ff ff ff       	jmp    80104eef <trap+0x7b>
    kbdintr();
80104f99:	e8 bc d1 ff ff       	call   8010215a <kbdintr>
    lapiceoi();
80104f9e:	e8 6d d3 ff ff       	call   80102310 <lapiceoi>
    break;
80104fa3:	e9 47 ff ff ff       	jmp    80104eef <trap+0x7b>
    uartintr();
80104fa8:	e8 91 03 00 00       	call   8010533e <uartintr>
    lapiceoi();
80104fad:	e8 5e d3 ff ff       	call   80102310 <lapiceoi>
    break;
80104fb2:	e9 38 ff ff ff       	jmp    80104eef <trap+0x7b>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80104fb7:	8b 43 38             	mov    0x38(%ebx),%eax
80104fba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            cpuid(), tf->cs, tf->eip);
80104fbd:	8b 73 3c             	mov    0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80104fc0:	e8 40 e1 ff ff       	call   80103105 <cpuid>
80104fc5:	ff 75 e4             	push   -0x1c(%ebp)
80104fc8:	0f b7 f6             	movzwl %si,%esi
80104fcb:	56                   	push   %esi
80104fcc:	50                   	push   %eax
80104fcd:	68 58 71 10 80       	push   $0x80107158
80104fd2:	e8 03 b6 ff ff       	call   801005da <cprintf>
    lapiceoi();
80104fd7:	e8 34 d3 ff ff       	call   80102310 <lapiceoi>
    break;
80104fdc:	83 c4 10             	add    $0x10,%esp
80104fdf:	e9 0b ff ff ff       	jmp    80104eef <trap+0x7b>
  asm volatile("movl %%cr2,%0" : "=r" (val));
80104fe4:	0f 20 d6             	mov    %cr2,%esi
		uint error_code =	page_fault_error(myproc()->pgdir, rcr2());
80104fe7:	e8 4a e1 ff ff       	call   80103136 <myproc>
80104fec:	83 ec 08             	sub    $0x8,%esp
80104fef:	56                   	push   %esi
80104ff0:	ff 70 0c             	push   0xc(%eax)
80104ff3:	e8 0e 11 00 00       	call   80106106 <page_fault_error>
80104ff8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80104ffb:	0f 20 d6             	mov    %cr2,%esi
		if(rcr2() > myproc()->sz){
80104ffe:	e8 33 e1 ff ff       	call   80103136 <myproc>
80105003:	83 c4 10             	add    $0x10,%esp
80105006:	39 70 08             	cmp    %esi,0x8(%eax)
80105009:	73 3c                	jae    80105047 <trap+0x1d3>
			cprintf("fuera de sz\n");
8010500b:	83 ec 0c             	sub    $0xc,%esp
8010500e:	68 dd 70 10 80       	push   $0x801070dd
80105013:	e8 c2 b5 ff ff       	call   801005da <cprintf>
			cprintf("tf->err=%d\n", tf->err);
80105018:	83 c4 08             	add    $0x8,%esp
8010501b:	ff 73 34             	push   0x34(%ebx)
8010501e:	68 ea 70 10 80       	push   $0x801070ea
80105023:	e8 b2 b5 ff ff       	call   801005da <cprintf>
			print_error(error_code);
80105028:	83 c4 04             	add    $0x4,%esp
8010502b:	ff 75 e4             	push   -0x1c(%ebp)
8010502e:	e8 29 fe ff ff       	call   80104e5c <print_error>
			myproc()->killed = 1;
80105033:	e8 fe e0 ff ff       	call   80103136 <myproc>
80105038:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
			break;
8010503f:	83 c4 10             	add    $0x10,%esp
80105042:	e9 a8 fe ff ff       	jmp    80104eef <trap+0x7b>
80105047:	0f 20 d6             	mov    %cr2,%esi
		if(rcr2() < myproc()->stack_end){
8010504a:	e8 e7 e0 ff ff       	call   80103136 <myproc>
8010504f:	39 30                	cmp    %esi,(%eax)
80105051:	0f 87 84 00 00 00    	ja     801050db <trap+0x267>
80105057:	0f 20 d0             	mov    %cr2,%eax
		if(rcr2() >= KERNBASE){
8010505a:	85 c0                	test   %eax,%eax
8010505c:	0f 88 b5 00 00 00    	js     80105117 <trap+0x2a3>
		char *mem = kalloc();
80105062:	e8 d7 cf ff ff       	call   8010203e <kalloc>
80105067:	89 c6                	mov    %eax,%esi
    if(mem == 0)
80105069:	85 c0                	test   %eax,%eax
8010506b:	0f 84 e2 00 00 00    	je     80105153 <trap+0x2df>
		memset(mem, 0, PGSIZE);
80105071:	83 ec 04             	sub    $0x4,%esp
80105074:	68 00 10 00 00       	push   $0x1000
80105079:	6a 00                	push   $0x0
8010507b:	50                   	push   %eax
8010507c:	e8 25 eb ff ff       	call   80103ba6 <memset>
80105081:	0f 20 d0             	mov    %cr2,%eax
    if(mappages(myproc()->pgdir, (char *)PGROUNDDOWN(rcr2()), PGSIZE, V2P(mem), PTE_W | PTE_U) <0)
80105084:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80105089:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010508c:	e8 a5 e0 ff ff       	call   80103136 <myproc>
80105091:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
80105098:	81 c6 00 00 00 80    	add    $0x80000000,%esi
8010509e:	56                   	push   %esi
8010509f:	68 00 10 00 00       	push   $0x1000
801050a4:	ff 75 e4             	push   -0x1c(%ebp)
801050a7:	ff 70 0c             	push   0xc(%eax)
801050aa:	e8 85 10 00 00       	call   80106134 <mappages>
801050af:	83 c4 20             	add    $0x20,%esp
801050b2:	85 c0                	test   %eax,%eax
801050b4:	0f 89 35 fe ff ff    	jns    80104eef <trap+0x7b>
      cprintf("mappages: out of memory\n");
801050ba:	83 ec 0c             	sub    $0xc,%esp
801050bd:	68 37 71 10 80       	push   $0x80107137
801050c2:	e8 13 b5 ff ff       	call   801005da <cprintf>
      myproc()->killed = 1;
801050c7:	e8 6a e0 ff ff       	call   80103136 <myproc>
801050cc:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
      break;
801050d3:	83 c4 10             	add    $0x10,%esp
801050d6:	e9 14 fe ff ff       	jmp    80104eef <trap+0x7b>
			cprintf("debajo de la pila:\n");
801050db:	83 ec 0c             	sub    $0xc,%esp
801050de:	68 f6 70 10 80       	push   $0x801070f6
801050e3:	e8 f2 b4 ff ff       	call   801005da <cprintf>
			cprintf("tf->err=%d\n", tf->err);
801050e8:	83 c4 08             	add    $0x8,%esp
801050eb:	ff 73 34             	push   0x34(%ebx)
801050ee:	68 ea 70 10 80       	push   $0x801070ea
801050f3:	e8 e2 b4 ff ff       	call   801005da <cprintf>
			print_error(error_code);
801050f8:	83 c4 04             	add    $0x4,%esp
801050fb:	ff 75 e4             	push   -0x1c(%ebp)
801050fe:	e8 59 fd ff ff       	call   80104e5c <print_error>
			myproc()->killed = 1;
80105103:	e8 2e e0 ff ff       	call   80103136 <myproc>
80105108:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
			break;
8010510f:	83 c4 10             	add    $0x10,%esp
80105112:	e9 d8 fd ff ff       	jmp    80104eef <trap+0x7b>
			cprintf("kernbase superado\n");
80105117:	83 ec 0c             	sub    $0xc,%esp
8010511a:	68 0a 71 10 80       	push   $0x8010710a
8010511f:	e8 b6 b4 ff ff       	call   801005da <cprintf>
			cprintf("tf->err=%d\n", tf->err);
80105124:	83 c4 08             	add    $0x8,%esp
80105127:	ff 73 34             	push   0x34(%ebx)
8010512a:	68 ea 70 10 80       	push   $0x801070ea
8010512f:	e8 a6 b4 ff ff       	call   801005da <cprintf>
			print_error(error_code);
80105134:	83 c4 04             	add    $0x4,%esp
80105137:	ff 75 e4             	push   -0x1c(%ebp)
8010513a:	e8 1d fd ff ff       	call   80104e5c <print_error>
			myproc()->killed = 1;
8010513f:	e8 f2 df ff ff       	call   80103136 <myproc>
80105144:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
			break;
8010514b:	83 c4 10             	add    $0x10,%esp
8010514e:	e9 9c fd ff ff       	jmp    80104eef <trap+0x7b>
      cprintf("kalloc didn't alloc page\n");
80105153:	83 ec 0c             	sub    $0xc,%esp
80105156:	68 1d 71 10 80       	push   $0x8010711d
8010515b:	e8 7a b4 ff ff       	call   801005da <cprintf>
      myproc()->killed = 1;
80105160:	e8 d1 df ff ff       	call   80103136 <myproc>
80105165:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
      break;
8010516c:	83 c4 10             	add    $0x10,%esp
8010516f:	e9 7b fd ff ff       	jmp    80104eef <trap+0x7b>
    if(myproc() == 0 || (tf->cs&3) == 0){
80105174:	e8 bd df ff ff       	call   80103136 <myproc>
80105179:	85 c0                	test   %eax,%eax
8010517b:	74 64                	je     801051e1 <trap+0x36d>
8010517d:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105181:	74 5e                	je     801051e1 <trap+0x36d>
80105183:	0f 20 d0             	mov    %cr2,%eax
80105186:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105189:	8b 53 38             	mov    0x38(%ebx),%edx
8010518c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010518f:	e8 71 df ff ff       	call   80103105 <cpuid>
80105194:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105197:	8b 4b 34             	mov    0x34(%ebx),%ecx
8010519a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
8010519d:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
801051a0:	e8 91 df ff ff       	call   80103136 <myproc>
801051a5:	8d 50 74             	lea    0x74(%eax),%edx
801051a8:	89 55 d8             	mov    %edx,-0x28(%ebp)
801051ab:	e8 86 df ff ff       	call   80103136 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801051b0:	ff 75 d4             	push   -0x2c(%ebp)
801051b3:	ff 75 e4             	push   -0x1c(%ebp)
801051b6:	ff 75 e0             	push   -0x20(%ebp)
801051b9:	ff 75 dc             	push   -0x24(%ebp)
801051bc:	56                   	push   %esi
801051bd:	ff 75 d8             	push   -0x28(%ebp)
801051c0:	ff 70 18             	push   0x18(%eax)
801051c3:	68 b0 71 10 80       	push   $0x801071b0
801051c8:	e8 0d b4 ff ff       	call   801005da <cprintf>
    myproc()->killed = 1;
801051cd:	83 c4 20             	add    $0x20,%esp
801051d0:	e8 61 df ff ff       	call   80103136 <myproc>
801051d5:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
801051dc:	e9 0e fd ff ff       	jmp    80104eef <trap+0x7b>
801051e1:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801051e4:	8b 73 38             	mov    0x38(%ebx),%esi
801051e7:	e8 19 df ff ff       	call   80103105 <cpuid>
801051ec:	83 ec 0c             	sub    $0xc,%esp
801051ef:	57                   	push   %edi
801051f0:	56                   	push   %esi
801051f1:	50                   	push   %eax
801051f2:	ff 73 30             	push   0x30(%ebx)
801051f5:	68 7c 71 10 80       	push   $0x8010717c
801051fa:	e8 db b3 ff ff       	call   801005da <cprintf>
      panic("trap");
801051ff:	83 c4 14             	add    $0x14,%esp
80105202:	68 50 71 10 80       	push   $0x80107150
80105207:	e8 35 b1 ff ff       	call   80100341 <panic>
    exit(status);
8010520c:	83 ec 0c             	sub    $0xc,%esp
8010520f:	57                   	push   %edi
80105210:	e8 cf e2 ff ff       	call   801034e4 <exit>
80105215:	83 c4 10             	add    $0x10,%esp
80105218:	e9 f6 fc ff ff       	jmp    80104f13 <trap+0x9f>
  if(myproc() && myproc()->state == RUNNING &&
8010521d:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105221:	0f 85 04 fd ff ff    	jne    80104f2b <trap+0xb7>
    yield();
80105227:	e8 96 e3 ff ff       	call   801035c2 <yield>
8010522c:	e9 fa fc ff ff       	jmp    80104f2b <trap+0xb7>
    exit(status);
80105231:	83 ec 0c             	sub    $0xc,%esp
80105234:	57                   	push   %edi
80105235:	e8 aa e2 ff ff       	call   801034e4 <exit>
8010523a:	83 c4 10             	add    $0x10,%esp
8010523d:	e9 0d fd ff ff       	jmp    80104f4f <trap+0xdb>

80105242 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80105242:	83 3d c0 46 11 80 00 	cmpl   $0x0,0x801146c0
80105249:	74 14                	je     8010525f <uartgetc+0x1d>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010524b:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105250:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105251:	a8 01                	test   $0x1,%al
80105253:	74 10                	je     80105265 <uartgetc+0x23>
80105255:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010525a:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
8010525b:	0f b6 c0             	movzbl %al,%eax
8010525e:	c3                   	ret    
    return -1;
8010525f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105264:	c3                   	ret    
    return -1;
80105265:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010526a:	c3                   	ret    

8010526b <uartputc>:
  if(!uart)
8010526b:	83 3d c0 46 11 80 00 	cmpl   $0x0,0x801146c0
80105272:	74 39                	je     801052ad <uartputc+0x42>
{
80105274:	55                   	push   %ebp
80105275:	89 e5                	mov    %esp,%ebp
80105277:	53                   	push   %ebx
80105278:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010527b:	bb 00 00 00 00       	mov    $0x0,%ebx
80105280:	eb 0e                	jmp    80105290 <uartputc+0x25>
    microdelay(10);
80105282:	83 ec 0c             	sub    $0xc,%esp
80105285:	6a 0a                	push   $0xa
80105287:	e8 a5 d0 ff ff       	call   80102331 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010528c:	43                   	inc    %ebx
8010528d:	83 c4 10             	add    $0x10,%esp
80105290:	83 fb 7f             	cmp    $0x7f,%ebx
80105293:	7f 0a                	jg     8010529f <uartputc+0x34>
80105295:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010529a:	ec                   	in     (%dx),%al
8010529b:	a8 20                	test   $0x20,%al
8010529d:	74 e3                	je     80105282 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010529f:	8b 45 08             	mov    0x8(%ebp),%eax
801052a2:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052a7:	ee                   	out    %al,(%dx)
}
801052a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801052ab:	c9                   	leave  
801052ac:	c3                   	ret    
801052ad:	c3                   	ret    

801052ae <uartinit>:
{
801052ae:	55                   	push   %ebp
801052af:	89 e5                	mov    %esp,%ebp
801052b1:	56                   	push   %esi
801052b2:	53                   	push   %ebx
801052b3:	b1 00                	mov    $0x0,%cl
801052b5:	ba fa 03 00 00       	mov    $0x3fa,%edx
801052ba:	88 c8                	mov    %cl,%al
801052bc:	ee                   	out    %al,(%dx)
801052bd:	be fb 03 00 00       	mov    $0x3fb,%esi
801052c2:	b0 80                	mov    $0x80,%al
801052c4:	89 f2                	mov    %esi,%edx
801052c6:	ee                   	out    %al,(%dx)
801052c7:	b0 0c                	mov    $0xc,%al
801052c9:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052ce:	ee                   	out    %al,(%dx)
801052cf:	bb f9 03 00 00       	mov    $0x3f9,%ebx
801052d4:	88 c8                	mov    %cl,%al
801052d6:	89 da                	mov    %ebx,%edx
801052d8:	ee                   	out    %al,(%dx)
801052d9:	b0 03                	mov    $0x3,%al
801052db:	89 f2                	mov    %esi,%edx
801052dd:	ee                   	out    %al,(%dx)
801052de:	ba fc 03 00 00       	mov    $0x3fc,%edx
801052e3:	88 c8                	mov    %cl,%al
801052e5:	ee                   	out    %al,(%dx)
801052e6:	b0 01                	mov    $0x1,%al
801052e8:	89 da                	mov    %ebx,%edx
801052ea:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801052eb:	ba fd 03 00 00       	mov    $0x3fd,%edx
801052f0:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801052f1:	3c ff                	cmp    $0xff,%al
801052f3:	74 42                	je     80105337 <uartinit+0x89>
  uart = 1;
801052f5:	c7 05 c0 46 11 80 01 	movl   $0x1,0x801146c0
801052fc:	00 00 00 
801052ff:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105304:	ec                   	in     (%dx),%al
80105305:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010530a:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
8010530b:	83 ec 08             	sub    $0x8,%esp
8010530e:	6a 00                	push   $0x0
80105310:	6a 04                	push   $0x4
80105312:	e8 e5 cb ff ff       	call   80101efc <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105317:	83 c4 10             	add    $0x10,%esp
8010531a:	bb bc 72 10 80       	mov    $0x801072bc,%ebx
8010531f:	eb 10                	jmp    80105331 <uartinit+0x83>
    uartputc(*p);
80105321:	83 ec 0c             	sub    $0xc,%esp
80105324:	0f be c0             	movsbl %al,%eax
80105327:	50                   	push   %eax
80105328:	e8 3e ff ff ff       	call   8010526b <uartputc>
  for(p="xv6...\n"; *p; p++)
8010532d:	43                   	inc    %ebx
8010532e:	83 c4 10             	add    $0x10,%esp
80105331:	8a 03                	mov    (%ebx),%al
80105333:	84 c0                	test   %al,%al
80105335:	75 ea                	jne    80105321 <uartinit+0x73>
}
80105337:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010533a:	5b                   	pop    %ebx
8010533b:	5e                   	pop    %esi
8010533c:	5d                   	pop    %ebp
8010533d:	c3                   	ret    

8010533e <uartintr>:

void
uartintr(void)
{
8010533e:	55                   	push   %ebp
8010533f:	89 e5                	mov    %esp,%ebp
80105341:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105344:	68 42 52 10 80       	push   $0x80105242
80105349:	e8 b1 b3 ff ff       	call   801006ff <consoleintr>
}
8010534e:	83 c4 10             	add    $0x10,%esp
80105351:	c9                   	leave  
80105352:	c3                   	ret    

80105353 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105353:	6a 00                	push   $0x0
  pushl $0
80105355:	6a 00                	push   $0x0
  jmp alltraps
80105357:	e9 bc f9 ff ff       	jmp    80104d18 <alltraps>

8010535c <vector1>:
.globl vector1
vector1:
  pushl $0
8010535c:	6a 00                	push   $0x0
  pushl $1
8010535e:	6a 01                	push   $0x1
  jmp alltraps
80105360:	e9 b3 f9 ff ff       	jmp    80104d18 <alltraps>

80105365 <vector2>:
.globl vector2
vector2:
  pushl $0
80105365:	6a 00                	push   $0x0
  pushl $2
80105367:	6a 02                	push   $0x2
  jmp alltraps
80105369:	e9 aa f9 ff ff       	jmp    80104d18 <alltraps>

8010536e <vector3>:
.globl vector3
vector3:
  pushl $0
8010536e:	6a 00                	push   $0x0
  pushl $3
80105370:	6a 03                	push   $0x3
  jmp alltraps
80105372:	e9 a1 f9 ff ff       	jmp    80104d18 <alltraps>

80105377 <vector4>:
.globl vector4
vector4:
  pushl $0
80105377:	6a 00                	push   $0x0
  pushl $4
80105379:	6a 04                	push   $0x4
  jmp alltraps
8010537b:	e9 98 f9 ff ff       	jmp    80104d18 <alltraps>

80105380 <vector5>:
.globl vector5
vector5:
  pushl $0
80105380:	6a 00                	push   $0x0
  pushl $5
80105382:	6a 05                	push   $0x5
  jmp alltraps
80105384:	e9 8f f9 ff ff       	jmp    80104d18 <alltraps>

80105389 <vector6>:
.globl vector6
vector6:
  pushl $0
80105389:	6a 00                	push   $0x0
  pushl $6
8010538b:	6a 06                	push   $0x6
  jmp alltraps
8010538d:	e9 86 f9 ff ff       	jmp    80104d18 <alltraps>

80105392 <vector7>:
.globl vector7
vector7:
  pushl $0
80105392:	6a 00                	push   $0x0
  pushl $7
80105394:	6a 07                	push   $0x7
  jmp alltraps
80105396:	e9 7d f9 ff ff       	jmp    80104d18 <alltraps>

8010539b <vector8>:
.globl vector8
vector8:
  pushl $8
8010539b:	6a 08                	push   $0x8
  jmp alltraps
8010539d:	e9 76 f9 ff ff       	jmp    80104d18 <alltraps>

801053a2 <vector9>:
.globl vector9
vector9:
  pushl $0
801053a2:	6a 00                	push   $0x0
  pushl $9
801053a4:	6a 09                	push   $0x9
  jmp alltraps
801053a6:	e9 6d f9 ff ff       	jmp    80104d18 <alltraps>

801053ab <vector10>:
.globl vector10
vector10:
  pushl $10
801053ab:	6a 0a                	push   $0xa
  jmp alltraps
801053ad:	e9 66 f9 ff ff       	jmp    80104d18 <alltraps>

801053b2 <vector11>:
.globl vector11
vector11:
  pushl $11
801053b2:	6a 0b                	push   $0xb
  jmp alltraps
801053b4:	e9 5f f9 ff ff       	jmp    80104d18 <alltraps>

801053b9 <vector12>:
.globl vector12
vector12:
  pushl $12
801053b9:	6a 0c                	push   $0xc
  jmp alltraps
801053bb:	e9 58 f9 ff ff       	jmp    80104d18 <alltraps>

801053c0 <vector13>:
.globl vector13
vector13:
  pushl $13
801053c0:	6a 0d                	push   $0xd
  jmp alltraps
801053c2:	e9 51 f9 ff ff       	jmp    80104d18 <alltraps>

801053c7 <vector14>:
.globl vector14
vector14:
  pushl $14
801053c7:	6a 0e                	push   $0xe
  jmp alltraps
801053c9:	e9 4a f9 ff ff       	jmp    80104d18 <alltraps>

801053ce <vector15>:
.globl vector15
vector15:
  pushl $0
801053ce:	6a 00                	push   $0x0
  pushl $15
801053d0:	6a 0f                	push   $0xf
  jmp alltraps
801053d2:	e9 41 f9 ff ff       	jmp    80104d18 <alltraps>

801053d7 <vector16>:
.globl vector16
vector16:
  pushl $0
801053d7:	6a 00                	push   $0x0
  pushl $16
801053d9:	6a 10                	push   $0x10
  jmp alltraps
801053db:	e9 38 f9 ff ff       	jmp    80104d18 <alltraps>

801053e0 <vector17>:
.globl vector17
vector17:
  pushl $17
801053e0:	6a 11                	push   $0x11
  jmp alltraps
801053e2:	e9 31 f9 ff ff       	jmp    80104d18 <alltraps>

801053e7 <vector18>:
.globl vector18
vector18:
  pushl $0
801053e7:	6a 00                	push   $0x0
  pushl $18
801053e9:	6a 12                	push   $0x12
  jmp alltraps
801053eb:	e9 28 f9 ff ff       	jmp    80104d18 <alltraps>

801053f0 <vector19>:
.globl vector19
vector19:
  pushl $0
801053f0:	6a 00                	push   $0x0
  pushl $19
801053f2:	6a 13                	push   $0x13
  jmp alltraps
801053f4:	e9 1f f9 ff ff       	jmp    80104d18 <alltraps>

801053f9 <vector20>:
.globl vector20
vector20:
  pushl $0
801053f9:	6a 00                	push   $0x0
  pushl $20
801053fb:	6a 14                	push   $0x14
  jmp alltraps
801053fd:	e9 16 f9 ff ff       	jmp    80104d18 <alltraps>

80105402 <vector21>:
.globl vector21
vector21:
  pushl $0
80105402:	6a 00                	push   $0x0
  pushl $21
80105404:	6a 15                	push   $0x15
  jmp alltraps
80105406:	e9 0d f9 ff ff       	jmp    80104d18 <alltraps>

8010540b <vector22>:
.globl vector22
vector22:
  pushl $0
8010540b:	6a 00                	push   $0x0
  pushl $22
8010540d:	6a 16                	push   $0x16
  jmp alltraps
8010540f:	e9 04 f9 ff ff       	jmp    80104d18 <alltraps>

80105414 <vector23>:
.globl vector23
vector23:
  pushl $0
80105414:	6a 00                	push   $0x0
  pushl $23
80105416:	6a 17                	push   $0x17
  jmp alltraps
80105418:	e9 fb f8 ff ff       	jmp    80104d18 <alltraps>

8010541d <vector24>:
.globl vector24
vector24:
  pushl $0
8010541d:	6a 00                	push   $0x0
  pushl $24
8010541f:	6a 18                	push   $0x18
  jmp alltraps
80105421:	e9 f2 f8 ff ff       	jmp    80104d18 <alltraps>

80105426 <vector25>:
.globl vector25
vector25:
  pushl $0
80105426:	6a 00                	push   $0x0
  pushl $25
80105428:	6a 19                	push   $0x19
  jmp alltraps
8010542a:	e9 e9 f8 ff ff       	jmp    80104d18 <alltraps>

8010542f <vector26>:
.globl vector26
vector26:
  pushl $0
8010542f:	6a 00                	push   $0x0
  pushl $26
80105431:	6a 1a                	push   $0x1a
  jmp alltraps
80105433:	e9 e0 f8 ff ff       	jmp    80104d18 <alltraps>

80105438 <vector27>:
.globl vector27
vector27:
  pushl $0
80105438:	6a 00                	push   $0x0
  pushl $27
8010543a:	6a 1b                	push   $0x1b
  jmp alltraps
8010543c:	e9 d7 f8 ff ff       	jmp    80104d18 <alltraps>

80105441 <vector28>:
.globl vector28
vector28:
  pushl $0
80105441:	6a 00                	push   $0x0
  pushl $28
80105443:	6a 1c                	push   $0x1c
  jmp alltraps
80105445:	e9 ce f8 ff ff       	jmp    80104d18 <alltraps>

8010544a <vector29>:
.globl vector29
vector29:
  pushl $0
8010544a:	6a 00                	push   $0x0
  pushl $29
8010544c:	6a 1d                	push   $0x1d
  jmp alltraps
8010544e:	e9 c5 f8 ff ff       	jmp    80104d18 <alltraps>

80105453 <vector30>:
.globl vector30
vector30:
  pushl $0
80105453:	6a 00                	push   $0x0
  pushl $30
80105455:	6a 1e                	push   $0x1e
  jmp alltraps
80105457:	e9 bc f8 ff ff       	jmp    80104d18 <alltraps>

8010545c <vector31>:
.globl vector31
vector31:
  pushl $0
8010545c:	6a 00                	push   $0x0
  pushl $31
8010545e:	6a 1f                	push   $0x1f
  jmp alltraps
80105460:	e9 b3 f8 ff ff       	jmp    80104d18 <alltraps>

80105465 <vector32>:
.globl vector32
vector32:
  pushl $0
80105465:	6a 00                	push   $0x0
  pushl $32
80105467:	6a 20                	push   $0x20
  jmp alltraps
80105469:	e9 aa f8 ff ff       	jmp    80104d18 <alltraps>

8010546e <vector33>:
.globl vector33
vector33:
  pushl $0
8010546e:	6a 00                	push   $0x0
  pushl $33
80105470:	6a 21                	push   $0x21
  jmp alltraps
80105472:	e9 a1 f8 ff ff       	jmp    80104d18 <alltraps>

80105477 <vector34>:
.globl vector34
vector34:
  pushl $0
80105477:	6a 00                	push   $0x0
  pushl $34
80105479:	6a 22                	push   $0x22
  jmp alltraps
8010547b:	e9 98 f8 ff ff       	jmp    80104d18 <alltraps>

80105480 <vector35>:
.globl vector35
vector35:
  pushl $0
80105480:	6a 00                	push   $0x0
  pushl $35
80105482:	6a 23                	push   $0x23
  jmp alltraps
80105484:	e9 8f f8 ff ff       	jmp    80104d18 <alltraps>

80105489 <vector36>:
.globl vector36
vector36:
  pushl $0
80105489:	6a 00                	push   $0x0
  pushl $36
8010548b:	6a 24                	push   $0x24
  jmp alltraps
8010548d:	e9 86 f8 ff ff       	jmp    80104d18 <alltraps>

80105492 <vector37>:
.globl vector37
vector37:
  pushl $0
80105492:	6a 00                	push   $0x0
  pushl $37
80105494:	6a 25                	push   $0x25
  jmp alltraps
80105496:	e9 7d f8 ff ff       	jmp    80104d18 <alltraps>

8010549b <vector38>:
.globl vector38
vector38:
  pushl $0
8010549b:	6a 00                	push   $0x0
  pushl $38
8010549d:	6a 26                	push   $0x26
  jmp alltraps
8010549f:	e9 74 f8 ff ff       	jmp    80104d18 <alltraps>

801054a4 <vector39>:
.globl vector39
vector39:
  pushl $0
801054a4:	6a 00                	push   $0x0
  pushl $39
801054a6:	6a 27                	push   $0x27
  jmp alltraps
801054a8:	e9 6b f8 ff ff       	jmp    80104d18 <alltraps>

801054ad <vector40>:
.globl vector40
vector40:
  pushl $0
801054ad:	6a 00                	push   $0x0
  pushl $40
801054af:	6a 28                	push   $0x28
  jmp alltraps
801054b1:	e9 62 f8 ff ff       	jmp    80104d18 <alltraps>

801054b6 <vector41>:
.globl vector41
vector41:
  pushl $0
801054b6:	6a 00                	push   $0x0
  pushl $41
801054b8:	6a 29                	push   $0x29
  jmp alltraps
801054ba:	e9 59 f8 ff ff       	jmp    80104d18 <alltraps>

801054bf <vector42>:
.globl vector42
vector42:
  pushl $0
801054bf:	6a 00                	push   $0x0
  pushl $42
801054c1:	6a 2a                	push   $0x2a
  jmp alltraps
801054c3:	e9 50 f8 ff ff       	jmp    80104d18 <alltraps>

801054c8 <vector43>:
.globl vector43
vector43:
  pushl $0
801054c8:	6a 00                	push   $0x0
  pushl $43
801054ca:	6a 2b                	push   $0x2b
  jmp alltraps
801054cc:	e9 47 f8 ff ff       	jmp    80104d18 <alltraps>

801054d1 <vector44>:
.globl vector44
vector44:
  pushl $0
801054d1:	6a 00                	push   $0x0
  pushl $44
801054d3:	6a 2c                	push   $0x2c
  jmp alltraps
801054d5:	e9 3e f8 ff ff       	jmp    80104d18 <alltraps>

801054da <vector45>:
.globl vector45
vector45:
  pushl $0
801054da:	6a 00                	push   $0x0
  pushl $45
801054dc:	6a 2d                	push   $0x2d
  jmp alltraps
801054de:	e9 35 f8 ff ff       	jmp    80104d18 <alltraps>

801054e3 <vector46>:
.globl vector46
vector46:
  pushl $0
801054e3:	6a 00                	push   $0x0
  pushl $46
801054e5:	6a 2e                	push   $0x2e
  jmp alltraps
801054e7:	e9 2c f8 ff ff       	jmp    80104d18 <alltraps>

801054ec <vector47>:
.globl vector47
vector47:
  pushl $0
801054ec:	6a 00                	push   $0x0
  pushl $47
801054ee:	6a 2f                	push   $0x2f
  jmp alltraps
801054f0:	e9 23 f8 ff ff       	jmp    80104d18 <alltraps>

801054f5 <vector48>:
.globl vector48
vector48:
  pushl $0
801054f5:	6a 00                	push   $0x0
  pushl $48
801054f7:	6a 30                	push   $0x30
  jmp alltraps
801054f9:	e9 1a f8 ff ff       	jmp    80104d18 <alltraps>

801054fe <vector49>:
.globl vector49
vector49:
  pushl $0
801054fe:	6a 00                	push   $0x0
  pushl $49
80105500:	6a 31                	push   $0x31
  jmp alltraps
80105502:	e9 11 f8 ff ff       	jmp    80104d18 <alltraps>

80105507 <vector50>:
.globl vector50
vector50:
  pushl $0
80105507:	6a 00                	push   $0x0
  pushl $50
80105509:	6a 32                	push   $0x32
  jmp alltraps
8010550b:	e9 08 f8 ff ff       	jmp    80104d18 <alltraps>

80105510 <vector51>:
.globl vector51
vector51:
  pushl $0
80105510:	6a 00                	push   $0x0
  pushl $51
80105512:	6a 33                	push   $0x33
  jmp alltraps
80105514:	e9 ff f7 ff ff       	jmp    80104d18 <alltraps>

80105519 <vector52>:
.globl vector52
vector52:
  pushl $0
80105519:	6a 00                	push   $0x0
  pushl $52
8010551b:	6a 34                	push   $0x34
  jmp alltraps
8010551d:	e9 f6 f7 ff ff       	jmp    80104d18 <alltraps>

80105522 <vector53>:
.globl vector53
vector53:
  pushl $0
80105522:	6a 00                	push   $0x0
  pushl $53
80105524:	6a 35                	push   $0x35
  jmp alltraps
80105526:	e9 ed f7 ff ff       	jmp    80104d18 <alltraps>

8010552b <vector54>:
.globl vector54
vector54:
  pushl $0
8010552b:	6a 00                	push   $0x0
  pushl $54
8010552d:	6a 36                	push   $0x36
  jmp alltraps
8010552f:	e9 e4 f7 ff ff       	jmp    80104d18 <alltraps>

80105534 <vector55>:
.globl vector55
vector55:
  pushl $0
80105534:	6a 00                	push   $0x0
  pushl $55
80105536:	6a 37                	push   $0x37
  jmp alltraps
80105538:	e9 db f7 ff ff       	jmp    80104d18 <alltraps>

8010553d <vector56>:
.globl vector56
vector56:
  pushl $0
8010553d:	6a 00                	push   $0x0
  pushl $56
8010553f:	6a 38                	push   $0x38
  jmp alltraps
80105541:	e9 d2 f7 ff ff       	jmp    80104d18 <alltraps>

80105546 <vector57>:
.globl vector57
vector57:
  pushl $0
80105546:	6a 00                	push   $0x0
  pushl $57
80105548:	6a 39                	push   $0x39
  jmp alltraps
8010554a:	e9 c9 f7 ff ff       	jmp    80104d18 <alltraps>

8010554f <vector58>:
.globl vector58
vector58:
  pushl $0
8010554f:	6a 00                	push   $0x0
  pushl $58
80105551:	6a 3a                	push   $0x3a
  jmp alltraps
80105553:	e9 c0 f7 ff ff       	jmp    80104d18 <alltraps>

80105558 <vector59>:
.globl vector59
vector59:
  pushl $0
80105558:	6a 00                	push   $0x0
  pushl $59
8010555a:	6a 3b                	push   $0x3b
  jmp alltraps
8010555c:	e9 b7 f7 ff ff       	jmp    80104d18 <alltraps>

80105561 <vector60>:
.globl vector60
vector60:
  pushl $0
80105561:	6a 00                	push   $0x0
  pushl $60
80105563:	6a 3c                	push   $0x3c
  jmp alltraps
80105565:	e9 ae f7 ff ff       	jmp    80104d18 <alltraps>

8010556a <vector61>:
.globl vector61
vector61:
  pushl $0
8010556a:	6a 00                	push   $0x0
  pushl $61
8010556c:	6a 3d                	push   $0x3d
  jmp alltraps
8010556e:	e9 a5 f7 ff ff       	jmp    80104d18 <alltraps>

80105573 <vector62>:
.globl vector62
vector62:
  pushl $0
80105573:	6a 00                	push   $0x0
  pushl $62
80105575:	6a 3e                	push   $0x3e
  jmp alltraps
80105577:	e9 9c f7 ff ff       	jmp    80104d18 <alltraps>

8010557c <vector63>:
.globl vector63
vector63:
  pushl $0
8010557c:	6a 00                	push   $0x0
  pushl $63
8010557e:	6a 3f                	push   $0x3f
  jmp alltraps
80105580:	e9 93 f7 ff ff       	jmp    80104d18 <alltraps>

80105585 <vector64>:
.globl vector64
vector64:
  pushl $0
80105585:	6a 00                	push   $0x0
  pushl $64
80105587:	6a 40                	push   $0x40
  jmp alltraps
80105589:	e9 8a f7 ff ff       	jmp    80104d18 <alltraps>

8010558e <vector65>:
.globl vector65
vector65:
  pushl $0
8010558e:	6a 00                	push   $0x0
  pushl $65
80105590:	6a 41                	push   $0x41
  jmp alltraps
80105592:	e9 81 f7 ff ff       	jmp    80104d18 <alltraps>

80105597 <vector66>:
.globl vector66
vector66:
  pushl $0
80105597:	6a 00                	push   $0x0
  pushl $66
80105599:	6a 42                	push   $0x42
  jmp alltraps
8010559b:	e9 78 f7 ff ff       	jmp    80104d18 <alltraps>

801055a0 <vector67>:
.globl vector67
vector67:
  pushl $0
801055a0:	6a 00                	push   $0x0
  pushl $67
801055a2:	6a 43                	push   $0x43
  jmp alltraps
801055a4:	e9 6f f7 ff ff       	jmp    80104d18 <alltraps>

801055a9 <vector68>:
.globl vector68
vector68:
  pushl $0
801055a9:	6a 00                	push   $0x0
  pushl $68
801055ab:	6a 44                	push   $0x44
  jmp alltraps
801055ad:	e9 66 f7 ff ff       	jmp    80104d18 <alltraps>

801055b2 <vector69>:
.globl vector69
vector69:
  pushl $0
801055b2:	6a 00                	push   $0x0
  pushl $69
801055b4:	6a 45                	push   $0x45
  jmp alltraps
801055b6:	e9 5d f7 ff ff       	jmp    80104d18 <alltraps>

801055bb <vector70>:
.globl vector70
vector70:
  pushl $0
801055bb:	6a 00                	push   $0x0
  pushl $70
801055bd:	6a 46                	push   $0x46
  jmp alltraps
801055bf:	e9 54 f7 ff ff       	jmp    80104d18 <alltraps>

801055c4 <vector71>:
.globl vector71
vector71:
  pushl $0
801055c4:	6a 00                	push   $0x0
  pushl $71
801055c6:	6a 47                	push   $0x47
  jmp alltraps
801055c8:	e9 4b f7 ff ff       	jmp    80104d18 <alltraps>

801055cd <vector72>:
.globl vector72
vector72:
  pushl $0
801055cd:	6a 00                	push   $0x0
  pushl $72
801055cf:	6a 48                	push   $0x48
  jmp alltraps
801055d1:	e9 42 f7 ff ff       	jmp    80104d18 <alltraps>

801055d6 <vector73>:
.globl vector73
vector73:
  pushl $0
801055d6:	6a 00                	push   $0x0
  pushl $73
801055d8:	6a 49                	push   $0x49
  jmp alltraps
801055da:	e9 39 f7 ff ff       	jmp    80104d18 <alltraps>

801055df <vector74>:
.globl vector74
vector74:
  pushl $0
801055df:	6a 00                	push   $0x0
  pushl $74
801055e1:	6a 4a                	push   $0x4a
  jmp alltraps
801055e3:	e9 30 f7 ff ff       	jmp    80104d18 <alltraps>

801055e8 <vector75>:
.globl vector75
vector75:
  pushl $0
801055e8:	6a 00                	push   $0x0
  pushl $75
801055ea:	6a 4b                	push   $0x4b
  jmp alltraps
801055ec:	e9 27 f7 ff ff       	jmp    80104d18 <alltraps>

801055f1 <vector76>:
.globl vector76
vector76:
  pushl $0
801055f1:	6a 00                	push   $0x0
  pushl $76
801055f3:	6a 4c                	push   $0x4c
  jmp alltraps
801055f5:	e9 1e f7 ff ff       	jmp    80104d18 <alltraps>

801055fa <vector77>:
.globl vector77
vector77:
  pushl $0
801055fa:	6a 00                	push   $0x0
  pushl $77
801055fc:	6a 4d                	push   $0x4d
  jmp alltraps
801055fe:	e9 15 f7 ff ff       	jmp    80104d18 <alltraps>

80105603 <vector78>:
.globl vector78
vector78:
  pushl $0
80105603:	6a 00                	push   $0x0
  pushl $78
80105605:	6a 4e                	push   $0x4e
  jmp alltraps
80105607:	e9 0c f7 ff ff       	jmp    80104d18 <alltraps>

8010560c <vector79>:
.globl vector79
vector79:
  pushl $0
8010560c:	6a 00                	push   $0x0
  pushl $79
8010560e:	6a 4f                	push   $0x4f
  jmp alltraps
80105610:	e9 03 f7 ff ff       	jmp    80104d18 <alltraps>

80105615 <vector80>:
.globl vector80
vector80:
  pushl $0
80105615:	6a 00                	push   $0x0
  pushl $80
80105617:	6a 50                	push   $0x50
  jmp alltraps
80105619:	e9 fa f6 ff ff       	jmp    80104d18 <alltraps>

8010561e <vector81>:
.globl vector81
vector81:
  pushl $0
8010561e:	6a 00                	push   $0x0
  pushl $81
80105620:	6a 51                	push   $0x51
  jmp alltraps
80105622:	e9 f1 f6 ff ff       	jmp    80104d18 <alltraps>

80105627 <vector82>:
.globl vector82
vector82:
  pushl $0
80105627:	6a 00                	push   $0x0
  pushl $82
80105629:	6a 52                	push   $0x52
  jmp alltraps
8010562b:	e9 e8 f6 ff ff       	jmp    80104d18 <alltraps>

80105630 <vector83>:
.globl vector83
vector83:
  pushl $0
80105630:	6a 00                	push   $0x0
  pushl $83
80105632:	6a 53                	push   $0x53
  jmp alltraps
80105634:	e9 df f6 ff ff       	jmp    80104d18 <alltraps>

80105639 <vector84>:
.globl vector84
vector84:
  pushl $0
80105639:	6a 00                	push   $0x0
  pushl $84
8010563b:	6a 54                	push   $0x54
  jmp alltraps
8010563d:	e9 d6 f6 ff ff       	jmp    80104d18 <alltraps>

80105642 <vector85>:
.globl vector85
vector85:
  pushl $0
80105642:	6a 00                	push   $0x0
  pushl $85
80105644:	6a 55                	push   $0x55
  jmp alltraps
80105646:	e9 cd f6 ff ff       	jmp    80104d18 <alltraps>

8010564b <vector86>:
.globl vector86
vector86:
  pushl $0
8010564b:	6a 00                	push   $0x0
  pushl $86
8010564d:	6a 56                	push   $0x56
  jmp alltraps
8010564f:	e9 c4 f6 ff ff       	jmp    80104d18 <alltraps>

80105654 <vector87>:
.globl vector87
vector87:
  pushl $0
80105654:	6a 00                	push   $0x0
  pushl $87
80105656:	6a 57                	push   $0x57
  jmp alltraps
80105658:	e9 bb f6 ff ff       	jmp    80104d18 <alltraps>

8010565d <vector88>:
.globl vector88
vector88:
  pushl $0
8010565d:	6a 00                	push   $0x0
  pushl $88
8010565f:	6a 58                	push   $0x58
  jmp alltraps
80105661:	e9 b2 f6 ff ff       	jmp    80104d18 <alltraps>

80105666 <vector89>:
.globl vector89
vector89:
  pushl $0
80105666:	6a 00                	push   $0x0
  pushl $89
80105668:	6a 59                	push   $0x59
  jmp alltraps
8010566a:	e9 a9 f6 ff ff       	jmp    80104d18 <alltraps>

8010566f <vector90>:
.globl vector90
vector90:
  pushl $0
8010566f:	6a 00                	push   $0x0
  pushl $90
80105671:	6a 5a                	push   $0x5a
  jmp alltraps
80105673:	e9 a0 f6 ff ff       	jmp    80104d18 <alltraps>

80105678 <vector91>:
.globl vector91
vector91:
  pushl $0
80105678:	6a 00                	push   $0x0
  pushl $91
8010567a:	6a 5b                	push   $0x5b
  jmp alltraps
8010567c:	e9 97 f6 ff ff       	jmp    80104d18 <alltraps>

80105681 <vector92>:
.globl vector92
vector92:
  pushl $0
80105681:	6a 00                	push   $0x0
  pushl $92
80105683:	6a 5c                	push   $0x5c
  jmp alltraps
80105685:	e9 8e f6 ff ff       	jmp    80104d18 <alltraps>

8010568a <vector93>:
.globl vector93
vector93:
  pushl $0
8010568a:	6a 00                	push   $0x0
  pushl $93
8010568c:	6a 5d                	push   $0x5d
  jmp alltraps
8010568e:	e9 85 f6 ff ff       	jmp    80104d18 <alltraps>

80105693 <vector94>:
.globl vector94
vector94:
  pushl $0
80105693:	6a 00                	push   $0x0
  pushl $94
80105695:	6a 5e                	push   $0x5e
  jmp alltraps
80105697:	e9 7c f6 ff ff       	jmp    80104d18 <alltraps>

8010569c <vector95>:
.globl vector95
vector95:
  pushl $0
8010569c:	6a 00                	push   $0x0
  pushl $95
8010569e:	6a 5f                	push   $0x5f
  jmp alltraps
801056a0:	e9 73 f6 ff ff       	jmp    80104d18 <alltraps>

801056a5 <vector96>:
.globl vector96
vector96:
  pushl $0
801056a5:	6a 00                	push   $0x0
  pushl $96
801056a7:	6a 60                	push   $0x60
  jmp alltraps
801056a9:	e9 6a f6 ff ff       	jmp    80104d18 <alltraps>

801056ae <vector97>:
.globl vector97
vector97:
  pushl $0
801056ae:	6a 00                	push   $0x0
  pushl $97
801056b0:	6a 61                	push   $0x61
  jmp alltraps
801056b2:	e9 61 f6 ff ff       	jmp    80104d18 <alltraps>

801056b7 <vector98>:
.globl vector98
vector98:
  pushl $0
801056b7:	6a 00                	push   $0x0
  pushl $98
801056b9:	6a 62                	push   $0x62
  jmp alltraps
801056bb:	e9 58 f6 ff ff       	jmp    80104d18 <alltraps>

801056c0 <vector99>:
.globl vector99
vector99:
  pushl $0
801056c0:	6a 00                	push   $0x0
  pushl $99
801056c2:	6a 63                	push   $0x63
  jmp alltraps
801056c4:	e9 4f f6 ff ff       	jmp    80104d18 <alltraps>

801056c9 <vector100>:
.globl vector100
vector100:
  pushl $0
801056c9:	6a 00                	push   $0x0
  pushl $100
801056cb:	6a 64                	push   $0x64
  jmp alltraps
801056cd:	e9 46 f6 ff ff       	jmp    80104d18 <alltraps>

801056d2 <vector101>:
.globl vector101
vector101:
  pushl $0
801056d2:	6a 00                	push   $0x0
  pushl $101
801056d4:	6a 65                	push   $0x65
  jmp alltraps
801056d6:	e9 3d f6 ff ff       	jmp    80104d18 <alltraps>

801056db <vector102>:
.globl vector102
vector102:
  pushl $0
801056db:	6a 00                	push   $0x0
  pushl $102
801056dd:	6a 66                	push   $0x66
  jmp alltraps
801056df:	e9 34 f6 ff ff       	jmp    80104d18 <alltraps>

801056e4 <vector103>:
.globl vector103
vector103:
  pushl $0
801056e4:	6a 00                	push   $0x0
  pushl $103
801056e6:	6a 67                	push   $0x67
  jmp alltraps
801056e8:	e9 2b f6 ff ff       	jmp    80104d18 <alltraps>

801056ed <vector104>:
.globl vector104
vector104:
  pushl $0
801056ed:	6a 00                	push   $0x0
  pushl $104
801056ef:	6a 68                	push   $0x68
  jmp alltraps
801056f1:	e9 22 f6 ff ff       	jmp    80104d18 <alltraps>

801056f6 <vector105>:
.globl vector105
vector105:
  pushl $0
801056f6:	6a 00                	push   $0x0
  pushl $105
801056f8:	6a 69                	push   $0x69
  jmp alltraps
801056fa:	e9 19 f6 ff ff       	jmp    80104d18 <alltraps>

801056ff <vector106>:
.globl vector106
vector106:
  pushl $0
801056ff:	6a 00                	push   $0x0
  pushl $106
80105701:	6a 6a                	push   $0x6a
  jmp alltraps
80105703:	e9 10 f6 ff ff       	jmp    80104d18 <alltraps>

80105708 <vector107>:
.globl vector107
vector107:
  pushl $0
80105708:	6a 00                	push   $0x0
  pushl $107
8010570a:	6a 6b                	push   $0x6b
  jmp alltraps
8010570c:	e9 07 f6 ff ff       	jmp    80104d18 <alltraps>

80105711 <vector108>:
.globl vector108
vector108:
  pushl $0
80105711:	6a 00                	push   $0x0
  pushl $108
80105713:	6a 6c                	push   $0x6c
  jmp alltraps
80105715:	e9 fe f5 ff ff       	jmp    80104d18 <alltraps>

8010571a <vector109>:
.globl vector109
vector109:
  pushl $0
8010571a:	6a 00                	push   $0x0
  pushl $109
8010571c:	6a 6d                	push   $0x6d
  jmp alltraps
8010571e:	e9 f5 f5 ff ff       	jmp    80104d18 <alltraps>

80105723 <vector110>:
.globl vector110
vector110:
  pushl $0
80105723:	6a 00                	push   $0x0
  pushl $110
80105725:	6a 6e                	push   $0x6e
  jmp alltraps
80105727:	e9 ec f5 ff ff       	jmp    80104d18 <alltraps>

8010572c <vector111>:
.globl vector111
vector111:
  pushl $0
8010572c:	6a 00                	push   $0x0
  pushl $111
8010572e:	6a 6f                	push   $0x6f
  jmp alltraps
80105730:	e9 e3 f5 ff ff       	jmp    80104d18 <alltraps>

80105735 <vector112>:
.globl vector112
vector112:
  pushl $0
80105735:	6a 00                	push   $0x0
  pushl $112
80105737:	6a 70                	push   $0x70
  jmp alltraps
80105739:	e9 da f5 ff ff       	jmp    80104d18 <alltraps>

8010573e <vector113>:
.globl vector113
vector113:
  pushl $0
8010573e:	6a 00                	push   $0x0
  pushl $113
80105740:	6a 71                	push   $0x71
  jmp alltraps
80105742:	e9 d1 f5 ff ff       	jmp    80104d18 <alltraps>

80105747 <vector114>:
.globl vector114
vector114:
  pushl $0
80105747:	6a 00                	push   $0x0
  pushl $114
80105749:	6a 72                	push   $0x72
  jmp alltraps
8010574b:	e9 c8 f5 ff ff       	jmp    80104d18 <alltraps>

80105750 <vector115>:
.globl vector115
vector115:
  pushl $0
80105750:	6a 00                	push   $0x0
  pushl $115
80105752:	6a 73                	push   $0x73
  jmp alltraps
80105754:	e9 bf f5 ff ff       	jmp    80104d18 <alltraps>

80105759 <vector116>:
.globl vector116
vector116:
  pushl $0
80105759:	6a 00                	push   $0x0
  pushl $116
8010575b:	6a 74                	push   $0x74
  jmp alltraps
8010575d:	e9 b6 f5 ff ff       	jmp    80104d18 <alltraps>

80105762 <vector117>:
.globl vector117
vector117:
  pushl $0
80105762:	6a 00                	push   $0x0
  pushl $117
80105764:	6a 75                	push   $0x75
  jmp alltraps
80105766:	e9 ad f5 ff ff       	jmp    80104d18 <alltraps>

8010576b <vector118>:
.globl vector118
vector118:
  pushl $0
8010576b:	6a 00                	push   $0x0
  pushl $118
8010576d:	6a 76                	push   $0x76
  jmp alltraps
8010576f:	e9 a4 f5 ff ff       	jmp    80104d18 <alltraps>

80105774 <vector119>:
.globl vector119
vector119:
  pushl $0
80105774:	6a 00                	push   $0x0
  pushl $119
80105776:	6a 77                	push   $0x77
  jmp alltraps
80105778:	e9 9b f5 ff ff       	jmp    80104d18 <alltraps>

8010577d <vector120>:
.globl vector120
vector120:
  pushl $0
8010577d:	6a 00                	push   $0x0
  pushl $120
8010577f:	6a 78                	push   $0x78
  jmp alltraps
80105781:	e9 92 f5 ff ff       	jmp    80104d18 <alltraps>

80105786 <vector121>:
.globl vector121
vector121:
  pushl $0
80105786:	6a 00                	push   $0x0
  pushl $121
80105788:	6a 79                	push   $0x79
  jmp alltraps
8010578a:	e9 89 f5 ff ff       	jmp    80104d18 <alltraps>

8010578f <vector122>:
.globl vector122
vector122:
  pushl $0
8010578f:	6a 00                	push   $0x0
  pushl $122
80105791:	6a 7a                	push   $0x7a
  jmp alltraps
80105793:	e9 80 f5 ff ff       	jmp    80104d18 <alltraps>

80105798 <vector123>:
.globl vector123
vector123:
  pushl $0
80105798:	6a 00                	push   $0x0
  pushl $123
8010579a:	6a 7b                	push   $0x7b
  jmp alltraps
8010579c:	e9 77 f5 ff ff       	jmp    80104d18 <alltraps>

801057a1 <vector124>:
.globl vector124
vector124:
  pushl $0
801057a1:	6a 00                	push   $0x0
  pushl $124
801057a3:	6a 7c                	push   $0x7c
  jmp alltraps
801057a5:	e9 6e f5 ff ff       	jmp    80104d18 <alltraps>

801057aa <vector125>:
.globl vector125
vector125:
  pushl $0
801057aa:	6a 00                	push   $0x0
  pushl $125
801057ac:	6a 7d                	push   $0x7d
  jmp alltraps
801057ae:	e9 65 f5 ff ff       	jmp    80104d18 <alltraps>

801057b3 <vector126>:
.globl vector126
vector126:
  pushl $0
801057b3:	6a 00                	push   $0x0
  pushl $126
801057b5:	6a 7e                	push   $0x7e
  jmp alltraps
801057b7:	e9 5c f5 ff ff       	jmp    80104d18 <alltraps>

801057bc <vector127>:
.globl vector127
vector127:
  pushl $0
801057bc:	6a 00                	push   $0x0
  pushl $127
801057be:	6a 7f                	push   $0x7f
  jmp alltraps
801057c0:	e9 53 f5 ff ff       	jmp    80104d18 <alltraps>

801057c5 <vector128>:
.globl vector128
vector128:
  pushl $0
801057c5:	6a 00                	push   $0x0
  pushl $128
801057c7:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801057cc:	e9 47 f5 ff ff       	jmp    80104d18 <alltraps>

801057d1 <vector129>:
.globl vector129
vector129:
  pushl $0
801057d1:	6a 00                	push   $0x0
  pushl $129
801057d3:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801057d8:	e9 3b f5 ff ff       	jmp    80104d18 <alltraps>

801057dd <vector130>:
.globl vector130
vector130:
  pushl $0
801057dd:	6a 00                	push   $0x0
  pushl $130
801057df:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801057e4:	e9 2f f5 ff ff       	jmp    80104d18 <alltraps>

801057e9 <vector131>:
.globl vector131
vector131:
  pushl $0
801057e9:	6a 00                	push   $0x0
  pushl $131
801057eb:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801057f0:	e9 23 f5 ff ff       	jmp    80104d18 <alltraps>

801057f5 <vector132>:
.globl vector132
vector132:
  pushl $0
801057f5:	6a 00                	push   $0x0
  pushl $132
801057f7:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801057fc:	e9 17 f5 ff ff       	jmp    80104d18 <alltraps>

80105801 <vector133>:
.globl vector133
vector133:
  pushl $0
80105801:	6a 00                	push   $0x0
  pushl $133
80105803:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105808:	e9 0b f5 ff ff       	jmp    80104d18 <alltraps>

8010580d <vector134>:
.globl vector134
vector134:
  pushl $0
8010580d:	6a 00                	push   $0x0
  pushl $134
8010580f:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105814:	e9 ff f4 ff ff       	jmp    80104d18 <alltraps>

80105819 <vector135>:
.globl vector135
vector135:
  pushl $0
80105819:	6a 00                	push   $0x0
  pushl $135
8010581b:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80105820:	e9 f3 f4 ff ff       	jmp    80104d18 <alltraps>

80105825 <vector136>:
.globl vector136
vector136:
  pushl $0
80105825:	6a 00                	push   $0x0
  pushl $136
80105827:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010582c:	e9 e7 f4 ff ff       	jmp    80104d18 <alltraps>

80105831 <vector137>:
.globl vector137
vector137:
  pushl $0
80105831:	6a 00                	push   $0x0
  pushl $137
80105833:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80105838:	e9 db f4 ff ff       	jmp    80104d18 <alltraps>

8010583d <vector138>:
.globl vector138
vector138:
  pushl $0
8010583d:	6a 00                	push   $0x0
  pushl $138
8010583f:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105844:	e9 cf f4 ff ff       	jmp    80104d18 <alltraps>

80105849 <vector139>:
.globl vector139
vector139:
  pushl $0
80105849:	6a 00                	push   $0x0
  pushl $139
8010584b:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80105850:	e9 c3 f4 ff ff       	jmp    80104d18 <alltraps>

80105855 <vector140>:
.globl vector140
vector140:
  pushl $0
80105855:	6a 00                	push   $0x0
  pushl $140
80105857:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010585c:	e9 b7 f4 ff ff       	jmp    80104d18 <alltraps>

80105861 <vector141>:
.globl vector141
vector141:
  pushl $0
80105861:	6a 00                	push   $0x0
  pushl $141
80105863:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105868:	e9 ab f4 ff ff       	jmp    80104d18 <alltraps>

8010586d <vector142>:
.globl vector142
vector142:
  pushl $0
8010586d:	6a 00                	push   $0x0
  pushl $142
8010586f:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105874:	e9 9f f4 ff ff       	jmp    80104d18 <alltraps>

80105879 <vector143>:
.globl vector143
vector143:
  pushl $0
80105879:	6a 00                	push   $0x0
  pushl $143
8010587b:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105880:	e9 93 f4 ff ff       	jmp    80104d18 <alltraps>

80105885 <vector144>:
.globl vector144
vector144:
  pushl $0
80105885:	6a 00                	push   $0x0
  pushl $144
80105887:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010588c:	e9 87 f4 ff ff       	jmp    80104d18 <alltraps>

80105891 <vector145>:
.globl vector145
vector145:
  pushl $0
80105891:	6a 00                	push   $0x0
  pushl $145
80105893:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105898:	e9 7b f4 ff ff       	jmp    80104d18 <alltraps>

8010589d <vector146>:
.globl vector146
vector146:
  pushl $0
8010589d:	6a 00                	push   $0x0
  pushl $146
8010589f:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801058a4:	e9 6f f4 ff ff       	jmp    80104d18 <alltraps>

801058a9 <vector147>:
.globl vector147
vector147:
  pushl $0
801058a9:	6a 00                	push   $0x0
  pushl $147
801058ab:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801058b0:	e9 63 f4 ff ff       	jmp    80104d18 <alltraps>

801058b5 <vector148>:
.globl vector148
vector148:
  pushl $0
801058b5:	6a 00                	push   $0x0
  pushl $148
801058b7:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801058bc:	e9 57 f4 ff ff       	jmp    80104d18 <alltraps>

801058c1 <vector149>:
.globl vector149
vector149:
  pushl $0
801058c1:	6a 00                	push   $0x0
  pushl $149
801058c3:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801058c8:	e9 4b f4 ff ff       	jmp    80104d18 <alltraps>

801058cd <vector150>:
.globl vector150
vector150:
  pushl $0
801058cd:	6a 00                	push   $0x0
  pushl $150
801058cf:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801058d4:	e9 3f f4 ff ff       	jmp    80104d18 <alltraps>

801058d9 <vector151>:
.globl vector151
vector151:
  pushl $0
801058d9:	6a 00                	push   $0x0
  pushl $151
801058db:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801058e0:	e9 33 f4 ff ff       	jmp    80104d18 <alltraps>

801058e5 <vector152>:
.globl vector152
vector152:
  pushl $0
801058e5:	6a 00                	push   $0x0
  pushl $152
801058e7:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801058ec:	e9 27 f4 ff ff       	jmp    80104d18 <alltraps>

801058f1 <vector153>:
.globl vector153
vector153:
  pushl $0
801058f1:	6a 00                	push   $0x0
  pushl $153
801058f3:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801058f8:	e9 1b f4 ff ff       	jmp    80104d18 <alltraps>

801058fd <vector154>:
.globl vector154
vector154:
  pushl $0
801058fd:	6a 00                	push   $0x0
  pushl $154
801058ff:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105904:	e9 0f f4 ff ff       	jmp    80104d18 <alltraps>

80105909 <vector155>:
.globl vector155
vector155:
  pushl $0
80105909:	6a 00                	push   $0x0
  pushl $155
8010590b:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105910:	e9 03 f4 ff ff       	jmp    80104d18 <alltraps>

80105915 <vector156>:
.globl vector156
vector156:
  pushl $0
80105915:	6a 00                	push   $0x0
  pushl $156
80105917:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010591c:	e9 f7 f3 ff ff       	jmp    80104d18 <alltraps>

80105921 <vector157>:
.globl vector157
vector157:
  pushl $0
80105921:	6a 00                	push   $0x0
  pushl $157
80105923:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80105928:	e9 eb f3 ff ff       	jmp    80104d18 <alltraps>

8010592d <vector158>:
.globl vector158
vector158:
  pushl $0
8010592d:	6a 00                	push   $0x0
  pushl $158
8010592f:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105934:	e9 df f3 ff ff       	jmp    80104d18 <alltraps>

80105939 <vector159>:
.globl vector159
vector159:
  pushl $0
80105939:	6a 00                	push   $0x0
  pushl $159
8010593b:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105940:	e9 d3 f3 ff ff       	jmp    80104d18 <alltraps>

80105945 <vector160>:
.globl vector160
vector160:
  pushl $0
80105945:	6a 00                	push   $0x0
  pushl $160
80105947:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010594c:	e9 c7 f3 ff ff       	jmp    80104d18 <alltraps>

80105951 <vector161>:
.globl vector161
vector161:
  pushl $0
80105951:	6a 00                	push   $0x0
  pushl $161
80105953:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105958:	e9 bb f3 ff ff       	jmp    80104d18 <alltraps>

8010595d <vector162>:
.globl vector162
vector162:
  pushl $0
8010595d:	6a 00                	push   $0x0
  pushl $162
8010595f:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105964:	e9 af f3 ff ff       	jmp    80104d18 <alltraps>

80105969 <vector163>:
.globl vector163
vector163:
  pushl $0
80105969:	6a 00                	push   $0x0
  pushl $163
8010596b:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105970:	e9 a3 f3 ff ff       	jmp    80104d18 <alltraps>

80105975 <vector164>:
.globl vector164
vector164:
  pushl $0
80105975:	6a 00                	push   $0x0
  pushl $164
80105977:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010597c:	e9 97 f3 ff ff       	jmp    80104d18 <alltraps>

80105981 <vector165>:
.globl vector165
vector165:
  pushl $0
80105981:	6a 00                	push   $0x0
  pushl $165
80105983:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105988:	e9 8b f3 ff ff       	jmp    80104d18 <alltraps>

8010598d <vector166>:
.globl vector166
vector166:
  pushl $0
8010598d:	6a 00                	push   $0x0
  pushl $166
8010598f:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105994:	e9 7f f3 ff ff       	jmp    80104d18 <alltraps>

80105999 <vector167>:
.globl vector167
vector167:
  pushl $0
80105999:	6a 00                	push   $0x0
  pushl $167
8010599b:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801059a0:	e9 73 f3 ff ff       	jmp    80104d18 <alltraps>

801059a5 <vector168>:
.globl vector168
vector168:
  pushl $0
801059a5:	6a 00                	push   $0x0
  pushl $168
801059a7:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801059ac:	e9 67 f3 ff ff       	jmp    80104d18 <alltraps>

801059b1 <vector169>:
.globl vector169
vector169:
  pushl $0
801059b1:	6a 00                	push   $0x0
  pushl $169
801059b3:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801059b8:	e9 5b f3 ff ff       	jmp    80104d18 <alltraps>

801059bd <vector170>:
.globl vector170
vector170:
  pushl $0
801059bd:	6a 00                	push   $0x0
  pushl $170
801059bf:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801059c4:	e9 4f f3 ff ff       	jmp    80104d18 <alltraps>

801059c9 <vector171>:
.globl vector171
vector171:
  pushl $0
801059c9:	6a 00                	push   $0x0
  pushl $171
801059cb:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801059d0:	e9 43 f3 ff ff       	jmp    80104d18 <alltraps>

801059d5 <vector172>:
.globl vector172
vector172:
  pushl $0
801059d5:	6a 00                	push   $0x0
  pushl $172
801059d7:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801059dc:	e9 37 f3 ff ff       	jmp    80104d18 <alltraps>

801059e1 <vector173>:
.globl vector173
vector173:
  pushl $0
801059e1:	6a 00                	push   $0x0
  pushl $173
801059e3:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801059e8:	e9 2b f3 ff ff       	jmp    80104d18 <alltraps>

801059ed <vector174>:
.globl vector174
vector174:
  pushl $0
801059ed:	6a 00                	push   $0x0
  pushl $174
801059ef:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801059f4:	e9 1f f3 ff ff       	jmp    80104d18 <alltraps>

801059f9 <vector175>:
.globl vector175
vector175:
  pushl $0
801059f9:	6a 00                	push   $0x0
  pushl $175
801059fb:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105a00:	e9 13 f3 ff ff       	jmp    80104d18 <alltraps>

80105a05 <vector176>:
.globl vector176
vector176:
  pushl $0
80105a05:	6a 00                	push   $0x0
  pushl $176
80105a07:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105a0c:	e9 07 f3 ff ff       	jmp    80104d18 <alltraps>

80105a11 <vector177>:
.globl vector177
vector177:
  pushl $0
80105a11:	6a 00                	push   $0x0
  pushl $177
80105a13:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105a18:	e9 fb f2 ff ff       	jmp    80104d18 <alltraps>

80105a1d <vector178>:
.globl vector178
vector178:
  pushl $0
80105a1d:	6a 00                	push   $0x0
  pushl $178
80105a1f:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105a24:	e9 ef f2 ff ff       	jmp    80104d18 <alltraps>

80105a29 <vector179>:
.globl vector179
vector179:
  pushl $0
80105a29:	6a 00                	push   $0x0
  pushl $179
80105a2b:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105a30:	e9 e3 f2 ff ff       	jmp    80104d18 <alltraps>

80105a35 <vector180>:
.globl vector180
vector180:
  pushl $0
80105a35:	6a 00                	push   $0x0
  pushl $180
80105a37:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105a3c:	e9 d7 f2 ff ff       	jmp    80104d18 <alltraps>

80105a41 <vector181>:
.globl vector181
vector181:
  pushl $0
80105a41:	6a 00                	push   $0x0
  pushl $181
80105a43:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105a48:	e9 cb f2 ff ff       	jmp    80104d18 <alltraps>

80105a4d <vector182>:
.globl vector182
vector182:
  pushl $0
80105a4d:	6a 00                	push   $0x0
  pushl $182
80105a4f:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105a54:	e9 bf f2 ff ff       	jmp    80104d18 <alltraps>

80105a59 <vector183>:
.globl vector183
vector183:
  pushl $0
80105a59:	6a 00                	push   $0x0
  pushl $183
80105a5b:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105a60:	e9 b3 f2 ff ff       	jmp    80104d18 <alltraps>

80105a65 <vector184>:
.globl vector184
vector184:
  pushl $0
80105a65:	6a 00                	push   $0x0
  pushl $184
80105a67:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105a6c:	e9 a7 f2 ff ff       	jmp    80104d18 <alltraps>

80105a71 <vector185>:
.globl vector185
vector185:
  pushl $0
80105a71:	6a 00                	push   $0x0
  pushl $185
80105a73:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105a78:	e9 9b f2 ff ff       	jmp    80104d18 <alltraps>

80105a7d <vector186>:
.globl vector186
vector186:
  pushl $0
80105a7d:	6a 00                	push   $0x0
  pushl $186
80105a7f:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105a84:	e9 8f f2 ff ff       	jmp    80104d18 <alltraps>

80105a89 <vector187>:
.globl vector187
vector187:
  pushl $0
80105a89:	6a 00                	push   $0x0
  pushl $187
80105a8b:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105a90:	e9 83 f2 ff ff       	jmp    80104d18 <alltraps>

80105a95 <vector188>:
.globl vector188
vector188:
  pushl $0
80105a95:	6a 00                	push   $0x0
  pushl $188
80105a97:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105a9c:	e9 77 f2 ff ff       	jmp    80104d18 <alltraps>

80105aa1 <vector189>:
.globl vector189
vector189:
  pushl $0
80105aa1:	6a 00                	push   $0x0
  pushl $189
80105aa3:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105aa8:	e9 6b f2 ff ff       	jmp    80104d18 <alltraps>

80105aad <vector190>:
.globl vector190
vector190:
  pushl $0
80105aad:	6a 00                	push   $0x0
  pushl $190
80105aaf:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105ab4:	e9 5f f2 ff ff       	jmp    80104d18 <alltraps>

80105ab9 <vector191>:
.globl vector191
vector191:
  pushl $0
80105ab9:	6a 00                	push   $0x0
  pushl $191
80105abb:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105ac0:	e9 53 f2 ff ff       	jmp    80104d18 <alltraps>

80105ac5 <vector192>:
.globl vector192
vector192:
  pushl $0
80105ac5:	6a 00                	push   $0x0
  pushl $192
80105ac7:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105acc:	e9 47 f2 ff ff       	jmp    80104d18 <alltraps>

80105ad1 <vector193>:
.globl vector193
vector193:
  pushl $0
80105ad1:	6a 00                	push   $0x0
  pushl $193
80105ad3:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105ad8:	e9 3b f2 ff ff       	jmp    80104d18 <alltraps>

80105add <vector194>:
.globl vector194
vector194:
  pushl $0
80105add:	6a 00                	push   $0x0
  pushl $194
80105adf:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105ae4:	e9 2f f2 ff ff       	jmp    80104d18 <alltraps>

80105ae9 <vector195>:
.globl vector195
vector195:
  pushl $0
80105ae9:	6a 00                	push   $0x0
  pushl $195
80105aeb:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105af0:	e9 23 f2 ff ff       	jmp    80104d18 <alltraps>

80105af5 <vector196>:
.globl vector196
vector196:
  pushl $0
80105af5:	6a 00                	push   $0x0
  pushl $196
80105af7:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105afc:	e9 17 f2 ff ff       	jmp    80104d18 <alltraps>

80105b01 <vector197>:
.globl vector197
vector197:
  pushl $0
80105b01:	6a 00                	push   $0x0
  pushl $197
80105b03:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105b08:	e9 0b f2 ff ff       	jmp    80104d18 <alltraps>

80105b0d <vector198>:
.globl vector198
vector198:
  pushl $0
80105b0d:	6a 00                	push   $0x0
  pushl $198
80105b0f:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105b14:	e9 ff f1 ff ff       	jmp    80104d18 <alltraps>

80105b19 <vector199>:
.globl vector199
vector199:
  pushl $0
80105b19:	6a 00                	push   $0x0
  pushl $199
80105b1b:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105b20:	e9 f3 f1 ff ff       	jmp    80104d18 <alltraps>

80105b25 <vector200>:
.globl vector200
vector200:
  pushl $0
80105b25:	6a 00                	push   $0x0
  pushl $200
80105b27:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105b2c:	e9 e7 f1 ff ff       	jmp    80104d18 <alltraps>

80105b31 <vector201>:
.globl vector201
vector201:
  pushl $0
80105b31:	6a 00                	push   $0x0
  pushl $201
80105b33:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105b38:	e9 db f1 ff ff       	jmp    80104d18 <alltraps>

80105b3d <vector202>:
.globl vector202
vector202:
  pushl $0
80105b3d:	6a 00                	push   $0x0
  pushl $202
80105b3f:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105b44:	e9 cf f1 ff ff       	jmp    80104d18 <alltraps>

80105b49 <vector203>:
.globl vector203
vector203:
  pushl $0
80105b49:	6a 00                	push   $0x0
  pushl $203
80105b4b:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105b50:	e9 c3 f1 ff ff       	jmp    80104d18 <alltraps>

80105b55 <vector204>:
.globl vector204
vector204:
  pushl $0
80105b55:	6a 00                	push   $0x0
  pushl $204
80105b57:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105b5c:	e9 b7 f1 ff ff       	jmp    80104d18 <alltraps>

80105b61 <vector205>:
.globl vector205
vector205:
  pushl $0
80105b61:	6a 00                	push   $0x0
  pushl $205
80105b63:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105b68:	e9 ab f1 ff ff       	jmp    80104d18 <alltraps>

80105b6d <vector206>:
.globl vector206
vector206:
  pushl $0
80105b6d:	6a 00                	push   $0x0
  pushl $206
80105b6f:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105b74:	e9 9f f1 ff ff       	jmp    80104d18 <alltraps>

80105b79 <vector207>:
.globl vector207
vector207:
  pushl $0
80105b79:	6a 00                	push   $0x0
  pushl $207
80105b7b:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105b80:	e9 93 f1 ff ff       	jmp    80104d18 <alltraps>

80105b85 <vector208>:
.globl vector208
vector208:
  pushl $0
80105b85:	6a 00                	push   $0x0
  pushl $208
80105b87:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105b8c:	e9 87 f1 ff ff       	jmp    80104d18 <alltraps>

80105b91 <vector209>:
.globl vector209
vector209:
  pushl $0
80105b91:	6a 00                	push   $0x0
  pushl $209
80105b93:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105b98:	e9 7b f1 ff ff       	jmp    80104d18 <alltraps>

80105b9d <vector210>:
.globl vector210
vector210:
  pushl $0
80105b9d:	6a 00                	push   $0x0
  pushl $210
80105b9f:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105ba4:	e9 6f f1 ff ff       	jmp    80104d18 <alltraps>

80105ba9 <vector211>:
.globl vector211
vector211:
  pushl $0
80105ba9:	6a 00                	push   $0x0
  pushl $211
80105bab:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105bb0:	e9 63 f1 ff ff       	jmp    80104d18 <alltraps>

80105bb5 <vector212>:
.globl vector212
vector212:
  pushl $0
80105bb5:	6a 00                	push   $0x0
  pushl $212
80105bb7:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105bbc:	e9 57 f1 ff ff       	jmp    80104d18 <alltraps>

80105bc1 <vector213>:
.globl vector213
vector213:
  pushl $0
80105bc1:	6a 00                	push   $0x0
  pushl $213
80105bc3:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105bc8:	e9 4b f1 ff ff       	jmp    80104d18 <alltraps>

80105bcd <vector214>:
.globl vector214
vector214:
  pushl $0
80105bcd:	6a 00                	push   $0x0
  pushl $214
80105bcf:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105bd4:	e9 3f f1 ff ff       	jmp    80104d18 <alltraps>

80105bd9 <vector215>:
.globl vector215
vector215:
  pushl $0
80105bd9:	6a 00                	push   $0x0
  pushl $215
80105bdb:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105be0:	e9 33 f1 ff ff       	jmp    80104d18 <alltraps>

80105be5 <vector216>:
.globl vector216
vector216:
  pushl $0
80105be5:	6a 00                	push   $0x0
  pushl $216
80105be7:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105bec:	e9 27 f1 ff ff       	jmp    80104d18 <alltraps>

80105bf1 <vector217>:
.globl vector217
vector217:
  pushl $0
80105bf1:	6a 00                	push   $0x0
  pushl $217
80105bf3:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105bf8:	e9 1b f1 ff ff       	jmp    80104d18 <alltraps>

80105bfd <vector218>:
.globl vector218
vector218:
  pushl $0
80105bfd:	6a 00                	push   $0x0
  pushl $218
80105bff:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105c04:	e9 0f f1 ff ff       	jmp    80104d18 <alltraps>

80105c09 <vector219>:
.globl vector219
vector219:
  pushl $0
80105c09:	6a 00                	push   $0x0
  pushl $219
80105c0b:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105c10:	e9 03 f1 ff ff       	jmp    80104d18 <alltraps>

80105c15 <vector220>:
.globl vector220
vector220:
  pushl $0
80105c15:	6a 00                	push   $0x0
  pushl $220
80105c17:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105c1c:	e9 f7 f0 ff ff       	jmp    80104d18 <alltraps>

80105c21 <vector221>:
.globl vector221
vector221:
  pushl $0
80105c21:	6a 00                	push   $0x0
  pushl $221
80105c23:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105c28:	e9 eb f0 ff ff       	jmp    80104d18 <alltraps>

80105c2d <vector222>:
.globl vector222
vector222:
  pushl $0
80105c2d:	6a 00                	push   $0x0
  pushl $222
80105c2f:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105c34:	e9 df f0 ff ff       	jmp    80104d18 <alltraps>

80105c39 <vector223>:
.globl vector223
vector223:
  pushl $0
80105c39:	6a 00                	push   $0x0
  pushl $223
80105c3b:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105c40:	e9 d3 f0 ff ff       	jmp    80104d18 <alltraps>

80105c45 <vector224>:
.globl vector224
vector224:
  pushl $0
80105c45:	6a 00                	push   $0x0
  pushl $224
80105c47:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105c4c:	e9 c7 f0 ff ff       	jmp    80104d18 <alltraps>

80105c51 <vector225>:
.globl vector225
vector225:
  pushl $0
80105c51:	6a 00                	push   $0x0
  pushl $225
80105c53:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105c58:	e9 bb f0 ff ff       	jmp    80104d18 <alltraps>

80105c5d <vector226>:
.globl vector226
vector226:
  pushl $0
80105c5d:	6a 00                	push   $0x0
  pushl $226
80105c5f:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105c64:	e9 af f0 ff ff       	jmp    80104d18 <alltraps>

80105c69 <vector227>:
.globl vector227
vector227:
  pushl $0
80105c69:	6a 00                	push   $0x0
  pushl $227
80105c6b:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105c70:	e9 a3 f0 ff ff       	jmp    80104d18 <alltraps>

80105c75 <vector228>:
.globl vector228
vector228:
  pushl $0
80105c75:	6a 00                	push   $0x0
  pushl $228
80105c77:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105c7c:	e9 97 f0 ff ff       	jmp    80104d18 <alltraps>

80105c81 <vector229>:
.globl vector229
vector229:
  pushl $0
80105c81:	6a 00                	push   $0x0
  pushl $229
80105c83:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105c88:	e9 8b f0 ff ff       	jmp    80104d18 <alltraps>

80105c8d <vector230>:
.globl vector230
vector230:
  pushl $0
80105c8d:	6a 00                	push   $0x0
  pushl $230
80105c8f:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105c94:	e9 7f f0 ff ff       	jmp    80104d18 <alltraps>

80105c99 <vector231>:
.globl vector231
vector231:
  pushl $0
80105c99:	6a 00                	push   $0x0
  pushl $231
80105c9b:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105ca0:	e9 73 f0 ff ff       	jmp    80104d18 <alltraps>

80105ca5 <vector232>:
.globl vector232
vector232:
  pushl $0
80105ca5:	6a 00                	push   $0x0
  pushl $232
80105ca7:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105cac:	e9 67 f0 ff ff       	jmp    80104d18 <alltraps>

80105cb1 <vector233>:
.globl vector233
vector233:
  pushl $0
80105cb1:	6a 00                	push   $0x0
  pushl $233
80105cb3:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105cb8:	e9 5b f0 ff ff       	jmp    80104d18 <alltraps>

80105cbd <vector234>:
.globl vector234
vector234:
  pushl $0
80105cbd:	6a 00                	push   $0x0
  pushl $234
80105cbf:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105cc4:	e9 4f f0 ff ff       	jmp    80104d18 <alltraps>

80105cc9 <vector235>:
.globl vector235
vector235:
  pushl $0
80105cc9:	6a 00                	push   $0x0
  pushl $235
80105ccb:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105cd0:	e9 43 f0 ff ff       	jmp    80104d18 <alltraps>

80105cd5 <vector236>:
.globl vector236
vector236:
  pushl $0
80105cd5:	6a 00                	push   $0x0
  pushl $236
80105cd7:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105cdc:	e9 37 f0 ff ff       	jmp    80104d18 <alltraps>

80105ce1 <vector237>:
.globl vector237
vector237:
  pushl $0
80105ce1:	6a 00                	push   $0x0
  pushl $237
80105ce3:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105ce8:	e9 2b f0 ff ff       	jmp    80104d18 <alltraps>

80105ced <vector238>:
.globl vector238
vector238:
  pushl $0
80105ced:	6a 00                	push   $0x0
  pushl $238
80105cef:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105cf4:	e9 1f f0 ff ff       	jmp    80104d18 <alltraps>

80105cf9 <vector239>:
.globl vector239
vector239:
  pushl $0
80105cf9:	6a 00                	push   $0x0
  pushl $239
80105cfb:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105d00:	e9 13 f0 ff ff       	jmp    80104d18 <alltraps>

80105d05 <vector240>:
.globl vector240
vector240:
  pushl $0
80105d05:	6a 00                	push   $0x0
  pushl $240
80105d07:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105d0c:	e9 07 f0 ff ff       	jmp    80104d18 <alltraps>

80105d11 <vector241>:
.globl vector241
vector241:
  pushl $0
80105d11:	6a 00                	push   $0x0
  pushl $241
80105d13:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105d18:	e9 fb ef ff ff       	jmp    80104d18 <alltraps>

80105d1d <vector242>:
.globl vector242
vector242:
  pushl $0
80105d1d:	6a 00                	push   $0x0
  pushl $242
80105d1f:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105d24:	e9 ef ef ff ff       	jmp    80104d18 <alltraps>

80105d29 <vector243>:
.globl vector243
vector243:
  pushl $0
80105d29:	6a 00                	push   $0x0
  pushl $243
80105d2b:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105d30:	e9 e3 ef ff ff       	jmp    80104d18 <alltraps>

80105d35 <vector244>:
.globl vector244
vector244:
  pushl $0
80105d35:	6a 00                	push   $0x0
  pushl $244
80105d37:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105d3c:	e9 d7 ef ff ff       	jmp    80104d18 <alltraps>

80105d41 <vector245>:
.globl vector245
vector245:
  pushl $0
80105d41:	6a 00                	push   $0x0
  pushl $245
80105d43:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105d48:	e9 cb ef ff ff       	jmp    80104d18 <alltraps>

80105d4d <vector246>:
.globl vector246
vector246:
  pushl $0
80105d4d:	6a 00                	push   $0x0
  pushl $246
80105d4f:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105d54:	e9 bf ef ff ff       	jmp    80104d18 <alltraps>

80105d59 <vector247>:
.globl vector247
vector247:
  pushl $0
80105d59:	6a 00                	push   $0x0
  pushl $247
80105d5b:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105d60:	e9 b3 ef ff ff       	jmp    80104d18 <alltraps>

80105d65 <vector248>:
.globl vector248
vector248:
  pushl $0
80105d65:	6a 00                	push   $0x0
  pushl $248
80105d67:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105d6c:	e9 a7 ef ff ff       	jmp    80104d18 <alltraps>

80105d71 <vector249>:
.globl vector249
vector249:
  pushl $0
80105d71:	6a 00                	push   $0x0
  pushl $249
80105d73:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105d78:	e9 9b ef ff ff       	jmp    80104d18 <alltraps>

80105d7d <vector250>:
.globl vector250
vector250:
  pushl $0
80105d7d:	6a 00                	push   $0x0
  pushl $250
80105d7f:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105d84:	e9 8f ef ff ff       	jmp    80104d18 <alltraps>

80105d89 <vector251>:
.globl vector251
vector251:
  pushl $0
80105d89:	6a 00                	push   $0x0
  pushl $251
80105d8b:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105d90:	e9 83 ef ff ff       	jmp    80104d18 <alltraps>

80105d95 <vector252>:
.globl vector252
vector252:
  pushl $0
80105d95:	6a 00                	push   $0x0
  pushl $252
80105d97:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105d9c:	e9 77 ef ff ff       	jmp    80104d18 <alltraps>

80105da1 <vector253>:
.globl vector253
vector253:
  pushl $0
80105da1:	6a 00                	push   $0x0
  pushl $253
80105da3:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105da8:	e9 6b ef ff ff       	jmp    80104d18 <alltraps>

80105dad <vector254>:
.globl vector254
vector254:
  pushl $0
80105dad:	6a 00                	push   $0x0
  pushl $254
80105daf:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105db4:	e9 5f ef ff ff       	jmp    80104d18 <alltraps>

80105db9 <vector255>:
.globl vector255
vector255:
  pushl $0
80105db9:	6a 00                	push   $0x0
  pushl $255
80105dbb:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105dc0:	e9 53 ef ff ff       	jmp    80104d18 <alltraps>

80105dc5 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105dc5:	55                   	push   %ebp
80105dc6:	89 e5                	mov    %esp,%ebp
80105dc8:	57                   	push   %edi
80105dc9:	56                   	push   %esi
80105dca:	53                   	push   %ebx
80105dcb:	83 ec 0c             	sub    $0xc,%esp
80105dce:	89 d3                	mov    %edx,%ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105dd0:	c1 ea 16             	shr    $0x16,%edx
80105dd3:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105dd6:	8b 37                	mov    (%edi),%esi
80105dd8:	f7 c6 01 00 00 00    	test   $0x1,%esi
80105dde:	74 20                	je     80105e00 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105de0:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
80105de6:	81 c6 00 00 00 80    	add    $0x80000000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105dec:	c1 eb 0c             	shr    $0xc,%ebx
80105def:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
80105df5:	8d 04 9e             	lea    (%esi,%ebx,4),%eax
}
80105df8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105dfb:	5b                   	pop    %ebx
80105dfc:	5e                   	pop    %esi
80105dfd:	5f                   	pop    %edi
80105dfe:	5d                   	pop    %ebp
80105dff:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105e00:	85 c9                	test   %ecx,%ecx
80105e02:	74 2b                	je     80105e2f <walkpgdir+0x6a>
80105e04:	e8 35 c2 ff ff       	call   8010203e <kalloc>
80105e09:	89 c6                	mov    %eax,%esi
80105e0b:	85 c0                	test   %eax,%eax
80105e0d:	74 20                	je     80105e2f <walkpgdir+0x6a>
    memset(pgtab, 0, PGSIZE);
80105e0f:	83 ec 04             	sub    $0x4,%esp
80105e12:	68 00 10 00 00       	push   $0x1000
80105e17:	6a 00                	push   $0x0
80105e19:	50                   	push   %eax
80105e1a:	e8 87 dd ff ff       	call   80103ba6 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105e1f:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80105e25:	83 c8 07             	or     $0x7,%eax
80105e28:	89 07                	mov    %eax,(%edi)
80105e2a:	83 c4 10             	add    $0x10,%esp
80105e2d:	eb bd                	jmp    80105dec <walkpgdir+0x27>
      return 0;
80105e2f:	b8 00 00 00 00       	mov    $0x0,%eax
80105e34:	eb c2                	jmp    80105df8 <walkpgdir+0x33>

80105e36 <seginit>:
{
80105e36:	55                   	push   %ebp
80105e37:	89 e5                	mov    %esp,%ebp
80105e39:	57                   	push   %edi
80105e3a:	56                   	push   %esi
80105e3b:	53                   	push   %ebx
80105e3c:	83 ec 2c             	sub    $0x2c,%esp
  c = &cpus[cpuid()];
80105e3f:	e8 c1 d2 ff ff       	call   80103105 <cpuid>
80105e44:	89 c3                	mov    %eax,%ebx
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105e46:	8d 14 80             	lea    (%eax,%eax,4),%edx
80105e49:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
80105e4c:	8d 04 01             	lea    (%ecx,%eax,1),%eax
80105e4f:	c1 e0 04             	shl    $0x4,%eax
80105e52:	66 c7 80 18 18 11 80 	movw   $0xffff,-0x7feee7e8(%eax)
80105e59:	ff ff 
80105e5b:	66 c7 80 1a 18 11 80 	movw   $0x0,-0x7feee7e6(%eax)
80105e62:	00 00 
80105e64:	c6 80 1c 18 11 80 00 	movb   $0x0,-0x7feee7e4(%eax)
80105e6b:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
80105e6e:	01 d9                	add    %ebx,%ecx
80105e70:	c1 e1 04             	shl    $0x4,%ecx
80105e73:	0f b6 b1 1d 18 11 80 	movzbl -0x7feee7e3(%ecx),%esi
80105e7a:	83 e6 f0             	and    $0xfffffff0,%esi
80105e7d:	89 f7                	mov    %esi,%edi
80105e7f:	83 cf 0a             	or     $0xa,%edi
80105e82:	89 fa                	mov    %edi,%edx
80105e84:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
80105e8a:	83 ce 1a             	or     $0x1a,%esi
80105e8d:	89 f2                	mov    %esi,%edx
80105e8f:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
80105e95:	83 e6 9f             	and    $0xffffff9f,%esi
80105e98:	89 f2                	mov    %esi,%edx
80105e9a:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
80105ea0:	83 ce 80             	or     $0xffffff80,%esi
80105ea3:	89 f2                	mov    %esi,%edx
80105ea5:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
80105eab:	0f b6 b1 1e 18 11 80 	movzbl -0x7feee7e2(%ecx),%esi
80105eb2:	83 ce 0f             	or     $0xf,%esi
80105eb5:	89 f2                	mov    %esi,%edx
80105eb7:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
80105ebd:	89 f7                	mov    %esi,%edi
80105ebf:	83 e7 ef             	and    $0xffffffef,%edi
80105ec2:	89 fa                	mov    %edi,%edx
80105ec4:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
80105eca:	83 e6 cf             	and    $0xffffffcf,%esi
80105ecd:	89 f2                	mov    %esi,%edx
80105ecf:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
80105ed5:	89 f7                	mov    %esi,%edi
80105ed7:	83 cf 40             	or     $0x40,%edi
80105eda:	89 fa                	mov    %edi,%edx
80105edc:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
80105ee2:	83 ce c0             	or     $0xffffffc0,%esi
80105ee5:	89 f2                	mov    %esi,%edx
80105ee7:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
80105eed:	c6 80 1f 18 11 80 00 	movb   $0x0,-0x7feee7e1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105ef4:	66 c7 80 20 18 11 80 	movw   $0xffff,-0x7feee7e0(%eax)
80105efb:	ff ff 
80105efd:	66 c7 80 22 18 11 80 	movw   $0x0,-0x7feee7de(%eax)
80105f04:	00 00 
80105f06:	c6 80 24 18 11 80 00 	movb   $0x0,-0x7feee7dc(%eax)
80105f0d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80105f10:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
80105f13:	c1 e1 04             	shl    $0x4,%ecx
80105f16:	0f b6 b1 25 18 11 80 	movzbl -0x7feee7db(%ecx),%esi
80105f1d:	83 e6 f0             	and    $0xfffffff0,%esi
80105f20:	89 f7                	mov    %esi,%edi
80105f22:	83 cf 02             	or     $0x2,%edi
80105f25:	89 fa                	mov    %edi,%edx
80105f27:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
80105f2d:	83 ce 12             	or     $0x12,%esi
80105f30:	89 f2                	mov    %esi,%edx
80105f32:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
80105f38:	83 e6 9f             	and    $0xffffff9f,%esi
80105f3b:	89 f2                	mov    %esi,%edx
80105f3d:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
80105f43:	83 ce 80             	or     $0xffffff80,%esi
80105f46:	89 f2                	mov    %esi,%edx
80105f48:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
80105f4e:	0f b6 b1 26 18 11 80 	movzbl -0x7feee7da(%ecx),%esi
80105f55:	83 ce 0f             	or     $0xf,%esi
80105f58:	89 f2                	mov    %esi,%edx
80105f5a:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
80105f60:	89 f7                	mov    %esi,%edi
80105f62:	83 e7 ef             	and    $0xffffffef,%edi
80105f65:	89 fa                	mov    %edi,%edx
80105f67:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
80105f6d:	83 e6 cf             	and    $0xffffffcf,%esi
80105f70:	89 f2                	mov    %esi,%edx
80105f72:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
80105f78:	89 f7                	mov    %esi,%edi
80105f7a:	83 cf 40             	or     $0x40,%edi
80105f7d:	89 fa                	mov    %edi,%edx
80105f7f:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
80105f85:	83 ce c0             	or     $0xffffffc0,%esi
80105f88:	89 f2                	mov    %esi,%edx
80105f8a:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
80105f90:	c6 80 27 18 11 80 00 	movb   $0x0,-0x7feee7d9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105f97:	66 c7 80 28 18 11 80 	movw   $0xffff,-0x7feee7d8(%eax)
80105f9e:	ff ff 
80105fa0:	66 c7 80 2a 18 11 80 	movw   $0x0,-0x7feee7d6(%eax)
80105fa7:	00 00 
80105fa9:	c6 80 2c 18 11 80 00 	movb   $0x0,-0x7feee7d4(%eax)
80105fb0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80105fb3:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
80105fb6:	c1 e1 04             	shl    $0x4,%ecx
80105fb9:	0f b6 b1 2d 18 11 80 	movzbl -0x7feee7d3(%ecx),%esi
80105fc0:	83 e6 f0             	and    $0xfffffff0,%esi
80105fc3:	89 f7                	mov    %esi,%edi
80105fc5:	83 cf 0a             	or     $0xa,%edi
80105fc8:	89 fa                	mov    %edi,%edx
80105fca:	88 91 2d 18 11 80    	mov    %dl,-0x7feee7d3(%ecx)
80105fd0:	89 f7                	mov    %esi,%edi
80105fd2:	83 cf 1a             	or     $0x1a,%edi
80105fd5:	89 fa                	mov    %edi,%edx
80105fd7:	88 91 2d 18 11 80    	mov    %dl,-0x7feee7d3(%ecx)
80105fdd:	83 ce 7a             	or     $0x7a,%esi
80105fe0:	89 f2                	mov    %esi,%edx
80105fe2:	88 91 2d 18 11 80    	mov    %dl,-0x7feee7d3(%ecx)
80105fe8:	c6 81 2d 18 11 80 fa 	movb   $0xfa,-0x7feee7d3(%ecx)
80105fef:	0f b6 b1 2e 18 11 80 	movzbl -0x7feee7d2(%ecx),%esi
80105ff6:	83 ce 0f             	or     $0xf,%esi
80105ff9:	89 f2                	mov    %esi,%edx
80105ffb:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
80106001:	89 f7                	mov    %esi,%edi
80106003:	83 e7 ef             	and    $0xffffffef,%edi
80106006:	89 fa                	mov    %edi,%edx
80106008:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
8010600e:	83 e6 cf             	and    $0xffffffcf,%esi
80106011:	89 f2                	mov    %esi,%edx
80106013:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
80106019:	89 f7                	mov    %esi,%edi
8010601b:	83 cf 40             	or     $0x40,%edi
8010601e:	89 fa                	mov    %edi,%edx
80106020:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
80106026:	83 ce c0             	or     $0xffffffc0,%esi
80106029:	89 f2                	mov    %esi,%edx
8010602b:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
80106031:	c6 80 2f 18 11 80 00 	movb   $0x0,-0x7feee7d1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80106038:	66 c7 80 30 18 11 80 	movw   $0xffff,-0x7feee7d0(%eax)
8010603f:	ff ff 
80106041:	66 c7 80 32 18 11 80 	movw   $0x0,-0x7feee7ce(%eax)
80106048:	00 00 
8010604a:	c6 80 34 18 11 80 00 	movb   $0x0,-0x7feee7cc(%eax)
80106051:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80106054:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
80106057:	c1 e1 04             	shl    $0x4,%ecx
8010605a:	0f b6 b1 35 18 11 80 	movzbl -0x7feee7cb(%ecx),%esi
80106061:	83 e6 f0             	and    $0xfffffff0,%esi
80106064:	89 f7                	mov    %esi,%edi
80106066:	83 cf 02             	or     $0x2,%edi
80106069:	89 fa                	mov    %edi,%edx
8010606b:	88 91 35 18 11 80    	mov    %dl,-0x7feee7cb(%ecx)
80106071:	89 f7                	mov    %esi,%edi
80106073:	83 cf 12             	or     $0x12,%edi
80106076:	89 fa                	mov    %edi,%edx
80106078:	88 91 35 18 11 80    	mov    %dl,-0x7feee7cb(%ecx)
8010607e:	83 ce 72             	or     $0x72,%esi
80106081:	89 f2                	mov    %esi,%edx
80106083:	88 91 35 18 11 80    	mov    %dl,-0x7feee7cb(%ecx)
80106089:	c6 81 35 18 11 80 f2 	movb   $0xf2,-0x7feee7cb(%ecx)
80106090:	0f b6 b1 36 18 11 80 	movzbl -0x7feee7ca(%ecx),%esi
80106097:	83 ce 0f             	or     $0xf,%esi
8010609a:	89 f2                	mov    %esi,%edx
8010609c:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
801060a2:	89 f7                	mov    %esi,%edi
801060a4:	83 e7 ef             	and    $0xffffffef,%edi
801060a7:	89 fa                	mov    %edi,%edx
801060a9:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
801060af:	83 e6 cf             	and    $0xffffffcf,%esi
801060b2:	89 f2                	mov    %esi,%edx
801060b4:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
801060ba:	89 f7                	mov    %esi,%edi
801060bc:	83 cf 40             	or     $0x40,%edi
801060bf:	89 fa                	mov    %edi,%edx
801060c1:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
801060c7:	83 ce c0             	or     $0xffffffc0,%esi
801060ca:	89 f2                	mov    %esi,%edx
801060cc:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
801060d2:	c6 80 37 18 11 80 00 	movb   $0x0,-0x7feee7c9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801060d9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801060dc:	01 da                	add    %ebx,%edx
801060de:	c1 e2 04             	shl    $0x4,%edx
801060e1:	81 c2 10 18 11 80    	add    $0x80111810,%edx
  pd[0] = size-1;
801060e7:	66 c7 45 e2 2f 00    	movw   $0x2f,-0x1e(%ebp)
  pd[1] = (uint)p;
801060ed:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
  pd[2] = (uint)p >> 16;
801060f1:	c1 ea 10             	shr    $0x10,%edx
801060f4:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801060f8:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801060fb:	0f 01 10             	lgdtl  (%eax)
}
801060fe:	83 c4 2c             	add    $0x2c,%esp
80106101:	5b                   	pop    %ebx
80106102:	5e                   	pop    %esi
80106103:	5f                   	pop    %edi
80106104:	5d                   	pop    %ebp
80106105:	c3                   	ret    

80106106 <page_fault_error>:
// are set
// Return an "uint" value with the flags activated in the entry
// of address in the page table
uint
page_fault_error(pde_t *pgdir, uint va)
{
80106106:	55                   	push   %ebp
80106107:	89 e5                	mov    %esp,%ebp
80106109:	83 ec 08             	sub    $0x8,%esp
	uint error;
  char *a;
  pte_t *pte;

  a = (char*)PGROUNDDOWN(va);
8010610c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010610f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  if( (pte = walkpgdir(pgdir, a, 0)) == 0)
80106115:	b9 00 00 00 00       	mov    $0x0,%ecx
8010611a:	8b 45 08             	mov    0x8(%ebp),%eax
8010611d:	e8 a3 fc ff ff       	call   80105dc5 <walkpgdir>
80106122:	85 c0                	test   %eax,%eax
80106124:	74 07                	je     8010612d <page_fault_error+0x27>
    return -1;
		
	error = *pte & 0x1F;
80106126:	8b 00                	mov    (%eax),%eax
80106128:	83 e0 1f             	and    $0x1f,%eax
	
  return error;
}
8010612b:	c9                   	leave  
8010612c:	c3                   	ret    
    return -1;
8010612d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106132:	eb f7                	jmp    8010612b <page_fault_error+0x25>

80106134 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80106134:	55                   	push   %ebp
80106135:	89 e5                	mov    %esp,%ebp
80106137:	57                   	push   %edi
80106138:	56                   	push   %esi
80106139:	53                   	push   %ebx
8010613a:	83 ec 0c             	sub    $0xc,%esp
8010613d:	8b 7d 0c             	mov    0xc(%ebp),%edi
80106140:	8b 75 14             	mov    0x14(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80106143:	89 fb                	mov    %edi,%ebx
80106145:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010614b:	03 7d 10             	add    0x10(%ebp),%edi
8010614e:	4f                   	dec    %edi
8010614f:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106155:	b9 01 00 00 00       	mov    $0x1,%ecx
8010615a:	89 da                	mov    %ebx,%edx
8010615c:	8b 45 08             	mov    0x8(%ebp),%eax
8010615f:	e8 61 fc ff ff       	call   80105dc5 <walkpgdir>
80106164:	85 c0                	test   %eax,%eax
80106166:	74 2e                	je     80106196 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80106168:	f6 00 01             	testb  $0x1,(%eax)
8010616b:	75 1c                	jne    80106189 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
8010616d:	89 f2                	mov    %esi,%edx
8010616f:	0b 55 18             	or     0x18(%ebp),%edx
80106172:	83 ca 01             	or     $0x1,%edx
80106175:	89 10                	mov    %edx,(%eax)
    if(a == last)
80106177:	39 fb                	cmp    %edi,%ebx
80106179:	74 28                	je     801061a3 <mappages+0x6f>
      break;
    a += PGSIZE;
8010617b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80106181:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106187:	eb cc                	jmp    80106155 <mappages+0x21>
      panic("remap");
80106189:	83 ec 0c             	sub    $0xc,%esp
8010618c:	68 c4 72 10 80       	push   $0x801072c4
80106191:	e8 ab a1 ff ff       	call   80100341 <panic>
      return -1;
80106196:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
8010619b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010619e:	5b                   	pop    %ebx
8010619f:	5e                   	pop    %esi
801061a0:	5f                   	pop    %edi
801061a1:	5d                   	pop    %ebp
801061a2:	c3                   	ret    
  return 0;
801061a3:	b8 00 00 00 00       	mov    $0x0,%eax
801061a8:	eb f1                	jmp    8010619b <mappages+0x67>

801061aa <switchkvm>:
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801061aa:	a1 c4 46 11 80       	mov    0x801146c4,%eax
801061af:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801061b4:	0f 22 d8             	mov    %eax,%cr3
}
801061b7:	c3                   	ret    

801061b8 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801061b8:	55                   	push   %ebp
801061b9:	89 e5                	mov    %esp,%ebp
801061bb:	57                   	push   %edi
801061bc:	56                   	push   %esi
801061bd:	53                   	push   %ebx
801061be:	83 ec 1c             	sub    $0x1c,%esp
801061c1:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
801061c4:	85 f6                	test   %esi,%esi
801061c6:	0f 84 21 01 00 00    	je     801062ed <switchuvm+0x135>
    panic("switchuvm: no process");
  if(p->kstack == 0)
801061cc:	83 7e 10 00          	cmpl   $0x0,0x10(%esi)
801061d0:	0f 84 24 01 00 00    	je     801062fa <switchuvm+0x142>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
801061d6:	83 7e 0c 00          	cmpl   $0x0,0xc(%esi)
801061da:	0f 84 27 01 00 00    	je     80106307 <switchuvm+0x14f>
    panic("switchuvm: no pgdir");

  pushcli();
801061e0:	e8 3b d8 ff ff       	call   80103a20 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801061e5:	e8 b7 ce ff ff       	call   801030a1 <mycpu>
801061ea:	89 c3                	mov    %eax,%ebx
801061ec:	e8 b0 ce ff ff       	call   801030a1 <mycpu>
801061f1:	8d 78 08             	lea    0x8(%eax),%edi
801061f4:	e8 a8 ce ff ff       	call   801030a1 <mycpu>
801061f9:	83 c0 08             	add    $0x8,%eax
801061fc:	c1 e8 10             	shr    $0x10,%eax
801061ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106202:	e8 9a ce ff ff       	call   801030a1 <mycpu>
80106207:	83 c0 08             	add    $0x8,%eax
8010620a:	c1 e8 18             	shr    $0x18,%eax
8010620d:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106214:	67 00 
80106216:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
8010621d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
80106220:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106226:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010622c:	83 e2 f0             	and    $0xfffffff0,%edx
8010622f:	88 d1                	mov    %dl,%cl
80106231:	83 c9 09             	or     $0x9,%ecx
80106234:	88 8b 9d 00 00 00    	mov    %cl,0x9d(%ebx)
8010623a:	83 ca 19             	or     $0x19,%edx
8010623d:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106243:	83 e2 9f             	and    $0xffffff9f,%edx
80106246:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010624c:	83 ca 80             	or     $0xffffff80,%edx
8010624f:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106255:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
8010625b:	88 d1                	mov    %dl,%cl
8010625d:	83 e1 f0             	and    $0xfffffff0,%ecx
80106260:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
80106266:	88 d1                	mov    %dl,%cl
80106268:	83 e1 e0             	and    $0xffffffe0,%ecx
8010626b:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
80106271:	83 e2 c0             	and    $0xffffffc0,%edx
80106274:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010627a:	83 ca 40             	or     $0x40,%edx
8010627d:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80106283:	83 e2 7f             	and    $0x7f,%edx
80106286:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010628c:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80106292:	e8 0a ce ff ff       	call   801030a1 <mycpu>
80106297:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
8010629d:	83 e2 ef             	and    $0xffffffef,%edx
801062a0:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801062a6:	e8 f6 cd ff ff       	call   801030a1 <mycpu>
801062ab:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801062b1:	8b 5e 10             	mov    0x10(%esi),%ebx
801062b4:	e8 e8 cd ff ff       	call   801030a1 <mycpu>
801062b9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801062bf:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801062c2:	e8 da cd ff ff       	call   801030a1 <mycpu>
801062c7:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801062cd:	b8 28 00 00 00       	mov    $0x28,%eax
801062d2:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
801062d5:	8b 46 0c             	mov    0xc(%esi),%eax
801062d8:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801062dd:	0f 22 d8             	mov    %eax,%cr3
  popcli();
801062e0:	e8 76 d7 ff ff       	call   80103a5b <popcli>
}
801062e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062e8:	5b                   	pop    %ebx
801062e9:	5e                   	pop    %esi
801062ea:	5f                   	pop    %edi
801062eb:	5d                   	pop    %ebp
801062ec:	c3                   	ret    
    panic("switchuvm: no process");
801062ed:	83 ec 0c             	sub    $0xc,%esp
801062f0:	68 ca 72 10 80       	push   $0x801072ca
801062f5:	e8 47 a0 ff ff       	call   80100341 <panic>
    panic("switchuvm: no kstack");
801062fa:	83 ec 0c             	sub    $0xc,%esp
801062fd:	68 e0 72 10 80       	push   $0x801072e0
80106302:	e8 3a a0 ff ff       	call   80100341 <panic>
    panic("switchuvm: no pgdir");
80106307:	83 ec 0c             	sub    $0xc,%esp
8010630a:	68 f5 72 10 80       	push   $0x801072f5
8010630f:	e8 2d a0 ff ff       	call   80100341 <panic>

80106314 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80106314:	55                   	push   %ebp
80106315:	89 e5                	mov    %esp,%ebp
80106317:	56                   	push   %esi
80106318:	53                   	push   %ebx
80106319:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
8010631c:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106322:	77 4b                	ja     8010636f <inituvm+0x5b>
    panic("inituvm: more than a page");
  mem = kalloc();
80106324:	e8 15 bd ff ff       	call   8010203e <kalloc>
80106329:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
8010632b:	83 ec 04             	sub    $0x4,%esp
8010632e:	68 00 10 00 00       	push   $0x1000
80106333:	6a 00                	push   $0x0
80106335:	50                   	push   %eax
80106336:	e8 6b d8 ff ff       	call   80103ba6 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010633b:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
80106342:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106348:	50                   	push   %eax
80106349:	68 00 10 00 00       	push   $0x1000
8010634e:	6a 00                	push   $0x0
80106350:	ff 75 08             	push   0x8(%ebp)
80106353:	e8 dc fd ff ff       	call   80106134 <mappages>
  memmove(mem, init, sz);
80106358:	83 c4 1c             	add    $0x1c,%esp
8010635b:	56                   	push   %esi
8010635c:	ff 75 0c             	push   0xc(%ebp)
8010635f:	53                   	push   %ebx
80106360:	e8 b7 d8 ff ff       	call   80103c1c <memmove>
}
80106365:	83 c4 10             	add    $0x10,%esp
80106368:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010636b:	5b                   	pop    %ebx
8010636c:	5e                   	pop    %esi
8010636d:	5d                   	pop    %ebp
8010636e:	c3                   	ret    
    panic("inituvm: more than a page");
8010636f:	83 ec 0c             	sub    $0xc,%esp
80106372:	68 09 73 10 80       	push   $0x80107309
80106377:	e8 c5 9f ff ff       	call   80100341 <panic>

8010637c <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010637c:	55                   	push   %ebp
8010637d:	89 e5                	mov    %esp,%ebp
8010637f:	57                   	push   %edi
80106380:	56                   	push   %esi
80106381:	53                   	push   %ebx
80106382:	83 ec 0c             	sub    $0xc,%esp
80106385:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106388:	89 fb                	mov    %edi,%ebx
8010638a:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
80106390:	74 3c                	je     801063ce <loaduvm+0x52>
    panic("loaduvm: addr must be page aligned");
80106392:	83 ec 0c             	sub    $0xc,%esp
80106395:	68 c4 73 10 80       	push   $0x801073c4
8010639a:	e8 a2 9f ff ff       	call   80100341 <panic>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
8010639f:	83 ec 0c             	sub    $0xc,%esp
801063a2:	68 23 73 10 80       	push   $0x80107323
801063a7:	e8 95 9f ff ff       	call   80100341 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
801063ac:	05 00 00 00 80       	add    $0x80000000,%eax
801063b1:	56                   	push   %esi
801063b2:	89 da                	mov    %ebx,%edx
801063b4:	03 55 14             	add    0x14(%ebp),%edx
801063b7:	52                   	push   %edx
801063b8:	50                   	push   %eax
801063b9:	ff 75 10             	push   0x10(%ebp)
801063bc:	e8 49 b3 ff ff       	call   8010170a <readi>
801063c1:	83 c4 10             	add    $0x10,%esp
801063c4:	39 f0                	cmp    %esi,%eax
801063c6:	75 47                	jne    8010640f <loaduvm+0x93>
  for(i = 0; i < sz; i += PGSIZE){
801063c8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801063ce:	3b 5d 18             	cmp    0x18(%ebp),%ebx
801063d1:	73 2f                	jae    80106402 <loaduvm+0x86>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801063d3:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
801063d6:	b9 00 00 00 00       	mov    $0x0,%ecx
801063db:	8b 45 08             	mov    0x8(%ebp),%eax
801063de:	e8 e2 f9 ff ff       	call   80105dc5 <walkpgdir>
801063e3:	85 c0                	test   %eax,%eax
801063e5:	74 b8                	je     8010639f <loaduvm+0x23>
    pa = PTE_ADDR(*pte);
801063e7:	8b 00                	mov    (%eax),%eax
801063e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801063ee:	8b 75 18             	mov    0x18(%ebp),%esi
801063f1:	29 de                	sub    %ebx,%esi
801063f3:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801063f9:	76 b1                	jbe    801063ac <loaduvm+0x30>
      n = PGSIZE;
801063fb:	be 00 10 00 00       	mov    $0x1000,%esi
80106400:	eb aa                	jmp    801063ac <loaduvm+0x30>
      return -1;
  }
  return 0;
80106402:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106407:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010640a:	5b                   	pop    %ebx
8010640b:	5e                   	pop    %esi
8010640c:	5f                   	pop    %edi
8010640d:	5d                   	pop    %ebp
8010640e:	c3                   	ret    
      return -1;
8010640f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106414:	eb f1                	jmp    80106407 <loaduvm+0x8b>

80106416 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106416:	55                   	push   %ebp
80106417:	89 e5                	mov    %esp,%ebp
80106419:	57                   	push   %edi
8010641a:	56                   	push   %esi
8010641b:	53                   	push   %ebx
8010641c:	83 ec 0c             	sub    $0xc,%esp
8010641f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106422:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106425:	73 11                	jae    80106438 <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
80106427:	8b 45 10             	mov    0x10(%ebp),%eax
8010642a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106430:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106436:	eb 17                	jmp    8010644f <deallocuvm+0x39>
    return oldsz;
80106438:	89 f8                	mov    %edi,%eax
8010643a:	eb 62                	jmp    8010649e <deallocuvm+0x88>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010643c:	c1 eb 16             	shr    $0x16,%ebx
8010643f:	43                   	inc    %ebx
80106440:	c1 e3 16             	shl    $0x16,%ebx
80106443:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106449:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010644f:	39 fb                	cmp    %edi,%ebx
80106451:	73 48                	jae    8010649b <deallocuvm+0x85>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106453:	b9 00 00 00 00       	mov    $0x0,%ecx
80106458:	89 da                	mov    %ebx,%edx
8010645a:	8b 45 08             	mov    0x8(%ebp),%eax
8010645d:	e8 63 f9 ff ff       	call   80105dc5 <walkpgdir>
80106462:	89 c6                	mov    %eax,%esi
    if(!pte)
80106464:	85 c0                	test   %eax,%eax
80106466:	74 d4                	je     8010643c <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
80106468:	8b 00                	mov    (%eax),%eax
8010646a:	a8 01                	test   $0x1,%al
8010646c:	74 db                	je     80106449 <deallocuvm+0x33>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
8010646e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106473:	74 19                	je     8010648e <deallocuvm+0x78>
        panic("kfree");
      char *v = P2V(pa);
80106475:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010647a:	83 ec 0c             	sub    $0xc,%esp
8010647d:	50                   	push   %eax
8010647e:	e8 a4 ba ff ff       	call   80101f27 <kfree>
      *pte = 0;
80106483:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80106489:	83 c4 10             	add    $0x10,%esp
8010648c:	eb bb                	jmp    80106449 <deallocuvm+0x33>
        panic("kfree");
8010648e:	83 ec 0c             	sub    $0xc,%esp
80106491:	68 a6 6b 10 80       	push   $0x80106ba6
80106496:	e8 a6 9e ff ff       	call   80100341 <panic>
    }
  }
  return newsz;
8010649b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010649e:	8d 65 f4             	lea    -0xc(%ebp),%esp
801064a1:	5b                   	pop    %ebx
801064a2:	5e                   	pop    %esi
801064a3:	5f                   	pop    %edi
801064a4:	5d                   	pop    %ebp
801064a5:	c3                   	ret    

801064a6 <allocuvm>:
{
801064a6:	55                   	push   %ebp
801064a7:	89 e5                	mov    %esp,%ebp
801064a9:	57                   	push   %edi
801064aa:	56                   	push   %esi
801064ab:	53                   	push   %ebx
801064ac:	83 ec 1c             	sub    $0x1c,%esp
801064af:	8b 7d 08             	mov    0x8(%ebp),%edi
  if(newsz >= KERNBASE)
801064b2:	8b 45 10             	mov    0x10(%ebp),%eax
801064b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801064b8:	85 c0                	test   %eax,%eax
801064ba:	0f 88 c1 00 00 00    	js     80106581 <allocuvm+0xdb>
  if(newsz < oldsz)
801064c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801064c3:	39 45 10             	cmp    %eax,0x10(%ebp)
801064c6:	72 5c                	jb     80106524 <allocuvm+0x7e>
  a = PGROUNDUP(oldsz);
801064c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801064cb:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
801064d1:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
801064d7:	3b 75 10             	cmp    0x10(%ebp),%esi
801064da:	0f 83 a8 00 00 00    	jae    80106588 <allocuvm+0xe2>
    mem = kalloc();
801064e0:	e8 59 bb ff ff       	call   8010203e <kalloc>
801064e5:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
801064e7:	85 c0                	test   %eax,%eax
801064e9:	74 3e                	je     80106529 <allocuvm+0x83>
    memset(mem, 0, PGSIZE);
801064eb:	83 ec 04             	sub    $0x4,%esp
801064ee:	68 00 10 00 00       	push   $0x1000
801064f3:	6a 00                	push   $0x0
801064f5:	50                   	push   %eax
801064f6:	e8 ab d6 ff ff       	call   80103ba6 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801064fb:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
80106502:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106508:	50                   	push   %eax
80106509:	68 00 10 00 00       	push   $0x1000
8010650e:	56                   	push   %esi
8010650f:	57                   	push   %edi
80106510:	e8 1f fc ff ff       	call   80106134 <mappages>
80106515:	83 c4 20             	add    $0x20,%esp
80106518:	85 c0                	test   %eax,%eax
8010651a:	78 35                	js     80106551 <allocuvm+0xab>
  for(; a < newsz; a += PGSIZE){
8010651c:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106522:	eb b3                	jmp    801064d7 <allocuvm+0x31>
    return oldsz;
80106524:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106527:	eb 5f                	jmp    80106588 <allocuvm+0xe2>
      cprintf("allocuvm out of memory\n");
80106529:	83 ec 0c             	sub    $0xc,%esp
8010652c:	68 41 73 10 80       	push   $0x80107341
80106531:	e8 a4 a0 ff ff       	call   801005da <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106536:	83 c4 0c             	add    $0xc,%esp
80106539:	ff 75 0c             	push   0xc(%ebp)
8010653c:	ff 75 10             	push   0x10(%ebp)
8010653f:	57                   	push   %edi
80106540:	e8 d1 fe ff ff       	call   80106416 <deallocuvm>
      return 0;
80106545:	83 c4 10             	add    $0x10,%esp
80106548:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010654f:	eb 37                	jmp    80106588 <allocuvm+0xe2>
      cprintf("allocuvm out of memory (2)\n");
80106551:	83 ec 0c             	sub    $0xc,%esp
80106554:	68 59 73 10 80       	push   $0x80107359
80106559:	e8 7c a0 ff ff       	call   801005da <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010655e:	83 c4 0c             	add    $0xc,%esp
80106561:	ff 75 0c             	push   0xc(%ebp)
80106564:	ff 75 10             	push   0x10(%ebp)
80106567:	57                   	push   %edi
80106568:	e8 a9 fe ff ff       	call   80106416 <deallocuvm>
      kfree(mem);
8010656d:	89 1c 24             	mov    %ebx,(%esp)
80106570:	e8 b2 b9 ff ff       	call   80101f27 <kfree>
      return 0;
80106575:	83 c4 10             	add    $0x10,%esp
80106578:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010657f:	eb 07                	jmp    80106588 <allocuvm+0xe2>
    return 0;
80106581:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106588:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010658b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010658e:	5b                   	pop    %ebx
8010658f:	5e                   	pop    %esi
80106590:	5f                   	pop    %edi
80106591:	5d                   	pop    %ebp
80106592:	c3                   	ret    

80106593 <freevm>:

// Free a page table and all the physical memory pages
// in the user part if dodeallocuvm is not zero
void
freevm(pde_t *pgdir, int dodeallocuvm)
{
80106593:	55                   	push   %ebp
80106594:	89 e5                	mov    %esp,%ebp
80106596:	56                   	push   %esi
80106597:	53                   	push   %ebx
80106598:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
8010659b:	85 f6                	test   %esi,%esi
8010659d:	74 0d                	je     801065ac <freevm+0x19>
    panic("freevm: no pgdir");
  if (dodeallocuvm)
8010659f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801065a3:	75 14                	jne    801065b9 <freevm+0x26>
{
801065a5:	bb 00 00 00 00       	mov    $0x0,%ebx
801065aa:	eb 23                	jmp    801065cf <freevm+0x3c>
    panic("freevm: no pgdir");
801065ac:	83 ec 0c             	sub    $0xc,%esp
801065af:	68 75 73 10 80       	push   $0x80107375
801065b4:	e8 88 9d ff ff       	call   80100341 <panic>
    deallocuvm(pgdir, KERNBASE, 0);
801065b9:	83 ec 04             	sub    $0x4,%esp
801065bc:	6a 00                	push   $0x0
801065be:	68 00 00 00 80       	push   $0x80000000
801065c3:	56                   	push   %esi
801065c4:	e8 4d fe ff ff       	call   80106416 <deallocuvm>
801065c9:	83 c4 10             	add    $0x10,%esp
801065cc:	eb d7                	jmp    801065a5 <freevm+0x12>
  for(i = 0; i < NPDENTRIES; i++){
801065ce:	43                   	inc    %ebx
801065cf:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
801065d5:	77 1f                	ja     801065f6 <freevm+0x63>
    if(pgdir[i] & PTE_P){
801065d7:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
801065da:	a8 01                	test   $0x1,%al
801065dc:	74 f0                	je     801065ce <freevm+0x3b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801065de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801065e3:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801065e8:	83 ec 0c             	sub    $0xc,%esp
801065eb:	50                   	push   %eax
801065ec:	e8 36 b9 ff ff       	call   80101f27 <kfree>
801065f1:	83 c4 10             	add    $0x10,%esp
801065f4:	eb d8                	jmp    801065ce <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
801065f6:	83 ec 0c             	sub    $0xc,%esp
801065f9:	56                   	push   %esi
801065fa:	e8 28 b9 ff ff       	call   80101f27 <kfree>
}
801065ff:	83 c4 10             	add    $0x10,%esp
80106602:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106605:	5b                   	pop    %ebx
80106606:	5e                   	pop    %esi
80106607:	5d                   	pop    %ebp
80106608:	c3                   	ret    

80106609 <setupkvm>:
{
80106609:	55                   	push   %ebp
8010660a:	89 e5                	mov    %esp,%ebp
8010660c:	56                   	push   %esi
8010660d:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
8010660e:	e8 2b ba ff ff       	call   8010203e <kalloc>
80106613:	89 c6                	mov    %eax,%esi
80106615:	85 c0                	test   %eax,%eax
80106617:	74 57                	je     80106670 <setupkvm+0x67>
  memset(pgdir, 0, PGSIZE);
80106619:	83 ec 04             	sub    $0x4,%esp
8010661c:	68 00 10 00 00       	push   $0x1000
80106621:	6a 00                	push   $0x0
80106623:	50                   	push   %eax
80106624:	e8 7d d5 ff ff       	call   80103ba6 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106629:	83 c4 10             	add    $0x10,%esp
8010662c:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
80106631:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106637:	73 37                	jae    80106670 <setupkvm+0x67>
                (uint)k->phys_start, k->perm) < 0) {
80106639:	8b 53 04             	mov    0x4(%ebx),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010663c:	83 ec 0c             	sub    $0xc,%esp
8010663f:	ff 73 0c             	push   0xc(%ebx)
80106642:	52                   	push   %edx
80106643:	8b 43 08             	mov    0x8(%ebx),%eax
80106646:	29 d0                	sub    %edx,%eax
80106648:	50                   	push   %eax
80106649:	ff 33                	push   (%ebx)
8010664b:	56                   	push   %esi
8010664c:	e8 e3 fa ff ff       	call   80106134 <mappages>
80106651:	83 c4 20             	add    $0x20,%esp
80106654:	85 c0                	test   %eax,%eax
80106656:	78 05                	js     8010665d <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106658:	83 c3 10             	add    $0x10,%ebx
8010665b:	eb d4                	jmp    80106631 <setupkvm+0x28>
      freevm(pgdir, 0);
8010665d:	83 ec 08             	sub    $0x8,%esp
80106660:	6a 00                	push   $0x0
80106662:	56                   	push   %esi
80106663:	e8 2b ff ff ff       	call   80106593 <freevm>
      return 0;
80106668:	83 c4 10             	add    $0x10,%esp
8010666b:	be 00 00 00 00       	mov    $0x0,%esi
}
80106670:	89 f0                	mov    %esi,%eax
80106672:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106675:	5b                   	pop    %ebx
80106676:	5e                   	pop    %esi
80106677:	5d                   	pop    %ebp
80106678:	c3                   	ret    

80106679 <kvmalloc>:
{
80106679:	55                   	push   %ebp
8010667a:	89 e5                	mov    %esp,%ebp
8010667c:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010667f:	e8 85 ff ff ff       	call   80106609 <setupkvm>
80106684:	a3 c4 46 11 80       	mov    %eax,0x801146c4
  switchkvm();
80106689:	e8 1c fb ff ff       	call   801061aa <switchkvm>
}
8010668e:	c9                   	leave  
8010668f:	c3                   	ret    

80106690 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106690:	55                   	push   %ebp
80106691:	89 e5                	mov    %esp,%ebp
80106693:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106696:	b9 00 00 00 00       	mov    $0x0,%ecx
8010669b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010669e:	8b 45 08             	mov    0x8(%ebp),%eax
801066a1:	e8 1f f7 ff ff       	call   80105dc5 <walkpgdir>
  if(pte == 0)
801066a6:	85 c0                	test   %eax,%eax
801066a8:	74 05                	je     801066af <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
801066aa:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
801066ad:	c9                   	leave  
801066ae:	c3                   	ret    
    panic("clearpteu");
801066af:	83 ec 0c             	sub    $0xc,%esp
801066b2:	68 86 73 10 80       	push   $0x80107386
801066b7:	e8 85 9c ff ff       	call   80100341 <panic>

801066bc <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801066bc:	55                   	push   %ebp
801066bd:	89 e5                	mov    %esp,%ebp
801066bf:	57                   	push   %edi
801066c0:	56                   	push   %esi
801066c1:	53                   	push   %ebx
801066c2:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801066c5:	e8 3f ff ff ff       	call   80106609 <setupkvm>
801066ca:	89 45 dc             	mov    %eax,-0x24(%ebp)
801066cd:	85 c0                	test   %eax,%eax
801066cf:	0f 84 c6 00 00 00    	je     8010679b <copyuvm+0xdf>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801066d5:	bb 00 00 00 00       	mov    $0x0,%ebx
801066da:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
801066dd:	0f 83 b8 00 00 00    	jae    8010679b <copyuvm+0xdf>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801066e3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801066e6:	b9 00 00 00 00       	mov    $0x0,%ecx
801066eb:	89 da                	mov    %ebx,%edx
801066ed:	8b 45 08             	mov    0x8(%ebp),%eax
801066f0:	e8 d0 f6 ff ff       	call   80105dc5 <walkpgdir>
801066f5:	85 c0                	test   %eax,%eax
801066f7:	74 65                	je     8010675e <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
801066f9:	8b 00                	mov    (%eax),%eax
801066fb:	a8 01                	test   $0x1,%al
801066fd:	74 6c                	je     8010676b <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
801066ff:	89 c6                	mov    %eax,%esi
80106701:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
80106707:	25 ff 0f 00 00       	and    $0xfff,%eax
8010670c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
8010670f:	e8 2a b9 ff ff       	call   8010203e <kalloc>
80106714:	89 c7                	mov    %eax,%edi
80106716:	85 c0                	test   %eax,%eax
80106718:	74 6a                	je     80106784 <copyuvm+0xc8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010671a:	81 c6 00 00 00 80    	add    $0x80000000,%esi
80106720:	83 ec 04             	sub    $0x4,%esp
80106723:	68 00 10 00 00       	push   $0x1000
80106728:	56                   	push   %esi
80106729:	50                   	push   %eax
8010672a:	e8 ed d4 ff ff       	call   80103c1c <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010672f:	83 c4 04             	add    $0x4,%esp
80106732:	ff 75 e0             	push   -0x20(%ebp)
80106735:	8d 87 00 00 00 80    	lea    -0x80000000(%edi),%eax
8010673b:	50                   	push   %eax
8010673c:	68 00 10 00 00       	push   $0x1000
80106741:	ff 75 e4             	push   -0x1c(%ebp)
80106744:	ff 75 dc             	push   -0x24(%ebp)
80106747:	e8 e8 f9 ff ff       	call   80106134 <mappages>
8010674c:	83 c4 20             	add    $0x20,%esp
8010674f:	85 c0                	test   %eax,%eax
80106751:	78 25                	js     80106778 <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
80106753:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106759:	e9 7c ff ff ff       	jmp    801066da <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
8010675e:	83 ec 0c             	sub    $0xc,%esp
80106761:	68 90 73 10 80       	push   $0x80107390
80106766:	e8 d6 9b ff ff       	call   80100341 <panic>
      panic("copyuvm: page not present");
8010676b:	83 ec 0c             	sub    $0xc,%esp
8010676e:	68 aa 73 10 80       	push   $0x801073aa
80106773:	e8 c9 9b ff ff       	call   80100341 <panic>
      kfree(mem);
80106778:	83 ec 0c             	sub    $0xc,%esp
8010677b:	57                   	push   %edi
8010677c:	e8 a6 b7 ff ff       	call   80101f27 <kfree>
      goto bad;
80106781:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d, 1);
80106784:	83 ec 08             	sub    $0x8,%esp
80106787:	6a 01                	push   $0x1
80106789:	ff 75 dc             	push   -0x24(%ebp)
8010678c:	e8 02 fe ff ff       	call   80106593 <freevm>
  return 0;
80106791:	83 c4 10             	add    $0x10,%esp
80106794:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
8010679b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010679e:	8d 65 f4             	lea    -0xc(%ebp),%esp
801067a1:	5b                   	pop    %ebx
801067a2:	5e                   	pop    %esi
801067a3:	5f                   	pop    %edi
801067a4:	5d                   	pop    %ebp
801067a5:	c3                   	ret    

801067a6 <copyuvm1>:

// Given a parent process's page table, create a copy
// of it for a child taking care of lazy memory
pde_t*
copyuvm1(pde_t *pgdir, uint sz)
{
801067a6:	55                   	push   %ebp
801067a7:	89 e5                	mov    %esp,%ebp
801067a9:	57                   	push   %edi
801067aa:	56                   	push   %esi
801067ab:	53                   	push   %ebx
801067ac:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;
  if((d = setupkvm()) == 0)
801067af:	e8 55 fe ff ff       	call   80106609 <setupkvm>
801067b4:	89 45 dc             	mov    %eax,-0x24(%ebp)
801067b7:	85 c0                	test   %eax,%eax
801067b9:	0f 84 b6 00 00 00    	je     80106875 <copyuvm1+0xcf>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801067bf:	be 00 00 00 00       	mov    $0x0,%esi
801067c4:	eb 13                	jmp    801067d9 <copyuvm1+0x33>
    if((pte = walkpgdir(pgdir, (void *) i, 1)) == 0)
      panic("copyuvm: pte should exist");
801067c6:	83 ec 0c             	sub    $0xc,%esp
801067c9:	68 90 73 10 80       	push   $0x80107390
801067ce:	e8 6e 9b ff ff       	call   80100341 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801067d3:	81 c6 00 10 00 00    	add    $0x1000,%esi
801067d9:	3b 75 0c             	cmp    0xc(%ebp),%esi
801067dc:	0f 83 93 00 00 00    	jae    80106875 <copyuvm1+0xcf>
    if((pte = walkpgdir(pgdir, (void *) i, 1)) == 0)
801067e2:	b9 01 00 00 00       	mov    $0x1,%ecx
801067e7:	89 f2                	mov    %esi,%edx
801067e9:	8b 45 08             	mov    0x8(%ebp),%eax
801067ec:	e8 d4 f5 ff ff       	call   80105dc5 <walkpgdir>
801067f1:	85 c0                	test   %eax,%eax
801067f3:	74 d1                	je     801067c6 <copyuvm1+0x20>
    if(!(*pte & PTE_P)){
801067f5:	8b 00                	mov    (%eax),%eax
801067f7:	a8 01                	test   $0x1,%al
801067f9:	74 d8                	je     801067d3 <copyuvm1+0x2d>
			//Si la página no está presente vamos a seguir
			//iterando
			continue;
		}
		//Si la página tiene el bit de presente, la copiamos
    pa = PTE_ADDR(*pte);
801067fb:	89 c2                	mov    %eax,%edx
801067fd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80106803:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    flags = PTE_FLAGS(*pte);
80106806:	25 ff 0f 00 00       	and    $0xfff,%eax
8010680b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
8010680e:	e8 2b b8 ff ff       	call   8010203e <kalloc>
80106813:	89 c7                	mov    %eax,%edi
80106815:	85 c0                	test   %eax,%eax
80106817:	74 45                	je     8010685e <copyuvm1+0xb8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106819:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010681c:	05 00 00 00 80       	add    $0x80000000,%eax
80106821:	83 ec 04             	sub    $0x4,%esp
80106824:	68 00 10 00 00       	push   $0x1000
80106829:	50                   	push   %eax
8010682a:	57                   	push   %edi
8010682b:	e8 ec d3 ff ff       	call   80103c1c <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106830:	83 c4 04             	add    $0x4,%esp
80106833:	ff 75 e0             	push   -0x20(%ebp)
80106836:	8d 87 00 00 00 80    	lea    -0x80000000(%edi),%eax
8010683c:	50                   	push   %eax
8010683d:	68 00 10 00 00       	push   $0x1000
80106842:	56                   	push   %esi
80106843:	ff 75 dc             	push   -0x24(%ebp)
80106846:	e8 e9 f8 ff ff       	call   80106134 <mappages>
8010684b:	83 c4 20             	add    $0x20,%esp
8010684e:	85 c0                	test   %eax,%eax
80106850:	79 81                	jns    801067d3 <copyuvm1+0x2d>
      kfree(mem);
80106852:	83 ec 0c             	sub    $0xc,%esp
80106855:	57                   	push   %edi
80106856:	e8 cc b6 ff ff       	call   80101f27 <kfree>
      goto bad;
8010685b:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d, 1);
8010685e:	83 ec 08             	sub    $0x8,%esp
80106861:	6a 01                	push   $0x1
80106863:	ff 75 dc             	push   -0x24(%ebp)
80106866:	e8 28 fd ff ff       	call   80106593 <freevm>
  return 0;
8010686b:	83 c4 10             	add    $0x10,%esp
8010686e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106875:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106878:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010687b:	5b                   	pop    %ebx
8010687c:	5e                   	pop    %esi
8010687d:	5f                   	pop    %edi
8010687e:	5d                   	pop    %ebp
8010687f:	c3                   	ret    

80106880 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106880:	55                   	push   %ebp
80106881:	89 e5                	mov    %esp,%ebp
80106883:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106886:	b9 00 00 00 00       	mov    $0x0,%ecx
8010688b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010688e:	8b 45 08             	mov    0x8(%ebp),%eax
80106891:	e8 2f f5 ff ff       	call   80105dc5 <walkpgdir>
  if((*pte & PTE_P) == 0)
80106896:	8b 00                	mov    (%eax),%eax
80106898:	a8 01                	test   $0x1,%al
8010689a:	74 10                	je     801068ac <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
8010689c:	a8 04                	test   $0x4,%al
8010689e:	74 13                	je     801068b3 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
801068a0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801068a5:	05 00 00 00 80       	add    $0x80000000,%eax
}
801068aa:	c9                   	leave  
801068ab:	c3                   	ret    
    return 0;
801068ac:	b8 00 00 00 00       	mov    $0x0,%eax
801068b1:	eb f7                	jmp    801068aa <uva2ka+0x2a>
    return 0;
801068b3:	b8 00 00 00 00       	mov    $0x0,%eax
801068b8:	eb f0                	jmp    801068aa <uva2ka+0x2a>

801068ba <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801068ba:	55                   	push   %ebp
801068bb:	89 e5                	mov    %esp,%ebp
801068bd:	57                   	push   %edi
801068be:	56                   	push   %esi
801068bf:	53                   	push   %ebx
801068c0:	83 ec 0c             	sub    $0xc,%esp
801068c3:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801068c6:	eb 25                	jmp    801068ed <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801068c8:	8b 55 0c             	mov    0xc(%ebp),%edx
801068cb:	29 f2                	sub    %esi,%edx
801068cd:	01 d0                	add    %edx,%eax
801068cf:	83 ec 04             	sub    $0x4,%esp
801068d2:	53                   	push   %ebx
801068d3:	ff 75 10             	push   0x10(%ebp)
801068d6:	50                   	push   %eax
801068d7:	e8 40 d3 ff ff       	call   80103c1c <memmove>
    len -= n;
801068dc:	29 df                	sub    %ebx,%edi
    buf += n;
801068de:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
801068e1:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
801068e7:	89 45 0c             	mov    %eax,0xc(%ebp)
801068ea:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
801068ed:	85 ff                	test   %edi,%edi
801068ef:	74 2f                	je     80106920 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
801068f1:	8b 75 0c             	mov    0xc(%ebp),%esi
801068f4:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801068fa:	83 ec 08             	sub    $0x8,%esp
801068fd:	56                   	push   %esi
801068fe:	ff 75 08             	push   0x8(%ebp)
80106901:	e8 7a ff ff ff       	call   80106880 <uva2ka>
    if(pa0 == 0)
80106906:	83 c4 10             	add    $0x10,%esp
80106909:	85 c0                	test   %eax,%eax
8010690b:	74 20                	je     8010692d <copyout+0x73>
    n = PGSIZE - (va - va0);
8010690d:	89 f3                	mov    %esi,%ebx
8010690f:	2b 5d 0c             	sub    0xc(%ebp),%ebx
80106912:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106918:	39 df                	cmp    %ebx,%edi
8010691a:	73 ac                	jae    801068c8 <copyout+0xe>
      n = len;
8010691c:	89 fb                	mov    %edi,%ebx
8010691e:	eb a8                	jmp    801068c8 <copyout+0xe>
  }
  return 0;
80106920:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106925:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106928:	5b                   	pop    %ebx
80106929:	5e                   	pop    %esi
8010692a:	5f                   	pop    %edi
8010692b:	5d                   	pop    %ebp
8010692c:	c3                   	ret    
      return -1;
8010692d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106932:	eb f1                	jmp    80106925 <copyout+0x6b>
