Message-ID: <3D6EDDC0.F9ADC015@zip.com.au>
Date: Thu, 29 Aug 2002 19:51:44 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: statm_pgd_range() sucks!
References: <20020830015814.GN18114@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@surriel.com
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> Okay, I have *had it* with statm_pgd_range()!

It's certainly very bad.  A measurement tools shouldn't be perturbing
the system so much as to invalidate the results of other measurement
tools, and this one does.

I have several times had colleagues peering at kernel code wondering
why their application was spending so long in statm_pgd_range when
it really wasn't.

> ...
> (1) shared, lib, text, & total are now reported as what's mapped
>         instead of what's resident. This actually fixes two bugs:

hmm.  Personally, I've never believed, or even bothered to try to
understand what those columns are measuring.  Does anyone actually
find them useful for anything?  If so, what are they being used for?
What info do we really, actually want to know?

Reporting the size of the vma is really inaccurate for many situations, 
and the info which you're showing here can be generated from
/proc/pid/maps.  And it would be nice to get something useful out of this.

Would it be hard to add an `nr_pages' occupancy counter to vm_area_struct?
Go and add all those up?

BTW, Rohit's hugetlb patch touches proc_pid_statm(), so a diff on -mm3
would be appreciated.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
