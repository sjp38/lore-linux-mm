Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id A063D8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 09:16:15 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id g36-v6so10086483wrd.9
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 06:16:15 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id x20-v6si1548219wmc.137.2018.09.14.06.16.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 06:16:14 -0700 (PDT)
Date: Fri, 14 Sep 2018 15:16:18 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v5 3/7] mm, devm_memremap_pages: Fix shutdown handling
Message-ID: <20180914131618.GD27141@lst.de>
References: <153680531988.453305.8080706591516037706.stgit@dwillia2-desk3.amr.corp.intel.com> <153680533706.453305.3428304103990941022.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153680533706.453305.3428304103990941022.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, stable@vger.kernel.org, Christoph Hellwig <hch@lst.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, alexander.h.duyck@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> An argument could be made to require that the ->kill() operation be set
> in the @pgmap arg rather than passed in separately. However, it helps
> code readability, tracking the lifetime of a given instance, to be able
> to grep the kill routine directly at the devm_memremap_pages() call
> site.

I generally do not like passing redundant argument, and I don't really
see why this case is different.  Or in other ways I'd like to make
your above argument..

Except for that the patch looks good to me.
