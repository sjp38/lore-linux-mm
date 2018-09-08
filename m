Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id DEBE38E0001
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 21:46:07 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d40-v6so7778298pla.14
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 18:46:07 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id y4-v6si10014269pgo.390.2018.09.07.18.46.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 18:46:06 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v36 0/5] Virtio-balloon: support free page reporting
Date: Sat, 8 Sep 2018 01:46:02 +0000
Message-ID: <286AC319A985734F985F78AFA26841F7397924FE@shsmsx102.ccr.corp.intel.com>
References: <1532075585-39067-1-git-send-email-wei.w.wang@intel.com>
 <20180723122342-mutt-send-email-mst@kernel.org>
 <20180723143604.GB2457@work-vm> <5B911B03.2060602@intel.com>
 <20180907122955.GD2544@work-vm>
In-Reply-To: <20180907122955.GD2544@work-vm>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "peterx@redhat.com" <peterx@redhat.com>

On Friday, September 7, 2018 8:30 PM, Dr. David Alan Gilbert wrote:
> OK, that's much better.
> The ~50% reducton with a 8G VM and a real workload is great, and it does
> what you expect when you put a lot more RAM in and see the 84% reduction
> on a guest with 128G RAM - 54s vs ~9s is a big win!
>=20
> (The migrate_set_speed is a bit high, since that's in bytes/s - but it's =
not
> important).
>=20
> That looks good,
>=20

Thanks Dave for the feedback.
Hope you can join our discussion and review the v37 patches as well.

Best,
Wei
