Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id AE2726B0038
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 09:59:44 -0400 (EDT)
Received: by wgme6 with SMTP id e6so14229273wgm.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 06:59:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s9si3353577wia.28.2015.06.09.06.59.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 06:59:43 -0700 (PDT)
Message-ID: <5576F14C.8080303@suse.cz>
Date: Tue, 09 Jun 2015 15:59:40 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv6 13/36] mm: drop tail page refcounting
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com> <1433351167-125878-14-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1433351167-125878-14-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/03/2015 07:05 PM, Kirill A. Shutemov wrote:
> Tail page refcounting is utterly complicated and painful to support.
>
> It uses ->_mapcount on tail pages to store how many times this page is
> pinned. get_page() bumps ->_mapcount on tail page in addition to
> ->_count on head. This information is required by split_huge_page() to
> be able to distribute pins from head of compound page to tails during
> the split.
>
> We will need ->_mapcount acoount PTE mappings of subpages of the

                            to account

> compound page. We eliminate need in current meaning of ->_mapcount in
> tail pages by forbidding split entirely if the page is pinned.
>
> The only user of tail page refcounting is THP which is marked BROKEN for
> now.
>
> Let's drop all this mess. It makes get_page() and put_page() much
> simpler.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
