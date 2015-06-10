Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 116136B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 09:13:57 -0400 (EDT)
Received: by wgez8 with SMTP id z8so35486793wge.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 06:13:56 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id y1si17977658wjw.91.2015.06.10.06.13.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 06:13:55 -0700 (PDT)
Date: Wed, 10 Jun 2015 15:13:54 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150610131354.GO19417@two.firstfloor.org>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
 <20150608174551.GA27558@gmail.com>
 <20150609084739.GQ26425@suse.de>
 <20150609103231.GA11026@gmail.com>
 <20150609112055.GS26425@suse.de>
 <20150609124328.GA23066@gmail.com>
 <5577078B.2000503@intel.com>
 <55771909.2020005@intel.com>
 <55775749.3090004@intel.com>
 <CA+55aFz6b5pG9tRNazk8ynTCXS3whzWJ_737dt1xxAHDf1jASQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFz6b5pG9tRNazk8ynTCXS3whzWJ_737dt1xxAHDf1jASQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Jun 09, 2015 at 02:54:01PM -0700, Linus Torvalds wrote:
> On Tue, Jun 9, 2015 at 2:14 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> >
> > The 0 cycle TLB miss was also interesting.  It goes back up to something
> > reasonable if I put the mb()/mfence's back.
> 
> So I've said it before, and I'll say it again: Intel does really well
> on TLB fills.

Assuming the page tables are cache-hot... And hot here does not mean
L3 cache, but higher. But a memory intensive workload can easily
violate that.

That's why I'm dubious of all these micro benchmarks. They won't be
clearing caches. They generate unrealistic conditions in the CPU
pipeline and overestimate the cost of the flushes.

The only good way to measure TLB costs is macro benchmarks.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
