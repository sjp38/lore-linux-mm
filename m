Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00C7E6B0010
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 10:08:54 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id p14-v6so3729839oip.0
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 07:08:53 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v7-v6si698677oig.199.2018.10.03.07.08.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 07:08:53 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w93E6ERe079620
	for <linux-mm@kvack.org>; Wed, 3 Oct 2018 10:08:52 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mvwmfcvu8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 03 Oct 2018 10:08:51 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 3 Oct 2018 15:08:48 +0100
Date: Wed, 3 Oct 2018 19:38:41 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] mm, numa: Migrate pages to local nodes quicker early
 in the lifetime of a task
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20181001100525.29789-1-mgorman@techsingularity.net>
 <20181001100525.29789-3-mgorman@techsingularity.net>
 <20181002124149.GB4593@linux.vnet.ibm.com>
 <20181002135459.GA7003@techsingularity.net>
 <20181002173005.GD4593@linux.vnet.ibm.com>
 <20181003130741.GA4488@linux.vnet.ibm.com>
 <20181003132155.GD7003@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20181003132155.GD7003@techsingularity.net>
Message-Id: <20181003140841.GC4488@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Jirka Hladky <jhladky@redhat.com>, Rik van Riel <riel@surriel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

* Mel Gorman <mgorman@techsingularity.net> [2018-10-03 14:21:55]:

> On Wed, Oct 03, 2018 at 06:37:41PM +0530, Srikar Dronamraju wrote:
> > * Srikar Dronamraju <srikar@linux.vnet.ibm.com> [2018-10-02 23:00:05]:
> > 
> 

> That's unfortunate.
> 
> How much does this workload normally vary between runs? If you monitor
> migrations over time, is there an increase spike in migration early in
> the lifetime of the workload?
> 

The run to run variation has always been less than 1%.
I haven't monitored migrations over time. Will try to include it my next
run. Its a shared setup so I may not get the box immediately.


-- 
Thanks and Regards
Srikar Dronamraju
