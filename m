Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id C40ED6B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 06:06:11 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id r13so2333518pag.1
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 03:06:11 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id e85si1724065pfk.179.2016.10.26.03.06.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Oct 2016 03:06:10 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RESEND PATCH v3 kernel 0/7] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Date: Wed, 26 Oct 2016 10:06:07 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A0FD034@shsmsx102.ccr.corp.intel.com>
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
 <580A4F81.60201@intel.com>
In-Reply-To: <580A4F81.60201@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "mst@redhat.com" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>

> On 10/20/2016 11:24 PM, Liang Li wrote:
> > Dave Hansen suggested a new scheme to encode the data structure,
> > because of additional complexity, it's not implemented in v3.
>=20
> So, what do you want done with this patch set?  Do you want it applied as=
-is
> so that we can introduce a new host/guest ABI that we must support until
> the end of time?  Then, we go back in a year or two and add the newer
> format that addresses the deficiencies that this ABI has with a third ver=
sion?
>=20

Hi Dave & Michael,

I am working on Dave's new bitmap schema, I have finished the part of getti=
ng the 'hybrid scheme bitmap'
and found the complexity was more than I expected.  The main issue is more =
memory is required to
 save the 'hybrid scheme bitmap' beside that used to save the raw page bitm=
ap, for the worst case, the
memory required is 3 times than that in the previous implementation.=20

I am wondering if I should continue, as an alternative solution, how about =
using PFNs array when
inflating/deflating only a few pages? Things will be much more simple.


Thanks!
Liang=20



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
