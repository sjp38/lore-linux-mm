Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B1446440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 12:39:27 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id y64so1443361wmd.6
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:39:27 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id r189si1896727wmr.211.2017.08.24.09.39.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 09:39:26 -0700 (PDT)
Date: Thu, 24 Aug 2017 18:39:25 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v6 4/5] fs, xfs: introduce MAP_DIRECT for creating
	block-map-atomic file ranges
Message-ID: <20170824163925.GA28503@lst.de>
References: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com> <150353213655.5039.7662200155640827407.stgit@dwillia2-desk3.amr.corp.intel.com> <20170824161152.GB27591@lst.de> <CAPcyv4jjNi_+c5DW9nsBLEnYMBtsR_v67+bF6bC4Cb9mY7T+Ww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jjNi_+c5DW9nsBLEnYMBtsR_v67+bF6bC4Cb9mY7T+Ww@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, Linux API <linux-api@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, xen-devel@lists.xen.org

On Thu, Aug 24, 2017 at 09:31:17AM -0700, Dan Williams wrote:
> External agent is a DMA device, or a hypervisor like Xen. In the DMA
> case perhaps we can use the fcntl lease mechanism, I'll investigate.
> In the Xen case it actually would need to use fiemap() to discover the
> physical addresses that back the file to setup their M2P tables.
> Here's the discussion where we discovered that physical address
> dependency:
> 
>     https://lists.xen.org/archives/html/xen-devel/2017-04/msg00419.html

fiemap does not work to discover physical addresses.  If they want
to do anything involving physical address they will need a kernel
driver.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
