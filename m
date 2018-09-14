Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id C68EF8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 10:16:22 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id e88-v6so7423602qtb.1
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 07:16:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f13-v6si756048qti.132.2018.09.14.07.16.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 07:16:21 -0700 (PDT)
Date: Fri, 14 Sep 2018 10:16:17 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v5 5/7] mm, hmm: Use devm semantics for hmm_devmem_{add,
 remove}
Message-ID: <20180914141617.GC3826@redhat.com>
References: <153680531988.453305.8080706591516037706.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153680534781.453305.3660438915028111950.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180914131838.GF27141@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180914131838.GF27141@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org, Logan Gunthorpe <logang@deltatee.com>, alexander.h.duyck@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 14, 2018 at 03:18:38PM +0200, Christoph Hellwig wrote:
> On Wed, Sep 12, 2018 at 07:22:27PM -0700, Dan Williams wrote:
> > devm semantics arrange for resources to be torn down when
> > device-driver-probe fails or when device-driver-release completes.
> > Similar to devm_memremap_pages() there is no need to support an explicit
> > remove operation when the users properly adhere to devm semantics.
> > 
> > Note that devm_kzalloc() automatically handles allocating node-local
> > memory.
> > 
> > Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> Given that we have no single user of these function I still think we
> should just remove them.

It is in the process of being upstreamed:

https://cgit.freedesktop.org/~glisse/linux/log/?h=nouveau-hmm-v01

and more users are coming for other devices.

Yes it is taking time ... things never goes as planed.

Cheers,
Jerome
