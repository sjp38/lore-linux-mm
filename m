Message-ID: <3D6EEC88.F6D0E6D6@zip.com.au>
Date: Thu, 29 Aug 2002 20:54:48 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: statm_pgd_range() sucks!
References: <20020830015814.GN18114@holomorphy.com> <3D6EDDC0.F9ADC015@zip.com.au> <20020830031208.GK888@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@surriel.com
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> William Lee Irwin III wrote:
> >> (1) shared, lib, text, & total are now reported as what's mapped
> >>         instead of what's resident. This actually fixes two bugs:
> 
> On Thu, Aug 29, 2002 at 07:51:44PM -0700, Andrew Morton wrote:
> > hmm.  Personally, I've never believed, or even bothered to try to
> > understand what those columns are measuring.  Does anyone actually
> > find them useful for anything?  If so, what are they being used for?
> > What info do we really, actually want to know?
> 
> I'm basically looking for VSZ, RSS, %cpu, & pid -- after that I don't
> care.

Well statistics coming out of the kernel can be quite vital in the tuning
of real world applications - they're not just for kernel developers.  The
stats contribute to the bottom-line performance and stability of the things
for which people are actually using the kernel.  That's a motherhood statement,
I know, but I think it's important.

> ...
> 
> Per-vma RSS is trivial, just less self-contained. Everywhere the
> mm->rss is touched, the vma to account that to is also known, except
> for put_dirty_page(), and that can be repaired as its caller knows.

This would provide useful information at a justifiable cost, don't you
think?

(ho-hum, all right.  I'll code it ;))
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
