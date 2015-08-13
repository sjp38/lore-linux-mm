Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 78B166B0253
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 10:41:35 -0400 (EDT)
Received: by lagz9 with SMTP id z9so27329109lag.3
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 07:41:35 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id gp9si735999wib.115.2015.08.13.07.41.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 07:41:33 -0700 (PDT)
Date: Thu, 13 Aug 2015 16:41:32 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v5 2/5] allow mapping page-less memremaped areas into
	KVA
Message-ID: <20150813144132.GC17375@lst.de>
References: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com> <20150813030109.36703.21738.stgit@otcpl-skl-sds-2.jf.intel.com> <55CC3222.5090503@plexistor.com> <CAPcyv4gwFD5F=k_qQyf68z74Opzf1t4DMqY+A9D2w_Fwsbzvew@mail.gmail.com> <55CC9A5A.1020209@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55CC9A5A.1020209@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Dan Williams <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Rik van Riel <riel@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Thu, Aug 13, 2015 at 04:23:38PM +0300, Boaz Harrosh wrote:
> > DAX as is is races against pmem unbind.   A synchronization cost must
> > be paid somewhere to make sure the memremap() mapping is still valid.
> 
> Sorry for being so slow, is what I asked. what is exactly "pmem unbind" ?
> 
> Currently in my 4.1 Kernel the ioremap is done on modprobe time and
> released modprobe --remove time. the --remove can not happen with a mounted
> FS dax or not. So what is exactly "pmem unbind". And if there is a new knob
> then make it refuse with a raised refcount.

Surprise removal of a PCIe card which is mapped to provide non-volatile
memory for example.  Or memory hot swap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
