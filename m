Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 10C558E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 06:50:50 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id w185so5995260qka.9
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 03:50:50 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r30si4961465qtd.209.2019.01.09.03.50.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 03:50:49 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x09BnWqO170039
	for <linux-mm@kvack.org>; Wed, 9 Jan 2019 06:50:48 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2pwejsw0ax-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 09 Jan 2019 06:50:48 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 9 Jan 2019 11:50:46 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [Bug 202149] New: NULL Pointer Dereference in __split_huge_pmd on PPC64LE
In-Reply-To: <ed4bea40-cf9e-89a1-f99a-3dbd6249847f@bluematt.me>
References: <bug-202149-27@https.bugzilla.kernel.org/> <20190104170459.c8c7fa57ba9bc8a69dee5666@linux-foundation.org> <87ef9nk4cj.fsf@linux.ibm.com> <ed4bea40-cf9e-89a1-f99a-3dbd6249847f@bluematt.me>
Date: Wed, 09 Jan 2019 17:20:40 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <8736q2jbhr.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Corallo <kernel@bluematt.me>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org
Cc: bugzilla-daemon@bugzilla.kernel.org

Matt Corallo <kernel@bluematt.me> writes:

> .config follows. I have not tested with 64K pages as, sadly, I have a 
> large BTRFS volume that was formatted on x86, and am thus stuck with 4K 
> pages. Note that this is roughly the Debian kernel, so it has whatever 
> patches Debian defaults to applying, a list of which follows.
>

What is the test you are running? I tried a 4K page size config on P9. I
am running ltp test suite there. Also tried few thp memremap tests.
Nothing hit that.

root@:~/tests/ltp/testcases/kernel/mem/thp# getconf  PAGESIZE
4096
root@ltc-boston123:~/tests/ltp/testcases/kernel/mem/thp# grep thp /proc/vmstat 
thp_fault_alloc 641141
thp_fault_fallback 0
thp_collapse_alloc 90
thp_collapse_alloc_failed 0
thp_file_alloc 0
thp_file_mapped 0
thp_split_page 1
thp_split_page_failed 0
thp_deferred_split_page 641150
thp_split_pmd 24
thp_zero_page_alloc 1
thp_zero_page_alloc_failed 0
thp_swpout 0
thp_swpout_fallback 0
root@:~/tests/ltp/testcases/kernel/mem/thp# 

-aneesh
