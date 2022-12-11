
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
80100046:	e8 04 40 00 00       	call   8010404f <acquire>

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
8010007a:	e8 35 40 00 00       	call   801040b4 <release>
      acquiresleep(&b->lock);
8010007f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100082:	89 04 24             	mov    %eax,(%esp)
80100085:	e8 b6 3d 00 00       	call   80103e40 <acquiresleep>
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
801000c8:	e8 e7 3f 00 00       	call   801040b4 <release>
      acquiresleep(&b->lock);
801000cd:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d0:	89 04 24             	mov    %eax,(%esp)
801000d3:	e8 68 3d 00 00       	call   80103e40 <acquiresleep>
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
801000e8:	68 00 6f 10 80       	push   $0x80106f00
801000ed:	e8 4f 02 00 00       	call   80100341 <panic>

801000f2 <binit>:
{
801000f2:	55                   	push   %ebp
801000f3:	89 e5                	mov    %esp,%ebp
801000f5:	53                   	push   %ebx
801000f6:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000f9:	68 11 6f 10 80       	push   $0x80106f11
801000fe:	68 20 a5 10 80       	push   $0x8010a520
80100103:	e8 10 3e 00 00       	call   80103f18 <initlock>
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
80100138:	68 18 6f 10 80       	push   $0x80106f18
8010013d:	8d 43 0c             	lea    0xc(%ebx),%eax
80100140:	50                   	push   %eax
80100141:	e8 c7 3c 00 00       	call   80103e0d <initsleeplock>
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
801001a6:	e8 1f 3d 00 00       	call   80103eca <holdingsleep>
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
801001c9:	68 1f 6f 10 80       	push   $0x80106f1f
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
801001e2:	e8 e3 3c 00 00       	call   80103eca <holdingsleep>
801001e7:	83 c4 10             	add    $0x10,%esp
801001ea:	85 c0                	test   %eax,%eax
801001ec:	74 69                	je     80100257 <brelse+0x84>
    panic("brelse");

  releasesleep(&b->lock);
801001ee:	83 ec 0c             	sub    $0xc,%esp
801001f1:	56                   	push   %esi
801001f2:	e8 98 3c 00 00       	call   80103e8f <releasesleep>

  acquire(&bcache.lock);
801001f7:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801001fe:	e8 4c 3e 00 00       	call   8010404f <acquire>
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
80100248:	e8 67 3e 00 00       	call   801040b4 <release>
}
8010024d:	83 c4 10             	add    $0x10,%esp
80100250:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100253:	5b                   	pop    %ebx
80100254:	5e                   	pop    %esi
80100255:	5d                   	pop    %ebp
80100256:	c3                   	ret    
    panic("brelse");
80100257:	83 ec 0c             	sub    $0xc,%esp
8010025a:	68 26 6f 10 80       	push   $0x80106f26
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
80100286:	e8 c4 3d 00 00       	call   8010404f <acquire>
  while(n > 0){
8010028b:	83 c4 10             	add    $0x10,%esp
8010028e:	85 db                	test   %ebx,%ebx
80100290:	0f 8e 8c 00 00 00    	jle    80100322 <consoleread+0xbe>
    while(input.r == input.w){
80100296:	a1 00 ef 10 80       	mov    0x8010ef00,%eax
8010029b:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
801002a1:	75 47                	jne    801002ea <consoleread+0x86>
      if(myproc()->killed){
801002a3:	e8 97 2f 00 00       	call   8010323f <myproc>
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
801002bb:	e8 ea 37 00 00       	call   80103aaa <sleep>
801002c0:	83 c4 10             	add    $0x10,%esp
801002c3:	eb d1                	jmp    80100296 <consoleread+0x32>
        release(&cons.lock);
801002c5:	83 ec 0c             	sub    $0xc,%esp
801002c8:	68 20 ef 10 80       	push   $0x8010ef20
801002cd:	e8 e2 3d 00 00       	call   801040b4 <release>
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
8010032a:	e8 85 3d 00 00       	call   801040b4 <release>
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
8010035c:	68 2d 6f 10 80       	push   $0x80106f2d
80100361:	e8 74 02 00 00       	call   801005da <cprintf>
  cprintf(s);
80100366:	83 c4 04             	add    $0x4,%esp
80100369:	ff 75 08             	push   0x8(%ebp)
8010036c:	e8 69 02 00 00       	call   801005da <cprintf>
  cprintf("\n");
80100371:	c7 04 24 6b 7a 10 80 	movl   $0x80107a6b,(%esp)
80100378:	e8 5d 02 00 00       	call   801005da <cprintf>
  getcallerpcs(&s, pcs);
8010037d:	83 c4 08             	add    $0x8,%esp
80100380:	8d 45 d0             	lea    -0x30(%ebp),%eax
80100383:	50                   	push   %eax
80100384:	8d 45 08             	lea    0x8(%ebp),%eax
80100387:	50                   	push   %eax
80100388:	e8 a6 3b 00 00       	call   80103f33 <getcallerpcs>
  for(i=0; i<10; i++)
8010038d:	83 c4 10             	add    $0x10,%esp
80100390:	bb 00 00 00 00       	mov    $0x0,%ebx
80100395:	eb 15                	jmp    801003ac <panic+0x6b>
    cprintf(" %p", pcs[i]);
80100397:	83 ec 08             	sub    $0x8,%esp
8010039a:	ff 74 9d d0          	push   -0x30(%ebp,%ebx,4)
8010039e:	68 41 6f 10 80       	push   $0x80106f41
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
8010046c:	68 45 6f 10 80       	push   $0x80106f45
80100471:	e8 cb fe ff ff       	call   80100341 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100476:	83 ec 04             	sub    $0x4,%esp
80100479:	68 60 0e 00 00       	push   $0xe60
8010047e:	68 a0 80 0b 80       	push   $0x800b80a0
80100483:	68 00 80 0b 80       	push   $0x800b8000
80100488:	e8 e4 3c 00 00       	call   80104171 <memmove>
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
801004a7:	e8 4f 3c 00 00       	call   801040fb <memset>
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
801004d4:	e8 57 53 00 00       	call   80105830 <uartputc>
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
801004ed:	e8 3e 53 00 00       	call   80105830 <uartputc>
801004f2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801004f9:	e8 32 53 00 00       	call   80105830 <uartputc>
801004fe:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100505:	e8 26 53 00 00       	call   80105830 <uartputc>
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
80100540:	8a 92 70 6f 10 80    	mov    -0x7fef9090(%edx),%dl
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
8010059b:	e8 af 3a 00 00       	call   8010404f <acquire>
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
801005c0:	e8 ef 3a 00 00       	call   801040b4 <release>
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
80100607:	e8 43 3a 00 00       	call   8010404f <acquire>
8010060c:	83 c4 10             	add    $0x10,%esp
8010060f:	eb de                	jmp    801005ef <cprintf+0x15>
    panic("null fmt");
80100611:	83 ec 0c             	sub    $0xc,%esp
80100614:	68 5f 6f 10 80       	push   $0x80106f5f
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
8010069c:	bb 58 6f 10 80       	mov    $0x80106f58,%ebx
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
801006f5:	e8 ba 39 00 00       	call   801040b4 <release>
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
80100710:	e8 3a 39 00 00       	call   8010404f <acquire>
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
801007b8:	e8 96 34 00 00       	call   80103c53 <wakeup>
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
80100831:	e8 7e 38 00 00       	call   801040b4 <release>
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
80100845:	e8 d7 34 00 00       	call   80103d21 <procdump>
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
80100852:	68 68 6f 10 80       	push   $0x80106f68
80100857:	68 20 ef 10 80       	push   $0x8010ef20
8010085c:	e8 b7 36 00 00       	call   80103f18 <initlock>

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
8010089c:	e8 9e 29 00 00       	call   8010323f <myproc>
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
8010091c:	68 81 6f 10 80       	push   $0x80106f81
80100921:	e8 b4 fc ff ff       	call   801005da <cprintf>
    return -1;
80100926:	83 c4 10             	add    $0x10,%esp
80100929:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010092e:	eb dc                	jmp    8010090c <exec+0x7c>
  if((pgdir = setupkvm()) == 0)
80100930:	e8 99 62 00 00       	call   80106bce <setupkvm>
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
801009c6:	e8 a0 60 00 00       	call   80106a6b <allocuvm>
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
801009fc:	e8 40 5f 00 00       	call   80106941 <loaduvm>
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
80100a3e:	e8 28 60 00 00       	call   80106a6b <allocuvm>
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
80100a6b:	e8 e8 60 00 00       	call   80106b58 <freevm>
80100a70:	83 c4 10             	add    $0x10,%esp
80100a73:	e9 76 fe ff ff       	jmp    801008ee <exec+0x5e>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100a78:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100a7e:	83 ec 08             	sub    $0x8,%esp
80100a81:	50                   	push   %eax
80100a82:	56                   	push   %esi
80100a83:	e8 cd 61 00 00       	call   80106c55 <clearpteu>
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
80100ac1:	e8 c5 37 00 00       	call   8010428b <strlen>
80100ac6:	29 c6                	sub    %eax,%esi
80100ac8:	4e                   	dec    %esi
80100ac9:	83 e6 fc             	and    $0xfffffffc,%esi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100acc:	83 c4 04             	add    $0x4,%esp
80100acf:	ff 33                	push   (%ebx)
80100ad1:	e8 b5 37 00 00       	call   8010428b <strlen>
80100ad6:	40                   	inc    %eax
80100ad7:	50                   	push   %eax
80100ad8:	ff 33                	push   (%ebx)
80100ada:	56                   	push   %esi
80100adb:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100ae1:	e8 99 63 00 00       	call   80106e7f <copyout>
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
80100b41:	e8 39 63 00 00       	call   80106e7f <copyout>
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
80100b7b:	e8 d3 36 00 00       	call   80104253 <safestrcpy>
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
80100bb3:	e8 c5 5b 00 00       	call   8010677d <switchuvm>
  freevm(oldpgdir, 1);
80100bb8:	83 c4 08             	add    $0x8,%esp
80100bbb:	6a 01                	push   $0x1
80100bbd:	53                   	push   %ebx
80100bbe:	e8 95 5f 00 00       	call   80106b58 <freevm>
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
80100bea:	68 8d 6f 10 80       	push   $0x80106f8d
80100bef:	68 60 ef 10 80       	push   $0x8010ef60
80100bf4:	e8 1f 33 00 00       	call   80103f18 <initlock>
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
80100c0a:	e8 40 34 00 00       	call   8010404f <acquire>
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
80100c39:	e8 76 34 00 00       	call   801040b4 <release>
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
80100c50:	e8 5f 34 00 00       	call   801040b4 <release>
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
80100c6e:	e8 dc 33 00 00       	call   8010404f <acquire>
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
80100c89:	e8 26 34 00 00       	call   801040b4 <release>
  return f;
}
80100c8e:	89 d8                	mov    %ebx,%eax
80100c90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c93:	c9                   	leave  
80100c94:	c3                   	ret    
    panic("filedup");
80100c95:	83 ec 0c             	sub    $0xc,%esp
80100c98:	68 94 6f 10 80       	push   $0x80106f94
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
80100cb3:	e8 97 33 00 00       	call   8010404f <acquire>
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
80100ceb:	e8 c4 33 00 00       	call   801040b4 <release>

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
80100d1d:	68 9c 6f 10 80       	push   $0x80106f9c
80100d22:	e8 1a f6 ff ff       	call   80100341 <panic>
    release(&ftable.lock);
80100d27:	83 ec 0c             	sub    $0xc,%esp
80100d2a:	68 60 ef 10 80       	push   $0x8010ef60
80100d2f:	e8 80 33 00 00       	call   801040b4 <release>
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
80100e0f:	68 a6 6f 10 80       	push   $0x80106fa6
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
80100ed4:	68 af 6f 10 80       	push   $0x80106faf
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
80100ef8:	68 b5 6f 10 80       	push   $0x80106fb5
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
80100f42:	e8 2a 32 00 00       	call   80104171 <memmove>
80100f47:	83 c4 10             	add    $0x10,%esp
80100f4a:	eb 15                	jmp    80100f61 <skipelem+0x58>
  else {
    memmove(name, s, len);
80100f4c:	83 ec 04             	sub    $0x4,%esp
80100f4f:	57                   	push   %edi
80100f50:	50                   	push   %eax
80100f51:	56                   	push   %esi
80100f52:	e8 1a 32 00 00       	call   80104171 <memmove>
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
80100f95:	e8 61 31 00 00       	call   801040fb <memset>
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
80101053:	68 bf 6f 10 80       	push   $0x80106fbf
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
80101128:	68 d5 6f 10 80       	push   $0x80106fd5
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
80101145:	e8 05 2f 00 00       	call   8010404f <acquire>
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
8010118a:	e8 25 2f 00 00       	call   801040b4 <release>
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
801011c0:	e8 ef 2e 00 00       	call   801040b4 <release>
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
801011d5:	68 e8 6f 10 80       	push   $0x80106fe8
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
801011fe:	e8 6e 2f 00 00       	call   80104171 <memmove>
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
8010128c:	68 f8 6f 10 80       	push   $0x80106ff8
80101291:	e8 ab f0 ff ff       	call   80100341 <panic>

80101296 <iinit>:
{
80101296:	55                   	push   %ebp
80101297:	89 e5                	mov    %esp,%ebp
80101299:	53                   	push   %ebx
8010129a:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
8010129d:	68 0b 70 10 80       	push   $0x8010700b
801012a2:	68 60 f9 10 80       	push   $0x8010f960
801012a7:	e8 6c 2c 00 00       	call   80103f18 <initlock>
  for(i = 0; i < NINODE; i++) {
801012ac:	83 c4 10             	add    $0x10,%esp
801012af:	bb 00 00 00 00       	mov    $0x0,%ebx
801012b4:	eb 1f                	jmp    801012d5 <iinit+0x3f>
    initsleeplock(&icache.inode[i].lock, "inode");
801012b6:	83 ec 08             	sub    $0x8,%esp
801012b9:	68 12 70 10 80       	push   $0x80107012
801012be:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
801012c1:	89 d0                	mov    %edx,%eax
801012c3:	c1 e0 04             	shl    $0x4,%eax
801012c6:	05 a0 f9 10 80       	add    $0x8010f9a0,%eax
801012cb:	50                   	push   %eax
801012cc:	e8 3c 2b 00 00       	call   80103e0d <initsleeplock>
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
80101314:	68 78 70 10 80       	push   $0x80107078
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
80101385:	68 18 70 10 80       	push   $0x80107018
8010138a:	e8 b2 ef ff ff       	call   80100341 <panic>
      memset(dip, 0, sizeof(*dip));
8010138f:	83 ec 04             	sub    $0x4,%esp
80101392:	6a 40                	push   $0x40
80101394:	6a 00                	push   $0x0
80101396:	57                   	push   %edi
80101397:	e8 5f 2d 00 00       	call   801040fb <memset>
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
80101423:	e8 49 2d 00 00       	call   80104171 <memmove>
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
801014ff:	e8 4b 2b 00 00       	call   8010404f <acquire>
  ip->ref++;
80101504:	8b 43 08             	mov    0x8(%ebx),%eax
80101507:	40                   	inc    %eax
80101508:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010150b:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101512:	e8 9d 2b 00 00       	call   801040b4 <release>
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
80101537:	e8 04 29 00 00       	call   80103e40 <acquiresleep>
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
8010154f:	68 2a 70 10 80       	push   $0x8010702a
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
801015af:	e8 bd 2b 00 00       	call   80104171 <memmove>
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
801015d4:	68 30 70 10 80       	push   $0x80107030
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
801015f1:	e8 d4 28 00 00       	call   80103eca <holdingsleep>
801015f6:	83 c4 10             	add    $0x10,%esp
801015f9:	85 c0                	test   %eax,%eax
801015fb:	74 19                	je     80101616 <iunlock+0x38>
801015fd:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101601:	7e 13                	jle    80101616 <iunlock+0x38>
  releasesleep(&ip->lock);
80101603:	83 ec 0c             	sub    $0xc,%esp
80101606:	56                   	push   %esi
80101607:	e8 83 28 00 00       	call   80103e8f <releasesleep>
}
8010160c:	83 c4 10             	add    $0x10,%esp
8010160f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101612:	5b                   	pop    %ebx
80101613:	5e                   	pop    %esi
80101614:	5d                   	pop    %ebp
80101615:	c3                   	ret    
    panic("iunlock");
80101616:	83 ec 0c             	sub    $0xc,%esp
80101619:	68 3f 70 10 80       	push   $0x8010703f
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
80101633:	e8 08 28 00 00       	call   80103e40 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101638:	83 c4 10             	add    $0x10,%esp
8010163b:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
8010163f:	74 07                	je     80101648 <iput+0x25>
80101641:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101646:	74 33                	je     8010167b <iput+0x58>
  releasesleep(&ip->lock);
80101648:	83 ec 0c             	sub    $0xc,%esp
8010164b:	56                   	push   %esi
8010164c:	e8 3e 28 00 00       	call   80103e8f <releasesleep>
  acquire(&icache.lock);
80101651:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101658:	e8 f2 29 00 00       	call   8010404f <acquire>
  ip->ref--;
8010165d:	8b 43 08             	mov    0x8(%ebx),%eax
80101660:	48                   	dec    %eax
80101661:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
80101664:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
8010166b:	e8 44 2a 00 00       	call   801040b4 <release>
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
80101683:	e8 c7 29 00 00       	call   8010404f <acquire>
    int r = ip->ref;
80101688:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
8010168b:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101692:	e8 1d 2a 00 00       	call   801040b4 <release>
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
80101787:	e8 e5 29 00 00       	call   80104171 <memmove>
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
8010188a:	e8 e2 28 00 00       	call   80104171 <memmove>
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
8010194d:	e8 85 28 00 00       	call   801041d7 <strncmp>
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
80101974:	68 47 70 10 80       	push   $0x80107047
80101979:	e8 c3 e9 ff ff       	call   80100341 <panic>
      panic("dirlookup read");
8010197e:	83 ec 0c             	sub    $0xc,%esp
80101981:	68 59 70 10 80       	push   $0x80107059
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
801019fe:	e8 3c 18 00 00       	call   8010323f <myproc>
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
80101b33:	68 68 70 10 80       	push   $0x80107068
80101b38:	e8 04 e8 ff ff       	call   80100341 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b3d:	83 ec 04             	sub    $0x4,%esp
80101b40:	6a 0e                	push   $0xe
80101b42:	57                   	push   %edi
80101b43:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101b46:	8d 45 da             	lea    -0x26(%ebp),%eax
80101b49:	50                   	push   %eax
80101b4a:	e8 c0 26 00 00       	call   8010420f <strncpy>
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
80101b78:	68 20 77 10 80       	push   $0x80107720
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
80101c70:	68 cb 70 10 80       	push   $0x801070cb
80101c75:	e8 c7 e6 ff ff       	call   80100341 <panic>
    panic("incorrect blockno");
80101c7a:	83 ec 0c             	sub    $0xc,%esp
80101c7d:	68 d4 70 10 80       	push   $0x801070d4
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
80101c97:	68 e6 70 10 80       	push   $0x801070e6
80101c9c:	68 00 16 11 80       	push   $0x80111600
80101ca1:	e8 72 22 00 00       	call   80103f18 <initlock>
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
80101d07:	e8 43 23 00 00       	call   8010404f <acquire>

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
80101d36:	e8 18 1f 00 00       	call   80103c53 <wakeup>

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
80101d54:	e8 5b 23 00 00       	call   801040b4 <release>
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
80101d6b:	e8 44 23 00 00       	call   801040b4 <release>
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
80101da3:	e8 22 21 00 00       	call   80103eca <holdingsleep>
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
80101dd0:	e8 7a 22 00 00       	call   8010404f <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101dd5:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101ddc:	83 c4 10             	add    $0x10,%esp
80101ddf:	ba e4 15 11 80       	mov    $0x801115e4,%edx
80101de4:	eb 2a                	jmp    80101e10 <iderw+0x7b>
    panic("iderw: buf not locked");
80101de6:	83 ec 0c             	sub    $0xc,%esp
80101de9:	68 ea 70 10 80       	push   $0x801070ea
80101dee:	e8 4e e5 ff ff       	call   80100341 <panic>
    panic("iderw: nothing to do");
80101df3:	83 ec 0c             	sub    $0xc,%esp
80101df6:	68 00 71 10 80       	push   $0x80107100
80101dfb:	e8 41 e5 ff ff       	call   80100341 <panic>
    panic("iderw: ide disk 1 not present");
80101e00:	83 ec 0c             	sub    $0xc,%esp
80101e03:	68 15 71 10 80       	push   $0x80107115
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
80101e32:	e8 73 1c 00 00       	call   80103aaa <sleep>
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
80101e4c:	e8 63 22 00 00       	call   801040b4 <release>
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
80101ec0:	68 34 71 10 80       	push   $0x80107134
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
80101f5a:	e8 9c 21 00 00       	call   801040fb <memset>

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
80101f89:	68 66 71 10 80       	push   $0x80107166
80101f8e:	e8 ae e3 ff ff       	call   80100341 <panic>
    acquire(&kmem.lock);
80101f93:	83 ec 0c             	sub    $0xc,%esp
80101f96:	68 40 16 11 80       	push   $0x80111640
80101f9b:	e8 af 20 00 00       	call   8010404f <acquire>
80101fa0:	83 c4 10             	add    $0x10,%esp
80101fa3:	eb c6                	jmp    80101f6b <kfree+0x43>
    release(&kmem.lock);
80101fa5:	83 ec 0c             	sub    $0xc,%esp
80101fa8:	68 40 16 11 80       	push   $0x80111640
80101fad:	e8 02 21 00 00       	call   801040b4 <release>
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
80101ff3:	68 6c 71 10 80       	push   $0x8010716c
80101ff8:	68 40 16 11 80       	push   $0x80111640
80101ffd:	e8 16 1f 00 00       	call   80103f18 <initlock>
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
80102078:	e8 d2 1f 00 00       	call   8010404f <acquire>
8010207d:	83 c4 10             	add    $0x10,%esp
80102080:	eb cd                	jmp    8010204f <kalloc+0x10>
    release(&kmem.lock);
80102082:	83 ec 0c             	sub    $0xc,%esp
80102085:	68 40 16 11 80       	push   $0x80111640
8010208a:	e8 25 20 00 00       	call   801040b4 <release>
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
801020cd:	0f b6 91 a0 72 10 80 	movzbl -0x7fef8d60(%ecx),%edx
801020d4:	0b 15 7c 16 11 80    	or     0x8011167c,%edx
801020da:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  shift ^= togglecode[data];
801020e0:	0f b6 81 a0 71 10 80 	movzbl -0x7fef8e60(%ecx),%eax
801020e7:	31 c2                	xor    %eax,%edx
801020e9:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  c = charcode[shift & (CTL | SHIFT)][data];
801020ef:	89 d0                	mov    %edx,%eax
801020f1:	83 e0 03             	and    $0x3,%eax
801020f4:	8b 04 85 80 71 10 80 	mov    -0x7fef8e80(,%eax,4),%eax
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
8010212d:	8a 81 a0 72 10 80    	mov    -0x7fef8d60(%ecx),%al
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
8010240b:	e8 32 1d 00 00       	call   80104142 <memcmp>
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
80102551:	e8 1b 1c 00 00       	call   80104171 <memmove>
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
8010264a:	e8 22 1b 00 00       	call   80104171 <memmove>
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
801026b5:	68 a0 73 10 80       	push   $0x801073a0
801026ba:	68 a0 16 11 80       	push   $0x801116a0
801026bf:	e8 54 18 00 00       	call   80103f18 <initlock>
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
801026ff:	e8 4b 19 00 00       	call   8010404f <acquire>
80102704:	83 c4 10             	add    $0x10,%esp
80102707:	eb 15                	jmp    8010271e <begin_op+0x2a>
      sleep(&log, &log.lock);
80102709:	83 ec 08             	sub    $0x8,%esp
8010270c:	68 a0 16 11 80       	push   $0x801116a0
80102711:	68 a0 16 11 80       	push   $0x801116a0
80102716:	e8 8f 13 00 00       	call   80103aaa <sleep>
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
8010274e:	e8 57 13 00 00       	call   80103aaa <sleep>
80102753:	83 c4 10             	add    $0x10,%esp
80102756:	eb c6                	jmp    8010271e <begin_op+0x2a>
      log.outstanding += 1;
80102758:	89 0d dc 16 11 80    	mov    %ecx,0x801116dc
      release(&log.lock);
8010275e:	83 ec 0c             	sub    $0xc,%esp
80102761:	68 a0 16 11 80       	push   $0x801116a0
80102766:	e8 49 19 00 00       	call   801040b4 <release>
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
8010277c:	e8 ce 18 00 00       	call   8010404f <acquire>
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
801027b4:	e8 fb 18 00 00       	call   801040b4 <release>
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
801027c8:	68 a4 73 10 80       	push   $0x801073a4
801027cd:	e8 6f db ff ff       	call   80100341 <panic>
    wakeup(&log);
801027d2:	83 ec 0c             	sub    $0xc,%esp
801027d5:	68 a0 16 11 80       	push   $0x801116a0
801027da:	e8 74 14 00 00       	call   80103c53 <wakeup>
801027df:	83 c4 10             	add    $0x10,%esp
801027e2:	eb c8                	jmp    801027ac <end_op+0x3c>
    commit();
801027e4:	e8 92 fe ff ff       	call   8010267b <commit>
    acquire(&log.lock);
801027e9:	83 ec 0c             	sub    $0xc,%esp
801027ec:	68 a0 16 11 80       	push   $0x801116a0
801027f1:	e8 59 18 00 00       	call   8010404f <acquire>
    log.committing = 0;
801027f6:	c7 05 e0 16 11 80 00 	movl   $0x0,0x801116e0
801027fd:	00 00 00 
    wakeup(&log);
80102800:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
80102807:	e8 47 14 00 00       	call   80103c53 <wakeup>
    release(&log.lock);
8010280c:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
80102813:	e8 9c 18 00 00       	call   801040b4 <release>
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
8010284d:	e8 fd 17 00 00       	call   8010404f <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102852:	83 c4 10             	add    $0x10,%esp
80102855:	b8 00 00 00 00       	mov    $0x0,%eax
8010285a:	eb 1b                	jmp    80102877 <log_write+0x5a>
    panic("too big a transaction");
8010285c:	83 ec 0c             	sub    $0xc,%esp
8010285f:	68 b3 73 10 80       	push   $0x801073b3
80102864:	e8 d8 da ff ff       	call   80100341 <panic>
    panic("log_write outside of trans");
80102869:	83 ec 0c             	sub    $0xc,%esp
8010286c:	68 c9 73 10 80       	push   $0x801073c9
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
801028a6:	e8 09 18 00 00       	call   801040b4 <release>
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
801028d2:	e8 9a 18 00 00       	call   80104171 <memmove>

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
80102900:	e8 a5 08 00 00       	call   801031aa <mycpu>
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
80102958:	e8 b1 08 00 00       	call   8010320e <cpuid>
8010295d:	89 c3                	mov    %eax,%ebx
8010295f:	e8 aa 08 00 00       	call   8010320e <cpuid>
80102964:	83 ec 04             	sub    $0x4,%esp
80102967:	53                   	push   %ebx
80102968:	50                   	push   %eax
80102969:	68 e4 73 10 80       	push   $0x801073e4
8010296e:	e8 67 dc ff ff       	call   801005da <cprintf>
  idtinit();       // load idt register
80102973:	e8 e4 2a 00 00       	call   8010545c <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102978:	e8 2d 08 00 00       	call   801031aa <mycpu>
8010297d:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010297f:	b8 01 00 00 00       	mov    $0x1,%eax
80102984:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
8010298b:	e8 9a 0d 00 00       	call   8010372a <scheduler>

80102990 <mpenter>:
{
80102990:	55                   	push   %ebp
80102991:	89 e5                	mov    %esp,%ebp
80102993:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102996:	e8 d4 3d 00 00       	call   8010676f <switchkvm>
  seginit();
8010299b:	e8 5b 3a 00 00       	call   801063fb <seginit>
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
801029ca:	e8 6f 42 00 00       	call   80106c3e <kvmalloc>
  mpinit();        // detect other processors
801029cf:	e8 b8 01 00 00       	call   80102b8c <mpinit>
  lapicinit();     // interrupt controller
801029d4:	e8 16 f8 ff ff       	call   801021ef <lapicinit>
  seginit();       // segment descriptors
801029d9:	e8 1d 3a 00 00       	call   801063fb <seginit>
  picinit();       // disable pic
801029de:	e8 79 02 00 00       	call   80102c5c <picinit>
  ioapicinit();    // another interrupt controller
801029e3:	e8 93 f4 ff ff       	call   80101e7b <ioapicinit>
  consoleinit();   // console hardware
801029e8:	e8 5f de ff ff       	call   8010084c <consoleinit>
  uartinit();      // serial port
801029ed:	e8 81 2e 00 00       	call   80105873 <uartinit>
  pinit();         // process table
801029f2:	e8 99 07 00 00       	call   80103190 <pinit>
  tvinit();        // trap vectors
801029f7:	e8 63 29 00 00       	call   8010535f <tvinit>
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
80102a22:	e8 3b 08 00 00       	call   80103262 <userinit>
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
80102a6b:	68 f8 73 10 80       	push   $0x801073f8
80102a70:	53                   	push   %ebx
80102a71:	e8 cc 16 00 00       	call   80104142 <memcmp>
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
80102b2e:	68 fd 73 10 80       	push   $0x801073fd
80102b33:	57                   	push   %edi
80102b34:	e8 09 16 00 00       	call   80104142 <memcmp>
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
80102bbd:	68 02 74 10 80       	push   $0x80107402
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
80102c52:	68 1c 74 10 80       	push   $0x8010741c
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
80102cd6:	68 3b 74 10 80       	push   $0x8010743b
80102cdb:	50                   	push   %eax
80102cdc:	e8 37 12 00 00       	call   80103f18 <initlock>
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
80102d60:	e8 ea 12 00 00       	call   8010404f <acquire>
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
80102d82:	e8 cc 0e 00 00       	call   80103c53 <wakeup>
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
80102da0:	e8 0f 13 00 00       	call   801040b4 <release>
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
80102dc1:	e8 8d 0e 00 00       	call   80103c53 <wakeup>
80102dc6:	83 c4 10             	add    $0x10,%esp
80102dc9:	eb bf                	jmp    80102d8a <pipeclose+0x35>
    release(&p->lock);
80102dcb:	83 ec 0c             	sub    $0xc,%esp
80102dce:	53                   	push   %ebx
80102dcf:	e8 e0 12 00 00       	call   801040b4 <release>
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
80102ded:	e8 5d 12 00 00       	call   8010404f <acquire>
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
80102e09:	e8 45 0e 00 00       	call   80103c53 <wakeup>
  release(&p->lock);
80102e0e:	89 1c 24             	mov    %ebx,(%esp)
80102e11:	e8 9e 12 00 00       	call   801040b4 <release>
  return n;
80102e16:	83 c4 10             	add    $0x10,%esp
80102e19:	8b 45 10             	mov    0x10(%ebp),%eax
80102e1c:	eb 5c                	jmp    80102e7a <pipewrite+0x99>
      wakeup(&p->nread);
80102e1e:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102e24:	83 ec 0c             	sub    $0xc,%esp
80102e27:	50                   	push   %eax
80102e28:	e8 26 0e 00 00       	call   80103c53 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102e2d:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102e33:	83 c4 08             	add    $0x8,%esp
80102e36:	53                   	push   %ebx
80102e37:	50                   	push   %eax
80102e38:	e8 6d 0c 00 00       	call   80103aaa <sleep>
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
80102e5e:	e8 dc 03 00 00       	call   8010323f <myproc>
80102e63:	83 78 30 00          	cmpl   $0x0,0x30(%eax)
80102e67:	74 b5                	je     80102e1e <pipewrite+0x3d>
        release(&p->lock);
80102e69:	83 ec 0c             	sub    $0xc,%esp
80102e6c:	53                   	push   %ebx
80102e6d:	e8 42 12 00 00       	call   801040b4 <release>
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
80102eb3:	e8 97 11 00 00       	call   8010404f <acquire>
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
80102ec8:	e8 dd 0b 00 00       	call   80103aaa <sleep>
80102ecd:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102ed0:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102ed6:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80102edc:	75 75                	jne    80102f53 <piperead+0xb0>
80102ede:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80102ee4:	85 f6                	test   %esi,%esi
80102ee6:	74 34                	je     80102f1c <piperead+0x79>
    if(myproc()->killed){
80102ee8:	e8 52 03 00 00       	call   8010323f <myproc>
80102eed:	83 78 30 00          	cmpl   $0x0,0x30(%eax)
80102ef1:	74 ca                	je     80102ebd <piperead+0x1a>
      release(&p->lock);
80102ef3:	83 ec 0c             	sub    $0xc,%esp
80102ef6:	53                   	push   %ebx
80102ef7:	e8 b8 11 00 00       	call   801040b4 <release>
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
80102f39:	e8 15 0d 00 00       	call   80103c53 <wakeup>
  release(&p->lock);
80102f3e:	89 1c 24             	mov    %ebx,(%esp)
80102f41:	e8 6e 11 00 00       	call   801040b4 <release>
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
// PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80102f5a:	55                   	push   %ebp
80102f5b:	89 e5                	mov    %esp,%ebp
80102f5d:	56                   	push   %esi
80102f5e:	53                   	push   %ebx
80102f5f:	89 c3                	mov    %eax,%ebx
  struct proc *p;
	for(int i=0; i<NPRI; i++){
80102f61:	b9 00 00 00 00       	mov    $0x0,%ecx
80102f66:	eb 32                	jmp    80102f9a <wakeup1+0x40>
		for(p = ptable.proc[i]; p < &ptable.proc[i][NPROC]; p++){
80102f68:	81 c2 88 00 00 00    	add    $0x88,%edx
80102f6e:	8d 71 01             	lea    0x1(%ecx),%esi
80102f71:	89 f0                	mov    %esi,%eax
80102f73:	c1 e0 04             	shl    $0x4,%eax
80102f76:	01 f0                	add    %esi,%eax
80102f78:	c1 e0 08             	shl    $0x8,%eax
80102f7b:	05 54 1d 11 80       	add    $0x80111d54,%eax
80102f80:	39 d0                	cmp    %edx,%eax
80102f82:	76 14                	jbe    80102f98 <wakeup1+0x3e>
			if(p->state == SLEEPING && p->chan == chan)
80102f84:	83 7a 14 02          	cmpl   $0x2,0x14(%edx)
80102f88:	75 de                	jne    80102f68 <wakeup1+0xe>
80102f8a:	39 5a 2c             	cmp    %ebx,0x2c(%edx)
80102f8d:	75 d9                	jne    80102f68 <wakeup1+0xe>
      	p->state = RUNNABLE;		
80102f8f:	c7 42 14 03 00 00 00 	movl   $0x3,0x14(%edx)
80102f96:	eb d0                	jmp    80102f68 <wakeup1+0xe>
	for(int i=0; i<NPRI; i++){
80102f98:	89 f1                	mov    %esi,%ecx
80102f9a:	83 f9 01             	cmp    $0x1,%ecx
80102f9d:	7f 12                	jg     80102fb1 <wakeup1+0x57>
		for(p = ptable.proc[i]; p < &ptable.proc[i][NPROC]; p++){
80102f9f:	89 ca                	mov    %ecx,%edx
80102fa1:	c1 e2 04             	shl    $0x4,%edx
80102fa4:	01 ca                	add    %ecx,%edx
80102fa6:	c1 e2 08             	shl    $0x8,%edx
80102fa9:	81 c2 54 1d 11 80    	add    $0x80111d54,%edx
80102faf:	eb bd                	jmp    80102f6e <wakeup1+0x14>
		}
	}
}
80102fb1:	5b                   	pop    %ebx
80102fb2:	5e                   	pop    %esi
80102fb3:	5d                   	pop    %ebp
80102fb4:	c3                   	ret    

80102fb5 <allocproc>:
{
80102fb5:	55                   	push   %ebp
80102fb6:	89 e5                	mov    %esp,%ebp
80102fb8:	53                   	push   %ebx
80102fb9:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80102fbc:	68 20 1d 11 80       	push   $0x80111d20
80102fc1:	e8 89 10 00 00       	call   8010404f <acquire>
		for(p = ptable.proc[i]; p < &ptable.proc[i][NPROC]; p++){
80102fc6:	83 c4 10             	add    $0x10,%esp
80102fc9:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80102fce:	81 fb 54 2e 11 80    	cmp    $0x80112e54,%ebx
80102fd4:	73 7e                	jae    80103054 <allocproc+0x9f>
			if(p->state == UNUSED)
80102fd6:	83 7b 14 00          	cmpl   $0x0,0x14(%ebx)
80102fda:	74 08                	je     80102fe4 <allocproc+0x2f>
		for(p = ptable.proc[i]; p < &ptable.proc[i][NPROC]; p++){
80102fdc:	81 c3 88 00 00 00    	add    $0x88,%ebx
80102fe2:	eb ea                	jmp    80102fce <allocproc+0x19>
  p->state = EMBRYO;
80102fe4:	c7 43 14 01 00 00 00 	movl   $0x1,0x14(%ebx)
  p->pid = nextpid++;
80102feb:	a1 04 a0 10 80       	mov    0x8010a004,%eax
80102ff0:	8d 50 01             	lea    0x1(%eax),%edx
80102ff3:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
80102ff9:	89 43 18             	mov    %eax,0x18(%ebx)
  release(&ptable.lock);
80102ffc:	83 ec 0c             	sub    $0xc,%esp
80102fff:	68 20 1d 11 80       	push   $0x80111d20
80103004:	e8 ab 10 00 00       	call   801040b4 <release>
  if((p->kstack = kalloc()) == 0){
80103009:	e8 31 f0 ff ff       	call   8010203f <kalloc>
8010300e:	89 43 10             	mov    %eax,0x10(%ebx)
80103011:	83 c4 10             	add    $0x10,%esp
80103014:	85 c0                	test   %eax,%eax
80103016:	74 53                	je     8010306b <allocproc+0xb6>
  sp -= sizeof *p->tf;
80103018:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
8010301e:	89 53 20             	mov    %edx,0x20(%ebx)
  *(uint*)sp = (uint)trapret;
80103021:	c7 80 b0 0f 00 00 54 	movl   $0x80105354,0xfb0(%eax)
80103028:	53 10 80 
  sp -= sizeof *p->context;
8010302b:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80103030:	89 43 28             	mov    %eax,0x28(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103033:	83 ec 04             	sub    $0x4,%esp
80103036:	6a 14                	push   $0x14
80103038:	6a 00                	push   $0x0
8010303a:	50                   	push   %eax
8010303b:	e8 bb 10 00 00       	call   801040fb <memset>
  p->context->eip = (uint)forkret;
80103040:	8b 43 28             	mov    0x28(%ebx),%eax
80103043:	c7 40 10 4d 31 10 80 	movl   $0x8010314d,0x10(%eax)
  return p;
8010304a:	83 c4 10             	add    $0x10,%esp
}
8010304d:	89 d8                	mov    %ebx,%eax
8010304f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103052:	c9                   	leave  
80103053:	c3                   	ret    
  release(&ptable.lock);
80103054:	83 ec 0c             	sub    $0xc,%esp
80103057:	68 20 1d 11 80       	push   $0x80111d20
8010305c:	e8 53 10 00 00       	call   801040b4 <release>
  return 0;
80103061:	83 c4 10             	add    $0x10,%esp
80103064:	bb 00 00 00 00       	mov    $0x0,%ebx
80103069:	eb e2                	jmp    8010304d <allocproc+0x98>
    p->state = UNUSED;
8010306b:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
    return 0;
80103072:	89 c3                	mov    %eax,%ebx
80103074:	eb d7                	jmp    8010304d <allocproc+0x98>

80103076 <allocproc1>:
{
80103076:	55                   	push   %ebp
80103077:	89 e5                	mov    %esp,%ebp
80103079:	57                   	push   %edi
8010307a:	56                   	push   %esi
8010307b:	53                   	push   %ebx
8010307c:	83 ec 18             	sub    $0x18,%esp
8010307f:	89 c7                	mov    %eax,%edi
80103081:	89 d6                	mov    %edx,%esi
  acquire(&ptable.lock);
80103083:	68 20 1d 11 80       	push   $0x80111d20
80103088:	e8 c2 0f 00 00       	call   8010404f <acquire>
  for(p = ptable.proc[i]; p < &ptable.proc[i][NPROC]; p++){
8010308d:	89 f3                	mov    %esi,%ebx
8010308f:	c1 e3 04             	shl    $0x4,%ebx
80103092:	01 f3                	add    %esi,%ebx
80103094:	c1 e3 08             	shl    $0x8,%ebx
80103097:	81 c3 54 1d 11 80    	add    $0x80111d54,%ebx
8010309d:	83 c4 10             	add    $0x10,%esp
801030a0:	eb 06                	jmp    801030a8 <allocproc1+0x32>
801030a2:	81 c3 88 00 00 00    	add    $0x88,%ebx
801030a8:	8d 56 01             	lea    0x1(%esi),%edx
801030ab:	89 d0                	mov    %edx,%eax
801030ad:	c1 e0 04             	shl    $0x4,%eax
801030b0:	01 d0                	add    %edx,%eax
801030b2:	c1 e0 08             	shl    $0x8,%eax
801030b5:	05 54 1d 11 80       	add    $0x80111d54,%eax
801030ba:	39 d8                	cmp    %ebx,%eax
801030bc:	76 65                	jbe    80103123 <allocproc1+0xad>
  	if(p->state == UNUSED)
801030be:	83 7b 14 00          	cmpl   $0x0,0x14(%ebx)
801030c2:	75 de                	jne    801030a2 <allocproc1+0x2c>
  p->state = EMBRYO;
801030c4:	c7 43 14 01 00 00 00 	movl   $0x1,0x14(%ebx)
  p->pid = ppid;
801030cb:	89 7b 18             	mov    %edi,0x18(%ebx)
	p->prio = prio;  
801030ce:	89 33                	mov    %esi,(%ebx)
  release(&ptable.lock);
801030d0:	83 ec 0c             	sub    $0xc,%esp
801030d3:	68 20 1d 11 80       	push   $0x80111d20
801030d8:	e8 d7 0f 00 00       	call   801040b4 <release>
  if((p->kstack = kalloc()) == 0){
801030dd:	e8 5d ef ff ff       	call   8010203f <kalloc>
801030e2:	89 43 10             	mov    %eax,0x10(%ebx)
801030e5:	83 c4 10             	add    $0x10,%esp
801030e8:	85 c0                	test   %eax,%eax
801030ea:	74 56                	je     80103142 <allocproc1+0xcc>
  sp -= sizeof *p->tf;
801030ec:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
801030f2:	89 53 20             	mov    %edx,0x20(%ebx)
  *(uint*)sp = (uint)trapret;
801030f5:	c7 80 b0 0f 00 00 54 	movl   $0x80105354,0xfb0(%eax)
801030fc:	53 10 80 
  sp -= sizeof *p->context;
801030ff:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80103104:	89 43 28             	mov    %eax,0x28(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103107:	83 ec 04             	sub    $0x4,%esp
8010310a:	6a 14                	push   $0x14
8010310c:	6a 00                	push   $0x0
8010310e:	50                   	push   %eax
8010310f:	e8 e7 0f 00 00       	call   801040fb <memset>
  p->context->eip = (uint)forkret;
80103114:	8b 43 28             	mov    0x28(%ebx),%eax
80103117:	c7 40 10 4d 31 10 80 	movl   $0x8010314d,0x10(%eax)
  return p;
8010311e:	83 c4 10             	add    $0x10,%esp
80103121:	eb 15                	jmp    80103138 <allocproc1+0xc2>
  release(&ptable.lock);
80103123:	83 ec 0c             	sub    $0xc,%esp
80103126:	68 20 1d 11 80       	push   $0x80111d20
8010312b:	e8 84 0f 00 00       	call   801040b4 <release>
  return 0;
80103130:	83 c4 10             	add    $0x10,%esp
80103133:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80103138:	89 d8                	mov    %ebx,%eax
8010313a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010313d:	5b                   	pop    %ebx
8010313e:	5e                   	pop    %esi
8010313f:	5f                   	pop    %edi
80103140:	5d                   	pop    %ebp
80103141:	c3                   	ret    
    p->state = UNUSED;
80103142:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
    return 0;
80103149:	89 c3                	mov    %eax,%ebx
8010314b:	eb eb                	jmp    80103138 <allocproc1+0xc2>

8010314d <forkret>:
{
8010314d:	55                   	push   %ebp
8010314e:	89 e5                	mov    %esp,%ebp
80103150:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
80103153:	68 20 1d 11 80       	push   $0x80111d20
80103158:	e8 57 0f 00 00       	call   801040b4 <release>
  if (first) {
8010315d:	83 c4 10             	add    $0x10,%esp
80103160:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
80103167:	75 02                	jne    8010316b <forkret+0x1e>
}
80103169:	c9                   	leave  
8010316a:	c3                   	ret    
    first = 0;
8010316b:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
80103172:	00 00 00 
    iinit(ROOTDEV);
80103175:	83 ec 0c             	sub    $0xc,%esp
80103178:	6a 01                	push   $0x1
8010317a:	e8 17 e1 ff ff       	call   80101296 <iinit>
    initlog(ROOTDEV);
8010317f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103186:	e8 20 f5 ff ff       	call   801026ab <initlog>
8010318b:	83 c4 10             	add    $0x10,%esp
}
8010318e:	eb d9                	jmp    80103169 <forkret+0x1c>

80103190 <pinit>:
{
80103190:	55                   	push   %ebp
80103191:	89 e5                	mov    %esp,%ebp
80103193:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103196:	68 40 74 10 80       	push   $0x80107440
8010319b:	68 20 1d 11 80       	push   $0x80111d20
801031a0:	e8 73 0d 00 00       	call   80103f18 <initlock>
}
801031a5:	83 c4 10             	add    $0x10,%esp
801031a8:	c9                   	leave  
801031a9:	c3                   	ret    

801031aa <mycpu>:
{
801031aa:	55                   	push   %ebp
801031ab:	89 e5                	mov    %esp,%ebp
801031ad:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801031b0:	9c                   	pushf  
801031b1:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801031b2:	f6 c4 02             	test   $0x2,%ah
801031b5:	75 2c                	jne    801031e3 <mycpu+0x39>
  apicid = lapicid();
801031b7:	e8 3f f1 ff ff       	call   801022fb <lapicid>
801031bc:	89 c1                	mov    %eax,%ecx
  for (i = 0; i < ncpu; ++i) {
801031be:	ba 00 00 00 00       	mov    $0x0,%edx
801031c3:	39 15 84 17 11 80    	cmp    %edx,0x80111784
801031c9:	7e 25                	jle    801031f0 <mycpu+0x46>
    if (cpus[i].apicid == apicid)
801031cb:	8d 04 92             	lea    (%edx,%edx,4),%eax
801031ce:	01 c0                	add    %eax,%eax
801031d0:	01 d0                	add    %edx,%eax
801031d2:	c1 e0 04             	shl    $0x4,%eax
801031d5:	0f b6 80 a0 17 11 80 	movzbl -0x7feee860(%eax),%eax
801031dc:	39 c8                	cmp    %ecx,%eax
801031de:	74 1d                	je     801031fd <mycpu+0x53>
  for (i = 0; i < ncpu; ++i) {
801031e0:	42                   	inc    %edx
801031e1:	eb e0                	jmp    801031c3 <mycpu+0x19>
    panic("mycpu called with interrupts enabled\n");
801031e3:	83 ec 0c             	sub    $0xc,%esp
801031e6:	68 78 75 10 80       	push   $0x80107578
801031eb:	e8 51 d1 ff ff       	call   80100341 <panic>
  panic("unknown apicid\n");
801031f0:	83 ec 0c             	sub    $0xc,%esp
801031f3:	68 47 74 10 80       	push   $0x80107447
801031f8:	e8 44 d1 ff ff       	call   80100341 <panic>
      return &cpus[i];
801031fd:	8d 04 92             	lea    (%edx,%edx,4),%eax
80103200:	01 c0                	add    %eax,%eax
80103202:	01 d0                	add    %edx,%eax
80103204:	c1 e0 04             	shl    $0x4,%eax
80103207:	05 a0 17 11 80       	add    $0x801117a0,%eax
}
8010320c:	c9                   	leave  
8010320d:	c3                   	ret    

8010320e <cpuid>:
cpuid() {
8010320e:	55                   	push   %ebp
8010320f:	89 e5                	mov    %esp,%ebp
80103211:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103214:	e8 91 ff ff ff       	call   801031aa <mycpu>
80103219:	2d a0 17 11 80       	sub    $0x801117a0,%eax
8010321e:	c1 f8 04             	sar    $0x4,%eax
80103221:	8d 0c c0             	lea    (%eax,%eax,8),%ecx
80103224:	89 ca                	mov    %ecx,%edx
80103226:	c1 e2 05             	shl    $0x5,%edx
80103229:	29 ca                	sub    %ecx,%edx
8010322b:	8d 14 90             	lea    (%eax,%edx,4),%edx
8010322e:	8d 0c d0             	lea    (%eax,%edx,8),%ecx
80103231:	89 ca                	mov    %ecx,%edx
80103233:	c1 e2 0f             	shl    $0xf,%edx
80103236:	29 ca                	sub    %ecx,%edx
80103238:	8d 04 90             	lea    (%eax,%edx,4),%eax
8010323b:	f7 d8                	neg    %eax
}
8010323d:	c9                   	leave  
8010323e:	c3                   	ret    

8010323f <myproc>:
myproc(void) {
8010323f:	55                   	push   %ebp
80103240:	89 e5                	mov    %esp,%ebp
80103242:	53                   	push   %ebx
80103243:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103246:	e8 2a 0d 00 00       	call   80103f75 <pushcli>
  c = mycpu();
8010324b:	e8 5a ff ff ff       	call   801031aa <mycpu>
  p = c->proc;
80103250:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103256:	e8 55 0d 00 00       	call   80103fb0 <popcli>
}
8010325b:	89 d8                	mov    %ebx,%eax
8010325d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103260:	c9                   	leave  
80103261:	c3                   	ret    

80103262 <userinit>:
{
80103262:	55                   	push   %ebp
80103263:	89 e5                	mov    %esp,%ebp
80103265:	53                   	push   %ebx
80103266:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103269:	e8 47 fd ff ff       	call   80102fb5 <allocproc>
8010326e:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103270:	a3 54 3f 11 80       	mov    %eax,0x80113f54
  if((p->pgdir = setupkvm()) == 0)
80103275:	e8 54 39 00 00       	call   80106bce <setupkvm>
8010327a:	89 43 0c             	mov    %eax,0xc(%ebx)
8010327d:	85 c0                	test   %eax,%eax
8010327f:	0f 84 b7 00 00 00    	je     8010333c <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103285:	83 ec 04             	sub    $0x4,%esp
80103288:	68 2c 00 00 00       	push   $0x2c
8010328d:	68 60 a4 10 80       	push   $0x8010a460
80103292:	50                   	push   %eax
80103293:	e8 41 36 00 00       	call   801068d9 <inituvm>
  p->sz = PGSIZE;
80103298:	c7 43 08 00 10 00 00 	movl   $0x1000,0x8(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
8010329f:	8b 43 20             	mov    0x20(%ebx),%eax
801032a2:	83 c4 0c             	add    $0xc,%esp
801032a5:	6a 4c                	push   $0x4c
801032a7:	6a 00                	push   $0x0
801032a9:	50                   	push   %eax
801032aa:	e8 4c 0e 00 00       	call   801040fb <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801032af:	8b 43 20             	mov    0x20(%ebx),%eax
801032b2:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801032b8:	8b 43 20             	mov    0x20(%ebx),%eax
801032bb:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801032c1:	8b 43 20             	mov    0x20(%ebx),%eax
801032c4:	8b 50 2c             	mov    0x2c(%eax),%edx
801032c7:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801032cb:	8b 43 20             	mov    0x20(%ebx),%eax
801032ce:	8b 50 2c             	mov    0x2c(%eax),%edx
801032d1:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801032d5:	8b 43 20             	mov    0x20(%ebx),%eax
801032d8:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801032df:	8b 43 20             	mov    0x20(%ebx),%eax
801032e2:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801032e9:	8b 43 20             	mov    0x20(%ebx),%eax
801032ec:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
801032f3:	8d 43 78             	lea    0x78(%ebx),%eax
801032f6:	83 c4 0c             	add    $0xc,%esp
801032f9:	6a 10                	push   $0x10
801032fb:	68 70 74 10 80       	push   $0x80107470
80103300:	50                   	push   %eax
80103301:	e8 4d 0f 00 00       	call   80104253 <safestrcpy>
  p->cwd = namei("/");
80103306:	c7 04 24 79 74 10 80 	movl   $0x80107479,(%esp)
8010330d:	e8 70 e8 ff ff       	call   80101b82 <namei>
80103312:	89 43 74             	mov    %eax,0x74(%ebx)
  acquire(&ptable.lock);
80103315:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010331c:	e8 2e 0d 00 00       	call   8010404f <acquire>
  p->state = RUNNABLE;
80103321:	c7 43 14 03 00 00 00 	movl   $0x3,0x14(%ebx)
  release(&ptable.lock);
80103328:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010332f:	e8 80 0d 00 00       	call   801040b4 <release>
}
80103334:	83 c4 10             	add    $0x10,%esp
80103337:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010333a:	c9                   	leave  
8010333b:	c3                   	ret    
    panic("userinit: out of memory?");
8010333c:	83 ec 0c             	sub    $0xc,%esp
8010333f:	68 57 74 10 80       	push   $0x80107457
80103344:	e8 f8 cf ff ff       	call   80100341 <panic>

80103349 <growproc>:
{
80103349:	55                   	push   %ebp
8010334a:	89 e5                	mov    %esp,%ebp
8010334c:	56                   	push   %esi
8010334d:	53                   	push   %ebx
8010334e:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
80103351:	e8 e9 fe ff ff       	call   8010323f <myproc>
80103356:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;//Tamaño inicial
80103358:	8b 40 08             	mov    0x8(%eax),%eax
  if(n > 0){
8010335b:	85 f6                	test   %esi,%esi
8010335d:	7f 1c                	jg     8010337b <growproc+0x32>
  } else if(n < 0){
8010335f:	78 37                	js     80103398 <growproc+0x4f>
  curproc->sz = sz;
80103361:	89 43 08             	mov    %eax,0x8(%ebx)
  lcr3(V2P(curproc->pgdir));  // Invalidate TLB. Cambia la tabla de páginas
80103364:	8b 43 0c             	mov    0xc(%ebx),%eax
80103367:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010336c:	0f 22 d8             	mov    %eax,%cr3
  return 0;
8010336f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103374:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103377:	5b                   	pop    %ebx
80103378:	5e                   	pop    %esi
80103379:	5d                   	pop    %ebp
8010337a:	c3                   	ret    
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010337b:	83 ec 04             	sub    $0x4,%esp
8010337e:	01 c6                	add    %eax,%esi
80103380:	56                   	push   %esi
80103381:	50                   	push   %eax
80103382:	ff 73 0c             	push   0xc(%ebx)
80103385:	e8 e1 36 00 00       	call   80106a6b <allocuvm>
8010338a:	83 c4 10             	add    $0x10,%esp
8010338d:	85 c0                	test   %eax,%eax
8010338f:	75 d0                	jne    80103361 <growproc+0x18>
      return -1;
80103391:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103396:	eb dc                	jmp    80103374 <growproc+0x2b>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103398:	83 ec 04             	sub    $0x4,%esp
8010339b:	01 c6                	add    %eax,%esi
8010339d:	56                   	push   %esi
8010339e:	50                   	push   %eax
8010339f:	ff 73 0c             	push   0xc(%ebx)
801033a2:	e8 34 36 00 00       	call   801069db <deallocuvm>
801033a7:	83 c4 10             	add    $0x10,%esp
801033aa:	85 c0                	test   %eax,%eax
801033ac:	75 b3                	jne    80103361 <growproc+0x18>
      return -1;
801033ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801033b3:	eb bf                	jmp    80103374 <growproc+0x2b>

801033b5 <fork>:
{
801033b5:	55                   	push   %ebp
801033b6:	89 e5                	mov    %esp,%ebp
801033b8:	57                   	push   %edi
801033b9:	56                   	push   %esi
801033ba:	53                   	push   %ebx
801033bb:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
801033be:	e8 7c fe ff ff       	call   8010323f <myproc>
801033c3:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
801033c5:	e8 eb fb ff ff       	call   80102fb5 <allocproc>
801033ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801033cd:	85 c0                	test   %eax,%eax
801033cf:	0f 84 e3 00 00 00    	je     801034b8 <fork+0x103>
801033d5:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm1(curproc->pgdir, curproc->sz)) == 0){
801033d7:	83 ec 08             	sub    $0x8,%esp
801033da:	ff 73 08             	push   0x8(%ebx)
801033dd:	ff 73 0c             	push   0xc(%ebx)
801033e0:	e8 86 39 00 00       	call   80106d6b <copyuvm1>
801033e5:	89 47 0c             	mov    %eax,0xc(%edi)
801033e8:	83 c4 10             	add    $0x10,%esp
801033eb:	85 c0                	test   %eax,%eax
801033ed:	74 2e                	je     8010341d <fork+0x68>
  np->sz = curproc->sz;
801033ef:	8b 43 08             	mov    0x8(%ebx),%eax
801033f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801033f5:	89 42 08             	mov    %eax,0x8(%edx)
  np->parent = curproc;
801033f8:	89 5a 1c             	mov    %ebx,0x1c(%edx)
  *np->tf = *curproc->tf;
801033fb:	8b 73 20             	mov    0x20(%ebx),%esi
801033fe:	8b 7a 20             	mov    0x20(%edx),%edi
80103401:	b9 13 00 00 00       	mov    $0x13,%ecx
80103406:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	np->prio = curproc->prio;
80103408:	8b 03                	mov    (%ebx),%eax
8010340a:	89 02                	mov    %eax,(%edx)
  np->tf->eax = 0;
8010340c:	8b 42 20             	mov    0x20(%edx),%eax
8010340f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103416:	be 00 00 00 00       	mov    $0x0,%esi
8010341b:	eb 27                	jmp    80103444 <fork+0x8f>
    kfree(np->kstack);
8010341d:	83 ec 0c             	sub    $0xc,%esp
80103420:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103423:	ff 73 10             	push   0x10(%ebx)
80103426:	e8 fd ea ff ff       	call   80101f28 <kfree>
    np->kstack = 0;
8010342b:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
    np->state = UNUSED;
80103432:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
    return -1;
80103439:	83 c4 10             	add    $0x10,%esp
8010343c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103441:	eb 6b                	jmp    801034ae <fork+0xf9>
  for(i = 0; i < NOFILE; i++)
80103443:	46                   	inc    %esi
80103444:	83 fe 0f             	cmp    $0xf,%esi
80103447:	7f 1d                	jg     80103466 <fork+0xb1>
    if(curproc->ofile[i])
80103449:	8b 44 b3 34          	mov    0x34(%ebx,%esi,4),%eax
8010344d:	85 c0                	test   %eax,%eax
8010344f:	74 f2                	je     80103443 <fork+0x8e>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103451:	83 ec 0c             	sub    $0xc,%esp
80103454:	50                   	push   %eax
80103455:	e8 05 d8 ff ff       	call   80100c5f <filedup>
8010345a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010345d:	89 44 b2 34          	mov    %eax,0x34(%edx,%esi,4)
80103461:	83 c4 10             	add    $0x10,%esp
80103464:	eb dd                	jmp    80103443 <fork+0x8e>
  np->cwd = idup(curproc->cwd);
80103466:	83 ec 0c             	sub    $0xc,%esp
80103469:	ff 73 74             	push   0x74(%ebx)
8010346c:	e8 7f e0 ff ff       	call   801014f0 <idup>
80103471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103474:	89 47 74             	mov    %eax,0x74(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103477:	83 c3 78             	add    $0x78,%ebx
8010347a:	8d 47 78             	lea    0x78(%edi),%eax
8010347d:	83 c4 0c             	add    $0xc,%esp
80103480:	6a 10                	push   $0x10
80103482:	53                   	push   %ebx
80103483:	50                   	push   %eax
80103484:	e8 ca 0d 00 00       	call   80104253 <safestrcpy>
  pid = np->pid;
80103489:	8b 5f 18             	mov    0x18(%edi),%ebx
  acquire(&ptable.lock);
8010348c:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103493:	e8 b7 0b 00 00       	call   8010404f <acquire>
  np->state = RUNNABLE;
80103498:	c7 47 14 03 00 00 00 	movl   $0x3,0x14(%edi)
  release(&ptable.lock);
8010349f:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801034a6:	e8 09 0c 00 00       	call   801040b4 <release>
  return pid;
801034ab:	83 c4 10             	add    $0x10,%esp
}
801034ae:	89 d8                	mov    %ebx,%eax
801034b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801034b3:	5b                   	pop    %ebx
801034b4:	5e                   	pop    %esi
801034b5:	5f                   	pop    %edi
801034b6:	5d                   	pop    %ebp
801034b7:	c3                   	ret    
    return -1;
801034b8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801034bd:	eb ef                	jmp    801034ae <fork+0xf9>

801034bf <fork1>:
{
801034bf:	55                   	push   %ebp
801034c0:	89 e5                	mov    %esp,%ebp
801034c2:	57                   	push   %edi
801034c3:	56                   	push   %esi
801034c4:	53                   	push   %ebx
801034c5:	83 ec 1c             	sub    $0x1c,%esp
801034c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((np = allocproc1(curproc->pid, prio)) == 0){
801034cb:	8b 43 18             	mov    0x18(%ebx),%eax
801034ce:	8b 55 0c             	mov    0xc(%ebp),%edx
801034d1:	e8 a0 fb ff ff       	call   80103076 <allocproc1>
801034d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801034d9:	85 c0                	test   %eax,%eax
801034db:	0f 84 04 01 00 00    	je     801035e5 <fork1+0x126>
801034e1:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm1(curproc->pgdir, curproc->sz)) == 0){
801034e3:	83 ec 08             	sub    $0x8,%esp
801034e6:	ff 73 08             	push   0x8(%ebx)
801034e9:	ff 73 0c             	push   0xc(%ebx)
801034ec:	e8 7a 38 00 00       	call   80106d6b <copyuvm1>
801034f1:	89 47 0c             	mov    %eax,0xc(%edi)
801034f4:	83 c4 10             	add    $0x10,%esp
801034f7:	85 c0                	test   %eax,%eax
801034f9:	74 34                	je     8010352f <fork1+0x70>
  np->sz = curproc->sz;
801034fb:	8b 43 08             	mov    0x8(%ebx),%eax
801034fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103501:	89 42 08             	mov    %eax,0x8(%edx)
  np->parent = curproc->parent;
80103504:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103507:	89 42 1c             	mov    %eax,0x1c(%edx)
  *np->tf = *curproc->tf;
8010350a:	8b 73 20             	mov    0x20(%ebx),%esi
8010350d:	8b 7a 20             	mov    0x20(%edx),%edi
80103510:	b9 13 00 00 00       	mov    $0x13,%ecx
80103515:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	curproc->pid = 0;
80103517:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
  np->tf->eax = 0;
8010351e:	8b 42 20             	mov    0x20(%edx),%eax
80103521:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103528:	be 00 00 00 00       	mov    $0x0,%esi
8010352d:	eb 2a                	jmp    80103559 <fork1+0x9a>
    kfree(np->kstack);
8010352f:	83 ec 0c             	sub    $0xc,%esp
80103532:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103535:	ff 73 10             	push   0x10(%ebx)
80103538:	e8 eb e9 ff ff       	call   80101f28 <kfree>
    np->kstack = 0;
8010353d:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
    np->state = UNUSED;
80103544:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
    return -1;
8010354b:	83 c4 10             	add    $0x10,%esp
8010354e:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103553:	e9 83 00 00 00       	jmp    801035db <fork1+0x11c>
  for(i = 0; i < NOFILE; i++)
80103558:	46                   	inc    %esi
80103559:	83 fe 0f             	cmp    $0xf,%esi
8010355c:	7f 1d                	jg     8010357b <fork1+0xbc>
    if(curproc->ofile[i])
8010355e:	8b 44 b3 34          	mov    0x34(%ebx,%esi,4),%eax
80103562:	85 c0                	test   %eax,%eax
80103564:	74 f2                	je     80103558 <fork1+0x99>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103566:	83 ec 0c             	sub    $0xc,%esp
80103569:	50                   	push   %eax
8010356a:	e8 f0 d6 ff ff       	call   80100c5f <filedup>
8010356f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103572:	89 44 b1 34          	mov    %eax,0x34(%ecx,%esi,4)
80103576:	83 c4 10             	add    $0x10,%esp
80103579:	eb dd                	jmp    80103558 <fork1+0x99>
  np->cwd = idup(curproc->cwd);
8010357b:	83 ec 0c             	sub    $0xc,%esp
8010357e:	ff 73 74             	push   0x74(%ebx)
80103581:	e8 6a df ff ff       	call   801014f0 <idup>
80103586:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103589:	89 47 74             	mov    %eax,0x74(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010358c:	8d 53 78             	lea    0x78(%ebx),%edx
8010358f:	8d 47 78             	lea    0x78(%edi),%eax
80103592:	83 c4 0c             	add    $0xc,%esp
80103595:	6a 10                	push   $0x10
80103597:	52                   	push   %edx
80103598:	50                   	push   %eax
80103599:	e8 b5 0c 00 00       	call   80104253 <safestrcpy>
  pid = np->pid;
8010359e:	8b 77 18             	mov    0x18(%edi),%esi
  acquire(&ptable.lock);
801035a1:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801035a8:	e8 a2 0a 00 00       	call   8010404f <acquire>
  np->state = RUNNABLE;
801035ad:	c7 47 14 03 00 00 00 	movl   $0x3,0x14(%edi)
	curproc->state = UNUSED;
801035b4:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
	cprintf("pprio=%d, prio=%d\n",curproc->prio, np->prio);
801035bb:	83 c4 0c             	add    $0xc,%esp
801035be:	ff 37                	push   (%edi)
801035c0:	ff 33                	push   (%ebx)
801035c2:	68 7b 74 10 80       	push   $0x8010747b
801035c7:	e8 0e d0 ff ff       	call   801005da <cprintf>
  release(&ptable.lock);
801035cc:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801035d3:	e8 dc 0a 00 00       	call   801040b4 <release>
  return pid;
801035d8:	83 c4 10             	add    $0x10,%esp
}
801035db:	89 f0                	mov    %esi,%eax
801035dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801035e0:	5b                   	pop    %ebx
801035e1:	5e                   	pop    %esi
801035e2:	5f                   	pop    %edi
801035e3:	5d                   	pop    %ebp
801035e4:	c3                   	ret    
    return -1;
801035e5:	be ff ff ff ff       	mov    $0xffffffff,%esi
801035ea:	eb ef                	jmp    801035db <fork1+0x11c>

801035ec <getprio>:
{
801035ec:	55                   	push   %ebp
801035ed:	89 e5                	mov    %esp,%ebp
801035ef:	57                   	push   %edi
801035f0:	56                   	push   %esi
801035f1:	53                   	push   %ebx
801035f2:	83 ec 14             	sub    $0x14,%esp
801035f5:	8b 7d 08             	mov    0x8(%ebp),%edi
	cprintf("pid looking for=%d\n",pid);
801035f8:	57                   	push   %edi
801035f9:	68 8e 74 10 80       	push   $0x8010748e
801035fe:	e8 d7 cf ff ff       	call   801005da <cprintf>
	acquire(&ptable.lock);
80103603:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010360a:	e8 40 0a 00 00       	call   8010404f <acquire>
	for(i=0; i<NPRI; i++){
8010360f:	83 c4 10             	add    $0x10,%esp
80103612:	be 00 00 00 00       	mov    $0x0,%esi
80103617:	83 fe 01             	cmp    $0x1,%esi
8010361a:	7f 72                	jg     8010368e <getprio+0xa2>
		for(p = ptable.proc[i]; p < &ptable.proc[i][NPROC]; p++){
8010361c:	89 f0                	mov    %esi,%eax
8010361e:	c1 e0 04             	shl    $0x4,%eax
80103621:	01 f0                	add    %esi,%eax
80103623:	c1 e0 08             	shl    $0x8,%eax
80103626:	89 c3                	mov    %eax,%ebx
80103628:	81 c3 54 1d 11 80    	add    $0x80111d54,%ebx
8010362e:	8d 46 01             	lea    0x1(%esi),%eax
80103631:	89 c2                	mov    %eax,%edx
80103633:	c1 e2 04             	shl    $0x4,%edx
80103636:	01 c2                	add    %eax,%edx
80103638:	89 d0                	mov    %edx,%eax
8010363a:	c1 e0 08             	shl    $0x8,%eax
8010363d:	05 54 1d 11 80       	add    $0x80111d54,%eax
80103642:	39 d8                	cmp    %ebx,%eax
80103644:	76 45                	jbe    8010368b <getprio+0x9f>
			cprintf(".................................name=%s\n",p->name);
80103646:	8d 43 78             	lea    0x78(%ebx),%eax
80103649:	83 ec 08             	sub    $0x8,%esp
8010364c:	50                   	push   %eax
8010364d:	68 a0 75 10 80       	push   $0x801075a0
80103652:	e8 83 cf ff ff       	call   801005da <cprintf>
			if(p->pid == pid){
80103657:	83 c4 10             	add    $0x10,%esp
8010365a:	39 7b 18             	cmp    %edi,0x18(%ebx)
8010365d:	74 08                	je     80103667 <getprio+0x7b>
		for(p = ptable.proc[i]; p < &ptable.proc[i][NPROC]; p++){
8010365f:	81 c3 88 00 00 00    	add    $0x88,%ebx
80103665:	eb c7                	jmp    8010362e <getprio+0x42>
				release(&ptable.lock);
80103667:	83 ec 0c             	sub    $0xc,%esp
8010366a:	68 20 1d 11 80       	push   $0x80111d20
8010366f:	e8 40 0a 00 00       	call   801040b4 <release>
				cprintf("getprio_found: prio=%d, i=%d\n",p->prio,i);
80103674:	83 c4 0c             	add    $0xc,%esp
80103677:	56                   	push   %esi
80103678:	ff 33                	push   (%ebx)
8010367a:	68 a2 74 10 80       	push   $0x801074a2
8010367f:	e8 56 cf ff ff       	call   801005da <cprintf>
				return p->prio;//i
80103684:	8b 03                	mov    (%ebx),%eax
80103686:	83 c4 10             	add    $0x10,%esp
80103689:	eb 18                	jmp    801036a3 <getprio+0xb7>
	for(i=0; i<NPRI; i++){
8010368b:	46                   	inc    %esi
8010368c:	eb 89                	jmp    80103617 <getprio+0x2b>
	release(&ptable.lock);
8010368e:	83 ec 0c             	sub    $0xc,%esp
80103691:	68 20 1d 11 80       	push   $0x80111d20
80103696:	e8 19 0a 00 00       	call   801040b4 <release>
	return -1;
8010369b:	83 c4 10             	add    $0x10,%esp
8010369e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801036a6:	5b                   	pop    %ebx
801036a7:	5e                   	pop    %esi
801036a8:	5f                   	pop    %edi
801036a9:	5d                   	pop    %ebp
801036aa:	c3                   	ret    

801036ab <replace_process>:
{
801036ab:	55                   	push   %ebp
801036ac:	89 e5                	mov    %esp,%ebp
801036ae:	56                   	push   %esi
801036af:	53                   	push   %ebx
801036b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
801036b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	new->sz = old->sz;
801036b6:	8b 41 08             	mov    0x8(%ecx),%eax
801036b9:	89 43 08             	mov    %eax,0x8(%ebx)
	new->pgdir = old->pgdir;
801036bc:	8b 41 0c             	mov    0xc(%ecx),%eax
801036bf:	89 43 0c             	mov    %eax,0xc(%ebx)
	new->kstack = old->kstack;
801036c2:	8b 41 10             	mov    0x10(%ecx),%eax
801036c5:	89 43 10             	mov    %eax,0x10(%ebx)
	new->pid = old->pid;
801036c8:	8b 41 18             	mov    0x18(%ecx),%eax
801036cb:	89 43 18             	mov    %eax,0x18(%ebx)
	new->parent = old->parent;
801036ce:	8b 41 1c             	mov    0x1c(%ecx),%eax
801036d1:	89 43 1c             	mov    %eax,0x1c(%ebx)
	new->tf = old->tf;
801036d4:	8b 41 20             	mov    0x20(%ecx),%eax
801036d7:	89 43 20             	mov    %eax,0x20(%ebx)
	new->stack_end = old->stack_end;
801036da:	8b 41 24             	mov    0x24(%ecx),%eax
801036dd:	89 43 24             	mov    %eax,0x24(%ebx)
	new->context = old->context;
801036e0:	8b 41 28             	mov    0x28(%ecx),%eax
801036e3:	89 43 28             	mov    %eax,0x28(%ebx)
	new->chan = old->chan;
801036e6:	8b 41 2c             	mov    0x2c(%ecx),%eax
801036e9:	89 43 2c             	mov    %eax,0x2c(%ebx)
	for(i=0; i<NOFILE; i++){
801036ec:	b8 00 00 00 00       	mov    $0x0,%eax
801036f1:	eb 0c                	jmp    801036ff <replace_process+0x54>
		new->ofile[i] = old->ofile[i];
801036f3:	8d 50 0c             	lea    0xc(%eax),%edx
801036f6:	8b 74 91 04          	mov    0x4(%ecx,%edx,4),%esi
801036fa:	89 74 93 04          	mov    %esi,0x4(%ebx,%edx,4)
	for(i=0; i<NOFILE; i++){
801036fe:	40                   	inc    %eax
801036ff:	83 f8 0f             	cmp    $0xf,%eax
80103702:	7e ef                	jle    801036f3 <replace_process+0x48>
	new->cwd = old->cwd;
80103704:	8b 41 74             	mov    0x74(%ecx),%eax
80103707:	89 43 74             	mov    %eax,0x74(%ebx)
	old->cwd = 0;
8010370a:	c7 41 74 00 00 00 00 	movl   $0x0,0x74(%ecx)
	for(i=0; i<16; i++){
80103711:	b8 00 00 00 00       	mov    $0x0,%eax
80103716:	eb 09                	jmp    80103721 <replace_process+0x76>
		new->name[i] = old->name[i];
80103718:	8a 54 01 78          	mov    0x78(%ecx,%eax,1),%dl
8010371c:	88 54 03 78          	mov    %dl,0x78(%ebx,%eax,1)
	for(i=0; i<16; i++){
80103720:	40                   	inc    %eax
80103721:	83 f8 0f             	cmp    $0xf,%eax
80103724:	7e f2                	jle    80103718 <replace_process+0x6d>
}
80103726:	5b                   	pop    %ebx
80103727:	5e                   	pop    %esi
80103728:	5d                   	pop    %ebp
80103729:	c3                   	ret    

8010372a <scheduler>:
{
8010372a:	55                   	push   %ebp
8010372b:	89 e5                	mov    %esp,%ebp
8010372d:	56                   	push   %esi
8010372e:	53                   	push   %ebx
  struct cpu *c = mycpu();
8010372f:	e8 76 fa ff ff       	call   801031aa <mycpu>
80103734:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103736:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010373d:	00 00 00 
80103740:	e9 8c 00 00 00       	jmp    801037d1 <scheduler+0xa7>
      	c->proc = p;
80103745:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      	switchuvm(p);
8010374b:	83 ec 0c             	sub    $0xc,%esp
8010374e:	53                   	push   %ebx
8010374f:	e8 29 30 00 00       	call   8010677d <switchuvm>
      	p->state = RUNNING;
80103754:	c7 43 14 04 00 00 00 	movl   $0x4,0x14(%ebx)
      	swtch(&(c->scheduler), p->context);
8010375b:	83 c4 08             	add    $0x8,%esp
8010375e:	ff 73 28             	push   0x28(%ebx)
80103761:	8d 46 04             	lea    0x4(%esi),%eax
80103764:	50                   	push   %eax
80103765:	e8 37 0b 00 00       	call   801042a1 <swtch>
      	switchkvm();//Cambia a la tabla de páginas del kernel
8010376a:	e8 00 30 00 00       	call   8010676f <switchkvm>
      	c->proc = 0;
8010376f:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103776:	00 00 00 
80103779:	83 c4 10             	add    $0x10,%esp
				p = ptable.proc[i];
8010377c:	bb 54 2e 11 80       	mov    $0x80112e54,%ebx
				i = NPRI-1;
80103781:	ba 01 00 00 00       	mov    $0x1,%edx
			while(p < &ptable.proc[i][NPROC]){
80103786:	8d 4a 01             	lea    0x1(%edx),%ecx
80103789:	89 c8                	mov    %ecx,%eax
8010378b:	c1 e0 04             	shl    $0x4,%eax
8010378e:	01 c8                	add    %ecx,%eax
80103790:	c1 e0 08             	shl    $0x8,%eax
80103793:	05 54 1d 11 80       	add    $0x80111d54,%eax
80103798:	39 d8                	cmp    %ebx,%eax
8010379a:	76 0e                	jbe    801037aa <scheduler+0x80>
				if(p->state != RUNNABLE){
8010379c:	83 7b 14 03          	cmpl   $0x3,0x14(%ebx)
801037a0:	74 a3                	je     80103745 <scheduler+0x1b>
					p++;
801037a2:	81 c3 88 00 00 00    	add    $0x88,%ebx
        	continue;
801037a8:	eb dc                	jmp    80103786 <scheduler+0x5c>
		for(i = NPRI-1; i>=0 ; i--){
801037aa:	4a                   	dec    %edx
801037ab:	85 d2                	test   %edx,%edx
801037ad:	78 12                	js     801037c1 <scheduler+0x97>
			p = ptable.proc[i];
801037af:	89 d3                	mov    %edx,%ebx
801037b1:	c1 e3 04             	shl    $0x4,%ebx
801037b4:	01 d3                	add    %edx,%ebx
801037b6:	c1 e3 08             	shl    $0x8,%ebx
801037b9:	81 c3 54 1d 11 80    	add    $0x80111d54,%ebx
			while(p < &ptable.proc[i][NPROC]){
801037bf:	eb c5                	jmp    80103786 <scheduler+0x5c>
    release(&ptable.lock);
801037c1:	83 ec 0c             	sub    $0xc,%esp
801037c4:	68 20 1d 11 80       	push   $0x80111d20
801037c9:	e8 e6 08 00 00       	call   801040b4 <release>
    sti();
801037ce:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
801037d1:	fb                   	sti    
    acquire(&ptable.lock);
801037d2:	83 ec 0c             	sub    $0xc,%esp
801037d5:	68 20 1d 11 80       	push   $0x80111d20
801037da:	e8 70 08 00 00       	call   8010404f <acquire>
		for(i = NPRI-1; i>=0 ; i--){
801037df:	83 c4 10             	add    $0x10,%esp
801037e2:	ba 01 00 00 00       	mov    $0x1,%edx
801037e7:	eb c2                	jmp    801037ab <scheduler+0x81>

801037e9 <sched>:
{
801037e9:	55                   	push   %ebp
801037ea:	89 e5                	mov    %esp,%ebp
801037ec:	56                   	push   %esi
801037ed:	53                   	push   %ebx
  struct proc *p = myproc();
801037ee:	e8 4c fa ff ff       	call   8010323f <myproc>
801037f3:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
801037f5:	83 ec 0c             	sub    $0xc,%esp
801037f8:	68 20 1d 11 80       	push   $0x80111d20
801037fd:	e8 0e 08 00 00       	call   80104010 <holding>
80103802:	83 c4 10             	add    $0x10,%esp
80103805:	85 c0                	test   %eax,%eax
80103807:	74 4f                	je     80103858 <sched+0x6f>
  if(mycpu()->ncli != 1)
80103809:	e8 9c f9 ff ff       	call   801031aa <mycpu>
8010380e:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103815:	75 4e                	jne    80103865 <sched+0x7c>
  if(p->state == RUNNING)
80103817:	83 7b 14 04          	cmpl   $0x4,0x14(%ebx)
8010381b:	74 55                	je     80103872 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010381d:	9c                   	pushf  
8010381e:	58                   	pop    %eax
  if(readeflags()&FL_IF)
8010381f:	f6 c4 02             	test   $0x2,%ah
80103822:	75 5b                	jne    8010387f <sched+0x96>
  intena = mycpu()->intena;
80103824:	e8 81 f9 ff ff       	call   801031aa <mycpu>
80103829:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
8010382f:	e8 76 f9 ff ff       	call   801031aa <mycpu>
80103834:	83 ec 08             	sub    $0x8,%esp
80103837:	ff 70 04             	push   0x4(%eax)
8010383a:	83 c3 28             	add    $0x28,%ebx
8010383d:	53                   	push   %ebx
8010383e:	e8 5e 0a 00 00       	call   801042a1 <swtch>
  mycpu()->intena = intena;
80103843:	e8 62 f9 ff ff       	call   801031aa <mycpu>
80103848:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
8010384e:	83 c4 10             	add    $0x10,%esp
80103851:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103854:	5b                   	pop    %ebx
80103855:	5e                   	pop    %esi
80103856:	5d                   	pop    %ebp
80103857:	c3                   	ret    
    panic("sched ptable.lock");
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	68 c0 74 10 80       	push   $0x801074c0
80103860:	e8 dc ca ff ff       	call   80100341 <panic>
    panic("sched locks");
80103865:	83 ec 0c             	sub    $0xc,%esp
80103868:	68 d2 74 10 80       	push   $0x801074d2
8010386d:	e8 cf ca ff ff       	call   80100341 <panic>
    panic("sched running");
80103872:	83 ec 0c             	sub    $0xc,%esp
80103875:	68 de 74 10 80       	push   $0x801074de
8010387a:	e8 c2 ca ff ff       	call   80100341 <panic>
    panic("sched interruptible");
8010387f:	83 ec 0c             	sub    $0xc,%esp
80103882:	68 ec 74 10 80       	push   $0x801074ec
80103887:	e8 b5 ca ff ff       	call   80100341 <panic>

8010388c <exit>:
{ 
8010388c:	55                   	push   %ebp
8010388d:	89 e5                	mov    %esp,%ebp
8010388f:	57                   	push   %edi
80103890:	56                   	push   %esi
80103891:	53                   	push   %ebx
80103892:	83 ec 0c             	sub    $0xc,%esp
  struct proc *curproc = myproc();
80103895:	e8 a5 f9 ff ff       	call   8010323f <myproc>
  if(curproc == initproc)
8010389a:	39 05 54 3f 11 80    	cmp    %eax,0x80113f54
801038a0:	74 09                	je     801038ab <exit+0x1f>
801038a2:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
801038a4:	bb 00 00 00 00       	mov    $0x0,%ebx
801038a9:	eb 0e                	jmp    801038b9 <exit+0x2d>
    panic("init exiting");
801038ab:	83 ec 0c             	sub    $0xc,%esp
801038ae:	68 00 75 10 80       	push   $0x80107500
801038b3:	e8 89 ca ff ff       	call   80100341 <panic>
  for(fd = 0; fd < NOFILE; fd++){
801038b8:	43                   	inc    %ebx
801038b9:	83 fb 0f             	cmp    $0xf,%ebx
801038bc:	7f 1e                	jg     801038dc <exit+0x50>
    if(curproc->ofile[fd]){
801038be:	8b 44 9e 34          	mov    0x34(%esi,%ebx,4),%eax
801038c2:	85 c0                	test   %eax,%eax
801038c4:	74 f2                	je     801038b8 <exit+0x2c>
      fileclose(curproc->ofile[fd]);
801038c6:	83 ec 0c             	sub    $0xc,%esp
801038c9:	50                   	push   %eax
801038ca:	e8 d3 d3 ff ff       	call   80100ca2 <fileclose>
      curproc->ofile[fd] = 0;
801038cf:	c7 44 9e 34 00 00 00 	movl   $0x0,0x34(%esi,%ebx,4)
801038d6:	00 
801038d7:	83 c4 10             	add    $0x10,%esp
801038da:	eb dc                	jmp    801038b8 <exit+0x2c>
  begin_op();
801038dc:	e8 13 ee ff ff       	call   801026f4 <begin_op>
  iput(curproc->cwd);
801038e1:	83 ec 0c             	sub    $0xc,%esp
801038e4:	ff 76 74             	push   0x74(%esi)
801038e7:	e8 37 dd ff ff       	call   80101623 <iput>
  end_op();
801038ec:	e8 7f ee ff ff       	call   80102770 <end_op>
  curproc->cwd = 0;
801038f1:	c7 46 74 00 00 00 00 	movl   $0x0,0x74(%esi)
  acquire(&ptable.lock);
801038f8:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801038ff:	e8 4b 07 00 00       	call   8010404f <acquire>
  curproc->exitcode = status;
80103904:	8b 45 08             	mov    0x8(%ebp),%eax
80103907:	89 46 04             	mov    %eax,0x4(%esi)
  wakeup1(curproc->parent);
8010390a:	8b 46 1c             	mov    0x1c(%esi),%eax
8010390d:	e8 48 f6 ff ff       	call   80102f5a <wakeup1>
	for(int i=0; i<NPRI; i++){
80103912:	83 c4 10             	add    $0x10,%esp
80103915:	bf 00 00 00 00       	mov    $0x0,%edi
8010391a:	eb 38                	jmp    80103954 <exit+0xc8>
		for(p = ptable.proc[i]; p < &ptable.proc[i][NPROC]; p++){
8010391c:	81 c3 88 00 00 00    	add    $0x88,%ebx
80103922:	8d 57 01             	lea    0x1(%edi),%edx
80103925:	89 d0                	mov    %edx,%eax
80103927:	c1 e0 04             	shl    $0x4,%eax
8010392a:	01 d0                	add    %edx,%eax
8010392c:	c1 e0 08             	shl    $0x8,%eax
8010392f:	05 54 1d 11 80       	add    $0x80111d54,%eax
80103934:	39 d8                	cmp    %ebx,%eax
80103936:	76 1a                	jbe    80103952 <exit+0xc6>
			if(p->parent == curproc){
80103938:	39 73 1c             	cmp    %esi,0x1c(%ebx)
8010393b:	75 df                	jne    8010391c <exit+0x90>
				p->parent = initproc;
8010393d:	a1 54 3f 11 80       	mov    0x80113f54,%eax
80103942:	89 43 1c             	mov    %eax,0x1c(%ebx)
				if(p->state == ZOMBIE)
80103945:	83 7b 14 05          	cmpl   $0x5,0x14(%ebx)
80103949:	75 d1                	jne    8010391c <exit+0x90>
					wakeup1(initproc);
8010394b:	e8 0a f6 ff ff       	call   80102f5a <wakeup1>
80103950:	eb ca                	jmp    8010391c <exit+0x90>
	for(int i=0; i<NPRI; i++){
80103952:	89 d7                	mov    %edx,%edi
80103954:	83 ff 01             	cmp    $0x1,%edi
80103957:	7f 12                	jg     8010396b <exit+0xdf>
		for(p = ptable.proc[i]; p < &ptable.proc[i][NPROC]; p++){
80103959:	89 fb                	mov    %edi,%ebx
8010395b:	c1 e3 04             	shl    $0x4,%ebx
8010395e:	01 fb                	add    %edi,%ebx
80103960:	c1 e3 08             	shl    $0x8,%ebx
80103963:	81 c3 54 1d 11 80    	add    $0x80111d54,%ebx
80103969:	eb b7                	jmp    80103922 <exit+0x96>
  deallocuvm(curproc->pgdir, KERNBASE, 0);
8010396b:	83 ec 04             	sub    $0x4,%esp
8010396e:	6a 00                	push   $0x0
80103970:	68 00 00 00 80       	push   $0x80000000
80103975:	ff 76 0c             	push   0xc(%esi)
80103978:	e8 5e 30 00 00       	call   801069db <deallocuvm>
  curproc->state = ZOMBIE;
8010397d:	c7 46 14 05 00 00 00 	movl   $0x5,0x14(%esi)
  sched();
80103984:	e8 60 fe ff ff       	call   801037e9 <sched>
  panic("zombie exit");
80103989:	c7 04 24 0d 75 10 80 	movl   $0x8010750d,(%esp)
80103990:	e8 ac c9 ff ff       	call   80100341 <panic>

80103995 <setprio>:
{
80103995:	55                   	push   %ebp
80103996:	89 e5                	mov    %esp,%ebp
80103998:	57                   	push   %edi
80103999:	56                   	push   %esi
8010399a:	53                   	push   %ebx
8010399b:	83 ec 28             	sub    $0x28,%esp
8010399e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i = ~(prio) & 0x1;//Comenzamos por la prioridad contraria
801039a1:	8b 75 0c             	mov    0xc(%ebp),%esi
801039a4:	83 f6 01             	xor    $0x1,%esi
801039a7:	83 e6 01             	and    $0x1,%esi
  acquire(&ptable.lock);
801039aa:	68 20 1d 11 80       	push   $0x80111d20
801039af:	e8 9b 06 00 00       	call   8010404f <acquire>
	cprintf("setprio_i=%d\n",i);
801039b4:	83 c4 08             	add    $0x8,%esp
801039b7:	56                   	push   %esi
801039b8:	68 19 75 10 80       	push   $0x80107519
801039bd:	e8 18 cc ff ff       	call   801005da <cprintf>
  for(; busq < NPRI; i = ~(i) & 0x1){
801039c2:	83 c4 10             	add    $0x10,%esp
	int busq = 0;//Variable de terminación bucle
801039c5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  for(; busq < NPRI; i = ~(i) & 0x1){
801039cc:	eb 72                	jmp    80103a40 <setprio+0xab>
					exit(0);
801039ce:	83 ec 0c             	sub    $0xc,%esp
801039d1:	6a 00                	push   $0x0
801039d3:	e8 b4 fe ff ff       	call   8010388c <exit>
    for(e = ptable.proc[i]; e < &ptable.proc[i][NPROC]; e++){
801039d8:	81 c3 88 00 00 00    	add    $0x88,%ebx
801039de:	8d 56 01             	lea    0x1(%esi),%edx
801039e1:	89 d0                	mov    %edx,%eax
801039e3:	c1 e0 04             	shl    $0x4,%eax
801039e6:	01 d0                	add    %edx,%eax
801039e8:	c1 e0 08             	shl    $0x8,%eax
801039eb:	05 54 1d 11 80       	add    $0x80111d54,%eax
801039f0:	39 d8                	cmp    %ebx,%eax
801039f2:	76 49                	jbe    80103a3d <setprio+0xa8>
      cprintf("..........set.........name=%s:%d, prio=%d\n",e->name, e->pid, e->prio);
801039f4:	8d 43 78             	lea    0x78(%ebx),%eax
801039f7:	ff 33                	push   (%ebx)
801039f9:	ff 73 18             	push   0x18(%ebx)
801039fc:	50                   	push   %eax
801039fd:	68 cc 75 10 80       	push   $0x801075cc
80103a02:	e8 d3 cb ff ff       	call   801005da <cprintf>
      if(e->pid == pid && e->prio !=prio){
80103a07:	83 c4 10             	add    $0x10,%esp
80103a0a:	39 7b 18             	cmp    %edi,0x18(%ebx)
80103a0d:	75 c9                	jne    801039d8 <setprio+0x43>
80103a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a12:	39 03                	cmp    %eax,(%ebx)
80103a14:	74 c2                	je     801039d8 <setprio+0x43>
  			release(&ptable.lock);
80103a16:	83 ec 0c             	sub    $0xc,%esp
80103a19:	68 20 1d 11 80       	push   $0x80111d20
80103a1e:	e8 91 06 00 00       	call   801040b4 <release>
				if(fork1(e, prio)!=0)
80103a23:	83 c4 08             	add    $0x8,%esp
80103a26:	ff 75 0c             	push   0xc(%ebp)
80103a29:	53                   	push   %ebx
80103a2a:	e8 90 fa ff ff       	call   801034bf <fork1>
80103a2f:	83 c4 10             	add    $0x10,%esp
80103a32:	85 c0                	test   %eax,%eax
80103a34:	75 98                	jne    801039ce <setprio+0x39>
				return 5;
80103a36:	b8 05 00 00 00       	mov    $0x5,%eax
80103a3b:	eb 33                	jmp    80103a70 <setprio+0xdb>
  for(; busq < NPRI; i = ~(i) & 0x1){
80103a3d:	83 f6 01             	xor    $0x1,%esi
80103a40:	83 7d e4 01          	cmpl   $0x1,-0x1c(%ebp)
80103a44:	7f 15                	jg     80103a5b <setprio+0xc6>
		busq++;
80103a46:	ff 45 e4             	incl   -0x1c(%ebp)
    for(e = ptable.proc[i]; e < &ptable.proc[i][NPROC]; e++){
80103a49:	89 f3                	mov    %esi,%ebx
80103a4b:	c1 e3 04             	shl    $0x4,%ebx
80103a4e:	01 f3                	add    %esi,%ebx
80103a50:	c1 e3 08             	shl    $0x8,%ebx
80103a53:	81 c3 54 1d 11 80    	add    $0x80111d54,%ebx
80103a59:	eb 83                	jmp    801039de <setprio+0x49>
	release(&ptable.lock);
80103a5b:	83 ec 0c             	sub    $0xc,%esp
80103a5e:	68 20 1d 11 80       	push   $0x80111d20
80103a63:	e8 4c 06 00 00       	call   801040b4 <release>
	return -1;
80103a68:	83 c4 10             	add    $0x10,%esp
80103a6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103a70:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103a73:	5b                   	pop    %ebx
80103a74:	5e                   	pop    %esi
80103a75:	5f                   	pop    %edi
80103a76:	5d                   	pop    %ebp
80103a77:	c3                   	ret    

80103a78 <yield>:
{
80103a78:	55                   	push   %ebp
80103a79:	89 e5                	mov    %esp,%ebp
80103a7b:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103a7e:	68 20 1d 11 80       	push   $0x80111d20
80103a83:	e8 c7 05 00 00       	call   8010404f <acquire>
  myproc()->state = RUNNABLE;
80103a88:	e8 b2 f7 ff ff       	call   8010323f <myproc>
80103a8d:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)
  sched();
80103a94:	e8 50 fd ff ff       	call   801037e9 <sched>
  release(&ptable.lock);
80103a99:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103aa0:	e8 0f 06 00 00       	call   801040b4 <release>
}
80103aa5:	83 c4 10             	add    $0x10,%esp
80103aa8:	c9                   	leave  
80103aa9:	c3                   	ret    

80103aaa <sleep>:
{
80103aaa:	55                   	push   %ebp
80103aab:	89 e5                	mov    %esp,%ebp
80103aad:	56                   	push   %esi
80103aae:	53                   	push   %ebx
80103aaf:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct proc *p = myproc();
80103ab2:	e8 88 f7 ff ff       	call   8010323f <myproc>
  if(p == 0)
80103ab7:	85 c0                	test   %eax,%eax
80103ab9:	74 66                	je     80103b21 <sleep+0x77>
80103abb:	89 c3                	mov    %eax,%ebx
  if(lk == 0)
80103abd:	85 f6                	test   %esi,%esi
80103abf:	74 6d                	je     80103b2e <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80103ac1:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
80103ac7:	74 18                	je     80103ae1 <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103ac9:	83 ec 0c             	sub    $0xc,%esp
80103acc:	68 20 1d 11 80       	push   $0x80111d20
80103ad1:	e8 79 05 00 00       	call   8010404f <acquire>
    release(lk);
80103ad6:	89 34 24             	mov    %esi,(%esp)
80103ad9:	e8 d6 05 00 00       	call   801040b4 <release>
80103ade:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
80103ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ae4:	89 43 2c             	mov    %eax,0x2c(%ebx)
  p->state = SLEEPING;
80103ae7:	c7 43 14 02 00 00 00 	movl   $0x2,0x14(%ebx)
  sched();
80103aee:	e8 f6 fc ff ff       	call   801037e9 <sched>
  p->chan = 0;
80103af3:	c7 43 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103afa:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
80103b00:	74 18                	je     80103b1a <sleep+0x70>
    release(&ptable.lock);
80103b02:	83 ec 0c             	sub    $0xc,%esp
80103b05:	68 20 1d 11 80       	push   $0x80111d20
80103b0a:	e8 a5 05 00 00       	call   801040b4 <release>
    acquire(lk);
80103b0f:	89 34 24             	mov    %esi,(%esp)
80103b12:	e8 38 05 00 00       	call   8010404f <acquire>
80103b17:	83 c4 10             	add    $0x10,%esp
}
80103b1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b1d:	5b                   	pop    %ebx
80103b1e:	5e                   	pop    %esi
80103b1f:	5d                   	pop    %ebp
80103b20:	c3                   	ret    
    panic("sleep");
80103b21:	83 ec 0c             	sub    $0xc,%esp
80103b24:	68 27 75 10 80       	push   $0x80107527
80103b29:	e8 13 c8 ff ff       	call   80100341 <panic>
    panic("sleep without lk");
80103b2e:	83 ec 0c             	sub    $0xc,%esp
80103b31:	68 2d 75 10 80       	push   $0x8010752d
80103b36:	e8 06 c8 ff ff       	call   80100341 <panic>

80103b3b <wait>:
{
80103b3b:	55                   	push   %ebp
80103b3c:	89 e5                	mov    %esp,%ebp
80103b3e:	57                   	push   %edi
80103b3f:	56                   	push   %esi
80103b40:	53                   	push   %ebx
80103b41:	83 ec 0c             	sub    $0xc,%esp
  struct proc *curproc = myproc();
80103b44:	e8 f6 f6 ff ff       	call   8010323f <myproc>
80103b49:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103b4b:	83 ec 0c             	sub    $0xc,%esp
80103b4e:	68 20 1d 11 80       	push   $0x80111d20
80103b53:	e8 f7 04 00 00       	call   8010404f <acquire>
80103b58:	83 c4 10             	add    $0x10,%esp
		for(int i=0; i<NPRI; i++){
80103b5b:	ba 00 00 00 00       	mov    $0x0,%edx
    havekids = 0;
80103b60:	b9 00 00 00 00       	mov    $0x0,%ecx
		for(int i=0; i<NPRI; i++){
80103b65:	83 fa 01             	cmp    $0x1,%edx
80103b68:	0f 8f a6 00 00 00    	jg     80103c14 <wait+0xd9>
			for(p = ptable.proc[i]; p < &ptable.proc[i][NPROC]; p++){
80103b6e:	89 d3                	mov    %edx,%ebx
80103b70:	c1 e3 04             	shl    $0x4,%ebx
80103b73:	01 d3                	add    %edx,%ebx
80103b75:	c1 e3 08             	shl    $0x8,%ebx
80103b78:	81 c3 54 1d 11 80    	add    $0x80111d54,%ebx
80103b7e:	eb 61                	jmp    80103be1 <wait+0xa6>
        	*status = p->exitcode;
80103b80:	8b 53 04             	mov    0x4(%ebx),%edx
80103b83:	8b 45 08             	mov    0x8(%ebp),%eax
80103b86:	89 10                	mov    %edx,(%eax)
        	pid = p->pid;
80103b88:	8b 73 18             	mov    0x18(%ebx),%esi
        	kfree(p->kstack);
80103b8b:	83 ec 0c             	sub    $0xc,%esp
80103b8e:	ff 73 10             	push   0x10(%ebx)
80103b91:	e8 92 e3 ff ff       	call   80101f28 <kfree>
        	p->kstack = 0;
80103b96:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        	freevm(p->pgdir, 0); // User zone deleted before
80103b9d:	83 c4 08             	add    $0x8,%esp
80103ba0:	6a 00                	push   $0x0
80103ba2:	ff 73 0c             	push   0xc(%ebx)
80103ba5:	e8 ae 2f 00 00       	call   80106b58 <freevm>
        	p->pid = 0;
80103baa:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
        	p->parent = 0;
80103bb1:	c7 43 1c 00 00 00 00 	movl   $0x0,0x1c(%ebx)
        	p->name[0] = 0;
80103bb8:	c6 43 78 00          	movb   $0x0,0x78(%ebx)
        	p->killed = 0;
80103bbc:	c7 43 30 00 00 00 00 	movl   $0x0,0x30(%ebx)
        	p->state = UNUSED;
80103bc3:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        	release(&ptable.lock);
80103bca:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103bd1:	e8 de 04 00 00       	call   801040b4 <release>
        	return pid;
80103bd6:	83 c4 10             	add    $0x10,%esp
80103bd9:	eb 58                	jmp    80103c33 <wait+0xf8>
			for(p = ptable.proc[i]; p < &ptable.proc[i][NPROC]; p++){
80103bdb:	81 c3 88 00 00 00    	add    $0x88,%ebx
80103be1:	8d 7a 01             	lea    0x1(%edx),%edi
80103be4:	89 f8                	mov    %edi,%eax
80103be6:	c1 e0 04             	shl    $0x4,%eax
80103be9:	01 f8                	add    %edi,%eax
80103beb:	c1 e0 08             	shl    $0x8,%eax
80103bee:	05 54 1d 11 80       	add    $0x80111d54,%eax
80103bf3:	39 d8                	cmp    %ebx,%eax
80103bf5:	76 16                	jbe    80103c0d <wait+0xd2>
				if(p->parent != curproc)
80103bf7:	39 73 1c             	cmp    %esi,0x1c(%ebx)
80103bfa:	75 df                	jne    80103bdb <wait+0xa0>
      	if(p->state == ZOMBIE){
80103bfc:	83 7b 14 05          	cmpl   $0x5,0x14(%ebx)
80103c00:	0f 84 7a ff ff ff    	je     80103b80 <wait+0x45>
      	havekids = 1;
80103c06:	b9 01 00 00 00       	mov    $0x1,%ecx
80103c0b:	eb ce                	jmp    80103bdb <wait+0xa0>
		for(int i=0; i<NPRI; i++){
80103c0d:	89 fa                	mov    %edi,%edx
80103c0f:	e9 51 ff ff ff       	jmp    80103b65 <wait+0x2a>
    if(!havekids || curproc->killed){
80103c14:	85 c9                	test   %ecx,%ecx
80103c16:	74 06                	je     80103c1e <wait+0xe3>
80103c18:	83 7e 30 00          	cmpl   $0x0,0x30(%esi)
80103c1c:	74 1f                	je     80103c3d <wait+0x102>
      release(&ptable.lock);
80103c1e:	83 ec 0c             	sub    $0xc,%esp
80103c21:	68 20 1d 11 80       	push   $0x80111d20
80103c26:	e8 89 04 00 00       	call   801040b4 <release>
      return -1;
80103c2b:	83 c4 10             	add    $0x10,%esp
80103c2e:	be ff ff ff ff       	mov    $0xffffffff,%esi
}
80103c33:	89 f0                	mov    %esi,%eax
80103c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103c38:	5b                   	pop    %ebx
80103c39:	5e                   	pop    %esi
80103c3a:	5f                   	pop    %edi
80103c3b:	5d                   	pop    %ebp
80103c3c:	c3                   	ret    
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103c3d:	83 ec 08             	sub    $0x8,%esp
80103c40:	68 20 1d 11 80       	push   $0x80111d20
80103c45:	56                   	push   %esi
80103c46:	e8 5f fe ff ff       	call   80103aaa <sleep>
    havekids = 0;
80103c4b:	83 c4 10             	add    $0x10,%esp
80103c4e:	e9 08 ff ff ff       	jmp    80103b5b <wait+0x20>

80103c53 <wakeup>:


// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103c53:	55                   	push   %ebp
80103c54:	89 e5                	mov    %esp,%ebp
80103c56:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103c59:	68 20 1d 11 80       	push   $0x80111d20
80103c5e:	e8 ec 03 00 00       	call   8010404f <acquire>
  wakeup1(chan);
80103c63:	8b 45 08             	mov    0x8(%ebp),%eax
80103c66:	e8 ef f2 ff ff       	call   80102f5a <wakeup1>
  release(&ptable.lock);
80103c6b:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103c72:	e8 3d 04 00 00       	call   801040b4 <release>
}
80103c77:	83 c4 10             	add    $0x10,%esp
80103c7a:	c9                   	leave  
80103c7b:	c3                   	ret    

80103c7c <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103c7c:	55                   	push   %ebp
80103c7d:	89 e5                	mov    %esp,%ebp
80103c7f:	56                   	push   %esi
80103c80:	53                   	push   %ebx
80103c81:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103c84:	83 ec 0c             	sub    $0xc,%esp
80103c87:	68 20 1d 11 80       	push   $0x80111d20
80103c8c:	e8 be 03 00 00       	call   8010404f <acquire>
	for(int i=0; i<NPRI; i++){
80103c91:	83 c4 10             	add    $0x10,%esp
80103c94:	be 00 00 00 00       	mov    $0x0,%esi
80103c99:	83 fe 01             	cmp    $0x1,%esi
80103c9c:	7f 67                	jg     80103d05 <kill+0x89>
		for(p = ptable.proc[i]; p < &ptable.proc[i][NPROC]; p++){
80103c9e:	89 f0                	mov    %esi,%eax
80103ca0:	c1 e0 04             	shl    $0x4,%eax
80103ca3:	01 f0                	add    %esi,%eax
80103ca5:	c1 e0 08             	shl    $0x8,%eax
80103ca8:	89 c1                	mov    %eax,%ecx
80103caa:	81 c1 54 1d 11 80    	add    $0x80111d54,%ecx
80103cb0:	8d 46 01             	lea    0x1(%esi),%eax
80103cb3:	89 c2                	mov    %eax,%edx
80103cb5:	c1 e2 04             	shl    $0x4,%edx
80103cb8:	01 c2                	add    %eax,%edx
80103cba:	89 d0                	mov    %edx,%eax
80103cbc:	c1 e0 08             	shl    $0x8,%eax
80103cbf:	05 54 1d 11 80       	add    $0x80111d54,%eax
80103cc4:	39 c8                	cmp    %ecx,%eax
80103cc6:	76 3a                	jbe    80103d02 <kill+0x86>
			if(p->pid == pid){
80103cc8:	39 59 18             	cmp    %ebx,0x18(%ecx)
80103ccb:	74 08                	je     80103cd5 <kill+0x59>
		for(p = ptable.proc[i]; p < &ptable.proc[i][NPROC]; p++){
80103ccd:	81 c1 88 00 00 00    	add    $0x88,%ecx
80103cd3:	eb db                	jmp    80103cb0 <kill+0x34>
      	p->killed = 1;
80103cd5:	c7 41 30 01 00 00 00 	movl   $0x1,0x30(%ecx)
      	// Wake process from sleep if necessary.
      	if(p->state == SLEEPING)
80103cdc:	83 79 14 02          	cmpl   $0x2,0x14(%ecx)
80103ce0:	74 17                	je     80103cf9 <kill+0x7d>
      	  p->state = RUNNABLE;
      	release(&ptable.lock);
80103ce2:	83 ec 0c             	sub    $0xc,%esp
80103ce5:	68 20 1d 11 80       	push   $0x80111d20
80103cea:	e8 c5 03 00 00       	call   801040b4 <release>
      	return 0;
80103cef:	83 c4 10             	add    $0x10,%esp
80103cf2:	b8 00 00 00 00       	mov    $0x0,%eax
80103cf7:	eb 21                	jmp    80103d1a <kill+0x9e>
      	  p->state = RUNNABLE;
80103cf9:	c7 41 14 03 00 00 00 	movl   $0x3,0x14(%ecx)
80103d00:	eb e0                	jmp    80103ce2 <kill+0x66>
	for(int i=0; i<NPRI; i++){
80103d02:	46                   	inc    %esi
80103d03:	eb 94                	jmp    80103c99 <kill+0x1d>
    	}
		}
	}
  release(&ptable.lock);
80103d05:	83 ec 0c             	sub    $0xc,%esp
80103d08:	68 20 1d 11 80       	push   $0x80111d20
80103d0d:	e8 a2 03 00 00       	call   801040b4 <release>
  return -1;
80103d12:	83 c4 10             	add    $0x10,%esp
80103d15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103d1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103d1d:	5b                   	pop    %ebx
80103d1e:	5e                   	pop    %esi
80103d1f:	5d                   	pop    %ebp
80103d20:	c3                   	ret    

80103d21 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103d21:	55                   	push   %ebp
80103d22:	89 e5                	mov    %esp,%ebp
80103d24:	57                   	push   %edi
80103d25:	56                   	push   %esi
80103d26:	53                   	push   %ebx
80103d27:	83 ec 3c             	sub    $0x3c,%esp
  int j;
  struct proc *p;
  char *state;
  uint pc[10];

		for(int i=0; i<NPRI; i++){
80103d2a:	be 00 00 00 00       	mov    $0x0,%esi
80103d2f:	e9 b5 00 00 00       	jmp    80103de9 <procdump+0xc8>
				if(p->state == UNUSED)
      		continue;
    		if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      		state = states[p->state];
    		else
      		state = "???";
80103d34:	b8 3e 75 10 80       	mov    $0x8010753e,%eax
    		cprintf("%d %s %s", p->pid, state, p->name);
80103d39:	8d 53 78             	lea    0x78(%ebx),%edx
80103d3c:	52                   	push   %edx
80103d3d:	50                   	push   %eax
80103d3e:	ff 73 18             	push   0x18(%ebx)
80103d41:	68 42 75 10 80       	push   $0x80107542
80103d46:	e8 8f c8 ff ff       	call   801005da <cprintf>
    		if(p->state == SLEEPING){
80103d4b:	83 c4 10             	add    $0x10,%esp
80103d4e:	83 7b 14 02          	cmpl   $0x2,0x14(%ebx)
80103d52:	74 4c                	je     80103da0 <procdump+0x7f>
      		getcallerpcs((uint*)p->context->ebp+2, pc);
      		for(j=0; j<10 && pc[j] != 0; j++)
        		cprintf(" %p", pc[j]);
    		}
    		cprintf("\n");				
80103d54:	83 ec 0c             	sub    $0xc,%esp
80103d57:	68 6b 7a 10 80       	push   $0x80107a6b
80103d5c:	e8 79 c8 ff ff       	call   801005da <cprintf>
80103d61:	83 c4 10             	add    $0x10,%esp
			for(p = ptable.proc[i]; p < &ptable.proc[i][NPROC]; p++){
80103d64:	81 c3 88 00 00 00    	add    $0x88,%ebx
80103d6a:	8d 46 01             	lea    0x1(%esi),%eax
80103d6d:	89 c2                	mov    %eax,%edx
80103d6f:	c1 e2 04             	shl    $0x4,%edx
80103d72:	01 c2                	add    %eax,%edx
80103d74:	89 d0                	mov    %edx,%eax
80103d76:	c1 e0 08             	shl    $0x8,%eax
80103d79:	05 54 1d 11 80       	add    $0x80111d54,%eax
80103d7e:	39 d8                	cmp    %ebx,%eax
80103d80:	76 66                	jbe    80103de8 <procdump+0xc7>
				if(p->state == UNUSED)
80103d82:	8b 43 14             	mov    0x14(%ebx),%eax
80103d85:	85 c0                	test   %eax,%eax
80103d87:	74 db                	je     80103d64 <procdump+0x43>
    		if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103d89:	83 f8 05             	cmp    $0x5,%eax
80103d8c:	77 a6                	ja     80103d34 <procdump+0x13>
80103d8e:	8b 04 85 f8 75 10 80 	mov    -0x7fef8a08(,%eax,4),%eax
80103d95:	85 c0                	test   %eax,%eax
80103d97:	75 a0                	jne    80103d39 <procdump+0x18>
      		state = "???";
80103d99:	b8 3e 75 10 80       	mov    $0x8010753e,%eax
80103d9e:	eb 99                	jmp    80103d39 <procdump+0x18>
      		getcallerpcs((uint*)p->context->ebp+2, pc);
80103da0:	8b 43 28             	mov    0x28(%ebx),%eax
80103da3:	8b 40 0c             	mov    0xc(%eax),%eax
80103da6:	83 c0 08             	add    $0x8,%eax
80103da9:	83 ec 08             	sub    $0x8,%esp
80103dac:	8d 55 c0             	lea    -0x40(%ebp),%edx
80103daf:	52                   	push   %edx
80103db0:	50                   	push   %eax
80103db1:	e8 7d 01 00 00       	call   80103f33 <getcallerpcs>
      		for(j=0; j<10 && pc[j] != 0; j++)
80103db6:	83 c4 10             	add    $0x10,%esp
80103db9:	bf 00 00 00 00       	mov    $0x0,%edi
80103dbe:	eb 12                	jmp    80103dd2 <procdump+0xb1>
        		cprintf(" %p", pc[j]);
80103dc0:	83 ec 08             	sub    $0x8,%esp
80103dc3:	50                   	push   %eax
80103dc4:	68 41 6f 10 80       	push   $0x80106f41
80103dc9:	e8 0c c8 ff ff       	call   801005da <cprintf>
      		for(j=0; j<10 && pc[j] != 0; j++)
80103dce:	47                   	inc    %edi
80103dcf:	83 c4 10             	add    $0x10,%esp
80103dd2:	83 ff 09             	cmp    $0x9,%edi
80103dd5:	0f 8f 79 ff ff ff    	jg     80103d54 <procdump+0x33>
80103ddb:	8b 44 bd c0          	mov    -0x40(%ebp,%edi,4),%eax
80103ddf:	85 c0                	test   %eax,%eax
80103de1:	75 dd                	jne    80103dc0 <procdump+0x9f>
80103de3:	e9 6c ff ff ff       	jmp    80103d54 <procdump+0x33>
		for(int i=0; i<NPRI; i++){
80103de8:	46                   	inc    %esi
80103de9:	83 fe 01             	cmp    $0x1,%esi
80103dec:	7f 17                	jg     80103e05 <procdump+0xe4>
			for(p = ptable.proc[i]; p < &ptable.proc[i][NPROC]; p++){
80103dee:	89 f0                	mov    %esi,%eax
80103df0:	c1 e0 04             	shl    $0x4,%eax
80103df3:	01 f0                	add    %esi,%eax
80103df5:	c1 e0 08             	shl    $0x8,%eax
80103df8:	89 c3                	mov    %eax,%ebx
80103dfa:	81 c3 54 1d 11 80    	add    $0x80111d54,%ebx
80103e00:	e9 65 ff ff ff       	jmp    80103d6a <procdump+0x49>
			}
		}
}
80103e05:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103e08:	5b                   	pop    %ebx
80103e09:	5e                   	pop    %esi
80103e0a:	5f                   	pop    %edi
80103e0b:	5d                   	pop    %ebp
80103e0c:	c3                   	ret    

80103e0d <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103e0d:	55                   	push   %ebp
80103e0e:	89 e5                	mov    %esp,%ebp
80103e10:	53                   	push   %ebx
80103e11:	83 ec 0c             	sub    $0xc,%esp
80103e14:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103e17:	68 10 76 10 80       	push   $0x80107610
80103e1c:	8d 43 04             	lea    0x4(%ebx),%eax
80103e1f:	50                   	push   %eax
80103e20:	e8 f3 00 00 00       	call   80103f18 <initlock>
  lk->name = name;
80103e25:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e28:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103e2b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103e31:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103e38:	83 c4 10             	add    $0x10,%esp
80103e3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103e3e:	c9                   	leave  
80103e3f:	c3                   	ret    

80103e40 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103e40:	55                   	push   %ebp
80103e41:	89 e5                	mov    %esp,%ebp
80103e43:	56                   	push   %esi
80103e44:	53                   	push   %ebx
80103e45:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103e48:	8d 73 04             	lea    0x4(%ebx),%esi
80103e4b:	83 ec 0c             	sub    $0xc,%esp
80103e4e:	56                   	push   %esi
80103e4f:	e8 fb 01 00 00       	call   8010404f <acquire>
  while (lk->locked) {
80103e54:	83 c4 10             	add    $0x10,%esp
80103e57:	eb 0d                	jmp    80103e66 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103e59:	83 ec 08             	sub    $0x8,%esp
80103e5c:	56                   	push   %esi
80103e5d:	53                   	push   %ebx
80103e5e:	e8 47 fc ff ff       	call   80103aaa <sleep>
80103e63:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103e66:	83 3b 00             	cmpl   $0x0,(%ebx)
80103e69:	75 ee                	jne    80103e59 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103e6b:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103e71:	e8 c9 f3 ff ff       	call   8010323f <myproc>
80103e76:	8b 40 18             	mov    0x18(%eax),%eax
80103e79:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103e7c:	83 ec 0c             	sub    $0xc,%esp
80103e7f:	56                   	push   %esi
80103e80:	e8 2f 02 00 00       	call   801040b4 <release>
}
80103e85:	83 c4 10             	add    $0x10,%esp
80103e88:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103e8b:	5b                   	pop    %ebx
80103e8c:	5e                   	pop    %esi
80103e8d:	5d                   	pop    %ebp
80103e8e:	c3                   	ret    

80103e8f <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103e8f:	55                   	push   %ebp
80103e90:	89 e5                	mov    %esp,%ebp
80103e92:	56                   	push   %esi
80103e93:	53                   	push   %ebx
80103e94:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103e97:	8d 73 04             	lea    0x4(%ebx),%esi
80103e9a:	83 ec 0c             	sub    $0xc,%esp
80103e9d:	56                   	push   %esi
80103e9e:	e8 ac 01 00 00       	call   8010404f <acquire>
  lk->locked = 0;
80103ea3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103ea9:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103eb0:	89 1c 24             	mov    %ebx,(%esp)
80103eb3:	e8 9b fd ff ff       	call   80103c53 <wakeup>
  release(&lk->lk);
80103eb8:	89 34 24             	mov    %esi,(%esp)
80103ebb:	e8 f4 01 00 00       	call   801040b4 <release>
}
80103ec0:	83 c4 10             	add    $0x10,%esp
80103ec3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ec6:	5b                   	pop    %ebx
80103ec7:	5e                   	pop    %esi
80103ec8:	5d                   	pop    %ebp
80103ec9:	c3                   	ret    

80103eca <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103eca:	55                   	push   %ebp
80103ecb:	89 e5                	mov    %esp,%ebp
80103ecd:	56                   	push   %esi
80103ece:	53                   	push   %ebx
80103ecf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103ed2:	8d 73 04             	lea    0x4(%ebx),%esi
80103ed5:	83 ec 0c             	sub    $0xc,%esp
80103ed8:	56                   	push   %esi
80103ed9:	e8 71 01 00 00       	call   8010404f <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103ede:	83 c4 10             	add    $0x10,%esp
80103ee1:	83 3b 00             	cmpl   $0x0,(%ebx)
80103ee4:	75 17                	jne    80103efd <holdingsleep+0x33>
80103ee6:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103eeb:	83 ec 0c             	sub    $0xc,%esp
80103eee:	56                   	push   %esi
80103eef:	e8 c0 01 00 00       	call   801040b4 <release>
  return r;
}
80103ef4:	89 d8                	mov    %ebx,%eax
80103ef6:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ef9:	5b                   	pop    %ebx
80103efa:	5e                   	pop    %esi
80103efb:	5d                   	pop    %ebp
80103efc:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103efd:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103f00:	e8 3a f3 ff ff       	call   8010323f <myproc>
80103f05:	3b 58 18             	cmp    0x18(%eax),%ebx
80103f08:	74 07                	je     80103f11 <holdingsleep+0x47>
80103f0a:	bb 00 00 00 00       	mov    $0x0,%ebx
80103f0f:	eb da                	jmp    80103eeb <holdingsleep+0x21>
80103f11:	bb 01 00 00 00       	mov    $0x1,%ebx
80103f16:	eb d3                	jmp    80103eeb <holdingsleep+0x21>

80103f18 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103f18:	55                   	push   %ebp
80103f19:	89 e5                	mov    %esp,%ebp
80103f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103f1e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f21:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103f24:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103f2a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103f31:	5d                   	pop    %ebp
80103f32:	c3                   	ret    

80103f33 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103f33:	55                   	push   %ebp
80103f34:	89 e5                	mov    %esp,%ebp
80103f36:	53                   	push   %ebx
80103f37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103f3a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f3d:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103f40:	b8 00 00 00 00       	mov    $0x0,%eax
80103f45:	83 f8 09             	cmp    $0x9,%eax
80103f48:	7f 21                	jg     80103f6b <getcallerpcs+0x38>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103f4a:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103f50:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103f56:	77 13                	ja     80103f6b <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103f58:	8b 5a 04             	mov    0x4(%edx),%ebx
80103f5b:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103f5e:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103f60:	40                   	inc    %eax
80103f61:	eb e2                	jmp    80103f45 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103f63:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103f6a:	40                   	inc    %eax
80103f6b:	83 f8 09             	cmp    $0x9,%eax
80103f6e:	7e f3                	jle    80103f63 <getcallerpcs+0x30>
}
80103f70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103f73:	c9                   	leave  
80103f74:	c3                   	ret    

80103f75 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103f75:	55                   	push   %ebp
80103f76:	89 e5                	mov    %esp,%ebp
80103f78:	53                   	push   %ebx
80103f79:	83 ec 04             	sub    $0x4,%esp
80103f7c:	9c                   	pushf  
80103f7d:	5b                   	pop    %ebx
  asm volatile("cli");
80103f7e:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103f7f:	e8 26 f2 ff ff       	call   801031aa <mycpu>
80103f84:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103f8b:	74 10                	je     80103f9d <pushcli+0x28>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103f8d:	e8 18 f2 ff ff       	call   801031aa <mycpu>
80103f92:	ff 80 a4 00 00 00    	incl   0xa4(%eax)
}
80103f98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103f9b:	c9                   	leave  
80103f9c:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103f9d:	e8 08 f2 ff ff       	call   801031aa <mycpu>
80103fa2:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103fa8:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103fae:	eb dd                	jmp    80103f8d <pushcli+0x18>

80103fb0 <popcli>:

void
popcli(void)
{
80103fb0:	55                   	push   %ebp
80103fb1:	89 e5                	mov    %esp,%ebp
80103fb3:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103fb6:	9c                   	pushf  
80103fb7:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103fb8:	f6 c4 02             	test   $0x2,%ah
80103fbb:	75 28                	jne    80103fe5 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103fbd:	e8 e8 f1 ff ff       	call   801031aa <mycpu>
80103fc2:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103fc8:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103fcb:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103fd1:	85 d2                	test   %edx,%edx
80103fd3:	78 1d                	js     80103ff2 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103fd5:	e8 d0 f1 ff ff       	call   801031aa <mycpu>
80103fda:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103fe1:	74 1c                	je     80103fff <popcli+0x4f>
    sti();
}
80103fe3:	c9                   	leave  
80103fe4:	c3                   	ret    
    panic("popcli - interruptible");
80103fe5:	83 ec 0c             	sub    $0xc,%esp
80103fe8:	68 1b 76 10 80       	push   $0x8010761b
80103fed:	e8 4f c3 ff ff       	call   80100341 <panic>
    panic("popcli");
80103ff2:	83 ec 0c             	sub    $0xc,%esp
80103ff5:	68 32 76 10 80       	push   $0x80107632
80103ffa:	e8 42 c3 ff ff       	call   80100341 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103fff:	e8 a6 f1 ff ff       	call   801031aa <mycpu>
80104004:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
8010400b:	74 d6                	je     80103fe3 <popcli+0x33>
  asm volatile("sti");
8010400d:	fb                   	sti    
}
8010400e:	eb d3                	jmp    80103fe3 <popcli+0x33>

80104010 <holding>:
{
80104010:	55                   	push   %ebp
80104011:	89 e5                	mov    %esp,%ebp
80104013:	53                   	push   %ebx
80104014:	83 ec 04             	sub    $0x4,%esp
80104017:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
8010401a:	e8 56 ff ff ff       	call   80103f75 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
8010401f:	83 3b 00             	cmpl   $0x0,(%ebx)
80104022:	75 11                	jne    80104035 <holding+0x25>
80104024:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80104029:	e8 82 ff ff ff       	call   80103fb0 <popcli>
}
8010402e:	89 d8                	mov    %ebx,%eax
80104030:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104033:	c9                   	leave  
80104034:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80104035:	8b 5b 08             	mov    0x8(%ebx),%ebx
80104038:	e8 6d f1 ff ff       	call   801031aa <mycpu>
8010403d:	39 c3                	cmp    %eax,%ebx
8010403f:	74 07                	je     80104048 <holding+0x38>
80104041:	bb 00 00 00 00       	mov    $0x0,%ebx
80104046:	eb e1                	jmp    80104029 <holding+0x19>
80104048:	bb 01 00 00 00       	mov    $0x1,%ebx
8010404d:	eb da                	jmp    80104029 <holding+0x19>

8010404f <acquire>:
{
8010404f:	55                   	push   %ebp
80104050:	89 e5                	mov    %esp,%ebp
80104052:	53                   	push   %ebx
80104053:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104056:	e8 1a ff ff ff       	call   80103f75 <pushcli>
  if(holding(lk))
8010405b:	83 ec 0c             	sub    $0xc,%esp
8010405e:	ff 75 08             	push   0x8(%ebp)
80104061:	e8 aa ff ff ff       	call   80104010 <holding>
80104066:	83 c4 10             	add    $0x10,%esp
80104069:	85 c0                	test   %eax,%eax
8010406b:	75 3a                	jne    801040a7 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
8010406d:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80104070:	b8 01 00 00 00       	mov    $0x1,%eax
80104075:	f0 87 02             	lock xchg %eax,(%edx)
80104078:	85 c0                	test   %eax,%eax
8010407a:	75 f1                	jne    8010406d <acquire+0x1e>
  __sync_synchronize();
8010407c:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80104081:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104084:	e8 21 f1 ff ff       	call   801031aa <mycpu>
80104089:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010408c:	8b 45 08             	mov    0x8(%ebp),%eax
8010408f:	83 c0 0c             	add    $0xc,%eax
80104092:	83 ec 08             	sub    $0x8,%esp
80104095:	50                   	push   %eax
80104096:	8d 45 08             	lea    0x8(%ebp),%eax
80104099:	50                   	push   %eax
8010409a:	e8 94 fe ff ff       	call   80103f33 <getcallerpcs>
}
8010409f:	83 c4 10             	add    $0x10,%esp
801040a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801040a5:	c9                   	leave  
801040a6:	c3                   	ret    
    panic("acquire");
801040a7:	83 ec 0c             	sub    $0xc,%esp
801040aa:	68 39 76 10 80       	push   $0x80107639
801040af:	e8 8d c2 ff ff       	call   80100341 <panic>

801040b4 <release>:
{
801040b4:	55                   	push   %ebp
801040b5:	89 e5                	mov    %esp,%ebp
801040b7:	53                   	push   %ebx
801040b8:	83 ec 10             	sub    $0x10,%esp
801040bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
801040be:	53                   	push   %ebx
801040bf:	e8 4c ff ff ff       	call   80104010 <holding>
801040c4:	83 c4 10             	add    $0x10,%esp
801040c7:	85 c0                	test   %eax,%eax
801040c9:	74 23                	je     801040ee <release+0x3a>
  lk->pcs[0] = 0;
801040cb:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
801040d2:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
801040d9:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801040de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
801040e4:	e8 c7 fe ff ff       	call   80103fb0 <popcli>
}
801040e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801040ec:	c9                   	leave  
801040ed:	c3                   	ret    
    panic("release");
801040ee:	83 ec 0c             	sub    $0xc,%esp
801040f1:	68 41 76 10 80       	push   $0x80107641
801040f6:	e8 46 c2 ff ff       	call   80100341 <panic>

801040fb <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801040fb:	55                   	push   %ebp
801040fc:	89 e5                	mov    %esp,%ebp
801040fe:	57                   	push   %edi
801040ff:	53                   	push   %ebx
80104100:	8b 55 08             	mov    0x8(%ebp),%edx
80104103:	8b 45 0c             	mov    0xc(%ebp),%eax
  if ((int)dst%4 == 0 && n%4 == 0){
80104106:	f6 c2 03             	test   $0x3,%dl
80104109:	75 29                	jne    80104134 <memset+0x39>
8010410b:	f6 45 10 03          	testb  $0x3,0x10(%ebp)
8010410f:	75 23                	jne    80104134 <memset+0x39>
    c &= 0xFF;
80104111:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104114:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104117:	c1 e9 02             	shr    $0x2,%ecx
8010411a:	c1 e0 18             	shl    $0x18,%eax
8010411d:	89 fb                	mov    %edi,%ebx
8010411f:	c1 e3 10             	shl    $0x10,%ebx
80104122:	09 d8                	or     %ebx,%eax
80104124:	89 fb                	mov    %edi,%ebx
80104126:	c1 e3 08             	shl    $0x8,%ebx
80104129:	09 d8                	or     %ebx,%eax
8010412b:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
8010412d:	89 d7                	mov    %edx,%edi
8010412f:	fc                   	cld    
80104130:	f3 ab                	rep stos %eax,%es:(%edi)
}
80104132:	eb 08                	jmp    8010413c <memset+0x41>
  asm volatile("cld; rep stosb" :
80104134:	89 d7                	mov    %edx,%edi
80104136:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104139:	fc                   	cld    
8010413a:	f3 aa                	rep stos %al,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
8010413c:	89 d0                	mov    %edx,%eax
8010413e:	5b                   	pop    %ebx
8010413f:	5f                   	pop    %edi
80104140:	5d                   	pop    %ebp
80104141:	c3                   	ret    

80104142 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104142:	55                   	push   %ebp
80104143:	89 e5                	mov    %esp,%ebp
80104145:	56                   	push   %esi
80104146:	53                   	push   %ebx
80104147:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010414a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010414d:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104150:	eb 04                	jmp    80104156 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80104152:	41                   	inc    %ecx
80104153:	42                   	inc    %edx
  while(n-- > 0){
80104154:	89 f0                	mov    %esi,%eax
80104156:	8d 70 ff             	lea    -0x1(%eax),%esi
80104159:	85 c0                	test   %eax,%eax
8010415b:	74 10                	je     8010416d <memcmp+0x2b>
    if(*s1 != *s2)
8010415d:	8a 01                	mov    (%ecx),%al
8010415f:	8a 1a                	mov    (%edx),%bl
80104161:	38 d8                	cmp    %bl,%al
80104163:	74 ed                	je     80104152 <memcmp+0x10>
      return *s1 - *s2;
80104165:	0f b6 c0             	movzbl %al,%eax
80104168:	0f b6 db             	movzbl %bl,%ebx
8010416b:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
8010416d:	5b                   	pop    %ebx
8010416e:	5e                   	pop    %esi
8010416f:	5d                   	pop    %ebp
80104170:	c3                   	ret    

80104171 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104171:	55                   	push   %ebp
80104172:	89 e5                	mov    %esp,%ebp
80104174:	56                   	push   %esi
80104175:	53                   	push   %ebx
80104176:	8b 75 08             	mov    0x8(%ebp),%esi
80104179:	8b 55 0c             	mov    0xc(%ebp),%edx
8010417c:	8b 45 10             	mov    0x10(%ebp),%eax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010417f:	39 f2                	cmp    %esi,%edx
80104181:	73 36                	jae    801041b9 <memmove+0x48>
80104183:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80104186:	39 f1                	cmp    %esi,%ecx
80104188:	76 33                	jbe    801041bd <memmove+0x4c>
    s += n;
    d += n;
8010418a:	8d 14 06             	lea    (%esi,%eax,1),%edx
    while(n-- > 0)
8010418d:	eb 08                	jmp    80104197 <memmove+0x26>
      *--d = *--s;
8010418f:	49                   	dec    %ecx
80104190:	4a                   	dec    %edx
80104191:	8a 01                	mov    (%ecx),%al
80104193:	88 02                	mov    %al,(%edx)
    while(n-- > 0)
80104195:	89 d8                	mov    %ebx,%eax
80104197:	8d 58 ff             	lea    -0x1(%eax),%ebx
8010419a:	85 c0                	test   %eax,%eax
8010419c:	75 f1                	jne    8010418f <memmove+0x1e>
8010419e:	eb 13                	jmp    801041b3 <memmove+0x42>
  } else
    while(n-- > 0)
      *d++ = *s++;
801041a0:	8a 02                	mov    (%edx),%al
801041a2:	88 01                	mov    %al,(%ecx)
801041a4:	8d 49 01             	lea    0x1(%ecx),%ecx
801041a7:	8d 52 01             	lea    0x1(%edx),%edx
    while(n-- > 0)
801041aa:	89 d8                	mov    %ebx,%eax
801041ac:	8d 58 ff             	lea    -0x1(%eax),%ebx
801041af:	85 c0                	test   %eax,%eax
801041b1:	75 ed                	jne    801041a0 <memmove+0x2f>

  return dst;
}
801041b3:	89 f0                	mov    %esi,%eax
801041b5:	5b                   	pop    %ebx
801041b6:	5e                   	pop    %esi
801041b7:	5d                   	pop    %ebp
801041b8:	c3                   	ret    
801041b9:	89 f1                	mov    %esi,%ecx
801041bb:	eb ef                	jmp    801041ac <memmove+0x3b>
801041bd:	89 f1                	mov    %esi,%ecx
801041bf:	eb eb                	jmp    801041ac <memmove+0x3b>

801041c1 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801041c1:	55                   	push   %ebp
801041c2:	89 e5                	mov    %esp,%ebp
801041c4:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801041c7:	ff 75 10             	push   0x10(%ebp)
801041ca:	ff 75 0c             	push   0xc(%ebp)
801041cd:	ff 75 08             	push   0x8(%ebp)
801041d0:	e8 9c ff ff ff       	call   80104171 <memmove>
}
801041d5:	c9                   	leave  
801041d6:	c3                   	ret    

801041d7 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801041d7:	55                   	push   %ebp
801041d8:	89 e5                	mov    %esp,%ebp
801041da:	53                   	push   %ebx
801041db:	8b 55 08             	mov    0x8(%ebp),%edx
801041de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801041e1:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
801041e4:	eb 03                	jmp    801041e9 <strncmp+0x12>
    n--, p++, q++;
801041e6:	48                   	dec    %eax
801041e7:	42                   	inc    %edx
801041e8:	41                   	inc    %ecx
  while(n > 0 && *p && *p == *q)
801041e9:	85 c0                	test   %eax,%eax
801041eb:	74 0a                	je     801041f7 <strncmp+0x20>
801041ed:	8a 1a                	mov    (%edx),%bl
801041ef:	84 db                	test   %bl,%bl
801041f1:	74 04                	je     801041f7 <strncmp+0x20>
801041f3:	3a 19                	cmp    (%ecx),%bl
801041f5:	74 ef                	je     801041e6 <strncmp+0xf>
  if(n == 0)
801041f7:	85 c0                	test   %eax,%eax
801041f9:	74 0d                	je     80104208 <strncmp+0x31>
    return 0;
  return (uchar)*p - (uchar)*q;
801041fb:	0f b6 02             	movzbl (%edx),%eax
801041fe:	0f b6 11             	movzbl (%ecx),%edx
80104201:	29 d0                	sub    %edx,%eax
}
80104203:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104206:	c9                   	leave  
80104207:	c3                   	ret    
    return 0;
80104208:	b8 00 00 00 00       	mov    $0x0,%eax
8010420d:	eb f4                	jmp    80104203 <strncmp+0x2c>

8010420f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010420f:	55                   	push   %ebp
80104210:	89 e5                	mov    %esp,%ebp
80104212:	57                   	push   %edi
80104213:	56                   	push   %esi
80104214:	53                   	push   %ebx
80104215:	8b 45 08             	mov    0x8(%ebp),%eax
80104218:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010421b:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
8010421e:	89 c1                	mov    %eax,%ecx
80104220:	eb 04                	jmp    80104226 <strncpy+0x17>
80104222:	89 fb                	mov    %edi,%ebx
80104224:	89 f1                	mov    %esi,%ecx
80104226:	89 d6                	mov    %edx,%esi
80104228:	4a                   	dec    %edx
80104229:	85 f6                	test   %esi,%esi
8010422b:	7e 10                	jle    8010423d <strncpy+0x2e>
8010422d:	8d 7b 01             	lea    0x1(%ebx),%edi
80104230:	8d 71 01             	lea    0x1(%ecx),%esi
80104233:	8a 1b                	mov    (%ebx),%bl
80104235:	88 19                	mov    %bl,(%ecx)
80104237:	84 db                	test   %bl,%bl
80104239:	75 e7                	jne    80104222 <strncpy+0x13>
8010423b:	89 f1                	mov    %esi,%ecx
    ;
  while(n-- > 0)
8010423d:	8d 5a ff             	lea    -0x1(%edx),%ebx
80104240:	85 d2                	test   %edx,%edx
80104242:	7e 0a                	jle    8010424e <strncpy+0x3f>
    *s++ = 0;
80104244:	c6 01 00             	movb   $0x0,(%ecx)
  while(n-- > 0)
80104247:	89 da                	mov    %ebx,%edx
    *s++ = 0;
80104249:	8d 49 01             	lea    0x1(%ecx),%ecx
8010424c:	eb ef                	jmp    8010423d <strncpy+0x2e>
  return os;
}
8010424e:	5b                   	pop    %ebx
8010424f:	5e                   	pop    %esi
80104250:	5f                   	pop    %edi
80104251:	5d                   	pop    %ebp
80104252:	c3                   	ret    

80104253 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104253:	55                   	push   %ebp
80104254:	89 e5                	mov    %esp,%ebp
80104256:	57                   	push   %edi
80104257:	56                   	push   %esi
80104258:	53                   	push   %ebx
80104259:	8b 45 08             	mov    0x8(%ebp),%eax
8010425c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010425f:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80104262:	85 d2                	test   %edx,%edx
80104264:	7e 20                	jle    80104286 <safestrcpy+0x33>
80104266:	89 c1                	mov    %eax,%ecx
80104268:	eb 04                	jmp    8010426e <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
8010426a:	89 fb                	mov    %edi,%ebx
8010426c:	89 f1                	mov    %esi,%ecx
8010426e:	4a                   	dec    %edx
8010426f:	85 d2                	test   %edx,%edx
80104271:	7e 10                	jle    80104283 <safestrcpy+0x30>
80104273:	8d 7b 01             	lea    0x1(%ebx),%edi
80104276:	8d 71 01             	lea    0x1(%ecx),%esi
80104279:	8a 1b                	mov    (%ebx),%bl
8010427b:	88 19                	mov    %bl,(%ecx)
8010427d:	84 db                	test   %bl,%bl
8010427f:	75 e9                	jne    8010426a <safestrcpy+0x17>
80104281:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80104283:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80104286:	5b                   	pop    %ebx
80104287:	5e                   	pop    %esi
80104288:	5f                   	pop    %edi
80104289:	5d                   	pop    %ebp
8010428a:	c3                   	ret    

8010428b <strlen>:

int
strlen(const char *s)
{
8010428b:	55                   	push   %ebp
8010428c:	89 e5                	mov    %esp,%ebp
8010428e:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80104291:	b8 00 00 00 00       	mov    $0x0,%eax
80104296:	eb 01                	jmp    80104299 <strlen+0xe>
80104298:	40                   	inc    %eax
80104299:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
8010429d:	75 f9                	jne    80104298 <strlen+0xd>
    ;
  return n;
}
8010429f:	5d                   	pop    %ebp
801042a0:	c3                   	ret    

801042a1 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801042a1:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801042a5:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801042a9:	55                   	push   %ebp
  pushl %ebx
801042aa:	53                   	push   %ebx
  pushl %esi
801042ab:	56                   	push   %esi
  pushl %edi
801042ac:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801042ad:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801042af:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801042b1:	5f                   	pop    %edi
  popl %esi
801042b2:	5e                   	pop    %esi
  popl %ebx
801042b3:	5b                   	pop    %ebx
  popl %ebp
801042b4:	5d                   	pop    %ebp
  ret
801042b5:	c3                   	ret    

801042b6 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801042b6:	55                   	push   %ebp
801042b7:	89 e5                	mov    %esp,%ebp
801042b9:	53                   	push   %ebx
801042ba:	83 ec 04             	sub    $0x4,%esp
801042bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
801042c0:	e8 7a ef ff ff       	call   8010323f <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801042c5:	8b 40 08             	mov    0x8(%eax),%eax
801042c8:	39 d8                	cmp    %ebx,%eax
801042ca:	76 18                	jbe    801042e4 <fetchint+0x2e>
801042cc:	8d 53 04             	lea    0x4(%ebx),%edx
801042cf:	39 d0                	cmp    %edx,%eax
801042d1:	72 18                	jb     801042eb <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
801042d3:	8b 13                	mov    (%ebx),%edx
801042d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801042d8:	89 10                	mov    %edx,(%eax)
  return 0;
801042da:	b8 00 00 00 00       	mov    $0x0,%eax
}
801042df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042e2:	c9                   	leave  
801042e3:	c3                   	ret    
    return -1;
801042e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042e9:	eb f4                	jmp    801042df <fetchint+0x29>
801042eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042f0:	eb ed                	jmp    801042df <fetchint+0x29>

801042f2 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801042f2:	55                   	push   %ebp
801042f3:	89 e5                	mov    %esp,%ebp
801042f5:	53                   	push   %ebx
801042f6:	83 ec 04             	sub    $0x4,%esp
801042f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
801042fc:	e8 3e ef ff ff       	call   8010323f <myproc>

  if(addr >= curproc->sz)
80104301:	39 58 08             	cmp    %ebx,0x8(%eax)
80104304:	76 24                	jbe    8010432a <fetchstr+0x38>
    return -1;
  *pp = (char*)addr;
80104306:	8b 55 0c             	mov    0xc(%ebp),%edx
80104309:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
8010430b:	8b 50 08             	mov    0x8(%eax),%edx
  for(s = *pp; s < ep; s++){
8010430e:	89 d8                	mov    %ebx,%eax
80104310:	eb 01                	jmp    80104313 <fetchstr+0x21>
80104312:	40                   	inc    %eax
80104313:	39 d0                	cmp    %edx,%eax
80104315:	73 09                	jae    80104320 <fetchstr+0x2e>
    if(*s == 0)
80104317:	80 38 00             	cmpb   $0x0,(%eax)
8010431a:	75 f6                	jne    80104312 <fetchstr+0x20>
      return s - *pp;
8010431c:	29 d8                	sub    %ebx,%eax
8010431e:	eb 05                	jmp    80104325 <fetchstr+0x33>
  }
  return -1;
80104320:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104325:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104328:	c9                   	leave  
80104329:	c3                   	ret    
    return -1;
8010432a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010432f:	eb f4                	jmp    80104325 <fetchstr+0x33>

80104331 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104331:	55                   	push   %ebp
80104332:	89 e5                	mov    %esp,%ebp
80104334:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104337:	e8 03 ef ff ff       	call   8010323f <myproc>
8010433c:	8b 50 20             	mov    0x20(%eax),%edx
8010433f:	8b 45 08             	mov    0x8(%ebp),%eax
80104342:	c1 e0 02             	shl    $0x2,%eax
80104345:	03 42 44             	add    0x44(%edx),%eax
80104348:	83 ec 08             	sub    $0x8,%esp
8010434b:	ff 75 0c             	push   0xc(%ebp)
8010434e:	83 c0 04             	add    $0x4,%eax
80104351:	50                   	push   %eax
80104352:	e8 5f ff ff ff       	call   801042b6 <fetchint>
}
80104357:	c9                   	leave  
80104358:	c3                   	ret    

80104359 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, void **pp, int size)
{
80104359:	55                   	push   %ebp
8010435a:	89 e5                	mov    %esp,%ebp
8010435c:	56                   	push   %esi
8010435d:	53                   	push   %ebx
8010435e:	83 ec 10             	sub    $0x10,%esp
80104361:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80104364:	e8 d6 ee ff ff       	call   8010323f <myproc>
80104369:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
8010436b:	83 ec 08             	sub    $0x8,%esp
8010436e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104371:	50                   	push   %eax
80104372:	ff 75 08             	push   0x8(%ebp)
80104375:	e8 b7 ff ff ff       	call   80104331 <argint>
8010437a:	83 c4 10             	add    $0x10,%esp
8010437d:	85 c0                	test   %eax,%eax
8010437f:	78 25                	js     801043a6 <argptr+0x4d>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104381:	85 db                	test   %ebx,%ebx
80104383:	78 28                	js     801043ad <argptr+0x54>
80104385:	8b 56 08             	mov    0x8(%esi),%edx
80104388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010438b:	39 c2                	cmp    %eax,%edx
8010438d:	76 25                	jbe    801043b4 <argptr+0x5b>
8010438f:	01 c3                	add    %eax,%ebx
80104391:	39 da                	cmp    %ebx,%edx
80104393:	72 26                	jb     801043bb <argptr+0x62>
    return -1;
  *pp = (void*)i;
80104395:	8b 55 0c             	mov    0xc(%ebp),%edx
80104398:	89 02                	mov    %eax,(%edx)
  return 0;
8010439a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010439f:	8d 65 f8             	lea    -0x8(%ebp),%esp
801043a2:	5b                   	pop    %ebx
801043a3:	5e                   	pop    %esi
801043a4:	5d                   	pop    %ebp
801043a5:	c3                   	ret    
    return -1;
801043a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043ab:	eb f2                	jmp    8010439f <argptr+0x46>
    return -1;
801043ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043b2:	eb eb                	jmp    8010439f <argptr+0x46>
801043b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043b9:	eb e4                	jmp    8010439f <argptr+0x46>
801043bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043c0:	eb dd                	jmp    8010439f <argptr+0x46>

801043c2 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801043c2:	55                   	push   %ebp
801043c3:	89 e5                	mov    %esp,%ebp
801043c5:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
801043c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801043cb:	50                   	push   %eax
801043cc:	ff 75 08             	push   0x8(%ebp)
801043cf:	e8 5d ff ff ff       	call   80104331 <argint>
801043d4:	83 c4 10             	add    $0x10,%esp
801043d7:	85 c0                	test   %eax,%eax
801043d9:	78 13                	js     801043ee <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
801043db:	83 ec 08             	sub    $0x8,%esp
801043de:	ff 75 0c             	push   0xc(%ebp)
801043e1:	ff 75 f4             	push   -0xc(%ebp)
801043e4:	e8 09 ff ff ff       	call   801042f2 <fetchstr>
801043e9:	83 c4 10             	add    $0x10,%esp
}
801043ec:	c9                   	leave  
801043ed:	c3                   	ret    
    return -1;
801043ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043f3:	eb f7                	jmp    801043ec <argstr+0x2a>

801043f5 <syscall>:
[SYS_setprio]	sys_setprio,
};

void
syscall(void)
{
801043f5:	55                   	push   %ebp
801043f6:	89 e5                	mov    %esp,%ebp
801043f8:	53                   	push   %ebx
801043f9:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
801043fc:	e8 3e ee ff ff       	call   8010323f <myproc>
80104401:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104403:	8b 40 20             	mov    0x20(%eax),%eax
80104406:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104409:	8d 50 ff             	lea    -0x1(%eax),%edx
8010440c:	83 fa 18             	cmp    $0x18,%edx
8010440f:	77 17                	ja     80104428 <syscall+0x33>
80104411:	8b 14 85 80 76 10 80 	mov    -0x7fef8980(,%eax,4),%edx
80104418:	85 d2                	test   %edx,%edx
8010441a:	74 0c                	je     80104428 <syscall+0x33>
    curproc->tf->eax = syscalls[num]();
8010441c:	ff d2                	call   *%edx
8010441e:	89 c2                	mov    %eax,%edx
80104420:	8b 43 20             	mov    0x20(%ebx),%eax
80104423:	89 50 1c             	mov    %edx,0x1c(%eax)
80104426:	eb 1f                	jmp    80104447 <syscall+0x52>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104428:	8d 53 78             	lea    0x78(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010442b:	50                   	push   %eax
8010442c:	52                   	push   %edx
8010442d:	ff 73 18             	push   0x18(%ebx)
80104430:	68 49 76 10 80       	push   $0x80107649
80104435:	e8 a0 c1 ff ff       	call   801005da <cprintf>
    curproc->tf->eax = -1;
8010443a:	8b 43 20             	mov    0x20(%ebx),%eax
8010443d:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80104444:	83 c4 10             	add    $0x10,%esp
  }
}
80104447:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010444a:	c9                   	leave  
8010444b:	c3                   	ret    

8010444c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010444c:	55                   	push   %ebp
8010444d:	89 e5                	mov    %esp,%ebp
8010444f:	56                   	push   %esi
80104450:	53                   	push   %ebx
80104451:	83 ec 18             	sub    $0x18,%esp
80104454:	89 d6                	mov    %edx,%esi
80104456:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104458:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010445b:	52                   	push   %edx
8010445c:	50                   	push   %eax
8010445d:	e8 cf fe ff ff       	call   80104331 <argint>
80104462:	83 c4 10             	add    $0x10,%esp
80104465:	85 c0                	test   %eax,%eax
80104467:	78 35                	js     8010449e <argfd+0x52>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104469:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010446d:	77 28                	ja     80104497 <argfd+0x4b>
8010446f:	e8 cb ed ff ff       	call   8010323f <myproc>
80104474:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104477:	8b 44 90 34          	mov    0x34(%eax,%edx,4),%eax
8010447b:	85 c0                	test   %eax,%eax
8010447d:	74 18                	je     80104497 <argfd+0x4b>
    return -1;
  if(pfd)
8010447f:	85 f6                	test   %esi,%esi
80104481:	74 02                	je     80104485 <argfd+0x39>
    *pfd = fd;
80104483:	89 16                	mov    %edx,(%esi)
  if(pf)
80104485:	85 db                	test   %ebx,%ebx
80104487:	74 1c                	je     801044a5 <argfd+0x59>
    *pf = f;
80104489:	89 03                	mov    %eax,(%ebx)
  return 0;
8010448b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104490:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104493:	5b                   	pop    %ebx
80104494:	5e                   	pop    %esi
80104495:	5d                   	pop    %ebp
80104496:	c3                   	ret    
    return -1;
80104497:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010449c:	eb f2                	jmp    80104490 <argfd+0x44>
    return -1;
8010449e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044a3:	eb eb                	jmp    80104490 <argfd+0x44>
  return 0;
801044a5:	b8 00 00 00 00       	mov    $0x0,%eax
801044aa:	eb e4                	jmp    80104490 <argfd+0x44>

801044ac <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801044ac:	55                   	push   %ebp
801044ad:	89 e5                	mov    %esp,%ebp
801044af:	53                   	push   %ebx
801044b0:	83 ec 04             	sub    $0x4,%esp
801044b3:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801044b5:	e8 85 ed ff ff       	call   8010323f <myproc>
801044ba:	89 c2                	mov    %eax,%edx

  for(fd = 0; fd < NOFILE; fd++){
801044bc:	b8 00 00 00 00       	mov    $0x0,%eax
801044c1:	83 f8 0f             	cmp    $0xf,%eax
801044c4:	7f 10                	jg     801044d6 <fdalloc+0x2a>
    if(curproc->ofile[fd] == 0){
801044c6:	83 7c 82 34 00       	cmpl   $0x0,0x34(%edx,%eax,4)
801044cb:	74 03                	je     801044d0 <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
801044cd:	40                   	inc    %eax
801044ce:	eb f1                	jmp    801044c1 <fdalloc+0x15>
      curproc->ofile[fd] = f;
801044d0:	89 5c 82 34          	mov    %ebx,0x34(%edx,%eax,4)
      return fd;
801044d4:	eb 05                	jmp    801044db <fdalloc+0x2f>
    }
  }
  return -1;
801044d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801044db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044de:	c9                   	leave  
801044df:	c3                   	ret    

801044e0 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801044e0:	55                   	push   %ebp
801044e1:	89 e5                	mov    %esp,%ebp
801044e3:	56                   	push   %esi
801044e4:	53                   	push   %ebx
801044e5:	83 ec 10             	sub    $0x10,%esp
801044e8:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801044ea:	b8 20 00 00 00       	mov    $0x20,%eax
801044ef:	89 c6                	mov    %eax,%esi
801044f1:	39 43 58             	cmp    %eax,0x58(%ebx)
801044f4:	76 2e                	jbe    80104524 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801044f6:	6a 10                	push   $0x10
801044f8:	50                   	push   %eax
801044f9:	8d 45 e8             	lea    -0x18(%ebp),%eax
801044fc:	50                   	push   %eax
801044fd:	53                   	push   %ebx
801044fe:	e8 08 d2 ff ff       	call   8010170b <readi>
80104503:	83 c4 10             	add    $0x10,%esp
80104506:	83 f8 10             	cmp    $0x10,%eax
80104509:	75 0c                	jne    80104517 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
8010450b:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
80104510:	75 1e                	jne    80104530 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104512:	8d 46 10             	lea    0x10(%esi),%eax
80104515:	eb d8                	jmp    801044ef <isdirempty+0xf>
      panic("isdirempty: readi");
80104517:	83 ec 0c             	sub    $0xc,%esp
8010451a:	68 e8 76 10 80       	push   $0x801076e8
8010451f:	e8 1d be ff ff       	call   80100341 <panic>
      return 0;
  }
  return 1;
80104524:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104529:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010452c:	5b                   	pop    %ebx
8010452d:	5e                   	pop    %esi
8010452e:	5d                   	pop    %ebp
8010452f:	c3                   	ret    
      return 0;
80104530:	b8 00 00 00 00       	mov    $0x0,%eax
80104535:	eb f2                	jmp    80104529 <isdirempty+0x49>

80104537 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104537:	55                   	push   %ebp
80104538:	89 e5                	mov    %esp,%ebp
8010453a:	57                   	push   %edi
8010453b:	56                   	push   %esi
8010453c:	53                   	push   %ebx
8010453d:	83 ec 44             	sub    $0x44,%esp
80104540:	89 d7                	mov    %edx,%edi
80104542:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
80104545:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104548:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010454b:	8d 55 d6             	lea    -0x2a(%ebp),%edx
8010454e:	52                   	push   %edx
8010454f:	50                   	push   %eax
80104550:	e8 45 d6 ff ff       	call   80101b9a <nameiparent>
80104555:	89 c6                	mov    %eax,%esi
80104557:	83 c4 10             	add    $0x10,%esp
8010455a:	85 c0                	test   %eax,%eax
8010455c:	0f 84 32 01 00 00    	je     80104694 <create+0x15d>
    return 0;
  ilock(dp);
80104562:	83 ec 0c             	sub    $0xc,%esp
80104565:	50                   	push   %eax
80104566:	e8 b3 cf ff ff       	call   8010151e <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010456b:	83 c4 0c             	add    $0xc,%esp
8010456e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104571:	50                   	push   %eax
80104572:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104575:	50                   	push   %eax
80104576:	56                   	push   %esi
80104577:	e8 d8 d3 ff ff       	call   80101954 <dirlookup>
8010457c:	89 c3                	mov    %eax,%ebx
8010457e:	83 c4 10             	add    $0x10,%esp
80104581:	85 c0                	test   %eax,%eax
80104583:	74 3c                	je     801045c1 <create+0x8a>
    iunlockput(dp);
80104585:	83 ec 0c             	sub    $0xc,%esp
80104588:	56                   	push   %esi
80104589:	e8 33 d1 ff ff       	call   801016c1 <iunlockput>
    ilock(ip);
8010458e:	89 1c 24             	mov    %ebx,(%esp)
80104591:	e8 88 cf ff ff       	call   8010151e <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104596:	83 c4 10             	add    $0x10,%esp
80104599:	66 83 ff 02          	cmp    $0x2,%di
8010459d:	75 07                	jne    801045a6 <create+0x6f>
8010459f:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801045a4:	74 11                	je     801045b7 <create+0x80>
      return ip;
    iunlockput(ip);
801045a6:	83 ec 0c             	sub    $0xc,%esp
801045a9:	53                   	push   %ebx
801045aa:	e8 12 d1 ff ff       	call   801016c1 <iunlockput>
    return 0;
801045af:	83 c4 10             	add    $0x10,%esp
801045b2:	bb 00 00 00 00       	mov    $0x0,%ebx
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801045b7:	89 d8                	mov    %ebx,%eax
801045b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801045bc:	5b                   	pop    %ebx
801045bd:	5e                   	pop    %esi
801045be:	5f                   	pop    %edi
801045bf:	5d                   	pop    %ebp
801045c0:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
801045c1:	83 ec 08             	sub    $0x8,%esp
801045c4:	0f bf c7             	movswl %di,%eax
801045c7:	50                   	push   %eax
801045c8:	ff 36                	push   (%esi)
801045ca:	e8 57 cd ff ff       	call   80101326 <ialloc>
801045cf:	89 c3                	mov    %eax,%ebx
801045d1:	83 c4 10             	add    $0x10,%esp
801045d4:	85 c0                	test   %eax,%eax
801045d6:	74 53                	je     8010462b <create+0xf4>
  ilock(ip);
801045d8:	83 ec 0c             	sub    $0xc,%esp
801045db:	50                   	push   %eax
801045dc:	e8 3d cf ff ff       	call   8010151e <ilock>
  ip->major = major;
801045e1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801045e4:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
801045e8:	8b 45 c0             	mov    -0x40(%ebp),%eax
801045eb:	66 89 43 54          	mov    %ax,0x54(%ebx)
  ip->nlink = 1;
801045ef:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
801045f5:	89 1c 24             	mov    %ebx,(%esp)
801045f8:	e8 c8 cd ff ff       	call   801013c5 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
801045fd:	83 c4 10             	add    $0x10,%esp
80104600:	66 83 ff 01          	cmp    $0x1,%di
80104604:	74 32                	je     80104638 <create+0x101>
  if(dirlink(dp, name, ip->inum) < 0)
80104606:	83 ec 04             	sub    $0x4,%esp
80104609:	ff 73 04             	push   0x4(%ebx)
8010460c:	8d 45 d6             	lea    -0x2a(%ebp),%eax
8010460f:	50                   	push   %eax
80104610:	56                   	push   %esi
80104611:	e8 bb d4 ff ff       	call   80101ad1 <dirlink>
80104616:	83 c4 10             	add    $0x10,%esp
80104619:	85 c0                	test   %eax,%eax
8010461b:	78 6a                	js     80104687 <create+0x150>
  iunlockput(dp);
8010461d:	83 ec 0c             	sub    $0xc,%esp
80104620:	56                   	push   %esi
80104621:	e8 9b d0 ff ff       	call   801016c1 <iunlockput>
  return ip;
80104626:	83 c4 10             	add    $0x10,%esp
80104629:	eb 8c                	jmp    801045b7 <create+0x80>
    panic("create: ialloc");
8010462b:	83 ec 0c             	sub    $0xc,%esp
8010462e:	68 fa 76 10 80       	push   $0x801076fa
80104633:	e8 09 bd ff ff       	call   80100341 <panic>
    dp->nlink++;  // for ".."
80104638:	66 8b 46 56          	mov    0x56(%esi),%ax
8010463c:	40                   	inc    %eax
8010463d:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104641:	83 ec 0c             	sub    $0xc,%esp
80104644:	56                   	push   %esi
80104645:	e8 7b cd ff ff       	call   801013c5 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010464a:	83 c4 0c             	add    $0xc,%esp
8010464d:	ff 73 04             	push   0x4(%ebx)
80104650:	68 0a 77 10 80       	push   $0x8010770a
80104655:	53                   	push   %ebx
80104656:	e8 76 d4 ff ff       	call   80101ad1 <dirlink>
8010465b:	83 c4 10             	add    $0x10,%esp
8010465e:	85 c0                	test   %eax,%eax
80104660:	78 18                	js     8010467a <create+0x143>
80104662:	83 ec 04             	sub    $0x4,%esp
80104665:	ff 76 04             	push   0x4(%esi)
80104668:	68 09 77 10 80       	push   $0x80107709
8010466d:	53                   	push   %ebx
8010466e:	e8 5e d4 ff ff       	call   80101ad1 <dirlink>
80104673:	83 c4 10             	add    $0x10,%esp
80104676:	85 c0                	test   %eax,%eax
80104678:	79 8c                	jns    80104606 <create+0xcf>
      panic("create dots");
8010467a:	83 ec 0c             	sub    $0xc,%esp
8010467d:	68 0c 77 10 80       	push   $0x8010770c
80104682:	e8 ba bc ff ff       	call   80100341 <panic>
    panic("create: dirlink");
80104687:	83 ec 0c             	sub    $0xc,%esp
8010468a:	68 18 77 10 80       	push   $0x80107718
8010468f:	e8 ad bc ff ff       	call   80100341 <panic>
    return 0;
80104694:	89 c3                	mov    %eax,%ebx
80104696:	e9 1c ff ff ff       	jmp    801045b7 <create+0x80>

8010469b <sys_dup>:
{
8010469b:	55                   	push   %ebp
8010469c:	89 e5                	mov    %esp,%ebp
8010469e:	53                   	push   %ebx
8010469f:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801046a2:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801046a5:	ba 00 00 00 00       	mov    $0x0,%edx
801046aa:	b8 00 00 00 00       	mov    $0x0,%eax
801046af:	e8 98 fd ff ff       	call   8010444c <argfd>
801046b4:	85 c0                	test   %eax,%eax
801046b6:	78 23                	js     801046db <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801046b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046bb:	e8 ec fd ff ff       	call   801044ac <fdalloc>
801046c0:	89 c3                	mov    %eax,%ebx
801046c2:	85 c0                	test   %eax,%eax
801046c4:	78 1c                	js     801046e2 <sys_dup+0x47>
  filedup(f);
801046c6:	83 ec 0c             	sub    $0xc,%esp
801046c9:	ff 75 f4             	push   -0xc(%ebp)
801046cc:	e8 8e c5 ff ff       	call   80100c5f <filedup>
  return fd;
801046d1:	83 c4 10             	add    $0x10,%esp
}
801046d4:	89 d8                	mov    %ebx,%eax
801046d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801046d9:	c9                   	leave  
801046da:	c3                   	ret    
    return -1;
801046db:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801046e0:	eb f2                	jmp    801046d4 <sys_dup+0x39>
    return -1;
801046e2:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801046e7:	eb eb                	jmp    801046d4 <sys_dup+0x39>

801046e9 <sys_dup2>:
{
801046e9:	55                   	push   %ebp
801046ea:	89 e5                	mov    %esp,%ebp
801046ec:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0,&oldfd,&old_f) < 0){
801046ef:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801046f2:	8d 55 f0             	lea    -0x10(%ebp),%edx
801046f5:	b8 00 00 00 00       	mov    $0x0,%eax
801046fa:	e8 4d fd ff ff       	call   8010444c <argfd>
801046ff:	85 c0                	test   %eax,%eax
80104701:	78 5e                	js     80104761 <sys_dup2+0x78>
  if(argint(1, &newfd) < 0)
80104703:	83 ec 08             	sub    $0x8,%esp
80104706:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104709:	50                   	push   %eax
8010470a:	6a 01                	push   $0x1
8010470c:	e8 20 fc ff ff       	call   80104331 <argint>
80104711:	83 c4 10             	add    $0x10,%esp
80104714:	85 c0                	test   %eax,%eax
80104716:	78 50                	js     80104768 <sys_dup2+0x7f>
  if(newfd==oldfd)
80104718:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010471b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010471e:	74 3f                	je     8010475f <sys_dup2+0x76>
  if( newfd<0 || newfd >NOFILE)
80104720:	83 f8 10             	cmp    $0x10,%eax
80104723:	77 4a                	ja     8010476f <sys_dup2+0x86>
  if((new_f=myproc()->ofile[newfd]) != 0)  
80104725:	e8 15 eb ff ff       	call   8010323f <myproc>
8010472a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010472d:	8b 44 90 34          	mov    0x34(%eax,%edx,4),%eax
80104731:	85 c0                	test   %eax,%eax
80104733:	74 0c                	je     80104741 <sys_dup2+0x58>
    fileclose(new_f);
80104735:	83 ec 0c             	sub    $0xc,%esp
80104738:	50                   	push   %eax
80104739:	e8 64 c5 ff ff       	call   80100ca2 <fileclose>
8010473e:	83 c4 10             	add    $0x10,%esp
  myproc()->ofile[newfd] = old_f;
80104741:	e8 f9 ea ff ff       	call   8010323f <myproc>
80104746:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104749:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010474c:	89 54 88 34          	mov    %edx,0x34(%eax,%ecx,4)
  filedup(old_f);
80104750:	83 ec 0c             	sub    $0xc,%esp
80104753:	52                   	push   %edx
80104754:	e8 06 c5 ff ff       	call   80100c5f <filedup>
  return newfd;
80104759:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010475c:	83 c4 10             	add    $0x10,%esp
}
8010475f:	c9                   	leave  
80104760:	c3                   	ret    
    return -1;
80104761:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104766:	eb f7                	jmp    8010475f <sys_dup2+0x76>
    return -1;
80104768:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010476d:	eb f0                	jmp    8010475f <sys_dup2+0x76>
  	return -1;
8010476f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104774:	eb e9                	jmp    8010475f <sys_dup2+0x76>

80104776 <sys_getprio>:
{
80104776:	55                   	push   %ebp
80104777:	89 e5                	mov    %esp,%ebp
80104779:	53                   	push   %ebx
8010477a:	83 ec 20             	sub    $0x20,%esp
	cprintf("--getprio--");
8010477d:	68 28 77 10 80       	push   $0x80107728
80104782:	e8 53 be ff ff       	call   801005da <cprintf>
	if(argint(0, &pid) < 0)
80104787:	83 c4 08             	add    $0x8,%esp
8010478a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010478d:	50                   	push   %eax
8010478e:	6a 00                	push   $0x0
80104790:	e8 9c fb ff ff       	call   80104331 <argint>
80104795:	83 c4 10             	add    $0x10,%esp
80104798:	85 c0                	test   %eax,%eax
8010479a:	78 28                	js     801047c4 <sys_getprio+0x4e>
	if(pid < 0)
8010479c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010479f:	85 c0                	test   %eax,%eax
801047a1:	78 28                	js     801047cb <sys_getprio+0x55>
	ret = getprio(pid);	
801047a3:	83 ec 0c             	sub    $0xc,%esp
801047a6:	50                   	push   %eax
801047a7:	e8 40 ee ff ff       	call   801035ec <getprio>
801047ac:	89 c3                	mov    %eax,%ebx
	cprintf("getprio-ret\n");
801047ae:	c7 04 24 34 77 10 80 	movl   $0x80107734,(%esp)
801047b5:	e8 20 be ff ff       	call   801005da <cprintf>
	return ret;
801047ba:	83 c4 10             	add    $0x10,%esp
}
801047bd:	89 d8                	mov    %ebx,%eax
801047bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801047c2:	c9                   	leave  
801047c3:	c3                   	ret    
		return -1;	
801047c4:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801047c9:	eb f2                	jmp    801047bd <sys_getprio+0x47>
		return -1;
801047cb:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801047d0:	eb eb                	jmp    801047bd <sys_getprio+0x47>

801047d2 <sys_setprio>:
{
801047d2:	55                   	push   %ebp
801047d3:	89 e5                	mov    %esp,%ebp
801047d5:	53                   	push   %ebx
801047d6:	83 ec 20             	sub    $0x20,%esp
	cprintf("--setprio--");
801047d9:	68 41 77 10 80       	push   $0x80107741
801047de:	e8 f7 bd ff ff       	call   801005da <cprintf>
	if(argint(0, &pid) < 0)
801047e3:	83 c4 08             	add    $0x8,%esp
801047e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801047e9:	50                   	push   %eax
801047ea:	6a 00                	push   $0x0
801047ec:	e8 40 fb ff ff       	call   80104331 <argint>
801047f1:	83 c4 10             	add    $0x10,%esp
801047f4:	85 c0                	test   %eax,%eax
801047f6:	78 3f                	js     80104837 <sys_setprio+0x65>
	if(argptr(1,(void**) &prio, sizeof(enum proc_prio)) < 0)
801047f8:	83 ec 04             	sub    $0x4,%esp
801047fb:	6a 04                	push   $0x4
801047fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104800:	50                   	push   %eax
80104801:	6a 01                	push   $0x1
80104803:	e8 51 fb ff ff       	call   80104359 <argptr>
80104808:	83 c4 10             	add    $0x10,%esp
8010480b:	85 c0                	test   %eax,%eax
8010480d:	78 2f                	js     8010483e <sys_setprio+0x6c>
	ret = setprio(pid, prio);
8010480f:	83 ec 08             	sub    $0x8,%esp
80104812:	ff 75 f0             	push   -0x10(%ebp)
80104815:	ff 75 f4             	push   -0xc(%ebp)
80104818:	e8 78 f1 ff ff       	call   80103995 <setprio>
8010481d:	89 c3                	mov    %eax,%ebx
	cprintf("setprio return %d\n",ret);
8010481f:	83 c4 08             	add    $0x8,%esp
80104822:	50                   	push   %eax
80104823:	68 4d 77 10 80       	push   $0x8010774d
80104828:	e8 ad bd ff ff       	call   801005da <cprintf>
	return ret;
8010482d:	83 c4 10             	add    $0x10,%esp
}
80104830:	89 d8                	mov    %ebx,%eax
80104832:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104835:	c9                   	leave  
80104836:	c3                   	ret    
		return -1;
80104837:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010483c:	eb f2                	jmp    80104830 <sys_setprio+0x5e>
		return -1;
8010483e:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104843:	eb eb                	jmp    80104830 <sys_setprio+0x5e>

80104845 <sys_read>:
{
80104845:	55                   	push   %ebp
80104846:	89 e5                	mov    %esp,%ebp
80104848:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, (void**)&p, n) < 0)
8010484b:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010484e:	ba 00 00 00 00       	mov    $0x0,%edx
80104853:	b8 00 00 00 00       	mov    $0x0,%eax
80104858:	e8 ef fb ff ff       	call   8010444c <argfd>
8010485d:	85 c0                	test   %eax,%eax
8010485f:	78 43                	js     801048a4 <sys_read+0x5f>
80104861:	83 ec 08             	sub    $0x8,%esp
80104864:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104867:	50                   	push   %eax
80104868:	6a 02                	push   $0x2
8010486a:	e8 c2 fa ff ff       	call   80104331 <argint>
8010486f:	83 c4 10             	add    $0x10,%esp
80104872:	85 c0                	test   %eax,%eax
80104874:	78 2e                	js     801048a4 <sys_read+0x5f>
80104876:	83 ec 04             	sub    $0x4,%esp
80104879:	ff 75 f0             	push   -0x10(%ebp)
8010487c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010487f:	50                   	push   %eax
80104880:	6a 01                	push   $0x1
80104882:	e8 d2 fa ff ff       	call   80104359 <argptr>
80104887:	83 c4 10             	add    $0x10,%esp
8010488a:	85 c0                	test   %eax,%eax
8010488c:	78 16                	js     801048a4 <sys_read+0x5f>
  return fileread(f, p, n);
8010488e:	83 ec 04             	sub    $0x4,%esp
80104891:	ff 75 f0             	push   -0x10(%ebp)
80104894:	ff 75 ec             	push   -0x14(%ebp)
80104897:	ff 75 f4             	push   -0xc(%ebp)
8010489a:	e8 fc c4 ff ff       	call   80100d9b <fileread>
8010489f:	83 c4 10             	add    $0x10,%esp
}
801048a2:	c9                   	leave  
801048a3:	c3                   	ret    
    return -1;
801048a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048a9:	eb f7                	jmp    801048a2 <sys_read+0x5d>

801048ab <sys_write>:
{
801048ab:	55                   	push   %ebp
801048ac:	89 e5                	mov    %esp,%ebp
801048ae:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, (void**)&p, n) < 0)
801048b1:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801048b4:	ba 00 00 00 00       	mov    $0x0,%edx
801048b9:	b8 00 00 00 00       	mov    $0x0,%eax
801048be:	e8 89 fb ff ff       	call   8010444c <argfd>
801048c3:	85 c0                	test   %eax,%eax
801048c5:	78 43                	js     8010490a <sys_write+0x5f>
801048c7:	83 ec 08             	sub    $0x8,%esp
801048ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
801048cd:	50                   	push   %eax
801048ce:	6a 02                	push   $0x2
801048d0:	e8 5c fa ff ff       	call   80104331 <argint>
801048d5:	83 c4 10             	add    $0x10,%esp
801048d8:	85 c0                	test   %eax,%eax
801048da:	78 2e                	js     8010490a <sys_write+0x5f>
801048dc:	83 ec 04             	sub    $0x4,%esp
801048df:	ff 75 f0             	push   -0x10(%ebp)
801048e2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801048e5:	50                   	push   %eax
801048e6:	6a 01                	push   $0x1
801048e8:	e8 6c fa ff ff       	call   80104359 <argptr>
801048ed:	83 c4 10             	add    $0x10,%esp
801048f0:	85 c0                	test   %eax,%eax
801048f2:	78 16                	js     8010490a <sys_write+0x5f>
  return filewrite(f, p, n);
801048f4:	83 ec 04             	sub    $0x4,%esp
801048f7:	ff 75 f0             	push   -0x10(%ebp)
801048fa:	ff 75 ec             	push   -0x14(%ebp)
801048fd:	ff 75 f4             	push   -0xc(%ebp)
80104900:	e8 1b c5 ff ff       	call   80100e20 <filewrite>
80104905:	83 c4 10             	add    $0x10,%esp
}
80104908:	c9                   	leave  
80104909:	c3                   	ret    
    return -1;
8010490a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010490f:	eb f7                	jmp    80104908 <sys_write+0x5d>

80104911 <sys_close>:
{
80104911:	55                   	push   %ebp
80104912:	89 e5                	mov    %esp,%ebp
80104914:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80104917:	8d 4d f0             	lea    -0x10(%ebp),%ecx
8010491a:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010491d:	b8 00 00 00 00       	mov    $0x0,%eax
80104922:	e8 25 fb ff ff       	call   8010444c <argfd>
80104927:	85 c0                	test   %eax,%eax
80104929:	78 25                	js     80104950 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
8010492b:	e8 0f e9 ff ff       	call   8010323f <myproc>
80104930:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104933:	c7 44 90 34 00 00 00 	movl   $0x0,0x34(%eax,%edx,4)
8010493a:	00 
  fileclose(f);
8010493b:	83 ec 0c             	sub    $0xc,%esp
8010493e:	ff 75 f0             	push   -0x10(%ebp)
80104941:	e8 5c c3 ff ff       	call   80100ca2 <fileclose>
  return 0;
80104946:	83 c4 10             	add    $0x10,%esp
80104949:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010494e:	c9                   	leave  
8010494f:	c3                   	ret    
    return -1;
80104950:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104955:	eb f7                	jmp    8010494e <sys_close+0x3d>

80104957 <sys_fstat>:
{
80104957:	55                   	push   %ebp
80104958:	89 e5                	mov    %esp,%ebp
8010495a:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010495d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104960:	ba 00 00 00 00       	mov    $0x0,%edx
80104965:	b8 00 00 00 00       	mov    $0x0,%eax
8010496a:	e8 dd fa ff ff       	call   8010444c <argfd>
8010496f:	85 c0                	test   %eax,%eax
80104971:	78 2a                	js     8010499d <sys_fstat+0x46>
80104973:	83 ec 04             	sub    $0x4,%esp
80104976:	6a 14                	push   $0x14
80104978:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010497b:	50                   	push   %eax
8010497c:	6a 01                	push   $0x1
8010497e:	e8 d6 f9 ff ff       	call   80104359 <argptr>
80104983:	83 c4 10             	add    $0x10,%esp
80104986:	85 c0                	test   %eax,%eax
80104988:	78 13                	js     8010499d <sys_fstat+0x46>
  return filestat(f, st);
8010498a:	83 ec 08             	sub    $0x8,%esp
8010498d:	ff 75 f0             	push   -0x10(%ebp)
80104990:	ff 75 f4             	push   -0xc(%ebp)
80104993:	e8 bc c3 ff ff       	call   80100d54 <filestat>
80104998:	83 c4 10             	add    $0x10,%esp
}
8010499b:	c9                   	leave  
8010499c:	c3                   	ret    
    return -1;
8010499d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049a2:	eb f7                	jmp    8010499b <sys_fstat+0x44>

801049a4 <sys_link>:
{
801049a4:	55                   	push   %ebp
801049a5:	89 e5                	mov    %esp,%ebp
801049a7:	56                   	push   %esi
801049a8:	53                   	push   %ebx
801049a9:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801049ac:	8d 45 e0             	lea    -0x20(%ebp),%eax
801049af:	50                   	push   %eax
801049b0:	6a 00                	push   $0x0
801049b2:	e8 0b fa ff ff       	call   801043c2 <argstr>
801049b7:	83 c4 10             	add    $0x10,%esp
801049ba:	85 c0                	test   %eax,%eax
801049bc:	0f 88 d1 00 00 00    	js     80104a93 <sys_link+0xef>
801049c2:	83 ec 08             	sub    $0x8,%esp
801049c5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801049c8:	50                   	push   %eax
801049c9:	6a 01                	push   $0x1
801049cb:	e8 f2 f9 ff ff       	call   801043c2 <argstr>
801049d0:	83 c4 10             	add    $0x10,%esp
801049d3:	85 c0                	test   %eax,%eax
801049d5:	0f 88 b8 00 00 00    	js     80104a93 <sys_link+0xef>
  begin_op();
801049db:	e8 14 dd ff ff       	call   801026f4 <begin_op>
  if((ip = namei(old)) == 0){
801049e0:	83 ec 0c             	sub    $0xc,%esp
801049e3:	ff 75 e0             	push   -0x20(%ebp)
801049e6:	e8 97 d1 ff ff       	call   80101b82 <namei>
801049eb:	89 c3                	mov    %eax,%ebx
801049ed:	83 c4 10             	add    $0x10,%esp
801049f0:	85 c0                	test   %eax,%eax
801049f2:	0f 84 a2 00 00 00    	je     80104a9a <sys_link+0xf6>
  ilock(ip);
801049f8:	83 ec 0c             	sub    $0xc,%esp
801049fb:	50                   	push   %eax
801049fc:	e8 1d cb ff ff       	call   8010151e <ilock>
  if(ip->type == T_DIR){
80104a01:	83 c4 10             	add    $0x10,%esp
80104a04:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104a09:	0f 84 97 00 00 00    	je     80104aa6 <sys_link+0x102>
  ip->nlink++;
80104a0f:	66 8b 43 56          	mov    0x56(%ebx),%ax
80104a13:	40                   	inc    %eax
80104a14:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104a18:	83 ec 0c             	sub    $0xc,%esp
80104a1b:	53                   	push   %ebx
80104a1c:	e8 a4 c9 ff ff       	call   801013c5 <iupdate>
  iunlock(ip);
80104a21:	89 1c 24             	mov    %ebx,(%esp)
80104a24:	e8 b5 cb ff ff       	call   801015de <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104a29:	83 c4 08             	add    $0x8,%esp
80104a2c:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104a2f:	50                   	push   %eax
80104a30:	ff 75 e4             	push   -0x1c(%ebp)
80104a33:	e8 62 d1 ff ff       	call   80101b9a <nameiparent>
80104a38:	89 c6                	mov    %eax,%esi
80104a3a:	83 c4 10             	add    $0x10,%esp
80104a3d:	85 c0                	test   %eax,%eax
80104a3f:	0f 84 85 00 00 00    	je     80104aca <sys_link+0x126>
  ilock(dp);
80104a45:	83 ec 0c             	sub    $0xc,%esp
80104a48:	50                   	push   %eax
80104a49:	e8 d0 ca ff ff       	call   8010151e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104a4e:	83 c4 10             	add    $0x10,%esp
80104a51:	8b 03                	mov    (%ebx),%eax
80104a53:	39 06                	cmp    %eax,(%esi)
80104a55:	75 67                	jne    80104abe <sys_link+0x11a>
80104a57:	83 ec 04             	sub    $0x4,%esp
80104a5a:	ff 73 04             	push   0x4(%ebx)
80104a5d:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104a60:	50                   	push   %eax
80104a61:	56                   	push   %esi
80104a62:	e8 6a d0 ff ff       	call   80101ad1 <dirlink>
80104a67:	83 c4 10             	add    $0x10,%esp
80104a6a:	85 c0                	test   %eax,%eax
80104a6c:	78 50                	js     80104abe <sys_link+0x11a>
  iunlockput(dp);
80104a6e:	83 ec 0c             	sub    $0xc,%esp
80104a71:	56                   	push   %esi
80104a72:	e8 4a cc ff ff       	call   801016c1 <iunlockput>
  iput(ip);
80104a77:	89 1c 24             	mov    %ebx,(%esp)
80104a7a:	e8 a4 cb ff ff       	call   80101623 <iput>
  end_op();
80104a7f:	e8 ec dc ff ff       	call   80102770 <end_op>
  return 0;
80104a84:	83 c4 10             	add    $0x10,%esp
80104a87:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104a8f:	5b                   	pop    %ebx
80104a90:	5e                   	pop    %esi
80104a91:	5d                   	pop    %ebp
80104a92:	c3                   	ret    
    return -1;
80104a93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a98:	eb f2                	jmp    80104a8c <sys_link+0xe8>
    end_op();
80104a9a:	e8 d1 dc ff ff       	call   80102770 <end_op>
    return -1;
80104a9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104aa4:	eb e6                	jmp    80104a8c <sys_link+0xe8>
    iunlockput(ip);
80104aa6:	83 ec 0c             	sub    $0xc,%esp
80104aa9:	53                   	push   %ebx
80104aaa:	e8 12 cc ff ff       	call   801016c1 <iunlockput>
    end_op();
80104aaf:	e8 bc dc ff ff       	call   80102770 <end_op>
    return -1;
80104ab4:	83 c4 10             	add    $0x10,%esp
80104ab7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104abc:	eb ce                	jmp    80104a8c <sys_link+0xe8>
    iunlockput(dp);
80104abe:	83 ec 0c             	sub    $0xc,%esp
80104ac1:	56                   	push   %esi
80104ac2:	e8 fa cb ff ff       	call   801016c1 <iunlockput>
    goto bad;
80104ac7:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80104aca:	83 ec 0c             	sub    $0xc,%esp
80104acd:	53                   	push   %ebx
80104ace:	e8 4b ca ff ff       	call   8010151e <ilock>
  ip->nlink--;
80104ad3:	66 8b 43 56          	mov    0x56(%ebx),%ax
80104ad7:	48                   	dec    %eax
80104ad8:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104adc:	89 1c 24             	mov    %ebx,(%esp)
80104adf:	e8 e1 c8 ff ff       	call   801013c5 <iupdate>
  iunlockput(ip);
80104ae4:	89 1c 24             	mov    %ebx,(%esp)
80104ae7:	e8 d5 cb ff ff       	call   801016c1 <iunlockput>
  end_op();
80104aec:	e8 7f dc ff ff       	call   80102770 <end_op>
  return -1;
80104af1:	83 c4 10             	add    $0x10,%esp
80104af4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104af9:	eb 91                	jmp    80104a8c <sys_link+0xe8>

80104afb <sys_unlink>:
{
80104afb:	55                   	push   %ebp
80104afc:	89 e5                	mov    %esp,%ebp
80104afe:	57                   	push   %edi
80104aff:	56                   	push   %esi
80104b00:	53                   	push   %ebx
80104b01:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
80104b04:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104b07:	50                   	push   %eax
80104b08:	6a 00                	push   $0x0
80104b0a:	e8 b3 f8 ff ff       	call   801043c2 <argstr>
80104b0f:	83 c4 10             	add    $0x10,%esp
80104b12:	85 c0                	test   %eax,%eax
80104b14:	0f 88 7f 01 00 00    	js     80104c99 <sys_unlink+0x19e>
  begin_op();
80104b1a:	e8 d5 db ff ff       	call   801026f4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104b1f:	83 ec 08             	sub    $0x8,%esp
80104b22:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104b25:	50                   	push   %eax
80104b26:	ff 75 c4             	push   -0x3c(%ebp)
80104b29:	e8 6c d0 ff ff       	call   80101b9a <nameiparent>
80104b2e:	89 c6                	mov    %eax,%esi
80104b30:	83 c4 10             	add    $0x10,%esp
80104b33:	85 c0                	test   %eax,%eax
80104b35:	0f 84 eb 00 00 00    	je     80104c26 <sys_unlink+0x12b>
  ilock(dp);
80104b3b:	83 ec 0c             	sub    $0xc,%esp
80104b3e:	50                   	push   %eax
80104b3f:	e8 da c9 ff ff       	call   8010151e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104b44:	83 c4 08             	add    $0x8,%esp
80104b47:	68 0a 77 10 80       	push   $0x8010770a
80104b4c:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104b4f:	50                   	push   %eax
80104b50:	e8 ea cd ff ff       	call   8010193f <namecmp>
80104b55:	83 c4 10             	add    $0x10,%esp
80104b58:	85 c0                	test   %eax,%eax
80104b5a:	0f 84 fa 00 00 00    	je     80104c5a <sys_unlink+0x15f>
80104b60:	83 ec 08             	sub    $0x8,%esp
80104b63:	68 09 77 10 80       	push   $0x80107709
80104b68:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104b6b:	50                   	push   %eax
80104b6c:	e8 ce cd ff ff       	call   8010193f <namecmp>
80104b71:	83 c4 10             	add    $0x10,%esp
80104b74:	85 c0                	test   %eax,%eax
80104b76:	0f 84 de 00 00 00    	je     80104c5a <sys_unlink+0x15f>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104b7c:	83 ec 04             	sub    $0x4,%esp
80104b7f:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104b82:	50                   	push   %eax
80104b83:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104b86:	50                   	push   %eax
80104b87:	56                   	push   %esi
80104b88:	e8 c7 cd ff ff       	call   80101954 <dirlookup>
80104b8d:	89 c3                	mov    %eax,%ebx
80104b8f:	83 c4 10             	add    $0x10,%esp
80104b92:	85 c0                	test   %eax,%eax
80104b94:	0f 84 c0 00 00 00    	je     80104c5a <sys_unlink+0x15f>
  ilock(ip);
80104b9a:	83 ec 0c             	sub    $0xc,%esp
80104b9d:	50                   	push   %eax
80104b9e:	e8 7b c9 ff ff       	call   8010151e <ilock>
  if(ip->nlink < 1)
80104ba3:	83 c4 10             	add    $0x10,%esp
80104ba6:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104bab:	0f 8e 81 00 00 00    	jle    80104c32 <sys_unlink+0x137>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104bb1:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104bb6:	0f 84 83 00 00 00    	je     80104c3f <sys_unlink+0x144>
  memset(&de, 0, sizeof(de));
80104bbc:	83 ec 04             	sub    $0x4,%esp
80104bbf:	6a 10                	push   $0x10
80104bc1:	6a 00                	push   $0x0
80104bc3:	8d 7d d8             	lea    -0x28(%ebp),%edi
80104bc6:	57                   	push   %edi
80104bc7:	e8 2f f5 ff ff       	call   801040fb <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104bcc:	6a 10                	push   $0x10
80104bce:	ff 75 c0             	push   -0x40(%ebp)
80104bd1:	57                   	push   %edi
80104bd2:	56                   	push   %esi
80104bd3:	e8 33 cc ff ff       	call   8010180b <writei>
80104bd8:	83 c4 20             	add    $0x20,%esp
80104bdb:	83 f8 10             	cmp    $0x10,%eax
80104bde:	0f 85 8e 00 00 00    	jne    80104c72 <sys_unlink+0x177>
  if(ip->type == T_DIR){
80104be4:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104be9:	0f 84 90 00 00 00    	je     80104c7f <sys_unlink+0x184>
  iunlockput(dp);
80104bef:	83 ec 0c             	sub    $0xc,%esp
80104bf2:	56                   	push   %esi
80104bf3:	e8 c9 ca ff ff       	call   801016c1 <iunlockput>
  ip->nlink--;
80104bf8:	66 8b 43 56          	mov    0x56(%ebx),%ax
80104bfc:	48                   	dec    %eax
80104bfd:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104c01:	89 1c 24             	mov    %ebx,(%esp)
80104c04:	e8 bc c7 ff ff       	call   801013c5 <iupdate>
  iunlockput(ip);
80104c09:	89 1c 24             	mov    %ebx,(%esp)
80104c0c:	e8 b0 ca ff ff       	call   801016c1 <iunlockput>
  end_op();
80104c11:	e8 5a db ff ff       	call   80102770 <end_op>
  return 0;
80104c16:	83 c4 10             	add    $0x10,%esp
80104c19:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104c21:	5b                   	pop    %ebx
80104c22:	5e                   	pop    %esi
80104c23:	5f                   	pop    %edi
80104c24:	5d                   	pop    %ebp
80104c25:	c3                   	ret    
    end_op();
80104c26:	e8 45 db ff ff       	call   80102770 <end_op>
    return -1;
80104c2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c30:	eb ec                	jmp    80104c1e <sys_unlink+0x123>
    panic("unlink: nlink < 1");
80104c32:	83 ec 0c             	sub    $0xc,%esp
80104c35:	68 60 77 10 80       	push   $0x80107760
80104c3a:	e8 02 b7 ff ff       	call   80100341 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104c3f:	89 d8                	mov    %ebx,%eax
80104c41:	e8 9a f8 ff ff       	call   801044e0 <isdirempty>
80104c46:	85 c0                	test   %eax,%eax
80104c48:	0f 85 6e ff ff ff    	jne    80104bbc <sys_unlink+0xc1>
    iunlockput(ip);
80104c4e:	83 ec 0c             	sub    $0xc,%esp
80104c51:	53                   	push   %ebx
80104c52:	e8 6a ca ff ff       	call   801016c1 <iunlockput>
    goto bad;
80104c57:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80104c5a:	83 ec 0c             	sub    $0xc,%esp
80104c5d:	56                   	push   %esi
80104c5e:	e8 5e ca ff ff       	call   801016c1 <iunlockput>
  end_op();
80104c63:	e8 08 db ff ff       	call   80102770 <end_op>
  return -1;
80104c68:	83 c4 10             	add    $0x10,%esp
80104c6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c70:	eb ac                	jmp    80104c1e <sys_unlink+0x123>
    panic("unlink: writei");
80104c72:	83 ec 0c             	sub    $0xc,%esp
80104c75:	68 72 77 10 80       	push   $0x80107772
80104c7a:	e8 c2 b6 ff ff       	call   80100341 <panic>
    dp->nlink--;
80104c7f:	66 8b 46 56          	mov    0x56(%esi),%ax
80104c83:	48                   	dec    %eax
80104c84:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104c88:	83 ec 0c             	sub    $0xc,%esp
80104c8b:	56                   	push   %esi
80104c8c:	e8 34 c7 ff ff       	call   801013c5 <iupdate>
80104c91:	83 c4 10             	add    $0x10,%esp
80104c94:	e9 56 ff ff ff       	jmp    80104bef <sys_unlink+0xf4>
    return -1;
80104c99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c9e:	e9 7b ff ff ff       	jmp    80104c1e <sys_unlink+0x123>

80104ca3 <sys_open>:

int
sys_open(void)
{
80104ca3:	55                   	push   %ebp
80104ca4:	89 e5                	mov    %esp,%ebp
80104ca6:	57                   	push   %edi
80104ca7:	56                   	push   %esi
80104ca8:	53                   	push   %ebx
80104ca9:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104cac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104caf:	50                   	push   %eax
80104cb0:	6a 00                	push   $0x0
80104cb2:	e8 0b f7 ff ff       	call   801043c2 <argstr>
80104cb7:	83 c4 10             	add    $0x10,%esp
80104cba:	85 c0                	test   %eax,%eax
80104cbc:	0f 88 a0 00 00 00    	js     80104d62 <sys_open+0xbf>
80104cc2:	83 ec 08             	sub    $0x8,%esp
80104cc5:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104cc8:	50                   	push   %eax
80104cc9:	6a 01                	push   $0x1
80104ccb:	e8 61 f6 ff ff       	call   80104331 <argint>
80104cd0:	83 c4 10             	add    $0x10,%esp
80104cd3:	85 c0                	test   %eax,%eax
80104cd5:	0f 88 87 00 00 00    	js     80104d62 <sys_open+0xbf>
    return -1;

  begin_op();
80104cdb:	e8 14 da ff ff       	call   801026f4 <begin_op>

  if(omode & O_CREATE){
80104ce0:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104ce4:	0f 84 8b 00 00 00    	je     80104d75 <sys_open+0xd2>
    ip = create(path, T_FILE, 0, 0);
80104cea:	83 ec 0c             	sub    $0xc,%esp
80104ced:	6a 00                	push   $0x0
80104cef:	b9 00 00 00 00       	mov    $0x0,%ecx
80104cf4:	ba 02 00 00 00       	mov    $0x2,%edx
80104cf9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104cfc:	e8 36 f8 ff ff       	call   80104537 <create>
80104d01:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104d03:	83 c4 10             	add    $0x10,%esp
80104d06:	85 c0                	test   %eax,%eax
80104d08:	74 5f                	je     80104d69 <sys_open+0xc6>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80104d0a:	e8 ef be ff ff       	call   80100bfe <filealloc>
80104d0f:	89 c3                	mov    %eax,%ebx
80104d11:	85 c0                	test   %eax,%eax
80104d13:	0f 84 b5 00 00 00    	je     80104dce <sys_open+0x12b>
80104d19:	e8 8e f7 ff ff       	call   801044ac <fdalloc>
80104d1e:	89 c7                	mov    %eax,%edi
80104d20:	85 c0                	test   %eax,%eax
80104d22:	0f 88 a6 00 00 00    	js     80104dce <sys_open+0x12b>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104d28:	83 ec 0c             	sub    $0xc,%esp
80104d2b:	56                   	push   %esi
80104d2c:	e8 ad c8 ff ff       	call   801015de <iunlock>
  end_op();
80104d31:	e8 3a da ff ff       	call   80102770 <end_op>

  f->type = FD_INODE;
80104d36:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104d3c:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104d3f:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104d46:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d49:	83 c4 10             	add    $0x10,%esp
80104d4c:	a8 01                	test   $0x1,%al
80104d4e:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104d52:	a8 03                	test   $0x3,%al
80104d54:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104d58:	89 f8                	mov    %edi,%eax
80104d5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104d5d:	5b                   	pop    %ebx
80104d5e:	5e                   	pop    %esi
80104d5f:	5f                   	pop    %edi
80104d60:	5d                   	pop    %ebp
80104d61:	c3                   	ret    
    return -1;
80104d62:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104d67:	eb ef                	jmp    80104d58 <sys_open+0xb5>
      end_op();
80104d69:	e8 02 da ff ff       	call   80102770 <end_op>
      return -1;
80104d6e:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104d73:	eb e3                	jmp    80104d58 <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104d75:	83 ec 0c             	sub    $0xc,%esp
80104d78:	ff 75 e4             	push   -0x1c(%ebp)
80104d7b:	e8 02 ce ff ff       	call   80101b82 <namei>
80104d80:	89 c6                	mov    %eax,%esi
80104d82:	83 c4 10             	add    $0x10,%esp
80104d85:	85 c0                	test   %eax,%eax
80104d87:	74 39                	je     80104dc2 <sys_open+0x11f>
    ilock(ip);
80104d89:	83 ec 0c             	sub    $0xc,%esp
80104d8c:	50                   	push   %eax
80104d8d:	e8 8c c7 ff ff       	call   8010151e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104d92:	83 c4 10             	add    $0x10,%esp
80104d95:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104d9a:	0f 85 6a ff ff ff    	jne    80104d0a <sys_open+0x67>
80104da0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104da4:	0f 84 60 ff ff ff    	je     80104d0a <sys_open+0x67>
      iunlockput(ip);
80104daa:	83 ec 0c             	sub    $0xc,%esp
80104dad:	56                   	push   %esi
80104dae:	e8 0e c9 ff ff       	call   801016c1 <iunlockput>
      end_op();
80104db3:	e8 b8 d9 ff ff       	call   80102770 <end_op>
      return -1;
80104db8:	83 c4 10             	add    $0x10,%esp
80104dbb:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104dc0:	eb 96                	jmp    80104d58 <sys_open+0xb5>
      end_op();
80104dc2:	e8 a9 d9 ff ff       	call   80102770 <end_op>
      return -1;
80104dc7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104dcc:	eb 8a                	jmp    80104d58 <sys_open+0xb5>
    if(f)
80104dce:	85 db                	test   %ebx,%ebx
80104dd0:	74 0c                	je     80104dde <sys_open+0x13b>
      fileclose(f);
80104dd2:	83 ec 0c             	sub    $0xc,%esp
80104dd5:	53                   	push   %ebx
80104dd6:	e8 c7 be ff ff       	call   80100ca2 <fileclose>
80104ddb:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80104dde:	83 ec 0c             	sub    $0xc,%esp
80104de1:	56                   	push   %esi
80104de2:	e8 da c8 ff ff       	call   801016c1 <iunlockput>
    end_op();
80104de7:	e8 84 d9 ff ff       	call   80102770 <end_op>
    return -1;
80104dec:	83 c4 10             	add    $0x10,%esp
80104def:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104df4:	e9 5f ff ff ff       	jmp    80104d58 <sys_open+0xb5>

80104df9 <sys_mkdir>:

int
sys_mkdir(void)
{
80104df9:	55                   	push   %ebp
80104dfa:	89 e5                	mov    %esp,%ebp
80104dfc:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104dff:	e8 f0 d8 ff ff       	call   801026f4 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104e04:	83 ec 08             	sub    $0x8,%esp
80104e07:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e0a:	50                   	push   %eax
80104e0b:	6a 00                	push   $0x0
80104e0d:	e8 b0 f5 ff ff       	call   801043c2 <argstr>
80104e12:	83 c4 10             	add    $0x10,%esp
80104e15:	85 c0                	test   %eax,%eax
80104e17:	78 36                	js     80104e4f <sys_mkdir+0x56>
80104e19:	83 ec 0c             	sub    $0xc,%esp
80104e1c:	6a 00                	push   $0x0
80104e1e:	b9 00 00 00 00       	mov    $0x0,%ecx
80104e23:	ba 01 00 00 00       	mov    $0x1,%edx
80104e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e2b:	e8 07 f7 ff ff       	call   80104537 <create>
80104e30:	83 c4 10             	add    $0x10,%esp
80104e33:	85 c0                	test   %eax,%eax
80104e35:	74 18                	je     80104e4f <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104e37:	83 ec 0c             	sub    $0xc,%esp
80104e3a:	50                   	push   %eax
80104e3b:	e8 81 c8 ff ff       	call   801016c1 <iunlockput>
  end_op();
80104e40:	e8 2b d9 ff ff       	call   80102770 <end_op>
  return 0;
80104e45:	83 c4 10             	add    $0x10,%esp
80104e48:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e4d:	c9                   	leave  
80104e4e:	c3                   	ret    
    end_op();
80104e4f:	e8 1c d9 ff ff       	call   80102770 <end_op>
    return -1;
80104e54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e59:	eb f2                	jmp    80104e4d <sys_mkdir+0x54>

80104e5b <sys_mknod>:

int
sys_mknod(void)
{
80104e5b:	55                   	push   %ebp
80104e5c:	89 e5                	mov    %esp,%ebp
80104e5e:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104e61:	e8 8e d8 ff ff       	call   801026f4 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104e66:	83 ec 08             	sub    $0x8,%esp
80104e69:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e6c:	50                   	push   %eax
80104e6d:	6a 00                	push   $0x0
80104e6f:	e8 4e f5 ff ff       	call   801043c2 <argstr>
80104e74:	83 c4 10             	add    $0x10,%esp
80104e77:	85 c0                	test   %eax,%eax
80104e79:	78 62                	js     80104edd <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104e7b:	83 ec 08             	sub    $0x8,%esp
80104e7e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e81:	50                   	push   %eax
80104e82:	6a 01                	push   $0x1
80104e84:	e8 a8 f4 ff ff       	call   80104331 <argint>
  if((argstr(0, &path)) < 0 ||
80104e89:	83 c4 10             	add    $0x10,%esp
80104e8c:	85 c0                	test   %eax,%eax
80104e8e:	78 4d                	js     80104edd <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104e90:	83 ec 08             	sub    $0x8,%esp
80104e93:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104e96:	50                   	push   %eax
80104e97:	6a 02                	push   $0x2
80104e99:	e8 93 f4 ff ff       	call   80104331 <argint>
     argint(1, &major) < 0 ||
80104e9e:	83 c4 10             	add    $0x10,%esp
80104ea1:	85 c0                	test   %eax,%eax
80104ea3:	78 38                	js     80104edd <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104ea5:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80104ea9:	83 ec 0c             	sub    $0xc,%esp
80104eac:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104eb0:	50                   	push   %eax
80104eb1:	ba 03 00 00 00       	mov    $0x3,%edx
80104eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb9:	e8 79 f6 ff ff       	call   80104537 <create>
     argint(2, &minor) < 0 ||
80104ebe:	83 c4 10             	add    $0x10,%esp
80104ec1:	85 c0                	test   %eax,%eax
80104ec3:	74 18                	je     80104edd <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104ec5:	83 ec 0c             	sub    $0xc,%esp
80104ec8:	50                   	push   %eax
80104ec9:	e8 f3 c7 ff ff       	call   801016c1 <iunlockput>
  end_op();
80104ece:	e8 9d d8 ff ff       	call   80102770 <end_op>
  return 0;
80104ed3:	83 c4 10             	add    $0x10,%esp
80104ed6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104edb:	c9                   	leave  
80104edc:	c3                   	ret    
    end_op();
80104edd:	e8 8e d8 ff ff       	call   80102770 <end_op>
    return -1;
80104ee2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ee7:	eb f2                	jmp    80104edb <sys_mknod+0x80>

80104ee9 <sys_chdir>:

int
sys_chdir(void)
{
80104ee9:	55                   	push   %ebp
80104eea:	89 e5                	mov    %esp,%ebp
80104eec:	56                   	push   %esi
80104eed:	53                   	push   %ebx
80104eee:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104ef1:	e8 49 e3 ff ff       	call   8010323f <myproc>
80104ef6:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104ef8:	e8 f7 d7 ff ff       	call   801026f4 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104efd:	83 ec 08             	sub    $0x8,%esp
80104f00:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f03:	50                   	push   %eax
80104f04:	6a 00                	push   $0x0
80104f06:	e8 b7 f4 ff ff       	call   801043c2 <argstr>
80104f0b:	83 c4 10             	add    $0x10,%esp
80104f0e:	85 c0                	test   %eax,%eax
80104f10:	78 52                	js     80104f64 <sys_chdir+0x7b>
80104f12:	83 ec 0c             	sub    $0xc,%esp
80104f15:	ff 75 f4             	push   -0xc(%ebp)
80104f18:	e8 65 cc ff ff       	call   80101b82 <namei>
80104f1d:	89 c3                	mov    %eax,%ebx
80104f1f:	83 c4 10             	add    $0x10,%esp
80104f22:	85 c0                	test   %eax,%eax
80104f24:	74 3e                	je     80104f64 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104f26:	83 ec 0c             	sub    $0xc,%esp
80104f29:	50                   	push   %eax
80104f2a:	e8 ef c5 ff ff       	call   8010151e <ilock>
  if(ip->type != T_DIR){
80104f2f:	83 c4 10             	add    $0x10,%esp
80104f32:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104f37:	75 37                	jne    80104f70 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104f39:	83 ec 0c             	sub    $0xc,%esp
80104f3c:	53                   	push   %ebx
80104f3d:	e8 9c c6 ff ff       	call   801015de <iunlock>
  iput(curproc->cwd);
80104f42:	83 c4 04             	add    $0x4,%esp
80104f45:	ff 76 74             	push   0x74(%esi)
80104f48:	e8 d6 c6 ff ff       	call   80101623 <iput>
  end_op();
80104f4d:	e8 1e d8 ff ff       	call   80102770 <end_op>
  curproc->cwd = ip;
80104f52:	89 5e 74             	mov    %ebx,0x74(%esi)
  return 0;
80104f55:	83 c4 10             	add    $0x10,%esp
80104f58:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104f60:	5b                   	pop    %ebx
80104f61:	5e                   	pop    %esi
80104f62:	5d                   	pop    %ebp
80104f63:	c3                   	ret    
    end_op();
80104f64:	e8 07 d8 ff ff       	call   80102770 <end_op>
    return -1;
80104f69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f6e:	eb ed                	jmp    80104f5d <sys_chdir+0x74>
    iunlockput(ip);
80104f70:	83 ec 0c             	sub    $0xc,%esp
80104f73:	53                   	push   %ebx
80104f74:	e8 48 c7 ff ff       	call   801016c1 <iunlockput>
    end_op();
80104f79:	e8 f2 d7 ff ff       	call   80102770 <end_op>
    return -1;
80104f7e:	83 c4 10             	add    $0x10,%esp
80104f81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f86:	eb d5                	jmp    80104f5d <sys_chdir+0x74>

80104f88 <sys_exec>:

int
sys_exec(void)
{
80104f88:	55                   	push   %ebp
80104f89:	89 e5                	mov    %esp,%ebp
80104f8b:	53                   	push   %ebx
80104f8c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104f92:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f95:	50                   	push   %eax
80104f96:	6a 00                	push   $0x0
80104f98:	e8 25 f4 ff ff       	call   801043c2 <argstr>
80104f9d:	83 c4 10             	add    $0x10,%esp
80104fa0:	85 c0                	test   %eax,%eax
80104fa2:	78 38                	js     80104fdc <sys_exec+0x54>
80104fa4:	83 ec 08             	sub    $0x8,%esp
80104fa7:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104fad:	50                   	push   %eax
80104fae:	6a 01                	push   $0x1
80104fb0:	e8 7c f3 ff ff       	call   80104331 <argint>
80104fb5:	83 c4 10             	add    $0x10,%esp
80104fb8:	85 c0                	test   %eax,%eax
80104fba:	78 20                	js     80104fdc <sys_exec+0x54>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104fbc:	83 ec 04             	sub    $0x4,%esp
80104fbf:	68 80 00 00 00       	push   $0x80
80104fc4:	6a 00                	push   $0x0
80104fc6:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104fcc:	50                   	push   %eax
80104fcd:	e8 29 f1 ff ff       	call   801040fb <memset>
80104fd2:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104fd5:	bb 00 00 00 00       	mov    $0x0,%ebx
80104fda:	eb 2a                	jmp    80105006 <sys_exec+0x7e>
    return -1;
80104fdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fe1:	eb 76                	jmp    80105059 <sys_exec+0xd1>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
80104fe3:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104fea:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80104fee:	83 ec 08             	sub    $0x8,%esp
80104ff1:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104ff7:	50                   	push   %eax
80104ff8:	ff 75 f4             	push   -0xc(%ebp)
80104ffb:	e8 90 b8 ff ff       	call   80100890 <exec>
80105000:	83 c4 10             	add    $0x10,%esp
80105003:	eb 54                	jmp    80105059 <sys_exec+0xd1>
  for(i=0;; i++){
80105005:	43                   	inc    %ebx
    if(i >= NELEM(argv))
80105006:	83 fb 1f             	cmp    $0x1f,%ebx
80105009:	77 49                	ja     80105054 <sys_exec+0xcc>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010500b:	83 ec 08             	sub    $0x8,%esp
8010500e:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105014:	50                   	push   %eax
80105015:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
8010501b:	8d 04 98             	lea    (%eax,%ebx,4),%eax
8010501e:	50                   	push   %eax
8010501f:	e8 92 f2 ff ff       	call   801042b6 <fetchint>
80105024:	83 c4 10             	add    $0x10,%esp
80105027:	85 c0                	test   %eax,%eax
80105029:	78 33                	js     8010505e <sys_exec+0xd6>
    if(uarg == 0){
8010502b:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105031:	85 c0                	test   %eax,%eax
80105033:	74 ae                	je     80104fe3 <sys_exec+0x5b>
    if(fetchstr(uarg, &argv[i]) < 0)
80105035:	83 ec 08             	sub    $0x8,%esp
80105038:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
8010503f:	52                   	push   %edx
80105040:	50                   	push   %eax
80105041:	e8 ac f2 ff ff       	call   801042f2 <fetchstr>
80105046:	83 c4 10             	add    $0x10,%esp
80105049:	85 c0                	test   %eax,%eax
8010504b:	79 b8                	jns    80105005 <sys_exec+0x7d>
      return -1;
8010504d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105052:	eb 05                	jmp    80105059 <sys_exec+0xd1>
      return -1;
80105054:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105059:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010505c:	c9                   	leave  
8010505d:	c3                   	ret    
      return -1;
8010505e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105063:	eb f4                	jmp    80105059 <sys_exec+0xd1>

80105065 <sys_pipe>:

int
sys_pipe(void)
{
80105065:	55                   	push   %ebp
80105066:	89 e5                	mov    %esp,%ebp
80105068:	53                   	push   %ebx
80105069:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010506c:	6a 08                	push   $0x8
8010506e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105071:	50                   	push   %eax
80105072:	6a 00                	push   $0x0
80105074:	e8 e0 f2 ff ff       	call   80104359 <argptr>
80105079:	83 c4 10             	add    $0x10,%esp
8010507c:	85 c0                	test   %eax,%eax
8010507e:	78 79                	js     801050f9 <sys_pipe+0x94>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80105080:	83 ec 08             	sub    $0x8,%esp
80105083:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105086:	50                   	push   %eax
80105087:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010508a:	50                   	push   %eax
8010508b:	e8 db db ff ff       	call   80102c6b <pipealloc>
80105090:	83 c4 10             	add    $0x10,%esp
80105093:	85 c0                	test   %eax,%eax
80105095:	78 69                	js     80105100 <sys_pipe+0x9b>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105097:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010509a:	e8 0d f4 ff ff       	call   801044ac <fdalloc>
8010509f:	89 c3                	mov    %eax,%ebx
801050a1:	85 c0                	test   %eax,%eax
801050a3:	78 21                	js     801050c6 <sys_pipe+0x61>
801050a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801050a8:	e8 ff f3 ff ff       	call   801044ac <fdalloc>
801050ad:	85 c0                	test   %eax,%eax
801050af:	78 15                	js     801050c6 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
801050b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050b4:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
801050b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050b9:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
801050bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801050c4:	c9                   	leave  
801050c5:	c3                   	ret    
    if(fd0 >= 0)
801050c6:	85 db                	test   %ebx,%ebx
801050c8:	79 20                	jns    801050ea <sys_pipe+0x85>
    fileclose(rf);
801050ca:	83 ec 0c             	sub    $0xc,%esp
801050cd:	ff 75 f0             	push   -0x10(%ebp)
801050d0:	e8 cd bb ff ff       	call   80100ca2 <fileclose>
    fileclose(wf);
801050d5:	83 c4 04             	add    $0x4,%esp
801050d8:	ff 75 ec             	push   -0x14(%ebp)
801050db:	e8 c2 bb ff ff       	call   80100ca2 <fileclose>
    return -1;
801050e0:	83 c4 10             	add    $0x10,%esp
801050e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050e8:	eb d7                	jmp    801050c1 <sys_pipe+0x5c>
      myproc()->ofile[fd0] = 0;
801050ea:	e8 50 e1 ff ff       	call   8010323f <myproc>
801050ef:	c7 44 98 34 00 00 00 	movl   $0x0,0x34(%eax,%ebx,4)
801050f6:	00 
801050f7:	eb d1                	jmp    801050ca <sys_pipe+0x65>
    return -1;
801050f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050fe:	eb c1                	jmp    801050c1 <sys_pipe+0x5c>
    return -1;
80105100:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105105:	eb ba                	jmp    801050c1 <sys_pipe+0x5c>

80105107 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105107:	55                   	push   %ebp
80105108:	89 e5                	mov    %esp,%ebp
8010510a:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010510d:	e8 a3 e2 ff ff       	call   801033b5 <fork>
}
80105112:	c9                   	leave  
80105113:	c3                   	ret    

80105114 <sys_exit>:
	Implementación del código de llamada al sistema para cuando un usuario
	realiza un exit(status)
*/
int
sys_exit(void)
{
80105114:	55                   	push   %ebp
80105115:	89 e5                	mov    %esp,%ebp
80105117:	83 ec 20             	sub    $0x20,%esp
	//Para esta nueva implementación, vamos a recuperar el status
	//que puso el usuario como argumento y lo guardamos 
  int status; 

	//Puesto que es un valor entero, lo recuperamos de la pila (posición 0) con argint
  if(argint(0,&status) < 0)
8010511a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010511d:	50                   	push   %eax
8010511e:	6a 00                	push   $0x0
80105120:	e8 0c f2 ff ff       	call   80104331 <argint>
80105125:	83 c4 10             	add    $0x10,%esp
80105128:	85 c0                	test   %eax,%eax
8010512a:	78 1c                	js     80105148 <sys_exit+0x34>
    return -1;

	//Desplazamos los  bits 8 posiciones a la izquierda
	status = status << 8;
8010512c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010512f:	c1 e0 08             	shl    $0x8,%eax
80105132:	89 45 f4             	mov    %eax,-0xc(%ebp)

  exit(status);//Llamamos a la función de salida del kernel
80105135:	83 ec 0c             	sub    $0xc,%esp
80105138:	50                   	push   %eax
80105139:	e8 4e e7 ff ff       	call   8010388c <exit>
  return 0;  // not reached
8010513e:	83 c4 10             	add    $0x10,%esp
80105141:	b8 00 00 00 00       	mov    $0x0,%eax

}
80105146:	c9                   	leave  
80105147:	c3                   	ret    
    return -1;
80105148:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010514d:	eb f7                	jmp    80105146 <sys_exit+0x32>

8010514f <sys_wait>:
/*
	Implementación de la función wait(status) para un usuario
*/
int
sys_wait(void)
{
8010514f:	55                   	push   %ebp
80105150:	89 e5                	mov    %esp,%ebp
80105152:	83 ec 1c             	sub    $0x1c,%esp
	*/
  int *status;
  int size = 4;//Tamaño de un entero
    
  //Recuperamos el valor con argptr puesto que no es un entero, sino un puntero a entero
	if(argptr(0,(void**) &status, size) < 0)
80105155:	6a 04                	push   $0x4
80105157:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010515a:	50                   	push   %eax
8010515b:	6a 00                	push   $0x0
8010515d:	e8 f7 f1 ff ff       	call   80104359 <argptr>
80105162:	83 c4 10             	add    $0x10,%esp
80105165:	85 c0                	test   %eax,%eax
80105167:	78 10                	js     80105179 <sys_wait+0x2a>
    return -1;
  
	//Por último, llamamos a la función wait del kernel
  return wait(status);
80105169:	83 ec 0c             	sub    $0xc,%esp
8010516c:	ff 75 f4             	push   -0xc(%ebp)
8010516f:	e8 c7 e9 ff ff       	call   80103b3b <wait>
80105174:	83 c4 10             	add    $0x10,%esp
}
80105177:	c9                   	leave  
80105178:	c3                   	ret    
    return -1;
80105179:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010517e:	eb f7                	jmp    80105177 <sys_wait+0x28>

80105180 <sys_kill>:

int
sys_kill(void)
{
80105180:	55                   	push   %ebp
80105181:	89 e5                	mov    %esp,%ebp
80105183:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105186:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105189:	50                   	push   %eax
8010518a:	6a 00                	push   $0x0
8010518c:	e8 a0 f1 ff ff       	call   80104331 <argint>
80105191:	83 c4 10             	add    $0x10,%esp
80105194:	85 c0                	test   %eax,%eax
80105196:	78 10                	js     801051a8 <sys_kill+0x28>
    return -1;
  return kill(pid);
80105198:	83 ec 0c             	sub    $0xc,%esp
8010519b:	ff 75 f4             	push   -0xc(%ebp)
8010519e:	e8 d9 ea ff ff       	call   80103c7c <kill>
801051a3:	83 c4 10             	add    $0x10,%esp
}
801051a6:	c9                   	leave  
801051a7:	c3                   	ret    
    return -1;
801051a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051ad:	eb f7                	jmp    801051a6 <sys_kill+0x26>

801051af <sys_getpid>:

int
sys_getpid(void)
{
801051af:	55                   	push   %ebp
801051b0:	89 e5                	mov    %esp,%ebp
801051b2:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801051b5:	e8 85 e0 ff ff       	call   8010323f <myproc>
801051ba:	8b 40 18             	mov    0x18(%eax),%eax
}
801051bd:	c9                   	leave  
801051be:	c3                   	ret    

801051bf <sys_sbrk>:

int
sys_sbrk(void)
{
801051bf:	55                   	push   %ebp
801051c0:	89 e5                	mov    %esp,%ebp
801051c2:	56                   	push   %esi
801051c3:	53                   	push   %ebx
801051c4:	83 ec 10             	sub    $0x10,%esp
	//La dirección que devolvemos siempre será la del tamaño 
	//actual del proceso, que es por donde está el heap 
	//actualmente (dirección de comienzo de la memoria libre)
  int n;//Valor que quiere reservar el usuario
	uint oldsz = myproc()->sz;
801051c7:	e8 73 e0 ff ff       	call   8010323f <myproc>
801051cc:	8b 58 08             	mov    0x8(%eax),%ebx
	uint newsz = oldsz;

	//Recuperamos el valor de n de la pila de usuario
  if(argint(0, &n) < 0)
801051cf:	83 ec 08             	sub    $0x8,%esp
801051d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801051d5:	50                   	push   %eax
801051d6:	6a 00                	push   $0x0
801051d8:	e8 54 f1 ff ff       	call   80104331 <argint>
801051dd:	83 c4 10             	add    $0x10,%esp
801051e0:	85 c0                	test   %eax,%eax
801051e2:	78 55                	js     80105239 <sys_sbrk+0x7a>
    return -1;

	//Hacemos comprobación para que solo reserve hasta el KERNBASE
	if(oldsz + n > KERNBASE)
801051e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051e7:	8d 34 18             	lea    (%eax,%ebx,1),%esi
801051ea:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
801051f0:	77 4e                	ja     80105240 <sys_sbrk+0x81>
		return -1;
	
	//Actualizamos el nuevo tamaño del proceso
	newsz = oldsz + n;
	
	if(n < 0)
801051f2:	85 c0                	test   %eax,%eax
801051f4:	78 21                	js     80105217 <sys_sbrk+0x58>
	{//Desalojamos las páginas físicas ocupadas hasta ahora
		if((newsz = deallocuvm(myproc()->pgdir, oldsz, newsz)) == 0)
      return -1;
	}

  lcr3(V2P(myproc()->pgdir));  // Invalidate TLB. Cambia la tabla de páginas		
801051f6:	e8 44 e0 ff ff       	call   8010323f <myproc>
801051fb:	8b 40 0c             	mov    0xc(%eax),%eax
801051fe:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105203:	0f 22 d8             	mov    %eax,%cr3

	//Ahora actualizamos el tamaño del proceso
	myproc()->sz = newsz;
80105206:	e8 34 e0 ff ff       	call   8010323f <myproc>
8010520b:	89 70 08             	mov    %esi,0x8(%eax)
  
  return oldsz;
8010520e:	89 d8                	mov    %ebx,%eax
}
80105210:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105213:	5b                   	pop    %ebx
80105214:	5e                   	pop    %esi
80105215:	5d                   	pop    %ebp
80105216:	c3                   	ret    
		if((newsz = deallocuvm(myproc()->pgdir, oldsz, newsz)) == 0)
80105217:	e8 23 e0 ff ff       	call   8010323f <myproc>
8010521c:	83 ec 04             	sub    $0x4,%esp
8010521f:	56                   	push   %esi
80105220:	53                   	push   %ebx
80105221:	ff 70 0c             	push   0xc(%eax)
80105224:	e8 b2 17 00 00       	call   801069db <deallocuvm>
80105229:	89 c6                	mov    %eax,%esi
8010522b:	83 c4 10             	add    $0x10,%esp
8010522e:	85 c0                	test   %eax,%eax
80105230:	75 c4                	jne    801051f6 <sys_sbrk+0x37>
      return -1;
80105232:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105237:	eb d7                	jmp    80105210 <sys_sbrk+0x51>
    return -1;
80105239:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010523e:	eb d0                	jmp    80105210 <sys_sbrk+0x51>
		return -1;
80105240:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105245:	eb c9                	jmp    80105210 <sys_sbrk+0x51>

80105247 <sys_sleep>:

int
sys_sleep(void)
{
80105247:	55                   	push   %ebp
80105248:	89 e5                	mov    %esp,%ebp
8010524a:	53                   	push   %ebx
8010524b:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010524e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105251:	50                   	push   %eax
80105252:	6a 00                	push   $0x0
80105254:	e8 d8 f0 ff ff       	call   80104331 <argint>
80105259:	83 c4 10             	add    $0x10,%esp
8010525c:	85 c0                	test   %eax,%eax
8010525e:	78 75                	js     801052d5 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80105260:	83 ec 0c             	sub    $0xc,%esp
80105263:	68 80 3f 11 80       	push   $0x80113f80
80105268:	e8 e2 ed ff ff       	call   8010404f <acquire>
  ticks0 = ticks;
8010526d:	8b 1d 60 3f 11 80    	mov    0x80113f60,%ebx
  while(ticks - ticks0 < n){
80105273:	83 c4 10             	add    $0x10,%esp
80105276:	a1 60 3f 11 80       	mov    0x80113f60,%eax
8010527b:	29 d8                	sub    %ebx,%eax
8010527d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105280:	73 39                	jae    801052bb <sys_sleep+0x74>
    if(myproc()->killed){
80105282:	e8 b8 df ff ff       	call   8010323f <myproc>
80105287:	83 78 30 00          	cmpl   $0x0,0x30(%eax)
8010528b:	75 17                	jne    801052a4 <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
8010528d:	83 ec 08             	sub    $0x8,%esp
80105290:	68 80 3f 11 80       	push   $0x80113f80
80105295:	68 60 3f 11 80       	push   $0x80113f60
8010529a:	e8 0b e8 ff ff       	call   80103aaa <sleep>
8010529f:	83 c4 10             	add    $0x10,%esp
801052a2:	eb d2                	jmp    80105276 <sys_sleep+0x2f>
      release(&tickslock);
801052a4:	83 ec 0c             	sub    $0xc,%esp
801052a7:	68 80 3f 11 80       	push   $0x80113f80
801052ac:	e8 03 ee ff ff       	call   801040b4 <release>
      return -1;
801052b1:	83 c4 10             	add    $0x10,%esp
801052b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052b9:	eb 15                	jmp    801052d0 <sys_sleep+0x89>
  }
  release(&tickslock);
801052bb:	83 ec 0c             	sub    $0xc,%esp
801052be:	68 80 3f 11 80       	push   $0x80113f80
801052c3:	e8 ec ed ff ff       	call   801040b4 <release>
  return 0;
801052c8:	83 c4 10             	add    $0x10,%esp
801052cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801052d3:	c9                   	leave  
801052d4:	c3                   	ret    
    return -1;
801052d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052da:	eb f4                	jmp    801052d0 <sys_sleep+0x89>

801052dc <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801052dc:	55                   	push   %ebp
801052dd:	89 e5                	mov    %esp,%ebp
801052df:	53                   	push   %ebx
801052e0:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
801052e3:	68 80 3f 11 80       	push   $0x80113f80
801052e8:	e8 62 ed ff ff       	call   8010404f <acquire>
  xticks = ticks;
801052ed:	8b 1d 60 3f 11 80    	mov    0x80113f60,%ebx
  release(&tickslock);
801052f3:	c7 04 24 80 3f 11 80 	movl   $0x80113f80,(%esp)
801052fa:	e8 b5 ed ff ff       	call   801040b4 <release>
  return xticks;
}
801052ff:	89 d8                	mov    %ebx,%eax
80105301:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105304:	c9                   	leave  
80105305:	c3                   	ret    

80105306 <sys_date>:

//Implementación de llamada al sistema date para sacar la fecha actual por pantalla
//Devuelve 0 en caso de acabar correctamente y -1 en caso de fallo
int
sys_date(void)
{
80105306:	55                   	push   %ebp
80105307:	89 e5                	mov    %esp,%ebp
80105309:	83 ec 1c             	sub    $0x1c,%esp
	//date tiene que recuperar el rtcdate de la pila del usuario
 	struct rtcdate *d;//Aquí vamos a guardar el argumento del usuario

 	//vamos a usar argptr para recuperar el rtcdate
 	if(argptr(0, (void **) &d, sizeof(struct rtcdate)) < 0){
8010530c:	6a 18                	push   $0x18
8010530e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105311:	50                   	push   %eax
80105312:	6a 00                	push   $0x0
80105314:	e8 40 f0 ff ff       	call   80104359 <argptr>
80105319:	83 c4 10             	add    $0x10,%esp
8010531c:	85 c0                	test   %eax,%eax
8010531e:	78 15                	js     80105335 <sys_date+0x2f>
  	return -1;
 	}
 	//Ahora una vez recuperado el rtcdate solo tenemos que rellenarlo con los valores oportunos
	//Para ello usamos cmostime, que rellena los valores del rtcdate con la fecha actual 
 cmostime(d);
80105320:	83 ec 0c             	sub    $0xc,%esp
80105323:	ff 75 f4             	push   -0xc(%ebp)
80105326:	e8 9b d0 ff ff       	call   801023c6 <cmostime>

 return 0;
8010532b:	83 c4 10             	add    $0x10,%esp
8010532e:	b8 00 00 00 00       	mov    $0x0,%eax

}
80105333:	c9                   	leave  
80105334:	c3                   	ret    
  	return -1;
80105335:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010533a:	eb f7                	jmp    80105333 <sys_date+0x2d>

8010533c <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010533c:	1e                   	push   %ds
  pushl %es
8010533d:	06                   	push   %es
  pushl %fs
8010533e:	0f a0                	push   %fs
  pushl %gs
80105340:	0f a8                	push   %gs
  pushal
80105342:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105343:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105347:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105349:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010534b:	54                   	push   %esp
  call trap
8010534c:	e8 2f 01 00 00       	call   80105480 <trap>
  addl $4, %esp
80105351:	83 c4 04             	add    $0x4,%esp

80105354 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105354:	61                   	popa   
  popl %gs
80105355:	0f a9                	pop    %gs
  popl %fs
80105357:	0f a1                	pop    %fs
  popl %es
80105359:	07                   	pop    %es
  popl %ds
8010535a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010535b:	83 c4 08             	add    $0x8,%esp
  iret
8010535e:	cf                   	iret   

8010535f <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010535f:	55                   	push   %ebp
80105360:	89 e5                	mov    %esp,%ebp
80105362:	53                   	push   %ebx
80105363:	83 ec 04             	sub    $0x4,%esp
  int i;

  for(i = 0; i < 256; i++)
80105366:	b8 00 00 00 00       	mov    $0x0,%eax
8010536b:	eb 72                	jmp    801053df <tvinit+0x80>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010536d:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80105374:	66 89 0c c5 c0 3f 11 	mov    %cx,-0x7feec040(,%eax,8)
8010537b:	80 
8010537c:	66 c7 04 c5 c2 3f 11 	movw   $0x8,-0x7feec03e(,%eax,8)
80105383:	80 08 00 
80105386:	8a 14 c5 c4 3f 11 80 	mov    -0x7feec03c(,%eax,8),%dl
8010538d:	83 e2 e0             	and    $0xffffffe0,%edx
80105390:	88 14 c5 c4 3f 11 80 	mov    %dl,-0x7feec03c(,%eax,8)
80105397:	c6 04 c5 c4 3f 11 80 	movb   $0x0,-0x7feec03c(,%eax,8)
8010539e:	00 
8010539f:	8a 14 c5 c5 3f 11 80 	mov    -0x7feec03b(,%eax,8),%dl
801053a6:	83 e2 f0             	and    $0xfffffff0,%edx
801053a9:	83 ca 0e             	or     $0xe,%edx
801053ac:	88 14 c5 c5 3f 11 80 	mov    %dl,-0x7feec03b(,%eax,8)
801053b3:	88 d3                	mov    %dl,%bl
801053b5:	83 e3 ef             	and    $0xffffffef,%ebx
801053b8:	88 1c c5 c5 3f 11 80 	mov    %bl,-0x7feec03b(,%eax,8)
801053bf:	83 e2 8f             	and    $0xffffff8f,%edx
801053c2:	88 14 c5 c5 3f 11 80 	mov    %dl,-0x7feec03b(,%eax,8)
801053c9:	83 ca 80             	or     $0xffffff80,%edx
801053cc:	88 14 c5 c5 3f 11 80 	mov    %dl,-0x7feec03b(,%eax,8)
801053d3:	c1 e9 10             	shr    $0x10,%ecx
801053d6:	66 89 0c c5 c6 3f 11 	mov    %cx,-0x7feec03a(,%eax,8)
801053dd:	80 
  for(i = 0; i < 256; i++)
801053de:	40                   	inc    %eax
801053df:	3d ff 00 00 00       	cmp    $0xff,%eax
801053e4:	7e 87                	jle    8010536d <tvinit+0xe>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801053e6:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
801053ec:	66 89 15 c0 41 11 80 	mov    %dx,0x801141c0
801053f3:	66 c7 05 c2 41 11 80 	movw   $0x8,0x801141c2
801053fa:	08 00 
801053fc:	a0 c4 41 11 80       	mov    0x801141c4,%al
80105401:	83 e0 e0             	and    $0xffffffe0,%eax
80105404:	a2 c4 41 11 80       	mov    %al,0x801141c4
80105409:	c6 05 c4 41 11 80 00 	movb   $0x0,0x801141c4
80105410:	a0 c5 41 11 80       	mov    0x801141c5,%al
80105415:	83 c8 0f             	or     $0xf,%eax
80105418:	a2 c5 41 11 80       	mov    %al,0x801141c5
8010541d:	83 e0 ef             	and    $0xffffffef,%eax
80105420:	a2 c5 41 11 80       	mov    %al,0x801141c5
80105425:	88 c1                	mov    %al,%cl
80105427:	83 c9 60             	or     $0x60,%ecx
8010542a:	88 0d c5 41 11 80    	mov    %cl,0x801141c5
80105430:	83 c8 e0             	or     $0xffffffe0,%eax
80105433:	a2 c5 41 11 80       	mov    %al,0x801141c5
80105438:	c1 ea 10             	shr    $0x10,%edx
8010543b:	66 89 15 c6 41 11 80 	mov    %dx,0x801141c6

  initlock(&tickslock, "time");
80105442:	83 ec 08             	sub    $0x8,%esp
80105445:	68 81 77 10 80       	push   $0x80107781
8010544a:	68 80 3f 11 80       	push   $0x80113f80
8010544f:	e8 c4 ea ff ff       	call   80103f18 <initlock>
}
80105454:	83 c4 10             	add    $0x10,%esp
80105457:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010545a:	c9                   	leave  
8010545b:	c3                   	ret    

8010545c <idtinit>:

void
idtinit(void)
{
8010545c:	55                   	push   %ebp
8010545d:	89 e5                	mov    %esp,%ebp
8010545f:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105462:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80105468:	b8 c0 3f 11 80       	mov    $0x80113fc0,%eax
8010546d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105471:	c1 e8 10             	shr    $0x10,%eax
80105474:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105478:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010547b:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
8010547e:	c9                   	leave  
8010547f:	c3                   	ret    

80105480 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105480:	55                   	push   %ebp
80105481:	89 e5                	mov    %esp,%ebp
80105483:	57                   	push   %edi
80105484:	56                   	push   %esi
80105485:	53                   	push   %ebx
80105486:	83 ec 2c             	sub    $0x2c,%esp
80105489:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//Declaramos la variable status, que toma el valor del número de trap
	int status = tf->trapno+1;	
8010548c:	8b 43 30             	mov    0x30(%ebx),%eax
8010548f:	8d 78 01             	lea    0x1(%eax),%edi

  if(tf->trapno == T_SYSCALL){
80105492:	83 f8 40             	cmp    $0x40,%eax
80105495:	74 13                	je     801054aa <trap+0x2a>
    if(myproc()->killed)
      exit(status);
    return;
  }

  switch(tf->trapno){
80105497:	83 e8 0e             	sub    $0xe,%eax
8010549a:	83 f8 31             	cmp    $0x31,%eax
8010549d:	0f 87 96 02 00 00    	ja     80105739 <trap+0x2b9>
801054a3:	ff 24 85 ec 78 10 80 	jmp    *-0x7fef8714(,%eax,4)
    if(myproc()->killed)
801054aa:	e8 90 dd ff ff       	call   8010323f <myproc>
801054af:	83 78 30 00          	cmpl   $0x0,0x30(%eax)
801054b3:	75 2a                	jne    801054df <trap+0x5f>
    myproc()->tf = tf;
801054b5:	e8 85 dd ff ff       	call   8010323f <myproc>
801054ba:	89 58 20             	mov    %ebx,0x20(%eax)
    syscall();
801054bd:	e8 33 ef ff ff       	call   801043f5 <syscall>
    if(myproc()->killed)
801054c2:	e8 78 dd ff ff       	call   8010323f <myproc>
801054c7:	83 78 30 00          	cmpl   $0x0,0x30(%eax)
801054cb:	0f 84 8a 00 00 00    	je     8010555b <trap+0xdb>
      exit(status);
801054d1:	83 ec 0c             	sub    $0xc,%esp
801054d4:	57                   	push   %edi
801054d5:	e8 b2 e3 ff ff       	call   8010388c <exit>
801054da:	83 c4 10             	add    $0x10,%esp
    return;
801054dd:	eb 7c                	jmp    8010555b <trap+0xdb>
      exit(status);
801054df:	83 ec 0c             	sub    $0xc,%esp
801054e2:	57                   	push   %edi
801054e3:	e8 a4 e3 ff ff       	call   8010388c <exit>
801054e8:	83 c4 10             	add    $0x10,%esp
801054eb:	eb c8                	jmp    801054b5 <trap+0x35>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801054ed:	e8 1c dd ff ff       	call   8010320e <cpuid>
801054f2:	85 c0                	test   %eax,%eax
801054f4:	74 6d                	je     80105563 <trap+0xe3>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
801054f6:	e8 16 ce ff ff       	call   80102311 <lapiceoi>
  }//fin switch

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801054fb:	e8 3f dd ff ff       	call   8010323f <myproc>
80105500:	85 c0                	test   %eax,%eax
80105502:	74 1b                	je     8010551f <trap+0x9f>
80105504:	e8 36 dd ff ff       	call   8010323f <myproc>
80105509:	83 78 30 00          	cmpl   $0x0,0x30(%eax)
8010550d:	74 10                	je     8010551f <trap+0x9f>
8010550f:	8b 43 3c             	mov    0x3c(%ebx),%eax
80105512:	83 e0 03             	and    $0x3,%eax
80105515:	66 83 f8 03          	cmp    $0x3,%ax
80105519:	0f 84 b2 02 00 00    	je     801057d1 <trap+0x351>
    exit(status);

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010551f:	e8 1b dd ff ff       	call   8010323f <myproc>
80105524:	85 c0                	test   %eax,%eax
80105526:	74 0f                	je     80105537 <trap+0xb7>
80105528:	e8 12 dd ff ff       	call   8010323f <myproc>
8010552d:	83 78 14 04          	cmpl   $0x4,0x14(%eax)
80105531:	0f 84 ab 02 00 00    	je     801057e2 <trap+0x362>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105537:	e8 03 dd ff ff       	call   8010323f <myproc>
8010553c:	85 c0                	test   %eax,%eax
8010553e:	74 1b                	je     8010555b <trap+0xdb>
80105540:	e8 fa dc ff ff       	call   8010323f <myproc>
80105545:	83 78 30 00          	cmpl   $0x0,0x30(%eax)
80105549:	74 10                	je     8010555b <trap+0xdb>
8010554b:	8b 43 3c             	mov    0x3c(%ebx),%eax
8010554e:	83 e0 03             	and    $0x3,%eax
80105551:	66 83 f8 03          	cmp    $0x3,%ax
80105555:	0f 84 9b 02 00 00    	je     801057f6 <trap+0x376>
    exit(status);
}
8010555b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010555e:	5b                   	pop    %ebx
8010555f:	5e                   	pop    %esi
80105560:	5f                   	pop    %edi
80105561:	5d                   	pop    %ebp
80105562:	c3                   	ret    
      acquire(&tickslock);
80105563:	83 ec 0c             	sub    $0xc,%esp
80105566:	68 80 3f 11 80       	push   $0x80113f80
8010556b:	e8 df ea ff ff       	call   8010404f <acquire>
      ticks++;
80105570:	ff 05 60 3f 11 80    	incl   0x80113f60
      wakeup(&ticks);
80105576:	c7 04 24 60 3f 11 80 	movl   $0x80113f60,(%esp)
8010557d:	e8 d1 e6 ff ff       	call   80103c53 <wakeup>
      release(&tickslock);
80105582:	c7 04 24 80 3f 11 80 	movl   $0x80113f80,(%esp)
80105589:	e8 26 eb ff ff       	call   801040b4 <release>
8010558e:	83 c4 10             	add    $0x10,%esp
80105591:	e9 60 ff ff ff       	jmp    801054f6 <trap+0x76>
    ideintr();
80105596:	e8 5f c7 ff ff       	call   80101cfa <ideintr>
    lapiceoi();
8010559b:	e8 71 cd ff ff       	call   80102311 <lapiceoi>
    break;
801055a0:	e9 56 ff ff ff       	jmp    801054fb <trap+0x7b>
    kbdintr();
801055a5:	e8 b1 cb ff ff       	call   8010215b <kbdintr>
    lapiceoi();
801055aa:	e8 62 cd ff ff       	call   80102311 <lapiceoi>
    break;
801055af:	e9 47 ff ff ff       	jmp    801054fb <trap+0x7b>
    uartintr();
801055b4:	e8 4a 03 00 00       	call   80105903 <uartintr>
    lapiceoi();
801055b9:	e8 53 cd ff ff       	call   80102311 <lapiceoi>
    break;
801055be:	e9 38 ff ff ff       	jmp    801054fb <trap+0x7b>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801055c3:	8b 43 38             	mov    0x38(%ebx),%eax
801055c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            cpuid(), tf->cs, tf->eip);
801055c9:	8b 73 3c             	mov    0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801055cc:	e8 3d dc ff ff       	call   8010320e <cpuid>
801055d1:	ff 75 e4             	push   -0x1c(%ebp)
801055d4:	0f b7 f6             	movzwl %si,%esi
801055d7:	56                   	push   %esi
801055d8:	50                   	push   %eax
801055d9:	68 c0 77 10 80       	push   $0x801077c0
801055de:	e8 f7 af ff ff       	call   801005da <cprintf>
    lapiceoi();
801055e3:	e8 29 cd ff ff       	call   80102311 <lapiceoi>
    break;
801055e8:	83 c4 10             	add    $0x10,%esp
801055eb:	e9 0b ff ff ff       	jmp    801054fb <trap+0x7b>
  asm volatile("movl %%cr2,%0" : "=r" (val));
801055f0:	0f 20 d6             	mov    %cr2,%esi
		uint error_code =	page_fault_error(myproc()->pgdir, rcr2());
801055f3:	e8 47 dc ff ff       	call   8010323f <myproc>
801055f8:	83 ec 08             	sub    $0x8,%esp
801055fb:	56                   	push   %esi
801055fc:	ff 70 0c             	push   0xc(%eax)
801055ff:	e8 c7 10 00 00       	call   801066cb <page_fault_error>
80105604:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105607:	0f 20 d6             	mov    %cr2,%esi
		if(rcr2() > myproc()->sz){
8010560a:	e8 30 dc ff ff       	call   8010323f <myproc>
8010560f:	83 c4 10             	add    $0x10,%esp
80105612:	39 70 08             	cmp    %esi,0x8(%eax)
80105615:	73 24                	jae    8010563b <trap+0x1bb>
			cprintf("\nPage Fault1: Address out of range. Error %d\n",error_code);
80105617:	83 ec 08             	sub    $0x8,%esp
8010561a:	ff 75 e4             	push   -0x1c(%ebp)
8010561d:	68 e4 77 10 80       	push   $0x801077e4
80105622:	e8 b3 af ff ff       	call   801005da <cprintf>
			myproc()->killed = 1;
80105627:	e8 13 dc ff ff       	call   8010323f <myproc>
8010562c:	c7 40 30 01 00 00 00 	movl   $0x1,0x30(%eax)
			break;
80105633:	83 c4 10             	add    $0x10,%esp
80105636:	e9 c0 fe ff ff       	jmp    801054fb <trap+0x7b>
8010563b:	0f 20 d6             	mov    %cr2,%esi
		if(rcr2() < myproc()->stack_end){
8010563e:	e8 fc db ff ff       	call   8010323f <myproc>
80105643:	39 70 24             	cmp    %esi,0x24(%eax)
80105646:	0f 87 84 00 00 00    	ja     801056d0 <trap+0x250>
8010564c:	0f 20 d0             	mov    %cr2,%eax
		if(rcr2() >= KERNBASE){
8010564f:	85 c0                	test   %eax,%eax
80105651:	0f 88 9d 00 00 00    	js     801056f4 <trap+0x274>
		char *mem = kalloc();
80105657:	e8 e3 c9 ff ff       	call   8010203f <kalloc>
8010565c:	89 c6                	mov    %eax,%esi
    if(mem == 0)
8010565e:	85 c0                	test   %eax,%eax
80105660:	0f 84 b2 00 00 00    	je     80105718 <trap+0x298>
		memset(mem, 0, PGSIZE);
80105666:	83 ec 04             	sub    $0x4,%esp
80105669:	68 00 10 00 00       	push   $0x1000
8010566e:	6a 00                	push   $0x0
80105670:	50                   	push   %eax
80105671:	e8 85 ea ff ff       	call   801040fb <memset>
80105676:	0f 20 d0             	mov    %cr2,%eax
    if(mappages(myproc()->pgdir, (char *)PGROUNDDOWN(rcr2()), PGSIZE, V2P(mem), PTE_W | PTE_U) <0)
80105679:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010567e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105681:	e8 b9 db ff ff       	call   8010323f <myproc>
80105686:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
8010568d:	81 c6 00 00 00 80    	add    $0x80000000,%esi
80105693:	56                   	push   %esi
80105694:	68 00 10 00 00       	push   $0x1000
80105699:	ff 75 e4             	push   -0x1c(%ebp)
8010569c:	ff 70 0c             	push   0xc(%eax)
8010569f:	e8 55 10 00 00       	call   801066f9 <mappages>
801056a4:	83 c4 20             	add    $0x20,%esp
801056a7:	85 c0                	test   %eax,%eax
801056a9:	0f 89 4c fe ff ff    	jns    801054fb <trap+0x7b>
      cprintf("mappages: out of memory\n");
801056af:	83 ec 0c             	sub    $0xc,%esp
801056b2:	68 a0 77 10 80       	push   $0x801077a0
801056b7:	e8 1e af ff ff       	call   801005da <cprintf>
      myproc()->killed = 1;
801056bc:	e8 7e db ff ff       	call   8010323f <myproc>
801056c1:	c7 40 30 01 00 00 00 	movl   $0x1,0x30(%eax)
      break;
801056c8:	83 c4 10             	add    $0x10,%esp
801056cb:	e9 2b fe ff ff       	jmp    801054fb <trap+0x7b>
			cprintf("\nPage Fault2: Address out of range. Error %d\n",error_code);
801056d0:	83 ec 08             	sub    $0x8,%esp
801056d3:	ff 75 e4             	push   -0x1c(%ebp)
801056d6:	68 14 78 10 80       	push   $0x80107814
801056db:	e8 fa ae ff ff       	call   801005da <cprintf>
			myproc()->killed = 1;
801056e0:	e8 5a db ff ff       	call   8010323f <myproc>
801056e5:	c7 40 30 01 00 00 00 	movl   $0x1,0x30(%eax)
			break;
801056ec:	83 c4 10             	add    $0x10,%esp
801056ef:	e9 07 fe ff ff       	jmp    801054fb <trap+0x7b>
			cprintf("\nPage Fault3: Address out of range. Error %d\n",error_code);
801056f4:	83 ec 08             	sub    $0x8,%esp
801056f7:	ff 75 e4             	push   -0x1c(%ebp)
801056fa:	68 44 78 10 80       	push   $0x80107844
801056ff:	e8 d6 ae ff ff       	call   801005da <cprintf>
			myproc()->killed = 1;
80105704:	e8 36 db ff ff       	call   8010323f <myproc>
80105709:	c7 40 30 01 00 00 00 	movl   $0x1,0x30(%eax)
			break;
80105710:	83 c4 10             	add    $0x10,%esp
80105713:	e9 e3 fd ff ff       	jmp    801054fb <trap+0x7b>
      cprintf("kalloc didn't alloc page\n");
80105718:	83 ec 0c             	sub    $0xc,%esp
8010571b:	68 86 77 10 80       	push   $0x80107786
80105720:	e8 b5 ae ff ff       	call   801005da <cprintf>
      myproc()->killed = 1;
80105725:	e8 15 db ff ff       	call   8010323f <myproc>
8010572a:	c7 40 30 01 00 00 00 	movl   $0x1,0x30(%eax)
      break;
80105731:	83 c4 10             	add    $0x10,%esp
80105734:	e9 c2 fd ff ff       	jmp    801054fb <trap+0x7b>
    if(myproc() == 0 || (tf->cs&3) == 0){
80105739:	e8 01 db ff ff       	call   8010323f <myproc>
8010573e:	85 c0                	test   %eax,%eax
80105740:	74 64                	je     801057a6 <trap+0x326>
80105742:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105746:	74 5e                	je     801057a6 <trap+0x326>
80105748:	0f 20 d0             	mov    %cr2,%eax
8010574b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010574e:	8b 53 38             	mov    0x38(%ebx),%edx
80105751:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80105754:	e8 b5 da ff ff       	call   8010320e <cpuid>
80105759:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010575c:	8b 4b 34             	mov    0x34(%ebx),%ecx
8010575f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
80105762:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105765:	e8 d5 da ff ff       	call   8010323f <myproc>
8010576a:	8d 50 78             	lea    0x78(%eax),%edx
8010576d:	89 55 d8             	mov    %edx,-0x28(%ebp)
80105770:	e8 ca da ff ff       	call   8010323f <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105775:	ff 75 d4             	push   -0x2c(%ebp)
80105778:	ff 75 e4             	push   -0x1c(%ebp)
8010577b:	ff 75 e0             	push   -0x20(%ebp)
8010577e:	ff 75 dc             	push   -0x24(%ebp)
80105781:	56                   	push   %esi
80105782:	ff 75 d8             	push   -0x28(%ebp)
80105785:	ff 70 18             	push   0x18(%eax)
80105788:	68 a8 78 10 80       	push   $0x801078a8
8010578d:	e8 48 ae ff ff       	call   801005da <cprintf>
    myproc()->killed = 1;
80105792:	83 c4 20             	add    $0x20,%esp
80105795:	e8 a5 da ff ff       	call   8010323f <myproc>
8010579a:	c7 40 30 01 00 00 00 	movl   $0x1,0x30(%eax)
801057a1:	e9 55 fd ff ff       	jmp    801054fb <trap+0x7b>
801057a6:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801057a9:	8b 73 38             	mov    0x38(%ebx),%esi
801057ac:	e8 5d da ff ff       	call   8010320e <cpuid>
801057b1:	83 ec 0c             	sub    $0xc,%esp
801057b4:	57                   	push   %edi
801057b5:	56                   	push   %esi
801057b6:	50                   	push   %eax
801057b7:	ff 73 30             	push   0x30(%ebx)
801057ba:	68 74 78 10 80       	push   $0x80107874
801057bf:	e8 16 ae ff ff       	call   801005da <cprintf>
      panic("trap");
801057c4:	83 c4 14             	add    $0x14,%esp
801057c7:	68 b9 77 10 80       	push   $0x801077b9
801057cc:	e8 70 ab ff ff       	call   80100341 <panic>
    exit(status);
801057d1:	83 ec 0c             	sub    $0xc,%esp
801057d4:	57                   	push   %edi
801057d5:	e8 b2 e0 ff ff       	call   8010388c <exit>
801057da:	83 c4 10             	add    $0x10,%esp
801057dd:	e9 3d fd ff ff       	jmp    8010551f <trap+0x9f>
  if(myproc() && myproc()->state == RUNNING &&
801057e2:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801057e6:	0f 85 4b fd ff ff    	jne    80105537 <trap+0xb7>
    yield();
801057ec:	e8 87 e2 ff ff       	call   80103a78 <yield>
801057f1:	e9 41 fd ff ff       	jmp    80105537 <trap+0xb7>
    exit(status);
801057f6:	83 ec 0c             	sub    $0xc,%esp
801057f9:	57                   	push   %edi
801057fa:	e8 8d e0 ff ff       	call   8010388c <exit>
801057ff:	83 c4 10             	add    $0x10,%esp
80105802:	e9 54 fd ff ff       	jmp    8010555b <trap+0xdb>

80105807 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80105807:	83 3d c0 47 11 80 00 	cmpl   $0x0,0x801147c0
8010580e:	74 14                	je     80105824 <uartgetc+0x1d>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105810:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105815:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105816:	a8 01                	test   $0x1,%al
80105818:	74 10                	je     8010582a <uartgetc+0x23>
8010581a:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010581f:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105820:	0f b6 c0             	movzbl %al,%eax
80105823:	c3                   	ret    
    return -1;
80105824:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105829:	c3                   	ret    
    return -1;
8010582a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010582f:	c3                   	ret    

80105830 <uartputc>:
  if(!uart)
80105830:	83 3d c0 47 11 80 00 	cmpl   $0x0,0x801147c0
80105837:	74 39                	je     80105872 <uartputc+0x42>
{
80105839:	55                   	push   %ebp
8010583a:	89 e5                	mov    %esp,%ebp
8010583c:	53                   	push   %ebx
8010583d:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105840:	bb 00 00 00 00       	mov    $0x0,%ebx
80105845:	eb 0e                	jmp    80105855 <uartputc+0x25>
    microdelay(10);
80105847:	83 ec 0c             	sub    $0xc,%esp
8010584a:	6a 0a                	push   $0xa
8010584c:	e8 e1 ca ff ff       	call   80102332 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105851:	43                   	inc    %ebx
80105852:	83 c4 10             	add    $0x10,%esp
80105855:	83 fb 7f             	cmp    $0x7f,%ebx
80105858:	7f 0a                	jg     80105864 <uartputc+0x34>
8010585a:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010585f:	ec                   	in     (%dx),%al
80105860:	a8 20                	test   $0x20,%al
80105862:	74 e3                	je     80105847 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105864:	8b 45 08             	mov    0x8(%ebp),%eax
80105867:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010586c:	ee                   	out    %al,(%dx)
}
8010586d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105870:	c9                   	leave  
80105871:	c3                   	ret    
80105872:	c3                   	ret    

80105873 <uartinit>:
{
80105873:	55                   	push   %ebp
80105874:	89 e5                	mov    %esp,%ebp
80105876:	56                   	push   %esi
80105877:	53                   	push   %ebx
80105878:	b1 00                	mov    $0x0,%cl
8010587a:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010587f:	88 c8                	mov    %cl,%al
80105881:	ee                   	out    %al,(%dx)
80105882:	be fb 03 00 00       	mov    $0x3fb,%esi
80105887:	b0 80                	mov    $0x80,%al
80105889:	89 f2                	mov    %esi,%edx
8010588b:	ee                   	out    %al,(%dx)
8010588c:	b0 0c                	mov    $0xc,%al
8010588e:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105893:	ee                   	out    %al,(%dx)
80105894:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105899:	88 c8                	mov    %cl,%al
8010589b:	89 da                	mov    %ebx,%edx
8010589d:	ee                   	out    %al,(%dx)
8010589e:	b0 03                	mov    $0x3,%al
801058a0:	89 f2                	mov    %esi,%edx
801058a2:	ee                   	out    %al,(%dx)
801058a3:	ba fc 03 00 00       	mov    $0x3fc,%edx
801058a8:	88 c8                	mov    %cl,%al
801058aa:	ee                   	out    %al,(%dx)
801058ab:	b0 01                	mov    $0x1,%al
801058ad:	89 da                	mov    %ebx,%edx
801058af:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801058b0:	ba fd 03 00 00       	mov    $0x3fd,%edx
801058b5:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801058b6:	3c ff                	cmp    $0xff,%al
801058b8:	74 42                	je     801058fc <uartinit+0x89>
  uart = 1;
801058ba:	c7 05 c0 47 11 80 01 	movl   $0x1,0x801147c0
801058c1:	00 00 00 
801058c4:	ba fa 03 00 00       	mov    $0x3fa,%edx
801058c9:	ec                   	in     (%dx),%al
801058ca:	ba f8 03 00 00       	mov    $0x3f8,%edx
801058cf:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801058d0:	83 ec 08             	sub    $0x8,%esp
801058d3:	6a 00                	push   $0x0
801058d5:	6a 04                	push   $0x4
801058d7:	e8 21 c6 ff ff       	call   80101efd <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801058dc:	83 c4 10             	add    $0x10,%esp
801058df:	bb b4 79 10 80       	mov    $0x801079b4,%ebx
801058e4:	eb 10                	jmp    801058f6 <uartinit+0x83>
    uartputc(*p);
801058e6:	83 ec 0c             	sub    $0xc,%esp
801058e9:	0f be c0             	movsbl %al,%eax
801058ec:	50                   	push   %eax
801058ed:	e8 3e ff ff ff       	call   80105830 <uartputc>
  for(p="xv6...\n"; *p; p++)
801058f2:	43                   	inc    %ebx
801058f3:	83 c4 10             	add    $0x10,%esp
801058f6:	8a 03                	mov    (%ebx),%al
801058f8:	84 c0                	test   %al,%al
801058fa:	75 ea                	jne    801058e6 <uartinit+0x73>
}
801058fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801058ff:	5b                   	pop    %ebx
80105900:	5e                   	pop    %esi
80105901:	5d                   	pop    %ebp
80105902:	c3                   	ret    

80105903 <uartintr>:

void
uartintr(void)
{
80105903:	55                   	push   %ebp
80105904:	89 e5                	mov    %esp,%ebp
80105906:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105909:	68 07 58 10 80       	push   $0x80105807
8010590e:	e8 ec ad ff ff       	call   801006ff <consoleintr>
}
80105913:	83 c4 10             	add    $0x10,%esp
80105916:	c9                   	leave  
80105917:	c3                   	ret    

80105918 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105918:	6a 00                	push   $0x0
  pushl $0
8010591a:	6a 00                	push   $0x0
  jmp alltraps
8010591c:	e9 1b fa ff ff       	jmp    8010533c <alltraps>

80105921 <vector1>:
.globl vector1
vector1:
  pushl $0
80105921:	6a 00                	push   $0x0
  pushl $1
80105923:	6a 01                	push   $0x1
  jmp alltraps
80105925:	e9 12 fa ff ff       	jmp    8010533c <alltraps>

8010592a <vector2>:
.globl vector2
vector2:
  pushl $0
8010592a:	6a 00                	push   $0x0
  pushl $2
8010592c:	6a 02                	push   $0x2
  jmp alltraps
8010592e:	e9 09 fa ff ff       	jmp    8010533c <alltraps>

80105933 <vector3>:
.globl vector3
vector3:
  pushl $0
80105933:	6a 00                	push   $0x0
  pushl $3
80105935:	6a 03                	push   $0x3
  jmp alltraps
80105937:	e9 00 fa ff ff       	jmp    8010533c <alltraps>

8010593c <vector4>:
.globl vector4
vector4:
  pushl $0
8010593c:	6a 00                	push   $0x0
  pushl $4
8010593e:	6a 04                	push   $0x4
  jmp alltraps
80105940:	e9 f7 f9 ff ff       	jmp    8010533c <alltraps>

80105945 <vector5>:
.globl vector5
vector5:
  pushl $0
80105945:	6a 00                	push   $0x0
  pushl $5
80105947:	6a 05                	push   $0x5
  jmp alltraps
80105949:	e9 ee f9 ff ff       	jmp    8010533c <alltraps>

8010594e <vector6>:
.globl vector6
vector6:
  pushl $0
8010594e:	6a 00                	push   $0x0
  pushl $6
80105950:	6a 06                	push   $0x6
  jmp alltraps
80105952:	e9 e5 f9 ff ff       	jmp    8010533c <alltraps>

80105957 <vector7>:
.globl vector7
vector7:
  pushl $0
80105957:	6a 00                	push   $0x0
  pushl $7
80105959:	6a 07                	push   $0x7
  jmp alltraps
8010595b:	e9 dc f9 ff ff       	jmp    8010533c <alltraps>

80105960 <vector8>:
.globl vector8
vector8:
  pushl $8
80105960:	6a 08                	push   $0x8
  jmp alltraps
80105962:	e9 d5 f9 ff ff       	jmp    8010533c <alltraps>

80105967 <vector9>:
.globl vector9
vector9:
  pushl $0
80105967:	6a 00                	push   $0x0
  pushl $9
80105969:	6a 09                	push   $0x9
  jmp alltraps
8010596b:	e9 cc f9 ff ff       	jmp    8010533c <alltraps>

80105970 <vector10>:
.globl vector10
vector10:
  pushl $10
80105970:	6a 0a                	push   $0xa
  jmp alltraps
80105972:	e9 c5 f9 ff ff       	jmp    8010533c <alltraps>

80105977 <vector11>:
.globl vector11
vector11:
  pushl $11
80105977:	6a 0b                	push   $0xb
  jmp alltraps
80105979:	e9 be f9 ff ff       	jmp    8010533c <alltraps>

8010597e <vector12>:
.globl vector12
vector12:
  pushl $12
8010597e:	6a 0c                	push   $0xc
  jmp alltraps
80105980:	e9 b7 f9 ff ff       	jmp    8010533c <alltraps>

80105985 <vector13>:
.globl vector13
vector13:
  pushl $13
80105985:	6a 0d                	push   $0xd
  jmp alltraps
80105987:	e9 b0 f9 ff ff       	jmp    8010533c <alltraps>

8010598c <vector14>:
.globl vector14
vector14:
  pushl $14
8010598c:	6a 0e                	push   $0xe
  jmp alltraps
8010598e:	e9 a9 f9 ff ff       	jmp    8010533c <alltraps>

80105993 <vector15>:
.globl vector15
vector15:
  pushl $0
80105993:	6a 00                	push   $0x0
  pushl $15
80105995:	6a 0f                	push   $0xf
  jmp alltraps
80105997:	e9 a0 f9 ff ff       	jmp    8010533c <alltraps>

8010599c <vector16>:
.globl vector16
vector16:
  pushl $0
8010599c:	6a 00                	push   $0x0
  pushl $16
8010599e:	6a 10                	push   $0x10
  jmp alltraps
801059a0:	e9 97 f9 ff ff       	jmp    8010533c <alltraps>

801059a5 <vector17>:
.globl vector17
vector17:
  pushl $17
801059a5:	6a 11                	push   $0x11
  jmp alltraps
801059a7:	e9 90 f9 ff ff       	jmp    8010533c <alltraps>

801059ac <vector18>:
.globl vector18
vector18:
  pushl $0
801059ac:	6a 00                	push   $0x0
  pushl $18
801059ae:	6a 12                	push   $0x12
  jmp alltraps
801059b0:	e9 87 f9 ff ff       	jmp    8010533c <alltraps>

801059b5 <vector19>:
.globl vector19
vector19:
  pushl $0
801059b5:	6a 00                	push   $0x0
  pushl $19
801059b7:	6a 13                	push   $0x13
  jmp alltraps
801059b9:	e9 7e f9 ff ff       	jmp    8010533c <alltraps>

801059be <vector20>:
.globl vector20
vector20:
  pushl $0
801059be:	6a 00                	push   $0x0
  pushl $20
801059c0:	6a 14                	push   $0x14
  jmp alltraps
801059c2:	e9 75 f9 ff ff       	jmp    8010533c <alltraps>

801059c7 <vector21>:
.globl vector21
vector21:
  pushl $0
801059c7:	6a 00                	push   $0x0
  pushl $21
801059c9:	6a 15                	push   $0x15
  jmp alltraps
801059cb:	e9 6c f9 ff ff       	jmp    8010533c <alltraps>

801059d0 <vector22>:
.globl vector22
vector22:
  pushl $0
801059d0:	6a 00                	push   $0x0
  pushl $22
801059d2:	6a 16                	push   $0x16
  jmp alltraps
801059d4:	e9 63 f9 ff ff       	jmp    8010533c <alltraps>

801059d9 <vector23>:
.globl vector23
vector23:
  pushl $0
801059d9:	6a 00                	push   $0x0
  pushl $23
801059db:	6a 17                	push   $0x17
  jmp alltraps
801059dd:	e9 5a f9 ff ff       	jmp    8010533c <alltraps>

801059e2 <vector24>:
.globl vector24
vector24:
  pushl $0
801059e2:	6a 00                	push   $0x0
  pushl $24
801059e4:	6a 18                	push   $0x18
  jmp alltraps
801059e6:	e9 51 f9 ff ff       	jmp    8010533c <alltraps>

801059eb <vector25>:
.globl vector25
vector25:
  pushl $0
801059eb:	6a 00                	push   $0x0
  pushl $25
801059ed:	6a 19                	push   $0x19
  jmp alltraps
801059ef:	e9 48 f9 ff ff       	jmp    8010533c <alltraps>

801059f4 <vector26>:
.globl vector26
vector26:
  pushl $0
801059f4:	6a 00                	push   $0x0
  pushl $26
801059f6:	6a 1a                	push   $0x1a
  jmp alltraps
801059f8:	e9 3f f9 ff ff       	jmp    8010533c <alltraps>

801059fd <vector27>:
.globl vector27
vector27:
  pushl $0
801059fd:	6a 00                	push   $0x0
  pushl $27
801059ff:	6a 1b                	push   $0x1b
  jmp alltraps
80105a01:	e9 36 f9 ff ff       	jmp    8010533c <alltraps>

80105a06 <vector28>:
.globl vector28
vector28:
  pushl $0
80105a06:	6a 00                	push   $0x0
  pushl $28
80105a08:	6a 1c                	push   $0x1c
  jmp alltraps
80105a0a:	e9 2d f9 ff ff       	jmp    8010533c <alltraps>

80105a0f <vector29>:
.globl vector29
vector29:
  pushl $0
80105a0f:	6a 00                	push   $0x0
  pushl $29
80105a11:	6a 1d                	push   $0x1d
  jmp alltraps
80105a13:	e9 24 f9 ff ff       	jmp    8010533c <alltraps>

80105a18 <vector30>:
.globl vector30
vector30:
  pushl $0
80105a18:	6a 00                	push   $0x0
  pushl $30
80105a1a:	6a 1e                	push   $0x1e
  jmp alltraps
80105a1c:	e9 1b f9 ff ff       	jmp    8010533c <alltraps>

80105a21 <vector31>:
.globl vector31
vector31:
  pushl $0
80105a21:	6a 00                	push   $0x0
  pushl $31
80105a23:	6a 1f                	push   $0x1f
  jmp alltraps
80105a25:	e9 12 f9 ff ff       	jmp    8010533c <alltraps>

80105a2a <vector32>:
.globl vector32
vector32:
  pushl $0
80105a2a:	6a 00                	push   $0x0
  pushl $32
80105a2c:	6a 20                	push   $0x20
  jmp alltraps
80105a2e:	e9 09 f9 ff ff       	jmp    8010533c <alltraps>

80105a33 <vector33>:
.globl vector33
vector33:
  pushl $0
80105a33:	6a 00                	push   $0x0
  pushl $33
80105a35:	6a 21                	push   $0x21
  jmp alltraps
80105a37:	e9 00 f9 ff ff       	jmp    8010533c <alltraps>

80105a3c <vector34>:
.globl vector34
vector34:
  pushl $0
80105a3c:	6a 00                	push   $0x0
  pushl $34
80105a3e:	6a 22                	push   $0x22
  jmp alltraps
80105a40:	e9 f7 f8 ff ff       	jmp    8010533c <alltraps>

80105a45 <vector35>:
.globl vector35
vector35:
  pushl $0
80105a45:	6a 00                	push   $0x0
  pushl $35
80105a47:	6a 23                	push   $0x23
  jmp alltraps
80105a49:	e9 ee f8 ff ff       	jmp    8010533c <alltraps>

80105a4e <vector36>:
.globl vector36
vector36:
  pushl $0
80105a4e:	6a 00                	push   $0x0
  pushl $36
80105a50:	6a 24                	push   $0x24
  jmp alltraps
80105a52:	e9 e5 f8 ff ff       	jmp    8010533c <alltraps>

80105a57 <vector37>:
.globl vector37
vector37:
  pushl $0
80105a57:	6a 00                	push   $0x0
  pushl $37
80105a59:	6a 25                	push   $0x25
  jmp alltraps
80105a5b:	e9 dc f8 ff ff       	jmp    8010533c <alltraps>

80105a60 <vector38>:
.globl vector38
vector38:
  pushl $0
80105a60:	6a 00                	push   $0x0
  pushl $38
80105a62:	6a 26                	push   $0x26
  jmp alltraps
80105a64:	e9 d3 f8 ff ff       	jmp    8010533c <alltraps>

80105a69 <vector39>:
.globl vector39
vector39:
  pushl $0
80105a69:	6a 00                	push   $0x0
  pushl $39
80105a6b:	6a 27                	push   $0x27
  jmp alltraps
80105a6d:	e9 ca f8 ff ff       	jmp    8010533c <alltraps>

80105a72 <vector40>:
.globl vector40
vector40:
  pushl $0
80105a72:	6a 00                	push   $0x0
  pushl $40
80105a74:	6a 28                	push   $0x28
  jmp alltraps
80105a76:	e9 c1 f8 ff ff       	jmp    8010533c <alltraps>

80105a7b <vector41>:
.globl vector41
vector41:
  pushl $0
80105a7b:	6a 00                	push   $0x0
  pushl $41
80105a7d:	6a 29                	push   $0x29
  jmp alltraps
80105a7f:	e9 b8 f8 ff ff       	jmp    8010533c <alltraps>

80105a84 <vector42>:
.globl vector42
vector42:
  pushl $0
80105a84:	6a 00                	push   $0x0
  pushl $42
80105a86:	6a 2a                	push   $0x2a
  jmp alltraps
80105a88:	e9 af f8 ff ff       	jmp    8010533c <alltraps>

80105a8d <vector43>:
.globl vector43
vector43:
  pushl $0
80105a8d:	6a 00                	push   $0x0
  pushl $43
80105a8f:	6a 2b                	push   $0x2b
  jmp alltraps
80105a91:	e9 a6 f8 ff ff       	jmp    8010533c <alltraps>

80105a96 <vector44>:
.globl vector44
vector44:
  pushl $0
80105a96:	6a 00                	push   $0x0
  pushl $44
80105a98:	6a 2c                	push   $0x2c
  jmp alltraps
80105a9a:	e9 9d f8 ff ff       	jmp    8010533c <alltraps>

80105a9f <vector45>:
.globl vector45
vector45:
  pushl $0
80105a9f:	6a 00                	push   $0x0
  pushl $45
80105aa1:	6a 2d                	push   $0x2d
  jmp alltraps
80105aa3:	e9 94 f8 ff ff       	jmp    8010533c <alltraps>

80105aa8 <vector46>:
.globl vector46
vector46:
  pushl $0
80105aa8:	6a 00                	push   $0x0
  pushl $46
80105aaa:	6a 2e                	push   $0x2e
  jmp alltraps
80105aac:	e9 8b f8 ff ff       	jmp    8010533c <alltraps>

80105ab1 <vector47>:
.globl vector47
vector47:
  pushl $0
80105ab1:	6a 00                	push   $0x0
  pushl $47
80105ab3:	6a 2f                	push   $0x2f
  jmp alltraps
80105ab5:	e9 82 f8 ff ff       	jmp    8010533c <alltraps>

80105aba <vector48>:
.globl vector48
vector48:
  pushl $0
80105aba:	6a 00                	push   $0x0
  pushl $48
80105abc:	6a 30                	push   $0x30
  jmp alltraps
80105abe:	e9 79 f8 ff ff       	jmp    8010533c <alltraps>

80105ac3 <vector49>:
.globl vector49
vector49:
  pushl $0
80105ac3:	6a 00                	push   $0x0
  pushl $49
80105ac5:	6a 31                	push   $0x31
  jmp alltraps
80105ac7:	e9 70 f8 ff ff       	jmp    8010533c <alltraps>

80105acc <vector50>:
.globl vector50
vector50:
  pushl $0
80105acc:	6a 00                	push   $0x0
  pushl $50
80105ace:	6a 32                	push   $0x32
  jmp alltraps
80105ad0:	e9 67 f8 ff ff       	jmp    8010533c <alltraps>

80105ad5 <vector51>:
.globl vector51
vector51:
  pushl $0
80105ad5:	6a 00                	push   $0x0
  pushl $51
80105ad7:	6a 33                	push   $0x33
  jmp alltraps
80105ad9:	e9 5e f8 ff ff       	jmp    8010533c <alltraps>

80105ade <vector52>:
.globl vector52
vector52:
  pushl $0
80105ade:	6a 00                	push   $0x0
  pushl $52
80105ae0:	6a 34                	push   $0x34
  jmp alltraps
80105ae2:	e9 55 f8 ff ff       	jmp    8010533c <alltraps>

80105ae7 <vector53>:
.globl vector53
vector53:
  pushl $0
80105ae7:	6a 00                	push   $0x0
  pushl $53
80105ae9:	6a 35                	push   $0x35
  jmp alltraps
80105aeb:	e9 4c f8 ff ff       	jmp    8010533c <alltraps>

80105af0 <vector54>:
.globl vector54
vector54:
  pushl $0
80105af0:	6a 00                	push   $0x0
  pushl $54
80105af2:	6a 36                	push   $0x36
  jmp alltraps
80105af4:	e9 43 f8 ff ff       	jmp    8010533c <alltraps>

80105af9 <vector55>:
.globl vector55
vector55:
  pushl $0
80105af9:	6a 00                	push   $0x0
  pushl $55
80105afb:	6a 37                	push   $0x37
  jmp alltraps
80105afd:	e9 3a f8 ff ff       	jmp    8010533c <alltraps>

80105b02 <vector56>:
.globl vector56
vector56:
  pushl $0
80105b02:	6a 00                	push   $0x0
  pushl $56
80105b04:	6a 38                	push   $0x38
  jmp alltraps
80105b06:	e9 31 f8 ff ff       	jmp    8010533c <alltraps>

80105b0b <vector57>:
.globl vector57
vector57:
  pushl $0
80105b0b:	6a 00                	push   $0x0
  pushl $57
80105b0d:	6a 39                	push   $0x39
  jmp alltraps
80105b0f:	e9 28 f8 ff ff       	jmp    8010533c <alltraps>

80105b14 <vector58>:
.globl vector58
vector58:
  pushl $0
80105b14:	6a 00                	push   $0x0
  pushl $58
80105b16:	6a 3a                	push   $0x3a
  jmp alltraps
80105b18:	e9 1f f8 ff ff       	jmp    8010533c <alltraps>

80105b1d <vector59>:
.globl vector59
vector59:
  pushl $0
80105b1d:	6a 00                	push   $0x0
  pushl $59
80105b1f:	6a 3b                	push   $0x3b
  jmp alltraps
80105b21:	e9 16 f8 ff ff       	jmp    8010533c <alltraps>

80105b26 <vector60>:
.globl vector60
vector60:
  pushl $0
80105b26:	6a 00                	push   $0x0
  pushl $60
80105b28:	6a 3c                	push   $0x3c
  jmp alltraps
80105b2a:	e9 0d f8 ff ff       	jmp    8010533c <alltraps>

80105b2f <vector61>:
.globl vector61
vector61:
  pushl $0
80105b2f:	6a 00                	push   $0x0
  pushl $61
80105b31:	6a 3d                	push   $0x3d
  jmp alltraps
80105b33:	e9 04 f8 ff ff       	jmp    8010533c <alltraps>

80105b38 <vector62>:
.globl vector62
vector62:
  pushl $0
80105b38:	6a 00                	push   $0x0
  pushl $62
80105b3a:	6a 3e                	push   $0x3e
  jmp alltraps
80105b3c:	e9 fb f7 ff ff       	jmp    8010533c <alltraps>

80105b41 <vector63>:
.globl vector63
vector63:
  pushl $0
80105b41:	6a 00                	push   $0x0
  pushl $63
80105b43:	6a 3f                	push   $0x3f
  jmp alltraps
80105b45:	e9 f2 f7 ff ff       	jmp    8010533c <alltraps>

80105b4a <vector64>:
.globl vector64
vector64:
  pushl $0
80105b4a:	6a 00                	push   $0x0
  pushl $64
80105b4c:	6a 40                	push   $0x40
  jmp alltraps
80105b4e:	e9 e9 f7 ff ff       	jmp    8010533c <alltraps>

80105b53 <vector65>:
.globl vector65
vector65:
  pushl $0
80105b53:	6a 00                	push   $0x0
  pushl $65
80105b55:	6a 41                	push   $0x41
  jmp alltraps
80105b57:	e9 e0 f7 ff ff       	jmp    8010533c <alltraps>

80105b5c <vector66>:
.globl vector66
vector66:
  pushl $0
80105b5c:	6a 00                	push   $0x0
  pushl $66
80105b5e:	6a 42                	push   $0x42
  jmp alltraps
80105b60:	e9 d7 f7 ff ff       	jmp    8010533c <alltraps>

80105b65 <vector67>:
.globl vector67
vector67:
  pushl $0
80105b65:	6a 00                	push   $0x0
  pushl $67
80105b67:	6a 43                	push   $0x43
  jmp alltraps
80105b69:	e9 ce f7 ff ff       	jmp    8010533c <alltraps>

80105b6e <vector68>:
.globl vector68
vector68:
  pushl $0
80105b6e:	6a 00                	push   $0x0
  pushl $68
80105b70:	6a 44                	push   $0x44
  jmp alltraps
80105b72:	e9 c5 f7 ff ff       	jmp    8010533c <alltraps>

80105b77 <vector69>:
.globl vector69
vector69:
  pushl $0
80105b77:	6a 00                	push   $0x0
  pushl $69
80105b79:	6a 45                	push   $0x45
  jmp alltraps
80105b7b:	e9 bc f7 ff ff       	jmp    8010533c <alltraps>

80105b80 <vector70>:
.globl vector70
vector70:
  pushl $0
80105b80:	6a 00                	push   $0x0
  pushl $70
80105b82:	6a 46                	push   $0x46
  jmp alltraps
80105b84:	e9 b3 f7 ff ff       	jmp    8010533c <alltraps>

80105b89 <vector71>:
.globl vector71
vector71:
  pushl $0
80105b89:	6a 00                	push   $0x0
  pushl $71
80105b8b:	6a 47                	push   $0x47
  jmp alltraps
80105b8d:	e9 aa f7 ff ff       	jmp    8010533c <alltraps>

80105b92 <vector72>:
.globl vector72
vector72:
  pushl $0
80105b92:	6a 00                	push   $0x0
  pushl $72
80105b94:	6a 48                	push   $0x48
  jmp alltraps
80105b96:	e9 a1 f7 ff ff       	jmp    8010533c <alltraps>

80105b9b <vector73>:
.globl vector73
vector73:
  pushl $0
80105b9b:	6a 00                	push   $0x0
  pushl $73
80105b9d:	6a 49                	push   $0x49
  jmp alltraps
80105b9f:	e9 98 f7 ff ff       	jmp    8010533c <alltraps>

80105ba4 <vector74>:
.globl vector74
vector74:
  pushl $0
80105ba4:	6a 00                	push   $0x0
  pushl $74
80105ba6:	6a 4a                	push   $0x4a
  jmp alltraps
80105ba8:	e9 8f f7 ff ff       	jmp    8010533c <alltraps>

80105bad <vector75>:
.globl vector75
vector75:
  pushl $0
80105bad:	6a 00                	push   $0x0
  pushl $75
80105baf:	6a 4b                	push   $0x4b
  jmp alltraps
80105bb1:	e9 86 f7 ff ff       	jmp    8010533c <alltraps>

80105bb6 <vector76>:
.globl vector76
vector76:
  pushl $0
80105bb6:	6a 00                	push   $0x0
  pushl $76
80105bb8:	6a 4c                	push   $0x4c
  jmp alltraps
80105bba:	e9 7d f7 ff ff       	jmp    8010533c <alltraps>

80105bbf <vector77>:
.globl vector77
vector77:
  pushl $0
80105bbf:	6a 00                	push   $0x0
  pushl $77
80105bc1:	6a 4d                	push   $0x4d
  jmp alltraps
80105bc3:	e9 74 f7 ff ff       	jmp    8010533c <alltraps>

80105bc8 <vector78>:
.globl vector78
vector78:
  pushl $0
80105bc8:	6a 00                	push   $0x0
  pushl $78
80105bca:	6a 4e                	push   $0x4e
  jmp alltraps
80105bcc:	e9 6b f7 ff ff       	jmp    8010533c <alltraps>

80105bd1 <vector79>:
.globl vector79
vector79:
  pushl $0
80105bd1:	6a 00                	push   $0x0
  pushl $79
80105bd3:	6a 4f                	push   $0x4f
  jmp alltraps
80105bd5:	e9 62 f7 ff ff       	jmp    8010533c <alltraps>

80105bda <vector80>:
.globl vector80
vector80:
  pushl $0
80105bda:	6a 00                	push   $0x0
  pushl $80
80105bdc:	6a 50                	push   $0x50
  jmp alltraps
80105bde:	e9 59 f7 ff ff       	jmp    8010533c <alltraps>

80105be3 <vector81>:
.globl vector81
vector81:
  pushl $0
80105be3:	6a 00                	push   $0x0
  pushl $81
80105be5:	6a 51                	push   $0x51
  jmp alltraps
80105be7:	e9 50 f7 ff ff       	jmp    8010533c <alltraps>

80105bec <vector82>:
.globl vector82
vector82:
  pushl $0
80105bec:	6a 00                	push   $0x0
  pushl $82
80105bee:	6a 52                	push   $0x52
  jmp alltraps
80105bf0:	e9 47 f7 ff ff       	jmp    8010533c <alltraps>

80105bf5 <vector83>:
.globl vector83
vector83:
  pushl $0
80105bf5:	6a 00                	push   $0x0
  pushl $83
80105bf7:	6a 53                	push   $0x53
  jmp alltraps
80105bf9:	e9 3e f7 ff ff       	jmp    8010533c <alltraps>

80105bfe <vector84>:
.globl vector84
vector84:
  pushl $0
80105bfe:	6a 00                	push   $0x0
  pushl $84
80105c00:	6a 54                	push   $0x54
  jmp alltraps
80105c02:	e9 35 f7 ff ff       	jmp    8010533c <alltraps>

80105c07 <vector85>:
.globl vector85
vector85:
  pushl $0
80105c07:	6a 00                	push   $0x0
  pushl $85
80105c09:	6a 55                	push   $0x55
  jmp alltraps
80105c0b:	e9 2c f7 ff ff       	jmp    8010533c <alltraps>

80105c10 <vector86>:
.globl vector86
vector86:
  pushl $0
80105c10:	6a 00                	push   $0x0
  pushl $86
80105c12:	6a 56                	push   $0x56
  jmp alltraps
80105c14:	e9 23 f7 ff ff       	jmp    8010533c <alltraps>

80105c19 <vector87>:
.globl vector87
vector87:
  pushl $0
80105c19:	6a 00                	push   $0x0
  pushl $87
80105c1b:	6a 57                	push   $0x57
  jmp alltraps
80105c1d:	e9 1a f7 ff ff       	jmp    8010533c <alltraps>

80105c22 <vector88>:
.globl vector88
vector88:
  pushl $0
80105c22:	6a 00                	push   $0x0
  pushl $88
80105c24:	6a 58                	push   $0x58
  jmp alltraps
80105c26:	e9 11 f7 ff ff       	jmp    8010533c <alltraps>

80105c2b <vector89>:
.globl vector89
vector89:
  pushl $0
80105c2b:	6a 00                	push   $0x0
  pushl $89
80105c2d:	6a 59                	push   $0x59
  jmp alltraps
80105c2f:	e9 08 f7 ff ff       	jmp    8010533c <alltraps>

80105c34 <vector90>:
.globl vector90
vector90:
  pushl $0
80105c34:	6a 00                	push   $0x0
  pushl $90
80105c36:	6a 5a                	push   $0x5a
  jmp alltraps
80105c38:	e9 ff f6 ff ff       	jmp    8010533c <alltraps>

80105c3d <vector91>:
.globl vector91
vector91:
  pushl $0
80105c3d:	6a 00                	push   $0x0
  pushl $91
80105c3f:	6a 5b                	push   $0x5b
  jmp alltraps
80105c41:	e9 f6 f6 ff ff       	jmp    8010533c <alltraps>

80105c46 <vector92>:
.globl vector92
vector92:
  pushl $0
80105c46:	6a 00                	push   $0x0
  pushl $92
80105c48:	6a 5c                	push   $0x5c
  jmp alltraps
80105c4a:	e9 ed f6 ff ff       	jmp    8010533c <alltraps>

80105c4f <vector93>:
.globl vector93
vector93:
  pushl $0
80105c4f:	6a 00                	push   $0x0
  pushl $93
80105c51:	6a 5d                	push   $0x5d
  jmp alltraps
80105c53:	e9 e4 f6 ff ff       	jmp    8010533c <alltraps>

80105c58 <vector94>:
.globl vector94
vector94:
  pushl $0
80105c58:	6a 00                	push   $0x0
  pushl $94
80105c5a:	6a 5e                	push   $0x5e
  jmp alltraps
80105c5c:	e9 db f6 ff ff       	jmp    8010533c <alltraps>

80105c61 <vector95>:
.globl vector95
vector95:
  pushl $0
80105c61:	6a 00                	push   $0x0
  pushl $95
80105c63:	6a 5f                	push   $0x5f
  jmp alltraps
80105c65:	e9 d2 f6 ff ff       	jmp    8010533c <alltraps>

80105c6a <vector96>:
.globl vector96
vector96:
  pushl $0
80105c6a:	6a 00                	push   $0x0
  pushl $96
80105c6c:	6a 60                	push   $0x60
  jmp alltraps
80105c6e:	e9 c9 f6 ff ff       	jmp    8010533c <alltraps>

80105c73 <vector97>:
.globl vector97
vector97:
  pushl $0
80105c73:	6a 00                	push   $0x0
  pushl $97
80105c75:	6a 61                	push   $0x61
  jmp alltraps
80105c77:	e9 c0 f6 ff ff       	jmp    8010533c <alltraps>

80105c7c <vector98>:
.globl vector98
vector98:
  pushl $0
80105c7c:	6a 00                	push   $0x0
  pushl $98
80105c7e:	6a 62                	push   $0x62
  jmp alltraps
80105c80:	e9 b7 f6 ff ff       	jmp    8010533c <alltraps>

80105c85 <vector99>:
.globl vector99
vector99:
  pushl $0
80105c85:	6a 00                	push   $0x0
  pushl $99
80105c87:	6a 63                	push   $0x63
  jmp alltraps
80105c89:	e9 ae f6 ff ff       	jmp    8010533c <alltraps>

80105c8e <vector100>:
.globl vector100
vector100:
  pushl $0
80105c8e:	6a 00                	push   $0x0
  pushl $100
80105c90:	6a 64                	push   $0x64
  jmp alltraps
80105c92:	e9 a5 f6 ff ff       	jmp    8010533c <alltraps>

80105c97 <vector101>:
.globl vector101
vector101:
  pushl $0
80105c97:	6a 00                	push   $0x0
  pushl $101
80105c99:	6a 65                	push   $0x65
  jmp alltraps
80105c9b:	e9 9c f6 ff ff       	jmp    8010533c <alltraps>

80105ca0 <vector102>:
.globl vector102
vector102:
  pushl $0
80105ca0:	6a 00                	push   $0x0
  pushl $102
80105ca2:	6a 66                	push   $0x66
  jmp alltraps
80105ca4:	e9 93 f6 ff ff       	jmp    8010533c <alltraps>

80105ca9 <vector103>:
.globl vector103
vector103:
  pushl $0
80105ca9:	6a 00                	push   $0x0
  pushl $103
80105cab:	6a 67                	push   $0x67
  jmp alltraps
80105cad:	e9 8a f6 ff ff       	jmp    8010533c <alltraps>

80105cb2 <vector104>:
.globl vector104
vector104:
  pushl $0
80105cb2:	6a 00                	push   $0x0
  pushl $104
80105cb4:	6a 68                	push   $0x68
  jmp alltraps
80105cb6:	e9 81 f6 ff ff       	jmp    8010533c <alltraps>

80105cbb <vector105>:
.globl vector105
vector105:
  pushl $0
80105cbb:	6a 00                	push   $0x0
  pushl $105
80105cbd:	6a 69                	push   $0x69
  jmp alltraps
80105cbf:	e9 78 f6 ff ff       	jmp    8010533c <alltraps>

80105cc4 <vector106>:
.globl vector106
vector106:
  pushl $0
80105cc4:	6a 00                	push   $0x0
  pushl $106
80105cc6:	6a 6a                	push   $0x6a
  jmp alltraps
80105cc8:	e9 6f f6 ff ff       	jmp    8010533c <alltraps>

80105ccd <vector107>:
.globl vector107
vector107:
  pushl $0
80105ccd:	6a 00                	push   $0x0
  pushl $107
80105ccf:	6a 6b                	push   $0x6b
  jmp alltraps
80105cd1:	e9 66 f6 ff ff       	jmp    8010533c <alltraps>

80105cd6 <vector108>:
.globl vector108
vector108:
  pushl $0
80105cd6:	6a 00                	push   $0x0
  pushl $108
80105cd8:	6a 6c                	push   $0x6c
  jmp alltraps
80105cda:	e9 5d f6 ff ff       	jmp    8010533c <alltraps>

80105cdf <vector109>:
.globl vector109
vector109:
  pushl $0
80105cdf:	6a 00                	push   $0x0
  pushl $109
80105ce1:	6a 6d                	push   $0x6d
  jmp alltraps
80105ce3:	e9 54 f6 ff ff       	jmp    8010533c <alltraps>

80105ce8 <vector110>:
.globl vector110
vector110:
  pushl $0
80105ce8:	6a 00                	push   $0x0
  pushl $110
80105cea:	6a 6e                	push   $0x6e
  jmp alltraps
80105cec:	e9 4b f6 ff ff       	jmp    8010533c <alltraps>

80105cf1 <vector111>:
.globl vector111
vector111:
  pushl $0
80105cf1:	6a 00                	push   $0x0
  pushl $111
80105cf3:	6a 6f                	push   $0x6f
  jmp alltraps
80105cf5:	e9 42 f6 ff ff       	jmp    8010533c <alltraps>

80105cfa <vector112>:
.globl vector112
vector112:
  pushl $0
80105cfa:	6a 00                	push   $0x0
  pushl $112
80105cfc:	6a 70                	push   $0x70
  jmp alltraps
80105cfe:	e9 39 f6 ff ff       	jmp    8010533c <alltraps>

80105d03 <vector113>:
.globl vector113
vector113:
  pushl $0
80105d03:	6a 00                	push   $0x0
  pushl $113
80105d05:	6a 71                	push   $0x71
  jmp alltraps
80105d07:	e9 30 f6 ff ff       	jmp    8010533c <alltraps>

80105d0c <vector114>:
.globl vector114
vector114:
  pushl $0
80105d0c:	6a 00                	push   $0x0
  pushl $114
80105d0e:	6a 72                	push   $0x72
  jmp alltraps
80105d10:	e9 27 f6 ff ff       	jmp    8010533c <alltraps>

80105d15 <vector115>:
.globl vector115
vector115:
  pushl $0
80105d15:	6a 00                	push   $0x0
  pushl $115
80105d17:	6a 73                	push   $0x73
  jmp alltraps
80105d19:	e9 1e f6 ff ff       	jmp    8010533c <alltraps>

80105d1e <vector116>:
.globl vector116
vector116:
  pushl $0
80105d1e:	6a 00                	push   $0x0
  pushl $116
80105d20:	6a 74                	push   $0x74
  jmp alltraps
80105d22:	e9 15 f6 ff ff       	jmp    8010533c <alltraps>

80105d27 <vector117>:
.globl vector117
vector117:
  pushl $0
80105d27:	6a 00                	push   $0x0
  pushl $117
80105d29:	6a 75                	push   $0x75
  jmp alltraps
80105d2b:	e9 0c f6 ff ff       	jmp    8010533c <alltraps>

80105d30 <vector118>:
.globl vector118
vector118:
  pushl $0
80105d30:	6a 00                	push   $0x0
  pushl $118
80105d32:	6a 76                	push   $0x76
  jmp alltraps
80105d34:	e9 03 f6 ff ff       	jmp    8010533c <alltraps>

80105d39 <vector119>:
.globl vector119
vector119:
  pushl $0
80105d39:	6a 00                	push   $0x0
  pushl $119
80105d3b:	6a 77                	push   $0x77
  jmp alltraps
80105d3d:	e9 fa f5 ff ff       	jmp    8010533c <alltraps>

80105d42 <vector120>:
.globl vector120
vector120:
  pushl $0
80105d42:	6a 00                	push   $0x0
  pushl $120
80105d44:	6a 78                	push   $0x78
  jmp alltraps
80105d46:	e9 f1 f5 ff ff       	jmp    8010533c <alltraps>

80105d4b <vector121>:
.globl vector121
vector121:
  pushl $0
80105d4b:	6a 00                	push   $0x0
  pushl $121
80105d4d:	6a 79                	push   $0x79
  jmp alltraps
80105d4f:	e9 e8 f5 ff ff       	jmp    8010533c <alltraps>

80105d54 <vector122>:
.globl vector122
vector122:
  pushl $0
80105d54:	6a 00                	push   $0x0
  pushl $122
80105d56:	6a 7a                	push   $0x7a
  jmp alltraps
80105d58:	e9 df f5 ff ff       	jmp    8010533c <alltraps>

80105d5d <vector123>:
.globl vector123
vector123:
  pushl $0
80105d5d:	6a 00                	push   $0x0
  pushl $123
80105d5f:	6a 7b                	push   $0x7b
  jmp alltraps
80105d61:	e9 d6 f5 ff ff       	jmp    8010533c <alltraps>

80105d66 <vector124>:
.globl vector124
vector124:
  pushl $0
80105d66:	6a 00                	push   $0x0
  pushl $124
80105d68:	6a 7c                	push   $0x7c
  jmp alltraps
80105d6a:	e9 cd f5 ff ff       	jmp    8010533c <alltraps>

80105d6f <vector125>:
.globl vector125
vector125:
  pushl $0
80105d6f:	6a 00                	push   $0x0
  pushl $125
80105d71:	6a 7d                	push   $0x7d
  jmp alltraps
80105d73:	e9 c4 f5 ff ff       	jmp    8010533c <alltraps>

80105d78 <vector126>:
.globl vector126
vector126:
  pushl $0
80105d78:	6a 00                	push   $0x0
  pushl $126
80105d7a:	6a 7e                	push   $0x7e
  jmp alltraps
80105d7c:	e9 bb f5 ff ff       	jmp    8010533c <alltraps>

80105d81 <vector127>:
.globl vector127
vector127:
  pushl $0
80105d81:	6a 00                	push   $0x0
  pushl $127
80105d83:	6a 7f                	push   $0x7f
  jmp alltraps
80105d85:	e9 b2 f5 ff ff       	jmp    8010533c <alltraps>

80105d8a <vector128>:
.globl vector128
vector128:
  pushl $0
80105d8a:	6a 00                	push   $0x0
  pushl $128
80105d8c:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105d91:	e9 a6 f5 ff ff       	jmp    8010533c <alltraps>

80105d96 <vector129>:
.globl vector129
vector129:
  pushl $0
80105d96:	6a 00                	push   $0x0
  pushl $129
80105d98:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105d9d:	e9 9a f5 ff ff       	jmp    8010533c <alltraps>

80105da2 <vector130>:
.globl vector130
vector130:
  pushl $0
80105da2:	6a 00                	push   $0x0
  pushl $130
80105da4:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105da9:	e9 8e f5 ff ff       	jmp    8010533c <alltraps>

80105dae <vector131>:
.globl vector131
vector131:
  pushl $0
80105dae:	6a 00                	push   $0x0
  pushl $131
80105db0:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105db5:	e9 82 f5 ff ff       	jmp    8010533c <alltraps>

80105dba <vector132>:
.globl vector132
vector132:
  pushl $0
80105dba:	6a 00                	push   $0x0
  pushl $132
80105dbc:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105dc1:	e9 76 f5 ff ff       	jmp    8010533c <alltraps>

80105dc6 <vector133>:
.globl vector133
vector133:
  pushl $0
80105dc6:	6a 00                	push   $0x0
  pushl $133
80105dc8:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105dcd:	e9 6a f5 ff ff       	jmp    8010533c <alltraps>

80105dd2 <vector134>:
.globl vector134
vector134:
  pushl $0
80105dd2:	6a 00                	push   $0x0
  pushl $134
80105dd4:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105dd9:	e9 5e f5 ff ff       	jmp    8010533c <alltraps>

80105dde <vector135>:
.globl vector135
vector135:
  pushl $0
80105dde:	6a 00                	push   $0x0
  pushl $135
80105de0:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80105de5:	e9 52 f5 ff ff       	jmp    8010533c <alltraps>

80105dea <vector136>:
.globl vector136
vector136:
  pushl $0
80105dea:	6a 00                	push   $0x0
  pushl $136
80105dec:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80105df1:	e9 46 f5 ff ff       	jmp    8010533c <alltraps>

80105df6 <vector137>:
.globl vector137
vector137:
  pushl $0
80105df6:	6a 00                	push   $0x0
  pushl $137
80105df8:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80105dfd:	e9 3a f5 ff ff       	jmp    8010533c <alltraps>

80105e02 <vector138>:
.globl vector138
vector138:
  pushl $0
80105e02:	6a 00                	push   $0x0
  pushl $138
80105e04:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105e09:	e9 2e f5 ff ff       	jmp    8010533c <alltraps>

80105e0e <vector139>:
.globl vector139
vector139:
  pushl $0
80105e0e:	6a 00                	push   $0x0
  pushl $139
80105e10:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80105e15:	e9 22 f5 ff ff       	jmp    8010533c <alltraps>

80105e1a <vector140>:
.globl vector140
vector140:
  pushl $0
80105e1a:	6a 00                	push   $0x0
  pushl $140
80105e1c:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80105e21:	e9 16 f5 ff ff       	jmp    8010533c <alltraps>

80105e26 <vector141>:
.globl vector141
vector141:
  pushl $0
80105e26:	6a 00                	push   $0x0
  pushl $141
80105e28:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105e2d:	e9 0a f5 ff ff       	jmp    8010533c <alltraps>

80105e32 <vector142>:
.globl vector142
vector142:
  pushl $0
80105e32:	6a 00                	push   $0x0
  pushl $142
80105e34:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105e39:	e9 fe f4 ff ff       	jmp    8010533c <alltraps>

80105e3e <vector143>:
.globl vector143
vector143:
  pushl $0
80105e3e:	6a 00                	push   $0x0
  pushl $143
80105e40:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105e45:	e9 f2 f4 ff ff       	jmp    8010533c <alltraps>

80105e4a <vector144>:
.globl vector144
vector144:
  pushl $0
80105e4a:	6a 00                	push   $0x0
  pushl $144
80105e4c:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105e51:	e9 e6 f4 ff ff       	jmp    8010533c <alltraps>

80105e56 <vector145>:
.globl vector145
vector145:
  pushl $0
80105e56:	6a 00                	push   $0x0
  pushl $145
80105e58:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105e5d:	e9 da f4 ff ff       	jmp    8010533c <alltraps>

80105e62 <vector146>:
.globl vector146
vector146:
  pushl $0
80105e62:	6a 00                	push   $0x0
  pushl $146
80105e64:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105e69:	e9 ce f4 ff ff       	jmp    8010533c <alltraps>

80105e6e <vector147>:
.globl vector147
vector147:
  pushl $0
80105e6e:	6a 00                	push   $0x0
  pushl $147
80105e70:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105e75:	e9 c2 f4 ff ff       	jmp    8010533c <alltraps>

80105e7a <vector148>:
.globl vector148
vector148:
  pushl $0
80105e7a:	6a 00                	push   $0x0
  pushl $148
80105e7c:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105e81:	e9 b6 f4 ff ff       	jmp    8010533c <alltraps>

80105e86 <vector149>:
.globl vector149
vector149:
  pushl $0
80105e86:	6a 00                	push   $0x0
  pushl $149
80105e88:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105e8d:	e9 aa f4 ff ff       	jmp    8010533c <alltraps>

80105e92 <vector150>:
.globl vector150
vector150:
  pushl $0
80105e92:	6a 00                	push   $0x0
  pushl $150
80105e94:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105e99:	e9 9e f4 ff ff       	jmp    8010533c <alltraps>

80105e9e <vector151>:
.globl vector151
vector151:
  pushl $0
80105e9e:	6a 00                	push   $0x0
  pushl $151
80105ea0:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105ea5:	e9 92 f4 ff ff       	jmp    8010533c <alltraps>

80105eaa <vector152>:
.globl vector152
vector152:
  pushl $0
80105eaa:	6a 00                	push   $0x0
  pushl $152
80105eac:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105eb1:	e9 86 f4 ff ff       	jmp    8010533c <alltraps>

80105eb6 <vector153>:
.globl vector153
vector153:
  pushl $0
80105eb6:	6a 00                	push   $0x0
  pushl $153
80105eb8:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105ebd:	e9 7a f4 ff ff       	jmp    8010533c <alltraps>

80105ec2 <vector154>:
.globl vector154
vector154:
  pushl $0
80105ec2:	6a 00                	push   $0x0
  pushl $154
80105ec4:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105ec9:	e9 6e f4 ff ff       	jmp    8010533c <alltraps>

80105ece <vector155>:
.globl vector155
vector155:
  pushl $0
80105ece:	6a 00                	push   $0x0
  pushl $155
80105ed0:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105ed5:	e9 62 f4 ff ff       	jmp    8010533c <alltraps>

80105eda <vector156>:
.globl vector156
vector156:
  pushl $0
80105eda:	6a 00                	push   $0x0
  pushl $156
80105edc:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105ee1:	e9 56 f4 ff ff       	jmp    8010533c <alltraps>

80105ee6 <vector157>:
.globl vector157
vector157:
  pushl $0
80105ee6:	6a 00                	push   $0x0
  pushl $157
80105ee8:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80105eed:	e9 4a f4 ff ff       	jmp    8010533c <alltraps>

80105ef2 <vector158>:
.globl vector158
vector158:
  pushl $0
80105ef2:	6a 00                	push   $0x0
  pushl $158
80105ef4:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105ef9:	e9 3e f4 ff ff       	jmp    8010533c <alltraps>

80105efe <vector159>:
.globl vector159
vector159:
  pushl $0
80105efe:	6a 00                	push   $0x0
  pushl $159
80105f00:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105f05:	e9 32 f4 ff ff       	jmp    8010533c <alltraps>

80105f0a <vector160>:
.globl vector160
vector160:
  pushl $0
80105f0a:	6a 00                	push   $0x0
  pushl $160
80105f0c:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105f11:	e9 26 f4 ff ff       	jmp    8010533c <alltraps>

80105f16 <vector161>:
.globl vector161
vector161:
  pushl $0
80105f16:	6a 00                	push   $0x0
  pushl $161
80105f18:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105f1d:	e9 1a f4 ff ff       	jmp    8010533c <alltraps>

80105f22 <vector162>:
.globl vector162
vector162:
  pushl $0
80105f22:	6a 00                	push   $0x0
  pushl $162
80105f24:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105f29:	e9 0e f4 ff ff       	jmp    8010533c <alltraps>

80105f2e <vector163>:
.globl vector163
vector163:
  pushl $0
80105f2e:	6a 00                	push   $0x0
  pushl $163
80105f30:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105f35:	e9 02 f4 ff ff       	jmp    8010533c <alltraps>

80105f3a <vector164>:
.globl vector164
vector164:
  pushl $0
80105f3a:	6a 00                	push   $0x0
  pushl $164
80105f3c:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105f41:	e9 f6 f3 ff ff       	jmp    8010533c <alltraps>

80105f46 <vector165>:
.globl vector165
vector165:
  pushl $0
80105f46:	6a 00                	push   $0x0
  pushl $165
80105f48:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105f4d:	e9 ea f3 ff ff       	jmp    8010533c <alltraps>

80105f52 <vector166>:
.globl vector166
vector166:
  pushl $0
80105f52:	6a 00                	push   $0x0
  pushl $166
80105f54:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105f59:	e9 de f3 ff ff       	jmp    8010533c <alltraps>

80105f5e <vector167>:
.globl vector167
vector167:
  pushl $0
80105f5e:	6a 00                	push   $0x0
  pushl $167
80105f60:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105f65:	e9 d2 f3 ff ff       	jmp    8010533c <alltraps>

80105f6a <vector168>:
.globl vector168
vector168:
  pushl $0
80105f6a:	6a 00                	push   $0x0
  pushl $168
80105f6c:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105f71:	e9 c6 f3 ff ff       	jmp    8010533c <alltraps>

80105f76 <vector169>:
.globl vector169
vector169:
  pushl $0
80105f76:	6a 00                	push   $0x0
  pushl $169
80105f78:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105f7d:	e9 ba f3 ff ff       	jmp    8010533c <alltraps>

80105f82 <vector170>:
.globl vector170
vector170:
  pushl $0
80105f82:	6a 00                	push   $0x0
  pushl $170
80105f84:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105f89:	e9 ae f3 ff ff       	jmp    8010533c <alltraps>

80105f8e <vector171>:
.globl vector171
vector171:
  pushl $0
80105f8e:	6a 00                	push   $0x0
  pushl $171
80105f90:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105f95:	e9 a2 f3 ff ff       	jmp    8010533c <alltraps>

80105f9a <vector172>:
.globl vector172
vector172:
  pushl $0
80105f9a:	6a 00                	push   $0x0
  pushl $172
80105f9c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105fa1:	e9 96 f3 ff ff       	jmp    8010533c <alltraps>

80105fa6 <vector173>:
.globl vector173
vector173:
  pushl $0
80105fa6:	6a 00                	push   $0x0
  pushl $173
80105fa8:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105fad:	e9 8a f3 ff ff       	jmp    8010533c <alltraps>

80105fb2 <vector174>:
.globl vector174
vector174:
  pushl $0
80105fb2:	6a 00                	push   $0x0
  pushl $174
80105fb4:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105fb9:	e9 7e f3 ff ff       	jmp    8010533c <alltraps>

80105fbe <vector175>:
.globl vector175
vector175:
  pushl $0
80105fbe:	6a 00                	push   $0x0
  pushl $175
80105fc0:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105fc5:	e9 72 f3 ff ff       	jmp    8010533c <alltraps>

80105fca <vector176>:
.globl vector176
vector176:
  pushl $0
80105fca:	6a 00                	push   $0x0
  pushl $176
80105fcc:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105fd1:	e9 66 f3 ff ff       	jmp    8010533c <alltraps>

80105fd6 <vector177>:
.globl vector177
vector177:
  pushl $0
80105fd6:	6a 00                	push   $0x0
  pushl $177
80105fd8:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105fdd:	e9 5a f3 ff ff       	jmp    8010533c <alltraps>

80105fe2 <vector178>:
.globl vector178
vector178:
  pushl $0
80105fe2:	6a 00                	push   $0x0
  pushl $178
80105fe4:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105fe9:	e9 4e f3 ff ff       	jmp    8010533c <alltraps>

80105fee <vector179>:
.globl vector179
vector179:
  pushl $0
80105fee:	6a 00                	push   $0x0
  pushl $179
80105ff0:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105ff5:	e9 42 f3 ff ff       	jmp    8010533c <alltraps>

80105ffa <vector180>:
.globl vector180
vector180:
  pushl $0
80105ffa:	6a 00                	push   $0x0
  pushl $180
80105ffc:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106001:	e9 36 f3 ff ff       	jmp    8010533c <alltraps>

80106006 <vector181>:
.globl vector181
vector181:
  pushl $0
80106006:	6a 00                	push   $0x0
  pushl $181
80106008:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010600d:	e9 2a f3 ff ff       	jmp    8010533c <alltraps>

80106012 <vector182>:
.globl vector182
vector182:
  pushl $0
80106012:	6a 00                	push   $0x0
  pushl $182
80106014:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106019:	e9 1e f3 ff ff       	jmp    8010533c <alltraps>

8010601e <vector183>:
.globl vector183
vector183:
  pushl $0
8010601e:	6a 00                	push   $0x0
  pushl $183
80106020:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106025:	e9 12 f3 ff ff       	jmp    8010533c <alltraps>

8010602a <vector184>:
.globl vector184
vector184:
  pushl $0
8010602a:	6a 00                	push   $0x0
  pushl $184
8010602c:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106031:	e9 06 f3 ff ff       	jmp    8010533c <alltraps>

80106036 <vector185>:
.globl vector185
vector185:
  pushl $0
80106036:	6a 00                	push   $0x0
  pushl $185
80106038:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010603d:	e9 fa f2 ff ff       	jmp    8010533c <alltraps>

80106042 <vector186>:
.globl vector186
vector186:
  pushl $0
80106042:	6a 00                	push   $0x0
  pushl $186
80106044:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106049:	e9 ee f2 ff ff       	jmp    8010533c <alltraps>

8010604e <vector187>:
.globl vector187
vector187:
  pushl $0
8010604e:	6a 00                	push   $0x0
  pushl $187
80106050:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106055:	e9 e2 f2 ff ff       	jmp    8010533c <alltraps>

8010605a <vector188>:
.globl vector188
vector188:
  pushl $0
8010605a:	6a 00                	push   $0x0
  pushl $188
8010605c:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106061:	e9 d6 f2 ff ff       	jmp    8010533c <alltraps>

80106066 <vector189>:
.globl vector189
vector189:
  pushl $0
80106066:	6a 00                	push   $0x0
  pushl $189
80106068:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010606d:	e9 ca f2 ff ff       	jmp    8010533c <alltraps>

80106072 <vector190>:
.globl vector190
vector190:
  pushl $0
80106072:	6a 00                	push   $0x0
  pushl $190
80106074:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106079:	e9 be f2 ff ff       	jmp    8010533c <alltraps>

8010607e <vector191>:
.globl vector191
vector191:
  pushl $0
8010607e:	6a 00                	push   $0x0
  pushl $191
80106080:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106085:	e9 b2 f2 ff ff       	jmp    8010533c <alltraps>

8010608a <vector192>:
.globl vector192
vector192:
  pushl $0
8010608a:	6a 00                	push   $0x0
  pushl $192
8010608c:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106091:	e9 a6 f2 ff ff       	jmp    8010533c <alltraps>

80106096 <vector193>:
.globl vector193
vector193:
  pushl $0
80106096:	6a 00                	push   $0x0
  pushl $193
80106098:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010609d:	e9 9a f2 ff ff       	jmp    8010533c <alltraps>

801060a2 <vector194>:
.globl vector194
vector194:
  pushl $0
801060a2:	6a 00                	push   $0x0
  pushl $194
801060a4:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801060a9:	e9 8e f2 ff ff       	jmp    8010533c <alltraps>

801060ae <vector195>:
.globl vector195
vector195:
  pushl $0
801060ae:	6a 00                	push   $0x0
  pushl $195
801060b0:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801060b5:	e9 82 f2 ff ff       	jmp    8010533c <alltraps>

801060ba <vector196>:
.globl vector196
vector196:
  pushl $0
801060ba:	6a 00                	push   $0x0
  pushl $196
801060bc:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801060c1:	e9 76 f2 ff ff       	jmp    8010533c <alltraps>

801060c6 <vector197>:
.globl vector197
vector197:
  pushl $0
801060c6:	6a 00                	push   $0x0
  pushl $197
801060c8:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801060cd:	e9 6a f2 ff ff       	jmp    8010533c <alltraps>

801060d2 <vector198>:
.globl vector198
vector198:
  pushl $0
801060d2:	6a 00                	push   $0x0
  pushl $198
801060d4:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801060d9:	e9 5e f2 ff ff       	jmp    8010533c <alltraps>

801060de <vector199>:
.globl vector199
vector199:
  pushl $0
801060de:	6a 00                	push   $0x0
  pushl $199
801060e0:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801060e5:	e9 52 f2 ff ff       	jmp    8010533c <alltraps>

801060ea <vector200>:
.globl vector200
vector200:
  pushl $0
801060ea:	6a 00                	push   $0x0
  pushl $200
801060ec:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801060f1:	e9 46 f2 ff ff       	jmp    8010533c <alltraps>

801060f6 <vector201>:
.globl vector201
vector201:
  pushl $0
801060f6:	6a 00                	push   $0x0
  pushl $201
801060f8:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801060fd:	e9 3a f2 ff ff       	jmp    8010533c <alltraps>

80106102 <vector202>:
.globl vector202
vector202:
  pushl $0
80106102:	6a 00                	push   $0x0
  pushl $202
80106104:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106109:	e9 2e f2 ff ff       	jmp    8010533c <alltraps>

8010610e <vector203>:
.globl vector203
vector203:
  pushl $0
8010610e:	6a 00                	push   $0x0
  pushl $203
80106110:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106115:	e9 22 f2 ff ff       	jmp    8010533c <alltraps>

8010611a <vector204>:
.globl vector204
vector204:
  pushl $0
8010611a:	6a 00                	push   $0x0
  pushl $204
8010611c:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106121:	e9 16 f2 ff ff       	jmp    8010533c <alltraps>

80106126 <vector205>:
.globl vector205
vector205:
  pushl $0
80106126:	6a 00                	push   $0x0
  pushl $205
80106128:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010612d:	e9 0a f2 ff ff       	jmp    8010533c <alltraps>

80106132 <vector206>:
.globl vector206
vector206:
  pushl $0
80106132:	6a 00                	push   $0x0
  pushl $206
80106134:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106139:	e9 fe f1 ff ff       	jmp    8010533c <alltraps>

8010613e <vector207>:
.globl vector207
vector207:
  pushl $0
8010613e:	6a 00                	push   $0x0
  pushl $207
80106140:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106145:	e9 f2 f1 ff ff       	jmp    8010533c <alltraps>

8010614a <vector208>:
.globl vector208
vector208:
  pushl $0
8010614a:	6a 00                	push   $0x0
  pushl $208
8010614c:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106151:	e9 e6 f1 ff ff       	jmp    8010533c <alltraps>

80106156 <vector209>:
.globl vector209
vector209:
  pushl $0
80106156:	6a 00                	push   $0x0
  pushl $209
80106158:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010615d:	e9 da f1 ff ff       	jmp    8010533c <alltraps>

80106162 <vector210>:
.globl vector210
vector210:
  pushl $0
80106162:	6a 00                	push   $0x0
  pushl $210
80106164:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106169:	e9 ce f1 ff ff       	jmp    8010533c <alltraps>

8010616e <vector211>:
.globl vector211
vector211:
  pushl $0
8010616e:	6a 00                	push   $0x0
  pushl $211
80106170:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106175:	e9 c2 f1 ff ff       	jmp    8010533c <alltraps>

8010617a <vector212>:
.globl vector212
vector212:
  pushl $0
8010617a:	6a 00                	push   $0x0
  pushl $212
8010617c:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106181:	e9 b6 f1 ff ff       	jmp    8010533c <alltraps>

80106186 <vector213>:
.globl vector213
vector213:
  pushl $0
80106186:	6a 00                	push   $0x0
  pushl $213
80106188:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010618d:	e9 aa f1 ff ff       	jmp    8010533c <alltraps>

80106192 <vector214>:
.globl vector214
vector214:
  pushl $0
80106192:	6a 00                	push   $0x0
  pushl $214
80106194:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106199:	e9 9e f1 ff ff       	jmp    8010533c <alltraps>

8010619e <vector215>:
.globl vector215
vector215:
  pushl $0
8010619e:	6a 00                	push   $0x0
  pushl $215
801061a0:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801061a5:	e9 92 f1 ff ff       	jmp    8010533c <alltraps>

801061aa <vector216>:
.globl vector216
vector216:
  pushl $0
801061aa:	6a 00                	push   $0x0
  pushl $216
801061ac:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801061b1:	e9 86 f1 ff ff       	jmp    8010533c <alltraps>

801061b6 <vector217>:
.globl vector217
vector217:
  pushl $0
801061b6:	6a 00                	push   $0x0
  pushl $217
801061b8:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801061bd:	e9 7a f1 ff ff       	jmp    8010533c <alltraps>

801061c2 <vector218>:
.globl vector218
vector218:
  pushl $0
801061c2:	6a 00                	push   $0x0
  pushl $218
801061c4:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801061c9:	e9 6e f1 ff ff       	jmp    8010533c <alltraps>

801061ce <vector219>:
.globl vector219
vector219:
  pushl $0
801061ce:	6a 00                	push   $0x0
  pushl $219
801061d0:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801061d5:	e9 62 f1 ff ff       	jmp    8010533c <alltraps>

801061da <vector220>:
.globl vector220
vector220:
  pushl $0
801061da:	6a 00                	push   $0x0
  pushl $220
801061dc:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801061e1:	e9 56 f1 ff ff       	jmp    8010533c <alltraps>

801061e6 <vector221>:
.globl vector221
vector221:
  pushl $0
801061e6:	6a 00                	push   $0x0
  pushl $221
801061e8:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801061ed:	e9 4a f1 ff ff       	jmp    8010533c <alltraps>

801061f2 <vector222>:
.globl vector222
vector222:
  pushl $0
801061f2:	6a 00                	push   $0x0
  pushl $222
801061f4:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801061f9:	e9 3e f1 ff ff       	jmp    8010533c <alltraps>

801061fe <vector223>:
.globl vector223
vector223:
  pushl $0
801061fe:	6a 00                	push   $0x0
  pushl $223
80106200:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106205:	e9 32 f1 ff ff       	jmp    8010533c <alltraps>

8010620a <vector224>:
.globl vector224
vector224:
  pushl $0
8010620a:	6a 00                	push   $0x0
  pushl $224
8010620c:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106211:	e9 26 f1 ff ff       	jmp    8010533c <alltraps>

80106216 <vector225>:
.globl vector225
vector225:
  pushl $0
80106216:	6a 00                	push   $0x0
  pushl $225
80106218:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010621d:	e9 1a f1 ff ff       	jmp    8010533c <alltraps>

80106222 <vector226>:
.globl vector226
vector226:
  pushl $0
80106222:	6a 00                	push   $0x0
  pushl $226
80106224:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106229:	e9 0e f1 ff ff       	jmp    8010533c <alltraps>

8010622e <vector227>:
.globl vector227
vector227:
  pushl $0
8010622e:	6a 00                	push   $0x0
  pushl $227
80106230:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106235:	e9 02 f1 ff ff       	jmp    8010533c <alltraps>

8010623a <vector228>:
.globl vector228
vector228:
  pushl $0
8010623a:	6a 00                	push   $0x0
  pushl $228
8010623c:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106241:	e9 f6 f0 ff ff       	jmp    8010533c <alltraps>

80106246 <vector229>:
.globl vector229
vector229:
  pushl $0
80106246:	6a 00                	push   $0x0
  pushl $229
80106248:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010624d:	e9 ea f0 ff ff       	jmp    8010533c <alltraps>

80106252 <vector230>:
.globl vector230
vector230:
  pushl $0
80106252:	6a 00                	push   $0x0
  pushl $230
80106254:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106259:	e9 de f0 ff ff       	jmp    8010533c <alltraps>

8010625e <vector231>:
.globl vector231
vector231:
  pushl $0
8010625e:	6a 00                	push   $0x0
  pushl $231
80106260:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106265:	e9 d2 f0 ff ff       	jmp    8010533c <alltraps>

8010626a <vector232>:
.globl vector232
vector232:
  pushl $0
8010626a:	6a 00                	push   $0x0
  pushl $232
8010626c:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106271:	e9 c6 f0 ff ff       	jmp    8010533c <alltraps>

80106276 <vector233>:
.globl vector233
vector233:
  pushl $0
80106276:	6a 00                	push   $0x0
  pushl $233
80106278:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010627d:	e9 ba f0 ff ff       	jmp    8010533c <alltraps>

80106282 <vector234>:
.globl vector234
vector234:
  pushl $0
80106282:	6a 00                	push   $0x0
  pushl $234
80106284:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106289:	e9 ae f0 ff ff       	jmp    8010533c <alltraps>

8010628e <vector235>:
.globl vector235
vector235:
  pushl $0
8010628e:	6a 00                	push   $0x0
  pushl $235
80106290:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106295:	e9 a2 f0 ff ff       	jmp    8010533c <alltraps>

8010629a <vector236>:
.globl vector236
vector236:
  pushl $0
8010629a:	6a 00                	push   $0x0
  pushl $236
8010629c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801062a1:	e9 96 f0 ff ff       	jmp    8010533c <alltraps>

801062a6 <vector237>:
.globl vector237
vector237:
  pushl $0
801062a6:	6a 00                	push   $0x0
  pushl $237
801062a8:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801062ad:	e9 8a f0 ff ff       	jmp    8010533c <alltraps>

801062b2 <vector238>:
.globl vector238
vector238:
  pushl $0
801062b2:	6a 00                	push   $0x0
  pushl $238
801062b4:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801062b9:	e9 7e f0 ff ff       	jmp    8010533c <alltraps>

801062be <vector239>:
.globl vector239
vector239:
  pushl $0
801062be:	6a 00                	push   $0x0
  pushl $239
801062c0:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801062c5:	e9 72 f0 ff ff       	jmp    8010533c <alltraps>

801062ca <vector240>:
.globl vector240
vector240:
  pushl $0
801062ca:	6a 00                	push   $0x0
  pushl $240
801062cc:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801062d1:	e9 66 f0 ff ff       	jmp    8010533c <alltraps>

801062d6 <vector241>:
.globl vector241
vector241:
  pushl $0
801062d6:	6a 00                	push   $0x0
  pushl $241
801062d8:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801062dd:	e9 5a f0 ff ff       	jmp    8010533c <alltraps>

801062e2 <vector242>:
.globl vector242
vector242:
  pushl $0
801062e2:	6a 00                	push   $0x0
  pushl $242
801062e4:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801062e9:	e9 4e f0 ff ff       	jmp    8010533c <alltraps>

801062ee <vector243>:
.globl vector243
vector243:
  pushl $0
801062ee:	6a 00                	push   $0x0
  pushl $243
801062f0:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801062f5:	e9 42 f0 ff ff       	jmp    8010533c <alltraps>

801062fa <vector244>:
.globl vector244
vector244:
  pushl $0
801062fa:	6a 00                	push   $0x0
  pushl $244
801062fc:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106301:	e9 36 f0 ff ff       	jmp    8010533c <alltraps>

80106306 <vector245>:
.globl vector245
vector245:
  pushl $0
80106306:	6a 00                	push   $0x0
  pushl $245
80106308:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010630d:	e9 2a f0 ff ff       	jmp    8010533c <alltraps>

80106312 <vector246>:
.globl vector246
vector246:
  pushl $0
80106312:	6a 00                	push   $0x0
  pushl $246
80106314:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106319:	e9 1e f0 ff ff       	jmp    8010533c <alltraps>

8010631e <vector247>:
.globl vector247
vector247:
  pushl $0
8010631e:	6a 00                	push   $0x0
  pushl $247
80106320:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106325:	e9 12 f0 ff ff       	jmp    8010533c <alltraps>

8010632a <vector248>:
.globl vector248
vector248:
  pushl $0
8010632a:	6a 00                	push   $0x0
  pushl $248
8010632c:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106331:	e9 06 f0 ff ff       	jmp    8010533c <alltraps>

80106336 <vector249>:
.globl vector249
vector249:
  pushl $0
80106336:	6a 00                	push   $0x0
  pushl $249
80106338:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010633d:	e9 fa ef ff ff       	jmp    8010533c <alltraps>

80106342 <vector250>:
.globl vector250
vector250:
  pushl $0
80106342:	6a 00                	push   $0x0
  pushl $250
80106344:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106349:	e9 ee ef ff ff       	jmp    8010533c <alltraps>

8010634e <vector251>:
.globl vector251
vector251:
  pushl $0
8010634e:	6a 00                	push   $0x0
  pushl $251
80106350:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106355:	e9 e2 ef ff ff       	jmp    8010533c <alltraps>

8010635a <vector252>:
.globl vector252
vector252:
  pushl $0
8010635a:	6a 00                	push   $0x0
  pushl $252
8010635c:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106361:	e9 d6 ef ff ff       	jmp    8010533c <alltraps>

80106366 <vector253>:
.globl vector253
vector253:
  pushl $0
80106366:	6a 00                	push   $0x0
  pushl $253
80106368:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010636d:	e9 ca ef ff ff       	jmp    8010533c <alltraps>

80106372 <vector254>:
.globl vector254
vector254:
  pushl $0
80106372:	6a 00                	push   $0x0
  pushl $254
80106374:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106379:	e9 be ef ff ff       	jmp    8010533c <alltraps>

8010637e <vector255>:
.globl vector255
vector255:
  pushl $0
8010637e:	6a 00                	push   $0x0
  pushl $255
80106380:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106385:	e9 b2 ef ff ff       	jmp    8010533c <alltraps>

8010638a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010638a:	55                   	push   %ebp
8010638b:	89 e5                	mov    %esp,%ebp
8010638d:	57                   	push   %edi
8010638e:	56                   	push   %esi
8010638f:	53                   	push   %ebx
80106390:	83 ec 0c             	sub    $0xc,%esp
80106393:	89 d3                	mov    %edx,%ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80106395:	c1 ea 16             	shr    $0x16,%edx
80106398:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
8010639b:	8b 37                	mov    (%edi),%esi
8010639d:	f7 c6 01 00 00 00    	test   $0x1,%esi
801063a3:	74 20                	je     801063c5 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801063a5:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
801063ab:	81 c6 00 00 00 80    	add    $0x80000000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
801063b1:	c1 eb 0c             	shr    $0xc,%ebx
801063b4:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
801063ba:	8d 04 9e             	lea    (%esi,%ebx,4),%eax
}
801063bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801063c0:	5b                   	pop    %ebx
801063c1:	5e                   	pop    %esi
801063c2:	5f                   	pop    %edi
801063c3:	5d                   	pop    %ebp
801063c4:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801063c5:	85 c9                	test   %ecx,%ecx
801063c7:	74 2b                	je     801063f4 <walkpgdir+0x6a>
801063c9:	e8 71 bc ff ff       	call   8010203f <kalloc>
801063ce:	89 c6                	mov    %eax,%esi
801063d0:	85 c0                	test   %eax,%eax
801063d2:	74 20                	je     801063f4 <walkpgdir+0x6a>
    memset(pgtab, 0, PGSIZE);
801063d4:	83 ec 04             	sub    $0x4,%esp
801063d7:	68 00 10 00 00       	push   $0x1000
801063dc:	6a 00                	push   $0x0
801063de:	50                   	push   %eax
801063df:	e8 17 dd ff ff       	call   801040fb <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801063e4:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
801063ea:	83 c8 07             	or     $0x7,%eax
801063ed:	89 07                	mov    %eax,(%edi)
801063ef:	83 c4 10             	add    $0x10,%esp
801063f2:	eb bd                	jmp    801063b1 <walkpgdir+0x27>
      return 0;
801063f4:	b8 00 00 00 00       	mov    $0x0,%eax
801063f9:	eb c2                	jmp    801063bd <walkpgdir+0x33>

801063fb <seginit>:
{
801063fb:	55                   	push   %ebp
801063fc:	89 e5                	mov    %esp,%ebp
801063fe:	57                   	push   %edi
801063ff:	56                   	push   %esi
80106400:	53                   	push   %ebx
80106401:	83 ec 2c             	sub    $0x2c,%esp
  c = &cpus[cpuid()];
80106404:	e8 05 ce ff ff       	call   8010320e <cpuid>
80106409:	89 c3                	mov    %eax,%ebx
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010640b:	8d 14 80             	lea    (%eax,%eax,4),%edx
8010640e:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
80106411:	8d 04 01             	lea    (%ecx,%eax,1),%eax
80106414:	c1 e0 04             	shl    $0x4,%eax
80106417:	66 c7 80 18 18 11 80 	movw   $0xffff,-0x7feee7e8(%eax)
8010641e:	ff ff 
80106420:	66 c7 80 1a 18 11 80 	movw   $0x0,-0x7feee7e6(%eax)
80106427:	00 00 
80106429:	c6 80 1c 18 11 80 00 	movb   $0x0,-0x7feee7e4(%eax)
80106430:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
80106433:	01 d9                	add    %ebx,%ecx
80106435:	c1 e1 04             	shl    $0x4,%ecx
80106438:	0f b6 b1 1d 18 11 80 	movzbl -0x7feee7e3(%ecx),%esi
8010643f:	83 e6 f0             	and    $0xfffffff0,%esi
80106442:	89 f7                	mov    %esi,%edi
80106444:	83 cf 0a             	or     $0xa,%edi
80106447:	89 fa                	mov    %edi,%edx
80106449:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
8010644f:	83 ce 1a             	or     $0x1a,%esi
80106452:	89 f2                	mov    %esi,%edx
80106454:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
8010645a:	83 e6 9f             	and    $0xffffff9f,%esi
8010645d:	89 f2                	mov    %esi,%edx
8010645f:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
80106465:	83 ce 80             	or     $0xffffff80,%esi
80106468:	89 f2                	mov    %esi,%edx
8010646a:	88 91 1d 18 11 80    	mov    %dl,-0x7feee7e3(%ecx)
80106470:	0f b6 b1 1e 18 11 80 	movzbl -0x7feee7e2(%ecx),%esi
80106477:	83 ce 0f             	or     $0xf,%esi
8010647a:	89 f2                	mov    %esi,%edx
8010647c:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
80106482:	89 f7                	mov    %esi,%edi
80106484:	83 e7 ef             	and    $0xffffffef,%edi
80106487:	89 fa                	mov    %edi,%edx
80106489:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
8010648f:	83 e6 cf             	and    $0xffffffcf,%esi
80106492:	89 f2                	mov    %esi,%edx
80106494:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
8010649a:	89 f7                	mov    %esi,%edi
8010649c:	83 cf 40             	or     $0x40,%edi
8010649f:	89 fa                	mov    %edi,%edx
801064a1:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
801064a7:	83 ce c0             	or     $0xffffffc0,%esi
801064aa:	89 f2                	mov    %esi,%edx
801064ac:	88 91 1e 18 11 80    	mov    %dl,-0x7feee7e2(%ecx)
801064b2:	c6 80 1f 18 11 80 00 	movb   $0x0,-0x7feee7e1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801064b9:	66 c7 80 20 18 11 80 	movw   $0xffff,-0x7feee7e0(%eax)
801064c0:	ff ff 
801064c2:	66 c7 80 22 18 11 80 	movw   $0x0,-0x7feee7de(%eax)
801064c9:	00 00 
801064cb:	c6 80 24 18 11 80 00 	movb   $0x0,-0x7feee7dc(%eax)
801064d2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801064d5:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
801064d8:	c1 e1 04             	shl    $0x4,%ecx
801064db:	0f b6 b1 25 18 11 80 	movzbl -0x7feee7db(%ecx),%esi
801064e2:	83 e6 f0             	and    $0xfffffff0,%esi
801064e5:	89 f7                	mov    %esi,%edi
801064e7:	83 cf 02             	or     $0x2,%edi
801064ea:	89 fa                	mov    %edi,%edx
801064ec:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
801064f2:	83 ce 12             	or     $0x12,%esi
801064f5:	89 f2                	mov    %esi,%edx
801064f7:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
801064fd:	83 e6 9f             	and    $0xffffff9f,%esi
80106500:	89 f2                	mov    %esi,%edx
80106502:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
80106508:	83 ce 80             	or     $0xffffff80,%esi
8010650b:	89 f2                	mov    %esi,%edx
8010650d:	88 91 25 18 11 80    	mov    %dl,-0x7feee7db(%ecx)
80106513:	0f b6 b1 26 18 11 80 	movzbl -0x7feee7da(%ecx),%esi
8010651a:	83 ce 0f             	or     $0xf,%esi
8010651d:	89 f2                	mov    %esi,%edx
8010651f:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
80106525:	89 f7                	mov    %esi,%edi
80106527:	83 e7 ef             	and    $0xffffffef,%edi
8010652a:	89 fa                	mov    %edi,%edx
8010652c:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
80106532:	83 e6 cf             	and    $0xffffffcf,%esi
80106535:	89 f2                	mov    %esi,%edx
80106537:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
8010653d:	89 f7                	mov    %esi,%edi
8010653f:	83 cf 40             	or     $0x40,%edi
80106542:	89 fa                	mov    %edi,%edx
80106544:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
8010654a:	83 ce c0             	or     $0xffffffc0,%esi
8010654d:	89 f2                	mov    %esi,%edx
8010654f:	88 91 26 18 11 80    	mov    %dl,-0x7feee7da(%ecx)
80106555:	c6 80 27 18 11 80 00 	movb   $0x0,-0x7feee7d9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010655c:	66 c7 80 28 18 11 80 	movw   $0xffff,-0x7feee7d8(%eax)
80106563:	ff ff 
80106565:	66 c7 80 2a 18 11 80 	movw   $0x0,-0x7feee7d6(%eax)
8010656c:	00 00 
8010656e:	c6 80 2c 18 11 80 00 	movb   $0x0,-0x7feee7d4(%eax)
80106575:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80106578:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
8010657b:	c1 e1 04             	shl    $0x4,%ecx
8010657e:	0f b6 b1 2d 18 11 80 	movzbl -0x7feee7d3(%ecx),%esi
80106585:	83 e6 f0             	and    $0xfffffff0,%esi
80106588:	89 f7                	mov    %esi,%edi
8010658a:	83 cf 0a             	or     $0xa,%edi
8010658d:	89 fa                	mov    %edi,%edx
8010658f:	88 91 2d 18 11 80    	mov    %dl,-0x7feee7d3(%ecx)
80106595:	89 f7                	mov    %esi,%edi
80106597:	83 cf 1a             	or     $0x1a,%edi
8010659a:	89 fa                	mov    %edi,%edx
8010659c:	88 91 2d 18 11 80    	mov    %dl,-0x7feee7d3(%ecx)
801065a2:	83 ce 7a             	or     $0x7a,%esi
801065a5:	89 f2                	mov    %esi,%edx
801065a7:	88 91 2d 18 11 80    	mov    %dl,-0x7feee7d3(%ecx)
801065ad:	c6 81 2d 18 11 80 fa 	movb   $0xfa,-0x7feee7d3(%ecx)
801065b4:	0f b6 b1 2e 18 11 80 	movzbl -0x7feee7d2(%ecx),%esi
801065bb:	83 ce 0f             	or     $0xf,%esi
801065be:	89 f2                	mov    %esi,%edx
801065c0:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
801065c6:	89 f7                	mov    %esi,%edi
801065c8:	83 e7 ef             	and    $0xffffffef,%edi
801065cb:	89 fa                	mov    %edi,%edx
801065cd:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
801065d3:	83 e6 cf             	and    $0xffffffcf,%esi
801065d6:	89 f2                	mov    %esi,%edx
801065d8:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
801065de:	89 f7                	mov    %esi,%edi
801065e0:	83 cf 40             	or     $0x40,%edi
801065e3:	89 fa                	mov    %edi,%edx
801065e5:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
801065eb:	83 ce c0             	or     $0xffffffc0,%esi
801065ee:	89 f2                	mov    %esi,%edx
801065f0:	88 91 2e 18 11 80    	mov    %dl,-0x7feee7d2(%ecx)
801065f6:	c6 80 2f 18 11 80 00 	movb   $0x0,-0x7feee7d1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801065fd:	66 c7 80 30 18 11 80 	movw   $0xffff,-0x7feee7d0(%eax)
80106604:	ff ff 
80106606:	66 c7 80 32 18 11 80 	movw   $0x0,-0x7feee7ce(%eax)
8010660d:	00 00 
8010660f:	c6 80 34 18 11 80 00 	movb   $0x0,-0x7feee7cc(%eax)
80106616:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80106619:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
8010661c:	c1 e1 04             	shl    $0x4,%ecx
8010661f:	0f b6 b1 35 18 11 80 	movzbl -0x7feee7cb(%ecx),%esi
80106626:	83 e6 f0             	and    $0xfffffff0,%esi
80106629:	89 f7                	mov    %esi,%edi
8010662b:	83 cf 02             	or     $0x2,%edi
8010662e:	89 fa                	mov    %edi,%edx
80106630:	88 91 35 18 11 80    	mov    %dl,-0x7feee7cb(%ecx)
80106636:	89 f7                	mov    %esi,%edi
80106638:	83 cf 12             	or     $0x12,%edi
8010663b:	89 fa                	mov    %edi,%edx
8010663d:	88 91 35 18 11 80    	mov    %dl,-0x7feee7cb(%ecx)
80106643:	83 ce 72             	or     $0x72,%esi
80106646:	89 f2                	mov    %esi,%edx
80106648:	88 91 35 18 11 80    	mov    %dl,-0x7feee7cb(%ecx)
8010664e:	c6 81 35 18 11 80 f2 	movb   $0xf2,-0x7feee7cb(%ecx)
80106655:	0f b6 b1 36 18 11 80 	movzbl -0x7feee7ca(%ecx),%esi
8010665c:	83 ce 0f             	or     $0xf,%esi
8010665f:	89 f2                	mov    %esi,%edx
80106661:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
80106667:	89 f7                	mov    %esi,%edi
80106669:	83 e7 ef             	and    $0xffffffef,%edi
8010666c:	89 fa                	mov    %edi,%edx
8010666e:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
80106674:	83 e6 cf             	and    $0xffffffcf,%esi
80106677:	89 f2                	mov    %esi,%edx
80106679:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
8010667f:	89 f7                	mov    %esi,%edi
80106681:	83 cf 40             	or     $0x40,%edi
80106684:	89 fa                	mov    %edi,%edx
80106686:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
8010668c:	83 ce c0             	or     $0xffffffc0,%esi
8010668f:	89 f2                	mov    %esi,%edx
80106691:	88 91 36 18 11 80    	mov    %dl,-0x7feee7ca(%ecx)
80106697:	c6 80 37 18 11 80 00 	movb   $0x0,-0x7feee7c9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010669e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801066a1:	01 da                	add    %ebx,%edx
801066a3:	c1 e2 04             	shl    $0x4,%edx
801066a6:	81 c2 10 18 11 80    	add    $0x80111810,%edx
  pd[0] = size-1;
801066ac:	66 c7 45 e2 2f 00    	movw   $0x2f,-0x1e(%ebp)
  pd[1] = (uint)p;
801066b2:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
  pd[2] = (uint)p >> 16;
801066b6:	c1 ea 10             	shr    $0x10,%edx
801066b9:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801066bd:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801066c0:	0f 01 10             	lgdtl  (%eax)
}
801066c3:	83 c4 2c             	add    $0x2c,%esp
801066c6:	5b                   	pop    %ebx
801066c7:	5e                   	pop    %esi
801066c8:	5f                   	pop    %edi
801066c9:	5d                   	pop    %ebp
801066ca:	c3                   	ret    

801066cb <page_fault_error>:
// are set
// Return an "uint" value with the flags activated in the entry
// of address in the page table
uint
page_fault_error(pde_t *pgdir, uint va)
{
801066cb:	55                   	push   %ebp
801066cc:	89 e5                	mov    %esp,%ebp
801066ce:	83 ec 08             	sub    $0x8,%esp
	uint error;
  char *a;
  pte_t *pte;

  a = (char*)PGROUNDDOWN(va);
801066d1:	8b 55 0c             	mov    0xc(%ebp),%edx
801066d4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  if( (pte = walkpgdir(pgdir, a, 0)) == 0){
801066da:	b9 00 00 00 00       	mov    $0x0,%ecx
801066df:	8b 45 08             	mov    0x8(%ebp),%eax
801066e2:	e8 a3 fc ff ff       	call   8010638a <walkpgdir>
801066e7:	85 c0                	test   %eax,%eax
801066e9:	74 07                	je     801066f2 <page_fault_error+0x27>
    //Si la página que se busca no está mapeada, se devuelve
		//0 para que sea concedida
		return 0;
	}
		
	error = *pte & 0x7;
801066eb:	8b 00                	mov    (%eax),%eax
801066ed:	83 e0 07             	and    $0x7,%eax
	
  return error;
}
801066f0:	c9                   	leave  
801066f1:	c3                   	ret    
		return 0;
801066f2:	b8 00 00 00 00       	mov    $0x0,%eax
801066f7:	eb f7                	jmp    801066f0 <page_fault_error+0x25>

801066f9 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801066f9:	55                   	push   %ebp
801066fa:	89 e5                	mov    %esp,%ebp
801066fc:	57                   	push   %edi
801066fd:	56                   	push   %esi
801066fe:	53                   	push   %ebx
801066ff:	83 ec 0c             	sub    $0xc,%esp
80106702:	8b 7d 0c             	mov    0xc(%ebp),%edi
80106705:	8b 75 14             	mov    0x14(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80106708:	89 fb                	mov    %edi,%ebx
8010670a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106710:	03 7d 10             	add    0x10(%ebp),%edi
80106713:	4f                   	dec    %edi
80106714:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010671a:	b9 01 00 00 00       	mov    $0x1,%ecx
8010671f:	89 da                	mov    %ebx,%edx
80106721:	8b 45 08             	mov    0x8(%ebp),%eax
80106724:	e8 61 fc ff ff       	call   8010638a <walkpgdir>
80106729:	85 c0                	test   %eax,%eax
8010672b:	74 2e                	je     8010675b <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
8010672d:	f6 00 01             	testb  $0x1,(%eax)
80106730:	75 1c                	jne    8010674e <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80106732:	89 f2                	mov    %esi,%edx
80106734:	0b 55 18             	or     0x18(%ebp),%edx
80106737:	83 ca 01             	or     $0x1,%edx
8010673a:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010673c:	39 fb                	cmp    %edi,%ebx
8010673e:	74 28                	je     80106768 <mappages+0x6f>
      break;
    a += PGSIZE;
80106740:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80106746:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010674c:	eb cc                	jmp    8010671a <mappages+0x21>
      panic("remap");
8010674e:	83 ec 0c             	sub    $0xc,%esp
80106751:	68 bc 79 10 80       	push   $0x801079bc
80106756:	e8 e6 9b ff ff       	call   80100341 <panic>
      return -1;
8010675b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80106760:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106763:	5b                   	pop    %ebx
80106764:	5e                   	pop    %esi
80106765:	5f                   	pop    %edi
80106766:	5d                   	pop    %ebp
80106767:	c3                   	ret    
  return 0;
80106768:	b8 00 00 00 00       	mov    $0x0,%eax
8010676d:	eb f1                	jmp    80106760 <mappages+0x67>

8010676f <switchkvm>:
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010676f:	a1 c4 47 11 80       	mov    0x801147c4,%eax
80106774:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106779:	0f 22 d8             	mov    %eax,%cr3
}
8010677c:	c3                   	ret    

8010677d <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010677d:	55                   	push   %ebp
8010677e:	89 e5                	mov    %esp,%ebp
80106780:	57                   	push   %edi
80106781:	56                   	push   %esi
80106782:	53                   	push   %ebx
80106783:	83 ec 1c             	sub    $0x1c,%esp
80106786:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80106789:	85 f6                	test   %esi,%esi
8010678b:	0f 84 21 01 00 00    	je     801068b2 <switchuvm+0x135>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80106791:	83 7e 10 00          	cmpl   $0x0,0x10(%esi)
80106795:	0f 84 24 01 00 00    	je     801068bf <switchuvm+0x142>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
8010679b:	83 7e 0c 00          	cmpl   $0x0,0xc(%esi)
8010679f:	0f 84 27 01 00 00    	je     801068cc <switchuvm+0x14f>
    panic("switchuvm: no pgdir");

  pushcli();
801067a5:	e8 cb d7 ff ff       	call   80103f75 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801067aa:	e8 fb c9 ff ff       	call   801031aa <mycpu>
801067af:	89 c3                	mov    %eax,%ebx
801067b1:	e8 f4 c9 ff ff       	call   801031aa <mycpu>
801067b6:	8d 78 08             	lea    0x8(%eax),%edi
801067b9:	e8 ec c9 ff ff       	call   801031aa <mycpu>
801067be:	83 c0 08             	add    $0x8,%eax
801067c1:	c1 e8 10             	shr    $0x10,%eax
801067c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801067c7:	e8 de c9 ff ff       	call   801031aa <mycpu>
801067cc:	83 c0 08             	add    $0x8,%eax
801067cf:	c1 e8 18             	shr    $0x18,%eax
801067d2:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801067d9:	67 00 
801067db:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
801067e2:	8a 4d e4             	mov    -0x1c(%ebp),%cl
801067e5:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
801067eb:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
801067f1:	83 e2 f0             	and    $0xfffffff0,%edx
801067f4:	88 d1                	mov    %dl,%cl
801067f6:	83 c9 09             	or     $0x9,%ecx
801067f9:	88 8b 9d 00 00 00    	mov    %cl,0x9d(%ebx)
801067ff:	83 ca 19             	or     $0x19,%edx
80106802:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106808:	83 e2 9f             	and    $0xffffff9f,%edx
8010680b:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106811:	83 ca 80             	or     $0xffffff80,%edx
80106814:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010681a:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80106820:	88 d1                	mov    %dl,%cl
80106822:	83 e1 f0             	and    $0xfffffff0,%ecx
80106825:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
8010682b:	88 d1                	mov    %dl,%cl
8010682d:	83 e1 e0             	and    $0xffffffe0,%ecx
80106830:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
80106836:	83 e2 c0             	and    $0xffffffc0,%edx
80106839:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010683f:	83 ca 40             	or     $0x40,%edx
80106842:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80106848:	83 e2 7f             	and    $0x7f,%edx
8010684b:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80106851:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80106857:	e8 4e c9 ff ff       	call   801031aa <mycpu>
8010685c:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80106862:	83 e2 ef             	and    $0xffffffef,%edx
80106865:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010686b:	e8 3a c9 ff ff       	call   801031aa <mycpu>
80106870:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106876:	8b 5e 10             	mov    0x10(%esi),%ebx
80106879:	e8 2c c9 ff ff       	call   801031aa <mycpu>
8010687e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106884:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106887:	e8 1e c9 ff ff       	call   801031aa <mycpu>
8010688c:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106892:	b8 28 00 00 00       	mov    $0x28,%eax
80106897:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010689a:	8b 46 0c             	mov    0xc(%esi),%eax
8010689d:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801068a2:	0f 22 d8             	mov    %eax,%cr3
  popcli();
801068a5:	e8 06 d7 ff ff       	call   80103fb0 <popcli>
}
801068aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
801068ad:	5b                   	pop    %ebx
801068ae:	5e                   	pop    %esi
801068af:	5f                   	pop    %edi
801068b0:	5d                   	pop    %ebp
801068b1:	c3                   	ret    
    panic("switchuvm: no process");
801068b2:	83 ec 0c             	sub    $0xc,%esp
801068b5:	68 c2 79 10 80       	push   $0x801079c2
801068ba:	e8 82 9a ff ff       	call   80100341 <panic>
    panic("switchuvm: no kstack");
801068bf:	83 ec 0c             	sub    $0xc,%esp
801068c2:	68 d8 79 10 80       	push   $0x801079d8
801068c7:	e8 75 9a ff ff       	call   80100341 <panic>
    panic("switchuvm: no pgdir");
801068cc:	83 ec 0c             	sub    $0xc,%esp
801068cf:	68 ed 79 10 80       	push   $0x801079ed
801068d4:	e8 68 9a ff ff       	call   80100341 <panic>

801068d9 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801068d9:	55                   	push   %ebp
801068da:	89 e5                	mov    %esp,%ebp
801068dc:	56                   	push   %esi
801068dd:	53                   	push   %ebx
801068de:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
801068e1:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801068e7:	77 4b                	ja     80106934 <inituvm+0x5b>
    panic("inituvm: more than a page");
  mem = kalloc();
801068e9:	e8 51 b7 ff ff       	call   8010203f <kalloc>
801068ee:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
801068f0:	83 ec 04             	sub    $0x4,%esp
801068f3:	68 00 10 00 00       	push   $0x1000
801068f8:	6a 00                	push   $0x0
801068fa:	50                   	push   %eax
801068fb:	e8 fb d7 ff ff       	call   801040fb <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106900:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
80106907:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010690d:	50                   	push   %eax
8010690e:	68 00 10 00 00       	push   $0x1000
80106913:	6a 00                	push   $0x0
80106915:	ff 75 08             	push   0x8(%ebp)
80106918:	e8 dc fd ff ff       	call   801066f9 <mappages>
  memmove(mem, init, sz);
8010691d:	83 c4 1c             	add    $0x1c,%esp
80106920:	56                   	push   %esi
80106921:	ff 75 0c             	push   0xc(%ebp)
80106924:	53                   	push   %ebx
80106925:	e8 47 d8 ff ff       	call   80104171 <memmove>
}
8010692a:	83 c4 10             	add    $0x10,%esp
8010692d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106930:	5b                   	pop    %ebx
80106931:	5e                   	pop    %esi
80106932:	5d                   	pop    %ebp
80106933:	c3                   	ret    
    panic("inituvm: more than a page");
80106934:	83 ec 0c             	sub    $0xc,%esp
80106937:	68 01 7a 10 80       	push   $0x80107a01
8010693c:	e8 00 9a ff ff       	call   80100341 <panic>

80106941 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106941:	55                   	push   %ebp
80106942:	89 e5                	mov    %esp,%ebp
80106944:	57                   	push   %edi
80106945:	56                   	push   %esi
80106946:	53                   	push   %ebx
80106947:	83 ec 0c             	sub    $0xc,%esp
8010694a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010694d:	89 fb                	mov    %edi,%ebx
8010694f:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
80106955:	74 3c                	je     80106993 <loaduvm+0x52>
    panic("loaduvm: addr must be page aligned");
80106957:	83 ec 0c             	sub    $0xc,%esp
8010695a:	68 bc 7a 10 80       	push   $0x80107abc
8010695f:	e8 dd 99 ff ff       	call   80100341 <panic>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106964:	83 ec 0c             	sub    $0xc,%esp
80106967:	68 1b 7a 10 80       	push   $0x80107a1b
8010696c:	e8 d0 99 ff ff       	call   80100341 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106971:	05 00 00 00 80       	add    $0x80000000,%eax
80106976:	56                   	push   %esi
80106977:	89 da                	mov    %ebx,%edx
80106979:	03 55 14             	add    0x14(%ebp),%edx
8010697c:	52                   	push   %edx
8010697d:	50                   	push   %eax
8010697e:	ff 75 10             	push   0x10(%ebp)
80106981:	e8 85 ad ff ff       	call   8010170b <readi>
80106986:	83 c4 10             	add    $0x10,%esp
80106989:	39 f0                	cmp    %esi,%eax
8010698b:	75 47                	jne    801069d4 <loaduvm+0x93>
  for(i = 0; i < sz; i += PGSIZE){
8010698d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106993:	3b 5d 18             	cmp    0x18(%ebp),%ebx
80106996:	73 2f                	jae    801069c7 <loaduvm+0x86>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106998:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
8010699b:	b9 00 00 00 00       	mov    $0x0,%ecx
801069a0:	8b 45 08             	mov    0x8(%ebp),%eax
801069a3:	e8 e2 f9 ff ff       	call   8010638a <walkpgdir>
801069a8:	85 c0                	test   %eax,%eax
801069aa:	74 b8                	je     80106964 <loaduvm+0x23>
    pa = PTE_ADDR(*pte);
801069ac:	8b 00                	mov    (%eax),%eax
801069ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801069b3:	8b 75 18             	mov    0x18(%ebp),%esi
801069b6:	29 de                	sub    %ebx,%esi
801069b8:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801069be:	76 b1                	jbe    80106971 <loaduvm+0x30>
      n = PGSIZE;
801069c0:	be 00 10 00 00       	mov    $0x1000,%esi
801069c5:	eb aa                	jmp    80106971 <loaduvm+0x30>
      return -1;
  }
  return 0;
801069c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801069cf:	5b                   	pop    %ebx
801069d0:	5e                   	pop    %esi
801069d1:	5f                   	pop    %edi
801069d2:	5d                   	pop    %ebp
801069d3:	c3                   	ret    
      return -1;
801069d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069d9:	eb f1                	jmp    801069cc <loaduvm+0x8b>

801069db <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801069db:	55                   	push   %ebp
801069dc:	89 e5                	mov    %esp,%ebp
801069de:	57                   	push   %edi
801069df:	56                   	push   %esi
801069e0:	53                   	push   %ebx
801069e1:	83 ec 0c             	sub    $0xc,%esp
801069e4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801069e7:	39 7d 10             	cmp    %edi,0x10(%ebp)
801069ea:	73 11                	jae    801069fd <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
801069ec:	8b 45 10             	mov    0x10(%ebp),%eax
801069ef:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801069f5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801069fb:	eb 17                	jmp    80106a14 <deallocuvm+0x39>
    return oldsz;
801069fd:	89 f8                	mov    %edi,%eax
801069ff:	eb 62                	jmp    80106a63 <deallocuvm+0x88>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106a01:	c1 eb 16             	shr    $0x16,%ebx
80106a04:	43                   	inc    %ebx
80106a05:	c1 e3 16             	shl    $0x16,%ebx
80106a08:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106a0e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106a14:	39 fb                	cmp    %edi,%ebx
80106a16:	73 48                	jae    80106a60 <deallocuvm+0x85>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106a18:	b9 00 00 00 00       	mov    $0x0,%ecx
80106a1d:	89 da                	mov    %ebx,%edx
80106a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80106a22:	e8 63 f9 ff ff       	call   8010638a <walkpgdir>
80106a27:	89 c6                	mov    %eax,%esi
    if(!pte)
80106a29:	85 c0                	test   %eax,%eax
80106a2b:	74 d4                	je     80106a01 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
80106a2d:	8b 00                	mov    (%eax),%eax
80106a2f:	a8 01                	test   $0x1,%al
80106a31:	74 db                	je     80106a0e <deallocuvm+0x33>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106a33:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106a38:	74 19                	je     80106a53 <deallocuvm+0x78>
        panic("kfree");
      char *v = P2V(pa);
80106a3a:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106a3f:	83 ec 0c             	sub    $0xc,%esp
80106a42:	50                   	push   %eax
80106a43:	e8 e0 b4 ff ff       	call   80101f28 <kfree>
      *pte = 0;
80106a48:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80106a4e:	83 c4 10             	add    $0x10,%esp
80106a51:	eb bb                	jmp    80106a0e <deallocuvm+0x33>
        panic("kfree");
80106a53:	83 ec 0c             	sub    $0xc,%esp
80106a56:	68 66 71 10 80       	push   $0x80107166
80106a5b:	e8 e1 98 ff ff       	call   80100341 <panic>
    }
  }
  return newsz;
80106a60:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106a63:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106a66:	5b                   	pop    %ebx
80106a67:	5e                   	pop    %esi
80106a68:	5f                   	pop    %edi
80106a69:	5d                   	pop    %ebp
80106a6a:	c3                   	ret    

80106a6b <allocuvm>:
{
80106a6b:	55                   	push   %ebp
80106a6c:	89 e5                	mov    %esp,%ebp
80106a6e:	57                   	push   %edi
80106a6f:	56                   	push   %esi
80106a70:	53                   	push   %ebx
80106a71:	83 ec 1c             	sub    $0x1c,%esp
80106a74:	8b 7d 08             	mov    0x8(%ebp),%edi
  if(newsz >= KERNBASE)
80106a77:	8b 45 10             	mov    0x10(%ebp),%eax
80106a7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106a7d:	85 c0                	test   %eax,%eax
80106a7f:	0f 88 c1 00 00 00    	js     80106b46 <allocuvm+0xdb>
  if(newsz < oldsz)
80106a85:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a88:	39 45 10             	cmp    %eax,0x10(%ebp)
80106a8b:	72 5c                	jb     80106ae9 <allocuvm+0x7e>
  a = PGROUNDUP(oldsz);
80106a8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a90:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
80106a96:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
80106a9c:	3b 75 10             	cmp    0x10(%ebp),%esi
80106a9f:	0f 83 a8 00 00 00    	jae    80106b4d <allocuvm+0xe2>
    mem = kalloc();
80106aa5:	e8 95 b5 ff ff       	call   8010203f <kalloc>
80106aaa:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80106aac:	85 c0                	test   %eax,%eax
80106aae:	74 3e                	je     80106aee <allocuvm+0x83>
    memset(mem, 0, PGSIZE);
80106ab0:	83 ec 04             	sub    $0x4,%esp
80106ab3:	68 00 10 00 00       	push   $0x1000
80106ab8:	6a 00                	push   $0x0
80106aba:	50                   	push   %eax
80106abb:	e8 3b d6 ff ff       	call   801040fb <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106ac0:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
80106ac7:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106acd:	50                   	push   %eax
80106ace:	68 00 10 00 00       	push   $0x1000
80106ad3:	56                   	push   %esi
80106ad4:	57                   	push   %edi
80106ad5:	e8 1f fc ff ff       	call   801066f9 <mappages>
80106ada:	83 c4 20             	add    $0x20,%esp
80106add:	85 c0                	test   %eax,%eax
80106adf:	78 35                	js     80106b16 <allocuvm+0xab>
  for(; a < newsz; a += PGSIZE){
80106ae1:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106ae7:	eb b3                	jmp    80106a9c <allocuvm+0x31>
    return oldsz;
80106ae9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106aec:	eb 5f                	jmp    80106b4d <allocuvm+0xe2>
      cprintf("allocuvm out of memory\n");
80106aee:	83 ec 0c             	sub    $0xc,%esp
80106af1:	68 39 7a 10 80       	push   $0x80107a39
80106af6:	e8 df 9a ff ff       	call   801005da <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106afb:	83 c4 0c             	add    $0xc,%esp
80106afe:	ff 75 0c             	push   0xc(%ebp)
80106b01:	ff 75 10             	push   0x10(%ebp)
80106b04:	57                   	push   %edi
80106b05:	e8 d1 fe ff ff       	call   801069db <deallocuvm>
      return 0;
80106b0a:	83 c4 10             	add    $0x10,%esp
80106b0d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106b14:	eb 37                	jmp    80106b4d <allocuvm+0xe2>
      cprintf("allocuvm out of memory (2)\n");
80106b16:	83 ec 0c             	sub    $0xc,%esp
80106b19:	68 51 7a 10 80       	push   $0x80107a51
80106b1e:	e8 b7 9a ff ff       	call   801005da <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106b23:	83 c4 0c             	add    $0xc,%esp
80106b26:	ff 75 0c             	push   0xc(%ebp)
80106b29:	ff 75 10             	push   0x10(%ebp)
80106b2c:	57                   	push   %edi
80106b2d:	e8 a9 fe ff ff       	call   801069db <deallocuvm>
      kfree(mem);
80106b32:	89 1c 24             	mov    %ebx,(%esp)
80106b35:	e8 ee b3 ff ff       	call   80101f28 <kfree>
      return 0;
80106b3a:	83 c4 10             	add    $0x10,%esp
80106b3d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106b44:	eb 07                	jmp    80106b4d <allocuvm+0xe2>
    return 0;
80106b46:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106b4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106b53:	5b                   	pop    %ebx
80106b54:	5e                   	pop    %esi
80106b55:	5f                   	pop    %edi
80106b56:	5d                   	pop    %ebp
80106b57:	c3                   	ret    

80106b58 <freevm>:

// Free a page table and all the physical memory pages
// in the user part if dodeallocuvm is not zero
void
freevm(pde_t *pgdir, int dodeallocuvm)
{
80106b58:	55                   	push   %ebp
80106b59:	89 e5                	mov    %esp,%ebp
80106b5b:	56                   	push   %esi
80106b5c:	53                   	push   %ebx
80106b5d:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106b60:	85 f6                	test   %esi,%esi
80106b62:	74 0d                	je     80106b71 <freevm+0x19>
    panic("freevm: no pgdir");
  if (dodeallocuvm)
80106b64:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106b68:	75 14                	jne    80106b7e <freevm+0x26>
{
80106b6a:	bb 00 00 00 00       	mov    $0x0,%ebx
80106b6f:	eb 23                	jmp    80106b94 <freevm+0x3c>
    panic("freevm: no pgdir");
80106b71:	83 ec 0c             	sub    $0xc,%esp
80106b74:	68 6d 7a 10 80       	push   $0x80107a6d
80106b79:	e8 c3 97 ff ff       	call   80100341 <panic>
    deallocuvm(pgdir, KERNBASE, 0);
80106b7e:	83 ec 04             	sub    $0x4,%esp
80106b81:	6a 00                	push   $0x0
80106b83:	68 00 00 00 80       	push   $0x80000000
80106b88:	56                   	push   %esi
80106b89:	e8 4d fe ff ff       	call   801069db <deallocuvm>
80106b8e:	83 c4 10             	add    $0x10,%esp
80106b91:	eb d7                	jmp    80106b6a <freevm+0x12>
  for(i = 0; i < NPDENTRIES; i++){
80106b93:	43                   	inc    %ebx
80106b94:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106b9a:	77 1f                	ja     80106bbb <freevm+0x63>
    if(pgdir[i] & PTE_P){
80106b9c:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
80106b9f:	a8 01                	test   $0x1,%al
80106ba1:	74 f0                	je     80106b93 <freevm+0x3b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80106ba3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106ba8:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106bad:	83 ec 0c             	sub    $0xc,%esp
80106bb0:	50                   	push   %eax
80106bb1:	e8 72 b3 ff ff       	call   80101f28 <kfree>
80106bb6:	83 c4 10             	add    $0x10,%esp
80106bb9:	eb d8                	jmp    80106b93 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80106bbb:	83 ec 0c             	sub    $0xc,%esp
80106bbe:	56                   	push   %esi
80106bbf:	e8 64 b3 ff ff       	call   80101f28 <kfree>
}
80106bc4:	83 c4 10             	add    $0x10,%esp
80106bc7:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106bca:	5b                   	pop    %ebx
80106bcb:	5e                   	pop    %esi
80106bcc:	5d                   	pop    %ebp
80106bcd:	c3                   	ret    

80106bce <setupkvm>:
{
80106bce:	55                   	push   %ebp
80106bcf:	89 e5                	mov    %esp,%ebp
80106bd1:	56                   	push   %esi
80106bd2:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80106bd3:	e8 67 b4 ff ff       	call   8010203f <kalloc>
80106bd8:	89 c6                	mov    %eax,%esi
80106bda:	85 c0                	test   %eax,%eax
80106bdc:	74 57                	je     80106c35 <setupkvm+0x67>
  memset(pgdir, 0, PGSIZE);
80106bde:	83 ec 04             	sub    $0x4,%esp
80106be1:	68 00 10 00 00       	push   $0x1000
80106be6:	6a 00                	push   $0x0
80106be8:	50                   	push   %eax
80106be9:	e8 0d d5 ff ff       	call   801040fb <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106bee:	83 c4 10             	add    $0x10,%esp
80106bf1:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
80106bf6:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106bfc:	73 37                	jae    80106c35 <setupkvm+0x67>
                (uint)k->phys_start, k->perm) < 0) {
80106bfe:	8b 53 04             	mov    0x4(%ebx),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106c01:	83 ec 0c             	sub    $0xc,%esp
80106c04:	ff 73 0c             	push   0xc(%ebx)
80106c07:	52                   	push   %edx
80106c08:	8b 43 08             	mov    0x8(%ebx),%eax
80106c0b:	29 d0                	sub    %edx,%eax
80106c0d:	50                   	push   %eax
80106c0e:	ff 33                	push   (%ebx)
80106c10:	56                   	push   %esi
80106c11:	e8 e3 fa ff ff       	call   801066f9 <mappages>
80106c16:	83 c4 20             	add    $0x20,%esp
80106c19:	85 c0                	test   %eax,%eax
80106c1b:	78 05                	js     80106c22 <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106c1d:	83 c3 10             	add    $0x10,%ebx
80106c20:	eb d4                	jmp    80106bf6 <setupkvm+0x28>
      freevm(pgdir, 0);
80106c22:	83 ec 08             	sub    $0x8,%esp
80106c25:	6a 00                	push   $0x0
80106c27:	56                   	push   %esi
80106c28:	e8 2b ff ff ff       	call   80106b58 <freevm>
      return 0;
80106c2d:	83 c4 10             	add    $0x10,%esp
80106c30:	be 00 00 00 00       	mov    $0x0,%esi
}
80106c35:	89 f0                	mov    %esi,%eax
80106c37:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106c3a:	5b                   	pop    %ebx
80106c3b:	5e                   	pop    %esi
80106c3c:	5d                   	pop    %ebp
80106c3d:	c3                   	ret    

80106c3e <kvmalloc>:
{
80106c3e:	55                   	push   %ebp
80106c3f:	89 e5                	mov    %esp,%ebp
80106c41:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106c44:	e8 85 ff ff ff       	call   80106bce <setupkvm>
80106c49:	a3 c4 47 11 80       	mov    %eax,0x801147c4
  switchkvm();
80106c4e:	e8 1c fb ff ff       	call   8010676f <switchkvm>
}
80106c53:	c9                   	leave  
80106c54:	c3                   	ret    

80106c55 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106c55:	55                   	push   %ebp
80106c56:	89 e5                	mov    %esp,%ebp
80106c58:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106c5b:	b9 00 00 00 00       	mov    $0x0,%ecx
80106c60:	8b 55 0c             	mov    0xc(%ebp),%edx
80106c63:	8b 45 08             	mov    0x8(%ebp),%eax
80106c66:	e8 1f f7 ff ff       	call   8010638a <walkpgdir>
  if(pte == 0)
80106c6b:	85 c0                	test   %eax,%eax
80106c6d:	74 05                	je     80106c74 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106c6f:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106c72:	c9                   	leave  
80106c73:	c3                   	ret    
    panic("clearpteu");
80106c74:	83 ec 0c             	sub    $0xc,%esp
80106c77:	68 7e 7a 10 80       	push   $0x80107a7e
80106c7c:	e8 c0 96 ff ff       	call   80100341 <panic>

80106c81 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106c81:	55                   	push   %ebp
80106c82:	89 e5                	mov    %esp,%ebp
80106c84:	57                   	push   %edi
80106c85:	56                   	push   %esi
80106c86:	53                   	push   %ebx
80106c87:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106c8a:	e8 3f ff ff ff       	call   80106bce <setupkvm>
80106c8f:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106c92:	85 c0                	test   %eax,%eax
80106c94:	0f 84 c6 00 00 00    	je     80106d60 <copyuvm+0xdf>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106c9a:	bb 00 00 00 00       	mov    $0x0,%ebx
80106c9f:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
80106ca2:	0f 83 b8 00 00 00    	jae    80106d60 <copyuvm+0xdf>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106ca8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80106cab:	b9 00 00 00 00       	mov    $0x0,%ecx
80106cb0:	89 da                	mov    %ebx,%edx
80106cb2:	8b 45 08             	mov    0x8(%ebp),%eax
80106cb5:	e8 d0 f6 ff ff       	call   8010638a <walkpgdir>
80106cba:	85 c0                	test   %eax,%eax
80106cbc:	74 65                	je     80106d23 <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
80106cbe:	8b 00                	mov    (%eax),%eax
80106cc0:	a8 01                	test   $0x1,%al
80106cc2:	74 6c                	je     80106d30 <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80106cc4:	89 c6                	mov    %eax,%esi
80106cc6:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
80106ccc:	25 ff 0f 00 00       	and    $0xfff,%eax
80106cd1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
80106cd4:	e8 66 b3 ff ff       	call   8010203f <kalloc>
80106cd9:	89 c7                	mov    %eax,%edi
80106cdb:	85 c0                	test   %eax,%eax
80106cdd:	74 6a                	je     80106d49 <copyuvm+0xc8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106cdf:	81 c6 00 00 00 80    	add    $0x80000000,%esi
80106ce5:	83 ec 04             	sub    $0x4,%esp
80106ce8:	68 00 10 00 00       	push   $0x1000
80106ced:	56                   	push   %esi
80106cee:	50                   	push   %eax
80106cef:	e8 7d d4 ff ff       	call   80104171 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106cf4:	83 c4 04             	add    $0x4,%esp
80106cf7:	ff 75 e0             	push   -0x20(%ebp)
80106cfa:	8d 87 00 00 00 80    	lea    -0x80000000(%edi),%eax
80106d00:	50                   	push   %eax
80106d01:	68 00 10 00 00       	push   $0x1000
80106d06:	ff 75 e4             	push   -0x1c(%ebp)
80106d09:	ff 75 dc             	push   -0x24(%ebp)
80106d0c:	e8 e8 f9 ff ff       	call   801066f9 <mappages>
80106d11:	83 c4 20             	add    $0x20,%esp
80106d14:	85 c0                	test   %eax,%eax
80106d16:	78 25                	js     80106d3d <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
80106d18:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106d1e:	e9 7c ff ff ff       	jmp    80106c9f <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
80106d23:	83 ec 0c             	sub    $0xc,%esp
80106d26:	68 88 7a 10 80       	push   $0x80107a88
80106d2b:	e8 11 96 ff ff       	call   80100341 <panic>
      panic("copyuvm: page not present");
80106d30:	83 ec 0c             	sub    $0xc,%esp
80106d33:	68 a2 7a 10 80       	push   $0x80107aa2
80106d38:	e8 04 96 ff ff       	call   80100341 <panic>
      kfree(mem);
80106d3d:	83 ec 0c             	sub    $0xc,%esp
80106d40:	57                   	push   %edi
80106d41:	e8 e2 b1 ff ff       	call   80101f28 <kfree>
      goto bad;
80106d46:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d, 1);
80106d49:	83 ec 08             	sub    $0x8,%esp
80106d4c:	6a 01                	push   $0x1
80106d4e:	ff 75 dc             	push   -0x24(%ebp)
80106d51:	e8 02 fe ff ff       	call   80106b58 <freevm>
  return 0;
80106d56:	83 c4 10             	add    $0x10,%esp
80106d59:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106d60:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106d66:	5b                   	pop    %ebx
80106d67:	5e                   	pop    %esi
80106d68:	5f                   	pop    %edi
80106d69:	5d                   	pop    %ebp
80106d6a:	c3                   	ret    

80106d6b <copyuvm1>:

// Given a parent process's page table, create a copy
// of it for a child taking care of lazy memory
pde_t*
copyuvm1(pde_t *pgdir, uint sz)
{
80106d6b:	55                   	push   %ebp
80106d6c:	89 e5                	mov    %esp,%ebp
80106d6e:	57                   	push   %edi
80106d6f:	56                   	push   %esi
80106d70:	53                   	push   %ebx
80106d71:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;
  if((d = setupkvm()) == 0)
80106d74:	e8 55 fe ff ff       	call   80106bce <setupkvm>
80106d79:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106d7c:	85 c0                	test   %eax,%eax
80106d7e:	0f 84 b6 00 00 00    	je     80106e3a <copyuvm1+0xcf>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106d84:	be 00 00 00 00       	mov    $0x0,%esi
80106d89:	eb 13                	jmp    80106d9e <copyuvm1+0x33>
    if((pte = walkpgdir(pgdir, (void *) i, 1)) == 0)
      panic("copyuvm: pte should exist");
80106d8b:	83 ec 0c             	sub    $0xc,%esp
80106d8e:	68 88 7a 10 80       	push   $0x80107a88
80106d93:	e8 a9 95 ff ff       	call   80100341 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80106d98:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106d9e:	3b 75 0c             	cmp    0xc(%ebp),%esi
80106da1:	0f 83 93 00 00 00    	jae    80106e3a <copyuvm1+0xcf>
    if((pte = walkpgdir(pgdir, (void *) i, 1)) == 0)
80106da7:	b9 01 00 00 00       	mov    $0x1,%ecx
80106dac:	89 f2                	mov    %esi,%edx
80106dae:	8b 45 08             	mov    0x8(%ebp),%eax
80106db1:	e8 d4 f5 ff ff       	call   8010638a <walkpgdir>
80106db6:	85 c0                	test   %eax,%eax
80106db8:	74 d1                	je     80106d8b <copyuvm1+0x20>
    if(!(*pte & PTE_P)){
80106dba:	8b 00                	mov    (%eax),%eax
80106dbc:	a8 01                	test   $0x1,%al
80106dbe:	74 d8                	je     80106d98 <copyuvm1+0x2d>
			//Si la página no está presente vamos a seguir
			//iterando
			continue;
		}
		//Si la página tiene el bit de presente, la copiamos
    pa = PTE_ADDR(*pte);
80106dc0:	89 c2                	mov    %eax,%edx
80106dc2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80106dc8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    flags = PTE_FLAGS(*pte);
80106dcb:	25 ff 0f 00 00       	and    $0xfff,%eax
80106dd0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
80106dd3:	e8 67 b2 ff ff       	call   8010203f <kalloc>
80106dd8:	89 c7                	mov    %eax,%edi
80106dda:	85 c0                	test   %eax,%eax
80106ddc:	74 45                	je     80106e23 <copyuvm1+0xb8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106dde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106de1:	05 00 00 00 80       	add    $0x80000000,%eax
80106de6:	83 ec 04             	sub    $0x4,%esp
80106de9:	68 00 10 00 00       	push   $0x1000
80106dee:	50                   	push   %eax
80106def:	57                   	push   %edi
80106df0:	e8 7c d3 ff ff       	call   80104171 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106df5:	83 c4 04             	add    $0x4,%esp
80106df8:	ff 75 e0             	push   -0x20(%ebp)
80106dfb:	8d 87 00 00 00 80    	lea    -0x80000000(%edi),%eax
80106e01:	50                   	push   %eax
80106e02:	68 00 10 00 00       	push   $0x1000
80106e07:	56                   	push   %esi
80106e08:	ff 75 dc             	push   -0x24(%ebp)
80106e0b:	e8 e9 f8 ff ff       	call   801066f9 <mappages>
80106e10:	83 c4 20             	add    $0x20,%esp
80106e13:	85 c0                	test   %eax,%eax
80106e15:	79 81                	jns    80106d98 <copyuvm1+0x2d>
      kfree(mem);
80106e17:	83 ec 0c             	sub    $0xc,%esp
80106e1a:	57                   	push   %edi
80106e1b:	e8 08 b1 ff ff       	call   80101f28 <kfree>
      goto bad;
80106e20:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d, 1);
80106e23:	83 ec 08             	sub    $0x8,%esp
80106e26:	6a 01                	push   $0x1
80106e28:	ff 75 dc             	push   -0x24(%ebp)
80106e2b:	e8 28 fd ff ff       	call   80106b58 <freevm>
  return 0;
80106e30:	83 c4 10             	add    $0x10,%esp
80106e33:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106e3a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106e3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106e40:	5b                   	pop    %ebx
80106e41:	5e                   	pop    %esi
80106e42:	5f                   	pop    %edi
80106e43:	5d                   	pop    %ebp
80106e44:	c3                   	ret    

80106e45 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106e45:	55                   	push   %ebp
80106e46:	89 e5                	mov    %esp,%ebp
80106e48:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106e4b:	b9 00 00 00 00       	mov    $0x0,%ecx
80106e50:	8b 55 0c             	mov    0xc(%ebp),%edx
80106e53:	8b 45 08             	mov    0x8(%ebp),%eax
80106e56:	e8 2f f5 ff ff       	call   8010638a <walkpgdir>
  if((*pte & PTE_P) == 0)
80106e5b:	8b 00                	mov    (%eax),%eax
80106e5d:	a8 01                	test   $0x1,%al
80106e5f:	74 10                	je     80106e71 <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
80106e61:	a8 04                	test   $0x4,%al
80106e63:	74 13                	je     80106e78 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
80106e65:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106e6a:	05 00 00 00 80       	add    $0x80000000,%eax
}
80106e6f:	c9                   	leave  
80106e70:	c3                   	ret    
    return 0;
80106e71:	b8 00 00 00 00       	mov    $0x0,%eax
80106e76:	eb f7                	jmp    80106e6f <uva2ka+0x2a>
    return 0;
80106e78:	b8 00 00 00 00       	mov    $0x0,%eax
80106e7d:	eb f0                	jmp    80106e6f <uva2ka+0x2a>

80106e7f <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106e7f:	55                   	push   %ebp
80106e80:	89 e5                	mov    %esp,%ebp
80106e82:	57                   	push   %edi
80106e83:	56                   	push   %esi
80106e84:	53                   	push   %ebx
80106e85:	83 ec 0c             	sub    $0xc,%esp
80106e88:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106e8b:	eb 25                	jmp    80106eb2 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106e8d:	8b 55 0c             	mov    0xc(%ebp),%edx
80106e90:	29 f2                	sub    %esi,%edx
80106e92:	01 d0                	add    %edx,%eax
80106e94:	83 ec 04             	sub    $0x4,%esp
80106e97:	53                   	push   %ebx
80106e98:	ff 75 10             	push   0x10(%ebp)
80106e9b:	50                   	push   %eax
80106e9c:	e8 d0 d2 ff ff       	call   80104171 <memmove>
    len -= n;
80106ea1:	29 df                	sub    %ebx,%edi
    buf += n;
80106ea3:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106ea6:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80106eac:	89 45 0c             	mov    %eax,0xc(%ebp)
80106eaf:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
80106eb2:	85 ff                	test   %edi,%edi
80106eb4:	74 2f                	je     80106ee5 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
80106eb6:	8b 75 0c             	mov    0xc(%ebp),%esi
80106eb9:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106ebf:	83 ec 08             	sub    $0x8,%esp
80106ec2:	56                   	push   %esi
80106ec3:	ff 75 08             	push   0x8(%ebp)
80106ec6:	e8 7a ff ff ff       	call   80106e45 <uva2ka>
    if(pa0 == 0)
80106ecb:	83 c4 10             	add    $0x10,%esp
80106ece:	85 c0                	test   %eax,%eax
80106ed0:	74 20                	je     80106ef2 <copyout+0x73>
    n = PGSIZE - (va - va0);
80106ed2:	89 f3                	mov    %esi,%ebx
80106ed4:	2b 5d 0c             	sub    0xc(%ebp),%ebx
80106ed7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106edd:	39 df                	cmp    %ebx,%edi
80106edf:	73 ac                	jae    80106e8d <copyout+0xe>
      n = len;
80106ee1:	89 fb                	mov    %edi,%ebx
80106ee3:	eb a8                	jmp    80106e8d <copyout+0xe>
  }
  return 0;
80106ee5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106eea:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106eed:	5b                   	pop    %ebx
80106eee:	5e                   	pop    %esi
80106eef:	5f                   	pop    %edi
80106ef0:	5d                   	pop    %ebp
80106ef1:	c3                   	ret    
      return -1;
80106ef2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ef7:	eb f1                	jmp    80106eea <copyout+0x6b>
