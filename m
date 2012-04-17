Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 996F86B0044
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 13:12:31 -0400 (EDT)
Received: by dakh32 with SMTP id h32so9245928dak.9
        for <linux-mm@kvack.org>; Tue, 17 Apr 2012 10:12:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120417155502.GE22687@tiehlicka.suse.cz>
References: <20120417155502.GE22687@tiehlicka.suse.cz>
Date: Tue, 17 Apr 2012 10:12:30 -0700
Message-ID: <CAE9FiQXWKzv7Wo4iWGrKapmxQYtAGezghwup1UKoW2ghqUSr+A@mail.gmail.com>
Subject: Re: Weirdness in __alloc_bootmem_node_high
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 17, 2012 at 8:55 AM, Michal Hocko <mhocko@suse.cz> wrote:
> Hi,
> I just come across the following condition in __alloc_bootmem_node_high
> which I have hard times to understand. I guess it is a bug and we need
> something like the following. But, to be honest, I have no idea why we
> care about those 128MB above MAX_DMA32_PFN.
> ---
> =A0mm/bootmem.c | =A0 =A02 +-
> =A01 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index 0131170..5adb072 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -737,7 +737,7 @@ void * __init __alloc_bootmem_node_high(pg_data_t *pg=
dat, unsigned long size,
> =A0 =A0 =A0 =A0/* update goal according ...MAX_DMA32_PFN */
> =A0 =A0 =A0 =A0end_pfn =3D pgdat->node_start_pfn + pgdat->node_spanned_pa=
ges;
>
> - =A0 =A0 =A0 if (end_pfn > MAX_DMA32_PFN + (128 >> (20 - PAGE_SHIFT)) &&
> + =A0 =A0 =A0 if (end_pfn > MAX_DMA32_PFN + (128 << (20 - PAGE_SHIFT)) &&
> =A0 =A0 =A0 =A0 =A0 =A0(goal >> PAGE_SHIFT) < MAX_DMA32_PFN) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void *ptr;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long new_goal;
> --

We are not using bootmem with x86 now, so could remove those workaround now=
.

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
