Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7F7EA440325
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 12:27:35 -0400 (EDT)
Received: by iofh134 with SMTP id h134so191882459iof.0
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 09:27:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a20si927897igm.90.2015.10.05.09.27.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Oct 2015 09:27:34 -0700 (PDT)
Date: Mon, 5 Oct 2015 18:24:16 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm/mmap.c: Remove redundant statement "error = -ENOMEM"
Message-ID: <20151005162416.GA19857@redhat.com>
References: <COL130-W55A6DE834A523637B79293B9480@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <COL130-W55A6DE834A523637B79293B9480@phx.gbl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <xili_gchen_5257@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "emunson@akamai.com" <emunson@akamai.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

On 10/05, Chen Gang wrote:
>
> It is still a little better to remove it, although it should be skipped
> by "-O2".

Agreed, it can confuse the reader.

> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>

Acked-by: Oleg Nesterov <oleg@redhat.com>

> ---
>  mm/mmap.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 8393580..1da4600 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1562,7 +1562,6 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>  	}
>  
>  	/* Clear old maps */
> -	error = -ENOMEM;
>  	while (find_vma_links(mm, addr, addr + len, &prev, &rb_link,
>  			      &rb_parent)) {
>  		if (do_munmap(mm, addr, len))
> -- 
> 1.9.3
> 
>  		 	   		  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
