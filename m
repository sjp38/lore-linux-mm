Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D2F1F6B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 09:13:19 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g8so5306602pgs.14
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 06:13:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id j185si4831252pgd.620.2017.12.01.06.13.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 06:13:18 -0800 (PST)
Date: Fri, 1 Dec 2017 06:13:07 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v18 05/10] xbitmap: add more operations
Message-ID: <20171201141307.GA4722@bombadil.infradead.org>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
 <1511963726-34070-6-git-send-email-wei.w.wang@intel.com>
 <201711301934.CDC21800.FSLtJFFOOVQHMO@I-love.SAKURA.ne.jp>
 <5A210C96.8050208@intel.com>
 <201712012202.BDE13557.MJFQLtOOHVOFSF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712012202.BDE13557.MJFQLtOOHVOFSF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On Fri, Dec 01, 2017 at 10:02:01PM +0900, Tetsuo Handa wrote:
> If start == end is legal,
> 
>    for (; start < end; start = (start | (IDA_BITMAP_BITS - 1)) + 1) {
> 
> makes this loop do nothing because 10 < 10 is false.

... and this is why we add tests to the test-suite!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
