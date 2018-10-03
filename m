Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 176536B0266
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 09:21:59 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c26-v6so3183330eda.7
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 06:21:59 -0700 (PDT)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id t21-v6si1012882ejf.152.2018.10.03.06.21.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 06:21:57 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 502EE1C1EFE
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 14:21:57 +0100 (IST)
Date: Wed, 3 Oct 2018 14:21:55 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/2] mm, numa: Migrate pages to local nodes quicker early
 in the lifetime of a task
Message-ID: <20181003132155.GD7003@techsingularity.net>
References: <20181001100525.29789-1-mgorman@techsingularity.net>
 <20181001100525.29789-3-mgorman@techsingularity.net>
 <20181002124149.GB4593@linux.vnet.ibm.com>
 <20181002135459.GA7003@techsingularity.net>
 <20181002173005.GD4593@linux.vnet.ibm.com>
 <20181003130741.GA4488@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181003130741.GA4488@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Jirka Hladky <jhladky@redhat.com>, Rik van Riel <riel@surriel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Oct 03, 2018 at 06:37:41PM +0530, Srikar Dronamraju wrote:
> * Srikar Dronamraju <srikar@linux.vnet.ibm.com> [2018-10-02 23:00:05]:
> 
> > I will try to get a DayTrader run in a day or two. There JVM and db threads
> > act on the same memory, I presume it might show some insights.
> 
> I ran 2 runs of daytrader 7 with and without patch on a 2 node power9
> PowerNv box.
> https://github.com/WASdev/sample.daytrader7
> In each run, has 8 JVMs.
> 
> Throughputs (Higher are better)
> Without patch 19216.8 18900.7 Average: 19058.75
> With patch    18644.5 18480.9 Average: 18562.70
> 
> Difference being -2.6% regression
> 

That's unfortunate.

How much does this workload normally vary between runs? If you monitor
migrations over time, is there an increase spike in migration early in
the lifetime of the workload?

-- 
Mel Gorman
SUSE Labs
