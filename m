Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A327B6B0078
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 04:23:23 -0500 (EST)
Date: Mon, 2 Nov 2009 10:23:16 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 04/11] Export __get_user_pages_fast.
Message-ID: <20091102092316.GC8933@elte.hu>
References: <1257076590-29559-1-git-send-email-gleb@redhat.com> <1257076590-29559-5-git-send-email-gleb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1257076590-29559-5-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Nick Piggin <npiggin@suse.de>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


* Gleb Natapov <gleb@redhat.com> wrote:

> 
> Signed-off-by: Gleb Natapov <gleb@redhat.com>
> ---
>  arch/x86/mm/gup.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
> index 71da1bc..cea0dfe 100644
> --- a/arch/x86/mm/gup.c
> +++ b/arch/x86/mm/gup.c
> @@ -8,6 +8,7 @@
>  #include <linux/mm.h>
>  #include <linux/vmstat.h>
>  #include <linux/highmem.h>
> +#include <linux/module.h>
>  
>  #include <asm/pgtable.h>
>  
> @@ -274,6 +275,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  
>  	return nr;
>  }
> +EXPORT_SYMBOL_GPL(__get_user_pages_fast);

Lack of explanation in the changelog and lack of Cc:s. I fixed the 
latter.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
