Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E486C6B0279
	for <linux-mm@kvack.org>; Sun,  2 Jul 2017 13:57:36 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b11so15862213wmh.0
        for <linux-mm@kvack.org>; Sun, 02 Jul 2017 10:57:36 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id v17si9916612wra.112.2017.07.02.10.57.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jul 2017 10:57:35 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id w126so149539078wme.0
        for <linux-mm@kvack.org>; Sun, 02 Jul 2017 10:57:35 -0700 (PDT)
Date: Sun, 2 Jul 2017 20:57:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v8 05/10] mm: thp: enable thp migration in generic path
Message-ID: <20170702175732.okngzb6y6gwxrpdo@node.shutemov.name>
References: <20170701134008.110579-1-zi.yan@sent.com>
 <20170701134008.110579-6-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170701134008.110579-6-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com, dave.hansen@intel.com, n-horiguchi@ah.jp.nec.com

On Sat, Jul 01, 2017 at 09:40:03AM -0400, Zi Yan wrote:
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1302,6 +1302,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	bool ret = true;
>  	enum ttu_flags flags = (enum ttu_flags)arg;
>  
> +
>  	/* munlock has nothing to gain from examining un-locked vmas */
>  	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
>  		return true;

With exception of this useless hunk, looks good to me

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
