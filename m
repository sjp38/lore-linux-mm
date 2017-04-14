Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 537C86B0390
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 22:58:29 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id r16so63359505ioi.7
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 19:58:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o1si1131811iof.28.2017.04.13.19.58.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 19:58:28 -0700 (PDT)
Date: Thu, 13 Apr 2017 19:58:24 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v9 3/5] mm: function to offer a page block on the free
 list
Message-ID: <20170414025824.GK784@bombadil.infradead.org>
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
 <1492076108-117229-4-git-send-email-wei.w.wang@intel.com>
 <20170413130217.2316b0394192d8677f5ddbdf@linux-foundation.org>
 <58F03443.9040202@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58F03443.9040202@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On Fri, Apr 14, 2017 at 10:30:27AM +0800, Wei Wang wrote:
> OK. What do you think if we add this:
> 
> #if defined(CONFIG_VIRTIO_BALLOON) || defined(CONFIG_VIRTIO_BALLOON_MODULE)

That's spelled "IS_ENABLED(CONFIG_VIRTIO_BALLOON)", FYI.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
