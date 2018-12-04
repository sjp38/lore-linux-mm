Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC5C6B6EE9
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 08:29:59 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id w2so8331638edc.13
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 05:29:59 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k1si4151788eda.363.2018.12.04.05.29.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 05:29:58 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB4DOvMo013692
	for <linux-mm@kvack.org>; Tue, 4 Dec 2018 08:29:56 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2p5t3asjbb-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Dec 2018 08:29:56 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 4 Dec 2018 13:29:54 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH V2 4/5] mm/hugetlb: Add prot_modify_start/commit sequence for hugetlb update
In-Reply-To: <d7ee1b8c-2f45-f430-b413-9d511e7d78c4@linux.ibm.com>
References: <20181128143438.29458-1-aneesh.kumar@linux.ibm.com> <20181128143438.29458-5-aneesh.kumar@linux.ibm.com> <20181128141051.ff38f23023f652759b06f828@linux-foundation.org> <d7ee1b8c-2f45-f430-b413-9d511e7d78c4@linux.ibm.com>
Date: Tue, 04 Dec 2018 18:59:43 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87va495sjc.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:

> On 11/29/18 3:40 AM, Andrew Morton wrote:
>> On Wed, 28 Nov 2018 20:04:37 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:
>> 
>>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>> 
>> Some explanation of the motivation would be useful.
>
> I will update the commit message.
>

Is this good?

    mm/hugetlb: Add prot_modify_start/commit sequence for hugetlb update
    
    Architectures like ppc64 requires to do a conditional tlb flush based on the old
    and new value of pte. Follow the regular pte change protection sequence for
    hugetlb too. This allow the architectures to override the update sequence.

-aneesh
