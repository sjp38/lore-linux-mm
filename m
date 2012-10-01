Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 15D726B0078
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 10:02:32 -0400 (EDT)
Date: Mon, 1 Oct 2012 17:03:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: thp: Set the accessed flag for old pages on access
 fault.
Message-ID: <20121001140305.GA20173@shutemov.name>
References: <1349099505-5581-1-git-send-email-will.deacon@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1349099505-5581-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, mhocko@suse.cz, Steve Capper <steve.capper@arm.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Metcalf <cmetcalf@tilera.com>

On Mon, Oct 01, 2012 at 02:51:45PM +0100, Will Deacon wrote:
> diff --git a/mm/memory.c b/mm/memory.c
> index 5736170..d5c007d 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3537,7 +3537,11 @@ retry:
>  				if (unlikely(ret & VM_FAULT_OOM))
>  					goto retry;
>  				return ret;
> +			} else {
> +				huge_pmd_set_accessed(mm, vma, address, pmd,
> +						      orig_pmd);

I think putting it to 'else' is wrong. You should not touch pmd, if it's
under splitting.

>  			}
> +
>  			return 0;
>  		}
>  	}

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
