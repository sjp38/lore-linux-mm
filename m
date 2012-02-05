Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 971416B002C
	for <linux-mm@kvack.org>; Sat,  4 Feb 2012 23:45:43 -0500 (EST)
Received: by wgbdt11 with SMTP id dt11so2331303wgb.2
        for <linux-mm@kvack.org>; Sat, 04 Feb 2012 20:45:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201202041536.52189.toralf.foerster@gmx.de>
References: <201202041109.53003.toralf.foerster@gmx.de>
	<20120204133331.GA13223@sig21.net>
	<201202041536.52189.toralf.foerster@gmx.de>
Date: Sun, 5 Feb 2012 12:45:40 +0800
Message-ID: <CAJd=RBC-aceg6JUzGEfD3hcwv+0yd2M_N9kpS0v-JDMMKFaj_Q@mail.gmail.com>
Subject: Re: swap storm since kernel 3.2.x
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Toralf_F=C3=B6rster?= <toralf.foerster@gmx.de>
Cc: Johannes Stezenbach <js@sig21.net>, linux-kernel@vger.kernel.org, Hillf Danton <dhillf@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

2012/2/4 Toralf F=C3=B6rster <toralf.foerster@gmx.de>:
>
> Johannes Stezenbach wrote at 14:33:31
>> On Sat, Feb 04, 2012 at 11:09:52AM +0100, Toralf F=C3=B6rster wrote:
>> > Within the last few weeks I'm observing sometimes a swap storm at my
>> > ThinkPad while compiling/installing new packages at my Gentoo Linux -
>> > the load is often something like :
>> >
>> > Load avg: 13.6, 20.6, 20.9
>> >
>> > I'm wondering whether this is related to kernel 3.2.x /Gentoo specific=
 or
>> > related to my system only.
>>
>> Do you happen to have CONFIG_DEBUG_OBJECTS enabled? =C2=A0For me it
>> ate lots of memory with 3.2.2, easily visible in slabtop.
>>
>>
>> Johannes
>
> No, I've these settings :
>
> tfoerste@n22 ~ $ zgrep -e OBJ -e SLAB -e SLUB /proc/config.gz =C2=A0| gre=
p -v '#'
> CONFIG_SLUB_DEBUG=3Dy
> CONFIG_SLUB=3Dy
> CONFIG_SLABINFO=3Dy
>

Would you please try the patchset of Rik?

         https://lkml.org/lkml/2012/1/26/374

Good weekend
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
