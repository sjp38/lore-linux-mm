Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2EF256B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 09:40:00 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id m9so5055588pff.0
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 06:40:00 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v187si3328234pfv.227.2017.11.30.06.39.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 06:39:59 -0800 (PST)
Date: Thu, 30 Nov 2017 06:39:52 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v18 05/10] xbitmap: add more operations
Message-ID: <20171130143952.GB12684@bombadil.infradead.org>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
 <1511963726-34070-6-git-send-email-wei.w.wang@intel.com>
 <201711301934.CDC21800.FSLtJFFOOVQHMO@I-love.SAKURA.ne.jp>
 <201711302235.FAJ57385.OFJHOVQOFtMSFL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711302235.FAJ57385.OFJHOVQOFtMSFL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On Thu, Nov 30, 2017 at 10:35:03PM +0900, Tetsuo Handa wrote:
> According to xb_set_bit(), it seems to me that we are trying to avoid memory allocation
> for "struct ida_bitmap" when all set bits within a 1024-bits bitmap reside in the first
> 61 bits.
> 
> But does such saving help? Is there characteristic bias that majority of set bits resides
> in the first 61 bits, for "bit" is "unsigned long" which holds a page number (isn't it)?
> If no such bias, wouldn't eliminating radix_tree_exception() case and always storing
> "struct ida_bitmap" simplifies the code (and make the processing faster)?

It happens all the time.  The vast majority of users of the IDA set
low bits.  Also, it's the first 62 bits -- going up to 63 bits with the
XArray rewrite.

I do plan to redo the xbitmap on top of the XArray; I'm just trying to
get the XArray merged first.  The IDA and xbitmap code will share much
more code when that happens.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
