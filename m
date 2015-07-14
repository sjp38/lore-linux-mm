Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 59DBE280257
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 16:15:44 -0400 (EDT)
Received: by lbbzr7 with SMTP id zr7so12840358lbb.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 13:15:43 -0700 (PDT)
Received: from mail-lb0-x229.google.com (mail-lb0-x229.google.com. [2a00:1450:4010:c04::229])
        by mx.google.com with ESMTPS id cv1si1922892lbb.49.2015.07.14.13.15.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 13:15:42 -0700 (PDT)
Received: by lbbyj8 with SMTP id yj8so12835625lbb.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 13:15:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150714115252.8f21cfa864935a4b403c3d8d@linux-foundation.org>
References: <20150714152516.29844.69929.stgit@buzz>
	<20150714115252.8f21cfa864935a4b403c3d8d@linux-foundation.org>
Date: Tue, 14 Jul 2015 23:15:41 +0300
Message-ID: <CALYGNiPidOy47E5ArW28ny4m+nTN5P8gAjYZtdC2_C1nV-yomQ@mail.gmail.com>
Subject: Re: [PATCHSET v4 0/5] pagemap: make useable for non-privilege users
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mark Williamson <mwilliamson@undo-software.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue, Jul 14, 2015 at 9:52 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 14 Jul 2015 18:37:34 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:
>
>> This patchset makes pagemap useable again in the safe way (after row hammer
>> bug it was made CAP_SYS_ADMIN-only). This patchset restores access for
>> non-privileged users but hides PFNs from them.
>
> Documentation/vm/pagemap.txt hasn't been updated to describe these
> privilege issues?

Will do. Too much time passed between versions, I planned but forgot about that.

>
>> Also it adds bit 'map-exlusive' which is set if page is mapped only here:
>> it helps in estimation of working set without exposing pfns and allows to
>> distinguish CoWed and non-CoWed private anonymous pages.
>>
>> Second patch removes page-shift bits and completes migration to the new
>> pagemap format: flags soft-dirty and mmap-exlusive are available only
>> in the new format.
>
> I'm not really seeing a description of the new format in these
> changelogs.  Precisely what got removed, what got added and which
> capabilities change the output in what manner?

Now pfn (bits 0-54) is zero if task who opened pagemap has no
CAP_SYS_ADMIN (system-wide).

in v2 format page-shift (bits 55-60) now used for flags:
55 - soft-dirty (added for checkpoint-restore, I guess)
56 - mmap-exclusive (added in last patch)
57-60 - free for use

I'll document the history of these changes.

>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
