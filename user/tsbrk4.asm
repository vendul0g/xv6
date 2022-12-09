
tsbrk4:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	56                   	push   %esi
   e:	53                   	push   %ebx
   f:	51                   	push   %ecx
  10:	83 ec 28             	sub    $0x28,%esp
  char* a = sbrk (15000);
  13:	68 98 3a 00 00       	push   $0x3a98
  18:	e8 59 02 00 00       	call   276 <sbrk>
  1d:	89 c3                	mov    %eax,%ebx
	int pid, status;
	
	pid = fork();
  1f:	e8 c2 01 00 00       	call   1e6 <fork>
	if(pid!=0){
  24:	83 c4 10             	add    $0x10,%esp
  27:	85 c0                	test   %eax,%eax
  29:	75 3c                	jne    67 <main+0x67>
      printf (1, "Exited child %d, exitcode %d\n", pid, WEXITSTATUS (status));
    else if (WIFSIGNALED(status))
      printf (1, "Exited child (failure) %d, trap %d\n", pid, WEXITTRAP (status));
	}
	
  a[500] = 1;
  2b:	c6 83 f4 01 00 00 01 	movb   $0x1,0x1f4(%ebx)
	
  if ((uint)a + 15000 != (uint) sbrk (-15000))
  32:	8d b3 98 3a 00 00    	lea    0x3a98(%ebx),%esi
  38:	83 ec 0c             	sub    $0xc,%esp
  3b:	68 68 c5 ff ff       	push   $0xffffc568
  40:	e8 31 02 00 00       	call   276 <sbrk>
  45:	83 c4 10             	add    $0x10,%esp
  48:	39 c6                	cmp    %eax,%esi
  4a:	74 63                	je     af <main+0xaf>
  {
    printf (1, "sbrk() con número positivo falló.\n");
  4c:	83 ec 08             	sub    $0x8,%esp
  4f:	68 20 05 00 00       	push   $0x520
  54:	6a 01                	push   $0x1
  56:	e8 d6 02 00 00       	call   331 <printf>
    exit(1);
  5b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  62:	e8 87 01 00 00       	call   1ee <exit>
  67:	89 c6                	mov    %eax,%esi
		wait(&status);
  69:	83 ec 0c             	sub    $0xc,%esp
  6c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  6f:	50                   	push   %eax
  70:	e8 81 01 00 00       	call   1f6 <wait>
		if (WIFEXITED (status))
  75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  78:	83 c4 10             	add    $0x10,%esp
  7b:	89 c2                	mov    %eax,%edx
  7d:	83 e2 7f             	and    $0x7f,%edx
  80:	75 16                	jne    98 <main+0x98>
      printf (1, "Exited child %d, exitcode %d\n", pid, WEXITSTATUS (status));
  82:	0f b6 c4             	movzbl %ah,%eax
  85:	50                   	push   %eax
  86:	56                   	push   %esi
  87:	68 94 04 00 00       	push   $0x494
  8c:	6a 01                	push   $0x1
  8e:	e8 9e 02 00 00       	call   331 <printf>
  93:	83 c4 10             	add    $0x10,%esp
  96:	eb 93                	jmp    2b <main+0x2b>
      printf (1, "Exited child (failure) %d, trap %d\n", pid, WEXITTRAP (status));
  98:	4a                   	dec    %edx
  99:	52                   	push   %edx
  9a:	56                   	push   %esi
  9b:	68 fc 04 00 00       	push   $0x4fc
  a0:	6a 01                	push   $0x1
  a2:	e8 8a 02 00 00       	call   331 <printf>
  a7:	83 c4 10             	add    $0x10,%esp
  aa:	e9 7c ff ff ff       	jmp    2b <main+0x2b>
  }

  if (a != sbrk (0))
  af:	83 ec 0c             	sub    $0xc,%esp
  b2:	6a 00                	push   $0x0
  b4:	e8 bd 01 00 00       	call   276 <sbrk>
  b9:	83 c4 10             	add    $0x10,%esp
  bc:	39 c3                	cmp    %eax,%ebx
  be:	74 1b                	je     db <main+0xdb>
  {
    printf (1, "sbrk() con cero falló.\n");
  c0:	83 ec 08             	sub    $0x8,%esp
  c3:	68 b2 04 00 00       	push   $0x4b2
  c8:	6a 01                	push   $0x1
  ca:	e8 62 02 00 00       	call   331 <printf>
    exit(2);
  cf:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  d6:	e8 13 01 00 00       	call   1ee <exit>
  }

  if (a != sbrk (15000))
  db:	83 ec 0c             	sub    $0xc,%esp
  de:	68 98 3a 00 00       	push   $0x3a98
  e3:	e8 8e 01 00 00       	call   276 <sbrk>
  e8:	83 c4 10             	add    $0x10,%esp
  eb:	39 c3                	cmp    %eax,%ebx
  ed:	74 1b                	je     10a <main+0x10a>
  {
    printf (1, "sbrk() negativo falló.\n");
  ef:	83 ec 08             	sub    $0x8,%esp
  f2:	68 cb 04 00 00       	push   $0x4cb
  f7:	6a 01                	push   $0x1
  f9:	e8 33 02 00 00       	call   331 <printf>
    exit(3);
  fe:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
 105:	e8 e4 00 00 00       	call   1ee <exit>
  }

  printf (1, "Debe imprimir 1: %d.\n", ++a[500]);
 10a:	8a 83 f4 01 00 00    	mov    0x1f4(%ebx),%al
 110:	40                   	inc    %eax
 111:	88 83 f4 01 00 00    	mov    %al,0x1f4(%ebx)
 117:	83 ec 04             	sub    $0x4,%esp
 11a:	0f be c0             	movsbl %al,%eax
 11d:	50                   	push   %eax
 11e:	68 e4 04 00 00       	push   $0x4e4
 123:	6a 01                	push   $0x1
 125:	e8 07 02 00 00       	call   331 <printf>

  a=sbrk (-15000);
 12a:	c7 04 24 68 c5 ff ff 	movl   $0xffffc568,(%esp)
 131:	e8 40 01 00 00       	call   276 <sbrk>

  a=sbrk(1024*4096*2);
 136:	c7 04 24 00 00 80 00 	movl   $0x800000,(%esp)
 13d:	e8 34 01 00 00       	call   276 <sbrk>
 142:	89 c6                	mov    %eax,%esi

	pid = fork();
 144:	e8 9d 00 00 00       	call   1e6 <fork>
 149:	89 c3                	mov    %eax,%ebx
	if(pid!=0){
 14b:	83 c4 10             	add    $0x10,%esp
 14e:	85 c0                	test   %eax,%eax
 150:	75 4e                	jne    1a0 <main+0x1a0>
    else if (WIFSIGNALED(status))
      printf (1, "Exited child (failure) %d, trap %d\n", pid, WEXITTRAP (status));
	}


  a[600*4096*2] = 1;
 152:	c6 86 00 00 4b 00 01 	movb   $0x1,0x4b0000(%esi)

  sbrk(-1024*4096*2);
 159:	83 ec 0c             	sub    $0xc,%esp
 15c:	68 00 00 80 ff       	push   $0xff800000
 161:	e8 10 01 00 00       	call   276 <sbrk>

  a=sbrk(1024*4096*2);
 166:	c7 04 24 00 00 80 00 	movl   $0x800000,(%esp)
 16d:	e8 04 01 00 00       	call   276 <sbrk>

  printf (1, "Debe imprimir 1: %d.\n", ++a[600*4096*2]);
 172:	8a 88 00 00 4b 00    	mov    0x4b0000(%eax),%cl
 178:	8d 51 01             	lea    0x1(%ecx),%edx
 17b:	88 90 00 00 4b 00    	mov    %dl,0x4b0000(%eax)
 181:	83 c4 0c             	add    $0xc,%esp
 184:	0f be d2             	movsbl %dl,%edx
 187:	52                   	push   %edx
 188:	68 e4 04 00 00       	push   $0x4e4
 18d:	6a 01                	push   $0x1
 18f:	e8 9d 01 00 00       	call   331 <printf>

  exit(0);
 194:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 19b:	e8 4e 00 00 00       	call   1ee <exit>
		wait(&status);
 1a0:	83 ec 0c             	sub    $0xc,%esp
 1a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 1a6:	50                   	push   %eax
 1a7:	e8 4a 00 00 00       	call   1f6 <wait>
		if (WIFEXITED (status))
 1ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1af:	83 c4 10             	add    $0x10,%esp
 1b2:	89 c2                	mov    %eax,%edx
 1b4:	83 e2 7f             	and    $0x7f,%edx
 1b7:	75 16                	jne    1cf <main+0x1cf>
      printf (1, "Exited child %d, exitcode %d\n", pid, WEXITSTATUS (status));
 1b9:	0f b6 c4             	movzbl %ah,%eax
 1bc:	50                   	push   %eax
 1bd:	53                   	push   %ebx
 1be:	68 94 04 00 00       	push   $0x494
 1c3:	6a 01                	push   $0x1
 1c5:	e8 67 01 00 00       	call   331 <printf>
 1ca:	83 c4 10             	add    $0x10,%esp
 1cd:	eb 83                	jmp    152 <main+0x152>
      printf (1, "Exited child (failure) %d, trap %d\n", pid, WEXITTRAP (status));
 1cf:	4a                   	dec    %edx
 1d0:	52                   	push   %edx
 1d1:	53                   	push   %ebx
 1d2:	68 fc 04 00 00       	push   $0x4fc
 1d7:	6a 01                	push   $0x1
 1d9:	e8 53 01 00 00       	call   331 <printf>
 1de:	83 c4 10             	add    $0x10,%esp
 1e1:	e9 6c ff ff ff       	jmp    152 <main+0x152>

