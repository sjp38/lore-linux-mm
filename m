Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E11526008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 00:04:40 -0400 (EDT)
Received: by iwn2 with SMTP id 2so5477723iwn.14
        for <linux-mm@kvack.org>; Mon, 02 Aug 2010 21:09:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100803033108.GA23117@arachsys.com>
References: <20100802124734.GI2486@arachsys.com>
	<AANLkTinnWQA-K6r_+Y+giEC9zs-MbY6GFs8dWadSq0kh@mail.gmail.com>
	<20100803033108.GA23117@arachsys.com>
Date: Tue, 3 Aug 2010 13:09:18 +0900
Message-ID: <AANLkTinjmZOOaq7FgwJOZ=UNGS8x8KtQWZg6nv7fqJMe@mail.gmail.com>
Subject: Re: Over-eager swapping
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Chris Webb <chris@arachsys.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 3, 2010 at 12:31 PM, Chris Webb <chris@arachsys.com> wrote:
> Minchan Kim <minchan.kim@gmail.com> writes:
>
>> Another possibility is _zone_reclaim_ in NUMA.
>> Your working set has many anonymous page.
>>
>> The zone_reclaim set priority to ZONE_RECLAIM_PRIORITY.
>> It can make reclaim mode to lumpy so it can page out anon pages.
>>
>> Could you show me /proc/sys/vm/[zone_reclaim_mode/min_unmapped_ratio] ?
>
> Sure, no problem. On the machine with the /proc/meminfo I showed earlier,
> these are
>
> =A0# cat /proc/sys/vm/zone_reclaim_mode
> =A00
> =A0# cat /proc/sys/vm/min_unmapped_ratio
> =A01

if zone_reclaim_mode is zero, it doesn't swap out anon_pages.

1) How does VM reclaim anonymous pages even though vm_swappiness =3D=3D
zero and has big page cache?
2) I doubt file pages of your system is fulled by Buffers while Cached
is almost 10M.
Why is it remained although anon pages is swapped out and cached page
are reclaimed?

Hmm. I have no idea. :(

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
