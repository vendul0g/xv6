
sh:     file format elf32-i386


Disassembly of section .text:

00000000 <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	56                   	push   %esi
   4:	53                   	push   %ebx
   5:	8b 5d 08             	mov    0x8(%ebp),%ebx
   8:	8b 75 0c             	mov    0xc(%ebp),%esi
  printf(2, "$ ");
   b:	83 ec 08             	sub    $0x8,%esp
   e:	68 ac 0f 00 00       	push   $0xfac
  13:	6a 02                	push   $0x2
  15:	e8 eb 0c 00 00       	call   d05 <printf>
  memset(buf, 0, nbuf);
  1a:	83 c4 0c             	add    $0xc,%esp
  1d:	56                   	push   %esi
  1e:	6a 00                	push   $0x0
  20:	53                   	push   %ebx
  21:	e8 61 0a 00 00       	call   a87 <memset>
  gets(buf, nbuf);
  26:	83 c4 08             	add    $0x8,%esp
  29:	56                   	push   %esi
  2a:	53                   	push   %ebx
  2b:	e8 8e 0a 00 00       	call   abe <gets>
  if(buf[0] == 0) // EOF
  30:	83 c4 10             	add    $0x10,%esp
  33:	80 3b 00             	cmpb   $0x0,(%ebx)
  36:	74 0c                	je     44 <getcmd+0x44>
    return -1;
  return 0;
  38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  40:	5b                   	pop    %ebx
  41:	5e                   	pop    %esi
  42:	5d                   	pop    %ebp
  43:	c3                   	ret    
    return -1;
  44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  49:	eb f2                	jmp    3d <getcmd+0x3d>

0000004b <panic>:
  exit(0);
}

void
panic(char *s)
{
  4b:	55                   	push   %ebp
  4c:	89 e5                	mov    %esp,%ebp
  4e:	83 ec 0c             	sub    $0xc,%esp
  printf(2, "%s\n", s);
  51:	ff 75 08             	push   0x8(%ebp)
  54:	68 49 10 00 00       	push   $0x1049
  59:	6a 02                	push   $0x2
  5b:	e8 a5 0c 00 00       	call   d05 <printf>
  exit(0);
  60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  67:	e8 46 0b 00 00       	call   bb2 <exit>

0000006c <fork1>:
}

int
fork1(void)
{
  6c:	55                   	push   %ebp
  6d:	89 e5                	mov    %esp,%ebp
  6f:	83 ec 08             	sub    $0x8,%esp
  int pid;

  pid = fork();
  72:	e8 33 0b 00 00       	call   baa <fork>
  if(pid == -1)
  77:	83 f8 ff             	cmp    $0xffffffff,%eax
  7a:	74 02                	je     7e <fork1+0x12>
    panic("fork");
  return pid;
}
  7c:	c9                   	leave  
  7d:	c3                   	ret    
    panic("fork");
  7e:	83 ec 0c             	sub    $0xc,%esp
  81:	68 af 0f 00 00       	push   $0xfaf
  86:	e8 c0 ff ff ff       	call   4b <panic>

0000008b <runcmd>:
{
  8b:	55                   	push   %ebp
  8c:	89 e5                	mov    %esp,%ebp
  8e:	53                   	push   %ebx
  8f:	83 ec 14             	sub    $0x14,%esp
  92:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(cmd == 0)
  95:	85 db                	test   %ebx,%ebx
  97:	74 0e                	je     a7 <runcmd+0x1c>
  switch(cmd->type){
  99:	8b 03                	mov    (%ebx),%eax
  9b:	83 f8 05             	cmp    $0x5,%eax
  9e:	77 11                	ja     b1 <runcmd+0x26>
  a0:	ff 24 85 90 10 00 00 	jmp    *0x1090(,%eax,4)
    exit(0);
  a7:	83 ec 0c             	sub    $0xc,%esp
  aa:	6a 00                	push   $0x0
  ac:	e8 01 0b 00 00       	call   bb2 <exit>
    panic("runcmd");
  b1:	83 ec 0c             	sub    $0xc,%esp
  b4:	68 b4 0f 00 00       	push   $0xfb4
  b9:	e8 8d ff ff ff       	call   4b <panic>
    if(ecmd->argv[0] == 0)
  be:	8b 43 04             	mov    0x4(%ebx),%eax
  c1:	85 c0                	test   %eax,%eax
  c3:	74 2c                	je     f1 <runcmd+0x66>
    exec(ecmd->argv[0], ecmd->argv);
  c5:	8d 53 04             	lea    0x4(%ebx),%edx
  c8:	83 ec 08             	sub    $0x8,%esp
  cb:	52                   	push   %edx
  cc:	50                   	push   %eax
  cd:	e8 18 0b 00 00       	call   bea <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
  d2:	83 c4 0c             	add    $0xc,%esp
  d5:	ff 73 04             	push   0x4(%ebx)
  d8:	68 bb 0f 00 00       	push   $0xfbb
  dd:	6a 02                	push   $0x2
  df:	e8 21 0c 00 00       	call   d05 <printf>
    break;
  e4:	83 c4 10             	add    $0x10,%esp
  exit(0);
  e7:	83 ec 0c             	sub    $0xc,%esp
  ea:	6a 00                	push   $0x0
  ec:	e8 c1 0a 00 00       	call   bb2 <exit>
      exit(0);
  f1:	83 ec 0c             	sub    $0xc,%esp
  f4:	6a 00                	push   $0x0
  f6:	e8 b7 0a 00 00       	call   bb2 <exit>
    close(rcmd->fd);
  fb:	83 ec 0c             	sub    $0xc,%esp
  fe:	ff 73 14             	push   0x14(%ebx)
 101:	e8 d4 0a 00 00       	call   bda <close>
    if(open(rcmd->file, rcmd->mode) < 0){
 106:	83 c4 08             	add    $0x8,%esp
 109:	ff 73 10             	push   0x10(%ebx)
 10c:	ff 73 08             	push   0x8(%ebx)
 10f:	e8 de 0a 00 00       	call   bf2 <open>
 114:	83 c4 10             	add    $0x10,%esp
 117:	85 c0                	test   %eax,%eax
 119:	78 0b                	js     126 <runcmd+0x9b>
    runcmd(rcmd->cmd);
 11b:	83 ec 0c             	sub    $0xc,%esp
 11e:	ff 73 04             	push   0x4(%ebx)
 121:	e8 65 ff ff ff       	call   8b <runcmd>
      printf(2, "open %s failed\n", rcmd->file);
 126:	83 ec 04             	sub    $0x4,%esp
 129:	ff 73 08             	push   0x8(%ebx)
 12c:	68 cb 0f 00 00       	push   $0xfcb
 131:	6a 02                	push   $0x2
 133:	e8 cd 0b 00 00       	call   d05 <printf>
      exit(0);
 138:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 13f:	e8 6e 0a 00 00       	call   bb2 <exit>
    if(fork1() == 0)
 144:	e8 23 ff ff ff       	call   6c <fork1>
 149:	85 c0                	test   %eax,%eax
 14b:	74 15                	je     162 <runcmd+0xd7>
    wait(NULL);
 14d:	83 ec 0c             	sub    $0xc,%esp
 150:	6a 00                	push   $0x0
 152:	e8 63 0a 00 00       	call   bba <wait>
    runcmd(lcmd->right);
 157:	83 c4 04             	add    $0x4,%esp
 15a:	ff 73 08             	push   0x8(%ebx)
 15d:	e8 29 ff ff ff       	call   8b <runcmd>
      runcmd(lcmd->left);
 162:	83 ec 0c             	sub    $0xc,%esp
 165:	ff 73 04             	push   0x4(%ebx)
 168:	e8 1e ff ff ff       	call   8b <runcmd>
    if(pipe(p) < 0)
 16d:	83 ec 0c             	sub    $0xc,%esp
 170:	8d 45 f0             	lea    -0x10(%ebp),%eax
 173:	50                   	push   %eax
 174:	e8 49 0a 00 00       	call   bc2 <pipe>
 179:	83 c4 10             	add    $0x10,%esp
 17c:	85 c0                	test   %eax,%eax
 17e:	78 48                	js     1c8 <runcmd+0x13d>
    if(fork1() == 0){
 180:	e8 e7 fe ff ff       	call   6c <fork1>
 185:	85 c0                	test   %eax,%eax
 187:	74 4c                	je     1d5 <runcmd+0x14a>
    if(fork1() == 0){
 189:	e8 de fe ff ff       	call   6c <fork1>
 18e:	85 c0                	test   %eax,%eax
 190:	74 79                	je     20b <runcmd+0x180>
    close(p[0]);
 192:	83 ec 0c             	sub    $0xc,%esp
 195:	ff 75 f0             	push   -0x10(%ebp)
 198:	e8 3d 0a 00 00       	call   bda <close>
    close(p[1]);
 19d:	83 c4 04             	add    $0x4,%esp
 1a0:	ff 75 f4             	push   -0xc(%ebp)
 1a3:	e8 32 0a 00 00       	call   bda <close>
    wait(NULL);
 1a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1af:	e8 06 0a 00 00       	call   bba <wait>
    wait(NULL);
 1b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1bb:	e8 fa 09 00 00       	call   bba <wait>
    break;
 1c0:	83 c4 10             	add    $0x10,%esp
 1c3:	e9 1f ff ff ff       	jmp    e7 <runcmd+0x5c>
      panic("pipe");
 1c8:	83 ec 0c             	sub    $0xc,%esp
 1cb:	68 db 0f 00 00       	push   $0xfdb
 1d0:	e8 76 fe ff ff       	call   4b <panic>
      close(1);
 1d5:	83 ec 0c             	sub    $0xc,%esp
 1d8:	6a 01                	push   $0x1
 1da:	e8 fb 09 00 00       	call   bda <close>
      dup(p[1]);
 1df:	83 c4 04             	add    $0x4,%esp
 1e2:	ff 75 f4             	push   -0xc(%ebp)
 1e5:	e8 40 0a 00 00       	call   c2a <dup>
      close(p[0]);
 1ea:	83 c4 04             	add    $0x4,%esp
 1ed:	ff 75 f0             	push   -0x10(%ebp)
 1f0:	e8 e5 09 00 00       	call   bda <close>
      close(p[1]);
 1f5:	83 c4 04             	add    $0x4,%esp
 1f8:	ff 75 f4             	push   -0xc(%ebp)
 1fb:	e8 da 09 00 00       	call   bda <close>
      runcmd(pcmd->left);
 200:	83 c4 04             	add    $0x4,%esp
 203:	ff 73 04             	push   0x4(%ebx)
 206:	e8 80 fe ff ff       	call   8b <runcmd>
      close(0);
 20b:	83 ec 0c             	sub    $0xc,%esp
 20e:	6a 00                	push   $0x0
 210:	e8 c5 09 00 00       	call   bda <close>
      dup(p[0]);
 215:	83 c4 04             	add    $0x4,%esp
 218:	ff 75 f0             	push   -0x10(%ebp)
 21b:	e8 0a 0a 00 00       	call   c2a <dup>
      close(p[0]);
 220:	83 c4 04             	add    $0x4,%esp
 223:	ff 75 f0             	push   -0x10(%ebp)
 226:	e8 af 09 00 00       	call   bda <close>
      close(p[1]);
 22b:	83 c4 04             	add    $0x4,%esp
 22e:	ff 75 f4             	push   -0xc(%ebp)
 231:	e8 a4 09 00 00       	call   bda <close>
      runcmd(pcmd->right);
 236:	83 c4 04             	add    $0x4,%esp
 239:	ff 73 08             	push   0x8(%ebx)
 23c:	e8 4a fe ff ff       	call   8b <runcmd>
    if(fork1() == 0)
 241:	e8 26 fe ff ff       	call   6c <fork1>
 246:	85 c0                	test   %eax,%eax
 248:	0f 85 99 fe ff ff    	jne    e7 <runcmd+0x5c>
      runcmd(bcmd->cmd);
 24e:	83 ec 0c             	sub    $0xc,%esp
 251:	ff 73 04             	push   0x4(%ebx)
 254:	e8 32 fe ff ff       	call   8b <runcmd>

00000259 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
 259:	55                   	push   %ebp
 25a:	89 e5                	mov    %esp,%ebp
 25c:	53                   	push   %ebx
 25d:	83 ec 10             	sub    $0x10,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
 260:	6a 54                	push   $0x54
 262:	e8 be 0c 00 00       	call   f25 <malloc>
 267:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
 269:	83 c4 0c             	add    $0xc,%esp
 26c:	6a 54                	push   $0x54
 26e:	6a 00                	push   $0x0
 270:	50                   	push   %eax
 271:	e8 11 08 00 00       	call   a87 <memset>
  cmd->type = EXEC;
 276:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  return (struct cmd*)cmd;
}
 27c:	89 d8                	mov    %ebx,%eax
 27e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 281:	c9                   	leave  
 282:	c3                   	ret    

00000283 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
 283:	55                   	push   %ebp
 284:	89 e5                	mov    %esp,%ebp
 286:	53                   	push   %ebx
 287:	83 ec 10             	sub    $0x10,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
 28a:	6a 18                	push   $0x18
 28c:	e8 94 0c 00 00       	call   f25 <malloc>
 291:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
 293:	83 c4 0c             	add    $0xc,%esp
 296:	6a 18                	push   $0x18
 298:	6a 00                	push   $0x0
 29a:	50                   	push   %eax
 29b:	e8 e7 07 00 00       	call   a87 <memset>
  cmd->type = REDIR;
 2a0:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  cmd->cmd = subcmd;
 2a6:	8b 45 08             	mov    0x8(%ebp),%eax
 2a9:	89 43 04             	mov    %eax,0x4(%ebx)
  cmd->file = file;
 2ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 2af:	89 43 08             	mov    %eax,0x8(%ebx)
  cmd->efile = efile;
 2b2:	8b 45 10             	mov    0x10(%ebp),%eax
 2b5:	89 43 0c             	mov    %eax,0xc(%ebx)
  cmd->mode = mode;
 2b8:	8b 45 14             	mov    0x14(%ebp),%eax
 2bb:	89 43 10             	mov    %eax,0x10(%ebx)
  cmd->fd = fd;
 2be:	8b 45 18             	mov    0x18(%ebp),%eax
 2c1:	89 43 14             	mov    %eax,0x14(%ebx)
  return (struct cmd*)cmd;
}
 2c4:	89 d8                	mov    %ebx,%eax
 2c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 2c9:	c9                   	leave  
 2ca:	c3                   	ret    

000002cb <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
 2cb:	55                   	push   %ebp
 2cc:	89 e5                	mov    %esp,%ebp
 2ce:	53                   	push   %ebx
 2cf:	83 ec 10             	sub    $0x10,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
 2d2:	6a 0c                	push   $0xc
 2d4:	e8 4c 0c 00 00       	call   f25 <malloc>
 2d9:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
 2db:	83 c4 0c             	add    $0xc,%esp
 2de:	6a 0c                	push   $0xc
 2e0:	6a 00                	push   $0x0
 2e2:	50                   	push   %eax
 2e3:	e8 9f 07 00 00       	call   a87 <memset>
  cmd->type = PIPE;
 2e8:	c7 03 03 00 00 00    	movl   $0x3,(%ebx)
  cmd->left = left;
 2ee:	8b 45 08             	mov    0x8(%ebp),%eax
 2f1:	89 43 04             	mov    %eax,0x4(%ebx)
  cmd->right = right;
 2f4:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f7:	89 43 08             	mov    %eax,0x8(%ebx)
  return (struct cmd*)cmd;
}
 2fa:	89 d8                	mov    %ebx,%eax
 2fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 2ff:	c9                   	leave  
 300:	c3                   	ret    

00000301 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
 301:	55                   	push   %ebp
 302:	89 e5                	mov    %esp,%ebp
 304:	53                   	push   %ebx
 305:	83 ec 10             	sub    $0x10,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
 308:	6a 0c                	push   $0xc
 30a:	e8 16 0c 00 00       	call   f25 <malloc>
 30f:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
 311:	83 c4 0c             	add    $0xc,%esp
 314:	6a 0c                	push   $0xc
 316:	6a 00                	push   $0x0
 318:	50                   	push   %eax
 319:	e8 69 07 00 00       	call   a87 <memset>
  cmd->type = LIST;
 31e:	c7 03 04 00 00 00    	movl   $0x4,(%ebx)
  cmd->left = left;
 324:	8b 45 08             	mov    0x8(%ebp),%eax
 327:	89 43 04             	mov    %eax,0x4(%ebx)
  cmd->right = right;
 32a:	8b 45 0c             	mov    0xc(%ebp),%eax
 32d:	89 43 08             	mov    %eax,0x8(%ebx)
  return (struct cmd*)cmd;
}
 330:	89 d8                	mov    %ebx,%eax
 332:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 335:	c9                   	leave  
 336:	c3                   	ret    

00000337 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
 337:	55                   	push   %ebp
 338:	89 e5                	mov    %esp,%ebp
 33a:	53                   	push   %ebx
 33b:	83 ec 10             	sub    $0x10,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
 33e:	6a 08                	push   $0x8
 340:	e8 e0 0b 00 00       	call   f25 <malloc>
 345:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
 347:	83 c4 0c             	add    $0xc,%esp
 34a:	6a 08                	push   $0x8
 34c:	6a 00                	push   $0x0
 34e:	50                   	push   %eax
 34f:	e8 33 07 00 00       	call   a87 <memset>
  cmd->type = BACK;
 354:	c7 03 05 00 00 00    	movl   $0x5,(%ebx)
  cmd->cmd = subcmd;
 35a:	8b 45 08             	mov    0x8(%ebp),%eax
 35d:	89 43 04             	mov    %eax,0x4(%ebx)
  return (struct cmd*)cmd;
}
 360:	89 d8                	mov    %ebx,%eax
 362:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 365:	c9                   	leave  
 366:	c3                   	ret    

