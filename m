Received: by wa-out-1112.google.com with SMTP id j37so1388344waf.22
        for <linux-mm@kvack.org>; Mon, 17 Nov 2008 00:32:32 -0800 (PST)
Message-ID: <2f11576a0811170032i6548e03die47f9e341f3ef9a@mail.gmail.com>
Date: Mon, 17 Nov 2008 17:32:32 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: evict streaming IO cache first
In-Reply-To: <20081117172202.343e1b35.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20081115210039.537f59f5.akpm@linux-foundation.org>
	 <alpine.LFD.2.00.0811161013270.3468@nehalem.linux-foundation.org>
	 <49208E9A.5080801@redhat.com>
	 <20081116204720.1b8cbe18.akpm@linux-foundation.org>
	 <20081117153012.51ece88f.kamezawa.hiroyu@jp.fujitsu.com>
	 <2f11576a0811162239w58555c6dq8a61ec184b22bd52@mail.gmail.com>
	 <20081117155417.5cc63907.kamezawa.hiroyu@jp.fujitsu.com>
	 <2f11576a0811162303t51609098o6cd765c04d791581@mail.gmail.com>
	 <20081117172202.343e1b35.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>

>> > How about resetting zone->recent_scanned/rotated to be some value calculated from
>> > INACTIVE_ANON/INACTIVE_FILE at some time (when the system is enough idle) ?
>>
>> in get_scan_ratio()
>>
> But active/inactive ratio (and mapped_ratio) is not handled there.

Yes.
I think akpm pointed out just this point.


> Follwoing 2 will return the same scan ratio.
> ==case 1==
>  active_anon = 480M
>  inactive_anon = 32M
>  active_file = 2M
>  inactive_file = 510M
>
> ==case 2==
>  active_anon = 480M
>  inactive_anon = 32M
>  active_file = 480M
>  inactive_file = 32M
> ==

Yes.
the patch handle this situation by special priority.


Umm..
Perhaps, I am missing your point?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
