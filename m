Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 825AB6B027B
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 02:46:42 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id gg9so37984272pac.6
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 23:46:42 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id g68si12050491pfc.88.2016.10.27.23.46.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 23:46:41 -0700 (PDT)
Date: Thu, 27 Oct 2016 23:46:39 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/3] iopmem : Add documentation for iopmem driver
Message-ID: <20161028064639.GB3231@infradead.org>
References: <1476826937-20665-1-git-send-email-sbates@raithlin.com>
 <1476826937-20665-4-git-send-email-sbates@raithlin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1476826937-20665-4-git-send-email-sbates@raithlin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Bates <stephen.bates@microsemi.com>
Cc: linux-kernel@vger.kernel.org, linux-nvdimm@ml01.01.org, linux-rdma@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, dan.j.williams@intel.com, ross.zwisler@linux.intel.com, willy@linux.intel.com, jgunthorpe@obsidianresearch.com, haggaie@mellanox.com, hch@infradead.org, axboe@fb.com, corbet@lwn.net, jim.macdonald@everspin.com, sbates@raithin.com, logang@deltatee.com

I'd say please fold this into the previous patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
