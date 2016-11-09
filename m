Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 71FF26B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 16:23:47 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id q124so401662301itd.2
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 13:23:47 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 141si1138187itm.68.2016.11.09.13.23.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 13:23:46 -0800 (PST)
Date: Wed, 9 Nov 2016 16:23:41 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [swiotlb PATCH v3 0/3] Add support for DMA writable pages being
 writable by the network stack.
Message-ID: <20161109212341.GC12670@char.us.oracle.com>
References: <20161109151639.25151.24290.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161109151639.25151.24290.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Nov 09, 2016 at 10:19:57AM -0500, Alexander Duyck wrote:
> This patch series is a subset of the patches originally submitted with the
> above patch title.  Specifically all of these patches relate to the
> swiotlb.
> 
> I wasn't sure if I needed to resubmit this series or not.  I see that v2 is
> currently sitting in the for-linus-4.9 branch of the swiotlb git repo.  If
> no updates are required for the previous set then this patch set can be
> ignored since most of the changes are just cosmetic.

I already had tested v2 so if you have patches that you want to put on top
of that please do send them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
