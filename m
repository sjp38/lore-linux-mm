Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id D4406828E6
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 14:37:14 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id wy7so46762900lbb.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 11:37:14 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id f78si11355wmd.95.2016.06.13.11.37.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 11:37:13 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id k184so16885681wme.2
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 11:37:13 -0700 (PDT)
Date: Mon, 13 Jun 2016 21:37:07 +0300
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: [RFC PATCH 3/3] doc: add information about min_ptes_young
Message-ID: <20160613183707.GD3815@debian>
References: <1465672561-29608-1-git-send-email-ebru.akagunduz@gmail.com>
 <1465672561-29608-4-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465672561-29608-4-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, minchan@kernel.org

On Sat, Jun 11, 2016 at 10:16:01PM +0300, Ebru Akagunduz wrote:
> min_ptes_young specifies at least how many young pages needed
> to create a THP. This threshold also effects when making swapin
> readahead (if needed) to create a THP. We decide whether to make
> swapin readahed wortwhile looking the value.
> 
> /sys/kernel/mm/transparent_hugepage/khugepaged/min_ptes_young
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Suggested-by: Minchan Kim <minchan@kernel.org> 
> ---
Cc'ed Minchan Kim.
>  Documentation/vm/transhuge.txt | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> index 2ec6adb..0ae713b 100644
> --- a/Documentation/vm/transhuge.txt
> +++ b/Documentation/vm/transhuge.txt
> @@ -193,6 +193,13 @@ memory. A lower value can prevent THPs from being
>  collapsed, resulting fewer pages being collapsed into
>  THPs, and lower memory access performance.
>  
> +min_ptes_young specifies at least how many young pages needed
> +to create a THP. This threshold also effects when making swapin
> +readahead (if needed) to create a THP. We decide whether to make
> +swapin readahed wortwhile looking the value.
> +
> +/sys/kernel/mm/transparent_hugepage/khugepaged/min_ptes_young
> +
>  == Boot parameter ==
>  
>  You can change the sysfs boot time defaults of Transparent Hugepage
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
