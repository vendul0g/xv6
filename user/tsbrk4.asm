
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
  4f:	68 30 05 00 00       	push   $0x530
  54:	6a 01                	push   $0x1
  56:	e8 e6 02 00 00       	call   341 <printf>
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
  87:	68 a4 04 00 00       	push   $0x4a4
  8c:	6a 01                	push   $0x1
  8e:	e8 ae 02 00 00       	call   341 <printf>
  93:	83 c4 10             	add    $0x10,%esp
  96:	eb 93                	jmp    2b <main+0x2b>
      printf (1, "Exited child (failure) %d, trap %d\n", pid, WEXITTRAP (status));
  98:	4a                   	dec    %edx
  99:	52                   	push   %edx
  9a:	56                   	push   %esi
  9b:	68 0c 05 00 00       	push   $0x50c
  a0:	6a 01                	push   $0x1
  a2:	e8 9a 02 00 00       	call   341 <printf>
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
  c3:	68 c2 04 00 00       	push   $0x4c2
  c8:	6a 01                	push   $0x1
  ca:	e8 72 02 00 00       	call   341 <printf>
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
  f2:	68 db 04 00 00       	push   $0x4db
  f7:	6a 01                	push   $0x1
  f9:	e8 43 02 00 00       	call   341 <printf>
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
 11e:	68 f4 04 00 00       	push   $0x4f4
 123:	6a 01                	push   $0x1
 125:	e8 17 02 00 00       	call   341 <printf>

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
 188:	68 f4 04 00 00       	push   $0x4f4
 18d:	6a 01                	push   $0x1
 18f:	e8 ad 01 00 00       	call   341 <printf>

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
 1be:	68 a4 04 00 00       	push   $0x4a4
 1c3:	6a 01                	push   $0x1
 1c5:	e8 77 01 00 00       	call   341 <printf>
 1ca:	83 c4 10             	add    $0x10,%esp
 1cd:	eb 83                	jmp    152 <main+0x152>
      printf (1, "Exited child (failure) %d, trap %d\n", pid, WEXITTRAP (status));
 1cf:	4a                   	dec    %edx
 1d0:	52                   	push   %edx
 1d1:	53                   	push   %ebx
 1d2:	68 0c 05 00 00       	push   $0x50c
 1d7:	6a 01                	push   $0x1
 1d9:	e8 63 01 00 00       	call   341 <printf>
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

0000029e <getprio>:
SYSCALL(getprio)
 29e:	b8 18 00 00 00       	mov    $0x18,%eax
 2a3:	cd 40                	int    $0x40
 2a5:	c3                   	ret    

000002a6 <setprio>:
SYSCALL(setprio)
 2a6:	b8 19 00 00 00       	mov    $0x19,%eax
 2ab:	cd 40                	int    $0x40
 2ad:	c3                   	ret    

000002ae <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2ae:	55                   	push   %ebp
 2af:	89 e5                	mov    %esp,%ebp
 2b1:	83 ec 1c             	sub    $0x1c,%esp
 2b4:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2b7:	6a 01                	push   $0x1
 2b9:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2bc:	52                   	push   %edx
 2bd:	50                   	push   %eax
 2be:	e8 4b ff ff ff       	call   20e <write>
}
 2c3:	83 c4 10             	add    $0x10,%esp
 2c6:	c9                   	leave  
 2c7:	c3                   	ret    

