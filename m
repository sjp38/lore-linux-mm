Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 744D2828DF
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 10:42:03 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id uo6so15566325pac.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 07:42:03 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id r138si10011718pfr.8.2016.02.03.07.42.02
        for <linux-mm@kvack.org>;
        Wed, 03 Feb 2016 07:42:02 -0800 (PST)
Subject: Re: [PATCH 4/4] thp: rewrite freeze_page()/unfreeze_page() with
 generic rmap walkers
References: <1454512459-94334-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1454512459-94334-5-git-send-email-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56B21FC9.9040009@intel.com>
Date: Wed, 3 Feb 2016 07:42:01 -0800
MIME-Version: 1.0
In-Reply-To: <1454512459-94334-5-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/03/2016 07:14 AM, Kirill A. Shutemov wrote:
> But the new variant is somewhat slower. Current helpers iterates over
> VMAs the compound page is mapped to, and then over ptes within this VMA.
> New helpers iterates over small page, then over VMA the small page
> mapped to, and only then find relevant pte.

The code simplification here is really attractive.  Can you quantify
what the slowdown is?  Is it noticeable, or would it be in the noise
during all the other stuff that happens under memory pressure?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
