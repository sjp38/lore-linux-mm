Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB9DA6B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 05:50:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e190so319228222pfe.3
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 02:50:07 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id hs5si4574970pac.157.2016.04.18.02.50.06
        for <linux-mm@kvack.org>;
        Mon, 18 Apr 2016 02:50:07 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: post-copy is broken?
Date: Mon, 18 Apr 2016 09:50:03 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04181101@shsmsx102.ccr.corp.intel.com>
References: <F2CBF3009FA73547804AE4C663CAB28E0417EEE4@shsmsx102.ccr.corp.intel.com>
 <20160413080545.GA2270@work-vm> <20160413114103.GB2270@work-vm>
 <20160413125053.GC2270@work-vm> <20160413205132.GG26364@redhat.com>
 <20160414123441.GF2252@work-vm> <20160414162230.GC9976@redhat.com>
 <20160415125236.GA3376@node.shutemov.name> <20160415134233.GG2229@work-vm>
 <20160415152330.GB3376@node.shutemov.name> <20160415163448.GJ2229@work-vm>
In-Reply-To: <20160415163448.GJ2229@work-vm>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, Amit Shah <amit.shah@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> > > > I've run it directly, setting relevant QTEST_QEMU_BINARY.
> > >
> > > Interesting; it's failing reliably for me - but only with a
> > > reasonably freshly booted machine (so that the pages get THPd).
> >
> > The same here. Freshly booted machine with 64GiB ram. I've checked
> > /proc/vmstat: huge pages were allocated
>=20
> Thanks for testing.
>=20
> Damn; this is confusing now.  I've got a RHEL7 box with 4.6.0-rc3 on wher=
e it
> works, and a fedora24 VM where it fails (the f24 VM is where I did the bi=
sect
> so it works fine with the older kernel on the f24 userspace in that VM).
>=20
> So lets see:
>    works: Kirill's (64GB machine)
>           Dave's RHEL7 host (24GB RAM, dual xeon, RHEL7 userspace and ker=
nel
> config)
>    fails: Dave's f24 VM (4GB RAM, 4 vcpus VM on my laptop24 userspace and
> kernel config)
>=20
> So it's any of userspace, kernel config, machine hardware or hmm.
>=20
> My f24 box has transparent_hugepage_madvise, where my rhel7 has
> transparent_hugepage_always (but still works if I flip it to madvise at r=
un
> time).  I'll try and get the configs closer together.
>=20
> Liang Li: Can you run my test on your setup which fails the migrate and t=
ell
> me what your userspace is?
>=20
> (If you've not built my test yet, you might find you need to add a :
>    tests/postcopy-test$(EXESUF): tests/postcopy-test.o
>=20
>   to the tests/Makefile)
>=20

Hi Dave,

  How to build and run you test? I didn't do that before.

Thanks!
Liang

>=20
> Dave
> >
> > --
> >  Kirill A. Shutemov
> --
> Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
