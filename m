Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 57A616B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 09:12:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x5-v6so10838394edh.8
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 06:12:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q9-v6si436435edh.327.2018.07.12.06.12.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 06:12:32 -0700 (PDT)
Date: Thu, 12 Jul 2018 15:12:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v35 1/5] mm: support to get hints of free page blocks
Message-ID: <20180712131229.GM32648@dhcp22.suse.cz>
References: <1531215067-35472-1-git-send-email-wei.w.wang@intel.com>
 <1531215067-35472-2-git-send-email-wei.w.wang@intel.com>
 <CA+55aFz9a=D-kquM=sG5uhV_HrBAw+VAhcJmtPNz+howy4j9ow@mail.gmail.com>
 <5B455D50.90902@intel.com>
 <CA+55aFzqj8wxXnHAdUTiOomipgFONVbqKMjL_tfk7e5ar1FziQ@mail.gmail.com>
 <20180711092152.GE20050@dhcp22.suse.cz>
 <CA+55aFwku2tDH4+rfaC67xc4-cEwSrXgnQaci=e2id5ZCRE9JQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwku2tDH4+rfaC67xc4-cEwSrXgnQaci=e2id5ZCRE9JQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, virtualization <virtualization@lists.linux-foundation.org>, KVM list <kvm@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Michael S. Tsirkin" <mst@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, Rik van Riel <riel@redhat.com>, peterx@redhat.com

[Hmm this one somehow got stuck in my outgoing emails]

On Wed 11-07-18 09:23:54, Linus Torvalds wrote:
[...]
> So I'm open to new interfaces. I just want those new interfaces to
> make sense, and be low latency and simple for the VM to do. I'm
> objecting to the incredibly baroque and heavy-weight one that can
> return near-infinite amounts of memory.

Mel was suggesting a bulk page allocator a year ago [1]. I can see only
slab bulk api so I am not sure what happened with that work. Anyway
I think that starting with what we have right now is much more
appropriate than over design this thing from the early beginning.

[1] http://lkml.kernel.org/r/20170109163518.6001-5-mgorman@techsingularity.net
-- 
Michal Hocko
SUSE Labs
