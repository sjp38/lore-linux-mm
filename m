Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6318A6B000D
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 19:09:08 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id o1-v6so8464620ioa.20
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 16:09:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 8-v6sor929266itq.38.2018.06.15.16.09.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Jun 2018 16:09:04 -0700 (PDT)
MIME-Version: 1.0
References: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com> <1529037793-35521-2-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1529037793-35521-2-git-send-email-wei.w.wang@intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 16 Jun 2018 08:08:53 +0900
Message-ID: <CA+55aFzhuGKinEq5udPsk_uYHShkQxJYqcPO=tLCkT-oxpsgPg@mail.gmail.com>
Subject: Re: [PATCH v33 1/4] mm: add a function to get free page blocks
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com
Cc: virtio-dev@lists.oasis-open.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, virtualization <virtualization@lists.linux-foundation.org>, KVM list <kvm@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, Rik van Riel <riel@redhat.com>, peterx@redhat.com

On Fri, Jun 15, 2018 at 2:08 PM Wei Wang <wei.w.wang@intel.com> wrote:
>
> This patch adds a function to get free pages blocks from a free page
> list. The obtained free page blocks are hints about free pages, because
> there is no guarantee that they are still on the free page list after
> the function returns.

Ack. This is the kind of simple interface where I don't need to worry
about the MM code calling out to random drivers or subsystems.

I think that "order" should be checked for validity, but from a MM
standpoint I think this is fine.

                Linus
