Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EC2A26B005A
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 06:31:36 -0400 (EDT)
Subject: Re: kmemeleak BUG: lock held when returning to user space!
References: <20090709104202.GA3434@localdomain.by>
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Thu, 09 Jul 2009 11:47:23 +0100
In-Reply-To: <20090709104202.GA3434@localdomain.by> (Sergey Senozhatsky's message of "Thu\, 9 Jul 2009 13\:42\:02 +0300")
Message-ID: <tnxeisquo90.fsf@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sergey Senozhatsky <sergey.senozhatsky@mail.by> wrote:
> kernel: [  149.507103] ================================================
> kernel: [  149.507113] [ BUG: lock held when returning to user space! ]
> kernel: [  149.507119] ------------------------------------------------
> kernel: [  149.507127] cat/3279 is leaving the kernel with locks still held!
> kernel: [  149.507135] 1 lock held by cat/3279:
> kernel: [  149.507141]  #0:  (scan_mutex){+.+.+.}, at: [<c110707c>] kmemleak_open+0x4c/0x80
>
> problem is here:
> static int kmemleak_open(struct inode *inode, struct file *file)

It's been fixed in my kmemleak branch which I'll push to Linus:

http://www.linux-arm.org/git?p=linux-2.6.git;a=shortlog;h=kmemleak

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
