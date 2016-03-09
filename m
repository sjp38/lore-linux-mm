Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 994BA6B0253
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 09:19:14 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fl4so40595009pad.0
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 06:19:14 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id p8si8239715pfa.67.2016.03.09.06.19.13
        for <linux-mm@kvack.org>;
        Wed, 09 Mar 2016 06:19:13 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Date: Wed, 9 Mar 2016 14:19:04 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E041497EC@shsmsx102.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160303174615.GF2115@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E03770E33@SHSMSX101.ccr.corp.intel.com>
 <20160304081411.GD9100@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0377160A@SHSMSX101.ccr.corp.intel.com>
 <20160304102346.GB2479@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0414516C@shsmsx102.ccr.corp.intel.com>
 <56D9B6C2.3070708@redhat.com> <20160304185120.GB2588@work-vm>
 <20160309132210.GA5869@rkaganb.sw.ru>
In-Reply-To: <20160309132210.GA5869@rkaganb.sw.ru>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Kagan <rkagan@virtuozzo.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>

> On Fri, Mar 04, 2016 at 06:51:21PM +0000, Dr. David Alan Gilbert wrote:
> > * Paolo Bonzini (pbonzini@redhat.com) wrote:
> > >
> > >
> > > On 04/03/2016 15:26, Li, Liang Z wrote:
> > > >> >
> > > >> > The memory usage will keep increasing due to ever growing
> > > >> > caches, etc, so you'll be left with very little free memory fair=
ly soon.
> > > >> >
> > > > I don't think so.
> > > >
> > >
> > > Roman is right.  For example, here I am looking at a 64 GB
> > > (physical) machine which was booted about 30 minutes ago, and which
> > > is running disk-heavy workloads (installing VMs).
> > >
> > > Since I have started writing this email (2 minutes?), the amount of
> > > free memory has already gone down from 37 GB to 33 GB.  I expect
> > > that by the time I have finished running the workload, in two hours,
> > > it will not have any free memory.
> >
> > But what about a VM sitting idle, or that just has more RAM assigned
> > to it than is currently using.
> >  I've got a host here that's been up for 46 days and has been doing
> > some heavy VM debugging a few days ago, but today:
> >
> > # free -m
> >               total        used        free      shared  buff/cache   a=
vailable
> > Mem:          96536        1146       44834         184       50555    =
   94735
> >
> > I very rarely use all it's RAM, so it's got a big chunk of free RAM,
> > and yes it's got a big chunk of cache as well.
>=20
> One of the promises of virtualization is better resource utilization.
> People tend to avoid purchasing VMs so much oversized that they never
> touch a significant amount of their RAM.  (Well, at least this is how thi=
ngs
> stand in hosting market; I guess enterprize market is similar in this reg=
ard).
>=20
> That said, I'm not at all opposed to optimizing the migration of free mem=
ory;
> what I'm trying to say is that creating brand new infrastructure specific=
ally for
> that case doesn't look justified when the existing one can cover it in ad=
dition
> to much more common scenarios.
>=20
> Roman.

Even the existing one can cover more common scenarios, but it has performan=
ce issue.
that's why I create a new one.

Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
