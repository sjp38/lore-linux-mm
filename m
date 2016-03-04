Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id D1B426B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 05:11:12 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id 63so32927361pfe.3
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 02:11:12 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ln6si4862935pab.182.2016.03.04.02.11.05
        for <linux-mm@kvack.org>;
        Fri, 04 Mar 2016 02:11:05 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Date: Fri, 4 Mar 2016 10:11:00 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E037717B5@SHSMSX101.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160303174615.GF2115@work-vm> <20160304075538.GC9100@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E037714DA@SHSMSX101.ccr.corp.intel.com>
 <20160304083550.GE9100@rkaganb.sw.ru> <20160304090820.GA2149@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E03771639@SHSMSX101.ccr.corp.intel.com>
 <20160304114519-mutt-send-email-mst@redhat.com>
In-Reply-To: <20160304114519-mutt-send-email-mst@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Roman Kagan <rkagan@virtuozzo.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>

> On Fri, Mar 04, 2016 at 09:12:12AM +0000, Li, Liang Z wrote:
> > > Although I wonder which is cheaper; that would be fairly expensive
> > > for the guest wouldn't it? And you'd somehow have to kick the guest
> > > before migration to do the ballooning - and how long would you wait f=
or
> it to finish?
> >
> > About 5 seconds for an 8G guest, balloon to 1G. Get the free pages
> > bitmap take about 20ms for an 8G idle guest.
> >
> > Liang
>=20
> Where is the time spent though? allocating within guest?
> Or passing the info to host?
> If the former, we can use existing inflate/deflate vqs:
> Have guest put each free page on inflate vq, then on deflate vq.
>=20

Maybe I am not clear enough.

I mean if we inflate balloon before live migration, for a 8GB guest, it tak=
es about 5 Seconds for the inflating operation to finish.

For the PV solution, there is no need to inflate balloon before live migrat=
ion, the only cost is to traversing the free_list to
 construct the free pages bitmap, and it takes about 20ms for a 8GB idle gu=
est( less if there is less free pages),
 passing the free pages info to host will take about extra 3ms.


Liang
> --
> MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
