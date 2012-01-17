Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id A671A6B00BA
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 08:46:32 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH v2 2/2] Memory notification pseudo-device module
Date: Tue, 17 Jan 2012 13:45:51 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB9826904559397@008-AM1MPN1-003.mgdnok.nokia.com>
References: <cover.1326803859.git.leonid.moiseichuk@nokia.com>
	<5b429d6c4d0a3ad06ec01193eab7edc98a03e0de.1326803859.git.leonid.moiseichuk@nokia.com>
 <CAOJsxLFCbF8azY48_SHhYQ0oRDrf2-rEvGMKHBne2Znpj0XL4g@mail.gmail.com>
In-Reply-To: <CAOJsxLFCbF8azY48_SHhYQ0oRDrf2-rEvGMKHBne2Znpj0XL4g@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, gregkh@suse.de, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

Not only, here is many reasons:
1. publish code for review by people who knows how to do things and who can=
 advise something valuable
2. to have one more update source in addition to memcg I used in n9 for lib=
memnotify and which works not I like to see (ideally drop memcg)
3. maybe someone needs similar solution, keep it internally =3D kill it. No=
w module looks pretty simple for me and maintainable. Plus one small issue =
fixed for swapinfo()

So at least now it could be used for tracking activity and it is a good imp=
rovement. It also could be extended to report "memory pressure value" simil=
ar to Minchan's patch does if necessary.

With Best Wishes,
Leonid


> -----Original Message-----
> From: penberg@gmail.com [mailto:penberg@gmail.com] On Behalf Of ext
> Pekka Enberg
> Sent: 17 January, 2012 15:33
> To: Moiseichuk Leonid (Nokia-MP/Helsinki)
> Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; cesarb@cesarb.net;
> kamezawa.hiroyu@jp.fujitsu.com; emunson@mgebm.net;
> aarcange@redhat.com; riel@redhat.com; mel@csn.ul.ie;
> rientjes@google.com; dima@android.com; gregkh@suse.de;
> rebecca@android.com; san@google.com; akpm@linux-foundation.org;
> Jaaskelainen Vesa (Nokia-MP/Helsinki)
> Subject: Re: [PATCH v2 2/2] Memory notification pseudo-device module
>=20
> On Tue, Jan 17, 2012 at 3:22 PM, Leonid Moiseichuk
> <leonid.moiseichuk@nokia.com> wrote:
> > The memory notification (memnotify) device tracks level of memory
> > utilization, active page set and notifies subscribed processes when
> > consumption crossed specified threshold(s) up or down. It could be
> > used on embedded devices to implementation of performance-cheap
> memory
> > reacting by using e.g. libmemnotify or similar user-space component.
> >
> > The minimal (250 ms) and maximal (15s) periods of reaction and
> > granularity (~1.4% of memory size) could be tuned using module options.
> >
> > Signed-off-by: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>
>=20
> Is the point of making this a misc device to keep the ABI compatible with=
 N9?
> Is the ABI documented?
>=20
>                         Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
