Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF506B0003
	for <linux-mm@kvack.org>; Sun, 22 Jul 2018 07:12:05 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 66-v6so11053253plb.18
        for <linux-mm@kvack.org>; Sun, 22 Jul 2018 04:12:05 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id d31-v6si5760819pla.190.2018.07.22.04.12.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jul 2018 04:12:03 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v36 0/5] Virtio-balloon: support free page reporting
Date: Sun, 22 Jul 2018 11:11:59 +0000
Message-ID: <286AC319A985734F985F78AFA26841F739702695@SHSMSX101.ccr.corp.intel.com>
References: <1532075585-39067-1-git-send-email-wei.w.wang@intel.com>
 <20180720154922-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180720154922-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "peterx@redhat.com" <peterx@redhat.com>

On Friday, July 20, 2018 8:52 PM, Michael S. Tsirkin wrote:
> On Fri, Jul 20, 2018 at 04:33:00PM +0800, Wei Wang wrote:
> > This patch series is separated from the previous "Virtio-balloon
> > Enhancement" series. The new feature,
> VIRTIO_BALLOON_F_FREE_PAGE_HINT,
> > implemented by this series enables the virtio-balloon driver to report
> > hints of guest free pages to the host. It can be used to accelerate
> > live migration of VMs. Here is an introduction of this usage:
> >
> > Live migration needs to transfer the VM's memory from the source
> > machine to the destination round by round. For the 1st round, all the
> > VM's memory is transferred. From the 2nd round, only the pieces of
> > memory that were written by the guest (after the 1st round) are
> > transferred. One method that is popularly used by the hypervisor to
> > track which part of memory is written is to write-protect all the guest
> memory.
> >
> > This feature enables the optimization by skipping the transfer of
> > guest free pages during VM live migration. It is not concerned that
> > the memory pages are used after they are given to the hypervisor as a
> > hint of the free pages, because they will be tracked by the hypervisor
> > and transferred in the subsequent round if they are used and written.
> >
> > * Tests
> > - Test Environment
> >     Host: Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz
> >     Guest: 8G RAM, 4 vCPU
> >     Migration setup: migrate_set_speed 100G, migrate_set_downtime 2
> > second
>=20
> Can we split out patches 1 and 2? They seem appropriate for this release =
...

Sounds good to me. I'm not sure if there would be comments on the first 2 p=
atches. If no, can you just take them here? Or you need me to repost them s=
eparately?

Best,
Wei
