Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 7FAE46B005C
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 03:29:00 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH 3.2.0-rc1 0/3] Used Memory Meter pseudo-device and
 related changes in MM
Date: Mon, 9 Jan 2012 08:27:52 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB98269045549DF@008-AM1MPN1-003.mgdnok.nokia.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
 <20120104195612.GB19181@suse.de>
 <84FF21A720B0874AA94B46D76DB98269045542B5@008-AM1MPN1-003.mgdnok.nokia.com>
 <CAOJsxLEdTMB6JtYViRJq5gZ4_w5aaV18S3q-1rOXGzaMtmiW6A@mail.gmail.com>
 <84FF21A720B0874AA94B46D76DB9826904554391@008-AM1MPN1-003.mgdnok.nokia.com>
 <20120105145753.GA3937@suse.de>
 <84FF21A720B0874AA94B46D76DB98269045545E5@008-AM1MPN1-003.mgdnok.nokia.com>
 <alpine.DEB.2.00.1201051503530.10521@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1201051503530.10521@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: gregkh@suse.de, penberg@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

> -----Original Message-----
> From: ext David Rientjes [mailto:rientjes@google.com]
> Sent: 06 January, 2012 01:10

> If you can accept the overhead of the memory controller (increase in
> kernel text size and amount of metadata for page_cgroup), then you can
> already do this with a combination of memory thresholds with
> cgroup.event_control and disabling of the oom killer entirely with
> memory.oom_control.  You can also get notified when the oom killer is
> triggered by using eventfd(2) on memory.oom_control even though it's
> disabled in the kernel.  Then, the userspace task attached to that contro=
l
> file can send signals to applications to free their memory or, in the
> worst case, choose to kill an application but have all that policy be
> implemented in userspace.

We invested in memcg notification (Kiryl Shutsemau's patches) and use the s=
imilar approach in n9 already (see libmemnotifyqt on gitorious).
Unfortunately it is produces number of side effects which are related how m=
emcg handled application injection/removal from/to group.
So I like to try another approach.

> We actually have extended that internally to have an oom killer delay,
> i.e. a specific amount of time must pass for userspace to react to the oo=
m
...
> handled the event").  Those patches were posted on linux-mm several
> months
> ago but never merged upstream.  You should be able to use the same
> concept
> apart from the memory controller and implement it generically.

Yep. But in n9 concept OOMing some application is acceptable, so I do not s=
ee such changes as very suitable.

> You also presented this as an alternative for "embedded or small" users s=
o
> I wasn't aware that using the memory controller was an acceptable solutio=
n
> given its overhead.

Overhead, by the way, fully acceptable and I think in never kernels (3.x) s=
ituation will be much better.
But memcg has from my point principal problems for case when you cgroup app=
lication set is updated when application foregrounded/backgrounded, unfortu=
nately that is how n900 and n9 software designed.

Best Wishes,
Leonid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
