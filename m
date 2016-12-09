Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 395156B0267
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 00:35:50 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id a8so8985562pfg.0
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 21:35:50 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id v4si32024713pgb.232.2016.12.08.21.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 21:35:49 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [PATCH kernel v5 0/5] Extend virtio-balloon for
 fast (de)inflating & fast live migration
Date: Fri, 9 Dec 2016 05:35:45 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A14E339@SHSMSX104.ccr.corp.intel.com>
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
 <f67ca79c-ad34-59dd-835f-e7bc9dcaef58@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A130C01@shsmsx102.ccr.corp.intel.com>
 <0b18c636-ee67-cbb4-1ba3-81a06150db76@redhat.com>
 <0b83db29-ebad-2a70-8d61-756d33e33a48@intel.com>
 <2171e091-46ee-decd-7348-772555d3a5e3@redhat.com>
 <d3ff453c-56fa-19de-317c-1c82456f2831@intel.com>
 <20161207183817.GE28786@redhat.com>
 <b58fd9f6-d9dd-dd56-d476-dd342174dac5@intel.com>
 <20161207202824.GH28786@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A14E2AD@SHSMSX104.ccr.corp.intel.com>
 <060287c7-d1af-45d5-70ea-ad35d4bbeb84@intel.com>
In-Reply-To: <060287c7-d1af-45d5-70ea-ad35d4bbeb84@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "mst@redhat.com" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

> On 12/08/2016 08:45 PM, Li, Liang Z wrote:
> > What's the conclusion of your discussion? It seems you want some
> > statistic before deciding whether to  ripping the bitmap from the ABI,
> > am I right?
>=20
> I think Andrea and David feel pretty strongly that we should remove the
> bitmap, unless we have some data to support keeping it.  I don't feel as
> strongly about it, but I think their critique of it is pretty valid.  I t=
hink the
> consensus is that the bitmap needs to go.
>=20

Thanks for you clarification.

> The only real question IMNHO is whether we should do a power-of-2 or a
> length.  But, if we have 12 bits, then the argument for doing length is p=
retty
> strong.  We don't need anywhere near 12 bits if doing power-of-2.
>=20
So each item can max represent 16MB Bytes, seems not big enough,
but enough for most case.
Things became much more simple without the bitmap, and I like simple soluti=
on too. :)

I will prepare the v6 and remove all the bitmap related stuffs. Thank you a=
ll!

Liang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
