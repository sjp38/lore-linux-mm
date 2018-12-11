Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9A68E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 00:50:18 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x15so6432973edd.2
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 21:50:18 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h88si1549189edc.299.2018.12.10.21.50.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 21:50:17 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBB5meeC027098
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 00:50:15 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2pa75s8cuw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 00:50:15 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 11 Dec 2018 05:50:14 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH 00/18] my generic mmu_gather patches
In-Reply-To: <20180926113623.863696043@infradead.org>
References: <20180926113623.863696043@infradead.org>
Date: Tue, 11 Dec 2018 11:20:01 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87woogsjcm.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, riel@surriel.com, fengguang.wu@intel.com

Peter Zijlstra <peterz@infradead.org> writes:

> Hi,
>
> Here is my current stash of generic mmu_gather patches that goes on top of Will's
> tlb patches:
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux.git tlb/asm-generic
>
> And they include the s390 patches done by Heiko. At the end of this, there is
> not a single arch left with a custom mmu_gather.
>
> I've been slow posting these, because the 0-day bot seems to be having trouble
> and I've not been getting the regular cross-build green light emails that I
> otherwise rely upon.
>
> I hope to have addressed all the feedback from the last time, and I've added a
> bunch of missing Cc's from last time.
>
> Please review with care.

What is the update with this patch series? Looks good to be merged
upstream?

You can also add

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>

to the series.

-aneesh
