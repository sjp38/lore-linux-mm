Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD0C2806CB
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 16:44:16 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id c18so57235054ioa.23
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 13:44:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t138si10076823ita.48.2017.04.13.13.44.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 13:44:15 -0700 (PDT)
Date: Thu, 13 Apr 2017 13:44:11 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v9 0/5] Extend virtio-balloon for fast (de)inflating &
 fast live migration
Message-ID: <20170413204411.GJ784@bombadil.infradead.org>
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On Thu, Apr 13, 2017 at 05:35:03PM +0800, Wei Wang wrote:
> 2) transfer the guest unused pages to the host so that they
> can be skipped to migrate in live migration.

I don't understand this second bit.  You leave the pages on the free list,
and tell the host they're free.  What's preventing somebody else from
allocating them and using them for something?  Is the guest semi-frozen
at this point with just enough of it running to ask the balloon driver
to do things?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
