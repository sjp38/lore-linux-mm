Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id DBC8E6B02A0
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 04:43:40 -0400 (EDT)
Received: by lahh5 with SMTP id h5so112902676lah.2
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 01:43:40 -0700 (PDT)
Received: from mail-lb0-x235.google.com (mail-lb0-x235.google.com. [2a00:1450:4010:c04::235])
        by mx.google.com with ESMTPS id y2si6907724lbp.9.2015.07.21.01.43.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 01:43:39 -0700 (PDT)
Received: by lblf12 with SMTP id f12so110935729lbl.2
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 01:43:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150721080046.GC2475@hori1.linux.bs1.fc.nec.co.jp>
References: <20150714152516.29844.69929.stgit@buzz>
	<20150714153738.29844.39039.stgit@buzz>
	<20150721080046.GC2475@hori1.linux.bs1.fc.nec.co.jp>
Date: Tue, 21 Jul 2015 11:43:38 +0300
Message-ID: <CALYGNiO9wpmnrqbKhRKvfHgnUC854accifKc3m6Bvqsv0LHqXQ@mail.gmail.com>
Subject: Re: [PATCH v4 3/5] pagemap: rework hugetlb and thp report
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mark Williamson <mwilliamson@undo-software.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>

On Tue, Jul 21, 2015 at 11:00 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> On Tue, Jul 14, 2015 at 06:37:39PM +0300, Konstantin Khlebnikov wrote:
>> This patch moves pmd dissection out of reporting loop: huge pages
>> are reported as bunch of normal pages with contiguous PFNs.
>>
>> Add missing "FILE" bit in hugetlb vmas.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>
> With reflecting Kirill's comment about #ifdef, I'm OK for this patch.

That ifdef works most like documentation: "all thp magic happens here".
I'd like to keep it, if two redundant lines isn't a big deal.

>
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
