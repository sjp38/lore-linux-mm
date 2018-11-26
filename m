Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 18FD86B426E
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 10:38:53 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id 62so8658419otr.14
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 07:38:53 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m1si283788otl.73.2018.11.26.07.38.51
        for <linux-mm@kvack.org>;
        Mon, 26 Nov 2018 07:38:51 -0800 (PST)
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
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <1a9e887b-8087-e897-6195-e8df325bd458@arm.com>
Date: Mon, 26 Nov 2018 21:08:51 +0530
MIME-Version: 1.0
In-Reply-To: <9015e51a-3584-7bb2-cc5e-25b0ec8e5494@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dan Williams <dan.j.williams@intel.com>



On 11/24/2018 12:51 AM, Dave Hansen wrote:
> On 11/22/18 10:42 PM, Anshuman Khandual wrote:
>> Are we willing to go in the direction for inclusion of a new system
>> call, subset of it appears on sysfs etc ? My primary concern is not
>> how the attribute information appears on the sysfs but lack of it's
>> completeness.
> 
> A new system call makes total sense to me.  I have the same concern
> about the completeness of what's exposed in sysfs, I just don't see a
> _route_ to completeness with sysfs itself.  Thus, the minimalist
> approach as a first step.

Okay if we agree on the need for a new specific system call extracting
the superset attribute information MAX_NUMNODES * MAX_NUMNODES * U64
(u64 packs 8 bit values for 8 attributes or something like that) as we
had discussed before, it makes sense to export a subset of it which can
be faster but useful for the user space without going through a system
call. Do you agree on a (system call + sysfs) approach in principle ?
Also sysfs exported information has to be derived from whats available
through the system call not the other way round. Hence the starting
point has to be the system call definition.
