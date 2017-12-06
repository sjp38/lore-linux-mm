Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB1686B0253
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 17:52:47 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id v8so2861658otd.4
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 14:52:47 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o67sor1362683oih.308.2017.12.06.14.52.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Dec 2017 14:52:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171206224441.GA14274@lst.de>
References: <20171205003443.22111-1-hch@lst.de> <20171205003443.22111-3-hch@lst.de>
 <CAPcyv4i3RP12-3T8R4tazfVvC+UG-FaUjorcbHnC1OPsc-5+YQ@mail.gmail.com> <20171206224441.GA14274@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 6 Dec 2017 14:52:36 -0800
Message-ID: <CAPcyv4gzDKBqdSLma436nyTQNAqUxom0bJ2kbj5RH5hQZm8+7Q@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: fix dev_pagemap reference counting around get_dev_pagemap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>

On Wed, Dec 6, 2017 at 2:44 PM, Christoph Hellwig <hch@lst.de> wrote:
> On Tue, Dec 05, 2017 at 06:43:36PM -0800, Dan Williams wrote:
>> I don't think we need this change, but perhaps the reasoning should be
>> added to the code as a comment... details below.
>
> Hmm, looks like we are ok at least.  But even if it's not a correctness
> issue there is no good point in decrementing and incrementing the
> reference count every time.

True, we can take it once and drop it at the end when all the related
page references have been taken.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
