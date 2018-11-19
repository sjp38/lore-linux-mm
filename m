Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 393446B1B22
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:52:56 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id w19-v6so23823147plq.1
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 07:52:56 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id o13-v6si36311759pgh.61.2018.11.19.07.52.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 07:52:54 -0800 (PST)
Date: Mon, 19 Nov 2018 08:49:37 -0700
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCH 1/7] node: Link memory nodes to their compute nodes
Message-ID: <20181119154937.GD23062@localhost.localdomain>
References: <20181114224921.12123-2-keith.busch@intel.com>
 <20181115135710.GD19286@bombadil.infradead.org>
 <20181115145920.GG11416@localhost.localdomain>
 <20181115203654.GA28246@bombadil.infradead.org>
 <20181116183254.GD14630@localhost.localdomain>
 <d5c7a267-840b-f253-ef0d-3715b2bcc196@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d5c7a267-840b-f253-ef0d-3715b2bcc196@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Mon, Nov 19, 2018 at 08:45:25AM +0530, Anshuman Khandual wrote:
> On 11/17/2018 12:02 AM, Keith Busch wrote:
> > On Thu, Nov 15, 2018 at 12:36:54PM -0800, Matthew Wilcox wrote:
> >> So ... let's imagine a hypothetical system (I've never seen one built like
> >> this, but it doesn't seem too implausible).  Connect four CPU sockets in
> >> a square, each of which has some regular DIMMs attached to it.  CPU A is
> >> 0 hops to Memory A, one hop to Memory B and Memory C, and two hops from
> >> Memory D (each CPU only has two "QPI" links).  Then maybe there's some
> >> special memory extender device attached on the PCIe bus.  Now there's
> >> Memory B1 and B2 that's attached to CPU B and it's local to CPU B, but
> >> not as local as Memory B is ... and we'd probably _prefer_ to allocate
> >> memory for CPU A from Memory B1 than from Memory D.  But ... *mumble*,
> >> this seems hard.
> > 
> > Indeed, that particular example is out of scope for this series. The
> > first objective is to aid a process running in node B's CPUs to allocate
> > memory in B1. Anything that crosses QPI are their own.
> 
> This is problematic. Any new kernel API interface should accommodate B2 type
> memory as well from the above example which is on a PCIe bus. Because
> eventually they would be represented as some sort of a NUMA node and then
> applications will have to depend on this sysfs interface for their desired
> memory placement requirements. Unless this interface is thought through for
> B2 type of memory, it might not be extensible in the future.

I'm not sure I understand the concern. The proposal allows linking B
to B2 memory.
