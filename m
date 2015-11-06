Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 85CEE82F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 10:24:36 -0500 (EST)
Received: by wicfv8 with SMTP id fv8so30910469wic.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 07:24:36 -0800 (PST)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id bm2si752772wjc.190.2015.11.06.07.24.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 07:24:35 -0800 (PST)
Received: by wmec201 with SMTP id c201so20959256wme.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 07:24:35 -0800 (PST)
Date: Fri, 6 Nov 2015 17:24:33 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: add page_check_address_transhuge helper
Message-ID: <20151106152433.GA23298@node.shutemov.name>
References: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1446564375-72143-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20151105091013.GC29259@esperanza>
 <20151105092459.GC7614@node.shutemov.name>
 <20151105120726.GD29259@esperanza>
 <20151105123606.GE7614@node.shutemov.name>
 <20151105125354.GE29259@esperanza>
 <20151105125838.GF7614@node.shutemov.name>
 <20151106143707.GL29259@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151106143707.GL29259@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Nov 06, 2015 at 05:37:07PM +0300, Vladimir Davydov wrote:
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 0837487d3737..7ac775e41820 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -796,48 +796,43 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
>  	return 1;
>  }
>  
> -struct page_referenced_arg {
> -	int mapcount;
> -	int referenced;
> -	unsigned long vm_flags;
> -	struct mem_cgroup *memcg;
> -};
>  /*
> - * arg: page_referenced_arg will be passed
> + * Check that @page is mapped at @address into @mm. In contrast to
> + * page_check_address(), this function can handle transparent huge pages.
> + *
> + * On success returns true with pte mapped and locked. For transparent huge
> + * pages *@ptep is set to NULL.

I think

	"For PMD-mapped transparent huge pages"...

would be more correct.

Otherwise looks great!

Reviewed-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
