Subject: Re: lguest, Re: -mm merge plans for 2.6.23
From: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20070711122324.GA21714@lst.de>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <20070711122324.GA21714@lst.de>
Content-Type: text/plain
Date: Thu, 12 Jul 2007 11:21:51 +1000
Message-Id: <1184203311.6005.664.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-07-11 at 14:23 +0200, Christoph Hellwig wrote:
> > lguest-export-symbols-for-lguest-as-a-module.patch
> 
> __put_task_struct is one of those no way in hell should this be exported
> things because we don't want modules messing with task lifetimes.
> 
> Fortunately I can't find anything actually using this in lguest, so
> it looks the issue has been solved in the meantime.

To do inter-guest (ie. inter-process) I/O you really have to make sure
the other side doesn't go away.

> I also have a rather bad feeling about exporting access_process_vm.
> This is the proverbial sledge hammer for access to user vm addresses
> and I'd rather keep it away from module programmers with "if all
> you have is a hammer ..." in mind.
> 
> In lguest this is used by send_dma which from my short reading of the
> code seems to be the central IPC mechanism.  The double copy here
> doesn't look very efficient to me either.  Maybe some VM folks could
> look into a better way to archive this that might be both more
> efficient and not require the export.

It's not a double copy: it's a map & copy.

If KVM develops inter-guest I/O then this could all be extracted into a
helper function and made more efficient.

> Just started to reading this (again) so no useful comment here, but it
> would be nice if the code could follow CodingStyle and place the || and
> && at the end of the line in multiline conditionals instead of at the
> beginning of the new one.

Surprisingly, you have a point here.  Since the key purpose of lguest is
as demonstration code, it meticulously match kernel style.

I shall immediately prepare a patch to convert the rest of the kernel to
the correct "&& at beginning of line" style.

Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
