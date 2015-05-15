Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id D57086B006E
	for <linux-mm@kvack.org>; Fri, 15 May 2015 03:44:21 -0400 (EDT)
Received: by wicnf17 with SMTP id nf17so126244648wic.1
        for <linux-mm@kvack.org>; Fri, 15 May 2015 00:44:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jy3si2314000wid.81.2015.05.15.00.44.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 15 May 2015 00:44:20 -0700 (PDT)
Message-ID: <5555A3D1.3010108@suse.cz>
Date: Fri, 15 May 2015 09:44:17 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 03/28] memcg: adjust to support new THP refcounting
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-4-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> As with rmap, with new refcounting we cannot rely on PageTransHuge() to
> check if we need to charge size of huge page form the cgroup. We need to
> get information from caller to know whether it was mapped with PMD or
> PTE.
>
> We do uncharge when last reference on the page gone. At that point if we
> see PageTransHuge() it means we need to unchange whole huge page.
>
> The tricky part is partial unmap -- when we try to unmap part of huge
> page. We don't do a special handing of this situation, meaning we don't
> uncharge the part of huge page unless last user is gone or
> split_huge_page() is triggered. In case of cgroup memory pressure
> happens the partial unmapped page will be split through shrinker. This
> should be good enough.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

But same question about whether it should be using hpage_nr_pages() 
instead of a constant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
