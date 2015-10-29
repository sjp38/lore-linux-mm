Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9DAB082F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 04:25:22 -0400 (EDT)
Received: by pasz6 with SMTP id z6so34097975pas.2
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 01:25:22 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id qg3si812610pbb.100.2015.10.29.01.25.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 29 Oct 2015 01:25:21 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCHv12 26/37] mm: rework mapcount accounting to enable 4k
 mapping of THPs
Date: Thu, 29 Oct 2015 08:19:25 +0000
Message-ID: <20151029081924.GA12189@hori1.linux.bs1.fc.nec.co.jp>
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1444145044-72349-27-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1444145044-72349-27-git-send-email-kirill.shutemov@linux.intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <E8A2BB0EA3864044A1285E9E69DDEC6D@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Oct 06, 2015 at 06:23:53PM +0300, Kirill A. Shutemov wrote:
...
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 0268013cce63..45fadab47c53 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -165,7 +165,7 @@ static int remove_migration_pte(struct page *new, str=
uct vm_area_struct *vma,
>  		if (PageAnon(new))
>  			hugepage_add_anon_rmap(new, vma, addr);
>  		else
> -			page_dup_rmap(new);
> +			page_dup_rmap(new, false);

This is for hugetlb page, so the second argument should be true, right?

Thanks,
Naoya Horiguchi

>  	} else if (PageAnon(new))
>  		page_add_anon_rmap(new, vma, addr, false);
>  	else=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