000002c8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2c8:	55                   	push   %ebp
 2c9:	89 e5                	mov    %esp,%ebp
 2cb:	57                   	push   %edi
 2cc:	56                   	push   %esi
 2cd:	53                   	push   %ebx
 2ce:	83 ec 2c             	sub    $0x2c,%esp
 2d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 2d4:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2d6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2da:	74 04                	je     2e0 <printint+0x18>
 2dc:	85 d2                	test   %edx,%edx
 2de:	78 3c                	js     31c <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 2e0:	89 d1                	mov    %edx,%ecx
  neg = 0;
 2e2:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 2e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 2ee:	89 c8                	mov    %ecx,%eax
 2f0:	ba 00 00 00 00       	mov    $0x0,%edx
 2f5:	f7 f6                	div    %esi
 2f7:	89 df                	mov    %ebx,%edi
 2f9:	43                   	inc    %ebx
 2fa:	8a 92 b4 05 00 00    	mov    0x5b4(%edx),%dl
 300:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 304:	89 ca                	mov    %ecx,%edx
 306:	89 c1                	mov    %eax,%ecx
 308:	39 d6                	cmp    %edx,%esi
 30a:	76 e2                	jbe    2ee <printint+0x26>
  if(neg)
 30c:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 310:	74 24                	je     336 <printint+0x6e>
    buf[i++] = '-';
 312:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 317:	8d 5f 02             	lea    0x2(%edi),%ebx
 31a:	eb 1a                	jmp    336 <printint+0x6e>
    x = -xx;
 31c:	89 d1                	mov    %edx,%ecx
 31e:	f7 d9                	neg    %ecx
    neg = 1;
 320:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 327:	eb c0                	jmp    2e9 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 329:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 32e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 331:	e8 78 ff ff ff       	call   2ae <putc>
  while(--i >= 0)
 336:	4b                   	dec    %ebx
 337:	79 f0                	jns    329 <printint+0x61>
}
 339:	83 c4 2c             	add    $0x2c,%esp
 33c:	5b                   	pop    %ebx
 33d:	5e                   	pop    %esi
 33e:	5f                   	pop    %edi
 33f:	5d                   	pop    %ebp
 340:	c3                   	ret    

