Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 343B46B025F
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 12:29:40 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id c42so5993843wrc.13
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 09:29:40 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c10si1008093wrd.350.2017.10.20.09.29.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 09:29:38 -0700 (PDT)
Date: Fri, 20 Oct 2017 18:29:33 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v3 02/13] dax: require 'struct page' for filesystem dax
Message-ID: <20171020162933.GA26320@lst.de>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com> <150846714747.24336.14704246566580871364.stgit@dwillia2-desk3.amr.corp.intel.com> <20171020075735.GA14378@lst.de> <CAPcyv4hA1nrhDf=DA6_j7s7ezGOBhvEVZ8cu81DNui_p3bhhaA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4hA1nrhDf=DA6_j7s7ezGOBhvEVZ8cu81DNui_p3bhhaA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Fri, Oct 20, 2017 at 08:23:02AM -0700, Dan Williams wrote:
> Yes, however it seems these drivers / platforms have been living with
> the lack of struct page for a long time. So they either don't use DAX,
> or they have a constrained use case that never triggers
> get_user_pages(). If it is the latter then they could introduce a new
> configuration option that bypasses the pfn_t_devmap() check in
> bdev_dax_supported() and fix up the get_user_pages() paths to fail.
> So, I'd like to understand how these drivers have been using DAX
> support without struct page to see if we need a workaround or we can
> go ahead delete this support. If the usage is limited to
> execute-in-place perhaps we can do a constrained ->direct_access() for
> just that case.

For axonram I doubt anyone is using it any more - it was a very for
the IBM Cell blades, which were produceN? in a rather limited number.
And Cell basically seems to be dead as far as I can tell.

For S/390 Martin might be able to help out what the status of xpram
in general and DAX support in particular is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
