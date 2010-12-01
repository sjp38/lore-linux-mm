Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B0EDB6B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 19:50:51 -0500 (EST)
Received: by gwj22 with SMTP id 22so1175931gwj.14
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 16:50:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101130113540.GD15564@cmpxchg.org>
References: <cover.1291043273.git.minchan.kim@gmail.com>
	<a0f2905bb64ce33909d7dd74146bfea826fec21a.1291043274.git.minchan.kim@gmail.com>
	<20101130113540.GD15564@cmpxchg.org>
Date: Wed, 1 Dec 2010 09:50:49 +0900
Message-ID: <AANLkTi=SPop0yXgVA=gdkgC2TUOp2v3W3_iL4px1OaQR@mail.gmail.com>
Subject: Re: [PATCH v3 3/3] Prevent activation of page in madvise_dontneed
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Gamari <bgamari.foss@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 30, 2010 at 8:35 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Tue, Nov 30, 2010 at 12:23:21AM +0900, Minchan Kim wrote:
>> Now zap_pte_range alwayas activates pages which are pte_young &&
>> !VM_SequentialReadHint(vma). But in case of calling MADV_DONTNEED,
>> it's unnecessary since the page wouldn't use any more.
>>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> Acked-by: Rik van Riel <riel@redhat.com>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Nick Piggin <npiggin@kernel.dk>
>> Cc: Mel Gorman <mel@csn.ul.ie>
>> Cc: Wu Fengguang <fengguang.wu@intel.com>
>>
>> Changelog since v2:
>> =A0- remove unnecessary description
>> Changelog since v1:
>> =A0- change word from promote to activate
>> =A0- add activate argument to zap_pte_range and family function
>>
>> ---
>> =A0include/linux/mm.h | =A0 =A04 ++--
>> =A0mm/madvise.c =A0 =A0 =A0 | =A0 =A04 ++--
>> =A0mm/memory.c =A0 =A0 =A0 =A0| =A0 38 +++++++++++++++++++++++----------=
-----
>> =A0mm/mmap.c =A0 =A0 =A0 =A0 =A0| =A0 =A04 ++--
>> =A04 files changed, 29 insertions(+), 21 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index e097df6..6032881 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -779,11 +779,11 @@ struct page *vm_normal_page(struct vm_area_struct =
*vma, unsigned long addr,
>> =A0int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long size);
>> =A0unsigned long zap_page_range(struct vm_area_struct *vma, unsigned lon=
g address,
>> - =A0 =A0 =A0 =A0 =A0 =A0 unsigned long size, struct zap_details *);
>> + =A0 =A0 =A0 =A0 =A0 =A0 unsigned long size, struct zap_details *, bool=
 activate);
>
> I would prefer naming the parameter 'ignore_references' or something
> similar, so that it reflects the immediate effect on the zappers'
> behaviour, not what mark_page_accessed() might end up doing.
>
> Other than that, the patch looks good to me.

Fair enough.
Will fix.
Maybe it would take a long time until sending next version.

Thanks, Hannes.

>
> =A0 =A0 =A0 =A0Hannes
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
