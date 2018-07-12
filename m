Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B78226B0006
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 22:30:38 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id t11-v6so23944878iog.15
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 19:30:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k78-v6sor792011iod.146.2018.07.11.19.30.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 19:30:37 -0700 (PDT)
MIME-Version: 1.0
References: <1531215067-35472-1-git-send-email-wei.w.wang@intel.com>
 <1531215067-35472-2-git-send-email-wei.w.wang@intel.com> <CA+55aFz9a=D-kquM=sG5uhV_HrBAw+VAhcJmtPNz+howy4j9ow@mail.gmail.com>
 <5B455D50.90902@intel.com> <CA+55aFzqj8wxXnHAdUTiOomipgFONVbqKMjL_tfk7e5ar1FziQ@mail.gmail.com>
 <20180711092152.GE20050@dhcp22.suse.cz> <CA+55aFwku2tDH4+rfaC67xc4-cEwSrXgnQaci=e2id5ZCRE9JQ@mail.gmail.com>
 <5B46BB46.2080802@intel.com>
In-Reply-To: <5B46BB46.2080802@intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 11 Jul 2018 19:30:26 -0700
Message-ID: <CA+55aFxyv=EUAJFUSio=k+pm3ddteojshP7Radjia5ZRgm53zQ@mail.gmail.com>
Subject: Re: [PATCH v35 1/5] mm: support to get hints of free page blocks
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com
Cc: Michal Hocko <mhocko@kernel.org>, virtio-dev@lists.oasis-open.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, virtualization <virtualization@lists.linux-foundation.org>, KVM list <kvm@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Michael S. Tsirkin" <mst@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, Rik van Riel <riel@redhat.com>, peterx@redhat.com

On Wed, Jul 11, 2018 at 7:17 PM Wei Wang <wei.w.wang@intel.com> wrote:
>
> Would it be better to remove __GFP_THISNODE? We actually want to get all
> the guest free pages (from all the nodes).

Maybe. Or maybe it would be better to have the memory balloon logic be
per-node? Maybe you don't want to remove too much memory from one
node? I think it's one of those "play with it" things.

I don't think that's the big issue, actually. I think the real issue
is how to react quickly and gracefully to "oops, I'm trying to give
memory away, but now the guest wants it back" while you're in the
middle of trying to create that 2TB list of pages.

IOW, I think the real work is in whatever tuning for the righ
tbehavior. But I'm just guessing.

             Linus
