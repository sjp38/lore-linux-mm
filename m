Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id F24C56B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 10:03:42 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g2so17972517qtp.5
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 07:03:42 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l3si62930qkh.35.2018.04.05.07.03.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 07:03:42 -0700 (PDT)
Date: Thu, 5 Apr 2018 17:03:40 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v30 2/4] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
Message-ID: <20180405170248-mutt-send-email-mst@kernel.org>
References: <1522771805-78927-1-git-send-email-wei.w.wang@intel.com>
 <1522771805-78927-3-git-send-email-wei.w.wang@intel.com>
 <20180403214147-mutt-send-email-mst@kernel.org>
 <5AC43377.2070607@intel.com>
 <20180404155907-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F7394A6E96@shsmsx102.ccr.corp.intel.com>
 <20180405040900-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F7394A7F3B@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <286AC319A985734F985F78AFA26841F7394A7F3B@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Wei W" <wei.w.wang@intel.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "huangzhichao@huawei.com" <huangzhichao@huawei.com>

On Thu, Apr 05, 2018 at 02:05:03AM +0000, Wang, Wei W wrote:
> On Thursday, April 5, 2018 9:12 AM, Michael S. Tsirkin wrote:
> > On Thu, Apr 05, 2018 at 12:30:27AM +0000, Wang, Wei W wrote:
> > > On Wednesday, April 4, 2018 10:08 PM, Michael S. Tsirkin wrote:
> > > > On Wed, Apr 04, 2018 at 10:07:51AM +0800, Wei Wang wrote:
> > > > > On 04/04/2018 02:47 AM, Michael S. Tsirkin wrote:
> > > > > > On Wed, Apr 04, 2018 at 12:10:03AM +0800, Wei Wang wrote:
> > > I'm afraid the driver couldn't be aware if the added hints are stale
> > > or not,
> > 
> > 
> > No - I mean that driver has code that compares two values and stops
> > reporting. Can one of the values be stale?
> 
> The driver compares "vb->cmd_id_use != vb->cmd_id_received" to decide if it needs to stop reporting hints, and cmd_id_received is what the driver reads from host (host notifies the driver to read for the latest value). If host sends a new cmd id, it will notify the guest to read again. I'm not sure how that could be a stale cmd id (or maybe I misunderstood your point here?)
> 
> Best,
> Wei

The comparison is done in one thread, the update in another one.

-- 
MST
