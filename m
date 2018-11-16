Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF9596B0A3B
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 10:55:07 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id h9so10571713pgm.1
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 07:55:07 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id i69si29709701pgc.538.2018.11.16.07.55.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 07:55:06 -0800 (PST)
Date: Fri, 16 Nov 2018 08:51:41 -0700
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCH 0/7] ACPI HMAT memory sysfs representation
Message-ID: <20181116155141.GA14630@localhost.localdomain>
References: <20181114224902.12082-1-keith.busch@intel.com>
 <1ed406b2-b85f-8e02-1df0-7c39aa21eca9@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1ed406b2-b85f-8e02-1df0-7c39aa21eca9@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Fri, Nov 16, 2018 at 11:57:58AM +0530, Anshuman Khandual wrote:
> On 11/15/2018 04:19 AM, Keith Busch wrote:
> > This series provides a new sysfs representation for heterogeneous
> > system memory.
> > 
> > The previous series that was specific to HMAT that this series was based
> > on was last posted here: https://lkml.org/lkml/2017/12/13/968
> > 
> > Platforms may provide multiple types of cpu attached system memory. The
> > memory ranges for each type may have different characteristics that
> > applications may wish to know about when considering what node they want
> > their memory allocated from. 
> > 
> > It had previously been difficult to describe these setups as memory
> > rangers were generally lumped into the NUMA node of the CPUs. New
> > platform attributes have been created and in use today that describe
> > the more complex memory hierarchies that can be created.
> > 
> > This series first creates new generic APIs under the kernel's node
> > representation. These new APIs can be used to create links among local
> > memory and compute nodes and export characteristics about the memory
> > nodes. Documentation desribing the new representation are provided.
> > 
> > Finally the series adds a kernel user for these new APIs from parsing
> > the ACPI HMAT.
> 
> Not able to see the patches from this series either on the list or on the
> archive (https://lkml.org/lkml/2018/11/15/331). 

The send-email split the cover-letter from the series, probably
something I did. Series followed immediately after:

  https://lkml.org/lkml/2018/11/15/332

> IIRC last time we discussed
> about this and the concern which I raised was in absence of a broader NUMA
> rework for multi attribute memory it might not a good idea to settle down
> and freeze sysfs interface for the user space. 
