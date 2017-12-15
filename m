Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4506B0033
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 13:43:41 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a13so7579177pgt.0
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 10:43:41 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id j8si5443419pli.353.2017.12.15.10.43.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 10:43:40 -0800 (PST)
Date: Fri, 15 Dec 2017 10:42:56 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v19 3/7] xbitmap: add more operations
Message-ID: <20171215184256.GA27160@bombadil.infradead.org>
References: <1513079759-14169-1-git-send-email-wei.w.wang@intel.com>
 <1513079759-14169-4-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513079759-14169-4-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On Tue, Dec 12, 2017 at 07:55:55PM +0800, Wei Wang wrote:
> +int xb_preload_and_set_bit(struct xb *xb, unsigned long bit, gfp_t gfp);

I'm struggling to understand when one would use this.  The xb_ API
requires you to handle your own locking.  But specifying GFP flags
here implies you can sleep.  So ... um ... there's no locking?

> +void xb_clear_bit_range(struct xb *xb, unsigned long start, unsigned long end);

That's xb_zero() which you deleted with the previous patch ... remember,
keep things as close as possible to the bitmap API.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
