Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 91F866B0092
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:52:36 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so3818685pbc.14
        for <linux-mm@kvack.org>; Thu, 12 Apr 2012 17:52:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120412153603.fe320f54.akpm@linux-foundation.org>
References: <1334253782-22755-1-git-send-email-yinghan@google.com>
	<20120412153603.fe320f54.akpm@linux-foundation.org>
Date: Thu, 12 Apr 2012 17:52:35 -0700
Message-ID: <CALWz4iz8eWQod4C1dMiMZY-VFi73D_YCLpaFDnjzG7=EyFE-9Q@mail.gmail.com>
Subject: Re: [PATCH] mm: fix up the vmscan stat in vmstat
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Thu, Apr 12, 2012 at 3:36 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 12 Apr 2012 11:03:02 -0700
> Ying Han <yinghan@google.com> wrote:
>
>> It is always confusing on stat "pgsteal" where it counts both direct
>> reclaim as well as background reclaim. However, we have "kswapd_steal"
>> which also counts background reclaim value.
>>
>> This patch fixes it and also makes it match the existng "pgscan_" stats.
>>
>> Test:
>> pgsteal_kswapd_dma32 447623
>> pgsteal_kswapd_normal 42272677
>> pgsteal_kswapd_movable 0
>> pgsteal_direct_dma32 2801
>> pgsteal_direct_normal 44353270
>> pgsteal_direct_movable 0
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>> =A0include/linux/vm_event_item.h | =A0 =A05 +++--
>> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 11 ++++++++---
>> =A0mm/vmstat.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A04 ++--
>
> I was going to have a big whine about the failure to update the
> /proc/vmstat documentation. =A0But we don't have any /proc/vmstat
> documentation. =A0That was a sneaky labor-saving device.

yeah, there were couple of times that I was looking for the
documentation for vmstat but failed. It turns out that I just need to
quickly look at the source code and find out what each field means.

maybe that gives us a hint only kernel developers cares about them :)

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
