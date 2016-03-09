Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 26CB76B007E
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 01:18:04 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id tt10so31064635pab.3
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 22:18:04 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id wg10si10168598pac.23.2016.03.08.22.18.03
        for <linux-mm@kvack.org>;
        Tue, 08 Mar 2016 22:18:03 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Date: Wed, 9 Mar 2016 06:18:00 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04148E3A@shsmsx102.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160303174615.GF2115@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E03770E33@SHSMSX101.ccr.corp.intel.com>
 <20160304081411.GD9100@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0377160A@SHSMSX101.ccr.corp.intel.com>
 <20160304102346.GB2479@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0414516C@shsmsx102.ccr.corp.intel.com>
 <56D9B6C2.3070708@redhat.com>
In-Reply-To: <56D9B6C2.3070708@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>, Roman Kagan <rkagan@virtuozzo.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>

> On 04/03/2016 15:26, Li, Liang Z wrote:
> >> >
> >> > The memory usage will keep increasing due to ever growing caches,
> >> > etc, so you'll be left with very little free memory fairly soon.
> >> >
> > I don't think so.
> >
>=20
> Roman is right.  For example, here I am looking at a 64 GB (physical) mac=
hine
> which was booted about 30 minutes ago, and which is running disk-heavy
> workloads (installing VMs).
>=20
> Since I have started writing this email (2 minutes?), the amount of free
> memory has already gone down from 37 GB to 33 GB.  I expect that by the
> time I have finished running the workload, in two hours, it will not have=
 any
> free memory.
>=20
> Paolo

I have a VM which has 2GB of RAM, when the guest booted, there were about 1=
.4GB of free pages.
Then I tried to download a large file from the internet with the browser, a=
fter the downloading finished,
there were only 72MB of free pages left, as Roman pointed out, there were q=
uite a lot of Cached memory.
Then I tried to compile the QEMU, after the compiling finished, there were =
about 1.3G free pages.

So even the cache will increase to a large amount, it will be freed if ther=
e are some other specific workloads.=20
The cache memory is a big issue that should be taken into consideration.
 How about reclaim some cache before getting the free pages information? =20

Liang=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
