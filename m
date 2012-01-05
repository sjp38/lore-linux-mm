Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 37C3A6B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 08:03:16 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH 3.2.0-rc1 0/3] Used Memory Meter pseudo-device and
 related changes in MM
Date: Thu, 5 Jan 2012 13:02:23 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB9826904554391@008-AM1MPN1-003.mgdnok.nokia.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
	<20120104195612.GB19181@suse.de>
	<84FF21A720B0874AA94B46D76DB98269045542B5@008-AM1MPN1-003.mgdnok.nokia.com>
 <CAOJsxLEdTMB6JtYViRJq5gZ4_w5aaV18S3q-1rOXGzaMtmiW6A@mail.gmail.com>
In-Reply-To: <CAOJsxLEdTMB6JtYViRJq5gZ4_w5aaV18S3q-1rOXGzaMtmiW6A@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@kernel.org
Cc: gregkh@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

Well, mm/notify.c seems a bit global for me. At the first step I handle inp=
uts from Greg and try to find less destructive approach to allocation track=
ing rather than page_alloc.
The issue is I know quite well my problem, so other guys who needs memory t=
racking has own requirements how account memory, how often notify/which gra=
nularity, =20
how  many clients could be and so one. If I get some inputs I will be happy=
 to implement them.

With Best Wishes,
Leonid


-----Original Message-----
From: penberg@gmail.com [mailto:penberg@gmail.com] On Behalf Of ext Pekka E=
nberg
Sent: 05 January, 2012 14:41
To: Moiseichuk Leonid (Nokia-MP/Helsinki)
Cc: gregkh@suse.de; linux-mm@kvack.org; linux-kernel@vger.kernel.org; cesar=
b@cesarb.net; kamezawa.hiroyu@jp.fujitsu.com; emunson@mgebm.net; aarcange@r=
edhat.com; riel@redhat.com; mel@csn.ul.ie; rientjes@google.com; dima@androi=
d.com; rebecca@android.com; san@google.com; akpm@linux-foundation.org; Jaas=
kelainen Vesa (Nokia-MP/Helsinki)
Subject: Re: [PATCH 3.2.0-rc1 0/3] Used Memory Meter pseudo-device and rela=
ted changes in MM

On Thu, Jan 5, 2012 at 1:47 PM,  <leonid.moiseichuk@nokia.com> wrote:
> As I understand AOOM it wait until situation is reached bad conditions=20
> which required memory reclaiming, selects application according to=20
> free memory and oom_adj level and kills it.  So no intermediate levels co=
uld be checked (e.g.
> 75% usage),  nothing could be done in user-space to prevent killing,=20
> no notification for case when memory becomes OK.
>
> What I try to do is to get notification in any application that memory=20
> becomes low, and do something about it like stop processing data,=20
> close unused pages or correctly shuts applications, daemons. =20
> Application(s) might have necessity to install several notification=20
> levels, so reaction could be adjusted based on current utilization=20
> level per each application, not globally.

Sure. However, from VM point of view, both have the exact same
functionality: detect when we reach low memory condition (for some configur=
able threshold) and notify userspace or kernel subsystem about it.

That's the part I'd like to see implemented in mm/notify.c or similar.
I really don't care what Android or any other folks use it for exactly as l=
ong as the generic code is light-weight, clean, and we can reasonably assum=
e that distros can actually enable it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
