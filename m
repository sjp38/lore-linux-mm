Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7AB8D6B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 22:50:53 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id v184so4499384itc.15
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 19:50:53 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u6si953743wmu.2.2017.06.14.19.50.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 19:50:52 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5F2nPbe023942
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 22:50:51 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2b39wpa2u0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 22:50:51 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 14 Jun 2017 20:50:50 -0600
Subject: Re: [HELP-NEEDED, PATCH 0/3] Do not loose dirty bit on THP pages
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
References: <20170614135143.25068-1-kirill.shutemov@linux.intel.com>
 <eed279c6-bf61-f2f3-c9f2-d9a94568e2e3@linux.vnet.ibm.com>
 <20170614165513.GD17632@arm.com>
 <548e33cb-e737-bb39-91a3-f66ee9211262@linux.vnet.ibm.com>
Date: Thu, 15 Jun 2017 08:20:32 +0530
MIME-Version: 1.0
In-Reply-To: <548e33cb-e737-bb39-91a3-f66ee9211262@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <95a2756a-dd56-e042-95ed-90f4078e0380@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com



On Thursday 15 June 2017 06:35 AM, Aneesh Kumar K.V wrote:
> 

> W.r.t pmdp_invalidate() usage, I was wondering whether we can do that 
> early in __split_huge_pmd_locked().
> 


BTW by moving  pmdp_invalidate early, we can then get rid of

	pmdp_huge_split_prepare(vma, haddr, pmd);


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
