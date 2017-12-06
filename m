Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7896B0253
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 17:44:48 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id o2so2520507wmf.2
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 14:44:48 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id t4si2613229wrb.289.2017.12.06.14.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 14:44:42 -0800 (PST)
Date: Wed, 6 Dec 2017 23:44:41 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/2] mm: fix dev_pagemap reference counting around
	get_dev_pagemap
Message-ID: <20171206224441.GA14274@lst.de>
References: <20171205003443.22111-1-hch@lst.de> <20171205003443.22111-3-hch@lst.de> <CAPcyv4i3RP12-3T8R4tazfVvC+UG-FaUjorcbHnC1OPsc-5+YQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4i3RP12-3T8R4tazfVvC+UG-FaUjorcbHnC1OPsc-5+YQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>

On Tue, Dec 05, 2017 at 06:43:36PM -0800, Dan Williams wrote:
> I don't think we need this change, but perhaps the reasoning should be
> added to the code as a comment... details below.

Hmm, looks like we are ok at least.  But even if it's not a correctness
issue there is no good point in decrementing and incrementing the
reference count every time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
