Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 973D56B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 14:52:53 -0400 (EDT)
Received: by mail-ia0-f172.google.com with SMTP id l29so5635989iag.3
        for <linux-mm@kvack.org>; Mon, 18 Mar 2013 11:52:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1363602093-11965-1-git-send-email-linfeng@cn.fujitsu.com>
References: <1363602093-11965-1-git-send-email-linfeng@cn.fujitsu.com>
Date: Mon, 18 Mar 2013 11:52:52 -0700
Message-ID: <CAE9FiQUHtM_Nuz4ak+HeNGV6a-HTtfMkxc+zBZuow47Vj70CKQ@mail.gmail.com>
Subject: Re: [PATCH] x86: mm: add_pfn_range_mapped: use meaningful index to
 teach clean_sort_range()
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, penberg@kernel.org, jacob.shin@amd.com

On Mon, Mar 18, 2013 at 3:21 AM, Lin Feng <linfeng@cn.fujitsu.com> wrote:
> Since add_range_with_merge() return the max none zero element of the array, it's
> suffice to use it to instruct clean_sort_range() to do the sort. Or the former
> assignment by add_range_with_merge() is nonsense because clean_sort_range()
> will produce a accurate number of the sorted array and it never depends on
> nr_pfn_mapped.
>
> Cc: Jacob Shin <jacob.shin@amd.com>
> Cc: Yinghai Lu <yinghai@kernel.org>
> Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
> ---
>  arch/x86/mm/init.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
> index 59b7fc4..55ae904 100644
> --- a/arch/x86/mm/init.c
> +++ b/arch/x86/mm/init.c
> @@ -310,7 +310,7 @@ static void add_pfn_range_mapped(unsigned long start_pfn, unsigned long end_pfn)
>  {
>         nr_pfn_mapped = add_range_with_merge(pfn_mapped, E820_X_MAX,
>                                              nr_pfn_mapped, start_pfn, end_pfn);
> -       nr_pfn_mapped = clean_sort_range(pfn_mapped, E820_X_MAX);
> +       nr_pfn_mapped = clean_sort_range(pfn_mapped, nr_pfn_mapped);
>
>         max_pfn_mapped = max(max_pfn_mapped, end_pfn);>

Acked-by: Yinghai Lu <yinghai@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
