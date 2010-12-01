Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B0B706B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 19:50:02 -0500 (EST)
Received: by iwn42 with SMTP id 42so1984686iwn.14
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 16:49:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1011301025010.7450@tigran.mtv.corp.google.com>
References: <cover.1291043273.git.minchan.kim@gmail.com>
	<a0f2905bb64ce33909d7dd74146bfea826fec21a.1291043274.git.minchan.kim@gmail.com>
	<alpine.LSU.2.00.1011301025010.7450@tigran.mtv.corp.google.com>
Date: Wed, 1 Dec 2010 09:49:17 +0900
Message-ID: <AANLkTin-BoUQNw+NfQeku0=K8mK0trt5=J9tMXNvrs9i@mail.gmail.com>
Subject: Re: [PATCH v3 3/3] Prevent activation of page in madvise_dontneed
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Gamari <bgamari.foss@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On Wed, Dec 1, 2010 at 3:34 AM, Hugh Dickins <hughd@google.com> wrote:
> On Tue, 30 Nov 2010, Minchan Kim wrote:
>
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
>
> Everyone else seems pretty happy with this, and I've not checked
> at all whether it achieves your purpose; but personally I'd much
> prefer a smaller patch which adds your "activate" or "ignore_references"
> flag to struct zap_details, instead of passing this exceptional arg
> down lots of levels. =A0That's precisely the purpose of zap_details,
> to gather together a few things that aren't needed in the common case
> (though I admit the NULL details defaulting may be ugly).

Before I sent RFC, I tried it and suffered from NULL detail as you said.
But it's valuable to look on it, again.
Since other guys don't opposed this patch's goal, I will have a time
for unifying it into zap_details.

Thanks, Hugh.


> Hugh
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
