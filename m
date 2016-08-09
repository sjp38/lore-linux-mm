Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 64E996B0005
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 22:52:46 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id le9so2461404pab.0
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 19:52:46 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id tt6si14392163pab.247.2016.08.08.19.52.45
        for <linux-mm@kvack.org>;
        Mon, 08 Aug 2016 19:52:45 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH v3 kernel 0/7] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Date: Tue, 9 Aug 2016 02:52:41 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E0421A844@shsmsx102.ccr.corp.intel.com>
References: <1470638134-24149-1-git-send-email-liang.z.li@intel.com>
 <57A8B03E.4080709@intel.com>
In-Reply-To: <57A8B03E.4080709@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>

> Subject: Re: [PATCH v3 kernel 0/7] Extend virtio-balloon for fast (de)inf=
lating
> & fast live migration
>=20
> On 08/07/2016 11:35 PM, Liang Li wrote:
> > Dave Hansen suggested a new scheme to encode the data structure,
> > because of additional complexity, it's not implemented in v3.
>=20
> FWIW, I don't think it takes any additional complexity here, at least in =
the
> guest implementation side.  The thing I suggested would just mean explici=
tly
> calling out that there was a single bitmap instead of implying it in the =
ABI.
>=20
> Do you think the scheme I suggested is the way to go?

Yes, I think so.  And I will do that in the later version. In this V3, I ju=
st want to solve the=20
issue caused by a large page bitmap in v2.

Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
