Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC7A66B427C
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 10:52:14 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id r131so5640466oia.7
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 07:52:14 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k11si292798otk.44.2018.11.26.07.52.13
        for <linux-mm@kvack.org>;
        Mon, 26 Nov 2018 07:52:13 -0800 (PST)
Subject: Re: [PATCH 0/7] ACPI HMAT memory sysfs representation
References: <20181114224902.12082-1-keith.busch@intel.com>
 <1ed406b2-b85f-8e02-1df0-7c39aa21eca9@arm.com>
 <4ea6e80f-80ba-6992-8aa0-5c2d88996af7@intel.com>
 <b79804b0-32ee-03f9-fa62-a89684d46be6@arm.com>
 <c6abb754-0d82-8739-fe08-24e9402bae75@intel.com>
 <aae34dde-fa70-870a-9b74-fff9e385bfc9@arm.com>
 <f5315662-5c1a-68a3-4d04-21b4b5ca94b1@intel.com>
 <ac942498-8966-6a9b-0e55-c79ae167c679@arm.com>
 <9015e51a-3584-7bb2-cc5e-25b0ec8e5494@intel.com>
 <CAPcyv4jnnnXi9Fqaf-d7AdnKrTMDCWr-e9tAx+G6nphrEPYm=w@mail.gmail.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <4b9e30ea-aa8e-cfd7-230b-1d5b0a8837f4@arm.com>
Date: Mon, 26 Nov 2018 21:22:13 +0530
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jnnnXi9Fqaf-d7AdnKrTMDCWr-e9tAx+G6nphrEPYm=w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>
Cc: Keith Busch <keith.busch@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>



On 11/24/2018 02:43 AM, Dan Williams wrote:
> On Fri, Nov 23, 2018 at 11:21 AM Dave Hansen <dave.hansen@intel.com> wrote:
>>
>> On 11/22/18 10:42 PM, Anshuman Khandual wrote:
>>> Are we willing to go in the direction for inclusion of a new system
>>> call, subset of it appears on sysfs etc ? My primary concern is not
>>> how the attribute information appears on the sysfs but lack of it's
>>> completeness.
>>
>> A new system call makes total sense to me.  I have the same concern
>> about the completeness of what's exposed in sysfs, I just don't see a
>> _route_ to completeness with sysfs itself.  Thus, the minimalist
>> approach as a first step.
> 
> Outside of platform-firmware-id to Linux-numa-node-id what other
> userspace API infrastructure does the kernel need to provide? It seems
> userspace enumeration of memory attributes is fully enabled once the
> firmware-to-Linux identification is established.

Which is true if the user space is required to probe the memory attribute
values for the platform-firmware-id from the platform and then request
required memory from corresponding Linux-numa-node-id via standard mm
interfaces like mbind(). But in this patch series we are not mapping
platform-firmware-id to Linux-numa-node-id. We are exporting properties
applicable to Linux nodes (Linux-numa-node-id).

Even if platform-firmware-id to Linux-numa-node-id is required it can
be done through a new file like the following. Applications can just
take the platform_id node and query platform about it's properties.

/sys/devices/system/node/nodeX/platform_id

This above interface would have been okay as its just an extension of
the existing node information on sysfs. But thats not the case with
this proposal.
