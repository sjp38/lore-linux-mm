Message-ID: <20000906063923.20382.qmail@web6404.mail.yahoo.com>
Date: Tue, 5 Sep 2000 23:39:23 -0700 (PDT)
From: Zeshan Ahmad <zeshan_uet@yahoo.com>
Subject: kernel stack overflow
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: tigran@veritas.com
Cc: markhe@veritas.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi
 
I have tried the patch which Mark sent me but it
has'nt solved the problem.

Mark wrote:
>In my original, the code assumes that all general
>purpose slabs below
>"bufctl_limit" where suitable for bufctl allocation 
>(look at a 2.2.x
>version, in kmem_cache_sizes_init() I have a state
>variable called
>"found").
  
Since I am already using 2.2.x, so the patch is not
working. This means i am already using the variable
"found". Hence the problem is still there.

Is there any other solution available? Plz help me.

Waiting anxiously for ur reply.

Regards
Zeshan



__________________________________________________
Do You Yahoo!?
Yahoo! Mail - Free email you can access from anywhere!
http://mail.yahoo.com/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
