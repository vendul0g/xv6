
ls:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	56                   	push   %esi
   4:	53                   	push   %ebx
   5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   8:	83 ec 0c             	sub    $0xc,%esp
   b:	53                   	push   %ebx
   c:	e8 1a 03 00 00       	call   32b <strlen>
  11:	01 d8                	add    %ebx,%eax
  13:	83 c4 10             	add    $0x10,%esp
  16:	eb 01                	jmp    19 <fmtname+0x19>
  18:	48                   	dec    %eax
  19:	39 d8                	cmp    %ebx,%eax
  1b:	72 05                	jb     22 <fmtname+0x22>
  1d:	80 38 2f             	cmpb   $0x2f,(%eax)
  20:	75 f6                	jne    18 <fmtname+0x18>
    ;
  p++;
  22:	8d 58 01             	lea    0x1(%eax),%ebx

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  25:	83 ec 0c             	sub    $0xc,%esp
  28:	53                   	push   %ebx
  29:	e8 fd 02 00 00       	call   32b <strlen>
  2e:	83 c4 10             	add    $0x10,%esp
  31:	83 f8 0d             	cmp    $0xd,%eax
  34:	76 09                	jbe    3f <fmtname+0x3f>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}
  36:	89 d8                	mov    %ebx,%eax
  38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  3b:	5b                   	pop    %ebx
  3c:	5e                   	pop    %esi
  3d:	5d                   	pop    %ebp
  3e:	c3                   	ret    
  memmove(buf, p, strlen(p));
  3f:	83 ec 0c             	sub    $0xc,%esp
  42:	53                   	push   %ebx
  43:	e8 e3 02 00 00       	call   32b <strlen>
  48:	83 c4 0c             	add    $0xc,%esp
  4b:	50                   	push   %eax
  4c:	53                   	push   %ebx
  4d:	68 64 0a 00 00       	push   $0xa64
  52:	e8 e4 03 00 00       	call   43b <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  57:	89 1c 24             	mov    %ebx,(%esp)
  5a:	e8 cc 02 00 00       	call   32b <strlen>
  5f:	89 c6                	mov    %eax,%esi
  61:	89 1c 24             	mov    %ebx,(%esp)
  64:	e8 c2 02 00 00       	call   32b <strlen>
  69:	83 c4 0c             	add    $0xc,%esp
  6c:	ba 0e 00 00 00       	mov    $0xe,%edx
  71:	29 f2                	sub    %esi,%edx
  73:	52                   	push   %edx
  74:	6a 20                	push   $0x20
  76:	05 64 0a 00 00       	add    $0xa64,%eax
  7b:	50                   	push   %eax
  7c:	e8 c0 02 00 00       	call   341 <memset>
  return buf;
  81:	83 c4 10             	add    $0x10,%esp
  84:	bb 64 0a 00 00       	mov    $0xa64,%ebx
  89:	eb ab                	jmp    36 <fmtname+0x36>

0000008b <ls>:

