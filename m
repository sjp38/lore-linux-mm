Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 67227280278
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 04:09:20 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 4so4552770wrt.8
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 01:09:20 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id l19si8269324wrh.275.2017.11.10.01.09.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 01:09:19 -0800 (PST)
Date: Fri, 10 Nov 2017 10:09:18 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 15/15] wait_bit: introduce {wait_on,wake_up}_devmap_idle
Message-ID: <20171110090918.GF4895@lst.de>
References: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com> <150949217671.24061.13258957060358089669.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150949217671.24061.13258957060358089669.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, hch@lst.de

On Tue, Oct 31, 2017 at 04:22:56PM -0700, Dan Williams wrote:
> Add hashed waitqueue infrastructure to wait for ZONE_DEVICE pages to
> drop their reference counts and be considered idle for DMA. This
> facility will be used for filesystem callbacks / wakeups when DMA to a
> DAX mapped range of a file ends.
> 
> For now, this implementation does not have functional behavior change
> outside of waking waitqueues that do not have any waiters present.

Hmm.  What is the point of the patch then?

You also probably want to split this into one well documented patch
that changes the bit wait infrastructure and another one using it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
