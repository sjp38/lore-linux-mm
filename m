Received: (from gkropitz@localhost)
	by uzo.telecoma.net (8.8.7/8.8.7) id VAA08352
	for linux-mm@kvack.org; Fri, 18 May 2001 21:06:47 +0200
Date: Fri, 18 May 2001 21:06:47 +0200
From: firenza@gmx.net
Subject: java/old_mmap allocation problems...
Message-ID: <20010518210647.B8318@telecoma.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[initially posted on linux-kernel, but someone pointed out this
 closer targeted list to me]

hi,

i'm having problems to convince java (1.3.1) to allocate more
than 1.9gb of memory on 2.4.2-ac2 (SMP/6gb phys mem/compiled with
64GB option) or more than 1.1gb on 2.2.18 (SMP/2gb phys mem/compiled
with 2GB option)...

modifing /proc/sys/vm parameters didn't help either... the fact
that i can allocate more memory under 2.4 than under 2.2 lets
me hope that there is some possible kernel/vm tweaking that
would increase those limits...

any pointers would be greatly appreciated!

cheers,
-firenza

PS:

strace snippet of "java -Xmx2g" on the 2.4 system
brk(0x8057000)                          = 0x8057000
old_mmap(NULL, 163840, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x43691000
old_mmap(NULL, 2181038080, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_PRIVATE|MAP_ANONYMOUS|MAP_NORESERVE, -1, 0) = -1 ENOMEM

strace snippet of "java -Xmx1500m" on the 2.2 system
old_mmap(0x2e082000, 4096, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x2e082000
old_mmap(NULL, 163840, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x2e102000
old_mmap(NULL, 1606418432, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_PRIVATE|MAP_ANONYMOUS|MAP_NORESERVE, -1, 0) = -1 ENOMEM
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
