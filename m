Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5458E8D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 22:58:45 -0500 (EST)
Received: by wwb29 with SMTP id 29so924342wwb.26
        for <linux-mm@kvack.org>; Wed, 09 Feb 2011 19:58:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110210085823.2f99b81c.kamezawa.hiroyu@jp.fujitsu.com>
References: <1297262537-7425-1-git-send-email-ozaki.ryota@gmail.com> <20110210085823.2f99b81c.kamezawa.hiroyu@jp.fujitsu.com>
From: Ryota Ozaki <ozaki.ryota@gmail.com>
Date: Thu, 10 Feb 2011 12:58:21 +0900
Message-ID: <AANLkTikdBhSWAoP6TDRExSV2rHmWDkEc0foSKvqJt=tx@mail.gmail.com>
Subject: Re: [PATCH] mm: Fix out-of-date comments which refers non-existent functions
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

On Thu, Feb 10, 2011 at 8:58 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, =A09 Feb 2011 23:42:17 +0900
> Ryota Ozaki <ozaki.ryota@gmail.com> wrote:
>
>> From: Ryota Ozaki <ozaki.ryota@gmail.com>
>>
>> do_file_page and do_no_page don't exist anymore, but some comments
>> still refers them. The patch fixes them by replacing them with
>> existing ones.
>>
>> Signed-off-by: Ryota Ozaki <ozaki.ryota@gmail.com>
>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks, Kamezawa-san.

>
> It seems there are other ones ;)
> =3D=3D
> =A0 =A0Searched full:do_no_page (Results 1 - 3 of 3) sorted by relevancy
>
> =A0/linux-2.6-git/arch/alpha/include/asm/
> H A D =A0 cacheflush.h =A0 =A066 /* This is used only in do_no_page and d=
o_swap_page. */
> =A0/linux-2.6-git/arch/avr32/mm/
> H A D =A0 cache.c =A0 =A0 =A0 =A0 116 * This one is called from do_no_pag=
e(), do_swap_page() and install_page().
> =A0/linux-2.6-git/mm/
> H A D =A0 memory.c =A0 =A0 =A0 =A02121 * and do_anonymous_page and do_no_=
page can safely check later on).
> 2319 * do_no_page is protected similarly.

Nice catch :-) Cloud I assemble all fixes into one patch?

  ozaki-r

>
>
>
>
>
>> ---
>> =A0mm/memory.c | =A0 =A06 +++---
>> =A01 files changed, 3 insertions(+), 3 deletions(-)
>>
>> I'm not familiar with the codes very much, so the fix may be wrong.
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 31250fa..3fbf32a 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2115,10 +2115,10 @@ EXPORT_SYMBOL_GPL(apply_to_page_range);
>> =A0 * handle_pte_fault chooses page fault handler according to an entry
>> =A0 * which was read non-atomically. =A0Before making any commitment, on
>> =A0 * those architectures or configurations (e.g. i386 with PAE) which
>> - * might give a mix of unmatched parts, do_swap_page and do_file_page
>> + * might give a mix of unmatched parts, do_swap_page and do_nonlinear_f=
ault
>> =A0 * must check under lock before unmapping the pte and proceeding
>> =A0 * (but do_wp_page is only called after already making such a check;
>> - * and do_anonymous_page and do_no_page can safely check later on).
>> + * and do_anonymous_page can safely check later on).
>> =A0 */
>> =A0static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pte_t *page_=
table, pte_t orig_pte)
>> @@ -2316,7 +2316,7 @@ reuse:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* bit after it clear all dirty ptes, but =
before a racing
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* do_wp_page installs a dirty pte.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0* do_no_page is protected similarly.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* __do_fault is protected similarly.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!page_mkwrite) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait_on_page_locked(dirty_pa=
ge);
>> --
>> 1.7.2.3
>>
>>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