000001e6 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1e6:	b8 01 00 00 00       	mov    $0x1,%eax
 1eb:	cd 40                	int    $0x40
 1ed:	c3                   	ret    

000001ee <exit>:
SYSCALL(exit)
 1ee:	b8 02 00 00 00       	mov    $0x2,%eax
 1f3:	cd 40                	int    $0x40
 1f5:	c3                   	ret    

000001f6 <wait>:
SYSCALL(wait)
 1f6:	b8 03 00 00 00       	mov    $0x3,%eax
 1fb:	cd 40                	int    $0x40
 1fd:	c3                   	ret    

000001fe <pipe>:
SYSCALL(pipe)
 1fe:	b8 04 00 00 00       	mov    $0x4,%eax
 203:	cd 40                	int    $0x40
 205:	c3                   	ret    

00000206 <read>:
SYSCALL(read)
 206:	b8 05 00 00 00       	mov    $0x5,%eax
 20b:	cd 40                	int    $0x40
 20d:	c3                   	ret    

0000020e <write>:
SYSCALL(write)
 20e:	b8 10 00 00 00       	mov    $0x10,%eax
 213:	cd 40                	int    $0x40
 215:	c3                   	ret    

00000216 <close>:
SYSCALL(close)
 216:	b8 15 00 00 00       	mov    $0x15,%eax
 21b:	cd 40                	int    $0x40
 21d:	c3                   	ret    

