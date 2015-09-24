Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4AC6982F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 11:10:26 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so75625146pac.0
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 08:10:26 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id pp2si18969503pbb.235.2015.09.24.08.10.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 08:10:25 -0700 (PDT)
Date: Thu, 24 Sep 2015 08:10:24 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 04/15] x86, mm: quiet arch_add_memory()
Message-ID: <20150924151024.GB24375@infradead.org>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
 <20150923044134.36490.18815.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150923044134.36490.18815.stgit@dwillia2-desk3.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nvdimm@ml01.01.org

Looks fine,

Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
