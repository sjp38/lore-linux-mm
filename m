Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m144WGK6004945
	for <linux-mm@kvack.org>; Mon, 4 Feb 2008 15:32:16 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m144aOWq267632
	for <linux-mm@kvack.org>; Mon, 4 Feb 2008 15:36:24 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m144Wl99001130
	for <linux-mm@kvack.org>; Mon, 4 Feb 2008 15:32:47 +1100
Message-ID: <47A6951E.3000600@linux.vnet.ibm.com>
Date: Mon, 04 Feb 2008 10:01:26 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: 2.6.24-mm1 Build Faliure on pgtable_32.c
References: <20080203171634.58ab668b.akpm@linux-foundation.org> <20080204035543.GA8186@linux.vnet.ibm.com>
In-Reply-To: <20080204035543.GA8186@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Kamalesh Babulal wrote:
> Hi Andrew,
> 
> The 2.6.24-mm1 kernel build fails with 
> 
> arch/x86/mm/pgtable_32.c: In function `pgd_mop_up_pmds':
> arch/x86/mm/pgtable_32.c:302: warning: passing arg 1 of `pmd_free' from incompatible pointer type
> arch/x86/mm/pgtable_32.c:302: error: too few arguments to function `pmd_free'
> 
> I have tested the patch for the build failure only.
> 
> Signed-off-by: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>

Looks good to me, it seems like a conflict between origin.patch and
add-mm-argument-to-pte-pmd-pud-pgd_free.patch

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
