Date: Fri, 30 Mar 2007 04:40:48 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/2] mm: dont account ZERO_PAGE
Message-ID: <20070330024048.GG19407@wotan.suse.de>
References: <20070329075805.GA6852@wotan.suse.de> <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, Mar 29, 2007 at 02:10:55PM +0100, Hugh Dickins wrote:
> 
> But this patch is not complete, is it?  For example, fremap.c's
> zap_pte?  I haven't checked further.  I was going to suggest you

Ah yes, nonlinear... thanks I missed that.

Well it would make life easier if we got rid of ZERO_PAGE completely,
which I definitely wouldn't complain about ;) It is much more likely
to cause noticable performance loss in other areas though, so it is
not really a candidate for SLES at the moment.

But I would like to get something for mainline that everyone likes
whether that is vm_refcounted_page (which I just implemented and it
doesn't make things much cleaner, but I'll go with it); per-node
ZERO_PAGE; or whatever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
