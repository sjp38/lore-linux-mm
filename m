Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5A5F86B0033
	for <linux-mm@kvack.org>; Sat,  2 Dec 2017 20:51:25 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id h52so7475655otd.1
        for <linux-mm@kvack.org>; Sat, 02 Dec 2017 17:51:25 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u85si3166636oie.493.2017.12.02.17.51.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 02 Dec 2017 17:51:24 -0800 (PST)
Subject: Re: [PATCH v18 05/10] xbitmap: add more operations
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201711301934.CDC21800.FSLtJFFOOVQHMO@I-love.SAKURA.ne.jp>
	<5A210C96.8050208@intel.com>
	<201712012202.BDE13557.MJFQLtOOHVOFSF@I-love.SAKURA.ne.jp>
	<286AC319A985734F985F78AFA26841F739376DA1@shsmsx102.ccr.corp.intel.com>
	<20171201172519.GA27192@bombadil.infradead.org>
In-Reply-To: <20171201172519.GA27192@bombadil.infradead.org>
Message-Id: <201712031050.IAC64520.QVLFFOOJOSFtHM@I-love.SAKURA.ne.jp>
Date: Sun, 3 Dec 2017 10:50:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, wei.w.wang@intel.com
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

Matthew Wilcox wrote:
> On Fri, Dec 01, 2017 at 03:09:08PM +0000, Wang, Wei W wrote:
> > On Friday, December 1, 2017 9:02 PM, Tetsuo Handa wrote:
> > > If start == end is legal,
> > > 
> > >    for (; start < end; start = (start | (IDA_BITMAP_BITS - 1)) + 1) {
> > > 
> > > makes this loop do nothing because 10 < 10 is false.
> > 
> > How about "start <= end "?
> 
> Don't ask Tetsuo for his opinion, write some userspace code that uses it.
> 

Please be sure to prepare for "end == -1UL" case, for "start < end" will become
true when "start = (start | (IDA_BITMAP_BITS - 1)) + 1" made "start == 0" due to
overflow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