0000021e <kill>:
SYSCALL(kill)
 21e:	b8 06 00 00 00       	mov    $0x6,%eax
 223:	cd 40                	int    $0x40
 225:	c3                   	ret    

00000226 <exec>:
SYSCALL(exec)
 226:	b8 07 00 00 00       	mov    $0x7,%eax
 22b:	cd 40                	int    $0x40
 22d:	c3                   	ret    

0000022e <open>:
SYSCALL(open)
 22e:	b8 0f 00 00 00       	mov    $0xf,%eax
 233:	cd 40                	int    $0x40
 235:	c3                   	ret    

00000236 <mknod>:
SYSCALL(mknod)
 236:	b8 11 00 00 00       	mov    $0x11,%eax
 23b:	cd 40                	int    $0x40
 23d:	c3                   	ret    

0000023e <unlink>:
SYSCALL(unlink)
 23e:	b8 12 00 00 00       	mov    $0x12,%eax
 243:	cd 40                	int    $0x40
 245:	c3                   	ret    

00000246 <fstat>:
SYSCALL(fstat)
 246:	b8 08 00 00 00       	mov    $0x8,%eax
 24b:	cd 40                	int    $0x40
 24d:	c3                   	ret    

0000024e <link>:
SYSCALL(link)
 24e:	b8 13 00 00 00       	mov    $0x13,%eax
 253:	cd 40                	int    $0x40
 255:	c3                   	ret    

