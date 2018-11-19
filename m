Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1967F6B182C
	for <linux-mm@kvack.org>; Sun, 18 Nov 2018 22:04:47 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id h135-v6so16520358oic.2
        for <linux-mm@kvack.org>; Sun, 18 Nov 2018 19:04:47 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e200-v6si17075668oic.46.2018.11.18.19.04.45
        for <linux-mm@kvack.org>;
        Sun, 18 Nov 2018 19:04:46 -0800 (PST)
Subject: Re: [PATCH 1/7] node: Link memory nodes to their compute nodes
References: <20181114224921.12123-2-keith.busch@intel.com>
 <20181115135710.GD19286@bombadil.infradead.org>
 <20181115145920.GG11416@localhost.localdomain>
 <CAPcyv4iLSiJz6Z7qyjqpo=HUZQy-gAcaG69JytLPPGqOO157sg@mail.gmail.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <55e5a20e-4267-cb1d-959b-6068ebbd64b1@arm.com>
Date: Mon, 19 Nov 2018 08:34:42 +0530
MIME-Version: 1.0
In-Reply-To: <CAPcyv4iLSiJz6Z7qyjqpo=HUZQy-gAcaG69JytLPPGqOO157sg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>



On 11/15/2018 11:20 PM, Dan Williams wrote:
> On Thu, Nov 15, 2018 at 7:02 AM Keith Busch <keith.busch@intel.com> wrote:
>>
>> On Thu, Nov 15, 2018 at 05:57:10AM -0800, Matthew Wilcox wrote:
>>> On Wed, Nov 14, 2018 at 03:49:14PM -0700, Keith Busch wrote:
>>>> Memory-only nodes will often have affinity to a compute node, and
>>>> platforms have ways to express that locality relationship.
>>>>
>>>> A node containing CPUs or other DMA devices that can initiate memory
>>>> access are referred to as "memory iniators". A "memory target" is a
>>>> node that provides at least one phyiscal address range accessible to a
>>>> memory initiator.
>>>
>>> I think I may be confused here.  If there is _no_ link from node X to
>>> node Y, does that mean that node X's CPUs cannot access the memory on
>>> node Y?  In my mind, all nodes can access all memory in the system,
>>> just not with uniform bandwidth/latency.
>>
>> The link is just about which nodes are "local". It's like how nodes have
>> a cpulist. Other CPUs not in the node's list can acces that node's memory,
>> but the ones in the mask are local, and provide useful optimization hints.
>>
>> Would a node mask would be prefered to symlinks?
> 
> I think that would be more flexible, because the set of initiators
> that may have "best" or "local" access to a target may be more than 1.

Right. The memory target should have two nodemasks (for now at least). One
enumerating which initiator nodes can access the memory coherently and the
other one which are nearer and can benefit from local allocation.
