Received: from tex.inetint.com (tex [172.16.99.35]) by zeke.inet.com (INET SMTP Server)  with ESMTP id h2EKcQaH010228 for <linux-mm@kvack.org>; Fri, 14 Mar 2003 14:38:27 -0600 (CST)
Received: from harpo.inetint.com (localhost [127.0.0.1])
	by tex.inetint.com (8.12.1/8.12.1) with ESMTP id h2EKcOS4009578
	for <linux-mm@kvack.org>; Fri, 14 Mar 2003 14:38:24 -0600 (CST)
Message-ID: <3E723DBF.6040304@inet.com>
Date: Fri, 14 Mar 2003 14:38:23 -0600
From: Eli Carter <eli.carter@inet.com>
MIME-Version: 1.0
Subject: Re: 2.5.64-mm6
References: <20030313032615.7ca491d6.akpm@digeo.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.64/2.5.64-mm6/
[snip]
> kgdb.patch

I'm interested in this patch in your tree.  (Just to warn you of my 
biases, I'm currently working with the XScale/ARM arch.)  I've noticed 
some things about it in an initial look, namely:

There appears to be some code duplication between hex() and stubhex() in 
arch/i386/kernel/gdbstub.c.

Also, the bulk of gdbstub.c appears to be generic code.  There are a 
number of functions that have x86 asm in them, but it looks to me on 
initial viewing, that most of the logic is applicable to other arches. 
Am I understanding that correctly?
Right now it looks like an arch would need to provide a way to:
- reboot the processor
- implement 'continue at address' and 'step one instruction from address'
- handle_exeption()
- printexception()
- correct_hw_break()
- regs_to_gdb_regs() and gdb_regs_to_regs()
     Hmm, there's probably some more to that part...
The above is just for the gdbstub.c.  I'm still reading the patch. :)

Would breaking the arch-independent parts out to linux/kernel/gdbstub.c 
be a reasonable change or is that a dumb question? ;)

Thanks,

Eli
--------------------. "If it ain't broke now,
Eli Carter           \                  it will be soon." -- crypto-gram
eli.carter(a)inet.com `-------------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
