Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5646B0006
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 11:04:10 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id j68so9447505oih.14
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 08:04:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o29si7263647otd.84.2018.02.01.08.04.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 08:04:09 -0800 (PST)
Date: Thu, 1 Feb 2018 18:03:52 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [virtio-dev] Re: [PATCH v25 2/2] virtio-balloon:
 VIRTIO_BALLOON_F_FREE_PAGE_HINT
Message-ID: <20180201175115-mutt-send-email-mst@kernel.org>
References: <1516871646-22741-1-git-send-email-wei.w.wang@intel.com>
 <1516871646-22741-3-git-send-email-wei.w.wang@intel.com>
 <20180125154708-mutt-send-email-mst@kernel.org>
 <5A6A871C.6040408@intel.com>
 <20180126042649-mutt-send-email-mst@kernel.org>
 <5A6AA107.3000607@intel.com>
 <20180131011423-mutt-send-email-mst@kernel.org>
 <5A72E13A.9030701@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A72E13A.9030701@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>

On Thu, Feb 01, 2018 at 05:43:22PM +0800, Wei Wang wrote:
> 3) Hints means the pages are quite likely to be free pages (no guarantee).
> If the pages given to host are going to be freed, then we really couldn't
> call them hints, they are true free pages. Ballooning needs true free pages,
> while live migration needs hints, would you agree with this?

It's an interesting point, I'm convinced by it.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
