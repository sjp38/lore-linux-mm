Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 94A436B0093
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 03:13:37 -0500 (EST)
Received: by iwn1 with SMTP id 1so1306042iwn.37
        for <linux-mm@kvack.org>; Wed, 08 Dec 2010 00:13:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101208165944.174D.A69D9226@jp.fujitsu.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
	<dff7a42e5877b23a3cc3355743da4b7ef37299f8.1291568905.git.minchan.kim@gmail.com>
	<20101208165944.174D.A69D9226@jp.fujitsu.com>
Date: Wed, 8 Dec 2010 17:13:35 +0900
Message-ID: <AANLkTik4mtr8T6PddQopi4cwWGRmJ+-utykgjywGoxj+@mail.gmail.com>
Subject: Re: [PATCH v4 5/7] add profile information for invalidated page reclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hi KOSAKI,

On Wed, Dec 8, 2010 at 5:02 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> This patch adds profile information about invalidated page reclaim.
>> It's just for profiling for test so it would be discard when the series
>> are merged.
>>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Wu Fengguang <fengguang.wu@intel.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Nick Piggin <npiggin@kernel.dk>
>> Cc: Mel Gorman <mel@csn.ul.ie>
>> ---
>> =A0include/linux/vmstat.h | =A0 =A04 ++--
>> =A0mm/swap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 +++
>> =A0mm/vmstat.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 +++
>> =A03 files changed, 8 insertions(+), 2 deletions(-)
>
> Today, we have tracepoint. tracepoint has no overhead if it's unused.
> but vmstat has a overhead even if unused.
>
> Then, all new vmstat proposal should be described why you think it is
> frequently used from administrators.

It's just for easy gathering the data when Ben will test.
I never want to merge it in upstream and even mmtom.

If you don't like it for just testing, I am happy to change it with tracepo=
int.

Thanks.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
