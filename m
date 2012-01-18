Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 4510B6B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 05:40:11 -0500 (EST)
Received: by obbta7 with SMTP id ta7so5170361obb.14
        for <linux-mm@kvack.org>; Wed, 18 Jan 2012 02:40:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <84FF21A720B0874AA94B46D76DB98269045596EA@008-AM1MPN1-003.mgdnok.nokia.com>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
	<1326788038-29141-2-git-send-email-minchan@kernel.org>
	<CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com>
	<4F15A34F.40808@redhat.com>
	<alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
	<84FF21A720B0874AA94B46D76DB98269045596AE@008-AM1MPN1-003.mgdnok.nokia.com>
	<CAOJsxLGiG_Bsp8eMtqCjFToxYAPCE4HC9XCebpZ+-G8E3gg5bw@mail.gmail.com>
	<84FF21A720B0874AA94B46D76DB98269045596EA@008-AM1MPN1-003.mgdnok.nokia.com>
Date: Wed, 18 Jan 2012 12:40:10 +0200
Message-ID: <CAOJsxLG4hMrAdsyOg6QUe71SPqEBq3eZXvRvaKFZQo8HS1vphQ@mail.gmail.com>
Subject: Re: [RFC 1/3] /dev/low_mem_notify
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, kosaki.motohiro@gmail.com, hannes@cmpxchg.org, mtosatti@redhat.com, akpm@linux-foundation.org, rhod@redhat.com, kosaki.motohiro@jp.fujitsu.com

On Wed, Jan 18, 2012 at 11:41 AM,  <leonid.moiseichuk@nokia.com> wrote:
>> -----Original Message-----
>> From: penberg@gmail.com [mailto:penberg@gmail.com] On Behalf Of ext
>> Pekka Enberg
>> Sent: 18 January, 2012 11:16
> ...
>> > Would be possible to not use percents for thesholds? Accounting in pages
>> even
>> > not so difficult to user-space.
>>
>> How does that work with memory hotplug?
>
> Not worse than %%. For example you had 10% free memory threshold for 512 MB
> RAM meaning 51.2 MB in absolute number.  Then hotplug turned off 256 MB, you
> for sure must update threshold for %% because these 10% for 25.6 MB most
> likely will be not suitable for different operating mode.
> Using pages makes calculations must simpler.

Right. Does threshold in percentages make any sense then? Is it enough to use
number of free pages?

On Wed, Jan 18, 2012 at 11:06 AM,  <leonid.moiseichuk@nokia.com> wrote:
>> > Also, looking on vmnotify_match I understand that events propagated to
>> > user-space only in case threshold trigger change state from 0 to 1 but not
>> > back, 1-> 0 is very useful event as well
> (*)
>
>> >
>> > Would be possible to use for threshold pointed value(s) e.g. according to
>> > enum zone_state_item, because kinds of memory to track could be
>> different?
>> > E.g. to tracking paging activity NR_ACTIVE_ANON and NR_ACTIVE_FILE
>> could be
>> > interesting, not only free.
>>
>> I don't think there's anything in the ABI that would prevent that.
>
> If this statement also related my question (*)  I have to point need to track
> attributes history, otherwise user-space will be constantly kicked with
> updates.

Well sure, I think it makes sense to support state change to both directions.

> When I see code because from emails it is quite difficult to understand.  For
> short-term I need to focus on integration "memnotify" version internally
> which is kind of work for me already and provides all required interfaces n9
> needs.

Sure. I'm only talking about mainline here.

> Btw, when API starts to work with pointed thresholds logically it is not

Definitely, it's about generic VM event notification now.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
