Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 704BF6B0255
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 14:18:39 -0400 (EDT)
Received: by lblf12 with SMTP id f12so20250298lbl.2
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 11:18:39 -0700 (PDT)
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com. [209.85.217.182])
        by mx.google.com with ESMTPS id lc7si8198267lac.95.2015.07.24.11.18.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 11:18:37 -0700 (PDT)
Received: by lbbyj8 with SMTP id yj8so20289582lbb.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 11:18:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150721081755.GD4490@hori1.linux.bs1.fc.nec.co.jp>
References: <20150714152516.29844.69929.stgit@buzz>
	<20150714153749.29844.81954.stgit@buzz>
	<20150721081755.GD4490@hori1.linux.bs1.fc.nec.co.jp>
Date: Fri, 24 Jul 2015 19:18:37 +0100
Message-ID: <CAEVpBaJg4ySxozrBkcVr+CUy_HZdVJNqcdimVRA1HHPE=MRPNA@mail.gmail.com>
Subject: Re: [PATCH v4 5/5] pagemap: add mmap-exclusive bit for marking pages
 mapped only here
From: Mark Williamson <mwilliamson@undo-software.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>

Reviewed-by: Mark Williamson <mwilliamson@undo-software.com>

On Tue, Jul 21, 2015 at 9:17 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> On Tue, Jul 14, 2015 at 06:37:49PM +0300, Konstantin Khlebnikov wrote:
>> This patch sets bit 56 in pagemap if this page is mapped only once.
>> It allows to detect exclusively used pages without exposing PFN:
>>
>> present file exclusive state
>> 0       0    0         non-present
>> 1       1    0         file page mapped somewhere else
>> 1       1    1         file page mapped only here
>> 1       0    0         anon non-CoWed page (shared with parent/child)
>> 1       0    1         anon CoWed page (or never forked)
>>
>> CoWed pages in (MAP_FILE | MAP_PRIVATE) areas are anon in this context.
>>
>> MMap-exclusive bit doesn't reflect potential page-sharing via swapcache:
>> page could be mapped once but has several swap-ptes which point to it.
>> Application could detect that by swap bit in pagemap entry and touch
>> that pte via /proc/pid/mem to get real information.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>> Requested-by: Mark Williamson <mwilliamson@undo-software.com>
>> Link: http://lkml.kernel.org/r/CAEVpBa+_RyACkhODZrRvQLs80iy0sqpdrd0AaP_-tgnX3Y9yNQ@mail.gmail.com
>
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
