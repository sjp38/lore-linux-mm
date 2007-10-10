Date: Wed, 10 Oct 2007 05:06:18 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: remove zero_page (was Re: -mm merge plans for 2.6.24)
In-Reply-To: <200710092015.07741.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0710100424050.24074@blonde.wat.veritas.com>
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
 <200710091931.51564.nickpiggin@yahoo.com.au>
 <alpine.LFD.0.999.0710091917410.3838@woody.linux-foundation.org>
 <200710092015.07741.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Oct 2007, Nick Piggin wrote:
> by it ;) To prove my point: the *first* approach I posted to fix this
> problem was exactly a patch to special-case the zero_page refcounting
> which was removed with my PageReserved patch. Neither Hugh nor yourself
> liked it one bit!

True (speaking for me; I forget whether Linus ever got to see it).

I apologize to you, Nick, for getting you into this position of
fighting for something which wasn't your choice in the first place.

If I thought we'd have a better kernel by dropping this patch and
going back to one that just avoids the refcounting, I'd say do it.
No, I still think it's worth trying this one first.

But best have your avoid-the-refcounting patch ready and reviewed
for emergency use if regression does show up somewhere.

Thanks,
Hugh

[My mails out are at present getting randomly delayed by six hours or
so, which makes it extra hard for me to engage usefully in any thread.]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
