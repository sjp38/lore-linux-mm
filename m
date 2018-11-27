Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0D91E6B4957
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:56:23 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id t83so10516431oie.16
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:56:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k11sor1865563oif.101.2018.11.27.08.56.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 08:56:22 -0800 (PST)
MIME-Version: 1.0
References: <20181114224902.12082-1-keith.busch@intel.com> <1ed406b2-b85f-8e02-1df0-7c39aa21eca9@arm.com>
 <4ea6e80f-80ba-6992-8aa0-5c2d88996af7@intel.com> <b79804b0-32ee-03f9-fa62-a89684d46be6@arm.com>
 <c6abb754-0d82-8739-fe08-24e9402bae75@intel.com> <aae34dde-fa70-870a-9b74-fff9e385bfc9@arm.com>
 <f5315662-5c1a-68a3-4d04-21b4b5ca94b1@intel.com> <ac942498-8966-6a9b-0e55-c79ae167c679@arm.com>
 <9015e51a-3584-7bb2-cc5e-25b0ec8e5494@intel.com> <CAPcyv4jnnnXi9Fqaf-d7AdnKrTMDCWr-e9tAx+G6nphrEPYm=w@mail.gmail.com>
 <b9962dfa-924f-77f7-a40f-407dd20e9082@intel.com> <CAPcyv4hVFMvut9+Rq7G41yyKzV072U33YEeHNh160VBr3QW-nw@mail.gmail.com>
 <325d0e69-053a-ae9c-eede-7cdf28b1dbd6@arm.com>
In-Reply-To: <325d0e69-053a-ae9c-eede-7cdf28b1dbd6@arm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 27 Nov 2018 08:56:09 -0800
Message-ID: <CAPcyv4iA+yA_OZMUSbJTV=c9=QsRAcLjzLK94uuVsMTaPu6eTg@mail.gmail.com>
Subject: Re: [PATCH 0/7] ACPI HMAT memory sysfs representation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: anshuman.khandual@arm.com
Cc: Dave Hansen <dave.hansen@intel.com>, Keith Busch <keith.busch@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>

On Tue, Nov 27, 2018 at 2:15 AM Anshuman Khandual
<anshuman.khandual@arm.com> wrote:
>
>
>
> On 11/26/2018 11:38 PM, Dan Williams wrote:
> > On Mon, Nov 26, 2018 at 8:42 AM Dave Hansen <dave.hansen@intel.com> wrote:
> >>
> >> On 11/23/18 1:13 PM, Dan Williams wrote:
> >>>> A new system call makes total sense to me.  I have the same concern
> >>>> about the completeness of what's exposed in sysfs, I just don't see a
> >>>> _route_ to completeness with sysfs itself.  Thus, the minimalist
> >>>> approach as a first step.
> >>> Outside of platform-firmware-id to Linux-numa-node-id what other
> >>> userspace API infrastructure does the kernel need to provide? It seems
> >>> userspace enumeration of memory attributes is fully enabled once the
> >>> firmware-to-Linux identification is established.
> >>
> >> It would be nice not to have each app need to know about each specific
> >> platform's firmware.
> >
> > The app wouldn't need to know if it uses a common library. Whether the
> > library calls into the kernel or not is an implementation detail. If
> > it is information that only the app cares about and the kernel does
> > not consume, why have a syscall?
>
> If we just care about platform-firmware-id <--> Linux-numa-node-id mapping
> and fetching memory attribute from the platform (and hiding implementation
> details in a library) then the following interface should be sufficient.
>
> /sys/devices/system/node/nodeX/platform_id
>
> But as the series proposes (and rightly so) kernel needs to start providing
> ABI interfaces for memory attributes instead of hiding them in libraries.

Yes, I can get on board with sysfs providing a subset of the
performance description for administrators to discover the common case
via scripting and leave the exhaustive attribute description to a
separate interface. I was pushing back on the notion that sysfs must
be that exhaustive interface... we're making progress.

I still think we need /sys/devices/system/node/nodeX/platform_id to
enable higher order platform enumeration tooling, but that need not be
the end of the kernel interface description.
