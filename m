Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 451106B0292
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 08:17:34 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p37so57278wrc.5
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 05:17:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y192si34488wmc.9.2017.09.01.05.17.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Sep 2017 05:17:32 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v81CA987053403
	for <linux-mm@kvack.org>; Fri, 1 Sep 2017 08:17:31 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2cq6g8vg5s-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 01 Sep 2017 08:17:31 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 1 Sep 2017 22:17:28 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v81CHQgm31326318
	for <linux-mm@kvack.org>; Fri, 1 Sep 2017 22:17:26 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v81CHIEo009466
	for <linux-mm@kvack.org>; Fri, 1 Sep 2017 22:17:18 +1000
Subject: Re: [PATCH] mm/mempolicy: Move VMA address bound checks inside
 mpol_misplaced()
References: <20170901070228.19954-1-khandual@linux.vnet.ibm.com>
 <268bbc32-7c1a-cdb8-039a-f1ea5d75b009@suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 1 Sep 2017 17:47:22 +0530
MIME-Version: 1.0
In-Reply-To: <268bbc32-7c1a-cdb8-039a-f1ea5d75b009@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <8e40fafd-dcee-9baa-738e-1a870ee54b41@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org

On 09/01/2017 02:35 PM, Vlastimil Babka wrote:
> On 09/01/2017 09:02 AM, Anshuman Khandual wrote:
>> The VMA address bound checks are applicable to all memory policy modes,
>> not just MPOL_INTERLEAVE.
> 
> But only MPOL_INTERLEAVE actually uses addr and vma->vm_start.

I thought them to be just general sanity checks.

> 
>> Hence move it to the front and make it common.
>>
>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> 
> I would just remove them instead. Together with the BUG_ON(!vma). Looks
> like just leftover from development.

sure, resend with suggested changes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
