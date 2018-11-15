Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F8D36B0379
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 10:02:53 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 143so10451600pgc.3
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 07:02:53 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id h80-v6si26066235pfj.112.2018.11.15.07.02.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 07:02:52 -0800 (PST)
Date: Thu, 15 Nov 2018 07:59:20 -0700
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCH 1/7] node: Link memory nodes to their compute nodes
Message-ID: <20181115145920.GG11416@localhost.localdomain>
References: <20181114224921.12123-2-keith.busch@intel.com>
 <20181115135710.GD19286@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115135710.GD19286@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Nov 15, 2018 at 05:57:10AM -0800, Matthew Wilcox wrote:
> On Wed, Nov 14, 2018 at 03:49:14PM -0700, Keith Busch wrote:
> > Memory-only nodes will often have affinity to a compute node, and
> > platforms have ways to express that locality relationship.
> > 
> > A node containing CPUs or other DMA devices that can initiate memory
> > access are referred to as "memory iniators". A "memory target" is a
> > node that provides at least one phyiscal address range accessible to a
> > memory initiator.
> 
> I think I may be confused here.  If there is _no_ link from node X to
> node Y, does that mean that node X's CPUs cannot access the memory on
> node Y?  In my mind, all nodes can access all memory in the system,
> just not with uniform bandwidth/latency.

The link is just about which nodes are "local". It's like how nodes have
a cpulist. Other CPUs not in the node's list can acces that node's memory,
but the ones in the mask are local, and provide useful optimization hints.

Would a node mask would be prefered to symlinks?
