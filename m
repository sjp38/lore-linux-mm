Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id A47528E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 09:14:18 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id p105-v6so9797504wrc.11
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 06:14:18 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id u17-v6si1632743wmd.139.2018.09.14.06.14.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 06:14:17 -0700 (PDT)
Date: Fri, 14 Sep 2018 15:14:20 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v5 2/7] mm, devm_memremap_pages: Kill mapping "System
 RAM" support
Message-ID: <20180914131420.GC27141@lst.de>
References: <153680531988.453305.8080706591516037706.stgit@dwillia2-desk3.amr.corp.intel.com> <153680533172.453305.5701902165148172434.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153680533172.453305.5701902165148172434.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Christoph Hellwig <hch@lst.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, alexander.h.duyck@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 12, 2018 at 07:22:11PM -0700, Dan Williams wrote:
> Given the fact that devm_memremap_pages() requires a percpu_ref that is
> torn down by devm_memremap_pages_release() the current support for
> mapping RAM is broken.

I agree.  Do you remember why we even added it in the first place?

Signed-off-by: Christoph Hellwig <hch@lst.de>
