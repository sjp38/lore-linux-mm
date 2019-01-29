Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C256C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 10:43:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4FFC72148E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 10:43:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FFC72148E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF2478E0003; Tue, 29 Jan 2019 05:43:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA13E8E0001; Tue, 29 Jan 2019 05:43:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C91E78E0003; Tue, 29 Jan 2019 05:43:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A96C8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 05:43:58 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 82so16553681pfs.20
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 02:43:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=6tw/Spgorzr+z46ez+p1qLoKZbkKiDIsWtkcQMgZTCU=;
        b=s9Xg6RYaXFBOPSfudHPMyKqkFJxWSIANxihe55QCmteWkH45sFhL2x2sFxcCaLzVpP
         g7tM511F9Db5DKfOtcb+pgcZMOyR0gYZV5AVmAkdtSj/90OlTxSpXnW/0qjSsYcPOPQ6
         ar+PSPXc3zB/pDlU9UdKvMD7dzgr9f6B9NBlpVxPL6IRtN8TGQVZYeFBlcWHVCWCpzWu
         G5GdyT34oFW5pe4wIOW97hLPnaRW7umVWODzE9CJsGv93XI1h95Rlhqp27sjuUX6DGS2
         p/Br2uKW2RI2g0NH8UMfae8cR0COaEYBt4iYPHpVIVqzS9JG0jf18o7IJ+jEpik+TL0j
         Ww1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukcuo/ES0vifM9JAIpPRZS/D+0YvkbWIvAaxE8xHG3zPZPG+EFnX
	rpGUQdFKGqR3q+zZeqT9x3hcxodB4bfO6CCzuJjcZoTT5z7qxoGpHPs1/1DXIKqjOV+oGYX1+NT
	Yqzy2sl22+naxbWBlvKhflKEj59UWF6XQ7YUwa40rgXz9DcdDbC5KQgozmmvR2uUQEw==
X-Received: by 2002:a62:5797:: with SMTP id i23mr12960287pfj.162.1548758638260;
        Tue, 29 Jan 2019 02:43:58 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4sgJOQvIgDIyp/0FedR4vSZghrTOyo1FtTbX5/Y4JyLCdItBczGh3NkJ17B0/WGLeJCxBd
X-Received: by 2002:a62:5797:: with SMTP id i23mr12960245pfj.162.1548758637459;
        Tue, 29 Jan 2019 02:43:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548758637; cv=none;
        d=google.com; s=arc-20160816;
        b=PJyN5z6ldkagnOEXxx9kamBFaCRLF4Y/WLctmiu2csuoMLA0d4CiSwzIikJW2mKzF1
         zs8xDF73ShBtO1GlKmXZpY17INsFmDslxzyr0dsS4lLBbapwZuUx8HMMR9jfNF71MXKR
         86ExMVihLRrH0u6/Fj/7SXC1efWQfSCOy2+pka3q2hcsS5tyQ9OObGMy3lUDMEHgMNKN
         wNBhRa6rMR27KO3+BBycqIWiEhuUs8wA1mCjJPdqbHWJ5zbn6+adZTgAIsd92yAMyxnJ
         j8QfY/beYN6sWCSiObMafNAPL7x2EbHxOpZdZNG5F10FjhlKHfKNKWSXaMRmS1WjxbXr
         w/ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=6tw/Spgorzr+z46ez+p1qLoKZbkKiDIsWtkcQMgZTCU=;
        b=Sl73HLtTtEGX3Q3419Qmj2ULPjLkkw2wMagwIvxxwoIYLh8vt/u5bHviv8Xy7pkzLS
         3wY6BkrhjvBP+/lbNeLIEyYeFHY+MhcpIDZOl2VLdYOujLJsvCdZc13GwVyldV1R415F
         aZM21Fq0C+s1Mqo8FajqBPawECywV5Zr9FFQfTQlTSxa4XqcAtPxGJa8LkeGJZQ3kwLX
         x/ytmJgF5Le48XjlVu9ICgkzkTGsvPnpgXcbFsdhZl51c+kj7G9DCyYmvEth3sksFjkR
         ihO6NJ8MqFE2Jub9tArqupxleycpysLKhxcnp0TZ78VkRXBIrJzt3qn1EUlLmdFPT2i8
         GD9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u22si4004730pgk.335.2019.01.29.02.43.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 02:43:57 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0TAdhvr100062
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 05:43:56 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qambubnt9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 05:43:56 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 29 Jan 2019 10:43:54 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 29 Jan 2019 10:43:50 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0TAhnFc56950932
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 29 Jan 2019 10:43:49 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5373F11C04A;
	Tue, 29 Jan 2019 10:43:49 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3D1C511C05B;
	Tue, 29 Jan 2019 10:43:47 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.85.71.101])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 29 Jan 2019 10:43:47 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org,
        mpe@ellerman.id.au, akpm@linux-foundation.org, x86@kernel.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org