00000367 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
 367:	55                   	push   %ebp
 368:	89 e5                	mov    %esp,%ebp
 36a:	57                   	push   %edi
 36b:	56                   	push   %esi
 36c:	53                   	push   %ebx
 36d:	83 ec 0c             	sub    $0xc,%esp
 370:	8b 75 0c             	mov    0xc(%ebp),%esi
 373:	8b 7d 10             	mov    0x10(%ebp),%edi
  char *s;
  int ret;

  s = *ps;
 376:	8b 45 08             	mov    0x8(%ebp),%eax
 379:	8b 18                	mov    (%eax),%ebx
  while(s < es && strchr(whitespace, *s))
 37b:	eb 01                	jmp    37e <gettoken+0x17>
    s++;
 37d:	43                   	inc    %ebx
  while(s < es && strchr(whitespace, *s))
 37e:	39 f3                	cmp    %esi,%ebx
 380:	73 18                	jae    39a <gettoken+0x33>
 382:	83 ec 08             	sub    $0x8,%esp
 385:	0f be 03             	movsbl (%ebx),%eax
 388:	50                   	push   %eax
 389:	68 b0 16 00 00       	push   $0x16b0
 38e:	e8 0c 07 00 00       	call   a9f <strchr>
 393:	83 c4 10             	add    $0x10,%esp
 396:	85 c0                	test   %eax,%eax
 398:	75 e3                	jne    37d <gettoken+0x16>
  if(q)
 39a:	85 ff                	test   %edi,%edi
 39c:	74 02                	je     3a0 <gettoken+0x39>
    *q = s;
 39e:	89 1f                	mov    %ebx,(%edi)
  ret = *s;
 3a0:	8a 03                	mov    (%ebx),%al
 3a2:	0f be f8             	movsbl %al,%edi
  switch(*s){
 3a5:	3c 3c                	cmp    $0x3c,%al
 3a7:	7f 25                	jg     3ce <gettoken+0x67>
 3a9:	3c 3b                	cmp    $0x3b,%al
 3ab:	7d 13                	jge    3c0 <gettoken+0x59>
 3ad:	84 c0                	test   %al,%al
 3af:	74 10                	je     3c1 <gettoken+0x5a>
 3b1:	78 3d                	js     3f0 <gettoken+0x89>
 3b3:	3c 26                	cmp    $0x26,%al
 3b5:	74 09                	je     3c0 <gettoken+0x59>
 3b7:	7c 37                	jl     3f0 <gettoken+0x89>
 3b9:	83 e8 28             	sub    $0x28,%eax
 3bc:	3c 01                	cmp    $0x1,%al
 3be:	77 30                	ja     3f0 <gettoken+0x89>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
 3c0:	43                   	inc    %ebx
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
 3c1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3c5:	74 73                	je     43a <gettoken+0xd3>
    *eq = s;
 3c7:	8b 45 14             	mov    0x14(%ebp),%eax
 3ca:	89 18                	mov    %ebx,(%eax)
 3cc:	eb 6c                	jmp    43a <gettoken+0xd3>
  switch(*s){
 3ce:	3c 3e                	cmp    $0x3e,%al
 3d0:	75 0d                	jne    3df <gettoken+0x78>
    s++;
 3d2:	8d 43 01             	lea    0x1(%ebx),%eax
    if(*s == '>'){
 3d5:	80 7b 01 3e          	cmpb   $0x3e,0x1(%ebx)
 3d9:	74 0a                	je     3e5 <gettoken+0x7e>
    s++;
 3db:	89 c3                	mov    %eax,%ebx
 3dd:	eb e2                	jmp    3c1 <gettoken+0x5a>
  switch(*s){
 3df:	3c 7c                	cmp    $0x7c,%al
 3e1:	75 0d                	jne    3f0 <gettoken+0x89>
 3e3:	eb db                	jmp    3c0 <gettoken+0x59>
      s++;
 3e5:	83 c3 02             	add    $0x2,%ebx
      ret = '+';
 3e8:	bf 2b 00 00 00       	mov    $0x2b,%edi
 3ed:	eb d2                	jmp    3c1 <gettoken+0x5a>
      s++;
 3ef:	43                   	inc    %ebx
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
 3f0:	39 f3                	cmp    %esi,%ebx
 3f2:	73 37                	jae    42b <gettoken+0xc4>
 3f4:	83 ec 08             	sub    $0x8,%esp
 3f7:	0f be 03             	movsbl (%ebx),%eax
 3fa:	50                   	push   %eax
 3fb:	68 b0 16 00 00       	push   $0x16b0
 400:	e8 9a 06 00 00       	call   a9f <strchr>
 405:	83 c4 10             	add    $0x10,%esp
 408:	85 c0                	test   %eax,%eax
 40a:	75 26                	jne    432 <gettoken+0xcb>
 40c:	83 ec 08             	sub    $0x8,%esp
 40f:	0f be 03             	movsbl (%ebx),%eax
 412:	50                   	push   %eax
 413:	68 a8 16 00 00       	push   $0x16a8
 418:	e8 82 06 00 00       	call   a9f <strchr>
 41d:	83 c4 10             	add    $0x10,%esp
 420:	85 c0                	test   %eax,%eax
 422:	74 cb                	je     3ef <gettoken+0x88>
    ret = 'a';
 424:	bf 61 00 00 00       	mov    $0x61,%edi
 429:	eb 96                	jmp    3c1 <gettoken+0x5a>
 42b:	bf 61 00 00 00       	mov    $0x61,%edi
 430:	eb 8f                	jmp    3c1 <gettoken+0x5a>
 432:	bf 61 00 00 00       	mov    $0x61,%edi
 437:	eb 88                	jmp    3c1 <gettoken+0x5a>

  while(s < es && strchr(whitespace, *s))
    s++;
 439:	43                   	inc    %ebx
  while(s < es && strchr(whitespace, *s))
 43a:	39 f3                	cmp    %esi,%ebx
 43c:	73 18                	jae    456 <gettoken+0xef>
 43e:	83 ec 08             	sub    $0x8,%esp
 441:	0f be 03             	movsbl (%ebx),%eax
 444:	50                   	push   %eax
 445:	68 b0 16 00 00       	push   $0x16b0
 44a:	e8 50 06 00 00       	call   a9f <strchr>
 44f:	83 c4 10             	add    $0x10,%esp
 452:	85 c0                	test   %eax,%eax
 454:	75 e3                	jne    439 <gettoken+0xd2>
  *ps = s;
 456:	8b 45 08             	mov    0x8(%ebp),%eax
 459:	89 18                	mov    %ebx,(%eax)
  return ret;
}
 45b:	89 f8                	mov    %edi,%eax
 45d:	8d 65 f4             	lea    -0xc(%ebp),%esp
 460:	5b                   	pop    %ebx
 461:	5e                   	pop    %esi
 462:	5f                   	pop    %edi
 463:	5d                   	pop    %ebp
 464:	c3                   	ret    

00000465 <peek>:

int
peek(char **ps, char *es, char *toks)
{
 465:	55                   	push   %ebp
 466:	89 e5                	mov    %esp,%ebp
 468:	57                   	push   %edi
 469:	56                   	push   %esi
 46a:	53                   	push   %ebx
 46b:	83 ec 0c             	sub    $0xc,%esp
 46e:	8b 7d 08             	mov    0x8(%ebp),%edi
 471:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *s;

  s = *ps;
 474:	8b 1f                	mov    (%edi),%ebx
  while(s < es && strchr(whitespace, *s))
 476:	eb 01                	jmp    479 <peek+0x14>
    s++;
 478:	43                   	inc    %ebx
  while(s < es && strchr(whitespace, *s))
 479:	39 f3                	cmp    %esi,%ebx
 47b:	73 18                	jae    495 <peek+0x30>
 47d:	83 ec 08             	sub    $0x8,%esp
 480:	0f be 03             	movsbl (%ebx),%eax
 483:	50                   	push   %eax
 484:	68 b0 16 00 00       	push   $0x16b0
 489:	e8 11 06 00 00       	call   a9f <strchr>
 48e:	83 c4 10             	add    $0x10,%esp
 491:	85 c0                	test   %eax,%eax
 493:	75 e3                	jne    478 <peek+0x13>
  *ps = s;
 495:	89 1f                	mov    %ebx,(%edi)
  return *s && strchr(toks, *s);
 497:	8a 03                	mov    (%ebx),%al
 499:	84 c0                	test   %al,%al
 49b:	75 0d                	jne    4aa <peek+0x45>
 49d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 4a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4a5:	5b                   	pop    %ebx
 4a6:	5e                   	pop    %esi
 4a7:	5f                   	pop    %edi
 4a8:	5d                   	pop    %ebp
 4a9:	c3                   	ret    
  return *s && strchr(toks, *s);
 4aa:	83 ec 08             	sub    $0x8,%esp
 4ad:	0f be c0             	movsbl %al,%eax
 4b0:	50                   	push   %eax
 4b1:	ff 75 10             	push   0x10(%ebp)
 4b4:	e8 e6 05 00 00       	call   a9f <strchr>
 4b9:	83 c4 10             	add    $0x10,%esp
 4bc:	85 c0                	test   %eax,%eax
 4be:	74 07                	je     4c7 <peek+0x62>
 4c0:	b8 01 00 00 00       	mov    $0x1,%eax
 4c5:	eb db                	jmp    4a2 <peek+0x3d>
 4c7:	b8 00 00 00 00       	mov    $0x0,%eax
 4cc:	eb d4                	jmp    4a2 <peek+0x3d>

000004ce <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
 4ce:	55                   	push   %ebp
 4cf:	89 e5                	mov    %esp,%ebp
 4d1:	57                   	push   %edi
 4d2:	56                   	push   %esi
 4d3:	53                   	push   %ebx
 4d4:	83 ec 1c             	sub    $0x1c,%esp
 4d7:	8b 7d 0c             	mov    0xc(%ebp),%edi
 4da:	8b 75 10             	mov    0x10(%ebp),%esi
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
 4dd:	eb 28                	jmp    507 <parseredirs+0x39>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
      panic("missing file for redirection");
 4df:	83 ec 0c             	sub    $0xc,%esp
 4e2:	68 e0 0f 00 00       	push   $0xfe0
 4e7:	e8 5f fb ff ff       	call   4b <panic>
    switch(tok){
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
 4ec:	83 ec 0c             	sub    $0xc,%esp
 4ef:	6a 00                	push   $0x0
 4f1:	6a 00                	push   $0x0
 4f3:	ff 75 e0             	push   -0x20(%ebp)
 4f6:	ff 75 e4             	push   -0x1c(%ebp)
 4f9:	ff 75 08             	push   0x8(%ebp)
 4fc:	e8 82 fd ff ff       	call   283 <redircmd>
 501:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
 504:	83 c4 20             	add    $0x20,%esp
  while(peek(ps, es, "<>")){
 507:	83 ec 04             	sub    $0x4,%esp
 50a:	68 fd 0f 00 00       	push   $0xffd
 50f:	56                   	push   %esi
 510:	57                   	push   %edi
 511:	e8 4f ff ff ff       	call   465 <peek>
 516:	83 c4 10             	add    $0x10,%esp
 519:	85 c0                	test   %eax,%eax
 51b:	74 76                	je     593 <parseredirs+0xc5>
    tok = gettoken(ps, es, 0, 0);
 51d:	6a 00                	push   $0x0
 51f:	6a 00                	push   $0x0
 521:	56                   	push   %esi
 522:	57                   	push   %edi
 523:	e8 3f fe ff ff       	call   367 <gettoken>
 528:	89 c3                	mov    %eax,%ebx
    if(gettoken(ps, es, &q, &eq) != 'a')
 52a:	8d 45 e0             	lea    -0x20(%ebp),%eax
 52d:	50                   	push   %eax
 52e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 531:	50                   	push   %eax
 532:	56                   	push   %esi
 533:	57                   	push   %edi
 534:	e8 2e fe ff ff       	call   367 <gettoken>
 539:	83 c4 20             	add    $0x20,%esp
 53c:	83 f8 61             	cmp    $0x61,%eax
 53f:	75 9e                	jne    4df <parseredirs+0x11>
    switch(tok){
 541:	83 fb 3c             	cmp    $0x3c,%ebx
 544:	74 a6                	je     4ec <parseredirs+0x1e>
 546:	83 fb 3e             	cmp    $0x3e,%ebx
 549:	74 25                	je     570 <parseredirs+0xa2>
 54b:	83 fb 2b             	cmp    $0x2b,%ebx
 54e:	75 b7                	jne    507 <parseredirs+0x39>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
 550:	83 ec 0c             	sub    $0xc,%esp
 553:	6a 01                	push   $0x1
 555:	68 01 02 00 00       	push   $0x201
 55a:	ff 75 e0             	push   -0x20(%ebp)
 55d:	ff 75 e4             	push   -0x1c(%ebp)
 560:	ff 75 08             	push   0x8(%ebp)
 563:	e8 1b fd ff ff       	call   283 <redircmd>
 568:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
 56b:	83 c4 20             	add    $0x20,%esp
 56e:	eb 97                	jmp    507 <parseredirs+0x39>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
 570:	83 ec 0c             	sub    $0xc,%esp
 573:	6a 01                	push   $0x1
 575:	68 01 02 00 00       	push   $0x201
 57a:	ff 75 e0             	push   -0x20(%ebp)
 57d:	ff 75 e4             	push   -0x1c(%ebp)
 580:	ff 75 08             	push   0x8(%ebp)
 583:	e8 fb fc ff ff       	call   283 <redircmd>
 588:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
 58b:	83 c4 20             	add    $0x20,%esp
 58e:	e9 74 ff ff ff       	jmp    507 <parseredirs+0x39>
    }
  }
  return cmd;
}
 593:	8b 45 08             	mov    0x8(%ebp),%eax
 596:	8d 65 f4             	lea    -0xc(%ebp),%esp
 599:	5b                   	pop    %ebx
 59a:	5e                   	pop    %esi
 59b:	5f                   	pop    %edi
 59c:	5d                   	pop    %ebp
 59d:	c3                   	ret    

0000059e <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
 59e:	55                   	push   %ebp
 59f:	89 e5                	mov    %esp,%ebp
 5a1:	57                   	push   %edi
 5a2:	56                   	push   %esi
 5a3:	53                   	push   %ebx
 5a4:	83 ec 30             	sub    $0x30,%esp
 5a7:	8b 75 08             	mov    0x8(%ebp),%esi
 5aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
 5ad:	68 00 10 00 00       	push   $0x1000
 5b2:	57                   	push   %edi
 5b3:	56                   	push   %esi
 5b4:	e8 ac fe ff ff       	call   465 <peek>
 5b9:	83 c4 10             	add    $0x10,%esp
 5bc:	85 c0                	test   %eax,%eax
 5be:	75 1d                	jne    5dd <parseexec+0x3f>
 5c0:	89 c3                	mov    %eax,%ebx
    return parseblock(ps, es);

  ret = execcmd();
 5c2:	e8 92 fc ff ff       	call   259 <execcmd>
 5c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
 5ca:	83 ec 04             	sub    $0x4,%esp
 5cd:	57                   	push   %edi
 5ce:	56                   	push   %esi
 5cf:	50                   	push   %eax
 5d0:	e8 f9 fe ff ff       	call   4ce <parseredirs>
 5d5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  while(!peek(ps, es, "|)&;")){
 5d8:	83 c4 10             	add    $0x10,%esp
 5db:	eb 3b                	jmp    618 <parseexec+0x7a>
    return parseblock(ps, es);
 5dd:	83 ec 08             	sub    $0x8,%esp
 5e0:	57                   	push   %edi
 5e1:	56                   	push   %esi
 5e2:	e8 8d 01 00 00       	call   774 <parseblock>
 5e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 5ea:	83 c4 10             	add    $0x10,%esp
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
 5ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 5f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
 5f3:	5b                   	pop    %ebx
 5f4:	5e                   	pop    %esi
 5f5:	5f                   	pop    %edi
 5f6:	5d                   	pop    %ebp
 5f7:	c3                   	ret    
      panic("syntax");
 5f8:	83 ec 0c             	sub    $0xc,%esp
 5fb:	68 02 10 00 00       	push   $0x1002
 600:	e8 46 fa ff ff       	call   4b <panic>
    ret = parseredirs(ret, ps, es);
 605:	83 ec 04             	sub    $0x4,%esp
 608:	57                   	push   %edi
 609:	56                   	push   %esi
 60a:	ff 75 d4             	push   -0x2c(%ebp)
 60d:	e8 bc fe ff ff       	call   4ce <parseredirs>
 612:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 615:	83 c4 10             	add    $0x10,%esp
  while(!peek(ps, es, "|)&;")){
 618:	83 ec 04             	sub    $0x4,%esp
 61b:	68 17 10 00 00       	push   $0x1017
 620:	57                   	push   %edi
 621:	56                   	push   %esi
 622:	e8 3e fe ff ff       	call   465 <peek>
 627:	83 c4 10             	add    $0x10,%esp
 62a:	85 c0                	test   %eax,%eax
 62c:	75 3f                	jne    66d <parseexec+0xcf>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
 62e:	8d 45 e0             	lea    -0x20(%ebp),%eax
 631:	50                   	push   %eax
 632:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 635:	50                   	push   %eax
 636:	57                   	push   %edi
 637:	56                   	push   %esi
 638:	e8 2a fd ff ff       	call   367 <gettoken>
 63d:	83 c4 10             	add    $0x10,%esp
 640:	85 c0                	test   %eax,%eax
 642:	74 29                	je     66d <parseexec+0xcf>
    if(tok != 'a')
 644:	83 f8 61             	cmp    $0x61,%eax
 647:	75 af                	jne    5f8 <parseexec+0x5a>
    cmd->argv[argc] = q;
 649:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 64c:	8b 55 d0             	mov    -0x30(%ebp),%edx
 64f:	89 44 9a 04          	mov    %eax,0x4(%edx,%ebx,4)
    cmd->eargv[argc] = eq;
 653:	8b 45 e0             	mov    -0x20(%ebp),%eax
 656:	89 44 9a 2c          	mov    %eax,0x2c(%edx,%ebx,4)
    argc++;
 65a:	43                   	inc    %ebx
    if(argc >= MAXARGS)
 65b:	83 fb 09             	cmp    $0x9,%ebx
 65e:	7e a5                	jle    605 <parseexec+0x67>
      panic("too many args");
 660:	83 ec 0c             	sub    $0xc,%esp
 663:	68 09 10 00 00       	push   $0x1009
 668:	e8 de f9 ff ff       	call   4b <panic>
  cmd->argv[argc] = 0;
 66d:	8b 45 d0             	mov    -0x30(%ebp),%eax
 670:	c7 44 98 04 00 00 00 	movl   $0x0,0x4(%eax,%ebx,4)
 677:	00 
  cmd->eargv[argc] = 0;
 678:	c7 44 98 2c 00 00 00 	movl   $0x0,0x2c(%eax,%ebx,4)
 67f:	00 
  return ret;
 680:	e9 68 ff ff ff       	jmp    5ed <parseexec+0x4f>

00000685 <parsepipe>:
{
 685:	55                   	push   %ebp
 686:	89 e5                	mov    %esp,%ebp
 688:	57                   	push   %edi
 689:	56                   	push   %esi
 68a:	53                   	push   %ebx
 68b:	83 ec 14             	sub    $0x14,%esp
 68e:	8b 75 08             	mov    0x8(%ebp),%esi
 691:	8b 7d 0c             	mov    0xc(%ebp),%edi
  cmd = parseexec(ps, es);
 694:	57                   	push   %edi
 695:	56                   	push   %esi
 696:	e8 03 ff ff ff       	call   59e <parseexec>
 69b:	89 c3                	mov    %eax,%ebx
  if(peek(ps, es, "|")){
 69d:	83 c4 0c             	add    $0xc,%esp
 6a0:	68 1c 10 00 00       	push   $0x101c
 6a5:	57                   	push   %edi
 6a6:	56                   	push   %esi
 6a7:	e8 b9 fd ff ff       	call   465 <peek>
 6ac:	83 c4 10             	add    $0x10,%esp
 6af:	85 c0                	test   %eax,%eax
 6b1:	75 0a                	jne    6bd <parsepipe+0x38>
}
 6b3:	89 d8                	mov    %ebx,%eax
 6b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
 6b8:	5b                   	pop    %ebx
 6b9:	5e                   	pop    %esi
 6ba:	5f                   	pop    %edi
 6bb:	5d                   	pop    %ebp
 6bc:	c3                   	ret    
    gettoken(ps, es, 0, 0);
 6bd:	6a 00                	push   $0x0
 6bf:	6a 00                	push   $0x0
 6c1:	57                   	push   %edi
 6c2:	56                   	push   %esi
 6c3:	e8 9f fc ff ff       	call   367 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
 6c8:	83 c4 08             	add    $0x8,%esp
 6cb:	57                   	push   %edi
 6cc:	56                   	push   %esi
 6cd:	e8 b3 ff ff ff       	call   685 <parsepipe>
 6d2:	83 c4 08             	add    $0x8,%esp
 6d5:	50                   	push   %eax
 6d6:	53                   	push   %ebx
 6d7:	e8 ef fb ff ff       	call   2cb <pipecmd>
 6dc:	89 c3                	mov    %eax,%ebx
 6de:	83 c4 10             	add    $0x10,%esp
  return cmd;
 6e1:	eb d0                	jmp    6b3 <parsepipe+0x2e>

000006e3 <parseline>:
{
 6e3:	55                   	push   %ebp
 6e4:	89 e5                	mov    %esp,%ebp
 6e6:	57                   	push   %edi
 6e7:	56                   	push   %esi
 6e8:	53                   	push   %ebx
 6e9:	83 ec 14             	sub    $0x14,%esp
 6ec:	8b 75 08             	mov    0x8(%ebp),%esi
 6ef:	8b 7d 0c             	mov    0xc(%ebp),%edi
  cmd = parsepipe(ps, es);
 6f2:	57                   	push   %edi
 6f3:	56                   	push   %esi
 6f4:	e8 8c ff ff ff       	call   685 <parsepipe>
 6f9:	89 c3                	mov    %eax,%ebx
  while(peek(ps, es, "&")){
 6fb:	83 c4 10             	add    $0x10,%esp
 6fe:	eb 18                	jmp    718 <parseline+0x35>
    gettoken(ps, es, 0, 0);
 700:	6a 00                	push   $0x0
 702:	6a 00                	push   $0x0
 704:	57                   	push   %edi
 705:	56                   	push   %esi
 706:	e8 5c fc ff ff       	call   367 <gettoken>
    cmd = backcmd(cmd);
 70b:	89 1c 24             	mov    %ebx,(%esp)
 70e:	e8 24 fc ff ff       	call   337 <backcmd>
 713:	89 c3                	mov    %eax,%ebx
 715:	83 c4 10             	add    $0x10,%esp
  while(peek(ps, es, "&")){
 718:	83 ec 04             	sub    $0x4,%esp
 71b:	68 1e 10 00 00       	push   $0x101e
 720:	57                   	push   %edi
 721:	56                   	push   %esi
 722:	e8 3e fd ff ff       	call   465 <peek>
 727:	83 c4 10             	add    $0x10,%esp
 72a:	85 c0                	test   %eax,%eax
 72c:	75 d2                	jne    700 <parseline+0x1d>
  if(peek(ps, es, ";")){
 72e:	83 ec 04             	sub    $0x4,%esp
 731:	68 1a 10 00 00       	push   $0x101a
 736:	57                   	push   %edi
 737:	56                   	push   %esi
 738:	e8 28 fd ff ff       	call   465 <peek>
 73d:	83 c4 10             	add    $0x10,%esp
 740:	85 c0                	test   %eax,%eax
 742:	75 0a                	jne    74e <parseline+0x6b>
}
 744:	89 d8                	mov    %ebx,%eax
 746:	8d 65 f4             	lea    -0xc(%ebp),%esp
 749:	5b                   	pop    %ebx
 74a:	5e                   	pop    %esi
 74b:	5f                   	pop    %edi
 74c:	5d                   	pop    %ebp
 74d:	c3                   	ret    
    gettoken(ps, es, 0, 0);
 74e:	6a 00                	push   $0x0
 750:	6a 00                	push   $0x0
 752:	57                   	push   %edi
 753:	56                   	push   %esi
 754:	e8 0e fc ff ff       	call   367 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
 759:	83 c4 08             	add    $0x8,%esp
 75c:	57                   	push   %edi
 75d:	56                   	push   %esi
 75e:	e8 80 ff ff ff       	call   6e3 <parseline>
 763:	83 c4 08             	add    $0x8,%esp
 766:	50                   	push   %eax
 767:	53                   	push   %ebx
 768:	e8 94 fb ff ff       	call   301 <listcmd>
 76d:	89 c3                	mov    %eax,%ebx
 76f:	83 c4 10             	add    $0x10,%esp
  return cmd;
 772:	eb d0                	jmp    744 <parseline+0x61>

00000774 <parseblock>:
{
 774:	55                   	push   %ebp
 775:	89 e5                	mov    %esp,%ebp
 777:	57                   	push   %edi
 778:	56                   	push   %esi
 779:	53                   	push   %ebx
 77a:	83 ec 10             	sub    $0x10,%esp
 77d:	8b 5d 08             	mov    0x8(%ebp),%ebx
 780:	8b 75 0c             	mov    0xc(%ebp),%esi
  if(!peek(ps, es, "("))
 783:	68 00 10 00 00       	push   $0x1000
 788:	56                   	push   %esi
 789:	53                   	push   %ebx
 78a:	e8 d6 fc ff ff       	call   465 <peek>
 78f:	83 c4 10             	add    $0x10,%esp
 792:	85 c0                	test   %eax,%eax
 794:	74 4b                	je     7e1 <parseblock+0x6d>
  gettoken(ps, es, 0, 0);
 796:	6a 00                	push   $0x0
 798:	6a 00                	push   $0x0
 79a:	56                   	push   %esi
 79b:	53                   	push   %ebx
 79c:	e8 c6 fb ff ff       	call   367 <gettoken>
  cmd = parseline(ps, es);
 7a1:	83 c4 08             	add    $0x8,%esp
 7a4:	56                   	push   %esi
 7a5:	53                   	push   %ebx
 7a6:	e8 38 ff ff ff       	call   6e3 <parseline>
 7ab:	89 c7                	mov    %eax,%edi
  if(!peek(ps, es, ")"))
 7ad:	83 c4 0c             	add    $0xc,%esp
 7b0:	68 3c 10 00 00       	push   $0x103c
 7b5:	56                   	push   %esi
 7b6:	53                   	push   %ebx
 7b7:	e8 a9 fc ff ff       	call   465 <peek>
 7bc:	83 c4 10             	add    $0x10,%esp
 7bf:	85 c0                	test   %eax,%eax
 7c1:	74 2b                	je     7ee <parseblock+0x7a>
  gettoken(ps, es, 0, 0);
 7c3:	6a 00                	push   $0x0
 7c5:	6a 00                	push   $0x0
 7c7:	56                   	push   %esi
 7c8:	53                   	push   %ebx
 7c9:	e8 99 fb ff ff       	call   367 <gettoken>
  cmd = parseredirs(cmd, ps, es);
 7ce:	83 c4 0c             	add    $0xc,%esp
 7d1:	56                   	push   %esi
 7d2:	53                   	push   %ebx
 7d3:	57                   	push   %edi
 7d4:	e8 f5 fc ff ff       	call   4ce <parseredirs>
}
 7d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
 7dc:	5b                   	pop    %ebx
 7dd:	5e                   	pop    %esi
 7de:	5f                   	pop    %edi
 7df:	5d                   	pop    %ebp
 7e0:	c3                   	ret    
    panic("parseblock");
 7e1:	83 ec 0c             	sub    $0xc,%esp
 7e4:	68 20 10 00 00       	push   $0x1020
 7e9:	e8 5d f8 ff ff       	call   4b <panic>
    panic("syntax - missing )");
 7ee:	83 ec 0c             	sub    $0xc,%esp
 7f1:	68 2b 10 00 00       	push   $0x102b
 7f6:	e8 50 f8 ff ff       	call   4b <panic>

000007fb <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
 7fb:	55                   	push   %ebp
 7fc:	89 e5                	mov    %esp,%ebp
 7fe:	53                   	push   %ebx
 7ff:	83 ec 04             	sub    $0x4,%esp
 802:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
 805:	85 db                	test   %ebx,%ebx
 807:	74 1d                	je     826 <nulterminate+0x2b>
    return 0;

  switch(cmd->type){
 809:	8b 03                	mov    (%ebx),%eax
 80b:	83 f8 05             	cmp    $0x5,%eax
 80e:	77 16                	ja     826 <nulterminate+0x2b>
 810:	ff 24 85 a8 10 00 00 	jmp    *0x10a8(,%eax,4)
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
      *ecmd->eargv[i] = 0;
 817:	8b 54 83 2c          	mov    0x2c(%ebx,%eax,4),%edx
 81b:	c6 02 00             	movb   $0x0,(%edx)
    for(i=0; ecmd->argv[i]; i++)
 81e:	40                   	inc    %eax
 81f:	83 7c 83 04 00       	cmpl   $0x0,0x4(%ebx,%eax,4)
 824:	75 f1                	jne    817 <nulterminate+0x1c>
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
 826:	89 d8                	mov    %ebx,%eax
 828:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 82b:	c9                   	leave  
 82c:	c3                   	ret    
  switch(cmd->type){
 82d:	b8 00 00 00 00       	mov    $0x0,%eax
 832:	eb eb                	jmp    81f <nulterminate+0x24>
    nulterminate(rcmd->cmd);
 834:	83 ec 0c             	sub    $0xc,%esp
 837:	ff 73 04             	push   0x4(%ebx)
 83a:	e8 bc ff ff ff       	call   7fb <nulterminate>
    *rcmd->efile = 0;
 83f:	8b 43 0c             	mov    0xc(%ebx),%eax
 842:	c6 00 00             	movb   $0x0,(%eax)
    break;
 845:	83 c4 10             	add    $0x10,%esp
 848:	eb dc                	jmp    826 <nulterminate+0x2b>
    nulterminate(pcmd->left);
 84a:	83 ec 0c             	sub    $0xc,%esp
 84d:	ff 73 04             	push   0x4(%ebx)
 850:	e8 a6 ff ff ff       	call   7fb <nulterminate>
    nulterminate(pcmd->right);
 855:	83 c4 04             	add    $0x4,%esp
 858:	ff 73 08             	push   0x8(%ebx)
 85b:	e8 9b ff ff ff       	call   7fb <nulterminate>
    break;
 860:	83 c4 10             	add    $0x10,%esp
 863:	eb c1                	jmp    826 <nulterminate+0x2b>
    nulterminate(lcmd->left);
 865:	83 ec 0c             	sub    $0xc,%esp
 868:	ff 73 04             	push   0x4(%ebx)
 86b:	e8 8b ff ff ff       	call   7fb <nulterminate>
    nulterminate(lcmd->right);
 870:	83 c4 04             	add    $0x4,%esp
 873:	ff 73 08             	push   0x8(%ebx)
 876:	e8 80 ff ff ff       	call   7fb <nulterminate>
    break;
 87b:	83 c4 10             	add    $0x10,%esp
 87e:	eb a6                	jmp    826 <nulterminate+0x2b>
    nulterminate(bcmd->cmd);
 880:	83 ec 0c             	sub    $0xc,%esp
 883:	ff 73 04             	push   0x4(%ebx)
 886:	e8 70 ff ff ff       	call   7fb <nulterminate>
    break;
 88b:	83 c4 10             	add    $0x10,%esp
 88e:	eb 96                	jmp    826 <nulterminate+0x2b>

00000890 <parsecmd>:
{
 890:	55                   	push   %ebp
 891:	89 e5                	mov    %esp,%ebp
 893:	56                   	push   %esi
 894:	53                   	push   %ebx
  es = s + strlen(s);
 895:	8b 5d 08             	mov    0x8(%ebp),%ebx
 898:	83 ec 0c             	sub    $0xc,%esp
 89b:	53                   	push   %ebx
 89c:	e8 d0 01 00 00       	call   a71 <strlen>
 8a1:	01 c3                	add    %eax,%ebx
  cmd = parseline(&s, es);
 8a3:	83 c4 08             	add    $0x8,%esp
 8a6:	53                   	push   %ebx
 8a7:	8d 45 08             	lea    0x8(%ebp),%eax
 8aa:	50                   	push   %eax
 8ab:	e8 33 fe ff ff       	call   6e3 <parseline>
 8b0:	89 c6                	mov    %eax,%esi
  peek(&s, es, "");
 8b2:	83 c4 0c             	add    $0xc,%esp
 8b5:	68 8e 10 00 00       	push   $0x108e
 8ba:	53                   	push   %ebx
 8bb:	8d 45 08             	lea    0x8(%ebp),%eax
 8be:	50                   	push   %eax
 8bf:	e8 a1 fb ff ff       	call   465 <peek>
  if(s != es){
 8c4:	8b 45 08             	mov    0x8(%ebp),%eax
 8c7:	83 c4 10             	add    $0x10,%esp
 8ca:	39 d8                	cmp    %ebx,%eax
 8cc:	75 12                	jne    8e0 <parsecmd+0x50>
  nulterminate(cmd);
 8ce:	83 ec 0c             	sub    $0xc,%esp
 8d1:	56                   	push   %esi
 8d2:	e8 24 ff ff ff       	call   7fb <nulterminate>
}
 8d7:	89 f0                	mov    %esi,%eax
 8d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
 8dc:	5b                   	pop    %ebx
 8dd:	5e                   	pop    %esi
 8de:	5d                   	pop    %ebp
 8df:	c3                   	ret    
    printf(2, "leftovers: %s\n", s);
 8e0:	83 ec 04             	sub    $0x4,%esp
 8e3:	50                   	push   %eax
 8e4:	68 3e 10 00 00       	push   $0x103e
 8e9:	6a 02                	push   $0x2
 8eb:	e8 15 04 00 00       	call   d05 <printf>
    panic("syntax");
 8f0:	c7 04 24 02 10 00 00 	movl   $0x1002,(%esp)
 8f7:	e8 4f f7 ff ff       	call   4b <panic>

000008fc <main>:
{
 8fc:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 900:	83 e4 f0             	and    $0xfffffff0,%esp
 903:	ff 71 fc             	push   -0x4(%ecx)
 906:	55                   	push   %ebp
 907:	89 e5                	mov    %esp,%ebp
 909:	51                   	push   %ecx
 90a:	83 ec 14             	sub    $0x14,%esp
  while((fd = open("console", O_RDWR)) >= 0){
 90d:	83 ec 08             	sub    $0x8,%esp
 910:	6a 02                	push   $0x2
 912:	68 4d 10 00 00       	push   $0x104d
 917:	e8 d6 02 00 00       	call   bf2 <open>
 91c:	83 c4 10             	add    $0x10,%esp
 91f:	85 c0                	test   %eax,%eax
 921:	78 45                	js     968 <main+0x6c>
    if(fd >= 3){
 923:	83 f8 02             	cmp    $0x2,%eax
 926:	7e e5                	jle    90d <main+0x11>
      close(fd);
 928:	83 ec 0c             	sub    $0xc,%esp
 92b:	50                   	push   %eax
 92c:	e8 a9 02 00 00       	call   bda <close>
      break;
 931:	83 c4 10             	add    $0x10,%esp
 934:	eb 32                	jmp    968 <main+0x6c>
    if(fork1() == 0)
 936:	e8 31 f7 ff ff       	call   6c <fork1>
 93b:	85 c0                	test   %eax,%eax
 93d:	0f 84 9a 00 00 00    	je     9dd <main+0xe1>
    wait(&status);
 943:	83 ec 0c             	sub    $0xc,%esp
 946:	8d 45 f4             	lea    -0xc(%ebp),%eax
 949:	50                   	push   %eax
 94a:	e8 6b 02 00 00       	call   bba <wait>
    if (WIFEXITED (status))
 94f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 952:	83 c4 10             	add    $0x10,%esp
 955:	89 c2                	mov    %eax,%edx
 957:	83 e2 7f             	and    $0x7f,%edx
 95a:	0f 84 92 00 00 00    	je     9f2 <main+0xf6>
    else if(WIFSIGNALED(status))
 960:	85 d2                	test   %edx,%edx
 962:	0f 85 a5 00 00 00    	jne    a0d <main+0x111>
  while(getcmd(buf, sizeof(buf)) >= 0){
 968:	83 ec 08             	sub    $0x8,%esp
 96b:	6a 64                	push   $0x64
 96d:	68 c0 16 00 00       	push   $0x16c0
 972:	e8 89 f6 ff ff       	call   0 <getcmd>
 977:	83 c4 10             	add    $0x10,%esp
 97a:	85 c0                	test   %eax,%eax
 97c:	0f 88 a4 00 00 00    	js     a26 <main+0x12a>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
 982:	80 3d c0 16 00 00 63 	cmpb   $0x63,0x16c0
 989:	75 ab                	jne    936 <main+0x3a>
 98b:	80 3d c1 16 00 00 64 	cmpb   $0x64,0x16c1
 992:	75 a2                	jne    936 <main+0x3a>
 994:	80 3d c2 16 00 00 20 	cmpb   $0x20,0x16c2
 99b:	75 99                	jne    936 <main+0x3a>
      buf[strlen(buf)-1] = 0;  // chop \n
 99d:	83 ec 0c             	sub    $0xc,%esp
 9a0:	68 c0 16 00 00       	push   $0x16c0
 9a5:	e8 c7 00 00 00       	call   a71 <strlen>
 9aa:	c6 80 bf 16 00 00 00 	movb   $0x0,0x16bf(%eax)
      if(chdir(buf+3) < 0)
 9b1:	c7 04 24 c3 16 00 00 	movl   $0x16c3,(%esp)
 9b8:	e8 65 02 00 00       	call   c22 <chdir>
 9bd:	83 c4 10             	add    $0x10,%esp
 9c0:	85 c0                	test   %eax,%eax
 9c2:	79 a4                	jns    968 <main+0x6c>
        printf(2, "cannot cd %s\n", buf+3);
 9c4:	83 ec 04             	sub    $0x4,%esp
 9c7:	68 c3 16 00 00       	push   $0x16c3
 9cc:	68 55 10 00 00       	push   $0x1055
 9d1:	6a 02                	push   $0x2
 9d3:	e8 2d 03 00 00       	call   d05 <printf>
 9d8:	83 c4 10             	add    $0x10,%esp
      continue;
 9db:	eb 8b                	jmp    968 <main+0x6c>
      runcmd(parsecmd(buf));
 9dd:	83 ec 0c             	sub    $0xc,%esp
 9e0:	68 c0 16 00 00       	push   $0x16c0
 9e5:	e8 a6 fe ff ff       	call   890 <parsecmd>
 9ea:	89 04 24             	mov    %eax,(%esp)
 9ed:	e8 99 f6 ff ff       	call   8b <runcmd>
      printf(1, "Output code: %d\n",WEXITSTATUS(status));
 9f2:	83 ec 04             	sub    $0x4,%esp
 9f5:	0f b6 c4             	movzbl %ah,%eax
 9f8:	50                   	push   %eax
 9f9:	68 63 10 00 00       	push   $0x1063
 9fe:	6a 01                	push   $0x1
 a00:	e8 00 03 00 00       	call   d05 <printf>
 a05:	83 c4 10             	add    $0x10,%esp
 a08:	e9 5b ff ff ff       	jmp    968 <main+0x6c>
      printf (1, "Output code (failure): %d\n",WEXITTRAP(status));
 a0d:	83 ec 04             	sub    $0x4,%esp
 a10:	4a                   	dec    %edx
 a11:	52                   	push   %edx
 a12:	68 74 10 00 00       	push   $0x1074
 a17:	6a 01                	push   $0x1
 a19:	e8 e7 02 00 00       	call   d05 <printf>
 a1e:	83 c4 10             	add    $0x10,%esp
 a21:	e9 42 ff ff ff       	jmp    968 <main+0x6c>
  exit(0);
 a26:	83 ec 0c             	sub    $0xc,%esp
 a29:	6a 00                	push   $0x0
 a2b:	e8 82 01 00 00       	call   bb2 <exit>

00000a30 <start>:

// Entry point of the library	
void
start()
{
}
 a30:	c3                   	ret    

00000a31 <strcpy>:

char*
strcpy(char *s, const char *t)
{
 a31:	55                   	push   %ebp
 a32:	89 e5                	mov    %esp,%ebp
 a34:	56                   	push   %esi
 a35:	53                   	push   %ebx
 a36:	8b 45 08             	mov    0x8(%ebp),%eax
 a39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 a3c:	89 c2                	mov    %eax,%edx
 a3e:	89 cb                	mov    %ecx,%ebx
 a40:	41                   	inc    %ecx
 a41:	89 d6                	mov    %edx,%esi
 a43:	42                   	inc    %edx
 a44:	8a 1b                	mov    (%ebx),%bl
 a46:	88 1e                	mov    %bl,(%esi)
 a48:	84 db                	test   %bl,%bl
 a4a:	75 f2                	jne    a3e <strcpy+0xd>
    ;
  return os;
}
 a4c:	5b                   	pop    %ebx
 a4d:	5e                   	pop    %esi
 a4e:	5d                   	pop    %ebp
 a4f:	c3                   	ret    

00000a50 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 a50:	55                   	push   %ebp
 a51:	89 e5                	mov    %esp,%ebp
 a53:	8b 4d 08             	mov    0x8(%ebp),%ecx
 a56:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 a59:	eb 02                	jmp    a5d <strcmp+0xd>
    p++, q++;
 a5b:	41                   	inc    %ecx
 a5c:	42                   	inc    %edx
  while(*p && *p == *q)
 a5d:	8a 01                	mov    (%ecx),%al
 a5f:	84 c0                	test   %al,%al
 a61:	74 04                	je     a67 <strcmp+0x17>
 a63:	3a 02                	cmp    (%edx),%al
 a65:	74 f4                	je     a5b <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 a67:	0f b6 c0             	movzbl %al,%eax
 a6a:	0f b6 12             	movzbl (%edx),%edx
 a6d:	29 d0                	sub    %edx,%eax
}
 a6f:	5d                   	pop    %ebp
 a70:	c3                   	ret    

00000a71 <strlen>:

uint
strlen(const char *s)
{
 a71:	55                   	push   %ebp
 a72:	89 e5                	mov    %esp,%ebp
 a74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 a77:	b8 00 00 00 00       	mov    $0x0,%eax
 a7c:	eb 01                	jmp    a7f <strlen+0xe>
 a7e:	40                   	inc    %eax
 a7f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
 a83:	75 f9                	jne    a7e <strlen+0xd>
    ;
  return n;
}
 a85:	5d                   	pop    %ebp
 a86:	c3                   	ret    

00000a87 <memset>:

void*
memset(void *dst, int c, uint n)
{
 a87:	55                   	push   %ebp
 a88:	89 e5                	mov    %esp,%ebp
 a8a:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 a8b:	8b 7d 08             	mov    0x8(%ebp),%edi
 a8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 a91:	8b 45 0c             	mov    0xc(%ebp),%eax
 a94:	fc                   	cld    
 a95:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 a97:	8b 45 08             	mov    0x8(%ebp),%eax
 a9a:	8b 7d fc             	mov    -0x4(%ebp),%edi
 a9d:	c9                   	leave  
 a9e:	c3                   	ret    

00000a9f <strchr>:

char*
strchr(const char *s, char c)
{
 a9f:	55                   	push   %ebp
 aa0:	89 e5                	mov    %esp,%ebp
 aa2:	8b 45 08             	mov    0x8(%ebp),%eax
 aa5:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
 aa8:	eb 01                	jmp    aab <strchr+0xc>
 aaa:	40                   	inc    %eax
 aab:	8a 10                	mov    (%eax),%dl
 aad:	84 d2                	test   %dl,%dl
 aaf:	74 06                	je     ab7 <strchr+0x18>
    if(*s == c)
 ab1:	38 ca                	cmp    %cl,%dl
 ab3:	75 f5                	jne    aaa <strchr+0xb>
 ab5:	eb 05                	jmp    abc <strchr+0x1d>
      return (char*)s;
  return 0;
 ab7:	b8 00 00 00 00       	mov    $0x0,%eax
}
 abc:	5d                   	pop    %ebp
 abd:	c3                   	ret    

00000abe <gets>:

char*
gets(char *buf, int max)
{
 abe:	55                   	push   %ebp
 abf:	89 e5                	mov    %esp,%ebp
 ac1:	57                   	push   %edi
 ac2:	56                   	push   %esi
 ac3:	53                   	push   %ebx
 ac4:	83 ec 1c             	sub    $0x1c,%esp
 ac7:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 aca:	bb 00 00 00 00       	mov    $0x0,%ebx
 acf:	89 de                	mov    %ebx,%esi
 ad1:	43                   	inc    %ebx
 ad2:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 ad5:	7d 2b                	jge    b02 <gets+0x44>
    cc = read(0, &c, 1);
 ad7:	83 ec 04             	sub    $0x4,%esp
 ada:	6a 01                	push   $0x1
 adc:	8d 45 e7             	lea    -0x19(%ebp),%eax
 adf:	50                   	push   %eax
 ae0:	6a 00                	push   $0x0
 ae2:	e8 e3 00 00 00       	call   bca <read>
    if(cc < 1)
 ae7:	83 c4 10             	add    $0x10,%esp
 aea:	85 c0                	test   %eax,%eax
 aec:	7e 14                	jle    b02 <gets+0x44>
      break;
    buf[i++] = c;
 aee:	8a 45 e7             	mov    -0x19(%ebp),%al
 af1:	88 04 37             	mov    %al,(%edi,%esi,1)
    if(c == '\n' || c == '\r')
 af4:	3c 0a                	cmp    $0xa,%al
 af6:	74 08                	je     b00 <gets+0x42>
 af8:	3c 0d                	cmp    $0xd,%al
 afa:	75 d3                	jne    acf <gets+0x11>
    buf[i++] = c;
 afc:	89 de                	mov    %ebx,%esi
 afe:	eb 02                	jmp    b02 <gets+0x44>
 b00:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 b02:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 b06:	89 f8                	mov    %edi,%eax
 b08:	8d 65 f4             	lea    -0xc(%ebp),%esp
 b0b:	5b                   	pop    %ebx
 b0c:	5e                   	pop    %esi
 b0d:	5f                   	pop    %edi
 b0e:	5d                   	pop    %ebp
 b0f:	c3                   	ret    

00000b10 <stat>:

int
stat(const char *n, struct stat *st)
{
 b10:	55                   	push   %ebp
 b11:	89 e5                	mov    %esp,%ebp
 b13:	56                   	push   %esi
 b14:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 b15:	83 ec 08             	sub    $0x8,%esp
 b18:	6a 00                	push   $0x0
 b1a:	ff 75 08             	push   0x8(%ebp)
 b1d:	e8 d0 00 00 00       	call   bf2 <open>
  if(fd < 0)
 b22:	83 c4 10             	add    $0x10,%esp
 b25:	85 c0                	test   %eax,%eax
 b27:	78 24                	js     b4d <stat+0x3d>
 b29:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 b2b:	83 ec 08             	sub    $0x8,%esp
 b2e:	ff 75 0c             	push   0xc(%ebp)
 b31:	50                   	push   %eax
 b32:	e8 d3 00 00 00       	call   c0a <fstat>
 b37:	89 c6                	mov    %eax,%esi
  close(fd);
 b39:	89 1c 24             	mov    %ebx,(%esp)
 b3c:	e8 99 00 00 00       	call   bda <close>
  return r;
 b41:	83 c4 10             	add    $0x10,%esp
}
 b44:	89 f0                	mov    %esi,%eax
 b46:	8d 65 f8             	lea    -0x8(%ebp),%esp
 b49:	5b                   	pop    %ebx
 b4a:	5e                   	pop    %esi
 b4b:	5d                   	pop    %ebp
 b4c:	c3                   	ret    
    return -1;
 b4d:	be ff ff ff ff       	mov    $0xffffffff,%esi
 b52:	eb f0                	jmp    b44 <stat+0x34>

00000b54 <atoi>:

int
atoi(const char *s)
{
 b54:	55                   	push   %ebp
 b55:	89 e5                	mov    %esp,%ebp
 b57:	53                   	push   %ebx
 b58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 b5b:	ba 00 00 00 00       	mov    $0x0,%edx
  while('0' <= *s && *s <= '9')
 b60:	eb 0e                	jmp    b70 <atoi+0x1c>
    n = n*10 + *s++ - '0';
 b62:	8d 14 92             	lea    (%edx,%edx,4),%edx
 b65:	8d 1c 12             	lea    (%edx,%edx,1),%ebx
 b68:	41                   	inc    %ecx
 b69:	0f be c0             	movsbl %al,%eax
 b6c:	8d 54 18 d0          	lea    -0x30(%eax,%ebx,1),%edx
  while('0' <= *s && *s <= '9')
 b70:	8a 01                	mov    (%ecx),%al
 b72:	8d 58 d0             	lea    -0x30(%eax),%ebx
 b75:	80 fb 09             	cmp    $0x9,%bl
 b78:	76 e8                	jbe    b62 <atoi+0xe>
  return n;
}
 b7a:	89 d0                	mov    %edx,%eax
 b7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 b7f:	c9                   	leave  
 b80:	c3                   	ret    

00000b81 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 b81:	55                   	push   %ebp
 b82:	89 e5                	mov    %esp,%ebp
 b84:	56                   	push   %esi
 b85:	53                   	push   %ebx
 b86:	8b 45 08             	mov    0x8(%ebp),%eax
 b89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 b8c:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 b8f:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 b91:	eb 0c                	jmp    b9f <memmove+0x1e>
    *dst++ = *src++;
 b93:	8a 13                	mov    (%ebx),%dl
 b95:	88 11                	mov    %dl,(%ecx)
 b97:	8d 5b 01             	lea    0x1(%ebx),%ebx
 b9a:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 b9d:	89 f2                	mov    %esi,%edx
 b9f:	8d 72 ff             	lea    -0x1(%edx),%esi
 ba2:	85 d2                	test   %edx,%edx
 ba4:	7f ed                	jg     b93 <memmove+0x12>
  return vdst;
}
 ba6:	5b                   	pop    %ebx
 ba7:	5e                   	pop    %esi
 ba8:	5d                   	pop    %ebp
 ba9:	c3                   	ret    

00000baa <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 baa:	b8 01 00 00 00       	mov    $0x1,%eax
 baf:	cd 40                	int    $0x40
 bb1:	c3                   	ret    

00000bb2 <exit>:
SYSCALL(exit)
 bb2:	b8 02 00 00 00       	mov    $0x2,%eax
 bb7:	cd 40                	int    $0x40
 bb9:	c3                   	ret    

00000bba <wait>:
SYSCALL(wait)
 bba:	b8 03 00 00 00       	mov    $0x3,%eax
 bbf:	cd 40                	int    $0x40
 bc1:	c3                   	ret    

00000bc2 <pipe>:
SYSCALL(pipe)
 bc2:	b8 04 00 00 00       	mov    $0x4,%eax
 bc7:	cd 40                	int    $0x40
 bc9:	c3                   	ret    

00000bca <read>:
SYSCALL(read)
 bca:	b8 05 00 00 00       	mov    $0x5,%eax
 bcf:	cd 40                	int    $0x40
 bd1:	c3                   	ret    

00000bd2 <write>:
SYSCALL(write)
 bd2:	b8 10 00 00 00       	mov    $0x10,%eax
 bd7:	cd 40                	int    $0x40
 bd9:	c3                   	ret    

00000bda <close>:
SYSCALL(close)
 bda:	b8 15 00 00 00       	mov    $0x15,%eax
 bdf:	cd 40                	int    $0x40
 be1:	c3                   	ret    

00000be2 <kill>:
SYSCALL(kill)
 be2:	b8 06 00 00 00       	mov    $0x6,%eax
 be7:	cd 40                	int    $0x40
 be9:	c3                   	ret    

00000bea <exec>:
SYSCALL(exec)
 bea:	b8 07 00 00 00       	mov    $0x7,%eax
 bef:	cd 40                	int    $0x40
 bf1:	c3                   	ret    

00000bf2 <open>:
SYSCALL(open)
 bf2:	b8 0f 00 00 00       	mov    $0xf,%eax
 bf7:	cd 40                	int    $0x40
 bf9:	c3                   	ret    

00000bfa <mknod>:
SYSCALL(mknod)
 bfa:	b8 11 00 00 00       	mov    $0x11,%eax
 bff:	cd 40                	int    $0x40
 c01:	c3                   	ret    

00000c02 <unlink>:
SYSCALL(unlink)
 c02:	b8 12 00 00 00       	mov    $0x12,%eax
 c07:	cd 40                	int    $0x40
 c09:	c3                   	ret    

00000c0a <fstat>:
SYSCALL(fstat)
 c0a:	b8 08 00 00 00       	mov    $0x8,%eax
 c0f:	cd 40                	int    $0x40
 c11:	c3                   	ret    

00000c12 <link>:
SYSCALL(link)
 c12:	b8 13 00 00 00       	mov    $0x13,%eax
 c17:	cd 40                	int    $0x40
 c19:	c3                   	ret    

00000c1a <mkdir>:
SYSCALL(mkdir)
 c1a:	b8 14 00 00 00       	mov    $0x14,%eax
 c1f:	cd 40                	int    $0x40
 c21:	c3                   	ret    

00000c22 <chdir>:
SYSCALL(chdir)
 c22:	b8 09 00 00 00       	mov    $0x9,%eax
 c27:	cd 40                	int    $0x40
 c29:	c3                   	ret    

00000c2a <dup>:
SYSCALL(dup)
 c2a:	b8 0a 00 00 00       	mov    $0xa,%eax
 c2f:	cd 40                	int    $0x40
 c31:	c3                   	ret    

00000c32 <getpid>:
SYSCALL(getpid)
 c32:	b8 0b 00 00 00       	mov    $0xb,%eax
 c37:	cd 40                	int    $0x40
 c39:	c3                   	ret    

00000c3a <sbrk>:
SYSCALL(sbrk)
 c3a:	b8 0c 00 00 00       	mov    $0xc,%eax
 c3f:	cd 40                	int    $0x40
 c41:	c3                   	ret    

00000c42 <sleep>:
SYSCALL(sleep)
 c42:	b8 0d 00 00 00       	mov    $0xd,%eax
 c47:	cd 40                	int    $0x40
 c49:	c3                   	ret    

00000c4a <uptime>:
SYSCALL(uptime)
 c4a:	b8 0e 00 00 00       	mov    $0xe,%eax
 c4f:	cd 40                	int    $0x40
 c51:	c3                   	ret    

00000c52 <date>:
SYSCALL(date)
 c52:	b8 16 00 00 00       	mov    $0x16,%eax
 c57:	cd 40                	int    $0x40
 c59:	c3                   	ret    

00000c5a <dup2>:
SYSCALL(dup2)
 c5a:	b8 17 00 00 00       	mov    $0x17,%eax
 c5f:	cd 40                	int    $0x40
 c61:	c3                   	ret    

00000c62 <getprio>:
SYSCALL(getprio)
 c62:	b8 18 00 00 00       	mov    $0x18,%eax
 c67:	cd 40                	int    $0x40
 c69:	c3                   	ret    

00000c6a <setprio>:
SYSCALL(setprio)
 c6a:	b8 19 00 00 00       	mov    $0x19,%eax
 c6f:	cd 40                	int    $0x40
 c71:	c3                   	ret    

00000c72 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 c72:	55                   	push   %ebp
 c73:	89 e5                	mov    %esp,%ebp
 c75:	83 ec 1c             	sub    $0x1c,%esp
 c78:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 c7b:	6a 01                	push   $0x1
 c7d:	8d 55 f4             	lea    -0xc(%ebp),%edx
 c80:	52                   	push   %edx
 c81:	50                   	push   %eax
 c82:	e8 4b ff ff ff       	call   bd2 <write>
}
 c87:	83 c4 10             	add    $0x10,%esp
 c8a:	c9                   	leave  
 c8b:	c3                   	ret    

00000c8c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 c8c:	55                   	push   %ebp
 c8d:	89 e5                	mov    %esp,%ebp
 c8f:	57                   	push   %edi
 c90:	56                   	push   %esi
 c91:	53                   	push   %ebx
 c92:	83 ec 2c             	sub    $0x2c,%esp
 c95:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 c98:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 c9a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 c9e:	74 04                	je     ca4 <printint+0x18>
 ca0:	85 d2                	test   %edx,%edx
 ca2:	78 3c                	js     ce0 <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 ca4:	89 d1                	mov    %edx,%ecx
  neg = 0;
 ca6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 cad:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 cb2:	89 c8                	mov    %ecx,%eax
 cb4:	ba 00 00 00 00       	mov    $0x0,%edx
 cb9:	f7 f6                	div    %esi
 cbb:	89 df                	mov    %ebx,%edi
 cbd:	43                   	inc    %ebx
 cbe:	8a 92 20 11 00 00    	mov    0x1120(%edx),%dl
 cc4:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 cc8:	89 ca                	mov    %ecx,%edx
 cca:	89 c1                	mov    %eax,%ecx
 ccc:	39 d6                	cmp    %edx,%esi
 cce:	76 e2                	jbe    cb2 <printint+0x26>
  if(neg)
 cd0:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 cd4:	74 24                	je     cfa <printint+0x6e>
    buf[i++] = '-';
 cd6:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 cdb:	8d 5f 02             	lea    0x2(%edi),%ebx
 cde:	eb 1a                	jmp    cfa <printint+0x6e>
    x = -xx;
 ce0:	89 d1                	mov    %edx,%ecx
 ce2:	f7 d9                	neg    %ecx
    neg = 1;
 ce4:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 ceb:	eb c0                	jmp    cad <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 ced:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 cf2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 cf5:	e8 78 ff ff ff       	call   c72 <putc>
  while(--i >= 0)
 cfa:	4b                   	dec    %ebx
 cfb:	79 f0                	jns    ced <printint+0x61>
}
 cfd:	83 c4 2c             	add    $0x2c,%esp
 d00:	5b                   	pop    %ebx
 d01:	5e                   	pop    %esi
 d02:	5f                   	pop    %edi
 d03:	5d                   	pop    %ebp
 d04:	c3                   	ret    

00000d05 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 d05:	55                   	push   %ebp
 d06:	89 e5                	mov    %esp,%ebp
 d08:	57                   	push   %edi
 d09:	56                   	push   %esi
 d0a:	53                   	push   %ebx
 d0b:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 d0e:	8d 45 10             	lea    0x10(%ebp),%eax
 d11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 d14:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 d19:	bb 00 00 00 00       	mov    $0x0,%ebx
 d1e:	eb 12                	jmp    d32 <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 d20:	89 fa                	mov    %edi,%edx
 d22:	8b 45 08             	mov    0x8(%ebp),%eax
 d25:	e8 48 ff ff ff       	call   c72 <putc>
 d2a:	eb 05                	jmp    d31 <printf+0x2c>
      }
    } else if(state == '%'){
 d2c:	83 fe 25             	cmp    $0x25,%esi
 d2f:	74 22                	je     d53 <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 d31:	43                   	inc    %ebx
 d32:	8b 45 0c             	mov    0xc(%ebp),%eax
 d35:	8a 04 18             	mov    (%eax,%ebx,1),%al
 d38:	84 c0                	test   %al,%al
 d3a:	0f 84 1d 01 00 00    	je     e5d <printf+0x158>
    c = fmt[i] & 0xff;
 d40:	0f be f8             	movsbl %al,%edi
 d43:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 d46:	85 f6                	test   %esi,%esi
 d48:	75 e2                	jne    d2c <printf+0x27>
      if(c == '%'){
 d4a:	83 f8 25             	cmp    $0x25,%eax
 d4d:	75 d1                	jne    d20 <printf+0x1b>
        state = '%';
 d4f:	89 c6                	mov    %eax,%esi
 d51:	eb de                	jmp    d31 <printf+0x2c>
      if(c == 'd'){
 d53:	83 f8 25             	cmp    $0x25,%eax
 d56:	0f 84 cc 00 00 00    	je     e28 <printf+0x123>
 d5c:	0f 8c da 00 00 00    	jl     e3c <printf+0x137>
 d62:	83 f8 78             	cmp    $0x78,%eax
 d65:	0f 8f d1 00 00 00    	jg     e3c <printf+0x137>
 d6b:	83 f8 63             	cmp    $0x63,%eax
 d6e:	0f 8c c8 00 00 00    	jl     e3c <printf+0x137>
 d74:	83 e8 63             	sub    $0x63,%eax
 d77:	83 f8 15             	cmp    $0x15,%eax
 d7a:	0f 87 bc 00 00 00    	ja     e3c <printf+0x137>
 d80:	ff 24 85 c8 10 00 00 	jmp    *0x10c8(,%eax,4)
        printint(fd, *ap, 10, 1);
 d87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 d8a:	8b 17                	mov    (%edi),%edx
 d8c:	83 ec 0c             	sub    $0xc,%esp
 d8f:	6a 01                	push   $0x1
 d91:	b9 0a 00 00 00       	mov    $0xa,%ecx
 d96:	8b 45 08             	mov    0x8(%ebp),%eax
 d99:	e8 ee fe ff ff       	call   c8c <printint>
        ap++;
 d9e:	83 c7 04             	add    $0x4,%edi
 da1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 da4:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 da7:	be 00 00 00 00       	mov    $0x0,%esi
 dac:	eb 83                	jmp    d31 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 dae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 db1:	8b 17                	mov    (%edi),%edx
 db3:	83 ec 0c             	sub    $0xc,%esp
 db6:	6a 00                	push   $0x0
 db8:	b9 10 00 00 00       	mov    $0x10,%ecx
 dbd:	8b 45 08             	mov    0x8(%ebp),%eax
 dc0:	e8 c7 fe ff ff       	call   c8c <printint>
        ap++;
 dc5:	83 c7 04             	add    $0x4,%edi
 dc8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 dcb:	83 c4 10             	add    $0x10,%esp
      state = 0;
 dce:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 dd3:	e9 59 ff ff ff       	jmp    d31 <printf+0x2c>
        s = (char*)*ap;
 dd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 ddb:	8b 30                	mov    (%eax),%esi
        ap++;
 ddd:	83 c0 04             	add    $0x4,%eax
 de0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 de3:	85 f6                	test   %esi,%esi
 de5:	75 13                	jne    dfa <printf+0xf5>
          s = "(null)";
 de7:	be c0 10 00 00       	mov    $0x10c0,%esi
 dec:	eb 0c                	jmp    dfa <printf+0xf5>
          putc(fd, *s);
 dee:	0f be d2             	movsbl %dl,%edx
 df1:	8b 45 08             	mov    0x8(%ebp),%eax
 df4:	e8 79 fe ff ff       	call   c72 <putc>
          s++;
 df9:	46                   	inc    %esi
        while(*s != 0){
 dfa:	8a 16                	mov    (%esi),%dl
 dfc:	84 d2                	test   %dl,%dl
 dfe:	75 ee                	jne    dee <printf+0xe9>
      state = 0;
 e00:	be 00 00 00 00       	mov    $0x0,%esi
 e05:	e9 27 ff ff ff       	jmp    d31 <printf+0x2c>
        putc(fd, *ap);
 e0a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 e0d:	0f be 17             	movsbl (%edi),%edx
 e10:	8b 45 08             	mov    0x8(%ebp),%eax
 e13:	e8 5a fe ff ff       	call   c72 <putc>
        ap++;
 e18:	83 c7 04             	add    $0x4,%edi
 e1b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 e1e:	be 00 00 00 00       	mov    $0x0,%esi
 e23:	e9 09 ff ff ff       	jmp    d31 <printf+0x2c>
        putc(fd, c);
 e28:	89 fa                	mov    %edi,%edx
 e2a:	8b 45 08             	mov    0x8(%ebp),%eax
 e2d:	e8 40 fe ff ff       	call   c72 <putc>
      state = 0;
 e32:	be 00 00 00 00       	mov    $0x0,%esi
 e37:	e9 f5 fe ff ff       	jmp    d31 <printf+0x2c>
        putc(fd, '%');
 e3c:	ba 25 00 00 00       	mov    $0x25,%edx
 e41:	8b 45 08             	mov    0x8(%ebp),%eax
 e44:	e8 29 fe ff ff       	call   c72 <putc>
        putc(fd, c);
 e49:	89 fa                	mov    %edi,%edx
 e4b:	8b 45 08             	mov    0x8(%ebp),%eax
 e4e:	e8 1f fe ff ff       	call   c72 <putc>
      state = 0;
 e53:	be 00 00 00 00       	mov    $0x0,%esi
 e58:	e9 d4 fe ff ff       	jmp    d31 <printf+0x2c>
    }
  }
}
 e5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
 e60:	5b                   	pop    %ebx
 e61:	5e                   	pop    %esi
 e62:	5f                   	pop    %edi
 e63:	5d                   	pop    %ebp
 e64:	c3                   	ret    

00000e65 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 e65:	55                   	push   %ebp
 e66:	89 e5                	mov    %esp,%ebp
 e68:	57                   	push   %edi
 e69:	56                   	push   %esi
 e6a:	53                   	push   %ebx
 e6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 e6e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e71:	a1 24 17 00 00       	mov    0x1724,%eax
 e76:	eb 02                	jmp    e7a <free+0x15>
 e78:	89 d0                	mov    %edx,%eax
 e7a:	39 c8                	cmp    %ecx,%eax
 e7c:	73 04                	jae    e82 <free+0x1d>
 e7e:	39 08                	cmp    %ecx,(%eax)
 e80:	77 12                	ja     e94 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e82:	8b 10                	mov    (%eax),%edx
 e84:	39 c2                	cmp    %eax,%edx
 e86:	77 f0                	ja     e78 <free+0x13>
 e88:	39 c8                	cmp    %ecx,%eax
 e8a:	72 08                	jb     e94 <free+0x2f>
 e8c:	39 ca                	cmp    %ecx,%edx
 e8e:	77 04                	ja     e94 <free+0x2f>
 e90:	89 d0                	mov    %edx,%eax
 e92:	eb e6                	jmp    e7a <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 e94:	8b 73 fc             	mov    -0x4(%ebx),%esi
 e97:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 e9a:	8b 10                	mov    (%eax),%edx
 e9c:	39 d7                	cmp    %edx,%edi
 e9e:	74 19                	je     eb9 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 ea0:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 ea3:	8b 50 04             	mov    0x4(%eax),%edx
 ea6:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 ea9:	39 ce                	cmp    %ecx,%esi
 eab:	74 1b                	je     ec8 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 ead:	89 08                	mov    %ecx,(%eax)
  freep = p;
 eaf:	a3 24 17 00 00       	mov    %eax,0x1724
}
 eb4:	5b                   	pop    %ebx
 eb5:	5e                   	pop    %esi
 eb6:	5f                   	pop    %edi
 eb7:	5d                   	pop    %ebp
 eb8:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 eb9:	03 72 04             	add    0x4(%edx),%esi
 ebc:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 ebf:	8b 10                	mov    (%eax),%edx
 ec1:	8b 12                	mov    (%edx),%edx
 ec3:	89 53 f8             	mov    %edx,-0x8(%ebx)
 ec6:	eb db                	jmp    ea3 <free+0x3e>
    p->s.size += bp->s.size;
 ec8:	03 53 fc             	add    -0x4(%ebx),%edx
 ecb:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 ece:	8b 53 f8             	mov    -0x8(%ebx),%edx
 ed1:	89 10                	mov    %edx,(%eax)
 ed3:	eb da                	jmp    eaf <free+0x4a>

00000ed5 <morecore>:

static Header*
morecore(uint nu)
{
 ed5:	55                   	push   %ebp
 ed6:	89 e5                	mov    %esp,%ebp
 ed8:	53                   	push   %ebx
 ed9:	83 ec 04             	sub    $0x4,%esp
 edc:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 ede:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 ee3:	77 05                	ja     eea <morecore+0x15>
    nu = 4096;
 ee5:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 eea:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 ef1:	83 ec 0c             	sub    $0xc,%esp
 ef4:	50                   	push   %eax
 ef5:	e8 40 fd ff ff       	call   c3a <sbrk>
  if(p == (char*)-1)
 efa:	83 c4 10             	add    $0x10,%esp
 efd:	83 f8 ff             	cmp    $0xffffffff,%eax
 f00:	74 1c                	je     f1e <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 f02:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 f05:	83 c0 08             	add    $0x8,%eax
 f08:	83 ec 0c             	sub    $0xc,%esp
 f0b:	50                   	push   %eax
 f0c:	e8 54 ff ff ff       	call   e65 <free>
  return freep;
 f11:	a1 24 17 00 00       	mov    0x1724,%eax
 f16:	83 c4 10             	add    $0x10,%esp
}
 f19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 f1c:	c9                   	leave  
 f1d:	c3                   	ret    
    return 0;
 f1e:	b8 00 00 00 00       	mov    $0x0,%eax
 f23:	eb f4                	jmp    f19 <morecore+0x44>

00000f25 <malloc>:

void*
malloc(uint nbytes)
{
 f25:	55                   	push   %ebp
 f26:	89 e5                	mov    %esp,%ebp
 f28:	53                   	push   %ebx
 f29:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 f2c:	8b 45 08             	mov    0x8(%ebp),%eax
 f2f:	8d 58 07             	lea    0x7(%eax),%ebx
 f32:	c1 eb 03             	shr    $0x3,%ebx
 f35:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 f36:	8b 0d 24 17 00 00    	mov    0x1724,%ecx
 f3c:	85 c9                	test   %ecx,%ecx
 f3e:	74 04                	je     f44 <malloc+0x1f>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f40:	8b 01                	mov    (%ecx),%eax
 f42:	eb 4a                	jmp    f8e <malloc+0x69>
    base.s.ptr = freep = prevp = &base;
 f44:	c7 05 24 17 00 00 28 	movl   $0x1728,0x1724
 f4b:	17 00 00 
 f4e:	c7 05 28 17 00 00 28 	movl   $0x1728,0x1728
 f55:	17 00 00 
    base.s.size = 0;
 f58:	c7 05 2c 17 00 00 00 	movl   $0x0,0x172c
 f5f:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 f62:	b9 28 17 00 00       	mov    $0x1728,%ecx
 f67:	eb d7                	jmp    f40 <malloc+0x1b>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 f69:	74 19                	je     f84 <malloc+0x5f>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 f6b:	29 da                	sub    %ebx,%edx
 f6d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 f70:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 f73:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 f76:	89 0d 24 17 00 00    	mov    %ecx,0x1724
      return (void*)(p + 1);
 f7c:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 f7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 f82:	c9                   	leave  
 f83:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 f84:	8b 10                	mov    (%eax),%edx
 f86:	89 11                	mov    %edx,(%ecx)
 f88:	eb ec                	jmp    f76 <malloc+0x51>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f8a:	89 c1                	mov    %eax,%ecx
 f8c:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 f8e:	8b 50 04             	mov    0x4(%eax),%edx
 f91:	39 da                	cmp    %ebx,%edx
 f93:	73 d4                	jae    f69 <malloc+0x44>
    if(p == freep)
 f95:	39 05 24 17 00 00    	cmp    %eax,0x1724
 f9b:	75 ed                	jne    f8a <malloc+0x65>
      if((p = morecore(nunits)) == 0)
 f9d:	89 d8                	mov    %ebx,%eax
 f9f:	e8 31 ff ff ff       	call   ed5 <morecore>
 fa4:	85 c0                	test   %eax,%eax
 fa6:	75 e2                	jne    f8a <malloc+0x65>
 fa8:	eb d5                	jmp    f7f <malloc+0x5a>
