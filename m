Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8E5816B0071
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 23:57:21 -0500 (EST)
Received: by iwn10 with SMTP id 10so881343iwn.14
        for <linux-mm@kvack.org>; Mon, 22 Nov 2010 20:57:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101122142109.2f3e168c.akpm@linux-foundation.org>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
	<5d205f8a4df078b0da3681063bbf37382b02dd23.1290349672.git.minchan.kim@gmail.com>
	<20101122142109.2f3e168c.akpm@linux-foundation.org>
Date: Tue, 23 Nov 2010 13:57:17 +0900
Message-ID: <AANLkTimm9KzAYBecikb4WqnRCo-Gw5eJdSD5dhX5ObYa@mail.gmail.com>
Subject: Re: [RFC 2/2] Prevent promotion of page in madvise_dontneed
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 23, 2010 at 7:21 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Sun, 21 Nov 2010 23:30:24 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Now zap_pte_range alwayas promotes pages which are pte_young &&
>> !VM_SequentialReadHint(vma). But in case of calling MADV_DONTNEED,
>> it's unnecessary since the page wouldn't use any more.
>>
>> If the page is sharred by other processes and it's real working set
>
> This patch doesn't actually do anything. =A0It passes variable `promote'
> all the way down to unmap_vmas(), but unmap_vmas() doesn't use that new
> variable.

Oops. Sorry for that.
I will resend the patch with your fixlet and Ben's point.
Thank you.

> Have a comment fixlet:
>
> --- a/mm/memory.c~mm-prevent-promotion-of-page-in-madvise_dontneed-fix
> +++ a/mm/memory.c
> @@ -1075,7 +1075,7 @@ static unsigned long unmap_page_range(st
> =A0* @end_addr: virtual address at which to end unmapping
> =A0* @nr_accounted: Place number of unmapped pages in vm-accountable vma'=
s here
> =A0* @details: details of nonlinear truncation or shared cache invalidati=
on
> - * @promote: whether pages inclued vma would be promoted or not
> + * @promote: whether pages included in the vma should be promoted or not
> =A0*
> =A0* Returns the end address of the unmapping (restart addr if interrupte=
d).
> =A0*
> _
>
> Also, I'd suggest that we avoid introducing the term "promote". =A0It
> isn't a term which is presently used in Linux MM. =A0Probably "activate"
> has a better-known meaning.
>
> And `activate' could be a bool if one is in the mood for that.
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
