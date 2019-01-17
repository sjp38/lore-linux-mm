Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 167A08E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 11:51:10 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id d7so3623639oif.5
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 08:51:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z79sor944928oia.97.2019.01.17.08.51.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 08:51:08 -0800 (PST)
MIME-Version: 1.0
References: <20190116181859.D1504459@viggo.jf.intel.com> <x49sgxr9rjd.fsf@segfault.boston.devel.redhat.com>
In-Reply-To: <x49sgxr9rjd.fsf@segfault.boston.devel.redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 17 Jan 2019 08:50:57 -0800
Message-ID: <CAPcyv4je0XXWjej+xM4+gidryQH=p_sevD=eL6w8f-vDQzMm3w@mail.gmail.com>
Subject: Re: [PATCH 0/4] Allow persistent memory to be used like normal RAM
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Tom Lendacky <thomas.lendacky@amd.com>, Fengguang Wu <fengguang.wu@intel.com>, Dave Hansen <dave@sr71.net>, linux-nvdimm <linux-nvdimm@lists.01.org>, Takashi Iwai <tiwai@suse.de>, Ross Zwisler <zwisler@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, "Huang, Ying" <ying.huang@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@suse.de>

On Thu, Jan 17, 2019 at 8:29 AM Jeff Moyer <jmoyer@redhat.com> wrote:
>
> Dave Hansen <dave.hansen@linux.intel.com> writes:
>
> > Persistent memory is cool.  But, currently, you have to rewrite
> > your applications to use it.  Wouldn't it be cool if you could
> > just have it show up in your system like normal RAM and get to
> > it like a slow blob of memory?  Well... have I got the patch
> > series for you!
>
> So, isn't that what memory mode is for?
>   https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/

That's a hardware cache that privately manages DRAM in front of PMEM.
It benefits from some help from software [1].

> Why do we need this code in the kernel?

This goes further and enables software managed allocation decisions
with the full DRAM + PMEM address space.

[1]: https://lore.kernel.org/lkml/154767945660.1983228.12167020940431682725.stgit@dwillia2-desk3.amr.corp.intel.com/
