Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4B05D6B000A
	for <linux-mm@kvack.org>; Tue, 22 May 2018 02:25:25 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 70-v6so7831629wmb.2
        for <linux-mm@kvack.org>; Mon, 21 May 2018 23:25:25 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id y7-v6si2218304wrh.7.2018.05.21.23.25.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 23:25:24 -0700 (PDT)
Date: Tue, 22 May 2018 08:30:38 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 3/5] mm, hmm: use devm semantics for hmm_devmem_{add,
	remove}
Message-ID: <20180522063038.GC7925@lst.de>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com> <152694212973.5484.9009059511258430529.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152694212973.5484.9009059511258430529.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Christoph Hellwig <hch@lst.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
