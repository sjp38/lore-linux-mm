Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 65D046B004F
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 18:35:11 -0500 (EST)
Message-ID: <4F175706.8000808@redhat.com>
Date: Thu, 19 Jan 2012 01:34:30 +0200
From: Ronen Hod <rhod@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/3] /dev/low_mem_notify
References: <1326788038-29141-1-git-send-email-minchan@kernel.org> <1326788038-29141-2-git-send-email-minchan@kernel.org> <CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com> <4F15A34F.40808@redhat.com> <alpine.LFD.2.02.1201172044310.15303@tux.localdomain> <84FF21A720B0874AA94B46D76DB98269045596AE@008-AM1MPN1-003.mgdnok.nokia.com> <CAOJsxLGiG_Bsp8eMtqCjFToxYAPCE4HC9XCebpZ+-G8E3gg5bw@mail.gmail.com> <84FF21A720B0874AA94B46D76DB98269045596EA@008-AM1MPN1-003.mgdnok.nokia.com> <CAOJsxLG4hMrAdsyOg6QUe71SPqEBq3eZXvRvaKFZQo8HS1vphQ@mail.gmail.com> <84FF21A720B0874AA94B46D76DB982690455978C@008-AM1MPN1-003.mgdnok.nokia.com>
In-Reply-To: <84FF21A720B0874AA94B46D76DB982690455978C@008-AM1MPN1-003.mgdnok.nokia.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: penberg@kernel.org, riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, kosaki.motohiro@gmail.com, hannes@cmpxchg.org, mtosatti@redhat.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

On 01/18/2012 12:44 PM, leonid.moiseichuk@nokia.com wrote:
>> -----Original Message-----
>> From: penberg@gmail.com [mailto:penberg@gmail.com] On Behalf Of ext
>> Pekka Enberg
>> Sent: 18 January, 2012 12:40
> ...
>>> Not worse than %%. For example you had 10% free memory threshold for
>>> 512 MB RAM meaning 51.2 MB in absolute number.  Then hotplug turned
>>> off 256 MB, you for sure must update threshold for %% because these
>>> 10% for 25.6 MB most likely will be not suitable for different operating
>> mode.
>>> Using pages makes calculations must simpler.
>> Right. Does threshold in percentages make any sense then? Is it enough to
>> use number of free pages?
> Paul Mundt noticed that and we stopped use percentage in 2006 for n770 update.
> He was right.
> Percents are useless and do not correlate with other kernel APIs like sysinfo().

I believe that it will be best if the kernel publishes an ideal number_of_free_pages (in /proc/meminfo or whatever). Such number is easy to work with since this is what applications do, they free pages. Applications will be able to refer to this number from their garbage collector, or before allocating memory also if they did not get a notification, and it is also useful if several applications free memory at the same time.

Ronen.

>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
