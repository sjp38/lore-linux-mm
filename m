Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 60FA4800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 00:45:19 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id s22so2153357pfh.21
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 21:45:19 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id m17-v6si5626591pls.212.2018.01.23.21.45.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 21:45:18 -0800 (PST)
Message-ID: <5A681E03.1030007@intel.com>
Date: Wed, 24 Jan 2018 13:47:47 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v23 2/2] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
References: <1516762227-36346-1-git-send-email-wei.w.wang@intel.com> <1516762227-36346-3-git-send-email-wei.w.wang@intel.com> <20180124064923-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180124064923-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On 01/24/2018 01:01 PM, Michael S. Tsirkin wrote:
> On Wed, Jan 24, 2018 at 10:50:27AM +0800, Wei Wang wrote:
> This will not DTRT in all cases. It's quite possible
> that host does not need the kick when ring is half full but
> does need it later when ring is full.
> You can kick at ring half full as optimization but you absolutely
> still must kick on ring full. Something like:
>
> if (vq->num_free == virtqueue_get_vring_size(vq) / 2 ||
> 	vq->num_free <= 2)

Right. Would "if (vq->num_free < virtqueue_get_vring_size(vq) / 2" be 
better?


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
