Date: Mon, 15 Oct 2007 02:16:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH resend] ramdisk: fix zeroed ramdisk pages on memory
 pressure
Message-Id: <20071015021624.7d5233bd.akpm@linux-foundation.org>
In-Reply-To: <200710160006.19735.nickpiggin@yahoo.com.au>
References: <200710151028.34407.borntraeger@de.ibm.com>
	<200710160006.19735.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Oct 2007 00:06:19 +1000 Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> On Monday 15 October 2007 18:28, Christian Borntraeger wrote:
> > Andrew, this is a resend of a bugfix patch. Ramdisk seems a bit
> > unmaintained, so decided to sent the patch to you :-).
> > I have CCed Ted, who did work on the code in the 90s. I found no current
> > email address of Chad Page.
> 
> This really needs to be fixed...

rd.c is fairly mind-boggling vfs abuse.

> I can't make up my mind between the approaches to fixing it.
> 
> On one hand, I would actually prefer to really mark the buffers
> dirty (as in: Eric's fix for this problem[*]) than this patch,
> and this seems a bit like a bandaid...
> 
> On the other hand, the wound being covered by the bandaid is
> actually the code in the buffer layer that does this latent
> "cleaning" of the page because it sadly doesn't really keep
> track of the pagecache state. But it *still* feels like we
> should be marking the rd page's buffers dirty which should
> avoid this problem anyway.
> 
> [*] However, hmm, with Eric's patch I guess we'd still have a hole
> where filesystems that write their buffers by hand think they are
> "cleaning" these things and we're back to square one. That could
> be fixed by marking the buffers dirty again?
> 
> Why were Eric's patches dropped, BTW? I don't remember.

runtime problems, iirc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
