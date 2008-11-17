Message-ID: <49219A3E.1080100@redhat.com>
Date: Mon, 17 Nov 2008 11:22:22 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: evict streaming IO cache first
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com>	<20081115210039.537f59f5.akpm@linux-foundation.org>	<alpine.LFD.2.00.0811161013270.3468@nehalem.linux-foundation.org>	<49208E9A.5080801@redhat.com>	<20081116204720.1b8cbe18.akpm@linux-foundation.org>	<20081117153012.51ece88f.kamezawa.hiroyu@jp.fujitsu.com>	<2f11576a0811162239w58555c6dq8a61ec184b22bd52@mail.gmail.com>	<20081117155417.5cc63907.kamezawa.hiroyu@jp.fujitsu.com>	<2f11576a0811162303t51609098o6cd765c04d791581@mail.gmail.com> <20081117172202.343e1b35.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081117172202.343e1b35.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 17 Nov 2008 16:03:48 +0900
> "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com> wrote:
>>> How about resetting zone->recent_scanned/rotated to be some value calculated from
>>> INACTIVE_ANON/INACTIVE_FILE at some time (when the system is enough idle) ?
>> in get_scan_ratio()
>>
> But active/inactive ratio (and mapped_ratio) is not handled there.
> 
> Follwoing 2 will return the same scan ratio.

get_scan_ratio does not look at the sizes of the lists, but
at the ratio between "pages scanned" and "pages rotated".

A page that is moved from the inactive to the active list
is always counted as rotated.

A page that is moved from the active to the inactive list
is counted as rotated if it was mapped and referenced.

> ==case 1==
>   active_anon = 480M
>   inactive_anon = 32M
>   active_file = 2M
>   inactive_file = 510M
> 
> ==case 2==
>   active_anon = 480M
>   inactive_anon = 32M
>   active_file = 480M
>   inactive_file = 32M
> ==
> 
> 
> 
> -Kame
> 


-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
