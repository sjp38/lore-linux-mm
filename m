Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF71A6B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 06:13:53 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id rt15so2267763pab.14
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 03:13:53 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id u29si1785402pfi.120.2016.10.26.03.13.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Oct 2016 03:13:53 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RESEND PATCH v3 kernel 0/7] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Date: Wed, 26 Oct 2016 10:13:47 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A0FD05E@shsmsx102.ccr.corp.intel.com>
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
 <580A4F81.60201@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A0FD034@shsmsx102.ccr.corp.intel.com>
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E3A0FD034@shsmsx102.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "mst@redhat.com" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>

> > On 10/20/2016 11:24 PM, Liang Li wrote:
> > > Dave Hansen suggested a new scheme to encode the data structure,
> > > because of additional complexity, it's not implemented in v3.
> >
> > So, what do you want done with this patch set?  Do you want it applied
> > as-is so that we can introduce a new host/guest ABI that we must
> > support until the end of time?  Then, we go back in a year or two and
> > add the newer format that addresses the deficiencies that this ABI has =
with
> a third version?
> >
>=20
> Hi Dave & Michael,
>=20
> I am working on Dave's new bitmap schema, I have finished the part of
> getting the 'hybrid scheme bitmap'
> and found the complexity was more than I expected.  The main issue is mor=
e
> memory is required to  save the 'hybrid scheme bitmap' beside that used t=
o
> save the raw page bitmap, for the worst case, the memory required is 3
> times than that in the previous implementation.
>=20

3 times memory required is not accurate, please ignore this. sorry ...
The complexity is the point.=20

> I am wondering if I should continue, as an alternative solution, how abou=
t
> using PFNs array when inflating/deflating only a few pages? Things will b=
e
> much more simple.
>=20
>=20
> Thanks!
> Liang
>=20
>=20
>=20
>=20
> ---------------------------------------------------------------------
> To unsubscribe, e-mail: virtio-dev-unsubscribe@lists.oasis-open.org
> For additional commands, e-mail: virtio-dev-help@lists.oasis-open.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
