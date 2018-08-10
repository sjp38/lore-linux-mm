Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 56ED56B0003
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 10:25:49 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p14-v6so9347537oip.0
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 07:25:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k185-v6sor5721394oif.68.2018.08.10.07.25.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Aug 2018 07:25:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180810130052.GC1644@dhcp22.suse.cz>
References: <20180809025409.31552-1-rashmica.g@gmail.com> <20180809181224.0b7417e51215565dbda9f665@linux-foundation.org>
 <CAC6rBs=yYYZw-c02yp6rx-+TN2oUGgrp=uuLhZ=Kc_nnjmTRqA@mail.gmail.com> <20180810130052.GC1644@dhcp22.suse.cz>
From: Rashmica Gupta <rashmica.g@gmail.com>
Date: Sat, 11 Aug 2018 00:25:39 +1000
Message-ID: <CAC6rBsmkTSSg1RhWkpU-t+tQdyz7NKbfu96tX9BG1=LOGVg-Bw@mail.gmail.com>
Subject: Re: [PATCH v3] resource: Merge resources on a node when hot-adding memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, toshi.kani@hpe.com, tglx@linutronix.de, bp@suse.de, brijesh.singh@amd.com, thomas.lendacky@amd.com, jglisse@redhat.com, gregkh@linuxfoundation.org, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, Vlastimil Babka <vbabka@suse.cz>, malat@debian.org, Bjorn Helgaas <bhelgaas@google.com>, Oscar Salvador <osalvador@techadventures.net>, yasu.isimatu@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

On Fri, Aug 10, 2018 at 11:00 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 10-08-18 16:55:40, Rashmica Gupta wrote:
> [...]
>> Most memory hotplug/hotremove seems to be block or section based, and
>> always adds and removes memory at the same place.
>
> Yes and that is hard wired to the memory hotplug code. It is not easy to
> make it work outside of section units restriction. So whatever your
> memtrace is doing and if it relies on subsection hotplug it cannot
> possibly work with the current code.
>
> I didn't get to review your patch but if it is only needed for an
> unmerged code I would rather incline to not merge it unless it is a
> clear win to the resource subsystem. A report from Oscar shows that this
> is not the case though.
>

Yup, makes sense. I'll work on it and see if I can not break things.

> --
> Michal Hocko
> SUSE Labs
