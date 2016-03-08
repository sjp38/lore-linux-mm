Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 851076B0255
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 09:18:29 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id 63so13883796pfe.3
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 06:18:29 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id b19si5002788pfd.242.2016.03.08.06.18.28
        for <linux-mm@kvack.org>;
        Tue, 08 Mar 2016 06:18:28 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Date: Tue, 8 Mar 2016 14:17:59 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E041481F9@shsmsx102.ccr.corp.intel.com>
References: <20160303174615.GF2115@work-vm>
 <20160304075538.GC9100@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E037714DA@SHSMSX101.ccr.corp.intel.com>
 <20160304083550.GE9100@rkaganb.sw.ru> <20160304090820.GA2149@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E03771639@SHSMSX101.ccr.corp.intel.com>
 <20160304114519-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E037717B5@SHSMSX101.ccr.corp.intel.com>
 <20160304122456-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04145231@shsmsx102.ccr.corp.intel.com>
 <20160308160145-mutt-send-email-mst@redhat.com>
In-Reply-To: <20160308160145-mutt-send-email-mst@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Roman Kagan <rkagan@virtuozzo.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>

> On Fri, Mar 04, 2016 at 03:13:03PM +0000, Li, Liang Z wrote:
> > > > Maybe I am not clear enough.
> > > >
> > > > I mean if we inflate balloon before live migration, for a 8GB
> > > > guest, it takes
> > > about 5 Seconds for the inflating operation to finish.
> > >
> > > And these 5 seconds are spent where?
> > >
> >
> > The time is spent on allocating the pages and send the allocated pages
> > pfns to QEMU through virtio.
>=20
> What if we skip allocating pages but use the existing interface to send p=
fns to
> QEMU?
>

I think it will be much faster, allocating pages is the main reason for the=
 long time of the operation.
Experiment is needed to get the exact time spend on sending the pfns.

Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
