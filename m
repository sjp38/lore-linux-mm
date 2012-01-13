Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 7DCC86B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 04:35:25 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH 3.2.0-rc1 3/3] Used Memory Meter pseudo-device module
Date: Fri, 13 Jan 2012 09:34:40 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB9826904557417@008-AM1MPN1-003.mgdnok.nokia.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
 <ed78895aa673d2e5886e95c3e3eae38cc6661eda.1325696593.git.leonid.moiseichuk@nokia.com>
 <20120104195521.GA19181@suse.de>
 <84FF21A720B0874AA94B46D76DB9826904554AFD@008-AM1MPN1-003.mgdnok.nokia.com>
 <alpine.DEB.2.00.1201090203470.8480@chino.kir.corp.google.com>
 <84FF21A720B0874AA94B46D76DB9826904554B81@008-AM1MPN1-003.mgdnok.nokia.com>
 <alpine.DEB.2.00.1201091251300.10232@chino.kir.corp.google.com>
 <84FF21A720B0874AA94B46D76DB98269045568A1@008-AM1MPN1-003.mgdnok.nokia.com>
 <alpine.DEB.2.00.1201111338320.21755@chino.kir.corp.google.com>
 <84FF21A720B0874AA94B46D76DB9826904556CB7@008-AM1MPN1-003.mgdnok.nokia.com>
 <alpine.DEB.2.00.1201121247480.17287@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1201121247480.17287@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: gregkh@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

> -----Original Message-----
> From: ext David Rientjes [mailto:rientjes@google.com]
> Sent: 12 January, 2012 21:55
> To: Moiseichuk Leonid (Nokia-MP/Helsinki)
....
>=20
> Then it's fundamentally flawed since there's no guarantee that coming wit=
h
> 100MB of the min watermark, for example, means that an oom is imminent
> and will just result in unnecessary notification to userspace that will c=
ause
> some action to be taken that may not be necessary.  If the setting of the=
se
> thresholds depends on some pattern that is guaranteed to be along the pat=
h
> to oom for a certain workload, then that will also change depending on VM
> implementation changes, kernel versions, other applications, etc., and si=
mply
> is unmaintainable.

Why? That is expected that product tested and tuned properly, applications =
fixed, and at least no apps installed which might consume 100 MB in second =
or two.
If you have another product with big difference in memory size, application=
s etc. you might need to re-calibrate reactions.
Let's focus on realistic cases.

> It would be much better to address the slowdown when running out of
> memory rather than requiring userspace to react and unnecessarily send
> signals to threads that may or may not have the ability to respond becaus=
e
> they may already be oom themselves.

That is not possible - signals usually set at level you have 20-50 MB to re=
act.=20
Slowdown is natural thing if you have lack of space for code paging, I do n=
ot see any ways to fix it.

>  You can do crazy things to reduce
> latency in lowmem memory allocations like changing gfp_allowed_mask to
> be GFP_ATOMIC so that direct reclaim is never called, for example, and th=
en
> use the proposed oom killer delay to handle the situation at the time of =
oom.

It is not necessary.

> Regardless, you should be addressing the slowness in lowmem situations
> rather than implementing notifiers to userspace to handle the events itse=
lf,
> so nack on this proposal.

Define "lowmem situation" first.  For proposed approach it is from 50-90% o=
f memory usage until user-space can do something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
