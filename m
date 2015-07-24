Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id AA3DF6B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 14:17:51 -0400 (EDT)
Received: by lbbyj8 with SMTP id yj8so20278515lbb.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 11:17:50 -0700 (PDT)
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com. [209.85.217.176])
        by mx.google.com with ESMTPS id ld20si8204989lbb.61.2015.07.24.11.17.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 11:17:49 -0700 (PDT)
Received: by lbbqi7 with SMTP id qi7so20198057lbb.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 11:17:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALYGNiO9wpmnrqbKhRKvfHgnUC854accifKc3m6Bvqsv0LHqXQ@mail.gmail.com>
References: <20150714152516.29844.69929.stgit@buzz>
	<20150714153738.29844.39039.stgit@buzz>
	<20150721080046.GC2475@hori1.linux.bs1.fc.nec.co.jp>
	<CALYGNiO9wpmnrqbKhRKvfHgnUC854accifKc3m6Bvqsv0LHqXQ@mail.gmail.com>
Date: Fri, 24 Jul 2015 19:17:49 +0100
Message-ID: <CAEVpBaKTMs7JQrwHQVKF5ySb58QTm6Zr+GPgZevtjgStYBk8RQ@mail.gmail.com>
Subject: Re: [PATCH v4 3/5] pagemap: rework hugetlb and thp report
From: Mark Williamson <mwilliamson@undo-software.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>

Reviewed-by: Mark Williamson <mwilliamson@undo-software.com>

On Tue, Jul 21, 2015 at 9:43 AM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> On Tue, Jul 21, 2015 at 11:00 AM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
>> On Tue, Jul 14, 2015 at 06:37:39PM +0300, Konstantin Khlebnikov wrote:
>>> This patch moves pmd dissection out of reporting loop: huge pages
>>> are reported as bunch of normal pages with contiguous PFNs.
>>>
>>> Add missing "FILE" bit in hugetlb vmas.
>>>
>>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>>
>> With reflecting Kirill's comment about #ifdef, I'm OK for this patch.
>
> That ifdef works most like documentation: "all thp magic happens here".
> I'd like to keep it, if two redundant lines isn't a big deal.
>
>>
>> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
