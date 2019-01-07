Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2790B8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 03:38:07 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id 135so25332itk.5
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 00:38:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l125sor32115426iof.41.2019.01.07.00.38.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 00:38:06 -0800 (PST)
MIME-Version: 1.0
References: <1545966002-3075-1-git-send-email-kernelfans@gmail.com>
 <1545966002-3075-2-git-send-email-kernelfans@gmail.com> <20181231084018.GA28478@rapoport-lnx>
 <CAFgQCTvQnj7zReFvH_gmfVJdPXE325o+z4Xx76fupvsLR_7H2A@mail.gmail.com>
 <20190102092749.GA22664@rapoport-lnx> <20190102101804.GD1990@MiWiFi-R3L-srv>
 <20190102170537.GA3591@rapoport-lnx> <20190103184706.GU2509588@devbig004.ftw2.facebook.com>
In-Reply-To: <20190103184706.GU2509588@devbig004.ftw2.facebook.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 7 Jan 2019 16:37:54 +0800
Message-ID: <CAFgQCTt2=6mwFid8HS+K5UsqkBv8y7N5WOoKpVxYzNxjwmV75A@mail.gmail.com>
Subject: Re: [PATCHv3 1/2] mm/memblock: extend the limit inferior of bottom-up
 after parsing hotplug attr
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>, Baoquan He <bhe@redhat.com>, linux-acpi@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Nicholas Piggin <npiggin@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Daniel Vacek <neelx@redhat.com>, Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, Dave Young <dyoung@redhat.com>, yinghai@kernel.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org

I send out a series [RFC PATCH 0/4] x86_64/mm: remove bottom-up
allocation style by pushing forward the parsing of mem hotplug info (
https://lore.kernel.org/lkml/1546849485-27933-1-git-send-email-kernelfans@gmail.com/T/#t).
Please give comment if you are interested.

Thanks,
Pingfan

On Fri, Jan 4, 2019 at 2:47 AM Tejun Heo <tj@kernel.org> wrote:
>
> Hello,
>
> On Wed, Jan 02, 2019 at 07:05:38PM +0200, Mike Rapoport wrote:
> > I agree that currently the bottom-up allocation after the kernel text has
> > issues with KASLR. But this issues are not necessarily related to the
> > memory hotplug. Even with a single memory node, a bottom-up allocation will
> > fail if KASLR would put the kernel near the end of node0.
> >
> > What I am trying to understand is whether there is a fundamental reason to
> > prevent allocations from [0, kernel_start)?
> >
> > Maybe Tejun can recall why he suggested to start bottom-up allocations from
> > kernel_end.
>
> That's from 79442ed189ac ("mm/memblock.c: introduce bottom-up
> allocation mode").  I wasn't involved in that patch, so no idea why
> the restrictions were added, but FWIW it doesn't seem necessary to me.
>
> Thanks.
>
> --
> tejun
