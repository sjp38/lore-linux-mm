Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 83E406B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 08:41:27 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so14132407wic.1
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 05:41:27 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id n8si9608037wiz.102.2015.08.26.05.41.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 05:41:26 -0700 (PDT)
Date: Wed, 26 Aug 2015 14:41:24 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v2 5/9] x86, pmem: push fallback handling to arch code
Message-ID: <20150826124124.GA7613@lst.de>
References: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com> <20150826012751.8851.78564.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150826012751.8851.78564.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, boaz@plexistor.com, Toshi Kani <toshi.kani@hp.com>, david@fromorbit.com, linux-kernel@vger.kernel.org, mingo@kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, hpa@zytor.com, ross.zwisler@linux.intel.com, hch@lst.de

I like the intent behind this, but not the implementation.

I think the right approach is to keep the defaults in linux/pmem.h
and simply not set CONFIG_ARCH_HAS_PMEM_API for x86-32.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
