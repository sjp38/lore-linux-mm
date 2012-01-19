Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 7DEF36B005C
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 07:06:15 -0500 (EST)
Received: by obbta7 with SMTP id ta7so7177694obb.14
        for <linux-mm@kvack.org>; Thu, 19 Jan 2012 04:06:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <84FF21A720B0874AA94B46D76DB9826904559D9B@008-AM1MPN1-003.mgdnok.nokia.com>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
	<1326788038-29141-2-git-send-email-minchan@kernel.org>
	<CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com>
	<4F15A34F.40808@redhat.com>
	<alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
	<84FF21A720B0874AA94B46D76DB98269045596AE@008-AM1MPN1-003.mgdnok.nokia.com>
	<CAOJsxLGiG_Bsp8eMtqCjFToxYAPCE4HC9XCebpZ+-G8E3gg5bw@mail.gmail.com>
	<84FF21A720B0874AA94B46D76DB98269045596EA@008-AM1MPN1-003.mgdnok.nokia.com>
	<CAOJsxLG4hMrAdsyOg6QUe71SPqEBq3eZXvRvaKFZQo8HS1vphQ@mail.gmail.com>
	<84FF21A720B0874AA94B46D76DB982690455978C@008-AM1MPN1-003.mgdnok.nokia.com>
	<4F175706.8000808@redhat.com>
	<alpine.LFD.2.02.1201190922390.3033@tux.localdomain>
	<4F17DCED.4020908@redhat.com>
	<CAOJsxLG3x_R5xq85hh5RvPoD+nhgYbHJfbLW=YMxCZockAXJqw@mail.gmail.com>
	<4F17E058.8020008@redhat.com>
	<84FF21A720B0874AA94B46D76DB9826904559D46@008-AM1MPN1-003.mgdnok.nokia.com>
	<CAOJsxLHd5dCvBwV5gsraFZXh86wq7tg7uLLnevN8Pp_jGiOBbw@mail.gmail.com>
	<84FF21A720B0874AA94B46D76DB9826904559D9B@008-AM1MPN1-003.mgdnok.nokia.com>
Date: Thu, 19 Jan 2012 14:06:14 +0200
Message-ID: <CAOJsxLHhJf0VOzmGWTfLBKkjXvP5DwSbaFtpLnbt2wipfer4Gw@mail.gmail.com>
Subject: Re: [RFC 1/3] /dev/low_mem_notify
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: rhod@redhat.com, riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, kosaki.motohiro@gmail.com, hannes@cmpxchg.org, mtosatti@redhat.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

On Thu, Jan 19, 2012 at 1:54 PM,  <leonid.moiseichuk@nokia.com> wrote:
>> On Thu, Jan 19, 2012 at 12:53 PM, =A0<leonid.moiseichuk@nokia.com> wrote=
:
>> > 6. I do not understand how work with attributes performed ( ) but it
>> > has sense to use mask and fill requested attributes using mask and
>> > callback table i.e. if free pages requested - they are reported, other=
wise
>> not.
>>
>> That's how it works now in the git tree.
>
> Vmnotify.c has vmnotify_watch_event which collects fixed set of parameter=
s.

That's would be a bug. We should check event_attrs like we do for NR_SWAP_P=
AGES.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
