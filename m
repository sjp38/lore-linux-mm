Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1DB636B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 22:00:19 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d12-v6so3879873pgv.12
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 19:00:19 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 80-v6si5392675pgf.604.2018.07.27.19.00.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 19:00:17 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v2 0/2] virtio-balloon: some improvements
Date: Sat, 28 Jul 2018 02:00:13 +0000
Message-ID: <286AC319A985734F985F78AFA26841F7397114A2@SHSMSX101.ccr.corp.intel.com>
References: <1532683495-31974-1-git-send-email-wei.w.wang@intel.com>
 <20180727170605-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180727170605-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Friday, July 27, 2018 10:06 PM, Michael S. Tsirkin wrote:
> On Fri, Jul 27, 2018 at 05:24:53PM +0800, Wei Wang wrote:
> > This series is split from the "Virtio-balloon: support free page
> > reporting" series to make some improvements.
> >
> > v1->v2 ChangeLog:
> > - register the shrinker when VIRTIO_BALLOON_F_DEFLATE_ON_OOM is
> negotiated.
> >
> > Wei Wang (2):
> >   virtio-balloon: remove BUG() in init_vqs
> >   virtio_balloon: replace oom notifier with shrinker
>=20
> Thanks!
> Given it's very late in the release cycle, I'll merge this for the next L=
inux
> release.

No problem. Thanks!

Best,
Wei
