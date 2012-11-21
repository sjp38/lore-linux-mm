Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 4855A6B0072
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 12:45:46 -0500 (EST)
Message-ID: <50AD1333.7070900@redhat.com>
Date: Wed, 21 Nov 2012 12:45:23 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
References: <1353291284-2998-1-git-send-email-mingo@kernel.org> <20121119162909.GL8218@suse.de> <alpine.DEB.2.00.1211191644340.24618@chino.kir.corp.google.com> <alpine.DEB.2.00.1211191703270.24618@chino.kir.corp.google.com> <20121120060014.GA14065@gmail.com> <alpine.DEB.2.00.1211192213420.5498@chino.kir.corp.google.com> <20121120074445.GA14539@gmail.com> <alpine.DEB.2.00.1211200001420.16449@chino.kir.corp.google.com> <20121120090637.GA14873@gmail.com> <CA+55aFyR9FsGYWSKkgsnZB7JhheDMjEQgbzb0gsqawSTpetPvA@mail.gmail.com>
In-Reply-To: <CA+55aFyR9FsGYWSKkgsnZB7JhheDMjEQgbzb0gsqawSTpetPvA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On 11/21/2012 12:02 PM, Linus Torvalds wrote:

> The same is true of all your arguments about Mel's numbers wrt THP
> etc. Your arguments are misleading - either intentionally, of because
> you yourself didn't think things through. For schednuma, it's not
> enough to be par with mainline with THP off - the competition
> (autonuma) has been beating mainline soundly in Mel's configuration.
> So the target to beat is not mainline, but the much *higher*
> performance that autonuma got.

Once the numa base patches are upstream, the bar will be raised
automatically.

With the same infrastructure in place, we will be able to do
an apples to apples comparison of the NUMA placement policies,
and figure out which one will be the best to merge.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
