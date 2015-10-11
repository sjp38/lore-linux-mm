Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id A03EC6B0038
	for <linux-mm@kvack.org>; Sun, 11 Oct 2015 08:59:37 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so21314804wic.1
        for <linux-mm@kvack.org>; Sun, 11 Oct 2015 05:59:37 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id ho2si13625715wjb.204.2015.10.11.05.59.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Oct 2015 05:59:36 -0700 (PDT)
Date: Sun, 11 Oct 2015 14:59:35 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v2 01/20] block: generic request_queue reference
	counting
Message-ID: <20151011125935.GA3726@lst.de>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com> <20151010005528.17221.4466.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151010005528.17221.4466.stgit@dwillia2-desk3.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Jens Axboe <axboe@kernel.dk>, linux-kernel@vger.kernel.org, Keith Busch <keith.busch@intel.com>, linux-mm@kvack.org, ross.zwisler@linux.intel.com

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

We could still clean up draing or only release the reference on
bio_done, but let's do that separately and get this infrastructure in
ASAP.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
