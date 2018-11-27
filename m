Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id B10996B474B
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 05:15:41 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id s12so9868582otc.12
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 02:15:41 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p10si1477432otl.267.2018.11.27.02.15.39
        for <linux-mm@kvack.org>;
        Tue, 27 Nov 2018 02:15:40 -0800 (PST)
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
 <b9962dfa-924f-77f7-a40f-407dd20e9082@intel.com>
 <CAPcyv4hVFMvut9+Rq7G41yyKzV072U33YEeHNh160VBr3QW-nw@mail.gmail.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <325d0e69-053a-ae9c-eede-7cdf28b1dbd6@arm.com>
Date: Tue, 27 Nov 2018 15:45:40 +0530
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hVFMvut9+Rq7G41yyKzV072U33YEeHNh160VBr3QW-nw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>
Cc: Keith Busch <keith.busch@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>



On 11/26/2018 11:38 PM, Dan Williams wrote:
> On Mon, Nov 26, 2018 at 8:42 AM Dave Hansen <dave.hansen@intel.com> wrote:
>>
>> On 11/23/18 1:13 PM, Dan Williams wrote:
>>>> A new system call makes total sense to me.  I have the same concern
>>>> about the completeness of what's exposed in sysfs, I just don't see a
>>>> _route_ to completeness with sysfs itself.  Thus, the minimalist
>>>> approach as a first step.
>>> Outside of platform-firmware-id to Linux-numa-node-id what other
>>> userspace API infrastructure does the kernel need to provide? It seems
>>> userspace enumeration of memory attributes is fully enabled once the
>>> firmware-to-Linux identification is established.
>>
>> It would be nice not to have each app need to know about each specific
>> platform's firmware.
> 
> The app wouldn't need to know if it uses a common library. Whether the
> library calls into the kernel or not is an implementation detail. If
> it is information that only the app cares about and the kernel does
> not consume, why have a syscall?

If we just care about platform-firmware-id <--> Linux-numa-node-id mapping
and fetching memory attribute from the platform (and hiding implementation
details in a library) then the following interface should be sufficient.

/sys/devices/system/node/nodeX/platform_id

But as the series proposes (and rightly so) kernel needs to start providing
ABI interfaces for memory attributes instead of hiding them in libraries.
