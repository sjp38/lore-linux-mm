Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id F22666B0258
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 08:39:43 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so94369360pad.1
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 05:39:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id df7si1525382pdb.67.2015.09.07.05.39.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 05:39:43 -0700 (PDT)
Date: Mon, 7 Sep 2015 14:36:57 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm/mmap.c: Remove useless statement "vma = NULL" in
	find_vma()
Message-ID: <20150907123656.GA32668@redhat.com>
References: <COL130-W64A6555222F8CEDA513171B9560@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <COL130-W64A6555222F8CEDA513171B9560@phx.gbl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <xili_gchen_5257@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

On 09/05, Chen Gang wrote:
>
> From b12fa5a9263cf4c044988e59f0071f4bcc132215 Mon Sep 17 00:00:00 2001
> From: Chen Gang <gang.chen.5i5j@gmail.com>
> Date: Sat, 5 Sep 2015 21:49:56 +0800
> Subject: [PATCH] mm/mmap.c: Remove useless statement "vma = NULL" in
>  find_vma()
>
> Before the main looping, vma is already is NULL, so need not set it to
> NULL, again.
>
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>

Reviewed-by: Oleg Nesterov <oleg@redhat.com>

> ---
>  mm/mmap.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/mm/mmap.c b/mm/mmap.c
> index df6d5f0..4db7cf0 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2054,7 +2054,6 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
>  		return vma;
>  
>  	rb_node = mm->mm_rb.rb_node;
> -	vma = NULL;
>  
>  	while (rb_node) {
>  		struct vm_area_struct *tmp;
> -- 
> 1.9.3
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
