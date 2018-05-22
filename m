Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CDECC6B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 02:24:53 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f21-v6so8803716wmh.5
        for <linux-mm@kvack.org>; Mon, 21 May 2018 23:24:53 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id q13-v6si2145223wmq.132.2018.05.21.23.24.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 23:24:52 -0700 (PDT)
Date: Tue, 22 May 2018 08:30:06 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/5] mm, devm_memremap_pages: handle errors allocating
	final devres action
Message-ID: <20180522063006.GB7925@lst.de>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com> <152694212460.5484.13180030631810166467.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152694212460.5484.13180030631810166467.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, stable@vger.kernel.org, Christoph Hellwig <hch@lst.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 21, 2018 at 03:35:24PM -0700, Dan Williams wrote:
> The last step before devm_memremap_pages() returns success is to
> allocate a release action to tear the entire setup down. However, the
> result from devm_add_action() is not checked.
> 
> Checking the error also means that we need to handle the fact that the
> percpu_ref may not be killed by the time devm_memremap_pages_release()
> runs. Add a new state flag for this case.

Looks good (modulo any stable tag issues):

Reviewed-by: Christoph Hellwig <hch@lst.de>
