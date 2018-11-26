Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 836256B4255
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 10:17:51 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id m1-v6so21632258plb.13
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 07:17:51 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id bb4si540595plb.322.2018.11.26.07.17.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 07:17:50 -0800 (PST)
Date: Mon, 26 Nov 2018 08:14:47 -0700
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCH 4/7] node: Add memory caching attributes
Message-ID: <20181126151446.GK26707@localhost.localdomain>
References: <20181114224921.12123-2-keith.busch@intel.com>
 <20181114224921.12123-5-keith.busch@intel.com>
 <91698cef-cdcd-5143-884f-3da5536e156f@arm.com>
 <20181119230600.GC26707@localhost.localdomain>
 <731533d5-26e1-ade7-1a63-d1f85461d091@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <731533d5-26e1-ade7-1a63-d1f85461d091@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Nov 22, 2018 at 06:59:21PM +0530, Anshuman Khandual wrote:
> 
> 
> On 11/20/2018 04:36 AM, Keith Busch wrote:
> > On Mon, Nov 19, 2018 at 09:44:00AM +0530, Anshuman Khandual wrote:
> >> On 11/15/2018 04:19 AM, Keith Busch wrote:
> >>> System memory may have side caches to help improve access speed. While
> >>> the system provided cache is transparent to the software accessing
> >>> these memory ranges, applications can optimize their own access based
> >>> on cache attributes.
> >>
> >> Cache is not a separate memory attribute. It impacts how the real attributes
> >> like bandwidth, latency e.g which are already captured in the previous patch.
> >> What is the purpose of adding this as a separate attribute ? Can you explain
> >> how this is going to help the user space apart from the hints it has already
> >> received with bandwidth, latency etc properties.
> > 
> > I am not sure I understand the question here. Access bandwidth and latency
> > are entirely attributes different than what this patch provides. If the
> > system side-caches memory, the associativity, line size, and total size
> > can optionally be used by software to improve performance.
> 
> Okay but then does this belong to this series which about memory attributes ?

This patch series is about exporting memory attributes, and this system
memory caching is  one such attribute, so yes, I think it belongs.
