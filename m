From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH -v8 3/4] Enable the MS_ASYNC functionality in sys_msync()
Date: Thu, 24 Jan 2008 12:36:00 +1100
References: <12010440803930-git-send-email-salikhmetov@gmail.com> <1201044083504-git-send-email-salikhmetov@gmail.com> <alpine.LFD.1.00.0801230836250.1741@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.00.0801230836250.1741@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801241236.01114.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Anton Salikhmetov <salikhmetov@gmail.com>, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On Thursday 24 January 2008 04:05, Linus Torvalds wrote:
> On Wed, 23 Jan 2008, Anton Salikhmetov wrote:
> > +
> > +		if (pte_dirty(*pte) && pte_write(*pte)) {
>
> Not correct.
>
> You still need to check "pte_present()" before you can test any other
> bits. For a non-present pte, none of the other bits are defined, and for
> all we know there might be architectures out there that require them to
> be non-dirty.
>
> As it is, you just possibly randomly corrupted the pte.
>
> Yeah, on all architectures I know of, it the pte is clear, neither of
> those tests will trigger, so it just happens to work, but it's still
> wrong.

Probably it can fail for !present nonlinear mappings on many
architectures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
