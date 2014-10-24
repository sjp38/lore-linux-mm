Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4ADCE6B006E
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 18:48:21 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id a1so2025991wgh.35
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 15:48:20 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.194])
        by mx.google.com with ESMTP id br6si6570005wjc.156.2014.10.24.15.48.19
        for <linux-mm@kvack.org>;
        Fri, 24 Oct 2014 15:48:19 -0700 (PDT)
Date: Sat, 25 Oct 2014 01:45:37 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 03/10] mm: convert i_mmap_mutex to rwsem
Message-ID: <20141024224537.GA21108@node.dhcp.inet.fi>
References: <1414188380-17376-1-git-send-email-dave@stgolabs.net>
 <1414188380-17376-4-git-send-email-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414188380-17376-4-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, hughd@google.com, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org

On Fri, Oct 24, 2014 at 03:06:13PM -0700, Davidlohr Bueso wrote:
> diff --git a/mm/fremap.c b/mm/fremap.c
> index 72b8fa3..11ef7ec 100644
> --- a/mm/fremap.c
> +++ b/mm/fremap.c
> @@ -238,13 +238,13 @@ get_write_lock:
>  			}
>  			goto out_freed;
>  		}
> -		mutex_lock(&mapping->i_mmap_mutex);
> +		i_mmap_lock_write(mapping);
>  		flush_dcache_mmap_lock(mapping);
>  		vma->vm_flags |= VM_NONLINEAR;
>  		vma_interval_tree_remove(vma, &mapping->i_mmap);
>  		vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
>  		flush_dcache_mmap_unlock(mapping);
> -		mutex_unlock(&mapping->i_mmap_mutex);
> +		i_mmap_unlock_write(mapping);
>  	}
>  
>  	if (vma->vm_flags & VM_LOCKED) {

This should go to previous patch.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
