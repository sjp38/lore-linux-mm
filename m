Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4BCBE6B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 20:36:08 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id r13so11641308pag.1
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 17:36:08 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id y9si5121474pfa.215.2016.10.26.17.36.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Oct 2016 17:36:07 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RESEND PATCH v3 kernel 0/7] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Date: Thu, 27 Oct 2016 00:36:02 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A0FEB80@shsmsx102.ccr.corp.intel.com>
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
 <580A4F81.60201@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A0FD034@shsmsx102.ccr.corp.intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A0FD05E@shsmsx102.ccr.corp.intel.com>
 <5810F2A4.6080907@intel.com>
In-Reply-To: <5810F2A4.6080907@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "mst@redhat.com" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>

> Cc: linux-kernel@vger.kernel.org; virtualization@lists.linux-foundation.o=
rg;
> linux-mm@kvack.org; virtio-dev@lists.oasis-open.org; kvm@vger.kernel.org;
> qemu-devel@nongnu.org; quintela@redhat.com; dgilbert@redhat.com;
> pbonzini@redhat.com; cornelia.huck@de.ibm.com; amit.shah@redhat.com
> Subject: Re: [RESEND PATCH v3 kernel 0/7] Extend virtio-balloon for fast
> (de)inflating & fast live migration
>=20
> On 10/26/2016 03:13 AM, Li, Liang Z wrote:
> > 3 times memory required is not accurate, please ignore this. sorry ...
> > The complexity is the point.
>=20
> What is making it so complex?  Can you describe the problems?

I plan to complete it first and send out the patch set,  then discuss if it=
 worth.  I need some time.

Thanks!
Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
