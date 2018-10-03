Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4DE1C6B0008
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 09:07:51 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id v4-v6so3574883oix.2
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 06:07:51 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q124-v6si669843oih.209.2018.10.03.06.07.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 06:07:50 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w93Cx11a130744
	for <linux-mm@kvack.org>; Wed, 3 Oct 2018 09:07:49 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mvwvm1dgb-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 03 Oct 2018 09:07:49 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 3 Oct 2018 14:07:47 +0100
Date: Wed, 3 Oct 2018 18:37:41 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] mm, numa: Migrate pages to local nodes quicker early
 in the lifetime of a task
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20181001100525.29789-1-mgorman@techsingularity.net>
 <20181001100525.29789-3-mgorman@techsingularity.net>
 <20181002124149.GB4593@linux.vnet.ibm.com>
 <20181002135459.GA7003@techsingularity.net>
 <20181002173005.GD4593@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20181002173005.GD4593@linux.vnet.ibm.com>
Message-Id: <20181003130741.GA4488@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Jirka Hladky <jhladky@redhat.com>, Rik van Riel <riel@surriel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

* Srikar Dronamraju <srikar@linux.vnet.ibm.com> [2018-10-02 23:00:05]:

> I will try to get a DayTrader run in a day or two. There JVM and db threads
> act on the same memory, I presume it might show some insights.

I ran 2 runs of daytrader 7 with and without patch on a 2 node power9
PowerNv box.
https://github.com/WASdev/sample.daytrader7
In each run, has 8 JVMs.

Throughputs (Higher are better)
Without patch 19216.8 18900.7 Average: 19058.75
With patch    18644.5 18480.9 Average: 18562.70

Difference being -2.6% regression

-- 
Thanks and Regards
Srikar Dronamraju
