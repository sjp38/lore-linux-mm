Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 55D536B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 07:32:09 -0400 (EDT)
Received: by igxx6 with SMTP id x6so7225993igx.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 04:32:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id kj8si1993358igb.28.2015.09.25.04.32.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 04:32:08 -0700 (PDT)
Date: Fri, 25 Sep 2015 04:32:06 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 08/15] block, dax, pmem: reference counting infrastructure
Message-ID: <20150925113206.GA22272@infradead.org>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
 <20150923044155.36490.2017.stgit@dwillia2-desk3.jf.intel.com>
 <20150924151503.GF24375@infradead.org>
 <CAPcyv4g9TFnUK_=Nk+b3_QMX4nUiGN9RN1PnT2zwLv_NgLExLQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4g9TFnUK_=Nk+b3_QMX4nUiGN9RN1PnT2zwLv_NgLExLQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, linux-nvdimm <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu, Sep 24, 2015 at 05:03:18PM -0700, Dan Williams wrote:
> That makes sense to me, especially because drivers/nvdimm/blk.c is
> broken in the same way as drivers/nvdimm/pmem.c and it would be
> awkward to have it use blk_dax_get() / blk_dax_put().  The
> percpu_refcount should be valid for all queues and it will only ever
> be > 1 in the blk_mq and libnvdimm cases (for now).  Will fix.

Looking at this a bit more it might actually make sense to grab the
referene in common code before calling into ->make_request.

Jens, any opinion on that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
