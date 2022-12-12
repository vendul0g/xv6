
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
80100028:	bc d0 57 11 80       	mov    $0x801157d0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 aa 29 10 80       	mov    $0x801029aa,%eax
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
80100046:	e8 58 3c 00 00       	call   80103ca3 <acquire>

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
8010007a:	e8 89 3c 00 00       	call   80103d08 <release>
      acquiresleep(&b->lock);
8010007f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100082:	89 04 24             	mov    %eax,(%esp)
80100085:	e8 0a 3a 00 00       	call   80103a94 <acquiresleep>
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
801000c8:	e8 3b 3c 00 00       	call   80103d08 <release>
      acquiresleep(&b->lock);
801000cd:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d0:	89 04 24             	mov    %eax,(%esp)
801000d3:	e8 bc 39 00 00       	call   80103a94 <acquiresleep>
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
801000e8:	68 60 6a 10 80       	push   $0x80106a60
801000ed:	e8 4f 02 00 00       	call   80100341 <panic>

801000f2 <binit>:
{
801000f2:	55                   	push   %ebp
801000f3:	89 e5                	mov    %esp,%ebp
801000f5:	53                   	push   %ebx
801000f6:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000f9:	68 71 6a 10 80       	push   $0x80106a71
801000fe:	68 20 a5 10 80       	push   $0x8010a520
80100103:	e8 64 3a 00 00       	call   80103b6c <initlock>
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
80100138:	68 78 6a 10 80       	push   $0x80106a78
8010013d:	8d 43 0c             	lea    0xc(%ebx),%eax
80100140:	50                   	push   %eax
80100141:	e8 1b 39 00 00       	call   80103a61 <initsleeplock>
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
8010018e:	e8 02 1c 00 00       	call   80101d95 <iderw>
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
801001a6:	e8 73 39 00 00       	call   80103b1e <holdingsleep>
801001ab:	83 c4 10             	add    $0x10,%esp
801001ae:	85 c0                	test   %eax,%eax
801001b0:	74 14                	je     801001c6 <bwrite+0x2e>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001b2:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001b5:	83 ec 0c             	sub    $0xc,%esp
801001b8:	53                   	push   %ebx
801001b9:	e8 d7 1b 00 00       	call   80101d95 <iderw>
}
801001be:	83 c4 10             	add    $0x10,%esp
801001c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c4:	c9                   	leave  
801001c5:	c3                   	ret    
    panic("bwrite");
801001c6:	83 ec 0c             	sub    $0xc,%esp
801001c9:	68 7f 6a 10 80       	push   $0x80106a7f
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
801001e2:	e8 37 39 00 00       	call   80103b1e <holdingsleep>
801001e7:	83 c4 10             	add    $0x10,%esp
801001ea:	85 c0                	test   %eax,%eax
801001ec:	74 69                	je     80100257 <brelse+0x84>
    panic("brelse");

  releasesleep(&b->lock);
801001ee:	83 ec 0c             	sub    $0xc,%esp
801001f1:	56                   	push   %esi
801001f2:	e8 ec 38 00 00       	call   80103ae3 <releasesleep>

  acquire(&bcache.lock);
801001f7:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801001fe:	e8 a0 3a 00 00       	call   80103ca3 <acquire>
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
80100248:	e8 bb 3a 00 00       	call   80103d08 <release>
}
8010024d:	83 c4 10             	add    $0x10,%esp
80100250:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100253:	5b                   	pop    %ebx
80100254:	5e                   	pop    %esi
80100255:	5d                   	pop    %ebp
80100256:	c3                   	ret    
    panic("brelse");
80100257:	83 ec 0c             	sub    $0xc,%esp
8010025a:	68 86 6a 10 80       	push   $0x80106a86
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
80100277:	e8 62 13 00 00       	call   801015de <iunlock>
  target = n;
8010027c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
8010027f:	c7 04 24 20 ef 10 80 	movl   $0x8010ef20,(%esp)
80100286:	e8 18 3a 00 00       	call   80103ca3 <acquire>
  while(n > 0){
8010028b:	83 c4 10             	add    $0x10,%esp
8010028e:	85 db                	test   %ebx,%ebx
80100290:	0f 8e 8c 00 00 00    	jle    80100322 <consoleread+0xbe>
    while(input.r == input.w){
80100296:	a1 00 ef 10 80       	mov    0x8010ef00,%eax
8010029b:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
801002a1:	75 47                	jne    801002ea <consoleread+0x86>
      if(myproc()->killed){
801002a3:	e8 95 2e 00 00       	call   8010313d <myproc>
801002a8:	83 78 30 00          	cmpl   $0x0,0x30(%eax)
801002ac:	75 17                	jne    801002c5 <consoleread+0x61>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002ae:	83 ec 08             	sub    $0x8,%esp
801002b1:	68 20 ef 10 80       	push   $0x8010ef20
801002b6:	68 00 ef 10 80       	push   $0x8010ef00
801002bb:	e8 dd 34 00 00       	call   8010379d <sleep>
801002c0:	83 c4 10             	add    $0x10,%esp
801002c3:	eb d1                	jmp    80100296 <consoleread+0x32>
        release(&cons.lock);
801002c5:	83 ec 0c             	sub    $0xc,%esp
801002c8:	68 20 ef 10 80       	push   $0x8010ef20
801002cd:	e8 36 3a 00 00       	call   80103d08 <release>
        ilock(ip);
801002d2:	89 3c 24             	mov    %edi,(%esp)
801002d5:	e8 44 12 00 00       	call   8010151e <ilock>
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
8010032a:	e8 d9 39 00 00       	call   80103d08 <release>
  ilock(ip);
8010032f:	89 3c 24             	mov    %edi,(%esp)
80100332:	e8 e7 11 00 00       	call   8010151e <ilock>
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
80100353:	e8 a3 1f 00 00       	call   801022fb <lapicid>
80100358:	83 ec 08             	sub    $0x8,%esp
8010035b:	50                   	push   %eax
8010035c:	68 8d 6a 10 80       	push   $0x80106a8d
80100361:	e8 74 02 00 00       	call   801005da <cprintf>
  cprintf(s);
80100366:	83 c4 04             	add    $0x4,%esp
80100369:	ff 75 08             	push   0x8(%ebp)
8010036c:	e8 69 02 00 00       	call   801005da <cprintf>
  cprintf("\n");
80100371:	c7 04 24 6b 74 10 80 	movl   $0x8010746b,(%esp)
80100378:	e8 5d 02 00 00       	call   801005da <cprintf>
  getcallerpcs(&s, pcs);
8010037d:	83 c4 08             	add    $0x8,%esp
80100380:	8d 45 d0             	lea    -0x30(%ebp),%eax
80100383:	50                   	push   %eax
80100384:	8d 45 08             	lea    0x8(%ebp),%eax
80100387:	50                   	push   %eax
80100388:	e8 fa 37 00 00       	call   80103b87 <getcallerpcs>
  for(i=0; i<10; i++)
8010038d:	83 c4 10             	add    $0x10,%esp
80100390:	bb 00 00 00 00       	mov    $0x0,%ebx
80100395:	eb 15                	jmp    801003ac <panic+0x6b>
    cprintf(" %p", pcs[i]);
80100397:	83 ec 08             	sub    $0x8,%esp
8010039a:	ff 74 9d d0          	push   -0x30(%ebp,%ebx,4)
8010039e:	68 a1 6a 10 80       	push   $0x80106aa1
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
8010046c:	68 a5 6a 10 80       	push   $0x80106aa5
80100471:	e8 cb fe ff ff       	call   80100341 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100476:	83 ec 04             	sub    $0x4,%esp
80100479:	68 60 0e 00 00       	push   $0xe60
8010047e:	68 a0 80 0b 80       	push   $0x800b80a0
80100483:	68 00 80 0b 80       	push   $0x800b8000
80100488:	e8 38 39 00 00       	call   80103dc5 <memmove>
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
801004a7:	e8 a3 38 00 00       	call   80103d4f <memset>
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
801004d4:	e8 e2 4e 00 00       	call   801053bb <uartputc>
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
801004ed:	e8 c9 4e 00 00       	call   801053bb <uartputc>
801004f2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801004f9:	e8 bd 4e 00 00       	call   801053bb <uartputc>
801004fe:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100505:	e8 b1 4e 00 00       	call   801053bb <uartputc>
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
80100540:	8a 92 d0 6a 10 80    	mov    -0x7fef9530(%edx),%dl
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
8010058f:	e8 4a 10 00 00       	call   801015de <iunlock>
  acquire(&cons.lock);
80100594:	c7 04 24 20 ef 10 80 	movl   $0x8010ef20,(%esp)
8010059b:	e8 03 37 00 00       	call   80103ca3 <acquire>
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
801005c0:	e8 43 37 00 00       	call   80103d08 <release>
  ilock(ip);
801005c5:	83 c4 04             	add    $0x4,%esp
801005c8:	ff 75 08             	push   0x8(%ebp)
801005cb:	e8 4e 0f 00 00       	call   8010151e <ilock>

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
80100607:	e8 97 36 00 00       	call   80103ca3 <acquire>
8010060c:	83 c4 10             	add    $0x10,%esp
8010060f:	eb de                	jmp    801005ef <cprintf+0x15>
    panic("null fmt");
80100611:	83 ec 0c             	sub    $0xc,%esp
80100614:	68 bf 6a 10 80       	push   $0x80106abf
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
8010069c:	bb b8 6a 10 80       	mov    $0x80106ab8,%ebx
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
801006f5:	e8 0e 36 00 00       	call   80103d08 <release>
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
80100710:	e8 8e 35 00 00       	call   80103ca3 <acquire>
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
801007b8:	e8 52 31 00 00       	call   8010390f <wakeup>
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
80100831:	e8 d2 34 00 00       	call   80103d08 <release>
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
80100845:	e8 64 31 00 00       	call   801039ae <procdump>
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
80100852:	68 c8 6a 10 80       	push   $0x80106ac8
80100857:	68 20 ef 10 80       	push   $0x8010ef20
8010085c:	e8 0b 33 00 00       	call   80103b6c <initlock>

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
80100886:	e8 72 16 00 00       	call   80101efd <ioapicenable>
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
8010089c:	e8 9c 28 00 00       	call   8010313d <myproc>
801008a1:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
801008a7:	e8 48 1e 00 00       	call   801026f4 <begin_op>

  if((ip = namei(path)) == 0){
801008ac:	83 ec 0c             	sub    $0xc,%esp
801008af:	ff 75 08             	push   0x8(%ebp)
801008b2:	e8 cb 12 00 00       	call   80101b82 <namei>
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
801008c4:	e8 55 0c 00 00       	call   8010151e <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
801008c9:	6a 34                	push   $0x34
801008cb:	6a 00                	push   $0x0
801008cd:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
801008d3:	50                   	push   %eax
801008d4:	53                   	push   %ebx
801008d5:	e8 31 0e 00 00       	call   8010170b <readi>
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
801008f0:	0f 84 e4 02 00 00    	je     80100bda <exec+0x34a>
    iunlockput(ip);
801008f6:	83 ec 0c             	sub    $0xc,%esp
801008f9:	53                   	push   %ebx
801008fa:	e8 c2 0d 00 00       	call   801016c1 <iunlockput>
    end_op();
801008ff:	e8 6c 1e 00 00       	call   80102770 <end_op>
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
80100914:	e8 57 1e 00 00       	call   80102770 <end_op>
    cprintf("exec: fail\n");
80100919:	83 ec 0c             	sub    $0xc,%esp
8010091c:	68 e1 6a 10 80       	push   $0x80106ae1
80100921:	e8 b4 fc ff ff       	call   801005da <cprintf>
    return -1;
80100926:	83 c4 10             	add    $0x10,%esp
80100929:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010092e:	eb dc                	jmp    8010090c <exec+0x7c>
  if((pgdir = setupkvm()) == 0)
80100930:	e8 f6 5d 00 00       	call   8010672b <setupkvm>
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
8010097a:	e8 8c 0d 00 00       	call   8010170b <readi>
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
801009c6:	e8 fd 5b 00 00       	call   801065c8 <allocuvm>
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
801009fc:	e8 9d 5a 00 00       	call   8010649e <loaduvm>
80100a01:	83 c4 20             	add    $0x20,%esp
80100a04:	85 c0                	test   %eax,%eax
80100a06:	0f 89 4e ff ff ff    	jns    8010095a <exec+0xca>
80100a0c:	eb 49                	jmp    80100a57 <exec+0x1c7>
  iunlockput(ip);
80100a0e:	83 ec 0c             	sub    $0xc,%esp
80100a11:	53                   	push   %ebx
80100a12:	e8 aa 0c 00 00       	call   801016c1 <iunlockput>
  end_op();
80100a17:	e8 54 1d 00 00       	call   80102770 <end_op>
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
80100a3e:	e8 85 5b 00 00       	call   801065c8 <allocuvm>
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
80100a6b:	e8 45 5c 00 00       	call   801066b5 <freevm>
80100a70:	83 c4 10             	add    $0x10,%esp
80100a73:	e9 76 fe ff ff       	jmp    801008ee <exec+0x5e>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100a78:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100a7e:	83 ec 08             	sub    $0x8,%esp
80100a81:	50                   	push   %eax
80100a82:	56                   	push   %esi
80100a83:	e8 2a 5d 00 00       	call   801067b2 <clearpteu>
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
80100ab7:	0f 87 13 01 00 00    	ja     80100bd0 <exec+0x340>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100abd:	83 ec 0c             	sub    $0xc,%esp
80100ac0:	50                   	push   %eax
80100ac1:	e8 19 34 00 00       	call   80103edf <strlen>
80100ac6:	29 c6                	sub    %eax,%esi
80100ac8:	4e                   	dec    %esi
80100ac9:	83 e6 fc             	and    $0xfffffffc,%esi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100acc:	83 c4 04             	add    $0x4,%esp
80100acf:	ff 33                	push   (%ebx)
80100ad1:	e8 09 34 00 00       	call   80103edf <strlen>
80100ad6:	40                   	inc    %eax
80100ad7:	50                   	push   %eax
80100ad8:	ff 33                	push   (%ebx)
80100ada:	56                   	push   %esi
80100adb:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100ae1:	e8 f6 5e 00 00       	call   801069dc <copyout>
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
80100b41:	e8 96 5e 00 00       	call   801069dc <copyout>
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
80100b71:	83 c0 78             	add    $0x78,%eax
80100b74:	83 ec 04             	sub    $0x4,%esp
80100b77:	6a 10                	push   $0x10
80100b79:	52                   	push   %edx
80100b7a:	50                   	push   %eax
80100b7b:	e8 27 33 00 00       	call   80103ea7 <safestrcpy>
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
80100bad:	89 4f 24             	mov    %ecx,0x24(%edi)
  switchuvm(curproc);
80100bb0:	89 3c 24             	mov    %edi,(%esp)
80100bb3:	e8 22 57 00 00       	call   801062da <switchuvm>
  freevm(oldpgdir, 1);
80100bb8:	83 c4 08             	add    $0x8,%esp
80100bbb:	6a 01                	push   $0x1
80100bbd:	53                   	push   %ebx
80100bbe:	e8 f2 5a 00 00       	call   801066b5 <freevm>
  return 0;
80100bc3:	83 c4 10             	add    $0x10,%esp
80100bc6:	b8 00 00 00 00       	mov    $0x0,%eax
80100bcb:	e9 3c fd ff ff       	jmp    8010090c <exec+0x7c>
  ip = 0;
80100bd0:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bd5:	e9 7d fe ff ff       	jmp    80100a57 <exec+0x1c7>
  return -1;
80100bda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bdf:	e9 28 fd ff ff       	jmp    8010090c <exec+0x7c>

80100be4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100be4:	55                   	push   %ebp
80100be5:	89 e5                	mov    %esp,%ebp
80100be7:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100bea:	68 ed 6a 10 80       	push   $0x80106aed
80100bef:	68 60 ef 10 80       	push   $0x8010ef60
80100bf4:	e8 73 2f 00 00       	call   80103b6c <initlock>
}
80100bf9:	83 c4 10             	add    $0x10,%esp
80100bfc:	c9                   	leave  
80100bfd:	c3                   	ret    

80100bfe <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100bfe:	55                   	push   %ebp
80100bff:	89 e5                	mov    %esp,%ebp
80100c01:	53                   	push   %ebx
80100c02:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c05:	68 60 ef 10 80       	push   $0x8010ef60
80100c0a:	e8 94 30 00 00       	call   80103ca3 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c0f:	83 c4 10             	add    $0x10,%esp
80100c12:	bb 94 ef 10 80       	mov    $0x8010ef94,%ebx
80100c17:	81 fb f4 f8 10 80    	cmp    $0x8010f8f4,%ebx
80100c1d:	73 29                	jae    80100c48 <filealloc+0x4a>
    if(f->ref == 0){
80100c1f:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c23:	74 05                	je     80100c2a <filealloc+0x2c>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c25:	83 c3 18             	add    $0x18,%ebx
80100c28:	eb ed                	jmp    80100c17 <filealloc+0x19>
      f->ref = 1;
80100c2a:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100c31:	83 ec 0c             	sub    $0xc,%esp
80100c34:	68 60 ef 10 80       	push   $0x8010ef60
80100c39:	e8 ca 30 00 00       	call   80103d08 <release>
      return f;
80100c3e:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100c41:	89 d8                	mov    %ebx,%eax
80100c43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c46:	c9                   	leave  
80100c47:	c3                   	ret    
  release(&ftable.lock);
80100c48:	83 ec 0c             	sub    $0xc,%esp
80100c4b:	68 60 ef 10 80       	push   $0x8010ef60
80100c50:	e8 b3 30 00 00       	call   80103d08 <release>
  return 0;
80100c55:	83 c4 10             	add    $0x10,%esp
80100c58:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c5d:	eb e2                	jmp    80100c41 <filealloc+0x43>

80100c5f <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100c5f:	55                   	push   %ebp
80100c60:	89 e5                	mov    %esp,%ebp
80100c62:	53                   	push   %ebx
80100c63:	83 ec 10             	sub    $0x10,%esp
80100c66:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100c69:	68 60 ef 10 80       	push   $0x8010ef60
80100c6e:	e8 30 30 00 00       	call   80103ca3 <acquire>
  if(f->ref < 1)
80100c73:	8b 43 04             	mov    0x4(%ebx),%eax
80100c76:	83 c4 10             	add    $0x10,%esp
80100c79:	85 c0                	test   %eax,%eax
80100c7b:	7e 18                	jle    80100c95 <filedup+0x36>
    panic("filedup");
  f->ref++;
80100c7d:	40                   	inc    %eax
80100c7e:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100c81:	83 ec 0c             	sub    $0xc,%esp
80100c84:	68 60 ef 10 80       	push   $0x8010ef60
80100c89:	e8 7a 30 00 00       	call   80103d08 <release>
  return f;
}
80100c8e:	89 d8                	mov    %ebx,%eax
80100c90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c93:	c9                   	leave  
80100c94:	c3                   	ret    
    panic("filedup");
80100c95:	83 ec 0c             	sub    $0xc,%esp
80100c98:	68 f4 6a 10 80       	push   $0x80106af4
80100c9d:	e8 9f f6 ff ff       	call   80100341 <panic>

80100ca2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100ca2:	55                   	push   %ebp
80100ca3:	89 e5                	mov    %esp,%ebp
80100ca5:	57                   	push   %edi
80100ca6:	56                   	push   %esi
80100ca7:	53                   	push   %ebx
80100ca8:	83 ec 38             	sub    $0x38,%esp
80100cab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100cae:	68 60 ef 10 80       	push   $0x8010ef60
80100cb3:	e8 eb 2f 00 00       	call   80103ca3 <acquire>
  if(f->ref < 1)
80100cb8:	8b 43 04             	mov    0x4(%ebx),%eax
80100cbb:	83 c4 10             	add    $0x10,%esp
80100cbe:	85 c0                	test   %eax,%eax
80100cc0:	7e 58                	jle    80100d1a <fileclose+0x78>
    panic("fileclose");
  if(--f->ref > 0){
80100cc2:	48                   	dec    %eax
80100cc3:	89 43 04             	mov    %eax,0x4(%ebx)
80100cc6:	85 c0                	test   %eax,%eax
80100cc8:	7f 5d                	jg     80100d27 <fileclose+0x85>
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100cca:	8d 7d d0             	lea    -0x30(%ebp),%edi
80100ccd:	b9 06 00 00 00       	mov    $0x6,%ecx
80100cd2:	89 de                	mov    %ebx,%esi
80100cd4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  f->ref = 0;
80100cd6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100cdd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100ce3:	83 ec 0c             	sub    $0xc,%esp
80100ce6:	68 60 ef 10 80       	push   $0x8010ef60
80100ceb:	e8 18 30 00 00       	call   80103d08 <release>

  if(ff.type == FD_PIPE)
80100cf0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100cf3:	83 c4 10             	add    $0x10,%esp
80100cf6:	83 f8 01             	cmp    $0x1,%eax
80100cf9:	74 44                	je     80100d3f <fileclose+0x9d>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80100cfb:	83 f8 02             	cmp    $0x2,%eax
80100cfe:	75 37                	jne    80100d37 <fileclose+0x95>
    begin_op();
80100d00:	e8 ef 19 00 00       	call   801026f4 <begin_op>
    iput(ff.ip);
80100d05:	83 ec 0c             	sub    $0xc,%esp
80100d08:	ff 75 e0             	push   -0x20(%ebp)
80100d0b:	e8 13 09 00 00       	call   80101623 <iput>
    end_op();
80100d10:	e8 5b 1a 00 00       	call   80102770 <end_op>
80100d15:	83 c4 10             	add    $0x10,%esp
80100d18:	eb 1d                	jmp    80100d37 <fileclose+0x95>
    panic("fileclose");
80100d1a:	83 ec 0c             	sub    $0xc,%esp
80100d1d:	68 fc 6a 10 80       	push   $0x80106afc
80100d22:	e8 1a f6 ff ff       	call   80100341 <panic>
    release(&ftable.lock);
80100d27:	83 ec 0c             	sub    $0xc,%esp
80100d2a:	68 60 ef 10 80       	push   $0x8010ef60
80100d2f:	e8 d4 2f 00 00       	call   80103d08 <release>
    return;
80100d34:	83 c4 10             	add    $0x10,%esp
  }
}
80100d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100d3a:	5b                   	pop    %ebx
80100d3b:	5e                   	pop    %esi
80100d3c:	5f                   	pop    %edi
80100d3d:	5d                   	pop    %ebp
80100d3e:	c3                   	ret    
    pipeclose(ff.pipe, ff.writable);
80100d3f:	83 ec 08             	sub    $0x8,%esp
80100d42:	0f be 45 d9          	movsbl -0x27(%ebp),%eax
80100d46:	50                   	push   %eax
80100d47:	ff 75 dc             	push   -0x24(%ebp)
80100d4a:	e8 06 20 00 00       	call   80102d55 <pipeclose>
80100d4f:	83 c4 10             	add    $0x10,%esp
80100d52:	eb e3                	jmp    80100d37 <fileclose+0x95>

80100d54 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100d54:	55                   	push   %ebp
80100d55:	89 e5                	mov    %esp,%ebp
80100d57:	53                   	push   %ebx
80100d58:	83 ec 04             	sub    $0x4,%esp
80100d5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100d5e:	83 3b 02             	cmpl   $0x2,(%ebx)
80100d61:	75 31                	jne    80100d94 <filestat+0x40>
    ilock(f->ip);
80100d63:	83 ec 0c             	sub    $0xc,%esp
80100d66:	ff 73 10             	push   0x10(%ebx)
80100d69:	e8 b0 07 00 00       	call   8010151e <ilock>
    stati(f->ip, st);
80100d6e:	83 c4 08             	add    $0x8,%esp
80100d71:	ff 75 0c             	push   0xc(%ebp)
80100d74:	ff 73 10             	push   0x10(%ebx)
80100d77:	e8 65 09 00 00       	call   801016e1 <stati>
    iunlock(f->ip);
80100d7c:	83 c4 04             	add    $0x4,%esp
80100d7f:	ff 73 10             	push   0x10(%ebx)
80100d82:	e8 57 08 00 00       	call   801015de <iunlock>
    return 0;
80100d87:	83 c4 10             	add    $0x10,%esp
80100d8a:	b8 00 00 00 00       	mov    $0x0,%eax
  }
  return -1;
}
80100d8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d92:	c9                   	leave  
80100d93:	c3                   	ret    
  return -1;
80100d94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100d99:	eb f4                	jmp    80100d8f <filestat+0x3b>

80100d9b <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100d9b:	55                   	push   %ebp
80100d9c:	89 e5                	mov    %esp,%ebp
80100d9e:	56                   	push   %esi
80100d9f:	53                   	push   %ebx
80100da0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100da3:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100da7:	74 70                	je     80100e19 <fileread+0x7e>
    return -1;
  if(f->type == FD_PIPE)
80100da9:	8b 03                	mov    (%ebx),%eax
80100dab:	83 f8 01             	cmp    $0x1,%eax
80100dae:	74 44                	je     80100df4 <fileread+0x59>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100db0:	83 f8 02             	cmp    $0x2,%eax
80100db3:	75 57                	jne    80100e0c <fileread+0x71>
    ilock(f->ip);
80100db5:	83 ec 0c             	sub    $0xc,%esp
80100db8:	ff 73 10             	push   0x10(%ebx)
80100dbb:	e8 5e 07 00 00       	call   8010151e <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100dc0:	ff 75 10             	push   0x10(%ebp)
80100dc3:	ff 73 14             	push   0x14(%ebx)
80100dc6:	ff 75 0c             	push   0xc(%ebp)
80100dc9:	ff 73 10             	push   0x10(%ebx)
80100dcc:	e8 3a 09 00 00       	call   8010170b <readi>
80100dd1:	89 c6                	mov    %eax,%esi
80100dd3:	83 c4 20             	add    $0x20,%esp
80100dd6:	85 c0                	test   %eax,%eax
80100dd8:	7e 03                	jle    80100ddd <fileread+0x42>
      f->off += r;
80100dda:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100ddd:	83 ec 0c             	sub    $0xc,%esp
80100de0:	ff 73 10             	push   0x10(%ebx)
80100de3:	e8 f6 07 00 00       	call   801015de <iunlock>
    return r;
80100de8:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100deb:	89 f0                	mov    %esi,%eax
80100ded:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100df0:	5b                   	pop    %ebx
80100df1:	5e                   	pop    %esi
80100df2:	5d                   	pop    %ebp
80100df3:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100df4:	83 ec 04             	sub    $0x4,%esp
80100df7:	ff 75 10             	push   0x10(%ebp)
80100dfa:	ff 75 0c             	push   0xc(%ebp)
80100dfd:	ff 73 0c             	push   0xc(%ebx)
80100e00:	e8 9e 20 00 00       	call   80102ea3 <piperead>
80100e05:	89 c6                	mov    %eax,%esi
80100e07:	83 c4 10             	add    $0x10,%esp
80100e0a:	eb df                	jmp    80100deb <fileread+0x50>
  panic("fileread");
80100e0c:	83 ec 0c             	sub    $0xc,%esp
80100e0f:	68 06 6b 10 80       	push   $0x80106b06
80100e14:	e8 28 f5 ff ff       	call   80100341 <panic>
    return -1;
80100e19:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e1e:	eb cb                	jmp    80100deb <fileread+0x50>

80100e20 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100e20:	55                   	push   %ebp
80100e21:	89 e5                	mov    %esp,%ebp
80100e23:	57                   	push   %edi
80100e24:	56                   	push   %esi
80100e25:	53                   	push   %ebx
80100e26:	83 ec 1c             	sub    $0x1c,%esp
80100e29:	8b 75 08             	mov    0x8(%ebp),%esi
  int r;

  if(f->writable == 0)
80100e2c:	80 7e 09 00          	cmpb   $0x0,0x9(%esi)
80100e30:	0f 84 cc 00 00 00    	je     80100f02 <filewrite+0xe2>
    return -1;
  if(f->type == FD_PIPE)
80100e36:	8b 06                	mov    (%esi),%eax
80100e38:	83 f8 01             	cmp    $0x1,%eax
80100e3b:	74 10                	je     80100e4d <filewrite+0x2d>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e3d:	83 f8 02             	cmp    $0x2,%eax
80100e40:	0f 85 af 00 00 00    	jne    80100ef5 <filewrite+0xd5>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100e46:	bf 00 00 00 00       	mov    $0x0,%edi
80100e4b:	eb 67                	jmp    80100eb4 <filewrite+0x94>
    return pipewrite(f->pipe, addr, n);
80100e4d:	83 ec 04             	sub    $0x4,%esp
80100e50:	ff 75 10             	push   0x10(%ebp)
80100e53:	ff 75 0c             	push   0xc(%ebp)
80100e56:	ff 76 0c             	push   0xc(%esi)
80100e59:	e8 83 1f 00 00       	call   80102de1 <pipewrite>
80100e5e:	83 c4 10             	add    $0x10,%esp
80100e61:	e9 82 00 00 00       	jmp    80100ee8 <filewrite+0xc8>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100e66:	e8 89 18 00 00       	call   801026f4 <begin_op>
      ilock(f->ip);
80100e6b:	83 ec 0c             	sub    $0xc,%esp
80100e6e:	ff 76 10             	push   0x10(%esi)
80100e71:	e8 a8 06 00 00       	call   8010151e <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100e76:	ff 75 e4             	push   -0x1c(%ebp)
80100e79:	ff 76 14             	push   0x14(%esi)
80100e7c:	89 f8                	mov    %edi,%eax
80100e7e:	03 45 0c             	add    0xc(%ebp),%eax
80100e81:	50                   	push   %eax
80100e82:	ff 76 10             	push   0x10(%esi)
80100e85:	e8 81 09 00 00       	call   8010180b <writei>
80100e8a:	89 c3                	mov    %eax,%ebx
80100e8c:	83 c4 20             	add    $0x20,%esp
80100e8f:	85 c0                	test   %eax,%eax
80100e91:	7e 03                	jle    80100e96 <filewrite+0x76>
        f->off += r;
80100e93:	01 46 14             	add    %eax,0x14(%esi)
      iunlock(f->ip);
80100e96:	83 ec 0c             	sub    $0xc,%esp
80100e99:	ff 76 10             	push   0x10(%esi)
80100e9c:	e8 3d 07 00 00       	call   801015de <iunlock>
      end_op();
80100ea1:	e8 ca 18 00 00       	call   80102770 <end_op>

      if(r < 0)
80100ea6:	83 c4 10             	add    $0x10,%esp
80100ea9:	85 db                	test   %ebx,%ebx
80100eab:	78 31                	js     80100ede <filewrite+0xbe>
        break;
      if(r != n1)
80100ead:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
80100eb0:	75 1f                	jne    80100ed1 <filewrite+0xb1>
        panic("short filewrite");
      i += r;
80100eb2:	01 df                	add    %ebx,%edi
    while(i < n){
80100eb4:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100eb7:	7d 25                	jge    80100ede <filewrite+0xbe>
      int n1 = n - i;
80100eb9:	8b 45 10             	mov    0x10(%ebp),%eax
80100ebc:	29 f8                	sub    %edi,%eax
80100ebe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(n1 > max)
80100ec1:	3d 00 06 00 00       	cmp    $0x600,%eax
80100ec6:	7e 9e                	jle    80100e66 <filewrite+0x46>
        n1 = max;
80100ec8:	c7 45 e4 00 06 00 00 	movl   $0x600,-0x1c(%ebp)
80100ecf:	eb 95                	jmp    80100e66 <filewrite+0x46>
        panic("short filewrite");
80100ed1:	83 ec 0c             	sub    $0xc,%esp
80100ed4:	68 0f 6b 10 80       	push   $0x80106b0f
80100ed9:	e8 63 f4 ff ff       	call   80100341 <panic>
    }
    return i == n ? n : -1;
80100ede:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100ee1:	74 0d                	je     80100ef0 <filewrite+0xd0>
80100ee3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
80100ee8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100eeb:	5b                   	pop    %ebx
80100eec:	5e                   	pop    %esi
80100eed:	5f                   	pop    %edi
80100eee:	5d                   	pop    %ebp
80100eef:	c3                   	ret    
    return i == n ? n : -1;
80100ef0:	8b 45 10             	mov    0x10(%ebp),%eax
80100ef3:	eb f3                	jmp    80100ee8 <filewrite+0xc8>
  panic("filewrite");
80100ef5:	83 ec 0c             	sub    $0xc,%esp
80100ef8:	68 15 6b 10 80       	push   $0x80106b15
80100efd:	e8 3f f4 ff ff       	call   80100341 <panic>
    return -1;
80100f02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f07:	eb df                	jmp    80100ee8 <filewrite+0xc8>

80100f09 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80100f09:	55                   	push   %ebp
80100f0a:	89 e5                	mov    %esp,%ebp
80100f0c:	57                   	push   %edi
80100f0d:	56                   	push   %esi
80100f0e:	53                   	push   %ebx
80100f0f:	83 ec 0c             	sub    $0xc,%esp
80100f12:	89 d6                	mov    %edx,%esi
  char *s;
  int len;

  while(*path == '/')
80100f14:	eb 01                	jmp    80100f17 <skipelem+0xe>
    path++;
80100f16:	40                   	inc    %eax
  while(*path == '/')
80100f17:	8a 10                	mov    (%eax),%dl
80100f19:	80 fa 2f             	cmp    $0x2f,%dl
80100f1c:	74 f8                	je     80100f16 <skipelem+0xd>
  if(*path == 0)
80100f1e:	84 d2                	test   %dl,%dl
80100f20:	74 4e                	je     80100f70 <skipelem+0x67>
80100f22:	89 c3                	mov    %eax,%ebx
80100f24:	eb 01                	jmp    80100f27 <skipelem+0x1e>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80100f26:	43                   	inc    %ebx
  while(*path != '/' && *path != 0)
80100f27:	8a 13                	mov    (%ebx),%dl
80100f29:	80 fa 2f             	cmp    $0x2f,%dl
80100f2c:	74 04                	je     80100f32 <skipelem+0x29>
80100f2e:	84 d2                	test   %dl,%dl
80100f30:	75 f4                	jne    80100f26 <skipelem+0x1d>
  len = path - s;
80100f32:	89 df                	mov    %ebx,%edi
80100f34:	29 c7                	sub    %eax,%edi
  if(len >= DIRSIZ)
80100f36:	83 ff 0d             	cmp    $0xd,%edi
80100f39:	7e 11                	jle    80100f4c <skipelem+0x43>
    memmove(name, s, DIRSIZ);
80100f3b:	83 ec 04             	sub    $0x4,%esp
80100f3e:	6a 0e                	push   $0xe
80100f40:	50                   	push   %eax
80100f41:	56                   	push   %esi
80100f42:	e8 7e 2e 00 00       	call   80103dc5 <memmove>
80100f47:	83 c4 10             	add    $0x10,%esp
80100f4a:	eb 15                	jmp    80100f61 <skipelem+0x58>
  else {
    memmove(name, s, len);
80100f4c:	83 ec 04             	sub    $0x4,%esp
80100f4f:	57                   	push   %edi
80100f50:	50                   	push   %eax
80100f51:	56                   	push   %esi
80100f52:	e8 6e 2e 00 00       	call   80103dc5 <memmove>
    name[len] = 0;
80100f57:	c6 04 3e 00          	movb   $0x0,(%esi,%edi,1)
80100f5b:	83 c4 10             	add    $0x10,%esp
80100f5e:	eb 01                	jmp    80100f61 <skipelem+0x58>
  }
  while(*path == '/')
    path++;
80100f60:	43                   	inc    %ebx
  while(*path == '/')
80100f61:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80100f64:	74 fa                	je     80100f60 <skipelem+0x57>
  return path;
}
80100f66:	89 d8                	mov    %ebx,%eax
80100f68:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f6b:	5b                   	pop    %ebx
80100f6c:	5e                   	pop    %esi
80100f6d:	5f                   	pop    %edi
80100f6e:	5d                   	pop    %ebp
80100f6f:	c3                   	ret    
    return 0;
80100f70:	bb 00 00 00 00       	mov    $0x0,%ebx
80100f75:	eb ef                	jmp    80100f66 <skipelem+0x5d>

80100f77 <bzero>:
{
80100f77:	55                   	push   %ebp
80100f78:	89 e5                	mov    %esp,%ebp
80100f7a:	53                   	push   %ebx
80100f7b:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, bno);
80100f7e:	52                   	push   %edx
80100f7f:	50                   	push   %eax
80100f80:	e8 e5 f1 ff ff       	call   8010016a <bread>
80100f85:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80100f87:	8d 40 5c             	lea    0x5c(%eax),%eax
80100f8a:	83 c4 0c             	add    $0xc,%esp
80100f8d:	68 00 02 00 00       	push   $0x200
80100f92:	6a 00                	push   $0x0
80100f94:	50                   	push   %eax
80100f95:	e8 b5 2d 00 00       	call   80103d4f <memset>
  log_write(bp);
80100f9a:	89 1c 24             	mov    %ebx,(%esp)
80100f9d:	e8 7b 18 00 00       	call   8010281d <log_write>
  brelse(bp);
80100fa2:	89 1c 24             	mov    %ebx,(%esp)
80100fa5:	e8 29 f2 ff ff       	call   801001d3 <brelse>
}
80100faa:	83 c4 10             	add    $0x10,%esp
80100fad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100fb0:	c9                   	leave  
80100fb1:	c3                   	ret    

80100fb2 <balloc>:
{
80100fb2:	55                   	push   %ebp
80100fb3:	89 e5                	mov    %esp,%ebp
80100fb5:	57                   	push   %edi
80100fb6:	56                   	push   %esi
80100fb7:	53                   	push   %ebx
80100fb8:	83 ec 1c             	sub    $0x1c,%esp
80100fbb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80100fbe:	be 00 00 00 00       	mov    $0x0,%esi
80100fc3:	eb 5b                	jmp    80101020 <balloc+0x6e>
    bp = bread(dev, BBLOCK(b, sb));
80100fc5:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
80100fcb:	eb 61                	jmp    8010102e <balloc+0x7c>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80100fcd:	c1 fa 03             	sar    $0x3,%edx
80100fd0:	8b 7d e0             	mov    -0x20(%ebp),%edi
80100fd3:	8a 4c 17 5c          	mov    0x5c(%edi,%edx,1),%cl
80100fd7:	0f b6 f9             	movzbl %cl,%edi
80100fda:	85 7d e4             	test   %edi,-0x1c(%ebp)
80100fdd:	74 7e                	je     8010105d <balloc+0xab>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80100fdf:	40                   	inc    %eax
80100fe0:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80100fe5:	7f 25                	jg     8010100c <balloc+0x5a>
80100fe7:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
80100fea:	3b 1d b4 15 11 80    	cmp    0x801115b4,%ebx
80100ff0:	73 1a                	jae    8010100c <balloc+0x5a>
      m = 1 << (bi % 8);
80100ff2:	89 c1                	mov    %eax,%ecx
80100ff4:	83 e1 07             	and    $0x7,%ecx
80100ff7:	ba 01 00 00 00       	mov    $0x1,%edx
80100ffc:	d3 e2                	shl    %cl,%edx
80100ffe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101001:	89 c2                	mov    %eax,%edx
80101003:	85 c0                	test   %eax,%eax
80101005:	79 c6                	jns    80100fcd <balloc+0x1b>
80101007:	8d 50 07             	lea    0x7(%eax),%edx
8010100a:	eb c1                	jmp    80100fcd <balloc+0x1b>
    brelse(bp);
8010100c:	83 ec 0c             	sub    $0xc,%esp
8010100f:	ff 75 e0             	push   -0x20(%ebp)
80101012:	e8 bc f1 ff ff       	call   801001d3 <brelse>
  for(b = 0; b < sb.size; b += BPB){
80101017:	81 c6 00 10 00 00    	add    $0x1000,%esi
8010101d:	83 c4 10             	add    $0x10,%esp
80101020:	39 35 b4 15 11 80    	cmp    %esi,0x801115b4
80101026:	76 28                	jbe    80101050 <balloc+0x9e>
    bp = bread(dev, BBLOCK(b, sb));
80101028:	89 f0                	mov    %esi,%eax
8010102a:	85 f6                	test   %esi,%esi
8010102c:	78 97                	js     80100fc5 <balloc+0x13>
8010102e:	c1 f8 0c             	sar    $0xc,%eax
80101031:	83 ec 08             	sub    $0x8,%esp
80101034:	03 05 cc 15 11 80    	add    0x801115cc,%eax
8010103a:	50                   	push   %eax
8010103b:	ff 75 dc             	push   -0x24(%ebp)
8010103e:	e8 27 f1 ff ff       	call   8010016a <bread>
80101043:	89 45 e0             	mov    %eax,-0x20(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101046:	83 c4 10             	add    $0x10,%esp
80101049:	b8 00 00 00 00       	mov    $0x0,%eax
8010104e:	eb 90                	jmp    80100fe0 <balloc+0x2e>
  panic("balloc: out of blocks");
80101050:	83 ec 0c             	sub    $0xc,%esp
80101053:	68 1f 6b 10 80       	push   $0x80106b1f
80101058:	e8 e4 f2 ff ff       	call   80100341 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
8010105d:	0b 4d e4             	or     -0x1c(%ebp),%ecx
80101060:	8b 75 e0             	mov    -0x20(%ebp),%esi
80101063:	88 4c 16 5c          	mov    %cl,0x5c(%esi,%edx,1)
        log_write(bp);
80101067:	83 ec 0c             	sub    $0xc,%esp
8010106a:	56                   	push   %esi
8010106b:	e8 ad 17 00 00       	call   8010281d <log_write>
        brelse(bp);
80101070:	89 34 24             	mov    %esi,(%esp)
80101073:	e8 5b f1 ff ff       	call   801001d3 <brelse>
        bzero(dev, b + bi);
80101078:	89 da                	mov    %ebx,%edx
8010107a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010107d:	e8 f5 fe ff ff       	call   80100f77 <bzero>
}
80101082:	89 d8                	mov    %ebx,%eax
80101084:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101087:	5b                   	pop    %ebx
80101088:	5e                   	pop    %esi
80101089:	5f                   	pop    %edi
8010108a:	5d                   	pop    %ebp
8010108b:	c3                   	ret    

8010108c <bmap>:
{
8010108c:	55                   	push   %ebp
8010108d:	89 e5                	mov    %esp,%ebp
8010108f:	57                   	push   %edi
80101090:	56                   	push   %esi
80101091:	53                   	push   %ebx
80101092:	83 ec 1c             	sub    $0x1c,%esp
80101095:	89 c3                	mov    %eax,%ebx
80101097:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
80101099:	83 fa 0b             	cmp    $0xb,%edx
8010109c:	76 45                	jbe    801010e3 <bmap+0x57>
  bn -= NDIRECT;
8010109e:	8d 72 f4             	lea    -0xc(%edx),%esi
  if(bn < NINDIRECT){
801010a1:	83 fe 7f             	cmp    $0x7f,%esi
801010a4:	77 7f                	ja     80101125 <bmap+0x99>
    if((addr = ip->addrs[NDIRECT]) == 0)
801010a6:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801010ac:	85 c0                	test   %eax,%eax
801010ae:	74 4a                	je     801010fa <bmap+0x6e>
    bp = bread(ip->dev, addr);
801010b0:	83 ec 08             	sub    $0x8,%esp
801010b3:	50                   	push   %eax
801010b4:	ff 33                	push   (%ebx)
801010b6:	e8 af f0 ff ff       	call   8010016a <bread>
801010bb:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
801010bd:	8d 44 b0 5c          	lea    0x5c(%eax,%esi,4),%eax
801010c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801010c4:	8b 30                	mov    (%eax),%esi
801010c6:	83 c4 10             	add    $0x10,%esp
801010c9:	85 f6                	test   %esi,%esi
801010cb:	74 3c                	je     80101109 <bmap+0x7d>
    brelse(bp);
801010cd:	83 ec 0c             	sub    $0xc,%esp
801010d0:	57                   	push   %edi
801010d1:	e8 fd f0 ff ff       	call   801001d3 <brelse>
    return addr;
801010d6:	83 c4 10             	add    $0x10,%esp
}
801010d9:	89 f0                	mov    %esi,%eax
801010db:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010de:	5b                   	pop    %ebx
801010df:	5e                   	pop    %esi
801010e0:	5f                   	pop    %edi
801010e1:	5d                   	pop    %ebp
801010e2:	c3                   	ret    
    if((addr = ip->addrs[bn]) == 0)
801010e3:	8b 74 90 5c          	mov    0x5c(%eax,%edx,4),%esi
801010e7:	85 f6                	test   %esi,%esi
801010e9:	75 ee                	jne    801010d9 <bmap+0x4d>
      ip->addrs[bn] = addr = balloc(ip->dev);
801010eb:	8b 00                	mov    (%eax),%eax
801010ed:	e8 c0 fe ff ff       	call   80100fb2 <balloc>
801010f2:	89 c6                	mov    %eax,%esi
801010f4:	89 44 bb 5c          	mov    %eax,0x5c(%ebx,%edi,4)
    return addr;
801010f8:	eb df                	jmp    801010d9 <bmap+0x4d>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
801010fa:	8b 03                	mov    (%ebx),%eax
801010fc:	e8 b1 fe ff ff       	call   80100fb2 <balloc>
80101101:	89 83 8c 00 00 00    	mov    %eax,0x8c(%ebx)
80101107:	eb a7                	jmp    801010b0 <bmap+0x24>
      a[bn] = addr = balloc(ip->dev);
80101109:	8b 03                	mov    (%ebx),%eax
8010110b:	e8 a2 fe ff ff       	call   80100fb2 <balloc>
80101110:	89 c6                	mov    %eax,%esi
80101112:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101115:	89 30                	mov    %esi,(%eax)
      log_write(bp);
80101117:	83 ec 0c             	sub    $0xc,%esp
8010111a:	57                   	push   %edi
8010111b:	e8 fd 16 00 00       	call   8010281d <log_write>
80101120:	83 c4 10             	add    $0x10,%esp
80101123:	eb a8                	jmp    801010cd <bmap+0x41>
  panic("bmap: out of range");
80101125:	83 ec 0c             	sub    $0xc,%esp
80101128:	68 35 6b 10 80       	push   $0x80106b35
8010112d:	e8 0f f2 ff ff       	call   80100341 <panic>

80101132 <iget>:
{
80101132:	55                   	push   %ebp
80101133:	89 e5                	mov    %esp,%ebp
80101135:	57                   	push   %edi
80101136:	56                   	push   %esi
80101137:	53                   	push   %ebx
80101138:	83 ec 28             	sub    $0x28,%esp
8010113b:	89 c7                	mov    %eax,%edi
8010113d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101140:	68 60 f9 10 80       	push   $0x8010f960
80101145:	e8 59 2b 00 00       	call   80103ca3 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010114a:	83 c4 10             	add    $0x10,%esp
  empty = 0;
8010114d:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101152:	bb 94 f9 10 80       	mov    $0x8010f994,%ebx
80101157:	eb 0a                	jmp    80101163 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101159:	85 f6                	test   %esi,%esi
8010115b:	74 39                	je     80101196 <iget+0x64>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010115d:	81 c3 90 00 00 00    	add    $0x90,%ebx
80101163:	81 fb b4 15 11 80    	cmp    $0x801115b4,%ebx
80101169:	73 33                	jae    8010119e <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010116b:	8b 43 08             	mov    0x8(%ebx),%eax
8010116e:	85 c0                	test   %eax,%eax
80101170:	7e e7                	jle    80101159 <iget+0x27>
80101172:	39 3b                	cmp    %edi,(%ebx)
80101174:	75 e3                	jne    80101159 <iget+0x27>
80101176:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101179:	39 4b 04             	cmp    %ecx,0x4(%ebx)
8010117c:	75 db                	jne    80101159 <iget+0x27>
      ip->ref++;
8010117e:	40                   	inc    %eax
8010117f:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
80101182:	83 ec 0c             	sub    $0xc,%esp
80101185:	68 60 f9 10 80       	push   $0x8010f960
8010118a:	e8 79 2b 00 00       	call   80103d08 <release>
      return ip;
8010118f:	83 c4 10             	add    $0x10,%esp
80101192:	89 de                	mov    %ebx,%esi
80101194:	eb 32                	jmp    801011c8 <iget+0x96>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101196:	85 c0                	test   %eax,%eax
80101198:	75 c3                	jne    8010115d <iget+0x2b>
      empty = ip;
8010119a:	89 de                	mov    %ebx,%esi
8010119c:	eb bf                	jmp    8010115d <iget+0x2b>
  if(empty == 0)
8010119e:	85 f6                	test   %esi,%esi
801011a0:	74 30                	je     801011d2 <iget+0xa0>
  ip->dev = dev;
801011a2:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
801011a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801011a7:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
801011aa:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
801011b1:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
801011b8:	83 ec 0c             	sub    $0xc,%esp
801011bb:	68 60 f9 10 80       	push   $0x8010f960
801011c0:	e8 43 2b 00 00       	call   80103d08 <release>
  return ip;
801011c5:	83 c4 10             	add    $0x10,%esp
}
801011c8:	89 f0                	mov    %esi,%eax
801011ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011cd:	5b                   	pop    %ebx
801011ce:	5e                   	pop    %esi
801011cf:	5f                   	pop    %edi
801011d0:	5d                   	pop    %ebp
801011d1:	c3                   	ret    
    panic("iget: no inodes");
801011d2:	83 ec 0c             	sub    $0xc,%esp
801011d5:	68 48 6b 10 80       	push   $0x80106b48
801011da:	e8 62 f1 ff ff       	call   80100341 <panic>

801011df <readsb>:
{
801011df:	55                   	push   %ebp
801011e0:	89 e5                	mov    %esp,%ebp
801011e2:	53                   	push   %ebx
801011e3:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
801011e6:	6a 01                	push   $0x1
801011e8:	ff 75 08             	push   0x8(%ebp)
801011eb:	e8 7a ef ff ff       	call   8010016a <bread>
801011f0:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801011f2:	8d 40 5c             	lea    0x5c(%eax),%eax
801011f5:	83 c4 0c             	add    $0xc,%esp
801011f8:	6a 1c                	push   $0x1c
801011fa:	50                   	push   %eax
801011fb:	ff 75 0c             	push   0xc(%ebp)
801011fe:	e8 c2 2b 00 00       	call   80103dc5 <memmove>
  brelse(bp);
80101203:	89 1c 24             	mov    %ebx,(%esp)
80101206:	e8 c8 ef ff ff       	call   801001d3 <brelse>
}
8010120b:	83 c4 10             	add    $0x10,%esp
8010120e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101211:	c9                   	leave  
80101212:	c3                   	ret    

80101213 <bfree>:
{
80101213:	55                   	push   %ebp
80101214:	89 e5                	mov    %esp,%ebp
80101216:	56                   	push   %esi
80101217:	53                   	push   %ebx
80101218:	89 c3                	mov    %eax,%ebx
8010121a:	89 d6                	mov    %edx,%esi
  readsb(dev, &sb);
8010121c:	83 ec 08             	sub    $0x8,%esp
8010121f:	68 b4 15 11 80       	push   $0x801115b4
80101224:	50                   	push   %eax
80101225:	e8 b5 ff ff ff       	call   801011df <readsb>
  bp = bread(dev, BBLOCK(b, sb));
8010122a:	89 f0                	mov    %esi,%eax
8010122c:	c1 e8 0c             	shr    $0xc,%eax
8010122f:	83 c4 08             	add    $0x8,%esp
80101232:	03 05 cc 15 11 80    	add    0x801115cc,%eax
80101238:	50                   	push   %eax
80101239:	53                   	push   %ebx
8010123a:	e8 2b ef ff ff       	call   8010016a <bread>
8010123f:	89 c3                	mov    %eax,%ebx
  bi = b % BPB;
80101241:	89 f2                	mov    %esi,%edx
80101243:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  m = 1 << (bi % 8);
80101249:	89 f1                	mov    %esi,%ecx
8010124b:	83 e1 07             	and    $0x7,%ecx
8010124e:	b8 01 00 00 00       	mov    $0x1,%eax
80101253:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
80101255:	83 c4 10             	add    $0x10,%esp
80101258:	c1 fa 03             	sar    $0x3,%edx
8010125b:	8a 4c 13 5c          	mov    0x5c(%ebx,%edx,1),%cl
8010125f:	0f b6 f1             	movzbl %cl,%esi
80101262:	85 c6                	test   %eax,%esi
80101264:	74 23                	je     80101289 <bfree+0x76>
  bp->data[bi/8] &= ~m;
80101266:	f7 d0                	not    %eax
80101268:	21 c8                	and    %ecx,%eax
8010126a:	88 44 13 5c          	mov    %al,0x5c(%ebx,%edx,1)
  log_write(bp);
8010126e:	83 ec 0c             	sub    $0xc,%esp
80101271:	53                   	push   %ebx
80101272:	e8 a6 15 00 00       	call   8010281d <log_write>
  brelse(bp);
80101277:	89 1c 24             	mov    %ebx,(%esp)
8010127a:	e8 54 ef ff ff       	call   801001d3 <brelse>
}
8010127f:	83 c4 10             	add    $0x10,%esp
80101282:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101285:	5b                   	pop    %ebx
80101286:	5e                   	pop    %esi
80101287:	5d                   	pop    %ebp
80101288:	c3                   	ret    
    panic("freeing free block");
80101289:	83 ec 0c             	sub    $0xc,%esp
8010128c:	68 58 6b 10 80       	push   $0x80106b58
80101291:	e8 ab f0 ff ff       	call   80100341 <panic>

80101296 <iinit>:
{
80101296:	55                   	push   %ebp
80101297:	89 e5                	mov    %esp,%ebp
80101299:	53                   	push   %ebx
8010129a:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
8010129d:	68 6b 6b 10 80       	push   $0x80106b6b
801012a2:	68 60 f9 10 80       	push   $0x8010f960
801012a7:	e8 c0 28 00 00       	call   80103b6c <initlock>
  for(i = 0; i < NINODE; i++) {
801012ac:	83 c4 10             	add    $0x10,%esp
801012af:	bb 00 00 00 00       	mov    $0x0,%ebx
801012b4:	eb 1f                	jmp    801012d5 <iinit+0x3f>
    initsleeplock(&icache.inode[i].lock, "inode");
801012b6:	83 ec 08             	sub    $0x8,%esp
801012b9:	68 72 6b 10 80       	push   $0x80106b72
801012be:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
801012c1:	89 d0                	mov    %edx,%eax
801012c3:	c1 e0 04             	shl    $0x4,%eax
801012c6:	05 a0 f9 10 80       	add    $0x8010f9a0,%eax
801012cb:	50                   	push   %eax
801012cc:	e8 90 27 00 00       	call   80103a61 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
801012d1:	43                   	inc    %ebx
801012d2:	83 c4 10             	add    $0x10,%esp
801012d5:	83 fb 31             	cmp    $0x31,%ebx
801012d8:	7e dc                	jle    801012b6 <iinit+0x20>
  readsb(dev, &sb);
801012da:	83 ec 08             	sub    $0x8,%esp
801012dd:	68 b4 15 11 80       	push   $0x801115b4
801012e2:	ff 75 08             	push   0x8(%ebp)
801012e5:	e8 f5 fe ff ff       	call   801011df <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801012ea:	ff 35 cc 15 11 80    	push   0x801115cc
801012f0:	ff 35 c8 15 11 80    	push   0x801115c8
801012f6:	ff 35 c4 15 11 80    	push   0x801115c4
801012fc:	ff 35 c0 15 11 80    	push   0x801115c0
80101302:	ff 35 bc 15 11 80    	push   0x801115bc
80101308:	ff 35 b8 15 11 80    	push   0x801115b8
8010130e:	ff 35 b4 15 11 80    	push   0x801115b4
80101314:	68 d8 6b 10 80       	push   $0x80106bd8
80101319:	e8 bc f2 ff ff       	call   801005da <cprintf>
}
8010131e:	83 c4 30             	add    $0x30,%esp
80101321:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101324:	c9                   	leave  
80101325:	c3                   	ret    

80101326 <ialloc>:
{
80101326:	55                   	push   %ebp
80101327:	89 e5                	mov    %esp,%ebp
80101329:	57                   	push   %edi
8010132a:	56                   	push   %esi
8010132b:	53                   	push   %ebx
8010132c:	83 ec 1c             	sub    $0x1c,%esp
8010132f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101332:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101335:	bb 01 00 00 00       	mov    $0x1,%ebx
8010133a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
8010133d:	39 1d bc 15 11 80    	cmp    %ebx,0x801115bc
80101343:	76 3d                	jbe    80101382 <ialloc+0x5c>
    bp = bread(dev, IBLOCK(inum, sb));
80101345:	89 d8                	mov    %ebx,%eax
80101347:	c1 e8 03             	shr    $0x3,%eax
8010134a:	83 ec 08             	sub    $0x8,%esp
8010134d:	03 05 c8 15 11 80    	add    0x801115c8,%eax
80101353:	50                   	push   %eax
80101354:	ff 75 08             	push   0x8(%ebp)
80101357:	e8 0e ee ff ff       	call   8010016a <bread>
8010135c:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
8010135e:	89 d8                	mov    %ebx,%eax
80101360:	83 e0 07             	and    $0x7,%eax
80101363:	c1 e0 06             	shl    $0x6,%eax
80101366:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
8010136a:	83 c4 10             	add    $0x10,%esp
8010136d:	66 83 3f 00          	cmpw   $0x0,(%edi)
80101371:	74 1c                	je     8010138f <ialloc+0x69>
    brelse(bp);
80101373:	83 ec 0c             	sub    $0xc,%esp
80101376:	56                   	push   %esi
80101377:	e8 57 ee ff ff       	call   801001d3 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
8010137c:	43                   	inc    %ebx
8010137d:	83 c4 10             	add    $0x10,%esp
80101380:	eb b8                	jmp    8010133a <ialloc+0x14>
  panic("ialloc: no inodes");
80101382:	83 ec 0c             	sub    $0xc,%esp
80101385:	68 78 6b 10 80       	push   $0x80106b78
8010138a:	e8 b2 ef ff ff       	call   80100341 <panic>
      memset(dip, 0, sizeof(*dip));
8010138f:	83 ec 04             	sub    $0x4,%esp
80101392:	6a 40                	push   $0x40
80101394:	6a 00                	push   $0x0
80101396:	57                   	push   %edi
80101397:	e8 b3 29 00 00       	call   80103d4f <memset>
      dip->type = type;
8010139c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010139f:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013a2:	89 34 24             	mov    %esi,(%esp)
801013a5:	e8 73 14 00 00       	call   8010281d <log_write>
      brelse(bp);
801013aa:	89 34 24             	mov    %esi,(%esp)
801013ad:	e8 21 ee ff ff       	call   801001d3 <brelse>
      return iget(dev, inum);
801013b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801013b5:	8b 45 08             	mov    0x8(%ebp),%eax
801013b8:	e8 75 fd ff ff       	call   80101132 <iget>
}
801013bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801013c0:	5b                   	pop    %ebx
801013c1:	5e                   	pop    %esi
801013c2:	5f                   	pop    %edi
801013c3:	5d                   	pop    %ebp
801013c4:	c3                   	ret    

801013c5 <iupdate>:
{
801013c5:	55                   	push   %ebp
801013c6:	89 e5                	mov    %esp,%ebp
801013c8:	56                   	push   %esi
801013c9:	53                   	push   %ebx
801013ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801013cd:	8b 43 04             	mov    0x4(%ebx),%eax
801013d0:	c1 e8 03             	shr    $0x3,%eax
801013d3:	83 ec 08             	sub    $0x8,%esp
801013d6:	03 05 c8 15 11 80    	add    0x801115c8,%eax
801013dc:	50                   	push   %eax
801013dd:	ff 33                	push   (%ebx)
801013df:	e8 86 ed ff ff       	call   8010016a <bread>
801013e4:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801013e6:	8b 43 04             	mov    0x4(%ebx),%eax
801013e9:	83 e0 07             	and    $0x7,%eax
801013ec:	c1 e0 06             	shl    $0x6,%eax
801013ef:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
801013f3:	8b 53 50             	mov    0x50(%ebx),%edx
801013f6:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801013f9:	66 8b 53 52          	mov    0x52(%ebx),%dx
801013fd:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101401:	8b 53 54             	mov    0x54(%ebx),%edx
80101404:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101408:	66 8b 53 56          	mov    0x56(%ebx),%dx
8010140c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101410:	8b 53 58             	mov    0x58(%ebx),%edx
80101413:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101416:	83 c3 5c             	add    $0x5c,%ebx
80101419:	83 c0 0c             	add    $0xc,%eax
8010141c:	83 c4 0c             	add    $0xc,%esp
8010141f:	6a 34                	push   $0x34
80101421:	53                   	push   %ebx
80101422:	50                   	push   %eax
80101423:	e8 9d 29 00 00       	call   80103dc5 <memmove>
  log_write(bp);
80101428:	89 34 24             	mov    %esi,(%esp)
8010142b:	e8 ed 13 00 00       	call   8010281d <log_write>
  brelse(bp);
80101430:	89 34 24             	mov    %esi,(%esp)
80101433:	e8 9b ed ff ff       	call   801001d3 <brelse>
}
80101438:	83 c4 10             	add    $0x10,%esp
8010143b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010143e:	5b                   	pop    %ebx
8010143f:	5e                   	pop    %esi
80101440:	5d                   	pop    %ebp
80101441:	c3                   	ret    

80101442 <itrunc>:
{
80101442:	55                   	push   %ebp
80101443:	89 e5                	mov    %esp,%ebp
80101445:	57                   	push   %edi
80101446:	56                   	push   %esi
80101447:	53                   	push   %ebx
80101448:	83 ec 1c             	sub    $0x1c,%esp
8010144b:	89 c6                	mov    %eax,%esi
  for(i = 0; i < NDIRECT; i++){
8010144d:	bb 00 00 00 00       	mov    $0x0,%ebx
80101452:	eb 01                	jmp    80101455 <itrunc+0x13>
80101454:	43                   	inc    %ebx
80101455:	83 fb 0b             	cmp    $0xb,%ebx
80101458:	7f 19                	jg     80101473 <itrunc+0x31>
    if(ip->addrs[i]){
8010145a:	8b 54 9e 5c          	mov    0x5c(%esi,%ebx,4),%edx
8010145e:	85 d2                	test   %edx,%edx
80101460:	74 f2                	je     80101454 <itrunc+0x12>
      bfree(ip->dev, ip->addrs[i]);
80101462:	8b 06                	mov    (%esi),%eax
80101464:	e8 aa fd ff ff       	call   80101213 <bfree>
      ip->addrs[i] = 0;
80101469:	c7 44 9e 5c 00 00 00 	movl   $0x0,0x5c(%esi,%ebx,4)
80101470:	00 
80101471:	eb e1                	jmp    80101454 <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
80101473:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
80101479:	85 c0                	test   %eax,%eax
8010147b:	75 1b                	jne    80101498 <itrunc+0x56>
  ip->size = 0;
8010147d:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
80101484:	83 ec 0c             	sub    $0xc,%esp
80101487:	56                   	push   %esi
80101488:	e8 38 ff ff ff       	call   801013c5 <iupdate>
}
8010148d:	83 c4 10             	add    $0x10,%esp
80101490:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101493:	5b                   	pop    %ebx
80101494:	5e                   	pop    %esi
80101495:	5f                   	pop    %edi
80101496:	5d                   	pop    %ebp
80101497:	c3                   	ret    
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101498:	83 ec 08             	sub    $0x8,%esp
8010149b:	50                   	push   %eax
8010149c:	ff 36                	push   (%esi)
8010149e:	e8 c7 ec ff ff       	call   8010016a <bread>
801014a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
801014a6:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
801014a9:	83 c4 10             	add    $0x10,%esp
801014ac:	bb 00 00 00 00       	mov    $0x0,%ebx
801014b1:	eb 01                	jmp    801014b4 <itrunc+0x72>
801014b3:	43                   	inc    %ebx
801014b4:	83 fb 7f             	cmp    $0x7f,%ebx
801014b7:	77 10                	ja     801014c9 <itrunc+0x87>
      if(a[j])
801014b9:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
801014bc:	85 d2                	test   %edx,%edx
801014be:	74 f3                	je     801014b3 <itrunc+0x71>
        bfree(ip->dev, a[j]);
801014c0:	8b 06                	mov    (%esi),%eax
801014c2:	e8 4c fd ff ff       	call   80101213 <bfree>
801014c7:	eb ea                	jmp    801014b3 <itrunc+0x71>
    brelse(bp);
801014c9:	83 ec 0c             	sub    $0xc,%esp
801014cc:	ff 75 e4             	push   -0x1c(%ebp)
801014cf:	e8 ff ec ff ff       	call   801001d3 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
801014d4:	8b 06                	mov    (%esi),%eax
801014d6:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
801014dc:	e8 32 fd ff ff       	call   80101213 <bfree>
    ip->addrs[NDIRECT] = 0;
801014e1:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
801014e8:	00 00 00 
801014eb:	83 c4 10             	add    $0x10,%esp
801014ee:	eb 8d                	jmp    8010147d <itrunc+0x3b>

801014f0 <idup>:
{
801014f0:	55                   	push   %ebp
801014f1:	89 e5                	mov    %esp,%ebp
801014f3:	53                   	push   %ebx
801014f4:	83 ec 10             	sub    $0x10,%esp
801014f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
801014fa:	68 60 f9 10 80       	push   $0x8010f960
801014ff:	e8 9f 27 00 00       	call   80103ca3 <acquire>
  ip->ref++;
80101504:	8b 43 08             	mov    0x8(%ebx),%eax
80101507:	40                   	inc    %eax
80101508:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010150b:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101512:	e8 f1 27 00 00       	call   80103d08 <release>
}
80101517:	89 d8                	mov    %ebx,%eax
80101519:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010151c:	c9                   	leave  
8010151d:	c3                   	ret    

8010151e <ilock>:
{
8010151e:	55                   	push   %ebp
8010151f:	89 e5                	mov    %esp,%ebp
80101521:	56                   	push   %esi
80101522:	53                   	push   %ebx
80101523:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101526:	85 db                	test   %ebx,%ebx
80101528:	74 22                	je     8010154c <ilock+0x2e>
8010152a:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
8010152e:	7e 1c                	jle    8010154c <ilock+0x2e>
  acquiresleep(&ip->lock);
80101530:	83 ec 0c             	sub    $0xc,%esp
80101533:	8d 43 0c             	lea    0xc(%ebx),%eax
80101536:	50                   	push   %eax
80101537:	e8 58 25 00 00       	call   80103a94 <acquiresleep>
  if(ip->valid == 0){
8010153c:	83 c4 10             	add    $0x10,%esp
8010153f:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101543:	74 14                	je     80101559 <ilock+0x3b>
}
80101545:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101548:	5b                   	pop    %ebx
80101549:	5e                   	pop    %esi
8010154a:	5d                   	pop    %ebp
8010154b:	c3                   	ret    
    panic("ilock");
8010154c:	83 ec 0c             	sub    $0xc,%esp
8010154f:	68 8a 6b 10 80       	push   $0x80106b8a
80101554:	e8 e8 ed ff ff       	call   80100341 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101559:	8b 43 04             	mov    0x4(%ebx),%eax
8010155c:	c1 e8 03             	shr    $0x3,%eax
8010155f:	83 ec 08             	sub    $0x8,%esp
80101562:	03 05 c8 15 11 80    	add    0x801115c8,%eax
80101568:	50                   	push   %eax
80101569:	ff 33                	push   (%ebx)
8010156b:	e8 fa eb ff ff       	call   8010016a <bread>
80101570:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101572:	8b 43 04             	mov    0x4(%ebx),%eax
80101575:	83 e0 07             	and    $0x7,%eax
80101578:	c1 e0 06             	shl    $0x6,%eax
8010157b:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
8010157f:	8b 10                	mov    (%eax),%edx
80101581:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
80101585:	66 8b 50 02          	mov    0x2(%eax),%dx
80101589:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
8010158d:	8b 50 04             	mov    0x4(%eax),%edx
80101590:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
80101594:	66 8b 50 06          	mov    0x6(%eax),%dx
80101598:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
8010159c:	8b 50 08             	mov    0x8(%eax),%edx
8010159f:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801015a2:	83 c0 0c             	add    $0xc,%eax
801015a5:	8d 53 5c             	lea    0x5c(%ebx),%edx
801015a8:	83 c4 0c             	add    $0xc,%esp
801015ab:	6a 34                	push   $0x34
801015ad:	50                   	push   %eax
801015ae:	52                   	push   %edx
801015af:	e8 11 28 00 00       	call   80103dc5 <memmove>
    brelse(bp);
801015b4:	89 34 24             	mov    %esi,(%esp)
801015b7:	e8 17 ec ff ff       	call   801001d3 <brelse>
    ip->valid = 1;
801015bc:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
801015c3:	83 c4 10             	add    $0x10,%esp
801015c6:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
801015cb:	0f 85 74 ff ff ff    	jne    80101545 <ilock+0x27>
      panic("ilock: no type");
801015d1:	83 ec 0c             	sub    $0xc,%esp
801015d4:	68 90 6b 10 80       	push   $0x80106b90
801015d9:	e8 63 ed ff ff       	call   80100341 <panic>

801015de <iunlock>:
{
801015de:	55                   	push   %ebp
801015df:	89 e5                	mov    %esp,%ebp
801015e1:	56                   	push   %esi
801015e2:	53                   	push   %ebx
801015e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801015e6:	85 db                	test   %ebx,%ebx
801015e8:	74 2c                	je     80101616 <iunlock+0x38>
801015ea:	8d 73 0c             	lea    0xc(%ebx),%esi
801015ed:	83 ec 0c             	sub    $0xc,%esp
801015f0:	56                   	push   %esi
801015f1:	e8 28 25 00 00       	call   80103b1e <holdingsleep>
801015f6:	83 c4 10             	add    $0x10,%esp
801015f9:	85 c0                	test   %eax,%eax
801015fb:	74 19                	je     80101616 <iunlock+0x38>
801015fd:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101601:	7e 13                	jle    80101616 <iunlock+0x38>
  releasesleep(&ip->lock);
80101603:	83 ec 0c             	sub    $0xc,%esp
80101606:	56                   	push   %esi
80101607:	e8 d7 24 00 00       	call   80103ae3 <releasesleep>
}
8010160c:	83 c4 10             	add    $0x10,%esp
8010160f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101612:	5b                   	pop    %ebx
80101613:	5e                   	pop    %esi
80101614:	5d                   	pop    %ebp
80101615:	c3                   	ret    
    panic("iunlock");
80101616:	83 ec 0c             	sub    $0xc,%esp
80101619:	68 9f 6b 10 80       	push   $0x80106b9f
8010161e:	e8 1e ed ff ff       	call   80100341 <panic>

80101623 <iput>:
{
80101623:	55                   	push   %ebp
80101624:	89 e5                	mov    %esp,%ebp
80101626:	57                   	push   %edi
80101627:	56                   	push   %esi
80101628:	53                   	push   %ebx
80101629:	83 ec 18             	sub    $0x18,%esp
8010162c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
8010162f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101632:	56                   	push   %esi
80101633:	e8 5c 24 00 00       	call   80103a94 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101638:	83 c4 10             	add    $0x10,%esp
8010163b:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
8010163f:	74 07                	je     80101648 <iput+0x25>
80101641:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101646:	74 33                	je     8010167b <iput+0x58>
  releasesleep(&ip->lock);
80101648:	83 ec 0c             	sub    $0xc,%esp
8010164b:	56                   	push   %esi
8010164c:	e8 92 24 00 00       	call   80103ae3 <releasesleep>
  acquire(&icache.lock);
80101651:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101658:	e8 46 26 00 00       	call   80103ca3 <acquire>
  ip->ref--;
8010165d:	8b 43 08             	mov    0x8(%ebx),%eax
80101660:	48                   	dec    %eax
80101661:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
80101664:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
8010166b:	e8 98 26 00 00       	call   80103d08 <release>
}
80101670:	83 c4 10             	add    $0x10,%esp
80101673:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101676:	5b                   	pop    %ebx
80101677:	5e                   	pop    %esi
80101678:	5f                   	pop    %edi
80101679:	5d                   	pop    %ebp
8010167a:	c3                   	ret    
    acquire(&icache.lock);
8010167b:	83 ec 0c             	sub    $0xc,%esp
8010167e:	68 60 f9 10 80       	push   $0x8010f960
80101683:	e8 1b 26 00 00       	call   80103ca3 <acquire>
    int r = ip->ref;
80101688:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
8010168b:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101692:	e8 71 26 00 00       	call   80103d08 <release>
    if(r == 1){
80101697:	83 c4 10             	add    $0x10,%esp
8010169a:	83 ff 01             	cmp    $0x1,%edi
8010169d:	75 a9                	jne    80101648 <iput+0x25>
      itrunc(ip);
8010169f:	89 d8                	mov    %ebx,%eax
801016a1:	e8 9c fd ff ff       	call   80101442 <itrunc>
      ip->type = 0;
801016a6:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
801016ac:	83 ec 0c             	sub    $0xc,%esp
801016af:	53                   	push   %ebx
801016b0:	e8 10 fd ff ff       	call   801013c5 <iupdate>
      ip->valid = 0;
801016b5:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
801016bc:	83 c4 10             	add    $0x10,%esp
801016bf:	eb 87                	jmp    80101648 <iput+0x25>

801016c1 <iunlockput>:
{
801016c1:	55                   	push   %ebp
801016c2:	89 e5                	mov    %esp,%ebp
801016c4:	53                   	push   %ebx
801016c5:	83 ec 10             	sub    $0x10,%esp
801016c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
801016cb:	53                   	push   %ebx
801016cc:	e8 0d ff ff ff       	call   801015de <iunlock>
  iput(ip);
801016d1:	89 1c 24             	mov    %ebx,(%esp)
801016d4:	e8 4a ff ff ff       	call   80101623 <iput>
}
801016d9:	83 c4 10             	add    $0x10,%esp
801016dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801016df:	c9                   	leave  
801016e0:	c3                   	ret    

801016e1 <stati>:
{
801016e1:	55                   	push   %ebp
801016e2:	89 e5                	mov    %esp,%ebp
801016e4:	8b 55 08             	mov    0x8(%ebp),%edx
801016e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
801016ea:	8b 0a                	mov    (%edx),%ecx
801016ec:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
801016ef:	8b 4a 04             	mov    0x4(%edx),%ecx
801016f2:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
801016f5:	8b 4a 50             	mov    0x50(%edx),%ecx
801016f8:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
801016fb:	66 8b 4a 56          	mov    0x56(%edx),%cx
801016ff:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101703:	8b 52 58             	mov    0x58(%edx),%edx
80101706:	89 50 10             	mov    %edx,0x10(%eax)
}
80101709:	5d                   	pop    %ebp
8010170a:	c3                   	ret    

8010170b <readi>:
{
8010170b:	55                   	push   %ebp
8010170c:	89 e5                	mov    %esp,%ebp
8010170e:	57                   	push   %edi
8010170f:	56                   	push   %esi
80101710:	53                   	push   %ebx
80101711:	83 ec 0c             	sub    $0xc,%esp
  if(ip->type == T_DEV){
80101714:	8b 45 08             	mov    0x8(%ebp),%eax
80101717:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
8010171c:	74 2c                	je     8010174a <readi+0x3f>
  if(off > ip->size || off + n < off)
8010171e:	8b 45 08             	mov    0x8(%ebp),%eax
80101721:	8b 40 58             	mov    0x58(%eax),%eax
80101724:	3b 45 10             	cmp    0x10(%ebp),%eax
80101727:	0f 82 d0 00 00 00    	jb     801017fd <readi+0xf2>
8010172d:	8b 55 10             	mov    0x10(%ebp),%edx
80101730:	03 55 14             	add    0x14(%ebp),%edx
80101733:	0f 82 cb 00 00 00    	jb     80101804 <readi+0xf9>
  if(off + n > ip->size)
80101739:	39 d0                	cmp    %edx,%eax
8010173b:	73 06                	jae    80101743 <readi+0x38>
    n = ip->size - off;
8010173d:	2b 45 10             	sub    0x10(%ebp),%eax
80101740:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101743:	bf 00 00 00 00       	mov    $0x0,%edi
80101748:	eb 55                	jmp    8010179f <readi+0x94>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
8010174a:	66 8b 40 52          	mov    0x52(%eax),%ax
8010174e:	66 83 f8 09          	cmp    $0x9,%ax
80101752:	0f 87 97 00 00 00    	ja     801017ef <readi+0xe4>
80101758:	98                   	cwtl   
80101759:	8b 04 c5 00 f9 10 80 	mov    -0x7fef0700(,%eax,8),%eax
80101760:	85 c0                	test   %eax,%eax
80101762:	0f 84 8e 00 00 00    	je     801017f6 <readi+0xeb>
    return devsw[ip->major].read(ip, dst, n);
80101768:	83 ec 04             	sub    $0x4,%esp
8010176b:	ff 75 14             	push   0x14(%ebp)
8010176e:	ff 75 0c             	push   0xc(%ebp)
80101771:	ff 75 08             	push   0x8(%ebp)
80101774:	ff d0                	call   *%eax
80101776:	83 c4 10             	add    $0x10,%esp
80101779:	eb 6c                	jmp    801017e7 <readi+0xdc>
    memmove(dst, bp->data + off%BSIZE, m);
8010177b:	83 ec 04             	sub    $0x4,%esp
8010177e:	53                   	push   %ebx
8010177f:	8d 44 16 5c          	lea    0x5c(%esi,%edx,1),%eax
80101783:	50                   	push   %eax
80101784:	ff 75 0c             	push   0xc(%ebp)
80101787:	e8 39 26 00 00       	call   80103dc5 <memmove>
    brelse(bp);
8010178c:	89 34 24             	mov    %esi,(%esp)
8010178f:	e8 3f ea ff ff       	call   801001d3 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101794:	01 df                	add    %ebx,%edi
80101796:	01 5d 10             	add    %ebx,0x10(%ebp)
80101799:	01 5d 0c             	add    %ebx,0xc(%ebp)
8010179c:	83 c4 10             	add    $0x10,%esp
8010179f:	39 7d 14             	cmp    %edi,0x14(%ebp)
801017a2:	76 40                	jbe    801017e4 <readi+0xd9>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801017a4:	8b 55 10             	mov    0x10(%ebp),%edx
801017a7:	c1 ea 09             	shr    $0x9,%edx
801017aa:	8b 45 08             	mov    0x8(%ebp),%eax
801017ad:	e8 da f8 ff ff       	call   8010108c <bmap>
801017b2:	83 ec 08             	sub    $0x8,%esp
801017b5:	50                   	push   %eax
801017b6:	8b 45 08             	mov    0x8(%ebp),%eax
801017b9:	ff 30                	push   (%eax)
801017bb:	e8 aa e9 ff ff       	call   8010016a <bread>
801017c0:	89 c6                	mov    %eax,%esi
    m = min(n - tot, BSIZE - off%BSIZE);
801017c2:	8b 55 10             	mov    0x10(%ebp),%edx
801017c5:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801017cb:	b8 00 02 00 00       	mov    $0x200,%eax
801017d0:	29 d0                	sub    %edx,%eax
801017d2:	8b 4d 14             	mov    0x14(%ebp),%ecx
801017d5:	29 f9                	sub    %edi,%ecx
801017d7:	89 c3                	mov    %eax,%ebx
801017d9:	83 c4 10             	add    $0x10,%esp
801017dc:	39 c8                	cmp    %ecx,%eax
801017de:	76 9b                	jbe    8010177b <readi+0x70>
801017e0:	89 cb                	mov    %ecx,%ebx
801017e2:	eb 97                	jmp    8010177b <readi+0x70>
  return n;
801017e4:	8b 45 14             	mov    0x14(%ebp),%eax
}
801017e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017ea:	5b                   	pop    %ebx
801017eb:	5e                   	pop    %esi
801017ec:	5f                   	pop    %edi
801017ed:	5d                   	pop    %ebp
801017ee:	c3                   	ret    
      return -1;
801017ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801017f4:	eb f1                	jmp    801017e7 <readi+0xdc>
801017f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801017fb:	eb ea                	jmp    801017e7 <readi+0xdc>
    return -1;
801017fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101802:	eb e3                	jmp    801017e7 <readi+0xdc>
80101804:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101809:	eb dc                	jmp    801017e7 <readi+0xdc>

8010180b <writei>:
{
8010180b:	55                   	push   %ebp
8010180c:	89 e5                	mov    %esp,%ebp
8010180e:	57                   	push   %edi
8010180f:	56                   	push   %esi
80101810:	53                   	push   %ebx
80101811:	83 ec 0c             	sub    $0xc,%esp
  if(ip->type == T_DEV){
80101814:	8b 45 08             	mov    0x8(%ebp),%eax
80101817:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
8010181c:	74 2c                	je     8010184a <writei+0x3f>
  if(off > ip->size || off + n < off)
8010181e:	8b 45 08             	mov    0x8(%ebp),%eax
80101821:	8b 7d 10             	mov    0x10(%ebp),%edi
80101824:	39 78 58             	cmp    %edi,0x58(%eax)
80101827:	0f 82 fd 00 00 00    	jb     8010192a <writei+0x11f>
8010182d:	89 f8                	mov    %edi,%eax
8010182f:	03 45 14             	add    0x14(%ebp),%eax
80101832:	0f 82 f9 00 00 00    	jb     80101931 <writei+0x126>
  if(off + n > MAXFILE*BSIZE)
80101838:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010183d:	0f 87 f5 00 00 00    	ja     80101938 <writei+0x12d>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101843:	bf 00 00 00 00       	mov    $0x0,%edi
80101848:	eb 60                	jmp    801018aa <writei+0x9f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010184a:	66 8b 40 52          	mov    0x52(%eax),%ax
8010184e:	66 83 f8 09          	cmp    $0x9,%ax
80101852:	0f 87 c4 00 00 00    	ja     8010191c <writei+0x111>
80101858:	98                   	cwtl   
80101859:	8b 04 c5 04 f9 10 80 	mov    -0x7fef06fc(,%eax,8),%eax
80101860:	85 c0                	test   %eax,%eax
80101862:	0f 84 bb 00 00 00    	je     80101923 <writei+0x118>
    return devsw[ip->major].write(ip, src, n);
80101868:	83 ec 04             	sub    $0x4,%esp
8010186b:	ff 75 14             	push   0x14(%ebp)
8010186e:	ff 75 0c             	push   0xc(%ebp)
80101871:	ff 75 08             	push   0x8(%ebp)
80101874:	ff d0                	call   *%eax
80101876:	83 c4 10             	add    $0x10,%esp
80101879:	e9 85 00 00 00       	jmp    80101903 <writei+0xf8>
    memmove(bp->data + off%BSIZE, src, m);
8010187e:	83 ec 04             	sub    $0x4,%esp
80101881:	56                   	push   %esi
80101882:	ff 75 0c             	push   0xc(%ebp)
80101885:	8d 44 13 5c          	lea    0x5c(%ebx,%edx,1),%eax
80101889:	50                   	push   %eax
8010188a:	e8 36 25 00 00       	call   80103dc5 <memmove>
    log_write(bp);
8010188f:	89 1c 24             	mov    %ebx,(%esp)
80101892:	e8 86 0f 00 00       	call   8010281d <log_write>
    brelse(bp);
80101897:	89 1c 24             	mov    %ebx,(%esp)
8010189a:	e8 34 e9 ff ff       	call   801001d3 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010189f:	01 f7                	add    %esi,%edi
801018a1:	01 75 10             	add    %esi,0x10(%ebp)
801018a4:	01 75 0c             	add    %esi,0xc(%ebp)
801018a7:	83 c4 10             	add    $0x10,%esp
801018aa:	3b 7d 14             	cmp    0x14(%ebp),%edi
801018ad:	73 40                	jae    801018ef <writei+0xe4>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801018af:	8b 55 10             	mov    0x10(%ebp),%edx
801018b2:	c1 ea 09             	shr    $0x9,%edx
801018b5:	8b 45 08             	mov    0x8(%ebp),%eax
801018b8:	e8 cf f7 ff ff       	call   8010108c <bmap>
801018bd:	83 ec 08             	sub    $0x8,%esp
801018c0:	50                   	push   %eax
801018c1:	8b 45 08             	mov    0x8(%ebp),%eax
801018c4:	ff 30                	push   (%eax)
801018c6:	e8 9f e8 ff ff       	call   8010016a <bread>
801018cb:	89 c3                	mov    %eax,%ebx
    m = min(n - tot, BSIZE - off%BSIZE);
801018cd:	8b 55 10             	mov    0x10(%ebp),%edx
801018d0:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801018d6:	b8 00 02 00 00       	mov    $0x200,%eax
801018db:	29 d0                	sub    %edx,%eax
801018dd:	8b 4d 14             	mov    0x14(%ebp),%ecx
801018e0:	29 f9                	sub    %edi,%ecx
801018e2:	89 c6                	mov    %eax,%esi
801018e4:	83 c4 10             	add    $0x10,%esp
801018e7:	39 c8                	cmp    %ecx,%eax
801018e9:	76 93                	jbe    8010187e <writei+0x73>
801018eb:	89 ce                	mov    %ecx,%esi
801018ed:	eb 8f                	jmp    8010187e <writei+0x73>
  if(n > 0 && off > ip->size){
801018ef:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801018f3:	74 0b                	je     80101900 <writei+0xf5>
801018f5:	8b 45 08             	mov    0x8(%ebp),%eax
801018f8:	8b 7d 10             	mov    0x10(%ebp),%edi
801018fb:	39 78 58             	cmp    %edi,0x58(%eax)
801018fe:	72 0b                	jb     8010190b <writei+0x100>
  return n;
80101900:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101903:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101906:	5b                   	pop    %ebx
80101907:	5e                   	pop    %esi
80101908:	5f                   	pop    %edi
80101909:	5d                   	pop    %ebp
8010190a:	c3                   	ret    
    ip->size = off;
8010190b:	89 78 58             	mov    %edi,0x58(%eax)
    iupdate(ip);
8010190e:	83 ec 0c             	sub    $0xc,%esp
80101911:	50                   	push   %eax
80101912:	e8 ae fa ff ff       	call   801013c5 <iupdate>
80101917:	83 c4 10             	add    $0x10,%esp
8010191a:	eb e4                	jmp    80101900 <writei+0xf5>
      return -1;
8010191c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101921:	eb e0                	jmp    80101903 <writei+0xf8>
80101923:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101928:	eb d9                	jmp    80101903 <writei+0xf8>
    return -1;
8010192a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010192f:	eb d2                	jmp    80101903 <writei+0xf8>
80101931:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101936:	eb cb                	jmp    80101903 <writei+0xf8>
    return -1;
80101938:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010193d:	eb c4                	jmp    80101903 <writei+0xf8>

8010193f <namecmp>:
{
8010193f:	55                   	push   %ebp
80101940:	89 e5                	mov    %esp,%ebp
80101942:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101945:	6a 0e                	push   $0xe
80101947:	ff 75 0c             	push   0xc(%ebp)
8010194a:	ff 75 08             	push   0x8(%ebp)
8010194d:	e8 d9 24 00 00       	call   80103e2b <strncmp>
}
80101952:	c9                   	leave  
80101953:	c3                   	ret    

80101954 <dirlookup>:
{
80101954:	55                   	push   %ebp
80101955:	89 e5                	mov    %esp,%ebp
80101957:	57                   	push   %edi
80101958:	56                   	push   %esi
80101959:	53                   	push   %ebx
8010195a:	83 ec 1c             	sub    $0x1c,%esp
8010195d:	8b 75 08             	mov    0x8(%ebp),%esi
80101960:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(dp->type != T_DIR)
80101963:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101968:	75 07                	jne    80101971 <dirlookup+0x1d>
  for(off = 0; off < dp->size; off += sizeof(de)){
8010196a:	bb 00 00 00 00       	mov    $0x0,%ebx
8010196f:	eb 1d                	jmp    8010198e <dirlookup+0x3a>
    panic("dirlookup not DIR");
80101971:	83 ec 0c             	sub    $0xc,%esp
80101974:	68 a7 6b 10 80       	push   $0x80106ba7
80101979:	e8 c3 e9 ff ff       	call   80100341 <panic>
      panic("dirlookup read");
8010197e:	83 ec 0c             	sub    $0xc,%esp
80101981:	68 b9 6b 10 80       	push   $0x80106bb9
80101986:	e8 b6 e9 ff ff       	call   80100341 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
8010198b:	83 c3 10             	add    $0x10,%ebx
8010198e:	39 5e 58             	cmp    %ebx,0x58(%esi)
80101991:	76 48                	jbe    801019db <dirlookup+0x87>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101993:	6a 10                	push   $0x10
80101995:	53                   	push   %ebx
80101996:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101999:	50                   	push   %eax
8010199a:	56                   	push   %esi
8010199b:	e8 6b fd ff ff       	call   8010170b <readi>
801019a0:	83 c4 10             	add    $0x10,%esp
801019a3:	83 f8 10             	cmp    $0x10,%eax
801019a6:	75 d6                	jne    8010197e <dirlookup+0x2a>
    if(de.inum == 0)
801019a8:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
801019ad:	74 dc                	je     8010198b <dirlookup+0x37>
    if(namecmp(name, de.name) == 0){
801019af:	83 ec 08             	sub    $0x8,%esp
801019b2:	8d 45 da             	lea    -0x26(%ebp),%eax
801019b5:	50                   	push   %eax
801019b6:	57                   	push   %edi
801019b7:	e8 83 ff ff ff       	call   8010193f <namecmp>
801019bc:	83 c4 10             	add    $0x10,%esp
801019bf:	85 c0                	test   %eax,%eax
801019c1:	75 c8                	jne    8010198b <dirlookup+0x37>
      if(poff)
801019c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801019c7:	74 05                	je     801019ce <dirlookup+0x7a>
        *poff = off;
801019c9:	8b 45 10             	mov    0x10(%ebp),%eax
801019cc:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
801019ce:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
801019d2:	8b 06                	mov    (%esi),%eax
801019d4:	e8 59 f7 ff ff       	call   80101132 <iget>
801019d9:	eb 05                	jmp    801019e0 <dirlookup+0x8c>
  return 0;
801019db:	b8 00 00 00 00       	mov    $0x0,%eax
}
801019e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801019e3:	5b                   	pop    %ebx
801019e4:	5e                   	pop    %esi
801019e5:	5f                   	pop    %edi
801019e6:	5d                   	pop    %ebp
801019e7:	c3                   	ret    

801019e8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801019e8:	55                   	push   %ebp
801019e9:	89 e5                	mov    %esp,%ebp
801019eb:	57                   	push   %edi
801019ec:	56                   	push   %esi
801019ed:	53                   	push   %ebx
801019ee:	83 ec 1c             	sub    $0x1c,%esp
801019f1:	89 c3                	mov    %eax,%ebx
801019f3:	89 55 e0             	mov    %edx,-0x20(%ebp)
801019f6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
801019f9:	80 38 2f             	cmpb   $0x2f,(%eax)
801019fc:	74 17                	je     80101a15 <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
801019fe:	e8 3a 17 00 00       	call   8010313d <myproc>
80101a03:	83 ec 0c             	sub    $0xc,%esp
80101a06:	ff 70 74             	push   0x74(%eax)
80101a09:	e8 e2 fa ff ff       	call   801014f0 <idup>
80101a0e:	89 c6                	mov    %eax,%esi
80101a10:	83 c4 10             	add    $0x10,%esp
80101a13:	eb 53                	jmp    80101a68 <namex+0x80>
    ip = iget(ROOTDEV, ROOTINO);
80101a15:	ba 01 00 00 00       	mov    $0x1,%edx
80101a1a:	b8 01 00 00 00       	mov    $0x1,%eax
80101a1f:	e8 0e f7 ff ff       	call   80101132 <iget>
80101a24:	89 c6                	mov    %eax,%esi
80101a26:	eb 40                	jmp    80101a68 <namex+0x80>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101a28:	83 ec 0c             	sub    $0xc,%esp
80101a2b:	56                   	push   %esi
80101a2c:	e8 90 fc ff ff       	call   801016c1 <iunlockput>
      return 0;
80101a31:	83 c4 10             	add    $0x10,%esp
80101a34:	be 00 00 00 00       	mov    $0x0,%esi
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101a39:	89 f0                	mov    %esi,%eax
80101a3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a3e:	5b                   	pop    %ebx
80101a3f:	5e                   	pop    %esi
80101a40:	5f                   	pop    %edi
80101a41:	5d                   	pop    %ebp
80101a42:	c3                   	ret    
    if((next = dirlookup(ip, name, 0)) == 0){
80101a43:	83 ec 04             	sub    $0x4,%esp
80101a46:	6a 00                	push   $0x0
80101a48:	ff 75 e4             	push   -0x1c(%ebp)
80101a4b:	56                   	push   %esi
80101a4c:	e8 03 ff ff ff       	call   80101954 <dirlookup>
80101a51:	89 c7                	mov    %eax,%edi
80101a53:	83 c4 10             	add    $0x10,%esp
80101a56:	85 c0                	test   %eax,%eax
80101a58:	74 4a                	je     80101aa4 <namex+0xbc>
    iunlockput(ip);
80101a5a:	83 ec 0c             	sub    $0xc,%esp
80101a5d:	56                   	push   %esi
80101a5e:	e8 5e fc ff ff       	call   801016c1 <iunlockput>
80101a63:	83 c4 10             	add    $0x10,%esp
    ip = next;
80101a66:	89 fe                	mov    %edi,%esi
  while((path = skipelem(path, name)) != 0){
80101a68:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101a6b:	89 d8                	mov    %ebx,%eax
80101a6d:	e8 97 f4 ff ff       	call   80100f09 <skipelem>
80101a72:	89 c3                	mov    %eax,%ebx
80101a74:	85 c0                	test   %eax,%eax
80101a76:	74 3c                	je     80101ab4 <namex+0xcc>
    ilock(ip);
80101a78:	83 ec 0c             	sub    $0xc,%esp
80101a7b:	56                   	push   %esi
80101a7c:	e8 9d fa ff ff       	call   8010151e <ilock>
    if(ip->type != T_DIR){
80101a81:	83 c4 10             	add    $0x10,%esp
80101a84:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101a89:	75 9d                	jne    80101a28 <namex+0x40>
    if(nameiparent && *path == '\0'){
80101a8b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101a8f:	74 b2                	je     80101a43 <namex+0x5b>
80101a91:	80 3b 00             	cmpb   $0x0,(%ebx)
80101a94:	75 ad                	jne    80101a43 <namex+0x5b>
      iunlock(ip);
80101a96:	83 ec 0c             	sub    $0xc,%esp
80101a99:	56                   	push   %esi
80101a9a:	e8 3f fb ff ff       	call   801015de <iunlock>
      return ip;
80101a9f:	83 c4 10             	add    $0x10,%esp
80101aa2:	eb 95                	jmp    80101a39 <namex+0x51>
      iunlockput(ip);
80101aa4:	83 ec 0c             	sub    $0xc,%esp
80101aa7:	56                   	push   %esi
80101aa8:	e8 14 fc ff ff       	call   801016c1 <iunlockput>
      return 0;
80101aad:	83 c4 10             	add    $0x10,%esp
80101ab0:	89 fe                	mov    %edi,%esi
80101ab2:	eb 85                	jmp    80101a39 <namex+0x51>
  if(nameiparent){
80101ab4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101ab8:	0f 84 7b ff ff ff    	je     80101a39 <namex+0x51>
    iput(ip);
80101abe:	83 ec 0c             	sub    $0xc,%esp
80101ac1:	56                   	push   %esi
80101ac2:	e8 5c fb ff ff       	call   80101623 <iput>
    return 0;
80101ac7:	83 c4 10             	add    $0x10,%esp
80101aca:	89 de                	mov    %ebx,%esi
80101acc:	e9 68 ff ff ff       	jmp    80101a39 <namex+0x51>

80101ad1 <dirlink>:
{
80101ad1:	55                   	push   %ebp
80101ad2:	89 e5                	mov    %esp,%ebp
80101ad4:	57                   	push   %edi
80101ad5:	56                   	push   %esi
80101ad6:	53                   	push   %ebx
80101ad7:	83 ec 20             	sub    $0x20,%esp
80101ada:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101add:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101ae0:	6a 00                	push   $0x0
80101ae2:	57                   	push   %edi
80101ae3:	53                   	push   %ebx
80101ae4:	e8 6b fe ff ff       	call   80101954 <dirlookup>
80101ae9:	83 c4 10             	add    $0x10,%esp
80101aec:	85 c0                	test   %eax,%eax
80101aee:	75 2d                	jne    80101b1d <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101af0:	b8 00 00 00 00       	mov    $0x0,%eax
80101af5:	89 c6                	mov    %eax,%esi
80101af7:	39 43 58             	cmp    %eax,0x58(%ebx)
80101afa:	76 41                	jbe    80101b3d <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101afc:	6a 10                	push   $0x10
80101afe:	50                   	push   %eax
80101aff:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101b02:	50                   	push   %eax
80101b03:	53                   	push   %ebx
80101b04:	e8 02 fc ff ff       	call   8010170b <readi>
80101b09:	83 c4 10             	add    $0x10,%esp
80101b0c:	83 f8 10             	cmp    $0x10,%eax
80101b0f:	75 1f                	jne    80101b30 <dirlink+0x5f>
    if(de.inum == 0)
80101b11:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101b16:	74 25                	je     80101b3d <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b18:	8d 46 10             	lea    0x10(%esi),%eax
80101b1b:	eb d8                	jmp    80101af5 <dirlink+0x24>
    iput(ip);
80101b1d:	83 ec 0c             	sub    $0xc,%esp
80101b20:	50                   	push   %eax
80101b21:	e8 fd fa ff ff       	call   80101623 <iput>
    return -1;
80101b26:	83 c4 10             	add    $0x10,%esp
80101b29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b2e:	eb 3d                	jmp    80101b6d <dirlink+0x9c>
      panic("dirlink read");
80101b30:	83 ec 0c             	sub    $0xc,%esp
80101b33:	68 c8 6b 10 80       	push   $0x80106bc8
80101b38:	e8 04 e8 ff ff       	call   80100341 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b3d:	83 ec 04             	sub    $0x4,%esp
80101b40:	6a 0e                	push   $0xe
80101b42:	57                   	push   %edi
80101b43:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101b46:	8d 45 da             	lea    -0x26(%ebp),%eax
80101b49:	50                   	push   %eax
80101b4a:	e8 14 23 00 00       	call   80103e63 <strncpy>
  de.inum = inum;
80101b4f:	8b 45 10             	mov    0x10(%ebp),%eax
80101b52:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101b56:	6a 10                	push   $0x10
80101b58:	56                   	push   %esi
80101b59:	57                   	push   %edi
80101b5a:	53                   	push   %ebx
80101b5b:	e8 ab fc ff ff       	call   8010180b <writei>
80101b60:	83 c4 20             	add    $0x20,%esp
80101b63:	83 f8 10             	cmp    $0x10,%eax
80101b66:	75 0d                	jne    80101b75 <dirlink+0xa4>
  return 0;
80101b68:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101b6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b70:	5b                   	pop    %ebx
80101b71:	5e                   	pop    %esi
80101b72:	5f                   	pop    %edi
80101b73:	5d                   	pop    %ebp
80101b74:	c3                   	ret    
    panic("dirlink");
80101b75:	83 ec 0c             	sub    $0xc,%esp
80101b78:	68 c0 71 10 80       	push   $0x801071c0
80101b7d:	e8 bf e7 ff ff       	call   80100341 <panic>

80101b82 <namei>:

struct inode*
namei(char *path)
{
80101b82:	55                   	push   %ebp
80101b83:	89 e5                	mov    %esp,%ebp
80101b85:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101b88:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101b8b:	ba 00 00 00 00       	mov    $0x0,%edx
80101b90:	8b 45 08             	mov    0x8(%ebp),%eax
80101b93:	e8 50 fe ff ff       	call   801019e8 <namex>
}
80101b98:	c9                   	leave  
80101b99:	c3                   	ret    

80101b9a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101b9a:	55                   	push   %ebp
80101b9b:	89 e5                	mov    %esp,%ebp
80101b9d:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101ba0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101ba3:	ba 01 00 00 00       	mov    $0x1,%edx
80101ba8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bab:	e8 38 fe ff ff       	call   801019e8 <namex>
}
80101bb0:	c9                   	leave  
80101bb1:	c3                   	ret    

80101bb2 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101bb2:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101bb4:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101bb9:	ec                   	in     (%dx),%al
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101bba:	88 c2                	mov    %al,%dl
80101bbc:	83 e2 c0             	and    $0xffffffc0,%edx
80101bbf:	80 fa 40             	cmp    $0x40,%dl
80101bc2:	75 f0                	jne    80101bb4 <idewait+0x2>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101bc4:	85 c9                	test   %ecx,%ecx
80101bc6:	74 09                	je     80101bd1 <idewait+0x1f>
80101bc8:	a8 21                	test   $0x21,%al
80101bca:	75 08                	jne    80101bd4 <idewait+0x22>
    return -1;
  return 0;
80101bcc:	b9 00 00 00 00       	mov    $0x0,%ecx
}
80101bd1:	89 c8                	mov    %ecx,%eax
80101bd3:	c3                   	ret    
    return -1;
80101bd4:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
80101bd9:	eb f6                	jmp    80101bd1 <idewait+0x1f>

80101bdb <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101bdb:	55                   	push   %ebp
80101bdc:	89 e5                	mov    %esp,%ebp
80101bde:	56                   	push   %esi
80101bdf:	53                   	push   %ebx
  if(b == 0)
80101be0:	85 c0                	test   %eax,%eax
80101be2:	0f 84 85 00 00 00    	je     80101c6d <idestart+0x92>
80101be8:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101bea:	8b 58 08             	mov    0x8(%eax),%ebx
80101bed:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101bf3:	0f 87 81 00 00 00    	ja     80101c7a <idestart+0x9f>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101bf9:	b8 00 00 00 00       	mov    $0x0,%eax
80101bfe:	e8 af ff ff ff       	call   80101bb2 <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101c03:	b0 00                	mov    $0x0,%al
80101c05:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101c0a:	ee                   	out    %al,(%dx)
80101c0b:	b0 01                	mov    $0x1,%al
80101c0d:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101c12:	ee                   	out    %al,(%dx)
80101c13:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101c18:	88 d8                	mov    %bl,%al
80101c1a:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101c1b:	0f b6 c7             	movzbl %bh,%eax
80101c1e:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101c23:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101c24:	89 d8                	mov    %ebx,%eax
80101c26:	c1 f8 10             	sar    $0x10,%eax
80101c29:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101c2e:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101c2f:	8a 46 04             	mov    0x4(%esi),%al
80101c32:	c1 e0 04             	shl    $0x4,%eax
80101c35:	83 e0 10             	and    $0x10,%eax
80101c38:	c1 fb 18             	sar    $0x18,%ebx
80101c3b:	83 e3 0f             	and    $0xf,%ebx
80101c3e:	09 d8                	or     %ebx,%eax
80101c40:	83 c8 e0             	or     $0xffffffe0,%eax
80101c43:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101c48:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101c49:	f6 06 04             	testb  $0x4,(%esi)
80101c4c:	74 39                	je     80101c87 <idestart+0xac>
80101c4e:	b0 30                	mov    $0x30,%al
80101c50:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c55:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
80101c56:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101c59:	b9 80 00 00 00       	mov    $0x80,%ecx
80101c5e:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101c63:	fc                   	cld    
80101c64:	f3 6f                	rep outsl %ds:(%esi),(%dx)
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101c66:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101c69:	5b                   	pop    %ebx
80101c6a:	5e                   	pop    %esi
80101c6b:	5d                   	pop    %ebp
80101c6c:	c3                   	ret    
    panic("idestart");
80101c6d:	83 ec 0c             	sub    $0xc,%esp
80101c70:	68 2b 6c 10 80       	push   $0x80106c2b
80101c75:	e8 c7 e6 ff ff       	call   80100341 <panic>
    panic("incorrect blockno");
80101c7a:	83 ec 0c             	sub    $0xc,%esp
80101c7d:	68 34 6c 10 80       	push   $0x80106c34
80101c82:	e8 ba e6 ff ff       	call   80100341 <panic>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101c87:	b0 20                	mov    $0x20,%al
80101c89:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c8e:	ee                   	out    %al,(%dx)
}
80101c8f:	eb d5                	jmp    80101c66 <idestart+0x8b>

80101c91 <ideinit>:
{
80101c91:	55                   	push   %ebp
80101c92:	89 e5                	mov    %esp,%ebp
80101c94:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101c97:	68 46 6c 10 80       	push   $0x80106c46
80101c9c:	68 00 16 11 80       	push   $0x80111600
80101ca1:	e8 c6 1e 00 00       	call   80103b6c <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101ca6:	83 c4 08             	add    $0x8,%esp
80101ca9:	a1 84 17 11 80       	mov    0x80111784,%eax
80101cae:	48                   	dec    %eax
80101caf:	50                   	push   %eax
80101cb0:	6a 0e                	push   $0xe
80101cb2:	e8 46 02 00 00       	call   80101efd <ioapicenable>
  idewait(0);
80101cb7:	b8 00 00 00 00       	mov    $0x0,%eax
80101cbc:	e8 f1 fe ff ff       	call   80101bb2 <idewait>
80101cc1:	b0 f0                	mov    $0xf0,%al
80101cc3:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101cc8:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101cc9:	83 c4 10             	add    $0x10,%esp
80101ccc:	b9 00 00 00 00       	mov    $0x0,%ecx
80101cd1:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101cd7:	7f 17                	jg     80101cf0 <ideinit+0x5f>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101cd9:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101cde:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101cdf:	84 c0                	test   %al,%al
80101ce1:	75 03                	jne    80101ce6 <ideinit+0x55>
  for(i=0; i<1000; i++){
80101ce3:	41                   	inc    %ecx
80101ce4:	eb eb                	jmp    80101cd1 <ideinit+0x40>
      havedisk1 = 1;
80101ce6:	c7 05 e0 15 11 80 01 	movl   $0x1,0x801115e0
80101ced:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101cf0:	b0 e0                	mov    $0xe0,%al
80101cf2:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101cf7:	ee                   	out    %al,(%dx)
}
80101cf8:	c9                   	leave  
80101cf9:	c3                   	ret    

80101cfa <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101cfa:	55                   	push   %ebp
80101cfb:	89 e5                	mov    %esp,%ebp
80101cfd:	57                   	push   %edi
80101cfe:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101cff:	83 ec 0c             	sub    $0xc,%esp
80101d02:	68 00 16 11 80       	push   $0x80111600
80101d07:	e8 97 1f 00 00       	call   80103ca3 <acquire>

  if((b = idequeue) == 0){
80101d0c:	8b 1d e4 15 11 80    	mov    0x801115e4,%ebx
80101d12:	83 c4 10             	add    $0x10,%esp
80101d15:	85 db                	test   %ebx,%ebx
80101d17:	74 4a                	je     80101d63 <ideintr+0x69>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101d19:	8b 43 58             	mov    0x58(%ebx),%eax
80101d1c:	a3 e4 15 11 80       	mov    %eax,0x801115e4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101d21:	f6 03 04             	testb  $0x4,(%ebx)
80101d24:	74 4f                	je     80101d75 <ideintr+0x7b>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101d26:	8b 03                	mov    (%ebx),%eax
80101d28:	83 c8 02             	or     $0x2,%eax
80101d2b:	89 03                	mov    %eax,(%ebx)
  b->flags &= ~B_DIRTY;
80101d2d:	83 e0 fb             	and    $0xfffffffb,%eax
80101d30:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101d32:	83 ec 0c             	sub    $0xc,%esp
80101d35:	53                   	push   %ebx
80101d36:	e8 d4 1b 00 00       	call   8010390f <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101d3b:	a1 e4 15 11 80       	mov    0x801115e4,%eax
80101d40:	83 c4 10             	add    $0x10,%esp
80101d43:	85 c0                	test   %eax,%eax
80101d45:	74 05                	je     80101d4c <ideintr+0x52>
    idestart(idequeue);
80101d47:	e8 8f fe ff ff       	call   80101bdb <idestart>

  release(&idelock);
80101d4c:	83 ec 0c             	sub    $0xc,%esp
80101d4f:	68 00 16 11 80       	push   $0x80111600
80101d54:	e8 af 1f 00 00       	call   80103d08 <release>
80101d59:	83 c4 10             	add    $0x10,%esp
}
80101d5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101d5f:	5b                   	pop    %ebx
80101d60:	5f                   	pop    %edi
80101d61:	5d                   	pop    %ebp
80101d62:	c3                   	ret    
    release(&idelock);
80101d63:	83 ec 0c             	sub    $0xc,%esp
80101d66:	68 00 16 11 80       	push   $0x80111600
80101d6b:	e8 98 1f 00 00       	call   80103d08 <release>
    return;
80101d70:	83 c4 10             	add    $0x10,%esp
80101d73:	eb e7                	jmp    80101d5c <ideintr+0x62>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101d75:	b8 01 00 00 00       	mov    $0x1,%eax
80101d7a:	e8 33 fe ff ff       	call   80101bb2 <idewait>
80101d7f:	85 c0                	test   %eax,%eax
80101d81:	78 a3                	js     80101d26 <ideintr+0x2c>
    insl(0x1f0, b->data, BSIZE/4);
80101d83:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101d86:	b9 80 00 00 00       	mov    $0x80,%ecx
80101d8b:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101d90:	fc                   	cld    
80101d91:	f3 6d                	rep insl (%dx),%es:(%edi)
}
80101d93:	eb 91                	jmp    80101d26 <ideintr+0x2c>

80101d95 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101d95:	55                   	push   %ebp
80101d96:	89 e5                	mov    %esp,%ebp
80101d98:	53                   	push   %ebx
80101d99:	83 ec 10             	sub    $0x10,%esp
80101d9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101d9f:	8d 43 0c             	lea    0xc(%ebx),%eax
80101da2:	50                   	push   %eax
80101da3:	e8 76 1d 00 00       	call   80103b1e <holdingsleep>
80101da8:	83 c4 10             	add    $0x10,%esp
80101dab:	85 c0                	test   %eax,%eax
80101dad:	74 37                	je     80101de6 <iderw+0x51>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101daf:	8b 03                	mov    (%ebx),%eax
80101db1:	83 e0 06             	and    $0x6,%eax
80101db4:	83 f8 02             	cmp    $0x2,%eax
80101db7:	74 3a                	je     80101df3 <iderw+0x5e>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101db9:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101dbd:	74 09                	je     80101dc8 <iderw+0x33>
80101dbf:	83 3d e0 15 11 80 00 	cmpl   $0x0,0x801115e0
80101dc6:	74 38                	je     80101e00 <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101dc8:	83 ec 0c             	sub    $0xc,%esp
80101dcb:	68 00 16 11 80       	push   $0x80111600
80101dd0:	e8 ce 1e 00 00       	call   80103ca3 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101dd5:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101ddc:	83 c4 10             	add    $0x10,%esp
80101ddf:	ba e4 15 11 80       	mov    $0x801115e4,%edx
80101de4:	eb 2a                	jmp    80101e10 <iderw+0x7b>
    panic("iderw: buf not locked");
80101de6:	83 ec 0c             	sub    $0xc,%esp
80101de9:	68 4a 6c 10 80       	push   $0x80106c4a
80101dee:	e8 4e e5 ff ff       	call   80100341 <panic>
    panic("iderw: nothing to do");
80101df3:	83 ec 0c             	sub    $0xc,%esp
80101df6:	68 60 6c 10 80       	push   $0x80106c60
80101dfb:	e8 41 e5 ff ff       	call   80100341 <panic>
    panic("iderw: ide disk 1 not present");
80101e00:	83 ec 0c             	sub    $0xc,%esp
80101e03:	68 75 6c 10 80       	push   $0x80106c75
80101e08:	e8 34 e5 ff ff       	call   80100341 <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e0d:	8d 50 58             	lea    0x58(%eax),%edx
80101e10:	8b 02                	mov    (%edx),%eax
80101e12:	85 c0                	test   %eax,%eax
80101e14:	75 f7                	jne    80101e0d <iderw+0x78>
    ;
  *pp = b;
80101e16:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101e18:	39 1d e4 15 11 80    	cmp    %ebx,0x801115e4
80101e1e:	75 1a                	jne    80101e3a <iderw+0xa5>
    idestart(b);
80101e20:	89 d8                	mov    %ebx,%eax
80101e22:	e8 b4 fd ff ff       	call   80101bdb <idestart>
80101e27:	eb 11                	jmp    80101e3a <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101e29:	83 ec 08             	sub    $0x8,%esp
80101e2c:	68 00 16 11 80       	push   $0x80111600
80101e31:	53                   	push   %ebx
80101e32:	e8 66 19 00 00       	call   8010379d <sleep>
80101e37:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101e3a:	8b 03                	mov    (%ebx),%eax
80101e3c:	83 e0 06             	and    $0x6,%eax
80101e3f:	83 f8 02             	cmp    $0x2,%eax
80101e42:	75 e5                	jne    80101e29 <iderw+0x94>
  }


  release(&idelock);
80101e44:	83 ec 0c             	sub    $0xc,%esp
80101e47:	68 00 16 11 80       	push   $0x80111600
80101e4c:	e8 b7 1e 00 00       	call   80103d08 <release>
}
80101e51:	83 c4 10             	add    $0x10,%esp
80101e54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101e57:	c9                   	leave  
80101e58:	c3                   	ret    

80101e59 <ioapicread>:
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
80101e59:	8b 15 34 16 11 80    	mov    0x80111634,%edx
80101e5f:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101e61:	a1 34 16 11 80       	mov    0x80111634,%eax
80101e66:	8b 40 10             	mov    0x10(%eax),%eax
}
80101e69:	c3                   	ret    

80101e6a <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80101e6a:	8b 0d 34 16 11 80    	mov    0x80111634,%ecx
80101e70:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101e72:	a1 34 16 11 80       	mov    0x80111634,%eax
80101e77:	89 50 10             	mov    %edx,0x10(%eax)
}
80101e7a:	c3                   	ret    

80101e7b <ioapicinit>:

void
ioapicinit(void)
{
80101e7b:	55                   	push   %ebp
80101e7c:	89 e5                	mov    %esp,%ebp
80101e7e:	57                   	push   %edi
80101e7f:	56                   	push   %esi
80101e80:	53                   	push   %ebx
80101e81:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101e84:	c7 05 34 16 11 80 00 	movl   $0xfec00000,0x80111634
80101e8b:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101e8e:	b8 01 00 00 00       	mov    $0x1,%eax
80101e93:	e8 c1 ff ff ff       	call   80101e59 <ioapicread>
80101e98:	c1 e8 10             	shr    $0x10,%eax
80101e9b:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80101e9e:	b8 00 00 00 00       	mov    $0x0,%eax
80101ea3:	e8 b1 ff ff ff       	call   80101e59 <ioapicread>
80101ea8:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101eab:	0f b6 15 80 17 11 80 	movzbl 0x80111780,%edx
80101eb2:	39 c2                	cmp    %eax,%edx
80101eb4:	75 07                	jne    80101ebd <ioapicinit+0x42>
{
80101eb6:	bb 00 00 00 00       	mov    $0x0,%ebx
80101ebb:	eb 34                	jmp    80101ef1 <ioapicinit+0x76>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101ebd:	83 ec 0c             	sub    $0xc,%esp
80101ec0:	68 94 6c 10 80       	push   $0x80106c94
80101ec5:	e8 10 e7 ff ff       	call   801005da <cprintf>
80101eca:	83 c4 10             	add    $0x10,%esp
80101ecd:	eb e7                	jmp    80101eb6 <ioapicinit+0x3b>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101ecf:	8d 53 20             	lea    0x20(%ebx),%edx
80101ed2:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101ed8:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101edc:	89 f0                	mov    %esi,%eax
80101ede:	e8 87 ff ff ff       	call   80101e6a <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101ee3:	8d 46 01             	lea    0x1(%esi),%eax
80101ee6:	ba 00 00 00 00       	mov    $0x0,%edx
80101eeb:	e8 7a ff ff ff       	call   80101e6a <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80101ef0:	43                   	inc    %ebx
80101ef1:	39 fb                	cmp    %edi,%ebx
80101ef3:	7e da                	jle    80101ecf <ioapicinit+0x54>
  }
}
80101ef5:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101ef8:	5b                   	pop    %ebx
80101ef9:	5e                   	pop    %esi
80101efa:	5f                   	pop    %edi
80101efb:	5d                   	pop    %ebp
80101efc:	c3                   	ret    

80101efd <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80101efd:	55                   	push   %ebp
80101efe:	89 e5                	mov    %esp,%ebp
80101f00:	53                   	push   %ebx
80101f01:	83 ec 04             	sub    $0x4,%esp
80101f04:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101f07:	8d 50 20             	lea    0x20(%eax),%edx
80101f0a:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80101f0e:	89 d8                	mov    %ebx,%eax
80101f10:	e8 55 ff ff ff       	call   80101e6a <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101f15:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f18:	c1 e2 18             	shl    $0x18,%edx
80101f1b:	8d 43 01             	lea    0x1(%ebx),%eax
80101f1e:	e8 47 ff ff ff       	call   80101e6a <ioapicwrite>
}
80101f23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101f26:	c9                   	leave  
80101f27:	c3                   	ret    

80101f28 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80101f28:	55                   	push   %ebp
80101f29:	89 e5                	mov    %esp,%ebp
80101f2b:	53                   	push   %ebx
80101f2c:	83 ec 04             	sub    $0x4,%esp
80101f2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80101f32:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80101f38:	75 4c                	jne    80101f86 <kfree+0x5e>
80101f3a:	81 fb d0 57 11 80    	cmp    $0x801157d0,%ebx
80101f40:	72 44                	jb     80101f86 <kfree+0x5e>
80101f42:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80101f48:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80101f4d:	77 37                	ja     80101f86 <kfree+0x5e>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80101f4f:	83 ec 04             	sub    $0x4,%esp
80101f52:	68 00 10 00 00       	push   $0x1000
80101f57:	6a 01                	push   $0x1
80101f59:	53                   	push   %ebx
80101f5a:	e8 f0 1d 00 00       	call   80103d4f <memset>

  if(kmem.use_lock)
80101f5f:	83 c4 10             	add    $0x10,%esp
80101f62:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80101f69:	75 28                	jne    80101f93 <kfree+0x6b>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80101f6b:	a1 78 16 11 80       	mov    0x80111678,%eax
80101f70:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80101f72:	89 1d 78 16 11 80    	mov    %ebx,0x80111678
  if(kmem.use_lock)
80101f78:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80101f7f:	75 24                	jne    80101fa5 <kfree+0x7d>
    release(&kmem.lock);
}
80101f81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101f84:	c9                   	leave  
80101f85:	c3                   	ret    
    panic("kfree");
80101f86:	83 ec 0c             	sub    $0xc,%esp
80101f89:	68 c6 6c 10 80       	push   $0x80106cc6
80101f8e:	e8 ae e3 ff ff       	call   80100341 <panic>
    acquire(&kmem.lock);
80101f93:	83 ec 0c             	sub    $0xc,%esp
80101f96:	68 40 16 11 80       	push   $0x80111640
80101f9b:	e8 03 1d 00 00       	call   80103ca3 <acquire>
80101fa0:	83 c4 10             	add    $0x10,%esp
80101fa3:	eb c6                	jmp    80101f6b <kfree+0x43>
    release(&kmem.lock);
80101fa5:	83 ec 0c             	sub    $0xc,%esp
80101fa8:	68 40 16 11 80       	push   $0x80111640
80101fad:	e8 56 1d 00 00       	call   80103d08 <release>
80101fb2:	83 c4 10             	add    $0x10,%esp
}
80101fb5:	eb ca                	jmp    80101f81 <kfree+0x59>

80101fb7 <freerange>:
{
80101fb7:	55                   	push   %ebp
80101fb8:	89 e5                	mov    %esp,%ebp
80101fba:	56                   	push   %esi
80101fbb:	53                   	push   %ebx
80101fbc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  p = (char*)PGROUNDUP((uint)vstart);
80101fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc2:	05 ff 0f 00 00       	add    $0xfff,%eax
80101fc7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80101fcc:	eb 0e                	jmp    80101fdc <freerange+0x25>
    kfree(p);
80101fce:	83 ec 0c             	sub    $0xc,%esp
80101fd1:	50                   	push   %eax
80101fd2:	e8 51 ff ff ff       	call   80101f28 <kfree>
80101fd7:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80101fda:	89 f0                	mov    %esi,%eax
80101fdc:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
80101fe2:	39 de                	cmp    %ebx,%esi
80101fe4:	76 e8                	jbe    80101fce <freerange+0x17>
}
80101fe6:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101fe9:	5b                   	pop    %ebx
80101fea:	5e                   	pop    %esi
80101feb:	5d                   	pop    %ebp
80101fec:	c3                   	ret    

80101fed <kinit1>:
{
80101fed:	55                   	push   %ebp
80101fee:	89 e5                	mov    %esp,%ebp
80101ff0:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
80101ff3:	68 cc 6c 10 80       	push   $0x80106ccc
80101ff8:	68 40 16 11 80       	push   $0x80111640
80101ffd:	e8 6a 1b 00 00       	call   80103b6c <initlock>
  kmem.use_lock = 0;
80102002:	c7 05 74 16 11 80 00 	movl   $0x0,0x80111674
80102009:	00 00 00 
  freerange(vstart, vend);
8010200c:	83 c4 08             	add    $0x8,%esp
8010200f:	ff 75 0c             	push   0xc(%ebp)
80102012:	ff 75 08             	push   0x8(%ebp)
80102015:	e8 9d ff ff ff       	call   80101fb7 <freerange>
}
8010201a:	83 c4 10             	add    $0x10,%esp
8010201d:	c9                   	leave  
8010201e:	c3                   	ret    

8010201f <kinit2>:
{
8010201f:	55                   	push   %ebp
80102020:	89 e5                	mov    %esp,%ebp
80102022:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
80102025:	ff 75 0c             	push   0xc(%ebp)
80102028:	ff 75 08             	push   0x8(%ebp)
8010202b:	e8 87 ff ff ff       	call   80101fb7 <freerange>
  kmem.use_lock = 1;
80102030:	c7 05 74 16 11 80 01 	movl   $0x1,0x80111674
80102037:	00 00 00 
}
8010203a:	83 c4 10             	add    $0x10,%esp
8010203d:	c9                   	leave  
8010203e:	c3                   	ret    

8010203f <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
8010203f:	55                   	push   %ebp
80102040:	89 e5                	mov    %esp,%ebp
80102042:	53                   	push   %ebx
80102043:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
80102046:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
8010204d:	75 21                	jne    80102070 <kalloc+0x31>
    acquire(&kmem.lock);
  r = kmem.freelist;
8010204f:	8b 1d 78 16 11 80    	mov    0x80111678,%ebx
  if(r)
80102055:	85 db                	test   %ebx,%ebx
80102057:	74 07                	je     80102060 <kalloc+0x21>
    kmem.freelist = r->next;
80102059:	8b 03                	mov    (%ebx),%eax
8010205b:	a3 78 16 11 80       	mov    %eax,0x80111678
  if(kmem.use_lock)
80102060:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80102067:	75 19                	jne    80102082 <kalloc+0x43>
    release(&kmem.lock);
  return (char*)r;
}
80102069:	89 d8                	mov    %ebx,%eax
8010206b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010206e:	c9                   	leave  
8010206f:	c3                   	ret    
    acquire(&kmem.lock);
80102070:	83 ec 0c             	sub    $0xc,%esp
80102073:	68 40 16 11 80       	push   $0x80111640
80102078:	e8 26 1c 00 00       	call   80103ca3 <acquire>
8010207d:	83 c4 10             	add    $0x10,%esp
80102080:	eb cd                	jmp    8010204f <kalloc+0x10>
    release(&kmem.lock);
80102082:	83 ec 0c             	sub    $0xc,%esp
80102085:	68 40 16 11 80       	push   $0x80111640
8010208a:	e8 79 1c 00 00       	call   80103d08 <release>
8010208f:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102092:	eb d5                	jmp    80102069 <kalloc+0x2a>

80102094 <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102094:	ba 64 00 00 00       	mov    $0x64,%edx
80102099:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
8010209a:	a8 01                	test   $0x1,%al
8010209c:	0f 84 b3 00 00 00    	je     80102155 <kbdgetc+0xc1>
801020a2:	ba 60 00 00 00       	mov    $0x60,%edx
801020a7:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
801020a8:	0f b6 c8             	movzbl %al,%ecx

  if(data == 0xE0){
801020ab:	3c e0                	cmp    $0xe0,%al
801020ad:	74 61                	je     80102110 <kbdgetc+0x7c>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
801020af:	84 c0                	test   %al,%al
801020b1:	78 6a                	js     8010211d <kbdgetc+0x89>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801020b3:	8b 15 7c 16 11 80    	mov    0x8011167c,%edx
801020b9:	f6 c2 40             	test   $0x40,%dl
801020bc:	74 0f                	je     801020cd <kbdgetc+0x39>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801020be:	83 c8 80             	or     $0xffffff80,%eax
801020c1:	0f b6 c8             	movzbl %al,%ecx
    shift &= ~E0ESC;
801020c4:	83 e2 bf             	and    $0xffffffbf,%edx
801020c7:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  }

  shift |= shiftcode[data];
801020cd:	0f b6 91 00 6e 10 80 	movzbl -0x7fef9200(%ecx),%edx
801020d4:	0b 15 7c 16 11 80    	or     0x8011167c,%edx
801020da:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  shift ^= togglecode[data];
801020e0:	0f b6 81 00 6d 10 80 	movzbl -0x7fef9300(%ecx),%eax
801020e7:	31 c2                	xor    %eax,%edx
801020e9:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  c = charcode[shift & (CTL | SHIFT)][data];
801020ef:	89 d0                	mov    %edx,%eax
801020f1:	83 e0 03             	and    $0x3,%eax
801020f4:	8b 04 85 e0 6c 10 80 	mov    -0x7fef9320(,%eax,4),%eax
801020fb:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
  if(shift & CAPSLOCK){
801020ff:	f6 c2 08             	test   $0x8,%dl
80102102:	74 56                	je     8010215a <kbdgetc+0xc6>
    if('a' <= c && c <= 'z')
80102104:	8d 50 9f             	lea    -0x61(%eax),%edx
80102107:	83 fa 19             	cmp    $0x19,%edx
8010210a:	77 3d                	ja     80102149 <kbdgetc+0xb5>
      c += 'A' - 'a';
8010210c:	83 e8 20             	sub    $0x20,%eax
8010210f:	c3                   	ret    
    shift |= E0ESC;
80102110:	83 0d 7c 16 11 80 40 	orl    $0x40,0x8011167c
    return 0;
80102117:	b8 00 00 00 00       	mov    $0x0,%eax
8010211c:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
8010211d:	8b 15 7c 16 11 80    	mov    0x8011167c,%edx
80102123:	f6 c2 40             	test   $0x40,%dl
80102126:	75 05                	jne    8010212d <kbdgetc+0x99>
80102128:	89 c1                	mov    %eax,%ecx
8010212a:	83 e1 7f             	and    $0x7f,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
8010212d:	8a 81 00 6e 10 80    	mov    -0x7fef9200(%ecx),%al
80102133:	83 c8 40             	or     $0x40,%eax
80102136:	0f b6 c0             	movzbl %al,%eax
80102139:	f7 d0                	not    %eax
8010213b:	21 c2                	and    %eax,%edx
8010213d:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
    return 0;
80102143:	b8 00 00 00 00       	mov    $0x0,%eax
80102148:	c3                   	ret    
    else if('A' <= c && c <= 'Z')
80102149:	8d 50 bf             	lea    -0x41(%eax),%edx
8010214c:	83 fa 19             	cmp    $0x19,%edx
8010214f:	77 09                	ja     8010215a <kbdgetc+0xc6>
      c += 'a' - 'A';
80102151:	83 c0 20             	add    $0x20,%eax
  }
  return c;
80102154:	c3                   	ret    
    return -1;
80102155:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010215a:	c3                   	ret    

8010215b <kbdintr>:

void
kbdintr(void)
{
8010215b:	55                   	push   %ebp
8010215c:	89 e5                	mov    %esp,%ebp
8010215e:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102161:	68 94 20 10 80       	push   $0x80102094
80102166:	e8 94 e5 ff ff       	call   801006ff <consoleintr>
}
8010216b:	83 c4 10             	add    $0x10,%esp
8010216e:	c9                   	leave  
8010216f:	c3                   	ret    

80102170 <lapicw>:

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102170:	8b 0d 80 16 11 80    	mov    0x80111680,%ecx
80102176:	8d 04 81             	lea    (%ecx,%eax,4),%eax
80102179:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010217b:	a1 80 16 11 80       	mov    0x80111680,%eax
80102180:	8b 40 20             	mov    0x20(%eax),%eax
}
80102183:	c3                   	ret    

80102184 <cmos_read>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102184:	ba 70 00 00 00       	mov    $0x70,%edx
80102189:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010218a:	ba 71 00 00 00       	mov    $0x71,%edx
8010218f:	ec                   	in     (%dx),%al
cmos_read(uint reg)
{
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
80102190:	0f b6 c0             	movzbl %al,%eax
}
80102193:	c3                   	ret    

80102194 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
80102194:	55                   	push   %ebp
80102195:	89 e5                	mov    %esp,%ebp
80102197:	53                   	push   %ebx
80102198:	83 ec 04             	sub    $0x4,%esp
8010219b:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
8010219d:	b8 00 00 00 00       	mov    $0x0,%eax
801021a2:	e8 dd ff ff ff       	call   80102184 <cmos_read>
801021a7:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
801021a9:	b8 02 00 00 00       	mov    $0x2,%eax
801021ae:	e8 d1 ff ff ff       	call   80102184 <cmos_read>
801021b3:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
801021b6:	b8 04 00 00 00       	mov    $0x4,%eax
801021bb:	e8 c4 ff ff ff       	call   80102184 <cmos_read>
801021c0:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
801021c3:	b8 07 00 00 00       	mov    $0x7,%eax
801021c8:	e8 b7 ff ff ff       	call   80102184 <cmos_read>
801021cd:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
801021d0:	b8 08 00 00 00       	mov    $0x8,%eax
801021d5:	e8 aa ff ff ff       	call   80102184 <cmos_read>
801021da:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
801021dd:	b8 09 00 00 00       	mov    $0x9,%eax
801021e2:	e8 9d ff ff ff       	call   80102184 <cmos_read>
801021e7:	89 43 14             	mov    %eax,0x14(%ebx)
}
801021ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801021ed:	c9                   	leave  
801021ee:	c3                   	ret    

801021ef <lapicinit>:
  if(!lapic)
801021ef:	83 3d 80 16 11 80 00 	cmpl   $0x0,0x80111680
801021f6:	0f 84 fe 00 00 00    	je     801022fa <lapicinit+0x10b>
{
801021fc:	55                   	push   %ebp
801021fd:	89 e5                	mov    %esp,%ebp
801021ff:	83 ec 08             	sub    $0x8,%esp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102202:	ba 3f 01 00 00       	mov    $0x13f,%edx
80102207:	b8 3c 00 00 00       	mov    $0x3c,%eax
8010220c:	e8 5f ff ff ff       	call   80102170 <lapicw>
  lapicw(TDCR, X1);
80102211:	ba 0b 00 00 00       	mov    $0xb,%edx
80102216:	b8 f8 00 00 00       	mov    $0xf8,%eax
8010221b:	e8 50 ff ff ff       	call   80102170 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102220:	ba 20 00 02 00       	mov    $0x20020,%edx
80102225:	b8 c8 00 00 00       	mov    $0xc8,%eax
8010222a:	e8 41 ff ff ff       	call   80102170 <lapicw>
  lapicw(TICR, 10000000);
8010222f:	ba 80 96 98 00       	mov    $0x989680,%edx
80102234:	b8 e0 00 00 00       	mov    $0xe0,%eax
80102239:	e8 32 ff ff ff       	call   80102170 <lapicw>
  lapicw(LINT0, MASKED);
8010223e:	ba 00 00 01 00       	mov    $0x10000,%edx
80102243:	b8 d4 00 00 00       	mov    $0xd4,%eax
80102248:	e8 23 ff ff ff       	call   80102170 <lapicw>
  lapicw(LINT1, MASKED);
8010224d:	ba 00 00 01 00       	mov    $0x10000,%edx
80102252:	b8 d8 00 00 00       	mov    $0xd8,%eax
80102257:	e8 14 ff ff ff       	call   80102170 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010225c:	a1 80 16 11 80       	mov    0x80111680,%eax
80102261:	8b 40 30             	mov    0x30(%eax),%eax
80102264:	c1 e8 10             	shr    $0x10,%eax
80102267:	a8 fc                	test   $0xfc,%al
80102269:	75 7b                	jne    801022e6 <lapicinit+0xf7>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010226b:	ba 33 00 00 00       	mov    $0x33,%edx
80102270:	b8 dc 00 00 00       	mov    $0xdc,%eax
80102275:	e8 f6 fe ff ff       	call   80102170 <lapicw>
  lapicw(ESR, 0);
8010227a:	ba 00 00 00 00       	mov    $0x0,%edx
8010227f:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102284:	e8 e7 fe ff ff       	call   80102170 <lapicw>
  lapicw(ESR, 0);
80102289:	ba 00 00 00 00       	mov    $0x0,%edx
8010228e:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102293:	e8 d8 fe ff ff       	call   80102170 <lapicw>
  lapicw(EOI, 0);
80102298:	ba 00 00 00 00       	mov    $0x0,%edx
8010229d:	b8 2c 00 00 00       	mov    $0x2c,%eax
801022a2:	e8 c9 fe ff ff       	call   80102170 <lapicw>
  lapicw(ICRHI, 0);
801022a7:	ba 00 00 00 00       	mov    $0x0,%edx
801022ac:	b8 c4 00 00 00       	mov    $0xc4,%eax
801022b1:	e8 ba fe ff ff       	call   80102170 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801022b6:	ba 00 85 08 00       	mov    $0x88500,%edx
801022bb:	b8 c0 00 00 00       	mov    $0xc0,%eax
801022c0:	e8 ab fe ff ff       	call   80102170 <lapicw>
  while(lapic[ICRLO] & DELIVS)
801022c5:	a1 80 16 11 80       	mov    0x80111680,%eax
801022ca:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
801022d0:	f6 c4 10             	test   $0x10,%ah
801022d3:	75 f0                	jne    801022c5 <lapicinit+0xd6>
  lapicw(TPR, 0);
801022d5:	ba 00 00 00 00       	mov    $0x0,%edx
801022da:	b8 20 00 00 00       	mov    $0x20,%eax
801022df:	e8 8c fe ff ff       	call   80102170 <lapicw>
}
801022e4:	c9                   	leave  
801022e5:	c3                   	ret    
    lapicw(PCINT, MASKED);
801022e6:	ba 00 00 01 00       	mov    $0x10000,%edx
801022eb:	b8 d0 00 00 00       	mov    $0xd0,%eax
801022f0:	e8 7b fe ff ff       	call   80102170 <lapicw>
801022f5:	e9 71 ff ff ff       	jmp    8010226b <lapicinit+0x7c>
801022fa:	c3                   	ret    

801022fb <lapicid>:
  if (!lapic)
801022fb:	a1 80 16 11 80       	mov    0x80111680,%eax
80102300:	85 c0                	test   %eax,%eax
80102302:	74 07                	je     8010230b <lapicid+0x10>
  return lapic[ID] >> 24;
80102304:	8b 40 20             	mov    0x20(%eax),%eax
80102307:	c1 e8 18             	shr    $0x18,%eax
8010230a:	c3                   	ret    
    return 0;
8010230b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102310:	c3                   	ret    

80102311 <lapiceoi>:
  if(lapic)
80102311:	83 3d 80 16 11 80 00 	cmpl   $0x0,0x80111680
80102318:	74 17                	je     80102331 <lapiceoi+0x20>
{
8010231a:	55                   	push   %ebp
8010231b:	89 e5                	mov    %esp,%ebp
8010231d:	83 ec 08             	sub    $0x8,%esp
    lapicw(EOI, 0);
80102320:	ba 00 00 00 00       	mov    $0x0,%edx
80102325:	b8 2c 00 00 00       	mov    $0x2c,%eax
8010232a:	e8 41 fe ff ff       	call   80102170 <lapicw>
}
8010232f:	c9                   	leave  
80102330:	c3                   	ret    
80102331:	c3                   	ret    

80102332 <microdelay>:
}
80102332:	c3                   	ret    

80102333 <lapicstartap>:
{
80102333:	55                   	push   %ebp
80102334:	89 e5                	mov    %esp,%ebp
80102336:	57                   	push   %edi
80102337:	56                   	push   %esi
80102338:	53                   	push   %ebx
80102339:	83 ec 0c             	sub    $0xc,%esp
8010233c:	8b 75 08             	mov    0x8(%ebp),%esi
8010233f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102342:	b0 0f                	mov    $0xf,%al
80102344:	ba 70 00 00 00       	mov    $0x70,%edx
80102349:	ee                   	out    %al,(%dx)
8010234a:	b0 0a                	mov    $0xa,%al
8010234c:	ba 71 00 00 00       	mov    $0x71,%edx
80102351:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
80102352:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
80102359:	00 00 
  wrv[1] = addr >> 4;
8010235b:	89 f8                	mov    %edi,%eax
8010235d:	c1 e8 04             	shr    $0x4,%eax
80102360:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
80102366:	c1 e6 18             	shl    $0x18,%esi
80102369:	89 f2                	mov    %esi,%edx
8010236b:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102370:	e8 fb fd ff ff       	call   80102170 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102375:	ba 00 c5 00 00       	mov    $0xc500,%edx
8010237a:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010237f:	e8 ec fd ff ff       	call   80102170 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
80102384:	ba 00 85 00 00       	mov    $0x8500,%edx
80102389:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010238e:	e8 dd fd ff ff       	call   80102170 <lapicw>
  for(i = 0; i < 2; i++){
80102393:	bb 00 00 00 00       	mov    $0x0,%ebx
80102398:	eb 1f                	jmp    801023b9 <lapicstartap+0x86>
    lapicw(ICRHI, apicid<<24);
8010239a:	89 f2                	mov    %esi,%edx
8010239c:	b8 c4 00 00 00       	mov    $0xc4,%eax
801023a1:	e8 ca fd ff ff       	call   80102170 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801023a6:	89 fa                	mov    %edi,%edx
801023a8:	c1 ea 0c             	shr    $0xc,%edx
801023ab:	80 ce 06             	or     $0x6,%dh
801023ae:	b8 c0 00 00 00       	mov    $0xc0,%eax
801023b3:	e8 b8 fd ff ff       	call   80102170 <lapicw>
  for(i = 0; i < 2; i++){
801023b8:	43                   	inc    %ebx
801023b9:	83 fb 01             	cmp    $0x1,%ebx
801023bc:	7e dc                	jle    8010239a <lapicstartap+0x67>
}
801023be:	83 c4 0c             	add    $0xc,%esp
801023c1:	5b                   	pop    %ebx
801023c2:	5e                   	pop    %esi
801023c3:	5f                   	pop    %edi
801023c4:	5d                   	pop    %ebp
801023c5:	c3                   	ret    

801023c6 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801023c6:	55                   	push   %ebp
801023c7:	89 e5                	mov    %esp,%ebp
801023c9:	57                   	push   %edi
801023ca:	56                   	push   %esi
801023cb:	53                   	push   %ebx
801023cc:	83 ec 3c             	sub    $0x3c,%esp
801023cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801023d2:	b8 0b 00 00 00       	mov    $0xb,%eax
801023d7:	e8 a8 fd ff ff       	call   80102184 <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
801023dc:	83 e0 04             	and    $0x4,%eax
801023df:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801023e1:	8d 45 d0             	lea    -0x30(%ebp),%eax
801023e4:	e8 ab fd ff ff       	call   80102194 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801023e9:	b8 0a 00 00 00       	mov    $0xa,%eax
801023ee:	e8 91 fd ff ff       	call   80102184 <cmos_read>
801023f3:	a8 80                	test   $0x80,%al
801023f5:	75 ea                	jne    801023e1 <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
801023f7:	8d 75 b8             	lea    -0x48(%ebp),%esi
801023fa:	89 f0                	mov    %esi,%eax
801023fc:	e8 93 fd ff ff       	call   80102194 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102401:	83 ec 04             	sub    $0x4,%esp
80102404:	6a 18                	push   $0x18
80102406:	56                   	push   %esi
80102407:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010240a:	50                   	push   %eax
8010240b:	e8 86 19 00 00       	call   80103d96 <memcmp>
80102410:	83 c4 10             	add    $0x10,%esp
80102413:	85 c0                	test   %eax,%eax
80102415:	75 ca                	jne    801023e1 <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
80102417:	85 ff                	test   %edi,%edi
80102419:	75 7e                	jne    80102499 <cmostime+0xd3>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010241b:	8b 55 d0             	mov    -0x30(%ebp),%edx
8010241e:	89 d0                	mov    %edx,%eax
80102420:	c1 e8 04             	shr    $0x4,%eax
80102423:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102426:	01 c0                	add    %eax,%eax
80102428:	83 e2 0f             	and    $0xf,%edx
8010242b:	01 d0                	add    %edx,%eax
8010242d:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
80102430:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80102433:	89 d0                	mov    %edx,%eax
80102435:	c1 e8 04             	shr    $0x4,%eax
80102438:	8d 04 80             	lea    (%eax,%eax,4),%eax
8010243b:	01 c0                	add    %eax,%eax
8010243d:	83 e2 0f             	and    $0xf,%edx
80102440:	01 d0                	add    %edx,%eax
80102442:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
80102445:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102448:	89 d0                	mov    %edx,%eax
8010244a:	c1 e8 04             	shr    $0x4,%eax
8010244d:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102450:	01 c0                	add    %eax,%eax
80102452:	83 e2 0f             	and    $0xf,%edx
80102455:	01 d0                	add    %edx,%eax
80102457:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
8010245a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010245d:	89 d0                	mov    %edx,%eax
8010245f:	c1 e8 04             	shr    $0x4,%eax
80102462:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102465:	01 c0                	add    %eax,%eax
80102467:	83 e2 0f             	and    $0xf,%edx
8010246a:	01 d0                	add    %edx,%eax
8010246c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
8010246f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102472:	89 d0                	mov    %edx,%eax
80102474:	c1 e8 04             	shr    $0x4,%eax
80102477:	8d 04 80             	lea    (%eax,%eax,4),%eax
8010247a:	01 c0                	add    %eax,%eax
8010247c:	83 e2 0f             	and    $0xf,%edx
8010247f:	01 d0                	add    %edx,%eax
80102481:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
80102484:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102487:	89 d0                	mov    %edx,%eax
80102489:	c1 e8 04             	shr    $0x4,%eax
8010248c:	8d 04 80             	lea    (%eax,%eax,4),%eax
8010248f:	01 c0                	add    %eax,%eax
80102491:	83 e2 0f             	and    $0xf,%edx
80102494:	01 d0                	add    %edx,%eax
80102496:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
80102499:	8d 75 d0             	lea    -0x30(%ebp),%esi
8010249c:	b9 06 00 00 00       	mov    $0x6,%ecx
801024a1:	89 df                	mov    %ebx,%edi
801024a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
801024a5:	81 43 14 d0 07 00 00 	addl   $0x7d0,0x14(%ebx)
}
801024ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
801024af:	5b                   	pop    %ebx
801024b0:	5e                   	pop    %esi
801024b1:	5f                   	pop    %edi
801024b2:	5d                   	pop    %ebp
801024b3:	c3                   	ret    

801024b4 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801024b4:	55                   	push   %ebp
801024b5:	89 e5                	mov    %esp,%ebp
801024b7:	53                   	push   %ebx
801024b8:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801024bb:	ff 35 d4 16 11 80    	push   0x801116d4
801024c1:	ff 35 e4 16 11 80    	push   0x801116e4
801024c7:	e8 9e dc ff ff       	call   8010016a <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
801024cc:	8b 58 5c             	mov    0x5c(%eax),%ebx
801024cf:	89 1d e8 16 11 80    	mov    %ebx,0x801116e8
  for (i = 0; i < log.lh.n; i++) {
801024d5:	83 c4 10             	add    $0x10,%esp
801024d8:	ba 00 00 00 00       	mov    $0x0,%edx
801024dd:	eb 0c                	jmp    801024eb <read_head+0x37>
    log.lh.block[i] = lh->block[i];
801024df:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
801024e3:	89 0c 95 ec 16 11 80 	mov    %ecx,-0x7feee914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801024ea:	42                   	inc    %edx
801024eb:	39 d3                	cmp    %edx,%ebx
801024ed:	7f f0                	jg     801024df <read_head+0x2b>
  }
  brelse(buf);
801024ef:	83 ec 0c             	sub    $0xc,%esp
801024f2:	50                   	push   %eax
801024f3:	e8 db dc ff ff       	call   801001d3 <brelse>
}
801024f8:	83 c4 10             	add    $0x10,%esp
801024fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801024fe:	c9                   	leave  
801024ff:	c3                   	ret    

80102500 <install_trans>:
{
80102500:	55                   	push   %ebp
80102501:	89 e5                	mov    %esp,%ebp
80102503:	57                   	push   %edi
80102504:	56                   	push   %esi
80102505:	53                   	push   %ebx
80102506:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102509:	be 00 00 00 00       	mov    $0x0,%esi
8010250e:	eb 62                	jmp    80102572 <install_trans+0x72>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102510:	89 f0                	mov    %esi,%eax
80102512:	03 05 d4 16 11 80    	add    0x801116d4,%eax
80102518:	40                   	inc    %eax
80102519:	83 ec 08             	sub    $0x8,%esp
8010251c:	50                   	push   %eax
8010251d:	ff 35 e4 16 11 80    	push   0x801116e4
80102523:	e8 42 dc ff ff       	call   8010016a <bread>
80102528:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010252a:	83 c4 08             	add    $0x8,%esp
8010252d:	ff 34 b5 ec 16 11 80 	push   -0x7feee914(,%esi,4)
80102534:	ff 35 e4 16 11 80    	push   0x801116e4
8010253a:	e8 2b dc ff ff       	call   8010016a <bread>
8010253f:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102541:	8d 57 5c             	lea    0x5c(%edi),%edx
80102544:	8d 40 5c             	lea    0x5c(%eax),%eax
80102547:	83 c4 0c             	add    $0xc,%esp
8010254a:	68 00 02 00 00       	push   $0x200
8010254f:	52                   	push   %edx
80102550:	50                   	push   %eax
80102551:	e8 6f 18 00 00       	call   80103dc5 <memmove>
    bwrite(dbuf);  // write dst to disk
80102556:	89 1c 24             	mov    %ebx,(%esp)
80102559:	e8 3a dc ff ff       	call   80100198 <bwrite>
    brelse(lbuf);
8010255e:	89 3c 24             	mov    %edi,(%esp)
80102561:	e8 6d dc ff ff       	call   801001d3 <brelse>
    brelse(dbuf);
80102566:	89 1c 24             	mov    %ebx,(%esp)
80102569:	e8 65 dc ff ff       	call   801001d3 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
8010256e:	46                   	inc    %esi
8010256f:	83 c4 10             	add    $0x10,%esp
80102572:	39 35 e8 16 11 80    	cmp    %esi,0x801116e8
80102578:	7f 96                	jg     80102510 <install_trans+0x10>
}
8010257a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010257d:	5b                   	pop    %ebx
8010257e:	5e                   	pop    %esi
8010257f:	5f                   	pop    %edi
80102580:	5d                   	pop    %ebp
80102581:	c3                   	ret    

80102582 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102582:	55                   	push   %ebp
80102583:	89 e5                	mov    %esp,%ebp
80102585:	53                   	push   %ebx
80102586:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102589:	ff 35 d4 16 11 80    	push   0x801116d4
8010258f:	ff 35 e4 16 11 80    	push   0x801116e4
80102595:	e8 d0 db ff ff       	call   8010016a <bread>
8010259a:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
8010259c:	8b 0d e8 16 11 80    	mov    0x801116e8,%ecx
801025a2:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
801025a5:	83 c4 10             	add    $0x10,%esp
801025a8:	b8 00 00 00 00       	mov    $0x0,%eax
801025ad:	eb 0c                	jmp    801025bb <write_head+0x39>
    hb->block[i] = log.lh.block[i];
801025af:	8b 14 85 ec 16 11 80 	mov    -0x7feee914(,%eax,4),%edx
801025b6:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
801025ba:	40                   	inc    %eax
801025bb:	39 c1                	cmp    %eax,%ecx
801025bd:	7f f0                	jg     801025af <write_head+0x2d>
  }
  bwrite(buf);
801025bf:	83 ec 0c             	sub    $0xc,%esp
801025c2:	53                   	push   %ebx
801025c3:	e8 d0 db ff ff       	call   80100198 <bwrite>
  brelse(buf);
801025c8:	89 1c 24             	mov    %ebx,(%esp)
801025cb:	e8 03 dc ff ff       	call   801001d3 <brelse>
}
801025d0:	83 c4 10             	add    $0x10,%esp
801025d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801025d6:	c9                   	leave  
801025d7:	c3                   	ret    

801025d8 <recover_from_log>:

static void
recover_from_log(void)
{
801025d8:	55                   	push   %ebp
801025d9:	89 e5                	mov    %esp,%ebp
801025db:	83 ec 08             	sub    $0x8,%esp
  read_head();
801025de:	e8 d1 fe ff ff       	call   801024b4 <read_head>
  install_trans(); // if committed, copy from log to disk
801025e3:	e8 18 ff ff ff       	call   80102500 <install_trans>
  log.lh.n = 0;
801025e8:	c7 05 e8 16 11 80 00 	movl   $0x0,0x801116e8
801025ef:	00 00 00 
  write_head(); // clear the log
801025f2:	e8 8b ff ff ff       	call   80102582 <write_head>
}
801025f7:	c9                   	leave  
801025f8:	c3                   	ret    

801025f9 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801025f9:	55                   	push   %ebp
801025fa:	89 e5                	mov    %esp,%ebp
801025fc:	57                   	push   %edi
801025fd:	56                   	push   %esi
801025fe:	53                   	push   %ebx
801025ff:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102602:	be 00 00 00 00       	mov    $0x0,%esi
80102607:	eb 62                	jmp    8010266b <write_log+0x72>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102609:	89 f0                	mov    %esi,%eax
8010260b:	03 05 d4 16 11 80    	add    0x801116d4,%eax
80102611:	40                   	inc    %eax
80102612:	83 ec 08             	sub    $0x8,%esp
80102615:	50                   	push   %eax
80102616:	ff 35 e4 16 11 80    	push   0x801116e4
8010261c:	e8 49 db ff ff       	call   8010016a <bread>
80102621:	89 c3                	mov    %eax,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102623:	83 c4 08             	add    $0x8,%esp
80102626:	ff 34 b5 ec 16 11 80 	push   -0x7feee914(,%esi,4)
8010262d:	ff 35 e4 16 11 80    	push   0x801116e4
80102633:	e8 32 db ff ff       	call   8010016a <bread>
80102638:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
8010263a:	8d 50 5c             	lea    0x5c(%eax),%edx
8010263d:	8d 43 5c             	lea    0x5c(%ebx),%eax
80102640:	83 c4 0c             	add    $0xc,%esp
80102643:	68 00 02 00 00       	push   $0x200
80102648:	52                   	push   %edx
80102649:	50                   	push   %eax
8010264a:	e8 76 17 00 00       	call   80103dc5 <memmove>
    bwrite(to);  // write the log
8010264f:	89 1c 24             	mov    %ebx,(%esp)
80102652:	e8 41 db ff ff       	call   80100198 <bwrite>
    brelse(from);
80102657:	89 3c 24             	mov    %edi,(%esp)
8010265a:	e8 74 db ff ff       	call   801001d3 <brelse>
    brelse(to);
8010265f:	89 1c 24             	mov    %ebx,(%esp)
80102662:	e8 6c db ff ff       	call   801001d3 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102667:	46                   	inc    %esi
80102668:	83 c4 10             	add    $0x10,%esp
8010266b:	39 35 e8 16 11 80    	cmp    %esi,0x801116e8
80102671:	7f 96                	jg     80102609 <write_log+0x10>
  }
}
80102673:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102676:	5b                   	pop    %ebx
80102677:	5e                   	pop    %esi
80102678:	5f                   	pop    %edi
80102679:	5d                   	pop    %ebp
8010267a:	c3                   	ret    

8010267b <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
8010267b:	83 3d e8 16 11 80 00 	cmpl   $0x0,0x801116e8
80102682:	7f 01                	jg     80102685 <commit+0xa>
80102684:	c3                   	ret    
{
80102685:	55                   	push   %ebp
80102686:	89 e5                	mov    %esp,%ebp
80102688:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
8010268b:	e8 69 ff ff ff       	call   801025f9 <write_log>
    write_head();    // Write header to disk -- the real commit
80102690:	e8 ed fe ff ff       	call   80102582 <write_head>
    install_trans(); // Now install writes to home locations
80102695:	e8 66 fe ff ff       	call   80102500 <install_trans>
    log.lh.n = 0;
8010269a:	c7 05 e8 16 11 80 00 	movl   $0x0,0x801116e8
801026a1:	00 00 00 
    write_head();    // Erase the transaction from the log
801026a4:	e8 d9 fe ff ff       	call   80102582 <write_head>
  }
}
801026a9:	c9                   	leave  
801026aa:	c3                   	ret    

801026ab <initlog>:
{
801026ab:	55                   	push   %ebp
801026ac:	89 e5                	mov    %esp,%ebp
801026ae:	53                   	push   %ebx
801026af:	83 ec 2c             	sub    $0x2c,%esp
801026b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
801026b5:	68 00 6f 10 80       	push   $0x80106f00
801026ba:	68 a0 16 11 80       	push   $0x801116a0
801026bf:	e8 a8 14 00 00       	call   80103b6c <initlock>
  readsb(dev, &sb);
801026c4:	83 c4 08             	add    $0x8,%esp
801026c7:	8d 45 dc             	lea    -0x24(%ebp),%eax
801026ca:	50                   	push   %eax
801026cb:	53                   	push   %ebx
801026cc:	e8 0e eb ff ff       	call   801011df <readsb>
  log.start = sb.logstart;
801026d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801026d4:	a3 d4 16 11 80       	mov    %eax,0x801116d4
  log.size = sb.nlog;
801026d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801026dc:	a3 d8 16 11 80       	mov    %eax,0x801116d8
  log.dev = dev;
801026e1:	89 1d e4 16 11 80    	mov    %ebx,0x801116e4
  recover_from_log();
801026e7:	e8 ec fe ff ff       	call   801025d8 <recover_from_log>
}
801026ec:	83 c4 10             	add    $0x10,%esp
801026ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801026f2:	c9                   	leave  
801026f3:	c3                   	ret    

801026f4 <begin_op>:
{
801026f4:	55                   	push   %ebp
801026f5:	89 e5                	mov    %esp,%ebp
801026f7:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
801026fa:	68 a0 16 11 80       	push   $0x801116a0
801026ff:	e8 9f 15 00 00       	call   80103ca3 <acquire>
80102704:	83 c4 10             	add    $0x10,%esp
80102707:	eb 15                	jmp    8010271e <begin_op+0x2a>
      sleep(&log, &log.lock);
80102709:	83 ec 08             	sub    $0x8,%esp
8010270c:	68 a0 16 11 80       	push   $0x801116a0
80102711:	68 a0 16 11 80       	push   $0x801116a0
80102716:	e8 82 10 00 00       	call   8010379d <sleep>
8010271b:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
8010271e:	83 3d e0 16 11 80 00 	cmpl   $0x0,0x801116e0
80102725:	75 e2                	jne    80102709 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102727:	a1 dc 16 11 80       	mov    0x801116dc,%eax
8010272c:	8d 48 01             	lea    0x1(%eax),%ecx
8010272f:	8d 54 80 05          	lea    0x5(%eax,%eax,4),%edx
80102733:	8d 04 12             	lea    (%edx,%edx,1),%eax
80102736:	03 05 e8 16 11 80    	add    0x801116e8,%eax
8010273c:	83 f8 1e             	cmp    $0x1e,%eax
8010273f:	7e 17                	jle    80102758 <begin_op+0x64>
      sleep(&log, &log.lock);
80102741:	83 ec 08             	sub    $0x8,%esp
80102744:	68 a0 16 11 80       	push   $0x801116a0
80102749:	68 a0 16 11 80       	push   $0x801116a0
8010274e:	e8 4a 10 00 00       	call   8010379d <sleep>
80102753:	83 c4 10             	add    $0x10,%esp
80102756:	eb c6                	jmp    8010271e <begin_op+0x2a>
      log.outstanding += 1;
80102758:	89 0d dc 16 11 80    	mov    %ecx,0x801116dc
      release(&log.lock);
8010275e:	83 ec 0c             	sub    $0xc,%esp
80102761:	68 a0 16 11 80       	push   $0x801116a0
80102766:	e8 9d 15 00 00       	call   80103d08 <release>
}
8010276b:	83 c4 10             	add    $0x10,%esp
8010276e:	c9                   	leave  
8010276f:	c3                   	ret    

80102770 <end_op>:
{
80102770:	55                   	push   %ebp
80102771:	89 e5                	mov    %esp,%ebp
80102773:	53                   	push   %ebx
80102774:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102777:	68 a0 16 11 80       	push   $0x801116a0
8010277c:	e8 22 15 00 00       	call   80103ca3 <acquire>
  log.outstanding -= 1;
80102781:	a1 dc 16 11 80       	mov    0x801116dc,%eax
80102786:	48                   	dec    %eax
80102787:	a3 dc 16 11 80       	mov    %eax,0x801116dc
  if(log.committing)
8010278c:	8b 1d e0 16 11 80    	mov    0x801116e0,%ebx
80102792:	83 c4 10             	add    $0x10,%esp
80102795:	85 db                	test   %ebx,%ebx
80102797:	75 2c                	jne    801027c5 <end_op+0x55>
  if(log.outstanding == 0){
80102799:	85 c0                	test   %eax,%eax
8010279b:	75 35                	jne    801027d2 <end_op+0x62>
    log.committing = 1;
8010279d:	c7 05 e0 16 11 80 01 	movl   $0x1,0x801116e0
801027a4:	00 00 00 
    do_commit = 1;
801027a7:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
801027ac:	83 ec 0c             	sub    $0xc,%esp
801027af:	68 a0 16 11 80       	push   $0x801116a0
801027b4:	e8 4f 15 00 00       	call   80103d08 <release>
  if(do_commit){
801027b9:	83 c4 10             	add    $0x10,%esp
801027bc:	85 db                	test   %ebx,%ebx
801027be:	75 24                	jne    801027e4 <end_op+0x74>
}
801027c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027c3:	c9                   	leave  
801027c4:	c3                   	ret    
    panic("log.committing");
801027c5:	83 ec 0c             	sub    $0xc,%esp
801027c8:	68 04 6f 10 80       	push   $0x80106f04
801027cd:	e8 6f db ff ff       	call   80100341 <panic>
    wakeup(&log);
801027d2:	83 ec 0c             	sub    $0xc,%esp
801027d5:	68 a0 16 11 80       	push   $0x801116a0
801027da:	e8 30 11 00 00       	call   8010390f <wakeup>
801027df:	83 c4 10             	add    $0x10,%esp
801027e2:	eb c8                	jmp    801027ac <end_op+0x3c>
    commit();
801027e4:	e8 92 fe ff ff       	call   8010267b <commit>
    acquire(&log.lock);
801027e9:	83 ec 0c             	sub    $0xc,%esp
801027ec:	68 a0 16 11 80       	push   $0x801116a0
801027f1:	e8 ad 14 00 00       	call   80103ca3 <acquire>
    log.committing = 0;
801027f6:	c7 05 e0 16 11 80 00 	movl   $0x0,0x801116e0
801027fd:	00 00 00 
    wakeup(&log);
80102800:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
80102807:	e8 03 11 00 00       	call   8010390f <wakeup>
    release(&log.lock);
8010280c:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
80102813:	e8 f0 14 00 00       	call   80103d08 <release>
80102818:	83 c4 10             	add    $0x10,%esp
}
8010281b:	eb a3                	jmp    801027c0 <end_op+0x50>

8010281d <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010281d:	55                   	push   %ebp
8010281e:	89 e5                	mov    %esp,%ebp
80102820:	53                   	push   %ebx
80102821:	83 ec 04             	sub    $0x4,%esp
80102824:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102827:	8b 15 e8 16 11 80    	mov    0x801116e8,%edx
8010282d:	83 fa 1d             	cmp    $0x1d,%edx
80102830:	7f 2a                	jg     8010285c <log_write+0x3f>
80102832:	a1 d8 16 11 80       	mov    0x801116d8,%eax
80102837:	48                   	dec    %eax
80102838:	39 c2                	cmp    %eax,%edx
8010283a:	7d 20                	jge    8010285c <log_write+0x3f>
    panic("too big a transaction");
  if (log.outstanding < 1)
8010283c:	83 3d dc 16 11 80 00 	cmpl   $0x0,0x801116dc
80102843:	7e 24                	jle    80102869 <log_write+0x4c>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102845:	83 ec 0c             	sub    $0xc,%esp
80102848:	68 a0 16 11 80       	push   $0x801116a0
8010284d:	e8 51 14 00 00       	call   80103ca3 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102852:	83 c4 10             	add    $0x10,%esp
80102855:	b8 00 00 00 00       	mov    $0x0,%eax
8010285a:	eb 1b                	jmp    80102877 <log_write+0x5a>
    panic("too big a transaction");
8010285c:	83 ec 0c             	sub    $0xc,%esp
8010285f:	68 13 6f 10 80       	push   $0x80106f13
80102864:	e8 d8 da ff ff       	call   80100341 <panic>
    panic("log_write outside of trans");
80102869:	83 ec 0c             	sub    $0xc,%esp
8010286c:	68 29 6f 10 80       	push   $0x80106f29
80102871:	e8 cb da ff ff       	call   80100341 <panic>
  for (i = 0; i < log.lh.n; i++) {
80102876:	40                   	inc    %eax
80102877:	8b 15 e8 16 11 80    	mov    0x801116e8,%edx
8010287d:	39 c2                	cmp    %eax,%edx
8010287f:	7e 0c                	jle    8010288d <log_write+0x70>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102881:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102884:	39 0c 85 ec 16 11 80 	cmp    %ecx,-0x7feee914(,%eax,4)
8010288b:	75 e9                	jne    80102876 <log_write+0x59>
      break;
  }
  log.lh.block[i] = b->blockno;
8010288d:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102890:	89 0c 85 ec 16 11 80 	mov    %ecx,-0x7feee914(,%eax,4)
  if (i == log.lh.n)
80102897:	39 c2                	cmp    %eax,%edx
80102899:	74 18                	je     801028b3 <log_write+0x96>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
8010289b:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
8010289e:	83 ec 0c             	sub    $0xc,%esp
801028a1:	68 a0 16 11 80       	push   $0x801116a0
801028a6:	e8 5d 14 00 00       	call   80103d08 <release>
}
801028ab:	83 c4 10             	add    $0x10,%esp
801028ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801028b1:	c9                   	leave  
801028b2:	c3                   	ret    
    log.lh.n++;
801028b3:	42                   	inc    %edx
801028b4:	89 15 e8 16 11 80    	mov    %edx,0x801116e8
801028ba:	eb df                	jmp    8010289b <log_write+0x7e>

801028bc <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801028bc:	55                   	push   %ebp
801028bd:	89 e5                	mov    %esp,%ebp
801028bf:	53                   	push   %ebx
801028c0:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801028c3:	68 8e 00 00 00       	push   $0x8e
801028c8:	68 8c a4 10 80       	push   $0x8010a48c
801028cd:	68 00 70 00 80       	push   $0x80007000
801028d2:	e8 ee 14 00 00       	call   80103dc5 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801028d7:	83 c4 10             	add    $0x10,%esp
801028da:	bb a0 17 11 80       	mov    $0x801117a0,%ebx
801028df:	eb 06                	jmp    801028e7 <startothers+0x2b>
801028e1:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801028e7:	8b 15 84 17 11 80    	mov    0x80111784,%edx
801028ed:	8d 04 92             	lea    (%edx,%edx,4),%eax
801028f0:	01 c0                	add    %eax,%eax
801028f2:	01 d0                	add    %edx,%eax
801028f4:	c1 e0 04             	shl    $0x4,%eax
801028f7:	05 a0 17 11 80       	add    $0x801117a0,%eax
801028fc:	39 d8                	cmp    %ebx,%eax
801028fe:	76 4c                	jbe    8010294c <startothers+0x90>
    if(c == mycpu())  // We've started already.
80102900:	e8 a3 07 00 00       	call   801030a8 <mycpu>
80102905:	39 c3                	cmp    %eax,%ebx
80102907:	74 d8                	je     801028e1 <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102909:	e8 31 f7 ff ff       	call   8010203f <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
8010290e:	05 00 10 00 00       	add    $0x1000,%eax
80102913:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102918:	c7 05 f8 6f 00 80 90 	movl   $0x80102990,0x80006ff8
8010291f:	29 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102922:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102929:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
8010292c:	83 ec 08             	sub    $0x8,%esp
8010292f:	68 00 70 00 00       	push   $0x7000
80102934:	0f b6 03             	movzbl (%ebx),%eax
80102937:	50                   	push   %eax
80102938:	e8 f6 f9 ff ff       	call   80102333 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010293d:	83 c4 10             	add    $0x10,%esp
80102940:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102946:	85 c0                	test   %eax,%eax
80102948:	74 f6                	je     80102940 <startothers+0x84>
8010294a:	eb 95                	jmp    801028e1 <startothers+0x25>
      ;
  }
}
8010294c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010294f:	c9                   	leave  
80102950:	c3                   	ret    

80102951 <mpmain>:
{
80102951:	55                   	push   %ebp
80102952:	89 e5                	mov    %esp,%ebp
80102954:	53                   	push   %ebx
80102955:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102958:	e8 af 07 00 00       	call   8010310c <cpuid>
8010295d:	89 c3                	mov    %eax,%ebx
8010295f:	e8 a8 07 00 00       	call   8010310c <cpuid>
80102964:	83 ec 04             	sub    $0x4,%esp
80102967:	53                   	push   %ebx
80102968:	50                   	push   %eax
80102969:	68 44 6f 10 80       	push   $0x80106f44
8010296e:	e8 67 dc ff ff       	call   801005da <cprintf>
  idtinit();       // load idt register
80102973:	e8 f4 26 00 00       	call   8010506c <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102978:	e8 2b 07 00 00       	call   801030a8 <mycpu>
8010297d:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010297f:	b8 01 00 00 00       	mov    $0x1,%eax
80102984:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
8010298b:	e8 f4 0a 00 00       	call   80103484 <scheduler>

80102990 <mpenter>:
{
80102990:	55                   	push   %ebp
80102991:	89 e5                	mov    %esp,%ebp
80102993:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102996:	e8 31 39 00 00       	call   801062cc <switchkvm>
  seginit();
8010299b:	e8 e6 35 00 00       	call   80105f86 <seginit>
  lapicinit();
801029a0:	e8 4a f8 ff ff       	call   801021ef <lapicinit>
  mpmain();
801029a5:	e8 a7 ff ff ff       	call   80102951 <mpmain>

801029aa <main>:
{
801029aa:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801029ae:	83 e4 f0             	and    $0xfffffff0,%esp
801029b1:	ff 71 fc             	push   -0x4(%ecx)
801029b4:	55                   	push   %ebp
801029b5:	89 e5                	mov    %esp,%ebp
801029b7:	51                   	push   %ecx
801029b8:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801029bb:	68 00 00 40 80       	push   $0x80400000
801029c0:	68 d0 57 11 80       	push   $0x801157d0
801029c5:	e8 23 f6 ff ff       	call   80101fed <kinit1>
  kvmalloc();      // kernel page table
801029ca:	e8 cc 3d 00 00       	call   8010679b <kvmalloc>
  mpinit();        // detect other processors
801029cf:	e8 b8 01 00 00       	call   80102b8c <mpinit>
  lapicinit();     // interrupt controller
801029d4:	e8 16 f8 ff ff       	call   801021ef <lapicinit>
  seginit();       // segment descriptors
801029d9:	e8 a8 35 00 00       	call   80105f86 <seginit>
  picinit();       // disable pic
801029de:	e8 79 02 00 00       	call   80102c5c <picinit>
  ioapicinit();    // another interrupt controller
801029e3:	e8 93 f4 ff ff       	call   80101e7b <ioapicinit>
  consoleinit();   // console hardware
801029e8:	e8 5f de ff ff       	call   8010084c <consoleinit>
  uartinit();      // serial port
801029ed:	e8 0c 2a 00 00       	call   801053fe <uartinit>
  pinit();         // process table
801029f2:	e8 97 06 00 00       	call   8010308e <pinit>
  tvinit();        // trap vectors
801029f7:	e8 73 25 00 00       	call   80104f6f <tvinit>
  binit();         // buffer cache
801029fc:	e8 f1 d6 ff ff       	call   801000f2 <binit>
  fileinit();      // file table
80102a01:	e8 de e1 ff ff       	call   80100be4 <fileinit>
  ideinit();       // disk 
80102a06:	e8 86 f2 ff ff       	call   80101c91 <ideinit>
  startothers();   // start other processors
80102a0b:	e8 ac fe ff ff       	call   801028bc <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102a10:	83 c4 08             	add    $0x8,%esp
80102a13:	68 00 00 00 8e       	push   $0x8e000000
80102a18:	68 00 00 40 80       	push   $0x80400000
80102a1d:	e8 fd f5 ff ff       	call   8010201f <kinit2>
  userinit();      // first user process
80102a22:	e8 39 07 00 00       	call   80103160 <userinit>
  mpmain();        // finish this processor's setup
80102a27:	e8 25 ff ff ff       	call   80102951 <mpmain>

80102a2c <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102a2c:	55                   	push   %ebp
80102a2d:	89 e5                	mov    %esp,%ebp
80102a2f:	56                   	push   %esi
80102a30:	53                   	push   %ebx
80102a31:	89 c6                	mov    %eax,%esi
  int i, sum;

  sum = 0;
80102a33:	b8 00 00 00 00       	mov    $0x0,%eax
  for(i=0; i<len; i++)
80102a38:	b9 00 00 00 00       	mov    $0x0,%ecx
80102a3d:	eb 07                	jmp    80102a46 <sum+0x1a>
    sum += addr[i];
80102a3f:	0f b6 1c 0e          	movzbl (%esi,%ecx,1),%ebx
80102a43:	01 d8                	add    %ebx,%eax
  for(i=0; i<len; i++)
80102a45:	41                   	inc    %ecx
80102a46:	39 d1                	cmp    %edx,%ecx
80102a48:	7c f5                	jl     80102a3f <sum+0x13>
  return sum;
}
80102a4a:	5b                   	pop    %ebx
80102a4b:	5e                   	pop    %esi
80102a4c:	5d                   	pop    %ebp
80102a4d:	c3                   	ret    

80102a4e <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102a4e:	55                   	push   %ebp
80102a4f:	89 e5                	mov    %esp,%ebp
80102a51:	56                   	push   %esi
80102a52:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102a53:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102a59:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102a5b:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102a5d:	eb 03                	jmp    80102a62 <mpsearch1+0x14>
80102a5f:	83 c3 10             	add    $0x10,%ebx
80102a62:	39 f3                	cmp    %esi,%ebx
80102a64:	73 29                	jae    80102a8f <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102a66:	83 ec 04             	sub    $0x4,%esp
80102a69:	6a 04                	push   $0x4
80102a6b:	68 58 6f 10 80       	push   $0x80106f58
80102a70:	53                   	push   %ebx
80102a71:	e8 20 13 00 00       	call   80103d96 <memcmp>
80102a76:	83 c4 10             	add    $0x10,%esp
80102a79:	85 c0                	test   %eax,%eax
80102a7b:	75 e2                	jne    80102a5f <mpsearch1+0x11>
80102a7d:	ba 10 00 00 00       	mov    $0x10,%edx
80102a82:	89 d8                	mov    %ebx,%eax
80102a84:	e8 a3 ff ff ff       	call   80102a2c <sum>
80102a89:	84 c0                	test   %al,%al
80102a8b:	75 d2                	jne    80102a5f <mpsearch1+0x11>
80102a8d:	eb 05                	jmp    80102a94 <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102a8f:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102a94:	89 d8                	mov    %ebx,%eax
80102a96:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102a99:	5b                   	pop    %ebx
80102a9a:	5e                   	pop    %esi
80102a9b:	5d                   	pop    %ebp
80102a9c:	c3                   	ret    

80102a9d <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102a9d:	55                   	push   %ebp
80102a9e:	89 e5                	mov    %esp,%ebp
80102aa0:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102aa3:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102aaa:	c1 e0 08             	shl    $0x8,%eax
80102aad:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102ab4:	09 d0                	or     %edx,%eax
80102ab6:	c1 e0 04             	shl    $0x4,%eax
80102ab9:	74 1f                	je     80102ada <mpsearch+0x3d>
    if((mp = mpsearch1(p, 1024)))
80102abb:	ba 00 04 00 00       	mov    $0x400,%edx
80102ac0:	e8 89 ff ff ff       	call   80102a4e <mpsearch1>
80102ac5:	85 c0                	test   %eax,%eax
80102ac7:	75 0f                	jne    80102ad8 <mpsearch+0x3b>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102ac9:	ba 00 00 01 00       	mov    $0x10000,%edx
80102ace:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102ad3:	e8 76 ff ff ff       	call   80102a4e <mpsearch1>
}
80102ad8:	c9                   	leave  
80102ad9:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102ada:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102ae1:	c1 e0 08             	shl    $0x8,%eax
80102ae4:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102aeb:	09 d0                	or     %edx,%eax
80102aed:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102af0:	2d 00 04 00 00       	sub    $0x400,%eax
80102af5:	ba 00 04 00 00       	mov    $0x400,%edx
80102afa:	e8 4f ff ff ff       	call   80102a4e <mpsearch1>
80102aff:	85 c0                	test   %eax,%eax
80102b01:	75 d5                	jne    80102ad8 <mpsearch+0x3b>
80102b03:	eb c4                	jmp    80102ac9 <mpsearch+0x2c>

80102b05 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102b05:	55                   	push   %ebp
80102b06:	89 e5                	mov    %esp,%ebp
80102b08:	57                   	push   %edi
80102b09:	56                   	push   %esi
80102b0a:	53                   	push   %ebx
80102b0b:	83 ec 1c             	sub    $0x1c,%esp
80102b0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102b11:	e8 87 ff ff ff       	call   80102a9d <mpsearch>
80102b16:	89 c3                	mov    %eax,%ebx
80102b18:	85 c0                	test   %eax,%eax
80102b1a:	74 53                	je     80102b6f <mpconfig+0x6a>
80102b1c:	8b 70 04             	mov    0x4(%eax),%esi
80102b1f:	85 f6                	test   %esi,%esi
80102b21:	74 50                	je     80102b73 <mpconfig+0x6e>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102b23:	8d be 00 00 00 80    	lea    -0x80000000(%esi),%edi
  if(memcmp(conf, "PCMP", 4) != 0)
80102b29:	83 ec 04             	sub    $0x4,%esp
80102b2c:	6a 04                	push   $0x4
80102b2e:	68 5d 6f 10 80       	push   $0x80106f5d
80102b33:	57                   	push   %edi
80102b34:	e8 5d 12 00 00       	call   80103d96 <memcmp>
80102b39:	83 c4 10             	add    $0x10,%esp
80102b3c:	85 c0                	test   %eax,%eax
80102b3e:	75 37                	jne    80102b77 <mpconfig+0x72>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102b40:	8a 86 06 00 00 80    	mov    -0x7ffffffa(%esi),%al
80102b46:	3c 01                	cmp    $0x1,%al
80102b48:	74 04                	je     80102b4e <mpconfig+0x49>
80102b4a:	3c 04                	cmp    $0x4,%al
80102b4c:	75 30                	jne    80102b7e <mpconfig+0x79>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102b4e:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
80102b55:	89 f8                	mov    %edi,%eax
80102b57:	e8 d0 fe ff ff       	call   80102a2c <sum>
80102b5c:	84 c0                	test   %al,%al
80102b5e:	75 25                	jne    80102b85 <mpconfig+0x80>
    return 0;
  *pmp = mp;
80102b60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102b63:	89 18                	mov    %ebx,(%eax)
  return conf;
}
80102b65:	89 f8                	mov    %edi,%eax
80102b67:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102b6a:	5b                   	pop    %ebx
80102b6b:	5e                   	pop    %esi
80102b6c:	5f                   	pop    %edi
80102b6d:	5d                   	pop    %ebp
80102b6e:	c3                   	ret    
    return 0;
80102b6f:	89 c7                	mov    %eax,%edi
80102b71:	eb f2                	jmp    80102b65 <mpconfig+0x60>
80102b73:	89 f7                	mov    %esi,%edi
80102b75:	eb ee                	jmp    80102b65 <mpconfig+0x60>
    return 0;
80102b77:	bf 00 00 00 00       	mov    $0x0,%edi
80102b7c:	eb e7                	jmp    80102b65 <mpconfig+0x60>
    return 0;
80102b7e:	bf 00 00 00 00       	mov    $0x0,%edi
80102b83:	eb e0                	jmp    80102b65 <mpconfig+0x60>
    return 0;
80102b85:	bf 00 00 00 00       	mov    $0x0,%edi
80102b8a:	eb d9                	jmp    80102b65 <mpconfig+0x60>

80102b8c <mpinit>:

void
mpinit(void)
{
80102b8c:	55                   	push   %ebp
80102b8d:	89 e5                	mov    %esp,%ebp
80102b8f:	57                   	push   %edi
80102b90:	56                   	push   %esi
80102b91:	53                   	push   %ebx
80102b92:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102b95:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102b98:	e8 68 ff ff ff       	call   80102b05 <mpconfig>
80102b9d:	85 c0                	test   %eax,%eax
80102b9f:	74 19                	je     80102bba <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102ba1:	8b 50 24             	mov    0x24(%eax),%edx
80102ba4:	89 15 80 16 11 80    	mov    %edx,0x80111680
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102baa:	8d 50 2c             	lea    0x2c(%eax),%edx
80102bad:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102bb1:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102bb3:	bf 01 00 00 00       	mov    $0x1,%edi
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102bb8:	eb 20                	jmp    80102bda <mpinit+0x4e>
    panic("Expect to run on an SMP");
80102bba:	83 ec 0c             	sub    $0xc,%esp
80102bbd:	68 62 6f 10 80       	push   $0x80106f62
80102bc2:	e8 7a d7 ff ff       	call   80100341 <panic>
    switch(*p){
80102bc7:	bf 00 00 00 00       	mov    $0x0,%edi
80102bcc:	eb 0c                	jmp    80102bda <mpinit+0x4e>
80102bce:	83 e8 03             	sub    $0x3,%eax
80102bd1:	3c 01                	cmp    $0x1,%al
80102bd3:	76 19                	jbe    80102bee <mpinit+0x62>
80102bd5:	bf 00 00 00 00       	mov    $0x0,%edi
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102bda:	39 ca                	cmp    %ecx,%edx
80102bdc:	73 4a                	jae    80102c28 <mpinit+0x9c>
    switch(*p){
80102bde:	8a 02                	mov    (%edx),%al
80102be0:	3c 02                	cmp    $0x2,%al
80102be2:	74 37                	je     80102c1b <mpinit+0x8f>
80102be4:	77 e8                	ja     80102bce <mpinit+0x42>
80102be6:	84 c0                	test   %al,%al
80102be8:	74 09                	je     80102bf3 <mpinit+0x67>
80102bea:	3c 01                	cmp    $0x1,%al
80102bec:	75 d9                	jne    80102bc7 <mpinit+0x3b>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102bee:	83 c2 08             	add    $0x8,%edx
      continue;
80102bf1:	eb e7                	jmp    80102bda <mpinit+0x4e>
      if(ncpu < NCPU) {
80102bf3:	a1 84 17 11 80       	mov    0x80111784,%eax
80102bf8:	83 f8 07             	cmp    $0x7,%eax
80102bfb:	7f 19                	jg     80102c16 <mpinit+0x8a>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102bfd:	8d 34 80             	lea    (%eax,%eax,4),%esi
80102c00:	01 f6                	add    %esi,%esi
80102c02:	01 c6                	add    %eax,%esi
80102c04:	c1 e6 04             	shl    $0x4,%esi
80102c07:	8a 5a 01             	mov    0x1(%edx),%bl
80102c0a:	88 9e a0 17 11 80    	mov    %bl,-0x7feee860(%esi)
        ncpu++;
80102c10:	40                   	inc    %eax
80102c11:	a3 84 17 11 80       	mov    %eax,0x80111784
      p += sizeof(struct mpproc);
80102c16:	83 c2 14             	add    $0x14,%edx
      continue;
80102c19:	eb bf                	jmp    80102bda <mpinit+0x4e>
      ioapicid = ioapic->apicno;
80102c1b:	8a 42 01             	mov    0x1(%edx),%al
80102c1e:	a2 80 17 11 80       	mov    %al,0x80111780
      p += sizeof(struct mpioapic);
80102c23:	83 c2 08             	add    $0x8,%edx
      continue;
80102c26:	eb b2                	jmp    80102bda <mpinit+0x4e>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80102c28:	85 ff                	test   %edi,%edi
80102c2a:	74 23                	je     80102c4f <mpinit+0xc3>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102c2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102c2f:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102c33:	74 12                	je     80102c47 <mpinit+0xbb>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c35:	b0 70                	mov    $0x70,%al
80102c37:	ba 22 00 00 00       	mov    $0x22,%edx
80102c3c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c3d:	ba 23 00 00 00       	mov    $0x23,%edx
80102c42:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102c43:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c46:	ee                   	out    %al,(%dx)
  }
}
80102c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c4a:	5b                   	pop    %ebx
80102c4b:	5e                   	pop    %esi
80102c4c:	5f                   	pop    %edi
80102c4d:	5d                   	pop    %ebp
80102c4e:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102c4f:	83 ec 0c             	sub    $0xc,%esp
80102c52:	68 7c 6f 10 80       	push   $0x80106f7c
80102c57:	e8 e5 d6 ff ff       	call   80100341 <panic>

80102c5c <picinit>:
80102c5c:	b0 ff                	mov    $0xff,%al
80102c5e:	ba 21 00 00 00       	mov    $0x21,%edx
80102c63:	ee                   	out    %al,(%dx)
80102c64:	ba a1 00 00 00       	mov    $0xa1,%edx
80102c69:	ee                   	out    %al,(%dx)
picinit(void)
{
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102c6a:	c3                   	ret    

80102c6b <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102c6b:	55                   	push   %ebp
80102c6c:	89 e5                	mov    %esp,%ebp
80102c6e:	57                   	push   %edi
80102c6f:	56                   	push   %esi
80102c70:	53                   	push   %ebx
80102c71:	83 ec 0c             	sub    $0xc,%esp
80102c74:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102c77:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102c7a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102c80:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102c86:	e8 73 df ff ff       	call   80100bfe <filealloc>
80102c8b:	89 03                	mov    %eax,(%ebx)
80102c8d:	85 c0                	test   %eax,%eax
80102c8f:	0f 84 88 00 00 00    	je     80102d1d <pipealloc+0xb2>
80102c95:	e8 64 df ff ff       	call   80100bfe <filealloc>
80102c9a:	89 06                	mov    %eax,(%esi)
80102c9c:	85 c0                	test   %eax,%eax
80102c9e:	74 7d                	je     80102d1d <pipealloc+0xb2>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102ca0:	e8 9a f3 ff ff       	call   8010203f <kalloc>
80102ca5:	89 c7                	mov    %eax,%edi
80102ca7:	85 c0                	test   %eax,%eax
80102ca9:	74 72                	je     80102d1d <pipealloc+0xb2>
    goto bad;
  p->readopen = 1;
80102cab:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102cb2:	00 00 00 
  p->writeopen = 1;
80102cb5:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102cbc:	00 00 00 
  p->nwrite = 0;
80102cbf:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102cc6:	00 00 00 
  p->nread = 0;
80102cc9:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102cd0:	00 00 00 
  initlock(&p->lock, "pipe");
80102cd3:	83 ec 08             	sub    $0x8,%esp
80102cd6:	68 9b 6f 10 80       	push   $0x80106f9b
80102cdb:	50                   	push   %eax
80102cdc:	e8 8b 0e 00 00       	call   80103b6c <initlock>
  (*f0)->type = FD_PIPE;
80102ce1:	8b 03                	mov    (%ebx),%eax
80102ce3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102ce9:	8b 03                	mov    (%ebx),%eax
80102ceb:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102cef:	8b 03                	mov    (%ebx),%eax
80102cf1:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102cf5:	8b 03                	mov    (%ebx),%eax
80102cf7:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102cfa:	8b 06                	mov    (%esi),%eax
80102cfc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102d02:	8b 06                	mov    (%esi),%eax
80102d04:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102d08:	8b 06                	mov    (%esi),%eax
80102d0a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102d0e:	8b 06                	mov    (%esi),%eax
80102d10:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102d13:	83 c4 10             	add    $0x10,%esp
80102d16:	b8 00 00 00 00       	mov    $0x0,%eax
80102d1b:	eb 29                	jmp    80102d46 <pipealloc+0xdb>

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102d1d:	8b 03                	mov    (%ebx),%eax
80102d1f:	85 c0                	test   %eax,%eax
80102d21:	74 0c                	je     80102d2f <pipealloc+0xc4>
    fileclose(*f0);
80102d23:	83 ec 0c             	sub    $0xc,%esp
80102d26:	50                   	push   %eax
80102d27:	e8 76 df ff ff       	call   80100ca2 <fileclose>
80102d2c:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102d2f:	8b 06                	mov    (%esi),%eax
80102d31:	85 c0                	test   %eax,%eax
80102d33:	74 19                	je     80102d4e <pipealloc+0xe3>
    fileclose(*f1);
80102d35:	83 ec 0c             	sub    $0xc,%esp
80102d38:	50                   	push   %eax
80102d39:	e8 64 df ff ff       	call   80100ca2 <fileclose>
80102d3e:	83 c4 10             	add    $0x10,%esp
  return -1;
80102d41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102d46:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d49:	5b                   	pop    %ebx
80102d4a:	5e                   	pop    %esi
80102d4b:	5f                   	pop    %edi
80102d4c:	5d                   	pop    %ebp
80102d4d:	c3                   	ret    
  return -1;
80102d4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d53:	eb f1                	jmp    80102d46 <pipealloc+0xdb>

80102d55 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102d55:	55                   	push   %ebp
80102d56:	89 e5                	mov    %esp,%ebp
80102d58:	53                   	push   %ebx
80102d59:	83 ec 10             	sub    $0x10,%esp
80102d5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102d5f:	53                   	push   %ebx
80102d60:	e8 3e 0f 00 00       	call   80103ca3 <acquire>
  if(writable){
80102d65:	83 c4 10             	add    $0x10,%esp
80102d68:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102d6c:	74 3f                	je     80102dad <pipeclose+0x58>
    p->writeopen = 0;
80102d6e:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102d75:	00 00 00 
    wakeup(&p->nread);
80102d78:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102d7e:	83 ec 0c             	sub    $0xc,%esp
80102d81:	50                   	push   %eax
80102d82:	e8 88 0b 00 00       	call   8010390f <wakeup>
80102d87:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102d8a:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102d91:	75 09                	jne    80102d9c <pipeclose+0x47>
80102d93:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102d9a:	74 2f                	je     80102dcb <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102d9c:	83 ec 0c             	sub    $0xc,%esp
80102d9f:	53                   	push   %ebx
80102da0:	e8 63 0f 00 00       	call   80103d08 <release>
80102da5:	83 c4 10             	add    $0x10,%esp
}
80102da8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102dab:	c9                   	leave  
80102dac:	c3                   	ret    
    p->readopen = 0;
80102dad:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102db4:	00 00 00 
    wakeup(&p->nwrite);
80102db7:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102dbd:	83 ec 0c             	sub    $0xc,%esp
80102dc0:	50                   	push   %eax
80102dc1:	e8 49 0b 00 00       	call   8010390f <wakeup>
80102dc6:	83 c4 10             	add    $0x10,%esp
80102dc9:	eb bf                	jmp    80102d8a <pipeclose+0x35>
    release(&p->lock);
80102dcb:	83 ec 0c             	sub    $0xc,%esp
80102dce:	53                   	push   %ebx
80102dcf:	e8 34 0f 00 00       	call   80103d08 <release>
    kfree((char*)p);
80102dd4:	89 1c 24             	mov    %ebx,(%esp)
80102dd7:	e8 4c f1 ff ff       	call   80101f28 <kfree>
80102ddc:	83 c4 10             	add    $0x10,%esp
80102ddf:	eb c7                	jmp    80102da8 <pipeclose+0x53>

80102de1 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80102de1:	55                   	push   %ebp
80102de2:	89 e5                	mov    %esp,%ebp
80102de4:	56                   	push   %esi
80102de5:	53                   	push   %ebx
80102de6:	83 ec 1c             	sub    $0x1c,%esp
80102de9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102dec:	53                   	push   %ebx
80102ded:	e8 b1 0e 00 00       	call   80103ca3 <acquire>
  for(i = 0; i < n; i++){
80102df2:	83 c4 10             	add    $0x10,%esp
80102df5:	be 00 00 00 00       	mov    $0x0,%esi
80102dfa:	3b 75 10             	cmp    0x10(%ebp),%esi
80102dfd:	7c 41                	jl     80102e40 <pipewrite+0x5f>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80102dff:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102e05:	83 ec 0c             	sub    $0xc,%esp
80102e08:	50                   	push   %eax
80102e09:	e8 01 0b 00 00       	call   8010390f <wakeup>
  release(&p->lock);
80102e0e:	89 1c 24             	mov    %ebx,(%esp)
80102e11:	e8 f2 0e 00 00       	call   80103d08 <release>
  return n;
80102e16:	83 c4 10             	add    $0x10,%esp
80102e19:	8b 45 10             	mov    0x10(%ebp),%eax
80102e1c:	eb 5c                	jmp    80102e7a <pipewrite+0x99>
      wakeup(&p->nread);
80102e1e:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102e24:	83 ec 0c             	sub    $0xc,%esp
80102e27:	50                   	push   %eax
80102e28:	e8 e2 0a 00 00       	call   8010390f <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102e2d:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102e33:	83 c4 08             	add    $0x8,%esp
80102e36:	53                   	push   %ebx
80102e37:	50                   	push   %eax
80102e38:	e8 60 09 00 00       	call   8010379d <sleep>
80102e3d:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102e40:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80102e46:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102e4c:	05 00 02 00 00       	add    $0x200,%eax
80102e51:	39 c2                	cmp    %eax,%edx
80102e53:	75 2c                	jne    80102e81 <pipewrite+0xa0>
      if(p->readopen == 0 || myproc()->killed){
80102e55:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102e5c:	74 0b                	je     80102e69 <pipewrite+0x88>
80102e5e:	e8 da 02 00 00       	call   8010313d <myproc>
80102e63:	83 78 30 00          	cmpl   $0x0,0x30(%eax)
80102e67:	74 b5                	je     80102e1e <pipewrite+0x3d>
        release(&p->lock);
80102e69:	83 ec 0c             	sub    $0xc,%esp
80102e6c:	53                   	push   %ebx
80102e6d:	e8 96 0e 00 00       	call   80103d08 <release>
        return -1;
80102e72:	83 c4 10             	add    $0x10,%esp
80102e75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102e7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102e7d:	5b                   	pop    %ebx
80102e7e:	5e                   	pop    %esi
80102e7f:	5d                   	pop    %ebp
80102e80:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80102e81:	8d 42 01             	lea    0x1(%edx),%eax
80102e84:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80102e8a:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102e90:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e93:	8a 04 30             	mov    (%eax,%esi,1),%al
80102e96:	88 45 f7             	mov    %al,-0x9(%ebp)
80102e99:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80102e9d:	46                   	inc    %esi
80102e9e:	e9 57 ff ff ff       	jmp    80102dfa <pipewrite+0x19>

80102ea3 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80102ea3:	55                   	push   %ebp
80102ea4:	89 e5                	mov    %esp,%ebp
80102ea6:	57                   	push   %edi
80102ea7:	56                   	push   %esi
80102ea8:	53                   	push   %ebx
80102ea9:	83 ec 18             	sub    $0x18,%esp
80102eac:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102eaf:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
80102eb2:	53                   	push   %ebx
80102eb3:	e8 eb 0d 00 00       	call   80103ca3 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102eb8:	83 c4 10             	add    $0x10,%esp
80102ebb:	eb 13                	jmp    80102ed0 <piperead+0x2d>
    if(myproc()->killed){
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80102ebd:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102ec3:	83 ec 08             	sub    $0x8,%esp
80102ec6:	53                   	push   %ebx
80102ec7:	50                   	push   %eax
80102ec8:	e8 d0 08 00 00       	call   8010379d <sleep>
80102ecd:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102ed0:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102ed6:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80102edc:	75 75                	jne    80102f53 <piperead+0xb0>
80102ede:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80102ee4:	85 f6                	test   %esi,%esi
80102ee6:	74 34                	je     80102f1c <piperead+0x79>
    if(myproc()->killed){
80102ee8:	e8 50 02 00 00       	call   8010313d <myproc>
80102eed:	83 78 30 00          	cmpl   $0x0,0x30(%eax)
80102ef1:	74 ca                	je     80102ebd <piperead+0x1a>
      release(&p->lock);
80102ef3:	83 ec 0c             	sub    $0xc,%esp
80102ef6:	53                   	push   %ebx
80102ef7:	e8 0c 0e 00 00       	call   80103d08 <release>
      return -1;
80102efc:	83 c4 10             	add    $0x10,%esp
80102eff:	be ff ff ff ff       	mov    $0xffffffff,%esi
80102f04:	eb 43                	jmp    80102f49 <piperead+0xa6>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80102f06:	8d 50 01             	lea    0x1(%eax),%edx
80102f09:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80102f0f:	25 ff 01 00 00       	and    $0x1ff,%eax
80102f14:	8a 44 03 34          	mov    0x34(%ebx,%eax,1),%al
80102f18:	88 04 37             	mov    %al,(%edi,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80102f1b:	46                   	inc    %esi
80102f1c:	3b 75 10             	cmp    0x10(%ebp),%esi
80102f1f:	7d 0e                	jge    80102f2f <piperead+0x8c>
    if(p->nread == p->nwrite)
80102f21:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102f27:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80102f2d:	75 d7                	jne    80102f06 <piperead+0x63>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80102f2f:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f35:	83 ec 0c             	sub    $0xc,%esp
80102f38:	50                   	push   %eax
80102f39:	e8 d1 09 00 00       	call   8010390f <wakeup>
  release(&p->lock);
80102f3e:	89 1c 24             	mov    %ebx,(%esp)
80102f41:	e8 c2 0d 00 00       	call   80103d08 <release>
  return i;
80102f46:	83 c4 10             	add    $0x10,%esp
}
80102f49:	89 f0                	mov    %esi,%eax
80102f4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f4e:	5b                   	pop    %ebx
80102f4f:	5e                   	pop    %esi
80102f50:	5f                   	pop    %edi
80102f51:	5d                   	pop    %ebp
80102f52:	c3                   	ret    
80102f53:	be 00 00 00 00       	mov    $0x0,%esi
80102f58:	eb c2                	jmp    80102f1c <piperead+0x79>

80102f5a <wakeup1>:
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80102f5a:	ba 54 1d 11 80       	mov    $0x80111d54,%edx
80102f5f:	eb 06                	jmp    80102f67 <wakeup1+0xd>
80102f61:	81 c2 88 00 00 00    	add    $0x88,%edx
80102f67:	81 fa 54 3f 11 80    	cmp    $0x80113f54,%edx
80102f6d:	73 14                	jae    80102f83 <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
80102f6f:	83 7a 14 02          	cmpl   $0x2,0x14(%edx)
80102f73:	75 ec                	jne    80102f61 <wakeup1+0x7>
80102f75:	39 42 2c             	cmp    %eax,0x2c(%edx)
80102f78:	75 e7                	jne    80102f61 <wakeup1+0x7>
      p->state = RUNNABLE;
80102f7a:	c7 42 14 03 00 00 00 	movl   $0x3,0x14(%edx)
80102f81:	eb de                	jmp    80102f61 <wakeup1+0x7>
}
80102f83:	c3                   	ret    

80102f84 <allocproc>:
{
80102f84:	55                   	push   %ebp
80102f85:	89 e5                	mov    %esp,%ebp
80102f87:	53                   	push   %ebx
80102f88:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80102f8b:	68 20 1d 11 80       	push   $0x80111d20
80102f90:	e8 0e 0d 00 00       	call   80103ca3 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80102f95:	83 c4 10             	add    $0x10,%esp
80102f98:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80102f9d:	eb 06                	jmp    80102fa5 <allocproc+0x21>
80102f9f:	81 c3 88 00 00 00    	add    $0x88,%ebx
80102fa5:	81 fb 54 3f 11 80    	cmp    $0x80113f54,%ebx
80102fab:	73 7c                	jae    80103029 <allocproc+0xa5>
    if(p->state == UNUSED)
80102fad:	83 7b 14 00          	cmpl   $0x0,0x14(%ebx)
80102fb1:	75 ec                	jne    80102f9f <allocproc+0x1b>
  p->state = EMBRYO;
80102fb3:	c7 43 14 01 00 00 00 	movl   $0x1,0x14(%ebx)
  p->pid = nextpid++;
80102fba:	a1 04 a0 10 80       	mov    0x8010a004,%eax
80102fbf:	8d 50 01             	lea    0x1(%eax),%edx
80102fc2:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
80102fc8:	89 43 18             	mov    %eax,0x18(%ebx)
	p->prio = NORM_PRIO;
80102fcb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ptable.lock);
80102fd1:	83 ec 0c             	sub    $0xc,%esp
80102fd4:	68 20 1d 11 80       	push   $0x80111d20
80102fd9:	e8 2a 0d 00 00       	call   80103d08 <release>
  if((p->kstack = kalloc()) == 0){
80102fde:	e8 5c f0 ff ff       	call   8010203f <kalloc>
80102fe3:	89 43 10             	mov    %eax,0x10(%ebx)
80102fe6:	83 c4 10             	add    $0x10,%esp
80102fe9:	85 c0                	test   %eax,%eax
80102feb:	74 53                	je     80103040 <allocproc+0xbc>
  sp -= sizeof *p->tf;
80102fed:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
80102ff3:	89 53 20             	mov    %edx,0x20(%ebx)
  *(uint*)sp = (uint)trapret;
80102ff6:	c7 80 b0 0f 00 00 64 	movl   $0x80104f64,0xfb0(%eax)
80102ffd:	4f 10 80 
  sp -= sizeof *p->context;
80103000:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80103005:	89 43 28             	mov    %eax,0x28(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103008:	83 ec 04             	sub    $0x4,%esp
8010300b:	6a 14                	push   $0x14
8010300d:	6a 00                	push   $0x0
8010300f:	50                   	push   %eax
80103010:	e8 3a 0d 00 00       	call   80103d4f <memset>
  p->context->eip = (uint)forkret;
80103015:	8b 43 28             	mov    0x28(%ebx),%eax
80103018:	c7 40 10 4b 30 10 80 	movl   $0x8010304b,0x10(%eax)
  return p;
8010301f:	83 c4 10             	add    $0x10,%esp
}
80103022:	89 d8                	mov    %ebx,%eax
80103024:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103027:	c9                   	leave  
80103028:	c3                   	ret    
  release(&ptable.lock);
80103029:	83 ec 0c             	sub    $0xc,%esp
8010302c:	68 20 1d 11 80       	push   $0x80111d20
80103031:	e8 d2 0c 00 00       	call   80103d08 <release>
  return 0;
80103036:	83 c4 10             	add    $0x10,%esp
80103039:	bb 00 00 00 00       	mov    $0x0,%ebx
8010303e:	eb e2                	jmp    80103022 <allocproc+0x9e>
    p->state = UNUSED;
80103040:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
    return 0;
80103047:	89 c3                	mov    %eax,%ebx
80103049:	eb d7                	jmp    80103022 <allocproc+0x9e>

8010304b <forkret>:
{
8010304b:	55                   	push   %ebp
8010304c:	89 e5                	mov    %esp,%ebp
8010304e:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
80103051:	68 20 1d 11 80       	push   $0x80111d20
80103056:	e8 ad 0c 00 00       	call   80103d08 <release>
  if (first) {
8010305b:	83 c4 10             	add    $0x10,%esp
8010305e:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
80103065:	75 02                	jne    80103069 <forkret+0x1e>
}
80103067:	c9                   	leave  
80103068:	c3                   	ret    
    first = 0;
80103069:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
80103070:	00 00 00 
    iinit(ROOTDEV);
80103073:	83 ec 0c             	sub    $0xc,%esp
80103076:	6a 01                	push   $0x1
80103078:	e8 19 e2 ff ff       	call   80101296 <iinit>
    initlog(ROOTDEV);
8010307d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103084:	e8 22 f6 ff ff       	call   801026ab <initlog>
80103089:	83 c4 10             	add    $0x10,%esp
}
8010308c:	eb d9                	jmp    80103067 <forkret+0x1c>

8010308e <pinit>:
{
8010308e:	55                   	push   %ebp
8010308f:	89 e5                	mov    %esp,%ebp
80103091:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103094:	68 a0 6f 10 80       	push   $0x80106fa0
80103099:	68 20 1d 11 80       	push   $0x80111d20
8010309e:	e8 c9 0a 00 00       	call   80103b6c <initlock>
}
801030a3:	83 c4 10             	add    $0x10,%esp
801030a6:	c9                   	leave  
801030a7:	c3                   	ret    

801030a8 <mycpu>:
{
801030a8:	55                   	push   %ebp
801030a9:	89 e5                	mov    %esp,%ebp
801030ab:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801030ae:	9c                   	pushf  
801030af:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801030b0:	f6 c4 02             	test   $0x2,%ah
801030b3:	75 2c                	jne    801030e1 <mycpu+0x39>
  apicid = lapicid();
801030b5:	e8 41 f2 ff ff       	call   801022fb <lapicid>
801030ba:	89 c1                	mov    %eax,%ecx
  for (i = 0; i < ncpu; ++i) {
801030bc:	ba 00 00 00 00       	mov    $0x0,%edx
801030c1:	39 15 84 17 11 80    	cmp    %edx,0x80111784
801030c7:	7e 25                	jle    801030ee <mycpu+0x46>
    if (cpus[i].apicid == apicid)
801030c9:	8d 04 92             	lea    (%edx,%edx,4),%eax
801030cc:	01 c0                	add    %eax,%eax
801030ce:	01 d0                	add    %edx,%eax
801030d0:	c1 e0 04             	shl    $0x4,%eax
801030d3:	0f b6 80 a0 17 11 80 	movzbl -0x7feee860(%eax),%eax
801030da:	39 c8                	cmp    %ecx,%eax
801030dc:	74 1d                	je     801030fb <mycpu+0x53>
  for (i = 0; i < ncpu; ++i) {
801030de:	42                   	inc    %edx
801030df:	eb e0                	jmp    801030c1 <mycpu+0x19>
    panic("mycpu called with interrupts enabled\n");
801030e1:	83 ec 0c             	sub    $0xc,%esp
801030e4:	68 84 70 10 80       	push   $0x80107084
801030e9:	e8 53 d2 ff ff       	call   80100341 <panic>
  panic("unknown apicid\n");
801030ee:	83 ec 0c             	sub    $0xc,%esp
801030f1:	68 a7 6f 10 80       	push   $0x80106fa7
801030f6:	e8 46 d2 ff ff       	call   80100341 <panic>
      return &cpus[i];
801030fb:	8d 04 92             	lea    (%edx,%edx,4),%eax
801030fe:	01 c0                	add    %eax,%eax
80103100:	01 d0                	add    %edx,%eax
80103102:	c1 e0 04             	shl    $0x4,%eax
80103105:	05 a0 17 11 80       	add    $0x801117a0,%eax
}
8010310a:	c9                   	leave  
8010310b:	c3                   	ret    

8010310c <cpuid>:
cpuid() {
8010310c:	55                   	push   %ebp
8010310d:	89 e5                	mov    %esp,%ebp
8010310f:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103112:	e8 91 ff ff ff       	call   801030a8 <mycpu>
80103117:	2d a0 17 11 80       	sub    $0x801117a0,%eax
8010311c:	c1 f8 04             	sar    $0x4,%eax
8010311f:	8d 0c c0             	lea    (%eax,%eax,8),%ecx
80103122:	89 ca                	mov    %ecx,%edx
80103124:	c1 e2 05             	shl    $0x5,%edx
80103127:	29 ca                	sub    %ecx,%edx
80103129:	8d 14 90             	lea    (%eax,%edx,4),%edx
8010312c:	8d 0c d0             	lea    (%eax,%edx,8),%ecx
8010312f:	89 ca                	mov    %ecx,%edx
80103131:	c1 e2 0f             	shl    $0xf,%edx
80103134:	29 ca                	sub    %ecx,%edx
80103136:	8d 04 90             	lea    (%eax,%edx,4),%eax
80103139:	f7 d8                	neg    %eax
}
8010313b:	c9                   	leave  
8010313c:	c3                   	ret    

8010313d <myproc>:
myproc(void) {
8010313d:	55                   	push   %ebp
8010313e:	89 e5                	mov    %esp,%ebp
80103140:	53                   	push   %ebx
80103141:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103144:	e8 80 0a 00 00       	call   80103bc9 <pushcli>
  c = mycpu();
80103149:	e8 5a ff ff ff       	call   801030a8 <mycpu>
  p = c->proc;
8010314e:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103154:	e8 ab 0a 00 00       	call   80103c04 <popcli>
}
80103159:	89 d8                	mov    %ebx,%eax
8010315b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010315e:	c9                   	leave  
8010315f:	c3                   	ret    

80103160 <userinit>:
{
80103160:	55                   	push   %ebp
80103161:	89 e5                	mov    %esp,%ebp
80103163:	53                   	push   %ebx
80103164:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103167:	e8 18 fe ff ff       	call   80102f84 <allocproc>
8010316c:	89 c3                	mov    %eax,%ebx
  initproc = p;
8010316e:	a3 54 3f 11 80       	mov    %eax,0x80113f54
  if((p->pgdir = setupkvm()) == 0)
80103173:	e8 b3 35 00 00       	call   8010672b <setupkvm>
80103178:	89 43 0c             	mov    %eax,0xc(%ebx)
8010317b:	85 c0                	test   %eax,%eax
8010317d:	0f 84 b7 00 00 00    	je     8010323a <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103183:	83 ec 04             	sub    $0x4,%esp
80103186:	68 2c 00 00 00       	push   $0x2c
8010318b:	68 60 a4 10 80       	push   $0x8010a460
80103190:	50                   	push   %eax
80103191:	e8 a0 32 00 00       	call   80106436 <inituvm>
  p->sz = PGSIZE;
80103196:	c7 43 08 00 10 00 00 	movl   $0x1000,0x8(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
8010319d:	8b 43 20             	mov    0x20(%ebx),%eax
801031a0:	83 c4 0c             	add    $0xc,%esp
801031a3:	6a 4c                	push   $0x4c
801031a5:	6a 00                	push   $0x0
801031a7:	50                   	push   %eax
801031a8:	e8 a2 0b 00 00       	call   80103d4f <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801031ad:	8b 43 20             	mov    0x20(%ebx),%eax
801031b0:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801031b6:	8b 43 20             	mov    0x20(%ebx),%eax
801031b9:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801031bf:	8b 43 20             	mov    0x20(%ebx),%eax
801031c2:	8b 50 2c             	mov    0x2c(%eax),%edx
801031c5:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801031c9:	8b 43 20             	mov    0x20(%ebx),%eax
801031cc:	8b 50 2c             	mov    0x2c(%eax),%edx
801031cf:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801031d3:	8b 43 20             	mov    0x20(%ebx),%eax
801031d6:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801031dd:	8b 43 20             	mov    0x20(%ebx),%eax
801031e0:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801031e7:	8b 43 20             	mov    0x20(%ebx),%eax
801031ea:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
801031f1:	8d 43 78             	lea    0x78(%ebx),%eax
801031f4:	83 c4 0c             	add    $0xc,%esp
801031f7:	6a 10                	push   $0x10
801031f9:	68 d0 6f 10 80       	push   $0x80106fd0
801031fe:	50                   	push   %eax
801031ff:	e8 a3 0c 00 00       	call   80103ea7 <safestrcpy>
  p->cwd = namei("/");
80103204:	c7 04 24 d9 6f 10 80 	movl   $0x80106fd9,(%esp)
8010320b:	e8 72 e9 ff ff       	call   80101b82 <namei>
80103210:	89 43 74             	mov    %eax,0x74(%ebx)
  acquire(&ptable.lock);
80103213:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010321a:	e8 84 0a 00 00       	call   80103ca3 <acquire>
  p->state = RUNNABLE;
8010321f:	c7 43 14 03 00 00 00 	movl   $0x3,0x14(%ebx)
  release(&ptable.lock);
80103226:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010322d:	e8 d6 0a 00 00       	call   80103d08 <release>
}
80103232:	83 c4 10             	add    $0x10,%esp
80103235:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103238:	c9                   	leave  
80103239:	c3                   	ret    
    panic("userinit: out of memory?");
8010323a:	83 ec 0c             	sub    $0xc,%esp
8010323d:	68 b7 6f 10 80       	push   $0x80106fb7
80103242:	e8 fa d0 ff ff       	call   80100341 <panic>

80103247 <growproc>:
{
80103247:	55                   	push   %ebp
80103248:	89 e5                	mov    %esp,%ebp
8010324a:	56                   	push   %esi
8010324b:	53                   	push   %ebx
8010324c:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
8010324f:	e8 e9 fe ff ff       	call   8010313d <myproc>
80103254:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;//Tamaño inicial
80103256:	8b 40 08             	mov    0x8(%eax),%eax
  if(n > 0){
80103259:	85 f6                	test   %esi,%esi
8010325b:	7f 1c                	jg     80103279 <growproc+0x32>
  } else if(n < 0){
8010325d:	78 37                	js     80103296 <growproc+0x4f>
  curproc->sz = sz;
8010325f:	89 43 08             	mov    %eax,0x8(%ebx)
  lcr3(V2P(curproc->pgdir));  // Invalidate TLB. Cambia la tabla de páginas
80103262:	8b 43 0c             	mov    0xc(%ebx),%eax
80103265:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010326a:	0f 22 d8             	mov    %eax,%cr3
  return 0;
8010326d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103272:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103275:	5b                   	pop    %ebx
80103276:	5e                   	pop    %esi
80103277:	5d                   	pop    %ebp
80103278:	c3                   	ret    
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103279:	83 ec 04             	sub    $0x4,%esp
8010327c:	01 c6                	add    %eax,%esi
8010327e:	56                   	push   %esi
8010327f:	50                   	push   %eax
80103280:	ff 73 0c             	push   0xc(%ebx)
80103283:	e8 40 33 00 00       	call   801065c8 <allocuvm>
80103288:	83 c4 10             	add    $0x10,%esp
8010328b:	85 c0                	test   %eax,%eax
8010328d:	75 d0                	jne    8010325f <growproc+0x18>
      return -1;
8010328f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103294:	eb dc                	jmp    80103272 <growproc+0x2b>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103296:	83 ec 04             	sub    $0x4,%esp
80103299:	01 c6                	add    %eax,%esi
8010329b:	56                   	push   %esi
8010329c:	50                   	push   %eax
8010329d:	ff 73 0c             	push   0xc(%ebx)
801032a0:	e8 93 32 00 00       	call   80106538 <deallocuvm>
801032a5:	83 c4 10             	add    $0x10,%esp
801032a8:	85 c0                	test   %eax,%eax
801032aa:	75 b3                	jne    8010325f <growproc+0x18>
      return -1;
801032ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801032b1:	eb bf                	jmp    80103272 <growproc+0x2b>

801032b3 <fork>:
{
801032b3:	55                   	push   %ebp
801032b4:	89 e5                	mov    %esp,%ebp
801032b6:	57                   	push   %edi
801032b7:	56                   	push   %esi
801032b8:	53                   	push   %ebx
801032b9:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
801032bc:	e8 7c fe ff ff       	call   8010313d <myproc>
801032c1:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
801032c3:	e8 bc fc ff ff       	call   80102f84 <allocproc>
801032c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801032cb:	85 c0                	test   %eax,%eax
801032cd:	0f 84 e3 00 00 00    	je     801033b6 <fork+0x103>
801032d3:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm1(curproc->pgdir, curproc->sz)) == 0){
801032d5:	83 ec 08             	sub    $0x8,%esp
801032d8:	ff 73 08             	push   0x8(%ebx)
801032db:	ff 73 0c             	push   0xc(%ebx)
801032de:	e8 e5 35 00 00       	call   801068c8 <copyuvm1>
801032e3:	89 47 0c             	mov    %eax,0xc(%edi)
801032e6:	83 c4 10             	add    $0x10,%esp
801032e9:	85 c0                	test   %eax,%eax
801032eb:	74 2e                	je     8010331b <fork+0x68>
  np->sz = curproc->sz;
801032ed:	8b 43 08             	mov    0x8(%ebx),%eax
801032f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032f3:	89 42 08             	mov    %eax,0x8(%edx)
  np->parent = curproc;
801032f6:	89 5a 1c             	mov    %ebx,0x1c(%edx)
  *np->tf = *curproc->tf;
801032f9:	8b 73 20             	mov    0x20(%ebx),%esi
801032fc:	8b 7a 20             	mov    0x20(%edx),%edi
801032ff:	b9 13 00 00 00       	mov    $0x13,%ecx
80103304:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	np->prio = curproc->prio;
80103306:	8b 03                	mov    (%ebx),%eax
80103308:	89 02                	mov    %eax,(%edx)
  np->tf->eax = 0;
8010330a:	8b 42 20             	mov    0x20(%edx),%eax
8010330d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103314:	be 00 00 00 00       	mov    $0x0,%esi
80103319:	eb 27                	jmp    80103342 <fork+0x8f>
    kfree(np->kstack);
8010331b:	83 ec 0c             	sub    $0xc,%esp
8010331e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103321:	ff 73 10             	push   0x10(%ebx)
80103324:	e8 ff eb ff ff       	call   80101f28 <kfree>
    np->kstack = 0;
80103329:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
    np->state = UNUSED;
80103330:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
    return -1;
80103337:	83 c4 10             	add    $0x10,%esp
8010333a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010333f:	eb 6b                	jmp    801033ac <fork+0xf9>
  for(i = 0; i < NOFILE; i++)
80103341:	46                   	inc    %esi
80103342:	83 fe 0f             	cmp    $0xf,%esi
80103345:	7f 1d                	jg     80103364 <fork+0xb1>
    if(curproc->ofile[i])
80103347:	8b 44 b3 34          	mov    0x34(%ebx,%esi,4),%eax
8010334b:	85 c0                	test   %eax,%eax
8010334d:	74 f2                	je     80103341 <fork+0x8e>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010334f:	83 ec 0c             	sub    $0xc,%esp
80103352:	50                   	push   %eax
80103353:	e8 07 d9 ff ff       	call   80100c5f <filedup>
80103358:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010335b:	89 44 b2 34          	mov    %eax,0x34(%edx,%esi,4)
8010335f:	83 c4 10             	add    $0x10,%esp
80103362:	eb dd                	jmp    80103341 <fork+0x8e>
  np->cwd = idup(curproc->cwd);
80103364:	83 ec 0c             	sub    $0xc,%esp
80103367:	ff 73 74             	push   0x74(%ebx)
8010336a:	e8 81 e1 ff ff       	call   801014f0 <idup>
8010336f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103372:	89 47 74             	mov    %eax,0x74(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103375:	83 c3 78             	add    $0x78,%ebx
80103378:	8d 47 78             	lea    0x78(%edi),%eax
8010337b:	83 c4 0c             	add    $0xc,%esp
8010337e:	6a 10                	push   $0x10
80103380:	53                   	push   %ebx
80103381:	50                   	push   %eax
80103382:	e8 20 0b 00 00       	call   80103ea7 <safestrcpy>
  pid = np->pid;
80103387:	8b 5f 18             	mov    0x18(%edi),%ebx
  acquire(&ptable.lock);
8010338a:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103391:	e8 0d 09 00 00       	call   80103ca3 <acquire>
  np->state = RUNNABLE;
80103396:	c7 47 14 03 00 00 00 	movl   $0x3,0x14(%edi)
  release(&ptable.lock);
8010339d:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801033a4:	e8 5f 09 00 00       	call   80103d08 <release>
  return pid;
801033a9:	83 c4 10             	add    $0x10,%esp
}
801033ac:	89 d8                	mov    %ebx,%eax
801033ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
801033b1:	5b                   	pop    %ebx
801033b2:	5e                   	pop    %esi
801033b3:	5f                   	pop    %edi
801033b4:	5d                   	pop    %ebp
801033b5:	c3                   	ret    
    return -1;
801033b6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801033bb:	eb ef                	jmp    801033ac <fork+0xf9>

801033bd <getprio>:
{
801033bd:	55                   	push   %ebp
801033be:	89 e5                	mov    %esp,%ebp
801033c0:	56                   	push   %esi
801033c1:	53                   	push   %ebx
801033c2:	8b 75 08             	mov    0x8(%ebp),%esi
	acquire(&ptable.lock);
801033c5:	83 ec 0c             	sub    $0xc,%esp
801033c8:	68 20 1d 11 80       	push   $0x80111d20
801033cd:	e8 d1 08 00 00       	call   80103ca3 <acquire>
	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801033d2:	83 c4 10             	add    $0x10,%esp
801033d5:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
801033da:	eb 06                	jmp    801033e2 <getprio+0x25>
801033dc:	81 c3 88 00 00 00    	add    $0x88,%ebx
801033e2:	81 fb 54 3f 11 80    	cmp    $0x80113f54,%ebx
801033e8:	73 1e                	jae    80103408 <getprio+0x4b>
		if(p->pid == pid){
801033ea:	39 73 18             	cmp    %esi,0x18(%ebx)
801033ed:	75 ed                	jne    801033dc <getprio+0x1f>
			release(&ptable.lock);
801033ef:	83 ec 0c             	sub    $0xc,%esp
801033f2:	68 20 1d 11 80       	push   $0x80111d20
801033f7:	e8 0c 09 00 00       	call   80103d08 <release>
			return p->prio;
801033fc:	8b 03                	mov    (%ebx),%eax
801033fe:	83 c4 10             	add    $0x10,%esp
}
80103401:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103404:	5b                   	pop    %ebx
80103405:	5e                   	pop    %esi
80103406:	5d                   	pop    %ebp
80103407:	c3                   	ret    
	release(&ptable.lock);
80103408:	83 ec 0c             	sub    $0xc,%esp
8010340b:	68 20 1d 11 80       	push   $0x80111d20
80103410:	e8 f3 08 00 00       	call   80103d08 <release>
	return -1;
80103415:	83 c4 10             	add    $0x10,%esp
80103418:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010341d:	eb e2                	jmp    80103401 <getprio+0x44>

8010341f <setprio>:
{
8010341f:	55                   	push   %ebp
80103420:	89 e5                	mov    %esp,%ebp
80103422:	53                   	push   %ebx
80103423:	83 ec 10             	sub    $0x10,%esp
80103426:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
80103429:	68 20 1d 11 80       	push   $0x80111d20
8010342e:	e8 70 08 00 00       	call   80103ca3 <acquire>
  for(e = ptable.proc; e < &ptable.proc[NPROC]; e++){
80103433:	83 c4 10             	add    $0x10,%esp
80103436:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
8010343b:	eb 05                	jmp    80103442 <setprio+0x23>
8010343d:	05 88 00 00 00       	add    $0x88,%eax
80103442:	3d 54 3f 11 80       	cmp    $0x80113f54,%eax
80103447:	73 24                	jae    8010346d <setprio+0x4e>
    if(e->pid == pid){
80103449:	39 58 18             	cmp    %ebx,0x18(%eax)
8010344c:	75 ef                	jne    8010343d <setprio+0x1e>
			e->prio = prio;
8010344e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103451:	89 10                	mov    %edx,(%eax)
			release(&ptable.lock);
80103453:	83 ec 0c             	sub    $0xc,%esp
80103456:	68 20 1d 11 80       	push   $0x80111d20
8010345b:	e8 a8 08 00 00       	call   80103d08 <release>
			return 0;
80103460:	83 c4 10             	add    $0x10,%esp
80103463:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103468:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010346b:	c9                   	leave  
8010346c:	c3                   	ret    
	release(&ptable.lock);
8010346d:	83 ec 0c             	sub    $0xc,%esp
80103470:	68 20 1d 11 80       	push   $0x80111d20
80103475:	e8 8e 08 00 00       	call   80103d08 <release>
	return -1;
8010347a:	83 c4 10             	add    $0x10,%esp
8010347d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103482:	eb e4                	jmp    80103468 <setprio+0x49>

80103484 <scheduler>:
{
80103484:	55                   	push   %ebp
80103485:	89 e5                	mov    %esp,%ebp
80103487:	56                   	push   %esi
80103488:	53                   	push   %ebx
  struct cpu *c = mycpu();
80103489:	e8 1a fc ff ff       	call   801030a8 <mycpu>
8010348e:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103490:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103497:	00 00 00 
8010349a:	e9 8a 00 00 00       	jmp    80103529 <scheduler+0xa5>
        for(aux = ptable.proc; aux < &ptable.proc[NPROC]; aux++){   
8010349f:	81 c3 88 00 00 00    	add    $0x88,%ebx
801034a5:	81 fb 54 3f 11 80    	cmp    $0x80113f54,%ebx
801034ab:	73 61                	jae    8010350e <scheduler+0x8a>
             if((aux->state == RUNNABLE) && (aux->prio == HI_PRIO)) {p1=aux; break;}
801034ad:	83 7b 14 03          	cmpl   $0x3,0x14(%ebx)
801034b1:	75 ec                	jne    8010349f <scheduler+0x1b>
801034b3:	83 3b 01             	cmpl   $0x1,(%ebx)
801034b6:	75 e7                	jne    8010349f <scheduler+0x1b>
       if(p1 != 0) p = p1;
801034b8:	85 db                	test   %ebx,%ebx
801034ba:	74 59                	je     80103515 <scheduler+0x91>
        c->proc = p;
801034bc:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
        switchuvm(p);
801034c2:	83 ec 0c             	sub    $0xc,%esp
801034c5:	53                   	push   %ebx
801034c6:	e8 0f 2e 00 00       	call   801062da <switchuvm>
        p->state = RUNNING;
801034cb:	c7 43 14 04 00 00 00 	movl   $0x4,0x14(%ebx)
        swtch(&(c->scheduler), p->context);
801034d2:	83 c4 08             	add    $0x8,%esp
801034d5:	ff 73 28             	push   0x28(%ebx)
801034d8:	8d 46 04             	lea    0x4(%esi),%eax
801034db:	50                   	push   %eax
801034dc:	e8 14 0a 00 00       	call   80103ef5 <swtch>
        switchkvm();
801034e1:	e8 e6 2d 00 00       	call   801062cc <switchkvm>
        c->proc = 0;
801034e6:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801034ed:	00 00 00 
801034f0:	83 c4 10             	add    $0x10,%esp
801034f3:	89 d8                	mov    %ebx,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801034f5:	05 88 00 00 00       	add    $0x88,%eax
801034fa:	3d 54 3f 11 80       	cmp    $0x80113f54,%eax
801034ff:	73 18                	jae    80103519 <scheduler+0x95>
      if(p->state != RUNNABLE) continue;
80103501:	83 78 14 03          	cmpl   $0x3,0x14(%eax)
80103505:	75 ee                	jne    801034f5 <scheduler+0x71>
        for(aux = ptable.proc; aux < &ptable.proc[NPROC]; aux++){   
80103507:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
8010350c:	eb 97                	jmp    801034a5 <scheduler+0x21>
        p1=0;
8010350e:	bb 00 00 00 00       	mov    $0x0,%ebx
80103513:	eb a3                	jmp    801034b8 <scheduler+0x34>
       if(p1 != 0) p = p1;
80103515:	89 c3                	mov    %eax,%ebx
80103517:	eb a3                	jmp    801034bc <scheduler+0x38>
    release(&ptable.lock);
80103519:	83 ec 0c             	sub    $0xc,%esp
8010351c:	68 20 1d 11 80       	push   $0x80111d20
80103521:	e8 e2 07 00 00       	call   80103d08 <release>
    sti();
80103526:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103529:	fb                   	sti    
    acquire(&ptable.lock);
8010352a:	83 ec 0c             	sub    $0xc,%esp
8010352d:	68 20 1d 11 80       	push   $0x80111d20
80103532:	e8 6c 07 00 00       	call   80103ca3 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103537:	83 c4 10             	add    $0x10,%esp
8010353a:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
8010353f:	eb b9                	jmp    801034fa <scheduler+0x76>

80103541 <scheduler1>:
{
80103541:	55                   	push   %ebp
80103542:	89 e5                	mov    %esp,%ebp
80103544:	56                   	push   %esi
80103545:	53                   	push   %ebx
  struct cpu *c = mycpu();
80103546:	e8 5d fb ff ff       	call   801030a8 <mycpu>
8010354b:	89 c6                	mov    %eax,%esi
  c->proc = 0;
8010354d:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103554:	00 00 00 
80103557:	eb 79                	jmp    801035d2 <scheduler1+0x91>
      c->proc = p;
80103559:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
8010355f:	83 ec 0c             	sub    $0xc,%esp
80103562:	53                   	push   %ebx
80103563:	e8 72 2d 00 00       	call   801062da <switchuvm>
      p->state = RUNNING;
80103568:	c7 43 14 04 00 00 00 	movl   $0x4,0x14(%ebx)
      swtch(&(c->scheduler), p->context);
8010356f:	83 c4 08             	add    $0x8,%esp
80103572:	ff 73 28             	push   0x28(%ebx)
80103575:	8d 46 04             	lea    0x4(%esi),%eax
80103578:	50                   	push   %eax
80103579:	e8 77 09 00 00       	call   80103ef5 <swtch>
      switchkvm();//Cambia a la tabla de páginas del kernel
8010357e:	e8 49 2d 00 00       	call   801062cc <switchkvm>
      c->proc = 0;
80103583:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
8010358a:	00 00 00 
8010358d:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103590:	81 c3 88 00 00 00    	add    $0x88,%ebx
80103596:	81 fb 54 3f 11 80    	cmp    $0x80113f54,%ebx
8010359c:	73 24                	jae    801035c2 <scheduler1+0x81>
      if(p->state != RUNNABLE)//se mantiene igual
8010359e:	83 7b 14 03          	cmpl   $0x3,0x14(%ebx)
801035a2:	75 ec                	jne    80103590 <scheduler1+0x4f>
			if(p->prio == NORM_PRIO){
801035a4:	83 3b 00             	cmpl   $0x0,(%ebx)
801035a7:	75 b0                	jne    80103559 <scheduler1+0x18>
					if(aux->state == RUNNABLE && aux->prio == HI_PRIO){
801035a9:	83 3d 68 1d 11 80 03 	cmpl   $0x3,0x80111d68
801035b0:	75 f7                	jne    801035a9 <scheduler1+0x68>
801035b2:	83 3d 54 1d 11 80 01 	cmpl   $0x1,0x80111d54
801035b9:	75 ee                	jne    801035a9 <scheduler1+0x68>
						p1 = aux;
801035bb:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
801035c0:	eb 97                	jmp    80103559 <scheduler1+0x18>
    release(&ptable.lock);
801035c2:	83 ec 0c             	sub    $0xc,%esp
801035c5:	68 20 1d 11 80       	push   $0x80111d20
801035ca:	e8 39 07 00 00       	call   80103d08 <release>
    sti();
801035cf:	83 c4 10             	add    $0x10,%esp
801035d2:	fb                   	sti    
    acquire(&ptable.lock);
801035d3:	83 ec 0c             	sub    $0xc,%esp
801035d6:	68 20 1d 11 80       	push   $0x80111d20
801035db:	e8 c3 06 00 00       	call   80103ca3 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801035e0:	83 c4 10             	add    $0x10,%esp
801035e3:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
801035e8:	eb ac                	jmp    80103596 <scheduler1+0x55>

801035ea <sched>:
{
801035ea:	55                   	push   %ebp
801035eb:	89 e5                	mov    %esp,%ebp
801035ed:	56                   	push   %esi
801035ee:	53                   	push   %ebx
  struct proc *p = myproc();
801035ef:	e8 49 fb ff ff       	call   8010313d <myproc>
801035f4:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
801035f6:	83 ec 0c             	sub    $0xc,%esp
801035f9:	68 20 1d 11 80       	push   $0x80111d20
801035fe:	e8 61 06 00 00       	call   80103c64 <holding>
80103603:	83 c4 10             	add    $0x10,%esp
80103606:	85 c0                	test   %eax,%eax
80103608:	74 4f                	je     80103659 <sched+0x6f>
  if(mycpu()->ncli != 1)
8010360a:	e8 99 fa ff ff       	call   801030a8 <mycpu>
8010360f:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103616:	75 4e                	jne    80103666 <sched+0x7c>
  if(p->state == RUNNING)
80103618:	83 7b 14 04          	cmpl   $0x4,0x14(%ebx)
8010361c:	74 55                	je     80103673 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010361e:	9c                   	pushf  
8010361f:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103620:	f6 c4 02             	test   $0x2,%ah
80103623:	75 5b                	jne    80103680 <sched+0x96>
  intena = mycpu()->intena;
80103625:	e8 7e fa ff ff       	call   801030a8 <mycpu>
8010362a:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103630:	e8 73 fa ff ff       	call   801030a8 <mycpu>
80103635:	83 ec 08             	sub    $0x8,%esp
80103638:	ff 70 04             	push   0x4(%eax)
8010363b:	83 c3 28             	add    $0x28,%ebx
8010363e:	53                   	push   %ebx
8010363f:	e8 b1 08 00 00       	call   80103ef5 <swtch>
  mycpu()->intena = intena;
80103644:	e8 5f fa ff ff       	call   801030a8 <mycpu>
80103649:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
8010364f:	83 c4 10             	add    $0x10,%esp
80103652:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103655:	5b                   	pop    %ebx
80103656:	5e                   	pop    %esi
80103657:	5d                   	pop    %ebp
80103658:	c3                   	ret    
    panic("sched ptable.lock");
80103659:	83 ec 0c             	sub    $0xc,%esp
8010365c:	68 db 6f 10 80       	push   $0x80106fdb
80103661:	e8 db cc ff ff       	call   80100341 <panic>
    panic("sched locks");
80103666:	83 ec 0c             	sub    $0xc,%esp
80103669:	68 ed 6f 10 80       	push   $0x80106fed
8010366e:	e8 ce cc ff ff       	call   80100341 <panic>
    panic("sched running");
80103673:	83 ec 0c             	sub    $0xc,%esp
80103676:	68 f9 6f 10 80       	push   $0x80106ff9
8010367b:	e8 c1 cc ff ff       	call   80100341 <panic>
    panic("sched interruptible");
80103680:	83 ec 0c             	sub    $0xc,%esp
80103683:	68 07 70 10 80       	push   $0x80107007
80103688:	e8 b4 cc ff ff       	call   80100341 <panic>

8010368d <exit>:
{ 
8010368d:	55                   	push   %ebp
8010368e:	89 e5                	mov    %esp,%ebp
80103690:	56                   	push   %esi
80103691:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103692:	e8 a6 fa ff ff       	call   8010313d <myproc>
  if(curproc == initproc)
80103697:	39 05 54 3f 11 80    	cmp    %eax,0x80113f54
8010369d:	74 09                	je     801036a8 <exit+0x1b>
8010369f:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
801036a1:	bb 00 00 00 00       	mov    $0x0,%ebx
801036a6:	eb 22                	jmp    801036ca <exit+0x3d>
    panic("init exiting");
801036a8:	83 ec 0c             	sub    $0xc,%esp
801036ab:	68 1b 70 10 80       	push   $0x8010701b
801036b0:	e8 8c cc ff ff       	call   80100341 <panic>
      fileclose(curproc->ofile[fd]);
801036b5:	83 ec 0c             	sub    $0xc,%esp
801036b8:	50                   	push   %eax
801036b9:	e8 e4 d5 ff ff       	call   80100ca2 <fileclose>
      curproc->ofile[fd] = 0;
801036be:	c7 44 9e 34 00 00 00 	movl   $0x0,0x34(%esi,%ebx,4)
801036c5:	00 
801036c6:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
801036c9:	43                   	inc    %ebx
801036ca:	83 fb 0f             	cmp    $0xf,%ebx
801036cd:	7f 0a                	jg     801036d9 <exit+0x4c>
    if(curproc->ofile[fd]){
801036cf:	8b 44 9e 34          	mov    0x34(%esi,%ebx,4),%eax
801036d3:	85 c0                	test   %eax,%eax
801036d5:	75 de                	jne    801036b5 <exit+0x28>
801036d7:	eb f0                	jmp    801036c9 <exit+0x3c>
  begin_op();
801036d9:	e8 16 f0 ff ff       	call   801026f4 <begin_op>
  iput(curproc->cwd);
801036de:	83 ec 0c             	sub    $0xc,%esp
801036e1:	ff 76 74             	push   0x74(%esi)
801036e4:	e8 3a df ff ff       	call   80101623 <iput>
  end_op();
801036e9:	e8 82 f0 ff ff       	call   80102770 <end_op>
  curproc->cwd = 0;
801036ee:	c7 46 74 00 00 00 00 	movl   $0x0,0x74(%esi)
  acquire(&ptable.lock);
801036f5:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801036fc:	e8 a2 05 00 00       	call   80103ca3 <acquire>
  curproc->exitcode = status;
80103701:	8b 45 08             	mov    0x8(%ebp),%eax
80103704:	89 46 04             	mov    %eax,0x4(%esi)
  wakeup1(curproc->parent);
80103707:	8b 46 1c             	mov    0x1c(%esi),%eax
8010370a:	e8 4b f8 ff ff       	call   80102f5a <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010370f:	83 c4 10             	add    $0x10,%esp
80103712:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80103717:	eb 06                	jmp    8010371f <exit+0x92>
80103719:	81 c3 88 00 00 00    	add    $0x88,%ebx
8010371f:	81 fb 54 3f 11 80    	cmp    $0x80113f54,%ebx
80103725:	73 1a                	jae    80103741 <exit+0xb4>
    if(p->parent == curproc){
80103727:	39 73 1c             	cmp    %esi,0x1c(%ebx)
8010372a:	75 ed                	jne    80103719 <exit+0x8c>
      p->parent = initproc;
8010372c:	a1 54 3f 11 80       	mov    0x80113f54,%eax
80103731:	89 43 1c             	mov    %eax,0x1c(%ebx)
      if(p->state == ZOMBIE)
80103734:	83 7b 14 05          	cmpl   $0x5,0x14(%ebx)
80103738:	75 df                	jne    80103719 <exit+0x8c>
        wakeup1(initproc);
8010373a:	e8 1b f8 ff ff       	call   80102f5a <wakeup1>
8010373f:	eb d8                	jmp    80103719 <exit+0x8c>
  deallocuvm(curproc->pgdir, KERNBASE, 0);
80103741:	83 ec 04             	sub    $0x4,%esp
80103744:	6a 00                	push   $0x0
80103746:	68 00 00 00 80       	push   $0x80000000
8010374b:	ff 76 0c             	push   0xc(%esi)
8010374e:	e8 e5 2d 00 00       	call   80106538 <deallocuvm>
  curproc->state = ZOMBIE;
80103753:	c7 46 14 05 00 00 00 	movl   $0x5,0x14(%esi)
  sched();
8010375a:	e8 8b fe ff ff       	call   801035ea <sched>
  panic("zombie exit");
8010375f:	c7 04 24 28 70 10 80 	movl   $0x80107028,(%esp)
80103766:	e8 d6 cb ff ff       	call   80100341 <panic>

8010376b <yield>:
{
8010376b:	55                   	push   %ebp
8010376c:	89 e5                	mov    %esp,%ebp
8010376e:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103771:	68 20 1d 11 80       	push   $0x80111d20
80103776:	e8 28 05 00 00       	call   80103ca3 <acquire>
  myproc()->state = RUNNABLE;
8010377b:	e8 bd f9 ff ff       	call   8010313d <myproc>
80103780:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)
  sched();
80103787:	e8 5e fe ff ff       	call   801035ea <sched>
  release(&ptable.lock);
8010378c:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103793:	e8 70 05 00 00       	call   80103d08 <release>
}
80103798:	83 c4 10             	add    $0x10,%esp
8010379b:	c9                   	leave  
8010379c:	c3                   	ret    

8010379d <sleep>:
{
8010379d:	55                   	push   %ebp
8010379e:	89 e5                	mov    %esp,%ebp
801037a0:	56                   	push   %esi
801037a1:	53                   	push   %ebx
801037a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct proc *p = myproc();
801037a5:	e8 93 f9 ff ff       	call   8010313d <myproc>
  if(p == 0)
801037aa:	85 c0                	test   %eax,%eax
801037ac:	74 66                	je     80103814 <sleep+0x77>
801037ae:	89 c3                	mov    %eax,%ebx
  if(lk == 0)
801037b0:	85 f6                	test   %esi,%esi
801037b2:	74 6d                	je     80103821 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801037b4:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
801037ba:	74 18                	je     801037d4 <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
801037bc:	83 ec 0c             	sub    $0xc,%esp
801037bf:	68 20 1d 11 80       	push   $0x80111d20
801037c4:	e8 da 04 00 00       	call   80103ca3 <acquire>
    release(lk);
801037c9:	89 34 24             	mov    %esi,(%esp)
801037cc:	e8 37 05 00 00       	call   80103d08 <release>
801037d1:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
801037d4:	8b 45 08             	mov    0x8(%ebp),%eax
801037d7:	89 43 2c             	mov    %eax,0x2c(%ebx)
  p->state = SLEEPING;
801037da:	c7 43 14 02 00 00 00 	movl   $0x2,0x14(%ebx)
  sched();
801037e1:	e8 04 fe ff ff       	call   801035ea <sched>
  p->chan = 0;
801037e6:	c7 43 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  if(lk != &ptable.lock){  //DOC: sleeplock2
801037ed:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
801037f3:	74 18                	je     8010380d <sleep+0x70>
    release(&ptable.lock);
801037f5:	83 ec 0c             	sub    $0xc,%esp
801037f8:	68 20 1d 11 80       	push   $0x80111d20
801037fd:	e8 06 05 00 00       	call   80103d08 <release>
    acquire(lk);
80103802:	89 34 24             	mov    %esi,(%esp)
80103805:	e8 99 04 00 00       	call   80103ca3 <acquire>
8010380a:	83 c4 10             	add    $0x10,%esp
}
8010380d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103810:	5b                   	pop    %ebx
80103811:	5e                   	pop    %esi
80103812:	5d                   	pop    %ebp
80103813:	c3                   	ret    
    panic("sleep");
80103814:	83 ec 0c             	sub    $0xc,%esp
80103817:	68 34 70 10 80       	push   $0x80107034
8010381c:	e8 20 cb ff ff       	call   80100341 <panic>
    panic("sleep without lk");
80103821:	83 ec 0c             	sub    $0xc,%esp
80103824:	68 3a 70 10 80       	push   $0x8010703a
80103829:	e8 13 cb ff ff       	call   80100341 <panic>

8010382e <wait>:
{
8010382e:	55                   	push   %ebp
8010382f:	89 e5                	mov    %esp,%ebp
80103831:	56                   	push   %esi
80103832:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103833:	e8 05 f9 ff ff       	call   8010313d <myproc>
80103838:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
8010383a:	83 ec 0c             	sub    $0xc,%esp
8010383d:	68 20 1d 11 80       	push   $0x80111d20
80103842:	e8 5c 04 00 00       	call   80103ca3 <acquire>
80103847:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010384a:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010384f:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80103854:	eb 68                	jmp    801038be <wait+0x90>
        *status = p->exitcode;
80103856:	8b 53 04             	mov    0x4(%ebx),%edx
80103859:	8b 45 08             	mov    0x8(%ebp),%eax
8010385c:	89 10                	mov    %edx,(%eax)
        pid = p->pid;
8010385e:	8b 73 18             	mov    0x18(%ebx),%esi
        kfree(p->kstack);
80103861:	83 ec 0c             	sub    $0xc,%esp
80103864:	ff 73 10             	push   0x10(%ebx)
80103867:	e8 bc e6 ff ff       	call   80101f28 <kfree>
        p->kstack = 0;
8010386c:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        freevm(p->pgdir, 0); // User zone deleted before
80103873:	83 c4 08             	add    $0x8,%esp
80103876:	6a 00                	push   $0x0
80103878:	ff 73 0c             	push   0xc(%ebx)
8010387b:	e8 35 2e 00 00       	call   801066b5 <freevm>
        p->pid = 0;
80103880:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
        p->parent = 0;
80103887:	c7 43 1c 00 00 00 00 	movl   $0x0,0x1c(%ebx)
        p->name[0] = 0;
8010388e:	c6 43 78 00          	movb   $0x0,0x78(%ebx)
        p->killed = 0;
80103892:	c7 43 30 00 00 00 00 	movl   $0x0,0x30(%ebx)
        p->state = UNUSED;
80103899:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        release(&ptable.lock);
801038a0:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801038a7:	e8 5c 04 00 00       	call   80103d08 <release>
        return pid;
801038ac:	83 c4 10             	add    $0x10,%esp
}
801038af:	89 f0                	mov    %esi,%eax
801038b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038b4:	5b                   	pop    %ebx
801038b5:	5e                   	pop    %esi
801038b6:	5d                   	pop    %ebp
801038b7:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038b8:	81 c3 88 00 00 00    	add    $0x88,%ebx
801038be:	81 fb 54 3f 11 80    	cmp    $0x80113f54,%ebx
801038c4:	73 12                	jae    801038d8 <wait+0xaa>
      if(p->parent != curproc)
801038c6:	39 73 1c             	cmp    %esi,0x1c(%ebx)
801038c9:	75 ed                	jne    801038b8 <wait+0x8a>
      if(p->state == ZOMBIE){
801038cb:	83 7b 14 05          	cmpl   $0x5,0x14(%ebx)
801038cf:	74 85                	je     80103856 <wait+0x28>
      havekids = 1;
801038d1:	b8 01 00 00 00       	mov    $0x1,%eax
801038d6:	eb e0                	jmp    801038b8 <wait+0x8a>
    if(!havekids || curproc->killed){
801038d8:	85 c0                	test   %eax,%eax
801038da:	74 06                	je     801038e2 <wait+0xb4>
801038dc:	83 7e 30 00          	cmpl   $0x0,0x30(%esi)
801038e0:	74 17                	je     801038f9 <wait+0xcb>
      release(&ptable.lock);
801038e2:	83 ec 0c             	sub    $0xc,%esp
801038e5:	68 20 1d 11 80       	push   $0x80111d20
801038ea:	e8 19 04 00 00       	call   80103d08 <release>
      return -1;
801038ef:	83 c4 10             	add    $0x10,%esp
801038f2:	be ff ff ff ff       	mov    $0xffffffff,%esi
801038f7:	eb b6                	jmp    801038af <wait+0x81>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801038f9:	83 ec 08             	sub    $0x8,%esp
801038fc:	68 20 1d 11 80       	push   $0x80111d20
80103901:	56                   	push   %esi
80103902:	e8 96 fe ff ff       	call   8010379d <sleep>
    havekids = 0;
80103907:	83 c4 10             	add    $0x10,%esp
8010390a:	e9 3b ff ff ff       	jmp    8010384a <wait+0x1c>

8010390f <wakeup>:


// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010390f:	55                   	push   %ebp
80103910:	89 e5                	mov    %esp,%ebp
80103912:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103915:	68 20 1d 11 80       	push   $0x80111d20
8010391a:	e8 84 03 00 00       	call   80103ca3 <acquire>
  wakeup1(chan);
8010391f:	8b 45 08             	mov    0x8(%ebp),%eax
80103922:	e8 33 f6 ff ff       	call   80102f5a <wakeup1>
  release(&ptable.lock);
80103927:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010392e:	e8 d5 03 00 00       	call   80103d08 <release>
}
80103933:	83 c4 10             	add    $0x10,%esp
80103936:	c9                   	leave  
80103937:	c3                   	ret    

80103938 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103938:	55                   	push   %ebp
80103939:	89 e5                	mov    %esp,%ebp
8010393b:	53                   	push   %ebx
8010393c:	83 ec 10             	sub    $0x10,%esp
8010393f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103942:	68 20 1d 11 80       	push   $0x80111d20
80103947:	e8 57 03 00 00       	call   80103ca3 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010394c:	83 c4 10             	add    $0x10,%esp
8010394f:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
80103954:	eb 0e                	jmp    80103964 <kill+0x2c>
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
80103956:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)
8010395d:	eb 1e                	jmp    8010397d <kill+0x45>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010395f:	05 88 00 00 00       	add    $0x88,%eax
80103964:	3d 54 3f 11 80       	cmp    $0x80113f54,%eax
80103969:	73 2c                	jae    80103997 <kill+0x5f>
    if(p->pid == pid){
8010396b:	39 58 18             	cmp    %ebx,0x18(%eax)
8010396e:	75 ef                	jne    8010395f <kill+0x27>
      p->killed = 1;
80103970:	c7 40 30 01 00 00 00 	movl   $0x1,0x30(%eax)
      if(p->state == SLEEPING)
80103977:	83 78 14 02          	cmpl   $0x2,0x14(%eax)
8010397b:	74 d9                	je     80103956 <kill+0x1e>
      release(&ptable.lock);
8010397d:	83 ec 0c             	sub    $0xc,%esp
80103980:	68 20 1d 11 80       	push   $0x80111d20
80103985:	e8 7e 03 00 00       	call   80103d08 <release>
      return 0;
8010398a:	83 c4 10             	add    $0x10,%esp
8010398d:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103992:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103995:	c9                   	leave  
80103996:	c3                   	ret    
  release(&ptable.lock);
80103997:	83 ec 0c             	sub    $0xc,%esp
8010399a:	68 20 1d 11 80       	push   $0x80111d20
8010399f:	e8 64 03 00 00       	call   80103d08 <release>
  return -1;
801039a4:	83 c4 10             	add    $0x10,%esp
801039a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801039ac:	eb e4                	jmp    80103992 <kill+0x5a>

801039ae <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801039ae:	55                   	push   %ebp
801039af:	89 e5                	mov    %esp,%ebp
801039b1:	56                   	push   %esi
801039b2:	53                   	push   %ebx
801039b3:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039b6:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
801039bb:	eb 36                	jmp    801039f3 <procdump+0x45>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
801039bd:	b8 4b 70 10 80       	mov    $0x8010704b,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
801039c2:	8d 53 78             	lea    0x78(%ebx),%edx
801039c5:	52                   	push   %edx
801039c6:	50                   	push   %eax
801039c7:	ff 73 18             	push   0x18(%ebx)
801039ca:	68 4f 70 10 80       	push   $0x8010704f
801039cf:	e8 06 cc ff ff       	call   801005da <cprintf>
    if(p->state == SLEEPING){
801039d4:	83 c4 10             	add    $0x10,%esp
801039d7:	83 7b 14 02          	cmpl   $0x2,0x14(%ebx)
801039db:	74 3c                	je     80103a19 <procdump+0x6b>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801039dd:	83 ec 0c             	sub    $0xc,%esp
801039e0:	68 6b 74 10 80       	push   $0x8010746b
801039e5:	e8 f0 cb ff ff       	call   801005da <cprintf>
801039ea:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039ed:	81 c3 88 00 00 00    	add    $0x88,%ebx
801039f3:	81 fb 54 3f 11 80    	cmp    $0x80113f54,%ebx
801039f9:	73 5f                	jae    80103a5a <procdump+0xac>
    if(p->state == UNUSED)
801039fb:	8b 43 14             	mov    0x14(%ebx),%eax
801039fe:	85 c0                	test   %eax,%eax
80103a00:	74 eb                	je     801039ed <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103a02:	83 f8 05             	cmp    $0x5,%eax
80103a05:	77 b6                	ja     801039bd <procdump+0xf>
80103a07:	8b 04 85 ac 70 10 80 	mov    -0x7fef8f54(,%eax,4),%eax
80103a0e:	85 c0                	test   %eax,%eax
80103a10:	75 b0                	jne    801039c2 <procdump+0x14>
      state = "???";
80103a12:	b8 4b 70 10 80       	mov    $0x8010704b,%eax
80103a17:	eb a9                	jmp    801039c2 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103a19:	8b 43 28             	mov    0x28(%ebx),%eax
80103a1c:	8b 40 0c             	mov    0xc(%eax),%eax
80103a1f:	83 c0 08             	add    $0x8,%eax
80103a22:	83 ec 08             	sub    $0x8,%esp
80103a25:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103a28:	52                   	push   %edx
80103a29:	50                   	push   %eax
80103a2a:	e8 58 01 00 00       	call   80103b87 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103a2f:	83 c4 10             	add    $0x10,%esp
80103a32:	be 00 00 00 00       	mov    $0x0,%esi
80103a37:	eb 12                	jmp    80103a4b <procdump+0x9d>
        cprintf(" %p", pc[i]);
80103a39:	83 ec 08             	sub    $0x8,%esp
80103a3c:	50                   	push   %eax
80103a3d:	68 a1 6a 10 80       	push   $0x80106aa1
80103a42:	e8 93 cb ff ff       	call   801005da <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103a47:	46                   	inc    %esi
80103a48:	83 c4 10             	add    $0x10,%esp
80103a4b:	83 fe 09             	cmp    $0x9,%esi
80103a4e:	7f 8d                	jg     801039dd <procdump+0x2f>
80103a50:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103a54:	85 c0                	test   %eax,%eax
80103a56:	75 e1                	jne    80103a39 <procdump+0x8b>
80103a58:	eb 83                	jmp    801039dd <procdump+0x2f>
  }
}
80103a5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a5d:	5b                   	pop    %ebx
80103a5e:	5e                   	pop    %esi
80103a5f:	5d                   	pop    %ebp
80103a60:	c3                   	ret    

80103a61 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103a61:	55                   	push   %ebp
80103a62:	89 e5                	mov    %esp,%ebp
80103a64:	53                   	push   %ebx
80103a65:	83 ec 0c             	sub    $0xc,%esp
80103a68:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103a6b:	68 c4 70 10 80       	push   $0x801070c4
80103a70:	8d 43 04             	lea    0x4(%ebx),%eax
80103a73:	50                   	push   %eax
80103a74:	e8 f3 00 00 00       	call   80103b6c <initlock>
  lk->name = name;
80103a79:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a7c:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103a7f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103a85:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103a8c:	83 c4 10             	add    $0x10,%esp
80103a8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a92:	c9                   	leave  
80103a93:	c3                   	ret    

80103a94 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103a94:	55                   	push   %ebp
80103a95:	89 e5                	mov    %esp,%ebp
80103a97:	56                   	push   %esi
80103a98:	53                   	push   %ebx
80103a99:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103a9c:	8d 73 04             	lea    0x4(%ebx),%esi
80103a9f:	83 ec 0c             	sub    $0xc,%esp
80103aa2:	56                   	push   %esi
80103aa3:	e8 fb 01 00 00       	call   80103ca3 <acquire>
  while (lk->locked) {
80103aa8:	83 c4 10             	add    $0x10,%esp
80103aab:	eb 0d                	jmp    80103aba <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103aad:	83 ec 08             	sub    $0x8,%esp
80103ab0:	56                   	push   %esi
80103ab1:	53                   	push   %ebx
80103ab2:	e8 e6 fc ff ff       	call   8010379d <sleep>
80103ab7:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103aba:	83 3b 00             	cmpl   $0x0,(%ebx)
80103abd:	75 ee                	jne    80103aad <acquiresleep+0x19>
  }
  lk->locked = 1;
80103abf:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103ac5:	e8 73 f6 ff ff       	call   8010313d <myproc>
80103aca:	8b 40 18             	mov    0x18(%eax),%eax
80103acd:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103ad0:	83 ec 0c             	sub    $0xc,%esp
80103ad3:	56                   	push   %esi
80103ad4:	e8 2f 02 00 00       	call   80103d08 <release>
}
80103ad9:	83 c4 10             	add    $0x10,%esp
80103adc:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103adf:	5b                   	pop    %ebx
80103ae0:	5e                   	pop    %esi
80103ae1:	5d                   	pop    %ebp
80103ae2:	c3                   	ret    

80103ae3 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103ae3:	55                   	push   %ebp
80103ae4:	89 e5                	mov    %esp,%ebp
80103ae6:	56                   	push   %esi
80103ae7:	53                   	push   %ebx
80103ae8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103aeb:	8d 73 04             	lea    0x4(%ebx),%esi
80103aee:	83 ec 0c             	sub    $0xc,%esp
80103af1:	56                   	push   %esi
80103af2:	e8 ac 01 00 00       	call   80103ca3 <acquire>
  lk->locked = 0;
80103af7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103afd:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103b04:	89 1c 24             	mov    %ebx,(%esp)
80103b07:	e8 03 fe ff ff       	call   8010390f <wakeup>
  release(&lk->lk);
80103b0c:	89 34 24             	mov    %esi,(%esp)
80103b0f:	e8 f4 01 00 00       	call   80103d08 <release>
}
80103b14:	83 c4 10             	add    $0x10,%esp
80103b17:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b1a:	5b                   	pop    %ebx
80103b1b:	5e                   	pop    %esi
80103b1c:	5d                   	pop    %ebp
80103b1d:	c3                   	ret    

80103b1e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103b1e:	55                   	push   %ebp
80103b1f:	89 e5                	mov    %esp,%ebp
80103b21:	56                   	push   %esi
80103b22:	53                   	push   %ebx
80103b23:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103b26:	8d 73 04             	lea    0x4(%ebx),%esi
80103b29:	83 ec 0c             	sub    $0xc,%esp
80103b2c:	56                   	push   %esi
80103b2d:	e8 71 01 00 00       	call   80103ca3 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103b32:	83 c4 10             	add    $0x10,%esp
80103b35:	83 3b 00             	cmpl   $0x0,(%ebx)
80103b38:	75 17                	jne    80103b51 <holdingsleep+0x33>
80103b3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103b3f:	83 ec 0c             	sub    $0xc,%esp
80103b42:	56                   	push   %esi
80103b43:	e8 c0 01 00 00       	call   80103d08 <release>
  return r;
}
80103b48:	89 d8                	mov    %ebx,%eax
80103b4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b4d:	5b                   	pop    %ebx
80103b4e:	5e                   	pop    %esi
80103b4f:	5d                   	pop    %ebp
80103b50:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103b51:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103b54:	e8 e4 f5 ff ff       	call   8010313d <myproc>
80103b59:	3b 58 18             	cmp    0x18(%eax),%ebx
80103b5c:	74 07                	je     80103b65 <holdingsleep+0x47>
80103b5e:	bb 00 00 00 00       	mov    $0x0,%ebx
80103b63:	eb da                	jmp    80103b3f <holdingsleep+0x21>
80103b65:	bb 01 00 00 00       	mov    $0x1,%ebx
80103b6a:	eb d3                	jmp    80103b3f <holdingsleep+0x21>

80103b6c <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103b6c:	55                   	push   %ebp
80103b6d:	89 e5                	mov    %esp,%ebp
80103b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103b72:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b75:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103b78:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103b7e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103b85:	5d                   	pop    %ebp
80103b86:	c3                   	ret    

80103b87 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103b87:	55                   	push   %ebp
80103b88:	89 e5                	mov    %esp,%ebp
80103b8a:	53                   	push   %ebx
80103b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103b8e:	8b 45 08             	mov    0x8(%ebp),%eax
80103b91:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103b94:	b8 00 00 00 00       	mov    $0x0,%eax
80103b99:	83 f8 09             	cmp    $0x9,%eax
80103b9c:	7f 21                	jg     80103bbf <getcallerpcs+0x38>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103b9e:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103ba4:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103baa:	77 13                	ja     80103bbf <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103bac:	8b 5a 04             	mov    0x4(%edx),%ebx
80103baf:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103bb2:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103bb4:	40                   	inc    %eax
80103bb5:	eb e2                	jmp    80103b99 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103bb7:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103bbe:	40                   	inc    %eax
80103bbf:	83 f8 09             	cmp    $0x9,%eax
80103bc2:	7e f3                	jle    80103bb7 <getcallerpcs+0x30>
}
80103bc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103bc7:	c9                   	leave  
80103bc8:	c3                   	ret    

80103bc9 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103bc9:	55                   	push   %ebp
80103bca:	89 e5                	mov    %esp,%ebp
80103bcc:	53                   	push   %ebx
80103bcd:	83 ec 04             	sub    $0x4,%esp
80103bd0:	9c                   	pushf  
80103bd1:	5b                   	pop    %ebx
  asm volatile("cli");
80103bd2:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103bd3:	e8 d0 f4 ff ff       	call   801030a8 <mycpu>
80103bd8:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103bdf:	74 10                	je     80103bf1 <pushcli+0x28>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103be1:	e8 c2 f4 ff ff       	call   801030a8 <mycpu>
80103be6:	ff 80 a4 00 00 00    	incl   0xa4(%eax)
}
80103bec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103bef:	c9                   	leave  
80103bf0:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103bf1:	e8 b2 f4 ff ff       	call   801030a8 <mycpu>
80103bf6:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103bfc:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103c02:	eb dd                	jmp    80103be1 <pushcli+0x18>

80103c04 <popcli>:

void
popcli(void)
{
80103c04:	55                   	push   %ebp
80103c05:	89 e5                	mov    %esp,%ebp
80103c07:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103c0a:	9c                   	pushf  
80103c0b:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103c0c:	f6 c4 02             	test   $0x2,%ah
80103c0f:	75 28                	jne    80103c39 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103c11:	e8 92 f4 ff ff       	call   801030a8 <mycpu>
80103c16:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103c1c:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103c1f:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103c25:	85 d2                	test   %edx,%edx
80103c27:	78 1d                	js     80103c46 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103c29:	e8 7a f4 ff ff       	call   801030a8 <mycpu>
80103c2e:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103c35:	74 1c                	je     80103c53 <popcli+0x4f>
    sti();
}
80103c37:	c9                   	leave  
80103c38:	c3                   	ret    
    panic("popcli - interruptible");
80103c39:	83 ec 0c             	sub    $0xc,%esp
80103c3c:	68 cf 70 10 80       	push   $0x801070cf
80103c41:	e8 fb c6 ff ff       	call   80100341 <panic>
    panic("popcli");
80103c46:	83 ec 0c             	sub    $0xc,%esp
80103c49:	68 e6 70 10 80       	push   $0x801070e6
80103c4e:	e8 ee c6 ff ff       	call   80100341 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103c53:	e8 50 f4 ff ff       	call   801030a8 <mycpu>
80103c58:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103c5f:	74 d6                	je     80103c37 <popcli+0x33>
  asm volatile("sti");
80103c61:	fb                   	sti    
}
80103c62:	eb d3                	jmp    80103c37 <popcli+0x33>

80103c64 <holding>:
{
80103c64:	55                   	push   %ebp
80103c65:	89 e5                	mov    %esp,%ebp
80103c67:	53                   	push   %ebx
80103c68:	83 ec 04             	sub    $0x4,%esp
80103c6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103c6e:	e8 56 ff ff ff       	call   80103bc9 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103c73:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c76:	75 11                	jne    80103c89 <holding+0x25>
80103c78:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103c7d:	e8 82 ff ff ff       	call   80103c04 <popcli>
}
80103c82:	89 d8                	mov    %ebx,%eax
80103c84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c87:	c9                   	leave  
80103c88:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103c89:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103c8c:	e8 17 f4 ff ff       	call   801030a8 <mycpu>
80103c91:	39 c3                	cmp    %eax,%ebx
80103c93:	74 07                	je     80103c9c <holding+0x38>
80103c95:	bb 00 00 00 00       	mov    $0x0,%ebx
80103c9a:	eb e1                	jmp    80103c7d <holding+0x19>
80103c9c:	bb 01 00 00 00       	mov    $0x1,%ebx
80103ca1:	eb da                	jmp    80103c7d <holding+0x19>

80103ca3 <acquire>:
{
80103ca3:	55                   	push   %ebp
80103ca4:	89 e5                	mov    %esp,%ebp
80103ca6:	53                   	push   %ebx
80103ca7:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103caa:	e8 1a ff ff ff       	call   80103bc9 <pushcli>
  if(holding(lk))
80103caf:	83 ec 0c             	sub    $0xc,%esp
80103cb2:	ff 75 08             	push   0x8(%ebp)
80103cb5:	e8 aa ff ff ff       	call   80103c64 <holding>
80103cba:	83 c4 10             	add    $0x10,%esp
80103cbd:	85 c0                	test   %eax,%eax
80103cbf:	75 3a                	jne    80103cfb <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103cc1:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103cc4:	b8 01 00 00 00       	mov    $0x1,%eax
80103cc9:	f0 87 02             	lock xchg %eax,(%edx)
80103ccc:	85 c0                	test   %eax,%eax
80103cce:	75 f1                	jne    80103cc1 <acquire+0x1e>
  __sync_synchronize();
80103cd0:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103cd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103cd8:	e8 cb f3 ff ff       	call   801030a8 <mycpu>
80103cdd:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ce3:	83 c0 0c             	add    $0xc,%eax
80103ce6:	83 ec 08             	sub    $0x8,%esp
80103ce9:	50                   	push   %eax
80103cea:	8d 45 08             	lea    0x8(%ebp),%eax
80103ced:	50                   	push   %eax
80103cee:	e8 94 fe ff ff       	call   80103b87 <getcallerpcs>
}
80103cf3:	83 c4 10             	add    $0x10,%esp
80103cf6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103cf9:	c9                   	leave  
80103cfa:	c3                   	ret    
    panic("acquire");
80103cfb:	83 ec 0c             	sub    $0xc,%esp
80103cfe:	68 ed 70 10 80       	push   $0x801070ed
80103d03:	e8 39 c6 ff ff       	call   80100341 <panic>

80103d08 <release>:
{
80103d08:	55                   	push   %ebp
80103d09:	89 e5                	mov    %esp,%ebp
80103d0b:	53                   	push   %ebx
80103d0c:	83 ec 10             	sub    $0x10,%esp
80103d0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103d12:	53                   	push   %ebx
80103d13:	e8 4c ff ff ff       	call   80103c64 <holding>
80103d18:	83 c4 10             	add    $0x10,%esp
80103d1b:	85 c0                	test   %eax,%eax
80103d1d:	74 23                	je     80103d42 <release+0x3a>
  lk->pcs[0] = 0;
80103d1f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103d26:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103d2d:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103d32:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103d38:	e8 c7 fe ff ff       	call   80103c04 <popcli>
}
80103d3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d40:	c9                   	leave  
80103d41:	c3                   	ret    
    panic("release");
80103d42:	83 ec 0c             	sub    $0xc,%esp
80103d45:	68 f5 70 10 80       	push   $0x801070f5
80103d4a:	e8 f2 c5 ff ff       	call   80100341 <panic>

80103d4f <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103d4f:	55                   	push   %ebp
80103d50:	89 e5                	mov    %esp,%ebp
80103d52:	57                   	push   %edi
80103d53:	53                   	push   %ebx
80103d54:	8b 55 08             	mov    0x8(%ebp),%edx
80103d57:	8b 45 0c             	mov    0xc(%ebp),%eax
  if ((int)dst%4 == 0 && n%4 == 0){
80103d5a:	f6 c2 03             	test   $0x3,%dl
80103d5d:	75 29                	jne    80103d88 <memset+0x39>
80103d5f:	f6 45 10 03          	testb  $0x3,0x10(%ebp)
80103d63:	75 23                	jne    80103d88 <memset+0x39>
    c &= 0xFF;
80103d65:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103d68:	8b 4d 10             	mov    0x10(%ebp),%ecx
80103d6b:	c1 e9 02             	shr    $0x2,%ecx
80103d6e:	c1 e0 18             	shl    $0x18,%eax
80103d71:	89 fb                	mov    %edi,%ebx
80103d73:	c1 e3 10             	shl    $0x10,%ebx
80103d76:	09 d8                	or     %ebx,%eax
80103d78:	89 fb                	mov    %edi,%ebx
80103d7a:	c1 e3 08             	shl    $0x8,%ebx
80103d7d:	09 d8                	or     %ebx,%eax
80103d7f:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103d81:	89 d7                	mov    %edx,%edi
80103d83:	fc                   	cld    
80103d84:	f3 ab                	rep stos %eax,%es:(%edi)
}
80103d86:	eb 08                	jmp    80103d90 <memset+0x41>
  asm volatile("cld; rep stosb" :
80103d88:	89 d7                	mov    %edx,%edi
80103d8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
80103d8d:	fc                   	cld    
80103d8e:	f3 aa                	rep stos %al,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80103d90:	89 d0                	mov    %edx,%eax
80103d92:	5b                   	pop    %ebx
80103d93:	5f                   	pop    %edi
80103d94:	5d                   	pop    %ebp
80103d95:	c3                   	ret    

80103d96 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103d96:	55                   	push   %ebp
80103d97:	89 e5                	mov    %esp,%ebp
80103d99:	56                   	push   %esi
80103d9a:	53                   	push   %ebx
80103d9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103d9e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103da1:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103da4:	eb 04                	jmp    80103daa <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80103da6:	41                   	inc    %ecx
80103da7:	42                   	inc    %edx
  while(n-- > 0){
80103da8:	89 f0                	mov    %esi,%eax
80103daa:	8d 70 ff             	lea    -0x1(%eax),%esi
80103dad:	85 c0                	test   %eax,%eax
80103daf:	74 10                	je     80103dc1 <memcmp+0x2b>
    if(*s1 != *s2)
80103db1:	8a 01                	mov    (%ecx),%al
80103db3:	8a 1a                	mov    (%edx),%bl
80103db5:	38 d8                	cmp    %bl,%al
80103db7:	74 ed                	je     80103da6 <memcmp+0x10>
      return *s1 - *s2;
80103db9:	0f b6 c0             	movzbl %al,%eax
80103dbc:	0f b6 db             	movzbl %bl,%ebx
80103dbf:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103dc1:	5b                   	pop    %ebx
80103dc2:	5e                   	pop    %esi
80103dc3:	5d                   	pop    %ebp
80103dc4:	c3                   	ret    

80103dc5 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103dc5:	55                   	push   %ebp
80103dc6:	89 e5                	mov    %esp,%ebp
80103dc8:	56                   	push   %esi
80103dc9:	53                   	push   %ebx
80103dca:	8b 75 08             	mov    0x8(%ebp),%esi
80103dcd:	8b 55 0c             	mov    0xc(%ebp),%edx
80103dd0:	8b 45 10             	mov    0x10(%ebp),%eax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103dd3:	39 f2                	cmp    %esi,%edx
80103dd5:	73 36                	jae    80103e0d <memmove+0x48>
80103dd7:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80103dda:	39 f1                	cmp    %esi,%ecx
80103ddc:	76 33                	jbe    80103e11 <memmove+0x4c>
    s += n;
    d += n;
80103dde:	8d 14 06             	lea    (%esi,%eax,1),%edx
    while(n-- > 0)
80103de1:	eb 08                	jmp    80103deb <memmove+0x26>
      *--d = *--s;
80103de3:	49                   	dec    %ecx
80103de4:	4a                   	dec    %edx
80103de5:	8a 01                	mov    (%ecx),%al
80103de7:	88 02                	mov    %al,(%edx)
    while(n-- > 0)
80103de9:	89 d8                	mov    %ebx,%eax
80103deb:	8d 58 ff             	lea    -0x1(%eax),%ebx
80103dee:	85 c0                	test   %eax,%eax
80103df0:	75 f1                	jne    80103de3 <memmove+0x1e>
80103df2:	eb 13                	jmp    80103e07 <memmove+0x42>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103df4:	8a 02                	mov    (%edx),%al
80103df6:	88 01                	mov    %al,(%ecx)
80103df8:	8d 49 01             	lea    0x1(%ecx),%ecx
80103dfb:	8d 52 01             	lea    0x1(%edx),%edx
    while(n-- > 0)
80103dfe:	89 d8                	mov    %ebx,%eax
80103e00:	8d 58 ff             	lea    -0x1(%eax),%ebx
80103e03:	85 c0                	test   %eax,%eax
80103e05:	75 ed                	jne    80103df4 <memmove+0x2f>

  return dst;
}
80103e07:	89 f0                	mov    %esi,%eax
80103e09:	5b                   	pop    %ebx
80103e0a:	5e                   	pop    %esi
80103e0b:	5d                   	pop    %ebp
80103e0c:	c3                   	ret    
80103e0d:	89 f1                	mov    %esi,%ecx
80103e0f:	eb ef                	jmp    80103e00 <memmove+0x3b>
80103e11:	89 f1                	mov    %esi,%ecx
80103e13:	eb eb                	jmp    80103e00 <memmove+0x3b>

80103e15 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103e15:	55                   	push   %ebp
80103e16:	89 e5                	mov    %esp,%ebp
80103e18:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80103e1b:	ff 75 10             	push   0x10(%ebp)
80103e1e:	ff 75 0c             	push   0xc(%ebp)
80103e21:	ff 75 08             	push   0x8(%ebp)
80103e24:	e8 9c ff ff ff       	call   80103dc5 <memmove>
}
80103e29:	c9                   	leave  
80103e2a:	c3                   	ret    

80103e2b <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103e2b:	55                   	push   %ebp
80103e2c:	89 e5                	mov    %esp,%ebp
80103e2e:	53                   	push   %ebx
80103e2f:	8b 55 08             	mov    0x8(%ebp),%edx
80103e32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103e35:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103e38:	eb 03                	jmp    80103e3d <strncmp+0x12>
    n--, p++, q++;
80103e3a:	48                   	dec    %eax
80103e3b:	42                   	inc    %edx
80103e3c:	41                   	inc    %ecx
  while(n > 0 && *p && *p == *q)
80103e3d:	85 c0                	test   %eax,%eax
80103e3f:	74 0a                	je     80103e4b <strncmp+0x20>
80103e41:	8a 1a                	mov    (%edx),%bl
80103e43:	84 db                	test   %bl,%bl
80103e45:	74 04                	je     80103e4b <strncmp+0x20>
80103e47:	3a 19                	cmp    (%ecx),%bl
80103e49:	74 ef                	je     80103e3a <strncmp+0xf>
  if(n == 0)
80103e4b:	85 c0                	test   %eax,%eax
80103e4d:	74 0d                	je     80103e5c <strncmp+0x31>
    return 0;
  return (uchar)*p - (uchar)*q;
80103e4f:	0f b6 02             	movzbl (%edx),%eax
80103e52:	0f b6 11             	movzbl (%ecx),%edx
80103e55:	29 d0                	sub    %edx,%eax
}
80103e57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103e5a:	c9                   	leave  
80103e5b:	c3                   	ret    
    return 0;
80103e5c:	b8 00 00 00 00       	mov    $0x0,%eax
80103e61:	eb f4                	jmp    80103e57 <strncmp+0x2c>

80103e63 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103e63:	55                   	push   %ebp
80103e64:	89 e5                	mov    %esp,%ebp
80103e66:	57                   	push   %edi
80103e67:	56                   	push   %esi
80103e68:	53                   	push   %ebx
80103e69:	8b 45 08             	mov    0x8(%ebp),%eax
80103e6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103e6f:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103e72:	89 c1                	mov    %eax,%ecx
80103e74:	eb 04                	jmp    80103e7a <strncpy+0x17>
80103e76:	89 fb                	mov    %edi,%ebx
80103e78:	89 f1                	mov    %esi,%ecx
80103e7a:	89 d6                	mov    %edx,%esi
80103e7c:	4a                   	dec    %edx
80103e7d:	85 f6                	test   %esi,%esi
80103e7f:	7e 10                	jle    80103e91 <strncpy+0x2e>
80103e81:	8d 7b 01             	lea    0x1(%ebx),%edi
80103e84:	8d 71 01             	lea    0x1(%ecx),%esi
80103e87:	8a 1b                	mov    (%ebx),%bl
80103e89:	88 19                	mov    %bl,(%ecx)
80103e8b:	84 db                	test   %bl,%bl
80103e8d:	75 e7                	jne    80103e76 <strncpy+0x13>
80103e8f:	89 f1                	mov    %esi,%ecx
    ;
  while(n-- > 0)
80103e91:	8d 5a ff             	lea    -0x1(%edx),%ebx
80103e94:	85 d2                	test   %edx,%edx
80103e96:	7e 0a                	jle    80103ea2 <strncpy+0x3f>
    *s++ = 0;
80103e98:	c6 01 00             	movb   $0x0,(%ecx)
  while(n-- > 0)
80103e9b:	89 da                	mov    %ebx,%edx
    *s++ = 0;
80103e9d:	8d 49 01             	lea    0x1(%ecx),%ecx
80103ea0:	eb ef                	jmp    80103e91 <strncpy+0x2e>
  return os;
}
80103ea2:	5b                   	pop    %ebx
80103ea3:	5e                   	pop    %esi
80103ea4:	5f                   	pop    %edi
80103ea5:	5d                   	pop    %ebp
80103ea6:	c3                   	ret    

80103ea7 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103ea7:	55                   	push   %ebp
80103ea8:	89 e5                	mov    %esp,%ebp
80103eaa:	57                   	push   %edi
80103eab:	56                   	push   %esi
80103eac:	53                   	push   %ebx
80103ead:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103eb3:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103eb6:	85 d2                	test   %edx,%edx
80103eb8:	7e 20                	jle    80103eda <safestrcpy+0x33>
80103eba:	89 c1                	mov    %eax,%ecx
80103ebc:	eb 04                	jmp    80103ec2 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103ebe:	89 fb                	mov    %edi,%ebx
80103ec0:	89 f1                	mov    %esi,%ecx
80103ec2:	4a                   	dec    %edx
80103ec3:	85 d2                	test   %edx,%edx
80103ec5:	7e 10                	jle    80103ed7 <safestrcpy+0x30>
80103ec7:	8d 7b 01             	lea    0x1(%ebx),%edi
80103eca:	8d 71 01             	lea    0x1(%ecx),%esi
80103ecd:	8a 1b                	mov    (%ebx),%bl
80103ecf:	88 19                	mov    %bl,(%ecx)
80103ed1:	84 db                	test   %bl,%bl
80103ed3:	75 e9                	jne    80103ebe <safestrcpy+0x17>
80103ed5:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103ed7:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103eda:	5b                   	pop    %ebx
80103edb:	5e                   	pop    %esi
80103edc:	5f                   	pop    %edi
80103edd:	5d                   	pop    %ebp
80103ede:	c3                   	ret    

80103edf <strlen>:

int
strlen(const char *s)
{
80103edf:	55                   	push   %ebp
80103ee0:	89 e5                	mov    %esp,%ebp
80103ee2:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103ee5:	b8 00 00 00 00       	mov    $0x0,%eax
80103eea:	eb 01                	jmp    80103eed <strlen+0xe>
80103eec:	40                   	inc    %eax
80103eed:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103ef1:	75 f9                	jne    80103eec <strlen+0xd>
    ;
  return n;
}
80103ef3:	5d                   	pop    %ebp
80103ef4:	c3                   	ret    

80103ef5 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103ef5:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103ef9:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103efd:	55                   	push   %ebp
  pushl %ebx
80103efe:	53                   	push   %ebx
  pushl %esi
80103eff:	56                   	push   %esi
  pushl %edi
80103f00:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103f01:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103f03:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103f05:	5f                   	pop    %edi
  popl %esi
80103f06:	5e                   	pop    %esi
  popl %ebx
80103f07:	5b                   	pop    %ebx
  popl %ebp
80103f08:	5d                   	pop    %ebp
  ret
80103f09:	c3                   	ret    

80103f0a <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103f0a:	55                   	push   %ebp
80103f0b:	89 e5                	mov    %esp,%ebp
80103f0d:	53                   	push   %ebx
80103f0e:	83 ec 04             	sub    $0x4,%esp
80103f11:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103f14:	e8 24 f2 ff ff       	call   8010313d <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103f19:	8b 40 08             	mov    0x8(%eax),%eax
80103f1c:	39 d8                	cmp    %ebx,%eax
80103f1e:	76 18                	jbe    80103f38 <fetchint+0x2e>
80103f20:	8d 53 04             	lea    0x4(%ebx),%edx
80103f23:	39 d0                	cmp    %edx,%eax
80103f25:	72 18                	jb     80103f3f <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103f27:	8b 13                	mov    (%ebx),%edx
80103f29:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f2c:	89 10                	mov    %edx,(%eax)
  return 0;
80103f2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103f36:	c9                   	leave  
80103f37:	c3                   	ret    
    return -1;
80103f38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f3d:	eb f4                	jmp    80103f33 <fetchint+0x29>
80103f3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f44:	eb ed                	jmp    80103f33 <fetchint+0x29>

80103f46 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80103f46:	55                   	push   %ebp
80103f47:	89 e5                	mov    %esp,%ebp
80103f49:	53                   	push   %ebx
80103f4a:	83 ec 04             	sub    $0x4,%esp
80103f4d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103f50:	e8 e8 f1 ff ff       	call   8010313d <myproc>

  if(addr >= curproc->sz)
80103f55:	39 58 08             	cmp    %ebx,0x8(%eax)
80103f58:	76 24                	jbe    80103f7e <fetchstr+0x38>
    return -1;
  *pp = (char*)addr;
80103f5a:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f5d:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80103f5f:	8b 50 08             	mov    0x8(%eax),%edx
  for(s = *pp; s < ep; s++){
80103f62:	89 d8                	mov    %ebx,%eax
80103f64:	eb 01                	jmp    80103f67 <fetchstr+0x21>
80103f66:	40                   	inc    %eax
80103f67:	39 d0                	cmp    %edx,%eax
80103f69:	73 09                	jae    80103f74 <fetchstr+0x2e>
    if(*s == 0)
80103f6b:	80 38 00             	cmpb   $0x0,(%eax)
80103f6e:	75 f6                	jne    80103f66 <fetchstr+0x20>
      return s - *pp;
80103f70:	29 d8                	sub    %ebx,%eax
80103f72:	eb 05                	jmp    80103f79 <fetchstr+0x33>
  }
  return -1;
80103f74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103f7c:	c9                   	leave  
80103f7d:	c3                   	ret    
    return -1;
80103f7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f83:	eb f4                	jmp    80103f79 <fetchstr+0x33>

80103f85 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80103f85:	55                   	push   %ebp
80103f86:	89 e5                	mov    %esp,%ebp
80103f88:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80103f8b:	e8 ad f1 ff ff       	call   8010313d <myproc>
80103f90:	8b 50 20             	mov    0x20(%eax),%edx
80103f93:	8b 45 08             	mov    0x8(%ebp),%eax
80103f96:	c1 e0 02             	shl    $0x2,%eax
80103f99:	03 42 44             	add    0x44(%edx),%eax
80103f9c:	83 ec 08             	sub    $0x8,%esp
80103f9f:	ff 75 0c             	push   0xc(%ebp)
80103fa2:	83 c0 04             	add    $0x4,%eax
80103fa5:	50                   	push   %eax
80103fa6:	e8 5f ff ff ff       	call   80103f0a <fetchint>
}
80103fab:	c9                   	leave  
80103fac:	c3                   	ret    

80103fad <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, void **pp, int size)
{
80103fad:	55                   	push   %ebp
80103fae:	89 e5                	mov    %esp,%ebp
80103fb0:	56                   	push   %esi
80103fb1:	53                   	push   %ebx
80103fb2:	83 ec 10             	sub    $0x10,%esp
80103fb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80103fb8:	e8 80 f1 ff ff       	call   8010313d <myproc>
80103fbd:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80103fbf:	83 ec 08             	sub    $0x8,%esp
80103fc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103fc5:	50                   	push   %eax
80103fc6:	ff 75 08             	push   0x8(%ebp)
80103fc9:	e8 b7 ff ff ff       	call   80103f85 <argint>
80103fce:	83 c4 10             	add    $0x10,%esp
80103fd1:	85 c0                	test   %eax,%eax
80103fd3:	78 25                	js     80103ffa <argptr+0x4d>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80103fd5:	85 db                	test   %ebx,%ebx
80103fd7:	78 28                	js     80104001 <argptr+0x54>
80103fd9:	8b 56 08             	mov    0x8(%esi),%edx
80103fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fdf:	39 c2                	cmp    %eax,%edx
80103fe1:	76 25                	jbe    80104008 <argptr+0x5b>
80103fe3:	01 c3                	add    %eax,%ebx
80103fe5:	39 da                	cmp    %ebx,%edx
80103fe7:	72 26                	jb     8010400f <argptr+0x62>
    return -1;
  *pp = (void*)i;
80103fe9:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fec:	89 02                	mov    %eax,(%edx)
  return 0;
80103fee:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ff3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ff6:	5b                   	pop    %ebx
80103ff7:	5e                   	pop    %esi
80103ff8:	5d                   	pop    %ebp
80103ff9:	c3                   	ret    
    return -1;
80103ffa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fff:	eb f2                	jmp    80103ff3 <argptr+0x46>
    return -1;
80104001:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104006:	eb eb                	jmp    80103ff3 <argptr+0x46>
80104008:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010400d:	eb e4                	jmp    80103ff3 <argptr+0x46>
8010400f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104014:	eb dd                	jmp    80103ff3 <argptr+0x46>

80104016 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104016:	55                   	push   %ebp
80104017:	89 e5                	mov    %esp,%ebp
80104019:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010401c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010401f:	50                   	push   %eax
80104020:	ff 75 08             	push   0x8(%ebp)
80104023:	e8 5d ff ff ff       	call   80103f85 <argint>
80104028:	83 c4 10             	add    $0x10,%esp
8010402b:	85 c0                	test   %eax,%eax
8010402d:	78 13                	js     80104042 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
8010402f:	83 ec 08             	sub    $0x8,%esp
80104032:	ff 75 0c             	push   0xc(%ebp)
80104035:	ff 75 f4             	push   -0xc(%ebp)
80104038:	e8 09 ff ff ff       	call   80103f46 <fetchstr>
8010403d:	83 c4 10             	add    $0x10,%esp
}
80104040:	c9                   	leave  
80104041:	c3                   	ret    
    return -1;
80104042:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104047:	eb f7                	jmp    80104040 <argstr+0x2a>

80104049 <syscall>:
[SYS_setprio]	sys_setprio,
};

void
syscall(void)
{
80104049:	55                   	push   %ebp
8010404a:	89 e5                	mov    %esp,%ebp
8010404c:	53                   	push   %ebx
8010404d:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104050:	e8 e8 f0 ff ff       	call   8010313d <myproc>
80104055:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104057:	8b 40 20             	mov    0x20(%eax),%eax
8010405a:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010405d:	8d 50 ff             	lea    -0x1(%eax),%edx
80104060:	83 fa 18             	cmp    $0x18,%edx
80104063:	77 17                	ja     8010407c <syscall+0x33>
80104065:	8b 14 85 20 71 10 80 	mov    -0x7fef8ee0(,%eax,4),%edx
8010406c:	85 d2                	test   %edx,%edx
8010406e:	74 0c                	je     8010407c <syscall+0x33>
    curproc->tf->eax = syscalls[num]();
80104070:	ff d2                	call   *%edx
80104072:	89 c2                	mov    %eax,%edx
80104074:	8b 43 20             	mov    0x20(%ebx),%eax
80104077:	89 50 1c             	mov    %edx,0x1c(%eax)
8010407a:	eb 1f                	jmp    8010409b <syscall+0x52>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010407c:	8d 53 78             	lea    0x78(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010407f:	50                   	push   %eax
80104080:	52                   	push   %edx
80104081:	ff 73 18             	push   0x18(%ebx)
80104084:	68 fd 70 10 80       	push   $0x801070fd
80104089:	e8 4c c5 ff ff       	call   801005da <cprintf>
    curproc->tf->eax = -1;
8010408e:	8b 43 20             	mov    0x20(%ebx),%eax
80104091:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80104098:	83 c4 10             	add    $0x10,%esp
  }
}
8010409b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010409e:	c9                   	leave  
8010409f:	c3                   	ret    

801040a0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801040a0:	55                   	push   %ebp
801040a1:	89 e5                	mov    %esp,%ebp
801040a3:	56                   	push   %esi
801040a4:	53                   	push   %ebx
801040a5:	83 ec 18             	sub    $0x18,%esp
801040a8:	89 d6                	mov    %edx,%esi
801040aa:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801040ac:	8d 55 f4             	lea    -0xc(%ebp),%edx
801040af:	52                   	push   %edx
801040b0:	50                   	push   %eax
801040b1:	e8 cf fe ff ff       	call   80103f85 <argint>
801040b6:	83 c4 10             	add    $0x10,%esp
801040b9:	85 c0                	test   %eax,%eax
801040bb:	78 35                	js     801040f2 <argfd+0x52>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801040bd:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801040c1:	77 28                	ja     801040eb <argfd+0x4b>
801040c3:	e8 75 f0 ff ff       	call   8010313d <myproc>
801040c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040cb:	8b 44 90 34          	mov    0x34(%eax,%edx,4),%eax
801040cf:	85 c0                	test   %eax,%eax
801040d1:	74 18                	je     801040eb <argfd+0x4b>
    return -1;
  if(pfd)
801040d3:	85 f6                	test   %esi,%esi
801040d5:	74 02                	je     801040d9 <argfd+0x39>
    *pfd = fd;
801040d7:	89 16                	mov    %edx,(%esi)
  if(pf)
801040d9:	85 db                	test   %ebx,%ebx
801040db:	74 1c                	je     801040f9 <argfd+0x59>
    *pf = f;
801040dd:	89 03                	mov    %eax,(%ebx)
  return 0;
801040df:	b8 00 00 00 00       	mov    $0x0,%eax
}
801040e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040e7:	5b                   	pop    %ebx
801040e8:	5e                   	pop    %esi
801040e9:	5d                   	pop    %ebp
801040ea:	c3                   	ret    
    return -1;
801040eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040f0:	eb f2                	jmp    801040e4 <argfd+0x44>
    return -1;
801040f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040f7:	eb eb                	jmp    801040e4 <argfd+0x44>
  return 0;
801040f9:	b8 00 00 00 00       	mov    $0x0,%eax
801040fe:	eb e4                	jmp    801040e4 <argfd+0x44>

80104100 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104100:	55                   	push   %ebp
80104101:	89 e5                	mov    %esp,%ebp
80104103:	53                   	push   %ebx
80104104:	83 ec 04             	sub    $0x4,%esp
80104107:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
80104109:	e8 2f f0 ff ff       	call   8010313d <myproc>
8010410e:	89 c2                	mov    %eax,%edx

  for(fd = 0; fd < NOFILE; fd++){
80104110:	b8 00 00 00 00       	mov    $0x0,%eax
80104115:	83 f8 0f             	cmp    $0xf,%eax
80104118:	7f 10                	jg     8010412a <fdalloc+0x2a>
    if(curproc->ofile[fd] == 0){
8010411a:	83 7c 82 34 00       	cmpl   $0x0,0x34(%edx,%eax,4)
8010411f:	74 03                	je     80104124 <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
80104121:	40                   	inc    %eax
80104122:	eb f1                	jmp    80104115 <fdalloc+0x15>
      curproc->ofile[fd] = f;
80104124:	89 5c 82 34          	mov    %ebx,0x34(%edx,%eax,4)
      return fd;
80104128:	eb 05                	jmp    8010412f <fdalloc+0x2f>
    }
  }
  return -1;
8010412a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010412f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104132:	c9                   	leave  
80104133:	c3                   	ret    

80104134 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80104134:	55                   	push   %ebp
80104135:	89 e5                	mov    %esp,%ebp
80104137:	56                   	push   %esi
80104138:	53                   	push   %ebx
80104139:	83 ec 10             	sub    $0x10,%esp
8010413c:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010413e:	b8 20 00 00 00       	mov    $0x20,%eax
80104143:	89 c6                	mov    %eax,%esi
80104145:	39 43 58             	cmp    %eax,0x58(%ebx)
80104148:	76 2e                	jbe    80104178 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010414a:	6a 10                	push   $0x10
8010414c:	50                   	push   %eax
8010414d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104150:	50                   	push   %eax
80104151:	53                   	push   %ebx
80104152:	e8 b4 d5 ff ff       	call   8010170b <readi>
80104157:	83 c4 10             	add    $0x10,%esp
8010415a:	83 f8 10             	cmp    $0x10,%eax
8010415d:	75 0c                	jne    8010416b <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
8010415f:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
80104164:	75 1e                	jne    80104184 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104166:	8d 46 10             	lea    0x10(%esi),%eax
80104169:	eb d8                	jmp    80104143 <isdirempty+0xf>
      panic("isdirempty: readi");
8010416b:	83 ec 0c             	sub    $0xc,%esp
8010416e:	68 88 71 10 80       	push   $0x80107188
80104173:	e8 c9 c1 ff ff       	call   80100341 <panic>
      return 0;
  }
  return 1;
80104178:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010417d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104180:	5b                   	pop    %ebx
80104181:	5e                   	pop    %esi
80104182:	5d                   	pop    %ebp
80104183:	c3                   	ret    
      return 0;
80104184:	b8 00 00 00 00       	mov    $0x0,%eax
80104189:	eb f2                	jmp    8010417d <isdirempty+0x49>

8010418b <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
8010418b:	55                   	push   %ebp
8010418c:	89 e5                	mov    %esp,%ebp
8010418e:	57                   	push   %edi
8010418f:	56                   	push   %esi
80104190:	53                   	push   %ebx
80104191:	83 ec 44             	sub    $0x44,%esp
80104194:	89 d7                	mov    %edx,%edi
80104196:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
80104199:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010419c:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010419f:	8d 55 d6             	lea    -0x2a(%ebp),%edx
801041a2:	52                   	push   %edx
801041a3:	50                   	push   %eax
801041a4:	e8 f1 d9 ff ff       	call   80101b9a <nameiparent>
801041a9:	89 c6                	mov    %eax,%esi
801041ab:	83 c4 10             	add    $0x10,%esp
801041ae:	85 c0                	test   %eax,%eax
801041b0:	0f 84 32 01 00 00    	je     801042e8 <create+0x15d>
    return 0;
  ilock(dp);
801041b6:	83 ec 0c             	sub    $0xc,%esp
801041b9:	50                   	push   %eax
801041ba:	e8 5f d3 ff ff       	call   8010151e <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801041bf:	83 c4 0c             	add    $0xc,%esp
801041c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801041c5:	50                   	push   %eax
801041c6:	8d 45 d6             	lea    -0x2a(%ebp),%eax
801041c9:	50                   	push   %eax
801041ca:	56                   	push   %esi
801041cb:	e8 84 d7 ff ff       	call   80101954 <dirlookup>
801041d0:	89 c3                	mov    %eax,%ebx
801041d2:	83 c4 10             	add    $0x10,%esp
801041d5:	85 c0                	test   %eax,%eax
801041d7:	74 3c                	je     80104215 <create+0x8a>
    iunlockput(dp);
801041d9:	83 ec 0c             	sub    $0xc,%esp
801041dc:	56                   	push   %esi
801041dd:	e8 df d4 ff ff       	call   801016c1 <iunlockput>
    ilock(ip);
801041e2:	89 1c 24             	mov    %ebx,(%esp)
801041e5:	e8 34 d3 ff ff       	call   8010151e <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801041ea:	83 c4 10             	add    $0x10,%esp
801041ed:	66 83 ff 02          	cmp    $0x2,%di
801041f1:	75 07                	jne    801041fa <create+0x6f>
801041f3:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801041f8:	74 11                	je     8010420b <create+0x80>
      return ip;
    iunlockput(ip);
801041fa:	83 ec 0c             	sub    $0xc,%esp
801041fd:	53                   	push   %ebx
801041fe:	e8 be d4 ff ff       	call   801016c1 <iunlockput>
    return 0;
80104203:	83 c4 10             	add    $0x10,%esp
80104206:	bb 00 00 00 00       	mov    $0x0,%ebx
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
8010420b:	89 d8                	mov    %ebx,%eax
8010420d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104210:	5b                   	pop    %ebx
80104211:	5e                   	pop    %esi
80104212:	5f                   	pop    %edi
80104213:	5d                   	pop    %ebp
80104214:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
80104215:	83 ec 08             	sub    $0x8,%esp
80104218:	0f bf c7             	movswl %di,%eax
8010421b:	50                   	push   %eax
8010421c:	ff 36                	push   (%esi)
8010421e:	e8 03 d1 ff ff       	call   80101326 <ialloc>
80104223:	89 c3                	mov    %eax,%ebx
80104225:	83 c4 10             	add    $0x10,%esp
80104228:	85 c0                	test   %eax,%eax
8010422a:	74 53                	je     8010427f <create+0xf4>
  ilock(ip);
8010422c:	83 ec 0c             	sub    $0xc,%esp
8010422f:	50                   	push   %eax
80104230:	e8 e9 d2 ff ff       	call   8010151e <ilock>
  ip->major = major;
80104235:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80104238:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
8010423c:	8b 45 c0             	mov    -0x40(%ebp),%eax
8010423f:	66 89 43 54          	mov    %ax,0x54(%ebx)
  ip->nlink = 1;
80104243:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104249:	89 1c 24             	mov    %ebx,(%esp)
8010424c:	e8 74 d1 ff ff       	call   801013c5 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104251:	83 c4 10             	add    $0x10,%esp
80104254:	66 83 ff 01          	cmp    $0x1,%di
80104258:	74 32                	je     8010428c <create+0x101>
  if(dirlink(dp, name, ip->inum) < 0)
8010425a:	83 ec 04             	sub    $0x4,%esp
8010425d:	ff 73 04             	push   0x4(%ebx)
80104260:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104263:	50                   	push   %eax
80104264:	56                   	push   %esi
80104265:	e8 67 d8 ff ff       	call   80101ad1 <dirlink>
8010426a:	83 c4 10             	add    $0x10,%esp
8010426d:	85 c0                	test   %eax,%eax
8010426f:	78 6a                	js     801042db <create+0x150>
  iunlockput(dp);
80104271:	83 ec 0c             	sub    $0xc,%esp
80104274:	56                   	push   %esi
80104275:	e8 47 d4 ff ff       	call   801016c1 <iunlockput>
  return ip;
8010427a:	83 c4 10             	add    $0x10,%esp
8010427d:	eb 8c                	jmp    8010420b <create+0x80>
    panic("create: ialloc");
8010427f:	83 ec 0c             	sub    $0xc,%esp
80104282:	68 9a 71 10 80       	push   $0x8010719a
80104287:	e8 b5 c0 ff ff       	call   80100341 <panic>
    dp->nlink++;  // for ".."
8010428c:	66 8b 46 56          	mov    0x56(%esi),%ax
80104290:	40                   	inc    %eax
80104291:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104295:	83 ec 0c             	sub    $0xc,%esp
80104298:	56                   	push   %esi
80104299:	e8 27 d1 ff ff       	call   801013c5 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010429e:	83 c4 0c             	add    $0xc,%esp
801042a1:	ff 73 04             	push   0x4(%ebx)
801042a4:	68 aa 71 10 80       	push   $0x801071aa
801042a9:	53                   	push   %ebx
801042aa:	e8 22 d8 ff ff       	call   80101ad1 <dirlink>
801042af:	83 c4 10             	add    $0x10,%esp
801042b2:	85 c0                	test   %eax,%eax
801042b4:	78 18                	js     801042ce <create+0x143>
801042b6:	83 ec 04             	sub    $0x4,%esp
801042b9:	ff 76 04             	push   0x4(%esi)
801042bc:	68 a9 71 10 80       	push   $0x801071a9
801042c1:	53                   	push   %ebx
801042c2:	e8 0a d8 ff ff       	call   80101ad1 <dirlink>
801042c7:	83 c4 10             	add    $0x10,%esp
801042ca:	85 c0                	test   %eax,%eax
801042cc:	79 8c                	jns    8010425a <create+0xcf>
      panic("create dots");
801042ce:	83 ec 0c             	sub    $0xc,%esp
801042d1:	68 ac 71 10 80       	push   $0x801071ac
801042d6:	e8 66 c0 ff ff       	call   80100341 <panic>
    panic("create: dirlink");
801042db:	83 ec 0c             	sub    $0xc,%esp
801042de:	68 b8 71 10 80       	push   $0x801071b8
801042e3:	e8 59 c0 ff ff       	call   80100341 <panic>
    return 0;
801042e8:	89 c3                	mov    %eax,%ebx
801042ea:	e9 1c ff ff ff       	jmp    8010420b <create+0x80>

801042ef <sys_dup>:
{
801042ef:	55                   	push   %ebp
801042f0:	89 e5                	mov    %esp,%ebp
801042f2:	53                   	push   %ebx
801042f3:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801042f6:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801042f9:	ba 00 00 00 00       	mov    $0x0,%edx
801042fe:	b8 00 00 00 00       	mov    $0x0,%eax
80104303:	e8 98 fd ff ff       	call   801040a0 <argfd>
80104308:	85 c0                	test   %eax,%eax
8010430a:	78 23                	js     8010432f <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
8010430c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430f:	e8 ec fd ff ff       	call   80104100 <fdalloc>
80104314:	89 c3                	mov    %eax,%ebx
80104316:	85 c0                	test   %eax,%eax
80104318:	78 1c                	js     80104336 <sys_dup+0x47>
  filedup(f);
8010431a:	83 ec 0c             	sub    $0xc,%esp
8010431d:	ff 75 f4             	push   -0xc(%ebp)
80104320:	e8 3a c9 ff ff       	call   80100c5f <filedup>
  return fd;
80104325:	83 c4 10             	add    $0x10,%esp
}
80104328:	89 d8                	mov    %ebx,%eax
8010432a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010432d:	c9                   	leave  
8010432e:	c3                   	ret    
    return -1;
8010432f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104334:	eb f2                	jmp    80104328 <sys_dup+0x39>
    return -1;
80104336:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010433b:	eb eb                	jmp    80104328 <sys_dup+0x39>

8010433d <sys_dup2>:
{
8010433d:	55                   	push   %ebp
8010433e:	89 e5                	mov    %esp,%ebp
80104340:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0,&oldfd,&old_f) < 0){
80104343:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104346:	8d 55 f0             	lea    -0x10(%ebp),%edx
80104349:	b8 00 00 00 00       	mov    $0x0,%eax
8010434e:	e8 4d fd ff ff       	call   801040a0 <argfd>
80104353:	85 c0                	test   %eax,%eax
80104355:	78 5e                	js     801043b5 <sys_dup2+0x78>
  if(argint(1, &newfd) < 0)
80104357:	83 ec 08             	sub    $0x8,%esp
8010435a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010435d:	50                   	push   %eax
8010435e:	6a 01                	push   $0x1
80104360:	e8 20 fc ff ff       	call   80103f85 <argint>
80104365:	83 c4 10             	add    $0x10,%esp
80104368:	85 c0                	test   %eax,%eax
8010436a:	78 50                	js     801043bc <sys_dup2+0x7f>
  if(newfd==oldfd)
8010436c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010436f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104372:	74 3f                	je     801043b3 <sys_dup2+0x76>
  if( newfd<0 || newfd >NOFILE)
80104374:	83 f8 10             	cmp    $0x10,%eax
80104377:	77 4a                	ja     801043c3 <sys_dup2+0x86>
  if((new_f=myproc()->ofile[newfd]) != 0)  
80104379:	e8 bf ed ff ff       	call   8010313d <myproc>
8010437e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104381:	8b 44 90 34          	mov    0x34(%eax,%edx,4),%eax
80104385:	85 c0                	test   %eax,%eax
80104387:	74 0c                	je     80104395 <sys_dup2+0x58>
    fileclose(new_f);
80104389:	83 ec 0c             	sub    $0xc,%esp
8010438c:	50                   	push   %eax
8010438d:	e8 10 c9 ff ff       	call   80100ca2 <fileclose>
80104392:	83 c4 10             	add    $0x10,%esp
  myproc()->ofile[newfd] = old_f;
80104395:	e8 a3 ed ff ff       	call   8010313d <myproc>
8010439a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010439d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801043a0:	89 54 88 34          	mov    %edx,0x34(%eax,%ecx,4)
  filedup(old_f);
801043a4:	83 ec 0c             	sub    $0xc,%esp
801043a7:	52                   	push   %edx
801043a8:	e8 b2 c8 ff ff       	call   80100c5f <filedup>
  return newfd;
801043ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043b0:	83 c4 10             	add    $0x10,%esp
}
801043b3:	c9                   	leave  
801043b4:	c3                   	ret    
    return -1;
801043b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043ba:	eb f7                	jmp    801043b3 <sys_dup2+0x76>
    return -1;
801043bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043c1:	eb f0                	jmp    801043b3 <sys_dup2+0x76>
  	return -1;
801043c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043c8:	eb e9                	jmp    801043b3 <sys_dup2+0x76>

801043ca <sys_getprio>:
{
801043ca:	55                   	push   %ebp
801043cb:	89 e5                	mov    %esp,%ebp
801043cd:	83 ec 20             	sub    $0x20,%esp
	if(argint(0, &pid) < 0)
801043d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801043d3:	50                   	push   %eax
801043d4:	6a 00                	push   $0x0
801043d6:	e8 aa fb ff ff       	call   80103f85 <argint>
801043db:	83 c4 10             	add    $0x10,%esp
801043de:	85 c0                	test   %eax,%eax
801043e0:	78 15                	js     801043f7 <sys_getprio+0x2d>
	if(pid < 0)
801043e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e5:	85 c0                	test   %eax,%eax
801043e7:	78 15                	js     801043fe <sys_getprio+0x34>
	return  getprio(pid);	
801043e9:	83 ec 0c             	sub    $0xc,%esp
801043ec:	50                   	push   %eax
801043ed:	e8 cb ef ff ff       	call   801033bd <getprio>
801043f2:	83 c4 10             	add    $0x10,%esp
}
801043f5:	c9                   	leave  
801043f6:	c3                   	ret    
		return -1;	
801043f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043fc:	eb f7                	jmp    801043f5 <sys_getprio+0x2b>
		return -1;
801043fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104403:	eb f0                	jmp    801043f5 <sys_getprio+0x2b>

80104405 <sys_setprio>:
{
80104405:	55                   	push   %ebp
80104406:	89 e5                	mov    %esp,%ebp
80104408:	83 ec 20             	sub    $0x20,%esp
	if(argint(0, &pid) < 0)
8010440b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010440e:	50                   	push   %eax
8010440f:	6a 00                	push   $0x0
80104411:	e8 6f fb ff ff       	call   80103f85 <argint>
80104416:	83 c4 10             	add    $0x10,%esp
80104419:	85 c0                	test   %eax,%eax
8010441b:	78 2a                	js     80104447 <sys_setprio+0x42>
	if(argptr(1,(void**) &prio, sizeof(enum proc_prio)) < 0)
8010441d:	83 ec 04             	sub    $0x4,%esp
80104420:	6a 04                	push   $0x4
80104422:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104425:	50                   	push   %eax
80104426:	6a 01                	push   $0x1
80104428:	e8 80 fb ff ff       	call   80103fad <argptr>
8010442d:	83 c4 10             	add    $0x10,%esp
80104430:	85 c0                	test   %eax,%eax
80104432:	78 1a                	js     8010444e <sys_setprio+0x49>
	return setprio(pid, prio);
80104434:	83 ec 08             	sub    $0x8,%esp
80104437:	ff 75 f0             	push   -0x10(%ebp)
8010443a:	ff 75 f4             	push   -0xc(%ebp)
8010443d:	e8 dd ef ff ff       	call   8010341f <setprio>
80104442:	83 c4 10             	add    $0x10,%esp
}
80104445:	c9                   	leave  
80104446:	c3                   	ret    
		return -1;
80104447:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010444c:	eb f7                	jmp    80104445 <sys_setprio+0x40>
		return -1;
8010444e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104453:	eb f0                	jmp    80104445 <sys_setprio+0x40>

80104455 <sys_read>:
{
80104455:	55                   	push   %ebp
80104456:	89 e5                	mov    %esp,%ebp
80104458:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, (void**)&p, n) < 0)
8010445b:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010445e:	ba 00 00 00 00       	mov    $0x0,%edx
80104463:	b8 00 00 00 00       	mov    $0x0,%eax
80104468:	e8 33 fc ff ff       	call   801040a0 <argfd>
8010446d:	85 c0                	test   %eax,%eax
8010446f:	78 43                	js     801044b4 <sys_read+0x5f>
80104471:	83 ec 08             	sub    $0x8,%esp
80104474:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104477:	50                   	push   %eax
80104478:	6a 02                	push   $0x2
8010447a:	e8 06 fb ff ff       	call   80103f85 <argint>
8010447f:	83 c4 10             	add    $0x10,%esp
80104482:	85 c0                	test   %eax,%eax
80104484:	78 2e                	js     801044b4 <sys_read+0x5f>
80104486:	83 ec 04             	sub    $0x4,%esp
80104489:	ff 75 f0             	push   -0x10(%ebp)
8010448c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010448f:	50                   	push   %eax
80104490:	6a 01                	push   $0x1
80104492:	e8 16 fb ff ff       	call   80103fad <argptr>
80104497:	83 c4 10             	add    $0x10,%esp
8010449a:	85 c0                	test   %eax,%eax
8010449c:	78 16                	js     801044b4 <sys_read+0x5f>
  return fileread(f, p, n);
8010449e:	83 ec 04             	sub    $0x4,%esp
801044a1:	ff 75 f0             	push   -0x10(%ebp)
801044a4:	ff 75 ec             	push   -0x14(%ebp)
801044a7:	ff 75 f4             	push   -0xc(%ebp)
801044aa:	e8 ec c8 ff ff       	call   80100d9b <fileread>
801044af:	83 c4 10             	add    $0x10,%esp
}
801044b2:	c9                   	leave  
801044b3:	c3                   	ret    
    return -1;
801044b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044b9:	eb f7                	jmp    801044b2 <sys_read+0x5d>

801044bb <sys_write>:
{
801044bb:	55                   	push   %ebp
801044bc:	89 e5                	mov    %esp,%ebp
801044be:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, (void**)&p, n) < 0)
801044c1:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801044c4:	ba 00 00 00 00       	mov    $0x0,%edx
801044c9:	b8 00 00 00 00       	mov    $0x0,%eax
801044ce:	e8 cd fb ff ff       	call   801040a0 <argfd>
801044d3:	85 c0                	test   %eax,%eax
801044d5:	78 43                	js     8010451a <sys_write+0x5f>
801044d7:	83 ec 08             	sub    $0x8,%esp
801044da:	8d 45 f0             	lea    -0x10(%ebp),%eax
801044dd:	50                   	push   %eax
801044de:	6a 02                	push   $0x2
801044e0:	e8 a0 fa ff ff       	call   80103f85 <argint>
801044e5:	83 c4 10             	add    $0x10,%esp
801044e8:	85 c0                	test   %eax,%eax
801044ea:	78 2e                	js     8010451a <sys_write+0x5f>
801044ec:	83 ec 04             	sub    $0x4,%esp
801044ef:	ff 75 f0             	push   -0x10(%ebp)
801044f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801044f5:	50                   	push   %eax
801044f6:	6a 01                	push   $0x1
801044f8:	e8 b0 fa ff ff       	call   80103fad <argptr>
801044fd:	83 c4 10             	add    $0x10,%esp
80104500:	85 c0                	test   %eax,%eax
80104502:	78 16                	js     8010451a <sys_write+0x5f>
  return filewrite(f, p, n);
80104504:	83 ec 04             	sub    $0x4,%esp
80104507:	ff 75 f0             	push   -0x10(%ebp)
8010450a:	ff 75 ec             	push   -0x14(%ebp)
8010450d:	ff 75 f4             	push   -0xc(%ebp)
80104510:	e8 0b c9 ff ff       	call   80100e20 <filewrite>
80104515:	83 c4 10             	add    $0x10,%esp
}
80104518:	c9                   	leave  
80104519:	c3                   	ret    
    return -1;
8010451a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010451f:	eb f7                	jmp    80104518 <sys_write+0x5d>

80104521 <sys_close>:
{
80104521:	55                   	push   %ebp
80104522:	89 e5                	mov    %esp,%ebp
80104524:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80104527:	8d 4d f0             	lea    -0x10(%ebp),%ecx
8010452a:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010452d:	b8 00 00 00 00       	mov    $0x0,%eax
80104532:	e8 69 fb ff ff       	call   801040a0 <argfd>
80104537:	85 c0                	test   %eax,%eax
80104539:	78 25                	js     80104560 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
8010453b:	e8 fd eb ff ff       	call   8010313d <myproc>
80104540:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104543:	c7 44 90 34 00 00 00 	movl   $0x0,0x34(%eax,%edx,4)
8010454a:	00 
  fileclose(f);
8010454b:	83 ec 0c             	sub    $0xc,%esp
8010454e:	ff 75 f0             	push   -0x10(%ebp)
80104551:	e8 4c c7 ff ff       	call   80100ca2 <fileclose>
  return 0;
80104556:	83 c4 10             	add    $0x10,%esp
80104559:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010455e:	c9                   	leave  
8010455f:	c3                   	ret    
    return -1;
80104560:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104565:	eb f7                	jmp    8010455e <sys_close+0x3d>

80104567 <sys_fstat>:
{
80104567:	55                   	push   %ebp
80104568:	89 e5                	mov    %esp,%ebp
8010456a:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010456d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104570:	ba 00 00 00 00       	mov    $0x0,%edx
80104575:	b8 00 00 00 00       	mov    $0x0,%eax
8010457a:	e8 21 fb ff ff       	call   801040a0 <argfd>
8010457f:	85 c0                	test   %eax,%eax
80104581:	78 2a                	js     801045ad <sys_fstat+0x46>
80104583:	83 ec 04             	sub    $0x4,%esp
80104586:	6a 14                	push   $0x14
80104588:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010458b:	50                   	push   %eax
8010458c:	6a 01                	push   $0x1
8010458e:	e8 1a fa ff ff       	call   80103fad <argptr>
80104593:	83 c4 10             	add    $0x10,%esp
80104596:	85 c0                	test   %eax,%eax
80104598:	78 13                	js     801045ad <sys_fstat+0x46>
  return filestat(f, st);
8010459a:	83 ec 08             	sub    $0x8,%esp
8010459d:	ff 75 f0             	push   -0x10(%ebp)
801045a0:	ff 75 f4             	push   -0xc(%ebp)
801045a3:	e8 ac c7 ff ff       	call   80100d54 <filestat>
801045a8:	83 c4 10             	add    $0x10,%esp
}
801045ab:	c9                   	leave  
801045ac:	c3                   	ret    
    return -1;
801045ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045b2:	eb f7                	jmp    801045ab <sys_fstat+0x44>

801045b4 <sys_link>:
{
801045b4:	55                   	push   %ebp
801045b5:	89 e5                	mov    %esp,%ebp
801045b7:	56                   	push   %esi
801045b8:	53                   	push   %ebx
801045b9:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801045bc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801045bf:	50                   	push   %eax
801045c0:	6a 00                	push   $0x0
801045c2:	e8 4f fa ff ff       	call   80104016 <argstr>
801045c7:	83 c4 10             	add    $0x10,%esp
801045ca:	85 c0                	test   %eax,%eax
801045cc:	0f 88 d1 00 00 00    	js     801046a3 <sys_link+0xef>
801045d2:	83 ec 08             	sub    $0x8,%esp
801045d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801045d8:	50                   	push   %eax
801045d9:	6a 01                	push   $0x1
801045db:	e8 36 fa ff ff       	call   80104016 <argstr>
801045e0:	83 c4 10             	add    $0x10,%esp
801045e3:	85 c0                	test   %eax,%eax
801045e5:	0f 88 b8 00 00 00    	js     801046a3 <sys_link+0xef>
  begin_op();
801045eb:	e8 04 e1 ff ff       	call   801026f4 <begin_op>
  if((ip = namei(old)) == 0){
801045f0:	83 ec 0c             	sub    $0xc,%esp
801045f3:	ff 75 e0             	push   -0x20(%ebp)
801045f6:	e8 87 d5 ff ff       	call   80101b82 <namei>
801045fb:	89 c3                	mov    %eax,%ebx
801045fd:	83 c4 10             	add    $0x10,%esp
80104600:	85 c0                	test   %eax,%eax
80104602:	0f 84 a2 00 00 00    	je     801046aa <sys_link+0xf6>
  ilock(ip);
80104608:	83 ec 0c             	sub    $0xc,%esp
8010460b:	50                   	push   %eax
8010460c:	e8 0d cf ff ff       	call   8010151e <ilock>
  if(ip->type == T_DIR){
80104611:	83 c4 10             	add    $0x10,%esp
80104614:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104619:	0f 84 97 00 00 00    	je     801046b6 <sys_link+0x102>
  ip->nlink++;
8010461f:	66 8b 43 56          	mov    0x56(%ebx),%ax
80104623:	40                   	inc    %eax
80104624:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104628:	83 ec 0c             	sub    $0xc,%esp
8010462b:	53                   	push   %ebx
8010462c:	e8 94 cd ff ff       	call   801013c5 <iupdate>
  iunlock(ip);
80104631:	89 1c 24             	mov    %ebx,(%esp)
80104634:	e8 a5 cf ff ff       	call   801015de <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104639:	83 c4 08             	add    $0x8,%esp
8010463c:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010463f:	50                   	push   %eax
80104640:	ff 75 e4             	push   -0x1c(%ebp)
80104643:	e8 52 d5 ff ff       	call   80101b9a <nameiparent>
80104648:	89 c6                	mov    %eax,%esi
8010464a:	83 c4 10             	add    $0x10,%esp
8010464d:	85 c0                	test   %eax,%eax
8010464f:	0f 84 85 00 00 00    	je     801046da <sys_link+0x126>
  ilock(dp);
80104655:	83 ec 0c             	sub    $0xc,%esp
80104658:	50                   	push   %eax
80104659:	e8 c0 ce ff ff       	call   8010151e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010465e:	83 c4 10             	add    $0x10,%esp
80104661:	8b 03                	mov    (%ebx),%eax
80104663:	39 06                	cmp    %eax,(%esi)
80104665:	75 67                	jne    801046ce <sys_link+0x11a>
80104667:	83 ec 04             	sub    $0x4,%esp
8010466a:	ff 73 04             	push   0x4(%ebx)
8010466d:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104670:	50                   	push   %eax
80104671:	56                   	push   %esi
80104672:	e8 5a d4 ff ff       	call   80101ad1 <dirlink>
80104677:	83 c4 10             	add    $0x10,%esp
8010467a:	85 c0                	test   %eax,%eax
8010467c:	78 50                	js     801046ce <sys_link+0x11a>
  iunlockput(dp);
8010467e:	83 ec 0c             	sub    $0xc,%esp
80104681:	56                   	push   %esi
80104682:	e8 3a d0 ff ff       	call   801016c1 <iunlockput>
  iput(ip);
80104687:	89 1c 24             	mov    %ebx,(%esp)
8010468a:	e8 94 cf ff ff       	call   80101623 <iput>
  end_op();
8010468f:	e8 dc e0 ff ff       	call   80102770 <end_op>
  return 0;
80104694:	83 c4 10             	add    $0x10,%esp
80104697:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010469c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010469f:	5b                   	pop    %ebx
801046a0:	5e                   	pop    %esi
801046a1:	5d                   	pop    %ebp
801046a2:	c3                   	ret    
    return -1;
801046a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046a8:	eb f2                	jmp    8010469c <sys_link+0xe8>
    end_op();
801046aa:	e8 c1 e0 ff ff       	call   80102770 <end_op>
    return -1;
801046af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046b4:	eb e6                	jmp    8010469c <sys_link+0xe8>
    iunlockput(ip);
801046b6:	83 ec 0c             	sub    $0xc,%esp
801046b9:	53                   	push   %ebx
801046ba:	e8 02 d0 ff ff       	call   801016c1 <iunlockput>
    end_op();
801046bf:	e8 ac e0 ff ff       	call   80102770 <end_op>
    return -1;
801046c4:	83 c4 10             	add    $0x10,%esp
801046c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046cc:	eb ce                	jmp    8010469c <sys_link+0xe8>
    iunlockput(dp);
801046ce:	83 ec 0c             	sub    $0xc,%esp
801046d1:	56                   	push   %esi
801046d2:	e8 ea cf ff ff       	call   801016c1 <iunlockput>
    goto bad;
801046d7:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
801046da:	83 ec 0c             	sub    $0xc,%esp
801046dd:	53                   	push   %ebx
801046de:	e8 3b ce ff ff       	call   8010151e <ilock>
  ip->nlink--;
801046e3:	66 8b 43 56          	mov    0x56(%ebx),%ax
801046e7:	48                   	dec    %eax
801046e8:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801046ec:	89 1c 24             	mov    %ebx,(%esp)
801046ef:	e8 d1 cc ff ff       	call   801013c5 <iupdate>
  iunlockput(ip);
801046f4:	89 1c 24             	mov    %ebx,(%esp)
801046f7:	e8 c5 cf ff ff       	call   801016c1 <iunlockput>
  end_op();
801046fc:	e8 6f e0 ff ff       	call   80102770 <end_op>
  return -1;
80104701:	83 c4 10             	add    $0x10,%esp
80104704:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104709:	eb 91                	jmp    8010469c <sys_link+0xe8>

8010470b <sys_unlink>:
{
8010470b:	55                   	push   %ebp
8010470c:	89 e5                	mov    %esp,%ebp
8010470e:	57                   	push   %edi
8010470f:	56                   	push   %esi
80104710:	53                   	push   %ebx
80104711:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
80104714:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104717:	50                   	push   %eax
80104718:	6a 00                	push   $0x0
8010471a:	e8 f7 f8 ff ff       	call   80104016 <argstr>
8010471f:	83 c4 10             	add    $0x10,%esp
80104722:	85 c0                	test   %eax,%eax
80104724:	0f 88 7f 01 00 00    	js     801048a9 <sys_unlink+0x19e>
  begin_op();
8010472a:	e8 c5 df ff ff       	call   801026f4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010472f:	83 ec 08             	sub    $0x8,%esp
80104732:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104735:	50                   	push   %eax
80104736:	ff 75 c4             	push   -0x3c(%ebp)
80104739:	e8 5c d4 ff ff       	call   80101b9a <nameiparent>
8010473e:	89 c6                	mov    %eax,%esi
80104740:	83 c4 10             	add    $0x10,%esp
80104743:	85 c0                	test   %eax,%eax
80104745:	0f 84 eb 00 00 00    	je     80104836 <sys_unlink+0x12b>
  ilock(dp);
8010474b:	83 ec 0c             	sub    $0xc,%esp
8010474e:	50                   	push   %eax
8010474f:	e8 ca cd ff ff       	call   8010151e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104754:	83 c4 08             	add    $0x8,%esp
80104757:	68 aa 71 10 80       	push   $0x801071aa
8010475c:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010475f:	50                   	push   %eax
80104760:	e8 da d1 ff ff       	call   8010193f <namecmp>
80104765:	83 c4 10             	add    $0x10,%esp
80104768:	85 c0                	test   %eax,%eax
8010476a:	0f 84 fa 00 00 00    	je     8010486a <sys_unlink+0x15f>
80104770:	83 ec 08             	sub    $0x8,%esp
80104773:	68 a9 71 10 80       	push   $0x801071a9
80104778:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010477b:	50                   	push   %eax
8010477c:	e8 be d1 ff ff       	call   8010193f <namecmp>
80104781:	83 c4 10             	add    $0x10,%esp
80104784:	85 c0                	test   %eax,%eax
80104786:	0f 84 de 00 00 00    	je     8010486a <sys_unlink+0x15f>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010478c:	83 ec 04             	sub    $0x4,%esp
8010478f:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104792:	50                   	push   %eax
80104793:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104796:	50                   	push   %eax
80104797:	56                   	push   %esi
80104798:	e8 b7 d1 ff ff       	call   80101954 <dirlookup>
8010479d:	89 c3                	mov    %eax,%ebx
8010479f:	83 c4 10             	add    $0x10,%esp
801047a2:	85 c0                	test   %eax,%eax
801047a4:	0f 84 c0 00 00 00    	je     8010486a <sys_unlink+0x15f>
  ilock(ip);
801047aa:	83 ec 0c             	sub    $0xc,%esp
801047ad:	50                   	push   %eax
801047ae:	e8 6b cd ff ff       	call   8010151e <ilock>
  if(ip->nlink < 1)
801047b3:	83 c4 10             	add    $0x10,%esp
801047b6:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801047bb:	0f 8e 81 00 00 00    	jle    80104842 <sys_unlink+0x137>
  if(ip->type == T_DIR && !isdirempty(ip)){
801047c1:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801047c6:	0f 84 83 00 00 00    	je     8010484f <sys_unlink+0x144>
  memset(&de, 0, sizeof(de));
801047cc:	83 ec 04             	sub    $0x4,%esp
801047cf:	6a 10                	push   $0x10
801047d1:	6a 00                	push   $0x0
801047d3:	8d 7d d8             	lea    -0x28(%ebp),%edi
801047d6:	57                   	push   %edi
801047d7:	e8 73 f5 ff ff       	call   80103d4f <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801047dc:	6a 10                	push   $0x10
801047de:	ff 75 c0             	push   -0x40(%ebp)
801047e1:	57                   	push   %edi
801047e2:	56                   	push   %esi
801047e3:	e8 23 d0 ff ff       	call   8010180b <writei>
801047e8:	83 c4 20             	add    $0x20,%esp
801047eb:	83 f8 10             	cmp    $0x10,%eax
801047ee:	0f 85 8e 00 00 00    	jne    80104882 <sys_unlink+0x177>
  if(ip->type == T_DIR){
801047f4:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801047f9:	0f 84 90 00 00 00    	je     8010488f <sys_unlink+0x184>
  iunlockput(dp);
801047ff:	83 ec 0c             	sub    $0xc,%esp
80104802:	56                   	push   %esi
80104803:	e8 b9 ce ff ff       	call   801016c1 <iunlockput>
  ip->nlink--;
80104808:	66 8b 43 56          	mov    0x56(%ebx),%ax
8010480c:	48                   	dec    %eax
8010480d:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104811:	89 1c 24             	mov    %ebx,(%esp)
80104814:	e8 ac cb ff ff       	call   801013c5 <iupdate>
  iunlockput(ip);
80104819:	89 1c 24             	mov    %ebx,(%esp)
8010481c:	e8 a0 ce ff ff       	call   801016c1 <iunlockput>
  end_op();
80104821:	e8 4a df ff ff       	call   80102770 <end_op>
  return 0;
80104826:	83 c4 10             	add    $0x10,%esp
80104829:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010482e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104831:	5b                   	pop    %ebx
80104832:	5e                   	pop    %esi
80104833:	5f                   	pop    %edi
80104834:	5d                   	pop    %ebp
80104835:	c3                   	ret    
    end_op();
80104836:	e8 35 df ff ff       	call   80102770 <end_op>
    return -1;
8010483b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104840:	eb ec                	jmp    8010482e <sys_unlink+0x123>
    panic("unlink: nlink < 1");
80104842:	83 ec 0c             	sub    $0xc,%esp
80104845:	68 c8 71 10 80       	push   $0x801071c8
8010484a:	e8 f2 ba ff ff       	call   80100341 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010484f:	89 d8                	mov    %ebx,%eax
80104851:	e8 de f8 ff ff       	call   80104134 <isdirempty>
80104856:	85 c0                	test   %eax,%eax
80104858:	0f 85 6e ff ff ff    	jne    801047cc <sys_unlink+0xc1>
    iunlockput(ip);
8010485e:	83 ec 0c             	sub    $0xc,%esp
80104861:	53                   	push   %ebx
80104862:	e8 5a ce ff ff       	call   801016c1 <iunlockput>
    goto bad;
80104867:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
8010486a:	83 ec 0c             	sub    $0xc,%esp
8010486d:	56                   	push   %esi
8010486e:	e8 4e ce ff ff       	call   801016c1 <iunlockput>
  end_op();
80104873:	e8 f8 de ff ff       	call   80102770 <end_op>
  return -1;
80104878:	83 c4 10             	add    $0x10,%esp
8010487b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104880:	eb ac                	jmp    8010482e <sys_unlink+0x123>
    panic("unlink: writei");
80104882:	83 ec 0c             	sub    $0xc,%esp
80104885:	68 da 71 10 80       	push   $0x801071da
8010488a:	e8 b2 ba ff ff       	call   80100341 <panic>
    dp->nlink--;
8010488f:	66 8b 46 56          	mov    0x56(%esi),%ax
80104893:	48                   	dec    %eax
80104894:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104898:	83 ec 0c             	sub    $0xc,%esp
8010489b:	56                   	push   %esi
8010489c:	e8 24 cb ff ff       	call   801013c5 <iupdate>
801048a1:	83 c4 10             	add    $0x10,%esp
801048a4:	e9 56 ff ff ff       	jmp    801047ff <sys_unlink+0xf4>
    return -1;
801048a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048ae:	e9 7b ff ff ff       	jmp    8010482e <sys_unlink+0x123>

801048b3 <sys_open>:

int
sys_open(void)
{
801048b3:	55                   	push   %ebp
801048b4:	89 e5                	mov    %esp,%ebp
801048b6:	57                   	push   %edi
801048b7:	56                   	push   %esi
801048b8:	53                   	push   %ebx
801048b9:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801048bc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801048bf:	50                   	push   %eax
801048c0:	6a 00                	push   $0x0
801048c2:	e8 4f f7 ff ff       	call   80104016 <argstr>
801048c7:	83 c4 10             	add    $0x10,%esp
801048ca:	85 c0                	test   %eax,%eax
801048cc:	0f 88 a0 00 00 00    	js     80104972 <sys_open+0xbf>
801048d2:	83 ec 08             	sub    $0x8,%esp
801048d5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801048d8:	50                   	push   %eax
801048d9:	6a 01                	push   $0x1
801048db:	e8 a5 f6 ff ff       	call   80103f85 <argint>
801048e0:	83 c4 10             	add    $0x10,%esp
801048e3:	85 c0                	test   %eax,%eax
801048e5:	0f 88 87 00 00 00    	js     80104972 <sys_open+0xbf>
    return -1;

  begin_op();
801048eb:	e8 04 de ff ff       	call   801026f4 <begin_op>

  if(omode & O_CREATE){
801048f0:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
801048f4:	0f 84 8b 00 00 00    	je     80104985 <sys_open+0xd2>
    ip = create(path, T_FILE, 0, 0);
801048fa:	83 ec 0c             	sub    $0xc,%esp
801048fd:	6a 00                	push   $0x0
801048ff:	b9 00 00 00 00       	mov    $0x0,%ecx
80104904:	ba 02 00 00 00       	mov    $0x2,%edx
80104909:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010490c:	e8 7a f8 ff ff       	call   8010418b <create>
80104911:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104913:	83 c4 10             	add    $0x10,%esp
80104916:	85 c0                	test   %eax,%eax
80104918:	74 5f                	je     80104979 <sys_open+0xc6>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010491a:	e8 df c2 ff ff       	call   80100bfe <filealloc>
8010491f:	89 c3                	mov    %eax,%ebx
80104921:	85 c0                	test   %eax,%eax
80104923:	0f 84 b5 00 00 00    	je     801049de <sys_open+0x12b>
80104929:	e8 d2 f7 ff ff       	call   80104100 <fdalloc>
8010492e:	89 c7                	mov    %eax,%edi
80104930:	85 c0                	test   %eax,%eax
80104932:	0f 88 a6 00 00 00    	js     801049de <sys_open+0x12b>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104938:	83 ec 0c             	sub    $0xc,%esp
8010493b:	56                   	push   %esi
8010493c:	e8 9d cc ff ff       	call   801015de <iunlock>
  end_op();
80104941:	e8 2a de ff ff       	call   80102770 <end_op>

  f->type = FD_INODE;
80104946:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
8010494c:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
8010494f:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104956:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104959:	83 c4 10             	add    $0x10,%esp
8010495c:	a8 01                	test   $0x1,%al
8010495e:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104962:	a8 03                	test   $0x3,%al
80104964:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104968:	89 f8                	mov    %edi,%eax
8010496a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010496d:	5b                   	pop    %ebx
8010496e:	5e                   	pop    %esi
8010496f:	5f                   	pop    %edi
80104970:	5d                   	pop    %ebp
80104971:	c3                   	ret    
    return -1;
80104972:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104977:	eb ef                	jmp    80104968 <sys_open+0xb5>
      end_op();
80104979:	e8 f2 dd ff ff       	call   80102770 <end_op>
      return -1;
8010497e:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104983:	eb e3                	jmp    80104968 <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104985:	83 ec 0c             	sub    $0xc,%esp
80104988:	ff 75 e4             	push   -0x1c(%ebp)
8010498b:	e8 f2 d1 ff ff       	call   80101b82 <namei>
80104990:	89 c6                	mov    %eax,%esi
80104992:	83 c4 10             	add    $0x10,%esp
80104995:	85 c0                	test   %eax,%eax
80104997:	74 39                	je     801049d2 <sys_open+0x11f>
    ilock(ip);
80104999:	83 ec 0c             	sub    $0xc,%esp
8010499c:	50                   	push   %eax
8010499d:	e8 7c cb ff ff       	call   8010151e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801049a2:	83 c4 10             	add    $0x10,%esp
801049a5:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801049aa:	0f 85 6a ff ff ff    	jne    8010491a <sys_open+0x67>
801049b0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801049b4:	0f 84 60 ff ff ff    	je     8010491a <sys_open+0x67>
      iunlockput(ip);
801049ba:	83 ec 0c             	sub    $0xc,%esp
801049bd:	56                   	push   %esi
801049be:	e8 fe cc ff ff       	call   801016c1 <iunlockput>
      end_op();
801049c3:	e8 a8 dd ff ff       	call   80102770 <end_op>
      return -1;
801049c8:	83 c4 10             	add    $0x10,%esp
801049cb:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049d0:	eb 96                	jmp    80104968 <sys_open+0xb5>
      end_op();
801049d2:	e8 99 dd ff ff       	call   80102770 <end_op>
      return -1;
801049d7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049dc:	eb 8a                	jmp    80104968 <sys_open+0xb5>
    if(f)
801049de:	85 db                	test   %ebx,%ebx
801049e0:	74 0c                	je     801049ee <sys_open+0x13b>
      fileclose(f);
801049e2:	83 ec 0c             	sub    $0xc,%esp
801049e5:	53                   	push   %ebx
801049e6:	e8 b7 c2 ff ff       	call   80100ca2 <fileclose>
801049eb:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801049ee:	83 ec 0c             	sub    $0xc,%esp
801049f1:	56                   	push   %esi
801049f2:	e8 ca cc ff ff       	call   801016c1 <iunlockput>
    end_op();
801049f7:	e8 74 dd ff ff       	call   80102770 <end_op>
    return -1;
801049fc:	83 c4 10             	add    $0x10,%esp
801049ff:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a04:	e9 5f ff ff ff       	jmp    80104968 <sys_open+0xb5>

80104a09 <sys_mkdir>:

int
sys_mkdir(void)
{
80104a09:	55                   	push   %ebp
80104a0a:	89 e5                	mov    %esp,%ebp
80104a0c:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104a0f:	e8 e0 dc ff ff       	call   801026f4 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104a14:	83 ec 08             	sub    $0x8,%esp
80104a17:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a1a:	50                   	push   %eax
80104a1b:	6a 00                	push   $0x0
80104a1d:	e8 f4 f5 ff ff       	call   80104016 <argstr>
80104a22:	83 c4 10             	add    $0x10,%esp
80104a25:	85 c0                	test   %eax,%eax
80104a27:	78 36                	js     80104a5f <sys_mkdir+0x56>
80104a29:	83 ec 0c             	sub    $0xc,%esp
80104a2c:	6a 00                	push   $0x0
80104a2e:	b9 00 00 00 00       	mov    $0x0,%ecx
80104a33:	ba 01 00 00 00       	mov    $0x1,%edx
80104a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a3b:	e8 4b f7 ff ff       	call   8010418b <create>
80104a40:	83 c4 10             	add    $0x10,%esp
80104a43:	85 c0                	test   %eax,%eax
80104a45:	74 18                	je     80104a5f <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104a47:	83 ec 0c             	sub    $0xc,%esp
80104a4a:	50                   	push   %eax
80104a4b:	e8 71 cc ff ff       	call   801016c1 <iunlockput>
  end_op();
80104a50:	e8 1b dd ff ff       	call   80102770 <end_op>
  return 0;
80104a55:	83 c4 10             	add    $0x10,%esp
80104a58:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a5d:	c9                   	leave  
80104a5e:	c3                   	ret    
    end_op();
80104a5f:	e8 0c dd ff ff       	call   80102770 <end_op>
    return -1;
80104a64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a69:	eb f2                	jmp    80104a5d <sys_mkdir+0x54>

80104a6b <sys_mknod>:

int
sys_mknod(void)
{
80104a6b:	55                   	push   %ebp
80104a6c:	89 e5                	mov    %esp,%ebp
80104a6e:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104a71:	e8 7e dc ff ff       	call   801026f4 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104a76:	83 ec 08             	sub    $0x8,%esp
80104a79:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a7c:	50                   	push   %eax
80104a7d:	6a 00                	push   $0x0
80104a7f:	e8 92 f5 ff ff       	call   80104016 <argstr>
80104a84:	83 c4 10             	add    $0x10,%esp
80104a87:	85 c0                	test   %eax,%eax
80104a89:	78 62                	js     80104aed <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104a8b:	83 ec 08             	sub    $0x8,%esp
80104a8e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104a91:	50                   	push   %eax
80104a92:	6a 01                	push   $0x1
80104a94:	e8 ec f4 ff ff       	call   80103f85 <argint>
  if((argstr(0, &path)) < 0 ||
80104a99:	83 c4 10             	add    $0x10,%esp
80104a9c:	85 c0                	test   %eax,%eax
80104a9e:	78 4d                	js     80104aed <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104aa0:	83 ec 08             	sub    $0x8,%esp
80104aa3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104aa6:	50                   	push   %eax
80104aa7:	6a 02                	push   $0x2
80104aa9:	e8 d7 f4 ff ff       	call   80103f85 <argint>
     argint(1, &major) < 0 ||
80104aae:	83 c4 10             	add    $0x10,%esp
80104ab1:	85 c0                	test   %eax,%eax
80104ab3:	78 38                	js     80104aed <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104ab5:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80104ab9:	83 ec 0c             	sub    $0xc,%esp
80104abc:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104ac0:	50                   	push   %eax
80104ac1:	ba 03 00 00 00       	mov    $0x3,%edx
80104ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac9:	e8 bd f6 ff ff       	call   8010418b <create>
     argint(2, &minor) < 0 ||
80104ace:	83 c4 10             	add    $0x10,%esp
80104ad1:	85 c0                	test   %eax,%eax
80104ad3:	74 18                	je     80104aed <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104ad5:	83 ec 0c             	sub    $0xc,%esp
80104ad8:	50                   	push   %eax
80104ad9:	e8 e3 cb ff ff       	call   801016c1 <iunlockput>
  end_op();
80104ade:	e8 8d dc ff ff       	call   80102770 <end_op>
  return 0;
80104ae3:	83 c4 10             	add    $0x10,%esp
80104ae6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104aeb:	c9                   	leave  
80104aec:	c3                   	ret    
    end_op();
80104aed:	e8 7e dc ff ff       	call   80102770 <end_op>
    return -1;
80104af2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104af7:	eb f2                	jmp    80104aeb <sys_mknod+0x80>

80104af9 <sys_chdir>:

int
sys_chdir(void)
{
80104af9:	55                   	push   %ebp
80104afa:	89 e5                	mov    %esp,%ebp
80104afc:	56                   	push   %esi
80104afd:	53                   	push   %ebx
80104afe:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104b01:	e8 37 e6 ff ff       	call   8010313d <myproc>
80104b06:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104b08:	e8 e7 db ff ff       	call   801026f4 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104b0d:	83 ec 08             	sub    $0x8,%esp
80104b10:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b13:	50                   	push   %eax
80104b14:	6a 00                	push   $0x0
80104b16:	e8 fb f4 ff ff       	call   80104016 <argstr>
80104b1b:	83 c4 10             	add    $0x10,%esp
80104b1e:	85 c0                	test   %eax,%eax
80104b20:	78 52                	js     80104b74 <sys_chdir+0x7b>
80104b22:	83 ec 0c             	sub    $0xc,%esp
80104b25:	ff 75 f4             	push   -0xc(%ebp)
80104b28:	e8 55 d0 ff ff       	call   80101b82 <namei>
80104b2d:	89 c3                	mov    %eax,%ebx
80104b2f:	83 c4 10             	add    $0x10,%esp
80104b32:	85 c0                	test   %eax,%eax
80104b34:	74 3e                	je     80104b74 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104b36:	83 ec 0c             	sub    $0xc,%esp
80104b39:	50                   	push   %eax
80104b3a:	e8 df c9 ff ff       	call   8010151e <ilock>
  if(ip->type != T_DIR){
80104b3f:	83 c4 10             	add    $0x10,%esp
80104b42:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104b47:	75 37                	jne    80104b80 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104b49:	83 ec 0c             	sub    $0xc,%esp
80104b4c:	53                   	push   %ebx
80104b4d:	e8 8c ca ff ff       	call   801015de <iunlock>
  iput(curproc->cwd);
80104b52:	83 c4 04             	add    $0x4,%esp
80104b55:	ff 76 74             	push   0x74(%esi)
80104b58:	e8 c6 ca ff ff       	call   80101623 <iput>
  end_op();
80104b5d:	e8 0e dc ff ff       	call   80102770 <end_op>
  curproc->cwd = ip;
80104b62:	89 5e 74             	mov    %ebx,0x74(%esi)
  return 0;
80104b65:	83 c4 10             	add    $0x10,%esp
80104b68:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104b70:	5b                   	pop    %ebx
80104b71:	5e                   	pop    %esi
80104b72:	5d                   	pop    %ebp
80104b73:	c3                   	ret    
    end_op();
80104b74:	e8 f7 db ff ff       	call   80102770 <end_op>
    return -1;
80104b79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b7e:	eb ed                	jmp    80104b6d <sys_chdir+0x74>
    iunlockput(ip);
80104b80:	83 ec 0c             	sub    $0xc,%esp
80104b83:	53                   	push   %ebx
80104b84:	e8 38 cb ff ff       	call   801016c1 <iunlockput>
    end_op();
80104b89:	e8 e2 db ff ff       	call   80102770 <end_op>
    return -1;
80104b8e:	83 c4 10             	add    $0x10,%esp
80104b91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b96:	eb d5                	jmp    80104b6d <sys_chdir+0x74>

80104b98 <sys_exec>:

int
sys_exec(void)
{
80104b98:	55                   	push   %ebp
80104b99:	89 e5                	mov    %esp,%ebp
80104b9b:	53                   	push   %ebx
80104b9c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104ba2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ba5:	50                   	push   %eax
80104ba6:	6a 00                	push   $0x0
80104ba8:	e8 69 f4 ff ff       	call   80104016 <argstr>
80104bad:	83 c4 10             	add    $0x10,%esp
80104bb0:	85 c0                	test   %eax,%eax
80104bb2:	78 38                	js     80104bec <sys_exec+0x54>
80104bb4:	83 ec 08             	sub    $0x8,%esp
80104bb7:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104bbd:	50                   	push   %eax
80104bbe:	6a 01                	push   $0x1
80104bc0:	e8 c0 f3 ff ff       	call   80103f85 <argint>
80104bc5:	83 c4 10             	add    $0x10,%esp
80104bc8:	85 c0                	test   %eax,%eax
80104bca:	78 20                	js     80104bec <sys_exec+0x54>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104bcc:	83 ec 04             	sub    $0x4,%esp
80104bcf:	68 80 00 00 00       	push   $0x80
80104bd4:	6a 00                	push   $0x0
80104bd6:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104bdc:	50                   	push   %eax
80104bdd:	e8 6d f1 ff ff       	call   80103d4f <memset>
80104be2:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104be5:	bb 00 00 00 00       	mov    $0x0,%ebx
80104bea:	eb 2a                	jmp    80104c16 <sys_exec+0x7e>
    return -1;
80104bec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bf1:	eb 76                	jmp    80104c69 <sys_exec+0xd1>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
80104bf3:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104bfa:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80104bfe:	83 ec 08             	sub    $0x8,%esp
80104c01:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104c07:	50                   	push   %eax
80104c08:	ff 75 f4             	push   -0xc(%ebp)
80104c0b:	e8 80 bc ff ff       	call   80100890 <exec>
80104c10:	83 c4 10             	add    $0x10,%esp
80104c13:	eb 54                	jmp    80104c69 <sys_exec+0xd1>
  for(i=0;; i++){
80104c15:	43                   	inc    %ebx
    if(i >= NELEM(argv))
80104c16:	83 fb 1f             	cmp    $0x1f,%ebx
80104c19:	77 49                	ja     80104c64 <sys_exec+0xcc>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104c1b:	83 ec 08             	sub    $0x8,%esp
80104c1e:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104c24:	50                   	push   %eax
80104c25:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104c2b:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104c2e:	50                   	push   %eax
80104c2f:	e8 d6 f2 ff ff       	call   80103f0a <fetchint>
80104c34:	83 c4 10             	add    $0x10,%esp
80104c37:	85 c0                	test   %eax,%eax
80104c39:	78 33                	js     80104c6e <sys_exec+0xd6>
    if(uarg == 0){
80104c3b:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104c41:	85 c0                	test   %eax,%eax
80104c43:	74 ae                	je     80104bf3 <sys_exec+0x5b>
    if(fetchstr(uarg, &argv[i]) < 0)
80104c45:	83 ec 08             	sub    $0x8,%esp
80104c48:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104c4f:	52                   	push   %edx
80104c50:	50                   	push   %eax
80104c51:	e8 f0 f2 ff ff       	call   80103f46 <fetchstr>
80104c56:	83 c4 10             	add    $0x10,%esp
80104c59:	85 c0                	test   %eax,%eax
80104c5b:	79 b8                	jns    80104c15 <sys_exec+0x7d>
      return -1;
80104c5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c62:	eb 05                	jmp    80104c69 <sys_exec+0xd1>
      return -1;
80104c64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c6c:	c9                   	leave  
80104c6d:	c3                   	ret    
      return -1;
80104c6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c73:	eb f4                	jmp    80104c69 <sys_exec+0xd1>

80104c75 <sys_pipe>:

int
sys_pipe(void)
{
80104c75:	55                   	push   %ebp
80104c76:	89 e5                	mov    %esp,%ebp
80104c78:	53                   	push   %ebx
80104c79:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104c7c:	6a 08                	push   $0x8
80104c7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c81:	50                   	push   %eax
80104c82:	6a 00                	push   $0x0
80104c84:	e8 24 f3 ff ff       	call   80103fad <argptr>
80104c89:	83 c4 10             	add    $0x10,%esp
80104c8c:	85 c0                	test   %eax,%eax
80104c8e:	78 79                	js     80104d09 <sys_pipe+0x94>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104c90:	83 ec 08             	sub    $0x8,%esp
80104c93:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104c96:	50                   	push   %eax
80104c97:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104c9a:	50                   	push   %eax
80104c9b:	e8 cb df ff ff       	call   80102c6b <pipealloc>
80104ca0:	83 c4 10             	add    $0x10,%esp
80104ca3:	85 c0                	test   %eax,%eax
80104ca5:	78 69                	js     80104d10 <sys_pipe+0x9b>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104caa:	e8 51 f4 ff ff       	call   80104100 <fdalloc>
80104caf:	89 c3                	mov    %eax,%ebx
80104cb1:	85 c0                	test   %eax,%eax
80104cb3:	78 21                	js     80104cd6 <sys_pipe+0x61>
80104cb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cb8:	e8 43 f4 ff ff       	call   80104100 <fdalloc>
80104cbd:	85 c0                	test   %eax,%eax
80104cbf:	78 15                	js     80104cd6 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104cc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cc4:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104cc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cc9:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104ccc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104cd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104cd4:	c9                   	leave  
80104cd5:	c3                   	ret    
    if(fd0 >= 0)
80104cd6:	85 db                	test   %ebx,%ebx
80104cd8:	79 20                	jns    80104cfa <sys_pipe+0x85>
    fileclose(rf);
80104cda:	83 ec 0c             	sub    $0xc,%esp
80104cdd:	ff 75 f0             	push   -0x10(%ebp)
80104ce0:	e8 bd bf ff ff       	call   80100ca2 <fileclose>
    fileclose(wf);
80104ce5:	83 c4 04             	add    $0x4,%esp
80104ce8:	ff 75 ec             	push   -0x14(%ebp)
80104ceb:	e8 b2 bf ff ff       	call   80100ca2 <fileclose>
    return -1;
80104cf0:	83 c4 10             	add    $0x10,%esp
80104cf3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cf8:	eb d7                	jmp    80104cd1 <sys_pipe+0x5c>
      myproc()->ofile[fd0] = 0;
80104cfa:	e8 3e e4 ff ff       	call   8010313d <myproc>
80104cff:	c7 44 98 34 00 00 00 	movl   $0x0,0x34(%eax,%ebx,4)
80104d06:	00 
80104d07:	eb d1                	jmp    80104cda <sys_pipe+0x65>
    return -1;
80104d09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d0e:	eb c1                	jmp    80104cd1 <sys_pipe+0x5c>
    return -1;
80104d10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d15:	eb ba                	jmp    80104cd1 <sys_pipe+0x5c>

80104d17 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104d17:	55                   	push   %ebp
80104d18:	89 e5                	mov    %esp,%ebp
80104d1a:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104d1d:	e8 91 e5 ff ff       	call   801032b3 <fork>
}
80104d22:	c9                   	leave  
80104d23:	c3                   	ret    

80104d24 <sys_exit>:
	Implementación del código de llamada al sistema para cuando un usuario
	realiza un exit(status)
*/
int
sys_exit(void)
{
80104d24:	55                   	push   %ebp
80104d25:	89 e5                	mov    %esp,%ebp
80104d27:	83 ec 20             	sub    $0x20,%esp
	//Para esta nueva implementación, vamos a recuperar el status
	//que puso el usuario como argumento y lo guardamos 
  int status; 

	//Puesto que es un valor entero, lo recuperamos de la pila (posición 0) con argint
  if(argint(0,&status) < 0)
80104d2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d2d:	50                   	push   %eax
80104d2e:	6a 00                	push   $0x0
80104d30:	e8 50 f2 ff ff       	call   80103f85 <argint>
80104d35:	83 c4 10             	add    $0x10,%esp
80104d38:	85 c0                	test   %eax,%eax
80104d3a:	78 1c                	js     80104d58 <sys_exit+0x34>
    return -1;

	//Desplazamos los  bits 8 posiciones a la izquierda
	status = status << 8;
80104d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d3f:	c1 e0 08             	shl    $0x8,%eax
80104d42:	89 45 f4             	mov    %eax,-0xc(%ebp)

  exit(status);//Llamamos a la función de salida del kernel
80104d45:	83 ec 0c             	sub    $0xc,%esp
80104d48:	50                   	push   %eax
80104d49:	e8 3f e9 ff ff       	call   8010368d <exit>
  return 0;  // not reached
80104d4e:	83 c4 10             	add    $0x10,%esp
80104d51:	b8 00 00 00 00       	mov    $0x0,%eax

}
80104d56:	c9                   	leave  
80104d57:	c3                   	ret    
    return -1;
80104d58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d5d:	eb f7                	jmp    80104d56 <sys_exit+0x32>

80104d5f <sys_wait>:
/*
	Implementación de la función wait(status) para un usuario
*/
int
sys_wait(void)
{
80104d5f:	55                   	push   %ebp
80104d60:	89 e5                	mov    %esp,%ebp
80104d62:	83 ec 1c             	sub    $0x1c,%esp
	*/
  int *status;
  int size = 4;//Tamaño de un entero
    
  //Recuperamos el valor con argptr puesto que no es un entero, sino un puntero a entero
	if(argptr(0,(void**) &status, size) < 0)
80104d65:	6a 04                	push   $0x4
80104d67:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d6a:	50                   	push   %eax
80104d6b:	6a 00                	push   $0x0
80104d6d:	e8 3b f2 ff ff       	call   80103fad <argptr>
80104d72:	83 c4 10             	add    $0x10,%esp
80104d75:	85 c0                	test   %eax,%eax
80104d77:	78 10                	js     80104d89 <sys_wait+0x2a>
    return -1;
  
	//Por último, llamamos a la función wait del kernel
  return wait(status);
80104d79:	83 ec 0c             	sub    $0xc,%esp
80104d7c:	ff 75 f4             	push   -0xc(%ebp)
80104d7f:	e8 aa ea ff ff       	call   8010382e <wait>
80104d84:	83 c4 10             	add    $0x10,%esp
}
80104d87:	c9                   	leave  
80104d88:	c3                   	ret    
    return -1;
80104d89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d8e:	eb f7                	jmp    80104d87 <sys_wait+0x28>

80104d90 <sys_kill>:

int
sys_kill(void)
{
80104d90:	55                   	push   %ebp
80104d91:	89 e5                	mov    %esp,%ebp
80104d93:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104d96:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d99:	50                   	push   %eax
80104d9a:	6a 00                	push   $0x0
80104d9c:	e8 e4 f1 ff ff       	call   80103f85 <argint>
80104da1:	83 c4 10             	add    $0x10,%esp
80104da4:	85 c0                	test   %eax,%eax
80104da6:	78 10                	js     80104db8 <sys_kill+0x28>
    return -1;
  return kill(pid);
80104da8:	83 ec 0c             	sub    $0xc,%esp
80104dab:	ff 75 f4             	push   -0xc(%ebp)
80104dae:	e8 85 eb ff ff       	call   80103938 <kill>
80104db3:	83 c4 10             	add    $0x10,%esp
}
80104db6:	c9                   	leave  
80104db7:	c3                   	ret    
    return -1;
80104db8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dbd:	eb f7                	jmp    80104db6 <sys_kill+0x26>

80104dbf <sys_getpid>:

int
sys_getpid(void)
{
80104dbf:	55                   	push   %ebp
80104dc0:	89 e5                	mov    %esp,%ebp
80104dc2:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104dc5:	e8 73 e3 ff ff       	call   8010313d <myproc>
80104dca:	8b 40 18             	mov    0x18(%eax),%eax
}
80104dcd:	c9                   	leave  
80104dce:	c3                   	ret    

80104dcf <sys_sbrk>:

int
sys_sbrk(void)
{
80104dcf:	55                   	push   %ebp
80104dd0:	89 e5                	mov    %esp,%ebp
80104dd2:	56                   	push   %esi
80104dd3:	53                   	push   %ebx
80104dd4:	83 ec 10             	sub    $0x10,%esp
	//La dirección que devolvemos siempre será la del tamaño 
	//actual del proceso, que es por donde está el heap 
	//actualmente (dirección de comienzo de la memoria libre)
  int n;//Valor que quiere reservar el usuario
	uint oldsz = myproc()->sz;
80104dd7:	e8 61 e3 ff ff       	call   8010313d <myproc>
80104ddc:	8b 58 08             	mov    0x8(%eax),%ebx
	uint newsz = oldsz;

	//Recuperamos el valor de n de la pila de usuario
  if(argint(0, &n) < 0)
80104ddf:	83 ec 08             	sub    $0x8,%esp
80104de2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104de5:	50                   	push   %eax
80104de6:	6a 00                	push   $0x0
80104de8:	e8 98 f1 ff ff       	call   80103f85 <argint>
80104ded:	83 c4 10             	add    $0x10,%esp
80104df0:	85 c0                	test   %eax,%eax
80104df2:	78 55                	js     80104e49 <sys_sbrk+0x7a>
    return -1;

	//Hacemos comprobación para que solo reserve hasta el KERNBASE
	if(oldsz + n > KERNBASE)
80104df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df7:	8d 34 18             	lea    (%eax,%ebx,1),%esi
80104dfa:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
80104e00:	77 4e                	ja     80104e50 <sys_sbrk+0x81>
		return -1;
	
	//Actualizamos el nuevo tamaño del proceso
	newsz = oldsz + n;
	
	if(n < 0)
80104e02:	85 c0                	test   %eax,%eax
80104e04:	78 21                	js     80104e27 <sys_sbrk+0x58>
	{//Desalojamos las páginas físicas ocupadas hasta ahora
		if((newsz = deallocuvm(myproc()->pgdir, oldsz, newsz)) == 0)
      return -1;
	}

  lcr3(V2P(myproc()->pgdir));  // Invalidate TLB. Cambia la tabla de páginas		
80104e06:	e8 32 e3 ff ff       	call   8010313d <myproc>
80104e0b:	8b 40 0c             	mov    0xc(%eax),%eax
80104e0e:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80104e13:	0f 22 d8             	mov    %eax,%cr3

	//Ahora actualizamos el tamaño del proceso
	myproc()->sz = newsz;
80104e16:	e8 22 e3 ff ff       	call   8010313d <myproc>
80104e1b:	89 70 08             	mov    %esi,0x8(%eax)
  
  return oldsz;
80104e1e:	89 d8                	mov    %ebx,%eax
}
80104e20:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104e23:	5b                   	pop    %ebx
80104e24:	5e                   	pop    %esi
80104e25:	5d                   	pop    %ebp
80104e26:	c3                   	ret    
		if((newsz = deallocuvm(myproc()->pgdir, oldsz, newsz)) == 0)
80104e27:	e8 11 e3 ff ff       	call   8010313d <myproc>
80104e2c:	83 ec 04             	sub    $0x4,%esp
80104e2f:	56                   	push   %esi
80104e30:	53                   	push   %ebx
80104e31:	ff 70 0c             	push   0xc(%eax)
80104e34:	e8 ff 16 00 00       	call   80106538 <deallocuvm>
80104e39:	89 c6                	mov    %eax,%esi
80104e3b:	83 c4 10             	add    $0x10,%esp
80104e3e:	85 c0                	test   %eax,%eax
80104e40:	75 c4                	jne    80104e06 <sys_sbrk+0x37>
      return -1;
80104e42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e47:	eb d7                	jmp    80104e20 <sys_sbrk+0x51>
    return -1;
80104e49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e4e:	eb d0                	jmp    80104e20 <sys_sbrk+0x51>
		return -1;
80104e50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e55:	eb c9                	jmp    80104e20 <sys_sbrk+0x51>

80104e57 <sys_sleep>:

int
sys_sleep(void)
{
80104e57:	55                   	push   %ebp
80104e58:	89 e5                	mov    %esp,%ebp
80104e5a:	53                   	push   %ebx
80104e5b:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104e5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e61:	50                   	push   %eax
80104e62:	6a 00                	push   $0x0
80104e64:	e8 1c f1 ff ff       	call   80103f85 <argint>
80104e69:	83 c4 10             	add    $0x10,%esp
80104e6c:	85 c0                	test   %eax,%eax
80104e6e:	78 75                	js     80104ee5 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104e70:	83 ec 0c             	sub    $0xc,%esp
80104e73:	68 80 3f 11 80       	push   $0x80113f80
80104e78:	e8 26 ee ff ff       	call   80103ca3 <acquire>
  ticks0 = ticks;
80104e7d:	8b 1d 60 3f 11 80    	mov    0x80113f60,%ebx
  while(ticks - ticks0 < n){
80104e83:	83 c4 10             	add    $0x10,%esp
80104e86:	a1 60 3f 11 80       	mov    0x80113f60,%eax
80104e8b:	29 d8                	sub    %ebx,%eax
80104e8d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104e90:	73 39                	jae    80104ecb <sys_sleep+0x74>
    if(myproc()->killed){
80104e92:	e8 a6 e2 ff ff       	call   8010313d <myproc>
80104e97:	83 78 30 00          	cmpl   $0x0,0x30(%eax)
80104e9b:	75 17                	jne    80104eb4 <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104e9d:	83 ec 08             	sub    $0x8,%esp
80104ea0:	68 80 3f 11 80       	push   $0x80113f80
80104ea5:	68 60 3f 11 80       	push   $0x80113f60
80104eaa:	e8 ee e8 ff ff       	call   8010379d <sleep>
80104eaf:	83 c4 10             	add    $0x10,%esp
80104eb2:	eb d2                	jmp    80104e86 <sys_sleep+0x2f>
      release(&tickslock);
80104eb4:	83 ec 0c             	sub    $0xc,%esp
80104eb7:	68 80 3f 11 80       	push   $0x80113f80
80104ebc:	e8 47 ee ff ff       	call   80103d08 <release>
      return -1;
80104ec1:	83 c4 10             	add    $0x10,%esp
80104ec4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ec9:	eb 15                	jmp    80104ee0 <sys_sleep+0x89>
  }
  release(&tickslock);
80104ecb:	83 ec 0c             	sub    $0xc,%esp
80104ece:	68 80 3f 11 80       	push   $0x80113f80
80104ed3:	e8 30 ee ff ff       	call   80103d08 <release>
  return 0;
80104ed8:	83 c4 10             	add    $0x10,%esp
80104edb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ee0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ee3:	c9                   	leave  
80104ee4:	c3                   	ret    
    return -1;
80104ee5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eea:	eb f4                	jmp    80104ee0 <sys_sleep+0x89>

80104eec <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104eec:	55                   	push   %ebp
80104eed:	89 e5                	mov    %esp,%ebp
80104eef:	53                   	push   %ebx
80104ef0:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104ef3:	68 80 3f 11 80       	push   $0x80113f80
80104ef8:	e8 a6 ed ff ff       	call   80103ca3 <acquire>
  xticks = ticks;
80104efd:	8b 1d 60 3f 11 80    	mov    0x80113f60,%ebx
  release(&tickslock);
80104f03:	c7 04 24 80 3f 11 80 	movl   $0x80113f80,(%esp)
80104f0a:	e8 f9 ed ff ff       	call   80103d08 <release>
  return xticks;
}
80104f0f:	89 d8                	mov    %ebx,%eax
80104f11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f14:	c9                   	leave  
80104f15:	c3                   	ret    

80104f16 <sys_date>:

//Implementación de llamada al sistema date para sacar la fecha actual por pantalla
//Devuelve 0 en caso de acabar correctamente y -1 en caso de fallo
int
sys_date(void)
{
80104f16:	55                   	push   %ebp
80104f17:	89 e5                	mov    %esp,%ebp
80104f19:	83 ec 1c             	sub    $0x1c,%esp
	//date tiene que recuperar el rtcdate de la pila del usuario
 	struct rtcdate *d;//Aquí vamos a guardar el argumento del usuario

 	//vamos a usar argptr para recuperar el rtcdate
 	if(argptr(0, (void **) &d, sizeof(struct rtcdate)) < 0){
80104f1c:	6a 18                	push   $0x18
80104f1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f21:	50                   	push   %eax
80104f22:	6a 00                	push   $0x0
80104f24:	e8 84 f0 ff ff       	call   80103fad <argptr>
80104f29:	83 c4 10             	add    $0x10,%esp
80104f2c:	85 c0                	test   %eax,%eax
80104f2e:	78 15                	js     80104f45 <sys_date+0x2f>
  	return -1;
 	}
 	//Ahora una vez recuperado el rtcdate solo tenemos que rellenarlo con los valores oportunos
	//Para ello usamos cmostime, que rellena los valores del rtcdate con la fecha actual 
 cmostime(d);
80104f30:	83 ec 0c             	sub    $0xc,%esp
80104f33:	ff 75 f4             	push   -0xc(%ebp)
80104f36:	e8 8b d4 ff ff       	call   801023c6 <cmostime>

 return 0;
80104f3b:	83 c4 10             	add    $0x10,%esp
80104f3e:	b8 00 00 00 00       	mov    $0x0,%eax

}
80104f43:	c9                   	leave  
80104f44:	c3                   	ret    
  	return -1;
80104f45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f4a:	eb f7                	jmp    80104f43 <sys_date+0x2d>

80104f4c <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104f4c:	1e                   	push   %ds
  pushl %es
80104f4d:	06                   	push   %es
  pushl %fs
80104f4e:	0f a0                	push   %fs
  pushl %gs
80104f50:	0f a8                	push   %gs
  pushal
80104f52:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104f53:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104f57:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104f59:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104f5b:	54                   	push   %esp
  call trap
80104f5c:	e8 2f 01 00 00       	call   80105090 <trap>
  addl $4, %esp
80104f61:	83 c4 04             	add    $0x4,%esp

80104f64 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104f64:	61                   	popa   
  popl %gs
80104f65:	0f a9                	pop    %gs
  popl %fs
80104f67:	0f a1                	pop    %fs
  popl %es
80104f69:	07                   	pop    %es
  popl %ds
80104f6a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104f6b:	83 c4 08             	add    $0x8,%esp
  iret
80104f6e:	cf                   	iret   

80104f6f <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104f6f:	55                   	push   %ebp
80104f70:	89 e5                	mov    %esp,%ebp
80104f72:	53                   	push   %ebx
80104f73:	83 ec 04             	sub    $0x4,%esp
  int i;

  for(i = 0; i < 256; i++)
80104f76:	b8 00 00 00 00       	mov    $0x0,%eax
80104f7b:	eb 72                	jmp    80104fef <tvinit+0x80>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104f7d:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80104f84:	66 89 0c c5 c0 3f 11 	mov    %cx,-0x7feec040(,%eax,8)
80104f8b:	80 
80104f8c:	66 c7 04 c5 c2 3f 11 	movw   $0x8,-0x7feec03e(,%eax,8)
80104f93:	80 08 00 
80104f96:	8a 14 c5 c4 3f 11 80 	mov    -0x7feec03c(,%eax,8),%dl
80104f9d:	83 e2 e0             	and    $0xffffffe0,%edx
80104fa0:	88 14 c5 c4 3f 11 80 	mov    %dl,-0x7feec03c(,%eax,8)
80104fa7:	c6 04 c5 c4 3f 11 80 	movb   $0x0,-0x7feec03c(,%eax,8)
80104fae:	00 
80104faf:	8a 14 c5 c5 3f 11 80 	mov    -0x7feec03b(,%eax,8),%dl
80104fb6:	83 e2 f0             	and    $0xfffffff0,%edx
80104fb9:	83 ca 0e             	or     $0xe,%edx
80104fbc:	88 14 c5 c5 3f 11 80 	mov    %dl,-0x7feec03b(,%eax,8)
80104fc3:	88 d3                	mov    %dl,%bl
80104fc5:	83 e3 ef             	and    $0xffffffef,%ebx
80104fc8:	88 1c c5 c5 3f 11 80 	mov    %bl,-0x7feec03b(,%eax,8)
80104fcf:	83 e2 8f             	and    $0xffffff8f,%edx
80104fd2:	88 14 c5 c5 3f 11 80 	mov    %dl,-0x7feec03b(,%eax,8)
80104fd9:	83 ca 80             	or     $0xffffff80,%edx
80104fdc:	88 14 c5 c5 3f 11 80 	mov    %dl,-0x7feec03b(,%eax,8)
80104fe3:	c1 e9 10             	shr    $0x10,%ecx
80104fe6:	66 89 0c c5 c6 3f 11 	mov    %cx,-0x7feec03a(,%eax,8)
80104fed:	80 
  for(i = 0; i < 256; i++)
80104fee:	40                   	inc    %eax
80104fef:	3d ff 00 00 00       	cmp    $0xff,%eax
80104ff4:	7e 87                	jle    80104f7d <tvinit+0xe>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104ff6:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80104ffc:	66 89 15 c0 41 11 80 	mov    %dx,0x801141c0
80105003:	66 c7 05 c2 41 11 80 	movw   $0x8,0x801141c2
8010500a:	08 00 
8010500c:	a0 c4 41 11 80       	mov    0x801141c4,%al
80105011:	83 e0 e0             	and    $0xffffffe0,%eax
80105014:	a2 c4 41 11 80       	mov    %al,0x801141c4
80105019:	c6 05 c4 41 11 80 00 	movb   $0x0,0x801141c4
80105020:	a0 c5 41 11 80       	mov    0x801141c5,%al
80105025:	83 c8 0f             	or     $0xf,%eax
80105028:	a2 c5 41 11 80       	mov    %al,0x801141c5
8010502d:	83 e0 ef             	and    $0xffffffef,%eax
80105030:	a2 c5 41 11 80       	mov    %al,0x801141c5
80105035:	88 c1                	mov    %al,%cl
80105037:	83 c9 60             	or     $0x60,%ecx
8010503a:	88 0d c5 41 11 80    	mov    %cl,0x801141c5
80105040:	83 c8 e0             	or     $0xffffffe0,%eax
80105043:	a2 c5 41 11 80       	mov    %al,0x801141c5
80105048:	c1 ea 10             	shr    $0x10,%edx
8010504b:	66 89 15 c6 41 11 80 	mov    %dx,0x801141c6

  initlock(&tickslock, "time");
80105052:	83 ec 08             	sub    $0x8,%esp
80105055:	68 e9 71 10 80       	push   $0x801071e9
8010505a:	68 80 3f 11 80       	push   $0x80113f80
8010505f:	e8 08 eb ff ff       	call   80103b6c <initlock>
}
80105064:	83 c4 10             	add    $0x10,%esp
80105067:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010506a:	c9                   	leave  
8010506b:	c3                   	ret    

8010506c <idtinit>:

void
idtinit(void)
{
8010506c:	55                   	push   %ebp
8010506d:	89 e5                	mov    %esp,%ebp
8010506f:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105072:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80105078:	b8 c0 3f 11 80       	mov    $0x80113fc0,%eax
8010507d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105081:	c1 e8 10             	shr    $0x10,%eax
80105084:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105088:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010508b:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
8010508e:	c9                   	leave  
8010508f:	c3                   	ret    

80105090 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105090:	55                   	push   %ebp
80105091:	89 e5                	mov    %esp,%ebp
80105093:	57                   	push   %edi
80105094:	56                   	push   %esi
80105095:	53                   	push   %ebx
80105096:	83 ec 2c             	sub    $0x2c,%esp
80105099:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//Declaramos la variable status, que toma el valor del número de trap
	int status = tf->trapno+1;	
8010509c:	8b 43 30             	mov    0x30(%ebx),%eax
8010509f:	8d 78 01             	lea    0x1(%eax),%edi

  if(tf->trapno == T_SYSCALL){
801050a2:	83 f8 40             	cmp    $0x40,%eax
801050a5:	74 13                	je     801050ba <trap+0x2a>
    if(myproc()->killed)
      exit(status);
    return;
  }

  switch(tf->trapno){
801050a7:	83 e8 0e             	sub    $0xe,%eax
801050aa:	83 f8 31             	cmp    $0x31,%eax
801050ad:	0f 87 11 02 00 00    	ja     801052c4 <trap+0x234>
801050b3:	ff 24 85 ec 72 10 80 	jmp    *-0x7fef8d14(,%eax,4)
    if(myproc()->killed)
801050ba:	e8 7e e0 ff ff       	call   8010313d <myproc>
801050bf:	83 78 30 00          	cmpl   $0x0,0x30(%eax)
801050c3:	75 2a                	jne    801050ef <trap+0x5f>
    myproc()->tf = tf;
801050c5:	e8 73 e0 ff ff       	call   8010313d <myproc>
801050ca:	89 58 20             	mov    %ebx,0x20(%eax)
    syscall();
801050cd:	e8 77 ef ff ff       	call   80104049 <syscall>
    if(myproc()->killed)
801050d2:	e8 66 e0 ff ff       	call   8010313d <myproc>
801050d7:	83 78 30 00          	cmpl   $0x0,0x30(%eax)
801050db:	0f 84 8a 00 00 00    	je     8010516b <trap+0xdb>
      exit(status);
801050e1:	83 ec 0c             	sub    $0xc,%esp
801050e4:	57                   	push   %edi
801050e5:	e8 a3 e5 ff ff       	call   8010368d <exit>
801050ea:	83 c4 10             	add    $0x10,%esp
    return;
801050ed:	eb 7c                	jmp    8010516b <trap+0xdb>
      exit(status);
801050ef:	83 ec 0c             	sub    $0xc,%esp
801050f2:	57                   	push   %edi
801050f3:	e8 95 e5 ff ff       	call   8010368d <exit>
801050f8:	83 c4 10             	add    $0x10,%esp
801050fb:	eb c8                	jmp    801050c5 <trap+0x35>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801050fd:	e8 0a e0 ff ff       	call   8010310c <cpuid>
80105102:	85 c0                	test   %eax,%eax
80105104:	74 6d                	je     80105173 <trap+0xe3>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80105106:	e8 06 d2 ff ff       	call   80102311 <lapiceoi>
  }//fin switch

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010510b:	e8 2d e0 ff ff       	call   8010313d <myproc>
80105110:	85 c0                	test   %eax,%eax
80105112:	74 1b                	je     8010512f <trap+0x9f>
80105114:	e8 24 e0 ff ff       	call   8010313d <myproc>
80105119:	83 78 30 00          	cmpl   $0x0,0x30(%eax)
8010511d:	74 10                	je     8010512f <trap+0x9f>
8010511f:	8b 43 3c             	mov    0x3c(%ebx),%eax
80105122:	83 e0 03             	and    $0x3,%eax
80105125:	66 83 f8 03          	cmp    $0x3,%ax
80105129:	0f 84 2d 02 00 00    	je     8010535c <trap+0x2cc>
    exit(status);

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010512f:	e8 09 e0 ff ff       	call   8010313d <myproc>
80105134:	85 c0                	test   %eax,%eax
80105136:	74 0f                	je     80105147 <trap+0xb7>
80105138:	e8 00 e0 ff ff       	call   8010313d <myproc>
8010513d:	83 78 14 04          	cmpl   $0x4,0x14(%eax)
80105141:	0f 84 26 02 00 00    	je     8010536d <trap+0x2dd>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105147:	e8 f1 df ff ff       	call   8010313d <myproc>
8010514c:	85 c0                	test   %eax,%eax
8010514e:	74 1b                	je     8010516b <trap+0xdb>
80105150:	e8 e8 df ff ff       	call   8010313d <myproc>
80105155:	83 78 30 00          	cmpl   $0x0,0x30(%eax)
80105159:	74 10                	je     8010516b <trap+0xdb>
8010515b:	8b 43 3c             	mov    0x3c(%ebx),%eax
8010515e:	83 e0 03             	and    $0x3,%eax
80105161:	66 83 f8 03          	cmp    $0x3,%ax
80105165:	0f 84 16 02 00 00    	je     80105381 <trap+0x2f1>
    exit(status);
}
8010516b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010516e:	5b                   	pop    %ebx
8010516f:	5e                   	pop    %esi
80105170:	5f                   	pop    %edi
80105171:	5d                   	pop    %ebp
80105172:	c3                   	ret    
      acquire(&tickslock);
80105173:	83 ec 0c             	sub    $0xc,%esp
80105176:	68 80 3f 11 80       	push   $0x80113f80
8010517b:	e8 23 eb ff ff       	call   80103ca3 <acquire>
      ticks++;
80105180:	ff 05 60 3f 11 80    	incl   0x80113f60
      wakeup(&ticks);
80105186:	c7 04 24 60 3f 11 80 	movl   $0x80113f60,(%esp)
8010518d:	e8 7d e7 ff ff       	call   8010390f <wakeup>
      release(&tickslock);
80105192:	c7 04 24 80 3f 11 80 	movl   $0x80113f80,(%esp)
80105199:	e8 6a eb ff ff       	call   80103d08 <release>
8010519e:	83 c4 10             	add    $0x10,%esp
801051a1:	e9 60 ff ff ff       	jmp    80105106 <trap+0x76>
    ideintr();
801051a6:	e8 4f cb ff ff       	call   80101cfa <ideintr>
    lapiceoi();
801051ab:	e8 61 d1 ff ff       	call   80102311 <lapiceoi>
    break;
801051b0:	e9 56 ff ff ff       	jmp    8010510b <trap+0x7b>
    kbdintr();
801051b5:	e8 a1 cf ff ff       	call   8010215b <kbdintr>
    lapiceoi();
801051ba:	e8 52 d1 ff ff       	call   80102311 <lapiceoi>
    break;
801051bf:	e9 47 ff ff ff       	jmp    8010510b <trap+0x7b>
    uartintr();
801051c4:	e8 c5 02 00 00       	call   8010548e <uartintr>
    lapiceoi();
801051c9:	e8 43 d1 ff ff       	call   80102311 <lapiceoi>
    break;
801051ce:	e9 38 ff ff ff       	jmp    8010510b <trap+0x7b>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801051d3:	8b 43 38             	mov    0x38(%ebx),%eax
801051d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            cpuid(), tf->cs, tf->eip);
801051d9:	8b 73 3c             	mov    0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801051dc:	e8 2b df ff ff       	call   8010310c <cpuid>
801051e1:	ff 75 e4             	push   -0x1c(%ebp)
801051e4:	0f b7 f6             	movzwl %si,%esi
801051e7:	56                   	push   %esi
801051e8:	50                   	push   %eax
801051e9:	68 28 72 10 80       	push   $0x80107228
801051ee:	e8 e7 b3 ff ff       	call   801005da <cprintf>
    lapiceoi();
801051f3:	e8 19 d1 ff ff       	call   80102311 <lapiceoi>
    break;
801051f8:	83 c4 10             	add    $0x10,%esp
801051fb:	e9 0b ff ff ff       	jmp    8010510b <trap+0x7b>
		if(tf->err == 7){//Solo fallamos ante violación de privilegios
80105200:	8b 43 34             	mov    0x34(%ebx),%eax
80105203:	83 f8 07             	cmp    $0x7,%eax
80105206:	74 79                	je     80105281 <trap+0x1f1>
		char *mem = kalloc();
80105208:	e8 32 ce ff ff       	call   8010203f <kalloc>
8010520d:	89 c6                	mov    %eax,%esi
    if(mem == 0)
8010520f:	85 c0                	test   %eax,%eax
80105211:	0f 84 8c 00 00 00    	je     801052a3 <trap+0x213>
		memset(mem, 0, PGSIZE);
80105217:	83 ec 04             	sub    $0x4,%esp
8010521a:	68 00 10 00 00       	push   $0x1000
8010521f:	6a 00                	push   $0x0
80105221:	50                   	push   %eax
80105222:	e8 28 eb ff ff       	call   80103d4f <memset>
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105227:	0f 20 d0             	mov    %cr2,%eax
    if(mappages(myproc()->pgdir, (char *)PGROUNDDOWN(rcr2()), PGSIZE, V2P(mem), PTE_W | PTE_U) <0)
8010522a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010522f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105232:	e8 06 df ff ff       	call   8010313d <myproc>
80105237:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
8010523e:	81 c6 00 00 00 80    	add    $0x80000000,%esi
80105244:	56                   	push   %esi
80105245:	68 00 10 00 00       	push   $0x1000
8010524a:	ff 75 e4             	push   -0x1c(%ebp)
8010524d:	ff 70 0c             	push   0xc(%eax)
80105250:	e8 01 10 00 00       	call   80106256 <mappages>
80105255:	83 c4 20             	add    $0x20,%esp
80105258:	85 c0                	test   %eax,%eax
8010525a:	0f 89 ab fe ff ff    	jns    8010510b <trap+0x7b>
      cprintf("mappages: out of memory\n");
80105260:	83 ec 0c             	sub    $0xc,%esp
80105263:	68 08 72 10 80       	push   $0x80107208
80105268:	e8 6d b3 ff ff       	call   801005da <cprintf>
      myproc()->killed = 1;
8010526d:	e8 cb de ff ff       	call   8010313d <myproc>
80105272:	c7 40 30 01 00 00 00 	movl   $0x1,0x30(%eax)
      break;
80105279:	83 c4 10             	add    $0x10,%esp
8010527c:	e9 8a fe ff ff       	jmp    8010510b <trap+0x7b>
			cprintf("\nPage Fault: No Permission . Error %d\n",tf->err);
80105281:	83 ec 08             	sub    $0x8,%esp
80105284:	50                   	push   %eax
80105285:	68 4c 72 10 80       	push   $0x8010724c
8010528a:	e8 4b b3 ff ff       	call   801005da <cprintf>
			myproc()->killed = 1;
8010528f:	e8 a9 de ff ff       	call   8010313d <myproc>
80105294:	c7 40 30 01 00 00 00 	movl   $0x1,0x30(%eax)
			break;
8010529b:	83 c4 10             	add    $0x10,%esp
8010529e:	e9 68 fe ff ff       	jmp    8010510b <trap+0x7b>
      cprintf("kalloc didn't alloc page\n");
801052a3:	83 ec 0c             	sub    $0xc,%esp
801052a6:	68 ee 71 10 80       	push   $0x801071ee
801052ab:	e8 2a b3 ff ff       	call   801005da <cprintf>
      myproc()->killed = 1;
801052b0:	e8 88 de ff ff       	call   8010313d <myproc>
801052b5:	c7 40 30 01 00 00 00 	movl   $0x1,0x30(%eax)
      break;
801052bc:	83 c4 10             	add    $0x10,%esp
801052bf:	e9 47 fe ff ff       	jmp    8010510b <trap+0x7b>
    if(myproc() == 0 || (tf->cs&3) == 0){
801052c4:	e8 74 de ff ff       	call   8010313d <myproc>
801052c9:	85 c0                	test   %eax,%eax
801052cb:	74 64                	je     80105331 <trap+0x2a1>
801052cd:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
801052d1:	74 5e                	je     80105331 <trap+0x2a1>
801052d3:	0f 20 d0             	mov    %cr2,%eax
801052d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801052d9:	8b 53 38             	mov    0x38(%ebx),%edx
801052dc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801052df:	e8 28 de ff ff       	call   8010310c <cpuid>
801052e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
801052e7:	8b 4b 34             	mov    0x34(%ebx),%ecx
801052ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
801052ed:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
801052f0:	e8 48 de ff ff       	call   8010313d <myproc>
801052f5:	8d 50 78             	lea    0x78(%eax),%edx
801052f8:	89 55 d8             	mov    %edx,-0x28(%ebp)
801052fb:	e8 3d de ff ff       	call   8010313d <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105300:	ff 75 d4             	push   -0x2c(%ebp)
80105303:	ff 75 e4             	push   -0x1c(%ebp)
80105306:	ff 75 e0             	push   -0x20(%ebp)
80105309:	ff 75 dc             	push   -0x24(%ebp)
8010530c:	56                   	push   %esi
8010530d:	ff 75 d8             	push   -0x28(%ebp)
80105310:	ff 70 18             	push   0x18(%eax)
80105313:	68 a8 72 10 80       	push   $0x801072a8
80105318:	e8 bd b2 ff ff       	call   801005da <cprintf>
    myproc()->killed = 1;
8010531d:	83 c4 20             	add    $0x20,%esp
80105320:	e8 18 de ff ff       	call   8010313d <myproc>
80105325:	c7 40 30 01 00 00 00 	movl   $0x1,0x30(%eax)
8010532c:	e9 da fd ff ff       	jmp    8010510b <trap+0x7b>
80105331:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105334:	8b 73 38             	mov    0x38(%ebx),%esi
80105337:	e8 d0 dd ff ff       	call   8010310c <cpuid>
8010533c:	83 ec 0c             	sub    $0xc,%esp
8010533f:	57                   	push   %edi
80105340:	56                   	push   %esi
80105341:	50                   	push   %eax
80105342:	ff 73 30             	push   0x30(%ebx)
80105345:	68 74 72 10 80       	push   $0x80107274
8010534a:	e8 8b b2 ff ff       	call   801005da <cprintf>
      panic("trap");
8010534f:	83 c4 14             	add    $0x14,%esp
80105352:	68 21 72 10 80       	push   $0x80107221
80105357:	e8 e5 af ff ff       	call   80100341 <panic>
    exit(status);
8010535c:	83 ec 0c             	sub    $0xc,%esp
8010535f:	57                   	push   %edi
80105360:	e8 28 e3 ff ff       	call   8010368d <exit>
80105365:	83 c4 10             	add    $0x10,%esp
80105368:	e9 c2 fd ff ff       	jmp    8010512f <trap+0x9f>
  if(myproc() && myproc()->state == RUNNING &&
8010536d:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105371:	0f 85 d0 fd ff ff    	jne    80105147 <trap+0xb7>
    yield();
80105377:	e8 ef e3 ff ff       	call   8010376b <yield>
8010537c:	e9 c6 fd ff ff       	jmp    80105147 <trap+0xb7>
    exit(status);
80105381:	83 ec 0c             	sub    $0xc,%esp
80105384:	57                   	push   %edi
80105385:	e8 03 e3 ff ff       	call   8010368d <exit>
8010538a:	83 c4 10             	add    $0x10,%esp
8010538d:	e9 d9 fd ff ff       	jmp    8010516b <trap+0xdb>

80105392 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80105392:	83 3d c0 47 11 80 00 	cmpl   $0x0,0x801147c0
80105399:	74 14                	je     801053af <uartgetc+0x1d>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010539b:	ba fd 03 00 00       	mov    $0x3fd,%edx
801053a0:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801053a1:	a8 01                	test   $0x1,%al
801053a3:	74 10                	je     801053b5 <uartgetc+0x23>
801053a5:	ba f8 03 00 00       	mov    $0x3f8,%edx
801053aa:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801053ab:	0f b6 c0             	movzbl %al,%eax
801053ae:	c3                   	ret    
    return -1;
801053af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053b4:	c3                   	ret    
    return -1;
801053b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801053ba:	c3                   	ret    

801053bb <uartputc>:
  if(!uart)
801053bb:	83 3d c0 47 11 80 00 	cmpl   $0x0,0x801147c0
801053c2:	74 39                	je     801053fd <uartputc+0x42>
{
801053c4:	55                   	push   %ebp
801053c5:	89 e5                	mov    %esp,%ebp
801053c7:	53                   	push   %ebx
801053c8:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801053cb:	bb 00 00 00 00       	mov    $0x0,%ebx
801053d0:	eb 0e                	jmp    801053e0 <uartputc+0x25>
    microdelay(10);
801053d2:	83 ec 0c             	sub    $0xc,%esp
801053d5:	6a 0a                	push   $0xa
801053d7:	e8 56 cf ff ff       	call   80102332 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801053dc:	43                   	inc    %ebx
801053dd:	83 c4 10             	add    $0x10,%esp
801053e0:	83 fb 7f             	cmp    $0x7f,%ebx
801053e3:	7f 0a                	jg     801053ef <uartputc+0x34>
801053e5:	ba fd 03 00 00       	mov    $0x3fd,%edx
801053ea:	ec                   	in     (%dx),%al
801053eb:	a8 20                	test   $0x20,%al
801053ed:	74 e3                	je     801053d2 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801053ef:	8b 45 08             	mov    0x8(%ebp),%eax
801053f2:	ba f8 03 00 00       	mov    $0x3f8,%edx
801053f7:	ee                   	out    %al,(%dx)
}
801053f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801053fb:	c9                   	leave  
801053fc:	c3                   	ret    
801053fd:	c3                   	ret    

801053fe <uartinit>:
{
801053fe:	55                   	push   %ebp
801053ff:	89 e5                	mov    %esp,%ebp
80105401:	56                   	push   %esi
80105402:	53                   	push   %ebx
80105403:	b1 00                	mov    $0x0,%cl
80105405:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010540a:	88 c8                	mov    %cl,%al
8010540c:	ee                   	out    %al,(%dx)
8010540d:	be fb 03 00 00       	mov    $0x3fb,%esi
80105412:	b0 80                	mov    $0x80,%al
80105414:	89 f2                	mov    %esi,%edx
80105416:	ee                   	out    %al,(%dx)
80105417:	b0 0c                	mov    $0xc,%al
80105419:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010541e:	ee                   	out    %al,(%dx)
8010541f:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105424:	88 c8                	mov    %cl,%al
80105426:	89 da                	mov    %ebx,%edx
80105428:	ee                   	out    %al,(%dx)
80105429:	b0 03                	mov    $0x3,%al
8010542b:	89 f2                	mov    %esi,%edx
8010542d:	ee                   	out    %al,(%dx)
8010542e:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105433:	88 c8                	mov    %cl,%al
80105435:	ee                   	out    %al,(%dx)
80105436:	b0 01                	mov    $0x1,%al
80105438:	89 da                	mov    %ebx,%edx
8010543a:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010543b:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105440:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105441:	3c ff                	cmp    $0xff,%al
80105443:	74 42                	je     80105487 <uartinit+0x89>
  uart = 1;
80105445:	c7 05 c0 47 11 80 01 	movl   $0x1,0x801147c0
8010544c:	00 00 00 
8010544f:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105454:	ec                   	in     (%dx),%al
80105455:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010545a:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
8010545b:	83 ec 08             	sub    $0x8,%esp
8010545e:	6a 00                	push   $0x0
80105460:	6a 04                	push   $0x4
80105462:	e8 96 ca ff ff       	call   80101efd <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105467:	83 c4 10             	add    $0x10,%esp
8010546a:	bb b4 73 10 80       	mov    $0x801073b4,%ebx
8010546f:	eb 10                	jmp    80105481 <uartinit+0x83>
    uartputc(*p);
80105471:	83 ec 0c             	sub    $0xc,%esp
80105474:	0f be c0             	movsbl %al,%eax
80105477:	50                   	push   %eax
80105478:	e8 3e ff ff ff       	call   801053bb <uartputc>
  for(p="xv6...\n"; *p; p++)
8010547d:	43                   	inc    %ebx
8010547e:	83 c4 10             	add    $0x10,%esp
80105481:	8a 03                	mov    (%ebx),%al
80105483:	84 c0                	test   %al,%al
80105485:	75 ea                	jne    80105471 <uartinit+0x73>
}
80105487:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010548a:	5b                   	pop    %ebx
8010548b:	5e                   	pop    %esi
8010548c:	5d                   	pop    %ebp
8010548d:	c3                   	ret    

8010548e <uartintr>:

void
uartintr(void)
{
8010548e:	55                   	push   %ebp
8010548f:	89 e5                	mov    %esp,%ebp
80105491:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105494:	68 92 53 10 80       	push   $0x80105392
80105499:	e8 61 b2 ff ff       	call   801006ff <consoleintr>
}
8010549e:	83 c4 10             	add    $0x10,%esp
801054a1:	c9                   	leave  
801054a2:	c3                   	ret    

801054a3 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801054a3:	6a 00                	push   $0x0
  pushl $0
801054a5:	6a 00                	push   $0x0
  jmp alltraps
801054a7:	e9 a0 fa ff ff       	jmp    80104f4c <alltraps>

801054ac <vector1>:
.globl vector1
vector1:
  pushl $0
801054ac:	6a 00                	push   $0x0
  pushl $1
801054ae:	6a 01                	push   $0x1
  jmp alltraps
801054b0:	e9 97 fa ff ff       	jmp    80104f4c <alltraps>

801054b5 <vector2>:
.globl vector2
vector2:
  pushl $0
801054b5:	6a 00                	push   $0x0
  pushl $2
801054b7:	6a 02                	push   $0x2
  jmp alltraps
801054b9:	e9 8e fa ff ff       	jmp    80104f4c <alltraps>

801054be <vector3>:
.globl vector3
vector3:
  pushl $0
801054be:	6a 00                	push   $0x0
  pushl $3
801054c0:	6a 03                	push   $0x3
  jmp alltraps
801054c2:	e9 85 fa ff ff       	jmp    80104f4c <alltraps>

801054c7 <vector4>:
.globl vector4
vector4:
  pushl $0
801054c7:	6a 00                	push   $0x0
  pushl $4
801054c9:	6a 04                	push   $0x4
  jmp alltraps
801054cb:	e9 7c fa ff ff       	jmp    80104f4c <alltraps>

801054d0 <vector5>:
.globl vector5
vector5:
  pushl $0
801054d0:	6a 00                	push   $0x0
  pushl $5
801054d2:	6a 05                	push   $0x5
  jmp alltraps
801054d4:	e9 73 fa ff ff       	jmp    80104f4c <alltraps>

801054d9 <vector6>:
.globl vector6
vector6:
  pushl $0
801054d9:	6a 00                	push   $0x0
  pushl $6
801054db:	6a 06                	push   $0x6
  jmp alltraps
801054dd:	e9 6a fa ff ff       	jmp    80104f4c <alltraps>

801054e2 <vector7>:
.globl vector7
vector7:
  pushl $0
801054e2:	6a 00                	push   $0x0
  pushl $7
801054e4:	6a 07                	push   $0x7
  jmp alltraps
801054e6:	e9 61 fa ff ff       	jmp    80104f4c <alltraps>

801054eb <vector8>:
.globl vector8
vector8:
  pushl $8
801054eb:	6a 08                	push   $0x8
  jmp alltraps
801054ed:	e9 5a fa ff ff       	jmp    80104f4c <alltraps>

801054f2 <vector9>:
.globl vector9
vector9:
  pushl $0
801054f2:	6a 00                	push   $0x0
  pushl $9
801054f4:	6a 09                	push   $0x9
  jmp alltraps
801054f6:	e9 51 fa ff ff       	jmp    80104f4c <alltraps>

801054fb <vector10>:
.globl vector10
vector10:
  pushl $10
801054fb:	6a 0a                	push   $0xa
  jmp alltraps
801054fd:	e9 4a fa ff ff       	jmp    80104f4c <alltraps>

80105502 <vector11>:
.globl vector11
vector11:
  pushl $11
80105502:	6a 0b                	push   $0xb
  jmp alltraps
80105504:	e9 43 fa ff ff       	jmp    80104f4c <alltraps>

80105509 <vector12>:
.globl vector12
vector12:
  pushl $12
80105509:	6a 0c                	push   $0xc
  jmp alltraps
8010550b:	e9 3c fa ff ff       	jmp    80104f4c <alltraps>

80105510 <vector13>:
.globl vector13
vector13:
  pushl $13
80105510:	6a 0d                	push   $0xd
  jmp alltraps
80105512:	e9 35 fa ff ff       	jmp    80104f4c <alltraps>

80105517 <vector14>:
.globl vector14
vector14:
  pushl $14
80105517:	6a 0e                	push   $0xe
  jmp alltraps
80105519:	e9 2e fa ff ff       	jmp    80104f4c <alltraps>

8010551e <vector15>:
.globl vector15
vector15:
  pushl $0
8010551e:	6a 00                	push   $0x0
  pushl $15
80105520:	6a 0f                	push   $0xf
  jmp alltraps
80105522:	e9 25 fa ff ff       	jmp    80104f4c <alltraps>

80105527 <vector16>:
.globl vector16
vector16:
  pushl $0
80105527:	6a 00                	push   $0x0
  pushl $16
80105529:	6a 10                	push   $0x10
  jmp alltraps
8010552b:	e9 1c fa ff ff       	jmp    80104f4c <alltraps>

80105530 <vector17>:
.globl vector17
vector17:
  pushl $17
80105530:	6a 11                	push   $0x11
  jmp alltraps
80105532:	e9 15 fa ff ff       	jmp    80104f4c <alltraps>

80105537 <vector18>:
.globl vector18
vector18:
  pushl $0
80105537:	6a 00                	push   $0x0
  pushl $18
80105539:	6a 12                	push   $0x12
  jmp alltraps
8010553b:	e9 0c fa ff ff       	jmp    80104f4c <alltraps>

80105540 <vector19>:
.globl vector19
vector19:
  pushl $0
80105540:	6a 00                	push   $0x0
  pushl $19
80105542:	6a 13                	push   $0x13
  jmp alltraps
80105544:	e9 03 fa ff ff       	jmp    80104f4c <alltraps>

80105549 <vector20>:
.globl vector20
vector20:
  pushl $0
80105549:	6a 00                	push   $0x0
  pushl $20
8010554b:	6a 14                	push   $0x14
  jmp alltraps
8010554d:	e9 fa f9 ff ff       	jmp    80104f4c <alltraps>

80105552 <vector21>:
.globl vector21
vector21:
  pushl $0
80105552:	6a 00                	push   $0x0
  pushl $21
80105554:	6a 15                	push   $0x15
  jmp alltraps
80105556:	e9 f1 f9 ff ff       	jmp    80104f4c <alltraps>

8010555b <vector22>:
.globl vector22
vector22:
  pushl $0
8010555b:	6a 00                	push   $0x0
  pushl $22
8010555d:	6a 16                	push   $0x16
  jmp alltraps
8010555f:	e9 e8 f9 ff ff       	jmp    80104f4c <alltraps>

80105564 <vector23>:
.globl vector23
vector23:
  pushl $0
80105564:	6a 00                	push   $0x0
  pushl $23
80105566:	6a 17                	push   $0x17
  jmp alltraps
80105568:	e9 df f9 ff ff       	jmp    80104f4c <alltraps>

8010556d <vector24>:
.globl vector24
vector24:
  pushl $0
8010556d:	6a 00                	push   $0x0
  pushl $24
8010556f:	6a 18                	push   $0x18
  jmp alltraps
80105571:	e9 d6 f9 ff ff       	jmp    80104f4c <alltraps>

80105576 <vector25>:
.globl vector25
vector25:
  pushl $0
80105576:	6a 00                	push   $0x0
  pushl $25
80105578:	6a 19                	push   $0x19
  jmp alltraps
8010557a:	e9 cd f9 ff ff       	jmp    80104f4c <alltraps>

8010557f <vector26>:
.globl vector26
vector26:
  pushl $0
8010557f:	6a 00                	push   $0x0
  pushl $26
80105581:	6a 1a                	push   $0x1a
  jmp alltraps
80105583:	e9 c4 f9 ff ff       	jmp    80104f4c <alltraps>

80105588 <vector27>:
.globl vector27
vector27:
  pushl $0
80105588:	6a 00                	push   $0x0
  pushl $27
8010558a:	6a 1b                	push   $0x1b
  jmp alltraps
8010558c:	e9 bb f9 ff ff       	jmp    80104f4c <alltraps>

80105591 <vector28>:
.globl vector28
vector28:
  pushl $0
80105591:	6a 00                	push   $0x0
  pushl $28
80105593:	6a 1c                	push   $0x1c
  jmp alltraps
80105595:	e9 b2 f9 ff ff       	jmp    80104f4c <alltraps>

8010559a <vector29>:
.globl vector29
vector29:
  pushl $0
8010559a:	6a 00                	push   $0x0
  pushl $29
8010559c:	6a 1d                	push   $0x1d
  jmp alltraps
8010559e:	e9 a9 f9 ff ff       	jmp    80104f4c <alltraps>

801055a3 <vector30>:
.globl vector30
vector30:
  pushl $0
801055a3:	6a 00                	push   $0x0
  pushl $30
801055a5:	6a 1e                	push   $0x1e
  jmp alltraps
801055a7:	e9 a0 f9 ff ff       	jmp    80104f4c <alltraps>

801055ac <vector31>:
.globl vector31
vector31:
  pushl $0
801055ac:	6a 00                	push   $0x0
  pushl $31
801055ae:	6a 1f                	push   $0x1f
  jmp alltraps
801055b0:	e9 97 f9 ff ff       	jmp    80104f4c <alltraps>

801055b5 <vector32>:
.globl vector32
vector32:
  pushl $0
801055b5:	6a 00                	push   $0x0
  pushl $32
801055b7:	6a 20                	push   $0x20
  jmp alltraps
801055b9:	e9 8e f9 ff ff       	jmp    80104f4c <alltraps>

801055be <vector33>:
.globl vector33
vector33:
  pushl $0
801055be:	6a 00                	push   $0x0
  pushl $33
801055c0:	6a 21                	push   $0x21
  jmp alltraps
801055c2:	e9 85 f9 ff ff       	jmp    80104f4c <alltraps>

801055c7 <vector34>:
.globl vector34
vector34:
  pushl $0
801055c7:	6a 00                	push   $0x0
  pushl $34
801055c9:	6a 22                	push   $0x22
  jmp alltraps
801055cb:	e9 7c f9 ff ff       	jmp    80104f4c <alltraps>

801055d0 <vector35>:
.globl vector35
vector35:
  pushl $0
801055d0:	6a 00                	push   $0x0
  pushl $35
801055d2:	6a 23                	push   $0x23
  jmp alltraps
801055d4:	e9 73 f9 ff ff       	jmp    80104f4c <alltraps>

801055d9 <vector36>:
.globl vector36
vector36:
  pushl $0
801055d9:	6a 00                	push   $0x0
  pushl $36
801055db:	6a 24                	push   $0x24
  jmp alltraps
801055dd:	e9 6a f9 ff ff       	jmp    80104f4c <alltraps>

801055e2 <vector37>:
.globl vector37
vector37:
  pushl $0
801055e2:	6a 00                	push   $0x0
  pushl $37
801055e4:	6a 25                	push   $0x25
  jmp alltraps
801055e6:	e9 61 f9 ff ff       	jmp    80104f4c <alltraps>

801055eb <vector38>:
.globl vector38
vector38:
  pushl $0
801055eb:	6a 00                	push   $0x0
  pushl $38
801055ed:	6a 26                	push   $0x26
  jmp alltraps
801055ef:	e9 58 f9 ff ff       	jmp    80104f4c <alltraps>

801055f4 <vector39>:
.globl vector39
vector39:
  pushl $0
801055f4:	6a 00                	push   $0x0
  pushl $39
801055f6:	6a 27                	push   $0x27
  jmp alltraps
801055f8:	e9 4f f9 ff ff       	jmp    80104f4c <alltraps>

801055fd <vector40>:
.globl vector40
vector40:
  pushl $0
801055fd:	6a 00                	push   $0x0
  pushl $40
801055ff:	6a 28                	push   $0x28
  jmp alltraps
80105601:	e9 46 f9 ff ff       	jmp    80104f4c <alltraps>

80105606 <vector41>:
.globl vector41
vector41:
  pushl $0
80105606:	6a 00                	push   $0x0
  pushl $41
80105608:	6a 29                	push   $0x29
  jmp alltraps
8010560a:	e9 3d f9 ff ff       	jmp    80104f4c <alltraps>

8010560f <vector42>:
.globl vector42
vector42:
  pushl $0
8010560f:	6a 00                	push   $0x0
  pushl $42
80105611:	6a 2a                	push   $0x2a
  jmp alltraps
80105613:	e9 34 f9 ff ff       	jmp    80104f4c <alltraps>

80105618 <vector43>:
.globl vector43
vector43:
  pushl $0
80105618:	6a 00                	push   $0x0
  pushl $43
8010561a:	6a 2b                	push   $0x2b
  jmp alltraps
8010561c:	e9 2b f9 ff ff       	jmp    80104f4c <alltraps>

80105621 <vector44>:
.globl vector44
vector44:
  pushl $0
80105621:	6a 00                	push   $0x0
  pushl $44
80105623:	6a 2c                	push   $0x2c
  jmp alltraps
80105625:	e9 22 f9 ff ff       	jmp    80104f4c <alltraps>

8010562a <vector45>:
.globl vector45
vector45:
  pushl $0
8010562a:	6a 00                	push   $0x0
  pushl $45
8010562c:	6a 2d                	push   $0x2d
  jmp alltraps
8010562e:	e9 19 f9 ff ff       	jmp    80104f4c <alltraps>

80105633 <vector46>:
.globl vector46
vector46:
  pushl $0
80105633:	6a 00                	push   $0x0
  pushl $46
80105635:	6a 2e                	push   $0x2e
  jmp alltraps
80105637:	e9 10 f9 ff ff       	jmp    80104f4c <alltraps>

8010563c <vector47>:
.globl vector47
vector47:
  pushl $0
8010563c:	6a 00                	push   $0x0
  pushl $47
8010563e:	6a 2f                	push   $0x2f
  jmp alltraps
80105640:	e9 07 f9 ff ff       	jmp    80104f4c <alltraps>

80105645 <vector48>:
.globl vector48
vector48:
  pushl $0
80105645:	6a 00                	push   $0x0
  pushl $48
80105647:	6a 30                	push   $0x30
  jmp alltraps
80105649:	e9 fe f8 ff ff       	jmp    80104f4c <alltraps>

8010564e <vector49>:
.globl vector49
vector49:
  pushl $0
8010564e:	6a 00                	push   $0x0
  pushl $49
80105650:	6a 31                	push   $0x31
  jmp alltraps
80105652:	e9 f5 f8 ff ff       	jmp    80104f4c <alltraps>

80105657 <vector50>:
.globl vector50
vector50:
  pushl $0
80105657:	6a 00                	push   $0x0
  pushl $50
80105659:	6a 32                	push   $0x32
  jmp alltraps
8010565b:	e9 ec f8 ff ff       	jmp    80104f4c <alltraps>

80105660 <vector51>:
.globl vector51
vector51:
  pushl $0
80105660:	6a 00                	push   $0x0
  pushl $51
80105662:	6a 33                	push   $0x33
  jmp alltraps
80105664:	e9 e3 f8 ff ff       	jmp    80104f4c <alltraps>

80105669 <vector52>:
.globl vector52
vector52:
  pushl $0
80105669:	6a 00                	push   $0x0
  pushl $52
8010566b:	6a 34                	push   $0x34
  jmp alltraps
8010566d:	e9 da f8 ff ff       	jmp    80104f4c <alltraps>

80105672 <vector53>:
.globl vector53
vector53:
  pushl $0
80105672:	6a 00                	push   $0x0
  pushl $53
80105674:	6a 35                	push   $0x35
  jmp alltraps
80105676:	e9 d1 f8 ff ff       	jmp    80104f4c <alltraps>

8010567b <vector54>:
.globl vector54
vector54:
  pushl $0
8010567b:	6a 00                	push   $0x0
  pushl $54
8010567d:	6a 36                	push   $0x36
  jmp alltraps
8010567f:	e9 c8 f8 ff ff       	jmp    80104f4c <alltraps>

80105684 <vector55>:
.globl vector55
vector55:
  pushl $0
80105684:	6a 00                	push   $0x0
  pushl $55
80105686:	6a 37                	push   $0x37
  jmp alltraps
80105688:	e9 bf f8 ff ff       	jmp    80104f4c <alltraps>

8010568d <vector56>:
.globl vector56
vector56:
  pushl $0
8010568d:	6a 00                	push   $0x0
  pushl $56
8010568f:	6a 38                	push   $0x38
  jmp alltraps
80105691:	e9 b6 f8 ff ff       	jmp    80104f4c <alltraps>

80105696 <vector57>:
.globl vector57
vector57:
  pushl $0
80105696:	6a 00                	push   $0x0
  pushl $57
80105698:	6a 39                	push   $0x39
  jmp alltraps
8010569a:	e9 ad f8 ff ff       	jmp    80104f4c <alltraps>

8010569f <vector58>:
.globl vector58
vector58:
  pushl $0
8010569f:	6a 00                	push   $0x0
  pushl $58
801056a1:	6a 3a                	push   $0x3a
  jmp alltraps
801056a3:	e9 a4 f8 ff ff       	jmp    80104f4c <alltraps>

801056a8 <vector59>:
.globl vector59
vector59:
  pushl $0
801056a8:	6a 00                	push   $0x0
  pushl $59
801056aa:	6a 3b                	push   $0x3b
  jmp alltraps
801056ac:	e9 9b f8 ff ff       	jmp    80104f4c <alltraps>

801056b1 <vector60>:
.globl vector60
vector60:
  pushl $0
801056b1:	6a 00                	push   $0x0
  pushl $60
801056b3:	6a 3c                	push   $0x3c
  jmp alltraps
801056b5:	e9 92 f8 ff ff       	jmp    80104f4c <alltraps>

801056ba <vector61>:
.globl vector61
vector61:
  pushl $0
801056ba:	6a 00                	push   $0x0
  pushl $61
801056bc:	6a 3d                	push   $0x3d
  jmp alltraps
801056be:	e9 89 f8 ff ff       	jmp    80104f4c <alltraps>

801056c3 <vector62>:
.globl vector62
vector62:
  pushl $0
801056c3:	6a 00                	push   $0x0
  pushl $62
801056c5:	6a 3e                	push   $0x3e
  jmp alltraps
801056c7:	e9 80 f8 ff ff       	jmp    80104f4c <alltraps>

801056cc <vector63>:
.globl vector63
vector63:
  pushl $0
801056cc:	6a 00                	push   $0x0
  pushl $63
801056ce:	6a 3f                	push   $0x3f
  jmp alltraps
801056d0:	e9 77 f8 ff ff       	jmp    80104f4c <alltraps>

801056d5 <vector64>:
.globl vector64
vector64:
  pushl $0
801056d5:	6a 00                	push   $0x0
  pushl $64
801056d7:	6a 40                	push   $0x40
  jmp alltraps
801056d9:	e9 6e f8 ff ff       	jmp    80104f4c <alltraps>

801056de <vector65>:
.globl vector65
vector65:
  pushl $0
801056de:	6a 00                	push   $0x0
  pushl $65
801056e0:	6a 41                	push   $0x41
  jmp alltraps
801056e2:	e9 65 f8 ff ff       	jmp    80104f4c <alltraps>

801056e7 <vector66>:
.globl vector66
vector66:
  pushl $0
801056e7:	6a 00                	push   $0x0
  pushl $66
801056e9:	6a 42                	push   $0x42
  jmp alltraps
801056eb:	e9 5c f8 ff ff       	jmp    80104f4c <alltraps>

801056f0 <vector67>:
.globl vector67
vector67:
  pushl $0
801056f0:	6a 00                	push   $0x0
  pushl $67
801056f2:	6a 43                	push   $0x43
  jmp alltraps
801056f4:	e9 53 f8 ff ff       	jmp    80104f4c <alltraps>

801056f9 <vector68>:
.globl vector68
vector68:
  pushl $0
801056f9:	6a 00                	push   $0x0
  pushl $68
801056fb:	6a 44                	push   $0x44
  jmp alltraps
801056fd:	e9 4a f8 ff ff       	jmp    80104f4c <alltraps>

80105702 <vector69>:
.globl vector69
vector69:
  pushl $0
80105702:	6a 00                	push   $0x0
  pushl $69
80105704:	6a 45                	push   $0x45
  jmp alltraps
80105706:	e9 41 f8 ff ff       	jmp    80104f4c <alltraps>

8010570b <vector70>:
.globl vector70
vector70:
  pushl $0
8010570b:	6a 00                	push   $0x0
  pushl $70
8010570d:	6a 46                	push   $0x46
  jmp alltraps
8010570f:	e9 38 f8 ff ff       	jmp    80104f4c <alltraps>

80105714 <vector71>:
.globl vector71
vector71:
  pushl $0
80105714:	6a 00                	push   $0x0
  pushl $71
80105716:	6a 47                	push   $0x47
  jmp alltraps
80105718:	e9 2f f8 ff ff       	jmp    80104f4c <alltraps>

8010571d <vector72>:
.globl vector72
vector72:
  pushl $0
8010571d:	6a 00                	push   $0x0
  pushl $72
8010571f:	6a 48                	push   $0x48
  jmp alltraps
80105721:	e9 26 f8 ff ff       	jmp    80104f4c <alltraps>

80105726 <vector73>:
.globl vector73
vector73:
  pushl $0
80105726:	6a 00                	push   $0x0
  pushl $73
80105728:	6a 49                	push   $0x49
  jmp alltraps
8010572a:	e9 1d f8 ff ff       	jmp    80104f4c <alltraps>

8010572f <vector74>:
.globl vector74
vector74:
  pushl $0
8010572f:	6a 00                	push   $0x0
  pushl $74
80105731:	6a 4a                	push   $0x4a
  jmp alltraps
80105733:	e9 14 f8 ff ff       	jmp    80104f4c <alltraps>

80105738 <vector75>:
.globl vector75
vector75:
  pushl $0
80105738:	6a 00                	push   $0x0
  pushl $75
8010573a:	6a 4b                	push   $0x4b
  jmp alltraps
8010573c:	e9 0b f8 ff ff       	jmp    80104f4c <alltraps>

80105741 <vector76>:
.globl vector76
vector76:
  pushl $0
80105741:	6a 00                	push   $0x0
  pushl $76
80105743:	6a 4c                	push   $0x4c
  jmp alltraps
80105745:	e9 02 f8 ff ff       	jmp    80104f4c <alltraps>

8010574a <vector77>:
.globl vector77
vector77:
  pushl $0
8010574a:	6a 00                	push   $0x0
  pushl $77
8010574c:	6a 4d                	push   $0x4d
  jmp alltraps
8010574e:	e9 f9 f7 ff ff       	jmp    80104f4c <alltraps>

80105753 <vector78>:
.globl vector78
vector78:
  pushl $0
80105753:	6a 00                	push   $0x0
  pushl $78
80105755:	6a 4e                	push   $0x4e
  jmp alltraps
80105757:	e9 f0 f7 ff ff       	jmp    80104f4c <alltraps>

8010575c <vector79>:
.globl vector79
vector79:
  pushl $0
8010575c:	6a 00                	push   $0x0
  pushl $79
8010575e:	6a 4f                	push   $0x4f
  jmp alltraps
80105760:	e9 e7 f7 ff ff       	jmp    80104f4c <alltraps>

80105765 <vector80>:
.globl vector80
vector80:
  pushl $0
80105765:	6a 00                	push   $0x0
  pushl $80
80105767:	6a 50                	push   $0x50
  jmp alltraps
80105769:	e9 de f7 ff ff       	jmp    80104f4c <alltraps>

8010576e <vector81>:
.globl vector81
vector81:
  pushl $0
8010576e:	6a 00                	push   $0x0
  pushl $81
80105770:	6a 51                	push   $0x51
  jmp alltraps
80105772:	e9 d5 f7 ff ff       	jmp    80104f4c <alltraps>

80105777 <vector82>:
.globl vector82
vector82:
  pushl $0
80105777:	6a 00                	push   $0x0
  pushl $82
80105779:	6a 52                	push   $0x52
  jmp alltraps
8010577b:	e9 cc f7 ff ff       	jmp    80104f4c <alltraps>

80105780 <vector83>:
.globl vector83
vector83:
  pushl $0
80105780:	6a 00                	push   $0x0
  pushl $83
80105782:	6a 53                	push   $0x53
  jmp alltraps
80105784:	e9 c3 f7 ff ff       	jmp    80104f4c <alltraps>

80105789 <vector84>:
.globl vector84
vector84:
  pushl $0
80105789:	6a 00                	push   $0x0
  pushl $84
8010578b:	6a 54                	push   $0x54
  jmp alltraps
8010578d:	e9 ba f7 ff ff       	jmp    80104f4c <alltraps>

80105792 <vector85>:
.globl vector85
vector85:
  pushl $0
80105792:	6a 00                	push   $0x0
  pushl $85
80105794:	6a 55                	push   $0x55
  jmp alltraps
80105796:	e9 b1 f7 ff ff       	jmp    80104f4c <alltraps>

8010579b <vector86>:
.globl vector86
vector86:
  pushl $0
8010579b:	6a 00                	push   $0x0
  pushl $86
8010579d:	6a 56                	push   $0x56
  jmp alltraps
8010579f:	e9 a8 f7 ff ff       	jmp    80104f4c <alltraps>

801057a4 <vector87>:
.globl vector87
vector87:
  pushl $0
801057a4:	6a 00                	push   $0x0
  pushl $87
801057a6:	6a 57                	push   $0x57
  jmp alltraps
801057a8:	e9 9f f7 ff ff       	jmp    80104f4c <alltraps>

801057ad <vector88>:
.globl vector88
vector88:
  pushl $0
801057ad:	6a 00                	push   $0x0
  pushl $88
801057af:	6a 58                	push   $0x58
  jmp alltraps
801057b1:	e9 96 f7 ff ff       	jmp    80104f4c <alltraps>

801057b6 <vector89>:
.globl vector89
vector89:
  pushl $0
801057b6:	6a 00                	push   $0x0
  pushl $89
801057b8:	6a 59                	push   $0x59
  jmp alltraps
801057ba:	e9 8d f7 ff ff       	jmp    80104f4c <alltraps>

801057bf <vector90>:
.globl vector90
vector90:
  pushl $0
801057bf:	6a 00                	push   $0x0
  pushl $90
801057c1:	6a 5a                	push   $0x5a
  jmp alltraps
801057c3:	e9 84 f7 ff ff       	jmp    80104f4c <alltraps>

801057c8 <vector91>:
.globl vector91
vector91:
  pushl $0
801057c8:	6a 00                	push   $0x0
  pushl $91
801057ca:	6a 5b                	push   $0x5b
  jmp alltraps
801057cc:	e9 7b f7 ff ff       	jmp    80104f4c <alltraps>

801057d1 <vector92>:
.globl vector92
vector92:
  pushl $0
801057d1:	6a 00                	push   $0x0
  pushl $92
801057d3:	6a 5c                	push   $0x5c
  jmp alltraps
801057d5:	e9 72 f7 ff ff       	jmp    80104f4c <alltraps>

801057da <vector93>:
.globl vector93
vector93:
  pushl $0
801057da:	6a 00                	push   $0x0
  pushl $93
801057dc:	6a 5d                	push   $0x5d
  jmp alltraps
801057de:	e9 69 f7 ff ff       	jmp    80104f4c <alltraps>

801057e3 <vector94>:
.globl vector94
vector94:
  pushl $0
801057e3:	6a 00                	push   $0x0
  pushl $94
801057e5:	6a 5e                	push   $0x5e
  jmp alltraps
801057e7:	e9 60 f7 ff ff       	jmp    80104f4c <alltraps>

801057ec <vector95>:
.globl vector95
vector95:
  pushl $0
801057ec:	6a 00                	push   $0x0
  pushl $95
801057ee:	6a 5f                	push   $0x5f
  jmp alltraps
801057f0:	e9 57 f7 ff ff       	jmp    80104f4c <alltraps>

801057f5 <vector96>:
.globl vector96
vector96:
  pushl $0
801057f5:	6a 00                	push   $0x0
  pushl $96
801057f7:	6a 60                	push   $0x60
  jmp alltraps
801057f9:	e9 4e f7 ff ff       	jmp    80104f4c <alltraps>

801057fe <vector97>:
.globl vector97
vector97:
  pushl $0
801057fe:	6a 00                	push   $0x0
  pushl $97
80105800:	6a 61                	push   $0x61
  jmp alltraps
80105802:	e9 45 f7 ff ff       	jmp    80104f4c <alltraps>

80105807 <vector98>:
.globl vector98
vector98:
  pushl $0
80105807:	6a 00                	push   $0x0
  pushl $98
80105809:	6a 62                	push   $0x62
  jmp alltraps
8010580b:	e9 3c f7 ff ff       	jmp    80104f4c <alltraps>

80105810 <vector99>:
.globl vector99
vector99:
  pushl $0
80105810:	6a 00                	push   $0x0
  pushl $99
80105812:	6a 63                	push   $0x63
  jmp alltraps
80105814:	e9 33 f7 ff ff       	jmp    80104f4c <alltraps>

80105819 <vector100>:
.globl vector100
vector100:
  pushl $0
80105819:	6a 00                	push   $0x0
  pushl $100
8010581b:	6a 64                	push   $0x64
  jmp alltraps
8010581d:	e9 2a f7 ff ff       	jmp    80104f4c <alltraps>

80105822 <vector101>:
.globl vector101
vector101:
  pushl $0
80105822:	6a 00                	push   $0x0
  pushl $101
80105824:	6a 65                	push   $0x65
  jmp alltraps
80105826:	e9 21 f7 ff ff       	jmp    80104f4c <alltraps>

8010582b <vector102>:
.globl vector102
vector102:
  pushl $0
8010582b:	6a 00                	push   $0x0
  pushl $102
8010582d:	6a 66                	push   $0x66
  jmp alltraps
8010582f:	e9 18 f7 ff ff       	jmp    80104f4c <alltraps>

80105834 <vector103>:
.globl vector103
vector103:
  pushl $0
80105834:	6a 00                	push   $0x0
  pushl $103
80105836:	6a 67                	push   $0x67
  jmp alltraps
80105838:	e9 0f f7 ff ff       	jmp    80104f4c <alltraps>

8010583d <vector104>:
.globl vector104
vector104:
  pushl $0
8010583d:	6a 00                	push   $0x0
  pushl $104
8010583f:	6a 68                	push   $0x68
  jmp alltraps
80105841:	e9 06 f7 ff ff       	jmp    80104f4c <alltraps>

80105846 <vector105>:
.globl vector105
vector105:
  pushl $0
80105846:	6a 00                	push   $0x0
  pushl $105
80105848:	6a 69                	push   $0x69
  jmp alltraps
8010584a:	e9 fd f6 ff ff       	jmp    80104f4c <alltraps>

8010584f <vector106>:
.globl vector106
vector106:
  pushl $0
8010584f:	6a 00                	push   $0x0
  pushl $106
80105851:	6a 6a                	push   $0x6a
  jmp alltraps
80105853:	e9 f4 f6 ff ff       	jmp    80104f4c <alltraps>

80105858 <vector107>:
.globl vector107
vector107:
  pushl $0
80105858:	6a 00                	push   $0x0
  pushl $107
8010585a:	6a 6b                	push   $0x6b
  jmp alltraps
8010585c:	e9 eb f6 ff ff       	jmp    80104f4c <alltraps>

80105861 <vector108>:
.globl vector108
vector108:
  pushl $0
80105861:	6a 00                	push   $0x0
  pushl $108
80105863:	6a 6c                	push   $0x6c
  jmp alltraps
80105865:	e9 e2 f6 ff ff       	jmp    80104f4c <alltraps>

8010586a <vector109>:
.globl vector109
vector109:
  pushl $0
8010586a:	6a 00                	push   $0x0
  pushl $109
8010586c:	6a 6d                	push   $0x6d
  jmp alltraps
8010586e:	e9 d9 f6 ff ff       	jmp    80104f4c <alltraps>

80105873 <vector110>:
.globl vector110
vector110:
  pushl $0
80105873:	6a 00                	push   $0x0
  pushl $110
80105875:	6a 6e                	push   $0x6e
  jmp alltraps
80105877:	e9 d0 f6 ff ff       	jmp    80104f4c <alltraps>

8010587c <vector111>:
.globl vector111
vector111:
  pushl $0
8010587c:	6a 00                	push   $0x0
  pushl $111
8010587e:	6a 6f                	push   $0x6f
  jmp alltraps
80105880:	e9 c7 f6 ff ff       	jmp    80104f4c <alltraps>

80105885 <vector112>:
.globl vector112
vector112:
  pushl $0
80105885:	6a 00                	push   $0x0
  pushl $112
80105887:	6a 70                	push   $0x70
  jmp alltraps
80105889:	e9 be f6 ff ff       	jmp    80104f4c <alltraps>

8010588e <vector113>:
.globl vector113
vector113:
  pushl $0
8010588e:	6a 00                	push   $0x0
  pushl $113
80105890:	6a 71                	push   $0x71
  jmp alltraps
80105892:	e9 b5 f6 ff ff       	jmp    80104f4c <alltraps>

80105897 <vector114>:
.globl vector114
vector114:
  pushl $0
80105897:	6a 00                	push   $0x0
  pushl $114
80105899:	6a 72                	push   $0x72
  jmp alltraps
8010589b:	e9 ac f6 ff ff       	jmp    80104f4c <alltraps>

801058a0 <vector115>:
.globl vector115
vector115:
  pushl $0
801058a0:	6a 00                	push   $0x0
  pushl $115
801058a2:	6a 73                	push   $0x73
  jmp alltraps
801058a4:	e9 a3 f6 ff ff       	jmp    80104f4c <alltraps>

801058a9 <vector116>:
.globl vector116
vector116:
  pushl $0
801058a9:	6a 00                	push   $0x0
  pushl $116
801058ab:	6a 74                	push   $0x74
  jmp alltraps
801058ad:	e9 9a f6 ff ff       	jmp    80104f4c <alltraps>

801058b2 <vector117>:
.globl vector117
vector117:
  pushl $0
801058b2:	6a 00                	push   $0x0
  pushl $117
801058b4:	6a 75                	push   $0x75
  jmp alltraps
801058b6:	e9 91 f6 ff ff       	jmp    80104f4c <alltraps>

801058bb <vector118>:
.globl vector118
vector118:
  pushl $0
801058bb:	6a 00                	push   $0x0
  pushl $118
801058bd:	6a 76                	push   $0x76
  jmp alltraps
801058bf:	e9 88 f6 ff ff       	jmp    80104f4c <alltraps>

801058c4 <vector119>:
.globl vector119
vector119:
  pushl $0
801058c4:	6a 00                	push   $0x0
  pushl $119
801058c6:	6a 77                	push   $0x77
  jmp alltraps
801058c8:	e9 7f f6 ff ff       	jmp    80104f4c <alltraps>

801058cd <vector120>:
.globl vector120
vector120:
  pushl $0
801058cd:	6a 00                	push   $0x0
  pushl $120
801058cf:	6a 78                	push   $0x78
  jmp alltraps
801058d1:	e9 76 f6 ff ff       	jmp    80104f4c <alltraps>

801058d6 <vector121>:
.globl vector121
vector121:
  pushl $0
801058d6:	6a 00                	push   $0x0
  pushl $121
801058d8:	6a 79                	push   $0x79
  jmp alltraps
801058da:	e9 6d f6 ff ff       	jmp    80104f4c <alltraps>

801058df <vector122>:
.globl vector122
vector122:
  pushl $0
801058df:	6a 00                	push   $0x0
  pushl $122
801058e1:	6a 7a                	push   $0x7a
  jmp alltraps
801058e3:	e9 64 f6 ff ff       	jmp    80104f4c <alltraps>

801058e8 <vector123>:
.globl vector123
vector123:
  pushl $0
801058e8:	6a 00                	push   $0x0
  pushl $123
801058ea:	6a 7b                	push   $0x7b
  jmp alltraps
801058ec:	e9 5b f6 ff ff       	jmp    80104f4c <alltraps>

801058f1 <vector124>:
.globl vector124
vector124:
  pushl $0
801058f1:	6a 00                	push   $0x0
  pushl $124
801058f3:	6a 7c                	push   $0x7c
  jmp alltraps
801058f5:	e9 52 f6 ff ff       	jmp    80104f4c <alltraps>

801058fa <vector125>:
.globl vector125
vector125:
  pushl $0
801058fa:	6a 00                	push   $0x0
  pushl $125
801058fc:	6a 7d                	push   $0x7d
  jmp alltraps
801058fe:	e9 49 f6 ff ff       	jmp    80104f4c <alltraps>

80105903 <vector126>:
.globl vector126
vector126:
  pushl $0
80105903:	6a 00                	push   $0x0
  pushl $126
80105905:	6a 7e                	push   $0x7e
  jmp alltraps
80105907:	e9 40 f6 ff ff       	jmp    80104f4c <alltraps>

8010590c <vector127>:
.globl vector127
vector127:
  pushl $0
8010590c:	6a 00                	push   $0x0
  pushl $127
8010590e:	6a 7f                	push   $0x7f
  jmp alltraps
80105910:	e9 37 f6 ff ff       	jmp    80104f4c <alltraps>

80105915 <vector128>:
.globl vector128
vector128:
  pushl $0
80105915:	6a 00                	push   $0x0
  pushl $128
80105917:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010591c:	e9 2b f6 ff ff       	jmp    80104f4c <alltraps>

80105921 <vector129>:
.globl vector129
vector129:
  pushl $0
80105921:	6a 00                	push   $0x0
  pushl $129
80105923:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105928:	e9 1f f6 ff ff       	jmp    80104f4c <alltraps>

8010592d <vector130>:
.globl vector130
vector130:
  pushl $0
8010592d:	6a 00                	push   $0x0
  pushl $130
8010592f:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105934:	e9 13 f6 ff ff       	jmp    80104f4c <alltraps>

80105939 <vector131>:
.globl vector131
vector131:
  pushl $0
80105939:	6a 00                	push   $0x0
  pushl $131
8010593b:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105940:	e9 07 f6 ff ff       	jmp    80104f4c <alltraps>

80105945 <vector132>:
.globl vector132
vector132:
  pushl $0
80105945:	6a 00                	push   $0x0
  pushl $132
80105947:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010594c:	e9 fb f5 ff ff       	jmp    80104f4c <alltraps>

80105951 <vector133>:
.globl vector133
vector133:
  pushl $0
80105951:	6a 00                	push   $0x0
  pushl $133
80105953:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105958:	e9 ef f5 ff ff       	jmp    80104f4c <alltraps>

8010595d <vector134>:
.globl vector134
vector134:
  pushl $0
8010595d:	6a 00                	push   $0x0
  pushl $134
8010595f:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105964:	e9 e3 f5 ff ff       	jmp    80104f4c <alltraps>

80105969 <vector135>:
.globl vector135
vector135:
  pushl $0
80105969:	6a 00                	push   $0x0
  pushl $135
8010596b:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80105970:	e9 d7 f5 ff ff       	jmp    80104f4c <alltraps>

80105975 <vector136>:
.globl vector136
vector136:
  pushl $0
80105975:	6a 00                	push   $0x0
  pushl $136
80105977:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010597c:	e9 cb f5 ff ff       	jmp    80104f4c <alltraps>

80105981 <vector137>:
.globl vector137
vector137:
  pushl $0
80105981:	6a 00                	push   $0x0
  pushl $137
80105983:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80105988:	e9 bf f5 ff ff       	jmp    80104f4c <alltraps>

8010598d <vector138>:
.globl vector138
vector138:
  pushl $0
8010598d:	6a 00                	push   $0x0
  pushl $138
8010598f:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105994:	e9 b3 f5 ff ff       	jmp    80104f4c <alltraps>

80105999 <vector139>:
.globl vector139
vector139:
  pushl $0
80105999:	6a 00                	push   $0x0
  pushl $139
8010599b:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801059a0:	e9 a7 f5 ff ff       	jmp    80104f4c <alltraps>

801059a5 <vector140>:
.globl vector140
vector140:
  pushl $0
801059a5:	6a 00                	push   $0x0
  pushl $140
801059a7:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801059ac:	e9 9b f5 ff ff       	jmp    80104f4c <alltraps>

801059b1 <vector141>:
.globl vector141
vector141:
  pushl $0
801059b1:	6a 00                	push   $0x0
  pushl $141
801059b3:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801059b8:	e9 8f f5 ff ff       	jmp    80104f4c <alltraps>

801059bd <vector142>:
.globl vector142
vector142:
  pushl $0
801059bd:	6a 00                	push   $0x0
  pushl $142
801059bf:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801059c4:	e9 83 f5 ff ff       	jmp    80104f4c <alltraps>

801059c9 <vector143>:
.globl vector143
vector143:
  pushl $0
801059c9:	6a 00                	push   $0x0
  pushl $143
801059cb:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801059d0:	e9 77 f5 ff ff       	jmp    80104f4c <alltraps>

801059d5 <vector144>:
.globl vector144
vector144:
  pushl $0
801059d5:	6a 00                	push   $0x0
  pushl $144
801059d7:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801059dc:	e9 6b f5 ff ff       	jmp    80104f4c <alltraps>

801059e1 <vector145>:
.globl vector145
vector145:
  pushl $0
801059e1:	6a 00                	push   $0x0
  pushl $145
801059e3:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801059e8:	e9 5f f5 ff ff       	jmp    80104f4c <alltraps>

801059ed <vector146>:
.globl vector146
vector146:
  pushl $0
801059ed:	6a 00                	push   $0x0
  pushl $146
801059ef:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801059f4:	e9 53 f5 ff ff       	jmp    80104f4c <alltraps>

801059f9 <vector147>:
.globl vector147
vector147:
  pushl $0
801059f9:	6a 00                	push   $0x0
  pushl $147
801059fb:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105a00:	e9 47 f5 ff ff       	jmp    80104f4c <alltraps>

80105a05 <vector148>:
.globl vector148
vector148:
  pushl $0
80105a05:	6a 00                	push   $0x0
  pushl $148
80105a07:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105a0c:	e9 3b f5 ff ff       	jmp    80104f4c <alltraps>

80105a11 <vector149>:
.globl vector149
vector149:
  pushl $0
80105a11:	6a 00                	push   $0x0
  pushl $149
80105a13:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105a18:	e9 2f f5 ff ff       	jmp    80104f4c <alltraps>

80105a1d <vector150>:
.globl vector150
vector150:
  pushl $0
80105a1d:	6a 00                	push   $0x0
  pushl $150
80105a1f:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105a24:	e9 23 f5 ff ff       	jmp    80104f4c <alltraps>

80105a29 <vector151>:
.globl vector151
vector151:
  pushl $0
80105a29:	6a 00                	push   $0x0
  pushl $151
80105a2b:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105a30:	e9 17 f5 ff ff       	jmp    80104f4c <alltraps>

80105a35 <vector152>:
.globl vector152
vector152:
  pushl $0
80105a35:	6a 00                	push   $0x0
  pushl $152
80105a37:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105a3c:	e9 0b f5 ff ff       	jmp    80104f4c <alltraps>

80105a41 <vector153>:
.globl vector153
vector153:
  pushl $0
80105a41:	6a 00                	push   $0x0
  pushl $153
80105a43:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105a48:	e9 ff f4 ff ff       	jmp    80104f4c <alltraps>

80105a4d <vector154>:
.globl vector154
vector154:
  pushl $0
80105a4d:	6a 00                	push   $0x0
  pushl $154
80105a4f:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105a54:	e9 f3 f4 ff ff       	jmp    80104f4c <alltraps>

80105a59 <vector155>:
.globl vector155
vector155:
  pushl $0
80105a59:	6a 00                	push   $0x0
  pushl $155
80105a5b:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105a60:	e9 e7 f4 ff ff       	jmp    80104f4c <alltraps>

80105a65 <vector156>:
.globl vector156
vector156:
  pushl $0
80105a65:	6a 00                	push   $0x0
  pushl $156
80105a67:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105a6c:	e9 db f4 ff ff       	jmp    80104f4c <alltraps>

80105a71 <vector157>:
.globl vector157
vector157:
  pushl $0
80105a71:	6a 00                	push   $0x0
  pushl $157
80105a73:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80105a78:	e9 cf f4 ff ff       	jmp    80104f4c <alltraps>

80105a7d <vector158>:
.globl vector158
vector158:
  pushl $0
80105a7d:	6a 00                	push   $0x0
  pushl $158
80105a7f:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105a84:	e9 c3 f4 ff ff       	jmp    80104f4c <alltraps>

80105a89 <vector159>:
.globl vector159
vector159:
  pushl $0
80105a89:	6a 00                	push   $0x0
  pushl $159
80105a8b:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105a90:	e9 b7 f4 ff ff       	jmp    80104f4c <alltraps>

80105a95 <vector160>:
.globl vector160
vector160:
  pushl $0
80105a95:	6a 00                	push   $0x0
  pushl $160
80105a97:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105a9c:	e9 ab f4 ff ff       	jmp    80104f4c <alltraps>

80105aa1 <vector161>:
.globl vector161
vector161:
  pushl $0
80105aa1:	6a 00                	push   $0x0
  pushl $161
80105aa3:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105aa8:	e9 9f f4 ff ff       	jmp    80104f4c <alltraps>

80105aad <vector162>:
.globl vector162
vector162:
  pushl $0
80105aad:	6a 00                	push   $0x0
  pushl $162
80105aaf:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105ab4:	e9 93 f4 ff ff       	jmp    80104f4c <alltraps>

80105ab9 <vector163>:
.globl vector163
vector163:
  pushl $0
80105ab9:	6a 00                	push   $0x0
  pushl $163
80105abb:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105ac0:	e9 87 f4 ff ff       	jmp    80104f4c <alltraps>

80105ac5 <vector164>:
.globl vector164
vector164:
  pushl $0
80105ac5:	6a 00                	push   $0x0
  pushl $164
80105ac7:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105acc:	e9 7b f4 ff ff       	jmp    80104f4c <alltraps>

80105ad1 <vector165>:
.globl vector165
vector165:
  pushl $0
80105ad1:	6a 00                	push   $0x0
  pushl $165
80105ad3:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105ad8:	e9 6f f4 ff ff       	jmp    80104f4c <alltraps>

80105add <vector166>:
.globl vector166
vector166:
  pushl $0
80105add:	6a 00                	push   $0x0
  pushl $166
80105adf:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105ae4:	e9 63 f4 ff ff       	jmp    80104f4c <alltraps>

80105ae9 <vector167>:
.globl vector167
vector167:
  pushl $0
80105ae9:	6a 00                	push   $0x0
  pushl $167
80105aeb:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105af0:	e9 57 f4 ff ff       	jmp    80104f4c <alltraps>

80105af5 <vector168>:
.globl vector168
vector168:
  pushl $0
80105af5:	6a 00                	push   $0x0
  pushl $168
80105af7:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105afc:	e9 4b f4 ff ff       	jmp    80104f4c <alltraps>

80105b01 <vector169>:
.globl vector169
vector169:
  pushl $0
80105b01:	6a 00                	push   $0x0
  pushl $169
80105b03:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105b08:	e9 3f f4 ff ff       	jmp    80104f4c <alltraps>

80105b0d <vector170>:
.globl vector170
vector170:
  pushl $0
80105b0d:	6a 00                	push   $0x0
  pushl $170
80105b0f:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105b14:	e9 33 f4 ff ff       	jmp    80104f4c <alltraps>

80105b19 <vector171>:
.globl vector171
vector171:
  pushl $0
80105b19:	6a 00                	push   $0x0
  pushl $171
80105b1b:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105b20:	e9 27 f4 ff ff       	jmp    80104f4c <alltraps>

80105b25 <vector172>:
.globl vector172
vector172:
  pushl $0
80105b25:	6a 00                	push   $0x0
  pushl $172
80105b27:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105b2c:	e9 1b f4 ff ff       	jmp    80104f4c <alltraps>

80105b31 <vector173>:
.globl vector173
vector173:
  pushl $0
80105b31:	6a 00                	push   $0x0
  pushl $173
80105b33:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105b38:	e9 0f f4 ff ff       	jmp    80104f4c <alltraps>

80105b3d <vector174>:
.globl vector174
vector174:
  pushl $0
80105b3d:	6a 00                	push   $0x0
  pushl $174
80105b3f:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105b44:	e9 03 f4 ff ff       	jmp    80104f4c <alltraps>

80105b49 <vector175>:
.globl vector175
vector175:
  pushl $0
80105b49:	6a 00                	push   $0x0
  pushl $175
80105b4b:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105b50:	e9 f7 f3 ff ff       	jmp    80104f4c <alltraps>

80105b55 <vector176>:
.globl vector176
vector176:
  pushl $0
80105b55:	6a 00                	push   $0x0
  pushl $176
80105b57:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105b5c:	e9 eb f3 ff ff       	jmp    80104f4c <alltraps>

80105b61 <vector177>:
.globl vector177
vector177:
  pushl $0
80105b61:	6a 00                	push   $0x0
  pushl $177
80105b63:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105b68:	e9 df f3 ff ff       	jmp    80104f4c <alltraps>

80105b6d <vector178>:
.globl vector178
vector178:
  pushl $0
80105b6d:	6a 00                	push   $0x0
  pushl $178
80105b6f:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105b74:	e9 d3 f3 ff ff       	jmp    80104f4c <alltraps>

80105b79 <vector179>:
.globl vector179
vector179:
  pushl $0
80105b79:	6a 00                	push   $0x0
  pushl $179
80105b7b:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105b80:	e9 c7 f3 ff ff       	jmp    80104f4c <alltraps>

80105b85 <vector180>:
.globl vector180
vector180:
  pushl $0
80105b85:	6a 00                	push   $0x0
  pushl $180
80105b87:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105b8c:	e9 bb f3 ff ff       	jmp    80104f4c <alltraps>

80105b91 <vector181>:
.globl vector181
vector181:
  pushl $0
80105b91:	6a 00                	push   $0x0
  pushl $181
80105b93:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105b98:	e9 af f3 ff ff       	jmp    80104f4c <alltraps>

80105b9d <vector182>:
.globl vector182
vector182:
  pushl $0
80105b9d:	6a 00                	push   $0x0
  pushl $182
80105b9f:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105ba4:	e9 a3 f3 ff ff       	jmp    80104f4c <alltraps>

80105ba9 <vector183>:
.globl vector183
vector183:
  pushl $0
80105ba9:	6a 00                	push   $0x0
  pushl $183
80105bab:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105bb0:	e9 97 f3 ff ff       	jmp    80104f4c <alltraps>

80105bb5 <vector184>:
.globl vector184
vector184:
  pushl $0
80105bb5:	6a 00                	push   $0x0
  pushl $184
80105bb7:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105bbc:	e9 8b f3 ff ff       	jmp    80104f4c <alltraps>

80105bc1 <vector185>:
.globl vector185
vector185:
  pushl $0
80105bc1:	6a 00                	push   $0x0
  pushl $185
80105bc3:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105bc8:	e9 7f f3 ff ff       	jmp    80104f4c <alltraps>

80105bcd <vector186>:
.globl vector186
vector186:
  pushl $0
80105bcd:	6a 00                	push   $0x0
  pushl $186
80105bcf:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105bd4:	e9 73 f3 ff ff       	jmp    80104f4c <alltraps>

80105bd9 <vector187>:
.globl vector187
vector187:
  pushl $0
80105bd9:	6a 00                	push   $0x0
  pushl $187
80105bdb:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105be0:	e9 67 f3 ff ff       	jmp    80104f4c <alltraps>

80105be5 <vector188>:
.globl vector188
vector188:
  pushl $0
80105be5:	6a 00                	push   $0x0
  pushl $188
80105be7:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105bec:	e9 5b f3 ff ff       	jmp    80104f4c <alltraps>

80105bf1 <vector189>:
.globl vector189
vector189:
  pushl $0
80105bf1:	6a 00                	push   $0x0
  pushl $189
80105bf3:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105bf8:	e9 4f f3 ff ff       	jmp    80104f4c <alltraps>

80105bfd <vector190>:
.globl vector190
vector190:
  pushl $0
80105bfd:	6a 00                	push   $0x0
  pushl $190
80105bff:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105c04:	e9 43 f3 ff ff       	jmp    80104f4c <alltraps>

80105c09 <vector191>:
.globl vector191
vector191:
  pushl $0
80105c09:	6a 00                	push   $0x0
  pushl $191
80105c0b:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105c10:	e9 37 f3 ff ff       	jmp    80104f4c <alltraps>

80105c15 <vector192>:
.globl vector192
vector192:
  pushl $0
80105c15:	6a 00                	push   $0x0
  pushl $192
80105c17:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105c1c:	e9 2b f3 ff ff       	jmp    80104f4c <alltraps>

80105c21 <vector193>:
.globl vector193
vector193:
  pushl $0
80105c21:	6a 00                	push   $0x0
  pushl $193
80105c23:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105c28:	e9 1f f3 ff ff       	jmp    80104f4c <alltraps>

80105c2d <vector194>:
.globl vector194
vector194:
  pushl $0
80105c2d:	6a 00                	push   $0x0
  pushl $194
80105c2f:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105c34:	e9 13 f3 ff ff       	jmp    80104f4c <alltraps>

80105c39 <vector195>:
.globl vector195
vector195:
  pushl $0
80105c39:	6a 00                	push   $0x0
  pushl $195
80105c3b:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105c40:	e9 07 f3 ff ff       	jmp    80104f4c <alltraps>

80105c45 <vector196>:
.globl vector196
vector196:
  pushl $0
80105c45:	6a 00                	push   $0x0
  pushl $196
80105c47:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105c4c:	e9 fb f2 ff ff       	jmp    80104f4c <alltraps>

80105c51 <vector197>:
.globl vector197
vector197:
  pushl $0
80105c51:	6a 00                	push   $0x0
  pushl $197
80105c53:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105c58:	e9 ef f2 ff ff       	jmp    80104f4c <alltraps>

80105c5d <vector198>:
.globl vector198
vector198:
  pushl $0
80105c5d:	6a 00                	push   $0x0
  pushl $198
80105c5f:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105c64:	e9 e3 f2 ff ff       	jmp    80104f4c <alltraps>

80105c69 <vector199>:
.globl vector199
vector199:
  pushl $0
80105c69:	6a 00                	push   $0x0
  pushl $199
80105c6b:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105c70:	e9 d7 f2 ff ff       	jmp    80104f4c <alltraps>

80105c75 <vector200>:
.globl vector200
vector200:
  pushl $0
80105c75:	6a 00                	push   $0x0
  pushl $200
80105c77:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105c7c:	e9 cb f2 ff ff       	jmp    80104f4c <alltraps>

80105c81 <vector201>:
.globl vector201
vector201:
  pushl $0
80105c81:	6a 00                	push   $0x0
  pushl $201
80105c83:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105c88:	e9 bf f2 ff ff       	jmp    80104f4c <alltraps>

80105c8d <vector202>:
.globl vector202
vector202:
  pushl $0
80105c8d:	6a 00                	push   $0x0
  pushl $202
80105c8f:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105c94:	e9 b3 f2 ff ff       	jmp    80104f4c <alltraps>

80105c99 <vector203>:
.globl vector203
vector203:
  pushl $0
80105c99:	6a 00                	push   $0x0
  pushl $203
80105c9b:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105ca0:	e9 a7 f2 ff ff       	jmp    80104f4c <alltraps>

80105ca5 <vector204>:
.globl vector204
vector204:
  pushl $0
80105ca5:	6a 00                	push   $0x0
  pushl $204
80105ca7:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105cac:	e9 9b f2 ff ff       	jmp    80104f4c <alltraps>

80105cb1 <vector205>:
.globl vector205
vector205:
  pushl $0
80105cb1:	6a 00                	push   $0x0
  pushl $205
80105cb3:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105cb8:	e9 8f f2 ff ff       	jmp    80104f4c <alltraps>

80105cbd <vector206>:
.globl vector206
vector206:
  pushl $0
80105cbd:	6a 00                	push   $0x0
  pushl $206
80105cbf:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105cc4:	e9 83 f2 ff ff       	jmp    80104f4c <alltraps>

80105cc9 <vector207>:
.globl vector207
vector207:
  pushl $0
80105cc9:	6a 00                	push   $0x0
  pushl $207
80105ccb:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105cd0:	e9 77 f2 ff ff       	jmp    80104f4c <alltraps>

80105cd5 <vector208>:
.globl vector208
vector208:
  pushl $0
80105cd5:	6a 00                	push   $0x0
  pushl $208
80105cd7:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105cdc:	e9 6b f2 ff ff       	jmp    80104f4c <alltraps>

80105ce1 <vector209>:
.globl vector209
vector209:
  pushl $0
80105ce1:	6a 00                	push   $0x0
  pushl $209
80105ce3:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105ce8:	e9 5f f2 ff ff       	jmp    80104f4c <alltraps>

80105ced <vector210>:
.globl vector210
vector210:
  pushl $0
80105ced:	6a 00                	push   $0x0
  pushl $210
80105cef:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105cf4:	e9 53 f2 ff ff       	jmp    80104f4c <alltraps>

80105cf9 <vector211>:
.globl vector211
vector211:
  pushl $0
80105cf9:	6a 00                	push   $0x0
  pushl $211
80105cfb:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105d00:	e9 47 f2 ff ff       	jmp    80104f4c <alltraps>

80105d05 <vector212>:
.globl vector212
vector212:
  pushl $0
80105d05:	6a 00                	push   $0x0
  pushl $212
80105d07:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105d0c:	e9 3b f2 ff ff       	jmp    80104f4c <alltraps>

80105d11 <vector213>:
.globl vector213
vector213:
  pushl $0
80105d11:	6a 00                	push   $0x0
  pushl $213
80105d13:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105d18:	e9 2f f2 ff ff       	jmp    80104f4c <alltraps>

80105d1d <vector214>:
.globl vector214
vector214:
  pushl $0
80105d1d:	6a 00                	push   $0x0
  pushl $214
80105d1f:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105d24:	e9 23 f2 ff ff       	jmp    80104f4c <alltraps>

80105d29 <vector215>:
.globl vector215
vector215:
  pushl $0
80105d29:	6a 00                	push   $0x0
  pushl $215
80105d2b:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105d30:	e9 17 f2 ff ff       	jmp    80104f4c <alltraps>

80105d35 <vector216>:
.globl vector216
vector216:
  pushl $0
80105d35:	6a 00                	push   $0x0
  pushl $216
80105d37:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105d3c:	e9 0b f2 ff ff       	jmp    80104f4c <alltraps>

80105d41 <vector217>:
.globl vector217
vector217:
  pushl $0
80105d41:	6a 00                	push   $0x0
  pushl $217
80105d43:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105d48:	e9 ff f1 ff ff       	jmp    80104f4c <alltraps>

80105d4d <vector218>:
.globl vector218
vector218:
  pushl $0
80105d4d:	6a 00                	push   $0x0
  pushl $218
80105d4f:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105d54:	e9 f3 f1 ff ff       	jmp    80104f4c <alltraps>

80105d59 <vector219>:
.globl vector219
vector219:
  pushl $0
80105d59:	6a 00                	push   $0x0
  pushl $219
80105d5b:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105d60:	e9 e7 f1 ff ff       	jmp    80104f4c <alltraps>

80105d65 <vector220>:
.globl vector220
vector220:
  pushl $0
80105d65:	6a 00                	push   $0x0
  pushl $220
80105d67:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105d6c:	e9 db f1 ff ff       	jmp    80104f4c <alltraps>

80105d71 <vector221>:
.globl vector221
vector221:
  pushl $0
80105d71:	6a 00                	push   $0x0
  pushl $221
80105d73:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105d78:	e9 cf f1 ff ff       	jmp    80104f4c <alltraps>

80105d7d <vector222>:
.globl vector222
vector222:
  pushl $0
80105d7d:	6a 00                	push   $0x0
  pushl $222
80105d7f:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105d84:	e9 c3 f1 ff ff       	jmp    80104f4c <alltraps>

80105d89 <vector223>:
.globl vector223
vector223:
  pushl $0
80105d89:	6a 00                	push   $0x0
  pushl $223
80105d8b:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105d90:	e9 b7 f1 ff ff       	jmp    80104f4c <alltraps>

80105d95 <vector224>:
.globl vector224
vector224:
  pushl $0
80105d95:	6a 00                	push   $0x0
  pushl $224
80105d97:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105d9c:	e9 ab f1 ff ff       	jmp    80104f4c <alltraps>

80105da1 <vector225>:
.globl vector225
vector225:
  pushl $0
80105da1:	6a 00                	push   $0x0
  pushl $225
80105da3:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105da8:	e9 9f f1 ff ff       	jmp    80104f4c <alltraps>

80105dad <vector226>:
.globl vector226
vector226:
  pushl $0
80105dad:	6a 00                	push   $0x0
  pushl $226
80105daf:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105db4:	e9 93 f1 ff ff       	jmp    80104f4c <alltraps>

80105db9 <vector227>:
.globl vector227
vector227:
  pushl $0
80105db9:	6a 00                	push   $0x0
  pushl $227
80105dbb:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105dc0:	e9 87 f1 ff ff       	jmp    80104f4c <alltraps>

80105dc5 <vector228>:
.globl vector228
vector228:
  pushl $0
80105dc5:	6a 00                	push   $0x0
  pushl $228
80105dc7:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105dcc:	e9 7b f1 ff ff       	jmp    80104f4c <alltraps>

80105dd1 <vector229>:
.globl vector229
vector229:
  pushl $0
80105dd1:	6a 00                	push   $0x0
  pushl $229
80105dd3:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105dd8:	e9 6f f1 ff ff       	jmp    80104f4c <alltraps>

80105ddd <vector230>:
.globl vector230
vector230:
  pushl $0
80105ddd:	6a 00                	push   $0x0
  pushl $230
80105ddf:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105de4:	e9 63 f1 ff ff       	jmp    80104f4c <alltraps>

80105de9 <vector231>:
.globl vector231
vector231:
  pushl $0
80105de9:	6a 00                	push   $0x0
  pushl $231
80105deb:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105df0:	e9 57 f1 ff ff       	jmp    80104f4c <alltraps>

80105df5 <vector232>:
.globl vector232
vector232:
  pushl $0
80105df5:	6a 00                	push   $0x0
  pushl $232
80105df7:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105dfc:	e9 4b f1 ff ff       	jmp    80104f4c <alltraps>

80105e01 <vector233>:
.globl vector233
vector233:
  pushl $0
80105e01:	6a 00                	push   $0x0
  pushl $233
80105e03:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105e08:	e9 3f f1 ff ff       	jmp    80104f4c <alltraps>

80105e0d <vector234>:
.globl vector234
vector234:
  pushl $0
80105e0d:	6a 00                	push   $0x0
  pushl $234
80105e0f:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105e14:	e9 33 f1 ff ff       	jmp    80104f4c <alltraps>

80105e19 <vector235>:
.globl vector235
vector235:
  pushl $0
80105e19:	6a 00                	push   $0x0
  pushl $235
80105e1b:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105e20:	e9 27 f1 ff ff       	jmp    80104f4c <alltraps>

80105e25 <vector236>:
.globl vector236
vector236:
  pushl $0
80105e25:	6a 00                	push   $0x0
  pushl $236
80105e27:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105e2c:	e9 1b f1 ff ff       	jmp    80104f4c <alltraps>

80105e31 <vector237>:
.globl vector237
vector237:
  pushl $0
80105e31:	6a 00                	push   $0x0
  pushl $237
80105e33:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105e38:	e9 0f f1 ff ff       	jmp    80104f4c <alltraps>

80105e3d <vector238>:
.globl vector238
vector238:
  pushl $0
80105e3d:	6a 00                	push   $0x0
  pushl $238
80105e3f:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105e44:	e9 03 f1 ff ff       	jmp    80104f4c <alltraps>

80105e49 <vector239>:
.globl vector239
vector239:
  pushl $0
80105e49:	6a 00                	push   $0x0
  pushl $239
80105e4b:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105e50:	e9 f7 f0 ff ff       	jmp    80104f4c <alltraps>

80105e55 <vector240>:
.globl vector240
vector240:
  pushl $0
80105e55:	6a 00                	push   $0x0
  pushl $240
80105e57:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105e5c:	e9 eb f0 ff ff       	jmp    80104f4c <alltraps>

80105e61 <vector241>:
.globl vector241
vector241:
  pushl $0
80105e61:	6a 00                	push   $0x0
  pushl $241
80105e63:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105e68:	e9 df f0 ff ff       	jmp    80104f4c <alltraps>

80105e6d <vector242>:
.globl vector242
vector242:
  pushl $0
80105e6d:	6a 00                	push   $0x0
  pushl $242
80105e6f:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105e74:	e9 d3 f0 ff ff       	jmp    80104f4c <alltraps>

80105e79 <vector243>:
.globl vector243
vector243:
  pushl $0
80105e79:	6a 00                	push   $0x0
  pushl $243
80105e7b:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105e80:	e9 c7 f0 ff ff       	jmp    80104f4c <alltraps>

80105e85 <vector244>:
.globl vector244
vector244:
  pushl $0
80105e85:	6a 00                	push   $0x0
  pushl $244
80105e87:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105e8c:	e9 bb f0 ff ff       	jmp    80104f4c <alltraps>

80105e91 <vector245>:
.globl vector245
vector245:
  pushl $0
80105e91:	6a 00                	push   $0x0
  pushl $245
80105e93:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105e98:	e9 af f0 ff ff       	jmp    80104f4c <alltraps>

80105e9d <vector246>:
.globl vector246
vector246:
  pushl $0
80105e9d:	6a 00                	push   $0x0
  pushl $246
80105e9f:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105ea4:	e9 a3 f0 ff ff       	jmp    80104f4c <alltraps>

80105ea9 <vector247>:
.globl vector247
vector247:
  pushl $0
80105ea9:	6a 00                	push   $0x0
  pushl $247
80105eab:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105eb0:	e9 97 f0 ff ff       	jmp    80104f4c <alltraps>

80105eb5 <vector248>:
.globl vector248
vector248:
  pushl $0
80105eb5:	6a 00                	push   $0x0
  pushl $248
80105eb7:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105ebc:	e9 8b f0 ff ff       	jmp    80104f4c <alltraps>

80105ec1 <vector249>:
.globl vector249
vector249:
  pushl $0
80105ec1:	6a 00                	push   $0x0
  pushl $249
80105ec3:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105ec8:	e9 7f f0 ff ff       	jmp    80104f4c <alltraps>

80105ecd <vector250>:
.globl vector250
vector250:
  pushl $0
80105ecd:	6a 00                	push   $0x0
  pushl $250
80105ecf:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105ed4:	e9 73 f0 ff ff       	jmp    80104f4c <alltraps>

80105ed9 <vector251>:
.globl vector251
vector251:
  pushl $0
80105ed9:	6a 00                	push   $0x0
  pushl $251
80105edb:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105ee0:	e9 67 f0 ff ff       	jmp    80104f4c <alltraps>

80105ee5 <vector252>:
.globl vector252
vector252:
  pushl $0
80105ee5:	6a 00                	push   $0x0
  pushl $252
80105ee7:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105eec:	e9 5b f0 ff ff       	jmp    80104f4c <alltraps>

80105ef1 <vector253>:
.globl vector253
vector253:
  pushl $0
80105ef1:	6a 00                	push   $0x0
  pushl $253
80105ef3:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105ef8:	e9 4f f0 ff ff       	jmp    80104f4c <alltraps>

80105efd <vector254>:
.globl vector254
vector254:
  pushl $0
80105efd:	6a 00                	push   $0x0
  pushl $254
80105eff:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105f04:	e9 43 f0 ff ff       	jmp    80104f4c <alltraps>

80105f09 <vector255>:
.globl vector255
vector255:
  pushl $0
80105f09:	6a 00                	push   $0x0
  pushl $255
80105f0b:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105f10:	e9 37 f0 ff ff       	jmp    80104f4c <alltraps>

80105f15 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105f15:	55                   	push   %ebp
80105f16:	89 e5                	mov    %esp,%ebp
80105f18:	57                   	push   %edi
80105f19:	56                   	push   %esi
80105f1a:	53                   	push   %ebx
80105f1b:	83 ec 0c             	sub    $0xc,%esp
80105f1e:	89 d3                	mov    %edx,%ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105f20:	c1 ea 16             	shr    $0x16,%edx
80105f23:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105f26:	8b 37                	mov    (%edi),%esi
80105f28:	f7 c6 01 00 00 00    	test   $0x1,%esi
80105f2e:	74 20                	je     80105f50 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105f30:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
80105f36:	81 c6 00 00 00 80    	add    $0x80000000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105f3c:	c1 eb 0c             	shr    $0xc,%ebx
80105f3f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
80105f45:	8d 04 9e             	lea    (%esi,%ebx,4),%eax
}
80105f48:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105f4b:	5b                   	pop    %ebx
80105f4c:	5e                   	pop    %esi
80105f4d:	5f                   	pop    %edi
80105f4e:	5d                   	pop    %ebp
80105f4f:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105f50:	85 c9                	test   %ecx,%ecx
80105f52:	74 2b                	je     80105f7f <walkpgdir+0x6a>
80105f54:	e8 e6 c0 ff ff       	call   8010203f <kalloc>
80105f59:	89 c6                	mov    %eax,%esi
80105f5b:	85 c0                	test   %eax,%eax
80105f5d:	74 20                	je     80105f7f <walkpgdir+0x6a>
    memset(pgtab, 0, PGSIZE);
80105f5f:	83 ec 04             	sub    $0x4,%esp
80105f62:	68 00 10 00 00       	push   $0x1000
80105f67:	6a 00                	push   $0x0
80105f69:	50                   	push   %eax
80105f6a:	e8 e0 dd ff ff       	call   80103d4f <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105f6f:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80105f75:	83 c8 07             	or     $0x7,%eax
80105f78:	89 07                	mov    %eax,(%edi)
80105f7a:	83 c4 10             	add    $0x10,%esp
80105f7d:	eb bd                	jmp    80105f3c <walkpgdir+0x27>
      return 0;
80105f7f:	b8 00 00 00 00       	mov    $0x0,%eax
80105f84:	eb c2                	jmp    80105f48 <walkpgdir+0x33>

80105f86 <seginit>:
{
80105f86:	55                   	push   %ebp
80105f87:	89 e5                	mov    %esp,%ebp
80105f89:	57                   	push   %edi
80105f8a:	56                   	push   %esi
80105f8b:	53                   	push   %ebx
80105f8c:	83 ec 2c             	sub    $0x2c,%esp
  c = &cpus[cpuid()];
80105f8f:	e8 78 d1 ff ff       	call   8010310c <cpuid>
80105f94:	89 c3                	mov    %eax,%ebx
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105f96:	8d 14 80             	lea    (%eax,%eax,4),%edx
80105f99:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
80105f9c:	8d 04 01             	lea    (%ecx,%eax,1),%eax
80105f9f:	c1 e0 04             	shl    $0x4,%eax
80105fa2:	66 c7 80 18 18 11 80 	movw   $0xffff,-0x7feee7e8(%eax)
80105fa9:	ff ff 
80105fab:	66 c7 80 1a 18 11 80 	movw   $0x0,-0x7feee7e6(%eax)
80105fb2:	00 00 
80105fb4:	c6 80 1c 18 11 80 00 	movb   $0x0,-0x7feee7e4(%eax)
80105fbb:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
80105fbe:	01 d9                	add    %ebx,%ecx
80105fc0:	c1 e1 04             	shl    $0x4,%ecx
80105fc3:	0f b6 b1 1d 18 11 80 	movzbl -0x7feee7e3(%ecx),%esi
80105fca:	83 e6 f0             	and    $0xfffffff0,%esi
80105fcd:	89 f7                	mov    %esi,%edi
80105fcf:	83 cf 0a             	or     $0xa,%edi
80105fd2:	89 fa                	mov    %edi,%edx
80105fd4:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
80105fda:	83 ce 1a             	or     $0x1a,%esi
80105fdd:	89 f2                	mov    %esi,%edx
80105fdf:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
80105fe5:	83 e6 9f             	and    $0xffffff9f,%esi
80105fe8:	89 f2                	mov    %esi,%edx
80105fea:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
80105ff0:	83 ce 80             	or     $0xffffff80,%esi
80105ff3:	89 f2                	mov    %esi,%edx
80105ff5:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
80105ffb:	0f b6 b1 1e 18 11 80 	movzbl -0x7feee7e2(%ecx),%esi
80106002:	83 ce 0f             	or     $0xf,%esi
80106005:	89 f2                	mov    %esi,%edx
80106007:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
8010600d:	89 f7                	mov    %esi,%edi
8010600f:	83 e7 ef             	and    $0xffffffef,%edi
80106012:	89 fa                	mov    %edi,%edx
80106014:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
8010601a:	83 e6 cf             	and    $0xffffffcf,%esi
8010601d:	89 f2                	mov    %esi,%edx
8010601f:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
80106025:	89 f7                	mov    %esi,%edi
80106027:	83 cf 40             	or     $0x40,%edi
8010602a:	89 fa                	mov    %edi,%edx
8010602c:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
80106032:	83 ce c0             	or     $0xffffffc0,%esi
80106035:	89 f2                	mov    %esi,%edx
80106037:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
8010603d:	c6 80 1f 18 11 80 00 	movb   $0x0,-0x7feee7e1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106044:	66 c7 80 20 18 11 80 	movw   $0xffff,-0x7feee7e0(%eax)
8010604b:	ff ff 
8010604d:	66 c7 80 22 18 11 80 	movw   $0x0,-0x7feee7de(%eax)
80106054:	00 00 
80106056:	c6 80 24 18 11 80 00 	movb   $0x0,-0x7feee7dc(%eax)
8010605d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80106060:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
80106063:	c1 e1 04             	shl    $0x4,%ecx
80106066:	0f b6 b1 25 18 11 80 	movzbl -0x7feee7db(%ecx),%esi
8010606d:	83 e6 f0             	and    $0xfffffff0,%esi
80106070:	89 f7                	mov    %esi,%edi
80106072:	83 cf 02             	or     $0x2,%edi
80106075:	89 fa                	mov    %edi,%edx
80106077:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
8010607d:	83 ce 12             	or     $0x12,%esi
80106080:	89 f2                	mov    %esi,%edx
80106082:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
80106088:	83 e6 9f             	and    $0xffffff9f,%esi
8010608b:	89 f2                	mov    %esi,%edx
8010608d:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
80106093:	83 ce 80             	or     $0xffffff80,%esi
80106096:	89 f2                	mov    %esi,%edx
80106098:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
8010609e:	0f b6 b1 26 18 11 80 	movzbl -0x7feee7da(%ecx),%esi
801060a5:	83 ce 0f             	or     $0xf,%esi
801060a8:	89 f2                	mov    %esi,%edx
801060aa:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
801060b0:	89 f7                	mov    %esi,%edi
801060b2:	83 e7 ef             	and    $0xffffffef,%edi
801060b5:	89 fa                	mov    %edi,%edx
801060b7:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
801060bd:	83 e6 cf             	and    $0xffffffcf,%esi
801060c0:	89 f2                	mov    %esi,%edx
801060c2:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
801060c8:	89 f7                	mov    %esi,%edi
801060ca:	83 cf 40             	or     $0x40,%edi
801060cd:	89 fa                	mov    %edi,%edx
801060cf:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
801060d5:	83 ce c0             	or     $0xffffffc0,%esi
801060d8:	89 f2                	mov    %esi,%edx
801060da:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
801060e0:	c6 80 27 18 11 80 00 	movb   $0x0,-0x7feee7d9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801060e7:	66 c7 80 28 18 11 80 	movw   $0xffff,-0x7feee7d8(%eax)
801060ee:	ff ff 
801060f0:	66 c7 80 2a 18 11 80 	movw   $0x0,-0x7feee7d6(%eax)
801060f7:	00 00 
801060f9:	c6 80 2c 18 11 80 00 	movb   $0x0,-0x7feee7d4(%eax)
80106100:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80106103:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
80106106:	c1 e1 04             	shl    $0x4,%ecx
80106109:	0f b6 b1 2d 18 11 80 	movzbl -0x7feee7d3(%ecx),%esi
80106110:	83 e6 f0             	and    $0xfffffff0,%esi
80106113:	89 f7                	mov    %esi,%edi
80106115:	83 cf 0a             	or     $0xa,%edi
80106118:	89 fa                	mov    %edi,%edx
8010611a:	88 91 2d 18 11 80    	mov    %dl,-0x7feee7d3(%ecx)
80106120:	89 f7                	mov    %esi,%edi
80106122:	83 cf 1a             	or     $0x1a,%edi
80106125:	89 fa                	mov    %edi,%edx
80106127:	88 91 2d 18 11 80    	mov    %dl,-0x7feee7d3(%ecx)
8010612d:	83 ce 7a             	or     $0x7a,%esi
80106130:	89 f2                	mov    %esi,%edx
80106132:	88 91 2d 18 11 80    	mov    %dl,-0x7feee7d3(%ecx)
80106138:	c6 81 2d 18 11 80 fa 	movb   $0xfa,-0x7feee7d3(%ecx)
8010613f:	0f b6 b1 2e 18 11 80 	movzbl -0x7feee7d2(%ecx),%esi
80106146:	83 ce 0f             	or     $0xf,%esi
80106149:	89 f2                	mov    %esi,%edx
8010614b:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
80106151:	89 f7                	mov    %esi,%edi
80106153:	83 e7 ef             	and    $0xffffffef,%edi
80106156:	89 fa                	mov    %edi,%edx
80106158:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
8010615e:	83 e6 cf             	and    $0xffffffcf,%esi
80106161:	89 f2                	mov    %esi,%edx
80106163:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
80106169:	89 f7                	mov    %esi,%edi
8010616b:	83 cf 40             	or     $0x40,%edi
8010616e:	89 fa                	mov    %edi,%edx
80106170:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
80106176:	83 ce c0             	or     $0xffffffc0,%esi
80106179:	89 f2                	mov    %esi,%edx
8010617b:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
80106181:	c6 80 2f 18 11 80 00 	movb   $0x0,-0x7feee7d1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80106188:	66 c7 80 30 18 11 80 	movw   $0xffff,-0x7feee7d0(%eax)
8010618f:	ff ff 
80106191:	66 c7 80 32 18 11 80 	movw   $0x0,-0x7feee7ce(%eax)
80106198:	00 00 
8010619a:	c6 80 34 18 11 80 00 	movb   $0x0,-0x7feee7cc(%eax)
801061a1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801061a4:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
801061a7:	c1 e1 04             	shl    $0x4,%ecx
801061aa:	0f b6 b1 35 18 11 80 	movzbl -0x7feee7cb(%ecx),%esi
801061b1:	83 e6 f0             	and    $0xfffffff0,%esi
801061b4:	89 f7                	mov    %esi,%edi
801061b6:	83 cf 02             	or     $0x2,%edi
801061b9:	89 fa                	mov    %edi,%edx
801061bb:	88 91 35 18 11 80    	mov    %dl,-0x7feee7cb(%ecx)
801061c1:	89 f7                	mov    %esi,%edi
801061c3:	83 cf 12             	or     $0x12,%edi
801061c6:	89 fa                	mov    %edi,%edx
801061c8:	88 91 35 18 11 80    	mov    %dl,-0x7feee7cb(%ecx)
801061ce:	83 ce 72             	or     $0x72,%esi
801061d1:	89 f2                	mov    %esi,%edx
801061d3:	88 91 35 18 11 80    	mov    %dl,-0x7feee7cb(%ecx)
801061d9:	c6 81 35 18 11 80 f2 	movb   $0xf2,-0x7feee7cb(%ecx)
801061e0:	0f b6 b1 36 18 11 80 	movzbl -0x7feee7ca(%ecx),%esi
801061e7:	83 ce 0f             	or     $0xf,%esi
801061ea:	89 f2                	mov    %esi,%edx
801061ec:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
801061f2:	89 f7                	mov    %esi,%edi
801061f4:	83 e7 ef             	and    $0xffffffef,%edi
801061f7:	89 fa                	mov    %edi,%edx
801061f9:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
801061ff:	83 e6 cf             	and    $0xffffffcf,%esi
80106202:	89 f2                	mov    %esi,%edx
80106204:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
8010620a:	89 f7                	mov    %esi,%edi
8010620c:	83 cf 40             	or     $0x40,%edi
8010620f:	89 fa                	mov    %edi,%edx
80106211:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
80106217:	83 ce c0             	or     $0xffffffc0,%esi
8010621a:	89 f2                	mov    %esi,%edx
8010621c:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
80106222:	c6 80 37 18 11 80 00 	movb   $0x0,-0x7feee7c9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80106229:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010622c:	01 da                	add    %ebx,%edx
8010622e:	c1 e2 04             	shl    $0x4,%edx
80106231:	81 c2 10 18 11 80    	add    $0x80111810,%edx
  pd[0] = size-1;
80106237:	66 c7 45 e2 2f 00    	movw   $0x2f,-0x1e(%ebp)
  pd[1] = (uint)p;
8010623d:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
  pd[2] = (uint)p >> 16;
80106241:	c1 ea 10             	shr    $0x10,%edx
80106244:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106248:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010624b:	0f 01 10             	lgdtl  (%eax)
}
8010624e:	83 c4 2c             	add    $0x2c,%esp
80106251:	5b                   	pop    %ebx
80106252:	5e                   	pop    %esi
80106253:	5f                   	pop    %edi
80106254:	5d                   	pop    %ebp
80106255:	c3                   	ret    

80106256 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80106256:	55                   	push   %ebp
80106257:	89 e5                	mov    %esp,%ebp
80106259:	57                   	push   %edi
8010625a:	56                   	push   %esi
8010625b:	53                   	push   %ebx
8010625c:	83 ec 0c             	sub    $0xc,%esp
8010625f:	8b 7d 0c             	mov    0xc(%ebp),%edi
80106262:	8b 75 14             	mov    0x14(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80106265:	89 fb                	mov    %edi,%ebx
80106267:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010626d:	03 7d 10             	add    0x10(%ebp),%edi
80106270:	4f                   	dec    %edi
80106271:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106277:	b9 01 00 00 00       	mov    $0x1,%ecx
8010627c:	89 da                	mov    %ebx,%edx
8010627e:	8b 45 08             	mov    0x8(%ebp),%eax
80106281:	e8 8f fc ff ff       	call   80105f15 <walkpgdir>
80106286:	85 c0                	test   %eax,%eax
80106288:	74 2e                	je     801062b8 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
8010628a:	f6 00 01             	testb  $0x1,(%eax)
8010628d:	75 1c                	jne    801062ab <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
8010628f:	89 f2                	mov    %esi,%edx
80106291:	0b 55 18             	or     0x18(%ebp),%edx
80106294:	83 ca 01             	or     $0x1,%edx
80106297:	89 10                	mov    %edx,(%eax)
    if(a == last)
80106299:	39 fb                	cmp    %edi,%ebx
8010629b:	74 28                	je     801062c5 <mappages+0x6f>
      break;
    a += PGSIZE;
8010629d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
801062a3:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801062a9:	eb cc                	jmp    80106277 <mappages+0x21>
      panic("remap");
801062ab:	83 ec 0c             	sub    $0xc,%esp
801062ae:	68 bc 73 10 80       	push   $0x801073bc
801062b3:	e8 89 a0 ff ff       	call   80100341 <panic>
      return -1;
801062b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801062bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062c0:	5b                   	pop    %ebx
801062c1:	5e                   	pop    %esi
801062c2:	5f                   	pop    %edi
801062c3:	5d                   	pop    %ebp
801062c4:	c3                   	ret    
  return 0;
801062c5:	b8 00 00 00 00       	mov    $0x0,%eax
801062ca:	eb f1                	jmp    801062bd <mappages+0x67>

801062cc <switchkvm>:
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801062cc:	a1 c4 47 11 80       	mov    0x801147c4,%eax
801062d1:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801062d6:	0f 22 d8             	mov    %eax,%cr3
}
801062d9:	c3                   	ret    

801062da <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801062da:	55                   	push   %ebp
801062db:	89 e5                	mov    %esp,%ebp
801062dd:	57                   	push   %edi
801062de:	56                   	push   %esi
801062df:	53                   	push   %ebx
801062e0:	83 ec 1c             	sub    $0x1c,%esp
801062e3:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
801062e6:	85 f6                	test   %esi,%esi
801062e8:	0f 84 21 01 00 00    	je     8010640f <switchuvm+0x135>
    panic("switchuvm: no process");
  if(p->kstack == 0)
801062ee:	83 7e 10 00          	cmpl   $0x0,0x10(%esi)
801062f2:	0f 84 24 01 00 00    	je     8010641c <switchuvm+0x142>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
801062f8:	83 7e 0c 00          	cmpl   $0x0,0xc(%esi)
801062fc:	0f 84 27 01 00 00    	je     80106429 <switchuvm+0x14f>
    panic("switchuvm: no pgdir");

  pushcli();
80106302:	e8 c2 d8 ff ff       	call   80103bc9 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106307:	e8 9c cd ff ff       	call   801030a8 <mycpu>
8010630c:	89 c3                	mov    %eax,%ebx
8010630e:	e8 95 cd ff ff       	call   801030a8 <mycpu>
80106313:	8d 78 08             	lea    0x8(%eax),%edi
80106316:	e8 8d cd ff ff       	call   801030a8 <mycpu>
8010631b:	83 c0 08             	add    $0x8,%eax
8010631e:	c1 e8 10             	shr    $0x10,%eax
80106321:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106324:	e8 7f cd ff ff       	call   801030a8 <mycpu>
80106329:	83 c0 08             	add    $0x8,%eax
8010632c:	c1 e8 18             	shr    $0x18,%eax
8010632f:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106336:	67 00 
80106338:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
8010633f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
80106342:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106348:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010634e:	83 e2 f0             	and    $0xfffffff0,%edx
80106351:	88 d1                	mov    %dl,%cl
80106353:	83 c9 09             	or     $0x9,%ecx
80106356:	88 8b 9d 00 00 00    	mov    %cl,0x9d(%ebx)
8010635c:	83 ca 19             	or     $0x19,%edx
8010635f:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106365:	83 e2 9f             	and    $0xffffff9f,%edx
80106368:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010636e:	83 ca 80             	or     $0xffffff80,%edx
80106371:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106377:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
8010637d:	88 d1                	mov    %dl,%cl
8010637f:	83 e1 f0             	and    $0xfffffff0,%ecx
80106382:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
80106388:	88 d1                	mov    %dl,%cl
8010638a:	83 e1 e0             	and    $0xffffffe0,%ecx
8010638d:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
80106393:	83 e2 c0             	and    $0xffffffc0,%edx
80106396:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010639c:	83 ca 40             	or     $0x40,%edx
8010639f:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801063a5:	83 e2 7f             	and    $0x7f,%edx
801063a8:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801063ae:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801063b4:	e8 ef cc ff ff       	call   801030a8 <mycpu>
801063b9:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
801063bf:	83 e2 ef             	and    $0xffffffef,%edx
801063c2:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801063c8:	e8 db cc ff ff       	call   801030a8 <mycpu>
801063cd:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801063d3:	8b 5e 10             	mov    0x10(%esi),%ebx
801063d6:	e8 cd cc ff ff       	call   801030a8 <mycpu>
801063db:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801063e1:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801063e4:	e8 bf cc ff ff       	call   801030a8 <mycpu>
801063e9:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801063ef:	b8 28 00 00 00       	mov    $0x28,%eax
801063f4:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
801063f7:	8b 46 0c             	mov    0xc(%esi),%eax
801063fa:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801063ff:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80106402:	e8 fd d7 ff ff       	call   80103c04 <popcli>
}
80106407:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010640a:	5b                   	pop    %ebx
8010640b:	5e                   	pop    %esi
8010640c:	5f                   	pop    %edi
8010640d:	5d                   	pop    %ebp
8010640e:	c3                   	ret    
    panic("switchuvm: no process");
8010640f:	83 ec 0c             	sub    $0xc,%esp
80106412:	68 c2 73 10 80       	push   $0x801073c2
80106417:	e8 25 9f ff ff       	call   80100341 <panic>
    panic("switchuvm: no kstack");
8010641c:	83 ec 0c             	sub    $0xc,%esp
8010641f:	68 d8 73 10 80       	push   $0x801073d8
80106424:	e8 18 9f ff ff       	call   80100341 <panic>
    panic("switchuvm: no pgdir");
80106429:	83 ec 0c             	sub    $0xc,%esp
8010642c:	68 ed 73 10 80       	push   $0x801073ed
80106431:	e8 0b 9f ff ff       	call   80100341 <panic>

80106436 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80106436:	55                   	push   %ebp
80106437:	89 e5                	mov    %esp,%ebp
80106439:	56                   	push   %esi
8010643a:	53                   	push   %ebx
8010643b:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
8010643e:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106444:	77 4b                	ja     80106491 <inituvm+0x5b>
    panic("inituvm: more than a page");
  mem = kalloc();
80106446:	e8 f4 bb ff ff       	call   8010203f <kalloc>
8010644b:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
8010644d:	83 ec 04             	sub    $0x4,%esp
80106450:	68 00 10 00 00       	push   $0x1000
80106455:	6a 00                	push   $0x0
80106457:	50                   	push   %eax
80106458:	e8 f2 d8 ff ff       	call   80103d4f <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010645d:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
80106464:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010646a:	50                   	push   %eax
8010646b:	68 00 10 00 00       	push   $0x1000
80106470:	6a 00                	push   $0x0
80106472:	ff 75 08             	push   0x8(%ebp)
80106475:	e8 dc fd ff ff       	call   80106256 <mappages>
  memmove(mem, init, sz);
8010647a:	83 c4 1c             	add    $0x1c,%esp
8010647d:	56                   	push   %esi
8010647e:	ff 75 0c             	push   0xc(%ebp)
80106481:	53                   	push   %ebx
80106482:	e8 3e d9 ff ff       	call   80103dc5 <memmove>
}
80106487:	83 c4 10             	add    $0x10,%esp
8010648a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010648d:	5b                   	pop    %ebx
8010648e:	5e                   	pop    %esi
8010648f:	5d                   	pop    %ebp
80106490:	c3                   	ret    
    panic("inituvm: more than a page");
80106491:	83 ec 0c             	sub    $0xc,%esp
80106494:	68 01 74 10 80       	push   $0x80107401
80106499:	e8 a3 9e ff ff       	call   80100341 <panic>

8010649e <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010649e:	55                   	push   %ebp
8010649f:	89 e5                	mov    %esp,%ebp
801064a1:	57                   	push   %edi
801064a2:	56                   	push   %esi
801064a3:	53                   	push   %ebx
801064a4:	83 ec 0c             	sub    $0xc,%esp
801064a7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801064aa:	89 fb                	mov    %edi,%ebx
801064ac:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
801064b2:	74 3c                	je     801064f0 <loaduvm+0x52>
    panic("loaduvm: addr must be page aligned");
801064b4:	83 ec 0c             	sub    $0xc,%esp
801064b7:	68 bc 74 10 80       	push   $0x801074bc
801064bc:	e8 80 9e ff ff       	call   80100341 <panic>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
801064c1:	83 ec 0c             	sub    $0xc,%esp
801064c4:	68 1b 74 10 80       	push   $0x8010741b
801064c9:	e8 73 9e ff ff       	call   80100341 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
801064ce:	05 00 00 00 80       	add    $0x80000000,%eax
801064d3:	56                   	push   %esi
801064d4:	89 da                	mov    %ebx,%edx
801064d6:	03 55 14             	add    0x14(%ebp),%edx
801064d9:	52                   	push   %edx
801064da:	50                   	push   %eax
801064db:	ff 75 10             	push   0x10(%ebp)
801064de:	e8 28 b2 ff ff       	call   8010170b <readi>
801064e3:	83 c4 10             	add    $0x10,%esp
801064e6:	39 f0                	cmp    %esi,%eax
801064e8:	75 47                	jne    80106531 <loaduvm+0x93>
  for(i = 0; i < sz; i += PGSIZE){
801064ea:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801064f0:	3b 5d 18             	cmp    0x18(%ebp),%ebx
801064f3:	73 2f                	jae    80106524 <loaduvm+0x86>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801064f5:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
801064f8:	b9 00 00 00 00       	mov    $0x0,%ecx
801064fd:	8b 45 08             	mov    0x8(%ebp),%eax
80106500:	e8 10 fa ff ff       	call   80105f15 <walkpgdir>
80106505:	85 c0                	test   %eax,%eax
80106507:	74 b8                	je     801064c1 <loaduvm+0x23>
    pa = PTE_ADDR(*pte);
80106509:	8b 00                	mov    (%eax),%eax
8010650b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106510:	8b 75 18             	mov    0x18(%ebp),%esi
80106513:	29 de                	sub    %ebx,%esi
80106515:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010651b:	76 b1                	jbe    801064ce <loaduvm+0x30>
      n = PGSIZE;
8010651d:	be 00 10 00 00       	mov    $0x1000,%esi
80106522:	eb aa                	jmp    801064ce <loaduvm+0x30>
      return -1;
  }
  return 0;
80106524:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106529:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010652c:	5b                   	pop    %ebx
8010652d:	5e                   	pop    %esi
8010652e:	5f                   	pop    %edi
8010652f:	5d                   	pop    %ebp
80106530:	c3                   	ret    
      return -1;
80106531:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106536:	eb f1                	jmp    80106529 <loaduvm+0x8b>

80106538 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106538:	55                   	push   %ebp
80106539:	89 e5                	mov    %esp,%ebp
8010653b:	57                   	push   %edi
8010653c:	56                   	push   %esi
8010653d:	53                   	push   %ebx
8010653e:	83 ec 0c             	sub    $0xc,%esp
80106541:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106544:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106547:	73 11                	jae    8010655a <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
80106549:	8b 45 10             	mov    0x10(%ebp),%eax
8010654c:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106552:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106558:	eb 17                	jmp    80106571 <deallocuvm+0x39>
    return oldsz;
8010655a:	89 f8                	mov    %edi,%eax
8010655c:	eb 62                	jmp    801065c0 <deallocuvm+0x88>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010655e:	c1 eb 16             	shr    $0x16,%ebx
80106561:	43                   	inc    %ebx
80106562:	c1 e3 16             	shl    $0x16,%ebx
80106565:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010656b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106571:	39 fb                	cmp    %edi,%ebx
80106573:	73 48                	jae    801065bd <deallocuvm+0x85>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106575:	b9 00 00 00 00       	mov    $0x0,%ecx
8010657a:	89 da                	mov    %ebx,%edx
8010657c:	8b 45 08             	mov    0x8(%ebp),%eax
8010657f:	e8 91 f9 ff ff       	call   80105f15 <walkpgdir>
80106584:	89 c6                	mov    %eax,%esi
    if(!pte)
80106586:	85 c0                	test   %eax,%eax
80106588:	74 d4                	je     8010655e <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
8010658a:	8b 00                	mov    (%eax),%eax
8010658c:	a8 01                	test   $0x1,%al
8010658e:	74 db                	je     8010656b <deallocuvm+0x33>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106590:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106595:	74 19                	je     801065b0 <deallocuvm+0x78>
        panic("kfree");
      char *v = P2V(pa);
80106597:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010659c:	83 ec 0c             	sub    $0xc,%esp
8010659f:	50                   	push   %eax
801065a0:	e8 83 b9 ff ff       	call   80101f28 <kfree>
      *pte = 0;
801065a5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801065ab:	83 c4 10             	add    $0x10,%esp
801065ae:	eb bb                	jmp    8010656b <deallocuvm+0x33>
        panic("kfree");
801065b0:	83 ec 0c             	sub    $0xc,%esp
801065b3:	68 c6 6c 10 80       	push   $0x80106cc6
801065b8:	e8 84 9d ff ff       	call   80100341 <panic>
    }
  }
  return newsz;
801065bd:	8b 45 10             	mov    0x10(%ebp),%eax
}
801065c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801065c3:	5b                   	pop    %ebx
801065c4:	5e                   	pop    %esi
801065c5:	5f                   	pop    %edi
801065c6:	5d                   	pop    %ebp
801065c7:	c3                   	ret    

801065c8 <allocuvm>:
{
801065c8:	55                   	push   %ebp
801065c9:	89 e5                	mov    %esp,%ebp
801065cb:	57                   	push   %edi
801065cc:	56                   	push   %esi
801065cd:	53                   	push   %ebx
801065ce:	83 ec 1c             	sub    $0x1c,%esp
801065d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  if(newsz >= KERNBASE)
801065d4:	8b 45 10             	mov    0x10(%ebp),%eax
801065d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801065da:	85 c0                	test   %eax,%eax
801065dc:	0f 88 c1 00 00 00    	js     801066a3 <allocuvm+0xdb>
  if(newsz < oldsz)
801065e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801065e5:	39 45 10             	cmp    %eax,0x10(%ebp)
801065e8:	72 5c                	jb     80106646 <allocuvm+0x7e>
  a = PGROUNDUP(oldsz);
801065ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801065ed:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
801065f3:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
801065f9:	3b 75 10             	cmp    0x10(%ebp),%esi
801065fc:	0f 83 a8 00 00 00    	jae    801066aa <allocuvm+0xe2>
    mem = kalloc();
80106602:	e8 38 ba ff ff       	call   8010203f <kalloc>
80106607:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80106609:	85 c0                	test   %eax,%eax
8010660b:	74 3e                	je     8010664b <allocuvm+0x83>
    memset(mem, 0, PGSIZE);
8010660d:	83 ec 04             	sub    $0x4,%esp
80106610:	68 00 10 00 00       	push   $0x1000
80106615:	6a 00                	push   $0x0
80106617:	50                   	push   %eax
80106618:	e8 32 d7 ff ff       	call   80103d4f <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010661d:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
80106624:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010662a:	50                   	push   %eax
8010662b:	68 00 10 00 00       	push   $0x1000
80106630:	56                   	push   %esi
80106631:	57                   	push   %edi
80106632:	e8 1f fc ff ff       	call   80106256 <mappages>
80106637:	83 c4 20             	add    $0x20,%esp
8010663a:	85 c0                	test   %eax,%eax
8010663c:	78 35                	js     80106673 <allocuvm+0xab>
  for(; a < newsz; a += PGSIZE){
8010663e:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106644:	eb b3                	jmp    801065f9 <allocuvm+0x31>
    return oldsz;
80106646:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106649:	eb 5f                	jmp    801066aa <allocuvm+0xe2>
      cprintf("allocuvm out of memory\n");
8010664b:	83 ec 0c             	sub    $0xc,%esp
8010664e:	68 39 74 10 80       	push   $0x80107439
80106653:	e8 82 9f ff ff       	call   801005da <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106658:	83 c4 0c             	add    $0xc,%esp
8010665b:	ff 75 0c             	push   0xc(%ebp)
8010665e:	ff 75 10             	push   0x10(%ebp)
80106661:	57                   	push   %edi
80106662:	e8 d1 fe ff ff       	call   80106538 <deallocuvm>
      return 0;
80106667:	83 c4 10             	add    $0x10,%esp
8010666a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106671:	eb 37                	jmp    801066aa <allocuvm+0xe2>
      cprintf("allocuvm out of memory (2)\n");
80106673:	83 ec 0c             	sub    $0xc,%esp
80106676:	68 51 74 10 80       	push   $0x80107451
8010667b:	e8 5a 9f ff ff       	call   801005da <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106680:	83 c4 0c             	add    $0xc,%esp
80106683:	ff 75 0c             	push   0xc(%ebp)
80106686:	ff 75 10             	push   0x10(%ebp)
80106689:	57                   	push   %edi
8010668a:	e8 a9 fe ff ff       	call   80106538 <deallocuvm>
      kfree(mem);
8010668f:	89 1c 24             	mov    %ebx,(%esp)
80106692:	e8 91 b8 ff ff       	call   80101f28 <kfree>
      return 0;
80106697:	83 c4 10             	add    $0x10,%esp
8010669a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801066a1:	eb 07                	jmp    801066aa <allocuvm+0xe2>
    return 0;
801066a3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
801066aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
801066b0:	5b                   	pop    %ebx
801066b1:	5e                   	pop    %esi
801066b2:	5f                   	pop    %edi
801066b3:	5d                   	pop    %ebp
801066b4:	c3                   	ret    

801066b5 <freevm>:

// Free a page table and all the physical memory pages
// in the user part if dodeallocuvm is not zero
void
freevm(pde_t *pgdir, int dodeallocuvm)
{
801066b5:	55                   	push   %ebp
801066b6:	89 e5                	mov    %esp,%ebp
801066b8:	56                   	push   %esi
801066b9:	53                   	push   %ebx
801066ba:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
801066bd:	85 f6                	test   %esi,%esi
801066bf:	74 0d                	je     801066ce <freevm+0x19>
    panic("freevm: no pgdir");
  if (dodeallocuvm)
801066c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801066c5:	75 14                	jne    801066db <freevm+0x26>
{
801066c7:	bb 00 00 00 00       	mov    $0x0,%ebx
801066cc:	eb 23                	jmp    801066f1 <freevm+0x3c>
    panic("freevm: no pgdir");
801066ce:	83 ec 0c             	sub    $0xc,%esp
801066d1:	68 6d 74 10 80       	push   $0x8010746d
801066d6:	e8 66 9c ff ff       	call   80100341 <panic>
    deallocuvm(pgdir, KERNBASE, 0);
801066db:	83 ec 04             	sub    $0x4,%esp
801066de:	6a 00                	push   $0x0
801066e0:	68 00 00 00 80       	push   $0x80000000
801066e5:	56                   	push   %esi
801066e6:	e8 4d fe ff ff       	call   80106538 <deallocuvm>
801066eb:	83 c4 10             	add    $0x10,%esp
801066ee:	eb d7                	jmp    801066c7 <freevm+0x12>
  for(i = 0; i < NPDENTRIES; i++){
801066f0:	43                   	inc    %ebx
801066f1:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
801066f7:	77 1f                	ja     80106718 <freevm+0x63>
    if(pgdir[i] & PTE_P){
801066f9:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
801066fc:	a8 01                	test   $0x1,%al
801066fe:	74 f0                	je     801066f0 <freevm+0x3b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80106700:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106705:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010670a:	83 ec 0c             	sub    $0xc,%esp
8010670d:	50                   	push   %eax
8010670e:	e8 15 b8 ff ff       	call   80101f28 <kfree>
80106713:	83 c4 10             	add    $0x10,%esp
80106716:	eb d8                	jmp    801066f0 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80106718:	83 ec 0c             	sub    $0xc,%esp
8010671b:	56                   	push   %esi
8010671c:	e8 07 b8 ff ff       	call   80101f28 <kfree>
}
80106721:	83 c4 10             	add    $0x10,%esp
80106724:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106727:	5b                   	pop    %ebx
80106728:	5e                   	pop    %esi
80106729:	5d                   	pop    %ebp
8010672a:	c3                   	ret    

8010672b <setupkvm>:
{
8010672b:	55                   	push   %ebp
8010672c:	89 e5                	mov    %esp,%ebp
8010672e:	56                   	push   %esi
8010672f:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80106730:	e8 0a b9 ff ff       	call   8010203f <kalloc>
80106735:	89 c6                	mov    %eax,%esi
80106737:	85 c0                	test   %eax,%eax
80106739:	74 57                	je     80106792 <setupkvm+0x67>
  memset(pgdir, 0, PGSIZE);
8010673b:	83 ec 04             	sub    $0x4,%esp
8010673e:	68 00 10 00 00       	push   $0x1000
80106743:	6a 00                	push   $0x0
80106745:	50                   	push   %eax
80106746:	e8 04 d6 ff ff       	call   80103d4f <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010674b:	83 c4 10             	add    $0x10,%esp
8010674e:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
80106753:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106759:	73 37                	jae    80106792 <setupkvm+0x67>
                (uint)k->phys_start, k->perm) < 0) {
8010675b:	8b 53 04             	mov    0x4(%ebx),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010675e:	83 ec 0c             	sub    $0xc,%esp
80106761:	ff 73 0c             	push   0xc(%ebx)
80106764:	52                   	push   %edx
80106765:	8b 43 08             	mov    0x8(%ebx),%eax
80106768:	29 d0                	sub    %edx,%eax
8010676a:	50                   	push   %eax
8010676b:	ff 33                	push   (%ebx)
8010676d:	56                   	push   %esi
8010676e:	e8 e3 fa ff ff       	call   80106256 <mappages>
80106773:	83 c4 20             	add    $0x20,%esp
80106776:	85 c0                	test   %eax,%eax
80106778:	78 05                	js     8010677f <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010677a:	83 c3 10             	add    $0x10,%ebx
8010677d:	eb d4                	jmp    80106753 <setupkvm+0x28>
      freevm(pgdir, 0);
8010677f:	83 ec 08             	sub    $0x8,%esp
80106782:	6a 00                	push   $0x0
80106784:	56                   	push   %esi
80106785:	e8 2b ff ff ff       	call   801066b5 <freevm>
      return 0;
8010678a:	83 c4 10             	add    $0x10,%esp
8010678d:	be 00 00 00 00       	mov    $0x0,%esi
}
80106792:	89 f0                	mov    %esi,%eax
80106794:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106797:	5b                   	pop    %ebx
80106798:	5e                   	pop    %esi
80106799:	5d                   	pop    %ebp
8010679a:	c3                   	ret    

8010679b <kvmalloc>:
{
8010679b:	55                   	push   %ebp
8010679c:	89 e5                	mov    %esp,%ebp
8010679e:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801067a1:	e8 85 ff ff ff       	call   8010672b <setupkvm>
801067a6:	a3 c4 47 11 80       	mov    %eax,0x801147c4
  switchkvm();
801067ab:	e8 1c fb ff ff       	call   801062cc <switchkvm>
}
801067b0:	c9                   	leave  
801067b1:	c3                   	ret    

801067b2 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801067b2:	55                   	push   %ebp
801067b3:	89 e5                	mov    %esp,%ebp
801067b5:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801067b8:	b9 00 00 00 00       	mov    $0x0,%ecx
801067bd:	8b 55 0c             	mov    0xc(%ebp),%edx
801067c0:	8b 45 08             	mov    0x8(%ebp),%eax
801067c3:	e8 4d f7 ff ff       	call   80105f15 <walkpgdir>
  if(pte == 0)
801067c8:	85 c0                	test   %eax,%eax
801067ca:	74 05                	je     801067d1 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
801067cc:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
801067cf:	c9                   	leave  
801067d0:	c3                   	ret    
    panic("clearpteu");
801067d1:	83 ec 0c             	sub    $0xc,%esp
801067d4:	68 7e 74 10 80       	push   $0x8010747e
801067d9:	e8 63 9b ff ff       	call   80100341 <panic>

801067de <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801067de:	55                   	push   %ebp
801067df:	89 e5                	mov    %esp,%ebp
801067e1:	57                   	push   %edi
801067e2:	56                   	push   %esi
801067e3:	53                   	push   %ebx
801067e4:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801067e7:	e8 3f ff ff ff       	call   8010672b <setupkvm>
801067ec:	89 45 dc             	mov    %eax,-0x24(%ebp)
801067ef:	85 c0                	test   %eax,%eax
801067f1:	0f 84 c6 00 00 00    	je     801068bd <copyuvm+0xdf>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801067f7:	bb 00 00 00 00       	mov    $0x0,%ebx
801067fc:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
801067ff:	0f 83 b8 00 00 00    	jae    801068bd <copyuvm+0xdf>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106805:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80106808:	b9 00 00 00 00       	mov    $0x0,%ecx
8010680d:	89 da                	mov    %ebx,%edx
8010680f:	8b 45 08             	mov    0x8(%ebp),%eax
80106812:	e8 fe f6 ff ff       	call   80105f15 <walkpgdir>
80106817:	85 c0                	test   %eax,%eax
80106819:	74 65                	je     80106880 <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
8010681b:	8b 00                	mov    (%eax),%eax
8010681d:	a8 01                	test   $0x1,%al
8010681f:	74 6c                	je     8010688d <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80106821:	89 c6                	mov    %eax,%esi
80106823:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
80106829:	25 ff 0f 00 00       	and    $0xfff,%eax
8010682e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
80106831:	e8 09 b8 ff ff       	call   8010203f <kalloc>
80106836:	89 c7                	mov    %eax,%edi
80106838:	85 c0                	test   %eax,%eax
8010683a:	74 6a                	je     801068a6 <copyuvm+0xc8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010683c:	81 c6 00 00 00 80    	add    $0x80000000,%esi
80106842:	83 ec 04             	sub    $0x4,%esp
80106845:	68 00 10 00 00       	push   $0x1000
8010684a:	56                   	push   %esi
8010684b:	50                   	push   %eax
8010684c:	e8 74 d5 ff ff       	call   80103dc5 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106851:	83 c4 04             	add    $0x4,%esp
80106854:	ff 75 e0             	push   -0x20(%ebp)
80106857:	8d 87 00 00 00 80    	lea    -0x80000000(%edi),%eax
8010685d:	50                   	push   %eax
8010685e:	68 00 10 00 00       	push   $0x1000
80106863:	ff 75 e4             	push   -0x1c(%ebp)
80106866:	ff 75 dc             	push   -0x24(%ebp)
80106869:	e8 e8 f9 ff ff       	call   80106256 <mappages>
8010686e:	83 c4 20             	add    $0x20,%esp
80106871:	85 c0                	test   %eax,%eax
80106873:	78 25                	js     8010689a <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
80106875:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010687b:	e9 7c ff ff ff       	jmp    801067fc <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
80106880:	83 ec 0c             	sub    $0xc,%esp
80106883:	68 88 74 10 80       	push   $0x80107488
80106888:	e8 b4 9a ff ff       	call   80100341 <panic>
      panic("copyuvm: page not present");
8010688d:	83 ec 0c             	sub    $0xc,%esp
80106890:	68 a2 74 10 80       	push   $0x801074a2
80106895:	e8 a7 9a ff ff       	call   80100341 <panic>
      kfree(mem);
8010689a:	83 ec 0c             	sub    $0xc,%esp
8010689d:	57                   	push   %edi
8010689e:	e8 85 b6 ff ff       	call   80101f28 <kfree>
      goto bad;
801068a3:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d, 1);
801068a6:	83 ec 08             	sub    $0x8,%esp
801068a9:	6a 01                	push   $0x1
801068ab:	ff 75 dc             	push   -0x24(%ebp)
801068ae:	e8 02 fe ff ff       	call   801066b5 <freevm>
  return 0;
801068b3:	83 c4 10             	add    $0x10,%esp
801068b6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
801068bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801068c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801068c3:	5b                   	pop    %ebx
801068c4:	5e                   	pop    %esi
801068c5:	5f                   	pop    %edi
801068c6:	5d                   	pop    %ebp
801068c7:	c3                   	ret    

801068c8 <copyuvm1>:

// Given a parent process's page table, create a copy
// of it for a child taking care of lazy memory
pde_t*
copyuvm1(pde_t *pgdir, uint sz)
{
801068c8:	55                   	push   %ebp
801068c9:	89 e5                	mov    %esp,%ebp
801068cb:	57                   	push   %edi
801068cc:	56                   	push   %esi
801068cd:	53                   	push   %ebx
801068ce:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;
  if((d = setupkvm()) == 0)
801068d1:	e8 55 fe ff ff       	call   8010672b <setupkvm>
801068d6:	89 45 dc             	mov    %eax,-0x24(%ebp)
801068d9:	85 c0                	test   %eax,%eax
801068db:	0f 84 b6 00 00 00    	je     80106997 <copyuvm1+0xcf>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801068e1:	be 00 00 00 00       	mov    $0x0,%esi
801068e6:	eb 13                	jmp    801068fb <copyuvm1+0x33>
    if((pte = walkpgdir(pgdir, (void *) i, 1)) == 0)
      panic("copyuvm: pte should exist");
801068e8:	83 ec 0c             	sub    $0xc,%esp
801068eb:	68 88 74 10 80       	push   $0x80107488
801068f0:	e8 4c 9a ff ff       	call   80100341 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801068f5:	81 c6 00 10 00 00    	add    $0x1000,%esi
801068fb:	3b 75 0c             	cmp    0xc(%ebp),%esi
801068fe:	0f 83 93 00 00 00    	jae    80106997 <copyuvm1+0xcf>
    if((pte = walkpgdir(pgdir, (void *) i, 1)) == 0)
80106904:	b9 01 00 00 00       	mov    $0x1,%ecx
80106909:	89 f2                	mov    %esi,%edx
8010690b:	8b 45 08             	mov    0x8(%ebp),%eax
8010690e:	e8 02 f6 ff ff       	call   80105f15 <walkpgdir>
80106913:	85 c0                	test   %eax,%eax
80106915:	74 d1                	je     801068e8 <copyuvm1+0x20>
    if(!(*pte & PTE_P)){
80106917:	8b 00                	mov    (%eax),%eax
80106919:	a8 01                	test   $0x1,%al
8010691b:	74 d8                	je     801068f5 <copyuvm1+0x2d>
			//Si la página no está presente vamos a seguir
			//iterando
			continue;
		}
		//Si la página tiene el bit de presente, la copiamos
    pa = PTE_ADDR(*pte);
8010691d:	89 c2                	mov    %eax,%edx
8010691f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80106925:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    flags = PTE_FLAGS(*pte);
80106928:	25 ff 0f 00 00       	and    $0xfff,%eax
8010692d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
80106930:	e8 0a b7 ff ff       	call   8010203f <kalloc>
80106935:	89 c7                	mov    %eax,%edi
80106937:	85 c0                	test   %eax,%eax
80106939:	74 45                	je     80106980 <copyuvm1+0xb8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010693b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010693e:	05 00 00 00 80       	add    $0x80000000,%eax
80106943:	83 ec 04             	sub    $0x4,%esp
80106946:	68 00 10 00 00       	push   $0x1000
8010694b:	50                   	push   %eax
8010694c:	57                   	push   %edi
8010694d:	e8 73 d4 ff ff       	call   80103dc5 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106952:	83 c4 04             	add    $0x4,%esp
80106955:	ff 75 e0             	push   -0x20(%ebp)
80106958:	8d 87 00 00 00 80    	lea    -0x80000000(%edi),%eax
8010695e:	50                   	push   %eax
8010695f:	68 00 10 00 00       	push   $0x1000
80106964:	56                   	push   %esi
80106965:	ff 75 dc             	push   -0x24(%ebp)
80106968:	e8 e9 f8 ff ff       	call   80106256 <mappages>
8010696d:	83 c4 20             	add    $0x20,%esp
80106970:	85 c0                	test   %eax,%eax
80106972:	79 81                	jns    801068f5 <copyuvm1+0x2d>
      kfree(mem);
80106974:	83 ec 0c             	sub    $0xc,%esp
80106977:	57                   	push   %edi
80106978:	e8 ab b5 ff ff       	call   80101f28 <kfree>
      goto bad;
8010697d:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d, 1);
80106980:	83 ec 08             	sub    $0x8,%esp
80106983:	6a 01                	push   $0x1
80106985:	ff 75 dc             	push   -0x24(%ebp)
80106988:	e8 28 fd ff ff       	call   801066b5 <freevm>
  return 0;
8010698d:	83 c4 10             	add    $0x10,%esp
80106990:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106997:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010699a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010699d:	5b                   	pop    %ebx
8010699e:	5e                   	pop    %esi
8010699f:	5f                   	pop    %edi
801069a0:	5d                   	pop    %ebp
801069a1:	c3                   	ret    

801069a2 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801069a2:	55                   	push   %ebp
801069a3:	89 e5                	mov    %esp,%ebp
801069a5:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801069a8:	b9 00 00 00 00       	mov    $0x0,%ecx
801069ad:	8b 55 0c             	mov    0xc(%ebp),%edx
801069b0:	8b 45 08             	mov    0x8(%ebp),%eax
801069b3:	e8 5d f5 ff ff       	call   80105f15 <walkpgdir>
  if((*pte & PTE_P) == 0)
801069b8:	8b 00                	mov    (%eax),%eax
801069ba:	a8 01                	test   $0x1,%al
801069bc:	74 10                	je     801069ce <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
801069be:	a8 04                	test   $0x4,%al
801069c0:	74 13                	je     801069d5 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
801069c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801069c7:	05 00 00 00 80       	add    $0x80000000,%eax
}
801069cc:	c9                   	leave  
801069cd:	c3                   	ret    
    return 0;
801069ce:	b8 00 00 00 00       	mov    $0x0,%eax
801069d3:	eb f7                	jmp    801069cc <uva2ka+0x2a>
    return 0;
801069d5:	b8 00 00 00 00       	mov    $0x0,%eax
801069da:	eb f0                	jmp    801069cc <uva2ka+0x2a>

801069dc <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801069dc:	55                   	push   %ebp
801069dd:	89 e5                	mov    %esp,%ebp
801069df:	57                   	push   %edi
801069e0:	56                   	push   %esi
801069e1:	53                   	push   %ebx
801069e2:	83 ec 0c             	sub    $0xc,%esp
801069e5:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801069e8:	eb 25                	jmp    80106a0f <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801069ea:	8b 55 0c             	mov    0xc(%ebp),%edx
801069ed:	29 f2                	sub    %esi,%edx
801069ef:	01 d0                	add    %edx,%eax
801069f1:	83 ec 04             	sub    $0x4,%esp
801069f4:	53                   	push   %ebx
801069f5:	ff 75 10             	push   0x10(%ebp)
801069f8:	50                   	push   %eax
801069f9:	e8 c7 d3 ff ff       	call   80103dc5 <memmove>
    len -= n;
801069fe:	29 df                	sub    %ebx,%edi
    buf += n;
80106a00:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106a03:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80106a09:	89 45 0c             	mov    %eax,0xc(%ebp)
80106a0c:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
80106a0f:	85 ff                	test   %edi,%edi
80106a11:	74 2f                	je     80106a42 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
80106a13:	8b 75 0c             	mov    0xc(%ebp),%esi
80106a16:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106a1c:	83 ec 08             	sub    $0x8,%esp
80106a1f:	56                   	push   %esi
80106a20:	ff 75 08             	push   0x8(%ebp)
80106a23:	e8 7a ff ff ff       	call   801069a2 <uva2ka>
    if(pa0 == 0)
80106a28:	83 c4 10             	add    $0x10,%esp
80106a2b:	85 c0                	test   %eax,%eax
80106a2d:	74 20                	je     80106a4f <copyout+0x73>
    n = PGSIZE - (va - va0);
80106a2f:	89 f3                	mov    %esi,%ebx
80106a31:	2b 5d 0c             	sub    0xc(%ebp),%ebx
80106a34:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106a3a:	39 df                	cmp    %ebx,%edi
80106a3c:	73 ac                	jae    801069ea <copyout+0xe>
      n = len;
80106a3e:	89 fb                	mov    %edi,%ebx
80106a40:	eb a8                	jmp    801069ea <copyout+0xe>
  }
  return 0;
80106a42:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a47:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106a4a:	5b                   	pop    %ebx
80106a4b:	5e                   	pop    %esi
80106a4c:	5f                   	pop    %edi
80106a4d:	5d                   	pop    %ebp
80106a4e:	c3                   	ret    
      return -1;
80106a4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a54:	eb f1                	jmp    80106a47 <copyout+0x6b>
