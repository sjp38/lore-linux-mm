Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1836B0374
	for <linux-mm@kvack.org>; Sat, 17 Jun 2017 08:29:25 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id q184so26228336oih.5
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 05:29:25 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id x66si1797391ota.182.2017.06.17.05.29.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Jun 2017 05:29:24 -0700 (PDT)
Received: by mail-oi0-x230.google.com with SMTP id k145so35917148oih.3
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 05:29:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170617052212.GA8246@lst.de>
References: <149766212410.22552.15957843500156182524.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149766212976.22552.11210067224152823950.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170617052212.GA8246@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 17 Jun 2017 05:29:23 -0700
Message-ID: <CAPcyv4g=x+Af1C8_q=+euwNw_Fwk3Wwe45XibtYR5=kbOcmgfg@mail.gmail.com>
Subject: Re: [RFC PATCH 1/2] mm: introduce bmap_walk()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Fri, Jun 16, 2017 at 10:22 PM, Christoph Hellwig <hch@lst.de> wrote:
> On Fri, Jun 16, 2017 at 06:15:29PM -0700, Dan Williams wrote:
>> Refactor the core of generic_swapfile_activate() into bmap_walk() so
>> that it can be used by a new daxfile_activate() helper (to be added).
>
> No way in hell!  generic_swapfile_activate needs to day and no new users
> of ->bmap over my dead body.  It's a guaranteed to fuck up your data left,
> right and center.

Certainly you're not saying that existing swapfiles are broken, so I
wonder what bugs you're talking about?

Unless you had plans to go remove bmap() I don't see how this gets in
your way at all. That said, I think "please don't add a new bmap()
user, use iomap instead" is a fair comment. You know me well enough to
know that would be all it takes to redirect my work, I can do without
the bluster.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
