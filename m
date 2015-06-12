Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 33BC56B0073
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 14:59:34 -0400 (EDT)
Received: by lacny3 with SMTP id ny3so6338063lac.3
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 11:59:33 -0700 (PDT)
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com. [209.85.215.49])
        by mx.google.com with ESMTPS id mr8si4072201lbb.104.2015.06.12.11.59.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jun 2015 11:59:32 -0700 (PDT)
Received: by lacdj3 with SMTP id dj3so6378699lac.0
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 11:59:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150609195333.21971.58194.stgit@zurg>
References: <20150609195333.21971.58194.stgit@zurg>
Date: Fri, 12 Jun 2015 19:59:31 +0100
Message-ID: <CAEVpBaK78nBijPLWrdBkmnSwLPoiZoZ5q=UQ6DzKDPmv2n-9eA@mail.gmail.com>
Subject: Re: [PATCHSET v3 0/4] pagemap: make useable for non-privilege users
From: Mark Williamson <mwilliamson@undo-software.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux API <linux-api@vger.kernel.org>, kernel list <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

Hi Konstantin,

Thanks very much for your help on this.

>From our side, I've tested our application against a patched kernel
and I confirm that the functionality can replace what we lost when
PFNs were removed from /proc/PID/pagemap.  This addresses the
functionality regression from our PoV (just requires minor userspace
changes on our part, which is fine).

I also reviewed the patch content and everything seemed good to me.

We're keen to see these get into mainline, so let us know if there's
anything we can do to help.

Cheers,
Mark

On Tue, Jun 9, 2015 at 9:00 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> This patchset makes pagemap useable again in the safe way. It adds bit
> 'map-exlusive' which is set if page is mapped only here and restores
> access for non-privileged users but hides pfn from them.
>
> Last patch removes page-shift bits and completes migration to the new
> pagemap format: flags soft-dirty and mmap-exlusive are available only
> in the new format.
>
> v3: check permissions in ->open
>
> ---
>
> Konstantin Khlebnikov (4):
>       pagemap: check permissions and capabilities at open time
>       pagemap: add mmap-exclusive bit for marking pages mapped only here
>       pagemap: hide physical addresses from non-privileged users
>       pagemap: switch to the new format and do some cleanup
>
>
>  Documentation/vm/pagemap.txt |    3 -
>  fs/proc/task_mmu.c           |  219 +++++++++++++++++++-----------------------
>  tools/vm/page-types.c        |   35 +++----
>  3 files changed, 118 insertions(+), 139 deletions(-)
>
> --
> Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
