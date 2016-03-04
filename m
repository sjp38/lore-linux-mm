Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0F3086B007E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 21:29:24 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id x188so2447699pfb.2
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 18:29:24 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id pj4si2197573pac.45.2016.03.03.18.29.23
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 18:29:23 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RFC qemu 2/4] virtio-balloon: Add a new feature to balloon
 device
Date: Fri, 4 Mar 2016 02:29:19 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E03770F7C@SHSMSX101.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <1457001868-15949-3-git-send-email-liang.z.li@intel.com>
 <20160303125651.GA21382@redhat.com>
In-Reply-To: <20160303125651.GA21382@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "quintela@redhat.com" <quintela@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "rth@twiddle.net" <rth@twiddle.net>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>

> Subject: Re: [RFC qemu 2/4] virtio-balloon: Add a new feature to balloon
> device
>=20
> On Thu, Mar 03, 2016 at 06:44:26PM +0800, Liang Li wrote:
> > Extend the virtio balloon device to support a new feature, this new
> > feature can help to get guest's free pages information, which can be
> > used for live migration optimzation.
> >
> > Signed-off-by: Liang Li <liang.z.li@intel.com>
>=20
> I don't understand why we need a new interface.
> Balloon already sends free pages to host.
> Just teach host to skip these pages.
>=20

I just make use the current virtio-balloon implementation,  it's more compl=
icated to
invent a new virtio-io device...
Actually, there is no need to inflate the balloon before live migration, so=
 the host has
no information about the guest's free pages, that's why I add a new one.

> Maybe instead of starting with code, you should send a high level descrip=
tion
> to the virtio tc for consideration?
>=20
> You can do it through the mailing list or using the web form:
> http://www.oasis-
> open.org/committees/comments/form.php?wg_abbrev=3Dvirtio
>=20

Thanks for your information and suggestion.

Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
