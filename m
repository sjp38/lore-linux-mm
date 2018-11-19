Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id AAAD36B17DA
	for <linux-mm@kvack.org>; Sun, 18 Nov 2018 20:52:16 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id 32so14728623ots.15
        for <linux-mm@kvack.org>; Sun, 18 Nov 2018 17:52:16 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j14si14265031ote.283.2018.11.18.17.52.15
        for <linux-mm@kvack.org>;
        Sun, 18 Nov 2018 17:52:15 -0800 (PST)
Subject: Re: [PATCH 0/7] ACPI HMAT memory sysfs representation
References: <20181114224902.12082-1-keith.busch@intel.com>
 <1ed406b2-b85f-8e02-1df0-7c39aa21eca9@arm.com>
 <20181116155141.GA14630@localhost.localdomain>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <415d842c-1fc9-1f15-640b-6d6c0f9611e2@arm.com>
Date: Mon, 19 Nov 2018 07:22:11 +0530
MIME-Version: 1.0
In-Reply-To: <20181116155141.GA14630@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>



On 11/16/2018 09:21 PM, Keith Busch wrote:
> On Fri, Nov 16, 2018 at 11:57:58AM +0530, Anshuman Khandual wrote:
>> On 11/15/2018 04:19 AM, Keith Busch wrote:
>>> This series provides a new sysfs representation for heterogeneous
>>> system memory.
>>>
>>> The previous series that was specific to HMAT that this series was based
>>> on was last posted here: https://lkml.org/lkml/2017/12/13/968
>>>
>>> Platforms may provide multiple types of cpu attached system memory. The
>>> memory ranges for each type may have different characteristics that
>>> applications may wish to know about when considering what node they want
>>> their memory allocated from. 
>>>
>>> It had previously been difficult to describe these setups as memory
>>> rangers were generally lumped into the NUMA node of the CPUs. New
>>> platform attributes have been created and in use today that describe
>>> the more complex memory hierarchies that can be created.
>>>
>>> This series first creates new generic APIs under the kernel's node
>>> representation. These new APIs can be used to create links among local
>>> memory and compute nodes and export characteristics about the memory
>>> nodes. Documentation desribing the new representation are provided.
>>>
>>> Finally the series adds a kernel user for these new APIs from parsing
>>> the ACPI HMAT.
>>
>> Not able to see the patches from this series either on the list or on the
>> archive (https://lkml.org/lkml/2018/11/15/331). 
> 
> The send-email split the cover-letter from the series, probably
> something I did. Series followed immediately after:
> 
>   https://lkml.org/lkml/2018/11/15/332

Yeah got it. I can see the series on the list. Thanks for pointing out.

> 
>> IIRC last time we discussed
>> about this and the concern which I raised was in absence of a broader NUMA
>> rework for multi attribute memory it might not a good idea to settle down
>> and freeze sysfs interface for the user space. 
> 
