Message-ID: <20000904104744.2259.qmail@web6402.mail.yahoo.com>
Date: Mon, 4 Sep 2000 03:47:44 -0700 (PDT)
From: Zeshan Ahmad <zeshan_uet@yahoo.com>
Subject: stack overflow 
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

Can any1 tell me how can the stack size be changed in
the Kernel. i am experiencing a stack overflow problem
when the function kmem_cache_sizes_init is called in
/init/main.c The exact place where the stack overflow
occurs is in the function kmem_cache_slabmgmt in
/mm/slab.c

Is there any way to change the stack size in Kernel?
Can the change in stack size simply solve this Kernel
stack overflow problem?

Urgent help is needed.

ZEESHAN

__________________________________________________
Do You Yahoo!?
Yahoo! Mail - Free email you can access from anywhere!
http://mail.yahoo.com/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