00000256 <mkdir>:
SYSCALL(mkdir)
 256:	b8 14 00 00 00       	mov    $0x14,%eax
 25b:	cd 40                	int    $0x40
 25d:	c3                   	ret    

0000025e <chdir>:
SYSCALL(chdir)
 25e:	b8 09 00 00 00       	mov    $0x9,%eax
 263:	cd 40                	int    $0x40
 265:	c3                   	ret    

00000266 <dup>:
SYSCALL(dup)
 266:	b8 0a 00 00 00       	mov    $0xa,%eax
 26b:	cd 40                	int    $0x40
 26d:	c3                   	ret    

0000026e <getpid>:
SYSCALL(getpid)
 26e:	b8 0b 00 00 00       	mov    $0xb,%eax
 273:	cd 40                	int    $0x40
 275:	c3                   	ret    

00000276 <sbrk>:
SYSCALL(sbrk)
 276:	b8 0c 00 00 00       	mov    $0xc,%eax
 27b:	cd 40                	int    $0x40
 27d:	c3                   	ret    

0000027e <sleep>:
SYSCALL(sleep)
 27e:	b8 0d 00 00 00       	mov    $0xd,%eax
 283:	cd 40                	int    $0x40
 285:	c3                   	ret    

00000286 <uptime>:
SYSCALL(uptime)
 286:	b8 0e 00 00 00       	mov    $0xe,%eax
 28b:	cd 40                	int    $0x40
 28d:	c3                   	ret    

0000028e <date>:
SYSCALL(date)
 28e:	b8 16 00 00 00       	mov    $0x16,%eax
 293:	cd 40                	int    $0x40
 295:	c3                   	ret    

00000296 <dup2>:
SYSCALL(dup2)
 296:	b8 17 00 00 00       	mov    $0x17,%eax
 29b:	cd 40                	int    $0x40
 29d:	c3                   	ret    

0000029e <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 29e:	55                   	push   %ebp
 29f:	89 e5                	mov    %esp,%ebp
 2a1:	83 ec 1c             	sub    $0x1c,%esp
 2a4:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2a7:	6a 01                	push   $0x1
 2a9:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2ac:	52                   	push   %edx
 2ad:	50                   	push   %eax
 2ae:	e8 5b ff ff ff       	call   20e <write>
}
 2b3:	83 c4 10             	add    $0x10,%esp
 2b6:	c9                   	leave  
 2b7:	c3                   	ret    

