Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 66FBC6B32DD
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 16:13:49 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id v184so1288594oie.6
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 13:13:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e1sor6731722otp.114.2018.11.23.13.13.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Nov 2018 13:13:48 -0800 (PST)
MIME-Version: 1.0
References: <20181114224902.12082-1-keith.busch@intel.com> <1ed406b2-b85f-8e02-1df0-7c39aa21eca9@arm.com>
 <4ea6e80f-80ba-6992-8aa0-5c2d88996af7@intel.com> <b79804b0-32ee-03f9-fa62-a89684d46be6@arm.com>
 <c6abb754-0d82-8739-fe08-24e9402bae75@intel.com> <aae34dde-fa70-870a-9b74-fff9e385bfc9@arm.com>
 <f5315662-5c1a-68a3-4d04-21b4b5ca94b1@intel.com> <ac942498-8966-6a9b-0e55-c79ae167c679@arm.com>
 <9015e51a-3584-7bb2-cc5e-25b0ec8e5494@intel.com>
In-Reply-To: <9015e51a-3584-7bb2-cc5e-25b0ec8e5494@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 23 Nov 2018 13:13:36 -0800
Message-ID: <CAPcyv4jnnnXi9Fqaf-d7AdnKrTMDCWr-e9tAx+G6nphrEPYm=w@mail.gmail.com>
Subject: Re: [PATCH 0/7] ACPI HMAT memory sysfs representation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: anshuman.khandual@arm.com, Keith Busch <keith.busch@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>

On Fri, Nov 23, 2018 at 11:21 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 11/22/18 10:42 PM, Anshuman Khandual wrote:
> > Are we willing to go in the direction for inclusion of a new system
> > call, subset of it appears on sysfs etc ? My primary concern is not
> > how the attribute information appears on the sysfs but lack of it's
> > completeness.
>
> A new system call makes total sense to me.  I have the same concern
> about the completeness of what's exposed in sysfs, I just don't see a
> _route_ to completeness with sysfs itself.  Thus, the minimalist
> approach as a first step.

Outside of platform-firmware-id to Linux-numa-node-id what other
userspace API infrastructure does the kernel need to provide? It seems
userspace enumeration of memory attributes is fully enabled once the
firmware-to-Linux identification is established.
