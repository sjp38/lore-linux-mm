Date: Wed, 23 Jan 2008 10:03:04 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH -v8 2/4] Update ctime and mtime for memory-mapped files
In-Reply-To: <12010440822957-git-send-email-salikhmetov@gmail.com>
Message-ID: <alpine.LFD.1.00.0801230959500.1741@woody.linux-foundation.org>
References: <12010440803930-git-send-email-salikhmetov@gmail.com> <12010440822957-git-send-email-salikhmetov@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Salikhmetov <salikhmetov@gmail.com>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>


On Wed, 23 Jan 2008, Anton Salikhmetov wrote:
>
> Update ctime and mtime for memory-mapped files at a write access on
> a present, read-only PTE, as well as at a write on a non-present PTE.

Ok, this one I'm applying. I agree that it leaves MS_ASYNC not updating 
the file until the next sync actually happens, but I can't really bring 
myself to care at least for an imminent 2.6.24 thing. The file times are 
actually "correct" in the sense that they will now match when the IO is 
done, and my man-page says that MS_ASYNC "schedules the io to be done".

And I think this is better than we have now, and I don't think this part 
is somethign that anybody really disagrees with.

We can (and should) keep the MS_ASYNC issue open.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
