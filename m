Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id E03906B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 02:25:18 -0500 (EST)
Received: by lagw12 with SMTP id w12so2159294lag.14
        for <linux-mm@kvack.org>; Wed, 18 Jan 2012 23:25:16 -0800 (PST)
Date: Thu, 19 Jan 2012 09:25:03 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [RFC 1/3] /dev/low_mem_notify
In-Reply-To: <4F175706.8000808@redhat.com>
Message-ID: <alpine.LFD.2.02.1201190922390.3033@tux.localdomain>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org> <1326788038-29141-2-git-send-email-minchan@kernel.org> <CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com> <4F15A34F.40808@redhat.com> <alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
 <84FF21A720B0874AA94B46D76DB98269045596AE@008-AM1MPN1-003.mgdnok.nokia.com> <CAOJsxLGiG_Bsp8eMtqCjFToxYAPCE4HC9XCebpZ+-G8E3gg5bw@mail.gmail.com> <84FF21A720B0874AA94B46D76DB98269045596EA@008-AM1MPN1-003.mgdnok.nokia.com> <CAOJsxLG4hMrAdsyOg6QUe71SPqEBq3eZXvRvaKFZQo8HS1vphQ@mail.gmail.com>
 <84FF21A720B0874AA94B46D76DB982690455978C@008-AM1MPN1-003.mgdnok.nokia.com> <4F175706.8000808@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ronen Hod <rhod@redhat.com>
Cc: leonid.moiseichuk@nokia.com, riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, kosaki.motohiro@gmail.com, hannes@cmpxchg.org, mtosatti@redhat.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

On Thu, 19 Jan 2012, Ronen Hod wrote:
> I believe that it will be best if the kernel publishes an ideal 
> number_of_free_pages (in /proc/meminfo or whatever). Such number is easy to 
> work with since this is what applications do, they free pages. Applications 
> will be able to refer to this number from their garbage collector, or before 
> allocating memory also if they did not get a notification, and it is also 
> useful if several applications free memory at the same time.

Isn't

/proc/sys/vm/min_free_kbytes

pretty much just that?

 			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
