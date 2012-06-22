Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 1F3516B0261
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 17:11:21 -0400 (EDT)
Received: by ggm4 with SMTP id 4so2398597ggm.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 14:11:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120622131901.28f273e3.akpm@linux-foundation.org>
References: <1339690570-7471-1-git-send-email-kosaki.motohiro@gmail.com> <20120622131901.28f273e3.akpm@linux-foundation.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Fri, 22 Jun 2012 17:10:59 -0400
Message-ID: <CAHGf_=rQ6AaZBjfvkWWKi+a5q+1R29_PGWDyD77VFisgJHPQEA@mail.gmail.com>
Subject: Re: [PATCH] mm: clear pages_scanned only if draining a pcp adds pages
 to the buddy allocator again
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

On Fri, Jun 22, 2012 at 4:19 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 14 Jun 2012 12:16:10 -0400
> kosaki.motohiro@gmail.com wrote:
>
>> commit 2ff754fa8f (mm: clear pages_scanned only if draining a pcp adds p=
ages
>> to the buddy allocator again) fixed one free_pcppages_bulk() misuse. But=
 two
>> another miuse still exist.
>
> This changelog is irritating. =A0One can understand it a bit if one
> happens to have a git repo handy (and why do this to the reader?), but
> the changelog for 2ff754fa8f indicates that the patch might fix a
> livelock. =A0Is that true of this patch? =A0Who knows...

The code in this simple patch speak the right usage, isn't it? And yes,
this patch also fixes a possibility of live lock. (but i haven't seen actua=
l
live lock cause from this mistake)

When anyone find a function misuse and fixes it, He/She should confirm othe=
r
callsite and should all of mistake too. Otherwise we observe the same issue
sooner of later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
