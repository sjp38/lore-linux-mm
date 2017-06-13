Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 328416B0279
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 14:55:18 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id o21so70853047qtb.13
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 11:55:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c145si833451qke.81.2017.06.13.11.55.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 11:55:17 -0700 (PDT)
Date: Tue, 13 Jun 2017 21:55:05 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v11 3/6] virtio-balloon: VIRTIO_BALLOON_F_PAGE_CHUNKS
Message-ID: <20170613215454-mutt-send-email-mst@kernel.org>
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
 <1497004901-30593-4-git-send-email-wei.w.wang@intel.com>
 <20170613200049-mutt-send-email-mst@kernel.org>
 <fb67359c-3d19-f67f-ec47-3cf868b8d9e8@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fb67359c-3d19-f67f-ec47-3cf868b8d9e8@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, Matthew Wilcox <willy@infradead.org>

On Tue, Jun 13, 2017 at 10:59:07AM -0700, Dave Hansen wrote:
> On 06/13/2017 10:56 AM, Michael S. Tsirkin wrote:
> >> +/* The size of one page_bmap used to record inflated/deflated pages. */
> >> +#define VIRTIO_BALLOON_PAGE_BMAP_SIZE	(8 * PAGE_SIZE)
> > At this size, you probably want alloc_pages to avoid kmalloc
> > overhead.
> 
> For slub, at least, kmalloc() just calls alloc_pages() basically
> directly.  There's virtually no overhead.
> 
> 

OK then.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
