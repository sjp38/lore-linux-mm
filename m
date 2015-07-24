Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id AC7D96B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 13:34:22 -0400 (EDT)
Received: by lagw2 with SMTP id w2so18170623lag.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 10:34:22 -0700 (PDT)
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com. [209.85.217.182])
        by mx.google.com with ESMTPS id rz3si8122417lbb.7.2015.07.24.10.34.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 10:34:20 -0700 (PDT)
Received: by lbbqi7 with SMTP id qi7so19554874lbb.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 10:34:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150714152516.29844.69929.stgit@buzz>
References: <20150714152516.29844.69929.stgit@buzz>
Date: Fri, 24 Jul 2015 18:34:19 +0100
Message-ID: <CAEVpBaLeG=C=01L39Dk76aY4PNLmnj5g5gKpE_nYZb84T9rHNg@mail.gmail.com>
Subject: Re: [PATCHSET v4 0/5] pagemap: make useable for non-privilege users
From: Mark Williamson <mwilliamson@undo-software.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

Hi Konstantin,

Thank you for the further update - I tested this patchset against our
code and it allows our software to work correctly (with minor userland
changes, as before).

I'll follow up with review messages but there aren't really any
concerns that I can see.

Cheers,
Mark

On Tue, Jul 14, 2015 at 4:37 PM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> This patchset makes pagemap useable again in the safe way (after row hammer
> bug it was made CAP_SYS_ADMIN-only). This patchset restores access for
> non-privileged users but hides PFNs from them.
>
> Also it adds bit 'map-exlusive' which is set if page is mapped only here:
> it helps in estimation of working set without exposing pfns and allows to
> distinguish CoWed and non-CoWed private anonymous pages.
>
> Second patch removes page-shift bits and completes migration to the new
> pagemap format: flags soft-dirty and mmap-exlusive are available only
> in the new format.
>
> Changes since v3:
> * patches reordered: cleanup now in second patch
> * update pagemap for hugetlb, add missing 'FILE' bit
> * fix PM_PFRAME_BITS: its 55 not 54 as was in previous versions
>
> ---
>
> Konstantin Khlebnikov (5):
>       pagemap: check permissions and capabilities at open time
>       pagemap: switch to the new format and do some cleanup
>       pagemap: rework hugetlb and thp report
>       pagemap: hide physical addresses from non-privileged users
>       pagemap: add mmap-exclusive bit for marking pages mapped only here
>
>
>  Documentation/vm/pagemap.txt |    3
>  fs/proc/task_mmu.c           |  267 ++++++++++++++++++------------------------
>  tools/vm/page-types.c        |   35 +++---
>  3 files changed, 137 insertions(+), 168 deletions(-)
>
> --
> Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