000002b8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2b8:	55                   	push   %ebp
 2b9:	89 e5                	mov    %esp,%ebp
 2bb:	57                   	push   %edi
 2bc:	56                   	push   %esi
 2bd:	53                   	push   %ebx
 2be:	83 ec 2c             	sub    $0x2c,%esp
 2c1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 2c4:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2c6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2ca:	74 04                	je     2d0 <printint+0x18>
 2cc:	85 d2                	test   %edx,%edx
 2ce:	78 3c                	js     30c <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 2d0:	89 d1                	mov    %edx,%ecx
  neg = 0;
 2d2:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 2d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 2de:	89 c8                	mov    %ecx,%eax
 2e0:	ba 00 00 00 00       	mov    $0x0,%edx
 2e5:	f7 f6                	div    %esi
 2e7:	89 df                	mov    %ebx,%edi
 2e9:	43                   	inc    %ebx
 2ea:	8a 92 a4 05 00 00    	mov    0x5a4(%edx),%dl
 2f0:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 2f4:	89 ca                	mov    %ecx,%edx
 2f6:	89 c1                	mov    %eax,%ecx
 2f8:	39 d6                	cmp    %edx,%esi
 2fa:	76 e2                	jbe    2de <printint+0x26>
  if(neg)
 2fc:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 300:	74 24                	je     326 <printint+0x6e>
    buf[i++] = '-';
 302:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 307:	8d 5f 02             	lea    0x2(%edi),%ebx
 30a:	eb 1a                	jmp    326 <printint+0x6e>
    x = -xx;
 30c:	89 d1                	mov    %edx,%ecx
 30e:	f7 d9                	neg    %ecx
    neg = 1;
 310:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 317:	eb c0                	jmp    2d9 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 319:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 31e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 321:	e8 78 ff ff ff       	call   29e <putc>
  while(--i >= 0)
 326:	4b                   	dec    %ebx
 327:	79 f0                	jns    319 <printint+0x61>
}
 329:	83 c4 2c             	add    $0x2c,%esp
 32c:	5b                   	pop    %ebx
 32d:	5e                   	pop    %esi
 32e:	5f                   	pop    %edi
 32f:	5d                   	pop    %ebp
 330:	c3                   	ret    

