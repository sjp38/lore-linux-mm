Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 839436B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 12:11:29 -0400 (EDT)
Received: by mail-io0-f174.google.com with SMTP id o5so20832753iod.2
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 09:11:29 -0700 (PDT)
Received: from quartz.orcorp.ca (quartz.orcorp.ca. [184.70.90.242])
        by mx.google.com with ESMTPS id r18si2310697igs.16.2016.03.17.09.11.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 09:11:27 -0700 (PDT)
Date: Thu, 17 Mar 2016 10:11:21 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH RFC 1/1] Add support for ZONE_DEVICE IO memory with
 struct pages.
Message-ID: <20160317161121.GA19501@obsidianresearch.com>
References: <1457979277-26791-1-git-send-email-stephen.bates@pmcs.com>
 <20160314212344.GC23727@linux.intel.com>
 <20160314215708.GA7282@obsidianresearch.com>
 <56EACAB3.5070301@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56EACAB3.5070301@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haggai Eran <haggaie@mellanox.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, Stephen Bates <stephen.bates@pmcs.com>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, linux-nvdimm@ml01.01.org, javier@cnexlabs.com, sagig@mellanox.com, leonro@mellanox.com, artemyko@mellanox.com, hch@infradead.org

On Thu, Mar 17, 2016 at 05:18:11PM +0200, Haggai Eran wrote:
> On 3/14/2016 11:57 PM, Jason Gunthorpe wrote:
> > The other issue is that the fencing mechanism RDMA uses to create
> > ordering with system memory is not good enough to fence peer-peer
> > transactions in the general case. It is only possibly good enough if
> > all the transactions run through the root complex.
> 
> Are you sure this is a problem? I'm not sure it is clear in the PCIe 
> specs, but I thought that for transactions that are not relaxed-ordered 
> and don't use ID-based ordering, a PCIe switch must prevent reads and 
> writes from passing writes.

Yes, that is right, and that is good enough if the PCI-E fabric is a
simple acyclic configuration (ie the common case).

There are fringe cases that are more complex, and maybe the correct
reading of the spec is to setup routing to avoid optimal paths, but it
certainly is possible to configure switches in a way that could not
guarentee global ordering.

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
