Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0DA6B18DE
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 00:44:33 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id t184so58644oih.22
        for <linux-mm@kvack.org>; Sun, 18 Nov 2018 21:44:33 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w202si7254090oif.241.2018.11.18.21.44.31
        for <linux-mm@kvack.org>;
        Sun, 18 Nov 2018 21:44:31 -0800 (PST)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH 0/7] ACPI HMAT memory sysfs representation
References: <20181114224902.12082-1-keith.busch@intel.com>
 <1ed406b2-b85f-8e02-1df0-7c39aa21eca9@arm.com>
 <4ea6e80f-80ba-6992-8aa0-5c2d88996af7@intel.com>
Message-ID: <b79804b0-32ee-03f9-fa62-a89684d46be6@arm.com>
Date: Mon, 19 Nov 2018 11:14:28 +0530
MIME-Version: 1.0
In-Reply-To: <4ea6e80f-80ba-6992-8aa0-5c2d88996af7@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dan Williams <dan.j.williams@intel.com>



On 11/16/2018 10:25 PM, Dave Hansen wrote:
> On 11/15/18 10:27 PM, Anshuman Khandual wrote:
>> Not able to see the patches from this series either on the list or on the
>> archive (https://lkml.org/lkml/2018/11/15/331). IIRC last time we discussed
>> about this and the concern which I raised was in absence of a broader NUMA
>> rework for multi attribute memory it might not a good idea to settle down
>> and freeze sysfs interface for the user space. 
> 

Hello Dave,

> This *is* the broader NUMA rework.  I think it's just a bit more
> incremental that what you originally had in mind.

IIUC NUMA re-work in principle involves these functional changes

1. Enumerating compute and memory nodes in heterogeneous environment (short/medium term)
2. Enumerating memory node attributes as seen from the compute nodes (short/medium term)
3. Changing core MM to accommodate multi attribute memory (long term)

The first two set of changes can get the user space applications
moving by identifying the right nodes and their attributes through
sysfs interface.

> 
> Did you have an alternative for how you wanted this to look?
> 

No. I did not get enough time this year to rework on the original
proposal I had. But will be able to help here to make this interface
more generic, abstract out these properties which is extensible in
the future.

- Anshuman
