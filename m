Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 21F176B003D
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 01:00:35 -0500 (EST)
Received: by fxm18 with SMTP id 18so943352fxm.38
        for <linux-mm@kvack.org>; Thu, 26 Feb 2009 22:00:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090227144355.1545.A69D9226@jp.fujitsu.com>
References: <bug-12785-10286@http.bugzilla.kernel.org/>
	 <20090226212918.fce45757.akpm@linux-foundation.org>
	 <20090227144355.1545.A69D9226@jp.fujitsu.com>
Date: Fri, 27 Feb 2009 14:00:32 +0800
Message-ID: <2aca4abf0902262200p1f0d93dbnd52c0b9df670ff19@mail.gmail.com>
Subject: Re: [Bugme-new] [Bug 12785] New: kswapd block the whole system by IO
	blaster in some case
From: =?GB2312?B?s8LKwOq7?= <crackevil@gmail.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Those experimental packages have been in use for 2 months, this issue
just occured and just once.
I think it's quite unexpectly random. Even in the same environment, I
can't make that issue alive again.

Today I'll look through the logs. Maybe in the syslog I can find
something valuable while other logs like dmesg, messages, kern.log,
etc have been found useless.

On Fri, Feb 27, 2009 at 1:48 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>>
>> (switched to email.  Please respond via emailed reply-to-all, not via th=
e
>> bugzilla web interface).
>>
>> (uh-oh)
>>
>> On Thu, 26 Feb 2009 21:20:46 -0800 (PST) bugme-daemon@bugzilla.kernel.or=
g wrote:
>>
>> > http://bugzilla.kernel.org/show_bug.cgi?id=3D12785
>> >
>> >            Summary: kswapd block the whole system by IO blaster in som=
e case
>> >            Product: Memory Management
>> >            Version: 2.5
>> >      KernelVersion: 2.6.28.4
>> >           Platform: All
>> >         OS/Version: Linux
>> >               Tree: Mainline
>> >             Status: NEW
>> >           Severity: low
>> >           Priority: P1
>> >          Component: Other
>> >         AssignedTo: akpm@osdl.org
>> >         ReportedBy: crackevil@gmail.com
>> >
>> >
>> > Distribution:debian lenny with some experimental packages
>
> As far as I know, lenny (debian 5.0) use kernel 2.6.26.
> then, recently changed code don't provide any hint.
>
> Martin, if remove experimental package, do you still see the same issue?
>
>
>
>> > Hardware Environment:ThinkPad SL 400 7DC with 2G memery
>> > Software Environment:no swap partition,kernel with 4G memery support
>> > Problem Description:
>> > Some day, my box dived into a block while HDLED was blinking.
>> > I switched to console from gdm, tried iotop by long waiting and found =
the
>> > killer was kswapd.
>> > In "top" output, free memory is almost 50M.The most memory is cached b=
y swap.
>> > The system blocked even shutdown command wasn't effective.The box had =
been
>> > killed by pressing then power button.
>> > BTW, there was no network available then, so there was no attack possi=
bility.
>> >
>> > I'd like to attach my kernel config file, but I don't know how to.For =
someone
>> > interesting, we may transfer the file my mail.crackevil@gmail.com
>> >
>> > ps:these experimental packages installed
>> >
>> > libdrm2_2.4.4+git+20090205+8b88036-1_i386.deb
>> > libdrm-dev_2.4.4+git+20090205+8b88036-1_i386.deb
>> > libdrm-intel1_2.4.4+git+20090205+8b88036-1_i386.deb
>> > libdrm-nouveau1_2.4.4+git+20090205+8b88036-1_i386.deb
>> > libgl1-mesa-dev_7.3-1_all.deb
>> > libgl1-mesa-dri_7.3-1_i386.deb
>> > libgl1-mesa-glx_7.3-1_i386.deb
>> > libglu1-mesa_7.3-1_i386.deb
>> > mesa-common-dev_7.3-1_all.deb
>> > mesa-utils_7.3-1_i386.deb
>> > xserver-common_2%3a1.5.99.902-1_all.deb
>> > xserver-xorg-core_2%3a1.5.99.902-1_i386.deb
>> > xkb-data_1.5-2_all.deb
>> >
>> >
>>
>
>
>
>



--=20



=B3=C2=CA=C0=EA=BB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
