Received: from ns.senbell.com.cn (root@[210.74.178.130])
	by kvack.org (8.8.7/8.8.7) with ESMTP id DAA23910
	for <linux-mm@kvack.org>; Wed, 7 Apr 1999 03:34:33 -0400
Received: (from root@localhost)
	by ns.senbell.com.cn (8.8.7/8.8.7) id VAA00397
	for linux-mm@kvack.org; Tue, 27 May 1997 21:36:16 +0800
Date: Tue, 27 May 1997 21:36:16 +0800
From: root <root@ns.senbell.com.cn>
Message-Id: <199705271336.VAA00397@ns.senbell.com.cn>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I am leiyin, a software engineer in china, beijing. I am interested
in Linux memory management these day. Since I find an ordinary user
can easily occupy all the memory available. Though I don't think this is 
a bug. I wonder whether I can control how much memory a user can occup
,including swap space, or not.


For example, this program occupy.c 
compile: cc -o occupy occupy.c

#define BLOCK 100000
#define PGSIZE 4096
char *p[BLOCK];

main()
{
  int i,j;

  for(i=0;i<BLOCK;i++)
  {
    for(j=0;j<PGSIZE;j++)
    p[i][j]  = 0;
    }

  sleep(100000); 
}


when I run occupy. My linux system with 32 RAM soon show
Out of Memory. And any other users cannot login and work normally.

Especially in AS400 OS/400 one can distribute a fixed size physical memory
(pool) for a subsystem. If Linux can do this( I mean a fixed size memory for
a user not subsystem), I think linux will become more lovely.


Address:leiyin_linux@163.net


  
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
