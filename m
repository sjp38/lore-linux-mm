Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1A90E440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 12:31:19 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id x10so1504129oig.2
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:31:19 -0700 (PDT)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id p187si3520977oig.538.2017.08.24.09.31.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 09:31:18 -0700 (PDT)
Received: by mail-oi0-x22a.google.com with SMTP id 187so10056123oig.1
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:31:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170824161152.GB27591@lst.de>
References: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150353213655.5039.7662200155640827407.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170824161152.GB27591@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 24 Aug 2017 09:31:17 -0700
Message-ID: <CAPcyv4jjNi_+c5DW9nsBLEnYMBtsR_v67+bF6bC4Cb9mY7T+Ww@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] fs, xfs: introduce MAP_DIRECT for creating
 block-map-atomic file ranges
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, Linux API <linux-api@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, xen-devel@lists.xen.org

[ adding Xen ]

On Thu, Aug 24, 2017 at 9:11 AM, Christoph Hellwig <hch@lst.de> wrote:
> I still can't make any sense of this description.  What is an external
> agent?  Userspace obviously can't ever see a change in the extent
> map, so it can't be meant.

External agent is a DMA device, or a hypervisor like Xen. In the DMA
case perhaps we can use the fcntl lease mechanism, I'll investigate.
In the Xen case it actually would need to use fiemap() to discover the
physical addresses that back the file to setup their M2P tables.
Here's the discussion where we discovered that physical address
dependency:

    https://lists.xen.org/archives/html/xen-devel/2017-04/msg00419.html

> It would help a lot if you could come up with a concrete user for this,
> including example code.

Will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
