Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 221A66B0068
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 22:27:24 -0500 (EST)
Message-ID: <1326252320.5973.13.camel@hakkenden.homenet>
Subject: Re: Kswapd in 3.2.0-rc5 is a CPU hog
From: "Nikolay S." <nowhere@hakkenden.ath.cx>
Date: Wed, 11 Jan 2012 07:25:20 +0400
In-Reply-To: <20120110143330.44cf1ccf.akpm@linux-foundation.org>
References: <1324437036.4677.5.camel@hakkenden.homenet>
	 <20111221095249.GA28474@tiehlicka.suse.cz> <20111221225512.GG23662@dastard>
	 <1324630880.562.6.camel@rybalov.eng.ttk.net>
	 <20111223102027.GB12731@dastard>
	 <1324638242.562.15.camel@rybalov.eng.ttk.net>
	 <20111223204503.GC12731@dastard>
	 <20111227111543.5e486eb7.kamezawa.hiroyu@jp.fujitsu.com>
	 <20111227035730.GA22840@barrios-laptop.redhat.com>
	 <20111227135658.08c8016a.kamezawa.hiroyu@jp.fujitsu.com>
	 <20120110143330.44cf1ccf.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

=D0=92 =D0=92=D1=82., 10/01/2012 =D0=B2 14:33 -0800, Andrew Morton =D0=BF=
=D0=B8=D1=88=D0=B5=D1=82:
> On Tue, 27 Dec 2011 13:56:58 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>=20
> > Hmm, if I understand correctly,
> >=20
> >  - dd's speed down is caused by kswapd's cpu consumption.
> >  - kswapd's cpu consumption is enlarged by shrink_slab() (by perf)
> >  - kswapd can't stop because NORMAL zone is small.
> >  - memory reclaim speed is enough because dd can't get enough cpu.
> >=20
> > I wonder reducing to call shrink_slab() may be a help but I'm not sure
> > where lock conention comes from...
>=20
> Nikolay, it sounds as if this problem has only recently started
> happening?  Was 3.1 OK?
>=20
> If so, we should work out what we did post-3.1 to cause this.

Yes, 3.1. was ok.
Recently I have upgraded to 3.2, and I can not reproduce the problem.
I'm now at 5 days uptime, the machine usage pattern, the software - all
the same, but the problem is not visible anymore:

  PID USER      S %CPU %MEM    TIME+  SWAP COMMAND
14822 nowhere   R   30  0.2   0:01.52  10m dd
  416 root      S    7  0.0   6:26.72    0 kswapd0

(also, kswapd run time after 5 days is only 6,5 seconds, whereas with
-rc5 it was 22 seconds after 5 days).

I can provide similar traces to see what has changed in kswapd's
activities (if it is of any value)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
