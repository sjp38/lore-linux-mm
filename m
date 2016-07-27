Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 75526828E1
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 21:32:40 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id pp5so12621925pac.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 18:32:40 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id pa7si3356062pac.177.2016.07.26.18.32.39
        for <linux-mm@kvack.org>;
        Tue, 26 Jul 2016 18:32:39 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [virtio-dev] Re: [PATCH v2 kernel 0/7] Extend virtio-balloon
 for fast (de)inflating & fast live migration
Date: Wed, 27 Jul 2016 01:32:33 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E042131A8@shsmsx102.ccr.corp.intel.com>
References: <1467196340-22079-1-git-send-email-liang.z.li@intel.com>
 <20160726215256-mutt-send-email-mst@kernel.org>
In-Reply-To: <20160726215256-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> So I'm fine with this patchset, but I noticed it was not yet reviewed by =
MM
> people. And that is not surprising since you did not copy memory
> management mailing list on it.
>=20
> I added linux-mm@kvack.org Cc on this mail but this might not be enough.
>=20
> Please repost (e.g. [PATCH v2 repost]) copying the relevant mailing list =
so we
> can get some reviews.
>=20

I will repost. Thanks!

Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
