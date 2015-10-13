Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6060E6B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 20:09:10 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so167345172wic.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 17:09:09 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id p6si19339193wia.41.2015.10.12.17.09.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 17:09:09 -0700 (PDT)
Received: by wieq12 with SMTP id q12so6317360wie.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 17:09:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151011125935.GA3726@lst.de>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
	<20151010005528.17221.4466.stgit@dwillia2-desk3.jf.intel.com>
	<20151011125935.GA3726@lst.de>
Date: Mon, 12 Oct 2015 17:09:08 -0700
Message-ID: <CAPcyv4ht4y7_ed92U+GpS6M-Ei+95FTAMW+owPM7S5FCLip2og@mail.gmail.com>
Subject: Re: [PATCH v2 01/20] block: generic request_queue reference counting
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Keith Busch <keith.busch@intel.com>, Linux MM <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Sun, Oct 11, 2015 at 5:59 AM, Christoph Hellwig <hch@lst.de> wrote:
> Looks good,
>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
>
> We could still clean up draing or only release the reference on
> bio_done, but let's do that separately and get this infrastructure in
> ASAP.

Thanks Christoph.

Jens, do you want to take this, or ok for me to take this through nvdimm.git?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
