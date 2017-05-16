Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 317416B02EE
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:29:02 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id x64so132026883pgd.6
        for <linux-mm@kvack.org>; Tue, 16 May 2017 03:29:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t66si13192690pfj.352.2017.05.16.03.29.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 03:29:00 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4GASx83003337
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:29:00 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2afv7bj7rc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:29:00 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 16 May 2017 20:28:52 +1000
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v4GASfHS63766756
	for <linux-mm@kvack.org>; Tue, 16 May 2017 20:28:49 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v4GASHRG004274
	for <linux-mm@kvack.org>; Tue, 16 May 2017 20:28:17 +1000
Subject: Re: [PATCH v2 2/2] powerpc/mm/hugetlb: Add support for 1G huge pages
References: <1494926264-22463-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1494926264-22463-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 16 May 2017 15:57:56 +0530
MIME-Version: 1.0
In-Reply-To: <1494926264-22463-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <04189f80-57fd-b921-20b9-565e1b307270@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, mpe@ellerman.id.au, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On 05/16/2017 02:47 PM, Aneesh Kumar K.V wrote:
> POWER9 supports hugepages of size 2M and 1G in radix MMU mode. This patch
> enables the usage of 1G page size for hugetlbfs. This also update the helper
> such we can do 1G page allocation at runtime.
> 
> We still don't enable 1G page size on DD1 version. This is to avoid doing
> workaround mentioned in commit: 6d3a0379ebdc8 (powerpc/mm: Add
> radix__tlb_flush_pte_p9_dd1()
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Sounds good.

Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
