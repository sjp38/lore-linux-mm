In-reply-to: <alpine.LFD.1.00.0801180949040.2957@woody.linux-foundation.org>
	(message from Linus Torvalds on Fri, 18 Jan 2008 09:58:04 -0800 (PST))
Subject: Re: [PATCH -v6 2/2] Updating ctime and mtime for memory-mapped
 files
References: <12006091182260-git-send-email-salikhmetov@gmail.com>  <12006091211208-git-send-email-salikhmetov@gmail.com>  <E1JFnsg-0008UU-LU@pomaz-ex.szeredi.hu>  <1200651337.5920.9.camel@twins> <1200651958.5920.12.camel@twins> <alpine.LFD.1.00.0801180949040.2957@woody.linux-foundation.org>
Message-Id: <E1JFvgx-0000zz-2C@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 18 Jan 2008 19:11:47 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: peterz@infradead.org, miklos@szeredi.hu, salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

> And even in that four-liner, I suspect that the *last* two lines are 
> actually incorrect: there's no point in updating the file time when the 
> page *becomes* dirty,

Actually all four lines do that.  The first two for a write access on
a present, read-only pte, the other two for a write on a non-present
pte.

> we should update the file time when it is marked 
> clean, and "msync(MS_SYNC)" should update it as part of *that*.

That would need a new page flag (PG_mmap_dirty?).  Do we have one
available?

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
