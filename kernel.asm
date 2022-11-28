
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
80100028:	bc d0 55 11 80       	mov    $0x801155d0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 93 29 10 80       	mov    $0x80102993,%eax
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
80100046:	e8 88 3a 00 00       	call   80103ad3 <acquire>

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
8010007a:	e8 b9 3a 00 00       	call   80103b38 <release>
      acquiresleep(&b->lock);
8010007f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100082:	89 04 24             	mov    %eax,(%esp)
80100085:	e8 3a 38 00 00       	call   801038c4 <acquiresleep>
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
801000c8:	e8 6b 3a 00 00       	call   80103b38 <release>
      acquiresleep(&b->lock);
801000cd:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d0:	89 04 24             	mov    %eax,(%esp)
801000d3:	e8 ec 37 00 00       	call   801038c4 <acquiresleep>
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
801000e8:	68 e0 67 10 80       	push   $0x801067e0
801000ed:	e8 4f 02 00 00       	call   80100341 <panic>

801000f2 <binit>:
{
801000f2:	55                   	push   %ebp
801000f3:	89 e5                	mov    %esp,%ebp
801000f5:	53                   	push   %ebx
801000f6:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000f9:	68 f1 67 10 80       	push   $0x801067f1
801000fe:	68 20 a5 10 80       	push   $0x8010a520
80100103:	e8 94 38 00 00       	call   8010399c <initlock>
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
80100138:	68 f8 67 10 80       	push   $0x801067f8
8010013d:	8d 43 0c             	lea    0xc(%ebx),%eax
80100140:	50                   	push   %eax
80100141:	e8 4b 37 00 00       	call   80103891 <initsleeplock>
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
8010018e:	e8 eb 1b 00 00       	call   80101d7e <iderw>
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
801001a6:	e8 a3 37 00 00       	call   8010394e <holdingsleep>
801001ab:	83 c4 10             	add    $0x10,%esp
801001ae:	85 c0                	test   %eax,%eax
801001b0:	74 14                	je     801001c6 <bwrite+0x2e>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001b2:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001b5:	83 ec 0c             	sub    $0xc,%esp
801001b8:	53                   	push   %ebx
801001b9:	e8 c0 1b 00 00       	call   80101d7e <iderw>
}
801001be:	83 c4 10             	add    $0x10,%esp
801001c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c4:	c9                   	leave  
801001c5:	c3                   	ret    
    panic("bwrite");
801001c6:	83 ec 0c             	sub    $0xc,%esp
801001c9:	68 ff 67 10 80       	push   $0x801067ff
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
801001e2:	e8 67 37 00 00       	call   8010394e <holdingsleep>
801001e7:	83 c4 10             	add    $0x10,%esp
801001ea:	85 c0                	test   %eax,%eax
801001ec:	74 69                	je     80100257 <brelse+0x84>
    panic("brelse");

  releasesleep(&b->lock);
801001ee:	83 ec 0c             	sub    $0xc,%esp
801001f1:	56                   	push   %esi
801001f2:	e8 1c 37 00 00       	call   80103913 <releasesleep>

  acquire(&bcache.lock);
801001f7:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801001fe:	e8 d0 38 00 00       	call   80103ad3 <acquire>
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
80100248:	e8 eb 38 00 00       	call   80103b38 <release>
}
8010024d:	83 c4 10             	add    $0x10,%esp
80100250:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100253:	5b                   	pop    %ebx
80100254:	5e                   	pop    %esi
80100255:	5d                   	pop    %ebp
80100256:	c3                   	ret    
    panic("brelse");
80100257:	83 ec 0c             	sub    $0xc,%esp
8010025a:	68 06 68 10 80       	push   $0x80106806
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
80100277:	e8 4b 13 00 00       	call   801015c7 <iunlock>
  target = n;
8010027c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
8010027f:	c7 04 24 20 ef 10 80 	movl   $0x8010ef20,(%esp)
80100286:	e8 48 38 00 00       	call   80103ad3 <acquire>
  while(n > 0){
8010028b:	83 c4 10             	add    $0x10,%esp
8010028e:	85 db                	test   %ebx,%ebx
80100290:	0f 8e 8c 00 00 00    	jle    80100322 <consoleread+0xbe>
    while(input.r == input.w){
80100296:	a1 00 ef 10 80       	mov    0x8010ef00,%eax
8010029b:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
801002a1:	75 47                	jne    801002ea <consoleread+0x86>
      if(myproc()->killed){
801002a3:	e8 72 2e 00 00       	call   8010311a <myproc>
801002a8:	83 78 28 00          	cmpl   $0x0,0x28(%eax)
801002ac:	75 17                	jne    801002c5 <consoleread+0x61>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002ae:	83 ec 08             	sub    $0x8,%esp
801002b1:	68 20 ef 10 80       	push   $0x8010ef20
801002b6:	68 00 ef 10 80       	push   $0x8010ef00
801002bb:	e8 11 33 00 00       	call   801035d1 <sleep>
801002c0:	83 c4 10             	add    $0x10,%esp
801002c3:	eb d1                	jmp    80100296 <consoleread+0x32>
        release(&cons.lock);
801002c5:	83 ec 0c             	sub    $0xc,%esp
801002c8:	68 20 ef 10 80       	push   $0x8010ef20
801002cd:	e8 66 38 00 00       	call   80103b38 <release>
        ilock(ip);
801002d2:	89 3c 24             	mov    %edi,(%esp)
801002d5:	e8 2d 12 00 00       	call   80101507 <ilock>
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
8010032a:	e8 09 38 00 00       	call   80103b38 <release>
  ilock(ip);
8010032f:	89 3c 24             	mov    %edi,(%esp)
80100332:	e8 d0 11 00 00       	call   80101507 <ilock>
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
80100353:	e8 8c 1f 00 00       	call   801022e4 <lapicid>
80100358:	83 ec 08             	sub    $0x8,%esp
8010035b:	50                   	push   %eax
8010035c:	68 0d 68 10 80       	push   $0x8010680d
80100361:	e8 74 02 00 00       	call   801005da <cprintf>
  cprintf(s);
80100366:	83 c4 04             	add    $0x4,%esp
80100369:	ff 75 08             	push   0x8(%ebp)
8010036c:	e8 69 02 00 00       	call   801005da <cprintf>
  cprintf("\n");
80100371:	c7 04 24 9c 6f 10 80 	movl   $0x80106f9c,(%esp)
80100378:	e8 5d 02 00 00       	call   801005da <cprintf>
  getcallerpcs(&s, pcs);
8010037d:	83 c4 08             	add    $0x8,%esp
80100380:	8d 45 d0             	lea    -0x30(%ebp),%eax
80100383:	50                   	push   %eax
80100384:	8d 45 08             	lea    0x8(%ebp),%eax
80100387:	50                   	push   %eax
80100388:	e8 2a 36 00 00       	call   801039b7 <getcallerpcs>
  for(i=0; i<10; i++)
8010038d:	83 c4 10             	add    $0x10,%esp
80100390:	bb 00 00 00 00       	mov    $0x0,%ebx
80100395:	eb 15                	jmp    801003ac <panic+0x6b>
    cprintf(" %p", pcs[i]);
80100397:	83 ec 08             	sub    $0x8,%esp
8010039a:	ff 74 9d d0          	push   -0x30(%ebp,%ebx,4)
8010039e:	68 21 68 10 80       	push   $0x80106821
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
8010046c:	68 25 68 10 80       	push   $0x80106825
80100471:	e8 cb fe ff ff       	call   80100341 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100476:	83 ec 04             	sub    $0x4,%esp
80100479:	68 60 0e 00 00       	push   $0xe60
8010047e:	68 a0 80 0b 80       	push   $0x800b80a0
80100483:	68 00 80 0b 80       	push   $0x800b8000
80100488:	e8 68 37 00 00       	call   80103bf5 <memmove>
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
801004a7:	e8 d3 36 00 00       	call   80103b7f <memset>
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
801004d4:	e8 30 4d 00 00       	call   80105209 <uartputc>
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
801004ed:	e8 17 4d 00 00       	call   80105209 <uartputc>
801004f2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801004f9:	e8 0b 4d 00 00       	call   80105209 <uartputc>
801004fe:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100505:	e8 ff 4c 00 00       	call   80105209 <uartputc>
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
80100540:	8a 92 50 68 10 80    	mov    -0x7fef97b0(%edx),%dl
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
8010058f:	e8 33 10 00 00       	call   801015c7 <iunlock>
  acquire(&cons.lock);
80100594:	c7 04 24 20 ef 10 80 	movl   $0x8010ef20,(%esp)
8010059b:	e8 33 35 00 00       	call   80103ad3 <acquire>
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
801005c0:	e8 73 35 00 00       	call   80103b38 <release>
  ilock(ip);
801005c5:	83 c4 04             	add    $0x4,%esp
801005c8:	ff 75 08             	push   0x8(%ebp)
801005cb:	e8 37 0f 00 00       	call   80101507 <ilock>

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
80100607:	e8 c7 34 00 00       	call   80103ad3 <acquire>
8010060c:	83 c4 10             	add    $0x10,%esp
8010060f:	eb de                	jmp    801005ef <cprintf+0x15>
    panic("null fmt");
80100611:	83 ec 0c             	sub    $0xc,%esp
80100614:	68 3f 68 10 80       	push   $0x8010683f
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
8010069c:	bb 38 68 10 80       	mov    $0x80106838,%ebx
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
801006f5:	e8 3e 34 00 00       	call   80103b38 <release>
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
80100710:	e8 be 33 00 00       	call   80103ad3 <acquire>
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
801007b8:	e8 87 2f 00 00       	call   80103744 <wakeup>
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
80100831:	e8 02 33 00 00       	call   80103b38 <release>
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
80100845:	e8 97 2f 00 00       	call   801037e1 <procdump>
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
80100852:	68 48 68 10 80       	push   $0x80106848
80100857:	68 20 ef 10 80       	push   $0x8010ef20
8010085c:	e8 3b 31 00 00       	call   8010399c <initlock>

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
80100886:	e8 5b 16 00 00       	call   80101ee6 <ioapicenable>
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
8010089c:	e8 79 28 00 00       	call   8010311a <myproc>
801008a1:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
801008a7:	e8 31 1e 00 00       	call   801026dd <begin_op>

  if((ip = namei(path)) == 0){
801008ac:	83 ec 0c             	sub    $0xc,%esp
801008af:	ff 75 08             	push   0x8(%ebp)
801008b2:	e8 b4 12 00 00       	call   80101b6b <namei>
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
801008c4:	e8 3e 0c 00 00       	call   80101507 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
801008c9:	6a 34                	push   $0x34
801008cb:	6a 00                	push   $0x0
801008cd:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
801008d3:	50                   	push   %eax
801008d4:	53                   	push   %ebx
801008d5:	e8 1a 0e 00 00       	call   801016f4 <readi>
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
801008f0:	0f 84 cd 02 00 00    	je     80100bc3 <exec+0x333>
    iunlockput(ip);
801008f6:	83 ec 0c             	sub    $0xc,%esp
801008f9:	53                   	push   %ebx
801008fa:	e8 ab 0d 00 00       	call   801016aa <iunlockput>
    end_op();
801008ff:	e8 55 1e 00 00       	call   80102759 <end_op>
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
80100914:	e8 40 1e 00 00       	call   80102759 <end_op>
    cprintf("exec: fail\n");
80100919:	83 ec 0c             	sub    $0xc,%esp
8010091c:	68 61 68 10 80       	push   $0x80106861
80100921:	e8 b4 fc ff ff       	call   801005da <cprintf>
    return -1;
80100926:	83 c4 10             	add    $0x10,%esp
80100929:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010092e:	eb dc                	jmp    8010090c <exec+0x7c>
  if((pgdir = setupkvm()) == 0)
80100930:	e8 44 5c 00 00       	call   80106579 <setupkvm>
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
8010097a:	e8 75 0d 00 00       	call   801016f4 <readi>
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
801009c6:	e8 4b 5a 00 00       	call   80106416 <allocuvm>
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
801009fc:	e8 eb 58 00 00       	call   801062ec <loaduvm>
80100a01:	83 c4 20             	add    $0x20,%esp
80100a04:	85 c0                	test   %eax,%eax
80100a06:	0f 89 4e ff ff ff    	jns    8010095a <exec+0xca>
80100a0c:	eb 49                	jmp    80100a57 <exec+0x1c7>
  iunlockput(ip);
80100a0e:	83 ec 0c             	sub    $0xc,%esp
80100a11:	53                   	push   %ebx
80100a12:	e8 93 0c 00 00       	call   801016aa <iunlockput>
  end_op();
80100a17:	e8 3d 1d 00 00       	call   80102759 <end_op>
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
80100a3e:	e8 d3 59 00 00       	call   80106416 <allocuvm>
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
80100a6b:	e8 93 5a 00 00       	call   80106503 <freevm>
80100a70:	83 c4 10             	add    $0x10,%esp
80100a73:	e9 76 fe ff ff       	jmp    801008ee <exec+0x5e>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100a78:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100a7e:	83 ec 08             	sub    $0x8,%esp
80100a81:	50                   	push   %eax
80100a82:	57                   	push   %edi
80100a83:	e8 78 5b 00 00       	call   80106600 <clearpteu>
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
80100aa9:	0f 87 0a 01 00 00    	ja     80100bb9 <exec+0x329>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100aaf:	83 ec 0c             	sub    $0xc,%esp
80100ab2:	50                   	push   %eax
80100ab3:	e8 57 32 00 00       	call   80103d0f <strlen>
80100ab8:	29 c6                	sub    %eax,%esi
80100aba:	4e                   	dec    %esi
80100abb:	83 e6 fc             	and    $0xfffffffc,%esi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100abe:	83 c4 04             	add    $0x4,%esp
80100ac1:	ff 33                	push   (%ebx)
80100ac3:	e8 47 32 00 00       	call   80103d0f <strlen>
80100ac8:	40                   	inc    %eax
80100ac9:	50                   	push   %eax
80100aca:	ff 33                	push   (%ebx)
80100acc:	56                   	push   %esi
80100acd:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100ad3:	e8 78 5c 00 00       	call   80106750 <copyout>
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
80100b33:	e8 18 5c 00 00       	call   80106750 <copyout>
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
80100b63:	83 c0 70             	add    $0x70,%eax
80100b66:	83 ec 04             	sub    $0x4,%esp
80100b69:	6a 10                	push   $0x10
80100b6b:	52                   	push   %edx
80100b6c:	50                   	push   %eax
80100b6d:	e8 65 31 00 00       	call   80103cd7 <safestrcpy>
  oldpgdir = curproc->pgdir;
80100b72:	8b 5f 08             	mov    0x8(%edi),%ebx
  curproc->pgdir = pgdir;
80100b75:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100b7b:	89 4f 08             	mov    %ecx,0x8(%edi)
  curproc->sz = sz;
80100b7e:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100b84:	89 4f 04             	mov    %ecx,0x4(%edi)
  curproc->tf->eip = elf.entry;  // main
80100b87:	8b 47 1c             	mov    0x1c(%edi),%eax
80100b8a:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100b90:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100b93:	8b 47 1c             	mov    0x1c(%edi),%eax
80100b96:	89 70 44             	mov    %esi,0x44(%eax)
  switchuvm(curproc);
80100b99:	89 3c 24             	mov    %edi,(%esp)
80100b9c:	e8 87 55 00 00       	call   80106128 <switchuvm>
  freevm(oldpgdir, 1);
80100ba1:	83 c4 08             	add    $0x8,%esp
80100ba4:	6a 01                	push   $0x1
80100ba6:	53                   	push   %ebx
80100ba7:	e8 57 59 00 00       	call   80106503 <freevm>
  return 0;
80100bac:	83 c4 10             	add    $0x10,%esp
80100baf:	b8 00 00 00 00       	mov    $0x0,%eax
80100bb4:	e9 53 fd ff ff       	jmp    8010090c <exec+0x7c>
  ip = 0;
80100bb9:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bbe:	e9 94 fe ff ff       	jmp    80100a57 <exec+0x1c7>
  return -1;
80100bc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc8:	e9 3f fd ff ff       	jmp    8010090c <exec+0x7c>

80100bcd <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100bcd:	55                   	push   %ebp
80100bce:	89 e5                	mov    %esp,%ebp
80100bd0:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100bd3:	68 6d 68 10 80       	push   $0x8010686d
80100bd8:	68 60 ef 10 80       	push   $0x8010ef60
80100bdd:	e8 ba 2d 00 00       	call   8010399c <initlock>
}
80100be2:	83 c4 10             	add    $0x10,%esp
80100be5:	c9                   	leave  
80100be6:	c3                   	ret    

80100be7 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100be7:	55                   	push   %ebp
80100be8:	89 e5                	mov    %esp,%ebp
80100bea:	53                   	push   %ebx
80100beb:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100bee:	68 60 ef 10 80       	push   $0x8010ef60
80100bf3:	e8 db 2e 00 00       	call   80103ad3 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100bf8:	83 c4 10             	add    $0x10,%esp
80100bfb:	bb 94 ef 10 80       	mov    $0x8010ef94,%ebx
80100c00:	81 fb f4 f8 10 80    	cmp    $0x8010f8f4,%ebx
80100c06:	73 29                	jae    80100c31 <filealloc+0x4a>
    if(f->ref == 0){
80100c08:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c0c:	74 05                	je     80100c13 <filealloc+0x2c>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c0e:	83 c3 18             	add    $0x18,%ebx
80100c11:	eb ed                	jmp    80100c00 <filealloc+0x19>
      f->ref = 1;
80100c13:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100c1a:	83 ec 0c             	sub    $0xc,%esp
80100c1d:	68 60 ef 10 80       	push   $0x8010ef60
80100c22:	e8 11 2f 00 00       	call   80103b38 <release>
      return f;
80100c27:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100c2a:	89 d8                	mov    %ebx,%eax
80100c2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c2f:	c9                   	leave  
80100c30:	c3                   	ret    
  release(&ftable.lock);
80100c31:	83 ec 0c             	sub    $0xc,%esp
80100c34:	68 60 ef 10 80       	push   $0x8010ef60
80100c39:	e8 fa 2e 00 00       	call   80103b38 <release>
  return 0;
80100c3e:	83 c4 10             	add    $0x10,%esp
80100c41:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c46:	eb e2                	jmp    80100c2a <filealloc+0x43>

80100c48 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100c48:	55                   	push   %ebp
80100c49:	89 e5                	mov    %esp,%ebp
80100c4b:	53                   	push   %ebx
80100c4c:	83 ec 10             	sub    $0x10,%esp
80100c4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100c52:	68 60 ef 10 80       	push   $0x8010ef60
80100c57:	e8 77 2e 00 00       	call   80103ad3 <acquire>
  if(f->ref < 1)
80100c5c:	8b 43 04             	mov    0x4(%ebx),%eax
80100c5f:	83 c4 10             	add    $0x10,%esp
80100c62:	85 c0                	test   %eax,%eax
80100c64:	7e 18                	jle    80100c7e <filedup+0x36>
    panic("filedup");
  f->ref++;
80100c66:	40                   	inc    %eax
80100c67:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100c6a:	83 ec 0c             	sub    $0xc,%esp
80100c6d:	68 60 ef 10 80       	push   $0x8010ef60
80100c72:	e8 c1 2e 00 00       	call   80103b38 <release>
  return f;
}
80100c77:	89 d8                	mov    %ebx,%eax
80100c79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c7c:	c9                   	leave  
80100c7d:	c3                   	ret    
    panic("filedup");
80100c7e:	83 ec 0c             	sub    $0xc,%esp
80100c81:	68 74 68 10 80       	push   $0x80106874
80100c86:	e8 b6 f6 ff ff       	call   80100341 <panic>

80100c8b <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100c8b:	55                   	push   %ebp
80100c8c:	89 e5                	mov    %esp,%ebp
80100c8e:	57                   	push   %edi
80100c8f:	56                   	push   %esi
80100c90:	53                   	push   %ebx
80100c91:	83 ec 38             	sub    $0x38,%esp
80100c94:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100c97:	68 60 ef 10 80       	push   $0x8010ef60
80100c9c:	e8 32 2e 00 00       	call   80103ad3 <acquire>
  if(f->ref < 1)
80100ca1:	8b 43 04             	mov    0x4(%ebx),%eax
80100ca4:	83 c4 10             	add    $0x10,%esp
80100ca7:	85 c0                	test   %eax,%eax
80100ca9:	7e 58                	jle    80100d03 <fileclose+0x78>
    panic("fileclose");
  if(--f->ref > 0){
80100cab:	48                   	dec    %eax
80100cac:	89 43 04             	mov    %eax,0x4(%ebx)
80100caf:	85 c0                	test   %eax,%eax
80100cb1:	7f 5d                	jg     80100d10 <fileclose+0x85>
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100cb3:	8d 7d d0             	lea    -0x30(%ebp),%edi
80100cb6:	b9 06 00 00 00       	mov    $0x6,%ecx
80100cbb:	89 de                	mov    %ebx,%esi
80100cbd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  f->ref = 0;
80100cbf:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100cc6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100ccc:	83 ec 0c             	sub    $0xc,%esp
80100ccf:	68 60 ef 10 80       	push   $0x8010ef60
80100cd4:	e8 5f 2e 00 00       	call   80103b38 <release>

  if(ff.type == FD_PIPE)
80100cd9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100cdc:	83 c4 10             	add    $0x10,%esp
80100cdf:	83 f8 01             	cmp    $0x1,%eax
80100ce2:	74 44                	je     80100d28 <fileclose+0x9d>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80100ce4:	83 f8 02             	cmp    $0x2,%eax
80100ce7:	75 37                	jne    80100d20 <fileclose+0x95>
    begin_op();
80100ce9:	e8 ef 19 00 00       	call   801026dd <begin_op>
    iput(ff.ip);
80100cee:	83 ec 0c             	sub    $0xc,%esp
80100cf1:	ff 75 e0             	push   -0x20(%ebp)
80100cf4:	e8 13 09 00 00       	call   8010160c <iput>
    end_op();
80100cf9:	e8 5b 1a 00 00       	call   80102759 <end_op>
80100cfe:	83 c4 10             	add    $0x10,%esp
80100d01:	eb 1d                	jmp    80100d20 <fileclose+0x95>
    panic("fileclose");
80100d03:	83 ec 0c             	sub    $0xc,%esp
80100d06:	68 7c 68 10 80       	push   $0x8010687c
80100d0b:	e8 31 f6 ff ff       	call   80100341 <panic>
    release(&ftable.lock);
80100d10:	83 ec 0c             	sub    $0xc,%esp
80100d13:	68 60 ef 10 80       	push   $0x8010ef60
80100d18:	e8 1b 2e 00 00       	call   80103b38 <release>
    return;
80100d1d:	83 c4 10             	add    $0x10,%esp
  }
}
80100d20:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100d23:	5b                   	pop    %ebx
80100d24:	5e                   	pop    %esi
80100d25:	5f                   	pop    %edi
80100d26:	5d                   	pop    %ebp
80100d27:	c3                   	ret    
    pipeclose(ff.pipe, ff.writable);
80100d28:	83 ec 08             	sub    $0x8,%esp
80100d2b:	0f be 45 d9          	movsbl -0x27(%ebp),%eax
80100d2f:	50                   	push   %eax
80100d30:	ff 75 dc             	push   -0x24(%ebp)
80100d33:	e8 06 20 00 00       	call   80102d3e <pipeclose>
80100d38:	83 c4 10             	add    $0x10,%esp
80100d3b:	eb e3                	jmp    80100d20 <fileclose+0x95>

80100d3d <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100d3d:	55                   	push   %ebp
80100d3e:	89 e5                	mov    %esp,%ebp
80100d40:	53                   	push   %ebx
80100d41:	83 ec 04             	sub    $0x4,%esp
80100d44:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100d47:	83 3b 02             	cmpl   $0x2,(%ebx)
80100d4a:	75 31                	jne    80100d7d <filestat+0x40>
    ilock(f->ip);
80100d4c:	83 ec 0c             	sub    $0xc,%esp
80100d4f:	ff 73 10             	push   0x10(%ebx)
80100d52:	e8 b0 07 00 00       	call   80101507 <ilock>
    stati(f->ip, st);
80100d57:	83 c4 08             	add    $0x8,%esp
80100d5a:	ff 75 0c             	push   0xc(%ebp)
80100d5d:	ff 73 10             	push   0x10(%ebx)
80100d60:	e8 65 09 00 00       	call   801016ca <stati>
    iunlock(f->ip);
80100d65:	83 c4 04             	add    $0x4,%esp
80100d68:	ff 73 10             	push   0x10(%ebx)
80100d6b:	e8 57 08 00 00       	call   801015c7 <iunlock>
    return 0;
80100d70:	83 c4 10             	add    $0x10,%esp
80100d73:	b8 00 00 00 00       	mov    $0x0,%eax
  }
  return -1;
}
80100d78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d7b:	c9                   	leave  
80100d7c:	c3                   	ret    
  return -1;
80100d7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100d82:	eb f4                	jmp    80100d78 <filestat+0x3b>

80100d84 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100d84:	55                   	push   %ebp
80100d85:	89 e5                	mov    %esp,%ebp
80100d87:	56                   	push   %esi
80100d88:	53                   	push   %ebx
80100d89:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100d8c:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100d90:	74 70                	je     80100e02 <fileread+0x7e>
    return -1;
  if(f->type == FD_PIPE)
80100d92:	8b 03                	mov    (%ebx),%eax
80100d94:	83 f8 01             	cmp    $0x1,%eax
80100d97:	74 44                	je     80100ddd <fileread+0x59>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100d99:	83 f8 02             	cmp    $0x2,%eax
80100d9c:	75 57                	jne    80100df5 <fileread+0x71>
    ilock(f->ip);
80100d9e:	83 ec 0c             	sub    $0xc,%esp
80100da1:	ff 73 10             	push   0x10(%ebx)
80100da4:	e8 5e 07 00 00       	call   80101507 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100da9:	ff 75 10             	push   0x10(%ebp)
80100dac:	ff 73 14             	push   0x14(%ebx)
80100daf:	ff 75 0c             	push   0xc(%ebp)
80100db2:	ff 73 10             	push   0x10(%ebx)
80100db5:	e8 3a 09 00 00       	call   801016f4 <readi>
80100dba:	89 c6                	mov    %eax,%esi
80100dbc:	83 c4 20             	add    $0x20,%esp
80100dbf:	85 c0                	test   %eax,%eax
80100dc1:	7e 03                	jle    80100dc6 <fileread+0x42>
      f->off += r;
80100dc3:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100dc6:	83 ec 0c             	sub    $0xc,%esp
80100dc9:	ff 73 10             	push   0x10(%ebx)
80100dcc:	e8 f6 07 00 00       	call   801015c7 <iunlock>
    return r;
80100dd1:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100dd4:	89 f0                	mov    %esi,%eax
80100dd6:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100dd9:	5b                   	pop    %ebx
80100dda:	5e                   	pop    %esi
80100ddb:	5d                   	pop    %ebp
80100ddc:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100ddd:	83 ec 04             	sub    $0x4,%esp
80100de0:	ff 75 10             	push   0x10(%ebp)
80100de3:	ff 75 0c             	push   0xc(%ebp)
80100de6:	ff 73 0c             	push   0xc(%ebx)
80100de9:	e8 9e 20 00 00       	call   80102e8c <piperead>
80100dee:	89 c6                	mov    %eax,%esi
80100df0:	83 c4 10             	add    $0x10,%esp
80100df3:	eb df                	jmp    80100dd4 <fileread+0x50>
  panic("fileread");
80100df5:	83 ec 0c             	sub    $0xc,%esp
80100df8:	68 86 68 10 80       	push   $0x80106886
80100dfd:	e8 3f f5 ff ff       	call   80100341 <panic>
    return -1;
80100e02:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e07:	eb cb                	jmp    80100dd4 <fileread+0x50>

80100e09 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100e09:	55                   	push   %ebp
80100e0a:	89 e5                	mov    %esp,%ebp
80100e0c:	57                   	push   %edi
80100e0d:	56                   	push   %esi
80100e0e:	53                   	push   %ebx
80100e0f:	83 ec 1c             	sub    $0x1c,%esp
80100e12:	8b 75 08             	mov    0x8(%ebp),%esi
  int r;

  if(f->writable == 0)
80100e15:	80 7e 09 00          	cmpb   $0x0,0x9(%esi)
80100e19:	0f 84 cc 00 00 00    	je     80100eeb <filewrite+0xe2>
    return -1;
  if(f->type == FD_PIPE)
80100e1f:	8b 06                	mov    (%esi),%eax
80100e21:	83 f8 01             	cmp    $0x1,%eax
80100e24:	74 10                	je     80100e36 <filewrite+0x2d>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e26:	83 f8 02             	cmp    $0x2,%eax
80100e29:	0f 85 af 00 00 00    	jne    80100ede <filewrite+0xd5>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100e2f:	bf 00 00 00 00       	mov    $0x0,%edi
80100e34:	eb 67                	jmp    80100e9d <filewrite+0x94>
    return pipewrite(f->pipe, addr, n);
80100e36:	83 ec 04             	sub    $0x4,%esp
80100e39:	ff 75 10             	push   0x10(%ebp)
80100e3c:	ff 75 0c             	push   0xc(%ebp)
80100e3f:	ff 76 0c             	push   0xc(%esi)
80100e42:	e8 83 1f 00 00       	call   80102dca <pipewrite>
80100e47:	83 c4 10             	add    $0x10,%esp
80100e4a:	e9 82 00 00 00       	jmp    80100ed1 <filewrite+0xc8>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100e4f:	e8 89 18 00 00       	call   801026dd <begin_op>
      ilock(f->ip);
80100e54:	83 ec 0c             	sub    $0xc,%esp
80100e57:	ff 76 10             	push   0x10(%esi)
80100e5a:	e8 a8 06 00 00       	call   80101507 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100e5f:	ff 75 e4             	push   -0x1c(%ebp)
80100e62:	ff 76 14             	push   0x14(%esi)
80100e65:	89 f8                	mov    %edi,%eax
80100e67:	03 45 0c             	add    0xc(%ebp),%eax
80100e6a:	50                   	push   %eax
80100e6b:	ff 76 10             	push   0x10(%esi)
80100e6e:	e8 81 09 00 00       	call   801017f4 <writei>
80100e73:	89 c3                	mov    %eax,%ebx
80100e75:	83 c4 20             	add    $0x20,%esp
80100e78:	85 c0                	test   %eax,%eax
80100e7a:	7e 03                	jle    80100e7f <filewrite+0x76>
        f->off += r;
80100e7c:	01 46 14             	add    %eax,0x14(%esi)
      iunlock(f->ip);
80100e7f:	83 ec 0c             	sub    $0xc,%esp
80100e82:	ff 76 10             	push   0x10(%esi)
80100e85:	e8 3d 07 00 00       	call   801015c7 <iunlock>
      end_op();
80100e8a:	e8 ca 18 00 00       	call   80102759 <end_op>

      if(r < 0)
80100e8f:	83 c4 10             	add    $0x10,%esp
80100e92:	85 db                	test   %ebx,%ebx
80100e94:	78 31                	js     80100ec7 <filewrite+0xbe>
        break;
      if(r != n1)
80100e96:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
80100e99:	75 1f                	jne    80100eba <filewrite+0xb1>
        panic("short filewrite");
      i += r;
80100e9b:	01 df                	add    %ebx,%edi
    while(i < n){
80100e9d:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100ea0:	7d 25                	jge    80100ec7 <filewrite+0xbe>
      int n1 = n - i;
80100ea2:	8b 45 10             	mov    0x10(%ebp),%eax
80100ea5:	29 f8                	sub    %edi,%eax
80100ea7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(n1 > max)
80100eaa:	3d 00 06 00 00       	cmp    $0x600,%eax
80100eaf:	7e 9e                	jle    80100e4f <filewrite+0x46>
        n1 = max;
80100eb1:	c7 45 e4 00 06 00 00 	movl   $0x600,-0x1c(%ebp)
80100eb8:	eb 95                	jmp    80100e4f <filewrite+0x46>
        panic("short filewrite");
80100eba:	83 ec 0c             	sub    $0xc,%esp
80100ebd:	68 8f 68 10 80       	push   $0x8010688f
80100ec2:	e8 7a f4 ff ff       	call   80100341 <panic>
    }
    return i == n ? n : -1;
80100ec7:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100eca:	74 0d                	je     80100ed9 <filewrite+0xd0>
80100ecc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
80100ed1:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100ed4:	5b                   	pop    %ebx
80100ed5:	5e                   	pop    %esi
80100ed6:	5f                   	pop    %edi
80100ed7:	5d                   	pop    %ebp
80100ed8:	c3                   	ret    
    return i == n ? n : -1;
80100ed9:	8b 45 10             	mov    0x10(%ebp),%eax
80100edc:	eb f3                	jmp    80100ed1 <filewrite+0xc8>
  panic("filewrite");
80100ede:	83 ec 0c             	sub    $0xc,%esp
80100ee1:	68 95 68 10 80       	push   $0x80106895
80100ee6:	e8 56 f4 ff ff       	call   80100341 <panic>
    return -1;
80100eeb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ef0:	eb df                	jmp    80100ed1 <filewrite+0xc8>

80100ef2 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80100ef2:	55                   	push   %ebp
80100ef3:	89 e5                	mov    %esp,%ebp
80100ef5:	57                   	push   %edi
80100ef6:	56                   	push   %esi
80100ef7:	53                   	push   %ebx
80100ef8:	83 ec 0c             	sub    $0xc,%esp
80100efb:	89 d6                	mov    %edx,%esi
  char *s;
  int len;

  while(*path == '/')
80100efd:	eb 01                	jmp    80100f00 <skipelem+0xe>
    path++;
80100eff:	40                   	inc    %eax
  while(*path == '/')
80100f00:	8a 10                	mov    (%eax),%dl
80100f02:	80 fa 2f             	cmp    $0x2f,%dl
80100f05:	74 f8                	je     80100eff <skipelem+0xd>
  if(*path == 0)
80100f07:	84 d2                	test   %dl,%dl
80100f09:	74 4e                	je     80100f59 <skipelem+0x67>
80100f0b:	89 c3                	mov    %eax,%ebx
80100f0d:	eb 01                	jmp    80100f10 <skipelem+0x1e>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80100f0f:	43                   	inc    %ebx
  while(*path != '/' && *path != 0)
80100f10:	8a 13                	mov    (%ebx),%dl
80100f12:	80 fa 2f             	cmp    $0x2f,%dl
80100f15:	74 04                	je     80100f1b <skipelem+0x29>
80100f17:	84 d2                	test   %dl,%dl
80100f19:	75 f4                	jne    80100f0f <skipelem+0x1d>
  len = path - s;
80100f1b:	89 df                	mov    %ebx,%edi
80100f1d:	29 c7                	sub    %eax,%edi
  if(len >= DIRSIZ)
80100f1f:	83 ff 0d             	cmp    $0xd,%edi
80100f22:	7e 11                	jle    80100f35 <skipelem+0x43>
    memmove(name, s, DIRSIZ);
80100f24:	83 ec 04             	sub    $0x4,%esp
80100f27:	6a 0e                	push   $0xe
80100f29:	50                   	push   %eax
80100f2a:	56                   	push   %esi
80100f2b:	e8 c5 2c 00 00       	call   80103bf5 <memmove>
80100f30:	83 c4 10             	add    $0x10,%esp
80100f33:	eb 15                	jmp    80100f4a <skipelem+0x58>
  else {
    memmove(name, s, len);
80100f35:	83 ec 04             	sub    $0x4,%esp
80100f38:	57                   	push   %edi
80100f39:	50                   	push   %eax
80100f3a:	56                   	push   %esi
80100f3b:	e8 b5 2c 00 00       	call   80103bf5 <memmove>
    name[len] = 0;
80100f40:	c6 04 3e 00          	movb   $0x0,(%esi,%edi,1)
80100f44:	83 c4 10             	add    $0x10,%esp
80100f47:	eb 01                	jmp    80100f4a <skipelem+0x58>
  }
  while(*path == '/')
    path++;
80100f49:	43                   	inc    %ebx
  while(*path == '/')
80100f4a:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80100f4d:	74 fa                	je     80100f49 <skipelem+0x57>
  return path;
}
80100f4f:	89 d8                	mov    %ebx,%eax
80100f51:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f54:	5b                   	pop    %ebx
80100f55:	5e                   	pop    %esi
80100f56:	5f                   	pop    %edi
80100f57:	5d                   	pop    %ebp
80100f58:	c3                   	ret    
    return 0;
80100f59:	bb 00 00 00 00       	mov    $0x0,%ebx
80100f5e:	eb ef                	jmp    80100f4f <skipelem+0x5d>

80100f60 <bzero>:
{
80100f60:	55                   	push   %ebp
80100f61:	89 e5                	mov    %esp,%ebp
80100f63:	53                   	push   %ebx
80100f64:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, bno);
80100f67:	52                   	push   %edx
80100f68:	50                   	push   %eax
80100f69:	e8 fc f1 ff ff       	call   8010016a <bread>
80100f6e:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80100f70:	8d 40 5c             	lea    0x5c(%eax),%eax
80100f73:	83 c4 0c             	add    $0xc,%esp
80100f76:	68 00 02 00 00       	push   $0x200
80100f7b:	6a 00                	push   $0x0
80100f7d:	50                   	push   %eax
80100f7e:	e8 fc 2b 00 00       	call   80103b7f <memset>
  log_write(bp);
80100f83:	89 1c 24             	mov    %ebx,(%esp)
80100f86:	e8 7b 18 00 00       	call   80102806 <log_write>
  brelse(bp);
80100f8b:	89 1c 24             	mov    %ebx,(%esp)
80100f8e:	e8 40 f2 ff ff       	call   801001d3 <brelse>
}
80100f93:	83 c4 10             	add    $0x10,%esp
80100f96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100f99:	c9                   	leave  
80100f9a:	c3                   	ret    

80100f9b <balloc>:
{
80100f9b:	55                   	push   %ebp
80100f9c:	89 e5                	mov    %esp,%ebp
80100f9e:	57                   	push   %edi
80100f9f:	56                   	push   %esi
80100fa0:	53                   	push   %ebx
80100fa1:	83 ec 1c             	sub    $0x1c,%esp
80100fa4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80100fa7:	be 00 00 00 00       	mov    $0x0,%esi
80100fac:	eb 5b                	jmp    80101009 <balloc+0x6e>
    bp = bread(dev, BBLOCK(b, sb));
80100fae:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
80100fb4:	eb 61                	jmp    80101017 <balloc+0x7c>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80100fb6:	c1 fa 03             	sar    $0x3,%edx
80100fb9:	8b 7d e0             	mov    -0x20(%ebp),%edi
80100fbc:	8a 4c 17 5c          	mov    0x5c(%edi,%edx,1),%cl
80100fc0:	0f b6 f9             	movzbl %cl,%edi
80100fc3:	85 7d e4             	test   %edi,-0x1c(%ebp)
80100fc6:	74 7e                	je     80101046 <balloc+0xab>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80100fc8:	40                   	inc    %eax
80100fc9:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80100fce:	7f 25                	jg     80100ff5 <balloc+0x5a>
80100fd0:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
80100fd3:	3b 1d b4 15 11 80    	cmp    0x801115b4,%ebx
80100fd9:	73 1a                	jae    80100ff5 <balloc+0x5a>
      m = 1 << (bi % 8);
80100fdb:	89 c1                	mov    %eax,%ecx
80100fdd:	83 e1 07             	and    $0x7,%ecx
80100fe0:	ba 01 00 00 00       	mov    $0x1,%edx
80100fe5:	d3 e2                	shl    %cl,%edx
80100fe7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80100fea:	89 c2                	mov    %eax,%edx
80100fec:	85 c0                	test   %eax,%eax
80100fee:	79 c6                	jns    80100fb6 <balloc+0x1b>
80100ff0:	8d 50 07             	lea    0x7(%eax),%edx
80100ff3:	eb c1                	jmp    80100fb6 <balloc+0x1b>
    brelse(bp);
80100ff5:	83 ec 0c             	sub    $0xc,%esp
80100ff8:	ff 75 e0             	push   -0x20(%ebp)
80100ffb:	e8 d3 f1 ff ff       	call   801001d3 <brelse>
  for(b = 0; b < sb.size; b += BPB){
80101000:	81 c6 00 10 00 00    	add    $0x1000,%esi
80101006:	83 c4 10             	add    $0x10,%esp
80101009:	39 35 b4 15 11 80    	cmp    %esi,0x801115b4
8010100f:	76 28                	jbe    80101039 <balloc+0x9e>
    bp = bread(dev, BBLOCK(b, sb));
80101011:	89 f0                	mov    %esi,%eax
80101013:	85 f6                	test   %esi,%esi
80101015:	78 97                	js     80100fae <balloc+0x13>
80101017:	c1 f8 0c             	sar    $0xc,%eax
8010101a:	83 ec 08             	sub    $0x8,%esp
8010101d:	03 05 cc 15 11 80    	add    0x801115cc,%eax
80101023:	50                   	push   %eax
80101024:	ff 75 dc             	push   -0x24(%ebp)
80101027:	e8 3e f1 ff ff       	call   8010016a <bread>
8010102c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010102f:	83 c4 10             	add    $0x10,%esp
80101032:	b8 00 00 00 00       	mov    $0x0,%eax
80101037:	eb 90                	jmp    80100fc9 <balloc+0x2e>
  panic("balloc: out of blocks");
80101039:	83 ec 0c             	sub    $0xc,%esp
8010103c:	68 9f 68 10 80       	push   $0x8010689f
80101041:	e8 fb f2 ff ff       	call   80100341 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
80101046:	0b 4d e4             	or     -0x1c(%ebp),%ecx
80101049:	8b 75 e0             	mov    -0x20(%ebp),%esi
8010104c:	88 4c 16 5c          	mov    %cl,0x5c(%esi,%edx,1)
        log_write(bp);
80101050:	83 ec 0c             	sub    $0xc,%esp
80101053:	56                   	push   %esi
80101054:	e8 ad 17 00 00       	call   80102806 <log_write>
        brelse(bp);
80101059:	89 34 24             	mov    %esi,(%esp)
8010105c:	e8 72 f1 ff ff       	call   801001d3 <brelse>
        bzero(dev, b + bi);
80101061:	89 da                	mov    %ebx,%edx
80101063:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101066:	e8 f5 fe ff ff       	call   80100f60 <bzero>
}
8010106b:	89 d8                	mov    %ebx,%eax
8010106d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101070:	5b                   	pop    %ebx
80101071:	5e                   	pop    %esi
80101072:	5f                   	pop    %edi
80101073:	5d                   	pop    %ebp
80101074:	c3                   	ret    

80101075 <bmap>:
{
80101075:	55                   	push   %ebp
80101076:	89 e5                	mov    %esp,%ebp
80101078:	57                   	push   %edi
80101079:	56                   	push   %esi
8010107a:	53                   	push   %ebx
8010107b:	83 ec 1c             	sub    $0x1c,%esp
8010107e:	89 c3                	mov    %eax,%ebx
80101080:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
80101082:	83 fa 0b             	cmp    $0xb,%edx
80101085:	76 45                	jbe    801010cc <bmap+0x57>
  bn -= NDIRECT;
80101087:	8d 72 f4             	lea    -0xc(%edx),%esi
  if(bn < NINDIRECT){
8010108a:	83 fe 7f             	cmp    $0x7f,%esi
8010108d:	77 7f                	ja     8010110e <bmap+0x99>
    if((addr = ip->addrs[NDIRECT]) == 0)
8010108f:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101095:	85 c0                	test   %eax,%eax
80101097:	74 4a                	je     801010e3 <bmap+0x6e>
    bp = bread(ip->dev, addr);
80101099:	83 ec 08             	sub    $0x8,%esp
8010109c:	50                   	push   %eax
8010109d:	ff 33                	push   (%ebx)
8010109f:	e8 c6 f0 ff ff       	call   8010016a <bread>
801010a4:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
801010a6:	8d 44 b0 5c          	lea    0x5c(%eax,%esi,4),%eax
801010aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801010ad:	8b 30                	mov    (%eax),%esi
801010af:	83 c4 10             	add    $0x10,%esp
801010b2:	85 f6                	test   %esi,%esi
801010b4:	74 3c                	je     801010f2 <bmap+0x7d>
    brelse(bp);
801010b6:	83 ec 0c             	sub    $0xc,%esp
801010b9:	57                   	push   %edi
801010ba:	e8 14 f1 ff ff       	call   801001d3 <brelse>
    return addr;
801010bf:	83 c4 10             	add    $0x10,%esp
}
801010c2:	89 f0                	mov    %esi,%eax
801010c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010c7:	5b                   	pop    %ebx
801010c8:	5e                   	pop    %esi
801010c9:	5f                   	pop    %edi
801010ca:	5d                   	pop    %ebp
801010cb:	c3                   	ret    
    if((addr = ip->addrs[bn]) == 0)
801010cc:	8b 74 90 5c          	mov    0x5c(%eax,%edx,4),%esi
801010d0:	85 f6                	test   %esi,%esi
801010d2:	75 ee                	jne    801010c2 <bmap+0x4d>
      ip->addrs[bn] = addr = balloc(ip->dev);
801010d4:	8b 00                	mov    (%eax),%eax
801010d6:	e8 c0 fe ff ff       	call   80100f9b <balloc>
801010db:	89 c6                	mov    %eax,%esi
801010dd:	89 44 bb 5c          	mov    %eax,0x5c(%ebx,%edi,4)
    return addr;
801010e1:	eb df                	jmp    801010c2 <bmap+0x4d>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
801010e3:	8b 03                	mov    (%ebx),%eax
801010e5:	e8 b1 fe ff ff       	call   80100f9b <balloc>
801010ea:	89 83 8c 00 00 00    	mov    %eax,0x8c(%ebx)
801010f0:	eb a7                	jmp    80101099 <bmap+0x24>
      a[bn] = addr = balloc(ip->dev);
801010f2:	8b 03                	mov    (%ebx),%eax
801010f4:	e8 a2 fe ff ff       	call   80100f9b <balloc>
801010f9:	89 c6                	mov    %eax,%esi
801010fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010fe:	89 30                	mov    %esi,(%eax)
      log_write(bp);
80101100:	83 ec 0c             	sub    $0xc,%esp
80101103:	57                   	push   %edi
80101104:	e8 fd 16 00 00       	call   80102806 <log_write>
80101109:	83 c4 10             	add    $0x10,%esp
8010110c:	eb a8                	jmp    801010b6 <bmap+0x41>
  panic("bmap: out of range");
8010110e:	83 ec 0c             	sub    $0xc,%esp
80101111:	68 b5 68 10 80       	push   $0x801068b5
80101116:	e8 26 f2 ff ff       	call   80100341 <panic>

8010111b <iget>:
{
8010111b:	55                   	push   %ebp
8010111c:	89 e5                	mov    %esp,%ebp
8010111e:	57                   	push   %edi
8010111f:	56                   	push   %esi
80101120:	53                   	push   %ebx
80101121:	83 ec 28             	sub    $0x28,%esp
80101124:	89 c7                	mov    %eax,%edi
80101126:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101129:	68 60 f9 10 80       	push   $0x8010f960
8010112e:	e8 a0 29 00 00       	call   80103ad3 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101133:	83 c4 10             	add    $0x10,%esp
  empty = 0;
80101136:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010113b:	bb 94 f9 10 80       	mov    $0x8010f994,%ebx
80101140:	eb 0a                	jmp    8010114c <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101142:	85 f6                	test   %esi,%esi
80101144:	74 39                	je     8010117f <iget+0x64>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101146:	81 c3 90 00 00 00    	add    $0x90,%ebx
8010114c:	81 fb b4 15 11 80    	cmp    $0x801115b4,%ebx
80101152:	73 33                	jae    80101187 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101154:	8b 43 08             	mov    0x8(%ebx),%eax
80101157:	85 c0                	test   %eax,%eax
80101159:	7e e7                	jle    80101142 <iget+0x27>
8010115b:	39 3b                	cmp    %edi,(%ebx)
8010115d:	75 e3                	jne    80101142 <iget+0x27>
8010115f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101162:	39 4b 04             	cmp    %ecx,0x4(%ebx)
80101165:	75 db                	jne    80101142 <iget+0x27>
      ip->ref++;
80101167:	40                   	inc    %eax
80101168:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
8010116b:	83 ec 0c             	sub    $0xc,%esp
8010116e:	68 60 f9 10 80       	push   $0x8010f960
80101173:	e8 c0 29 00 00       	call   80103b38 <release>
      return ip;
80101178:	83 c4 10             	add    $0x10,%esp
8010117b:	89 de                	mov    %ebx,%esi
8010117d:	eb 32                	jmp    801011b1 <iget+0x96>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010117f:	85 c0                	test   %eax,%eax
80101181:	75 c3                	jne    80101146 <iget+0x2b>
      empty = ip;
80101183:	89 de                	mov    %ebx,%esi
80101185:	eb bf                	jmp    80101146 <iget+0x2b>
  if(empty == 0)
80101187:	85 f6                	test   %esi,%esi
80101189:	74 30                	je     801011bb <iget+0xa0>
  ip->dev = dev;
8010118b:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
8010118d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101190:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
80101193:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
8010119a:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
801011a1:	83 ec 0c             	sub    $0xc,%esp
801011a4:	68 60 f9 10 80       	push   $0x8010f960
801011a9:	e8 8a 29 00 00       	call   80103b38 <release>
  return ip;
801011ae:	83 c4 10             	add    $0x10,%esp
}
801011b1:	89 f0                	mov    %esi,%eax
801011b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011b6:	5b                   	pop    %ebx
801011b7:	5e                   	pop    %esi
801011b8:	5f                   	pop    %edi
801011b9:	5d                   	pop    %ebp
801011ba:	c3                   	ret    
    panic("iget: no inodes");
801011bb:	83 ec 0c             	sub    $0xc,%esp
801011be:	68 c8 68 10 80       	push   $0x801068c8
801011c3:	e8 79 f1 ff ff       	call   80100341 <panic>

801011c8 <readsb>:
{
801011c8:	55                   	push   %ebp
801011c9:	89 e5                	mov    %esp,%ebp
801011cb:	53                   	push   %ebx
801011cc:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
801011cf:	6a 01                	push   $0x1
801011d1:	ff 75 08             	push   0x8(%ebp)
801011d4:	e8 91 ef ff ff       	call   8010016a <bread>
801011d9:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801011db:	8d 40 5c             	lea    0x5c(%eax),%eax
801011de:	83 c4 0c             	add    $0xc,%esp
801011e1:	6a 1c                	push   $0x1c
801011e3:	50                   	push   %eax
801011e4:	ff 75 0c             	push   0xc(%ebp)
801011e7:	e8 09 2a 00 00       	call   80103bf5 <memmove>
  brelse(bp);
801011ec:	89 1c 24             	mov    %ebx,(%esp)
801011ef:	e8 df ef ff ff       	call   801001d3 <brelse>
}
801011f4:	83 c4 10             	add    $0x10,%esp
801011f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801011fa:	c9                   	leave  
801011fb:	c3                   	ret    

801011fc <bfree>:
{
801011fc:	55                   	push   %ebp
801011fd:	89 e5                	mov    %esp,%ebp
801011ff:	56                   	push   %esi
80101200:	53                   	push   %ebx
80101201:	89 c3                	mov    %eax,%ebx
80101203:	89 d6                	mov    %edx,%esi
  readsb(dev, &sb);
80101205:	83 ec 08             	sub    $0x8,%esp
80101208:	68 b4 15 11 80       	push   $0x801115b4
8010120d:	50                   	push   %eax
8010120e:	e8 b5 ff ff ff       	call   801011c8 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101213:	89 f0                	mov    %esi,%eax
80101215:	c1 e8 0c             	shr    $0xc,%eax
80101218:	83 c4 08             	add    $0x8,%esp
8010121b:	03 05 cc 15 11 80    	add    0x801115cc,%eax
80101221:	50                   	push   %eax
80101222:	53                   	push   %ebx
80101223:	e8 42 ef ff ff       	call   8010016a <bread>
80101228:	89 c3                	mov    %eax,%ebx
  bi = b % BPB;
8010122a:	89 f2                	mov    %esi,%edx
8010122c:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  m = 1 << (bi % 8);
80101232:	89 f1                	mov    %esi,%ecx
80101234:	83 e1 07             	and    $0x7,%ecx
80101237:	b8 01 00 00 00       	mov    $0x1,%eax
8010123c:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
8010123e:	83 c4 10             	add    $0x10,%esp
80101241:	c1 fa 03             	sar    $0x3,%edx
80101244:	8a 4c 13 5c          	mov    0x5c(%ebx,%edx,1),%cl
80101248:	0f b6 f1             	movzbl %cl,%esi
8010124b:	85 c6                	test   %eax,%esi
8010124d:	74 23                	je     80101272 <bfree+0x76>
  bp->data[bi/8] &= ~m;
8010124f:	f7 d0                	not    %eax
80101251:	21 c8                	and    %ecx,%eax
80101253:	88 44 13 5c          	mov    %al,0x5c(%ebx,%edx,1)
  log_write(bp);
80101257:	83 ec 0c             	sub    $0xc,%esp
8010125a:	53                   	push   %ebx
8010125b:	e8 a6 15 00 00       	call   80102806 <log_write>
  brelse(bp);
80101260:	89 1c 24             	mov    %ebx,(%esp)
80101263:	e8 6b ef ff ff       	call   801001d3 <brelse>
}
80101268:	83 c4 10             	add    $0x10,%esp
8010126b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010126e:	5b                   	pop    %ebx
8010126f:	5e                   	pop    %esi
80101270:	5d                   	pop    %ebp
80101271:	c3                   	ret    
    panic("freeing free block");
80101272:	83 ec 0c             	sub    $0xc,%esp
80101275:	68 d8 68 10 80       	push   $0x801068d8
8010127a:	e8 c2 f0 ff ff       	call   80100341 <panic>

8010127f <iinit>:
{
8010127f:	55                   	push   %ebp
80101280:	89 e5                	mov    %esp,%ebp
80101282:	53                   	push   %ebx
80101283:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
80101286:	68 eb 68 10 80       	push   $0x801068eb
8010128b:	68 60 f9 10 80       	push   $0x8010f960
80101290:	e8 07 27 00 00       	call   8010399c <initlock>
  for(i = 0; i < NINODE; i++) {
80101295:	83 c4 10             	add    $0x10,%esp
80101298:	bb 00 00 00 00       	mov    $0x0,%ebx
8010129d:	eb 1f                	jmp    801012be <iinit+0x3f>
    initsleeplock(&icache.inode[i].lock, "inode");
8010129f:	83 ec 08             	sub    $0x8,%esp
801012a2:	68 f2 68 10 80       	push   $0x801068f2
801012a7:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
801012aa:	89 d0                	mov    %edx,%eax
801012ac:	c1 e0 04             	shl    $0x4,%eax
801012af:	05 a0 f9 10 80       	add    $0x8010f9a0,%eax
801012b4:	50                   	push   %eax
801012b5:	e8 d7 25 00 00       	call   80103891 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
801012ba:	43                   	inc    %ebx
801012bb:	83 c4 10             	add    $0x10,%esp
801012be:	83 fb 31             	cmp    $0x31,%ebx
801012c1:	7e dc                	jle    8010129f <iinit+0x20>
  readsb(dev, &sb);
801012c3:	83 ec 08             	sub    $0x8,%esp
801012c6:	68 b4 15 11 80       	push   $0x801115b4
801012cb:	ff 75 08             	push   0x8(%ebp)
801012ce:	e8 f5 fe ff ff       	call   801011c8 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801012d3:	ff 35 cc 15 11 80    	push   0x801115cc
801012d9:	ff 35 c8 15 11 80    	push   0x801115c8
801012df:	ff 35 c4 15 11 80    	push   0x801115c4
801012e5:	ff 35 c0 15 11 80    	push   0x801115c0
801012eb:	ff 35 bc 15 11 80    	push   0x801115bc
801012f1:	ff 35 b8 15 11 80    	push   0x801115b8
801012f7:	ff 35 b4 15 11 80    	push   0x801115b4
801012fd:	68 58 69 10 80       	push   $0x80106958
80101302:	e8 d3 f2 ff ff       	call   801005da <cprintf>
}
80101307:	83 c4 30             	add    $0x30,%esp
8010130a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010130d:	c9                   	leave  
8010130e:	c3                   	ret    

8010130f <ialloc>:
{
8010130f:	55                   	push   %ebp
80101310:	89 e5                	mov    %esp,%ebp
80101312:	57                   	push   %edi
80101313:	56                   	push   %esi
80101314:	53                   	push   %ebx
80101315:	83 ec 1c             	sub    $0x1c,%esp
80101318:	8b 45 0c             	mov    0xc(%ebp),%eax
8010131b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
8010131e:	bb 01 00 00 00       	mov    $0x1,%ebx
80101323:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80101326:	39 1d bc 15 11 80    	cmp    %ebx,0x801115bc
8010132c:	76 3d                	jbe    8010136b <ialloc+0x5c>
    bp = bread(dev, IBLOCK(inum, sb));
8010132e:	89 d8                	mov    %ebx,%eax
80101330:	c1 e8 03             	shr    $0x3,%eax
80101333:	83 ec 08             	sub    $0x8,%esp
80101336:	03 05 c8 15 11 80    	add    0x801115c8,%eax
8010133c:	50                   	push   %eax
8010133d:	ff 75 08             	push   0x8(%ebp)
80101340:	e8 25 ee ff ff       	call   8010016a <bread>
80101345:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
80101347:	89 d8                	mov    %ebx,%eax
80101349:	83 e0 07             	and    $0x7,%eax
8010134c:	c1 e0 06             	shl    $0x6,%eax
8010134f:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
80101353:	83 c4 10             	add    $0x10,%esp
80101356:	66 83 3f 00          	cmpw   $0x0,(%edi)
8010135a:	74 1c                	je     80101378 <ialloc+0x69>
    brelse(bp);
8010135c:	83 ec 0c             	sub    $0xc,%esp
8010135f:	56                   	push   %esi
80101360:	e8 6e ee ff ff       	call   801001d3 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
80101365:	43                   	inc    %ebx
80101366:	83 c4 10             	add    $0x10,%esp
80101369:	eb b8                	jmp    80101323 <ialloc+0x14>
  panic("ialloc: no inodes");
8010136b:	83 ec 0c             	sub    $0xc,%esp
8010136e:	68 f8 68 10 80       	push   $0x801068f8
80101373:	e8 c9 ef ff ff       	call   80100341 <panic>
      memset(dip, 0, sizeof(*dip));
80101378:	83 ec 04             	sub    $0x4,%esp
8010137b:	6a 40                	push   $0x40
8010137d:	6a 00                	push   $0x0
8010137f:	57                   	push   %edi
80101380:	e8 fa 27 00 00       	call   80103b7f <memset>
      dip->type = type;
80101385:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101388:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
8010138b:	89 34 24             	mov    %esi,(%esp)
8010138e:	e8 73 14 00 00       	call   80102806 <log_write>
      brelse(bp);
80101393:	89 34 24             	mov    %esi,(%esp)
80101396:	e8 38 ee ff ff       	call   801001d3 <brelse>
      return iget(dev, inum);
8010139b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010139e:	8b 45 08             	mov    0x8(%ebp),%eax
801013a1:	e8 75 fd ff ff       	call   8010111b <iget>
}
801013a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801013a9:	5b                   	pop    %ebx
801013aa:	5e                   	pop    %esi
801013ab:	5f                   	pop    %edi
801013ac:	5d                   	pop    %ebp
801013ad:	c3                   	ret    

801013ae <iupdate>:
{
801013ae:	55                   	push   %ebp
801013af:	89 e5                	mov    %esp,%ebp
801013b1:	56                   	push   %esi
801013b2:	53                   	push   %ebx
801013b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801013b6:	8b 43 04             	mov    0x4(%ebx),%eax
801013b9:	c1 e8 03             	shr    $0x3,%eax
801013bc:	83 ec 08             	sub    $0x8,%esp
801013bf:	03 05 c8 15 11 80    	add    0x801115c8,%eax
801013c5:	50                   	push   %eax
801013c6:	ff 33                	push   (%ebx)
801013c8:	e8 9d ed ff ff       	call   8010016a <bread>
801013cd:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801013cf:	8b 43 04             	mov    0x4(%ebx),%eax
801013d2:	83 e0 07             	and    $0x7,%eax
801013d5:	c1 e0 06             	shl    $0x6,%eax
801013d8:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
801013dc:	8b 53 50             	mov    0x50(%ebx),%edx
801013df:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801013e2:	66 8b 53 52          	mov    0x52(%ebx),%dx
801013e6:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801013ea:	8b 53 54             	mov    0x54(%ebx),%edx
801013ed:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801013f1:	66 8b 53 56          	mov    0x56(%ebx),%dx
801013f5:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801013f9:	8b 53 58             	mov    0x58(%ebx),%edx
801013fc:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801013ff:	83 c3 5c             	add    $0x5c,%ebx
80101402:	83 c0 0c             	add    $0xc,%eax
80101405:	83 c4 0c             	add    $0xc,%esp
80101408:	6a 34                	push   $0x34
8010140a:	53                   	push   %ebx
8010140b:	50                   	push   %eax
8010140c:	e8 e4 27 00 00       	call   80103bf5 <memmove>
  log_write(bp);
80101411:	89 34 24             	mov    %esi,(%esp)
80101414:	e8 ed 13 00 00       	call   80102806 <log_write>
  brelse(bp);
80101419:	89 34 24             	mov    %esi,(%esp)
8010141c:	e8 b2 ed ff ff       	call   801001d3 <brelse>
}
80101421:	83 c4 10             	add    $0x10,%esp
80101424:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101427:	5b                   	pop    %ebx
80101428:	5e                   	pop    %esi
80101429:	5d                   	pop    %ebp
8010142a:	c3                   	ret    

8010142b <itrunc>:
{
8010142b:	55                   	push   %ebp
8010142c:	89 e5                	mov    %esp,%ebp
8010142e:	57                   	push   %edi
8010142f:	56                   	push   %esi
80101430:	53                   	push   %ebx
80101431:	83 ec 1c             	sub    $0x1c,%esp
80101434:	89 c6                	mov    %eax,%esi
  for(i = 0; i < NDIRECT; i++){
80101436:	bb 00 00 00 00       	mov    $0x0,%ebx
8010143b:	eb 01                	jmp    8010143e <itrunc+0x13>
8010143d:	43                   	inc    %ebx
8010143e:	83 fb 0b             	cmp    $0xb,%ebx
80101441:	7f 19                	jg     8010145c <itrunc+0x31>
    if(ip->addrs[i]){
80101443:	8b 54 9e 5c          	mov    0x5c(%esi,%ebx,4),%edx
80101447:	85 d2                	test   %edx,%edx
80101449:	74 f2                	je     8010143d <itrunc+0x12>
      bfree(ip->dev, ip->addrs[i]);
8010144b:	8b 06                	mov    (%esi),%eax
8010144d:	e8 aa fd ff ff       	call   801011fc <bfree>
      ip->addrs[i] = 0;
80101452:	c7 44 9e 5c 00 00 00 	movl   $0x0,0x5c(%esi,%ebx,4)
80101459:	00 
8010145a:	eb e1                	jmp    8010143d <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
8010145c:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
80101462:	85 c0                	test   %eax,%eax
80101464:	75 1b                	jne    80101481 <itrunc+0x56>
  ip->size = 0;
80101466:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
8010146d:	83 ec 0c             	sub    $0xc,%esp
80101470:	56                   	push   %esi
80101471:	e8 38 ff ff ff       	call   801013ae <iupdate>
}
80101476:	83 c4 10             	add    $0x10,%esp
80101479:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010147c:	5b                   	pop    %ebx
8010147d:	5e                   	pop    %esi
8010147e:	5f                   	pop    %edi
8010147f:	5d                   	pop    %ebp
80101480:	c3                   	ret    
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101481:	83 ec 08             	sub    $0x8,%esp
80101484:	50                   	push   %eax
80101485:	ff 36                	push   (%esi)
80101487:	e8 de ec ff ff       	call   8010016a <bread>
8010148c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
8010148f:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
80101492:	83 c4 10             	add    $0x10,%esp
80101495:	bb 00 00 00 00       	mov    $0x0,%ebx
8010149a:	eb 01                	jmp    8010149d <itrunc+0x72>
8010149c:	43                   	inc    %ebx
8010149d:	83 fb 7f             	cmp    $0x7f,%ebx
801014a0:	77 10                	ja     801014b2 <itrunc+0x87>
      if(a[j])
801014a2:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
801014a5:	85 d2                	test   %edx,%edx
801014a7:	74 f3                	je     8010149c <itrunc+0x71>
        bfree(ip->dev, a[j]);
801014a9:	8b 06                	mov    (%esi),%eax
801014ab:	e8 4c fd ff ff       	call   801011fc <bfree>
801014b0:	eb ea                	jmp    8010149c <itrunc+0x71>
    brelse(bp);
801014b2:	83 ec 0c             	sub    $0xc,%esp
801014b5:	ff 75 e4             	push   -0x1c(%ebp)
801014b8:	e8 16 ed ff ff       	call   801001d3 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
801014bd:	8b 06                	mov    (%esi),%eax
801014bf:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
801014c5:	e8 32 fd ff ff       	call   801011fc <bfree>
    ip->addrs[NDIRECT] = 0;
801014ca:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
801014d1:	00 00 00 
801014d4:	83 c4 10             	add    $0x10,%esp
801014d7:	eb 8d                	jmp    80101466 <itrunc+0x3b>

801014d9 <idup>:
{
801014d9:	55                   	push   %ebp
801014da:	89 e5                	mov    %esp,%ebp
801014dc:	53                   	push   %ebx
801014dd:	83 ec 10             	sub    $0x10,%esp
801014e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
801014e3:	68 60 f9 10 80       	push   $0x8010f960
801014e8:	e8 e6 25 00 00       	call   80103ad3 <acquire>
  ip->ref++;
801014ed:	8b 43 08             	mov    0x8(%ebx),%eax
801014f0:	40                   	inc    %eax
801014f1:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801014f4:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
801014fb:	e8 38 26 00 00       	call   80103b38 <release>
}
80101500:	89 d8                	mov    %ebx,%eax
80101502:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101505:	c9                   	leave  
80101506:	c3                   	ret    

80101507 <ilock>:
{
80101507:	55                   	push   %ebp
80101508:	89 e5                	mov    %esp,%ebp
8010150a:	56                   	push   %esi
8010150b:	53                   	push   %ebx
8010150c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
8010150f:	85 db                	test   %ebx,%ebx
80101511:	74 22                	je     80101535 <ilock+0x2e>
80101513:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101517:	7e 1c                	jle    80101535 <ilock+0x2e>
  acquiresleep(&ip->lock);
80101519:	83 ec 0c             	sub    $0xc,%esp
8010151c:	8d 43 0c             	lea    0xc(%ebx),%eax
8010151f:	50                   	push   %eax
80101520:	e8 9f 23 00 00       	call   801038c4 <acquiresleep>
  if(ip->valid == 0){
80101525:	83 c4 10             	add    $0x10,%esp
80101528:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
8010152c:	74 14                	je     80101542 <ilock+0x3b>
}
8010152e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101531:	5b                   	pop    %ebx
80101532:	5e                   	pop    %esi
80101533:	5d                   	pop    %ebp
80101534:	c3                   	ret    
    panic("ilock");
80101535:	83 ec 0c             	sub    $0xc,%esp
80101538:	68 0a 69 10 80       	push   $0x8010690a
8010153d:	e8 ff ed ff ff       	call   80100341 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101542:	8b 43 04             	mov    0x4(%ebx),%eax
80101545:	c1 e8 03             	shr    $0x3,%eax
80101548:	83 ec 08             	sub    $0x8,%esp
8010154b:	03 05 c8 15 11 80    	add    0x801115c8,%eax
80101551:	50                   	push   %eax
80101552:	ff 33                	push   (%ebx)
80101554:	e8 11 ec ff ff       	call   8010016a <bread>
80101559:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
8010155b:	8b 43 04             	mov    0x4(%ebx),%eax
8010155e:	83 e0 07             	and    $0x7,%eax
80101561:	c1 e0 06             	shl    $0x6,%eax
80101564:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
80101568:	8b 10                	mov    (%eax),%edx
8010156a:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
8010156e:	66 8b 50 02          	mov    0x2(%eax),%dx
80101572:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
80101576:	8b 50 04             	mov    0x4(%eax),%edx
80101579:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
8010157d:	66 8b 50 06          	mov    0x6(%eax),%dx
80101581:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
80101585:	8b 50 08             	mov    0x8(%eax),%edx
80101588:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010158b:	83 c0 0c             	add    $0xc,%eax
8010158e:	8d 53 5c             	lea    0x5c(%ebx),%edx
80101591:	83 c4 0c             	add    $0xc,%esp
80101594:	6a 34                	push   $0x34
80101596:	50                   	push   %eax
80101597:	52                   	push   %edx
80101598:	e8 58 26 00 00       	call   80103bf5 <memmove>
    brelse(bp);
8010159d:	89 34 24             	mov    %esi,(%esp)
801015a0:	e8 2e ec ff ff       	call   801001d3 <brelse>
    ip->valid = 1;
801015a5:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
801015ac:	83 c4 10             	add    $0x10,%esp
801015af:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
801015b4:	0f 85 74 ff ff ff    	jne    8010152e <ilock+0x27>
      panic("ilock: no type");
801015ba:	83 ec 0c             	sub    $0xc,%esp
801015bd:	68 10 69 10 80       	push   $0x80106910
801015c2:	e8 7a ed ff ff       	call   80100341 <panic>

801015c7 <iunlock>:
{
801015c7:	55                   	push   %ebp
801015c8:	89 e5                	mov    %esp,%ebp
801015ca:	56                   	push   %esi
801015cb:	53                   	push   %ebx
801015cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801015cf:	85 db                	test   %ebx,%ebx
801015d1:	74 2c                	je     801015ff <iunlock+0x38>
801015d3:	8d 73 0c             	lea    0xc(%ebx),%esi
801015d6:	83 ec 0c             	sub    $0xc,%esp
801015d9:	56                   	push   %esi
801015da:	e8 6f 23 00 00       	call   8010394e <holdingsleep>
801015df:	83 c4 10             	add    $0x10,%esp
801015e2:	85 c0                	test   %eax,%eax
801015e4:	74 19                	je     801015ff <iunlock+0x38>
801015e6:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
801015ea:	7e 13                	jle    801015ff <iunlock+0x38>
  releasesleep(&ip->lock);
801015ec:	83 ec 0c             	sub    $0xc,%esp
801015ef:	56                   	push   %esi
801015f0:	e8 1e 23 00 00       	call   80103913 <releasesleep>
}
801015f5:	83 c4 10             	add    $0x10,%esp
801015f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801015fb:	5b                   	pop    %ebx
801015fc:	5e                   	pop    %esi
801015fd:	5d                   	pop    %ebp
801015fe:	c3                   	ret    
    panic("iunlock");
801015ff:	83 ec 0c             	sub    $0xc,%esp
80101602:	68 1f 69 10 80       	push   $0x8010691f
80101607:	e8 35 ed ff ff       	call   80100341 <panic>

8010160c <iput>:
{
8010160c:	55                   	push   %ebp
8010160d:	89 e5                	mov    %esp,%ebp
8010160f:	57                   	push   %edi
80101610:	56                   	push   %esi
80101611:	53                   	push   %ebx
80101612:	83 ec 18             	sub    $0x18,%esp
80101615:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
80101618:	8d 73 0c             	lea    0xc(%ebx),%esi
8010161b:	56                   	push   %esi
8010161c:	e8 a3 22 00 00       	call   801038c4 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101621:	83 c4 10             	add    $0x10,%esp
80101624:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101628:	74 07                	je     80101631 <iput+0x25>
8010162a:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010162f:	74 33                	je     80101664 <iput+0x58>
  releasesleep(&ip->lock);
80101631:	83 ec 0c             	sub    $0xc,%esp
80101634:	56                   	push   %esi
80101635:	e8 d9 22 00 00       	call   80103913 <releasesleep>
  acquire(&icache.lock);
8010163a:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101641:	e8 8d 24 00 00       	call   80103ad3 <acquire>
  ip->ref--;
80101646:	8b 43 08             	mov    0x8(%ebx),%eax
80101649:	48                   	dec    %eax
8010164a:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010164d:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101654:	e8 df 24 00 00       	call   80103b38 <release>
}
80101659:	83 c4 10             	add    $0x10,%esp
8010165c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010165f:	5b                   	pop    %ebx
80101660:	5e                   	pop    %esi
80101661:	5f                   	pop    %edi
80101662:	5d                   	pop    %ebp
80101663:	c3                   	ret    
    acquire(&icache.lock);
80101664:	83 ec 0c             	sub    $0xc,%esp
80101667:	68 60 f9 10 80       	push   $0x8010f960
8010166c:	e8 62 24 00 00       	call   80103ad3 <acquire>
    int r = ip->ref;
80101671:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
80101674:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
8010167b:	e8 b8 24 00 00       	call   80103b38 <release>
    if(r == 1){
80101680:	83 c4 10             	add    $0x10,%esp
80101683:	83 ff 01             	cmp    $0x1,%edi
80101686:	75 a9                	jne    80101631 <iput+0x25>
      itrunc(ip);
80101688:	89 d8                	mov    %ebx,%eax
8010168a:	e8 9c fd ff ff       	call   8010142b <itrunc>
      ip->type = 0;
8010168f:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
80101695:	83 ec 0c             	sub    $0xc,%esp
80101698:	53                   	push   %ebx
80101699:	e8 10 fd ff ff       	call   801013ae <iupdate>
      ip->valid = 0;
8010169e:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
801016a5:	83 c4 10             	add    $0x10,%esp
801016a8:	eb 87                	jmp    80101631 <iput+0x25>

801016aa <iunlockput>:
{
801016aa:	55                   	push   %ebp
801016ab:	89 e5                	mov    %esp,%ebp
801016ad:	53                   	push   %ebx
801016ae:	83 ec 10             	sub    $0x10,%esp
801016b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
801016b4:	53                   	push   %ebx
801016b5:	e8 0d ff ff ff       	call   801015c7 <iunlock>
  iput(ip);
801016ba:	89 1c 24             	mov    %ebx,(%esp)
801016bd:	e8 4a ff ff ff       	call   8010160c <iput>
}
801016c2:	83 c4 10             	add    $0x10,%esp
801016c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801016c8:	c9                   	leave  
801016c9:	c3                   	ret    

801016ca <stati>:
{
801016ca:	55                   	push   %ebp
801016cb:	89 e5                	mov    %esp,%ebp
801016cd:	8b 55 08             	mov    0x8(%ebp),%edx
801016d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
801016d3:	8b 0a                	mov    (%edx),%ecx
801016d5:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
801016d8:	8b 4a 04             	mov    0x4(%edx),%ecx
801016db:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
801016de:	8b 4a 50             	mov    0x50(%edx),%ecx
801016e1:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
801016e4:	66 8b 4a 56          	mov    0x56(%edx),%cx
801016e8:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
801016ec:	8b 52 58             	mov    0x58(%edx),%edx
801016ef:	89 50 10             	mov    %edx,0x10(%eax)
}
801016f2:	5d                   	pop    %ebp
801016f3:	c3                   	ret    

801016f4 <readi>:
{
801016f4:	55                   	push   %ebp
801016f5:	89 e5                	mov    %esp,%ebp
801016f7:	57                   	push   %edi
801016f8:	56                   	push   %esi
801016f9:	53                   	push   %ebx
801016fa:	83 ec 0c             	sub    $0xc,%esp
  if(ip->type == T_DEV){
801016fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101700:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101705:	74 2c                	je     80101733 <readi+0x3f>
  if(off > ip->size || off + n < off)
80101707:	8b 45 08             	mov    0x8(%ebp),%eax
8010170a:	8b 40 58             	mov    0x58(%eax),%eax
8010170d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101710:	0f 82 d0 00 00 00    	jb     801017e6 <readi+0xf2>
80101716:	8b 55 10             	mov    0x10(%ebp),%edx
80101719:	03 55 14             	add    0x14(%ebp),%edx
8010171c:	0f 82 cb 00 00 00    	jb     801017ed <readi+0xf9>
  if(off + n > ip->size)
80101722:	39 d0                	cmp    %edx,%eax
80101724:	73 06                	jae    8010172c <readi+0x38>
    n = ip->size - off;
80101726:	2b 45 10             	sub    0x10(%ebp),%eax
80101729:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010172c:	bf 00 00 00 00       	mov    $0x0,%edi
80101731:	eb 55                	jmp    80101788 <readi+0x94>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101733:	66 8b 40 52          	mov    0x52(%eax),%ax
80101737:	66 83 f8 09          	cmp    $0x9,%ax
8010173b:	0f 87 97 00 00 00    	ja     801017d8 <readi+0xe4>
80101741:	98                   	cwtl   
80101742:	8b 04 c5 00 f9 10 80 	mov    -0x7fef0700(,%eax,8),%eax
80101749:	85 c0                	test   %eax,%eax
8010174b:	0f 84 8e 00 00 00    	je     801017df <readi+0xeb>
    return devsw[ip->major].read(ip, dst, n);
80101751:	83 ec 04             	sub    $0x4,%esp
80101754:	ff 75 14             	push   0x14(%ebp)
80101757:	ff 75 0c             	push   0xc(%ebp)
8010175a:	ff 75 08             	push   0x8(%ebp)
8010175d:	ff d0                	call   *%eax
8010175f:	83 c4 10             	add    $0x10,%esp
80101762:	eb 6c                	jmp    801017d0 <readi+0xdc>
    memmove(dst, bp->data + off%BSIZE, m);
80101764:	83 ec 04             	sub    $0x4,%esp
80101767:	53                   	push   %ebx
80101768:	8d 44 16 5c          	lea    0x5c(%esi,%edx,1),%eax
8010176c:	50                   	push   %eax
8010176d:	ff 75 0c             	push   0xc(%ebp)
80101770:	e8 80 24 00 00       	call   80103bf5 <memmove>
    brelse(bp);
80101775:	89 34 24             	mov    %esi,(%esp)
80101778:	e8 56 ea ff ff       	call   801001d3 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010177d:	01 df                	add    %ebx,%edi
8010177f:	01 5d 10             	add    %ebx,0x10(%ebp)
80101782:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101785:	83 c4 10             	add    $0x10,%esp
80101788:	39 7d 14             	cmp    %edi,0x14(%ebp)
8010178b:	76 40                	jbe    801017cd <readi+0xd9>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010178d:	8b 55 10             	mov    0x10(%ebp),%edx
80101790:	c1 ea 09             	shr    $0x9,%edx
80101793:	8b 45 08             	mov    0x8(%ebp),%eax
80101796:	e8 da f8 ff ff       	call   80101075 <bmap>
8010179b:	83 ec 08             	sub    $0x8,%esp
8010179e:	50                   	push   %eax
8010179f:	8b 45 08             	mov    0x8(%ebp),%eax
801017a2:	ff 30                	push   (%eax)
801017a4:	e8 c1 e9 ff ff       	call   8010016a <bread>
801017a9:	89 c6                	mov    %eax,%esi
    m = min(n - tot, BSIZE - off%BSIZE);
801017ab:	8b 55 10             	mov    0x10(%ebp),%edx
801017ae:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801017b4:	b8 00 02 00 00       	mov    $0x200,%eax
801017b9:	29 d0                	sub    %edx,%eax
801017bb:	8b 4d 14             	mov    0x14(%ebp),%ecx
801017be:	29 f9                	sub    %edi,%ecx
801017c0:	89 c3                	mov    %eax,%ebx
801017c2:	83 c4 10             	add    $0x10,%esp
801017c5:	39 c8                	cmp    %ecx,%eax
801017c7:	76 9b                	jbe    80101764 <readi+0x70>
801017c9:	89 cb                	mov    %ecx,%ebx
801017cb:	eb 97                	jmp    80101764 <readi+0x70>
  return n;
801017cd:	8b 45 14             	mov    0x14(%ebp),%eax
}
801017d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017d3:	5b                   	pop    %ebx
801017d4:	5e                   	pop    %esi
801017d5:	5f                   	pop    %edi
801017d6:	5d                   	pop    %ebp
801017d7:	c3                   	ret    
      return -1;
801017d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801017dd:	eb f1                	jmp    801017d0 <readi+0xdc>
801017df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801017e4:	eb ea                	jmp    801017d0 <readi+0xdc>
    return -1;
801017e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801017eb:	eb e3                	jmp    801017d0 <readi+0xdc>
801017ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801017f2:	eb dc                	jmp    801017d0 <readi+0xdc>

801017f4 <writei>:
{
801017f4:	55                   	push   %ebp
801017f5:	89 e5                	mov    %esp,%ebp
801017f7:	57                   	push   %edi
801017f8:	56                   	push   %esi
801017f9:	53                   	push   %ebx
801017fa:	83 ec 0c             	sub    $0xc,%esp
  if(ip->type == T_DEV){
801017fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101800:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101805:	74 2c                	je     80101833 <writei+0x3f>
  if(off > ip->size || off + n < off)
80101807:	8b 45 08             	mov    0x8(%ebp),%eax
8010180a:	8b 7d 10             	mov    0x10(%ebp),%edi
8010180d:	39 78 58             	cmp    %edi,0x58(%eax)
80101810:	0f 82 fd 00 00 00    	jb     80101913 <writei+0x11f>
80101816:	89 f8                	mov    %edi,%eax
80101818:	03 45 14             	add    0x14(%ebp),%eax
8010181b:	0f 82 f9 00 00 00    	jb     8010191a <writei+0x126>
  if(off + n > MAXFILE*BSIZE)
80101821:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101826:	0f 87 f5 00 00 00    	ja     80101921 <writei+0x12d>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010182c:	bf 00 00 00 00       	mov    $0x0,%edi
80101831:	eb 60                	jmp    80101893 <writei+0x9f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101833:	66 8b 40 52          	mov    0x52(%eax),%ax
80101837:	66 83 f8 09          	cmp    $0x9,%ax
8010183b:	0f 87 c4 00 00 00    	ja     80101905 <writei+0x111>
80101841:	98                   	cwtl   
80101842:	8b 04 c5 04 f9 10 80 	mov    -0x7fef06fc(,%eax,8),%eax
80101849:	85 c0                	test   %eax,%eax
8010184b:	0f 84 bb 00 00 00    	je     8010190c <writei+0x118>
    return devsw[ip->major].write(ip, src, n);
80101851:	83 ec 04             	sub    $0x4,%esp
80101854:	ff 75 14             	push   0x14(%ebp)
80101857:	ff 75 0c             	push   0xc(%ebp)
8010185a:	ff 75 08             	push   0x8(%ebp)
8010185d:	ff d0                	call   *%eax
8010185f:	83 c4 10             	add    $0x10,%esp
80101862:	e9 85 00 00 00       	jmp    801018ec <writei+0xf8>
    memmove(bp->data + off%BSIZE, src, m);
80101867:	83 ec 04             	sub    $0x4,%esp
8010186a:	56                   	push   %esi
8010186b:	ff 75 0c             	push   0xc(%ebp)
8010186e:	8d 44 13 5c          	lea    0x5c(%ebx,%edx,1),%eax
80101872:	50                   	push   %eax
80101873:	e8 7d 23 00 00       	call   80103bf5 <memmove>
    log_write(bp);
80101878:	89 1c 24             	mov    %ebx,(%esp)
8010187b:	e8 86 0f 00 00       	call   80102806 <log_write>
    brelse(bp);
80101880:	89 1c 24             	mov    %ebx,(%esp)
80101883:	e8 4b e9 ff ff       	call   801001d3 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101888:	01 f7                	add    %esi,%edi
8010188a:	01 75 10             	add    %esi,0x10(%ebp)
8010188d:	01 75 0c             	add    %esi,0xc(%ebp)
80101890:	83 c4 10             	add    $0x10,%esp
80101893:	3b 7d 14             	cmp    0x14(%ebp),%edi
80101896:	73 40                	jae    801018d8 <writei+0xe4>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101898:	8b 55 10             	mov    0x10(%ebp),%edx
8010189b:	c1 ea 09             	shr    $0x9,%edx
8010189e:	8b 45 08             	mov    0x8(%ebp),%eax
801018a1:	e8 cf f7 ff ff       	call   80101075 <bmap>
801018a6:	83 ec 08             	sub    $0x8,%esp
801018a9:	50                   	push   %eax
801018aa:	8b 45 08             	mov    0x8(%ebp),%eax
801018ad:	ff 30                	push   (%eax)
801018af:	e8 b6 e8 ff ff       	call   8010016a <bread>
801018b4:	89 c3                	mov    %eax,%ebx
    m = min(n - tot, BSIZE - off%BSIZE);
801018b6:	8b 55 10             	mov    0x10(%ebp),%edx
801018b9:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801018bf:	b8 00 02 00 00       	mov    $0x200,%eax
801018c4:	29 d0                	sub    %edx,%eax
801018c6:	8b 4d 14             	mov    0x14(%ebp),%ecx
801018c9:	29 f9                	sub    %edi,%ecx
801018cb:	89 c6                	mov    %eax,%esi
801018cd:	83 c4 10             	add    $0x10,%esp
801018d0:	39 c8                	cmp    %ecx,%eax
801018d2:	76 93                	jbe    80101867 <writei+0x73>
801018d4:	89 ce                	mov    %ecx,%esi
801018d6:	eb 8f                	jmp    80101867 <writei+0x73>
  if(n > 0 && off > ip->size){
801018d8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801018dc:	74 0b                	je     801018e9 <writei+0xf5>
801018de:	8b 45 08             	mov    0x8(%ebp),%eax
801018e1:	8b 7d 10             	mov    0x10(%ebp),%edi
801018e4:	39 78 58             	cmp    %edi,0x58(%eax)
801018e7:	72 0b                	jb     801018f4 <writei+0x100>
  return n;
801018e9:	8b 45 14             	mov    0x14(%ebp),%eax
}
801018ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
801018ef:	5b                   	pop    %ebx
801018f0:	5e                   	pop    %esi
801018f1:	5f                   	pop    %edi
801018f2:	5d                   	pop    %ebp
801018f3:	c3                   	ret    
    ip->size = off;
801018f4:	89 78 58             	mov    %edi,0x58(%eax)
    iupdate(ip);
801018f7:	83 ec 0c             	sub    $0xc,%esp
801018fa:	50                   	push   %eax
801018fb:	e8 ae fa ff ff       	call   801013ae <iupdate>
80101900:	83 c4 10             	add    $0x10,%esp
80101903:	eb e4                	jmp    801018e9 <writei+0xf5>
      return -1;
80101905:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010190a:	eb e0                	jmp    801018ec <writei+0xf8>
8010190c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101911:	eb d9                	jmp    801018ec <writei+0xf8>
    return -1;
80101913:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101918:	eb d2                	jmp    801018ec <writei+0xf8>
8010191a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010191f:	eb cb                	jmp    801018ec <writei+0xf8>
    return -1;
80101921:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101926:	eb c4                	jmp    801018ec <writei+0xf8>

80101928 <namecmp>:
{
80101928:	55                   	push   %ebp
80101929:	89 e5                	mov    %esp,%ebp
8010192b:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
8010192e:	6a 0e                	push   $0xe
80101930:	ff 75 0c             	push   0xc(%ebp)
80101933:	ff 75 08             	push   0x8(%ebp)
80101936:	e8 20 23 00 00       	call   80103c5b <strncmp>
}
8010193b:	c9                   	leave  
8010193c:	c3                   	ret    

8010193d <dirlookup>:
{
8010193d:	55                   	push   %ebp
8010193e:	89 e5                	mov    %esp,%ebp
80101940:	57                   	push   %edi
80101941:	56                   	push   %esi
80101942:	53                   	push   %ebx
80101943:	83 ec 1c             	sub    $0x1c,%esp
80101946:	8b 75 08             	mov    0x8(%ebp),%esi
80101949:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(dp->type != T_DIR)
8010194c:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101951:	75 07                	jne    8010195a <dirlookup+0x1d>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101953:	bb 00 00 00 00       	mov    $0x0,%ebx
80101958:	eb 1d                	jmp    80101977 <dirlookup+0x3a>
    panic("dirlookup not DIR");
8010195a:	83 ec 0c             	sub    $0xc,%esp
8010195d:	68 27 69 10 80       	push   $0x80106927
80101962:	e8 da e9 ff ff       	call   80100341 <panic>
      panic("dirlookup read");
80101967:	83 ec 0c             	sub    $0xc,%esp
8010196a:	68 39 69 10 80       	push   $0x80106939
8010196f:	e8 cd e9 ff ff       	call   80100341 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101974:	83 c3 10             	add    $0x10,%ebx
80101977:	39 5e 58             	cmp    %ebx,0x58(%esi)
8010197a:	76 48                	jbe    801019c4 <dirlookup+0x87>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010197c:	6a 10                	push   $0x10
8010197e:	53                   	push   %ebx
8010197f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101982:	50                   	push   %eax
80101983:	56                   	push   %esi
80101984:	e8 6b fd ff ff       	call   801016f4 <readi>
80101989:	83 c4 10             	add    $0x10,%esp
8010198c:	83 f8 10             	cmp    $0x10,%eax
8010198f:	75 d6                	jne    80101967 <dirlookup+0x2a>
    if(de.inum == 0)
80101991:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101996:	74 dc                	je     80101974 <dirlookup+0x37>
    if(namecmp(name, de.name) == 0){
80101998:	83 ec 08             	sub    $0x8,%esp
8010199b:	8d 45 da             	lea    -0x26(%ebp),%eax
8010199e:	50                   	push   %eax
8010199f:	57                   	push   %edi
801019a0:	e8 83 ff ff ff       	call   80101928 <namecmp>
801019a5:	83 c4 10             	add    $0x10,%esp
801019a8:	85 c0                	test   %eax,%eax
801019aa:	75 c8                	jne    80101974 <dirlookup+0x37>
      if(poff)
801019ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801019b0:	74 05                	je     801019b7 <dirlookup+0x7a>
        *poff = off;
801019b2:	8b 45 10             	mov    0x10(%ebp),%eax
801019b5:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
801019b7:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
801019bb:	8b 06                	mov    (%esi),%eax
801019bd:	e8 59 f7 ff ff       	call   8010111b <iget>
801019c2:	eb 05                	jmp    801019c9 <dirlookup+0x8c>
  return 0;
801019c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801019c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801019cc:	5b                   	pop    %ebx
801019cd:	5e                   	pop    %esi
801019ce:	5f                   	pop    %edi
801019cf:	5d                   	pop    %ebp
801019d0:	c3                   	ret    

801019d1 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801019d1:	55                   	push   %ebp
801019d2:	89 e5                	mov    %esp,%ebp
801019d4:	57                   	push   %edi
801019d5:	56                   	push   %esi
801019d6:	53                   	push   %ebx
801019d7:	83 ec 1c             	sub    $0x1c,%esp
801019da:	89 c3                	mov    %eax,%ebx
801019dc:	89 55 e0             	mov    %edx,-0x20(%ebp)
801019df:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
801019e2:	80 38 2f             	cmpb   $0x2f,(%eax)
801019e5:	74 17                	je     801019fe <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
801019e7:	e8 2e 17 00 00       	call   8010311a <myproc>
801019ec:	83 ec 0c             	sub    $0xc,%esp
801019ef:	ff 70 6c             	push   0x6c(%eax)
801019f2:	e8 e2 fa ff ff       	call   801014d9 <idup>
801019f7:	89 c6                	mov    %eax,%esi
801019f9:	83 c4 10             	add    $0x10,%esp
801019fc:	eb 53                	jmp    80101a51 <namex+0x80>
    ip = iget(ROOTDEV, ROOTINO);
801019fe:	ba 01 00 00 00       	mov    $0x1,%edx
80101a03:	b8 01 00 00 00       	mov    $0x1,%eax
80101a08:	e8 0e f7 ff ff       	call   8010111b <iget>
80101a0d:	89 c6                	mov    %eax,%esi
80101a0f:	eb 40                	jmp    80101a51 <namex+0x80>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101a11:	83 ec 0c             	sub    $0xc,%esp
80101a14:	56                   	push   %esi
80101a15:	e8 90 fc ff ff       	call   801016aa <iunlockput>
      return 0;
80101a1a:	83 c4 10             	add    $0x10,%esp
80101a1d:	be 00 00 00 00       	mov    $0x0,%esi
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101a22:	89 f0                	mov    %esi,%eax
80101a24:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a27:	5b                   	pop    %ebx
80101a28:	5e                   	pop    %esi
80101a29:	5f                   	pop    %edi
80101a2a:	5d                   	pop    %ebp
80101a2b:	c3                   	ret    
    if((next = dirlookup(ip, name, 0)) == 0){
80101a2c:	83 ec 04             	sub    $0x4,%esp
80101a2f:	6a 00                	push   $0x0
80101a31:	ff 75 e4             	push   -0x1c(%ebp)
80101a34:	56                   	push   %esi
80101a35:	e8 03 ff ff ff       	call   8010193d <dirlookup>
80101a3a:	89 c7                	mov    %eax,%edi
80101a3c:	83 c4 10             	add    $0x10,%esp
80101a3f:	85 c0                	test   %eax,%eax
80101a41:	74 4a                	je     80101a8d <namex+0xbc>
    iunlockput(ip);
80101a43:	83 ec 0c             	sub    $0xc,%esp
80101a46:	56                   	push   %esi
80101a47:	e8 5e fc ff ff       	call   801016aa <iunlockput>
80101a4c:	83 c4 10             	add    $0x10,%esp
    ip = next;
80101a4f:	89 fe                	mov    %edi,%esi
  while((path = skipelem(path, name)) != 0){
80101a51:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101a54:	89 d8                	mov    %ebx,%eax
80101a56:	e8 97 f4 ff ff       	call   80100ef2 <skipelem>
80101a5b:	89 c3                	mov    %eax,%ebx
80101a5d:	85 c0                	test   %eax,%eax
80101a5f:	74 3c                	je     80101a9d <namex+0xcc>
    ilock(ip);
80101a61:	83 ec 0c             	sub    $0xc,%esp
80101a64:	56                   	push   %esi
80101a65:	e8 9d fa ff ff       	call   80101507 <ilock>
    if(ip->type != T_DIR){
80101a6a:	83 c4 10             	add    $0x10,%esp
80101a6d:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101a72:	75 9d                	jne    80101a11 <namex+0x40>
    if(nameiparent && *path == '\0'){
80101a74:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101a78:	74 b2                	je     80101a2c <namex+0x5b>
80101a7a:	80 3b 00             	cmpb   $0x0,(%ebx)
80101a7d:	75 ad                	jne    80101a2c <namex+0x5b>
      iunlock(ip);
80101a7f:	83 ec 0c             	sub    $0xc,%esp
80101a82:	56                   	push   %esi
80101a83:	e8 3f fb ff ff       	call   801015c7 <iunlock>
      return ip;
80101a88:	83 c4 10             	add    $0x10,%esp
80101a8b:	eb 95                	jmp    80101a22 <namex+0x51>
      iunlockput(ip);
80101a8d:	83 ec 0c             	sub    $0xc,%esp
80101a90:	56                   	push   %esi
80101a91:	e8 14 fc ff ff       	call   801016aa <iunlockput>
      return 0;
80101a96:	83 c4 10             	add    $0x10,%esp
80101a99:	89 fe                	mov    %edi,%esi
80101a9b:	eb 85                	jmp    80101a22 <namex+0x51>
  if(nameiparent){
80101a9d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101aa1:	0f 84 7b ff ff ff    	je     80101a22 <namex+0x51>
    iput(ip);
80101aa7:	83 ec 0c             	sub    $0xc,%esp
80101aaa:	56                   	push   %esi
80101aab:	e8 5c fb ff ff       	call   8010160c <iput>
    return 0;
80101ab0:	83 c4 10             	add    $0x10,%esp
80101ab3:	89 de                	mov    %ebx,%esi
80101ab5:	e9 68 ff ff ff       	jmp    80101a22 <namex+0x51>

80101aba <dirlink>:
{
80101aba:	55                   	push   %ebp
80101abb:	89 e5                	mov    %esp,%ebp
80101abd:	57                   	push   %edi
80101abe:	56                   	push   %esi
80101abf:	53                   	push   %ebx
80101ac0:	83 ec 20             	sub    $0x20,%esp
80101ac3:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101ac6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101ac9:	6a 00                	push   $0x0
80101acb:	57                   	push   %edi
80101acc:	53                   	push   %ebx
80101acd:	e8 6b fe ff ff       	call   8010193d <dirlookup>
80101ad2:	83 c4 10             	add    $0x10,%esp
80101ad5:	85 c0                	test   %eax,%eax
80101ad7:	75 2d                	jne    80101b06 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101ad9:	b8 00 00 00 00       	mov    $0x0,%eax
80101ade:	89 c6                	mov    %eax,%esi
80101ae0:	39 43 58             	cmp    %eax,0x58(%ebx)
80101ae3:	76 41                	jbe    80101b26 <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101ae5:	6a 10                	push   $0x10
80101ae7:	50                   	push   %eax
80101ae8:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101aeb:	50                   	push   %eax
80101aec:	53                   	push   %ebx
80101aed:	e8 02 fc ff ff       	call   801016f4 <readi>
80101af2:	83 c4 10             	add    $0x10,%esp
80101af5:	83 f8 10             	cmp    $0x10,%eax
80101af8:	75 1f                	jne    80101b19 <dirlink+0x5f>
    if(de.inum == 0)
80101afa:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101aff:	74 25                	je     80101b26 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b01:	8d 46 10             	lea    0x10(%esi),%eax
80101b04:	eb d8                	jmp    80101ade <dirlink+0x24>
    iput(ip);
80101b06:	83 ec 0c             	sub    $0xc,%esp
80101b09:	50                   	push   %eax
80101b0a:	e8 fd fa ff ff       	call   8010160c <iput>
    return -1;
80101b0f:	83 c4 10             	add    $0x10,%esp
80101b12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b17:	eb 3d                	jmp    80101b56 <dirlink+0x9c>
      panic("dirlink read");
80101b19:	83 ec 0c             	sub    $0xc,%esp
80101b1c:	68 48 69 10 80       	push   $0x80106948
80101b21:	e8 1b e8 ff ff       	call   80100341 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b26:	83 ec 04             	sub    $0x4,%esp
80101b29:	6a 0e                	push   $0xe
80101b2b:	57                   	push   %edi
80101b2c:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101b2f:	8d 45 da             	lea    -0x26(%ebp),%eax
80101b32:	50                   	push   %eax
80101b33:	e8 5b 21 00 00       	call   80103c93 <strncpy>
  de.inum = inum;
80101b38:	8b 45 10             	mov    0x10(%ebp),%eax
80101b3b:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101b3f:	6a 10                	push   $0x10
80101b41:	56                   	push   %esi
80101b42:	57                   	push   %edi
80101b43:	53                   	push   %ebx
80101b44:	e8 ab fc ff ff       	call   801017f4 <writei>
80101b49:	83 c4 20             	add    $0x20,%esp
80101b4c:	83 f8 10             	cmp    $0x10,%eax
80101b4f:	75 0d                	jne    80101b5e <dirlink+0xa4>
  return 0;
80101b51:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b59:	5b                   	pop    %ebx
80101b5a:	5e                   	pop    %esi
80101b5b:	5f                   	pop    %edi
80101b5c:	5d                   	pop    %ebp
80101b5d:	c3                   	ret    
    panic("dirlink");
80101b5e:	83 ec 0c             	sub    $0xc,%esp
80101b61:	68 38 6f 10 80       	push   $0x80106f38
80101b66:	e8 d6 e7 ff ff       	call   80100341 <panic>

80101b6b <namei>:

struct inode*
namei(char *path)
{
80101b6b:	55                   	push   %ebp
80101b6c:	89 e5                	mov    %esp,%ebp
80101b6e:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101b71:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101b74:	ba 00 00 00 00       	mov    $0x0,%edx
80101b79:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7c:	e8 50 fe ff ff       	call   801019d1 <namex>
}
80101b81:	c9                   	leave  
80101b82:	c3                   	ret    

80101b83 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101b83:	55                   	push   %ebp
80101b84:	89 e5                	mov    %esp,%ebp
80101b86:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101b8c:	ba 01 00 00 00       	mov    $0x1,%edx
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	e8 38 fe ff ff       	call   801019d1 <namex>
}
80101b99:	c9                   	leave  
80101b9a:	c3                   	ret    

80101b9b <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101b9b:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101b9d:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101ba2:	ec                   	in     (%dx),%al
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101ba3:	88 c2                	mov    %al,%dl
80101ba5:	83 e2 c0             	and    $0xffffffc0,%edx
80101ba8:	80 fa 40             	cmp    $0x40,%dl
80101bab:	75 f0                	jne    80101b9d <idewait+0x2>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101bad:	85 c9                	test   %ecx,%ecx
80101baf:	74 09                	je     80101bba <idewait+0x1f>
80101bb1:	a8 21                	test   $0x21,%al
80101bb3:	75 08                	jne    80101bbd <idewait+0x22>
    return -1;
  return 0;
80101bb5:	b9 00 00 00 00       	mov    $0x0,%ecx
}
80101bba:	89 c8                	mov    %ecx,%eax
80101bbc:	c3                   	ret    
    return -1;
80101bbd:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
80101bc2:	eb f6                	jmp    80101bba <idewait+0x1f>

80101bc4 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101bc4:	55                   	push   %ebp
80101bc5:	89 e5                	mov    %esp,%ebp
80101bc7:	56                   	push   %esi
80101bc8:	53                   	push   %ebx
  if(b == 0)
80101bc9:	85 c0                	test   %eax,%eax
80101bcb:	0f 84 85 00 00 00    	je     80101c56 <idestart+0x92>
80101bd1:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101bd3:	8b 58 08             	mov    0x8(%eax),%ebx
80101bd6:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101bdc:	0f 87 81 00 00 00    	ja     80101c63 <idestart+0x9f>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101be2:	b8 00 00 00 00       	mov    $0x0,%eax
80101be7:	e8 af ff ff ff       	call   80101b9b <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101bec:	b0 00                	mov    $0x0,%al
80101bee:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101bf3:	ee                   	out    %al,(%dx)
80101bf4:	b0 01                	mov    $0x1,%al
80101bf6:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101bfb:	ee                   	out    %al,(%dx)
80101bfc:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101c01:	88 d8                	mov    %bl,%al
80101c03:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101c04:	0f b6 c7             	movzbl %bh,%eax
80101c07:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101c0c:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101c0d:	89 d8                	mov    %ebx,%eax
80101c0f:	c1 f8 10             	sar    $0x10,%eax
80101c12:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101c17:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101c18:	8a 46 04             	mov    0x4(%esi),%al
80101c1b:	c1 e0 04             	shl    $0x4,%eax
80101c1e:	83 e0 10             	and    $0x10,%eax
80101c21:	c1 fb 18             	sar    $0x18,%ebx
80101c24:	83 e3 0f             	and    $0xf,%ebx
80101c27:	09 d8                	or     %ebx,%eax
80101c29:	83 c8 e0             	or     $0xffffffe0,%eax
80101c2c:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101c31:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101c32:	f6 06 04             	testb  $0x4,(%esi)
80101c35:	74 39                	je     80101c70 <idestart+0xac>
80101c37:	b0 30                	mov    $0x30,%al
80101c39:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c3e:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
80101c3f:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101c42:	b9 80 00 00 00       	mov    $0x80,%ecx
80101c47:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101c4c:	fc                   	cld    
80101c4d:	f3 6f                	rep outsl %ds:(%esi),(%dx)
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101c4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101c52:	5b                   	pop    %ebx
80101c53:	5e                   	pop    %esi
80101c54:	5d                   	pop    %ebp
80101c55:	c3                   	ret    
    panic("idestart");
80101c56:	83 ec 0c             	sub    $0xc,%esp
80101c59:	68 ab 69 10 80       	push   $0x801069ab
80101c5e:	e8 de e6 ff ff       	call   80100341 <panic>
    panic("incorrect blockno");
80101c63:	83 ec 0c             	sub    $0xc,%esp
80101c66:	68 b4 69 10 80       	push   $0x801069b4
80101c6b:	e8 d1 e6 ff ff       	call   80100341 <panic>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101c70:	b0 20                	mov    $0x20,%al
80101c72:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c77:	ee                   	out    %al,(%dx)
}
80101c78:	eb d5                	jmp    80101c4f <idestart+0x8b>

80101c7a <ideinit>:
{
80101c7a:	55                   	push   %ebp
80101c7b:	89 e5                	mov    %esp,%ebp
80101c7d:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101c80:	68 c6 69 10 80       	push   $0x801069c6
80101c85:	68 00 16 11 80       	push   $0x80111600
80101c8a:	e8 0d 1d 00 00       	call   8010399c <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101c8f:	83 c4 08             	add    $0x8,%esp
80101c92:	a1 84 17 11 80       	mov    0x80111784,%eax
80101c97:	48                   	dec    %eax
80101c98:	50                   	push   %eax
80101c99:	6a 0e                	push   $0xe
80101c9b:	e8 46 02 00 00       	call   80101ee6 <ioapicenable>
  idewait(0);
80101ca0:	b8 00 00 00 00       	mov    $0x0,%eax
80101ca5:	e8 f1 fe ff ff       	call   80101b9b <idewait>
80101caa:	b0 f0                	mov    $0xf0,%al
80101cac:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101cb1:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101cb2:	83 c4 10             	add    $0x10,%esp
80101cb5:	b9 00 00 00 00       	mov    $0x0,%ecx
80101cba:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101cc0:	7f 17                	jg     80101cd9 <ideinit+0x5f>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101cc2:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101cc7:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101cc8:	84 c0                	test   %al,%al
80101cca:	75 03                	jne    80101ccf <ideinit+0x55>
  for(i=0; i<1000; i++){
80101ccc:	41                   	inc    %ecx
80101ccd:	eb eb                	jmp    80101cba <ideinit+0x40>
      havedisk1 = 1;
80101ccf:	c7 05 e0 15 11 80 01 	movl   $0x1,0x801115e0
80101cd6:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101cd9:	b0 e0                	mov    $0xe0,%al
80101cdb:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101ce0:	ee                   	out    %al,(%dx)
}
80101ce1:	c9                   	leave  
80101ce2:	c3                   	ret    

80101ce3 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101ce3:	55                   	push   %ebp
80101ce4:	89 e5                	mov    %esp,%ebp
80101ce6:	57                   	push   %edi
80101ce7:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101ce8:	83 ec 0c             	sub    $0xc,%esp
80101ceb:	68 00 16 11 80       	push   $0x80111600
80101cf0:	e8 de 1d 00 00       	call   80103ad3 <acquire>

  if((b = idequeue) == 0){
80101cf5:	8b 1d e4 15 11 80    	mov    0x801115e4,%ebx
80101cfb:	83 c4 10             	add    $0x10,%esp
80101cfe:	85 db                	test   %ebx,%ebx
80101d00:	74 4a                	je     80101d4c <ideintr+0x69>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101d02:	8b 43 58             	mov    0x58(%ebx),%eax
80101d05:	a3 e4 15 11 80       	mov    %eax,0x801115e4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101d0a:	f6 03 04             	testb  $0x4,(%ebx)
80101d0d:	74 4f                	je     80101d5e <ideintr+0x7b>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101d0f:	8b 03                	mov    (%ebx),%eax
80101d11:	83 c8 02             	or     $0x2,%eax
80101d14:	89 03                	mov    %eax,(%ebx)
  b->flags &= ~B_DIRTY;
80101d16:	83 e0 fb             	and    $0xfffffffb,%eax
80101d19:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101d1b:	83 ec 0c             	sub    $0xc,%esp
80101d1e:	53                   	push   %ebx
80101d1f:	e8 20 1a 00 00       	call   80103744 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101d24:	a1 e4 15 11 80       	mov    0x801115e4,%eax
80101d29:	83 c4 10             	add    $0x10,%esp
80101d2c:	85 c0                	test   %eax,%eax
80101d2e:	74 05                	je     80101d35 <ideintr+0x52>
    idestart(idequeue);
80101d30:	e8 8f fe ff ff       	call   80101bc4 <idestart>

  release(&idelock);
80101d35:	83 ec 0c             	sub    $0xc,%esp
80101d38:	68 00 16 11 80       	push   $0x80111600
80101d3d:	e8 f6 1d 00 00       	call   80103b38 <release>
80101d42:	83 c4 10             	add    $0x10,%esp
}
80101d45:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101d48:	5b                   	pop    %ebx
80101d49:	5f                   	pop    %edi
80101d4a:	5d                   	pop    %ebp
80101d4b:	c3                   	ret    
    release(&idelock);
80101d4c:	83 ec 0c             	sub    $0xc,%esp
80101d4f:	68 00 16 11 80       	push   $0x80111600
80101d54:	e8 df 1d 00 00       	call   80103b38 <release>
    return;
80101d59:	83 c4 10             	add    $0x10,%esp
80101d5c:	eb e7                	jmp    80101d45 <ideintr+0x62>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101d5e:	b8 01 00 00 00       	mov    $0x1,%eax
80101d63:	e8 33 fe ff ff       	call   80101b9b <idewait>
80101d68:	85 c0                	test   %eax,%eax
80101d6a:	78 a3                	js     80101d0f <ideintr+0x2c>
    insl(0x1f0, b->data, BSIZE/4);
80101d6c:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101d6f:	b9 80 00 00 00       	mov    $0x80,%ecx
80101d74:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101d79:	fc                   	cld    
80101d7a:	f3 6d                	rep insl (%dx),%es:(%edi)
}
80101d7c:	eb 91                	jmp    80101d0f <ideintr+0x2c>

80101d7e <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101d7e:	55                   	push   %ebp
80101d7f:	89 e5                	mov    %esp,%ebp
80101d81:	53                   	push   %ebx
80101d82:	83 ec 10             	sub    $0x10,%esp
80101d85:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101d88:	8d 43 0c             	lea    0xc(%ebx),%eax
80101d8b:	50                   	push   %eax
80101d8c:	e8 bd 1b 00 00       	call   8010394e <holdingsleep>
80101d91:	83 c4 10             	add    $0x10,%esp
80101d94:	85 c0                	test   %eax,%eax
80101d96:	74 37                	je     80101dcf <iderw+0x51>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101d98:	8b 03                	mov    (%ebx),%eax
80101d9a:	83 e0 06             	and    $0x6,%eax
80101d9d:	83 f8 02             	cmp    $0x2,%eax
80101da0:	74 3a                	je     80101ddc <iderw+0x5e>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101da2:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101da6:	74 09                	je     80101db1 <iderw+0x33>
80101da8:	83 3d e0 15 11 80 00 	cmpl   $0x0,0x801115e0
80101daf:	74 38                	je     80101de9 <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101db1:	83 ec 0c             	sub    $0xc,%esp
80101db4:	68 00 16 11 80       	push   $0x80111600
80101db9:	e8 15 1d 00 00       	call   80103ad3 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101dbe:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101dc5:	83 c4 10             	add    $0x10,%esp
80101dc8:	ba e4 15 11 80       	mov    $0x801115e4,%edx
80101dcd:	eb 2a                	jmp    80101df9 <iderw+0x7b>
    panic("iderw: buf not locked");
80101dcf:	83 ec 0c             	sub    $0xc,%esp
80101dd2:	68 ca 69 10 80       	push   $0x801069ca
80101dd7:	e8 65 e5 ff ff       	call   80100341 <panic>
    panic("iderw: nothing to do");
80101ddc:	83 ec 0c             	sub    $0xc,%esp
80101ddf:	68 e0 69 10 80       	push   $0x801069e0
80101de4:	e8 58 e5 ff ff       	call   80100341 <panic>
    panic("iderw: ide disk 1 not present");
80101de9:	83 ec 0c             	sub    $0xc,%esp
80101dec:	68 f5 69 10 80       	push   $0x801069f5
80101df1:	e8 4b e5 ff ff       	call   80100341 <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101df6:	8d 50 58             	lea    0x58(%eax),%edx
80101df9:	8b 02                	mov    (%edx),%eax
80101dfb:	85 c0                	test   %eax,%eax
80101dfd:	75 f7                	jne    80101df6 <iderw+0x78>
    ;
  *pp = b;
80101dff:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101e01:	39 1d e4 15 11 80    	cmp    %ebx,0x801115e4
80101e07:	75 1a                	jne    80101e23 <iderw+0xa5>
    idestart(b);
80101e09:	89 d8                	mov    %ebx,%eax
80101e0b:	e8 b4 fd ff ff       	call   80101bc4 <idestart>
80101e10:	eb 11                	jmp    80101e23 <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101e12:	83 ec 08             	sub    $0x8,%esp
80101e15:	68 00 16 11 80       	push   $0x80111600
80101e1a:	53                   	push   %ebx
80101e1b:	e8 b1 17 00 00       	call   801035d1 <sleep>
80101e20:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101e23:	8b 03                	mov    (%ebx),%eax
80101e25:	83 e0 06             	and    $0x6,%eax
80101e28:	83 f8 02             	cmp    $0x2,%eax
80101e2b:	75 e5                	jne    80101e12 <iderw+0x94>
  }


  release(&idelock);
80101e2d:	83 ec 0c             	sub    $0xc,%esp
80101e30:	68 00 16 11 80       	push   $0x80111600
80101e35:	e8 fe 1c 00 00       	call   80103b38 <release>
}
80101e3a:	83 c4 10             	add    $0x10,%esp
80101e3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101e40:	c9                   	leave  
80101e41:	c3                   	ret    

80101e42 <ioapicread>:
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
80101e42:	8b 15 34 16 11 80    	mov    0x80111634,%edx
80101e48:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101e4a:	a1 34 16 11 80       	mov    0x80111634,%eax
80101e4f:	8b 40 10             	mov    0x10(%eax),%eax
}
80101e52:	c3                   	ret    

80101e53 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80101e53:	8b 0d 34 16 11 80    	mov    0x80111634,%ecx
80101e59:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101e5b:	a1 34 16 11 80       	mov    0x80111634,%eax
80101e60:	89 50 10             	mov    %edx,0x10(%eax)
}
80101e63:	c3                   	ret    

80101e64 <ioapicinit>:

void
ioapicinit(void)
{
80101e64:	55                   	push   %ebp
80101e65:	89 e5                	mov    %esp,%ebp
80101e67:	57                   	push   %edi
80101e68:	56                   	push   %esi
80101e69:	53                   	push   %ebx
80101e6a:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101e6d:	c7 05 34 16 11 80 00 	movl   $0xfec00000,0x80111634
80101e74:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101e77:	b8 01 00 00 00       	mov    $0x1,%eax
80101e7c:	e8 c1 ff ff ff       	call   80101e42 <ioapicread>
80101e81:	c1 e8 10             	shr    $0x10,%eax
80101e84:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80101e87:	b8 00 00 00 00       	mov    $0x0,%eax
80101e8c:	e8 b1 ff ff ff       	call   80101e42 <ioapicread>
80101e91:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101e94:	0f b6 15 80 17 11 80 	movzbl 0x80111780,%edx
80101e9b:	39 c2                	cmp    %eax,%edx
80101e9d:	75 07                	jne    80101ea6 <ioapicinit+0x42>
{
80101e9f:	bb 00 00 00 00       	mov    $0x0,%ebx
80101ea4:	eb 34                	jmp    80101eda <ioapicinit+0x76>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101ea6:	83 ec 0c             	sub    $0xc,%esp
80101ea9:	68 14 6a 10 80       	push   $0x80106a14
80101eae:	e8 27 e7 ff ff       	call   801005da <cprintf>
80101eb3:	83 c4 10             	add    $0x10,%esp
80101eb6:	eb e7                	jmp    80101e9f <ioapicinit+0x3b>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101eb8:	8d 53 20             	lea    0x20(%ebx),%edx
80101ebb:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101ec1:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101ec5:	89 f0                	mov    %esi,%eax
80101ec7:	e8 87 ff ff ff       	call   80101e53 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101ecc:	8d 46 01             	lea    0x1(%esi),%eax
80101ecf:	ba 00 00 00 00       	mov    $0x0,%edx
80101ed4:	e8 7a ff ff ff       	call   80101e53 <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80101ed9:	43                   	inc    %ebx
80101eda:	39 fb                	cmp    %edi,%ebx
80101edc:	7e da                	jle    80101eb8 <ioapicinit+0x54>
  }
}
80101ede:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101ee1:	5b                   	pop    %ebx
80101ee2:	5e                   	pop    %esi
80101ee3:	5f                   	pop    %edi
80101ee4:	5d                   	pop    %ebp
80101ee5:	c3                   	ret    

80101ee6 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80101ee6:	55                   	push   %ebp
80101ee7:	89 e5                	mov    %esp,%ebp
80101ee9:	53                   	push   %ebx
80101eea:	83 ec 04             	sub    $0x4,%esp
80101eed:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101ef0:	8d 50 20             	lea    0x20(%eax),%edx
80101ef3:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80101ef7:	89 d8                	mov    %ebx,%eax
80101ef9:	e8 55 ff ff ff       	call   80101e53 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101efe:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f01:	c1 e2 18             	shl    $0x18,%edx
80101f04:	8d 43 01             	lea    0x1(%ebx),%eax
80101f07:	e8 47 ff ff ff       	call   80101e53 <ioapicwrite>
}
80101f0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101f0f:	c9                   	leave  
80101f10:	c3                   	ret    

80101f11 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80101f11:	55                   	push   %ebp
80101f12:	89 e5                	mov    %esp,%ebp
80101f14:	53                   	push   %ebx
80101f15:	83 ec 04             	sub    $0x4,%esp
80101f18:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80101f1b:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80101f21:	75 4c                	jne    80101f6f <kfree+0x5e>
80101f23:	81 fb d0 55 11 80    	cmp    $0x801155d0,%ebx
80101f29:	72 44                	jb     80101f6f <kfree+0x5e>
80101f2b:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80101f31:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80101f36:	77 37                	ja     80101f6f <kfree+0x5e>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80101f38:	83 ec 04             	sub    $0x4,%esp
80101f3b:	68 00 10 00 00       	push   $0x1000
80101f40:	6a 01                	push   $0x1
80101f42:	53                   	push   %ebx
80101f43:	e8 37 1c 00 00       	call   80103b7f <memset>

  if(kmem.use_lock)
80101f48:	83 c4 10             	add    $0x10,%esp
80101f4b:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80101f52:	75 28                	jne    80101f7c <kfree+0x6b>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80101f54:	a1 78 16 11 80       	mov    0x80111678,%eax
80101f59:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80101f5b:	89 1d 78 16 11 80    	mov    %ebx,0x80111678
  if(kmem.use_lock)
80101f61:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80101f68:	75 24                	jne    80101f8e <kfree+0x7d>
    release(&kmem.lock);
}
80101f6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101f6d:	c9                   	leave  
80101f6e:	c3                   	ret    
    panic("kfree");
80101f6f:	83 ec 0c             	sub    $0xc,%esp
80101f72:	68 46 6a 10 80       	push   $0x80106a46
80101f77:	e8 c5 e3 ff ff       	call   80100341 <panic>
    acquire(&kmem.lock);
80101f7c:	83 ec 0c             	sub    $0xc,%esp
80101f7f:	68 40 16 11 80       	push   $0x80111640
80101f84:	e8 4a 1b 00 00       	call   80103ad3 <acquire>
80101f89:	83 c4 10             	add    $0x10,%esp
80101f8c:	eb c6                	jmp    80101f54 <kfree+0x43>
    release(&kmem.lock);
80101f8e:	83 ec 0c             	sub    $0xc,%esp
80101f91:	68 40 16 11 80       	push   $0x80111640
80101f96:	e8 9d 1b 00 00       	call   80103b38 <release>
80101f9b:	83 c4 10             	add    $0x10,%esp
}
80101f9e:	eb ca                	jmp    80101f6a <kfree+0x59>

80101fa0 <freerange>:
{
80101fa0:	55                   	push   %ebp
80101fa1:	89 e5                	mov    %esp,%ebp
80101fa3:	56                   	push   %esi
80101fa4:	53                   	push   %ebx
80101fa5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  p = (char*)PGROUNDUP((uint)vstart);
80101fa8:	8b 45 08             	mov    0x8(%ebp),%eax
80101fab:	05 ff 0f 00 00       	add    $0xfff,%eax
80101fb0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80101fb5:	eb 0e                	jmp    80101fc5 <freerange+0x25>
    kfree(p);
80101fb7:	83 ec 0c             	sub    $0xc,%esp
80101fba:	50                   	push   %eax
80101fbb:	e8 51 ff ff ff       	call   80101f11 <kfree>
80101fc0:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80101fc3:	89 f0                	mov    %esi,%eax
80101fc5:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
80101fcb:	39 de                	cmp    %ebx,%esi
80101fcd:	76 e8                	jbe    80101fb7 <freerange+0x17>
}
80101fcf:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101fd2:	5b                   	pop    %ebx
80101fd3:	5e                   	pop    %esi
80101fd4:	5d                   	pop    %ebp
80101fd5:	c3                   	ret    

80101fd6 <kinit1>:
{
80101fd6:	55                   	push   %ebp
80101fd7:	89 e5                	mov    %esp,%ebp
80101fd9:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
80101fdc:	68 4c 6a 10 80       	push   $0x80106a4c
80101fe1:	68 40 16 11 80       	push   $0x80111640
80101fe6:	e8 b1 19 00 00       	call   8010399c <initlock>
  kmem.use_lock = 0;
80101feb:	c7 05 74 16 11 80 00 	movl   $0x0,0x80111674
80101ff2:	00 00 00 
  freerange(vstart, vend);
80101ff5:	83 c4 08             	add    $0x8,%esp
80101ff8:	ff 75 0c             	push   0xc(%ebp)
80101ffb:	ff 75 08             	push   0x8(%ebp)
80101ffe:	e8 9d ff ff ff       	call   80101fa0 <freerange>
}
80102003:	83 c4 10             	add    $0x10,%esp
80102006:	c9                   	leave  
80102007:	c3                   	ret    

80102008 <kinit2>:
{
80102008:	55                   	push   %ebp
80102009:	89 e5                	mov    %esp,%ebp
8010200b:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
8010200e:	ff 75 0c             	push   0xc(%ebp)
80102011:	ff 75 08             	push   0x8(%ebp)
80102014:	e8 87 ff ff ff       	call   80101fa0 <freerange>
  kmem.use_lock = 1;
80102019:	c7 05 74 16 11 80 01 	movl   $0x1,0x80111674
80102020:	00 00 00 
}
80102023:	83 c4 10             	add    $0x10,%esp
80102026:	c9                   	leave  
80102027:	c3                   	ret    

80102028 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102028:	55                   	push   %ebp
80102029:	89 e5                	mov    %esp,%ebp
8010202b:	53                   	push   %ebx
8010202c:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
8010202f:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80102036:	75 21                	jne    80102059 <kalloc+0x31>
    acquire(&kmem.lock);
  r = kmem.freelist;
80102038:	8b 1d 78 16 11 80    	mov    0x80111678,%ebx
  if(r)
8010203e:	85 db                	test   %ebx,%ebx
80102040:	74 07                	je     80102049 <kalloc+0x21>
    kmem.freelist = r->next;
80102042:	8b 03                	mov    (%ebx),%eax
80102044:	a3 78 16 11 80       	mov    %eax,0x80111678
  if(kmem.use_lock)
80102049:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80102050:	75 19                	jne    8010206b <kalloc+0x43>
    release(&kmem.lock);
  return (char*)r;
}
80102052:	89 d8                	mov    %ebx,%eax
80102054:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102057:	c9                   	leave  
80102058:	c3                   	ret    
    acquire(&kmem.lock);
80102059:	83 ec 0c             	sub    $0xc,%esp
8010205c:	68 40 16 11 80       	push   $0x80111640
80102061:	e8 6d 1a 00 00       	call   80103ad3 <acquire>
80102066:	83 c4 10             	add    $0x10,%esp
80102069:	eb cd                	jmp    80102038 <kalloc+0x10>
    release(&kmem.lock);
8010206b:	83 ec 0c             	sub    $0xc,%esp
8010206e:	68 40 16 11 80       	push   $0x80111640
80102073:	e8 c0 1a 00 00       	call   80103b38 <release>
80102078:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010207b:	eb d5                	jmp    80102052 <kalloc+0x2a>

8010207d <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010207d:	ba 64 00 00 00       	mov    $0x64,%edx
80102082:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102083:	a8 01                	test   $0x1,%al
80102085:	0f 84 b3 00 00 00    	je     8010213e <kbdgetc+0xc1>
8010208b:	ba 60 00 00 00       	mov    $0x60,%edx
80102090:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102091:	0f b6 c8             	movzbl %al,%ecx

  if(data == 0xE0){
80102094:	3c e0                	cmp    $0xe0,%al
80102096:	74 61                	je     801020f9 <kbdgetc+0x7c>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102098:	84 c0                	test   %al,%al
8010209a:	78 6a                	js     80102106 <kbdgetc+0x89>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
8010209c:	8b 15 7c 16 11 80    	mov    0x8011167c,%edx
801020a2:	f6 c2 40             	test   $0x40,%dl
801020a5:	74 0f                	je     801020b6 <kbdgetc+0x39>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801020a7:	83 c8 80             	or     $0xffffff80,%eax
801020aa:	0f b6 c8             	movzbl %al,%ecx
    shift &= ~E0ESC;
801020ad:	83 e2 bf             	and    $0xffffffbf,%edx
801020b0:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  }

  shift |= shiftcode[data];
801020b6:	0f b6 91 80 6b 10 80 	movzbl -0x7fef9480(%ecx),%edx
801020bd:	0b 15 7c 16 11 80    	or     0x8011167c,%edx
801020c3:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  shift ^= togglecode[data];
801020c9:	0f b6 81 80 6a 10 80 	movzbl -0x7fef9580(%ecx),%eax
801020d0:	31 c2                	xor    %eax,%edx
801020d2:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  c = charcode[shift & (CTL | SHIFT)][data];
801020d8:	89 d0                	mov    %edx,%eax
801020da:	83 e0 03             	and    $0x3,%eax
801020dd:	8b 04 85 60 6a 10 80 	mov    -0x7fef95a0(,%eax,4),%eax
801020e4:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
  if(shift & CAPSLOCK){
801020e8:	f6 c2 08             	test   $0x8,%dl
801020eb:	74 56                	je     80102143 <kbdgetc+0xc6>
    if('a' <= c && c <= 'z')
801020ed:	8d 50 9f             	lea    -0x61(%eax),%edx
801020f0:	83 fa 19             	cmp    $0x19,%edx
801020f3:	77 3d                	ja     80102132 <kbdgetc+0xb5>
      c += 'A' - 'a';
801020f5:	83 e8 20             	sub    $0x20,%eax
801020f8:	c3                   	ret    
    shift |= E0ESC;
801020f9:	83 0d 7c 16 11 80 40 	orl    $0x40,0x8011167c
    return 0;
80102100:	b8 00 00 00 00       	mov    $0x0,%eax
80102105:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
80102106:	8b 15 7c 16 11 80    	mov    0x8011167c,%edx
8010210c:	f6 c2 40             	test   $0x40,%dl
8010210f:	75 05                	jne    80102116 <kbdgetc+0x99>
80102111:	89 c1                	mov    %eax,%ecx
80102113:	83 e1 7f             	and    $0x7f,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
80102116:	8a 81 80 6b 10 80    	mov    -0x7fef9480(%ecx),%al
8010211c:	83 c8 40             	or     $0x40,%eax
8010211f:	0f b6 c0             	movzbl %al,%eax
80102122:	f7 d0                	not    %eax
80102124:	21 c2                	and    %eax,%edx
80102126:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
    return 0;
8010212c:	b8 00 00 00 00       	mov    $0x0,%eax
80102131:	c3                   	ret    
    else if('A' <= c && c <= 'Z')
80102132:	8d 50 bf             	lea    -0x41(%eax),%edx
80102135:	83 fa 19             	cmp    $0x19,%edx
80102138:	77 09                	ja     80102143 <kbdgetc+0xc6>
      c += 'a' - 'A';
8010213a:	83 c0 20             	add    $0x20,%eax
  }
  return c;
8010213d:	c3                   	ret    
    return -1;
8010213e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102143:	c3                   	ret    

80102144 <kbdintr>:

void
kbdintr(void)
{
80102144:	55                   	push   %ebp
80102145:	89 e5                	mov    %esp,%ebp
80102147:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
8010214a:	68 7d 20 10 80       	push   $0x8010207d
8010214f:	e8 ab e5 ff ff       	call   801006ff <consoleintr>
}
80102154:	83 c4 10             	add    $0x10,%esp
80102157:	c9                   	leave  
80102158:	c3                   	ret    

80102159 <lapicw>:

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102159:	8b 0d 80 16 11 80    	mov    0x80111680,%ecx
8010215f:	8d 04 81             	lea    (%ecx,%eax,4),%eax
80102162:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102164:	a1 80 16 11 80       	mov    0x80111680,%eax
80102169:	8b 40 20             	mov    0x20(%eax),%eax
}
8010216c:	c3                   	ret    

8010216d <cmos_read>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010216d:	ba 70 00 00 00       	mov    $0x70,%edx
80102172:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102173:	ba 71 00 00 00       	mov    $0x71,%edx
80102178:	ec                   	in     (%dx),%al
cmos_read(uint reg)
{
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
80102179:	0f b6 c0             	movzbl %al,%eax
}
8010217c:	c3                   	ret    

8010217d <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
8010217d:	55                   	push   %ebp
8010217e:	89 e5                	mov    %esp,%ebp
80102180:	53                   	push   %ebx
80102181:	83 ec 04             	sub    $0x4,%esp
80102184:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
80102186:	b8 00 00 00 00       	mov    $0x0,%eax
8010218b:	e8 dd ff ff ff       	call   8010216d <cmos_read>
80102190:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
80102192:	b8 02 00 00 00       	mov    $0x2,%eax
80102197:	e8 d1 ff ff ff       	call   8010216d <cmos_read>
8010219c:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
8010219f:	b8 04 00 00 00       	mov    $0x4,%eax
801021a4:	e8 c4 ff ff ff       	call   8010216d <cmos_read>
801021a9:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
801021ac:	b8 07 00 00 00       	mov    $0x7,%eax
801021b1:	e8 b7 ff ff ff       	call   8010216d <cmos_read>
801021b6:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
801021b9:	b8 08 00 00 00       	mov    $0x8,%eax
801021be:	e8 aa ff ff ff       	call   8010216d <cmos_read>
801021c3:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
801021c6:	b8 09 00 00 00       	mov    $0x9,%eax
801021cb:	e8 9d ff ff ff       	call   8010216d <cmos_read>
801021d0:	89 43 14             	mov    %eax,0x14(%ebx)
}
801021d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801021d6:	c9                   	leave  
801021d7:	c3                   	ret    

801021d8 <lapicinit>:
  if(!lapic)
801021d8:	83 3d 80 16 11 80 00 	cmpl   $0x0,0x80111680
801021df:	0f 84 fe 00 00 00    	je     801022e3 <lapicinit+0x10b>
{
801021e5:	55                   	push   %ebp
801021e6:	89 e5                	mov    %esp,%ebp
801021e8:	83 ec 08             	sub    $0x8,%esp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801021eb:	ba 3f 01 00 00       	mov    $0x13f,%edx
801021f0:	b8 3c 00 00 00       	mov    $0x3c,%eax
801021f5:	e8 5f ff ff ff       	call   80102159 <lapicw>
  lapicw(TDCR, X1);
801021fa:	ba 0b 00 00 00       	mov    $0xb,%edx
801021ff:	b8 f8 00 00 00       	mov    $0xf8,%eax
80102204:	e8 50 ff ff ff       	call   80102159 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102209:	ba 20 00 02 00       	mov    $0x20020,%edx
8010220e:	b8 c8 00 00 00       	mov    $0xc8,%eax
80102213:	e8 41 ff ff ff       	call   80102159 <lapicw>
  lapicw(TICR, 10000000);
80102218:	ba 80 96 98 00       	mov    $0x989680,%edx
8010221d:	b8 e0 00 00 00       	mov    $0xe0,%eax
80102222:	e8 32 ff ff ff       	call   80102159 <lapicw>
  lapicw(LINT0, MASKED);
80102227:	ba 00 00 01 00       	mov    $0x10000,%edx
8010222c:	b8 d4 00 00 00       	mov    $0xd4,%eax
80102231:	e8 23 ff ff ff       	call   80102159 <lapicw>
  lapicw(LINT1, MASKED);
80102236:	ba 00 00 01 00       	mov    $0x10000,%edx
8010223b:	b8 d8 00 00 00       	mov    $0xd8,%eax
80102240:	e8 14 ff ff ff       	call   80102159 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102245:	a1 80 16 11 80       	mov    0x80111680,%eax
8010224a:	8b 40 30             	mov    0x30(%eax),%eax
8010224d:	c1 e8 10             	shr    $0x10,%eax
80102250:	a8 fc                	test   $0xfc,%al
80102252:	75 7b                	jne    801022cf <lapicinit+0xf7>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102254:	ba 33 00 00 00       	mov    $0x33,%edx
80102259:	b8 dc 00 00 00       	mov    $0xdc,%eax
8010225e:	e8 f6 fe ff ff       	call   80102159 <lapicw>
  lapicw(ESR, 0);
80102263:	ba 00 00 00 00       	mov    $0x0,%edx
80102268:	b8 a0 00 00 00       	mov    $0xa0,%eax
8010226d:	e8 e7 fe ff ff       	call   80102159 <lapicw>
  lapicw(ESR, 0);
80102272:	ba 00 00 00 00       	mov    $0x0,%edx
80102277:	b8 a0 00 00 00       	mov    $0xa0,%eax
8010227c:	e8 d8 fe ff ff       	call   80102159 <lapicw>
  lapicw(EOI, 0);
80102281:	ba 00 00 00 00       	mov    $0x0,%edx
80102286:	b8 2c 00 00 00       	mov    $0x2c,%eax
8010228b:	e8 c9 fe ff ff       	call   80102159 <lapicw>
  lapicw(ICRHI, 0);
80102290:	ba 00 00 00 00       	mov    $0x0,%edx
80102295:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010229a:	e8 ba fe ff ff       	call   80102159 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010229f:	ba 00 85 08 00       	mov    $0x88500,%edx
801022a4:	b8 c0 00 00 00       	mov    $0xc0,%eax
801022a9:	e8 ab fe ff ff       	call   80102159 <lapicw>
  while(lapic[ICRLO] & DELIVS)
801022ae:	a1 80 16 11 80       	mov    0x80111680,%eax
801022b3:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
801022b9:	f6 c4 10             	test   $0x10,%ah
801022bc:	75 f0                	jne    801022ae <lapicinit+0xd6>
  lapicw(TPR, 0);
801022be:	ba 00 00 00 00       	mov    $0x0,%edx
801022c3:	b8 20 00 00 00       	mov    $0x20,%eax
801022c8:	e8 8c fe ff ff       	call   80102159 <lapicw>
}
801022cd:	c9                   	leave  
801022ce:	c3                   	ret    
    lapicw(PCINT, MASKED);
801022cf:	ba 00 00 01 00       	mov    $0x10000,%edx
801022d4:	b8 d0 00 00 00       	mov    $0xd0,%eax
801022d9:	e8 7b fe ff ff       	call   80102159 <lapicw>
801022de:	e9 71 ff ff ff       	jmp    80102254 <lapicinit+0x7c>
801022e3:	c3                   	ret    

801022e4 <lapicid>:
  if (!lapic)
801022e4:	a1 80 16 11 80       	mov    0x80111680,%eax
801022e9:	85 c0                	test   %eax,%eax
801022eb:	74 07                	je     801022f4 <lapicid+0x10>
  return lapic[ID] >> 24;
801022ed:	8b 40 20             	mov    0x20(%eax),%eax
801022f0:	c1 e8 18             	shr    $0x18,%eax
801022f3:	c3                   	ret    
    return 0;
801022f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022f9:	c3                   	ret    

801022fa <lapiceoi>:
  if(lapic)
801022fa:	83 3d 80 16 11 80 00 	cmpl   $0x0,0x80111680
80102301:	74 17                	je     8010231a <lapiceoi+0x20>
{
80102303:	55                   	push   %ebp
80102304:	89 e5                	mov    %esp,%ebp
80102306:	83 ec 08             	sub    $0x8,%esp
    lapicw(EOI, 0);
80102309:	ba 00 00 00 00       	mov    $0x0,%edx
8010230e:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102313:	e8 41 fe ff ff       	call   80102159 <lapicw>
}
80102318:	c9                   	leave  
80102319:	c3                   	ret    
8010231a:	c3                   	ret    

8010231b <microdelay>:
}
8010231b:	c3                   	ret    

8010231c <lapicstartap>:
{
8010231c:	55                   	push   %ebp
8010231d:	89 e5                	mov    %esp,%ebp
8010231f:	57                   	push   %edi
80102320:	56                   	push   %esi
80102321:	53                   	push   %ebx
80102322:	83 ec 0c             	sub    $0xc,%esp
80102325:	8b 75 08             	mov    0x8(%ebp),%esi
80102328:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010232b:	b0 0f                	mov    $0xf,%al
8010232d:	ba 70 00 00 00       	mov    $0x70,%edx
80102332:	ee                   	out    %al,(%dx)
80102333:	b0 0a                	mov    $0xa,%al
80102335:	ba 71 00 00 00       	mov    $0x71,%edx
8010233a:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
8010233b:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
80102342:	00 00 
  wrv[1] = addr >> 4;
80102344:	89 f8                	mov    %edi,%eax
80102346:	c1 e8 04             	shr    $0x4,%eax
80102349:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
8010234f:	c1 e6 18             	shl    $0x18,%esi
80102352:	89 f2                	mov    %esi,%edx
80102354:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102359:	e8 fb fd ff ff       	call   80102159 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010235e:	ba 00 c5 00 00       	mov    $0xc500,%edx
80102363:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102368:	e8 ec fd ff ff       	call   80102159 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
8010236d:	ba 00 85 00 00       	mov    $0x8500,%edx
80102372:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102377:	e8 dd fd ff ff       	call   80102159 <lapicw>
  for(i = 0; i < 2; i++){
8010237c:	bb 00 00 00 00       	mov    $0x0,%ebx
80102381:	eb 1f                	jmp    801023a2 <lapicstartap+0x86>
    lapicw(ICRHI, apicid<<24);
80102383:	89 f2                	mov    %esi,%edx
80102385:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010238a:	e8 ca fd ff ff       	call   80102159 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
8010238f:	89 fa                	mov    %edi,%edx
80102391:	c1 ea 0c             	shr    $0xc,%edx
80102394:	80 ce 06             	or     $0x6,%dh
80102397:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010239c:	e8 b8 fd ff ff       	call   80102159 <lapicw>
  for(i = 0; i < 2; i++){
801023a1:	43                   	inc    %ebx
801023a2:	83 fb 01             	cmp    $0x1,%ebx
801023a5:	7e dc                	jle    80102383 <lapicstartap+0x67>
}
801023a7:	83 c4 0c             	add    $0xc,%esp
801023aa:	5b                   	pop    %ebx
801023ab:	5e                   	pop    %esi
801023ac:	5f                   	pop    %edi
801023ad:	5d                   	pop    %ebp
801023ae:	c3                   	ret    

801023af <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801023af:	55                   	push   %ebp
801023b0:	89 e5                	mov    %esp,%ebp
801023b2:	57                   	push   %edi
801023b3:	56                   	push   %esi
801023b4:	53                   	push   %ebx
801023b5:	83 ec 3c             	sub    $0x3c,%esp
801023b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801023bb:	b8 0b 00 00 00       	mov    $0xb,%eax
801023c0:	e8 a8 fd ff ff       	call   8010216d <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
801023c5:	83 e0 04             	and    $0x4,%eax
801023c8:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801023ca:	8d 45 d0             	lea    -0x30(%ebp),%eax
801023cd:	e8 ab fd ff ff       	call   8010217d <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801023d2:	b8 0a 00 00 00       	mov    $0xa,%eax
801023d7:	e8 91 fd ff ff       	call   8010216d <cmos_read>
801023dc:	a8 80                	test   $0x80,%al
801023de:	75 ea                	jne    801023ca <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
801023e0:	8d 75 b8             	lea    -0x48(%ebp),%esi
801023e3:	89 f0                	mov    %esi,%eax
801023e5:	e8 93 fd ff ff       	call   8010217d <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801023ea:	83 ec 04             	sub    $0x4,%esp
801023ed:	6a 18                	push   $0x18
801023ef:	56                   	push   %esi
801023f0:	8d 45 d0             	lea    -0x30(%ebp),%eax
801023f3:	50                   	push   %eax
801023f4:	e8 cd 17 00 00       	call   80103bc6 <memcmp>
801023f9:	83 c4 10             	add    $0x10,%esp
801023fc:	85 c0                	test   %eax,%eax
801023fe:	75 ca                	jne    801023ca <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
80102400:	85 ff                	test   %edi,%edi
80102402:	75 7e                	jne    80102482 <cmostime+0xd3>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102404:	8b 55 d0             	mov    -0x30(%ebp),%edx
80102407:	89 d0                	mov    %edx,%eax
80102409:	c1 e8 04             	shr    $0x4,%eax
8010240c:	8d 04 80             	lea    (%eax,%eax,4),%eax
8010240f:	01 c0                	add    %eax,%eax
80102411:	83 e2 0f             	and    $0xf,%edx
80102414:	01 d0                	add    %edx,%eax
80102416:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
80102419:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010241c:	89 d0                	mov    %edx,%eax
8010241e:	c1 e8 04             	shr    $0x4,%eax
80102421:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102424:	01 c0                	add    %eax,%eax
80102426:	83 e2 0f             	and    $0xf,%edx
80102429:	01 d0                	add    %edx,%eax
8010242b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
8010242e:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102431:	89 d0                	mov    %edx,%eax
80102433:	c1 e8 04             	shr    $0x4,%eax
80102436:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102439:	01 c0                	add    %eax,%eax
8010243b:	83 e2 0f             	and    $0xf,%edx
8010243e:	01 d0                	add    %edx,%eax
80102440:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
80102443:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102446:	89 d0                	mov    %edx,%eax
80102448:	c1 e8 04             	shr    $0x4,%eax
8010244b:	8d 04 80             	lea    (%eax,%eax,4),%eax
8010244e:	01 c0                	add    %eax,%eax
80102450:	83 e2 0f             	and    $0xf,%edx
80102453:	01 d0                	add    %edx,%eax
80102455:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
80102458:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010245b:	89 d0                	mov    %edx,%eax
8010245d:	c1 e8 04             	shr    $0x4,%eax
80102460:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102463:	01 c0                	add    %eax,%eax
80102465:	83 e2 0f             	and    $0xf,%edx
80102468:	01 d0                	add    %edx,%eax
8010246a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
8010246d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102470:	89 d0                	mov    %edx,%eax
80102472:	c1 e8 04             	shr    $0x4,%eax
80102475:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102478:	01 c0                	add    %eax,%eax
8010247a:	83 e2 0f             	and    $0xf,%edx
8010247d:	01 d0                	add    %edx,%eax
8010247f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
80102482:	8d 75 d0             	lea    -0x30(%ebp),%esi
80102485:	b9 06 00 00 00       	mov    $0x6,%ecx
8010248a:	89 df                	mov    %ebx,%edi
8010248c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
8010248e:	81 43 14 d0 07 00 00 	addl   $0x7d0,0x14(%ebx)
}
80102495:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102498:	5b                   	pop    %ebx
80102499:	5e                   	pop    %esi
8010249a:	5f                   	pop    %edi
8010249b:	5d                   	pop    %ebp
8010249c:	c3                   	ret    

8010249d <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010249d:	55                   	push   %ebp
8010249e:	89 e5                	mov    %esp,%ebp
801024a0:	53                   	push   %ebx
801024a1:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801024a4:	ff 35 d4 16 11 80    	push   0x801116d4
801024aa:	ff 35 e4 16 11 80    	push   0x801116e4
801024b0:	e8 b5 dc ff ff       	call   8010016a <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
801024b5:	8b 58 5c             	mov    0x5c(%eax),%ebx
801024b8:	89 1d e8 16 11 80    	mov    %ebx,0x801116e8
  for (i = 0; i < log.lh.n; i++) {
801024be:	83 c4 10             	add    $0x10,%esp
801024c1:	ba 00 00 00 00       	mov    $0x0,%edx
801024c6:	eb 0c                	jmp    801024d4 <read_head+0x37>
    log.lh.block[i] = lh->block[i];
801024c8:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
801024cc:	89 0c 95 ec 16 11 80 	mov    %ecx,-0x7feee914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801024d3:	42                   	inc    %edx
801024d4:	39 d3                	cmp    %edx,%ebx
801024d6:	7f f0                	jg     801024c8 <read_head+0x2b>
  }
  brelse(buf);
801024d8:	83 ec 0c             	sub    $0xc,%esp
801024db:	50                   	push   %eax
801024dc:	e8 f2 dc ff ff       	call   801001d3 <brelse>
}
801024e1:	83 c4 10             	add    $0x10,%esp
801024e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801024e7:	c9                   	leave  
801024e8:	c3                   	ret    

801024e9 <install_trans>:
{
801024e9:	55                   	push   %ebp
801024ea:	89 e5                	mov    %esp,%ebp
801024ec:	57                   	push   %edi
801024ed:	56                   	push   %esi
801024ee:	53                   	push   %ebx
801024ef:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801024f2:	be 00 00 00 00       	mov    $0x0,%esi
801024f7:	eb 62                	jmp    8010255b <install_trans+0x72>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801024f9:	89 f0                	mov    %esi,%eax
801024fb:	03 05 d4 16 11 80    	add    0x801116d4,%eax
80102501:	40                   	inc    %eax
80102502:	83 ec 08             	sub    $0x8,%esp
80102505:	50                   	push   %eax
80102506:	ff 35 e4 16 11 80    	push   0x801116e4
8010250c:	e8 59 dc ff ff       	call   8010016a <bread>
80102511:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102513:	83 c4 08             	add    $0x8,%esp
80102516:	ff 34 b5 ec 16 11 80 	push   -0x7feee914(,%esi,4)
8010251d:	ff 35 e4 16 11 80    	push   0x801116e4
80102523:	e8 42 dc ff ff       	call   8010016a <bread>
80102528:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010252a:	8d 57 5c             	lea    0x5c(%edi),%edx
8010252d:	8d 40 5c             	lea    0x5c(%eax),%eax
80102530:	83 c4 0c             	add    $0xc,%esp
80102533:	68 00 02 00 00       	push   $0x200
80102538:	52                   	push   %edx
80102539:	50                   	push   %eax
8010253a:	e8 b6 16 00 00       	call   80103bf5 <memmove>
    bwrite(dbuf);  // write dst to disk
8010253f:	89 1c 24             	mov    %ebx,(%esp)
80102542:	e8 51 dc ff ff       	call   80100198 <bwrite>
    brelse(lbuf);
80102547:	89 3c 24             	mov    %edi,(%esp)
8010254a:	e8 84 dc ff ff       	call   801001d3 <brelse>
    brelse(dbuf);
8010254f:	89 1c 24             	mov    %ebx,(%esp)
80102552:	e8 7c dc ff ff       	call   801001d3 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102557:	46                   	inc    %esi
80102558:	83 c4 10             	add    $0x10,%esp
8010255b:	39 35 e8 16 11 80    	cmp    %esi,0x801116e8
80102561:	7f 96                	jg     801024f9 <install_trans+0x10>
}
80102563:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102566:	5b                   	pop    %ebx
80102567:	5e                   	pop    %esi
80102568:	5f                   	pop    %edi
80102569:	5d                   	pop    %ebp
8010256a:	c3                   	ret    

8010256b <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010256b:	55                   	push   %ebp
8010256c:	89 e5                	mov    %esp,%ebp
8010256e:	53                   	push   %ebx
8010256f:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102572:	ff 35 d4 16 11 80    	push   0x801116d4
80102578:	ff 35 e4 16 11 80    	push   0x801116e4
8010257e:	e8 e7 db ff ff       	call   8010016a <bread>
80102583:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102585:	8b 0d e8 16 11 80    	mov    0x801116e8,%ecx
8010258b:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010258e:	83 c4 10             	add    $0x10,%esp
80102591:	b8 00 00 00 00       	mov    $0x0,%eax
80102596:	eb 0c                	jmp    801025a4 <write_head+0x39>
    hb->block[i] = log.lh.block[i];
80102598:	8b 14 85 ec 16 11 80 	mov    -0x7feee914(,%eax,4),%edx
8010259f:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
801025a3:	40                   	inc    %eax
801025a4:	39 c1                	cmp    %eax,%ecx
801025a6:	7f f0                	jg     80102598 <write_head+0x2d>
  }
  bwrite(buf);
801025a8:	83 ec 0c             	sub    $0xc,%esp
801025ab:	53                   	push   %ebx
801025ac:	e8 e7 db ff ff       	call   80100198 <bwrite>
  brelse(buf);
801025b1:	89 1c 24             	mov    %ebx,(%esp)
801025b4:	e8 1a dc ff ff       	call   801001d3 <brelse>
}
801025b9:	83 c4 10             	add    $0x10,%esp
801025bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801025bf:	c9                   	leave  
801025c0:	c3                   	ret    

801025c1 <recover_from_log>:

static void
recover_from_log(void)
{
801025c1:	55                   	push   %ebp
801025c2:	89 e5                	mov    %esp,%ebp
801025c4:	83 ec 08             	sub    $0x8,%esp
  read_head();
801025c7:	e8 d1 fe ff ff       	call   8010249d <read_head>
  install_trans(); // if committed, copy from log to disk
801025cc:	e8 18 ff ff ff       	call   801024e9 <install_trans>
  log.lh.n = 0;
801025d1:	c7 05 e8 16 11 80 00 	movl   $0x0,0x801116e8
801025d8:	00 00 00 
  write_head(); // clear the log
801025db:	e8 8b ff ff ff       	call   8010256b <write_head>
}
801025e0:	c9                   	leave  
801025e1:	c3                   	ret    

801025e2 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801025e2:	55                   	push   %ebp
801025e3:	89 e5                	mov    %esp,%ebp
801025e5:	57                   	push   %edi
801025e6:	56                   	push   %esi
801025e7:	53                   	push   %ebx
801025e8:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801025eb:	be 00 00 00 00       	mov    $0x0,%esi
801025f0:	eb 62                	jmp    80102654 <write_log+0x72>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801025f2:	89 f0                	mov    %esi,%eax
801025f4:	03 05 d4 16 11 80    	add    0x801116d4,%eax
801025fa:	40                   	inc    %eax
801025fb:	83 ec 08             	sub    $0x8,%esp
801025fe:	50                   	push   %eax
801025ff:	ff 35 e4 16 11 80    	push   0x801116e4
80102605:	e8 60 db ff ff       	call   8010016a <bread>
8010260a:	89 c3                	mov    %eax,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010260c:	83 c4 08             	add    $0x8,%esp
8010260f:	ff 34 b5 ec 16 11 80 	push   -0x7feee914(,%esi,4)
80102616:	ff 35 e4 16 11 80    	push   0x801116e4
8010261c:	e8 49 db ff ff       	call   8010016a <bread>
80102621:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102623:	8d 50 5c             	lea    0x5c(%eax),%edx
80102626:	8d 43 5c             	lea    0x5c(%ebx),%eax
80102629:	83 c4 0c             	add    $0xc,%esp
8010262c:	68 00 02 00 00       	push   $0x200
80102631:	52                   	push   %edx
80102632:	50                   	push   %eax
80102633:	e8 bd 15 00 00       	call   80103bf5 <memmove>
    bwrite(to);  // write the log
80102638:	89 1c 24             	mov    %ebx,(%esp)
8010263b:	e8 58 db ff ff       	call   80100198 <bwrite>
    brelse(from);
80102640:	89 3c 24             	mov    %edi,(%esp)
80102643:	e8 8b db ff ff       	call   801001d3 <brelse>
    brelse(to);
80102648:	89 1c 24             	mov    %ebx,(%esp)
8010264b:	e8 83 db ff ff       	call   801001d3 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102650:	46                   	inc    %esi
80102651:	83 c4 10             	add    $0x10,%esp
80102654:	39 35 e8 16 11 80    	cmp    %esi,0x801116e8
8010265a:	7f 96                	jg     801025f2 <write_log+0x10>
  }
}
8010265c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010265f:	5b                   	pop    %ebx
80102660:	5e                   	pop    %esi
80102661:	5f                   	pop    %edi
80102662:	5d                   	pop    %ebp
80102663:	c3                   	ret    

80102664 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
80102664:	83 3d e8 16 11 80 00 	cmpl   $0x0,0x801116e8
8010266b:	7f 01                	jg     8010266e <commit+0xa>
8010266d:	c3                   	ret    
{
8010266e:	55                   	push   %ebp
8010266f:	89 e5                	mov    %esp,%ebp
80102671:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
80102674:	e8 69 ff ff ff       	call   801025e2 <write_log>
    write_head();    // Write header to disk -- the real commit
80102679:	e8 ed fe ff ff       	call   8010256b <write_head>
    install_trans(); // Now install writes to home locations
8010267e:	e8 66 fe ff ff       	call   801024e9 <install_trans>
    log.lh.n = 0;
80102683:	c7 05 e8 16 11 80 00 	movl   $0x0,0x801116e8
8010268a:	00 00 00 
    write_head();    // Erase the transaction from the log
8010268d:	e8 d9 fe ff ff       	call   8010256b <write_head>
  }
}
80102692:	c9                   	leave  
80102693:	c3                   	ret    

80102694 <initlog>:
{
80102694:	55                   	push   %ebp
80102695:	89 e5                	mov    %esp,%ebp
80102697:	53                   	push   %ebx
80102698:	83 ec 2c             	sub    $0x2c,%esp
8010269b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
8010269e:	68 80 6c 10 80       	push   $0x80106c80
801026a3:	68 a0 16 11 80       	push   $0x801116a0
801026a8:	e8 ef 12 00 00       	call   8010399c <initlock>
  readsb(dev, &sb);
801026ad:	83 c4 08             	add    $0x8,%esp
801026b0:	8d 45 dc             	lea    -0x24(%ebp),%eax
801026b3:	50                   	push   %eax
801026b4:	53                   	push   %ebx
801026b5:	e8 0e eb ff ff       	call   801011c8 <readsb>
  log.start = sb.logstart;
801026ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801026bd:	a3 d4 16 11 80       	mov    %eax,0x801116d4
  log.size = sb.nlog;
801026c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801026c5:	a3 d8 16 11 80       	mov    %eax,0x801116d8
  log.dev = dev;
801026ca:	89 1d e4 16 11 80    	mov    %ebx,0x801116e4
  recover_from_log();
801026d0:	e8 ec fe ff ff       	call   801025c1 <recover_from_log>
}
801026d5:	83 c4 10             	add    $0x10,%esp
801026d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801026db:	c9                   	leave  
801026dc:	c3                   	ret    

801026dd <begin_op>:
{
801026dd:	55                   	push   %ebp
801026de:	89 e5                	mov    %esp,%ebp
801026e0:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
801026e3:	68 a0 16 11 80       	push   $0x801116a0
801026e8:	e8 e6 13 00 00       	call   80103ad3 <acquire>
801026ed:	83 c4 10             	add    $0x10,%esp
801026f0:	eb 15                	jmp    80102707 <begin_op+0x2a>
      sleep(&log, &log.lock);
801026f2:	83 ec 08             	sub    $0x8,%esp
801026f5:	68 a0 16 11 80       	push   $0x801116a0
801026fa:	68 a0 16 11 80       	push   $0x801116a0
801026ff:	e8 cd 0e 00 00       	call   801035d1 <sleep>
80102704:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102707:	83 3d e0 16 11 80 00 	cmpl   $0x0,0x801116e0
8010270e:	75 e2                	jne    801026f2 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102710:	a1 dc 16 11 80       	mov    0x801116dc,%eax
80102715:	8d 48 01             	lea    0x1(%eax),%ecx
80102718:	8d 54 80 05          	lea    0x5(%eax,%eax,4),%edx
8010271c:	8d 04 12             	lea    (%edx,%edx,1),%eax
8010271f:	03 05 e8 16 11 80    	add    0x801116e8,%eax
80102725:	83 f8 1e             	cmp    $0x1e,%eax
80102728:	7e 17                	jle    80102741 <begin_op+0x64>
      sleep(&log, &log.lock);
8010272a:	83 ec 08             	sub    $0x8,%esp
8010272d:	68 a0 16 11 80       	push   $0x801116a0
80102732:	68 a0 16 11 80       	push   $0x801116a0
80102737:	e8 95 0e 00 00       	call   801035d1 <sleep>
8010273c:	83 c4 10             	add    $0x10,%esp
8010273f:	eb c6                	jmp    80102707 <begin_op+0x2a>
      log.outstanding += 1;
80102741:	89 0d dc 16 11 80    	mov    %ecx,0x801116dc
      release(&log.lock);
80102747:	83 ec 0c             	sub    $0xc,%esp
8010274a:	68 a0 16 11 80       	push   $0x801116a0
8010274f:	e8 e4 13 00 00       	call   80103b38 <release>
}
80102754:	83 c4 10             	add    $0x10,%esp
80102757:	c9                   	leave  
80102758:	c3                   	ret    

80102759 <end_op>:
{
80102759:	55                   	push   %ebp
8010275a:	89 e5                	mov    %esp,%ebp
8010275c:	53                   	push   %ebx
8010275d:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102760:	68 a0 16 11 80       	push   $0x801116a0
80102765:	e8 69 13 00 00       	call   80103ad3 <acquire>
  log.outstanding -= 1;
8010276a:	a1 dc 16 11 80       	mov    0x801116dc,%eax
8010276f:	48                   	dec    %eax
80102770:	a3 dc 16 11 80       	mov    %eax,0x801116dc
  if(log.committing)
80102775:	8b 1d e0 16 11 80    	mov    0x801116e0,%ebx
8010277b:	83 c4 10             	add    $0x10,%esp
8010277e:	85 db                	test   %ebx,%ebx
80102780:	75 2c                	jne    801027ae <end_op+0x55>
  if(log.outstanding == 0){
80102782:	85 c0                	test   %eax,%eax
80102784:	75 35                	jne    801027bb <end_op+0x62>
    log.committing = 1;
80102786:	c7 05 e0 16 11 80 01 	movl   $0x1,0x801116e0
8010278d:	00 00 00 
    do_commit = 1;
80102790:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102795:	83 ec 0c             	sub    $0xc,%esp
80102798:	68 a0 16 11 80       	push   $0x801116a0
8010279d:	e8 96 13 00 00       	call   80103b38 <release>
  if(do_commit){
801027a2:	83 c4 10             	add    $0x10,%esp
801027a5:	85 db                	test   %ebx,%ebx
801027a7:	75 24                	jne    801027cd <end_op+0x74>
}
801027a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027ac:	c9                   	leave  
801027ad:	c3                   	ret    
    panic("log.committing");
801027ae:	83 ec 0c             	sub    $0xc,%esp
801027b1:	68 84 6c 10 80       	push   $0x80106c84
801027b6:	e8 86 db ff ff       	call   80100341 <panic>
    wakeup(&log);
801027bb:	83 ec 0c             	sub    $0xc,%esp
801027be:	68 a0 16 11 80       	push   $0x801116a0
801027c3:	e8 7c 0f 00 00       	call   80103744 <wakeup>
801027c8:	83 c4 10             	add    $0x10,%esp
801027cb:	eb c8                	jmp    80102795 <end_op+0x3c>
    commit();
801027cd:	e8 92 fe ff ff       	call   80102664 <commit>
    acquire(&log.lock);
801027d2:	83 ec 0c             	sub    $0xc,%esp
801027d5:	68 a0 16 11 80       	push   $0x801116a0
801027da:	e8 f4 12 00 00       	call   80103ad3 <acquire>
    log.committing = 0;
801027df:	c7 05 e0 16 11 80 00 	movl   $0x0,0x801116e0
801027e6:	00 00 00 
    wakeup(&log);
801027e9:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
801027f0:	e8 4f 0f 00 00       	call   80103744 <wakeup>
    release(&log.lock);
801027f5:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
801027fc:	e8 37 13 00 00       	call   80103b38 <release>
80102801:	83 c4 10             	add    $0x10,%esp
}
80102804:	eb a3                	jmp    801027a9 <end_op+0x50>

80102806 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102806:	55                   	push   %ebp
80102807:	89 e5                	mov    %esp,%ebp
80102809:	53                   	push   %ebx
8010280a:	83 ec 04             	sub    $0x4,%esp
8010280d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102810:	8b 15 e8 16 11 80    	mov    0x801116e8,%edx
80102816:	83 fa 1d             	cmp    $0x1d,%edx
80102819:	7f 2a                	jg     80102845 <log_write+0x3f>
8010281b:	a1 d8 16 11 80       	mov    0x801116d8,%eax
80102820:	48                   	dec    %eax
80102821:	39 c2                	cmp    %eax,%edx
80102823:	7d 20                	jge    80102845 <log_write+0x3f>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102825:	83 3d dc 16 11 80 00 	cmpl   $0x0,0x801116dc
8010282c:	7e 24                	jle    80102852 <log_write+0x4c>
    panic("log_write outside of trans");

  acquire(&log.lock);
8010282e:	83 ec 0c             	sub    $0xc,%esp
80102831:	68 a0 16 11 80       	push   $0x801116a0
80102836:	e8 98 12 00 00       	call   80103ad3 <acquire>
  for (i = 0; i < log.lh.n; i++) {
8010283b:	83 c4 10             	add    $0x10,%esp
8010283e:	b8 00 00 00 00       	mov    $0x0,%eax
80102843:	eb 1b                	jmp    80102860 <log_write+0x5a>
    panic("too big a transaction");
80102845:	83 ec 0c             	sub    $0xc,%esp
80102848:	68 93 6c 10 80       	push   $0x80106c93
8010284d:	e8 ef da ff ff       	call   80100341 <panic>
    panic("log_write outside of trans");
80102852:	83 ec 0c             	sub    $0xc,%esp
80102855:	68 a9 6c 10 80       	push   $0x80106ca9
8010285a:	e8 e2 da ff ff       	call   80100341 <panic>
  for (i = 0; i < log.lh.n; i++) {
8010285f:	40                   	inc    %eax
80102860:	8b 15 e8 16 11 80    	mov    0x801116e8,%edx
80102866:	39 c2                	cmp    %eax,%edx
80102868:	7e 0c                	jle    80102876 <log_write+0x70>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010286a:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010286d:	39 0c 85 ec 16 11 80 	cmp    %ecx,-0x7feee914(,%eax,4)
80102874:	75 e9                	jne    8010285f <log_write+0x59>
      break;
  }
  log.lh.block[i] = b->blockno;
80102876:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102879:	89 0c 85 ec 16 11 80 	mov    %ecx,-0x7feee914(,%eax,4)
  if (i == log.lh.n)
80102880:	39 c2                	cmp    %eax,%edx
80102882:	74 18                	je     8010289c <log_write+0x96>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102884:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102887:	83 ec 0c             	sub    $0xc,%esp
8010288a:	68 a0 16 11 80       	push   $0x801116a0
8010288f:	e8 a4 12 00 00       	call   80103b38 <release>
}
80102894:	83 c4 10             	add    $0x10,%esp
80102897:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010289a:	c9                   	leave  
8010289b:	c3                   	ret    
    log.lh.n++;
8010289c:	42                   	inc    %edx
8010289d:	89 15 e8 16 11 80    	mov    %edx,0x801116e8
801028a3:	eb df                	jmp    80102884 <log_write+0x7e>

801028a5 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801028a5:	55                   	push   %ebp
801028a6:	89 e5                	mov    %esp,%ebp
801028a8:	53                   	push   %ebx
801028a9:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801028ac:	68 8e 00 00 00       	push   $0x8e
801028b1:	68 8c a4 10 80       	push   $0x8010a48c
801028b6:	68 00 70 00 80       	push   $0x80007000
801028bb:	e8 35 13 00 00       	call   80103bf5 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801028c0:	83 c4 10             	add    $0x10,%esp
801028c3:	bb a0 17 11 80       	mov    $0x801117a0,%ebx
801028c8:	eb 06                	jmp    801028d0 <startothers+0x2b>
801028ca:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801028d0:	8b 15 84 17 11 80    	mov    0x80111784,%edx
801028d6:	8d 04 92             	lea    (%edx,%edx,4),%eax
801028d9:	01 c0                	add    %eax,%eax
801028db:	01 d0                	add    %edx,%eax
801028dd:	c1 e0 04             	shl    $0x4,%eax
801028e0:	05 a0 17 11 80       	add    $0x801117a0,%eax
801028e5:	39 d8                	cmp    %ebx,%eax
801028e7:	76 4c                	jbe    80102935 <startothers+0x90>
    if(c == mycpu())  // We've started already.
801028e9:	e8 97 07 00 00       	call   80103085 <mycpu>
801028ee:	39 c3                	cmp    %eax,%ebx
801028f0:	74 d8                	je     801028ca <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801028f2:	e8 31 f7 ff ff       	call   80102028 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
801028f7:	05 00 10 00 00       	add    $0x1000,%eax
801028fc:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102901:	c7 05 f8 6f 00 80 79 	movl   $0x80102979,0x80006ff8
80102908:	29 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
8010290b:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102912:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102915:	83 ec 08             	sub    $0x8,%esp
80102918:	68 00 70 00 00       	push   $0x7000
8010291d:	0f b6 03             	movzbl (%ebx),%eax
80102920:	50                   	push   %eax
80102921:	e8 f6 f9 ff ff       	call   8010231c <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102926:	83 c4 10             	add    $0x10,%esp
80102929:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
8010292f:	85 c0                	test   %eax,%eax
80102931:	74 f6                	je     80102929 <startothers+0x84>
80102933:	eb 95                	jmp    801028ca <startothers+0x25>
      ;
  }
}
80102935:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102938:	c9                   	leave  
80102939:	c3                   	ret    

8010293a <mpmain>:
{
8010293a:	55                   	push   %ebp
8010293b:	89 e5                	mov    %esp,%ebp
8010293d:	53                   	push   %ebx
8010293e:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102941:	e8 a3 07 00 00       	call   801030e9 <cpuid>
80102946:	89 c3                	mov    %eax,%ebx
80102948:	e8 9c 07 00 00       	call   801030e9 <cpuid>
8010294d:	83 ec 04             	sub    $0x4,%esp
80102950:	53                   	push   %ebx
80102951:	50                   	push   %eax
80102952:	68 c4 6c 10 80       	push   $0x80106cc4
80102957:	e8 7e dc ff ff       	call   801005da <cprintf>
  idtinit();       // load idt register
8010295c:	e8 a2 24 00 00       	call   80104e03 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102961:	e8 1f 07 00 00       	call   80103085 <mycpu>
80102966:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102968:	b8 01 00 00 00       	mov    $0x1,%eax
8010296d:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102974:	e8 1f 0a 00 00       	call   80103398 <scheduler>

80102979 <mpenter>:
{
80102979:	55                   	push   %ebp
8010297a:	89 e5                	mov    %esp,%ebp
8010297c:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
8010297f:	e8 96 37 00 00       	call   8010611a <switchkvm>
  seginit();
80102984:	e8 4b 34 00 00       	call   80105dd4 <seginit>
  lapicinit();
80102989:	e8 4a f8 ff ff       	call   801021d8 <lapicinit>
  mpmain();
8010298e:	e8 a7 ff ff ff       	call   8010293a <mpmain>

80102993 <main>:
{
80102993:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102997:	83 e4 f0             	and    $0xfffffff0,%esp
8010299a:	ff 71 fc             	push   -0x4(%ecx)
8010299d:	55                   	push   %ebp
8010299e:	89 e5                	mov    %esp,%ebp
801029a0:	51                   	push   %ecx
801029a1:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801029a4:	68 00 00 40 80       	push   $0x80400000
801029a9:	68 d0 55 11 80       	push   $0x801155d0
801029ae:	e8 23 f6 ff ff       	call   80101fd6 <kinit1>
  kvmalloc();      // kernel page table
801029b3:	e8 31 3c 00 00       	call   801065e9 <kvmalloc>
  mpinit();        // detect other processors
801029b8:	e8 b8 01 00 00       	call   80102b75 <mpinit>
  lapicinit();     // interrupt controller
801029bd:	e8 16 f8 ff ff       	call   801021d8 <lapicinit>
  seginit();       // segment descriptors
801029c2:	e8 0d 34 00 00       	call   80105dd4 <seginit>
  picinit();       // disable pic
801029c7:	e8 79 02 00 00       	call   80102c45 <picinit>
  ioapicinit();    // another interrupt controller
801029cc:	e8 93 f4 ff ff       	call   80101e64 <ioapicinit>
  consoleinit();   // console hardware
801029d1:	e8 76 de ff ff       	call   8010084c <consoleinit>
  uartinit();      // serial port
801029d6:	e8 71 28 00 00       	call   8010524c <uartinit>
  pinit();         // process table
801029db:	e8 8b 06 00 00       	call   8010306b <pinit>
  tvinit();        // trap vectors
801029e0:	e8 21 23 00 00       	call   80104d06 <tvinit>
  binit();         // buffer cache
801029e5:	e8 08 d7 ff ff       	call   801000f2 <binit>
  fileinit();      // file table
801029ea:	e8 de e1 ff ff       	call   80100bcd <fileinit>
  ideinit();       // disk 
801029ef:	e8 86 f2 ff ff       	call   80101c7a <ideinit>
  startothers();   // start other processors
801029f4:	e8 ac fe ff ff       	call   801028a5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801029f9:	83 c4 08             	add    $0x8,%esp
801029fc:	68 00 00 00 8e       	push   $0x8e000000
80102a01:	68 00 00 40 80       	push   $0x80400000
80102a06:	e8 fd f5 ff ff       	call   80102008 <kinit2>
  userinit();      // first user process
80102a0b:	e8 2d 07 00 00       	call   8010313d <userinit>
  mpmain();        // finish this processor's setup
80102a10:	e8 25 ff ff ff       	call   8010293a <mpmain>

80102a15 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102a15:	55                   	push   %ebp
80102a16:	89 e5                	mov    %esp,%ebp
80102a18:	56                   	push   %esi
80102a19:	53                   	push   %ebx
80102a1a:	89 c6                	mov    %eax,%esi
  int i, sum;

  sum = 0;
80102a1c:	b8 00 00 00 00       	mov    $0x0,%eax
  for(i=0; i<len; i++)
80102a21:	b9 00 00 00 00       	mov    $0x0,%ecx
80102a26:	eb 07                	jmp    80102a2f <sum+0x1a>
    sum += addr[i];
80102a28:	0f b6 1c 0e          	movzbl (%esi,%ecx,1),%ebx
80102a2c:	01 d8                	add    %ebx,%eax
  for(i=0; i<len; i++)
80102a2e:	41                   	inc    %ecx
80102a2f:	39 d1                	cmp    %edx,%ecx
80102a31:	7c f5                	jl     80102a28 <sum+0x13>
  return sum;
}
80102a33:	5b                   	pop    %ebx
80102a34:	5e                   	pop    %esi
80102a35:	5d                   	pop    %ebp
80102a36:	c3                   	ret    

80102a37 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102a37:	55                   	push   %ebp
80102a38:	89 e5                	mov    %esp,%ebp
80102a3a:	56                   	push   %esi
80102a3b:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102a3c:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102a42:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102a44:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102a46:	eb 03                	jmp    80102a4b <mpsearch1+0x14>
80102a48:	83 c3 10             	add    $0x10,%ebx
80102a4b:	39 f3                	cmp    %esi,%ebx
80102a4d:	73 29                	jae    80102a78 <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102a4f:	83 ec 04             	sub    $0x4,%esp
80102a52:	6a 04                	push   $0x4
80102a54:	68 d8 6c 10 80       	push   $0x80106cd8
80102a59:	53                   	push   %ebx
80102a5a:	e8 67 11 00 00       	call   80103bc6 <memcmp>
80102a5f:	83 c4 10             	add    $0x10,%esp
80102a62:	85 c0                	test   %eax,%eax
80102a64:	75 e2                	jne    80102a48 <mpsearch1+0x11>
80102a66:	ba 10 00 00 00       	mov    $0x10,%edx
80102a6b:	89 d8                	mov    %ebx,%eax
80102a6d:	e8 a3 ff ff ff       	call   80102a15 <sum>
80102a72:	84 c0                	test   %al,%al
80102a74:	75 d2                	jne    80102a48 <mpsearch1+0x11>
80102a76:	eb 05                	jmp    80102a7d <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102a78:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102a7d:	89 d8                	mov    %ebx,%eax
80102a7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102a82:	5b                   	pop    %ebx
80102a83:	5e                   	pop    %esi
80102a84:	5d                   	pop    %ebp
80102a85:	c3                   	ret    

80102a86 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102a86:	55                   	push   %ebp
80102a87:	89 e5                	mov    %esp,%ebp
80102a89:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102a8c:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102a93:	c1 e0 08             	shl    $0x8,%eax
80102a96:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102a9d:	09 d0                	or     %edx,%eax
80102a9f:	c1 e0 04             	shl    $0x4,%eax
80102aa2:	74 1f                	je     80102ac3 <mpsearch+0x3d>
    if((mp = mpsearch1(p, 1024)))
80102aa4:	ba 00 04 00 00       	mov    $0x400,%edx
80102aa9:	e8 89 ff ff ff       	call   80102a37 <mpsearch1>
80102aae:	85 c0                	test   %eax,%eax
80102ab0:	75 0f                	jne    80102ac1 <mpsearch+0x3b>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102ab2:	ba 00 00 01 00       	mov    $0x10000,%edx
80102ab7:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102abc:	e8 76 ff ff ff       	call   80102a37 <mpsearch1>
}
80102ac1:	c9                   	leave  
80102ac2:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102ac3:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102aca:	c1 e0 08             	shl    $0x8,%eax
80102acd:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102ad4:	09 d0                	or     %edx,%eax
80102ad6:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102ad9:	2d 00 04 00 00       	sub    $0x400,%eax
80102ade:	ba 00 04 00 00       	mov    $0x400,%edx
80102ae3:	e8 4f ff ff ff       	call   80102a37 <mpsearch1>
80102ae8:	85 c0                	test   %eax,%eax
80102aea:	75 d5                	jne    80102ac1 <mpsearch+0x3b>
80102aec:	eb c4                	jmp    80102ab2 <mpsearch+0x2c>

80102aee <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102aee:	55                   	push   %ebp
80102aef:	89 e5                	mov    %esp,%ebp
80102af1:	57                   	push   %edi
80102af2:	56                   	push   %esi
80102af3:	53                   	push   %ebx
80102af4:	83 ec 1c             	sub    $0x1c,%esp
80102af7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102afa:	e8 87 ff ff ff       	call   80102a86 <mpsearch>
80102aff:	89 c3                	mov    %eax,%ebx
80102b01:	85 c0                	test   %eax,%eax
80102b03:	74 53                	je     80102b58 <mpconfig+0x6a>
80102b05:	8b 70 04             	mov    0x4(%eax),%esi
80102b08:	85 f6                	test   %esi,%esi
80102b0a:	74 50                	je     80102b5c <mpconfig+0x6e>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102b0c:	8d be 00 00 00 80    	lea    -0x80000000(%esi),%edi
  if(memcmp(conf, "PCMP", 4) != 0)
80102b12:	83 ec 04             	sub    $0x4,%esp
80102b15:	6a 04                	push   $0x4
80102b17:	68 dd 6c 10 80       	push   $0x80106cdd
80102b1c:	57                   	push   %edi
80102b1d:	e8 a4 10 00 00       	call   80103bc6 <memcmp>
80102b22:	83 c4 10             	add    $0x10,%esp
80102b25:	85 c0                	test   %eax,%eax
80102b27:	75 37                	jne    80102b60 <mpconfig+0x72>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102b29:	8a 86 06 00 00 80    	mov    -0x7ffffffa(%esi),%al
80102b2f:	3c 01                	cmp    $0x1,%al
80102b31:	74 04                	je     80102b37 <mpconfig+0x49>
80102b33:	3c 04                	cmp    $0x4,%al
80102b35:	75 30                	jne    80102b67 <mpconfig+0x79>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102b37:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
80102b3e:	89 f8                	mov    %edi,%eax
80102b40:	e8 d0 fe ff ff       	call   80102a15 <sum>
80102b45:	84 c0                	test   %al,%al
80102b47:	75 25                	jne    80102b6e <mpconfig+0x80>
    return 0;
  *pmp = mp;
80102b49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102b4c:	89 18                	mov    %ebx,(%eax)
  return conf;
}
80102b4e:	89 f8                	mov    %edi,%eax
80102b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102b53:	5b                   	pop    %ebx
80102b54:	5e                   	pop    %esi
80102b55:	5f                   	pop    %edi
80102b56:	5d                   	pop    %ebp
80102b57:	c3                   	ret    
    return 0;
80102b58:	89 c7                	mov    %eax,%edi
80102b5a:	eb f2                	jmp    80102b4e <mpconfig+0x60>
80102b5c:	89 f7                	mov    %esi,%edi
80102b5e:	eb ee                	jmp    80102b4e <mpconfig+0x60>
    return 0;
80102b60:	bf 00 00 00 00       	mov    $0x0,%edi
80102b65:	eb e7                	jmp    80102b4e <mpconfig+0x60>
    return 0;
80102b67:	bf 00 00 00 00       	mov    $0x0,%edi
80102b6c:	eb e0                	jmp    80102b4e <mpconfig+0x60>
    return 0;
80102b6e:	bf 00 00 00 00       	mov    $0x0,%edi
80102b73:	eb d9                	jmp    80102b4e <mpconfig+0x60>

80102b75 <mpinit>:

void
mpinit(void)
{
80102b75:	55                   	push   %ebp
80102b76:	89 e5                	mov    %esp,%ebp
80102b78:	57                   	push   %edi
80102b79:	56                   	push   %esi
80102b7a:	53                   	push   %ebx
80102b7b:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102b7e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102b81:	e8 68 ff ff ff       	call   80102aee <mpconfig>
80102b86:	85 c0                	test   %eax,%eax
80102b88:	74 19                	je     80102ba3 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102b8a:	8b 50 24             	mov    0x24(%eax),%edx
80102b8d:	89 15 80 16 11 80    	mov    %edx,0x80111680
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102b93:	8d 50 2c             	lea    0x2c(%eax),%edx
80102b96:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102b9a:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102b9c:	bf 01 00 00 00       	mov    $0x1,%edi
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102ba1:	eb 20                	jmp    80102bc3 <mpinit+0x4e>
    panic("Expect to run on an SMP");
80102ba3:	83 ec 0c             	sub    $0xc,%esp
80102ba6:	68 e2 6c 10 80       	push   $0x80106ce2
80102bab:	e8 91 d7 ff ff       	call   80100341 <panic>
    switch(*p){
80102bb0:	bf 00 00 00 00       	mov    $0x0,%edi
80102bb5:	eb 0c                	jmp    80102bc3 <mpinit+0x4e>
80102bb7:	83 e8 03             	sub    $0x3,%eax
80102bba:	3c 01                	cmp    $0x1,%al
80102bbc:	76 19                	jbe    80102bd7 <mpinit+0x62>
80102bbe:	bf 00 00 00 00       	mov    $0x0,%edi
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102bc3:	39 ca                	cmp    %ecx,%edx
80102bc5:	73 4a                	jae    80102c11 <mpinit+0x9c>
    switch(*p){
80102bc7:	8a 02                	mov    (%edx),%al
80102bc9:	3c 02                	cmp    $0x2,%al
80102bcb:	74 37                	je     80102c04 <mpinit+0x8f>
80102bcd:	77 e8                	ja     80102bb7 <mpinit+0x42>
80102bcf:	84 c0                	test   %al,%al
80102bd1:	74 09                	je     80102bdc <mpinit+0x67>
80102bd3:	3c 01                	cmp    $0x1,%al
80102bd5:	75 d9                	jne    80102bb0 <mpinit+0x3b>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102bd7:	83 c2 08             	add    $0x8,%edx
      continue;
80102bda:	eb e7                	jmp    80102bc3 <mpinit+0x4e>
      if(ncpu < NCPU) {
80102bdc:	a1 84 17 11 80       	mov    0x80111784,%eax
80102be1:	83 f8 07             	cmp    $0x7,%eax
80102be4:	7f 19                	jg     80102bff <mpinit+0x8a>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102be6:	8d 34 80             	lea    (%eax,%eax,4),%esi
80102be9:	01 f6                	add    %esi,%esi
80102beb:	01 c6                	add    %eax,%esi
80102bed:	c1 e6 04             	shl    $0x4,%esi
80102bf0:	8a 5a 01             	mov    0x1(%edx),%bl
80102bf3:	88 9e a0 17 11 80    	mov    %bl,-0x7feee860(%esi)
        ncpu++;
80102bf9:	40                   	inc    %eax
80102bfa:	a3 84 17 11 80       	mov    %eax,0x80111784
      p += sizeof(struct mpproc);
80102bff:	83 c2 14             	add    $0x14,%edx
      continue;
80102c02:	eb bf                	jmp    80102bc3 <mpinit+0x4e>
      ioapicid = ioapic->apicno;
80102c04:	8a 42 01             	mov    0x1(%edx),%al
80102c07:	a2 80 17 11 80       	mov    %al,0x80111780
      p += sizeof(struct mpioapic);
80102c0c:	83 c2 08             	add    $0x8,%edx
      continue;
80102c0f:	eb b2                	jmp    80102bc3 <mpinit+0x4e>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80102c11:	85 ff                	test   %edi,%edi
80102c13:	74 23                	je     80102c38 <mpinit+0xc3>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102c15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102c18:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102c1c:	74 12                	je     80102c30 <mpinit+0xbb>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c1e:	b0 70                	mov    $0x70,%al
80102c20:	ba 22 00 00 00       	mov    $0x22,%edx
80102c25:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c26:	ba 23 00 00 00       	mov    $0x23,%edx
80102c2b:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102c2c:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c2f:	ee                   	out    %al,(%dx)
  }
}
80102c30:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c33:	5b                   	pop    %ebx
80102c34:	5e                   	pop    %esi
80102c35:	5f                   	pop    %edi
80102c36:	5d                   	pop    %ebp
80102c37:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102c38:	83 ec 0c             	sub    $0xc,%esp
80102c3b:	68 fc 6c 10 80       	push   $0x80106cfc
80102c40:	e8 fc d6 ff ff       	call   80100341 <panic>

80102c45 <picinit>:
80102c45:	b0 ff                	mov    $0xff,%al
80102c47:	ba 21 00 00 00       	mov    $0x21,%edx
80102c4c:	ee                   	out    %al,(%dx)
80102c4d:	ba a1 00 00 00       	mov    $0xa1,%edx
80102c52:	ee                   	out    %al,(%dx)
picinit(void)
{
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102c53:	c3                   	ret    

80102c54 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102c54:	55                   	push   %ebp
80102c55:	89 e5                	mov    %esp,%ebp
80102c57:	57                   	push   %edi
80102c58:	56                   	push   %esi
80102c59:	53                   	push   %ebx
80102c5a:	83 ec 0c             	sub    $0xc,%esp
80102c5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102c60:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102c63:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102c69:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102c6f:	e8 73 df ff ff       	call   80100be7 <filealloc>
80102c74:	89 03                	mov    %eax,(%ebx)
80102c76:	85 c0                	test   %eax,%eax
80102c78:	0f 84 88 00 00 00    	je     80102d06 <pipealloc+0xb2>
80102c7e:	e8 64 df ff ff       	call   80100be7 <filealloc>
80102c83:	89 06                	mov    %eax,(%esi)
80102c85:	85 c0                	test   %eax,%eax
80102c87:	74 7d                	je     80102d06 <pipealloc+0xb2>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102c89:	e8 9a f3 ff ff       	call   80102028 <kalloc>
80102c8e:	89 c7                	mov    %eax,%edi
80102c90:	85 c0                	test   %eax,%eax
80102c92:	74 72                	je     80102d06 <pipealloc+0xb2>
    goto bad;
  p->readopen = 1;
80102c94:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102c9b:	00 00 00 
  p->writeopen = 1;
80102c9e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102ca5:	00 00 00 
  p->nwrite = 0;
80102ca8:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102caf:	00 00 00 
  p->nread = 0;
80102cb2:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102cb9:	00 00 00 
  initlock(&p->lock, "pipe");
80102cbc:	83 ec 08             	sub    $0x8,%esp
80102cbf:	68 1b 6d 10 80       	push   $0x80106d1b
80102cc4:	50                   	push   %eax
80102cc5:	e8 d2 0c 00 00       	call   8010399c <initlock>
  (*f0)->type = FD_PIPE;
80102cca:	8b 03                	mov    (%ebx),%eax
80102ccc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102cd2:	8b 03                	mov    (%ebx),%eax
80102cd4:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102cd8:	8b 03                	mov    (%ebx),%eax
80102cda:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102cde:	8b 03                	mov    (%ebx),%eax
80102ce0:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102ce3:	8b 06                	mov    (%esi),%eax
80102ce5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102ceb:	8b 06                	mov    (%esi),%eax
80102ced:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102cf1:	8b 06                	mov    (%esi),%eax
80102cf3:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102cf7:	8b 06                	mov    (%esi),%eax
80102cf9:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102cfc:	83 c4 10             	add    $0x10,%esp
80102cff:	b8 00 00 00 00       	mov    $0x0,%eax
80102d04:	eb 29                	jmp    80102d2f <pipealloc+0xdb>

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102d06:	8b 03                	mov    (%ebx),%eax
80102d08:	85 c0                	test   %eax,%eax
80102d0a:	74 0c                	je     80102d18 <pipealloc+0xc4>
    fileclose(*f0);
80102d0c:	83 ec 0c             	sub    $0xc,%esp
80102d0f:	50                   	push   %eax
80102d10:	e8 76 df ff ff       	call   80100c8b <fileclose>
80102d15:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102d18:	8b 06                	mov    (%esi),%eax
80102d1a:	85 c0                	test   %eax,%eax
80102d1c:	74 19                	je     80102d37 <pipealloc+0xe3>
    fileclose(*f1);
80102d1e:	83 ec 0c             	sub    $0xc,%esp
80102d21:	50                   	push   %eax
80102d22:	e8 64 df ff ff       	call   80100c8b <fileclose>
80102d27:	83 c4 10             	add    $0x10,%esp
  return -1;
80102d2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102d2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d32:	5b                   	pop    %ebx
80102d33:	5e                   	pop    %esi
80102d34:	5f                   	pop    %edi
80102d35:	5d                   	pop    %ebp
80102d36:	c3                   	ret    
  return -1;
80102d37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d3c:	eb f1                	jmp    80102d2f <pipealloc+0xdb>

80102d3e <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102d3e:	55                   	push   %ebp
80102d3f:	89 e5                	mov    %esp,%ebp
80102d41:	53                   	push   %ebx
80102d42:	83 ec 10             	sub    $0x10,%esp
80102d45:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102d48:	53                   	push   %ebx
80102d49:	e8 85 0d 00 00       	call   80103ad3 <acquire>
  if(writable){
80102d4e:	83 c4 10             	add    $0x10,%esp
80102d51:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102d55:	74 3f                	je     80102d96 <pipeclose+0x58>
    p->writeopen = 0;
80102d57:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102d5e:	00 00 00 
    wakeup(&p->nread);
80102d61:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102d67:	83 ec 0c             	sub    $0xc,%esp
80102d6a:	50                   	push   %eax
80102d6b:	e8 d4 09 00 00       	call   80103744 <wakeup>
80102d70:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102d73:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102d7a:	75 09                	jne    80102d85 <pipeclose+0x47>
80102d7c:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102d83:	74 2f                	je     80102db4 <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102d85:	83 ec 0c             	sub    $0xc,%esp
80102d88:	53                   	push   %ebx
80102d89:	e8 aa 0d 00 00       	call   80103b38 <release>
80102d8e:	83 c4 10             	add    $0x10,%esp
}
80102d91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102d94:	c9                   	leave  
80102d95:	c3                   	ret    
    p->readopen = 0;
80102d96:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102d9d:	00 00 00 
    wakeup(&p->nwrite);
80102da0:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102da6:	83 ec 0c             	sub    $0xc,%esp
80102da9:	50                   	push   %eax
80102daa:	e8 95 09 00 00       	call   80103744 <wakeup>
80102daf:	83 c4 10             	add    $0x10,%esp
80102db2:	eb bf                	jmp    80102d73 <pipeclose+0x35>
    release(&p->lock);
80102db4:	83 ec 0c             	sub    $0xc,%esp
80102db7:	53                   	push   %ebx
80102db8:	e8 7b 0d 00 00       	call   80103b38 <release>
    kfree((char*)p);
80102dbd:	89 1c 24             	mov    %ebx,(%esp)
80102dc0:	e8 4c f1 ff ff       	call   80101f11 <kfree>
80102dc5:	83 c4 10             	add    $0x10,%esp
80102dc8:	eb c7                	jmp    80102d91 <pipeclose+0x53>

80102dca <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80102dca:	55                   	push   %ebp
80102dcb:	89 e5                	mov    %esp,%ebp
80102dcd:	56                   	push   %esi
80102dce:	53                   	push   %ebx
80102dcf:	83 ec 1c             	sub    $0x1c,%esp
80102dd2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102dd5:	53                   	push   %ebx
80102dd6:	e8 f8 0c 00 00       	call   80103ad3 <acquire>
  for(i = 0; i < n; i++){
80102ddb:	83 c4 10             	add    $0x10,%esp
80102dde:	be 00 00 00 00       	mov    $0x0,%esi
80102de3:	3b 75 10             	cmp    0x10(%ebp),%esi
80102de6:	7c 41                	jl     80102e29 <pipewrite+0x5f>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80102de8:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102dee:	83 ec 0c             	sub    $0xc,%esp
80102df1:	50                   	push   %eax
80102df2:	e8 4d 09 00 00       	call   80103744 <wakeup>
  release(&p->lock);
80102df7:	89 1c 24             	mov    %ebx,(%esp)
80102dfa:	e8 39 0d 00 00       	call   80103b38 <release>
  return n;
80102dff:	83 c4 10             	add    $0x10,%esp
80102e02:	8b 45 10             	mov    0x10(%ebp),%eax
80102e05:	eb 5c                	jmp    80102e63 <pipewrite+0x99>
      wakeup(&p->nread);
80102e07:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102e0d:	83 ec 0c             	sub    $0xc,%esp
80102e10:	50                   	push   %eax
80102e11:	e8 2e 09 00 00       	call   80103744 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102e16:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102e1c:	83 c4 08             	add    $0x8,%esp
80102e1f:	53                   	push   %ebx
80102e20:	50                   	push   %eax
80102e21:	e8 ab 07 00 00       	call   801035d1 <sleep>
80102e26:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102e29:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80102e2f:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102e35:	05 00 02 00 00       	add    $0x200,%eax
80102e3a:	39 c2                	cmp    %eax,%edx
80102e3c:	75 2c                	jne    80102e6a <pipewrite+0xa0>
      if(p->readopen == 0 || myproc()->killed){
80102e3e:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102e45:	74 0b                	je     80102e52 <pipewrite+0x88>
80102e47:	e8 ce 02 00 00       	call   8010311a <myproc>
80102e4c:	83 78 28 00          	cmpl   $0x0,0x28(%eax)
80102e50:	74 b5                	je     80102e07 <pipewrite+0x3d>
        release(&p->lock);
80102e52:	83 ec 0c             	sub    $0xc,%esp
80102e55:	53                   	push   %ebx
80102e56:	e8 dd 0c 00 00       	call   80103b38 <release>
        return -1;
80102e5b:	83 c4 10             	add    $0x10,%esp
80102e5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102e63:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102e66:	5b                   	pop    %ebx
80102e67:	5e                   	pop    %esi
80102e68:	5d                   	pop    %ebp
80102e69:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80102e6a:	8d 42 01             	lea    0x1(%edx),%eax
80102e6d:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80102e73:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102e79:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e7c:	8a 04 30             	mov    (%eax,%esi,1),%al
80102e7f:	88 45 f7             	mov    %al,-0x9(%ebp)
80102e82:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80102e86:	46                   	inc    %esi
80102e87:	e9 57 ff ff ff       	jmp    80102de3 <pipewrite+0x19>

80102e8c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80102e8c:	55                   	push   %ebp
80102e8d:	89 e5                	mov    %esp,%ebp
80102e8f:	57                   	push   %edi
80102e90:	56                   	push   %esi
80102e91:	53                   	push   %ebx
80102e92:	83 ec 18             	sub    $0x18,%esp
80102e95:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102e98:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
80102e9b:	53                   	push   %ebx
80102e9c:	e8 32 0c 00 00       	call   80103ad3 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102ea1:	83 c4 10             	add    $0x10,%esp
80102ea4:	eb 13                	jmp    80102eb9 <piperead+0x2d>
    if(myproc()->killed){
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80102ea6:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102eac:	83 ec 08             	sub    $0x8,%esp
80102eaf:	53                   	push   %ebx
80102eb0:	50                   	push   %eax
80102eb1:	e8 1b 07 00 00       	call   801035d1 <sleep>
80102eb6:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102eb9:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102ebf:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80102ec5:	75 75                	jne    80102f3c <piperead+0xb0>
80102ec7:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80102ecd:	85 f6                	test   %esi,%esi
80102ecf:	74 34                	je     80102f05 <piperead+0x79>
    if(myproc()->killed){
80102ed1:	e8 44 02 00 00       	call   8010311a <myproc>
80102ed6:	83 78 28 00          	cmpl   $0x0,0x28(%eax)
80102eda:	74 ca                	je     80102ea6 <piperead+0x1a>
      release(&p->lock);
80102edc:	83 ec 0c             	sub    $0xc,%esp
80102edf:	53                   	push   %ebx
80102ee0:	e8 53 0c 00 00       	call   80103b38 <release>
      return -1;
80102ee5:	83 c4 10             	add    $0x10,%esp
80102ee8:	be ff ff ff ff       	mov    $0xffffffff,%esi
80102eed:	eb 43                	jmp    80102f32 <piperead+0xa6>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80102eef:	8d 50 01             	lea    0x1(%eax),%edx
80102ef2:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80102ef8:	25 ff 01 00 00       	and    $0x1ff,%eax
80102efd:	8a 44 03 34          	mov    0x34(%ebx,%eax,1),%al
80102f01:	88 04 37             	mov    %al,(%edi,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80102f04:	46                   	inc    %esi
80102f05:	3b 75 10             	cmp    0x10(%ebp),%esi
80102f08:	7d 0e                	jge    80102f18 <piperead+0x8c>
    if(p->nread == p->nwrite)
80102f0a:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102f10:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80102f16:	75 d7                	jne    80102eef <piperead+0x63>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80102f18:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f1e:	83 ec 0c             	sub    $0xc,%esp
80102f21:	50                   	push   %eax
80102f22:	e8 1d 08 00 00       	call   80103744 <wakeup>
  release(&p->lock);
80102f27:	89 1c 24             	mov    %ebx,(%esp)
80102f2a:	e8 09 0c 00 00       	call   80103b38 <release>
  return i;
80102f2f:	83 c4 10             	add    $0x10,%esp
}
80102f32:	89 f0                	mov    %esi,%eax
80102f34:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f37:	5b                   	pop    %ebx
80102f38:	5e                   	pop    %esi
80102f39:	5f                   	pop    %edi
80102f3a:	5d                   	pop    %ebp
80102f3b:	c3                   	ret    
80102f3c:	be 00 00 00 00       	mov    $0x0,%esi
80102f41:	eb c2                	jmp    80102f05 <piperead+0x79>

80102f43 <wakeup1>:
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80102f43:	ba 54 1d 11 80       	mov    $0x80111d54,%edx
80102f48:	eb 03                	jmp    80102f4d <wakeup1+0xa>
80102f4a:	83 ea 80             	sub    $0xffffff80,%edx
80102f4d:	81 fa 54 3d 11 80    	cmp    $0x80113d54,%edx
80102f53:	73 14                	jae    80102f69 <wakeup1+0x26>
    if(p->state == SLEEPING && p->chan == chan)
80102f55:	83 7a 10 02          	cmpl   $0x2,0x10(%edx)
80102f59:	75 ef                	jne    80102f4a <wakeup1+0x7>
80102f5b:	39 42 24             	cmp    %eax,0x24(%edx)
80102f5e:	75 ea                	jne    80102f4a <wakeup1+0x7>
      p->state = RUNNABLE;
80102f60:	c7 42 10 03 00 00 00 	movl   $0x3,0x10(%edx)
80102f67:	eb e1                	jmp    80102f4a <wakeup1+0x7>
}
80102f69:	c3                   	ret    

80102f6a <allocproc>:
{
80102f6a:	55                   	push   %ebp
80102f6b:	89 e5                	mov    %esp,%ebp
80102f6d:	53                   	push   %ebx
80102f6e:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80102f71:	68 20 1d 11 80       	push   $0x80111d20
80102f76:	e8 58 0b 00 00       	call   80103ad3 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80102f7b:	83 c4 10             	add    $0x10,%esp
80102f7e:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80102f83:	eb 03                	jmp    80102f88 <allocproc+0x1e>
80102f85:	83 eb 80             	sub    $0xffffff80,%ebx
80102f88:	81 fb 54 3d 11 80    	cmp    $0x80113d54,%ebx
80102f8e:	73 76                	jae    80103006 <allocproc+0x9c>
    if(p->state == UNUSED)
80102f90:	83 7b 10 00          	cmpl   $0x0,0x10(%ebx)
80102f94:	75 ef                	jne    80102f85 <allocproc+0x1b>
  p->state = EMBRYO;
80102f96:	c7 43 10 01 00 00 00 	movl   $0x1,0x10(%ebx)
  p->pid = nextpid++;
80102f9d:	a1 04 a0 10 80       	mov    0x8010a004,%eax
80102fa2:	8d 50 01             	lea    0x1(%eax),%edx
80102fa5:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
80102fab:	89 43 14             	mov    %eax,0x14(%ebx)
  release(&ptable.lock);
80102fae:	83 ec 0c             	sub    $0xc,%esp
80102fb1:	68 20 1d 11 80       	push   $0x80111d20
80102fb6:	e8 7d 0b 00 00       	call   80103b38 <release>
  if((p->kstack = kalloc()) == 0){
80102fbb:	e8 68 f0 ff ff       	call   80102028 <kalloc>
80102fc0:	89 43 0c             	mov    %eax,0xc(%ebx)
80102fc3:	83 c4 10             	add    $0x10,%esp
80102fc6:	85 c0                	test   %eax,%eax
80102fc8:	74 53                	je     8010301d <allocproc+0xb3>
  sp -= sizeof *p->tf;
80102fca:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
80102fd0:	89 53 1c             	mov    %edx,0x1c(%ebx)
  *(uint*)sp = (uint)trapret;
80102fd3:	c7 80 b0 0f 00 00 fb 	movl   $0x80104cfb,0xfb0(%eax)
80102fda:	4c 10 80 
  sp -= sizeof *p->context;
80102fdd:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80102fe2:	89 43 20             	mov    %eax,0x20(%ebx)
  memset(p->context, 0, sizeof *p->context);
80102fe5:	83 ec 04             	sub    $0x4,%esp
80102fe8:	6a 14                	push   $0x14
80102fea:	6a 00                	push   $0x0
80102fec:	50                   	push   %eax
80102fed:	e8 8d 0b 00 00       	call   80103b7f <memset>
  p->context->eip = (uint)forkret;
80102ff2:	8b 43 20             	mov    0x20(%ebx),%eax
80102ff5:	c7 40 10 28 30 10 80 	movl   $0x80103028,0x10(%eax)
  return p;
80102ffc:	83 c4 10             	add    $0x10,%esp
}
80102fff:	89 d8                	mov    %ebx,%eax
80103001:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103004:	c9                   	leave  
80103005:	c3                   	ret    
  release(&ptable.lock);
80103006:	83 ec 0c             	sub    $0xc,%esp
80103009:	68 20 1d 11 80       	push   $0x80111d20
8010300e:	e8 25 0b 00 00       	call   80103b38 <release>
  return 0;
80103013:	83 c4 10             	add    $0x10,%esp
80103016:	bb 00 00 00 00       	mov    $0x0,%ebx
8010301b:	eb e2                	jmp    80102fff <allocproc+0x95>
    p->state = UNUSED;
8010301d:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
    return 0;
80103024:	89 c3                	mov    %eax,%ebx
80103026:	eb d7                	jmp    80102fff <allocproc+0x95>

80103028 <forkret>:
{
80103028:	55                   	push   %ebp
80103029:	89 e5                	mov    %esp,%ebp
8010302b:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
8010302e:	68 20 1d 11 80       	push   $0x80111d20
80103033:	e8 00 0b 00 00       	call   80103b38 <release>
  if (first) {
80103038:	83 c4 10             	add    $0x10,%esp
8010303b:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
80103042:	75 02                	jne    80103046 <forkret+0x1e>
}
80103044:	c9                   	leave  
80103045:	c3                   	ret    
    first = 0;
80103046:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
8010304d:	00 00 00 
    iinit(ROOTDEV);
80103050:	83 ec 0c             	sub    $0xc,%esp
80103053:	6a 01                	push   $0x1
80103055:	e8 25 e2 ff ff       	call   8010127f <iinit>
    initlog(ROOTDEV);
8010305a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103061:	e8 2e f6 ff ff       	call   80102694 <initlog>
80103066:	83 c4 10             	add    $0x10,%esp
}
80103069:	eb d9                	jmp    80103044 <forkret+0x1c>

8010306b <pinit>:
{
8010306b:	55                   	push   %ebp
8010306c:	89 e5                	mov    %esp,%ebp
8010306e:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103071:	68 20 6d 10 80       	push   $0x80106d20
80103076:	68 20 1d 11 80       	push   $0x80111d20
8010307b:	e8 1c 09 00 00       	call   8010399c <initlock>
}
80103080:	83 c4 10             	add    $0x10,%esp
80103083:	c9                   	leave  
80103084:	c3                   	ret    

80103085 <mycpu>:
{
80103085:	55                   	push   %ebp
80103086:	89 e5                	mov    %esp,%ebp
80103088:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010308b:	9c                   	pushf  
8010308c:	58                   	pop    %eax
  if(readeflags()&FL_IF)
8010308d:	f6 c4 02             	test   $0x2,%ah
80103090:	75 2c                	jne    801030be <mycpu+0x39>
  apicid = lapicid();
80103092:	e8 4d f2 ff ff       	call   801022e4 <lapicid>
80103097:	89 c1                	mov    %eax,%ecx
  for (i = 0; i < ncpu; ++i) {
80103099:	ba 00 00 00 00       	mov    $0x0,%edx
8010309e:	39 15 84 17 11 80    	cmp    %edx,0x80111784
801030a4:	7e 25                	jle    801030cb <mycpu+0x46>
    if (cpus[i].apicid == apicid)
801030a6:	8d 04 92             	lea    (%edx,%edx,4),%eax
801030a9:	01 c0                	add    %eax,%eax
801030ab:	01 d0                	add    %edx,%eax
801030ad:	c1 e0 04             	shl    $0x4,%eax
801030b0:	0f b6 80 a0 17 11 80 	movzbl -0x7feee860(%eax),%eax
801030b7:	39 c8                	cmp    %ecx,%eax
801030b9:	74 1d                	je     801030d8 <mycpu+0x53>
  for (i = 0; i < ncpu; ++i) {
801030bb:	42                   	inc    %edx
801030bc:	eb e0                	jmp    8010309e <mycpu+0x19>
    panic("mycpu called with interrupts enabled\n");
801030be:	83 ec 0c             	sub    $0xc,%esp
801030c1:	68 04 6e 10 80       	push   $0x80106e04
801030c6:	e8 76 d2 ff ff       	call   80100341 <panic>
  panic("unknown apicid\n");
801030cb:	83 ec 0c             	sub    $0xc,%esp
801030ce:	68 27 6d 10 80       	push   $0x80106d27
801030d3:	e8 69 d2 ff ff       	call   80100341 <panic>
      return &cpus[i];
801030d8:	8d 04 92             	lea    (%edx,%edx,4),%eax
801030db:	01 c0                	add    %eax,%eax
801030dd:	01 d0                	add    %edx,%eax
801030df:	c1 e0 04             	shl    $0x4,%eax
801030e2:	05 a0 17 11 80       	add    $0x801117a0,%eax
}
801030e7:	c9                   	leave  
801030e8:	c3                   	ret    

801030e9 <cpuid>:
cpuid() {
801030e9:	55                   	push   %ebp
801030ea:	89 e5                	mov    %esp,%ebp
801030ec:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801030ef:	e8 91 ff ff ff       	call   80103085 <mycpu>
801030f4:	2d a0 17 11 80       	sub    $0x801117a0,%eax
801030f9:	c1 f8 04             	sar    $0x4,%eax
801030fc:	8d 0c c0             	lea    (%eax,%eax,8),%ecx
801030ff:	89 ca                	mov    %ecx,%edx
80103101:	c1 e2 05             	shl    $0x5,%edx
80103104:	29 ca                	sub    %ecx,%edx
80103106:	8d 14 90             	lea    (%eax,%edx,4),%edx
80103109:	8d 0c d0             	lea    (%eax,%edx,8),%ecx
8010310c:	89 ca                	mov    %ecx,%edx
8010310e:	c1 e2 0f             	shl    $0xf,%edx
80103111:	29 ca                	sub    %ecx,%edx
80103113:	8d 04 90             	lea    (%eax,%edx,4),%eax
80103116:	f7 d8                	neg    %eax
}
80103118:	c9                   	leave  
80103119:	c3                   	ret    

8010311a <myproc>:
myproc(void) {
8010311a:	55                   	push   %ebp
8010311b:	89 e5                	mov    %esp,%ebp
8010311d:	53                   	push   %ebx
8010311e:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103121:	e8 d3 08 00 00       	call   801039f9 <pushcli>
  c = mycpu();
80103126:	e8 5a ff ff ff       	call   80103085 <mycpu>
  p = c->proc;
8010312b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103131:	e8 fe 08 00 00       	call   80103a34 <popcli>
}
80103136:	89 d8                	mov    %ebx,%eax
80103138:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010313b:	c9                   	leave  
8010313c:	c3                   	ret    

8010313d <userinit>:
{
8010313d:	55                   	push   %ebp
8010313e:	89 e5                	mov    %esp,%ebp
80103140:	53                   	push   %ebx
80103141:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103144:	e8 21 fe ff ff       	call   80102f6a <allocproc>
80103149:	89 c3                	mov    %eax,%ebx
  initproc = p;
8010314b:	a3 54 3d 11 80       	mov    %eax,0x80113d54
  if((p->pgdir = setupkvm()) == 0)
80103150:	e8 24 34 00 00       	call   80106579 <setupkvm>
80103155:	89 43 08             	mov    %eax,0x8(%ebx)
80103158:	85 c0                	test   %eax,%eax
8010315a:	0f 84 b7 00 00 00    	je     80103217 <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103160:	83 ec 04             	sub    $0x4,%esp
80103163:	68 2c 00 00 00       	push   $0x2c
80103168:	68 60 a4 10 80       	push   $0x8010a460
8010316d:	50                   	push   %eax
8010316e:	e8 11 31 00 00       	call   80106284 <inituvm>
  p->sz = PGSIZE;
80103173:	c7 43 04 00 10 00 00 	movl   $0x1000,0x4(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
8010317a:	8b 43 1c             	mov    0x1c(%ebx),%eax
8010317d:	83 c4 0c             	add    $0xc,%esp
80103180:	6a 4c                	push   $0x4c
80103182:	6a 00                	push   $0x0
80103184:	50                   	push   %eax
80103185:	e8 f5 09 00 00       	call   80103b7f <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010318a:	8b 43 1c             	mov    0x1c(%ebx),%eax
8010318d:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103193:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103196:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010319c:	8b 43 1c             	mov    0x1c(%ebx),%eax
8010319f:	8b 50 2c             	mov    0x2c(%eax),%edx
801031a2:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801031a6:	8b 43 1c             	mov    0x1c(%ebx),%eax
801031a9:	8b 50 2c             	mov    0x2c(%eax),%edx
801031ac:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801031b0:	8b 43 1c             	mov    0x1c(%ebx),%eax
801031b3:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801031ba:	8b 43 1c             	mov    0x1c(%ebx),%eax
801031bd:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801031c4:	8b 43 1c             	mov    0x1c(%ebx),%eax
801031c7:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
801031ce:	8d 43 70             	lea    0x70(%ebx),%eax
801031d1:	83 c4 0c             	add    $0xc,%esp
801031d4:	6a 10                	push   $0x10
801031d6:	68 50 6d 10 80       	push   $0x80106d50
801031db:	50                   	push   %eax
801031dc:	e8 f6 0a 00 00       	call   80103cd7 <safestrcpy>
  p->cwd = namei("/");
801031e1:	c7 04 24 59 6d 10 80 	movl   $0x80106d59,(%esp)
801031e8:	e8 7e e9 ff ff       	call   80101b6b <namei>
801031ed:	89 43 6c             	mov    %eax,0x6c(%ebx)
  acquire(&ptable.lock);
801031f0:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801031f7:	e8 d7 08 00 00       	call   80103ad3 <acquire>
  p->state = RUNNABLE;
801031fc:	c7 43 10 03 00 00 00 	movl   $0x3,0x10(%ebx)
  release(&ptable.lock);
80103203:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010320a:	e8 29 09 00 00       	call   80103b38 <release>
}
8010320f:	83 c4 10             	add    $0x10,%esp
80103212:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103215:	c9                   	leave  
80103216:	c3                   	ret    
    panic("userinit: out of memory?");
80103217:	83 ec 0c             	sub    $0xc,%esp
8010321a:	68 37 6d 10 80       	push   $0x80106d37
8010321f:	e8 1d d1 ff ff       	call   80100341 <panic>

80103224 <growproc>:
{
80103224:	55                   	push   %ebp
80103225:	89 e5                	mov    %esp,%ebp
80103227:	56                   	push   %esi
80103228:	53                   	push   %ebx
80103229:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
8010322c:	e8 e9 fe ff ff       	call   8010311a <myproc>
80103231:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;//Tamaño inicial
80103233:	8b 40 04             	mov    0x4(%eax),%eax
  if(n > 0){
80103236:	85 f6                	test   %esi,%esi
80103238:	7f 1c                	jg     80103256 <growproc+0x32>
  } else if(n < 0){
8010323a:	78 37                	js     80103273 <growproc+0x4f>
  curproc->sz = sz;
8010323c:	89 43 04             	mov    %eax,0x4(%ebx)
  lcr3(V2P(curproc->pgdir));  // Invalidate TLB. Cambia la tabla de páginas
8010323f:	8b 43 08             	mov    0x8(%ebx),%eax
80103242:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80103247:	0f 22 d8             	mov    %eax,%cr3
  return 0;
8010324a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010324f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103252:	5b                   	pop    %ebx
80103253:	5e                   	pop    %esi
80103254:	5d                   	pop    %ebp
80103255:	c3                   	ret    
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103256:	83 ec 04             	sub    $0x4,%esp
80103259:	01 c6                	add    %eax,%esi
8010325b:	56                   	push   %esi
8010325c:	50                   	push   %eax
8010325d:	ff 73 08             	push   0x8(%ebx)
80103260:	e8 b1 31 00 00       	call   80106416 <allocuvm>
80103265:	83 c4 10             	add    $0x10,%esp
80103268:	85 c0                	test   %eax,%eax
8010326a:	75 d0                	jne    8010323c <growproc+0x18>
      return -1;
8010326c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103271:	eb dc                	jmp    8010324f <growproc+0x2b>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103273:	83 ec 04             	sub    $0x4,%esp
80103276:	01 c6                	add    %eax,%esi
80103278:	56                   	push   %esi
80103279:	50                   	push   %eax
8010327a:	ff 73 08             	push   0x8(%ebx)
8010327d:	e8 04 31 00 00       	call   80106386 <deallocuvm>
80103282:	83 c4 10             	add    $0x10,%esp
80103285:	85 c0                	test   %eax,%eax
80103287:	75 b3                	jne    8010323c <growproc+0x18>
      return -1;
80103289:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010328e:	eb bf                	jmp    8010324f <growproc+0x2b>

80103290 <fork>:
{
80103290:	55                   	push   %ebp
80103291:	89 e5                	mov    %esp,%ebp
80103293:	57                   	push   %edi
80103294:	56                   	push   %esi
80103295:	53                   	push   %ebx
80103296:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
80103299:	e8 7c fe ff ff       	call   8010311a <myproc>
8010329e:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
801032a0:	e8 c5 fc ff ff       	call   80102f6a <allocproc>
801032a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801032a8:	85 c0                	test   %eax,%eax
801032aa:	0f 84 e1 00 00 00    	je     80103391 <fork+0x101>
801032b0:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801032b2:	83 ec 08             	sub    $0x8,%esp
801032b5:	ff 73 04             	push   0x4(%ebx)
801032b8:	ff 73 08             	push   0x8(%ebx)
801032bb:	e8 6c 33 00 00       	call   8010662c <copyuvm>
801032c0:	89 47 08             	mov    %eax,0x8(%edi)
801032c3:	83 c4 10             	add    $0x10,%esp
801032c6:	85 c0                	test   %eax,%eax
801032c8:	74 2c                	je     801032f6 <fork+0x66>
  np->sz = curproc->sz;
801032ca:	8b 43 04             	mov    0x4(%ebx),%eax
801032cd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801032d0:	89 41 04             	mov    %eax,0x4(%ecx)
  np->parent = curproc;
801032d3:	89 c8                	mov    %ecx,%eax
801032d5:	89 59 18             	mov    %ebx,0x18(%ecx)
  *np->tf = *curproc->tf;
801032d8:	8b 73 1c             	mov    0x1c(%ebx),%esi
801032db:	8b 79 1c             	mov    0x1c(%ecx),%edi
801032de:	b9 13 00 00 00       	mov    $0x13,%ecx
801032e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
801032e5:	8b 40 1c             	mov    0x1c(%eax),%eax
801032e8:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
801032ef:	be 00 00 00 00       	mov    $0x0,%esi
801032f4:	eb 27                	jmp    8010331d <fork+0x8d>
    kfree(np->kstack);
801032f6:	83 ec 0c             	sub    $0xc,%esp
801032f9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801032fc:	ff 73 0c             	push   0xc(%ebx)
801032ff:	e8 0d ec ff ff       	call   80101f11 <kfree>
    np->kstack = 0;
80103304:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    np->state = UNUSED;
8010330b:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
    return -1;
80103312:	83 c4 10             	add    $0x10,%esp
80103315:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010331a:	eb 6b                	jmp    80103387 <fork+0xf7>
  for(i = 0; i < NOFILE; i++)
8010331c:	46                   	inc    %esi
8010331d:	83 fe 0f             	cmp    $0xf,%esi
80103320:	7f 1d                	jg     8010333f <fork+0xaf>
    if(curproc->ofile[i])
80103322:	8b 44 b3 2c          	mov    0x2c(%ebx,%esi,4),%eax
80103326:	85 c0                	test   %eax,%eax
80103328:	74 f2                	je     8010331c <fork+0x8c>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010332a:	83 ec 0c             	sub    $0xc,%esp
8010332d:	50                   	push   %eax
8010332e:	e8 15 d9 ff ff       	call   80100c48 <filedup>
80103333:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103336:	89 44 b2 2c          	mov    %eax,0x2c(%edx,%esi,4)
8010333a:	83 c4 10             	add    $0x10,%esp
8010333d:	eb dd                	jmp    8010331c <fork+0x8c>
  np->cwd = idup(curproc->cwd);
8010333f:	83 ec 0c             	sub    $0xc,%esp
80103342:	ff 73 6c             	push   0x6c(%ebx)
80103345:	e8 8f e1 ff ff       	call   801014d9 <idup>
8010334a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010334d:	89 47 6c             	mov    %eax,0x6c(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103350:	83 c3 70             	add    $0x70,%ebx
80103353:	8d 47 70             	lea    0x70(%edi),%eax
80103356:	83 c4 0c             	add    $0xc,%esp
80103359:	6a 10                	push   $0x10
8010335b:	53                   	push   %ebx
8010335c:	50                   	push   %eax
8010335d:	e8 75 09 00 00       	call   80103cd7 <safestrcpy>
  pid = np->pid;
80103362:	8b 5f 14             	mov    0x14(%edi),%ebx
  acquire(&ptable.lock);
80103365:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010336c:	e8 62 07 00 00       	call   80103ad3 <acquire>
  np->state = RUNNABLE;
80103371:	c7 47 10 03 00 00 00 	movl   $0x3,0x10(%edi)
  release(&ptable.lock);
80103378:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010337f:	e8 b4 07 00 00       	call   80103b38 <release>
  return pid;
80103384:	83 c4 10             	add    $0x10,%esp
}
80103387:	89 d8                	mov    %ebx,%eax
80103389:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010338c:	5b                   	pop    %ebx
8010338d:	5e                   	pop    %esi
8010338e:	5f                   	pop    %edi
8010338f:	5d                   	pop    %ebp
80103390:	c3                   	ret    
    return -1;
80103391:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103396:	eb ef                	jmp    80103387 <fork+0xf7>

80103398 <scheduler>:
{
80103398:	55                   	push   %ebp
80103399:	89 e5                	mov    %esp,%ebp
8010339b:	56                   	push   %esi
8010339c:	53                   	push   %ebx
  struct cpu *c = mycpu();
8010339d:	e8 e3 fc ff ff       	call   80103085 <mycpu>
801033a2:	89 c6                	mov    %eax,%esi
  c->proc = 0;
801033a4:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801033ab:	00 00 00 
801033ae:	eb 5a                	jmp    8010340a <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801033b0:	83 eb 80             	sub    $0xffffff80,%ebx
801033b3:	81 fb 54 3d 11 80    	cmp    $0x80113d54,%ebx
801033b9:	73 3f                	jae    801033fa <scheduler+0x62>
      if(p->state != RUNNABLE)
801033bb:	83 7b 10 03          	cmpl   $0x3,0x10(%ebx)
801033bf:	75 ef                	jne    801033b0 <scheduler+0x18>
      c->proc = p;
801033c1:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
801033c7:	83 ec 0c             	sub    $0xc,%esp
801033ca:	53                   	push   %ebx
801033cb:	e8 58 2d 00 00       	call   80106128 <switchuvm>
      p->state = RUNNING;
801033d0:	c7 43 10 04 00 00 00 	movl   $0x4,0x10(%ebx)
      swtch(&(c->scheduler), p->context);
801033d7:	83 c4 08             	add    $0x8,%esp
801033da:	ff 73 20             	push   0x20(%ebx)
801033dd:	8d 46 04             	lea    0x4(%esi),%eax
801033e0:	50                   	push   %eax
801033e1:	e8 3f 09 00 00       	call   80103d25 <swtch>
      switchkvm();
801033e6:	e8 2f 2d 00 00       	call   8010611a <switchkvm>
      c->proc = 0;
801033eb:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801033f2:	00 00 00 
801033f5:	83 c4 10             	add    $0x10,%esp
801033f8:	eb b6                	jmp    801033b0 <scheduler+0x18>
    release(&ptable.lock);
801033fa:	83 ec 0c             	sub    $0xc,%esp
801033fd:	68 20 1d 11 80       	push   $0x80111d20
80103402:	e8 31 07 00 00       	call   80103b38 <release>
    sti();
80103407:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
8010340a:	fb                   	sti    
    acquire(&ptable.lock);
8010340b:	83 ec 0c             	sub    $0xc,%esp
8010340e:	68 20 1d 11 80       	push   $0x80111d20
80103413:	e8 bb 06 00 00       	call   80103ad3 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103418:	83 c4 10             	add    $0x10,%esp
8010341b:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80103420:	eb 91                	jmp    801033b3 <scheduler+0x1b>

80103422 <sched>:
{
80103422:	55                   	push   %ebp
80103423:	89 e5                	mov    %esp,%ebp
80103425:	56                   	push   %esi
80103426:	53                   	push   %ebx
  struct proc *p = myproc();
80103427:	e8 ee fc ff ff       	call   8010311a <myproc>
8010342c:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
8010342e:	83 ec 0c             	sub    $0xc,%esp
80103431:	68 20 1d 11 80       	push   $0x80111d20
80103436:	e8 59 06 00 00       	call   80103a94 <holding>
8010343b:	83 c4 10             	add    $0x10,%esp
8010343e:	85 c0                	test   %eax,%eax
80103440:	74 4f                	je     80103491 <sched+0x6f>
  if(mycpu()->ncli != 1)
80103442:	e8 3e fc ff ff       	call   80103085 <mycpu>
80103447:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
8010344e:	75 4e                	jne    8010349e <sched+0x7c>
  if(p->state == RUNNING)
80103450:	83 7b 10 04          	cmpl   $0x4,0x10(%ebx)
80103454:	74 55                	je     801034ab <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103456:	9c                   	pushf  
80103457:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103458:	f6 c4 02             	test   $0x2,%ah
8010345b:	75 5b                	jne    801034b8 <sched+0x96>
  intena = mycpu()->intena;
8010345d:	e8 23 fc ff ff       	call   80103085 <mycpu>
80103462:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103468:	e8 18 fc ff ff       	call   80103085 <mycpu>
8010346d:	83 ec 08             	sub    $0x8,%esp
80103470:	ff 70 04             	push   0x4(%eax)
80103473:	83 c3 20             	add    $0x20,%ebx
80103476:	53                   	push   %ebx
80103477:	e8 a9 08 00 00       	call   80103d25 <swtch>
  mycpu()->intena = intena;
8010347c:	e8 04 fc ff ff       	call   80103085 <mycpu>
80103481:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103487:	83 c4 10             	add    $0x10,%esp
8010348a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010348d:	5b                   	pop    %ebx
8010348e:	5e                   	pop    %esi
8010348f:	5d                   	pop    %ebp
80103490:	c3                   	ret    
    panic("sched ptable.lock");
80103491:	83 ec 0c             	sub    $0xc,%esp
80103494:	68 5b 6d 10 80       	push   $0x80106d5b
80103499:	e8 a3 ce ff ff       	call   80100341 <panic>
    panic("sched locks");
8010349e:	83 ec 0c             	sub    $0xc,%esp
801034a1:	68 6d 6d 10 80       	push   $0x80106d6d
801034a6:	e8 96 ce ff ff       	call   80100341 <panic>
    panic("sched running");
801034ab:	83 ec 0c             	sub    $0xc,%esp
801034ae:	68 79 6d 10 80       	push   $0x80106d79
801034b3:	e8 89 ce ff ff       	call   80100341 <panic>
    panic("sched interruptible");
801034b8:	83 ec 0c             	sub    $0xc,%esp
801034bb:	68 87 6d 10 80       	push   $0x80106d87
801034c0:	e8 7c ce ff ff       	call   80100341 <panic>

801034c5 <exit>:
{
801034c5:	55                   	push   %ebp
801034c6:	89 e5                	mov    %esp,%ebp
801034c8:	56                   	push   %esi
801034c9:	53                   	push   %ebx
  struct proc *curproc = myproc(); // curproc = myproc() --> :e proc.h
801034ca:	e8 4b fc ff ff       	call   8010311a <myproc>
  if(curproc == initproc)
801034cf:	39 05 54 3d 11 80    	cmp    %eax,0x80113d54
801034d5:	74 09                	je     801034e0 <exit+0x1b>
801034d7:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){// Recorre la tabla de descriptores de fichero y los cierra
801034d9:	bb 00 00 00 00       	mov    $0x0,%ebx
801034de:	eb 22                	jmp    80103502 <exit+0x3d>
    panic("init exiting");
801034e0:	83 ec 0c             	sub    $0xc,%esp
801034e3:	68 9b 6d 10 80       	push   $0x80106d9b
801034e8:	e8 54 ce ff ff       	call   80100341 <panic>
      fileclose(curproc->ofile[fd]);
801034ed:	83 ec 0c             	sub    $0xc,%esp
801034f0:	50                   	push   %eax
801034f1:	e8 95 d7 ff ff       	call   80100c8b <fileclose>
      curproc->ofile[fd] = 0;
801034f6:	c7 44 9e 2c 00 00 00 	movl   $0x0,0x2c(%esi,%ebx,4)
801034fd:	00 
801034fe:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){// Recorre la tabla de descriptores de fichero y los cierra
80103501:	43                   	inc    %ebx
80103502:	83 fb 0f             	cmp    $0xf,%ebx
80103505:	7f 0a                	jg     80103511 <exit+0x4c>
    if(curproc->ofile[fd]){
80103507:	8b 44 9e 2c          	mov    0x2c(%esi,%ebx,4),%eax
8010350b:	85 c0                	test   %eax,%eax
8010350d:	75 de                	jne    801034ed <exit+0x28>
8010350f:	eb f0                	jmp    80103501 <exit+0x3c>
  begin_op();
80103511:	e8 c7 f1 ff ff       	call   801026dd <begin_op>
  iput(curproc->cwd);
80103516:	83 ec 0c             	sub    $0xc,%esp
80103519:	ff 76 6c             	push   0x6c(%esi)
8010351c:	e8 eb e0 ff ff       	call   8010160c <iput>
  end_op();
80103521:	e8 33 f2 ff ff       	call   80102759 <end_op>
  curproc->cwd = 0;//cwd = proceso actual
80103526:	c7 46 6c 00 00 00 00 	movl   $0x0,0x6c(%esi)
  acquire(&ptable.lock);//bloquea la tabla de procesos global del SO
8010352d:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103534:	e8 9a 05 00 00       	call   80103ad3 <acquire>
	curproc->exitcode = status;
80103539:	8b 45 08             	mov    0x8(%ebp),%eax
8010353c:	89 06                	mov    %eax,(%esi)
	wakeup1(curproc->parent);
8010353e:	8b 46 18             	mov    0x18(%esi),%eax
80103541:	e8 fd f9 ff ff       	call   80102f43 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103546:	83 c4 10             	add    $0x10,%esp
80103549:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
8010354e:	eb 03                	jmp    80103553 <exit+0x8e>
80103550:	83 eb 80             	sub    $0xffffff80,%ebx
80103553:	81 fb 54 3d 11 80    	cmp    $0x80113d54,%ebx
80103559:	73 1a                	jae    80103575 <exit+0xb0>
    if(p->parent == curproc){
8010355b:	39 73 18             	cmp    %esi,0x18(%ebx)
8010355e:	75 f0                	jne    80103550 <exit+0x8b>
      p->parent = initproc;
80103560:	a1 54 3d 11 80       	mov    0x80113d54,%eax
80103565:	89 43 18             	mov    %eax,0x18(%ebx)
      if(p->state == ZOMBIE)
80103568:	83 7b 10 05          	cmpl   $0x5,0x10(%ebx)
8010356c:	75 e2                	jne    80103550 <exit+0x8b>
        wakeup1(initproc);
8010356e:	e8 d0 f9 ff ff       	call   80102f43 <wakeup1>
80103573:	eb db                	jmp    80103550 <exit+0x8b>
  deallocuvm(curproc->pgdir, KERNBASE, 0);
80103575:	83 ec 04             	sub    $0x4,%esp
80103578:	6a 00                	push   $0x0
8010357a:	68 00 00 00 80       	push   $0x80000000
8010357f:	ff 76 08             	push   0x8(%esi)
80103582:	e8 ff 2d 00 00       	call   80106386 <deallocuvm>
  curproc->state = ZOMBIE;
80103587:	c7 46 10 05 00 00 00 	movl   $0x5,0x10(%esi)
  sched();
8010358e:	e8 8f fe ff ff       	call   80103422 <sched>
  panic("zombie exit");
80103593:	c7 04 24 a8 6d 10 80 	movl   $0x80106da8,(%esp)
8010359a:	e8 a2 cd ff ff       	call   80100341 <panic>

8010359f <yield>:
{
8010359f:	55                   	push   %ebp
801035a0:	89 e5                	mov    %esp,%ebp
801035a2:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801035a5:	68 20 1d 11 80       	push   $0x80111d20
801035aa:	e8 24 05 00 00       	call   80103ad3 <acquire>
  myproc()->state = RUNNABLE;
801035af:	e8 66 fb ff ff       	call   8010311a <myproc>
801035b4:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
  sched();
801035bb:	e8 62 fe ff ff       	call   80103422 <sched>
  release(&ptable.lock);
801035c0:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801035c7:	e8 6c 05 00 00       	call   80103b38 <release>
}
801035cc:	83 c4 10             	add    $0x10,%esp
801035cf:	c9                   	leave  
801035d0:	c3                   	ret    

801035d1 <sleep>:
{
801035d1:	55                   	push   %ebp
801035d2:	89 e5                	mov    %esp,%ebp
801035d4:	56                   	push   %esi
801035d5:	53                   	push   %ebx
801035d6:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct proc *p = myproc();
801035d9:	e8 3c fb ff ff       	call   8010311a <myproc>
  if(p == 0)
801035de:	85 c0                	test   %eax,%eax
801035e0:	74 66                	je     80103648 <sleep+0x77>
801035e2:	89 c3                	mov    %eax,%ebx
  if(lk == 0)
801035e4:	85 f6                	test   %esi,%esi
801035e6:	74 6d                	je     80103655 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801035e8:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
801035ee:	74 18                	je     80103608 <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
801035f0:	83 ec 0c             	sub    $0xc,%esp
801035f3:	68 20 1d 11 80       	push   $0x80111d20
801035f8:	e8 d6 04 00 00       	call   80103ad3 <acquire>
    release(lk);
801035fd:	89 34 24             	mov    %esi,(%esp)
80103600:	e8 33 05 00 00       	call   80103b38 <release>
80103605:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
80103608:	8b 45 08             	mov    0x8(%ebp),%eax
8010360b:	89 43 24             	mov    %eax,0x24(%ebx)
  p->state = SLEEPING;
8010360e:	c7 43 10 02 00 00 00 	movl   $0x2,0x10(%ebx)
  sched();
80103615:	e8 08 fe ff ff       	call   80103422 <sched>
  p->chan = 0;
8010361a:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103621:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
80103627:	74 18                	je     80103641 <sleep+0x70>
    release(&ptable.lock);
80103629:	83 ec 0c             	sub    $0xc,%esp
8010362c:	68 20 1d 11 80       	push   $0x80111d20
80103631:	e8 02 05 00 00       	call   80103b38 <release>
    acquire(lk);
80103636:	89 34 24             	mov    %esi,(%esp)
80103639:	e8 95 04 00 00       	call   80103ad3 <acquire>
8010363e:	83 c4 10             	add    $0x10,%esp
}
80103641:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103644:	5b                   	pop    %ebx
80103645:	5e                   	pop    %esi
80103646:	5d                   	pop    %ebp
80103647:	c3                   	ret    
    panic("sleep");
80103648:	83 ec 0c             	sub    $0xc,%esp
8010364b:	68 b4 6d 10 80       	push   $0x80106db4
80103650:	e8 ec cc ff ff       	call   80100341 <panic>
    panic("sleep without lk");
80103655:	83 ec 0c             	sub    $0xc,%esp
80103658:	68 ba 6d 10 80       	push   $0x80106dba
8010365d:	e8 df cc ff ff       	call   80100341 <panic>

80103662 <wait>:
{
80103662:	55                   	push   %ebp
80103663:	89 e5                	mov    %esp,%ebp
80103665:	57                   	push   %edi
80103666:	56                   	push   %esi
80103667:	53                   	push   %ebx
80103668:	83 ec 0c             	sub    $0xc,%esp
8010366b:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct proc *curproc = myproc();
8010366e:	e8 a7 fa ff ff       	call   8010311a <myproc>
80103673:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103675:	83 ec 0c             	sub    $0xc,%esp
80103678:	68 20 1d 11 80       	push   $0x80111d20
8010367d:	e8 51 04 00 00       	call   80103ad3 <acquire>
80103682:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103685:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010368a:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
8010368f:	eb 5e                	jmp    801036ef <wait+0x8d>
        pid = p->pid;
80103691:	8b 73 14             	mov    0x14(%ebx),%esi
        kfree(p->kstack);
80103694:	83 ec 0c             	sub    $0xc,%esp
80103697:	ff 73 0c             	push   0xc(%ebx)
8010369a:	e8 72 e8 ff ff       	call   80101f11 <kfree>
        p->kstack = 0;
8010369f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        freevm(p->pgdir, 0); // User zone deleted before
801036a6:	83 c4 08             	add    $0x8,%esp
801036a9:	6a 00                	push   $0x0
801036ab:	ff 73 08             	push   0x8(%ebx)
801036ae:	e8 50 2e 00 00       	call   80106503 <freevm>
        p->pid = 0;
801036b3:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->parent = 0;
801036ba:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
        p->name[0] = 0;
801036c1:	c6 43 70 00          	movb   $0x0,0x70(%ebx)
        p->killed = 0;
801036c5:	c7 43 28 00 00 00 00 	movl   $0x0,0x28(%ebx)
        p->state = UNUSED;
801036cc:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        release(&ptable.lock);
801036d3:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801036da:	e8 59 04 00 00       	call   80103b38 <release>
        return pid;
801036df:	83 c4 10             	add    $0x10,%esp
}
801036e2:	89 f0                	mov    %esi,%eax
801036e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801036e7:	5b                   	pop    %ebx
801036e8:	5e                   	pop    %esi
801036e9:	5f                   	pop    %edi
801036ea:	5d                   	pop    %ebp
801036eb:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801036ec:	83 eb 80             	sub    $0xffffff80,%ebx
801036ef:	81 fb 54 3d 11 80    	cmp    $0x80113d54,%ebx
801036f5:	73 16                	jae    8010370d <wait+0xab>
      if(p->parent != curproc)
801036f7:	39 73 18             	cmp    %esi,0x18(%ebx)
801036fa:	75 f0                	jne    801036ec <wait+0x8a>
			*status = p->exitcode;
801036fc:	8b 03                	mov    (%ebx),%eax
801036fe:	89 07                	mov    %eax,(%edi)
      if(p->state == ZOMBIE){
80103700:	83 7b 10 05          	cmpl   $0x5,0x10(%ebx)
80103704:	74 8b                	je     80103691 <wait+0x2f>
      havekids = 1;
80103706:	b8 01 00 00 00       	mov    $0x1,%eax
8010370b:	eb df                	jmp    801036ec <wait+0x8a>
    if(!havekids || curproc->killed){
8010370d:	85 c0                	test   %eax,%eax
8010370f:	74 06                	je     80103717 <wait+0xb5>
80103711:	83 7e 28 00          	cmpl   $0x0,0x28(%esi)
80103715:	74 17                	je     8010372e <wait+0xcc>
      release(&ptable.lock);
80103717:	83 ec 0c             	sub    $0xc,%esp
8010371a:	68 20 1d 11 80       	push   $0x80111d20
8010371f:	e8 14 04 00 00       	call   80103b38 <release>
      return -1;
80103724:	83 c4 10             	add    $0x10,%esp
80103727:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010372c:	eb b4                	jmp    801036e2 <wait+0x80>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010372e:	83 ec 08             	sub    $0x8,%esp
80103731:	68 20 1d 11 80       	push   $0x80111d20
80103736:	56                   	push   %esi
80103737:	e8 95 fe ff ff       	call   801035d1 <sleep>
    havekids = 0;
8010373c:	83 c4 10             	add    $0x10,%esp
8010373f:	e9 41 ff ff ff       	jmp    80103685 <wait+0x23>

80103744 <wakeup>:


// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103744:	55                   	push   %ebp
80103745:	89 e5                	mov    %esp,%ebp
80103747:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
8010374a:	68 20 1d 11 80       	push   $0x80111d20
8010374f:	e8 7f 03 00 00       	call   80103ad3 <acquire>
  wakeup1(chan);
80103754:	8b 45 08             	mov    0x8(%ebp),%eax
80103757:	e8 e7 f7 ff ff       	call   80102f43 <wakeup1>
  release(&ptable.lock);
8010375c:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103763:	e8 d0 03 00 00       	call   80103b38 <release>
}
80103768:	83 c4 10             	add    $0x10,%esp
8010376b:	c9                   	leave  
8010376c:	c3                   	ret    

8010376d <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010376d:	55                   	push   %ebp
8010376e:	89 e5                	mov    %esp,%ebp
80103770:	53                   	push   %ebx
80103771:	83 ec 10             	sub    $0x10,%esp
80103774:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103777:	68 20 1d 11 80       	push   $0x80111d20
8010377c:	e8 52 03 00 00       	call   80103ad3 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103781:	83 c4 10             	add    $0x10,%esp
80103784:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
80103789:	eb 0c                	jmp    80103797 <kill+0x2a>
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
8010378b:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
80103792:	eb 1c                	jmp    801037b0 <kill+0x43>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103794:	83 e8 80             	sub    $0xffffff80,%eax
80103797:	3d 54 3d 11 80       	cmp    $0x80113d54,%eax
8010379c:	73 2c                	jae    801037ca <kill+0x5d>
    if(p->pid == pid){
8010379e:	39 58 14             	cmp    %ebx,0x14(%eax)
801037a1:	75 f1                	jne    80103794 <kill+0x27>
      p->killed = 1;
801037a3:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
      if(p->state == SLEEPING)
801037aa:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
801037ae:	74 db                	je     8010378b <kill+0x1e>
      release(&ptable.lock);
801037b0:	83 ec 0c             	sub    $0xc,%esp
801037b3:	68 20 1d 11 80       	push   $0x80111d20
801037b8:	e8 7b 03 00 00       	call   80103b38 <release>
      return 0;
801037bd:	83 c4 10             	add    $0x10,%esp
801037c0:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801037c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801037c8:	c9                   	leave  
801037c9:	c3                   	ret    
  release(&ptable.lock);
801037ca:	83 ec 0c             	sub    $0xc,%esp
801037cd:	68 20 1d 11 80       	push   $0x80111d20
801037d2:	e8 61 03 00 00       	call   80103b38 <release>
  return -1;
801037d7:	83 c4 10             	add    $0x10,%esp
801037da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037df:	eb e4                	jmp    801037c5 <kill+0x58>

801037e1 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801037e1:	55                   	push   %ebp
801037e2:	89 e5                	mov    %esp,%ebp
801037e4:	56                   	push   %esi
801037e5:	53                   	push   %ebx
801037e6:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801037e9:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
801037ee:	eb 33                	jmp    80103823 <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
801037f0:	b8 cb 6d 10 80       	mov    $0x80106dcb,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
801037f5:	8d 53 70             	lea    0x70(%ebx),%edx
801037f8:	52                   	push   %edx
801037f9:	50                   	push   %eax
801037fa:	ff 73 14             	push   0x14(%ebx)
801037fd:	68 cf 6d 10 80       	push   $0x80106dcf
80103802:	e8 d3 cd ff ff       	call   801005da <cprintf>
    if(p->state == SLEEPING){
80103807:	83 c4 10             	add    $0x10,%esp
8010380a:	83 7b 10 02          	cmpl   $0x2,0x10(%ebx)
8010380e:	74 39                	je     80103849 <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103810:	83 ec 0c             	sub    $0xc,%esp
80103813:	68 9c 6f 10 80       	push   $0x80106f9c
80103818:	e8 bd cd ff ff       	call   801005da <cprintf>
8010381d:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103820:	83 eb 80             	sub    $0xffffff80,%ebx
80103823:	81 fb 54 3d 11 80    	cmp    $0x80113d54,%ebx
80103829:	73 5f                	jae    8010388a <procdump+0xa9>
    if(p->state == UNUSED)
8010382b:	8b 43 10             	mov    0x10(%ebx),%eax
8010382e:	85 c0                	test   %eax,%eax
80103830:	74 ee                	je     80103820 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103832:	83 f8 05             	cmp    $0x5,%eax
80103835:	77 b9                	ja     801037f0 <procdump+0xf>
80103837:	8b 04 85 2c 6e 10 80 	mov    -0x7fef91d4(,%eax,4),%eax
8010383e:	85 c0                	test   %eax,%eax
80103840:	75 b3                	jne    801037f5 <procdump+0x14>
      state = "???";
80103842:	b8 cb 6d 10 80       	mov    $0x80106dcb,%eax
80103847:	eb ac                	jmp    801037f5 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103849:	8b 43 20             	mov    0x20(%ebx),%eax
8010384c:	8b 40 0c             	mov    0xc(%eax),%eax
8010384f:	83 c0 08             	add    $0x8,%eax
80103852:	83 ec 08             	sub    $0x8,%esp
80103855:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103858:	52                   	push   %edx
80103859:	50                   	push   %eax
8010385a:	e8 58 01 00 00       	call   801039b7 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
8010385f:	83 c4 10             	add    $0x10,%esp
80103862:	be 00 00 00 00       	mov    $0x0,%esi
80103867:	eb 12                	jmp    8010387b <procdump+0x9a>
        cprintf(" %p", pc[i]);
80103869:	83 ec 08             	sub    $0x8,%esp
8010386c:	50                   	push   %eax
8010386d:	68 21 68 10 80       	push   $0x80106821
80103872:	e8 63 cd ff ff       	call   801005da <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103877:	46                   	inc    %esi
80103878:	83 c4 10             	add    $0x10,%esp
8010387b:	83 fe 09             	cmp    $0x9,%esi
8010387e:	7f 90                	jg     80103810 <procdump+0x2f>
80103880:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103884:	85 c0                	test   %eax,%eax
80103886:	75 e1                	jne    80103869 <procdump+0x88>
80103888:	eb 86                	jmp    80103810 <procdump+0x2f>
  }
}
8010388a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010388d:	5b                   	pop    %ebx
8010388e:	5e                   	pop    %esi
8010388f:	5d                   	pop    %ebp
80103890:	c3                   	ret    

80103891 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103891:	55                   	push   %ebp
80103892:	89 e5                	mov    %esp,%ebp
80103894:	53                   	push   %ebx
80103895:	83 ec 0c             	sub    $0xc,%esp
80103898:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
8010389b:	68 44 6e 10 80       	push   $0x80106e44
801038a0:	8d 43 04             	lea    0x4(%ebx),%eax
801038a3:	50                   	push   %eax
801038a4:	e8 f3 00 00 00       	call   8010399c <initlock>
  lk->name = name;
801038a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801038ac:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
801038af:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
801038b5:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
801038bc:	83 c4 10             	add    $0x10,%esp
801038bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038c2:	c9                   	leave  
801038c3:	c3                   	ret    

801038c4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801038c4:	55                   	push   %ebp
801038c5:	89 e5                	mov    %esp,%ebp
801038c7:	56                   	push   %esi
801038c8:	53                   	push   %ebx
801038c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801038cc:	8d 73 04             	lea    0x4(%ebx),%esi
801038cf:	83 ec 0c             	sub    $0xc,%esp
801038d2:	56                   	push   %esi
801038d3:	e8 fb 01 00 00       	call   80103ad3 <acquire>
  while (lk->locked) {
801038d8:	83 c4 10             	add    $0x10,%esp
801038db:	eb 0d                	jmp    801038ea <acquiresleep+0x26>
    sleep(lk, &lk->lk);
801038dd:	83 ec 08             	sub    $0x8,%esp
801038e0:	56                   	push   %esi
801038e1:	53                   	push   %ebx
801038e2:	e8 ea fc ff ff       	call   801035d1 <sleep>
801038e7:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801038ea:	83 3b 00             	cmpl   $0x0,(%ebx)
801038ed:	75 ee                	jne    801038dd <acquiresleep+0x19>
  }
  lk->locked = 1;
801038ef:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
801038f5:	e8 20 f8 ff ff       	call   8010311a <myproc>
801038fa:	8b 40 14             	mov    0x14(%eax),%eax
801038fd:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103900:	83 ec 0c             	sub    $0xc,%esp
80103903:	56                   	push   %esi
80103904:	e8 2f 02 00 00       	call   80103b38 <release>
}
80103909:	83 c4 10             	add    $0x10,%esp
8010390c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010390f:	5b                   	pop    %ebx
80103910:	5e                   	pop    %esi
80103911:	5d                   	pop    %ebp
80103912:	c3                   	ret    

80103913 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103913:	55                   	push   %ebp
80103914:	89 e5                	mov    %esp,%ebp
80103916:	56                   	push   %esi
80103917:	53                   	push   %ebx
80103918:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
8010391b:	8d 73 04             	lea    0x4(%ebx),%esi
8010391e:	83 ec 0c             	sub    $0xc,%esp
80103921:	56                   	push   %esi
80103922:	e8 ac 01 00 00       	call   80103ad3 <acquire>
  lk->locked = 0;
80103927:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
8010392d:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103934:	89 1c 24             	mov    %ebx,(%esp)
80103937:	e8 08 fe ff ff       	call   80103744 <wakeup>
  release(&lk->lk);
8010393c:	89 34 24             	mov    %esi,(%esp)
8010393f:	e8 f4 01 00 00       	call   80103b38 <release>
}
80103944:	83 c4 10             	add    $0x10,%esp
80103947:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010394a:	5b                   	pop    %ebx
8010394b:	5e                   	pop    %esi
8010394c:	5d                   	pop    %ebp
8010394d:	c3                   	ret    

8010394e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010394e:	55                   	push   %ebp
8010394f:	89 e5                	mov    %esp,%ebp
80103951:	56                   	push   %esi
80103952:	53                   	push   %ebx
80103953:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103956:	8d 73 04             	lea    0x4(%ebx),%esi
80103959:	83 ec 0c             	sub    $0xc,%esp
8010395c:	56                   	push   %esi
8010395d:	e8 71 01 00 00       	call   80103ad3 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103962:	83 c4 10             	add    $0x10,%esp
80103965:	83 3b 00             	cmpl   $0x0,(%ebx)
80103968:	75 17                	jne    80103981 <holdingsleep+0x33>
8010396a:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
8010396f:	83 ec 0c             	sub    $0xc,%esp
80103972:	56                   	push   %esi
80103973:	e8 c0 01 00 00       	call   80103b38 <release>
  return r;
}
80103978:	89 d8                	mov    %ebx,%eax
8010397a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010397d:	5b                   	pop    %ebx
8010397e:	5e                   	pop    %esi
8010397f:	5d                   	pop    %ebp
80103980:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103981:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103984:	e8 91 f7 ff ff       	call   8010311a <myproc>
80103989:	3b 58 14             	cmp    0x14(%eax),%ebx
8010398c:	74 07                	je     80103995 <holdingsleep+0x47>
8010398e:	bb 00 00 00 00       	mov    $0x0,%ebx
80103993:	eb da                	jmp    8010396f <holdingsleep+0x21>
80103995:	bb 01 00 00 00       	mov    $0x1,%ebx
8010399a:	eb d3                	jmp    8010396f <holdingsleep+0x21>

8010399c <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010399c:	55                   	push   %ebp
8010399d:	89 e5                	mov    %esp,%ebp
8010399f:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
801039a2:	8b 55 0c             	mov    0xc(%ebp),%edx
801039a5:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801039a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801039ae:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801039b5:	5d                   	pop    %ebp
801039b6:	c3                   	ret    

801039b7 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801039b7:	55                   	push   %ebp
801039b8:	89 e5                	mov    %esp,%ebp
801039ba:	53                   	push   %ebx
801039bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801039be:	8b 45 08             	mov    0x8(%ebp),%eax
801039c1:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
801039c4:	b8 00 00 00 00       	mov    $0x0,%eax
801039c9:	83 f8 09             	cmp    $0x9,%eax
801039cc:	7f 21                	jg     801039ef <getcallerpcs+0x38>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801039ce:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
801039d4:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
801039da:	77 13                	ja     801039ef <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
801039dc:	8b 5a 04             	mov    0x4(%edx),%ebx
801039df:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
801039e2:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
801039e4:	40                   	inc    %eax
801039e5:	eb e2                	jmp    801039c9 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
801039e7:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
801039ee:	40                   	inc    %eax
801039ef:	83 f8 09             	cmp    $0x9,%eax
801039f2:	7e f3                	jle    801039e7 <getcallerpcs+0x30>
}
801039f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039f7:	c9                   	leave  
801039f8:	c3                   	ret    

801039f9 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801039f9:	55                   	push   %ebp
801039fa:	89 e5                	mov    %esp,%ebp
801039fc:	53                   	push   %ebx
801039fd:	83 ec 04             	sub    $0x4,%esp
80103a00:	9c                   	pushf  
80103a01:	5b                   	pop    %ebx
  asm volatile("cli");
80103a02:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103a03:	e8 7d f6 ff ff       	call   80103085 <mycpu>
80103a08:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103a0f:	74 10                	je     80103a21 <pushcli+0x28>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103a11:	e8 6f f6 ff ff       	call   80103085 <mycpu>
80103a16:	ff 80 a4 00 00 00    	incl   0xa4(%eax)
}
80103a1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a1f:	c9                   	leave  
80103a20:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103a21:	e8 5f f6 ff ff       	call   80103085 <mycpu>
80103a26:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103a2c:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103a32:	eb dd                	jmp    80103a11 <pushcli+0x18>

80103a34 <popcli>:

void
popcli(void)
{
80103a34:	55                   	push   %ebp
80103a35:	89 e5                	mov    %esp,%ebp
80103a37:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103a3a:	9c                   	pushf  
80103a3b:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103a3c:	f6 c4 02             	test   $0x2,%ah
80103a3f:	75 28                	jne    80103a69 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103a41:	e8 3f f6 ff ff       	call   80103085 <mycpu>
80103a46:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103a4c:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103a4f:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103a55:	85 d2                	test   %edx,%edx
80103a57:	78 1d                	js     80103a76 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103a59:	e8 27 f6 ff ff       	call   80103085 <mycpu>
80103a5e:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103a65:	74 1c                	je     80103a83 <popcli+0x4f>
    sti();
}
80103a67:	c9                   	leave  
80103a68:	c3                   	ret    
    panic("popcli - interruptible");
80103a69:	83 ec 0c             	sub    $0xc,%esp
80103a6c:	68 4f 6e 10 80       	push   $0x80106e4f
80103a71:	e8 cb c8 ff ff       	call   80100341 <panic>
    panic("popcli");
80103a76:	83 ec 0c             	sub    $0xc,%esp
80103a79:	68 66 6e 10 80       	push   $0x80106e66
80103a7e:	e8 be c8 ff ff       	call   80100341 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103a83:	e8 fd f5 ff ff       	call   80103085 <mycpu>
80103a88:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103a8f:	74 d6                	je     80103a67 <popcli+0x33>
  asm volatile("sti");
80103a91:	fb                   	sti    
}
80103a92:	eb d3                	jmp    80103a67 <popcli+0x33>

80103a94 <holding>:
{
80103a94:	55                   	push   %ebp
80103a95:	89 e5                	mov    %esp,%ebp
80103a97:	53                   	push   %ebx
80103a98:	83 ec 04             	sub    $0x4,%esp
80103a9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103a9e:	e8 56 ff ff ff       	call   801039f9 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103aa3:	83 3b 00             	cmpl   $0x0,(%ebx)
80103aa6:	75 11                	jne    80103ab9 <holding+0x25>
80103aa8:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103aad:	e8 82 ff ff ff       	call   80103a34 <popcli>
}
80103ab2:	89 d8                	mov    %ebx,%eax
80103ab4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103ab7:	c9                   	leave  
80103ab8:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103ab9:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103abc:	e8 c4 f5 ff ff       	call   80103085 <mycpu>
80103ac1:	39 c3                	cmp    %eax,%ebx
80103ac3:	74 07                	je     80103acc <holding+0x38>
80103ac5:	bb 00 00 00 00       	mov    $0x0,%ebx
80103aca:	eb e1                	jmp    80103aad <holding+0x19>
80103acc:	bb 01 00 00 00       	mov    $0x1,%ebx
80103ad1:	eb da                	jmp    80103aad <holding+0x19>

80103ad3 <acquire>:
{
80103ad3:	55                   	push   %ebp
80103ad4:	89 e5                	mov    %esp,%ebp
80103ad6:	53                   	push   %ebx
80103ad7:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103ada:	e8 1a ff ff ff       	call   801039f9 <pushcli>
  if(holding(lk))
80103adf:	83 ec 0c             	sub    $0xc,%esp
80103ae2:	ff 75 08             	push   0x8(%ebp)
80103ae5:	e8 aa ff ff ff       	call   80103a94 <holding>
80103aea:	83 c4 10             	add    $0x10,%esp
80103aed:	85 c0                	test   %eax,%eax
80103aef:	75 3a                	jne    80103b2b <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103af1:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103af4:	b8 01 00 00 00       	mov    $0x1,%eax
80103af9:	f0 87 02             	lock xchg %eax,(%edx)
80103afc:	85 c0                	test   %eax,%eax
80103afe:	75 f1                	jne    80103af1 <acquire+0x1e>
  __sync_synchronize();
80103b00:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103b05:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103b08:	e8 78 f5 ff ff       	call   80103085 <mycpu>
80103b0d:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103b10:	8b 45 08             	mov    0x8(%ebp),%eax
80103b13:	83 c0 0c             	add    $0xc,%eax
80103b16:	83 ec 08             	sub    $0x8,%esp
80103b19:	50                   	push   %eax
80103b1a:	8d 45 08             	lea    0x8(%ebp),%eax
80103b1d:	50                   	push   %eax
80103b1e:	e8 94 fe ff ff       	call   801039b7 <getcallerpcs>
}
80103b23:	83 c4 10             	add    $0x10,%esp
80103b26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b29:	c9                   	leave  
80103b2a:	c3                   	ret    
    panic("acquire");
80103b2b:	83 ec 0c             	sub    $0xc,%esp
80103b2e:	68 6d 6e 10 80       	push   $0x80106e6d
80103b33:	e8 09 c8 ff ff       	call   80100341 <panic>

80103b38 <release>:
{
80103b38:	55                   	push   %ebp
80103b39:	89 e5                	mov    %esp,%ebp
80103b3b:	53                   	push   %ebx
80103b3c:	83 ec 10             	sub    $0x10,%esp
80103b3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103b42:	53                   	push   %ebx
80103b43:	e8 4c ff ff ff       	call   80103a94 <holding>
80103b48:	83 c4 10             	add    $0x10,%esp
80103b4b:	85 c0                	test   %eax,%eax
80103b4d:	74 23                	je     80103b72 <release+0x3a>
  lk->pcs[0] = 0;
80103b4f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103b56:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103b5d:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103b62:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103b68:	e8 c7 fe ff ff       	call   80103a34 <popcli>
}
80103b6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b70:	c9                   	leave  
80103b71:	c3                   	ret    
    panic("release");
80103b72:	83 ec 0c             	sub    $0xc,%esp
80103b75:	68 75 6e 10 80       	push   $0x80106e75
80103b7a:	e8 c2 c7 ff ff       	call   80100341 <panic>

80103b7f <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103b7f:	55                   	push   %ebp
80103b80:	89 e5                	mov    %esp,%ebp
80103b82:	57                   	push   %edi
80103b83:	53                   	push   %ebx
80103b84:	8b 55 08             	mov    0x8(%ebp),%edx
80103b87:	8b 45 0c             	mov    0xc(%ebp),%eax
  if ((int)dst%4 == 0 && n%4 == 0){
80103b8a:	f6 c2 03             	test   $0x3,%dl
80103b8d:	75 29                	jne    80103bb8 <memset+0x39>
80103b8f:	f6 45 10 03          	testb  $0x3,0x10(%ebp)
80103b93:	75 23                	jne    80103bb8 <memset+0x39>
    c &= 0xFF;
80103b95:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103b98:	8b 4d 10             	mov    0x10(%ebp),%ecx
80103b9b:	c1 e9 02             	shr    $0x2,%ecx
80103b9e:	c1 e0 18             	shl    $0x18,%eax
80103ba1:	89 fb                	mov    %edi,%ebx
80103ba3:	c1 e3 10             	shl    $0x10,%ebx
80103ba6:	09 d8                	or     %ebx,%eax
80103ba8:	89 fb                	mov    %edi,%ebx
80103baa:	c1 e3 08             	shl    $0x8,%ebx
80103bad:	09 d8                	or     %ebx,%eax
80103baf:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103bb1:	89 d7                	mov    %edx,%edi
80103bb3:	fc                   	cld    
80103bb4:	f3 ab                	rep stos %eax,%es:(%edi)
}
80103bb6:	eb 08                	jmp    80103bc0 <memset+0x41>
  asm volatile("cld; rep stosb" :
80103bb8:	89 d7                	mov    %edx,%edi
80103bba:	8b 4d 10             	mov    0x10(%ebp),%ecx
80103bbd:	fc                   	cld    
80103bbe:	f3 aa                	rep stos %al,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80103bc0:	89 d0                	mov    %edx,%eax
80103bc2:	5b                   	pop    %ebx
80103bc3:	5f                   	pop    %edi
80103bc4:	5d                   	pop    %ebp
80103bc5:	c3                   	ret    

80103bc6 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103bc6:	55                   	push   %ebp
80103bc7:	89 e5                	mov    %esp,%ebp
80103bc9:	56                   	push   %esi
80103bca:	53                   	push   %ebx
80103bcb:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103bce:	8b 55 0c             	mov    0xc(%ebp),%edx
80103bd1:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103bd4:	eb 04                	jmp    80103bda <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80103bd6:	41                   	inc    %ecx
80103bd7:	42                   	inc    %edx
  while(n-- > 0){
80103bd8:	89 f0                	mov    %esi,%eax
80103bda:	8d 70 ff             	lea    -0x1(%eax),%esi
80103bdd:	85 c0                	test   %eax,%eax
80103bdf:	74 10                	je     80103bf1 <memcmp+0x2b>
    if(*s1 != *s2)
80103be1:	8a 01                	mov    (%ecx),%al
80103be3:	8a 1a                	mov    (%edx),%bl
80103be5:	38 d8                	cmp    %bl,%al
80103be7:	74 ed                	je     80103bd6 <memcmp+0x10>
      return *s1 - *s2;
80103be9:	0f b6 c0             	movzbl %al,%eax
80103bec:	0f b6 db             	movzbl %bl,%ebx
80103bef:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103bf1:	5b                   	pop    %ebx
80103bf2:	5e                   	pop    %esi
80103bf3:	5d                   	pop    %ebp
80103bf4:	c3                   	ret    

80103bf5 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103bf5:	55                   	push   %ebp
80103bf6:	89 e5                	mov    %esp,%ebp
80103bf8:	56                   	push   %esi
80103bf9:	53                   	push   %ebx
80103bfa:	8b 75 08             	mov    0x8(%ebp),%esi
80103bfd:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c00:	8b 45 10             	mov    0x10(%ebp),%eax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103c03:	39 f2                	cmp    %esi,%edx
80103c05:	73 36                	jae    80103c3d <memmove+0x48>
80103c07:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80103c0a:	39 f1                	cmp    %esi,%ecx
80103c0c:	76 33                	jbe    80103c41 <memmove+0x4c>
    s += n;
    d += n;
80103c0e:	8d 14 06             	lea    (%esi,%eax,1),%edx
    while(n-- > 0)
80103c11:	eb 08                	jmp    80103c1b <memmove+0x26>
      *--d = *--s;
80103c13:	49                   	dec    %ecx
80103c14:	4a                   	dec    %edx
80103c15:	8a 01                	mov    (%ecx),%al
80103c17:	88 02                	mov    %al,(%edx)
    while(n-- > 0)
80103c19:	89 d8                	mov    %ebx,%eax
80103c1b:	8d 58 ff             	lea    -0x1(%eax),%ebx
80103c1e:	85 c0                	test   %eax,%eax
80103c20:	75 f1                	jne    80103c13 <memmove+0x1e>
80103c22:	eb 13                	jmp    80103c37 <memmove+0x42>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103c24:	8a 02                	mov    (%edx),%al
80103c26:	88 01                	mov    %al,(%ecx)
80103c28:	8d 49 01             	lea    0x1(%ecx),%ecx
80103c2b:	8d 52 01             	lea    0x1(%edx),%edx
    while(n-- > 0)
80103c2e:	89 d8                	mov    %ebx,%eax
80103c30:	8d 58 ff             	lea    -0x1(%eax),%ebx
80103c33:	85 c0                	test   %eax,%eax
80103c35:	75 ed                	jne    80103c24 <memmove+0x2f>

  return dst;
}
80103c37:	89 f0                	mov    %esi,%eax
80103c39:	5b                   	pop    %ebx
80103c3a:	5e                   	pop    %esi
80103c3b:	5d                   	pop    %ebp
80103c3c:	c3                   	ret    
80103c3d:	89 f1                	mov    %esi,%ecx
80103c3f:	eb ef                	jmp    80103c30 <memmove+0x3b>
80103c41:	89 f1                	mov    %esi,%ecx
80103c43:	eb eb                	jmp    80103c30 <memmove+0x3b>

80103c45 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103c45:	55                   	push   %ebp
80103c46:	89 e5                	mov    %esp,%ebp
80103c48:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80103c4b:	ff 75 10             	push   0x10(%ebp)
80103c4e:	ff 75 0c             	push   0xc(%ebp)
80103c51:	ff 75 08             	push   0x8(%ebp)
80103c54:	e8 9c ff ff ff       	call   80103bf5 <memmove>
}
80103c59:	c9                   	leave  
80103c5a:	c3                   	ret    

80103c5b <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103c5b:	55                   	push   %ebp
80103c5c:	89 e5                	mov    %esp,%ebp
80103c5e:	53                   	push   %ebx
80103c5f:	8b 55 08             	mov    0x8(%ebp),%edx
80103c62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103c65:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103c68:	eb 03                	jmp    80103c6d <strncmp+0x12>
    n--, p++, q++;
80103c6a:	48                   	dec    %eax
80103c6b:	42                   	inc    %edx
80103c6c:	41                   	inc    %ecx
  while(n > 0 && *p && *p == *q)
80103c6d:	85 c0                	test   %eax,%eax
80103c6f:	74 0a                	je     80103c7b <strncmp+0x20>
80103c71:	8a 1a                	mov    (%edx),%bl
80103c73:	84 db                	test   %bl,%bl
80103c75:	74 04                	je     80103c7b <strncmp+0x20>
80103c77:	3a 19                	cmp    (%ecx),%bl
80103c79:	74 ef                	je     80103c6a <strncmp+0xf>
  if(n == 0)
80103c7b:	85 c0                	test   %eax,%eax
80103c7d:	74 0d                	je     80103c8c <strncmp+0x31>
    return 0;
  return (uchar)*p - (uchar)*q;
80103c7f:	0f b6 02             	movzbl (%edx),%eax
80103c82:	0f b6 11             	movzbl (%ecx),%edx
80103c85:	29 d0                	sub    %edx,%eax
}
80103c87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c8a:	c9                   	leave  
80103c8b:	c3                   	ret    
    return 0;
80103c8c:	b8 00 00 00 00       	mov    $0x0,%eax
80103c91:	eb f4                	jmp    80103c87 <strncmp+0x2c>

80103c93 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103c93:	55                   	push   %ebp
80103c94:	89 e5                	mov    %esp,%ebp
80103c96:	57                   	push   %edi
80103c97:	56                   	push   %esi
80103c98:	53                   	push   %ebx
80103c99:	8b 45 08             	mov    0x8(%ebp),%eax
80103c9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103c9f:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103ca2:	89 c1                	mov    %eax,%ecx
80103ca4:	eb 04                	jmp    80103caa <strncpy+0x17>
80103ca6:	89 fb                	mov    %edi,%ebx
80103ca8:	89 f1                	mov    %esi,%ecx
80103caa:	89 d6                	mov    %edx,%esi
80103cac:	4a                   	dec    %edx
80103cad:	85 f6                	test   %esi,%esi
80103caf:	7e 10                	jle    80103cc1 <strncpy+0x2e>
80103cb1:	8d 7b 01             	lea    0x1(%ebx),%edi
80103cb4:	8d 71 01             	lea    0x1(%ecx),%esi
80103cb7:	8a 1b                	mov    (%ebx),%bl
80103cb9:	88 19                	mov    %bl,(%ecx)
80103cbb:	84 db                	test   %bl,%bl
80103cbd:	75 e7                	jne    80103ca6 <strncpy+0x13>
80103cbf:	89 f1                	mov    %esi,%ecx
    ;
  while(n-- > 0)
80103cc1:	8d 5a ff             	lea    -0x1(%edx),%ebx
80103cc4:	85 d2                	test   %edx,%edx
80103cc6:	7e 0a                	jle    80103cd2 <strncpy+0x3f>
    *s++ = 0;
80103cc8:	c6 01 00             	movb   $0x0,(%ecx)
  while(n-- > 0)
80103ccb:	89 da                	mov    %ebx,%edx
    *s++ = 0;
80103ccd:	8d 49 01             	lea    0x1(%ecx),%ecx
80103cd0:	eb ef                	jmp    80103cc1 <strncpy+0x2e>
  return os;
}
80103cd2:	5b                   	pop    %ebx
80103cd3:	5e                   	pop    %esi
80103cd4:	5f                   	pop    %edi
80103cd5:	5d                   	pop    %ebp
80103cd6:	c3                   	ret    

80103cd7 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103cd7:	55                   	push   %ebp
80103cd8:	89 e5                	mov    %esp,%ebp
80103cda:	57                   	push   %edi
80103cdb:	56                   	push   %esi
80103cdc:	53                   	push   %ebx
80103cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80103ce0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103ce3:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103ce6:	85 d2                	test   %edx,%edx
80103ce8:	7e 20                	jle    80103d0a <safestrcpy+0x33>
80103cea:	89 c1                	mov    %eax,%ecx
80103cec:	eb 04                	jmp    80103cf2 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103cee:	89 fb                	mov    %edi,%ebx
80103cf0:	89 f1                	mov    %esi,%ecx
80103cf2:	4a                   	dec    %edx
80103cf3:	85 d2                	test   %edx,%edx
80103cf5:	7e 10                	jle    80103d07 <safestrcpy+0x30>
80103cf7:	8d 7b 01             	lea    0x1(%ebx),%edi
80103cfa:	8d 71 01             	lea    0x1(%ecx),%esi
80103cfd:	8a 1b                	mov    (%ebx),%bl
80103cff:	88 19                	mov    %bl,(%ecx)
80103d01:	84 db                	test   %bl,%bl
80103d03:	75 e9                	jne    80103cee <safestrcpy+0x17>
80103d05:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103d07:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103d0a:	5b                   	pop    %ebx
80103d0b:	5e                   	pop    %esi
80103d0c:	5f                   	pop    %edi
80103d0d:	5d                   	pop    %ebp
80103d0e:	c3                   	ret    

80103d0f <strlen>:

int
strlen(const char *s)
{
80103d0f:	55                   	push   %ebp
80103d10:	89 e5                	mov    %esp,%ebp
80103d12:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103d15:	b8 00 00 00 00       	mov    $0x0,%eax
80103d1a:	eb 01                	jmp    80103d1d <strlen+0xe>
80103d1c:	40                   	inc    %eax
80103d1d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103d21:	75 f9                	jne    80103d1c <strlen+0xd>
    ;
  return n;
}
80103d23:	5d                   	pop    %ebp
80103d24:	c3                   	ret    

80103d25 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103d25:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103d29:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103d2d:	55                   	push   %ebp
  pushl %ebx
80103d2e:	53                   	push   %ebx
  pushl %esi
80103d2f:	56                   	push   %esi
  pushl %edi
80103d30:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103d31:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103d33:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103d35:	5f                   	pop    %edi
  popl %esi
80103d36:	5e                   	pop    %esi
  popl %ebx
80103d37:	5b                   	pop    %ebx
  popl %ebp
80103d38:	5d                   	pop    %ebp
  ret
80103d39:	c3                   	ret    

80103d3a <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103d3a:	55                   	push   %ebp
80103d3b:	89 e5                	mov    %esp,%ebp
80103d3d:	53                   	push   %ebx
80103d3e:	83 ec 04             	sub    $0x4,%esp
80103d41:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103d44:	e8 d1 f3 ff ff       	call   8010311a <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103d49:	8b 40 04             	mov    0x4(%eax),%eax
80103d4c:	39 d8                	cmp    %ebx,%eax
80103d4e:	76 18                	jbe    80103d68 <fetchint+0x2e>
80103d50:	8d 53 04             	lea    0x4(%ebx),%edx
80103d53:	39 d0                	cmp    %edx,%eax
80103d55:	72 18                	jb     80103d6f <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103d57:	8b 13                	mov    (%ebx),%edx
80103d59:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d5c:	89 10                	mov    %edx,(%eax)
  return 0;
80103d5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d66:	c9                   	leave  
80103d67:	c3                   	ret    
    return -1;
80103d68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d6d:	eb f4                	jmp    80103d63 <fetchint+0x29>
80103d6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d74:	eb ed                	jmp    80103d63 <fetchint+0x29>

80103d76 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{//va a coger el elemento de la pila  ¡LA PILA ESTÁ EN LA DIRECCIÓN ESP! en el tf
80103d76:	55                   	push   %ebp
80103d77:	89 e5                	mov    %esp,%ebp
80103d79:	53                   	push   %ebx
80103d7a:	83 ec 04             	sub    $0x4,%esp
80103d7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103d80:	e8 95 f3 ff ff       	call   8010311a <myproc>

  if(addr >= curproc->sz)
80103d85:	39 58 04             	cmp    %ebx,0x4(%eax)
80103d88:	76 24                	jbe    80103dae <fetchstr+0x38>
    return -1;
  *pp = (char*)addr;
80103d8a:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d8d:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80103d8f:	8b 50 04             	mov    0x4(%eax),%edx
  for(s = *pp; s < ep; s++){
80103d92:	89 d8                	mov    %ebx,%eax
80103d94:	eb 01                	jmp    80103d97 <fetchstr+0x21>
80103d96:	40                   	inc    %eax
80103d97:	39 d0                	cmp    %edx,%eax
80103d99:	73 09                	jae    80103da4 <fetchstr+0x2e>
    if(*s == 0)
80103d9b:	80 38 00             	cmpb   $0x0,(%eax)
80103d9e:	75 f6                	jne    80103d96 <fetchstr+0x20>
      return s - *pp;
80103da0:	29 d8                	sub    %ebx,%eax
80103da2:	eb 05                	jmp    80103da9 <fetchstr+0x33>
  }
  return -1;
80103da4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103da9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103dac:	c9                   	leave  
80103dad:	c3                   	ret    
    return -1;
80103dae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103db3:	eb f4                	jmp    80103da9 <fetchstr+0x33>

80103db5 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{//n es el numero de argumento que queremos recuperar. ip es donde lo vamos a guardar
80103db5:	55                   	push   %ebp
80103db6:	89 e5                	mov    %esp,%ebp
80103db8:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80103dbb:	e8 5a f3 ff ff       	call   8010311a <myproc>
80103dc0:	8b 50 1c             	mov    0x1c(%eax),%edx
80103dc3:	8b 45 08             	mov    0x8(%ebp),%eax
80103dc6:	c1 e0 02             	shl    $0x2,%eax
80103dc9:	03 42 44             	add    0x44(%edx),%eax
80103dcc:	83 ec 08             	sub    $0x8,%esp
80103dcf:	ff 75 0c             	push   0xc(%ebp)
80103dd2:	83 c0 04             	add    $0x4,%eax
80103dd5:	50                   	push   %eax
80103dd6:	e8 5f ff ff ff       	call   80103d3a <fetchint>
}
80103ddb:	c9                   	leave  
80103ddc:	c3                   	ret    

80103ddd <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, void **pp, int size)
{
80103ddd:	55                   	push   %ebp
80103dde:	89 e5                	mov    %esp,%ebp
80103de0:	56                   	push   %esi
80103de1:	53                   	push   %ebx
80103de2:	83 ec 10             	sub    $0x10,%esp
80103de5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80103de8:	e8 2d f3 ff ff       	call   8010311a <myproc>
80103ded:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80103def:	83 ec 08             	sub    $0x8,%esp
80103df2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103df5:	50                   	push   %eax
80103df6:	ff 75 08             	push   0x8(%ebp)
80103df9:	e8 b7 ff ff ff       	call   80103db5 <argint>
80103dfe:	83 c4 10             	add    $0x10,%esp
80103e01:	85 c0                	test   %eax,%eax
80103e03:	78 25                	js     80103e2a <argptr+0x4d>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80103e05:	85 db                	test   %ebx,%ebx
80103e07:	78 28                	js     80103e31 <argptr+0x54>
80103e09:	8b 56 04             	mov    0x4(%esi),%edx
80103e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e0f:	39 c2                	cmp    %eax,%edx
80103e11:	76 25                	jbe    80103e38 <argptr+0x5b>
80103e13:	01 c3                	add    %eax,%ebx
80103e15:	39 da                	cmp    %ebx,%edx
80103e17:	72 26                	jb     80103e3f <argptr+0x62>
    return -1;
  *pp = (void*)i;
80103e19:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e1c:	89 02                	mov    %eax,(%edx)
  return 0;
80103e1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103e23:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103e26:	5b                   	pop    %ebx
80103e27:	5e                   	pop    %esi
80103e28:	5d                   	pop    %ebp
80103e29:	c3                   	ret    
    return -1;
80103e2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e2f:	eb f2                	jmp    80103e23 <argptr+0x46>
    return -1;
80103e31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e36:	eb eb                	jmp    80103e23 <argptr+0x46>
80103e38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e3d:	eb e4                	jmp    80103e23 <argptr+0x46>
80103e3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e44:	eb dd                	jmp    80103e23 <argptr+0x46>

80103e46 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80103e46:	55                   	push   %ebp
80103e47:	89 e5                	mov    %esp,%ebp
80103e49:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80103e4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103e4f:	50                   	push   %eax
80103e50:	ff 75 08             	push   0x8(%ebp)
80103e53:	e8 5d ff ff ff       	call   80103db5 <argint>
80103e58:	83 c4 10             	add    $0x10,%esp
80103e5b:	85 c0                	test   %eax,%eax
80103e5d:	78 13                	js     80103e72 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
80103e5f:	83 ec 08             	sub    $0x8,%esp
80103e62:	ff 75 0c             	push   0xc(%ebp)
80103e65:	ff 75 f4             	push   -0xc(%ebp)
80103e68:	e8 09 ff ff ff       	call   80103d76 <fetchstr>
80103e6d:	83 c4 10             	add    $0x10,%esp
}
80103e70:	c9                   	leave  
80103e71:	c3                   	ret    
    return -1;
80103e72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e77:	eb f7                	jmp    80103e70 <argstr+0x2a>

80103e79 <syscall>:
[SYS_dup2]    sys_dup2,
};

void
syscall(void)
{
80103e79:	55                   	push   %ebp
80103e7a:	89 e5                	mov    %esp,%ebp
80103e7c:	53                   	push   %ebx
80103e7d:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80103e80:	e8 95 f2 ff ff       	call   8010311a <myproc>
80103e85:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80103e87:	8b 40 1c             	mov    0x1c(%eax),%eax
80103e8a:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80103e8d:	8d 50 ff             	lea    -0x1(%eax),%edx
80103e90:	83 fa 16             	cmp    $0x16,%edx
80103e93:	77 17                	ja     80103eac <syscall+0x33>
80103e95:	8b 14 85 a0 6e 10 80 	mov    -0x7fef9160(,%eax,4),%edx
80103e9c:	85 d2                	test   %edx,%edx
80103e9e:	74 0c                	je     80103eac <syscall+0x33>
    curproc->tf->eax = syscalls[num]();
80103ea0:	ff d2                	call   *%edx
80103ea2:	89 c2                	mov    %eax,%edx
80103ea4:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103ea7:	89 50 1c             	mov    %edx,0x1c(%eax)
80103eaa:	eb 1f                	jmp    80103ecb <syscall+0x52>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80103eac:	8d 53 70             	lea    0x70(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80103eaf:	50                   	push   %eax
80103eb0:	52                   	push   %edx
80103eb1:	ff 73 14             	push   0x14(%ebx)
80103eb4:	68 7d 6e 10 80       	push   $0x80106e7d
80103eb9:	e8 1c c7 ff ff       	call   801005da <cprintf>
    curproc->tf->eax = -1;
80103ebe:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103ec1:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80103ec8:	83 c4 10             	add    $0x10,%esp
  }
}
80103ecb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103ece:	c9                   	leave  
80103ecf:	c3                   	ret    

80103ed0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80103ed0:	55                   	push   %ebp
80103ed1:	89 e5                	mov    %esp,%ebp
80103ed3:	56                   	push   %esi
80103ed4:	53                   	push   %ebx
80103ed5:	83 ec 18             	sub    $0x18,%esp
80103ed8:	89 d6                	mov    %edx,%esi
80103eda:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80103edc:	8d 55 f4             	lea    -0xc(%ebp),%edx
80103edf:	52                   	push   %edx
80103ee0:	50                   	push   %eax
80103ee1:	e8 cf fe ff ff       	call   80103db5 <argint>
80103ee6:	83 c4 10             	add    $0x10,%esp
80103ee9:	85 c0                	test   %eax,%eax
80103eeb:	78 35                	js     80103f22 <argfd+0x52>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80103eed:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80103ef1:	77 28                	ja     80103f1b <argfd+0x4b>
80103ef3:	e8 22 f2 ff ff       	call   8010311a <myproc>
80103ef8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103efb:	8b 44 90 2c          	mov    0x2c(%eax,%edx,4),%eax
80103eff:	85 c0                	test   %eax,%eax
80103f01:	74 18                	je     80103f1b <argfd+0x4b>
    return -1;
  if(pfd)
80103f03:	85 f6                	test   %esi,%esi
80103f05:	74 02                	je     80103f09 <argfd+0x39>
    *pfd = fd;
80103f07:	89 16                	mov    %edx,(%esi)
  if(pf)
80103f09:	85 db                	test   %ebx,%ebx
80103f0b:	74 1c                	je     80103f29 <argfd+0x59>
    *pf = f;
80103f0d:	89 03                	mov    %eax,(%ebx)
  return 0;
80103f0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f14:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103f17:	5b                   	pop    %ebx
80103f18:	5e                   	pop    %esi
80103f19:	5d                   	pop    %ebp
80103f1a:	c3                   	ret    
    return -1;
80103f1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f20:	eb f2                	jmp    80103f14 <argfd+0x44>
    return -1;
80103f22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f27:	eb eb                	jmp    80103f14 <argfd+0x44>
  return 0;
80103f29:	b8 00 00 00 00       	mov    $0x0,%eax
80103f2e:	eb e4                	jmp    80103f14 <argfd+0x44>

80103f30 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80103f30:	55                   	push   %ebp
80103f31:	89 e5                	mov    %esp,%ebp
80103f33:	53                   	push   %ebx
80103f34:	83 ec 04             	sub    $0x4,%esp
80103f37:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
80103f39:	e8 dc f1 ff ff       	call   8010311a <myproc>
80103f3e:	89 c2                	mov    %eax,%edx

  for(fd = 0; fd < NOFILE; fd++){
80103f40:	b8 00 00 00 00       	mov    $0x0,%eax
80103f45:	83 f8 0f             	cmp    $0xf,%eax
80103f48:	7f 10                	jg     80103f5a <fdalloc+0x2a>
    if(curproc->ofile[fd] == 0){
80103f4a:	83 7c 82 2c 00       	cmpl   $0x0,0x2c(%edx,%eax,4)
80103f4f:	74 03                	je     80103f54 <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
80103f51:	40                   	inc    %eax
80103f52:	eb f1                	jmp    80103f45 <fdalloc+0x15>
      curproc->ofile[fd] = f;
80103f54:	89 5c 82 2c          	mov    %ebx,0x2c(%edx,%eax,4)
      return fd;
80103f58:	eb 05                	jmp    80103f5f <fdalloc+0x2f>
    }
  }
  return -1;
80103f5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103f62:	c9                   	leave  
80103f63:	c3                   	ret    

80103f64 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80103f64:	55                   	push   %ebp
80103f65:	89 e5                	mov    %esp,%ebp
80103f67:	56                   	push   %esi
80103f68:	53                   	push   %ebx
80103f69:	83 ec 10             	sub    $0x10,%esp
80103f6c:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80103f6e:	b8 20 00 00 00       	mov    $0x20,%eax
80103f73:	89 c6                	mov    %eax,%esi
80103f75:	39 43 58             	cmp    %eax,0x58(%ebx)
80103f78:	76 2e                	jbe    80103fa8 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80103f7a:	6a 10                	push   $0x10
80103f7c:	50                   	push   %eax
80103f7d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103f80:	50                   	push   %eax
80103f81:	53                   	push   %ebx
80103f82:	e8 6d d7 ff ff       	call   801016f4 <readi>
80103f87:	83 c4 10             	add    $0x10,%esp
80103f8a:	83 f8 10             	cmp    $0x10,%eax
80103f8d:	75 0c                	jne    80103f9b <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
80103f8f:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
80103f94:	75 1e                	jne    80103fb4 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80103f96:	8d 46 10             	lea    0x10(%esi),%eax
80103f99:	eb d8                	jmp    80103f73 <isdirempty+0xf>
      panic("isdirempty: readi");
80103f9b:	83 ec 0c             	sub    $0xc,%esp
80103f9e:	68 00 6f 10 80       	push   $0x80106f00
80103fa3:	e8 99 c3 ff ff       	call   80100341 <panic>
      return 0;
  }
  return 1;
80103fa8:	b8 01 00 00 00       	mov    $0x1,%eax
}
80103fad:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103fb0:	5b                   	pop    %ebx
80103fb1:	5e                   	pop    %esi
80103fb2:	5d                   	pop    %ebp
80103fb3:	c3                   	ret    
      return 0;
80103fb4:	b8 00 00 00 00       	mov    $0x0,%eax
80103fb9:	eb f2                	jmp    80103fad <isdirempty+0x49>

80103fbb <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80103fbb:	55                   	push   %ebp
80103fbc:	89 e5                	mov    %esp,%ebp
80103fbe:	57                   	push   %edi
80103fbf:	56                   	push   %esi
80103fc0:	53                   	push   %ebx
80103fc1:	83 ec 44             	sub    $0x44,%esp
80103fc4:	89 d7                	mov    %edx,%edi
80103fc6:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
80103fc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103fcc:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80103fcf:	8d 55 d6             	lea    -0x2a(%ebp),%edx
80103fd2:	52                   	push   %edx
80103fd3:	50                   	push   %eax
80103fd4:	e8 aa db ff ff       	call   80101b83 <nameiparent>
80103fd9:	89 c6                	mov    %eax,%esi
80103fdb:	83 c4 10             	add    $0x10,%esp
80103fde:	85 c0                	test   %eax,%eax
80103fe0:	0f 84 32 01 00 00    	je     80104118 <create+0x15d>
    return 0;
  ilock(dp);
80103fe6:	83 ec 0c             	sub    $0xc,%esp
80103fe9:	50                   	push   %eax
80103fea:	e8 18 d5 ff ff       	call   80101507 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80103fef:	83 c4 0c             	add    $0xc,%esp
80103ff2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80103ff5:	50                   	push   %eax
80103ff6:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80103ff9:	50                   	push   %eax
80103ffa:	56                   	push   %esi
80103ffb:	e8 3d d9 ff ff       	call   8010193d <dirlookup>
80104000:	89 c3                	mov    %eax,%ebx
80104002:	83 c4 10             	add    $0x10,%esp
80104005:	85 c0                	test   %eax,%eax
80104007:	74 3c                	je     80104045 <create+0x8a>
    iunlockput(dp);
80104009:	83 ec 0c             	sub    $0xc,%esp
8010400c:	56                   	push   %esi
8010400d:	e8 98 d6 ff ff       	call   801016aa <iunlockput>
    ilock(ip);
80104012:	89 1c 24             	mov    %ebx,(%esp)
80104015:	e8 ed d4 ff ff       	call   80101507 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
8010401a:	83 c4 10             	add    $0x10,%esp
8010401d:	66 83 ff 02          	cmp    $0x2,%di
80104021:	75 07                	jne    8010402a <create+0x6f>
80104023:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
80104028:	74 11                	je     8010403b <create+0x80>
      return ip;
    iunlockput(ip);
8010402a:	83 ec 0c             	sub    $0xc,%esp
8010402d:	53                   	push   %ebx
8010402e:	e8 77 d6 ff ff       	call   801016aa <iunlockput>
    return 0;
80104033:	83 c4 10             	add    $0x10,%esp
80104036:	bb 00 00 00 00       	mov    $0x0,%ebx
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
8010403b:	89 d8                	mov    %ebx,%eax
8010403d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104040:	5b                   	pop    %ebx
80104041:	5e                   	pop    %esi
80104042:	5f                   	pop    %edi
80104043:	5d                   	pop    %ebp
80104044:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
80104045:	83 ec 08             	sub    $0x8,%esp
80104048:	0f bf c7             	movswl %di,%eax
8010404b:	50                   	push   %eax
8010404c:	ff 36                	push   (%esi)
8010404e:	e8 bc d2 ff ff       	call   8010130f <ialloc>
80104053:	89 c3                	mov    %eax,%ebx
80104055:	83 c4 10             	add    $0x10,%esp
80104058:	85 c0                	test   %eax,%eax
8010405a:	74 53                	je     801040af <create+0xf4>
  ilock(ip);
8010405c:	83 ec 0c             	sub    $0xc,%esp
8010405f:	50                   	push   %eax
80104060:	e8 a2 d4 ff ff       	call   80101507 <ilock>
  ip->major = major;
80104065:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80104068:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
8010406c:	8b 45 c0             	mov    -0x40(%ebp),%eax
8010406f:	66 89 43 54          	mov    %ax,0x54(%ebx)
  ip->nlink = 1;
80104073:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104079:	89 1c 24             	mov    %ebx,(%esp)
8010407c:	e8 2d d3 ff ff       	call   801013ae <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104081:	83 c4 10             	add    $0x10,%esp
80104084:	66 83 ff 01          	cmp    $0x1,%di
80104088:	74 32                	je     801040bc <create+0x101>
  if(dirlink(dp, name, ip->inum) < 0)
8010408a:	83 ec 04             	sub    $0x4,%esp
8010408d:	ff 73 04             	push   0x4(%ebx)
80104090:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104093:	50                   	push   %eax
80104094:	56                   	push   %esi
80104095:	e8 20 da ff ff       	call   80101aba <dirlink>
8010409a:	83 c4 10             	add    $0x10,%esp
8010409d:	85 c0                	test   %eax,%eax
8010409f:	78 6a                	js     8010410b <create+0x150>
  iunlockput(dp);
801040a1:	83 ec 0c             	sub    $0xc,%esp
801040a4:	56                   	push   %esi
801040a5:	e8 00 d6 ff ff       	call   801016aa <iunlockput>
  return ip;
801040aa:	83 c4 10             	add    $0x10,%esp
801040ad:	eb 8c                	jmp    8010403b <create+0x80>
    panic("create: ialloc");
801040af:	83 ec 0c             	sub    $0xc,%esp
801040b2:	68 12 6f 10 80       	push   $0x80106f12
801040b7:	e8 85 c2 ff ff       	call   80100341 <panic>
    dp->nlink++;  // for ".."
801040bc:	66 8b 46 56          	mov    0x56(%esi),%ax
801040c0:	40                   	inc    %eax
801040c1:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
801040c5:	83 ec 0c             	sub    $0xc,%esp
801040c8:	56                   	push   %esi
801040c9:	e8 e0 d2 ff ff       	call   801013ae <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801040ce:	83 c4 0c             	add    $0xc,%esp
801040d1:	ff 73 04             	push   0x4(%ebx)
801040d4:	68 22 6f 10 80       	push   $0x80106f22
801040d9:	53                   	push   %ebx
801040da:	e8 db d9 ff ff       	call   80101aba <dirlink>
801040df:	83 c4 10             	add    $0x10,%esp
801040e2:	85 c0                	test   %eax,%eax
801040e4:	78 18                	js     801040fe <create+0x143>
801040e6:	83 ec 04             	sub    $0x4,%esp
801040e9:	ff 76 04             	push   0x4(%esi)
801040ec:	68 21 6f 10 80       	push   $0x80106f21
801040f1:	53                   	push   %ebx
801040f2:	e8 c3 d9 ff ff       	call   80101aba <dirlink>
801040f7:	83 c4 10             	add    $0x10,%esp
801040fa:	85 c0                	test   %eax,%eax
801040fc:	79 8c                	jns    8010408a <create+0xcf>
      panic("create dots");
801040fe:	83 ec 0c             	sub    $0xc,%esp
80104101:	68 24 6f 10 80       	push   $0x80106f24
80104106:	e8 36 c2 ff ff       	call   80100341 <panic>
    panic("create: dirlink");
8010410b:	83 ec 0c             	sub    $0xc,%esp
8010410e:	68 30 6f 10 80       	push   $0x80106f30
80104113:	e8 29 c2 ff ff       	call   80100341 <panic>
    return 0;
80104118:	89 c3                	mov    %eax,%ebx
8010411a:	e9 1c ff ff ff       	jmp    8010403b <create+0x80>

8010411f <sys_dup>:
{
8010411f:	55                   	push   %ebp
80104120:	89 e5                	mov    %esp,%ebp
80104122:	53                   	push   %ebx
80104123:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)//Coge el fd (arg 0) del usuario con argint y lo pasa a f con argfd
80104126:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104129:	ba 00 00 00 00       	mov    $0x0,%edx
8010412e:	b8 00 00 00 00       	mov    $0x0,%eax
80104133:	e8 98 fd ff ff       	call   80103ed0 <argfd>
80104138:	85 c0                	test   %eax,%eax
8010413a:	78 23                	js     8010415f <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0) //fdalloc busca el hueco dentro de la table de df.s y mete el fichero
8010413c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413f:	e8 ec fd ff ff       	call   80103f30 <fdalloc>
80104144:	89 c3                	mov    %eax,%ebx
80104146:	85 c0                	test   %eax,%eax
80104148:	78 1c                	js     80104166 <sys_dup+0x47>
  filedup(f); //lo unico que hace filedup es aumentar el ref de la ftable
8010414a:	83 ec 0c             	sub    $0xc,%esp
8010414d:	ff 75 f4             	push   -0xc(%ebp)
80104150:	e8 f3 ca ff ff       	call   80100c48 <filedup>
  return fd;
80104155:	83 c4 10             	add    $0x10,%esp
}
80104158:	89 d8                	mov    %ebx,%eax
8010415a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010415d:	c9                   	leave  
8010415e:	c3                   	ret    
    return -1;
8010415f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104164:	eb f2                	jmp    80104158 <sys_dup+0x39>
    return -1;
80104166:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010416b:	eb eb                	jmp    80104158 <sys_dup+0x39>

8010416d <sys_dup2>:
{//Objetivo: duplicar oldfd para meterlo en el lugar de newfd (esté abierto o cerrado)
8010416d:	55                   	push   %ebp
8010416e:	89 e5                	mov    %esp,%ebp
80104170:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0,&oldfd,&old_f) < 0){
80104173:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104176:	8d 55 f0             	lea    -0x10(%ebp),%edx
80104179:	b8 00 00 00 00       	mov    $0x0,%eax
8010417e:	e8 4d fd ff ff       	call   80103ed0 <argfd>
80104183:	85 c0                	test   %eax,%eax
80104185:	78 5e                	js     801041e5 <sys_dup2+0x78>
  if(argint(1, &newfd) < 0){
80104187:	83 ec 08             	sub    $0x8,%esp
8010418a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010418d:	50                   	push   %eax
8010418e:	6a 01                	push   $0x1
80104190:	e8 20 fc ff ff       	call   80103db5 <argint>
80104195:	83 c4 10             	add    $0x10,%esp
80104198:	85 c0                	test   %eax,%eax
8010419a:	78 50                	js     801041ec <sys_dup2+0x7f>
  if( newfd<0 || newfd >NOFILE)
8010419c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010419f:	83 f8 10             	cmp    $0x10,%eax
801041a2:	77 4f                	ja     801041f3 <sys_dup2+0x86>
  if(newfd==oldfd)
801041a4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801041a7:	74 3a                	je     801041e3 <sys_dup2+0x76>
  if((new_f=myproc()->ofile[newfd]) != 0)//myproc->ofile es el la tabla de df.s abiertos  
801041a9:	e8 6c ef ff ff       	call   8010311a <myproc>
801041ae:	8b 55 ec             	mov    -0x14(%ebp),%edx
801041b1:	8b 44 90 2c          	mov    0x2c(%eax,%edx,4),%eax
801041b5:	85 c0                	test   %eax,%eax
801041b7:	74 0c                	je     801041c5 <sys_dup2+0x58>
    fileclose(new_f);
801041b9:	83 ec 0c             	sub    $0xc,%esp
801041bc:	50                   	push   %eax
801041bd:	e8 c9 ca ff ff       	call   80100c8b <fileclose>
801041c2:	83 c4 10             	add    $0x10,%esp
  myproc()->ofile[newfd] = old_f;
801041c5:	e8 50 ef ff ff       	call   8010311a <myproc>
801041ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041cd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801041d0:	89 54 88 2c          	mov    %edx,0x2c(%eax,%ecx,4)
  filedup(old_f); 
801041d4:	83 ec 0c             	sub    $0xc,%esp
801041d7:	52                   	push   %edx
801041d8:	e8 6b ca ff ff       	call   80100c48 <filedup>
  return newfd;
801041dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041e0:	83 c4 10             	add    $0x10,%esp
}
801041e3:	c9                   	leave  
801041e4:	c3                   	ret    
    return -1;
801041e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041ea:	eb f7                	jmp    801041e3 <sys_dup2+0x76>
    return -1;
801041ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041f1:	eb f0                	jmp    801041e3 <sys_dup2+0x76>
    return -1;
801041f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041f8:	eb e9                	jmp    801041e3 <sys_dup2+0x76>

801041fa <sys_read>:
{
801041fa:	55                   	push   %ebp
801041fb:	89 e5                	mov    %esp,%ebp
801041fd:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, (void**)&p, n) < 0)
80104200:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104203:	ba 00 00 00 00       	mov    $0x0,%edx
80104208:	b8 00 00 00 00       	mov    $0x0,%eax
8010420d:	e8 be fc ff ff       	call   80103ed0 <argfd>
80104212:	85 c0                	test   %eax,%eax
80104214:	78 43                	js     80104259 <sys_read+0x5f>
80104216:	83 ec 08             	sub    $0x8,%esp
80104219:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010421c:	50                   	push   %eax
8010421d:	6a 02                	push   $0x2
8010421f:	e8 91 fb ff ff       	call   80103db5 <argint>
80104224:	83 c4 10             	add    $0x10,%esp
80104227:	85 c0                	test   %eax,%eax
80104229:	78 2e                	js     80104259 <sys_read+0x5f>
8010422b:	83 ec 04             	sub    $0x4,%esp
8010422e:	ff 75 f0             	push   -0x10(%ebp)
80104231:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104234:	50                   	push   %eax
80104235:	6a 01                	push   $0x1
80104237:	e8 a1 fb ff ff       	call   80103ddd <argptr>
8010423c:	83 c4 10             	add    $0x10,%esp
8010423f:	85 c0                	test   %eax,%eax
80104241:	78 16                	js     80104259 <sys_read+0x5f>
  return fileread(f, p, n);
80104243:	83 ec 04             	sub    $0x4,%esp
80104246:	ff 75 f0             	push   -0x10(%ebp)
80104249:	ff 75 ec             	push   -0x14(%ebp)
8010424c:	ff 75 f4             	push   -0xc(%ebp)
8010424f:	e8 30 cb ff ff       	call   80100d84 <fileread>
80104254:	83 c4 10             	add    $0x10,%esp
}
80104257:	c9                   	leave  
80104258:	c3                   	ret    
    return -1;
80104259:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010425e:	eb f7                	jmp    80104257 <sys_read+0x5d>

80104260 <sys_write>:
{
80104260:	55                   	push   %ebp
80104261:	89 e5                	mov    %esp,%ebp
80104263:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, (void**)&p, n) < 0)
80104266:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104269:	ba 00 00 00 00       	mov    $0x0,%edx
8010426e:	b8 00 00 00 00       	mov    $0x0,%eax
80104273:	e8 58 fc ff ff       	call   80103ed0 <argfd>
80104278:	85 c0                	test   %eax,%eax
8010427a:	78 43                	js     801042bf <sys_write+0x5f>
8010427c:	83 ec 08             	sub    $0x8,%esp
8010427f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104282:	50                   	push   %eax
80104283:	6a 02                	push   $0x2
80104285:	e8 2b fb ff ff       	call   80103db5 <argint>
8010428a:	83 c4 10             	add    $0x10,%esp
8010428d:	85 c0                	test   %eax,%eax
8010428f:	78 2e                	js     801042bf <sys_write+0x5f>
80104291:	83 ec 04             	sub    $0x4,%esp
80104294:	ff 75 f0             	push   -0x10(%ebp)
80104297:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010429a:	50                   	push   %eax
8010429b:	6a 01                	push   $0x1
8010429d:	e8 3b fb ff ff       	call   80103ddd <argptr>
801042a2:	83 c4 10             	add    $0x10,%esp
801042a5:	85 c0                	test   %eax,%eax
801042a7:	78 16                	js     801042bf <sys_write+0x5f>
  return filewrite(f, p, n);
801042a9:	83 ec 04             	sub    $0x4,%esp
801042ac:	ff 75 f0             	push   -0x10(%ebp)
801042af:	ff 75 ec             	push   -0x14(%ebp)
801042b2:	ff 75 f4             	push   -0xc(%ebp)
801042b5:	e8 4f cb ff ff       	call   80100e09 <filewrite>
801042ba:	83 c4 10             	add    $0x10,%esp
}
801042bd:	c9                   	leave  
801042be:	c3                   	ret    
    return -1;
801042bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042c4:	eb f7                	jmp    801042bd <sys_write+0x5d>

801042c6 <sys_close>:
{
801042c6:	55                   	push   %ebp
801042c7:	89 e5                	mov    %esp,%ebp
801042c9:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801042cc:	8d 4d f0             	lea    -0x10(%ebp),%ecx
801042cf:	8d 55 f4             	lea    -0xc(%ebp),%edx
801042d2:	b8 00 00 00 00       	mov    $0x0,%eax
801042d7:	e8 f4 fb ff ff       	call   80103ed0 <argfd>
801042dc:	85 c0                	test   %eax,%eax
801042de:	78 25                	js     80104305 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
801042e0:	e8 35 ee ff ff       	call   8010311a <myproc>
801042e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042e8:	c7 44 90 2c 00 00 00 	movl   $0x0,0x2c(%eax,%edx,4)
801042ef:	00 
  fileclose(f);
801042f0:	83 ec 0c             	sub    $0xc,%esp
801042f3:	ff 75 f0             	push   -0x10(%ebp)
801042f6:	e8 90 c9 ff ff       	call   80100c8b <fileclose>
  return 0;
801042fb:	83 c4 10             	add    $0x10,%esp
801042fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104303:	c9                   	leave  
80104304:	c3                   	ret    
    return -1;
80104305:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010430a:	eb f7                	jmp    80104303 <sys_close+0x3d>

8010430c <sys_fstat>:
{
8010430c:	55                   	push   %ebp
8010430d:	89 e5                	mov    %esp,%ebp
8010430f:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104312:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104315:	ba 00 00 00 00       	mov    $0x0,%edx
8010431a:	b8 00 00 00 00       	mov    $0x0,%eax
8010431f:	e8 ac fb ff ff       	call   80103ed0 <argfd>
80104324:	85 c0                	test   %eax,%eax
80104326:	78 2a                	js     80104352 <sys_fstat+0x46>
80104328:	83 ec 04             	sub    $0x4,%esp
8010432b:	6a 14                	push   $0x14
8010432d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104330:	50                   	push   %eax
80104331:	6a 01                	push   $0x1
80104333:	e8 a5 fa ff ff       	call   80103ddd <argptr>
80104338:	83 c4 10             	add    $0x10,%esp
8010433b:	85 c0                	test   %eax,%eax
8010433d:	78 13                	js     80104352 <sys_fstat+0x46>
  return filestat(f, st);
8010433f:	83 ec 08             	sub    $0x8,%esp
80104342:	ff 75 f0             	push   -0x10(%ebp)
80104345:	ff 75 f4             	push   -0xc(%ebp)
80104348:	e8 f0 c9 ff ff       	call   80100d3d <filestat>
8010434d:	83 c4 10             	add    $0x10,%esp
}
80104350:	c9                   	leave  
80104351:	c3                   	ret    
    return -1;
80104352:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104357:	eb f7                	jmp    80104350 <sys_fstat+0x44>

80104359 <sys_link>:
{
80104359:	55                   	push   %ebp
8010435a:	89 e5                	mov    %esp,%ebp
8010435c:	56                   	push   %esi
8010435d:	53                   	push   %ebx
8010435e:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104361:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104364:	50                   	push   %eax
80104365:	6a 00                	push   $0x0
80104367:	e8 da fa ff ff       	call   80103e46 <argstr>
8010436c:	83 c4 10             	add    $0x10,%esp
8010436f:	85 c0                	test   %eax,%eax
80104371:	0f 88 d1 00 00 00    	js     80104448 <sys_link+0xef>
80104377:	83 ec 08             	sub    $0x8,%esp
8010437a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010437d:	50                   	push   %eax
8010437e:	6a 01                	push   $0x1
80104380:	e8 c1 fa ff ff       	call   80103e46 <argstr>
80104385:	83 c4 10             	add    $0x10,%esp
80104388:	85 c0                	test   %eax,%eax
8010438a:	0f 88 b8 00 00 00    	js     80104448 <sys_link+0xef>
  begin_op();
80104390:	e8 48 e3 ff ff       	call   801026dd <begin_op>
  if((ip = namei(old)) == 0){
80104395:	83 ec 0c             	sub    $0xc,%esp
80104398:	ff 75 e0             	push   -0x20(%ebp)
8010439b:	e8 cb d7 ff ff       	call   80101b6b <namei>
801043a0:	89 c3                	mov    %eax,%ebx
801043a2:	83 c4 10             	add    $0x10,%esp
801043a5:	85 c0                	test   %eax,%eax
801043a7:	0f 84 a2 00 00 00    	je     8010444f <sys_link+0xf6>
  ilock(ip);
801043ad:	83 ec 0c             	sub    $0xc,%esp
801043b0:	50                   	push   %eax
801043b1:	e8 51 d1 ff ff       	call   80101507 <ilock>
  if(ip->type == T_DIR){
801043b6:	83 c4 10             	add    $0x10,%esp
801043b9:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801043be:	0f 84 97 00 00 00    	je     8010445b <sys_link+0x102>
  ip->nlink++;
801043c4:	66 8b 43 56          	mov    0x56(%ebx),%ax
801043c8:	40                   	inc    %eax
801043c9:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801043cd:	83 ec 0c             	sub    $0xc,%esp
801043d0:	53                   	push   %ebx
801043d1:	e8 d8 cf ff ff       	call   801013ae <iupdate>
  iunlock(ip);
801043d6:	89 1c 24             	mov    %ebx,(%esp)
801043d9:	e8 e9 d1 ff ff       	call   801015c7 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801043de:	83 c4 08             	add    $0x8,%esp
801043e1:	8d 45 ea             	lea    -0x16(%ebp),%eax
801043e4:	50                   	push   %eax
801043e5:	ff 75 e4             	push   -0x1c(%ebp)
801043e8:	e8 96 d7 ff ff       	call   80101b83 <nameiparent>
801043ed:	89 c6                	mov    %eax,%esi
801043ef:	83 c4 10             	add    $0x10,%esp
801043f2:	85 c0                	test   %eax,%eax
801043f4:	0f 84 85 00 00 00    	je     8010447f <sys_link+0x126>
  ilock(dp);
801043fa:	83 ec 0c             	sub    $0xc,%esp
801043fd:	50                   	push   %eax
801043fe:	e8 04 d1 ff ff       	call   80101507 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104403:	83 c4 10             	add    $0x10,%esp
80104406:	8b 03                	mov    (%ebx),%eax
80104408:	39 06                	cmp    %eax,(%esi)
8010440a:	75 67                	jne    80104473 <sys_link+0x11a>
8010440c:	83 ec 04             	sub    $0x4,%esp
8010440f:	ff 73 04             	push   0x4(%ebx)
80104412:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104415:	50                   	push   %eax
80104416:	56                   	push   %esi
80104417:	e8 9e d6 ff ff       	call   80101aba <dirlink>
8010441c:	83 c4 10             	add    $0x10,%esp
8010441f:	85 c0                	test   %eax,%eax
80104421:	78 50                	js     80104473 <sys_link+0x11a>
  iunlockput(dp);
80104423:	83 ec 0c             	sub    $0xc,%esp
80104426:	56                   	push   %esi
80104427:	e8 7e d2 ff ff       	call   801016aa <iunlockput>
  iput(ip);
8010442c:	89 1c 24             	mov    %ebx,(%esp)
8010442f:	e8 d8 d1 ff ff       	call   8010160c <iput>
  end_op();
80104434:	e8 20 e3 ff ff       	call   80102759 <end_op>
  return 0;
80104439:	83 c4 10             	add    $0x10,%esp
8010443c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104441:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104444:	5b                   	pop    %ebx
80104445:	5e                   	pop    %esi
80104446:	5d                   	pop    %ebp
80104447:	c3                   	ret    
    return -1;
80104448:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010444d:	eb f2                	jmp    80104441 <sys_link+0xe8>
    end_op();
8010444f:	e8 05 e3 ff ff       	call   80102759 <end_op>
    return -1;
80104454:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104459:	eb e6                	jmp    80104441 <sys_link+0xe8>
    iunlockput(ip);
8010445b:	83 ec 0c             	sub    $0xc,%esp
8010445e:	53                   	push   %ebx
8010445f:	e8 46 d2 ff ff       	call   801016aa <iunlockput>
    end_op();
80104464:	e8 f0 e2 ff ff       	call   80102759 <end_op>
    return -1;
80104469:	83 c4 10             	add    $0x10,%esp
8010446c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104471:	eb ce                	jmp    80104441 <sys_link+0xe8>
    iunlockput(dp);
80104473:	83 ec 0c             	sub    $0xc,%esp
80104476:	56                   	push   %esi
80104477:	e8 2e d2 ff ff       	call   801016aa <iunlockput>
    goto bad;
8010447c:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
8010447f:	83 ec 0c             	sub    $0xc,%esp
80104482:	53                   	push   %ebx
80104483:	e8 7f d0 ff ff       	call   80101507 <ilock>
  ip->nlink--;
80104488:	66 8b 43 56          	mov    0x56(%ebx),%ax
8010448c:	48                   	dec    %eax
8010448d:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104491:	89 1c 24             	mov    %ebx,(%esp)
80104494:	e8 15 cf ff ff       	call   801013ae <iupdate>
  iunlockput(ip);
80104499:	89 1c 24             	mov    %ebx,(%esp)
8010449c:	e8 09 d2 ff ff       	call   801016aa <iunlockput>
  end_op();
801044a1:	e8 b3 e2 ff ff       	call   80102759 <end_op>
  return -1;
801044a6:	83 c4 10             	add    $0x10,%esp
801044a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044ae:	eb 91                	jmp    80104441 <sys_link+0xe8>

801044b0 <sys_unlink>:
{
801044b0:	55                   	push   %ebp
801044b1:	89 e5                	mov    %esp,%ebp
801044b3:	57                   	push   %edi
801044b4:	56                   	push   %esi
801044b5:	53                   	push   %ebx
801044b6:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801044b9:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801044bc:	50                   	push   %eax
801044bd:	6a 00                	push   $0x0
801044bf:	e8 82 f9 ff ff       	call   80103e46 <argstr>
801044c4:	83 c4 10             	add    $0x10,%esp
801044c7:	85 c0                	test   %eax,%eax
801044c9:	0f 88 7f 01 00 00    	js     8010464e <sys_unlink+0x19e>
  begin_op();
801044cf:	e8 09 e2 ff ff       	call   801026dd <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801044d4:	83 ec 08             	sub    $0x8,%esp
801044d7:	8d 45 ca             	lea    -0x36(%ebp),%eax
801044da:	50                   	push   %eax
801044db:	ff 75 c4             	push   -0x3c(%ebp)
801044de:	e8 a0 d6 ff ff       	call   80101b83 <nameiparent>
801044e3:	89 c6                	mov    %eax,%esi
801044e5:	83 c4 10             	add    $0x10,%esp
801044e8:	85 c0                	test   %eax,%eax
801044ea:	0f 84 eb 00 00 00    	je     801045db <sys_unlink+0x12b>
  ilock(dp);
801044f0:	83 ec 0c             	sub    $0xc,%esp
801044f3:	50                   	push   %eax
801044f4:	e8 0e d0 ff ff       	call   80101507 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801044f9:	83 c4 08             	add    $0x8,%esp
801044fc:	68 22 6f 10 80       	push   $0x80106f22
80104501:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104504:	50                   	push   %eax
80104505:	e8 1e d4 ff ff       	call   80101928 <namecmp>
8010450a:	83 c4 10             	add    $0x10,%esp
8010450d:	85 c0                	test   %eax,%eax
8010450f:	0f 84 fa 00 00 00    	je     8010460f <sys_unlink+0x15f>
80104515:	83 ec 08             	sub    $0x8,%esp
80104518:	68 21 6f 10 80       	push   $0x80106f21
8010451d:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104520:	50                   	push   %eax
80104521:	e8 02 d4 ff ff       	call   80101928 <namecmp>
80104526:	83 c4 10             	add    $0x10,%esp
80104529:	85 c0                	test   %eax,%eax
8010452b:	0f 84 de 00 00 00    	je     8010460f <sys_unlink+0x15f>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104531:	83 ec 04             	sub    $0x4,%esp
80104534:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104537:	50                   	push   %eax
80104538:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010453b:	50                   	push   %eax
8010453c:	56                   	push   %esi
8010453d:	e8 fb d3 ff ff       	call   8010193d <dirlookup>
80104542:	89 c3                	mov    %eax,%ebx
80104544:	83 c4 10             	add    $0x10,%esp
80104547:	85 c0                	test   %eax,%eax
80104549:	0f 84 c0 00 00 00    	je     8010460f <sys_unlink+0x15f>
  ilock(ip);
8010454f:	83 ec 0c             	sub    $0xc,%esp
80104552:	50                   	push   %eax
80104553:	e8 af cf ff ff       	call   80101507 <ilock>
  if(ip->nlink < 1)
80104558:	83 c4 10             	add    $0x10,%esp
8010455b:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104560:	0f 8e 81 00 00 00    	jle    801045e7 <sys_unlink+0x137>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104566:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010456b:	0f 84 83 00 00 00    	je     801045f4 <sys_unlink+0x144>
  memset(&de, 0, sizeof(de));
80104571:	83 ec 04             	sub    $0x4,%esp
80104574:	6a 10                	push   $0x10
80104576:	6a 00                	push   $0x0
80104578:	8d 7d d8             	lea    -0x28(%ebp),%edi
8010457b:	57                   	push   %edi
8010457c:	e8 fe f5 ff ff       	call   80103b7f <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104581:	6a 10                	push   $0x10
80104583:	ff 75 c0             	push   -0x40(%ebp)
80104586:	57                   	push   %edi
80104587:	56                   	push   %esi
80104588:	e8 67 d2 ff ff       	call   801017f4 <writei>
8010458d:	83 c4 20             	add    $0x20,%esp
80104590:	83 f8 10             	cmp    $0x10,%eax
80104593:	0f 85 8e 00 00 00    	jne    80104627 <sys_unlink+0x177>
  if(ip->type == T_DIR){
80104599:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010459e:	0f 84 90 00 00 00    	je     80104634 <sys_unlink+0x184>
  iunlockput(dp);
801045a4:	83 ec 0c             	sub    $0xc,%esp
801045a7:	56                   	push   %esi
801045a8:	e8 fd d0 ff ff       	call   801016aa <iunlockput>
  ip->nlink--;
801045ad:	66 8b 43 56          	mov    0x56(%ebx),%ax
801045b1:	48                   	dec    %eax
801045b2:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801045b6:	89 1c 24             	mov    %ebx,(%esp)
801045b9:	e8 f0 cd ff ff       	call   801013ae <iupdate>
  iunlockput(ip);
801045be:	89 1c 24             	mov    %ebx,(%esp)
801045c1:	e8 e4 d0 ff ff       	call   801016aa <iunlockput>
  end_op();
801045c6:	e8 8e e1 ff ff       	call   80102759 <end_op>
  return 0;
801045cb:	83 c4 10             	add    $0x10,%esp
801045ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801045d6:	5b                   	pop    %ebx
801045d7:	5e                   	pop    %esi
801045d8:	5f                   	pop    %edi
801045d9:	5d                   	pop    %ebp
801045da:	c3                   	ret    
    end_op();
801045db:	e8 79 e1 ff ff       	call   80102759 <end_op>
    return -1;
801045e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045e5:	eb ec                	jmp    801045d3 <sys_unlink+0x123>
    panic("unlink: nlink < 1");
801045e7:	83 ec 0c             	sub    $0xc,%esp
801045ea:	68 40 6f 10 80       	push   $0x80106f40
801045ef:	e8 4d bd ff ff       	call   80100341 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801045f4:	89 d8                	mov    %ebx,%eax
801045f6:	e8 69 f9 ff ff       	call   80103f64 <isdirempty>
801045fb:	85 c0                	test   %eax,%eax
801045fd:	0f 85 6e ff ff ff    	jne    80104571 <sys_unlink+0xc1>
    iunlockput(ip);
80104603:	83 ec 0c             	sub    $0xc,%esp
80104606:	53                   	push   %ebx
80104607:	e8 9e d0 ff ff       	call   801016aa <iunlockput>
    goto bad;
8010460c:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
8010460f:	83 ec 0c             	sub    $0xc,%esp
80104612:	56                   	push   %esi
80104613:	e8 92 d0 ff ff       	call   801016aa <iunlockput>
  end_op();
80104618:	e8 3c e1 ff ff       	call   80102759 <end_op>
  return -1;
8010461d:	83 c4 10             	add    $0x10,%esp
80104620:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104625:	eb ac                	jmp    801045d3 <sys_unlink+0x123>
    panic("unlink: writei");
80104627:	83 ec 0c             	sub    $0xc,%esp
8010462a:	68 52 6f 10 80       	push   $0x80106f52
8010462f:	e8 0d bd ff ff       	call   80100341 <panic>
    dp->nlink--;
80104634:	66 8b 46 56          	mov    0x56(%esi),%ax
80104638:	48                   	dec    %eax
80104639:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010463d:	83 ec 0c             	sub    $0xc,%esp
80104640:	56                   	push   %esi
80104641:	e8 68 cd ff ff       	call   801013ae <iupdate>
80104646:	83 c4 10             	add    $0x10,%esp
80104649:	e9 56 ff ff ff       	jmp    801045a4 <sys_unlink+0xf4>
    return -1;
8010464e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104653:	e9 7b ff ff ff       	jmp    801045d3 <sys_unlink+0x123>

80104658 <sys_open>:

int
sys_open(void)
{
80104658:	55                   	push   %ebp
80104659:	89 e5                	mov    %esp,%ebp
8010465b:	57                   	push   %edi
8010465c:	56                   	push   %esi
8010465d:	53                   	push   %ebx
8010465e:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104661:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104664:	50                   	push   %eax
80104665:	6a 00                	push   $0x0
80104667:	e8 da f7 ff ff       	call   80103e46 <argstr>
8010466c:	83 c4 10             	add    $0x10,%esp
8010466f:	85 c0                	test   %eax,%eax
80104671:	0f 88 a0 00 00 00    	js     80104717 <sys_open+0xbf>
80104677:	83 ec 08             	sub    $0x8,%esp
8010467a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010467d:	50                   	push   %eax
8010467e:	6a 01                	push   $0x1
80104680:	e8 30 f7 ff ff       	call   80103db5 <argint>
80104685:	83 c4 10             	add    $0x10,%esp
80104688:	85 c0                	test   %eax,%eax
8010468a:	0f 88 87 00 00 00    	js     80104717 <sys_open+0xbf>
    return -1;

  begin_op();
80104690:	e8 48 e0 ff ff       	call   801026dd <begin_op>

  if(omode & O_CREATE){
80104695:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104699:	0f 84 8b 00 00 00    	je     8010472a <sys_open+0xd2>
    ip = create(path, T_FILE, 0, 0);
8010469f:	83 ec 0c             	sub    $0xc,%esp
801046a2:	6a 00                	push   $0x0
801046a4:	b9 00 00 00 00       	mov    $0x0,%ecx
801046a9:	ba 02 00 00 00       	mov    $0x2,%edx
801046ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801046b1:	e8 05 f9 ff ff       	call   80103fbb <create>
801046b6:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801046b8:	83 c4 10             	add    $0x10,%esp
801046bb:	85 c0                	test   %eax,%eax
801046bd:	74 5f                	je     8010471e <sys_open+0xc6>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801046bf:	e8 23 c5 ff ff       	call   80100be7 <filealloc>
801046c4:	89 c3                	mov    %eax,%ebx
801046c6:	85 c0                	test   %eax,%eax
801046c8:	0f 84 b5 00 00 00    	je     80104783 <sys_open+0x12b>
801046ce:	e8 5d f8 ff ff       	call   80103f30 <fdalloc>
801046d3:	89 c7                	mov    %eax,%edi
801046d5:	85 c0                	test   %eax,%eax
801046d7:	0f 88 a6 00 00 00    	js     80104783 <sys_open+0x12b>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801046dd:	83 ec 0c             	sub    $0xc,%esp
801046e0:	56                   	push   %esi
801046e1:	e8 e1 ce ff ff       	call   801015c7 <iunlock>
  end_op();
801046e6:	e8 6e e0 ff ff       	call   80102759 <end_op>

  f->type = FD_INODE;
801046eb:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
801046f1:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
801046f4:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
801046fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046fe:	83 c4 10             	add    $0x10,%esp
80104701:	a8 01                	test   $0x1,%al
80104703:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104707:	a8 03                	test   $0x3,%al
80104709:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
8010470d:	89 f8                	mov    %edi,%eax
8010470f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104712:	5b                   	pop    %ebx
80104713:	5e                   	pop    %esi
80104714:	5f                   	pop    %edi
80104715:	5d                   	pop    %ebp
80104716:	c3                   	ret    
    return -1;
80104717:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010471c:	eb ef                	jmp    8010470d <sys_open+0xb5>
      end_op();
8010471e:	e8 36 e0 ff ff       	call   80102759 <end_op>
      return -1;
80104723:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104728:	eb e3                	jmp    8010470d <sys_open+0xb5>
    if((ip = namei(path)) == 0){
8010472a:	83 ec 0c             	sub    $0xc,%esp
8010472d:	ff 75 e4             	push   -0x1c(%ebp)
80104730:	e8 36 d4 ff ff       	call   80101b6b <namei>
80104735:	89 c6                	mov    %eax,%esi
80104737:	83 c4 10             	add    $0x10,%esp
8010473a:	85 c0                	test   %eax,%eax
8010473c:	74 39                	je     80104777 <sys_open+0x11f>
    ilock(ip);
8010473e:	83 ec 0c             	sub    $0xc,%esp
80104741:	50                   	push   %eax
80104742:	e8 c0 cd ff ff       	call   80101507 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104747:	83 c4 10             	add    $0x10,%esp
8010474a:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
8010474f:	0f 85 6a ff ff ff    	jne    801046bf <sys_open+0x67>
80104755:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104759:	0f 84 60 ff ff ff    	je     801046bf <sys_open+0x67>
      iunlockput(ip);
8010475f:	83 ec 0c             	sub    $0xc,%esp
80104762:	56                   	push   %esi
80104763:	e8 42 cf ff ff       	call   801016aa <iunlockput>
      end_op();
80104768:	e8 ec df ff ff       	call   80102759 <end_op>
      return -1;
8010476d:	83 c4 10             	add    $0x10,%esp
80104770:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104775:	eb 96                	jmp    8010470d <sys_open+0xb5>
      end_op();
80104777:	e8 dd df ff ff       	call   80102759 <end_op>
      return -1;
8010477c:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104781:	eb 8a                	jmp    8010470d <sys_open+0xb5>
    if(f)
80104783:	85 db                	test   %ebx,%ebx
80104785:	74 0c                	je     80104793 <sys_open+0x13b>
      fileclose(f);
80104787:	83 ec 0c             	sub    $0xc,%esp
8010478a:	53                   	push   %ebx
8010478b:	e8 fb c4 ff ff       	call   80100c8b <fileclose>
80104790:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80104793:	83 ec 0c             	sub    $0xc,%esp
80104796:	56                   	push   %esi
80104797:	e8 0e cf ff ff       	call   801016aa <iunlockput>
    end_op();
8010479c:	e8 b8 df ff ff       	call   80102759 <end_op>
    return -1;
801047a1:	83 c4 10             	add    $0x10,%esp
801047a4:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801047a9:	e9 5f ff ff ff       	jmp    8010470d <sys_open+0xb5>

801047ae <sys_mkdir>:

int
sys_mkdir(void)
{
801047ae:	55                   	push   %ebp
801047af:	89 e5                	mov    %esp,%ebp
801047b1:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801047b4:	e8 24 df ff ff       	call   801026dd <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801047b9:	83 ec 08             	sub    $0x8,%esp
801047bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801047bf:	50                   	push   %eax
801047c0:	6a 00                	push   $0x0
801047c2:	e8 7f f6 ff ff       	call   80103e46 <argstr>
801047c7:	83 c4 10             	add    $0x10,%esp
801047ca:	85 c0                	test   %eax,%eax
801047cc:	78 36                	js     80104804 <sys_mkdir+0x56>
801047ce:	83 ec 0c             	sub    $0xc,%esp
801047d1:	6a 00                	push   $0x0
801047d3:	b9 00 00 00 00       	mov    $0x0,%ecx
801047d8:	ba 01 00 00 00       	mov    $0x1,%edx
801047dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e0:	e8 d6 f7 ff ff       	call   80103fbb <create>
801047e5:	83 c4 10             	add    $0x10,%esp
801047e8:	85 c0                	test   %eax,%eax
801047ea:	74 18                	je     80104804 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
801047ec:	83 ec 0c             	sub    $0xc,%esp
801047ef:	50                   	push   %eax
801047f0:	e8 b5 ce ff ff       	call   801016aa <iunlockput>
  end_op();
801047f5:	e8 5f df ff ff       	call   80102759 <end_op>
  return 0;
801047fa:	83 c4 10             	add    $0x10,%esp
801047fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104802:	c9                   	leave  
80104803:	c3                   	ret    
    end_op();
80104804:	e8 50 df ff ff       	call   80102759 <end_op>
    return -1;
80104809:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010480e:	eb f2                	jmp    80104802 <sys_mkdir+0x54>

80104810 <sys_mknod>:

int
sys_mknod(void)
{
80104810:	55                   	push   %ebp
80104811:	89 e5                	mov    %esp,%ebp
80104813:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104816:	e8 c2 de ff ff       	call   801026dd <begin_op>
  if((argstr(0, &path)) < 0 ||
8010481b:	83 ec 08             	sub    $0x8,%esp
8010481e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104821:	50                   	push   %eax
80104822:	6a 00                	push   $0x0
80104824:	e8 1d f6 ff ff       	call   80103e46 <argstr>
80104829:	83 c4 10             	add    $0x10,%esp
8010482c:	85 c0                	test   %eax,%eax
8010482e:	78 62                	js     80104892 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104830:	83 ec 08             	sub    $0x8,%esp
80104833:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104836:	50                   	push   %eax
80104837:	6a 01                	push   $0x1
80104839:	e8 77 f5 ff ff       	call   80103db5 <argint>
  if((argstr(0, &path)) < 0 ||
8010483e:	83 c4 10             	add    $0x10,%esp
80104841:	85 c0                	test   %eax,%eax
80104843:	78 4d                	js     80104892 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104845:	83 ec 08             	sub    $0x8,%esp
80104848:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010484b:	50                   	push   %eax
8010484c:	6a 02                	push   $0x2
8010484e:	e8 62 f5 ff ff       	call   80103db5 <argint>
     argint(1, &major) < 0 ||
80104853:	83 c4 10             	add    $0x10,%esp
80104856:	85 c0                	test   %eax,%eax
80104858:	78 38                	js     80104892 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010485a:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
8010485e:	83 ec 0c             	sub    $0xc,%esp
80104861:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104865:	50                   	push   %eax
80104866:	ba 03 00 00 00       	mov    $0x3,%edx
8010486b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010486e:	e8 48 f7 ff ff       	call   80103fbb <create>
     argint(2, &minor) < 0 ||
80104873:	83 c4 10             	add    $0x10,%esp
80104876:	85 c0                	test   %eax,%eax
80104878:	74 18                	je     80104892 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010487a:	83 ec 0c             	sub    $0xc,%esp
8010487d:	50                   	push   %eax
8010487e:	e8 27 ce ff ff       	call   801016aa <iunlockput>
  end_op();
80104883:	e8 d1 de ff ff       	call   80102759 <end_op>
  return 0;
80104888:	83 c4 10             	add    $0x10,%esp
8010488b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104890:	c9                   	leave  
80104891:	c3                   	ret    
    end_op();
80104892:	e8 c2 de ff ff       	call   80102759 <end_op>
    return -1;
80104897:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010489c:	eb f2                	jmp    80104890 <sys_mknod+0x80>

8010489e <sys_chdir>:

int
sys_chdir(void)
{
8010489e:	55                   	push   %ebp
8010489f:	89 e5                	mov    %esp,%ebp
801048a1:	56                   	push   %esi
801048a2:	53                   	push   %ebx
801048a3:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801048a6:	e8 6f e8 ff ff       	call   8010311a <myproc>
801048ab:	89 c6                	mov    %eax,%esi
  
  begin_op();
801048ad:	e8 2b de ff ff       	call   801026dd <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801048b2:	83 ec 08             	sub    $0x8,%esp
801048b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801048b8:	50                   	push   %eax
801048b9:	6a 00                	push   $0x0
801048bb:	e8 86 f5 ff ff       	call   80103e46 <argstr>
801048c0:	83 c4 10             	add    $0x10,%esp
801048c3:	85 c0                	test   %eax,%eax
801048c5:	78 52                	js     80104919 <sys_chdir+0x7b>
801048c7:	83 ec 0c             	sub    $0xc,%esp
801048ca:	ff 75 f4             	push   -0xc(%ebp)
801048cd:	e8 99 d2 ff ff       	call   80101b6b <namei>
801048d2:	89 c3                	mov    %eax,%ebx
801048d4:	83 c4 10             	add    $0x10,%esp
801048d7:	85 c0                	test   %eax,%eax
801048d9:	74 3e                	je     80104919 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
801048db:	83 ec 0c             	sub    $0xc,%esp
801048de:	50                   	push   %eax
801048df:	e8 23 cc ff ff       	call   80101507 <ilock>
  if(ip->type != T_DIR){
801048e4:	83 c4 10             	add    $0x10,%esp
801048e7:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801048ec:	75 37                	jne    80104925 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801048ee:	83 ec 0c             	sub    $0xc,%esp
801048f1:	53                   	push   %ebx
801048f2:	e8 d0 cc ff ff       	call   801015c7 <iunlock>
  iput(curproc->cwd);
801048f7:	83 c4 04             	add    $0x4,%esp
801048fa:	ff 76 6c             	push   0x6c(%esi)
801048fd:	e8 0a cd ff ff       	call   8010160c <iput>
  end_op();
80104902:	e8 52 de ff ff       	call   80102759 <end_op>
  curproc->cwd = ip;
80104907:	89 5e 6c             	mov    %ebx,0x6c(%esi)
  return 0;
8010490a:	83 c4 10             	add    $0x10,%esp
8010490d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104912:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104915:	5b                   	pop    %ebx
80104916:	5e                   	pop    %esi
80104917:	5d                   	pop    %ebp
80104918:	c3                   	ret    
    end_op();
80104919:	e8 3b de ff ff       	call   80102759 <end_op>
    return -1;
8010491e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104923:	eb ed                	jmp    80104912 <sys_chdir+0x74>
    iunlockput(ip);
80104925:	83 ec 0c             	sub    $0xc,%esp
80104928:	53                   	push   %ebx
80104929:	e8 7c cd ff ff       	call   801016aa <iunlockput>
    end_op();
8010492e:	e8 26 de ff ff       	call   80102759 <end_op>
    return -1;
80104933:	83 c4 10             	add    $0x10,%esp
80104936:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010493b:	eb d5                	jmp    80104912 <sys_chdir+0x74>

8010493d <sys_exec>:

int
sys_exec(void)
{
8010493d:	55                   	push   %ebp
8010493e:	89 e5                	mov    %esp,%ebp
80104940:	53                   	push   %ebx
80104941:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104947:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010494a:	50                   	push   %eax
8010494b:	6a 00                	push   $0x0
8010494d:	e8 f4 f4 ff ff       	call   80103e46 <argstr>
80104952:	83 c4 10             	add    $0x10,%esp
80104955:	85 c0                	test   %eax,%eax
80104957:	78 38                	js     80104991 <sys_exec+0x54>
80104959:	83 ec 08             	sub    $0x8,%esp
8010495c:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104962:	50                   	push   %eax
80104963:	6a 01                	push   $0x1
80104965:	e8 4b f4 ff ff       	call   80103db5 <argint>
8010496a:	83 c4 10             	add    $0x10,%esp
8010496d:	85 c0                	test   %eax,%eax
8010496f:	78 20                	js     80104991 <sys_exec+0x54>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104971:	83 ec 04             	sub    $0x4,%esp
80104974:	68 80 00 00 00       	push   $0x80
80104979:	6a 00                	push   $0x0
8010497b:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104981:	50                   	push   %eax
80104982:	e8 f8 f1 ff ff       	call   80103b7f <memset>
80104987:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010498a:	bb 00 00 00 00       	mov    $0x0,%ebx
8010498f:	eb 2a                	jmp    801049bb <sys_exec+0x7e>
    return -1;
80104991:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104996:	eb 76                	jmp    80104a0e <sys_exec+0xd1>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
80104998:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
8010499f:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801049a3:	83 ec 08             	sub    $0x8,%esp
801049a6:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
801049ac:	50                   	push   %eax
801049ad:	ff 75 f4             	push   -0xc(%ebp)
801049b0:	e8 db be ff ff       	call   80100890 <exec>
801049b5:	83 c4 10             	add    $0x10,%esp
801049b8:	eb 54                	jmp    80104a0e <sys_exec+0xd1>
  for(i=0;; i++){
801049ba:	43                   	inc    %ebx
    if(i >= NELEM(argv))
801049bb:	83 fb 1f             	cmp    $0x1f,%ebx
801049be:	77 49                	ja     80104a09 <sys_exec+0xcc>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801049c0:	83 ec 08             	sub    $0x8,%esp
801049c3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801049c9:	50                   	push   %eax
801049ca:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
801049d0:	8d 04 98             	lea    (%eax,%ebx,4),%eax
801049d3:	50                   	push   %eax
801049d4:	e8 61 f3 ff ff       	call   80103d3a <fetchint>
801049d9:	83 c4 10             	add    $0x10,%esp
801049dc:	85 c0                	test   %eax,%eax
801049de:	78 33                	js     80104a13 <sys_exec+0xd6>
    if(uarg == 0){
801049e0:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801049e6:	85 c0                	test   %eax,%eax
801049e8:	74 ae                	je     80104998 <sys_exec+0x5b>
    if(fetchstr(uarg, &argv[i]) < 0)
801049ea:	83 ec 08             	sub    $0x8,%esp
801049ed:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
801049f4:	52                   	push   %edx
801049f5:	50                   	push   %eax
801049f6:	e8 7b f3 ff ff       	call   80103d76 <fetchstr>
801049fb:	83 c4 10             	add    $0x10,%esp
801049fe:	85 c0                	test   %eax,%eax
80104a00:	79 b8                	jns    801049ba <sys_exec+0x7d>
      return -1;
80104a02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a07:	eb 05                	jmp    80104a0e <sys_exec+0xd1>
      return -1;
80104a09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104a0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a11:	c9                   	leave  
80104a12:	c3                   	ret    
      return -1;
80104a13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a18:	eb f4                	jmp    80104a0e <sys_exec+0xd1>

80104a1a <sys_pipe>:

int
sys_pipe(void)
{
80104a1a:	55                   	push   %ebp
80104a1b:	89 e5                	mov    %esp,%ebp
80104a1d:	53                   	push   %ebx
80104a1e:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104a21:	6a 08                	push   $0x8
80104a23:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a26:	50                   	push   %eax
80104a27:	6a 00                	push   $0x0
80104a29:	e8 af f3 ff ff       	call   80103ddd <argptr>
80104a2e:	83 c4 10             	add    $0x10,%esp
80104a31:	85 c0                	test   %eax,%eax
80104a33:	78 79                	js     80104aae <sys_pipe+0x94>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104a35:	83 ec 08             	sub    $0x8,%esp
80104a38:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104a3b:	50                   	push   %eax
80104a3c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104a3f:	50                   	push   %eax
80104a40:	e8 0f e2 ff ff       	call   80102c54 <pipealloc>
80104a45:	83 c4 10             	add    $0x10,%esp
80104a48:	85 c0                	test   %eax,%eax
80104a4a:	78 69                	js     80104ab5 <sys_pipe+0x9b>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a4f:	e8 dc f4 ff ff       	call   80103f30 <fdalloc>
80104a54:	89 c3                	mov    %eax,%ebx
80104a56:	85 c0                	test   %eax,%eax
80104a58:	78 21                	js     80104a7b <sys_pipe+0x61>
80104a5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a5d:	e8 ce f4 ff ff       	call   80103f30 <fdalloc>
80104a62:	85 c0                	test   %eax,%eax
80104a64:	78 15                	js     80104a7b <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104a66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a69:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104a6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a6e:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104a71:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a79:	c9                   	leave  
80104a7a:	c3                   	ret    
    if(fd0 >= 0)
80104a7b:	85 db                	test   %ebx,%ebx
80104a7d:	79 20                	jns    80104a9f <sys_pipe+0x85>
    fileclose(rf);
80104a7f:	83 ec 0c             	sub    $0xc,%esp
80104a82:	ff 75 f0             	push   -0x10(%ebp)
80104a85:	e8 01 c2 ff ff       	call   80100c8b <fileclose>
    fileclose(wf);
80104a8a:	83 c4 04             	add    $0x4,%esp
80104a8d:	ff 75 ec             	push   -0x14(%ebp)
80104a90:	e8 f6 c1 ff ff       	call   80100c8b <fileclose>
    return -1;
80104a95:	83 c4 10             	add    $0x10,%esp
80104a98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a9d:	eb d7                	jmp    80104a76 <sys_pipe+0x5c>
      myproc()->ofile[fd0] = 0;
80104a9f:	e8 76 e6 ff ff       	call   8010311a <myproc>
80104aa4:	c7 44 98 2c 00 00 00 	movl   $0x0,0x2c(%eax,%ebx,4)
80104aab:	00 
80104aac:	eb d1                	jmp    80104a7f <sys_pipe+0x65>
    return -1;
80104aae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ab3:	eb c1                	jmp    80104a76 <sys_pipe+0x5c>
    return -1;
80104ab5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104aba:	eb ba                	jmp    80104a76 <sys_pipe+0x5c>

80104abc <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104abc:	55                   	push   %ebp
80104abd:	89 e5                	mov    %esp,%ebp
80104abf:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104ac2:	e8 c9 e7 ff ff       	call   80103290 <fork>
}
80104ac7:	c9                   	leave  
80104ac8:	c3                   	ret    

80104ac9 <sys_exit>:

int
sys_exit(void)
{ // Recuperamos el valor de salida con argint
80104ac9:	55                   	push   %ebp
80104aca:	89 e5                	mov    %esp,%ebp
80104acc:	83 ec 20             	sub    $0x20,%esp
  int status;
  if(argint(0,&status) < 0)
80104acf:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ad2:	50                   	push   %eax
80104ad3:	6a 00                	push   $0x0
80104ad5:	e8 db f2 ff ff       	call   80103db5 <argint>
80104ada:	83 c4 10             	add    $0x10,%esp
80104add:	85 c0                	test   %eax,%eax
80104adf:	78 1c                	js     80104afd <sys_exit+0x34>
  {
    return -1;
  }
	status = status << 8;
80104ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae4:	c1 e0 08             	shl    $0x8,%eax
80104ae7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  exit(status);
80104aea:	83 ec 0c             	sub    $0xc,%esp
80104aed:	50                   	push   %eax
80104aee:	e8 d2 e9 ff ff       	call   801034c5 <exit>
  return 0;  // not reached
80104af3:	83 c4 10             	add    $0x10,%esp
80104af6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104afb:	c9                   	leave  
80104afc:	c3                   	ret    
    return -1;
80104afd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b02:	eb f7                	jmp    80104afb <sys_exit+0x32>

80104b04 <sys_wait>:

int
sys_wait(void)
{ //Recuperamos la variable con argptr (int *)
80104b04:	55                   	push   %ebp
80104b05:	89 e5                	mov    %esp,%ebp
80104b07:	83 ec 1c             	sub    $0x1c,%esp
  int *status;
  int size = 4;

  if(argptr(0,(void**) &status,size) < 0)
80104b0a:	6a 04                	push   $0x4
80104b0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b0f:	50                   	push   %eax
80104b10:	6a 00                	push   $0x0
80104b12:	e8 c6 f2 ff ff       	call   80103ddd <argptr>
80104b17:	83 c4 10             	add    $0x10,%esp
80104b1a:	85 c0                	test   %eax,%eax
80104b1c:	78 10                	js     80104b2e <sys_wait+0x2a>
  {
    return -1;
  }
  return wait(status);
80104b1e:	83 ec 0c             	sub    $0xc,%esp
80104b21:	ff 75 f4             	push   -0xc(%ebp)
80104b24:	e8 39 eb ff ff       	call   80103662 <wait>
80104b29:	83 c4 10             	add    $0x10,%esp
}
80104b2c:	c9                   	leave  
80104b2d:	c3                   	ret    
    return -1;
80104b2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b33:	eb f7                	jmp    80104b2c <sys_wait+0x28>

80104b35 <sys_kill>:

int
sys_kill(void)
{
80104b35:	55                   	push   %ebp
80104b36:	89 e5                	mov    %esp,%ebp
80104b38:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104b3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b3e:	50                   	push   %eax
80104b3f:	6a 00                	push   $0x0
80104b41:	e8 6f f2 ff ff       	call   80103db5 <argint>
80104b46:	83 c4 10             	add    $0x10,%esp
80104b49:	85 c0                	test   %eax,%eax
80104b4b:	78 10                	js     80104b5d <sys_kill+0x28>
    return -1;
  return kill(pid);
80104b4d:	83 ec 0c             	sub    $0xc,%esp
80104b50:	ff 75 f4             	push   -0xc(%ebp)
80104b53:	e8 15 ec ff ff       	call   8010376d <kill>
80104b58:	83 c4 10             	add    $0x10,%esp
}
80104b5b:	c9                   	leave  
80104b5c:	c3                   	ret    
    return -1;
80104b5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b62:	eb f7                	jmp    80104b5b <sys_kill+0x26>

80104b64 <sys_getpid>:

int
sys_getpid(void)
{
80104b64:	55                   	push   %ebp
80104b65:	89 e5                	mov    %esp,%ebp
80104b67:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104b6a:	e8 ab e5 ff ff       	call   8010311a <myproc>
80104b6f:	8b 40 14             	mov    0x14(%eax),%eax
}
80104b72:	c9                   	leave  
80104b73:	c3                   	ret    

80104b74 <sys_sbrk>:

int
sys_sbrk(void)
{
80104b74:	55                   	push   %ebp
80104b75:	89 e5                	mov    %esp,%ebp
80104b77:	57                   	push   %edi
80104b78:	56                   	push   %esi
80104b79:	53                   	push   %ebx
80104b7a:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;
	int oldsz = myproc()->sz;
80104b7d:	e8 98 e5 ff ff       	call   8010311a <myproc>
80104b82:	8b 70 04             	mov    0x4(%eax),%esi
	int newsz = oldsz;
  addr = myproc()->sz;//Devuelvo el tamaño inicial
80104b85:	e8 90 e5 ff ff       	call   8010311a <myproc>
80104b8a:	8b 78 04             	mov    0x4(%eax),%edi
  if(argint(0, &n) < 0)
80104b8d:	83 ec 08             	sub    $0x8,%esp
80104b90:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104b93:	50                   	push   %eax
80104b94:	6a 00                	push   $0x0
80104b96:	e8 1a f2 ff ff       	call   80103db5 <argint>
80104b9b:	83 c4 10             	add    $0x10,%esp
80104b9e:	85 c0                	test   %eax,%eax
80104ba0:	78 45                	js     80104be7 <sys_sbrk+0x73>
80104ba2:	89 f3                	mov    %esi,%ebx
    return -1;
	//cprintf("old=%d,n=%d\n",oldsz,n);
	if(n > 0)
80104ba4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ba7:	85 c0                	test   %eax,%eax
80104ba9:	7e 15                	jle    80104bc0 <sys_sbrk+0x4c>
	{
		newsz = oldsz + n;//si n es positivo, aumento el tamaño (Ya fallará en trap.c) 
80104bab:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
	{//Si n es negativo, hago dealloc y actualizo el size tambien
		//Soy perezoso para reservar memoria, pero no para liberarla
    if((newsz = deallocuvm(myproc()->pgdir, oldsz, oldsz + n)) == 0)
      return -1;
  }
	myproc()->sz= newsz; //actualizamos el sz del proceso
80104bae:	e8 67 e5 ff ff       	call   8010311a <myproc>
80104bb3:	89 58 04             	mov    %ebx,0x4(%eax)

 // if(growproc(n) < 0)//El tamaño nuevo se pone en esta función
 //   return -1;
  return addr;
}
80104bb6:	89 f8                	mov    %edi,%eax
80104bb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104bbb:	5b                   	pop    %ebx
80104bbc:	5e                   	pop    %esi
80104bbd:	5f                   	pop    %edi
80104bbe:	5d                   	pop    %ebp
80104bbf:	c3                   	ret    
	else if(n < 0)
80104bc0:	79 ec                	jns    80104bae <sys_sbrk+0x3a>
    if((newsz = deallocuvm(myproc()->pgdir, oldsz, oldsz + n)) == 0)
80104bc2:	8d 1c 30             	lea    (%eax,%esi,1),%ebx
80104bc5:	e8 50 e5 ff ff       	call   8010311a <myproc>
80104bca:	83 ec 04             	sub    $0x4,%esp
80104bcd:	53                   	push   %ebx
80104bce:	56                   	push   %esi
80104bcf:	ff 70 08             	push   0x8(%eax)
80104bd2:	e8 af 17 00 00       	call   80106386 <deallocuvm>
80104bd7:	89 c3                	mov    %eax,%ebx
80104bd9:	83 c4 10             	add    $0x10,%esp
80104bdc:	85 c0                	test   %eax,%eax
80104bde:	75 ce                	jne    80104bae <sys_sbrk+0x3a>
      return -1;
80104be0:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104be5:	eb cf                	jmp    80104bb6 <sys_sbrk+0x42>
    return -1;
80104be7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104bec:	eb c8                	jmp    80104bb6 <sys_sbrk+0x42>

80104bee <sys_sleep>:

int
sys_sleep(void)
{
80104bee:	55                   	push   %ebp
80104bef:	89 e5                	mov    %esp,%ebp
80104bf1:	53                   	push   %ebx
80104bf2:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104bf5:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104bf8:	50                   	push   %eax
80104bf9:	6a 00                	push   $0x0
80104bfb:	e8 b5 f1 ff ff       	call   80103db5 <argint>
80104c00:	83 c4 10             	add    $0x10,%esp
80104c03:	85 c0                	test   %eax,%eax
80104c05:	78 75                	js     80104c7c <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104c07:	83 ec 0c             	sub    $0xc,%esp
80104c0a:	68 80 3d 11 80       	push   $0x80113d80
80104c0f:	e8 bf ee ff ff       	call   80103ad3 <acquire>
  ticks0 = ticks;
80104c14:	8b 1d 60 3d 11 80    	mov    0x80113d60,%ebx
  while(ticks - ticks0 < n){
80104c1a:	83 c4 10             	add    $0x10,%esp
80104c1d:	a1 60 3d 11 80       	mov    0x80113d60,%eax
80104c22:	29 d8                	sub    %ebx,%eax
80104c24:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104c27:	73 39                	jae    80104c62 <sys_sleep+0x74>
    if(myproc()->killed){
80104c29:	e8 ec e4 ff ff       	call   8010311a <myproc>
80104c2e:	83 78 28 00          	cmpl   $0x0,0x28(%eax)
80104c32:	75 17                	jne    80104c4b <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104c34:	83 ec 08             	sub    $0x8,%esp
80104c37:	68 80 3d 11 80       	push   $0x80113d80
80104c3c:	68 60 3d 11 80       	push   $0x80113d60
80104c41:	e8 8b e9 ff ff       	call   801035d1 <sleep>
80104c46:	83 c4 10             	add    $0x10,%esp
80104c49:	eb d2                	jmp    80104c1d <sys_sleep+0x2f>
      release(&tickslock);
80104c4b:	83 ec 0c             	sub    $0xc,%esp
80104c4e:	68 80 3d 11 80       	push   $0x80113d80
80104c53:	e8 e0 ee ff ff       	call   80103b38 <release>
      return -1;
80104c58:	83 c4 10             	add    $0x10,%esp
80104c5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c60:	eb 15                	jmp    80104c77 <sys_sleep+0x89>
  }
  release(&tickslock);
80104c62:	83 ec 0c             	sub    $0xc,%esp
80104c65:	68 80 3d 11 80       	push   $0x80113d80
80104c6a:	e8 c9 ee ff ff       	call   80103b38 <release>
  return 0;
80104c6f:	83 c4 10             	add    $0x10,%esp
80104c72:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c7a:	c9                   	leave  
80104c7b:	c3                   	ret    
    return -1;
80104c7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c81:	eb f4                	jmp    80104c77 <sys_sleep+0x89>

80104c83 <sys_date>:

int
sys_date(void)
{
80104c83:	55                   	push   %ebp
80104c84:	89 e5                	mov    %esp,%ebp
80104c86:	83 ec 1c             	sub    $0x1c,%esp
 //Date tiene que recuperar el dato de la pila del usuario
 struct rtcdate *d;//Esto es lo que me pasa el usuario
 //vamos a usar argint para recuperar el argumento
 if(argptr(0, (void **) &d, sizeof(struct rtcdate)) < 0){//Le pasamos el rtcdate para que se rellene
80104c89:	6a 18                	push   $0x18
80104c8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c8e:	50                   	push   %eax
80104c8f:	6a 00                	push   $0x0
80104c91:	e8 47 f1 ff ff       	call   80103ddd <argptr>
80104c96:	83 c4 10             	add    $0x10,%esp
80104c99:	85 c0                	test   %eax,%eax
80104c9b:	78 15                	js     80104cb2 <sys_date+0x2f>
  return -1;
 }
 //Ahora una vez recuperado el arg -> Implementamos la syscall
 cmostime(d);//Esta función hace las veces de date
80104c9d:	83 ec 0c             	sub    $0xc,%esp
80104ca0:	ff 75 f4             	push   -0xc(%ebp)
80104ca3:	e8 07 d7 ff ff       	call   801023af <cmostime>
 return 0;
80104ca8:	83 c4 10             	add    $0x10,%esp
80104cab:	b8 00 00 00 00       	mov    $0x0,%eax

}
80104cb0:	c9                   	leave  
80104cb1:	c3                   	ret    
  return -1;
80104cb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cb7:	eb f7                	jmp    80104cb0 <sys_date+0x2d>

80104cb9 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104cb9:	55                   	push   %ebp
80104cba:	89 e5                	mov    %esp,%ebp
80104cbc:	53                   	push   %ebx
80104cbd:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104cc0:	68 80 3d 11 80       	push   $0x80113d80
80104cc5:	e8 09 ee ff ff       	call   80103ad3 <acquire>
  xticks = ticks;
80104cca:	8b 1d 60 3d 11 80    	mov    0x80113d60,%ebx
  release(&tickslock);
80104cd0:	c7 04 24 80 3d 11 80 	movl   $0x80113d80,(%esp)
80104cd7:	e8 5c ee ff ff       	call   80103b38 <release>
  return xticks;
}
80104cdc:	89 d8                	mov    %ebx,%eax
80104cde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ce1:	c9                   	leave  
80104ce2:	c3                   	ret    

80104ce3 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104ce3:	1e                   	push   %ds
  pushl %es
80104ce4:	06                   	push   %es
  pushl %fs
80104ce5:	0f a0                	push   %fs
  pushl %gs
80104ce7:	0f a8                	push   %gs
  pushal
80104ce9:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104cea:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104cee:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104cf0:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104cf2:	54                   	push   %esp
  call trap
80104cf3:	e8 2f 01 00 00       	call   80104e27 <trap>
  addl $4, %esp
80104cf8:	83 c4 04             	add    $0x4,%esp

80104cfb <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104cfb:	61                   	popa   
  popl %gs
80104cfc:	0f a9                	pop    %gs
  popl %fs
80104cfe:	0f a1                	pop    %fs
  popl %es
80104d00:	07                   	pop    %es
  popl %ds
80104d01:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104d02:	83 c4 08             	add    $0x8,%esp
  iret
80104d05:	cf                   	iret   

80104d06 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104d06:	55                   	push   %ebp
80104d07:	89 e5                	mov    %esp,%ebp
80104d09:	53                   	push   %ebx
80104d0a:	83 ec 04             	sub    $0x4,%esp
  int i;

  for(i = 0; i < 256; i++)
80104d0d:	b8 00 00 00 00       	mov    $0x0,%eax
80104d12:	eb 72                	jmp    80104d86 <tvinit+0x80>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104d14:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80104d1b:	66 89 0c c5 c0 3d 11 	mov    %cx,-0x7feec240(,%eax,8)
80104d22:	80 
80104d23:	66 c7 04 c5 c2 3d 11 	movw   $0x8,-0x7feec23e(,%eax,8)
80104d2a:	80 08 00 
80104d2d:	8a 14 c5 c4 3d 11 80 	mov    -0x7feec23c(,%eax,8),%dl
80104d34:	83 e2 e0             	and    $0xffffffe0,%edx
80104d37:	88 14 c5 c4 3d 11 80 	mov    %dl,-0x7feec23c(,%eax,8)
80104d3e:	c6 04 c5 c4 3d 11 80 	movb   $0x0,-0x7feec23c(,%eax,8)
80104d45:	00 
80104d46:	8a 14 c5 c5 3d 11 80 	mov    -0x7feec23b(,%eax,8),%dl
80104d4d:	83 e2 f0             	and    $0xfffffff0,%edx
80104d50:	83 ca 0e             	or     $0xe,%edx
80104d53:	88 14 c5 c5 3d 11 80 	mov    %dl,-0x7feec23b(,%eax,8)
80104d5a:	88 d3                	mov    %dl,%bl
80104d5c:	83 e3 ef             	and    $0xffffffef,%ebx
80104d5f:	88 1c c5 c5 3d 11 80 	mov    %bl,-0x7feec23b(,%eax,8)
80104d66:	83 e2 8f             	and    $0xffffff8f,%edx
80104d69:	88 14 c5 c5 3d 11 80 	mov    %dl,-0x7feec23b(,%eax,8)
80104d70:	83 ca 80             	or     $0xffffff80,%edx
80104d73:	88 14 c5 c5 3d 11 80 	mov    %dl,-0x7feec23b(,%eax,8)
80104d7a:	c1 e9 10             	shr    $0x10,%ecx
80104d7d:	66 89 0c c5 c6 3d 11 	mov    %cx,-0x7feec23a(,%eax,8)
80104d84:	80 
  for(i = 0; i < 256; i++)
80104d85:	40                   	inc    %eax
80104d86:	3d ff 00 00 00       	cmp    $0xff,%eax
80104d8b:	7e 87                	jle    80104d14 <tvinit+0xe>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104d8d:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80104d93:	66 89 15 c0 3f 11 80 	mov    %dx,0x80113fc0
80104d9a:	66 c7 05 c2 3f 11 80 	movw   $0x8,0x80113fc2
80104da1:	08 00 
80104da3:	a0 c4 3f 11 80       	mov    0x80113fc4,%al
80104da8:	83 e0 e0             	and    $0xffffffe0,%eax
80104dab:	a2 c4 3f 11 80       	mov    %al,0x80113fc4
80104db0:	c6 05 c4 3f 11 80 00 	movb   $0x0,0x80113fc4
80104db7:	a0 c5 3f 11 80       	mov    0x80113fc5,%al
80104dbc:	83 c8 0f             	or     $0xf,%eax
80104dbf:	a2 c5 3f 11 80       	mov    %al,0x80113fc5
80104dc4:	83 e0 ef             	and    $0xffffffef,%eax
80104dc7:	a2 c5 3f 11 80       	mov    %al,0x80113fc5
80104dcc:	88 c1                	mov    %al,%cl
80104dce:	83 c9 60             	or     $0x60,%ecx
80104dd1:	88 0d c5 3f 11 80    	mov    %cl,0x80113fc5
80104dd7:	83 c8 e0             	or     $0xffffffe0,%eax
80104dda:	a2 c5 3f 11 80       	mov    %al,0x80113fc5
80104ddf:	c1 ea 10             	shr    $0x10,%edx
80104de2:	66 89 15 c6 3f 11 80 	mov    %dx,0x80113fc6

  initlock(&tickslock, "time");
80104de9:	83 ec 08             	sub    $0x8,%esp
80104dec:	68 61 6f 10 80       	push   $0x80106f61
80104df1:	68 80 3d 11 80       	push   $0x80113d80
80104df6:	e8 a1 eb ff ff       	call   8010399c <initlock>
}
80104dfb:	83 c4 10             	add    $0x10,%esp
80104dfe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e01:	c9                   	leave  
80104e02:	c3                   	ret    

80104e03 <idtinit>:

void
idtinit(void)
{
80104e03:	55                   	push   %ebp
80104e04:	89 e5                	mov    %esp,%ebp
80104e06:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104e09:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104e0f:	b8 c0 3d 11 80       	mov    $0x80113dc0,%eax
80104e14:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104e18:	c1 e8 10             	shr    $0x10,%eax
80104e1b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104e1f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104e22:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104e25:	c9                   	leave  
80104e26:	c3                   	ret    

80104e27 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80104e27:	55                   	push   %ebp
80104e28:	89 e5                	mov    %esp,%ebp
80104e2a:	57                   	push   %edi
80104e2b:	56                   	push   %esi
80104e2c:	53                   	push   %ebx
80104e2d:	83 ec 2c             	sub    $0x2c,%esp
80104e30:	8b 75 08             	mov    0x8(%ebp),%esi
  int status = -1;

  if(tf->trapno == T_SYSCALL){
80104e33:	8b 46 30             	mov    0x30(%esi),%eax
80104e36:	83 f8 40             	cmp    $0x40,%eax
80104e39:	74 19                	je     80104e54 <trap+0x2d>
    if(myproc()->killed)
      exit(status);
    return;
  }

  status = tf->trapno+1;
80104e3b:	8d 48 01             	lea    0x1(%eax),%ecx
80104e3e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)

  switch(tf->trapno){
80104e41:	83 e8 0e             	sub    $0xe,%eax
80104e44:	83 f8 31             	cmp    $0x31,%eax
80104e47:	0f 87 c6 02 00 00    	ja     80105113 <trap+0x2ec>
80104e4d:	ff 24 85 ec 70 10 80 	jmp    *-0x7fef8f14(,%eax,4)
    if(myproc()->killed)
80104e54:	e8 c1 e2 ff ff       	call   8010311a <myproc>
80104e59:	83 78 28 00          	cmpl   $0x0,0x28(%eax)
80104e5d:	75 2b                	jne    80104e8a <trap+0x63>
    myproc()->tf = tf;
80104e5f:	e8 b6 e2 ff ff       	call   8010311a <myproc>
80104e64:	89 70 1c             	mov    %esi,0x1c(%eax)
    syscall();
80104e67:	e8 0d f0 ff ff       	call   80103e79 <syscall>
    if(myproc()->killed)
80104e6c:	e8 a9 e2 ff ff       	call   8010311a <myproc>
80104e71:	83 78 28 00          	cmpl   $0x0,0x28(%eax)
80104e75:	0f 84 8c 00 00 00    	je     80104f07 <trap+0xe0>
      exit(status);
80104e7b:	83 ec 0c             	sub    $0xc,%esp
80104e7e:	6a ff                	push   $0xffffffff
80104e80:	e8 40 e6 ff ff       	call   801034c5 <exit>
80104e85:	83 c4 10             	add    $0x10,%esp
    return;
80104e88:	eb 7d                	jmp    80104f07 <trap+0xe0>
      exit(status);
80104e8a:	83 ec 0c             	sub    $0xc,%esp
80104e8d:	6a ff                	push   $0xffffffff
80104e8f:	e8 31 e6 ff ff       	call   801034c5 <exit>
80104e94:	83 c4 10             	add    $0x10,%esp
80104e97:	eb c6                	jmp    80104e5f <trap+0x38>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80104e99:	e8 4b e2 ff ff       	call   801030e9 <cpuid>
80104e9e:	85 c0                	test   %eax,%eax
80104ea0:	74 6d                	je     80104f0f <trap+0xe8>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80104ea2:	e8 53 d4 ff ff       	call   801022fa <lapiceoi>
  }//fin switch

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104ea7:	e8 6e e2 ff ff       	call   8010311a <myproc>
80104eac:	85 c0                	test   %eax,%eax
80104eae:	74 1b                	je     80104ecb <trap+0xa4>
80104eb0:	e8 65 e2 ff ff       	call   8010311a <myproc>
80104eb5:	83 78 28 00          	cmpl   $0x0,0x28(%eax)
80104eb9:	74 10                	je     80104ecb <trap+0xa4>
80104ebb:	8b 46 3c             	mov    0x3c(%esi),%eax
80104ebe:	83 e0 03             	and    $0x3,%eax
80104ec1:	66 83 f8 03          	cmp    $0x3,%ax
80104ec5:	0f 84 db 02 00 00    	je     801051a6 <trap+0x37f>
    exit(status);
  }

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80104ecb:	e8 4a e2 ff ff       	call   8010311a <myproc>
80104ed0:	85 c0                	test   %eax,%eax
80104ed2:	74 0f                	je     80104ee3 <trap+0xbc>
80104ed4:	e8 41 e2 ff ff       	call   8010311a <myproc>
80104ed9:	83 78 10 04          	cmpl   $0x4,0x10(%eax)
80104edd:	0f 84 d6 02 00 00    	je     801051b9 <trap+0x392>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104ee3:	e8 32 e2 ff ff       	call   8010311a <myproc>
80104ee8:	85 c0                	test   %eax,%eax
80104eea:	74 1b                	je     80104f07 <trap+0xe0>
80104eec:	e8 29 e2 ff ff       	call   8010311a <myproc>
80104ef1:	83 78 28 00          	cmpl   $0x0,0x28(%eax)
80104ef5:	74 10                	je     80104f07 <trap+0xe0>
80104ef7:	8b 46 3c             	mov    0x3c(%esi),%eax
80104efa:	83 e0 03             	and    $0x3,%eax
80104efd:	66 83 f8 03          	cmp    $0x3,%ax
80104f01:	0f 84 c6 02 00 00    	je     801051cd <trap+0x3a6>
    exit(status);
}
80104f07:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104f0a:	5b                   	pop    %ebx
80104f0b:	5e                   	pop    %esi
80104f0c:	5f                   	pop    %edi
80104f0d:	5d                   	pop    %ebp
80104f0e:	c3                   	ret    
      acquire(&tickslock);
80104f0f:	83 ec 0c             	sub    $0xc,%esp
80104f12:	68 80 3d 11 80       	push   $0x80113d80
80104f17:	e8 b7 eb ff ff       	call   80103ad3 <acquire>
      ticks++;
80104f1c:	ff 05 60 3d 11 80    	incl   0x80113d60
      wakeup(&ticks);
80104f22:	c7 04 24 60 3d 11 80 	movl   $0x80113d60,(%esp)
80104f29:	e8 16 e8 ff ff       	call   80103744 <wakeup>
      release(&tickslock);
80104f2e:	c7 04 24 80 3d 11 80 	movl   $0x80113d80,(%esp)
80104f35:	e8 fe eb ff ff       	call   80103b38 <release>
80104f3a:	83 c4 10             	add    $0x10,%esp
80104f3d:	e9 60 ff ff ff       	jmp    80104ea2 <trap+0x7b>
    ideintr();
80104f42:	e8 9c cd ff ff       	call   80101ce3 <ideintr>
    lapiceoi();
80104f47:	e8 ae d3 ff ff       	call   801022fa <lapiceoi>
    break;
80104f4c:	e9 56 ff ff ff       	jmp    80104ea7 <trap+0x80>
    kbdintr();
80104f51:	e8 ee d1 ff ff       	call   80102144 <kbdintr>
    lapiceoi();
80104f56:	e8 9f d3 ff ff       	call   801022fa <lapiceoi>
    break;
80104f5b:	e9 47 ff ff ff       	jmp    80104ea7 <trap+0x80>
    uartintr();
80104f60:	e8 77 03 00 00       	call   801052dc <uartintr>
    lapiceoi();
80104f65:	e8 90 d3 ff ff       	call   801022fa <lapiceoi>
    break;
80104f6a:	e9 38 ff ff ff       	jmp    80104ea7 <trap+0x80>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80104f6f:	8b 7e 38             	mov    0x38(%esi),%edi
            cpuid(), tf->cs, tf->eip);
80104f72:	8b 5e 3c             	mov    0x3c(%esi),%ebx
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80104f75:	e8 6f e1 ff ff       	call   801030e9 <cpuid>
80104f7a:	57                   	push   %edi
80104f7b:	0f b7 db             	movzwl %bx,%ebx
80104f7e:	53                   	push   %ebx
80104f7f:	50                   	push   %eax
80104f80:	68 b8 6f 10 80       	push   $0x80106fb8
80104f85:	e8 50 b6 ff ff       	call   801005da <cprintf>
    lapiceoi();
80104f8a:	e8 6b d3 ff ff       	call   801022fa <lapiceoi>
    break;
80104f8f:	83 c4 10             	add    $0x10,%esp
80104f92:	e9 10 ff ff ff       	jmp    80104ea7 <trap+0x80>
  asm volatile("movl %%cr2,%0" : "=r" (val));
80104f97:	0f 20 d0             	mov    %cr2,%eax
		if(rcr2() >= KERNBASE)
80104f9a:	85 c0                	test   %eax,%eax
80104f9c:	78 27                	js     80104fc5 <trap+0x19e>
		if((tf->cs&3) == 0)
80104f9e:	f6 46 3c 03          	testb  $0x3,0x3c(%esi)
80104fa2:	75 42                	jne    80104fe6 <trap+0x1bf>
			cprintf("Hola soy el kernel y tengo un fallo de página\n");
80104fa4:	83 ec 0c             	sub    $0xc,%esp
80104fa7:	68 dc 6f 10 80       	push   $0x80106fdc
80104fac:	e8 29 b6 ff ff       	call   801005da <cprintf>
			myproc()->killed = 1;
80104fb1:	e8 64 e1 ff ff       	call   8010311a <myproc>
80104fb6:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
			break;
80104fbd:	83 c4 10             	add    $0x10,%esp
80104fc0:	e9 e2 fe ff ff       	jmp    80104ea7 <trap+0x80>
			cprintf("kernbase superado");
80104fc5:	83 ec 0c             	sub    $0xc,%esp
80104fc8:	68 66 6f 10 80       	push   $0x80106f66
80104fcd:	e8 08 b6 ff ff       	call   801005da <cprintf>
			myproc()->killed = 1;
80104fd2:	e8 43 e1 ff ff       	call   8010311a <myproc>
80104fd7:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
			break;
80104fde:	83 c4 10             	add    $0x10,%esp
80104fe1:	e9 c1 fe ff ff       	jmp    80104ea7 <trap+0x80>
            tf->err, cpuid(), tf->eip, rcr2(),myproc()->sz);
80104fe6:	e8 2f e1 ff ff       	call   8010311a <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80104feb:	8b 78 04             	mov    0x4(%eax),%edi
80104fee:	0f 20 d0             	mov    %cr2,%eax
80104ff1:	89 45 d0             	mov    %eax,-0x30(%ebp)
80104ff4:	8b 56 38             	mov    0x38(%esi),%edx
80104ff7:	89 55 e0             	mov    %edx,-0x20(%ebp)
80104ffa:	e8 ea e0 ff ff       	call   801030e9 <cpuid>
80104fff:	89 45 dc             	mov    %eax,-0x24(%ebp)
80105002:	8b 4e 34             	mov    0x34(%esi),%ecx
80105005:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80105008:	8b 5e 30             	mov    0x30(%esi),%ebx
            myproc()->pid, myproc()->name, tf->trapno,
8010500b:	e8 0a e1 ff ff       	call   8010311a <myproc>
80105010:	8d 50 70             	lea    0x70(%eax),%edx
80105013:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80105016:	e8 ff e0 ff ff       	call   8010311a <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010501b:	83 ec 0c             	sub    $0xc,%esp
8010501e:	57                   	push   %edi
8010501f:	ff 75 d0             	push   -0x30(%ebp)
80105022:	ff 75 e0             	push   -0x20(%ebp)
80105025:	ff 75 dc             	push   -0x24(%ebp)
80105028:	ff 75 d8             	push   -0x28(%ebp)
8010502b:	53                   	push   %ebx
8010502c:	ff 75 d4             	push   -0x2c(%ebp)
8010502f:	ff 70 14             	push   0x14(%eax)
80105032:	68 0c 70 10 80       	push   $0x8010700c
80105037:	e8 9e b5 ff ff       	call   801005da <cprintf>
		char *mem = kalloc();//Cogemos la página física
8010503c:	83 c4 30             	add    $0x30,%esp
8010503f:	e8 e4 cf ff ff       	call   80102028 <kalloc>
80105044:	89 c7                	mov    %eax,%edi
		if(mem == 0)
80105046:	85 c0                	test   %eax,%eax
80105048:	74 1a                	je     80105064 <trap+0x23d>
		memset(mem, 0, PGSIZE);//Pongo la página a 0 para entregarla
8010504a:	83 ec 04             	sub    $0x4,%esp
8010504d:	68 00 10 00 00       	push   $0x1000
80105052:	6a 00                	push   $0x0
80105054:	50                   	push   %eax
80105055:	e8 25 eb ff ff       	call   80103b7f <memset>
		for(int i=0; i<PGSIZE; i++)
8010505a:	83 c4 10             	add    $0x10,%esp
8010505d:	bb 00 00 00 00       	mov    $0x0,%ebx
80105062:	eb 22                	jmp    80105086 <trap+0x25f>
			cprintf("panic: kalloc didn't reserve page\n");
80105064:	83 ec 0c             	sub    $0xc,%esp
80105067:	68 50 70 10 80       	push   $0x80107050
8010506c:	e8 69 b5 ff ff       	call   801005da <cprintf>
			myproc()->killed = 1;
80105071:	e8 a4 e0 ff ff       	call   8010311a <myproc>
80105076:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
			break;
8010507d:	83 c4 10             	add    $0x10,%esp
80105080:	e9 22 fe ff ff       	jmp    80104ea7 <trap+0x80>
		for(int i=0; i<PGSIZE; i++)
80105085:	43                   	inc    %ebx
80105086:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
8010508c:	7f 18                	jg     801050a6 <trap+0x27f>
			if(mem[i]==1)
8010508e:	80 3c 1f 01          	cmpb   $0x1,(%edi,%ebx,1)
80105092:	75 f1                	jne    80105085 <trap+0x25e>
				cprintf("HAY UN 1\n");
80105094:	83 ec 0c             	sub    $0xc,%esp
80105097:	68 78 6f 10 80       	push   $0x80106f78
8010509c:	e8 39 b5 ff ff       	call   801005da <cprintf>
801050a1:	83 c4 10             	add    $0x10,%esp
801050a4:	eb df                	jmp    80105085 <trap+0x25e>
801050a6:	0f 20 d3             	mov    %cr2,%ebx
		if(mappages(myproc()->pgdir, (char *)PGROUNDDOWN(rcr2()), PGSIZE, V2P(mem), PTE_W | PTE_U) < 0)
801050a9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
801050af:	e8 66 e0 ff ff       	call   8010311a <myproc>
801050b4:	83 ec 0c             	sub    $0xc,%esp
801050b7:	6a 06                	push   $0x6
801050b9:	8d 97 00 00 00 80    	lea    -0x80000000(%edi),%edx
801050bf:	52                   	push   %edx
801050c0:	68 00 10 00 00       	push   $0x1000
801050c5:	53                   	push   %ebx
801050c6:	ff 70 08             	push   0x8(%eax)
801050c9:	e8 d6 0f 00 00       	call   801060a4 <mappages>
801050ce:	83 c4 20             	add    $0x20,%esp
801050d1:	85 c0                	test   %eax,%eax
801050d3:	78 15                	js     801050ea <trap+0x2c3>
		cprintf("Pagina concedida\n");
801050d5:	83 ec 0c             	sub    $0xc,%esp
801050d8:	68 9e 6f 10 80       	push   $0x80106f9e
801050dd:	e8 f8 b4 ff ff       	call   801005da <cprintf>
		break;
801050e2:	83 c4 10             	add    $0x10,%esp
801050e5:	e9 bd fd ff ff       	jmp    80104ea7 <trap+0x80>
      cprintf("allocuvm out of memory (2)\n");
801050ea:	83 ec 0c             	sub    $0xc,%esp
801050ed:	68 82 6f 10 80       	push   $0x80106f82
801050f2:	e8 e3 b4 ff ff       	call   801005da <cprintf>
      kfree(mem);
801050f7:	89 3c 24             	mov    %edi,(%esp)
801050fa:	e8 12 ce ff ff       	call   80101f11 <kfree>
			myproc()->killed = 1;
801050ff:	e8 16 e0 ff ff       	call   8010311a <myproc>
80105104:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
			break;
8010510b:	83 c4 10             	add    $0x10,%esp
8010510e:	e9 94 fd ff ff       	jmp    80104ea7 <trap+0x80>
		if(myproc() == 0 || (tf->cs&3) == 0){
80105113:	e8 02 e0 ff ff       	call   8010311a <myproc>
80105118:	85 c0                	test   %eax,%eax
8010511a:	74 5f                	je     8010517b <trap+0x354>
8010511c:	f6 46 3c 03          	testb  $0x3,0x3c(%esi)
80105120:	74 59                	je     8010517b <trap+0x354>
80105122:	0f 20 d7             	mov    %cr2,%edi
    cprintf("_pid %d %s: trap %d err %d on cpu %d "
80105125:	8b 46 38             	mov    0x38(%esi),%eax
80105128:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010512b:	e8 b9 df ff ff       	call   801030e9 <cpuid>
80105130:	89 45 dc             	mov    %eax,-0x24(%ebp)
80105133:	8b 56 34             	mov    0x34(%esi),%edx
80105136:	89 55 d8             	mov    %edx,-0x28(%ebp)
80105139:	8b 5e 30             	mov    0x30(%esi),%ebx
            myproc()->pid, myproc()->name, tf->trapno,
8010513c:	e8 d9 df ff ff       	call   8010311a <myproc>
80105141:	8d 48 70             	lea    0x70(%eax),%ecx
80105144:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
80105147:	e8 ce df ff ff       	call   8010311a <myproc>
    cprintf("_pid %d %s: trap %d err %d on cpu %d "
8010514c:	57                   	push   %edi
8010514d:	ff 75 e0             	push   -0x20(%ebp)
80105150:	ff 75 dc             	push   -0x24(%ebp)
80105153:	ff 75 d8             	push   -0x28(%ebp)
80105156:	53                   	push   %ebx
80105157:	ff 75 d4             	push   -0x2c(%ebp)
8010515a:	ff 70 14             	push   0x14(%eax)
8010515d:	68 a8 70 10 80       	push   $0x801070a8
80105162:	e8 73 b4 ff ff       	call   801005da <cprintf>
    myproc()->killed = 1;
80105167:	83 c4 20             	add    $0x20,%esp
8010516a:	e8 ab df ff ff       	call   8010311a <myproc>
8010516f:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
80105176:	e9 2c fd ff ff       	jmp    80104ea7 <trap+0x80>
8010517b:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010517e:	8b 5e 38             	mov    0x38(%esi),%ebx
80105181:	e8 63 df ff ff       	call   801030e9 <cpuid>
80105186:	83 ec 0c             	sub    $0xc,%esp
80105189:	57                   	push   %edi
8010518a:	53                   	push   %ebx
8010518b:	50                   	push   %eax
8010518c:	ff 76 30             	push   0x30(%esi)
8010518f:	68 74 70 10 80       	push   $0x80107074
80105194:	e8 41 b4 ff ff       	call   801005da <cprintf>
      panic("trap");
80105199:	83 c4 14             	add    $0x14,%esp
8010519c:	68 b0 6f 10 80       	push   $0x80106fb0
801051a1:	e8 9b b1 ff ff       	call   80100341 <panic>
    exit(status);
801051a6:	83 ec 0c             	sub    $0xc,%esp
801051a9:	ff 75 e4             	push   -0x1c(%ebp)
801051ac:	e8 14 e3 ff ff       	call   801034c5 <exit>
801051b1:	83 c4 10             	add    $0x10,%esp
801051b4:	e9 12 fd ff ff       	jmp    80104ecb <trap+0xa4>
  if(myproc() && myproc()->state == RUNNING &&
801051b9:	83 7e 30 20          	cmpl   $0x20,0x30(%esi)
801051bd:	0f 85 20 fd ff ff    	jne    80104ee3 <trap+0xbc>
    yield();
801051c3:	e8 d7 e3 ff ff       	call   8010359f <yield>
801051c8:	e9 16 fd ff ff       	jmp    80104ee3 <trap+0xbc>
    exit(status);
801051cd:	83 ec 0c             	sub    $0xc,%esp
801051d0:	ff 75 e4             	push   -0x1c(%ebp)
801051d3:	e8 ed e2 ff ff       	call   801034c5 <exit>
801051d8:	83 c4 10             	add    $0x10,%esp
801051db:	e9 27 fd ff ff       	jmp    80104f07 <trap+0xe0>

801051e0 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
801051e0:	83 3d c0 45 11 80 00 	cmpl   $0x0,0x801145c0
801051e7:	74 14                	je     801051fd <uartgetc+0x1d>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801051e9:	ba fd 03 00 00       	mov    $0x3fd,%edx
801051ee:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801051ef:	a8 01                	test   $0x1,%al
801051f1:	74 10                	je     80105203 <uartgetc+0x23>
801051f3:	ba f8 03 00 00       	mov    $0x3f8,%edx
801051f8:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801051f9:	0f b6 c0             	movzbl %al,%eax
801051fc:	c3                   	ret    
    return -1;
801051fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105202:	c3                   	ret    
    return -1;
80105203:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105208:	c3                   	ret    

80105209 <uartputc>:
  if(!uart)
80105209:	83 3d c0 45 11 80 00 	cmpl   $0x0,0x801145c0
80105210:	74 39                	je     8010524b <uartputc+0x42>
{
80105212:	55                   	push   %ebp
80105213:	89 e5                	mov    %esp,%ebp
80105215:	53                   	push   %ebx
80105216:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105219:	bb 00 00 00 00       	mov    $0x0,%ebx
8010521e:	eb 0e                	jmp    8010522e <uartputc+0x25>
    microdelay(10);
80105220:	83 ec 0c             	sub    $0xc,%esp
80105223:	6a 0a                	push   $0xa
80105225:	e8 f1 d0 ff ff       	call   8010231b <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010522a:	43                   	inc    %ebx
8010522b:	83 c4 10             	add    $0x10,%esp
8010522e:	83 fb 7f             	cmp    $0x7f,%ebx
80105231:	7f 0a                	jg     8010523d <uartputc+0x34>
80105233:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105238:	ec                   	in     (%dx),%al
80105239:	a8 20                	test   $0x20,%al
8010523b:	74 e3                	je     80105220 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010523d:	8b 45 08             	mov    0x8(%ebp),%eax
80105240:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105245:	ee                   	out    %al,(%dx)
}
80105246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105249:	c9                   	leave  
8010524a:	c3                   	ret    
8010524b:	c3                   	ret    

8010524c <uartinit>:
{
8010524c:	55                   	push   %ebp
8010524d:	89 e5                	mov    %esp,%ebp
8010524f:	56                   	push   %esi
80105250:	53                   	push   %ebx
80105251:	b1 00                	mov    $0x0,%cl
80105253:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105258:	88 c8                	mov    %cl,%al
8010525a:	ee                   	out    %al,(%dx)
8010525b:	be fb 03 00 00       	mov    $0x3fb,%esi
80105260:	b0 80                	mov    $0x80,%al
80105262:	89 f2                	mov    %esi,%edx
80105264:	ee                   	out    %al,(%dx)
80105265:	b0 0c                	mov    $0xc,%al
80105267:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010526c:	ee                   	out    %al,(%dx)
8010526d:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105272:	88 c8                	mov    %cl,%al
80105274:	89 da                	mov    %ebx,%edx
80105276:	ee                   	out    %al,(%dx)
80105277:	b0 03                	mov    $0x3,%al
80105279:	89 f2                	mov    %esi,%edx
8010527b:	ee                   	out    %al,(%dx)
8010527c:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105281:	88 c8                	mov    %cl,%al
80105283:	ee                   	out    %al,(%dx)
80105284:	b0 01                	mov    $0x1,%al
80105286:	89 da                	mov    %ebx,%edx
80105288:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105289:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010528e:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
8010528f:	3c ff                	cmp    $0xff,%al
80105291:	74 42                	je     801052d5 <uartinit+0x89>
  uart = 1;
80105293:	c7 05 c0 45 11 80 01 	movl   $0x1,0x801145c0
8010529a:	00 00 00 
8010529d:	ba fa 03 00 00       	mov    $0x3fa,%edx
801052a2:	ec                   	in     (%dx),%al
801052a3:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052a8:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801052a9:	83 ec 08             	sub    $0x8,%esp
801052ac:	6a 00                	push   $0x0
801052ae:	6a 04                	push   $0x4
801052b0:	e8 31 cc ff ff       	call   80101ee6 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801052b5:	83 c4 10             	add    $0x10,%esp
801052b8:	bb b4 71 10 80       	mov    $0x801071b4,%ebx
801052bd:	eb 10                	jmp    801052cf <uartinit+0x83>
    uartputc(*p);
801052bf:	83 ec 0c             	sub    $0xc,%esp
801052c2:	0f be c0             	movsbl %al,%eax
801052c5:	50                   	push   %eax
801052c6:	e8 3e ff ff ff       	call   80105209 <uartputc>
  for(p="xv6...\n"; *p; p++)
801052cb:	43                   	inc    %ebx
801052cc:	83 c4 10             	add    $0x10,%esp
801052cf:	8a 03                	mov    (%ebx),%al
801052d1:	84 c0                	test   %al,%al
801052d3:	75 ea                	jne    801052bf <uartinit+0x73>
}
801052d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
801052d8:	5b                   	pop    %ebx
801052d9:	5e                   	pop    %esi
801052da:	5d                   	pop    %ebp
801052db:	c3                   	ret    

801052dc <uartintr>:

void
uartintr(void)
{
801052dc:	55                   	push   %ebp
801052dd:	89 e5                	mov    %esp,%ebp
801052df:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801052e2:	68 e0 51 10 80       	push   $0x801051e0
801052e7:	e8 13 b4 ff ff       	call   801006ff <consoleintr>
}
801052ec:	83 c4 10             	add    $0x10,%esp
801052ef:	c9                   	leave  
801052f0:	c3                   	ret    

801052f1 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801052f1:	6a 00                	push   $0x0
  pushl $0
801052f3:	6a 00                	push   $0x0
  jmp alltraps
801052f5:	e9 e9 f9 ff ff       	jmp    80104ce3 <alltraps>

801052fa <vector1>:
.globl vector1
vector1:
  pushl $0
801052fa:	6a 00                	push   $0x0
  pushl $1
801052fc:	6a 01                	push   $0x1
  jmp alltraps
801052fe:	e9 e0 f9 ff ff       	jmp    80104ce3 <alltraps>

80105303 <vector2>:
.globl vector2
vector2:
  pushl $0
80105303:	6a 00                	push   $0x0
  pushl $2
80105305:	6a 02                	push   $0x2
  jmp alltraps
80105307:	e9 d7 f9 ff ff       	jmp    80104ce3 <alltraps>

8010530c <vector3>:
.globl vector3
vector3:
  pushl $0
8010530c:	6a 00                	push   $0x0
  pushl $3
8010530e:	6a 03                	push   $0x3
  jmp alltraps
80105310:	e9 ce f9 ff ff       	jmp    80104ce3 <alltraps>

80105315 <vector4>:
.globl vector4
vector4:
  pushl $0
80105315:	6a 00                	push   $0x0
  pushl $4
80105317:	6a 04                	push   $0x4
  jmp alltraps
80105319:	e9 c5 f9 ff ff       	jmp    80104ce3 <alltraps>

8010531e <vector5>:
.globl vector5
vector5:
  pushl $0
8010531e:	6a 00                	push   $0x0
  pushl $5
80105320:	6a 05                	push   $0x5
  jmp alltraps
80105322:	e9 bc f9 ff ff       	jmp    80104ce3 <alltraps>

80105327 <vector6>:
.globl vector6
vector6:
  pushl $0
80105327:	6a 00                	push   $0x0
  pushl $6
80105329:	6a 06                	push   $0x6
  jmp alltraps
8010532b:	e9 b3 f9 ff ff       	jmp    80104ce3 <alltraps>

80105330 <vector7>:
.globl vector7
vector7:
  pushl $0
80105330:	6a 00                	push   $0x0
  pushl $7
80105332:	6a 07                	push   $0x7
  jmp alltraps
80105334:	e9 aa f9 ff ff       	jmp    80104ce3 <alltraps>

80105339 <vector8>:
.globl vector8
vector8:
  pushl $8
80105339:	6a 08                	push   $0x8
  jmp alltraps
8010533b:	e9 a3 f9 ff ff       	jmp    80104ce3 <alltraps>

80105340 <vector9>:
.globl vector9
vector9:
  pushl $0
80105340:	6a 00                	push   $0x0
  pushl $9
80105342:	6a 09                	push   $0x9
  jmp alltraps
80105344:	e9 9a f9 ff ff       	jmp    80104ce3 <alltraps>

80105349 <vector10>:
.globl vector10
vector10:
  pushl $10
80105349:	6a 0a                	push   $0xa
  jmp alltraps
8010534b:	e9 93 f9 ff ff       	jmp    80104ce3 <alltraps>

80105350 <vector11>:
.globl vector11
vector11:
  pushl $11
80105350:	6a 0b                	push   $0xb
  jmp alltraps
80105352:	e9 8c f9 ff ff       	jmp    80104ce3 <alltraps>

80105357 <vector12>:
.globl vector12
vector12:
  pushl $12
80105357:	6a 0c                	push   $0xc
  jmp alltraps
80105359:	e9 85 f9 ff ff       	jmp    80104ce3 <alltraps>

8010535e <vector13>:
.globl vector13
vector13:
  pushl $13
8010535e:	6a 0d                	push   $0xd
  jmp alltraps
80105360:	e9 7e f9 ff ff       	jmp    80104ce3 <alltraps>

80105365 <vector14>:
.globl vector14
vector14:
  pushl $14
80105365:	6a 0e                	push   $0xe
  jmp alltraps
80105367:	e9 77 f9 ff ff       	jmp    80104ce3 <alltraps>

8010536c <vector15>:
.globl vector15
vector15:
  pushl $0
8010536c:	6a 00                	push   $0x0
  pushl $15
8010536e:	6a 0f                	push   $0xf
  jmp alltraps
80105370:	e9 6e f9 ff ff       	jmp    80104ce3 <alltraps>

80105375 <vector16>:
.globl vector16
vector16:
  pushl $0
80105375:	6a 00                	push   $0x0
  pushl $16
80105377:	6a 10                	push   $0x10
  jmp alltraps
80105379:	e9 65 f9 ff ff       	jmp    80104ce3 <alltraps>

8010537e <vector17>:
.globl vector17
vector17:
  pushl $17
8010537e:	6a 11                	push   $0x11
  jmp alltraps
80105380:	e9 5e f9 ff ff       	jmp    80104ce3 <alltraps>

80105385 <vector18>:
.globl vector18
vector18:
  pushl $0
80105385:	6a 00                	push   $0x0
  pushl $18
80105387:	6a 12                	push   $0x12
  jmp alltraps
80105389:	e9 55 f9 ff ff       	jmp    80104ce3 <alltraps>

8010538e <vector19>:
.globl vector19
vector19:
  pushl $0
8010538e:	6a 00                	push   $0x0
  pushl $19
80105390:	6a 13                	push   $0x13
  jmp alltraps
80105392:	e9 4c f9 ff ff       	jmp    80104ce3 <alltraps>

80105397 <vector20>:
.globl vector20
vector20:
  pushl $0
80105397:	6a 00                	push   $0x0
  pushl $20
80105399:	6a 14                	push   $0x14
  jmp alltraps
8010539b:	e9 43 f9 ff ff       	jmp    80104ce3 <alltraps>

801053a0 <vector21>:
.globl vector21
vector21:
  pushl $0
801053a0:	6a 00                	push   $0x0
  pushl $21
801053a2:	6a 15                	push   $0x15
  jmp alltraps
801053a4:	e9 3a f9 ff ff       	jmp    80104ce3 <alltraps>

801053a9 <vector22>:
.globl vector22
vector22:
  pushl $0
801053a9:	6a 00                	push   $0x0
  pushl $22
801053ab:	6a 16                	push   $0x16
  jmp alltraps
801053ad:	e9 31 f9 ff ff       	jmp    80104ce3 <alltraps>

801053b2 <vector23>:
.globl vector23
vector23:
  pushl $0
801053b2:	6a 00                	push   $0x0
  pushl $23
801053b4:	6a 17                	push   $0x17
  jmp alltraps
801053b6:	e9 28 f9 ff ff       	jmp    80104ce3 <alltraps>

801053bb <vector24>:
.globl vector24
vector24:
  pushl $0
801053bb:	6a 00                	push   $0x0
  pushl $24
801053bd:	6a 18                	push   $0x18
  jmp alltraps
801053bf:	e9 1f f9 ff ff       	jmp    80104ce3 <alltraps>

801053c4 <vector25>:
.globl vector25
vector25:
  pushl $0
801053c4:	6a 00                	push   $0x0
  pushl $25
801053c6:	6a 19                	push   $0x19
  jmp alltraps
801053c8:	e9 16 f9 ff ff       	jmp    80104ce3 <alltraps>

801053cd <vector26>:
.globl vector26
vector26:
  pushl $0
801053cd:	6a 00                	push   $0x0
  pushl $26
801053cf:	6a 1a                	push   $0x1a
  jmp alltraps
801053d1:	e9 0d f9 ff ff       	jmp    80104ce3 <alltraps>

801053d6 <vector27>:
.globl vector27
vector27:
  pushl $0
801053d6:	6a 00                	push   $0x0
  pushl $27
801053d8:	6a 1b                	push   $0x1b
  jmp alltraps
801053da:	e9 04 f9 ff ff       	jmp    80104ce3 <alltraps>

801053df <vector28>:
.globl vector28
vector28:
  pushl $0
801053df:	6a 00                	push   $0x0
  pushl $28
801053e1:	6a 1c                	push   $0x1c
  jmp alltraps
801053e3:	e9 fb f8 ff ff       	jmp    80104ce3 <alltraps>

801053e8 <vector29>:
.globl vector29
vector29:
  pushl $0
801053e8:	6a 00                	push   $0x0
  pushl $29
801053ea:	6a 1d                	push   $0x1d
  jmp alltraps
801053ec:	e9 f2 f8 ff ff       	jmp    80104ce3 <alltraps>

801053f1 <vector30>:
.globl vector30
vector30:
  pushl $0
801053f1:	6a 00                	push   $0x0
  pushl $30
801053f3:	6a 1e                	push   $0x1e
  jmp alltraps
801053f5:	e9 e9 f8 ff ff       	jmp    80104ce3 <alltraps>

801053fa <vector31>:
.globl vector31
vector31:
  pushl $0
801053fa:	6a 00                	push   $0x0
  pushl $31
801053fc:	6a 1f                	push   $0x1f
  jmp alltraps
801053fe:	e9 e0 f8 ff ff       	jmp    80104ce3 <alltraps>

80105403 <vector32>:
.globl vector32
vector32:
  pushl $0
80105403:	6a 00                	push   $0x0
  pushl $32
80105405:	6a 20                	push   $0x20
  jmp alltraps
80105407:	e9 d7 f8 ff ff       	jmp    80104ce3 <alltraps>

8010540c <vector33>:
.globl vector33
vector33:
  pushl $0
8010540c:	6a 00                	push   $0x0
  pushl $33
8010540e:	6a 21                	push   $0x21
  jmp alltraps
80105410:	e9 ce f8 ff ff       	jmp    80104ce3 <alltraps>

80105415 <vector34>:
.globl vector34
vector34:
  pushl $0
80105415:	6a 00                	push   $0x0
  pushl $34
80105417:	6a 22                	push   $0x22
  jmp alltraps
80105419:	e9 c5 f8 ff ff       	jmp    80104ce3 <alltraps>

8010541e <vector35>:
.globl vector35
vector35:
  pushl $0
8010541e:	6a 00                	push   $0x0
  pushl $35
80105420:	6a 23                	push   $0x23
  jmp alltraps
80105422:	e9 bc f8 ff ff       	jmp    80104ce3 <alltraps>

80105427 <vector36>:
.globl vector36
vector36:
  pushl $0
80105427:	6a 00                	push   $0x0
  pushl $36
80105429:	6a 24                	push   $0x24
  jmp alltraps
8010542b:	e9 b3 f8 ff ff       	jmp    80104ce3 <alltraps>

80105430 <vector37>:
.globl vector37
vector37:
  pushl $0
80105430:	6a 00                	push   $0x0
  pushl $37
80105432:	6a 25                	push   $0x25
  jmp alltraps
80105434:	e9 aa f8 ff ff       	jmp    80104ce3 <alltraps>

80105439 <vector38>:
.globl vector38
vector38:
  pushl $0
80105439:	6a 00                	push   $0x0
  pushl $38
8010543b:	6a 26                	push   $0x26
  jmp alltraps
8010543d:	e9 a1 f8 ff ff       	jmp    80104ce3 <alltraps>

80105442 <vector39>:
.globl vector39
vector39:
  pushl $0
80105442:	6a 00                	push   $0x0
  pushl $39
80105444:	6a 27                	push   $0x27
  jmp alltraps
80105446:	e9 98 f8 ff ff       	jmp    80104ce3 <alltraps>

8010544b <vector40>:
.globl vector40
vector40:
  pushl $0
8010544b:	6a 00                	push   $0x0
  pushl $40
8010544d:	6a 28                	push   $0x28
  jmp alltraps
8010544f:	e9 8f f8 ff ff       	jmp    80104ce3 <alltraps>

80105454 <vector41>:
.globl vector41
vector41:
  pushl $0
80105454:	6a 00                	push   $0x0
  pushl $41
80105456:	6a 29                	push   $0x29
  jmp alltraps
80105458:	e9 86 f8 ff ff       	jmp    80104ce3 <alltraps>

8010545d <vector42>:
.globl vector42
vector42:
  pushl $0
8010545d:	6a 00                	push   $0x0
  pushl $42
8010545f:	6a 2a                	push   $0x2a
  jmp alltraps
80105461:	e9 7d f8 ff ff       	jmp    80104ce3 <alltraps>

80105466 <vector43>:
.globl vector43
vector43:
  pushl $0
80105466:	6a 00                	push   $0x0
  pushl $43
80105468:	6a 2b                	push   $0x2b
  jmp alltraps
8010546a:	e9 74 f8 ff ff       	jmp    80104ce3 <alltraps>

8010546f <vector44>:
.globl vector44
vector44:
  pushl $0
8010546f:	6a 00                	push   $0x0
  pushl $44
80105471:	6a 2c                	push   $0x2c
  jmp alltraps
80105473:	e9 6b f8 ff ff       	jmp    80104ce3 <alltraps>

80105478 <vector45>:
.globl vector45
vector45:
  pushl $0
80105478:	6a 00                	push   $0x0
  pushl $45
8010547a:	6a 2d                	push   $0x2d
  jmp alltraps
8010547c:	e9 62 f8 ff ff       	jmp    80104ce3 <alltraps>

80105481 <vector46>:
.globl vector46
vector46:
  pushl $0
80105481:	6a 00                	push   $0x0
  pushl $46
80105483:	6a 2e                	push   $0x2e
  jmp alltraps
80105485:	e9 59 f8 ff ff       	jmp    80104ce3 <alltraps>

8010548a <vector47>:
.globl vector47
vector47:
  pushl $0
8010548a:	6a 00                	push   $0x0
  pushl $47
8010548c:	6a 2f                	push   $0x2f
  jmp alltraps
8010548e:	e9 50 f8 ff ff       	jmp    80104ce3 <alltraps>

80105493 <vector48>:
.globl vector48
vector48:
  pushl $0
80105493:	6a 00                	push   $0x0
  pushl $48
80105495:	6a 30                	push   $0x30
  jmp alltraps
80105497:	e9 47 f8 ff ff       	jmp    80104ce3 <alltraps>

8010549c <vector49>:
.globl vector49
vector49:
  pushl $0
8010549c:	6a 00                	push   $0x0
  pushl $49
8010549e:	6a 31                	push   $0x31
  jmp alltraps
801054a0:	e9 3e f8 ff ff       	jmp    80104ce3 <alltraps>

801054a5 <vector50>:
.globl vector50
vector50:
  pushl $0
801054a5:	6a 00                	push   $0x0
  pushl $50
801054a7:	6a 32                	push   $0x32
  jmp alltraps
801054a9:	e9 35 f8 ff ff       	jmp    80104ce3 <alltraps>

801054ae <vector51>:
.globl vector51
vector51:
  pushl $0
801054ae:	6a 00                	push   $0x0
  pushl $51
801054b0:	6a 33                	push   $0x33
  jmp alltraps
801054b2:	e9 2c f8 ff ff       	jmp    80104ce3 <alltraps>

801054b7 <vector52>:
.globl vector52
vector52:
  pushl $0
801054b7:	6a 00                	push   $0x0
  pushl $52
801054b9:	6a 34                	push   $0x34
  jmp alltraps
801054bb:	e9 23 f8 ff ff       	jmp    80104ce3 <alltraps>

801054c0 <vector53>:
.globl vector53
vector53:
  pushl $0
801054c0:	6a 00                	push   $0x0
  pushl $53
801054c2:	6a 35                	push   $0x35
  jmp alltraps
801054c4:	e9 1a f8 ff ff       	jmp    80104ce3 <alltraps>

801054c9 <vector54>:
.globl vector54
vector54:
  pushl $0
801054c9:	6a 00                	push   $0x0
  pushl $54
801054cb:	6a 36                	push   $0x36
  jmp alltraps
801054cd:	e9 11 f8 ff ff       	jmp    80104ce3 <alltraps>

801054d2 <vector55>:
.globl vector55
vector55:
  pushl $0
801054d2:	6a 00                	push   $0x0
  pushl $55
801054d4:	6a 37                	push   $0x37
  jmp alltraps
801054d6:	e9 08 f8 ff ff       	jmp    80104ce3 <alltraps>

801054db <vector56>:
.globl vector56
vector56:
  pushl $0
801054db:	6a 00                	push   $0x0
  pushl $56
801054dd:	6a 38                	push   $0x38
  jmp alltraps
801054df:	e9 ff f7 ff ff       	jmp    80104ce3 <alltraps>

801054e4 <vector57>:
.globl vector57
vector57:
  pushl $0
801054e4:	6a 00                	push   $0x0
  pushl $57
801054e6:	6a 39                	push   $0x39
  jmp alltraps
801054e8:	e9 f6 f7 ff ff       	jmp    80104ce3 <alltraps>

801054ed <vector58>:
.globl vector58
vector58:
  pushl $0
801054ed:	6a 00                	push   $0x0
  pushl $58
801054ef:	6a 3a                	push   $0x3a
  jmp alltraps
801054f1:	e9 ed f7 ff ff       	jmp    80104ce3 <alltraps>

801054f6 <vector59>:
.globl vector59
vector59:
  pushl $0
801054f6:	6a 00                	push   $0x0
  pushl $59
801054f8:	6a 3b                	push   $0x3b
  jmp alltraps
801054fa:	e9 e4 f7 ff ff       	jmp    80104ce3 <alltraps>

801054ff <vector60>:
.globl vector60
vector60:
  pushl $0
801054ff:	6a 00                	push   $0x0
  pushl $60
80105501:	6a 3c                	push   $0x3c
  jmp alltraps
80105503:	e9 db f7 ff ff       	jmp    80104ce3 <alltraps>

80105508 <vector61>:
.globl vector61
vector61:
  pushl $0
80105508:	6a 00                	push   $0x0
  pushl $61
8010550a:	6a 3d                	push   $0x3d
  jmp alltraps
8010550c:	e9 d2 f7 ff ff       	jmp    80104ce3 <alltraps>

80105511 <vector62>:
.globl vector62
vector62:
  pushl $0
80105511:	6a 00                	push   $0x0
  pushl $62
80105513:	6a 3e                	push   $0x3e
  jmp alltraps
80105515:	e9 c9 f7 ff ff       	jmp    80104ce3 <alltraps>

8010551a <vector63>:
.globl vector63
vector63:
  pushl $0
8010551a:	6a 00                	push   $0x0
  pushl $63
8010551c:	6a 3f                	push   $0x3f
  jmp alltraps
8010551e:	e9 c0 f7 ff ff       	jmp    80104ce3 <alltraps>

80105523 <vector64>:
.globl vector64
vector64:
  pushl $0
80105523:	6a 00                	push   $0x0
  pushl $64
80105525:	6a 40                	push   $0x40
  jmp alltraps
80105527:	e9 b7 f7 ff ff       	jmp    80104ce3 <alltraps>

8010552c <vector65>:
.globl vector65
vector65:
  pushl $0
8010552c:	6a 00                	push   $0x0
  pushl $65
8010552e:	6a 41                	push   $0x41
  jmp alltraps
80105530:	e9 ae f7 ff ff       	jmp    80104ce3 <alltraps>

80105535 <vector66>:
.globl vector66
vector66:
  pushl $0
80105535:	6a 00                	push   $0x0
  pushl $66
80105537:	6a 42                	push   $0x42
  jmp alltraps
80105539:	e9 a5 f7 ff ff       	jmp    80104ce3 <alltraps>

8010553e <vector67>:
.globl vector67
vector67:
  pushl $0
8010553e:	6a 00                	push   $0x0
  pushl $67
80105540:	6a 43                	push   $0x43
  jmp alltraps
80105542:	e9 9c f7 ff ff       	jmp    80104ce3 <alltraps>

80105547 <vector68>:
.globl vector68
vector68:
  pushl $0
80105547:	6a 00                	push   $0x0
  pushl $68
80105549:	6a 44                	push   $0x44
  jmp alltraps
8010554b:	e9 93 f7 ff ff       	jmp    80104ce3 <alltraps>

80105550 <vector69>:
.globl vector69
vector69:
  pushl $0
80105550:	6a 00                	push   $0x0
  pushl $69
80105552:	6a 45                	push   $0x45
  jmp alltraps
80105554:	e9 8a f7 ff ff       	jmp    80104ce3 <alltraps>

80105559 <vector70>:
.globl vector70
vector70:
  pushl $0
80105559:	6a 00                	push   $0x0
  pushl $70
8010555b:	6a 46                	push   $0x46
  jmp alltraps
8010555d:	e9 81 f7 ff ff       	jmp    80104ce3 <alltraps>

80105562 <vector71>:
.globl vector71
vector71:
  pushl $0
80105562:	6a 00                	push   $0x0
  pushl $71
80105564:	6a 47                	push   $0x47
  jmp alltraps
80105566:	e9 78 f7 ff ff       	jmp    80104ce3 <alltraps>

8010556b <vector72>:
.globl vector72
vector72:
  pushl $0
8010556b:	6a 00                	push   $0x0
  pushl $72
8010556d:	6a 48                	push   $0x48
  jmp alltraps
8010556f:	e9 6f f7 ff ff       	jmp    80104ce3 <alltraps>

80105574 <vector73>:
.globl vector73
vector73:
  pushl $0
80105574:	6a 00                	push   $0x0
  pushl $73
80105576:	6a 49                	push   $0x49
  jmp alltraps
80105578:	e9 66 f7 ff ff       	jmp    80104ce3 <alltraps>

8010557d <vector74>:
.globl vector74
vector74:
  pushl $0
8010557d:	6a 00                	push   $0x0
  pushl $74
8010557f:	6a 4a                	push   $0x4a
  jmp alltraps
80105581:	e9 5d f7 ff ff       	jmp    80104ce3 <alltraps>

80105586 <vector75>:
.globl vector75
vector75:
  pushl $0
80105586:	6a 00                	push   $0x0
  pushl $75
80105588:	6a 4b                	push   $0x4b
  jmp alltraps
8010558a:	e9 54 f7 ff ff       	jmp    80104ce3 <alltraps>

8010558f <vector76>:
.globl vector76
vector76:
  pushl $0
8010558f:	6a 00                	push   $0x0
  pushl $76
80105591:	6a 4c                	push   $0x4c
  jmp alltraps
80105593:	e9 4b f7 ff ff       	jmp    80104ce3 <alltraps>

80105598 <vector77>:
.globl vector77
vector77:
  pushl $0
80105598:	6a 00                	push   $0x0
  pushl $77
8010559a:	6a 4d                	push   $0x4d
  jmp alltraps
8010559c:	e9 42 f7 ff ff       	jmp    80104ce3 <alltraps>

801055a1 <vector78>:
.globl vector78
vector78:
  pushl $0
801055a1:	6a 00                	push   $0x0
  pushl $78
801055a3:	6a 4e                	push   $0x4e
  jmp alltraps
801055a5:	e9 39 f7 ff ff       	jmp    80104ce3 <alltraps>

801055aa <vector79>:
.globl vector79
vector79:
  pushl $0
801055aa:	6a 00                	push   $0x0
  pushl $79
801055ac:	6a 4f                	push   $0x4f
  jmp alltraps
801055ae:	e9 30 f7 ff ff       	jmp    80104ce3 <alltraps>

801055b3 <vector80>:
.globl vector80
vector80:
  pushl $0
801055b3:	6a 00                	push   $0x0
  pushl $80
801055b5:	6a 50                	push   $0x50
  jmp alltraps
801055b7:	e9 27 f7 ff ff       	jmp    80104ce3 <alltraps>

801055bc <vector81>:
.globl vector81
vector81:
  pushl $0
801055bc:	6a 00                	push   $0x0
  pushl $81
801055be:	6a 51                	push   $0x51
  jmp alltraps
801055c0:	e9 1e f7 ff ff       	jmp    80104ce3 <alltraps>

801055c5 <vector82>:
.globl vector82
vector82:
  pushl $0
801055c5:	6a 00                	push   $0x0
  pushl $82
801055c7:	6a 52                	push   $0x52
  jmp alltraps
801055c9:	e9 15 f7 ff ff       	jmp    80104ce3 <alltraps>

801055ce <vector83>:
.globl vector83
vector83:
  pushl $0
801055ce:	6a 00                	push   $0x0
  pushl $83
801055d0:	6a 53                	push   $0x53
  jmp alltraps
801055d2:	e9 0c f7 ff ff       	jmp    80104ce3 <alltraps>

801055d7 <vector84>:
.globl vector84
vector84:
  pushl $0
801055d7:	6a 00                	push   $0x0
  pushl $84
801055d9:	6a 54                	push   $0x54
  jmp alltraps
801055db:	e9 03 f7 ff ff       	jmp    80104ce3 <alltraps>

801055e0 <vector85>:
.globl vector85
vector85:
  pushl $0
801055e0:	6a 00                	push   $0x0
  pushl $85
801055e2:	6a 55                	push   $0x55
  jmp alltraps
801055e4:	e9 fa f6 ff ff       	jmp    80104ce3 <alltraps>

801055e9 <vector86>:
.globl vector86
vector86:
  pushl $0
801055e9:	6a 00                	push   $0x0
  pushl $86
801055eb:	6a 56                	push   $0x56
  jmp alltraps
801055ed:	e9 f1 f6 ff ff       	jmp    80104ce3 <alltraps>

801055f2 <vector87>:
.globl vector87
vector87:
  pushl $0
801055f2:	6a 00                	push   $0x0
  pushl $87
801055f4:	6a 57                	push   $0x57
  jmp alltraps
801055f6:	e9 e8 f6 ff ff       	jmp    80104ce3 <alltraps>

801055fb <vector88>:
.globl vector88
vector88:
  pushl $0
801055fb:	6a 00                	push   $0x0
  pushl $88
801055fd:	6a 58                	push   $0x58
  jmp alltraps
801055ff:	e9 df f6 ff ff       	jmp    80104ce3 <alltraps>

80105604 <vector89>:
.globl vector89
vector89:
  pushl $0
80105604:	6a 00                	push   $0x0
  pushl $89
80105606:	6a 59                	push   $0x59
  jmp alltraps
80105608:	e9 d6 f6 ff ff       	jmp    80104ce3 <alltraps>

8010560d <vector90>:
.globl vector90
vector90:
  pushl $0
8010560d:	6a 00                	push   $0x0
  pushl $90
8010560f:	6a 5a                	push   $0x5a
  jmp alltraps
80105611:	e9 cd f6 ff ff       	jmp    80104ce3 <alltraps>

80105616 <vector91>:
.globl vector91
vector91:
  pushl $0
80105616:	6a 00                	push   $0x0
  pushl $91
80105618:	6a 5b                	push   $0x5b
  jmp alltraps
8010561a:	e9 c4 f6 ff ff       	jmp    80104ce3 <alltraps>

8010561f <vector92>:
.globl vector92
vector92:
  pushl $0
8010561f:	6a 00                	push   $0x0
  pushl $92
80105621:	6a 5c                	push   $0x5c
  jmp alltraps
80105623:	e9 bb f6 ff ff       	jmp    80104ce3 <alltraps>

80105628 <vector93>:
.globl vector93
vector93:
  pushl $0
80105628:	6a 00                	push   $0x0
  pushl $93
8010562a:	6a 5d                	push   $0x5d
  jmp alltraps
8010562c:	e9 b2 f6 ff ff       	jmp    80104ce3 <alltraps>

80105631 <vector94>:
.globl vector94
vector94:
  pushl $0
80105631:	6a 00                	push   $0x0
  pushl $94
80105633:	6a 5e                	push   $0x5e
  jmp alltraps
80105635:	e9 a9 f6 ff ff       	jmp    80104ce3 <alltraps>

8010563a <vector95>:
.globl vector95
vector95:
  pushl $0
8010563a:	6a 00                	push   $0x0
  pushl $95
8010563c:	6a 5f                	push   $0x5f
  jmp alltraps
8010563e:	e9 a0 f6 ff ff       	jmp    80104ce3 <alltraps>

80105643 <vector96>:
.globl vector96
vector96:
  pushl $0
80105643:	6a 00                	push   $0x0
  pushl $96
80105645:	6a 60                	push   $0x60
  jmp alltraps
80105647:	e9 97 f6 ff ff       	jmp    80104ce3 <alltraps>

8010564c <vector97>:
.globl vector97
vector97:
  pushl $0
8010564c:	6a 00                	push   $0x0
  pushl $97
8010564e:	6a 61                	push   $0x61
  jmp alltraps
80105650:	e9 8e f6 ff ff       	jmp    80104ce3 <alltraps>

80105655 <vector98>:
.globl vector98
vector98:
  pushl $0
80105655:	6a 00                	push   $0x0
  pushl $98
80105657:	6a 62                	push   $0x62
  jmp alltraps
80105659:	e9 85 f6 ff ff       	jmp    80104ce3 <alltraps>

8010565e <vector99>:
.globl vector99
vector99:
  pushl $0
8010565e:	6a 00                	push   $0x0
  pushl $99
80105660:	6a 63                	push   $0x63
  jmp alltraps
80105662:	e9 7c f6 ff ff       	jmp    80104ce3 <alltraps>

80105667 <vector100>:
.globl vector100
vector100:
  pushl $0
80105667:	6a 00                	push   $0x0
  pushl $100
80105669:	6a 64                	push   $0x64
  jmp alltraps
8010566b:	e9 73 f6 ff ff       	jmp    80104ce3 <alltraps>

80105670 <vector101>:
.globl vector101
vector101:
  pushl $0
80105670:	6a 00                	push   $0x0
  pushl $101
80105672:	6a 65                	push   $0x65
  jmp alltraps
80105674:	e9 6a f6 ff ff       	jmp    80104ce3 <alltraps>

80105679 <vector102>:
.globl vector102
vector102:
  pushl $0
80105679:	6a 00                	push   $0x0
  pushl $102
8010567b:	6a 66                	push   $0x66
  jmp alltraps
8010567d:	e9 61 f6 ff ff       	jmp    80104ce3 <alltraps>

80105682 <vector103>:
.globl vector103
vector103:
  pushl $0
80105682:	6a 00                	push   $0x0
  pushl $103
80105684:	6a 67                	push   $0x67
  jmp alltraps
80105686:	e9 58 f6 ff ff       	jmp    80104ce3 <alltraps>

8010568b <vector104>:
.globl vector104
vector104:
  pushl $0
8010568b:	6a 00                	push   $0x0
  pushl $104
8010568d:	6a 68                	push   $0x68
  jmp alltraps
8010568f:	e9 4f f6 ff ff       	jmp    80104ce3 <alltraps>

80105694 <vector105>:
.globl vector105
vector105:
  pushl $0
80105694:	6a 00                	push   $0x0
  pushl $105
80105696:	6a 69                	push   $0x69
  jmp alltraps
80105698:	e9 46 f6 ff ff       	jmp    80104ce3 <alltraps>

8010569d <vector106>:
.globl vector106
vector106:
  pushl $0
8010569d:	6a 00                	push   $0x0
  pushl $106
8010569f:	6a 6a                	push   $0x6a
  jmp alltraps
801056a1:	e9 3d f6 ff ff       	jmp    80104ce3 <alltraps>

801056a6 <vector107>:
.globl vector107
vector107:
  pushl $0
801056a6:	6a 00                	push   $0x0
  pushl $107
801056a8:	6a 6b                	push   $0x6b
  jmp alltraps
801056aa:	e9 34 f6 ff ff       	jmp    80104ce3 <alltraps>

801056af <vector108>:
.globl vector108
vector108:
  pushl $0
801056af:	6a 00                	push   $0x0
  pushl $108
801056b1:	6a 6c                	push   $0x6c
  jmp alltraps
801056b3:	e9 2b f6 ff ff       	jmp    80104ce3 <alltraps>

801056b8 <vector109>:
.globl vector109
vector109:
  pushl $0
801056b8:	6a 00                	push   $0x0
  pushl $109
801056ba:	6a 6d                	push   $0x6d
  jmp alltraps
801056bc:	e9 22 f6 ff ff       	jmp    80104ce3 <alltraps>

801056c1 <vector110>:
.globl vector110
vector110:
  pushl $0
801056c1:	6a 00                	push   $0x0
  pushl $110
801056c3:	6a 6e                	push   $0x6e
  jmp alltraps
801056c5:	e9 19 f6 ff ff       	jmp    80104ce3 <alltraps>

801056ca <vector111>:
.globl vector111
vector111:
  pushl $0
801056ca:	6a 00                	push   $0x0
  pushl $111
801056cc:	6a 6f                	push   $0x6f
  jmp alltraps
801056ce:	e9 10 f6 ff ff       	jmp    80104ce3 <alltraps>

801056d3 <vector112>:
.globl vector112
vector112:
  pushl $0
801056d3:	6a 00                	push   $0x0
  pushl $112
801056d5:	6a 70                	push   $0x70
  jmp alltraps
801056d7:	e9 07 f6 ff ff       	jmp    80104ce3 <alltraps>

801056dc <vector113>:
.globl vector113
vector113:
  pushl $0
801056dc:	6a 00                	push   $0x0
  pushl $113
801056de:	6a 71                	push   $0x71
  jmp alltraps
801056e0:	e9 fe f5 ff ff       	jmp    80104ce3 <alltraps>

801056e5 <vector114>:
.globl vector114
vector114:
  pushl $0
801056e5:	6a 00                	push   $0x0
  pushl $114
801056e7:	6a 72                	push   $0x72
  jmp alltraps
801056e9:	e9 f5 f5 ff ff       	jmp    80104ce3 <alltraps>

801056ee <vector115>:
.globl vector115
vector115:
  pushl $0
801056ee:	6a 00                	push   $0x0
  pushl $115
801056f0:	6a 73                	push   $0x73
  jmp alltraps
801056f2:	e9 ec f5 ff ff       	jmp    80104ce3 <alltraps>

801056f7 <vector116>:
.globl vector116
vector116:
  pushl $0
801056f7:	6a 00                	push   $0x0
  pushl $116
801056f9:	6a 74                	push   $0x74
  jmp alltraps
801056fb:	e9 e3 f5 ff ff       	jmp    80104ce3 <alltraps>

80105700 <vector117>:
.globl vector117
vector117:
  pushl $0
80105700:	6a 00                	push   $0x0
  pushl $117
80105702:	6a 75                	push   $0x75
  jmp alltraps
80105704:	e9 da f5 ff ff       	jmp    80104ce3 <alltraps>

80105709 <vector118>:
.globl vector118
vector118:
  pushl $0
80105709:	6a 00                	push   $0x0
  pushl $118
8010570b:	6a 76                	push   $0x76
  jmp alltraps
8010570d:	e9 d1 f5 ff ff       	jmp    80104ce3 <alltraps>

80105712 <vector119>:
.globl vector119
vector119:
  pushl $0
80105712:	6a 00                	push   $0x0
  pushl $119
80105714:	6a 77                	push   $0x77
  jmp alltraps
80105716:	e9 c8 f5 ff ff       	jmp    80104ce3 <alltraps>

8010571b <vector120>:
.globl vector120
vector120:
  pushl $0
8010571b:	6a 00                	push   $0x0
  pushl $120
8010571d:	6a 78                	push   $0x78
  jmp alltraps
8010571f:	e9 bf f5 ff ff       	jmp    80104ce3 <alltraps>

80105724 <vector121>:
.globl vector121
vector121:
  pushl $0
80105724:	6a 00                	push   $0x0
  pushl $121
80105726:	6a 79                	push   $0x79
  jmp alltraps
80105728:	e9 b6 f5 ff ff       	jmp    80104ce3 <alltraps>

8010572d <vector122>:
.globl vector122
vector122:
  pushl $0
8010572d:	6a 00                	push   $0x0
  pushl $122
8010572f:	6a 7a                	push   $0x7a
  jmp alltraps
80105731:	e9 ad f5 ff ff       	jmp    80104ce3 <alltraps>

80105736 <vector123>:
.globl vector123
vector123:
  pushl $0
80105736:	6a 00                	push   $0x0
  pushl $123
80105738:	6a 7b                	push   $0x7b
  jmp alltraps
8010573a:	e9 a4 f5 ff ff       	jmp    80104ce3 <alltraps>

8010573f <vector124>:
.globl vector124
vector124:
  pushl $0
8010573f:	6a 00                	push   $0x0
  pushl $124
80105741:	6a 7c                	push   $0x7c
  jmp alltraps
80105743:	e9 9b f5 ff ff       	jmp    80104ce3 <alltraps>

80105748 <vector125>:
.globl vector125
vector125:
  pushl $0
80105748:	6a 00                	push   $0x0
  pushl $125
8010574a:	6a 7d                	push   $0x7d
  jmp alltraps
8010574c:	e9 92 f5 ff ff       	jmp    80104ce3 <alltraps>

80105751 <vector126>:
.globl vector126
vector126:
  pushl $0
80105751:	6a 00                	push   $0x0
  pushl $126
80105753:	6a 7e                	push   $0x7e
  jmp alltraps
80105755:	e9 89 f5 ff ff       	jmp    80104ce3 <alltraps>

8010575a <vector127>:
.globl vector127
vector127:
  pushl $0
8010575a:	6a 00                	push   $0x0
  pushl $127
8010575c:	6a 7f                	push   $0x7f
  jmp alltraps
8010575e:	e9 80 f5 ff ff       	jmp    80104ce3 <alltraps>

80105763 <vector128>:
.globl vector128
vector128:
  pushl $0
80105763:	6a 00                	push   $0x0
  pushl $128
80105765:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010576a:	e9 74 f5 ff ff       	jmp    80104ce3 <alltraps>

8010576f <vector129>:
.globl vector129
vector129:
  pushl $0
8010576f:	6a 00                	push   $0x0
  pushl $129
80105771:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105776:	e9 68 f5 ff ff       	jmp    80104ce3 <alltraps>

8010577b <vector130>:
.globl vector130
vector130:
  pushl $0
8010577b:	6a 00                	push   $0x0
  pushl $130
8010577d:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105782:	e9 5c f5 ff ff       	jmp    80104ce3 <alltraps>

80105787 <vector131>:
.globl vector131
vector131:
  pushl $0
80105787:	6a 00                	push   $0x0
  pushl $131
80105789:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010578e:	e9 50 f5 ff ff       	jmp    80104ce3 <alltraps>

80105793 <vector132>:
.globl vector132
vector132:
  pushl $0
80105793:	6a 00                	push   $0x0
  pushl $132
80105795:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010579a:	e9 44 f5 ff ff       	jmp    80104ce3 <alltraps>

8010579f <vector133>:
.globl vector133
vector133:
  pushl $0
8010579f:	6a 00                	push   $0x0
  pushl $133
801057a1:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801057a6:	e9 38 f5 ff ff       	jmp    80104ce3 <alltraps>

801057ab <vector134>:
.globl vector134
vector134:
  pushl $0
801057ab:	6a 00                	push   $0x0
  pushl $134
801057ad:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801057b2:	e9 2c f5 ff ff       	jmp    80104ce3 <alltraps>

801057b7 <vector135>:
.globl vector135
vector135:
  pushl $0
801057b7:	6a 00                	push   $0x0
  pushl $135
801057b9:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801057be:	e9 20 f5 ff ff       	jmp    80104ce3 <alltraps>

801057c3 <vector136>:
.globl vector136
vector136:
  pushl $0
801057c3:	6a 00                	push   $0x0
  pushl $136
801057c5:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801057ca:	e9 14 f5 ff ff       	jmp    80104ce3 <alltraps>

801057cf <vector137>:
.globl vector137
vector137:
  pushl $0
801057cf:	6a 00                	push   $0x0
  pushl $137
801057d1:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801057d6:	e9 08 f5 ff ff       	jmp    80104ce3 <alltraps>

801057db <vector138>:
.globl vector138
vector138:
  pushl $0
801057db:	6a 00                	push   $0x0
  pushl $138
801057dd:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801057e2:	e9 fc f4 ff ff       	jmp    80104ce3 <alltraps>

801057e7 <vector139>:
.globl vector139
vector139:
  pushl $0
801057e7:	6a 00                	push   $0x0
  pushl $139
801057e9:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801057ee:	e9 f0 f4 ff ff       	jmp    80104ce3 <alltraps>

801057f3 <vector140>:
.globl vector140
vector140:
  pushl $0
801057f3:	6a 00                	push   $0x0
  pushl $140
801057f5:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801057fa:	e9 e4 f4 ff ff       	jmp    80104ce3 <alltraps>

801057ff <vector141>:
.globl vector141
vector141:
  pushl $0
801057ff:	6a 00                	push   $0x0
  pushl $141
80105801:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105806:	e9 d8 f4 ff ff       	jmp    80104ce3 <alltraps>

8010580b <vector142>:
.globl vector142
vector142:
  pushl $0
8010580b:	6a 00                	push   $0x0
  pushl $142
8010580d:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105812:	e9 cc f4 ff ff       	jmp    80104ce3 <alltraps>

80105817 <vector143>:
.globl vector143
vector143:
  pushl $0
80105817:	6a 00                	push   $0x0
  pushl $143
80105819:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010581e:	e9 c0 f4 ff ff       	jmp    80104ce3 <alltraps>

80105823 <vector144>:
.globl vector144
vector144:
  pushl $0
80105823:	6a 00                	push   $0x0
  pushl $144
80105825:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010582a:	e9 b4 f4 ff ff       	jmp    80104ce3 <alltraps>

8010582f <vector145>:
.globl vector145
vector145:
  pushl $0
8010582f:	6a 00                	push   $0x0
  pushl $145
80105831:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105836:	e9 a8 f4 ff ff       	jmp    80104ce3 <alltraps>

8010583b <vector146>:
.globl vector146
vector146:
  pushl $0
8010583b:	6a 00                	push   $0x0
  pushl $146
8010583d:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105842:	e9 9c f4 ff ff       	jmp    80104ce3 <alltraps>

80105847 <vector147>:
.globl vector147
vector147:
  pushl $0
80105847:	6a 00                	push   $0x0
  pushl $147
80105849:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010584e:	e9 90 f4 ff ff       	jmp    80104ce3 <alltraps>

80105853 <vector148>:
.globl vector148
vector148:
  pushl $0
80105853:	6a 00                	push   $0x0
  pushl $148
80105855:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010585a:	e9 84 f4 ff ff       	jmp    80104ce3 <alltraps>

8010585f <vector149>:
.globl vector149
vector149:
  pushl $0
8010585f:	6a 00                	push   $0x0
  pushl $149
80105861:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105866:	e9 78 f4 ff ff       	jmp    80104ce3 <alltraps>

8010586b <vector150>:
.globl vector150
vector150:
  pushl $0
8010586b:	6a 00                	push   $0x0
  pushl $150
8010586d:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105872:	e9 6c f4 ff ff       	jmp    80104ce3 <alltraps>

80105877 <vector151>:
.globl vector151
vector151:
  pushl $0
80105877:	6a 00                	push   $0x0
  pushl $151
80105879:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010587e:	e9 60 f4 ff ff       	jmp    80104ce3 <alltraps>

80105883 <vector152>:
.globl vector152
vector152:
  pushl $0
80105883:	6a 00                	push   $0x0
  pushl $152
80105885:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010588a:	e9 54 f4 ff ff       	jmp    80104ce3 <alltraps>

8010588f <vector153>:
.globl vector153
vector153:
  pushl $0
8010588f:	6a 00                	push   $0x0
  pushl $153
80105891:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105896:	e9 48 f4 ff ff       	jmp    80104ce3 <alltraps>

8010589b <vector154>:
.globl vector154
vector154:
  pushl $0
8010589b:	6a 00                	push   $0x0
  pushl $154
8010589d:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801058a2:	e9 3c f4 ff ff       	jmp    80104ce3 <alltraps>

801058a7 <vector155>:
.globl vector155
vector155:
  pushl $0
801058a7:	6a 00                	push   $0x0
  pushl $155
801058a9:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801058ae:	e9 30 f4 ff ff       	jmp    80104ce3 <alltraps>

801058b3 <vector156>:
.globl vector156
vector156:
  pushl $0
801058b3:	6a 00                	push   $0x0
  pushl $156
801058b5:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801058ba:	e9 24 f4 ff ff       	jmp    80104ce3 <alltraps>

801058bf <vector157>:
.globl vector157
vector157:
  pushl $0
801058bf:	6a 00                	push   $0x0
  pushl $157
801058c1:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801058c6:	e9 18 f4 ff ff       	jmp    80104ce3 <alltraps>

801058cb <vector158>:
.globl vector158
vector158:
  pushl $0
801058cb:	6a 00                	push   $0x0
  pushl $158
801058cd:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801058d2:	e9 0c f4 ff ff       	jmp    80104ce3 <alltraps>

801058d7 <vector159>:
.globl vector159
vector159:
  pushl $0
801058d7:	6a 00                	push   $0x0
  pushl $159
801058d9:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801058de:	e9 00 f4 ff ff       	jmp    80104ce3 <alltraps>

801058e3 <vector160>:
.globl vector160
vector160:
  pushl $0
801058e3:	6a 00                	push   $0x0
  pushl $160
801058e5:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801058ea:	e9 f4 f3 ff ff       	jmp    80104ce3 <alltraps>

801058ef <vector161>:
.globl vector161
vector161:
  pushl $0
801058ef:	6a 00                	push   $0x0
  pushl $161
801058f1:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801058f6:	e9 e8 f3 ff ff       	jmp    80104ce3 <alltraps>

801058fb <vector162>:
.globl vector162
vector162:
  pushl $0
801058fb:	6a 00                	push   $0x0
  pushl $162
801058fd:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105902:	e9 dc f3 ff ff       	jmp    80104ce3 <alltraps>

80105907 <vector163>:
.globl vector163
vector163:
  pushl $0
80105907:	6a 00                	push   $0x0
  pushl $163
80105909:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010590e:	e9 d0 f3 ff ff       	jmp    80104ce3 <alltraps>

80105913 <vector164>:
.globl vector164
vector164:
  pushl $0
80105913:	6a 00                	push   $0x0
  pushl $164
80105915:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010591a:	e9 c4 f3 ff ff       	jmp    80104ce3 <alltraps>

8010591f <vector165>:
.globl vector165
vector165:
  pushl $0
8010591f:	6a 00                	push   $0x0
  pushl $165
80105921:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105926:	e9 b8 f3 ff ff       	jmp    80104ce3 <alltraps>

8010592b <vector166>:
.globl vector166
vector166:
  pushl $0
8010592b:	6a 00                	push   $0x0
  pushl $166
8010592d:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105932:	e9 ac f3 ff ff       	jmp    80104ce3 <alltraps>

80105937 <vector167>:
.globl vector167
vector167:
  pushl $0
80105937:	6a 00                	push   $0x0
  pushl $167
80105939:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010593e:	e9 a0 f3 ff ff       	jmp    80104ce3 <alltraps>

80105943 <vector168>:
.globl vector168
vector168:
  pushl $0
80105943:	6a 00                	push   $0x0
  pushl $168
80105945:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010594a:	e9 94 f3 ff ff       	jmp    80104ce3 <alltraps>

8010594f <vector169>:
.globl vector169
vector169:
  pushl $0
8010594f:	6a 00                	push   $0x0
  pushl $169
80105951:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105956:	e9 88 f3 ff ff       	jmp    80104ce3 <alltraps>

8010595b <vector170>:
.globl vector170
vector170:
  pushl $0
8010595b:	6a 00                	push   $0x0
  pushl $170
8010595d:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105962:	e9 7c f3 ff ff       	jmp    80104ce3 <alltraps>

80105967 <vector171>:
.globl vector171
vector171:
  pushl $0
80105967:	6a 00                	push   $0x0
  pushl $171
80105969:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010596e:	e9 70 f3 ff ff       	jmp    80104ce3 <alltraps>

80105973 <vector172>:
.globl vector172
vector172:
  pushl $0
80105973:	6a 00                	push   $0x0
  pushl $172
80105975:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010597a:	e9 64 f3 ff ff       	jmp    80104ce3 <alltraps>

8010597f <vector173>:
.globl vector173
vector173:
  pushl $0
8010597f:	6a 00                	push   $0x0
  pushl $173
80105981:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105986:	e9 58 f3 ff ff       	jmp    80104ce3 <alltraps>

8010598b <vector174>:
.globl vector174
vector174:
  pushl $0
8010598b:	6a 00                	push   $0x0
  pushl $174
8010598d:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105992:	e9 4c f3 ff ff       	jmp    80104ce3 <alltraps>

80105997 <vector175>:
.globl vector175
vector175:
  pushl $0
80105997:	6a 00                	push   $0x0
  pushl $175
80105999:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010599e:	e9 40 f3 ff ff       	jmp    80104ce3 <alltraps>

801059a3 <vector176>:
.globl vector176
vector176:
  pushl $0
801059a3:	6a 00                	push   $0x0
  pushl $176
801059a5:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801059aa:	e9 34 f3 ff ff       	jmp    80104ce3 <alltraps>

801059af <vector177>:
.globl vector177
vector177:
  pushl $0
801059af:	6a 00                	push   $0x0
  pushl $177
801059b1:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801059b6:	e9 28 f3 ff ff       	jmp    80104ce3 <alltraps>

801059bb <vector178>:
.globl vector178
vector178:
  pushl $0
801059bb:	6a 00                	push   $0x0
  pushl $178
801059bd:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801059c2:	e9 1c f3 ff ff       	jmp    80104ce3 <alltraps>

801059c7 <vector179>:
.globl vector179
vector179:
  pushl $0
801059c7:	6a 00                	push   $0x0
  pushl $179
801059c9:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801059ce:	e9 10 f3 ff ff       	jmp    80104ce3 <alltraps>

801059d3 <vector180>:
.globl vector180
vector180:
  pushl $0
801059d3:	6a 00                	push   $0x0
  pushl $180
801059d5:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801059da:	e9 04 f3 ff ff       	jmp    80104ce3 <alltraps>

801059df <vector181>:
.globl vector181
vector181:
  pushl $0
801059df:	6a 00                	push   $0x0
  pushl $181
801059e1:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801059e6:	e9 f8 f2 ff ff       	jmp    80104ce3 <alltraps>

801059eb <vector182>:
.globl vector182
vector182:
  pushl $0
801059eb:	6a 00                	push   $0x0
  pushl $182
801059ed:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801059f2:	e9 ec f2 ff ff       	jmp    80104ce3 <alltraps>

801059f7 <vector183>:
.globl vector183
vector183:
  pushl $0
801059f7:	6a 00                	push   $0x0
  pushl $183
801059f9:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801059fe:	e9 e0 f2 ff ff       	jmp    80104ce3 <alltraps>

80105a03 <vector184>:
.globl vector184
vector184:
  pushl $0
80105a03:	6a 00                	push   $0x0
  pushl $184
80105a05:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105a0a:	e9 d4 f2 ff ff       	jmp    80104ce3 <alltraps>

80105a0f <vector185>:
.globl vector185
vector185:
  pushl $0
80105a0f:	6a 00                	push   $0x0
  pushl $185
80105a11:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105a16:	e9 c8 f2 ff ff       	jmp    80104ce3 <alltraps>

80105a1b <vector186>:
.globl vector186
vector186:
  pushl $0
80105a1b:	6a 00                	push   $0x0
  pushl $186
80105a1d:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105a22:	e9 bc f2 ff ff       	jmp    80104ce3 <alltraps>

80105a27 <vector187>:
.globl vector187
vector187:
  pushl $0
80105a27:	6a 00                	push   $0x0
  pushl $187
80105a29:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105a2e:	e9 b0 f2 ff ff       	jmp    80104ce3 <alltraps>

80105a33 <vector188>:
.globl vector188
vector188:
  pushl $0
80105a33:	6a 00                	push   $0x0
  pushl $188
80105a35:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105a3a:	e9 a4 f2 ff ff       	jmp    80104ce3 <alltraps>

80105a3f <vector189>:
.globl vector189
vector189:
  pushl $0
80105a3f:	6a 00                	push   $0x0
  pushl $189
80105a41:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105a46:	e9 98 f2 ff ff       	jmp    80104ce3 <alltraps>

80105a4b <vector190>:
.globl vector190
vector190:
  pushl $0
80105a4b:	6a 00                	push   $0x0
  pushl $190
80105a4d:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105a52:	e9 8c f2 ff ff       	jmp    80104ce3 <alltraps>

80105a57 <vector191>:
.globl vector191
vector191:
  pushl $0
80105a57:	6a 00                	push   $0x0
  pushl $191
80105a59:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105a5e:	e9 80 f2 ff ff       	jmp    80104ce3 <alltraps>

80105a63 <vector192>:
.globl vector192
vector192:
  pushl $0
80105a63:	6a 00                	push   $0x0
  pushl $192
80105a65:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105a6a:	e9 74 f2 ff ff       	jmp    80104ce3 <alltraps>

80105a6f <vector193>:
.globl vector193
vector193:
  pushl $0
80105a6f:	6a 00                	push   $0x0
  pushl $193
80105a71:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105a76:	e9 68 f2 ff ff       	jmp    80104ce3 <alltraps>

80105a7b <vector194>:
.globl vector194
vector194:
  pushl $0
80105a7b:	6a 00                	push   $0x0
  pushl $194
80105a7d:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105a82:	e9 5c f2 ff ff       	jmp    80104ce3 <alltraps>

80105a87 <vector195>:
.globl vector195
vector195:
  pushl $0
80105a87:	6a 00                	push   $0x0
  pushl $195
80105a89:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105a8e:	e9 50 f2 ff ff       	jmp    80104ce3 <alltraps>

80105a93 <vector196>:
.globl vector196
vector196:
  pushl $0
80105a93:	6a 00                	push   $0x0
  pushl $196
80105a95:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105a9a:	e9 44 f2 ff ff       	jmp    80104ce3 <alltraps>

80105a9f <vector197>:
.globl vector197
vector197:
  pushl $0
80105a9f:	6a 00                	push   $0x0
  pushl $197
80105aa1:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105aa6:	e9 38 f2 ff ff       	jmp    80104ce3 <alltraps>

80105aab <vector198>:
.globl vector198
vector198:
  pushl $0
80105aab:	6a 00                	push   $0x0
  pushl $198
80105aad:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105ab2:	e9 2c f2 ff ff       	jmp    80104ce3 <alltraps>

80105ab7 <vector199>:
.globl vector199
vector199:
  pushl $0
80105ab7:	6a 00                	push   $0x0
  pushl $199
80105ab9:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105abe:	e9 20 f2 ff ff       	jmp    80104ce3 <alltraps>

80105ac3 <vector200>:
.globl vector200
vector200:
  pushl $0
80105ac3:	6a 00                	push   $0x0
  pushl $200
80105ac5:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105aca:	e9 14 f2 ff ff       	jmp    80104ce3 <alltraps>

80105acf <vector201>:
.globl vector201
vector201:
  pushl $0
80105acf:	6a 00                	push   $0x0
  pushl $201
80105ad1:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105ad6:	e9 08 f2 ff ff       	jmp    80104ce3 <alltraps>

80105adb <vector202>:
.globl vector202
vector202:
  pushl $0
80105adb:	6a 00                	push   $0x0
  pushl $202
80105add:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105ae2:	e9 fc f1 ff ff       	jmp    80104ce3 <alltraps>

80105ae7 <vector203>:
.globl vector203
vector203:
  pushl $0
80105ae7:	6a 00                	push   $0x0
  pushl $203
80105ae9:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105aee:	e9 f0 f1 ff ff       	jmp    80104ce3 <alltraps>

80105af3 <vector204>:
.globl vector204
vector204:
  pushl $0
80105af3:	6a 00                	push   $0x0
  pushl $204
80105af5:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105afa:	e9 e4 f1 ff ff       	jmp    80104ce3 <alltraps>

80105aff <vector205>:
.globl vector205
vector205:
  pushl $0
80105aff:	6a 00                	push   $0x0
  pushl $205
80105b01:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105b06:	e9 d8 f1 ff ff       	jmp    80104ce3 <alltraps>

80105b0b <vector206>:
.globl vector206
vector206:
  pushl $0
80105b0b:	6a 00                	push   $0x0
  pushl $206
80105b0d:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105b12:	e9 cc f1 ff ff       	jmp    80104ce3 <alltraps>

80105b17 <vector207>:
.globl vector207
vector207:
  pushl $0
80105b17:	6a 00                	push   $0x0
  pushl $207
80105b19:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105b1e:	e9 c0 f1 ff ff       	jmp    80104ce3 <alltraps>

80105b23 <vector208>:
.globl vector208
vector208:
  pushl $0
80105b23:	6a 00                	push   $0x0
  pushl $208
80105b25:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105b2a:	e9 b4 f1 ff ff       	jmp    80104ce3 <alltraps>

80105b2f <vector209>:
.globl vector209
vector209:
  pushl $0
80105b2f:	6a 00                	push   $0x0
  pushl $209
80105b31:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105b36:	e9 a8 f1 ff ff       	jmp    80104ce3 <alltraps>

80105b3b <vector210>:
.globl vector210
vector210:
  pushl $0
80105b3b:	6a 00                	push   $0x0
  pushl $210
80105b3d:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105b42:	e9 9c f1 ff ff       	jmp    80104ce3 <alltraps>

80105b47 <vector211>:
.globl vector211
vector211:
  pushl $0
80105b47:	6a 00                	push   $0x0
  pushl $211
80105b49:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105b4e:	e9 90 f1 ff ff       	jmp    80104ce3 <alltraps>

80105b53 <vector212>:
.globl vector212
vector212:
  pushl $0
80105b53:	6a 00                	push   $0x0
  pushl $212
80105b55:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105b5a:	e9 84 f1 ff ff       	jmp    80104ce3 <alltraps>

80105b5f <vector213>:
.globl vector213
vector213:
  pushl $0
80105b5f:	6a 00                	push   $0x0
  pushl $213
80105b61:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105b66:	e9 78 f1 ff ff       	jmp    80104ce3 <alltraps>

80105b6b <vector214>:
.globl vector214
vector214:
  pushl $0
80105b6b:	6a 00                	push   $0x0
  pushl $214
80105b6d:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105b72:	e9 6c f1 ff ff       	jmp    80104ce3 <alltraps>

80105b77 <vector215>:
.globl vector215
vector215:
  pushl $0
80105b77:	6a 00                	push   $0x0
  pushl $215
80105b79:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105b7e:	e9 60 f1 ff ff       	jmp    80104ce3 <alltraps>

80105b83 <vector216>:
.globl vector216
vector216:
  pushl $0
80105b83:	6a 00                	push   $0x0
  pushl $216
80105b85:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105b8a:	e9 54 f1 ff ff       	jmp    80104ce3 <alltraps>

80105b8f <vector217>:
.globl vector217
vector217:
  pushl $0
80105b8f:	6a 00                	push   $0x0
  pushl $217
80105b91:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105b96:	e9 48 f1 ff ff       	jmp    80104ce3 <alltraps>

80105b9b <vector218>:
.globl vector218
vector218:
  pushl $0
80105b9b:	6a 00                	push   $0x0
  pushl $218
80105b9d:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105ba2:	e9 3c f1 ff ff       	jmp    80104ce3 <alltraps>

80105ba7 <vector219>:
.globl vector219
vector219:
  pushl $0
80105ba7:	6a 00                	push   $0x0
  pushl $219
80105ba9:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105bae:	e9 30 f1 ff ff       	jmp    80104ce3 <alltraps>

80105bb3 <vector220>:
.globl vector220
vector220:
  pushl $0
80105bb3:	6a 00                	push   $0x0
  pushl $220
80105bb5:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105bba:	e9 24 f1 ff ff       	jmp    80104ce3 <alltraps>

80105bbf <vector221>:
.globl vector221
vector221:
  pushl $0
80105bbf:	6a 00                	push   $0x0
  pushl $221
80105bc1:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105bc6:	e9 18 f1 ff ff       	jmp    80104ce3 <alltraps>

80105bcb <vector222>:
.globl vector222
vector222:
  pushl $0
80105bcb:	6a 00                	push   $0x0
  pushl $222
80105bcd:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105bd2:	e9 0c f1 ff ff       	jmp    80104ce3 <alltraps>

80105bd7 <vector223>:
.globl vector223
vector223:
  pushl $0
80105bd7:	6a 00                	push   $0x0
  pushl $223
80105bd9:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105bde:	e9 00 f1 ff ff       	jmp    80104ce3 <alltraps>

80105be3 <vector224>:
.globl vector224
vector224:
  pushl $0
80105be3:	6a 00                	push   $0x0
  pushl $224
80105be5:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105bea:	e9 f4 f0 ff ff       	jmp    80104ce3 <alltraps>

80105bef <vector225>:
.globl vector225
vector225:
  pushl $0
80105bef:	6a 00                	push   $0x0
  pushl $225
80105bf1:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105bf6:	e9 e8 f0 ff ff       	jmp    80104ce3 <alltraps>

80105bfb <vector226>:
.globl vector226
vector226:
  pushl $0
80105bfb:	6a 00                	push   $0x0
  pushl $226
80105bfd:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105c02:	e9 dc f0 ff ff       	jmp    80104ce3 <alltraps>

80105c07 <vector227>:
.globl vector227
vector227:
  pushl $0
80105c07:	6a 00                	push   $0x0
  pushl $227
80105c09:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105c0e:	e9 d0 f0 ff ff       	jmp    80104ce3 <alltraps>

80105c13 <vector228>:
.globl vector228
vector228:
  pushl $0
80105c13:	6a 00                	push   $0x0
  pushl $228
80105c15:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105c1a:	e9 c4 f0 ff ff       	jmp    80104ce3 <alltraps>

80105c1f <vector229>:
.globl vector229
vector229:
  pushl $0
80105c1f:	6a 00                	push   $0x0
  pushl $229
80105c21:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105c26:	e9 b8 f0 ff ff       	jmp    80104ce3 <alltraps>

80105c2b <vector230>:
.globl vector230
vector230:
  pushl $0
80105c2b:	6a 00                	push   $0x0
  pushl $230
80105c2d:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105c32:	e9 ac f0 ff ff       	jmp    80104ce3 <alltraps>

80105c37 <vector231>:
.globl vector231
vector231:
  pushl $0
80105c37:	6a 00                	push   $0x0
  pushl $231
80105c39:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105c3e:	e9 a0 f0 ff ff       	jmp    80104ce3 <alltraps>

80105c43 <vector232>:
.globl vector232
vector232:
  pushl $0
80105c43:	6a 00                	push   $0x0
  pushl $232
80105c45:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105c4a:	e9 94 f0 ff ff       	jmp    80104ce3 <alltraps>

80105c4f <vector233>:
.globl vector233
vector233:
  pushl $0
80105c4f:	6a 00                	push   $0x0
  pushl $233
80105c51:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105c56:	e9 88 f0 ff ff       	jmp    80104ce3 <alltraps>

80105c5b <vector234>:
.globl vector234
vector234:
  pushl $0
80105c5b:	6a 00                	push   $0x0
  pushl $234
80105c5d:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105c62:	e9 7c f0 ff ff       	jmp    80104ce3 <alltraps>

80105c67 <vector235>:
.globl vector235
vector235:
  pushl $0
80105c67:	6a 00                	push   $0x0
  pushl $235
80105c69:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105c6e:	e9 70 f0 ff ff       	jmp    80104ce3 <alltraps>

80105c73 <vector236>:
.globl vector236
vector236:
  pushl $0
80105c73:	6a 00                	push   $0x0
  pushl $236
80105c75:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105c7a:	e9 64 f0 ff ff       	jmp    80104ce3 <alltraps>

80105c7f <vector237>:
.globl vector237
vector237:
  pushl $0
80105c7f:	6a 00                	push   $0x0
  pushl $237
80105c81:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105c86:	e9 58 f0 ff ff       	jmp    80104ce3 <alltraps>

80105c8b <vector238>:
.globl vector238
vector238:
  pushl $0
80105c8b:	6a 00                	push   $0x0
  pushl $238
80105c8d:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105c92:	e9 4c f0 ff ff       	jmp    80104ce3 <alltraps>

80105c97 <vector239>:
.globl vector239
vector239:
  pushl $0
80105c97:	6a 00                	push   $0x0
  pushl $239
80105c99:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105c9e:	e9 40 f0 ff ff       	jmp    80104ce3 <alltraps>

80105ca3 <vector240>:
.globl vector240
vector240:
  pushl $0
80105ca3:	6a 00                	push   $0x0
  pushl $240
80105ca5:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105caa:	e9 34 f0 ff ff       	jmp    80104ce3 <alltraps>

80105caf <vector241>:
.globl vector241
vector241:
  pushl $0
80105caf:	6a 00                	push   $0x0
  pushl $241
80105cb1:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105cb6:	e9 28 f0 ff ff       	jmp    80104ce3 <alltraps>

80105cbb <vector242>:
.globl vector242
vector242:
  pushl $0
80105cbb:	6a 00                	push   $0x0
  pushl $242
80105cbd:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105cc2:	e9 1c f0 ff ff       	jmp    80104ce3 <alltraps>

80105cc7 <vector243>:
.globl vector243
vector243:
  pushl $0
80105cc7:	6a 00                	push   $0x0
  pushl $243
80105cc9:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105cce:	e9 10 f0 ff ff       	jmp    80104ce3 <alltraps>

80105cd3 <vector244>:
.globl vector244
vector244:
  pushl $0
80105cd3:	6a 00                	push   $0x0
  pushl $244
80105cd5:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105cda:	e9 04 f0 ff ff       	jmp    80104ce3 <alltraps>

80105cdf <vector245>:
.globl vector245
vector245:
  pushl $0
80105cdf:	6a 00                	push   $0x0
  pushl $245
80105ce1:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105ce6:	e9 f8 ef ff ff       	jmp    80104ce3 <alltraps>

80105ceb <vector246>:
.globl vector246
vector246:
  pushl $0
80105ceb:	6a 00                	push   $0x0
  pushl $246
80105ced:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105cf2:	e9 ec ef ff ff       	jmp    80104ce3 <alltraps>

80105cf7 <vector247>:
.globl vector247
vector247:
  pushl $0
80105cf7:	6a 00                	push   $0x0
  pushl $247
80105cf9:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105cfe:	e9 e0 ef ff ff       	jmp    80104ce3 <alltraps>

80105d03 <vector248>:
.globl vector248
vector248:
  pushl $0
80105d03:	6a 00                	push   $0x0
  pushl $248
80105d05:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105d0a:	e9 d4 ef ff ff       	jmp    80104ce3 <alltraps>

80105d0f <vector249>:
.globl vector249
vector249:
  pushl $0
80105d0f:	6a 00                	push   $0x0
  pushl $249
80105d11:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105d16:	e9 c8 ef ff ff       	jmp    80104ce3 <alltraps>

80105d1b <vector250>:
.globl vector250
vector250:
  pushl $0
80105d1b:	6a 00                	push   $0x0
  pushl $250
80105d1d:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105d22:	e9 bc ef ff ff       	jmp    80104ce3 <alltraps>

80105d27 <vector251>:
.globl vector251
vector251:
  pushl $0
80105d27:	6a 00                	push   $0x0
  pushl $251
80105d29:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105d2e:	e9 b0 ef ff ff       	jmp    80104ce3 <alltraps>

80105d33 <vector252>:
.globl vector252
vector252:
  pushl $0
80105d33:	6a 00                	push   $0x0
  pushl $252
80105d35:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105d3a:	e9 a4 ef ff ff       	jmp    80104ce3 <alltraps>

80105d3f <vector253>:
.globl vector253
vector253:
  pushl $0
80105d3f:	6a 00                	push   $0x0
  pushl $253
80105d41:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105d46:	e9 98 ef ff ff       	jmp    80104ce3 <alltraps>

80105d4b <vector254>:
.globl vector254
vector254:
  pushl $0
80105d4b:	6a 00                	push   $0x0
  pushl $254
80105d4d:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105d52:	e9 8c ef ff ff       	jmp    80104ce3 <alltraps>

80105d57 <vector255>:
.globl vector255
vector255:
  pushl $0
80105d57:	6a 00                	push   $0x0
  pushl $255
80105d59:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105d5e:	e9 80 ef ff ff       	jmp    80104ce3 <alltraps>

80105d63 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105d63:	55                   	push   %ebp
80105d64:	89 e5                	mov    %esp,%ebp
80105d66:	57                   	push   %edi
80105d67:	56                   	push   %esi
80105d68:	53                   	push   %ebx
80105d69:	83 ec 0c             	sub    $0xc,%esp
80105d6c:	89 d3                	mov    %edx,%ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105d6e:	c1 ea 16             	shr    $0x16,%edx
80105d71:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105d74:	8b 37                	mov    (%edi),%esi
80105d76:	f7 c6 01 00 00 00    	test   $0x1,%esi
80105d7c:	74 20                	je     80105d9e <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105d7e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
80105d84:	81 c6 00 00 00 80    	add    $0x80000000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105d8a:	c1 eb 0c             	shr    $0xc,%ebx
80105d8d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
80105d93:	8d 04 9e             	lea    (%esi,%ebx,4),%eax
}
80105d96:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105d99:	5b                   	pop    %ebx
80105d9a:	5e                   	pop    %esi
80105d9b:	5f                   	pop    %edi
80105d9c:	5d                   	pop    %ebp
80105d9d:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105d9e:	85 c9                	test   %ecx,%ecx
80105da0:	74 2b                	je     80105dcd <walkpgdir+0x6a>
80105da2:	e8 81 c2 ff ff       	call   80102028 <kalloc>
80105da7:	89 c6                	mov    %eax,%esi
80105da9:	85 c0                	test   %eax,%eax
80105dab:	74 20                	je     80105dcd <walkpgdir+0x6a>
    memset(pgtab, 0, PGSIZE);
80105dad:	83 ec 04             	sub    $0x4,%esp
80105db0:	68 00 10 00 00       	push   $0x1000
80105db5:	6a 00                	push   $0x0
80105db7:	50                   	push   %eax
80105db8:	e8 c2 dd ff ff       	call   80103b7f <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105dbd:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80105dc3:	83 c8 07             	or     $0x7,%eax
80105dc6:	89 07                	mov    %eax,(%edi)
80105dc8:	83 c4 10             	add    $0x10,%esp
80105dcb:	eb bd                	jmp    80105d8a <walkpgdir+0x27>
      return 0;
80105dcd:	b8 00 00 00 00       	mov    $0x0,%eax
80105dd2:	eb c2                	jmp    80105d96 <walkpgdir+0x33>

80105dd4 <seginit>:
{
80105dd4:	55                   	push   %ebp
80105dd5:	89 e5                	mov    %esp,%ebp
80105dd7:	57                   	push   %edi
80105dd8:	56                   	push   %esi
80105dd9:	53                   	push   %ebx
80105dda:	83 ec 2c             	sub    $0x2c,%esp
  c = &cpus[cpuid()];
80105ddd:	e8 07 d3 ff ff       	call   801030e9 <cpuid>
80105de2:	89 c3                	mov    %eax,%ebx
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105de4:	8d 14 80             	lea    (%eax,%eax,4),%edx
80105de7:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
80105dea:	8d 04 01             	lea    (%ecx,%eax,1),%eax
80105ded:	c1 e0 04             	shl    $0x4,%eax
80105df0:	66 c7 80 18 18 11 80 	movw   $0xffff,-0x7feee7e8(%eax)
80105df7:	ff ff 
80105df9:	66 c7 80 1a 18 11 80 	movw   $0x0,-0x7feee7e6(%eax)
80105e00:	00 00 
80105e02:	c6 80 1c 18 11 80 00 	movb   $0x0,-0x7feee7e4(%eax)
80105e09:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
80105e0c:	01 d9                	add    %ebx,%ecx
80105e0e:	c1 e1 04             	shl    $0x4,%ecx
80105e11:	0f b6 b1 1d 18 11 80 	movzbl -0x7feee7e3(%ecx),%esi
80105e18:	83 e6 f0             	and    $0xfffffff0,%esi
80105e1b:	89 f7                	mov    %esi,%edi
80105e1d:	83 cf 0a             	or     $0xa,%edi
80105e20:	89 fa                	mov    %edi,%edx
80105e22:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
80105e28:	83 ce 1a             	or     $0x1a,%esi
80105e2b:	89 f2                	mov    %esi,%edx
80105e2d:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
80105e33:	83 e6 9f             	and    $0xffffff9f,%esi
80105e36:	89 f2                	mov    %esi,%edx
80105e38:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
80105e3e:	83 ce 80             	or     $0xffffff80,%esi
80105e41:	89 f2                	mov    %esi,%edx
80105e43:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
80105e49:	0f b6 b1 1e 18 11 80 	movzbl -0x7feee7e2(%ecx),%esi
80105e50:	83 ce 0f             	or     $0xf,%esi
80105e53:	89 f2                	mov    %esi,%edx
80105e55:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
80105e5b:	89 f7                	mov    %esi,%edi
80105e5d:	83 e7 ef             	and    $0xffffffef,%edi
80105e60:	89 fa                	mov    %edi,%edx
80105e62:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
80105e68:	83 e6 cf             	and    $0xffffffcf,%esi
80105e6b:	89 f2                	mov    %esi,%edx
80105e6d:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
80105e73:	89 f7                	mov    %esi,%edi
80105e75:	83 cf 40             	or     $0x40,%edi
80105e78:	89 fa                	mov    %edi,%edx
80105e7a:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
80105e80:	83 ce c0             	or     $0xffffffc0,%esi
80105e83:	89 f2                	mov    %esi,%edx
80105e85:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
80105e8b:	c6 80 1f 18 11 80 00 	movb   $0x0,-0x7feee7e1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105e92:	66 c7 80 20 18 11 80 	movw   $0xffff,-0x7feee7e0(%eax)
80105e99:	ff ff 
80105e9b:	66 c7 80 22 18 11 80 	movw   $0x0,-0x7feee7de(%eax)
80105ea2:	00 00 
80105ea4:	c6 80 24 18 11 80 00 	movb   $0x0,-0x7feee7dc(%eax)
80105eab:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80105eae:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
80105eb1:	c1 e1 04             	shl    $0x4,%ecx
80105eb4:	0f b6 b1 25 18 11 80 	movzbl -0x7feee7db(%ecx),%esi
80105ebb:	83 e6 f0             	and    $0xfffffff0,%esi
80105ebe:	89 f7                	mov    %esi,%edi
80105ec0:	83 cf 02             	or     $0x2,%edi
80105ec3:	89 fa                	mov    %edi,%edx
80105ec5:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
80105ecb:	83 ce 12             	or     $0x12,%esi
80105ece:	89 f2                	mov    %esi,%edx
80105ed0:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
80105ed6:	83 e6 9f             	and    $0xffffff9f,%esi
80105ed9:	89 f2                	mov    %esi,%edx
80105edb:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
80105ee1:	83 ce 80             	or     $0xffffff80,%esi
80105ee4:	89 f2                	mov    %esi,%edx
80105ee6:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
80105eec:	0f b6 b1 26 18 11 80 	movzbl -0x7feee7da(%ecx),%esi
80105ef3:	83 ce 0f             	or     $0xf,%esi
80105ef6:	89 f2                	mov    %esi,%edx
80105ef8:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
80105efe:	89 f7                	mov    %esi,%edi
80105f00:	83 e7 ef             	and    $0xffffffef,%edi
80105f03:	89 fa                	mov    %edi,%edx
80105f05:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
80105f0b:	83 e6 cf             	and    $0xffffffcf,%esi
80105f0e:	89 f2                	mov    %esi,%edx
80105f10:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
80105f16:	89 f7                	mov    %esi,%edi
80105f18:	83 cf 40             	or     $0x40,%edi
80105f1b:	89 fa                	mov    %edi,%edx
80105f1d:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
80105f23:	83 ce c0             	or     $0xffffffc0,%esi
80105f26:	89 f2                	mov    %esi,%edx
80105f28:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
80105f2e:	c6 80 27 18 11 80 00 	movb   $0x0,-0x7feee7d9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105f35:	66 c7 80 28 18 11 80 	movw   $0xffff,-0x7feee7d8(%eax)
80105f3c:	ff ff 
80105f3e:	66 c7 80 2a 18 11 80 	movw   $0x0,-0x7feee7d6(%eax)
80105f45:	00 00 
80105f47:	c6 80 2c 18 11 80 00 	movb   $0x0,-0x7feee7d4(%eax)
80105f4e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80105f51:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
80105f54:	c1 e1 04             	shl    $0x4,%ecx
80105f57:	0f b6 b1 2d 18 11 80 	movzbl -0x7feee7d3(%ecx),%esi
80105f5e:	83 e6 f0             	and    $0xfffffff0,%esi
80105f61:	89 f7                	mov    %esi,%edi
80105f63:	83 cf 0a             	or     $0xa,%edi
80105f66:	89 fa                	mov    %edi,%edx
80105f68:	88 91 2d 18 11 80    	mov    %dl,-0x7feee7d3(%ecx)
80105f6e:	89 f7                	mov    %esi,%edi
80105f70:	83 cf 1a             	or     $0x1a,%edi
80105f73:	89 fa                	mov    %edi,%edx
80105f75:	88 91 2d 18 11 80    	mov    %dl,-0x7feee7d3(%ecx)
80105f7b:	83 ce 7a             	or     $0x7a,%esi
80105f7e:	89 f2                	mov    %esi,%edx
80105f80:	88 91 2d 18 11 80    	mov    %dl,-0x7feee7d3(%ecx)
80105f86:	c6 81 2d 18 11 80 fa 	movb   $0xfa,-0x7feee7d3(%ecx)
80105f8d:	0f b6 b1 2e 18 11 80 	movzbl -0x7feee7d2(%ecx),%esi
80105f94:	83 ce 0f             	or     $0xf,%esi
80105f97:	89 f2                	mov    %esi,%edx
80105f99:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
80105f9f:	89 f7                	mov    %esi,%edi
80105fa1:	83 e7 ef             	and    $0xffffffef,%edi
80105fa4:	89 fa                	mov    %edi,%edx
80105fa6:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
80105fac:	83 e6 cf             	and    $0xffffffcf,%esi
80105faf:	89 f2                	mov    %esi,%edx
80105fb1:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
80105fb7:	89 f7                	mov    %esi,%edi
80105fb9:	83 cf 40             	or     $0x40,%edi
80105fbc:	89 fa                	mov    %edi,%edx
80105fbe:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
80105fc4:	83 ce c0             	or     $0xffffffc0,%esi
80105fc7:	89 f2                	mov    %esi,%edx
80105fc9:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
80105fcf:	c6 80 2f 18 11 80 00 	movb   $0x0,-0x7feee7d1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105fd6:	66 c7 80 30 18 11 80 	movw   $0xffff,-0x7feee7d0(%eax)
80105fdd:	ff ff 
80105fdf:	66 c7 80 32 18 11 80 	movw   $0x0,-0x7feee7ce(%eax)
80105fe6:	00 00 
80105fe8:	c6 80 34 18 11 80 00 	movb   $0x0,-0x7feee7cc(%eax)
80105fef:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80105ff2:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
80105ff5:	c1 e1 04             	shl    $0x4,%ecx
80105ff8:	0f b6 b1 35 18 11 80 	movzbl -0x7feee7cb(%ecx),%esi
80105fff:	83 e6 f0             	and    $0xfffffff0,%esi
80106002:	89 f7                	mov    %esi,%edi
80106004:	83 cf 02             	or     $0x2,%edi
80106007:	89 fa                	mov    %edi,%edx
80106009:	88 91 35 18 11 80    	mov    %dl,-0x7feee7cb(%ecx)
8010600f:	89 f7                	mov    %esi,%edi
80106011:	83 cf 12             	or     $0x12,%edi
80106014:	89 fa                	mov    %edi,%edx
80106016:	88 91 35 18 11 80    	mov    %dl,-0x7feee7cb(%ecx)
8010601c:	83 ce 72             	or     $0x72,%esi
8010601f:	89 f2                	mov    %esi,%edx
80106021:	88 91 35 18 11 80    	mov    %dl,-0x7feee7cb(%ecx)
80106027:	c6 81 35 18 11 80 f2 	movb   $0xf2,-0x7feee7cb(%ecx)
8010602e:	0f b6 b1 36 18 11 80 	movzbl -0x7feee7ca(%ecx),%esi
80106035:	83 ce 0f             	or     $0xf,%esi
80106038:	89 f2                	mov    %esi,%edx
8010603a:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
80106040:	89 f7                	mov    %esi,%edi
80106042:	83 e7 ef             	and    $0xffffffef,%edi
80106045:	89 fa                	mov    %edi,%edx
80106047:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
8010604d:	83 e6 cf             	and    $0xffffffcf,%esi
80106050:	89 f2                	mov    %esi,%edx
80106052:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
80106058:	89 f7                	mov    %esi,%edi
8010605a:	83 cf 40             	or     $0x40,%edi
8010605d:	89 fa                	mov    %edi,%edx
8010605f:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
80106065:	83 ce c0             	or     $0xffffffc0,%esi
80106068:	89 f2                	mov    %esi,%edx
8010606a:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
80106070:	c6 80 37 18 11 80 00 	movb   $0x0,-0x7feee7c9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80106077:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010607a:	01 da                	add    %ebx,%edx
8010607c:	c1 e2 04             	shl    $0x4,%edx
8010607f:	81 c2 10 18 11 80    	add    $0x80111810,%edx
  pd[0] = size-1;
80106085:	66 c7 45 e2 2f 00    	movw   $0x2f,-0x1e(%ebp)
  pd[1] = (uint)p;
8010608b:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
  pd[2] = (uint)p >> 16;
8010608f:	c1 ea 10             	shr    $0x10,%edx
80106092:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106096:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106099:	0f 01 10             	lgdtl  (%eax)
}
8010609c:	83 c4 2c             	add    $0x2c,%esp
8010609f:	5b                   	pop    %ebx
801060a0:	5e                   	pop    %esi
801060a1:	5f                   	pop    %edi
801060a2:	5d                   	pop    %ebp
801060a3:	c3                   	ret    

801060a4 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801060a4:	55                   	push   %ebp
801060a5:	89 e5                	mov    %esp,%ebp
801060a7:	57                   	push   %edi
801060a8:	56                   	push   %esi
801060a9:	53                   	push   %ebx
801060aa:	83 ec 0c             	sub    $0xc,%esp
801060ad:	8b 7d 0c             	mov    0xc(%ebp),%edi
801060b0:	8b 75 14             	mov    0x14(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801060b3:	89 fb                	mov    %edi,%ebx
801060b5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801060bb:	03 7d 10             	add    0x10(%ebp),%edi
801060be:	4f                   	dec    %edi
801060bf:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801060c5:	b9 01 00 00 00       	mov    $0x1,%ecx
801060ca:	89 da                	mov    %ebx,%edx
801060cc:	8b 45 08             	mov    0x8(%ebp),%eax
801060cf:	e8 8f fc ff ff       	call   80105d63 <walkpgdir>
801060d4:	85 c0                	test   %eax,%eax
801060d6:	74 2e                	je     80106106 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
801060d8:	f6 00 01             	testb  $0x1,(%eax)
801060db:	75 1c                	jne    801060f9 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
801060dd:	89 f2                	mov    %esi,%edx
801060df:	0b 55 18             	or     0x18(%ebp),%edx
801060e2:	83 ca 01             	or     $0x1,%edx
801060e5:	89 10                	mov    %edx,(%eax)
    if(a == last)
801060e7:	39 fb                	cmp    %edi,%ebx
801060e9:	74 28                	je     80106113 <mappages+0x6f>
      break;
    a += PGSIZE;
801060eb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
801060f1:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801060f7:	eb cc                	jmp    801060c5 <mappages+0x21>
      panic("remap");
801060f9:	83 ec 0c             	sub    $0xc,%esp
801060fc:	68 bc 71 10 80       	push   $0x801071bc
80106101:	e8 3b a2 ff ff       	call   80100341 <panic>
      return -1;
80106106:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
8010610b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010610e:	5b                   	pop    %ebx
8010610f:	5e                   	pop    %esi
80106110:	5f                   	pop    %edi
80106111:	5d                   	pop    %ebp
80106112:	c3                   	ret    
  return 0;
80106113:	b8 00 00 00 00       	mov    $0x0,%eax
80106118:	eb f1                	jmp    8010610b <mappages+0x67>

8010611a <switchkvm>:
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010611a:	a1 c4 45 11 80       	mov    0x801145c4,%eax
8010611f:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106124:	0f 22 d8             	mov    %eax,%cr3
}
80106127:	c3                   	ret    

80106128 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80106128:	55                   	push   %ebp
80106129:	89 e5                	mov    %esp,%ebp
8010612b:	57                   	push   %edi
8010612c:	56                   	push   %esi
8010612d:	53                   	push   %ebx
8010612e:	83 ec 1c             	sub    $0x1c,%esp
80106131:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80106134:	85 f6                	test   %esi,%esi
80106136:	0f 84 21 01 00 00    	je     8010625d <switchuvm+0x135>
    panic("switchuvm: no process");
  if(p->kstack == 0)
8010613c:	83 7e 0c 00          	cmpl   $0x0,0xc(%esi)
80106140:	0f 84 24 01 00 00    	je     8010626a <switchuvm+0x142>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80106146:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
8010614a:	0f 84 27 01 00 00    	je     80106277 <switchuvm+0x14f>
    panic("switchuvm: no pgdir");

  pushcli();
80106150:	e8 a4 d8 ff ff       	call   801039f9 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106155:	e8 2b cf ff ff       	call   80103085 <mycpu>
8010615a:	89 c3                	mov    %eax,%ebx
8010615c:	e8 24 cf ff ff       	call   80103085 <mycpu>
80106161:	8d 78 08             	lea    0x8(%eax),%edi
80106164:	e8 1c cf ff ff       	call   80103085 <mycpu>
80106169:	83 c0 08             	add    $0x8,%eax
8010616c:	c1 e8 10             	shr    $0x10,%eax
8010616f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106172:	e8 0e cf ff ff       	call   80103085 <mycpu>
80106177:	83 c0 08             	add    $0x8,%eax
8010617a:	c1 e8 18             	shr    $0x18,%eax
8010617d:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106184:	67 00 
80106186:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
8010618d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
80106190:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106196:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010619c:	83 e2 f0             	and    $0xfffffff0,%edx
8010619f:	88 d1                	mov    %dl,%cl
801061a1:	83 c9 09             	or     $0x9,%ecx
801061a4:	88 8b 9d 00 00 00    	mov    %cl,0x9d(%ebx)
801061aa:	83 ca 19             	or     $0x19,%edx
801061ad:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801061b3:	83 e2 9f             	and    $0xffffff9f,%edx
801061b6:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801061bc:	83 ca 80             	or     $0xffffff80,%edx
801061bf:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801061c5:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801061cb:	88 d1                	mov    %dl,%cl
801061cd:	83 e1 f0             	and    $0xfffffff0,%ecx
801061d0:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
801061d6:	88 d1                	mov    %dl,%cl
801061d8:	83 e1 e0             	and    $0xffffffe0,%ecx
801061db:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
801061e1:	83 e2 c0             	and    $0xffffffc0,%edx
801061e4:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801061ea:	83 ca 40             	or     $0x40,%edx
801061ed:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801061f3:	83 e2 7f             	and    $0x7f,%edx
801061f6:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801061fc:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80106202:	e8 7e ce ff ff       	call   80103085 <mycpu>
80106207:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
8010620d:	83 e2 ef             	and    $0xffffffef,%edx
80106210:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106216:	e8 6a ce ff ff       	call   80103085 <mycpu>
8010621b:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106221:	8b 5e 0c             	mov    0xc(%esi),%ebx
80106224:	e8 5c ce ff ff       	call   80103085 <mycpu>
80106229:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010622f:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106232:	e8 4e ce ff ff       	call   80103085 <mycpu>
80106237:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
8010623d:	b8 28 00 00 00       	mov    $0x28,%eax
80106242:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106245:	8b 46 08             	mov    0x8(%esi),%eax
80106248:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010624d:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80106250:	e8 df d7 ff ff       	call   80103a34 <popcli>
}
80106255:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106258:	5b                   	pop    %ebx
80106259:	5e                   	pop    %esi
8010625a:	5f                   	pop    %edi
8010625b:	5d                   	pop    %ebp
8010625c:	c3                   	ret    
    panic("switchuvm: no process");
8010625d:	83 ec 0c             	sub    $0xc,%esp
80106260:	68 c2 71 10 80       	push   $0x801071c2
80106265:	e8 d7 a0 ff ff       	call   80100341 <panic>
    panic("switchuvm: no kstack");
8010626a:	83 ec 0c             	sub    $0xc,%esp
8010626d:	68 d8 71 10 80       	push   $0x801071d8
80106272:	e8 ca a0 ff ff       	call   80100341 <panic>
    panic("switchuvm: no pgdir");
80106277:	83 ec 0c             	sub    $0xc,%esp
8010627a:	68 ed 71 10 80       	push   $0x801071ed
8010627f:	e8 bd a0 ff ff       	call   80100341 <panic>

80106284 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80106284:	55                   	push   %ebp
80106285:	89 e5                	mov    %esp,%ebp
80106287:	56                   	push   %esi
80106288:	53                   	push   %ebx
80106289:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
8010628c:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106292:	77 4b                	ja     801062df <inituvm+0x5b>
    panic("inituvm: more than a page");
  mem = kalloc();
80106294:	e8 8f bd ff ff       	call   80102028 <kalloc>
80106299:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
8010629b:	83 ec 04             	sub    $0x4,%esp
8010629e:	68 00 10 00 00       	push   $0x1000
801062a3:	6a 00                	push   $0x0
801062a5:	50                   	push   %eax
801062a6:	e8 d4 d8 ff ff       	call   80103b7f <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801062ab:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
801062b2:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801062b8:	50                   	push   %eax
801062b9:	68 00 10 00 00       	push   $0x1000
801062be:	6a 00                	push   $0x0
801062c0:	ff 75 08             	push   0x8(%ebp)
801062c3:	e8 dc fd ff ff       	call   801060a4 <mappages>
  memmove(mem, init, sz);
801062c8:	83 c4 1c             	add    $0x1c,%esp
801062cb:	56                   	push   %esi
801062cc:	ff 75 0c             	push   0xc(%ebp)
801062cf:	53                   	push   %ebx
801062d0:	e8 20 d9 ff ff       	call   80103bf5 <memmove>
}
801062d5:	83 c4 10             	add    $0x10,%esp
801062d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801062db:	5b                   	pop    %ebx
801062dc:	5e                   	pop    %esi
801062dd:	5d                   	pop    %ebp
801062de:	c3                   	ret    
    panic("inituvm: more than a page");
801062df:	83 ec 0c             	sub    $0xc,%esp
801062e2:	68 01 72 10 80       	push   $0x80107201
801062e7:	e8 55 a0 ff ff       	call   80100341 <panic>

801062ec <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801062ec:	55                   	push   %ebp
801062ed:	89 e5                	mov    %esp,%ebp
801062ef:	57                   	push   %edi
801062f0:	56                   	push   %esi
801062f1:	53                   	push   %ebx
801062f2:	83 ec 0c             	sub    $0xc,%esp
801062f5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801062f8:	89 fb                	mov    %edi,%ebx
801062fa:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
80106300:	74 3c                	je     8010633e <loaduvm+0x52>
    panic("loaduvm: addr must be page aligned");
80106302:	83 ec 0c             	sub    $0xc,%esp
80106305:	68 a0 72 10 80       	push   $0x801072a0
8010630a:	e8 32 a0 ff ff       	call   80100341 <panic>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
8010630f:	83 ec 0c             	sub    $0xc,%esp
80106312:	68 1b 72 10 80       	push   $0x8010721b
80106317:	e8 25 a0 ff ff       	call   80100341 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010631c:	05 00 00 00 80       	add    $0x80000000,%eax
80106321:	56                   	push   %esi
80106322:	89 da                	mov    %ebx,%edx
80106324:	03 55 14             	add    0x14(%ebp),%edx
80106327:	52                   	push   %edx
80106328:	50                   	push   %eax
80106329:	ff 75 10             	push   0x10(%ebp)
8010632c:	e8 c3 b3 ff ff       	call   801016f4 <readi>
80106331:	83 c4 10             	add    $0x10,%esp
80106334:	39 f0                	cmp    %esi,%eax
80106336:	75 47                	jne    8010637f <loaduvm+0x93>
  for(i = 0; i < sz; i += PGSIZE){
80106338:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010633e:	3b 5d 18             	cmp    0x18(%ebp),%ebx
80106341:	73 2f                	jae    80106372 <loaduvm+0x86>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106343:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
80106346:	b9 00 00 00 00       	mov    $0x0,%ecx
8010634b:	8b 45 08             	mov    0x8(%ebp),%eax
8010634e:	e8 10 fa ff ff       	call   80105d63 <walkpgdir>
80106353:	85 c0                	test   %eax,%eax
80106355:	74 b8                	je     8010630f <loaduvm+0x23>
    pa = PTE_ADDR(*pte);
80106357:	8b 00                	mov    (%eax),%eax
80106359:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
8010635e:	8b 75 18             	mov    0x18(%ebp),%esi
80106361:	29 de                	sub    %ebx,%esi
80106363:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106369:	76 b1                	jbe    8010631c <loaduvm+0x30>
      n = PGSIZE;
8010636b:	be 00 10 00 00       	mov    $0x1000,%esi
80106370:	eb aa                	jmp    8010631c <loaduvm+0x30>
      return -1;
  }
  return 0;
80106372:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106377:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010637a:	5b                   	pop    %ebx
8010637b:	5e                   	pop    %esi
8010637c:	5f                   	pop    %edi
8010637d:	5d                   	pop    %ebp
8010637e:	c3                   	ret    
      return -1;
8010637f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106384:	eb f1                	jmp    80106377 <loaduvm+0x8b>

80106386 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106386:	55                   	push   %ebp
80106387:	89 e5                	mov    %esp,%ebp
80106389:	57                   	push   %edi
8010638a:	56                   	push   %esi
8010638b:	53                   	push   %ebx
8010638c:	83 ec 0c             	sub    $0xc,%esp
8010638f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106392:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106395:	73 11                	jae    801063a8 <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
80106397:	8b 45 10             	mov    0x10(%ebp),%eax
8010639a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801063a0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801063a6:	eb 17                	jmp    801063bf <deallocuvm+0x39>
    return oldsz;
801063a8:	89 f8                	mov    %edi,%eax
801063aa:	eb 62                	jmp    8010640e <deallocuvm+0x88>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801063ac:	c1 eb 16             	shr    $0x16,%ebx
801063af:	43                   	inc    %ebx
801063b0:	c1 e3 16             	shl    $0x16,%ebx
801063b3:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801063b9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801063bf:	39 fb                	cmp    %edi,%ebx
801063c1:	73 48                	jae    8010640b <deallocuvm+0x85>
    pte = walkpgdir(pgdir, (char*)a, 0);
801063c3:	b9 00 00 00 00       	mov    $0x0,%ecx
801063c8:	89 da                	mov    %ebx,%edx
801063ca:	8b 45 08             	mov    0x8(%ebp),%eax
801063cd:	e8 91 f9 ff ff       	call   80105d63 <walkpgdir>
801063d2:	89 c6                	mov    %eax,%esi
    if(!pte)
801063d4:	85 c0                	test   %eax,%eax
801063d6:	74 d4                	je     801063ac <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
801063d8:	8b 00                	mov    (%eax),%eax
801063da:	a8 01                	test   $0x1,%al
801063dc:	74 db                	je     801063b9 <deallocuvm+0x33>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
801063de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801063e3:	74 19                	je     801063fe <deallocuvm+0x78>
        panic("kfree");
      char *v = P2V(pa);
801063e5:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801063ea:	83 ec 0c             	sub    $0xc,%esp
801063ed:	50                   	push   %eax
801063ee:	e8 1e bb ff ff       	call   80101f11 <kfree>
      *pte = 0;
801063f3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801063f9:	83 c4 10             	add    $0x10,%esp
801063fc:	eb bb                	jmp    801063b9 <deallocuvm+0x33>
        panic("kfree");
801063fe:	83 ec 0c             	sub    $0xc,%esp
80106401:	68 46 6a 10 80       	push   $0x80106a46
80106406:	e8 36 9f ff ff       	call   80100341 <panic>
    }
  }
  return newsz;
8010640b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010640e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106411:	5b                   	pop    %ebx
80106412:	5e                   	pop    %esi
80106413:	5f                   	pop    %edi
80106414:	5d                   	pop    %ebp
80106415:	c3                   	ret    

80106416 <allocuvm>:
{
80106416:	55                   	push   %ebp
80106417:	89 e5                	mov    %esp,%ebp
80106419:	57                   	push   %edi
8010641a:	56                   	push   %esi
8010641b:	53                   	push   %ebx
8010641c:	83 ec 1c             	sub    $0x1c,%esp
8010641f:	8b 7d 08             	mov    0x8(%ebp),%edi
  if(newsz >= KERNBASE)
80106422:	8b 45 10             	mov    0x10(%ebp),%eax
80106425:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106428:	85 c0                	test   %eax,%eax
8010642a:	0f 88 c1 00 00 00    	js     801064f1 <allocuvm+0xdb>
  if(newsz < oldsz)
80106430:	8b 45 0c             	mov    0xc(%ebp),%eax
80106433:	39 45 10             	cmp    %eax,0x10(%ebp)
80106436:	72 5c                	jb     80106494 <allocuvm+0x7e>
  a = PGROUNDUP(oldsz);
80106438:	8b 45 0c             	mov    0xc(%ebp),%eax
8010643b:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
80106441:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
80106447:	3b 75 10             	cmp    0x10(%ebp),%esi
8010644a:	0f 83 a8 00 00 00    	jae    801064f8 <allocuvm+0xe2>
    mem = kalloc();//Cojo la página física
80106450:	e8 d3 bb ff ff       	call   80102028 <kalloc>
80106455:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80106457:	85 c0                	test   %eax,%eax
80106459:	74 3e                	je     80106499 <allocuvm+0x83>
    memset(mem, 0, PGSIZE);//Ponemos la página a 0 para vaciarla de datos de cara al usuario 
8010645b:	83 ec 04             	sub    $0x4,%esp
8010645e:	68 00 10 00 00       	push   $0x1000
80106463:	6a 00                	push   $0x0
80106465:	50                   	push   %eax
80106466:	e8 14 d7 ff ff       	call   80103b7f <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){//mapeo la página en la TP
8010646b:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
80106472:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106478:	50                   	push   %eax
80106479:	68 00 10 00 00       	push   $0x1000
8010647e:	56                   	push   %esi
8010647f:	57                   	push   %edi
80106480:	e8 1f fc ff ff       	call   801060a4 <mappages>
80106485:	83 c4 20             	add    $0x20,%esp
80106488:	85 c0                	test   %eax,%eax
8010648a:	78 35                	js     801064c1 <allocuvm+0xab>
  for(; a < newsz; a += PGSIZE){
8010648c:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106492:	eb b3                	jmp    80106447 <allocuvm+0x31>
    return oldsz;
80106494:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106497:	eb 5f                	jmp    801064f8 <allocuvm+0xe2>
      cprintf("allocuvm out of memory\n");
80106499:	83 ec 0c             	sub    $0xc,%esp
8010649c:	68 39 72 10 80       	push   $0x80107239
801064a1:	e8 34 a1 ff ff       	call   801005da <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801064a6:	83 c4 0c             	add    $0xc,%esp
801064a9:	ff 75 0c             	push   0xc(%ebp)
801064ac:	ff 75 10             	push   0x10(%ebp)
801064af:	57                   	push   %edi
801064b0:	e8 d1 fe ff ff       	call   80106386 <deallocuvm>
      return 0;
801064b5:	83 c4 10             	add    $0x10,%esp
801064b8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801064bf:	eb 37                	jmp    801064f8 <allocuvm+0xe2>
      cprintf("allocuvm out of memory (2)\n");
801064c1:	83 ec 0c             	sub    $0xc,%esp
801064c4:	68 82 6f 10 80       	push   $0x80106f82
801064c9:	e8 0c a1 ff ff       	call   801005da <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801064ce:	83 c4 0c             	add    $0xc,%esp
801064d1:	ff 75 0c             	push   0xc(%ebp)
801064d4:	ff 75 10             	push   0x10(%ebp)
801064d7:	57                   	push   %edi
801064d8:	e8 a9 fe ff ff       	call   80106386 <deallocuvm>
      kfree(mem);
801064dd:	89 1c 24             	mov    %ebx,(%esp)
801064e0:	e8 2c ba ff ff       	call   80101f11 <kfree>
      return 0;
801064e5:	83 c4 10             	add    $0x10,%esp
801064e8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801064ef:	eb 07                	jmp    801064f8 <allocuvm+0xe2>
    return 0;
801064f1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
801064f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801064fe:	5b                   	pop    %ebx
801064ff:	5e                   	pop    %esi
80106500:	5f                   	pop    %edi
80106501:	5d                   	pop    %ebp
80106502:	c3                   	ret    

80106503 <freevm>:

// Free a page table and all the physical memory pages
// in the user part if dodeallocuvm is not zero
void
freevm(pde_t *pgdir, int dodeallocuvm)
{
80106503:	55                   	push   %ebp
80106504:	89 e5                	mov    %esp,%ebp
80106506:	56                   	push   %esi
80106507:	53                   	push   %ebx
80106508:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
8010650b:	85 f6                	test   %esi,%esi
8010650d:	74 0d                	je     8010651c <freevm+0x19>
    panic("freevm: no pgdir");
  if (dodeallocuvm)
8010650f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106513:	75 14                	jne    80106529 <freevm+0x26>
{
80106515:	bb 00 00 00 00       	mov    $0x0,%ebx
8010651a:	eb 23                	jmp    8010653f <freevm+0x3c>
    panic("freevm: no pgdir");
8010651c:	83 ec 0c             	sub    $0xc,%esp
8010651f:	68 51 72 10 80       	push   $0x80107251
80106524:	e8 18 9e ff ff       	call   80100341 <panic>
    deallocuvm(pgdir, KERNBASE, 0);
80106529:	83 ec 04             	sub    $0x4,%esp
8010652c:	6a 00                	push   $0x0
8010652e:	68 00 00 00 80       	push   $0x80000000
80106533:	56                   	push   %esi
80106534:	e8 4d fe ff ff       	call   80106386 <deallocuvm>
80106539:	83 c4 10             	add    $0x10,%esp
8010653c:	eb d7                	jmp    80106515 <freevm+0x12>
  for(i = 0; i < NPDENTRIES; i++){
8010653e:	43                   	inc    %ebx
8010653f:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106545:	77 1f                	ja     80106566 <freevm+0x63>
    if(pgdir[i] & PTE_P){
80106547:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
8010654a:	a8 01                	test   $0x1,%al
8010654c:	74 f0                	je     8010653e <freevm+0x3b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010654e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106553:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106558:	83 ec 0c             	sub    $0xc,%esp
8010655b:	50                   	push   %eax
8010655c:	e8 b0 b9 ff ff       	call   80101f11 <kfree>
80106561:	83 c4 10             	add    $0x10,%esp
80106564:	eb d8                	jmp    8010653e <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80106566:	83 ec 0c             	sub    $0xc,%esp
80106569:	56                   	push   %esi
8010656a:	e8 a2 b9 ff ff       	call   80101f11 <kfree>
}
8010656f:	83 c4 10             	add    $0x10,%esp
80106572:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106575:	5b                   	pop    %ebx
80106576:	5e                   	pop    %esi
80106577:	5d                   	pop    %ebp
80106578:	c3                   	ret    

80106579 <setupkvm>:
{
80106579:	55                   	push   %ebp
8010657a:	89 e5                	mov    %esp,%ebp
8010657c:	56                   	push   %esi
8010657d:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
8010657e:	e8 a5 ba ff ff       	call   80102028 <kalloc>
80106583:	89 c6                	mov    %eax,%esi
80106585:	85 c0                	test   %eax,%eax
80106587:	74 57                	je     801065e0 <setupkvm+0x67>
  memset(pgdir, 0, PGSIZE);
80106589:	83 ec 04             	sub    $0x4,%esp
8010658c:	68 00 10 00 00       	push   $0x1000
80106591:	6a 00                	push   $0x0
80106593:	50                   	push   %eax
80106594:	e8 e6 d5 ff ff       	call   80103b7f <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106599:	83 c4 10             	add    $0x10,%esp
8010659c:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
801065a1:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
801065a7:	73 37                	jae    801065e0 <setupkvm+0x67>
                (uint)k->phys_start, k->perm) < 0) {
801065a9:	8b 53 04             	mov    0x4(%ebx),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801065ac:	83 ec 0c             	sub    $0xc,%esp
801065af:	ff 73 0c             	push   0xc(%ebx)
801065b2:	52                   	push   %edx
801065b3:	8b 43 08             	mov    0x8(%ebx),%eax
801065b6:	29 d0                	sub    %edx,%eax
801065b8:	50                   	push   %eax
801065b9:	ff 33                	push   (%ebx)
801065bb:	56                   	push   %esi
801065bc:	e8 e3 fa ff ff       	call   801060a4 <mappages>
801065c1:	83 c4 20             	add    $0x20,%esp
801065c4:	85 c0                	test   %eax,%eax
801065c6:	78 05                	js     801065cd <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801065c8:	83 c3 10             	add    $0x10,%ebx
801065cb:	eb d4                	jmp    801065a1 <setupkvm+0x28>
      freevm(pgdir, 0);
801065cd:	83 ec 08             	sub    $0x8,%esp
801065d0:	6a 00                	push   $0x0
801065d2:	56                   	push   %esi
801065d3:	e8 2b ff ff ff       	call   80106503 <freevm>
      return 0;
801065d8:	83 c4 10             	add    $0x10,%esp
801065db:	be 00 00 00 00       	mov    $0x0,%esi
}
801065e0:	89 f0                	mov    %esi,%eax
801065e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801065e5:	5b                   	pop    %ebx
801065e6:	5e                   	pop    %esi
801065e7:	5d                   	pop    %ebp
801065e8:	c3                   	ret    

801065e9 <kvmalloc>:
{
801065e9:	55                   	push   %ebp
801065ea:	89 e5                	mov    %esp,%ebp
801065ec:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801065ef:	e8 85 ff ff ff       	call   80106579 <setupkvm>
801065f4:	a3 c4 45 11 80       	mov    %eax,0x801145c4
  switchkvm();
801065f9:	e8 1c fb ff ff       	call   8010611a <switchkvm>
}
801065fe:	c9                   	leave  
801065ff:	c3                   	ret    

80106600 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106600:	55                   	push   %ebp
80106601:	89 e5                	mov    %esp,%ebp
80106603:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106606:	b9 00 00 00 00       	mov    $0x0,%ecx
8010660b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010660e:	8b 45 08             	mov    0x8(%ebp),%eax
80106611:	e8 4d f7 ff ff       	call   80105d63 <walkpgdir>
  if(pte == 0)
80106616:	85 c0                	test   %eax,%eax
80106618:	74 05                	je     8010661f <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
8010661a:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010661d:	c9                   	leave  
8010661e:	c3                   	ret    
    panic("clearpteu");
8010661f:	83 ec 0c             	sub    $0xc,%esp
80106622:	68 62 72 10 80       	push   $0x80107262
80106627:	e8 15 9d ff ff       	call   80100341 <panic>

8010662c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010662c:	55                   	push   %ebp
8010662d:	89 e5                	mov    %esp,%ebp
8010662f:	57                   	push   %edi
80106630:	56                   	push   %esi
80106631:	53                   	push   %ebx
80106632:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106635:	e8 3f ff ff ff       	call   80106579 <setupkvm>
8010663a:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010663d:	85 c0                	test   %eax,%eax
8010663f:	0f 84 c6 00 00 00    	je     8010670b <copyuvm+0xdf>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106645:	bb 00 00 00 00       	mov    $0x0,%ebx
8010664a:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
8010664d:	0f 83 b8 00 00 00    	jae    8010670b <copyuvm+0xdf>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106653:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80106656:	b9 00 00 00 00       	mov    $0x0,%ecx
8010665b:	89 da                	mov    %ebx,%edx
8010665d:	8b 45 08             	mov    0x8(%ebp),%eax
80106660:	e8 fe f6 ff ff       	call   80105d63 <walkpgdir>
80106665:	85 c0                	test   %eax,%eax
80106667:	74 65                	je     801066ce <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
80106669:	8b 00                	mov    (%eax),%eax
8010666b:	a8 01                	test   $0x1,%al
8010666d:	74 6c                	je     801066db <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
8010666f:	89 c6                	mov    %eax,%esi
80106671:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
80106677:	25 ff 0f 00 00       	and    $0xfff,%eax
8010667c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
8010667f:	e8 a4 b9 ff ff       	call   80102028 <kalloc>
80106684:	89 c7                	mov    %eax,%edi
80106686:	85 c0                	test   %eax,%eax
80106688:	74 6a                	je     801066f4 <copyuvm+0xc8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010668a:	81 c6 00 00 00 80    	add    $0x80000000,%esi
80106690:	83 ec 04             	sub    $0x4,%esp
80106693:	68 00 10 00 00       	push   $0x1000
80106698:	56                   	push   %esi
80106699:	50                   	push   %eax
8010669a:	e8 56 d5 ff ff       	call   80103bf5 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010669f:	83 c4 04             	add    $0x4,%esp
801066a2:	ff 75 e0             	push   -0x20(%ebp)
801066a5:	8d 87 00 00 00 80    	lea    -0x80000000(%edi),%eax
801066ab:	50                   	push   %eax
801066ac:	68 00 10 00 00       	push   $0x1000
801066b1:	ff 75 e4             	push   -0x1c(%ebp)
801066b4:	ff 75 dc             	push   -0x24(%ebp)
801066b7:	e8 e8 f9 ff ff       	call   801060a4 <mappages>
801066bc:	83 c4 20             	add    $0x20,%esp
801066bf:	85 c0                	test   %eax,%eax
801066c1:	78 25                	js     801066e8 <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
801066c3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801066c9:	e9 7c ff ff ff       	jmp    8010664a <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
801066ce:	83 ec 0c             	sub    $0xc,%esp
801066d1:	68 6c 72 10 80       	push   $0x8010726c
801066d6:	e8 66 9c ff ff       	call   80100341 <panic>
      panic("copyuvm: page not present");
801066db:	83 ec 0c             	sub    $0xc,%esp
801066de:	68 86 72 10 80       	push   $0x80107286
801066e3:	e8 59 9c ff ff       	call   80100341 <panic>
      kfree(mem);
801066e8:	83 ec 0c             	sub    $0xc,%esp
801066eb:	57                   	push   %edi
801066ec:	e8 20 b8 ff ff       	call   80101f11 <kfree>
      goto bad;
801066f1:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d, 1);
801066f4:	83 ec 08             	sub    $0x8,%esp
801066f7:	6a 01                	push   $0x1
801066f9:	ff 75 dc             	push   -0x24(%ebp)
801066fc:	e8 02 fe ff ff       	call   80106503 <freevm>
  return 0;
80106701:	83 c4 10             	add    $0x10,%esp
80106704:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
8010670b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010670e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106711:	5b                   	pop    %ebx
80106712:	5e                   	pop    %esi
80106713:	5f                   	pop    %edi
80106714:	5d                   	pop    %ebp
80106715:	c3                   	ret    

80106716 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106716:	55                   	push   %ebp
80106717:	89 e5                	mov    %esp,%ebp
80106719:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010671c:	b9 00 00 00 00       	mov    $0x0,%ecx
80106721:	8b 55 0c             	mov    0xc(%ebp),%edx
80106724:	8b 45 08             	mov    0x8(%ebp),%eax
80106727:	e8 37 f6 ff ff       	call   80105d63 <walkpgdir>
  if((*pte & PTE_P) == 0)
8010672c:	8b 00                	mov    (%eax),%eax
8010672e:	a8 01                	test   $0x1,%al
80106730:	74 10                	je     80106742 <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
80106732:	a8 04                	test   $0x4,%al
80106734:	74 13                	je     80106749 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
80106736:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010673b:	05 00 00 00 80       	add    $0x80000000,%eax
}
80106740:	c9                   	leave  
80106741:	c3                   	ret    
    return 0;
80106742:	b8 00 00 00 00       	mov    $0x0,%eax
80106747:	eb f7                	jmp    80106740 <uva2ka+0x2a>
    return 0;
80106749:	b8 00 00 00 00       	mov    $0x0,%eax
8010674e:	eb f0                	jmp    80106740 <uva2ka+0x2a>

80106750 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106750:	55                   	push   %ebp
80106751:	89 e5                	mov    %esp,%ebp
80106753:	57                   	push   %edi
80106754:	56                   	push   %esi
80106755:	53                   	push   %ebx
80106756:	83 ec 0c             	sub    $0xc,%esp
80106759:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010675c:	eb 25                	jmp    80106783 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
8010675e:	8b 55 0c             	mov    0xc(%ebp),%edx
80106761:	29 f2                	sub    %esi,%edx
80106763:	01 d0                	add    %edx,%eax
80106765:	83 ec 04             	sub    $0x4,%esp
80106768:	53                   	push   %ebx
80106769:	ff 75 10             	push   0x10(%ebp)
8010676c:	50                   	push   %eax
8010676d:	e8 83 d4 ff ff       	call   80103bf5 <memmove>
    len -= n;
80106772:	29 df                	sub    %ebx,%edi
    buf += n;
80106774:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106777:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
8010677d:	89 45 0c             	mov    %eax,0xc(%ebp)
80106780:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
80106783:	85 ff                	test   %edi,%edi
80106785:	74 2f                	je     801067b6 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
80106787:	8b 75 0c             	mov    0xc(%ebp),%esi
8010678a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106790:	83 ec 08             	sub    $0x8,%esp
80106793:	56                   	push   %esi
80106794:	ff 75 08             	push   0x8(%ebp)
80106797:	e8 7a ff ff ff       	call   80106716 <uva2ka>
    if(pa0 == 0)
8010679c:	83 c4 10             	add    $0x10,%esp
8010679f:	85 c0                	test   %eax,%eax
801067a1:	74 20                	je     801067c3 <copyout+0x73>
    n = PGSIZE - (va - va0);
801067a3:	89 f3                	mov    %esi,%ebx
801067a5:	2b 5d 0c             	sub    0xc(%ebp),%ebx
801067a8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
801067ae:	39 df                	cmp    %ebx,%edi
801067b0:	73 ac                	jae    8010675e <copyout+0xe>
      n = len;
801067b2:	89 fb                	mov    %edi,%ebx
801067b4:	eb a8                	jmp    8010675e <copyout+0xe>
  }
  return 0;
801067b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801067be:	5b                   	pop    %ebx
801067bf:	5e                   	pop    %esi
801067c0:	5f                   	pop    %edi
801067c1:	5d                   	pop    %ebp
801067c2:	c3                   	ret    
      return -1;
801067c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067c8:	eb f1                	jmp    801067bb <copyout+0x6b>
