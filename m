Message-ID: <20000825060646.25968.qmail@web6404.mail.yahoo.com>
Date: Thu, 24 Aug 2000 23:06:46 -0700 (PDT)
From: Zeshan Ahmad <zeshan_uet@yahoo.com>
Subject: Stack overflow problem
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi

I am working on a video compression project for my
undergraduate studies at UET Lahore, Pakistan. I am
using a PowerPC and trying to run the Linux Kernel on
it. I am using linux kernel 2.2.16 for Power PC But
when I get to the kmem_cache_sizes_init in the file
/init/main.c, there is a stack overflow and the system
is halted. I have done some hacking and have found out
that the stack overflow exactly take splace in the
function kmem_cache_slabmgmt in the file /mm/slab.c at
the line
slabp->s_inuse = 0;

Can any1 suggest the cause and remedy?

Secondly, this PowerPC kernel is booting at 8M. Is
there anyway Ican change it to boot at say 2M or 4M.
Which files in assembly do I have to edit?

Urgent response is requested!!!

ZESHAN

__________________________________________________
Do You Yahoo!?
Yahoo! Mail - Free email you can access from anywhere!
http://mail.yahoo.com/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
