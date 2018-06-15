Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CBC6C6B000A
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 10:28:53 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o19-v6so3452172pgn.14
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 07:28:53 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id e9-v6si9156915pli.337.2018.06.15.07.28.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 07:28:52 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v33 0/4] Virtio-balloon: support free page reporting
Date: Fri, 15 Jun 2018 14:28:49 +0000
Message-ID: <286AC319A985734F985F78AFA26841F7396A3DC9@shsmsx102.ccr.corp.intel.com>
References: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com>
 <20180615142610-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180615142610-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "peterx@redhat.com" <peterx@redhat.com>

On Friday, June 15, 2018 7:30 PM, Michael S. Tsirkin wrote:
> On Fri, Jun 15, 2018 at 12:43:09PM +0800, Wei Wang wrote:
> >       - remove the cmd id related interface. Now host can just send a f=
ree
> >         page hint command to the guest (via the host_cmd config registe=
r)
> >         to start the reporting.
>=20
> Here we go again. And what if reporting was already started previously?
> I don't think it's a good idea to tweak the host/guest interface yet agai=
n.

This interface is much simpler, and I'm not sure if that would be an issue =
here now, because
now the guest delivers the whole buffer of hints to host once, instead of h=
int by hint as before. And the guest notifies host after the buffer is deli=
vered. In any case, the host doorbell handler will be invoked, if host does=
n't need the hints at that time, it will just give back the buffer. There w=
ill be no stale hints remained in the ring now.

Best,
Wei
