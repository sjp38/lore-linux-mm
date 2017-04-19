Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C85F6B0390
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 02:21:41 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 18so1398073wrz.4
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 23:21:41 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k203si2465202wmk.63.2017.04.18.23.21.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 23:21:39 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3J6Efkn088807
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 02:21:38 -0400
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com [125.16.236.3])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29wqpu6avn-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 02:20:30 -0400
Received: from localhost
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 19 Apr 2017 11:50:26 +0530
Received: from d28av07.in.ibm.com (d28av07.in.ibm.com [9.184.220.146])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3J6KJdg18677780
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 11:50:19 +0530
Received: from d28av07.in.ibm.com (localhost [127.0.0.1])
	by d28av07.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3J6KObS006039
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 11:50:24 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC] mm/madvise: Enable (soft|hard) offline of HugeTLB pages at PGD level
In-Reply-To: <20170419032759.29700-1-khandual@linux.vnet.ibm.com>
References: <20170419032759.29700-1-khandual@linux.vnet.ibm.com>
Date: Wed, 19 Apr 2017 11:50:24 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <877f2ghqaf.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org

Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:

> Though migrating gigantic HugeTLB pages does not sound much like real
> world use case, they can be affected by memory errors. Hence migration
> at the PGD level HugeTLB pages should be supported just to enable soft
> and hard offline use cases.

In that case do we want to isolated the entire 16GB range ? Should we
just dequeue the page from hugepage pool convert them to regular 64K
pages and then isolate the 64K that had memory error ?

>
> While allocating the new gigantic HugeTLB page, it should not matter
> whether new page comes from the same node or not. There would be very
> few gigantic pages on the system afterall, we should not be bothered
> about node locality when trying to save a big page from crashing.
>
> This introduces a new HugeTLB allocator called alloc_gigantic_page()
> which will scan over all online nodes on the system and allocate a
> single HugeTLB page.
>


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
