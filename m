Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 36D5A6B006C
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 13:49:33 -0500 (EST)
Received: by qgdz107 with SMTP id z107so1209311qgd.4
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 10:49:33 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id 107si4061436qgp.63.2015.03.04.10.49.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 04 Mar 2015 10:49:32 -0800 (PST)
Date: Wed, 4 Mar 2015 12:49:31 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCHv4 13/24] mm, vmstats: new THP splitting event
In-Reply-To: <1425486792-93161-14-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.11.1503041249150.23719@gentwo.org>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com> <1425486792-93161-14-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 4 Mar 2015, Kirill A. Shutemov wrote:

> The patch replaces THP_SPLIT with tree events: THP_SPLIT_PAGE,
> THP_SPLIT_PAGE_FAILT and THP_SPLIT_PMD. It reflects the fact that we
> now can split PMD without the compound page and that split_huge_page()
> can fail.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
