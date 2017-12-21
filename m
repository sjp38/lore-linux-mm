Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id F07856B025E
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 07:14:45 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 33so11483595pll.9
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 04:14:45 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x2si13361178pgr.500.2017.12.21.04.14.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Dec 2017 04:14:44 -0800 (PST)
Date: Thu, 21 Dec 2017 04:14:37 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v20 0/7] Virtio-balloon Enhancement
Message-ID: <20171221121437.GA22405@bombadil.infradead.org>
References: <1513685879-21823-1-git-send-email-wei.w.wang@intel.com>
 <201712192305.AAE21882.MtQHJOFFSFVOLO@I-love.SAKURA.ne.jp>
 <5A3A3CBC.4030202@intel.com>
 <20171220122547.GA1654@bombadil.infradead.org>
 <286AC319A985734F985F78AFA26841F73938CC3E@shsmsx102.ccr.corp.intel.com>
 <20171220171019.GA12236@bombadil.infradead.org>
 <5A3B2148.8050306@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A3B2148.8050306@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mst@redhat.com" <mst@redhat.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>

On Thu, Dec 21, 2017 at 10:49:44AM +0800, Wei Wang wrote:
> On 12/21/2017 01:10 AM, Matthew Wilcox wrote:
> One more question is about the return value, why would it be ambiguous? I
> think it is the same as find_next_bit() which returns the found bit or size
> if not found.

Because find_next_bit doesn't reasonably support a bitmap which is
ULONG_MAX in size.  The point of XBitmap is to support a bitmap which
is ULONG_MAX in size, so every possible return value is a legitimate
"we found a bit here".  There's no value which can possibly be used for
"no bit was found".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
