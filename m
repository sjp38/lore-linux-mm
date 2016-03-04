Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 59EAF6B0253
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 04:36:28 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id 63so32426763pfe.3
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 01:36:28 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 134si4700620pfa.156.2016.03.04.01.36.27
        for <linux-mm@kvack.org>;
        Fri, 04 Mar 2016 01:36:27 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RFC qemu 0/4] A PV solution for live migration optimization
Date: Fri, 4 Mar 2016 09:36:22 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E0377172C@SHSMSX101.ccr.corp.intel.com>
References: <1457083967-13681-1-git-send-email-jitendra.kolhe@hpe.com>
In-Reply-To: <1457083967-13681-1-git-send-email-jitendra.kolhe@hpe.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jitendra Kolhe <jitendra.kolhe@hpe.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>
Cc: "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>, "mohan_parthasarathy@hpe.com" <mohan_parthasarathy@hpe.com>, "simhan@hpe.com" <simhan@hpe.com>

> > > * Liang Li (liang.z.li@intel.com) wrote:
> > > > The current QEMU live migration implementation mark the all the
> > > > guest's RAM pages as dirtied in the ram bulk stage, all these
> > > > pages will be processed and that takes quit a lot of CPU cycles.
> > > >
> > > > From guest's point of view, it doesn't care about the content in
> > > > free pages. We can make use of this fact and skip processing the
> > > > free pages in the ram bulk stage, it can save a lot CPU cycles and
> > > > reduce the network traffic significantly while speed up the live
> > > > migration process obviously.
> > > >
> > > > This patch set is the QEMU side implementation.
> > > >
> > > > The virtio-balloon is extended so that QEMU can get the free pages
> > > > information from the guest through virtio.
> > > >
> > > > After getting the free pages information (a bitmap), QEMU can use
> > > > it to filter out the guest's free pages in the ram bulk stage.
> > > > This make the live migration process much more efficient.
> > >
> > > Hi,
> > >   An interesting solution; I know a few different people have been
> > > looking at how to speed up ballooned VM migration.
> > >
> >
> > Ooh, different solutions for the same purpose, and both based on the
> balloon.
>=20
> We were also tying to address similar problem, without actually needing t=
o
> modify the guest driver. Please find patch details under mail with subjec=
t.
> migration: skip sending ram pages released by virtio-balloon driver
>=20
> Thanks,
> - Jitendra
>=20

Great! Thanks for your information.

Liang
> >
> > >   I wonder if it would be possible to avoid the kernel changes by
> > > parsing /proc/self/pagemap - if that can be used to detect
> > > unmapped/zero mapped pages in the guest ram, would it achieve the
> same result?
> > >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
