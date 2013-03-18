Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id AEEE66B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 14:53:58 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id j5so5592722iaf.14
        for <linux-mm@kvack.org>; Mon, 18 Mar 2013 11:53:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1363602068-11924-1-git-send-email-linfeng@cn.fujitsu.com>
References: <1363602068-11924-1-git-send-email-linfeng@cn.fujitsu.com>
Date: Mon, 18 Mar 2013 11:53:57 -0700
Message-ID: <CAE9FiQWuSL5Vq5VaAvQg_NT2gQJr17eMNoQbxtNJ8G3wweWNHQ@mail.gmail.com>
Subject: Re: [PATCH] x86: mm: accurate the comments for STEP_SIZE_SHIFT macro
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, penberg@kernel.org, jacob.shin@amd.com

On Mon, Mar 18, 2013 at 3:21 AM, Lin Feng <linfeng@cn.fujitsu.com> wrote:
> For x86 PUD_SHIFT is 30 and PMD_SHIFT is 21, so the consequence of
> (PUD_SHIFT-PMD_SHIFT)/2 is 4. Update the comments to the code.
>
> Cc: Yinghai Lu <yinghai@kernel.org>
> Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
> ---
>  arch/x86/mm/init.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
> index 59b7fc4..637a95b 100644
> --- a/arch/x86/mm/init.c
> +++ b/arch/x86/mm/init.c
> @@ -389,7 +389,7 @@ static unsigned long __init init_range_memory_mapping(
>         return mapped_ram_size;
>  }
>
> -/* (PUD_SHIFT-PMD_SHIFT)/2 */
> +/* (PUD_SHIFT-PMD_SHIFT)/2+1 */
>  #define STEP_SIZE_SHIFT 5
>  void __init init_mem_mapping(void)
>  {

9/2=4.5, so it becomes 5.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
