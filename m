Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 893EA6B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 06:04:01 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k94so351934wrc.6
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 03:04:01 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id e84si5106659wmi.217.2017.08.31.03.04.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 03:04:00 -0700 (PDT)
Date: Thu, 31 Aug 2017 12:03:59 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/2] mm: introduce MAP_VALIDATE, a mechanism for for
	safely defining new mmap flags
Message-ID: <20170831100359.GD21443@lst.de>
References: <150413449482.5923.1348069619036923853.stgit@dwillia2-desk3.amr.corp.intel.com> <150413450616.5923.7069852068237042023.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150413450616.5923.7069852068237042023.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-mm@kvack.org, jack@suse.cz, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, luto@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, hch@lst.de

> +/*
> + * The historical set of flags that all mmap implementations implicitly
> + * support when file_operations.mmap_supported_mask is zero. With the
> + * mmap3 syscall the deprecated MAP_DENYWRITE and MAP_EXECUTABLE bit
> + * values are explicitly rejected with EOPNOTSUPP rather than being
> + * silently accepted.
> + */

no mmap3 syscall here :)

Do you also need to update the nommu mmap implementation?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
