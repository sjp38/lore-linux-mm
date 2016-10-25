Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3664D6B0282
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 21:14:09 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fl2so5747043pad.7
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 18:14:09 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i89si18053251pfj.295.2016.10.24.18.14.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 18:14:08 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RESEND PATCH v3 kernel 1/7] virtio-balloon: rework deflate to
 add page to a list
Date: Tue, 25 Oct 2016 01:14:04 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A0FB4D6@shsmsx102.ccr.corp.intel.com>
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
 <1477031080-12616-2-git-send-email-liang.z.li@intel.com>
 <580E3ACD.1080906@intel.com>
In-Reply-To: <580E3ACD.1080906@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "mst@redhat.com" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>

> On 10/20/2016 11:24 PM, Liang Li wrote:
> > Will allow faster notifications using a bitmap down the road.
> > balloon_pfn_to_page() can be removed because it's useless.
>=20
> This is a pretty terse description of what's going on here.  Could you tr=
y to
> elaborate a bit?  What *is* the current approach?  Why does it not work
> going forward?  What do you propose instead?  Why is it better?

Sure. The description will be more clear if it's described as you suggest. =
Thanks!

Liang=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