void
ls(char *path)
{
  8b:	55                   	push   %ebp
  8c:	89 e5                	mov    %esp,%ebp
  8e:	57                   	push   %edi
  8f:	56                   	push   %esi
  90:	53                   	push   %ebx
  91:	81 ec 54 02 00 00    	sub    $0x254,%esp
  97:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  9a:	6a 00                	push   $0x0
  9c:	53                   	push   %ebx
  9d:	e8 0a 04 00 00       	call   4ac <open>
  a2:	83 c4 10             	add    $0x10,%esp
  a5:	85 c0                	test   %eax,%eax
  a7:	0f 88 8b 00 00 00    	js     138 <ls+0xad>
  ad:	89 c7                	mov    %eax,%edi
    printf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  af:	83 ec 08             	sub    $0x8,%esp
  b2:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
  b8:	50                   	push   %eax
  b9:	57                   	push   %edi
  ba:	e8 05 04 00 00       	call   4c4 <fstat>
  bf:	83 c4 10             	add    $0x10,%esp
  c2:	85 c0                	test   %eax,%eax
  c4:	0f 88 83 00 00 00    	js     14d <ls+0xc2>
    printf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  ca:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
  d0:	0f bf f0             	movswl %ax,%esi
  d3:	66 83 f8 01          	cmp    $0x1,%ax
  d7:	0f 84 8d 00 00 00    	je     16a <ls+0xdf>
  dd:	66 83 f8 02          	cmp    $0x2,%ax
  e1:	75 41                	jne    124 <ls+0x99>
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
  e3:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
  e9:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
  ef:	8b 8d cc fd ff ff    	mov    -0x234(%ebp),%ecx
  f5:	89 8d b0 fd ff ff    	mov    %ecx,-0x250(%ebp)
  fb:	83 ec 0c             	sub    $0xc,%esp
  fe:	53                   	push   %ebx
  ff:	e8 fc fe ff ff       	call   0 <fmtname>
 104:	83 c4 08             	add    $0x8,%esp
 107:	ff b5 b4 fd ff ff    	push   -0x24c(%ebp)
 10d:	ff b5 b0 fd ff ff    	push   -0x250(%ebp)
 113:	56                   	push   %esi
 114:	50                   	push   %eax
 115:	68 48 07 00 00       	push   $0x748
 11a:	6a 01                	push   $0x1
 11c:	e8 9e 04 00 00       	call   5bf <printf>
    break;
 121:	83 c4 20             	add    $0x20,%esp
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
 124:	83 ec 0c             	sub    $0xc,%esp
 127:	57                   	push   %edi
 128:	e8 67 03 00 00       	call   494 <close>
 12d:	83 c4 10             	add    $0x10,%esp
}
 130:	8d 65 f4             	lea    -0xc(%ebp),%esp
 133:	5b                   	pop    %ebx
 134:	5e                   	pop    %esi
 135:	5f                   	pop    %edi
 136:	5d                   	pop    %ebp
 137:	c3                   	ret    
    printf(2, "ls: cannot open %s\n", path);
 138:	83 ec 04             	sub    $0x4,%esp
 13b:	53                   	push   %ebx
 13c:	68 20 07 00 00       	push   $0x720
 141:	6a 02                	push   $0x2
 143:	e8 77 04 00 00       	call   5bf <printf>
    return;
 148:	83 c4 10             	add    $0x10,%esp
 14b:	eb e3                	jmp    130 <ls+0xa5>
    printf(2, "ls: cannot stat %s\n", path);
 14d:	83 ec 04             	sub    $0x4,%esp
 150:	53                   	push   %ebx
 151:	68 34 07 00 00       	push   $0x734
 156:	6a 02                	push   $0x2
 158:	e8 62 04 00 00       	call   5bf <printf>
    close(fd);
 15d:	89 3c 24             	mov    %edi,(%esp)
 160:	e8 2f 03 00 00       	call   494 <close>
    return;
 165:	83 c4 10             	add    $0x10,%esp
 168:	eb c6                	jmp    130 <ls+0xa5>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 16a:	83 ec 0c             	sub    $0xc,%esp
 16d:	53                   	push   %ebx
 16e:	e8 b8 01 00 00       	call   32b <strlen>
 173:	83 c0 10             	add    $0x10,%eax
 176:	83 c4 10             	add    $0x10,%esp
 179:	3d 00 02 00 00       	cmp    $0x200,%eax
 17e:	76 14                	jbe    194 <ls+0x109>
      printf(1, "ls: path too long\n");
 180:	83 ec 08             	sub    $0x8,%esp
 183:	68 55 07 00 00       	push   $0x755
 188:	6a 01                	push   $0x1
 18a:	e8 30 04 00 00       	call   5bf <printf>
      break;
 18f:	83 c4 10             	add    $0x10,%esp
 192:	eb 90                	jmp    124 <ls+0x99>
    strcpy(buf, path);
 194:	83 ec 08             	sub    $0x8,%esp
 197:	53                   	push   %ebx
 198:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
 19e:	53                   	push   %ebx
 19f:	e8 47 01 00 00       	call   2eb <strcpy>
    p = buf+strlen(buf);
 1a4:	89 1c 24             	mov    %ebx,(%esp)
 1a7:	e8 7f 01 00 00       	call   32b <strlen>
 1ac:	8d 34 03             	lea    (%ebx,%eax,1),%esi
    *p++ = '/';
 1af:	8d 44 03 01          	lea    0x1(%ebx,%eax,1),%eax
 1b3:	89 85 ac fd ff ff    	mov    %eax,-0x254(%ebp)
 1b9:	c6 06 2f             	movb   $0x2f,(%esi)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1bc:	83 c4 10             	add    $0x10,%esp
 1bf:	eb 19                	jmp    1da <ls+0x14f>
        printf(1, "ls: cannot stat %s\n", buf);
 1c1:	83 ec 04             	sub    $0x4,%esp
 1c4:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
 1ca:	50                   	push   %eax
 1cb:	68 34 07 00 00       	push   $0x734
 1d0:	6a 01                	push   $0x1
 1d2:	e8 e8 03 00 00       	call   5bf <printf>
        continue;
 1d7:	83 c4 10             	add    $0x10,%esp
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1da:	83 ec 04             	sub    $0x4,%esp
 1dd:	6a 10                	push   $0x10
 1df:	8d 85 d8 fd ff ff    	lea    -0x228(%ebp),%eax
 1e5:	50                   	push   %eax
 1e6:	57                   	push   %edi
 1e7:	e8 98 02 00 00       	call   484 <read>
 1ec:	83 c4 10             	add    $0x10,%esp
 1ef:	83 f8 10             	cmp    $0x10,%eax
 1f2:	0f 85 2c ff ff ff    	jne    124 <ls+0x99>
      if(de.inum == 0)
 1f8:	66 83 bd d8 fd ff ff 	cmpw   $0x0,-0x228(%ebp)
 1ff:	00 
 200:	74 d8                	je     1da <ls+0x14f>
      memmove(p, de.name, DIRSIZ);
 202:	83 ec 04             	sub    $0x4,%esp
 205:	6a 0e                	push   $0xe
 207:	8d 85 da fd ff ff    	lea    -0x226(%ebp),%eax
 20d:	50                   	push   %eax
 20e:	ff b5 ac fd ff ff    	push   -0x254(%ebp)
 214:	e8 22 02 00 00       	call   43b <memmove>
      p[DIRSIZ] = 0;
 219:	c6 46 0f 00          	movb   $0x0,0xf(%esi)
      if(stat(buf, &st) < 0){
 21d:	83 c4 08             	add    $0x8,%esp
 220:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
 226:	50                   	push   %eax
 227:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
 22d:	50                   	push   %eax
 22e:	e8 97 01 00 00       	call   3ca <stat>
 233:	83 c4 10             	add    $0x10,%esp
 236:	85 c0                	test   %eax,%eax
 238:	78 87                	js     1c1 <ls+0x136>
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 23a:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
 240:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
 246:	8b 95 cc fd ff ff    	mov    -0x234(%ebp),%edx
 24c:	89 95 b0 fd ff ff    	mov    %edx,-0x250(%ebp)
 252:	8b 9d c4 fd ff ff    	mov    -0x23c(%ebp),%ebx
 258:	83 ec 0c             	sub    $0xc,%esp
 25b:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
 261:	50                   	push   %eax
 262:	e8 99 fd ff ff       	call   0 <fmtname>
 267:	83 c4 08             	add    $0x8,%esp
 26a:	ff b5 b4 fd ff ff    	push   -0x24c(%ebp)
 270:	ff b5 b0 fd ff ff    	push   -0x250(%ebp)
 276:	0f bf db             	movswl %bx,%ebx
 279:	53                   	push   %ebx
 27a:	50                   	push   %eax
 27b:	68 48 07 00 00       	push   $0x748
 280:	6a 01                	push   $0x1
 282:	e8 38 03 00 00       	call   5bf <printf>
 287:	83 c4 20             	add    $0x20,%esp
 28a:	e9 4b ff ff ff       	jmp    1da <ls+0x14f>

0000028f <main>:

int
main(int argc, char *argv[])
{
 28f:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 293:	83 e4 f0             	and    $0xfffffff0,%esp
 296:	ff 71 fc             	push   -0x4(%ecx)
 299:	55                   	push   %ebp
 29a:	89 e5                	mov    %esp,%ebp
 29c:	57                   	push   %edi
 29d:	56                   	push   %esi
 29e:	53                   	push   %ebx
 29f:	51                   	push   %ecx
 2a0:	83 ec 08             	sub    $0x8,%esp
 2a3:	8b 31                	mov    (%ecx),%esi
 2a5:	8b 79 04             	mov    0x4(%ecx),%edi
  int i;

  if(argc < 2){
 2a8:	83 fe 01             	cmp    $0x1,%esi
 2ab:	7e 07                	jle    2b4 <main+0x25>
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
 2ad:	bb 01 00 00 00       	mov    $0x1,%ebx
 2b2:	eb 28                	jmp    2dc <main+0x4d>
    ls(".");
 2b4:	83 ec 0c             	sub    $0xc,%esp
 2b7:	68 68 07 00 00       	push   $0x768
 2bc:	e8 ca fd ff ff       	call   8b <ls>
    exit(0);
 2c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2c8:	e8 9f 01 00 00       	call   46c <exit>
    ls(argv[i]);
 2cd:	83 ec 0c             	sub    $0xc,%esp
 2d0:	ff 34 9f             	push   (%edi,%ebx,4)
 2d3:	e8 b3 fd ff ff       	call   8b <ls>
  for(i=1; i<argc; i++)
 2d8:	43                   	inc    %ebx
 2d9:	83 c4 10             	add    $0x10,%esp
 2dc:	39 f3                	cmp    %esi,%ebx
 2de:	7c ed                	jl     2cd <main+0x3e>
  exit(0);
 2e0:	83 ec 0c             	sub    $0xc,%esp
 2e3:	6a 00                	push   $0x0
 2e5:	e8 82 01 00 00       	call   46c <exit>

000002ea <start>:

// Entry point of the library	
void
start()
{
}
 2ea:	c3                   	ret    

000002eb <strcpy>:

char*
strcpy(char *s, const char *t)
{
 2eb:	55                   	push   %ebp
 2ec:	89 e5                	mov    %esp,%ebp
 2ee:	56                   	push   %esi
 2ef:	53                   	push   %ebx
 2f0:	8b 45 08             	mov    0x8(%ebp),%eax
 2f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2f6:	89 c2                	mov    %eax,%edx
 2f8:	89 cb                	mov    %ecx,%ebx
 2fa:	41                   	inc    %ecx
 2fb:	89 d6                	mov    %edx,%esi
 2fd:	42                   	inc    %edx
 2fe:	8a 1b                	mov    (%ebx),%bl
 300:	88 1e                	mov    %bl,(%esi)
 302:	84 db                	test   %bl,%bl
 304:	75 f2                	jne    2f8 <strcpy+0xd>
    ;
  return os;
}
 306:	5b                   	pop    %ebx
 307:	5e                   	pop    %esi
 308:	5d                   	pop    %ebp
 309:	c3                   	ret    

0000030a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 30a:	55                   	push   %ebp
 30b:	89 e5                	mov    %esp,%ebp
 30d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 310:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 313:	eb 02                	jmp    317 <strcmp+0xd>
    p++, q++;
 315:	41                   	inc    %ecx
 316:	42                   	inc    %edx
  while(*p && *p == *q)
 317:	8a 01                	mov    (%ecx),%al
 319:	84 c0                	test   %al,%al
 31b:	74 04                	je     321 <strcmp+0x17>
 31d:	3a 02                	cmp    (%edx),%al
 31f:	74 f4                	je     315 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 321:	0f b6 c0             	movzbl %al,%eax
 324:	0f b6 12             	movzbl (%edx),%edx
 327:	29 d0                	sub    %edx,%eax
}
 329:	5d                   	pop    %ebp
 32a:	c3                   	ret    

0000032b <strlen>:

uint
strlen(const char *s)
{
 32b:	55                   	push   %ebp
 32c:	89 e5                	mov    %esp,%ebp
 32e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 331:	b8 00 00 00 00       	mov    $0x0,%eax
 336:	eb 01                	jmp    339 <strlen+0xe>
 338:	40                   	inc    %eax
 339:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
 33d:	75 f9                	jne    338 <strlen+0xd>
    ;
  return n;
}
 33f:	5d                   	pop    %ebp
 340:	c3                   	ret    

00000341 <memset>:

void*
memset(void *dst, int c, uint n)
{
 341:	55                   	push   %ebp
 342:	89 e5                	mov    %esp,%ebp
 344:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 345:	8b 7d 08             	mov    0x8(%ebp),%edi
 348:	8b 4d 10             	mov    0x10(%ebp),%ecx
 34b:	8b 45 0c             	mov    0xc(%ebp),%eax
 34e:	fc                   	cld    
 34f:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 351:	8b 45 08             	mov    0x8(%ebp),%eax
 354:	8b 7d fc             	mov    -0x4(%ebp),%edi
 357:	c9                   	leave  
 358:	c3                   	ret    

00000359 <strchr>:

char*
strchr(const char *s, char c)
{
 359:	55                   	push   %ebp
 35a:	89 e5                	mov    %esp,%ebp
 35c:	8b 45 08             	mov    0x8(%ebp),%eax
 35f:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
 362:	eb 01                	jmp    365 <strchr+0xc>
 364:	40                   	inc    %eax
 365:	8a 10                	mov    (%eax),%dl
 367:	84 d2                	test   %dl,%dl
 369:	74 06                	je     371 <strchr+0x18>
    if(*s == c)
 36b:	38 ca                	cmp    %cl,%dl
 36d:	75 f5                	jne    364 <strchr+0xb>
 36f:	eb 05                	jmp    376 <strchr+0x1d>
      return (char*)s;
  return 0;
 371:	b8 00 00 00 00       	mov    $0x0,%eax
}
 376:	5d                   	pop    %ebp
 377:	c3                   	ret    

00000378 <gets>:

char*
gets(char *buf, int max)
{
 378:	55                   	push   %ebp
 379:	89 e5                	mov    %esp,%ebp
 37b:	57                   	push   %edi
 37c:	56                   	push   %esi
 37d:	53                   	push   %ebx
 37e:	83 ec 1c             	sub    $0x1c,%esp
 381:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 384:	bb 00 00 00 00       	mov    $0x0,%ebx
 389:	89 de                	mov    %ebx,%esi
 38b:	43                   	inc    %ebx
 38c:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 38f:	7d 2b                	jge    3bc <gets+0x44>
    cc = read(0, &c, 1);
 391:	83 ec 04             	sub    $0x4,%esp
 394:	6a 01                	push   $0x1
 396:	8d 45 e7             	lea    -0x19(%ebp),%eax
 399:	50                   	push   %eax
 39a:	6a 00                	push   $0x0
 39c:	e8 e3 00 00 00       	call   484 <read>
    if(cc < 1)
 3a1:	83 c4 10             	add    $0x10,%esp
 3a4:	85 c0                	test   %eax,%eax
 3a6:	7e 14                	jle    3bc <gets+0x44>
      break;
    buf[i++] = c;
 3a8:	8a 45 e7             	mov    -0x19(%ebp),%al
 3ab:	88 04 37             	mov    %al,(%edi,%esi,1)
    if(c == '\n' || c == '\r')
 3ae:	3c 0a                	cmp    $0xa,%al
 3b0:	74 08                	je     3ba <gets+0x42>
 3b2:	3c 0d                	cmp    $0xd,%al
 3b4:	75 d3                	jne    389 <gets+0x11>
    buf[i++] = c;
 3b6:	89 de                	mov    %ebx,%esi
 3b8:	eb 02                	jmp    3bc <gets+0x44>
 3ba:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 3bc:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 3c0:	89 f8                	mov    %edi,%eax
 3c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3c5:	5b                   	pop    %ebx
 3c6:	5e                   	pop    %esi
 3c7:	5f                   	pop    %edi
 3c8:	5d                   	pop    %ebp
 3c9:	c3                   	ret    

000003ca <stat>:

int
stat(const char *n, struct stat *st)
{
 3ca:	55                   	push   %ebp
 3cb:	89 e5                	mov    %esp,%ebp
 3cd:	56                   	push   %esi
 3ce:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3cf:	83 ec 08             	sub    $0x8,%esp
 3d2:	6a 00                	push   $0x0
 3d4:	ff 75 08             	push   0x8(%ebp)
 3d7:	e8 d0 00 00 00       	call   4ac <open>
  if(fd < 0)
 3dc:	83 c4 10             	add    $0x10,%esp
 3df:	85 c0                	test   %eax,%eax
 3e1:	78 24                	js     407 <stat+0x3d>
 3e3:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 3e5:	83 ec 08             	sub    $0x8,%esp
 3e8:	ff 75 0c             	push   0xc(%ebp)
 3eb:	50                   	push   %eax
 3ec:	e8 d3 00 00 00       	call   4c4 <fstat>
 3f1:	89 c6                	mov    %eax,%esi
  close(fd);
 3f3:	89 1c 24             	mov    %ebx,(%esp)
 3f6:	e8 99 00 00 00       	call   494 <close>
  return r;
 3fb:	83 c4 10             	add    $0x10,%esp
}
 3fe:	89 f0                	mov    %esi,%eax
 400:	8d 65 f8             	lea    -0x8(%ebp),%esp
 403:	5b                   	pop    %ebx
 404:	5e                   	pop    %esi
 405:	5d                   	pop    %ebp
 406:	c3                   	ret    
    return -1;
 407:	be ff ff ff ff       	mov    $0xffffffff,%esi
 40c:	eb f0                	jmp    3fe <stat+0x34>

0000040e <atoi>:

int
atoi(const char *s)
{
 40e:	55                   	push   %ebp
 40f:	89 e5                	mov    %esp,%ebp
 411:	53                   	push   %ebx
 412:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 415:	ba 00 00 00 00       	mov    $0x0,%edx
  while('0' <= *s && *s <= '9')
 41a:	eb 0e                	jmp    42a <atoi+0x1c>
    n = n*10 + *s++ - '0';
 41c:	8d 14 92             	lea    (%edx,%edx,4),%edx
 41f:	8d 1c 12             	lea    (%edx,%edx,1),%ebx
 422:	41                   	inc    %ecx
 423:	0f be c0             	movsbl %al,%eax
 426:	8d 54 18 d0          	lea    -0x30(%eax,%ebx,1),%edx
  while('0' <= *s && *s <= '9')
 42a:	8a 01                	mov    (%ecx),%al
 42c:	8d 58 d0             	lea    -0x30(%eax),%ebx
 42f:	80 fb 09             	cmp    $0x9,%bl
 432:	76 e8                	jbe    41c <atoi+0xe>
  return n;
}
 434:	89 d0                	mov    %edx,%eax
 436:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 439:	c9                   	leave  
 43a:	c3                   	ret    

0000043b <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 43b:	55                   	push   %ebp
 43c:	89 e5                	mov    %esp,%ebp
 43e:	56                   	push   %esi
 43f:	53                   	push   %ebx
 440:	8b 45 08             	mov    0x8(%ebp),%eax
 443:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 446:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 449:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 44b:	eb 0c                	jmp    459 <memmove+0x1e>
    *dst++ = *src++;
 44d:	8a 13                	mov    (%ebx),%dl
 44f:	88 11                	mov    %dl,(%ecx)
 451:	8d 5b 01             	lea    0x1(%ebx),%ebx
 454:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 457:	89 f2                	mov    %esi,%edx
 459:	8d 72 ff             	lea    -0x1(%edx),%esi
 45c:	85 d2                	test   %edx,%edx
 45e:	7f ed                	jg     44d <memmove+0x12>
  return vdst;
}
 460:	5b                   	pop    %ebx
 461:	5e                   	pop    %esi
 462:	5d                   	pop    %ebp
 463:	c3                   	ret    

00000464 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 464:	b8 01 00 00 00       	mov    $0x1,%eax
 469:	cd 40                	int    $0x40
 46b:	c3                   	ret    

0000046c <exit>:
SYSCALL(exit)
 46c:	b8 02 00 00 00       	mov    $0x2,%eax
 471:	cd 40                	int    $0x40
 473:	c3                   	ret    

00000474 <wait>:
SYSCALL(wait)
 474:	b8 03 00 00 00       	mov    $0x3,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <pipe>:
SYSCALL(pipe)
 47c:	b8 04 00 00 00       	mov    $0x4,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <read>:
SYSCALL(read)
 484:	b8 05 00 00 00       	mov    $0x5,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <write>:
SYSCALL(write)
 48c:	b8 10 00 00 00       	mov    $0x10,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <close>:
SYSCALL(close)
 494:	b8 15 00 00 00       	mov    $0x15,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <kill>:
SYSCALL(kill)
 49c:	b8 06 00 00 00       	mov    $0x6,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <exec>:
SYSCALL(exec)
 4a4:	b8 07 00 00 00       	mov    $0x7,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <open>:
SYSCALL(open)
 4ac:	b8 0f 00 00 00       	mov    $0xf,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <mknod>:
SYSCALL(mknod)
 4b4:	b8 11 00 00 00       	mov    $0x11,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <unlink>:
SYSCALL(unlink)
 4bc:	b8 12 00 00 00       	mov    $0x12,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <fstat>:
SYSCALL(fstat)
 4c4:	b8 08 00 00 00       	mov    $0x8,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <link>:
SYSCALL(link)
 4cc:	b8 13 00 00 00       	mov    $0x13,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <mkdir>:
SYSCALL(mkdir)
 4d4:	b8 14 00 00 00       	mov    $0x14,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <chdir>:
SYSCALL(chdir)
 4dc:	b8 09 00 00 00       	mov    $0x9,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <dup>:
SYSCALL(dup)
 4e4:	b8 0a 00 00 00       	mov    $0xa,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <getpid>:
SYSCALL(getpid)
 4ec:	b8 0b 00 00 00       	mov    $0xb,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <sbrk>:
SYSCALL(sbrk)
 4f4:	b8 0c 00 00 00       	mov    $0xc,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <sleep>:
SYSCALL(sleep)
 4fc:	b8 0d 00 00 00       	mov    $0xd,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <uptime>:
SYSCALL(uptime)
 504:	b8 0e 00 00 00       	mov    $0xe,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <date>:
SYSCALL(date)
 50c:	b8 16 00 00 00       	mov    $0x16,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <dup2>:
SYSCALL(dup2)
 514:	b8 17 00 00 00       	mov    $0x17,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <getprio>:
SYSCALL(getprio)
 51c:	b8 18 00 00 00       	mov    $0x18,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <setprio>:
SYSCALL(setprio)
 524:	b8 19 00 00 00       	mov    $0x19,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 52c:	55                   	push   %ebp
 52d:	89 e5                	mov    %esp,%ebp
 52f:	83 ec 1c             	sub    $0x1c,%esp
 532:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 535:	6a 01                	push   $0x1
 537:	8d 55 f4             	lea    -0xc(%ebp),%edx
 53a:	52                   	push   %edx
 53b:	50                   	push   %eax
 53c:	e8 4b ff ff ff       	call   48c <write>
}
 541:	83 c4 10             	add    $0x10,%esp
 544:	c9                   	leave  
 545:	c3                   	ret    

00000546 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 546:	55                   	push   %ebp
 547:	89 e5                	mov    %esp,%ebp
 549:	57                   	push   %edi
 54a:	56                   	push   %esi
 54b:	53                   	push   %ebx
 54c:	83 ec 2c             	sub    $0x2c,%esp
 54f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 552:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 554:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 558:	74 04                	je     55e <printint+0x18>
 55a:	85 d2                	test   %edx,%edx
 55c:	78 3c                	js     59a <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 55e:	89 d1                	mov    %edx,%ecx
  neg = 0;
 560:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 567:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 56c:	89 c8                	mov    %ecx,%eax
 56e:	ba 00 00 00 00       	mov    $0x0,%edx
 573:	f7 f6                	div    %esi
 575:	89 df                	mov    %ebx,%edi
 577:	43                   	inc    %ebx
 578:	8a 92 cc 07 00 00    	mov    0x7cc(%edx),%dl
 57e:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 582:	89 ca                	mov    %ecx,%edx
 584:	89 c1                	mov    %eax,%ecx
 586:	39 d6                	cmp    %edx,%esi
 588:	76 e2                	jbe    56c <printint+0x26>
  if(neg)
 58a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 58e:	74 24                	je     5b4 <printint+0x6e>
    buf[i++] = '-';
 590:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 595:	8d 5f 02             	lea    0x2(%edi),%ebx
 598:	eb 1a                	jmp    5b4 <printint+0x6e>
    x = -xx;
 59a:	89 d1                	mov    %edx,%ecx
 59c:	f7 d9                	neg    %ecx
    neg = 1;
 59e:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 5a5:	eb c0                	jmp    567 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 5a7:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 5ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 5af:	e8 78 ff ff ff       	call   52c <putc>
  while(--i >= 0)
 5b4:	4b                   	dec    %ebx
 5b5:	79 f0                	jns    5a7 <printint+0x61>
}
 5b7:	83 c4 2c             	add    $0x2c,%esp
 5ba:	5b                   	pop    %ebx
 5bb:	5e                   	pop    %esi
 5bc:	5f                   	pop    %edi
 5bd:	5d                   	pop    %ebp
 5be:	c3                   	ret    

000005bf <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 5bf:	55                   	push   %ebp
 5c0:	89 e5                	mov    %esp,%ebp
 5c2:	57                   	push   %edi
 5c3:	56                   	push   %esi
 5c4:	53                   	push   %ebx
 5c5:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 5c8:	8d 45 10             	lea    0x10(%ebp),%eax
 5cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 5ce:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 5d3:	bb 00 00 00 00       	mov    $0x0,%ebx
 5d8:	eb 12                	jmp    5ec <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 5da:	89 fa                	mov    %edi,%edx
 5dc:	8b 45 08             	mov    0x8(%ebp),%eax
 5df:	e8 48 ff ff ff       	call   52c <putc>
 5e4:	eb 05                	jmp    5eb <printf+0x2c>
      }
    } else if(state == '%'){
 5e6:	83 fe 25             	cmp    $0x25,%esi
 5e9:	74 22                	je     60d <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 5eb:	43                   	inc    %ebx
 5ec:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ef:	8a 04 18             	mov    (%eax,%ebx,1),%al
 5f2:	84 c0                	test   %al,%al
 5f4:	0f 84 1d 01 00 00    	je     717 <printf+0x158>
    c = fmt[i] & 0xff;
 5fa:	0f be f8             	movsbl %al,%edi
 5fd:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 600:	85 f6                	test   %esi,%esi
 602:	75 e2                	jne    5e6 <printf+0x27>
      if(c == '%'){
 604:	83 f8 25             	cmp    $0x25,%eax
 607:	75 d1                	jne    5da <printf+0x1b>
        state = '%';
 609:	89 c6                	mov    %eax,%esi
 60b:	eb de                	jmp    5eb <printf+0x2c>
      if(c == 'd'){
 60d:	83 f8 25             	cmp    $0x25,%eax
 610:	0f 84 cc 00 00 00    	je     6e2 <printf+0x123>
 616:	0f 8c da 00 00 00    	jl     6f6 <printf+0x137>
 61c:	83 f8 78             	cmp    $0x78,%eax
 61f:	0f 8f d1 00 00 00    	jg     6f6 <printf+0x137>
 625:	83 f8 63             	cmp    $0x63,%eax
 628:	0f 8c c8 00 00 00    	jl     6f6 <printf+0x137>
 62e:	83 e8 63             	sub    $0x63,%eax
 631:	83 f8 15             	cmp    $0x15,%eax
 634:	0f 87 bc 00 00 00    	ja     6f6 <printf+0x137>
 63a:	ff 24 85 74 07 00 00 	jmp    *0x774(,%eax,4)
        printint(fd, *ap, 10, 1);
 641:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 644:	8b 17                	mov    (%edi),%edx
 646:	83 ec 0c             	sub    $0xc,%esp
 649:	6a 01                	push   $0x1
 64b:	b9 0a 00 00 00       	mov    $0xa,%ecx
 650:	8b 45 08             	mov    0x8(%ebp),%eax
 653:	e8 ee fe ff ff       	call   546 <printint>
        ap++;
 658:	83 c7 04             	add    $0x4,%edi
 65b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 65e:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 661:	be 00 00 00 00       	mov    $0x0,%esi
 666:	eb 83                	jmp    5eb <printf+0x2c>
        printint(fd, *ap, 16, 0);
 668:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 66b:	8b 17                	mov    (%edi),%edx
 66d:	83 ec 0c             	sub    $0xc,%esp
 670:	6a 00                	push   $0x0
 672:	b9 10 00 00 00       	mov    $0x10,%ecx
 677:	8b 45 08             	mov    0x8(%ebp),%eax
 67a:	e8 c7 fe ff ff       	call   546 <printint>
        ap++;
 67f:	83 c7 04             	add    $0x4,%edi
 682:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 685:	83 c4 10             	add    $0x10,%esp
      state = 0;
 688:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 68d:	e9 59 ff ff ff       	jmp    5eb <printf+0x2c>
        s = (char*)*ap;
 692:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 695:	8b 30                	mov    (%eax),%esi
        ap++;
 697:	83 c0 04             	add    $0x4,%eax
 69a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 69d:	85 f6                	test   %esi,%esi
 69f:	75 13                	jne    6b4 <printf+0xf5>
          s = "(null)";
 6a1:	be 6a 07 00 00       	mov    $0x76a,%esi
 6a6:	eb 0c                	jmp    6b4 <printf+0xf5>
          putc(fd, *s);
 6a8:	0f be d2             	movsbl %dl,%edx
 6ab:	8b 45 08             	mov    0x8(%ebp),%eax
 6ae:	e8 79 fe ff ff       	call   52c <putc>
          s++;
 6b3:	46                   	inc    %esi
        while(*s != 0){
 6b4:	8a 16                	mov    (%esi),%dl
 6b6:	84 d2                	test   %dl,%dl
 6b8:	75 ee                	jne    6a8 <printf+0xe9>
      state = 0;
 6ba:	be 00 00 00 00       	mov    $0x0,%esi
 6bf:	e9 27 ff ff ff       	jmp    5eb <printf+0x2c>
        putc(fd, *ap);
 6c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 6c7:	0f be 17             	movsbl (%edi),%edx
 6ca:	8b 45 08             	mov    0x8(%ebp),%eax
 6cd:	e8 5a fe ff ff       	call   52c <putc>
        ap++;
 6d2:	83 c7 04             	add    $0x4,%edi
 6d5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 6d8:	be 00 00 00 00       	mov    $0x0,%esi
 6dd:	e9 09 ff ff ff       	jmp    5eb <printf+0x2c>
        putc(fd, c);
 6e2:	89 fa                	mov    %edi,%edx
 6e4:	8b 45 08             	mov    0x8(%ebp),%eax
 6e7:	e8 40 fe ff ff       	call   52c <putc>
      state = 0;
 6ec:	be 00 00 00 00       	mov    $0x0,%esi
 6f1:	e9 f5 fe ff ff       	jmp    5eb <printf+0x2c>
        putc(fd, '%');
 6f6:	ba 25 00 00 00       	mov    $0x25,%edx
 6fb:	8b 45 08             	mov    0x8(%ebp),%eax
 6fe:	e8 29 fe ff ff       	call   52c <putc>
        putc(fd, c);
 703:	89 fa                	mov    %edi,%edx
 705:	8b 45 08             	mov    0x8(%ebp),%eax
 708:	e8 1f fe ff ff       	call   52c <putc>
      state = 0;
 70d:	be 00 00 00 00       	mov    $0x0,%esi
 712:	e9 d4 fe ff ff       	jmp    5eb <printf+0x2c>
    }
  }
}
 717:	8d 65 f4             	lea    -0xc(%ebp),%esp
 71a:	5b                   	pop    %ebx
 71b:	5e                   	pop    %esi
 71c:	5f                   	pop    %edi
 71d:	5d                   	pop    %ebp
 71e:	c3                   	ret    
