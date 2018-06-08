Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id F2D606B0005
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 13:05:11 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id j24-v6so8866969otk.11
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 10:05:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h64-v6sor5608752oig.60.2018.06.08.10.05.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Jun 2018 10:05:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <152847720311.55924.16999195879201817653.stgit@djiang5-desk3.ch.intel.com>
References: <152847720311.55924.16999195879201817653.stgit@djiang5-desk3.ch.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 8 Jun 2018 10:05:10 -0700
Message-ID: <CAPcyv4h+OTXvfLiG8cpS7nO5wkUTkZBsyq9iq6FB_FG4wi4naA@mail.gmail.com>
Subject: Re: [PATCH] dax: remove VM_MIXEDMAP for fsdax and device dax
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>

On Fri, Jun 8, 2018 at 10:00 AM, Dave Jiang <dave.jiang@intel.com> wrote:
> This patch is reworked from an earlier patch that Dan has posted:
> https://patchwork.kernel.org/patch/10131727/
>
> VM_MIXEDMAP is used by dax to direct mm paths like vm_normal_page() that
> the memory page it is dealing with is not typical memory from the linear
> map. The get_user_pages_fast() path, since it does not resolve the vma,
> is already using {pte,pmd}_devmap() as a stand-in for VM_MIXEDMAP, so we
> use that as a VM_MIXEDMAP replacement in some locations. In the cases
> where there is no pte to consult we fallback to using vma_is_dax() to
> detect the VM_MIXEDMAP special case.
>
> Now that we have explicit driver pfn_t-flag opt-in/opt-out for
> get_user_pages() support for DAX we can stop setting VM_MIXEDMAP.  This
> also means we no longer need to worry about safely manipulating vm_flags
> in a future where we support dynamically changing the dax mode of a
> file.
>
> DAX should also now be supported with madvise_behavior(), vma_merge(),
> and copy_page_range().
>
> This patch has been tested against ndctl unit test. It has also been
> tested against xfstests commit: 625515d using fake pmem created by memmap
> and no additional issues have been observed.
>
> Signed-off-by: Dave Jiang <dave.jiang@intel.com>

Acked-by: Dan Williams <dan.j.williams@intel.com>
