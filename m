Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0E66B6B06C2
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 04:52:12 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id n10-v6so681664oib.5
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 01:52:12 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m50si2858181otc.34.2018.11.09.01.52.10
        for <linux-mm@kvack.org>;
        Fri, 09 Nov 2018 01:52:11 -0800 (PST)
Subject: Re: [RFC][PATCH v1 01/11] mm: hwpoison: cleanup unused PageHuge()
 check
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1541746035-13408-2-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <727d2a08-c44f-3d5a-244a-ed994ac7baf9@arm.com>
Date: Fri, 9 Nov 2018 15:22:05 +0530
MIME-Version: 1.0
In-Reply-To: <1541746035-13408-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, xishi.qiuxishi@alibaba-inc.com, Laurent Dufour <ldufour@linux.vnet.ibm.com>



On 11/09/2018 12:17 PM, Naoya Horiguchi wrote:
> memory_failure() forks to memory_failure_hugetlb() for hugetlb pages,
> so a PageHuge() check after the fork should not be necessary.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Pretty straightforward.

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