00000331 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 331:	55                   	push   %ebp
 332:	89 e5                	mov    %esp,%ebp
 334:	57                   	push   %edi
 335:	56                   	push   %esi
 336:	53                   	push   %ebx
 337:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 33a:	8d 45 10             	lea    0x10(%ebp),%eax
 33d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 340:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 345:	bb 00 00 00 00       	mov    $0x0,%ebx
 34a:	eb 12                	jmp    35e <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 34c:	89 fa                	mov    %edi,%edx
 34e:	8b 45 08             	mov    0x8(%ebp),%eax
 351:	e8 48 ff ff ff       	call   29e <putc>
 356:	eb 05                	jmp    35d <printf+0x2c>
      }
    } else if(state == '%'){
 358:	83 fe 25             	cmp    $0x25,%esi
 35b:	74 22                	je     37f <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 35d:	43                   	inc    %ebx
 35e:	8b 45 0c             	mov    0xc(%ebp),%eax
 361:	8a 04 18             	mov    (%eax,%ebx,1),%al
 364:	84 c0                	test   %al,%al
 366:	0f 84 1d 01 00 00    	je     489 <printf+0x158>
    c = fmt[i] & 0xff;
 36c:	0f be f8             	movsbl %al,%edi
 36f:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 372:	85 f6                	test   %esi,%esi
 374:	75 e2                	jne    358 <printf+0x27>
      if(c == '%'){
 376:	83 f8 25             	cmp    $0x25,%eax
 379:	75 d1                	jne    34c <printf+0x1b>
        state = '%';
 37b:	89 c6                	mov    %eax,%esi
 37d:	eb de                	jmp    35d <printf+0x2c>
      if(c == 'd'){
 37f:	83 f8 25             	cmp    $0x25,%eax
 382:	0f 84 cc 00 00 00    	je     454 <printf+0x123>
 388:	0f 8c da 00 00 00    	jl     468 <printf+0x137>
 38e:	83 f8 78             	cmp    $0x78,%eax
 391:	0f 8f d1 00 00 00    	jg     468 <printf+0x137>
 397:	83 f8 63             	cmp    $0x63,%eax
 39a:	0f 8c c8 00 00 00    	jl     468 <printf+0x137>
 3a0:	83 e8 63             	sub    $0x63,%eax
 3a3:	83 f8 15             	cmp    $0x15,%eax
 3a6:	0f 87 bc 00 00 00    	ja     468 <printf+0x137>
 3ac:	ff 24 85 4c 05 00 00 	jmp    *0x54c(,%eax,4)
        printint(fd, *ap, 10, 1);
 3b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3b6:	8b 17                	mov    (%edi),%edx
 3b8:	83 ec 0c             	sub    $0xc,%esp
 3bb:	6a 01                	push   $0x1
 3bd:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3c2:	8b 45 08             	mov    0x8(%ebp),%eax
 3c5:	e8 ee fe ff ff       	call   2b8 <printint>
        ap++;
 3ca:	83 c7 04             	add    $0x4,%edi
 3cd:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3d0:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 3d3:	be 00 00 00 00       	mov    $0x0,%esi
 3d8:	eb 83                	jmp    35d <printf+0x2c>
        printint(fd, *ap, 16, 0);
 3da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3dd:	8b 17                	mov    (%edi),%edx
 3df:	83 ec 0c             	sub    $0xc,%esp
 3e2:	6a 00                	push   $0x0
 3e4:	b9 10 00 00 00       	mov    $0x10,%ecx
 3e9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ec:	e8 c7 fe ff ff       	call   2b8 <printint>
        ap++;
 3f1:	83 c7 04             	add    $0x4,%edi
 3f4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3f7:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3fa:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 3ff:	e9 59 ff ff ff       	jmp    35d <printf+0x2c>
        s = (char*)*ap;
 404:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 407:	8b 30                	mov    (%eax),%esi
        ap++;
 409:	83 c0 04             	add    $0x4,%eax
 40c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 40f:	85 f6                	test   %esi,%esi
 411:	75 13                	jne    426 <printf+0xf5>
          s = "(null)";
 413:	be 45 05 00 00       	mov    $0x545,%esi
 418:	eb 0c                	jmp    426 <printf+0xf5>
          putc(fd, *s);
 41a:	0f be d2             	movsbl %dl,%edx
 41d:	8b 45 08             	mov    0x8(%ebp),%eax
 420:	e8 79 fe ff ff       	call   29e <putc>
          s++;
 425:	46                   	inc    %esi
        while(*s != 0){
 426:	8a 16                	mov    (%esi),%dl
 428:	84 d2                	test   %dl,%dl
 42a:	75 ee                	jne    41a <printf+0xe9>
      state = 0;
 42c:	be 00 00 00 00       	mov    $0x0,%esi
 431:	e9 27 ff ff ff       	jmp    35d <printf+0x2c>
        putc(fd, *ap);
 436:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 439:	0f be 17             	movsbl (%edi),%edx
 43c:	8b 45 08             	mov    0x8(%ebp),%eax
 43f:	e8 5a fe ff ff       	call   29e <putc>
        ap++;
 444:	83 c7 04             	add    $0x4,%edi
 447:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 44a:	be 00 00 00 00       	mov    $0x0,%esi
 44f:	e9 09 ff ff ff       	jmp    35d <printf+0x2c>
        putc(fd, c);
 454:	89 fa                	mov    %edi,%edx
 456:	8b 45 08             	mov    0x8(%ebp),%eax
 459:	e8 40 fe ff ff       	call   29e <putc>
      state = 0;
 45e:	be 00 00 00 00       	mov    $0x0,%esi
 463:	e9 f5 fe ff ff       	jmp    35d <printf+0x2c>
        putc(fd, '%');
 468:	ba 25 00 00 00       	mov    $0x25,%edx
 46d:	8b 45 08             	mov    0x8(%ebp),%eax
 470:	e8 29 fe ff ff       	call   29e <putc>
        putc(fd, c);
 475:	89 fa                	mov    %edi,%edx
 477:	8b 45 08             	mov    0x8(%ebp),%eax
 47a:	e8 1f fe ff ff       	call   29e <putc>
      state = 0;
 47f:	be 00 00 00 00       	mov    $0x0,%esi
 484:	e9 d4 fe ff ff       	jmp    35d <printf+0x2c>
    }
  }
}
 489:	8d 65 f4             	lea    -0xc(%ebp),%esp
 48c:	5b                   	pop    %ebx
 48d:	5e                   	pop    %esi
 48e:	5f                   	pop    %edi
 48f:	5d                   	pop    %ebp
 490:	c3                   	ret    
