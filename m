Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 597728E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 09:18:01 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id d17-v6so10064894wrr.14
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 06:18:01 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id e67-v6si1665714wmg.44.2018.09.14.06.18.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 06:18:00 -0700 (PDT)
Date: Fri, 14 Sep 2018 15:18:03 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v5 4/7] mm, devm_memremap_pages: Add
 MEMORY_DEVICE_PRIVATE support
Message-ID: <20180914131803.GE27141@lst.de>
References: <153680531988.453305.8080706591516037706.stgit@dwillia2-desk3.amr.corp.intel.com> <153680534246.453305.10522027577023444732.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153680534246.453305.10522027577023444732.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Christoph Hellwig <hch@lst.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, alexander.h.duyck@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 12, 2018 at 07:22:22PM -0700, Dan Williams wrote:
> In preparation for consolidating all ZONE_DEVICE enabling via
> devm_memremap_pages(), teach it how to handle the constraints of
> MEMORY_DEVICE_PRIVATE ranges.

MEMORY_DEVICE_PRIVATE still somehow boggles my mind, but otherwise
this looks sensible to me:

Acked-by: Christoph Hellwig <hch@lst.de>
