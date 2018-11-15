Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1DFAD6B0332
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 08:57:13 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id y2so6892433plr.8
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 05:57:13 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 3-v6si28010306plm.136.2018.11.15.05.57.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Nov 2018 05:57:11 -0800 (PST)
Date: Thu, 15 Nov 2018 05:57:10 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/7] node: Link memory nodes to their compute nodes
Message-ID: <20181115135710.GD19286@bombadil.infradead.org>
References: <20181114224921.12123-2-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114224921.12123-2-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, Nov 14, 2018 at 03:49:14PM -0700, Keith Busch wrote:
> Memory-only nodes will often have affinity to a compute node, and
> platforms have ways to express that locality relationship.
> 
> A node containing CPUs or other DMA devices that can initiate memory
> access are referred to as "memory iniators". A "memory target" is a
> node that provides at least one phyiscal address range accessible to a
> memory initiator.

I think I may be confused here.  If there is _no_ link from node X to
node Y, does that mean that node X's CPUs cannot access the memory on
node Y?  In my mind, all nodes can access all memory in the system,
just not with uniform bandwidth/latency.