00000341 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 341:	55                   	push   %ebp
 342:	89 e5                	mov    %esp,%ebp
 344:	57                   	push   %edi
 345:	56                   	push   %esi
 346:	53                   	push   %ebx
 347:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 34a:	8d 45 10             	lea    0x10(%ebp),%eax
 34d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 350:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 355:	bb 00 00 00 00       	mov    $0x0,%ebx
 35a:	eb 12                	jmp    36e <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 35c:	89 fa                	mov    %edi,%edx
 35e:	8b 45 08             	mov    0x8(%ebp),%eax
 361:	e8 48 ff ff ff       	call   2ae <putc>
 366:	eb 05                	jmp    36d <printf+0x2c>
      }
    } else if(state == '%'){
 368:	83 fe 25             	cmp    $0x25,%esi
 36b:	74 22                	je     38f <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 36d:	43                   	inc    %ebx
 36e:	8b 45 0c             	mov    0xc(%ebp),%eax
 371:	8a 04 18             	mov    (%eax,%ebx,1),%al
 374:	84 c0                	test   %al,%al
 376:	0f 84 1d 01 00 00    	je     499 <printf+0x158>
    c = fmt[i] & 0xff;
 37c:	0f be f8             	movsbl %al,%edi
 37f:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 382:	85 f6                	test   %esi,%esi
 384:	75 e2                	jne    368 <printf+0x27>
      if(c == '%'){
 386:	83 f8 25             	cmp    $0x25,%eax
 389:	75 d1                	jne    35c <printf+0x1b>
        state = '%';
 38b:	89 c6                	mov    %eax,%esi
 38d:	eb de                	jmp    36d <printf+0x2c>
      if(c == 'd'){
 38f:	83 f8 25             	cmp    $0x25,%eax
 392:	0f 84 cc 00 00 00    	je     464 <printf+0x123>
 398:	0f 8c da 00 00 00    	jl     478 <printf+0x137>
 39e:	83 f8 78             	cmp    $0x78,%eax
 3a1:	0f 8f d1 00 00 00    	jg     478 <printf+0x137>
 3a7:	83 f8 63             	cmp    $0x63,%eax
 3aa:	0f 8c c8 00 00 00    	jl     478 <printf+0x137>
 3b0:	83 e8 63             	sub    $0x63,%eax
 3b3:	83 f8 15             	cmp    $0x15,%eax
 3b6:	0f 87 bc 00 00 00    	ja     478 <printf+0x137>
 3bc:	ff 24 85 5c 05 00 00 	jmp    *0x55c(,%eax,4)
        printint(fd, *ap, 10, 1);
 3c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3c6:	8b 17                	mov    (%edi),%edx
 3c8:	83 ec 0c             	sub    $0xc,%esp
 3cb:	6a 01                	push   $0x1
 3cd:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3d2:	8b 45 08             	mov    0x8(%ebp),%eax
 3d5:	e8 ee fe ff ff       	call   2c8 <printint>
        ap++;
 3da:	83 c7 04             	add    $0x4,%edi
 3dd:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3e0:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 3e3:	be 00 00 00 00       	mov    $0x0,%esi
 3e8:	eb 83                	jmp    36d <printf+0x2c>
        printint(fd, *ap, 16, 0);
 3ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3ed:	8b 17                	mov    (%edi),%edx
 3ef:	83 ec 0c             	sub    $0xc,%esp
 3f2:	6a 00                	push   $0x0
 3f4:	b9 10 00 00 00       	mov    $0x10,%ecx
 3f9:	8b 45 08             	mov    0x8(%ebp),%eax
 3fc:	e8 c7 fe ff ff       	call   2c8 <printint>
        ap++;
 401:	83 c7 04             	add    $0x4,%edi
 404:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 407:	83 c4 10             	add    $0x10,%esp
      state = 0;
 40a:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 40f:	e9 59 ff ff ff       	jmp    36d <printf+0x2c>
        s = (char*)*ap;
 414:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 417:	8b 30                	mov    (%eax),%esi
        ap++;
 419:	83 c0 04             	add    $0x4,%eax
 41c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 41f:	85 f6                	test   %esi,%esi
 421:	75 13                	jne    436 <printf+0xf5>
          s = "(null)";
 423:	be 55 05 00 00       	mov    $0x555,%esi
 428:	eb 0c                	jmp    436 <printf+0xf5>
          putc(fd, *s);
 42a:	0f be d2             	movsbl %dl,%edx
 42d:	8b 45 08             	mov    0x8(%ebp),%eax
 430:	e8 79 fe ff ff       	call   2ae <putc>
          s++;
 435:	46                   	inc    %esi
        while(*s != 0){
 436:	8a 16                	mov    (%esi),%dl
 438:	84 d2                	test   %dl,%dl
 43a:	75 ee                	jne    42a <printf+0xe9>
      state = 0;
 43c:	be 00 00 00 00       	mov    $0x0,%esi
 441:	e9 27 ff ff ff       	jmp    36d <printf+0x2c>
        putc(fd, *ap);
 446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 449:	0f be 17             	movsbl (%edi),%edx
 44c:	8b 45 08             	mov    0x8(%ebp),%eax
 44f:	e8 5a fe ff ff       	call   2ae <putc>
        ap++;
 454:	83 c7 04             	add    $0x4,%edi
 457:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 45a:	be 00 00 00 00       	mov    $0x0,%esi
 45f:	e9 09 ff ff ff       	jmp    36d <printf+0x2c>
        putc(fd, c);
 464:	89 fa                	mov    %edi,%edx
 466:	8b 45 08             	mov    0x8(%ebp),%eax
 469:	e8 40 fe ff ff       	call   2ae <putc>
      state = 0;
 46e:	be 00 00 00 00       	mov    $0x0,%esi
 473:	e9 f5 fe ff ff       	jmp    36d <printf+0x2c>
        putc(fd, '%');
 478:	ba 25 00 00 00       	mov    $0x25,%edx
 47d:	8b 45 08             	mov    0x8(%ebp),%eax
 480:	e8 29 fe ff ff       	call   2ae <putc>
        putc(fd, c);
 485:	89 fa                	mov    %edi,%edx
 487:	8b 45 08             	mov    0x8(%ebp),%eax
 48a:	e8 1f fe ff ff       	call   2ae <putc>
      state = 0;
 48f:	be 00 00 00 00       	mov    $0x0,%esi
 494:	e9 d4 fe ff ff       	jmp    36d <printf+0x2c>
    }
  }
}
 499:	8d 65 f4             	lea    -0xc(%ebp),%esp
 49c:	5b                   	pop    %ebx
 49d:	5e                   	pop    %esi
 49e:	5f                   	pop    %edi
 49f:	5d                   	pop    %ebp
 4a0:	c3                   	ret    
