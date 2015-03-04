Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9656B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 00:54:40 -0500 (EST)
Received: by iecar1 with SMTP id ar1so64783402iec.0
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 21:54:40 -0800 (PST)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id l10si3799251igx.55.2015.03.03.21.54.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Mar 2015 21:54:40 -0800 (PST)
Received: by igdh15 with SMTP id h15so34139995igd.4
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 21:54:40 -0800 (PST)
Date: Tue, 3 Mar 2015 21:54:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: fix anon_vma->degree underflow in anon_vma endless
 growing prevention
In-Reply-To: <20150303133642.GC2409@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1503032153510.12253@chino.kir.corp.google.com>
References: <1425384142-5064-1-git-send-email-chianglungyu@gmail.com> <20150303133642.GC2409@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Leon Yu <chianglungyu@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Tue, 3 Mar 2015, Michal Hocko wrote:

> I think we can safely remove the following code as well, because it is
> anon_vma_clone which is responsible to do all the cleanups.
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 943c6ad18b1d..06a6076c92e5 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -774,10 +774,8 @@ again:			remove_next = 1 + (end > next->vm_end);
>  
>  			importer->anon_vma = exporter->anon_vma;
>  			error = anon_vma_clone(importer, exporter);
> -			if (error) {
> -				importer->anon_vma = NULL;
> +			if (error)
>  				return error;
> -			}
>  		}
>  	}
>  

When Michal proposes this on top of -mm, feel free to add my

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
