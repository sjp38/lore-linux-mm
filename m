Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 474046B0258
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:32:10 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id 65so8813837pfd.2
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:32:10 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id km8si10918102pab.198.2016.01.27.10.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 10:32:09 -0800 (PST)
Date: Wed, 27 Jan 2016 19:32:05 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [LSF/MM ATTEND] 2016: Requests to attend MM-summit
Message-ID: <20160127183205.GY6357@twins.programming.kicks-ass.net>
References: <87k2n2usyf.fsf@linux.vnet.ibm.com>
 <20160122163801.GA16668@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160122163801.GA16668@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, Jan 22, 2016 at 11:38:01AM -0500, Johannes Weiner wrote:
> > 
> > Peter Zijlstra's VM_PINNED patch series should help in fixing the issue. I would
> > like to discuss what needs to be done to get this patch series merged upstream
> > https://lkml.org/lkml/2014/5/26/345 (VM_PINNED)
> > 
> > Others needed for the discussion:
> > Peter Zijlstra <peterz@infradead.org>
> 
> There was no consensus whether this specific implementation would work
> well for all sources of pinning. Giving this some time in the MM track
> could be useful.

I got stuck and lost in IB land. But that was a fair while ago. I should
probably look at rebasing it against something recent, although I
seriuosly doubt I can get through IB this time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
