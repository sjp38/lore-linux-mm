Message-ID: <3D76E207.1FA08024@zip.com.au>
Date: Wed, 04 Sep 2002 21:48:07 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: statm_pgd_range() sucks!
References: <20020830015814.GN18114@holomorphy.com> <3D6EDDC0.F9ADC015@zip.com.au> <20020905032035.GY888@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@surriel.com
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> On Thu, Aug 29, 2002 at 07:51:44PM -0700, Andrew Morton wrote:
> > BTW, Rohit's hugetlb patch touches proc_pid_statm(), so a diff on -mm3
> > would be appreciated.
> 
> I lost track of what the TODO's were but this is of relatively minor
> import, and I lagged long enough this is against 2.5.33-mm2:

Well the TODO was to worry about the (very) incorrect reporting of
mapping occupancy.  mmap(1G file), touch one byte of it (or none)
and the thing will report 1G?

We figured that per-vma rss accounting would be easy and would fix
it, then we remembered that vma's can be split into two, which
screwed that plan most royally.

Maybe when a VMA is split, we set the new VMA to have an rss of zero,
and keep on doing the accounting.  That way, the sum-of-vmas is
still correct even though the individual ones are wildly wrong??
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
