Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 096B15F0001
	for <linux-mm@kvack.org>; Sat, 30 May 2009 22:37:49 -0400 (EDT)
Date: Sat, 30 May 2009 19:35:56 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [PATCH] Use kzfree in tty buffer management to enforce data
	sanitization
Message-ID: <20090531023556.GB9033@oblivion.subreption.com>
References: <20090531015537.GA8941@oblivion.subreption.com> <alpine.LFD.2.01.0905301902530.3435@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0905301902530.3435@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On 19:04 Sat 30 May     , Linus Torvalds wrote:
> 
> 
> On Sat, 30 May 2009, Larry H. wrote:
> >
> > This patch doesn't affect fastpaths.
> 
> This patch is ugly as hell.
> 
> You already know the size of the data to clear.
> 
> If we actually wanted this (and I am in _no_way_ saying we do), the only 
> sane thing to do is to just do
> 
> 	memset(buf->data, 0, N_TTY_BUF_SIZE);
> 	if (PAGE_SIZE != N_TTY_BUF_SIZE)
> 		kfree(...)
> 	else
> 		free_page(...)
> 

It wasn't me who proposed using kzfree in these places. Ask Ingo and
Peter or refer to the entire thread about my previous patches.

In a way it's convenient that a patch written as of their
'recommendations' and 'positive feedback' is being ditched and properly
outed as an overkill. Surprisingly we might agree on this one.

> but quite frankly, I'm not convinced about these patches at all.
> 
> I'm also not in the least convinced about how you just dismiss everybodys 
> concerns.

This was proposed by Ingo, Andrew, Peter and later agreed upon by Alan.
I'm not sure whose concerns are being dismissed, but it looks like when
I make a perfectly valid technical point, and document it or provide
references, it's my concerns that get dismissed. It's also typically the
same people who do it, without providing true reasoning nor facts that
support their claims.

And every time I submit a patch which _exactly_ follows what other
people suddenly decided to agree upon, it is dismissed as well. In the
end it looks like there's no intention to close some
serious security loopholes in the kernel, but engage in endless
arguments about who's right or wrong, more often than not with people
whose area of expertise is definitely not security, making ad hominem
statements and so forth.

The next time a kernel vulnerability appears that is remotely related to
some of the venues of attack I've commented, it will be useful to be
able to refer to these responses.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
