Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id D98FE6B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 07:13:32 -0400 (EDT)
Received: by lagv1 with SMTP id v1so2918156lag.3
        for <linux-mm@kvack.org>; Tue, 12 May 2015 04:13:32 -0700 (PDT)
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com. [209.85.215.45])
        by mx.google.com with ESMTPS id u8si10149594laj.60.2015.05.12.04.13.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 04:13:31 -0700 (PDT)
Received: by lagv1 with SMTP id v1so2917560lag.3
        for <linux-mm@kvack.org>; Tue, 12 May 2015 04:13:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150512090156.24768.2521.stgit@buzz>
References: <20150512090156.24768.2521.stgit@buzz>
Date: Tue, 12 May 2015 12:13:30 +0100
Message-ID: <CAEVpBa+-wwf5Q3CwQAAad3V0pJ+uD50uaHKW=EnChLDLOLSAGg@mail.gmail.com>
Subject: Re: [PATCH RFC 0/3] pagemap: make useable for non-privilege users
From: Mark Williamson <mwilliamson@undo-software.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, kernel list <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, Linux API <linux-api@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Machek <pavel@ucw.cz>, Mark Seaborn <mseaborn@chromium.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, Daniel James <djames@undo-software.com>, Finn Grimwood <fgrimwood@undo-software.com>

Hi Konstantin,

Thanks very much for continuing to look at this!  It's very much
appreciated.  I've been investigating from our end but got caught up
in some gnarly details of our pagemap-consuming code.

I like the approach and it seems like the information you're exposing
will be useful for our application.  I'll test the patch and see if it
works for us as-is.

Will follow up with any comments on the individual patches.

Thanks,
Mark

On Tue, May 12, 2015 at 10:43 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> This patchset tries to make pagemap useable again in the safe way.
> First patch adds bit 'map-exlusive' which is set if page is mapped only here.
> Second patch restores access for non-privileged users but hides pfn if task
> has no capability CAP_SYS_ADMIN. Third patch removes page-shift bits and
> completes migration to the new pagemap format (flags soft-dirty and
> mmap-exlusive are available only in the new format).
>
> ---
>
> Konstantin Khlebnikov (3):
>       pagemap: add mmap-exclusive bit for marking pages mapped only here
>       pagemap: hide physical addresses from non-privileged users
>       pagemap: switch to the new format and do some cleanup
>
>
>  Documentation/vm/pagemap.txt |    3 -
>  fs/proc/task_mmu.c           |  178 +++++++++++++++++-------------------------
>  tools/vm/page-types.c        |   35 ++++----
>  3 files changed, 91 insertions(+), 125 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
