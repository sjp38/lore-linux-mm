Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 59EAE6B027A
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 20:51:17 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id r13so11831246pag.1
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 17:51:17 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d76si5194066pga.220.2016.10.26.17.51.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Oct 2016 17:51:16 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RESEND PATCH v3 kernel 0/7] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Date: Thu, 27 Oct 2016 00:51:13 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A0FEBC7@shsmsx102.ccr.corp.intel.com>
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
 <580A4F81.60201@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A0FD034@shsmsx102.ccr.corp.intel.com>
 <5810F1C7.4060807@intel.com>
In-Reply-To: <5810F1C7.4060807@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "mst@redhat.com" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>

> On 10/26/2016 03:06 AM, Li, Liang Z wrote:
> > I am working on Dave's new bitmap schema, I have finished the part of
> > getting the 'hybrid scheme bitmap' and found the complexity was more
> > than I expected. The main issue is more memory is required to save the
> > 'hybrid scheme bitmap' beside that used to save the raw page bitmap,
> > for the worst case, the memory required is 3 times than that in the
> > previous implementation.
>=20
> Really?  Could you please describe the scenario where this occurs?
> > I am wondering if I should continue, as an alternative solution, how
> > about using PFNs array when inflating/deflating only a few pages?
> > Things will be much more simple.
>=20
> Yes, using pfn lists is more efficient than using bitmaps for sparse bitm=
aps.
> Yes, there will be cases where it is preferable to just use pfn lists vs.=
 any kind
> of bitmap.
>=20
> But, what does it matter?  At least with your current scheme where we go
> out and collect get_unused_pages(), we do the allocation up front.  The
> space efficiency doesn't matter at all for small sizes since we do the co=
nstant-
> size allocation *anyway*.
>=20
> I'm also pretty sure you can pack the pfn and page order into a single 64=
-bit
> word and have no bitmap for a given record.  That would make it pack just=
 as
> well as the old pfns alone.  Right?

Yes, thanks for reminding, I am using 128 bit now, I will change it to 64 b=
it.
Let me finish the v4 first.

Thanks!
Liang

=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
