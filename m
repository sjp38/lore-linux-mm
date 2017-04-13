Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id B56A26B03AB
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 13:03:53 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id g74so53458658ioi.4
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 10:03:53 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b193si25070051iof.159.2017.04.13.10.03.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 10:03:52 -0700 (PDT)
Date: Thu, 13 Apr 2017 10:03:46 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v9 2/5] virtio-balloon: VIRTIO_BALLOON_F_BALLOON_CHUNKS
Message-ID: <20170413170346.GI784@bombadil.infradead.org>
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
 <1492076108-117229-3-git-send-email-wei.w.wang@intel.com>
 <20170413184040-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170413184040-mutt-send-email-mst@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On Thu, Apr 13, 2017 at 07:34:19PM +0300, Michael S. Tsirkin wrote:
> So we don't need the bitmap to talk to host, it is just
> a data structure we chose to maintain lists of pages, right?
> OK as far as it goes but you need much better isolation for it.
> Build a data structure with APIs such as _init, _cleanup, _add, _clear,
> _find_first, _find_next.
> Completely unrelated to pages, it just maintains bits.
> Then use it here.

That sounds an awful lot like the xbitmap I wrote a few months ago ...

http://git.infradead.org/users/willy/linux-dax.git/commit/727e401bee5ad7d37e0077291d90cc17475c6392

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
