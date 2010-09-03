Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 679086B0047
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 00:28:29 -0400 (EDT)
Received: by iwn33 with SMTP id 33so1561622iwn.14
        for <linux-mm@kvack.org>; Thu, 02 Sep 2010 21:28:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201009022204.14661.rjw@sisk.pl>
References: <1283442461-16290-1-git-send-email-minchan.kim@gmail.com>
	<201009022204.14661.rjw@sisk.pl>
Date: Fri, 3 Sep 2010 13:28:27 +0900
Message-ID: <AANLkTinNZYQ7WV_xu7_WE-ekPhHOjqsfr9xtnW3m9r1V@mail.gmail.com>
Subject: Re: [PATCH] vmscan: don't use return value trick when oom_killer_disabled
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "M. Vefa Bicakci" <bicave@superonline.com>, stable@kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

2010/9/3 Rafael J. Wysocki <rjw@sisk.pl>:
> On Thursday, September 02, 2010, Minchan Kim wrote:
>> M. Vefa Bicakci reported 2.6.35 kernel hang up when hibernation on his
>> 32bit 3GB mem machine. (https://bugzilla.kernel.org/show_bug.cgi?id=3D16=
771)
>> Also he was bisected first bad commit is below
>>
>> =A0 commit bb21c7ce18eff8e6e7877ca1d06c6db719376e3c
>> =A0 Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> =A0 Date: =A0 Fri Jun 4 14:15:05 2010 -0700
>>
>> =A0 =A0 =A0vmscan: fix do_try_to_free_pages() return value when priority=
=3D=3D0 reclaim failure
>>
>> At first impression, this seemed very strange because the above commit o=
nly
>> chenged function return value and hibernate_preallocate_memory() ignore
>> return value of shrink_all_memory(). But it's related.
>>
>> Now, page allocation from hibernation code may enter infinite loop if
>> the system has highmem.
>>
>> The reasons are two. 1) hibernate_preallocate_memory() call
>> alloc_pages() wrong order
>
> This isn't the case, as explained here: http://lkml.org/lkml/2010/9/1/316=
 .
>
> The ordering of calls is correct, but it's better to check if there are a=
ny
> non-highmem pages to allocate from before the last call (for performance
> reasons, but that also would eliminate the failure in question).

I actually didn't look into the 1) problem detail.
Just copy and paste from KOSAKI's description.
As I look the thread, KOSAKI seem to admit the description is wrong.
I will resend the patch removing phrase about 1) problem if KOSAKI don't mi=
nd.
KOSAKI. Is it okay?

Thanks.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
