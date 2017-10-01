Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC7AF6B0069
	for <linux-mm@kvack.org>; Sun,  1 Oct 2017 03:57:03 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l24so544969wre.18
        for <linux-mm@kvack.org>; Sun, 01 Oct 2017 00:57:03 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id z51si5962551wrc.23.2017.10.01.00.57.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Oct 2017 00:57:02 -0700 (PDT)
Date: Sun, 1 Oct 2017 09:57:01 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v2 0/4] dax: require 'struct page' and other fixups
Message-ID: <20171001075701.GB11554@lst.de>
References: <150664806143.36094.11882924009668860273.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150664806143.36094.11882924009668860273.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

While this looks like a really nice cleanup of the code and removes
nasty race conditions I'd like to understand the tradeoffs.

This now requires every dax device that is used with a file system
to have a struct page backing, which means not only means we'd
break existing setups, but also a sharp turn from previous policy.

Unless I misremember it was you Intel guys that heavily pushed for
the page-less version, so I'd like to understand why you've changed
your mind.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
