Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5816B2AA0
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 08:29:26 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id j15so4712356ota.17
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:29:26 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p10si17014714otl.267.2018.11.22.05.29.25
        for <linux-mm@kvack.org>;
        Thu, 22 Nov 2018 05:29:25 -0800 (PST)
Subject: Re: [PATCH 4/7] node: Add memory caching attributes
References: <20181114224921.12123-2-keith.busch@intel.com>
 <20181114224921.12123-5-keith.busch@intel.com>
 <91698cef-cdcd-5143-884f-3da5536e156f@arm.com>
 <20181119230600.GC26707@localhost.localdomain>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <731533d5-26e1-ade7-1a63-d1f85461d091@arm.com>
Date: Thu, 22 Nov 2018 18:59:21 +0530
MIME-Version: 1.0
In-Reply-To: <20181119230600.GC26707@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>



On 11/20/2018 04:36 AM, Keith Busch wrote:
> On Mon, Nov 19, 2018 at 09:44:00AM +0530, Anshuman Khandual wrote:
>> On 11/15/2018 04:19 AM, Keith Busch wrote:
>>> System memory may have side caches to help improve access speed. While
>>> the system provided cache is transparent to the software accessing
>>> these memory ranges, applications can optimize their own access based
>>> on cache attributes.
>>
>> Cache is not a separate memory attribute. It impacts how the real attributes
>> like bandwidth, latency e.g which are already captured in the previous patch.
>> What is the purpose of adding this as a separate attribute ? Can you explain
>> how this is going to help the user space apart from the hints it has already
>> received with bandwidth, latency etc properties.
> 
> I am not sure I understand the question here. Access bandwidth and latency
> are entirely attributes different than what this patch provides. If the
> system side-caches memory, the associativity, line size, and total size
> can optionally be used by software to improve performance.

Okay but then does this belong to this series which about memory attributes ?