Subject: Re: [PATCH V5 0/5] NestMMU pte upgrade workaround for mprotect
In-Reply-To: <20190116085035.29729-1-aneesh.kumar@linux.ibm.com>
References: <20190116085035.29729-1-aneesh.kumar@linux.ibm.com>
Date: Tue, 29 Jan 2019 16:13:45 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19012910-0020-0000-0000-0000030D407E
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19012910-0021-0000-0000-0000215E4385
Message-Id: <87va27agm6.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-29_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=519 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901290082
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Andrew,

How do you want to merge this? Michael Ellerman suggests this should go
via -mm tree.

-aneesh


"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:

> We can upgrade pte access (R -> RW transition) via mprotect. We need
> to make sure we follow the recommended pte update sequence as outlined in
> commit bd5050e38aec ("powerpc/mm/radix: Change pte relax sequence to handle nest MMU hang")
> for such updates. This patch series do that.
>
> Changes from V4:
> * Drop EXPORT_SYMBOL 
>
> Changes from V3:
> * Build fix for x86
>
> Changes from V2:
> * Update commit message for patch 4
> * use radix tlb flush routines directly.
>
> Changes from V1:
> * Restrict ths only for R->RW upgrade. We don't need to do this for Autonuma
> * Restrict this only for radix translation mode.
>
>
> Aneesh Kumar K.V (5):
>   mm: Update ptep_modify_prot_start/commit to take vm_area_struct as arg
>   mm: update ptep_modify_prot_commit to take old pte value as arg
>   arch/powerpc/mm: Nest MMU workaround for mprotect RW upgrade.
>   mm/hugetlb: Add prot_modify_start/commit sequence for hugetlb update
>   arch/powerpc/mm/hugetlb: NestMMU workaround for hugetlb mprotect RW
>     upgrade
>
>  arch/powerpc/include/asm/book3s/64/hugetlb.h | 12 ++++++++++
>  arch/powerpc/include/asm/book3s/64/pgtable.h | 18 ++++++++++++++
>  arch/powerpc/include/asm/book3s/64/radix.h   |  4 ++++
>  arch/powerpc/mm/hugetlbpage-hash64.c         | 25 ++++++++++++++++++++
>  arch/powerpc/mm/hugetlbpage-radix.c          | 17 +++++++++++++
>  arch/powerpc/mm/pgtable-book3s64.c           | 25 ++++++++++++++++++++
>  arch/powerpc/mm/pgtable-radix.c              | 18 ++++++++++++++
>  arch/s390/include/asm/pgtable.h              |  5 ++--
>  arch/s390/mm/pgtable.c                       |  8 ++++---
>  arch/x86/include/asm/paravirt.h              | 13 +++++-----
>  arch/x86/include/asm/paravirt_types.h        |  5 ++--
>  arch/x86/xen/mmu.h                           |  4 ++--
>  arch/x86/xen/mmu_pv.c                        |  8 +++----
>  fs/proc/task_mmu.c                           |  8 ++++---
>  include/asm-generic/pgtable.h                | 18 +++++++-------
>  include/linux/hugetlb.h                      | 20 ++++++++++++++++
>  mm/hugetlb.c                                 |  8 ++++---
>  mm/memory.c                                  |  8 +++----
>  mm/mprotect.c                                |  6 ++---
>  19 files changed, 189 insertions(+), 41 deletions(-)
>
> -- 
> 2.20.1

