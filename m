Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 2ECA36B02F1
	for <linux-mm@kvack.org>; Fri,  3 May 2013 14:58:28 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 4 May 2013 00:23:53 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id DA20AE004A
	for <linux-mm@kvack.org>; Sat,  4 May 2013 00:30:35 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r43IwHPL58392790
	for <linux-mm@kvack.org>; Sat, 4 May 2013 00:28:17 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r43IwLC8016576
	for <linux-mm@kvack.org>; Sat, 4 May 2013 04:58:21 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V7 04/10] powerpc: Update find_linux_pte_or_hugepte to handle transparent hugepages
In-Reply-To: <20130503045323.GP13041@truffula.fritz.box>
References: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1367178711-8232-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130503045323.GP13041@truffula.fritz.box>
Date: Sat, 04 May 2013 00:28:20 +0530
Message-ID: <87ip2z51rn.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <dwg@au1.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

David Gibson <dwg@au1.ibm.com> writes:

> On Mon, Apr 29, 2013 at 01:21:45AM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>
> What's the difference in meaning between pmd_huge() and pmd_large()?
>

#ifndef CONFIG_HUGETLB_PAGE
#define pmd_huge(x)	0
#endif

Also pmd_large do check for THP PTE flag, and _PAGE_PRESENT.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
