Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0876B06D0
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 05:20:47 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id h1so818216oti.6
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 02:20:47 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t26-v6si3001681oij.160.2018.11.09.02.20.46
        for <linux-mm@kvack.org>;
        Fri, 09 Nov 2018 02:20:46 -0800 (PST)
Subject: Re: [RFC][PATCH v1 02/11] mm: soft-offline: add missing error check
 of set_hwpoison_free_buddy_page()
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1541746035-13408-3-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <9ea93154-4843-231d-d72b-bf12c8807c24@arm.com>
Date: Fri, 9 Nov 2018 15:50:41 +0530
MIME-Version: 1.0
In-Reply-To: <1541746035-13408-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, xishi.qiuxishi@alibaba-inc.com, Laurent Dufour <ldufour@linux.vnet.ibm.com>



On 11/09/2018 12:17 PM, Naoya Horiguchi wrote:
> set_hwpoison_free_buddy_page() could fail, then the target page is
> finally not isolated, so it's better to report -EBUSY for userspace
> to know the failure and chance of retry.
> 

IIUC set_hwpoison_free_buddy_page() could only fail if the page is not
free in the buddy. At least for soft_offline_huge_page() that wont be
the case otherwise dissolve_free_huge_page() would have returned non
zero -EBUSY. Is there any other reason set_hwpoison_free_buddy_page()
would not succeed ?

> And for consistency, this patch moves set_hwpoison_free_buddy_page()
> in unmap_and_move() to __soft_offline_page().

Yeah this check should be handled in soft offline functions not inside
migrations they trigger.
