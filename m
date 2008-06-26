Date: Thu, 26 Jun 2008 19:27:15 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 5/5] Convert anon_vma spinlock to rw semaphore
Message-ID: <20080626172715.GJ14329@duo.random>
References: <20080626003632.049547282@sgi.com> <20080626003833.966166360@sgi.com> <20080626010510.GC6938@duo.random> <Pine.LNX.4.64.0806261019440.7392@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806261019440.7392@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, apw@shadowen.org, Hugh Dickins <hugh@veritas.com>, holt@sgi.com, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, Jun 26, 2008 at 10:23:17AM -0700, Christoph Lameter wrote:
> On Thu, 26 Jun 2008, Andrea Arcangeli wrote:
> 
> > You dropped the benchmark numbers from the comment, that was useful
> > data. You may want to re-run the benchmark on different hardware just
> > to be sure it was valid though (just to be sure it's a significant
> > regression for AIM).
> 
> I could not reproduce it with the recent versions. The degradation was 
> less than expected.

That's very encouraging! That info plus the removal of the superflous
atomic ops in the fork fast path sounds quite reasonable. We need to
run this series over some extensive benchmark like the one that found
preemptive BLK was hurting performance a lot to be more certain.

Thanks for the info!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
