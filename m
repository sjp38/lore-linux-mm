Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id AB9DF800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 12:33:14 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id m66so2642010oig.13
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 09:33:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p24si1140552oth.66.2018.01.24.09.33.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 09:33:13 -0800 (PST)
Date: Wed, 24 Jan 2018 19:32:59 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v23 2/2] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
Message-ID: <20180124193217-mutt-send-email-mst@kernel.org>
References: <1516762227-36346-1-git-send-email-wei.w.wang@intel.com>
 <1516762227-36346-3-git-send-email-wei.w.wang@intel.com>
 <20180124064923-mutt-send-email-mst@kernel.org>
 <5A681E03.1030007@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A681E03.1030007@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On Wed, Jan 24, 2018 at 01:47:47PM +0800, Wei Wang wrote:
> On 01/24/2018 01:01 PM, Michael S. Tsirkin wrote:
> > On Wed, Jan 24, 2018 at 10:50:27AM +0800, Wei Wang wrote:
> > This will not DTRT in all cases. It's quite possible
> > that host does not need the kick when ring is half full but
> > does need it later when ring is full.
> > You can kick at ring half full as optimization but you absolutely
> > still must kick on ring full. Something like:
> > 
> > if (vq->num_free == virtqueue_get_vring_size(vq) / 2 ||
> > 	vq->num_free <= 2)
> 
> Right. Would "if (vq->num_free < virtqueue_get_vring_size(vq) / 2" be
> better?
> 
> 
> Best,
> Wei

It gives more kicks ... this reminds me, you need to validate
that vring size is at least 2, otherwise fail probe.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
