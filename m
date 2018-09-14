Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id A046E8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 09:18:35 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id a37-v6so10064983wrc.5
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 06:18:35 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id h1-v6si6282688wro.367.2018.09.14.06.18.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 06:18:34 -0700 (PDT)
Date: Fri, 14 Sep 2018 15:18:38 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v5 5/7] mm, hmm: Use devm semantics for
 hmm_devmem_{add, remove}
Message-ID: <20180914131838.GF27141@lst.de>
References: <153680531988.453305.8080706591516037706.stgit@dwillia2-desk3.amr.corp.intel.com> <153680534781.453305.3660438915028111950.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153680534781.453305.3660438915028111950.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Christoph Hellwig <hch@lst.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, alexander.h.duyck@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 12, 2018 at 07:22:27PM -0700, Dan Williams wrote:
> devm semantics arrange for resources to be torn down when
> device-driver-probe fails or when device-driver-release completes.
> Similar to devm_memremap_pages() there is no need to support an explicit
> remove operation when the users properly adhere to devm semantics.
> 
> Note that devm_kzalloc() automatically handles allocating node-local
> memory.
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Given that we have no single user of these function I still think we
should just remove them.
