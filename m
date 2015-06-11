Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 384966B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 08:30:27 -0400 (EDT)
Received: by wifx6 with SMTP id x6so8511411wif.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 05:30:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s9si1668837wia.28.2015.06.11.05.30.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 05:30:25 -0700 (PDT)
Message-ID: <55797F57.8040001@suse.cz>
Date: Thu, 11 Jun 2015 14:30:15 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv6 36/36] thp: update documentation
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com> <1433351167-125878-37-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1433351167-125878-37-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/03/2015 07:06 PM, Kirill A. Shutemov wrote:
> The patch updates Documentation/vm/transhuge.txt to reflect changes in
> THP design.

One thing I'm missing is info about the deferred splitting.

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>   Documentation/vm/transhuge.txt | 124 +++++++++++++++++++++++------------------
>   1 file changed, 69 insertions(+), 55 deletions(-)
>
> diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> index 6b31cfbe2a9a..2352b12cae93 100644
> --- a/Documentation/vm/transhuge.txt
> +++ b/Documentation/vm/transhuge.txt
> @@ -35,10 +35,10 @@ miss is going to run faster.
>
>   == Design ==
>
> -- "graceful fallback": mm components which don't have transparent
> -  hugepage knowledge fall back to breaking a transparent hugepage and
> -  working on the regular pages and their respective regular pmd/pte
> -  mappings
> +- "graceful fallback": mm components which don't have transparent hugepage
> +  knowledge fall back to breaking huge pmd mapping into table of ptes and,
> +  if nesessary, split a transparent hugepage. Therefore these components

         necessary
> +
> +split_huge_page uses migration entries to stabilize page->_count and
> +page->_mapcount.

Hm, what if there's some physical memory scanner taking page->_count 
pins? I think compaction shouldn't be an issue, but maybe some others?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
