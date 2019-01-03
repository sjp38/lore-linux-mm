Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id AECD48E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 13:47:11 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id p20so11128104ywe.5
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 10:47:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 195sor7609305ywh.176.2019.01.03.10.47.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 10:47:10 -0800 (PST)
Date: Thu, 3 Jan 2019 10:47:06 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHv3 1/2] mm/memblock: extend the limit inferior of
 bottom-up after parsing hotplug attr
Message-ID: <20190103184706.GU2509588@devbig004.ftw2.facebook.com>
References: <1545966002-3075-1-git-send-email-kernelfans@gmail.com>
 <1545966002-3075-2-git-send-email-kernelfans@gmail.com>
 <20181231084018.GA28478@rapoport-lnx>
 <CAFgQCTvQnj7zReFvH_gmfVJdPXE325o+z4Xx76fupvsLR_7H2A@mail.gmail.com>
 <20190102092749.GA22664@rapoport-lnx>
 <20190102101804.GD1990@MiWiFi-R3L-srv>
 <20190102170537.GA3591@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190102170537.GA3591@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Baoquan He <bhe@redhat.com>, Pingfan Liu <kernelfans@gmail.com>, linux-acpi@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Nicholas Piggin <npiggin@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Daniel Vacek <neelx@redhat.com>, Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, Dave Young <dyoung@redhat.com>, yinghai@kernel.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org

Hello,

On Wed, Jan 02, 2019 at 07:05:38PM +0200, Mike Rapoport wrote:
> I agree that currently the bottom-up allocation after the kernel text has
> issues with KASLR. But this issues are not necessarily related to the
> memory hotplug. Even with a single memory node, a bottom-up allocation will
> fail if KASLR would put the kernel near the end of node0.
> 
> What I am trying to understand is whether there is a fundamental reason to
> prevent allocations from [0, kernel_start)?
> 
> Maybe Tejun can recall why he suggested to start bottom-up allocations from
> kernel_end.

That's from 79442ed189ac ("mm/memblock.c: introduce bottom-up
allocation mode").  I wasn't involved in that patch, so no idea why
the restrictions were added, but FWIW it doesn't seem necessary to me.

Thanks.

-- 
tejun
