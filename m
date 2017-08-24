Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 31716440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 16:27:02 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 4so689052oie.8
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 13:27:02 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id h84si4047616oif.273.2017.08.24.13.26.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 13:26:56 -0700 (PDT)
Received: by mail-oi0-x230.google.com with SMTP id t88so5390494oij.0
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 13:26:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170824163925.GA28503@lst.de>
References: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150353213655.5039.7662200155640827407.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170824161152.GB27591@lst.de> <CAPcyv4jjNi_+c5DW9nsBLEnYMBtsR_v67+bF6bC4Cb9mY7T+Ww@mail.gmail.com>
 <20170824163925.GA28503@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 24 Aug 2017 13:26:55 -0700
Message-ID: <CAPcyv4j06mdEek-aYfZCbTW0MaL6gy7OpUsgyv4hBB5yy_rW6A@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] fs, xfs: introduce MAP_DIRECT for creating
 block-map-atomic file ranges
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, Linux API <linux-api@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, xen-devel@lists.xen.org

On Thu, Aug 24, 2017 at 9:39 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Thu, Aug 24, 2017 at 09:31:17AM -0700, Dan Williams wrote:
>> External agent is a DMA device, or a hypervisor like Xen. In the DMA
>> case perhaps we can use the fcntl lease mechanism, I'll investigate.
>> In the Xen case it actually would need to use fiemap() to discover the
>> physical addresses that back the file to setup their M2P tables.
>> Here's the discussion where we discovered that physical address
>> dependency:
>>
>>     https://lists.xen.org/archives/html/xen-devel/2017-04/msg00419.html
>
> fiemap does not work to discover physical addresses.  If they want
> to do anything involving physical address they will need a kernel
> driver.

True, it's broken with respect to multi-device filesystems and these
patches do nothing to fix that problem. Ok, I'm fine to let that use
case depend on a kernel driver and just focus on fixing the DMA case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
