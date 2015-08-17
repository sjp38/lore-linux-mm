Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6E9B66B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 11:02:01 -0400 (EDT)
Received: by wijp15 with SMTP id p15so77345246wij.0
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 08:02:00 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id p11si21113354wik.60.2015.08.17.08.01.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Aug 2015 08:01:59 -0700 (PDT)
Date: Mon, 17 Aug 2015 17:01:58 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [RFC PATCH 5/7] libnvdimm, e820: make CONFIG_X86_PMEM_LEGACY a
	tristate option
Message-ID: <20150817150158.GB2625@lst.de>
References: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com> <20150813035028.36913.25267.stgit@otcpl-skl-sds-2.jf.intel.com> <20150815090635.GF21033@lst.de> <CAPcyv4hMaRDOttcnvjq-aBXqgaPuB1d1XVi-dJFryC9pJ8PhMw@mail.gmail.com> <20150815155846.GA26248@lst.de> <CAPcyv4iN0BmipDfrsoCg2N2KnhX0+Hz2-ghr1i0H4US+bFe+Dw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iN0BmipDfrsoCg2N2KnhX0+Hz2-ghr1i0H4US+bFe+Dw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boaz Harrosh <boaz@plexistor.com>, Rik van Riel <riel@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, david <david@fromorbit.com>, Ingo Molnar <mingo@kernel.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>

On Sat, Aug 15, 2015 at 09:04:02AM -0700, Dan Williams wrote:
> What other layer? /sys/devices/platform/e820_pmem is that exact same
> device we had before this patch.  We just have a proper driver for it
> now.

We're adding another layer of indirection between the old e820 file
and the new module.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
