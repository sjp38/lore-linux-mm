Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6F36B0003
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 15:36:55 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id f8-v6so27669998qtb.23
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 12:36:55 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id i11-v6si490301qvb.29.2018.07.11.12.36.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 12:36:54 -0700 (PDT)
Date: Wed, 11 Jul 2018 22:36:50 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v35 1/5] mm: support to get hints of free page blocks
Message-ID: <20180711223040-mutt-send-email-mst@kernel.org>
References: <1531215067-35472-1-git-send-email-wei.w.wang@intel.com>
 <1531215067-35472-2-git-send-email-wei.w.wang@intel.com>
 <CA+55aFz9a=D-kquM=sG5uhV_HrBAw+VAhcJmtPNz+howy4j9ow@mail.gmail.com>
 <5B455D50.90902@intel.com>
 <CA+55aFzqj8wxXnHAdUTiOomipgFONVbqKMjL_tfk7e5ar1FziQ@mail.gmail.com>
 <20180711092152.GE20050@dhcp22.suse.cz>
 <5B45E17D.2090205@intel.com>
 <20180711110949.GJ20050@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180711110949.GJ20050@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Wang <wei.w.wang@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, virtio-dev@lists.oasis-open.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, virtualization <virtualization@lists.linux-foundation.org>, KVM list <kvm@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, Rik van Riel <riel@redhat.com>, peterx@redhat.com

On Wed, Jul 11, 2018 at 01:09:49PM +0200, Michal Hocko wrote:
> But let me note that I am not really convinced how this (or previous)
> approach will really work in most workloads. We tend to cache heavily so
> there is rarely any memory free.

It might be that it's worth flushing the cache when VM is
migrating. Or maybe we should implement virtio-tmem or add
transcendent memory support to the balloon.

-- 
MST
