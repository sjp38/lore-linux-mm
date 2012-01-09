Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 89E5E6B005C
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 05:20:16 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH 3.2.0-rc1 3/3] Used Memory Meter pseudo-device module
Date: Mon, 9 Jan 2012 10:19:30 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB9826904554B81@008-AM1MPN1-003.mgdnok.nokia.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
 <ed78895aa673d2e5886e95c3e3eae38cc6661eda.1325696593.git.leonid.moiseichuk@nokia.com>
 <20120104195521.GA19181@suse.de>
 <84FF21A720B0874AA94B46D76DB9826904554AFD@008-AM1MPN1-003.mgdnok.nokia.com>
 <alpine.DEB.2.00.1201090203470.8480@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1201090203470.8480@chino.kir.corp.google.com>
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
> Sent: 09 January, 2012 12:09
...
>=20
> I'm not sure why you need to detect low memory thresholds if you're not
> interested in using the memory controller, why not just use the oom kille=
r
> delay that I suggested earlier and allow userspace to respond to conditio=
ns
> when you are known to failed reclaim and require that something be killed=
?

As I understand that is required to turn on memcg and memcg is a thing I tr=
y to avoid.

> > 1.7. David Rientjes
> > > This is just a side-note but as this information is meant to be
> > > consumed by userspace you have the option of hooking into the
> > > mm_page_alloc tracepoint. You get the same information about how
> > > many pages are allocated or freed. I accept that it will probably be =
a bit
> slower but on the plus side it'll be backwards compatible and you don't n=
eed
> a kernel patch for it.
> >
>=20
> I didn't write that.

Sorry, it was Mel Gorman. Copy-paste problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
