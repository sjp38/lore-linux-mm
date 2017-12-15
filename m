Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CE1DE6B0038
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 08:24:12 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id w5so6994318pgt.4
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 05:24:12 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t85si4576600pgb.154.2017.12.15.05.24.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 05:24:11 -0800 (PST)
Date: Fri, 15 Dec 2017 05:24:05 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v19 1/7] xbitmap: Introduce xbitmap
Message-ID: <20171215132405.GB10348@bombadil.infradead.org>
References: <1513079759-14169-2-git-send-email-wei.w.wang@intel.com>
 <201712151837.MQq7hdgk%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712151837.MQq7hdgk%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Wei Wang <wei.w.wang@intel.com>, kbuild-all@01.org, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On Fri, Dec 15, 2017 at 07:05:07PM +0800, kbuild test robot wrote:
>     21		struct radix_tree_node *node;
>     22		void **slot;
                             ^^^
missing __rcu annotation here.

Wei, could you fold that change into your next round?  Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
