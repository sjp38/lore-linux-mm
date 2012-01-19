Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id EA7096B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 04:21:08 -0500 (EST)
Message-ID: <4F17E058.8020008@redhat.com>
Date: Thu, 19 Jan 2012 11:20:24 +0200
From: Ronen Hod <rhod@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/3] /dev/low_mem_notify
References: <1326788038-29141-1-git-send-email-minchan@kernel.org> <1326788038-29141-2-git-send-email-minchan@kernel.org> <CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com> <4F15A34F.40808@redhat.com> <alpine.LFD.2.02.1201172044310.15303@tux.localdomain> <84FF21A720B0874AA94B46D76DB98269045596AE@008-AM1MPN1-003.mgdnok.nokia.com> <CAOJsxLGiG_Bsp8eMtqCjFToxYAPCE4HC9XCebpZ+-G8E3gg5bw@mail.gmail.com> <84FF21A720B0874AA94B46D76DB98269045596EA@008-AM1MPN1-003.mgdnok.nokia.com> <CAOJsxLG4hMrAdsyOg6QUe71SPqEBq3eZXvRvaKFZQo8HS1vphQ@mail.gmail.com> <84FF21A720B0874AA94B46D76DB982690455978C@008-AM1MPN1-003.mgdnok.nokia.com> <4F175706.8000808@redhat.com> <alpine.LFD.2.02.1201190922390.3033@tux.localdomain> <4F17DCED.4020908@redhat.com> <CAOJsxLG3x_R5xq85hh5RvPoD+nhgYbHJfbLW=YMxCZockAXJqw@mail.gmail.com>
In-Reply-To: <CAOJsxLG3x_R5xq85hh5RvPoD+nhgYbHJfbLW=YMxCZockAXJqw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: leonid.moiseichuk@nokia.com, riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, kosaki.motohiro@gmail.com, hannes@cmpxchg.org, mtosatti@redhat.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

On 01/19/2012 11:10 AM, Pekka Enberg wrote:
> On Thu, Jan 19, 2012 at 11:05 AM, Ronen Hod<rhod@redhat.com>  wrote:
>>>> I believe that it will be best if the kernel publishes an ideal
>>>> number_of_free_pages (in /proc/meminfo or whatever). Such number is easy to
>>>> work with since this is what applications do, they free pages. Applications
>>>> will be able to refer to this number from their garbage collector, or before
>>>> allocating memory also if they did not get a notification, and it is also
>>>> useful if several applications free memory at the same time.
>>> Isn't
>>>
>>> /proc/sys/vm/min_free_kbytes
>>>
>>> pretty much just that?
>> Would you suggest to use min_free_kbytes as the threshold for sending
>> low_memory_notifications to applications, and separately as a target value
>> for the applications' memory giveaway?
> I'm not saying that the kernel should use it directly but it seems
> like the kind of "ideal number of free pages" threshold you're
> suggesting. So userspace can read that value and use it as the "number
> of free pages" threshold for VM events, no?

Yes, I like it. The rules of the game are simple and consistent all over, be it the alert threshold, voluntary poling by the apps, and for concurrent work by several applications.
Well, as long as it provides a good indication for low_mem_pressure.

Thanks, Ronen.

>
>                          Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
