Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id F2D2B6B0804
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 01:28:05 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id e10so15399034oth.21
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 22:28:05 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l65si10015856otc.218.2018.11.15.22.28.04
        for <linux-mm@kvack.org>;
        Thu, 15 Nov 2018 22:28:04 -0800 (PST)
Subject: Re: [PATCH 0/7] ACPI HMAT memory sysfs representation
References: <20181114224902.12082-1-keith.busch@intel.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <1ed406b2-b85f-8e02-1df0-7c39aa21eca9@arm.com>
Date: Fri, 16 Nov 2018 11:57:58 +0530
MIME-Version: 1.0
In-Reply-To: <20181114224902.12082-1-keith.busch@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On 11/15/2018 04:19 AM, Keith Busch wrote:
> This series provides a new sysfs representation for heterogeneous
> system memory.
> 
> The previous series that was specific to HMAT that this series was based
> on was last posted here: https://lkml.org/lkml/2017/12/13/968
> 
> Platforms may provide multiple types of cpu attached system memory. The
> memory ranges for each type may have different characteristics that
> applications may wish to know about when considering what node they want
> their memory allocated from. 
> 
> It had previously been difficult to describe these setups as memory
> rangers were generally lumped into the NUMA node of the CPUs. New
> platform attributes have been created and in use today that describe
> the more complex memory hierarchies that can be created.
> 
> This series first creates new generic APIs under the kernel's node
> representation. These new APIs can be used to create links among local
> memory and compute nodes and export characteristics about the memory
> nodes. Documentation desribing the new representation are provided.
> 
> Finally the series adds a kernel user for these new APIs from parsing
> the ACPI HMAT.

Not able to see the patches from this series either on the list or on the
archive (https://lkml.org/lkml/2018/11/15/331). IIRC last time we discussed
about this and the concern which I raised was in absence of a broader NUMA
rework for multi attribute memory it might not a good idea to settle down
and freeze sysfs interface for the user space. 
