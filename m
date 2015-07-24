Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id AB56F6B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 14:16:42 -0400 (EDT)
Received: by lafd3 with SMTP id d3so8447380laf.1
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 11:16:41 -0700 (PDT)
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com. [209.85.217.171])
        by mx.google.com with ESMTPS id qo9si8192072lbc.100.2015.07.24.11.16.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 11:16:40 -0700 (PDT)
Received: by lblf12 with SMTP id f12so20222222lbl.2
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 11:16:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150721080626.GB4490@hori1.linux.bs1.fc.nec.co.jp>
References: <20150714152516.29844.69929.stgit@buzz>
	<20150714153735.29844.38428.stgit@buzz>
	<20150721080626.GB4490@hori1.linux.bs1.fc.nec.co.jp>
Date: Fri, 24 Jul 2015 19:16:39 +0100
Message-ID: <CAEVpBaKsFLRx-tfy_zC-3Yqp++wKMKjULEKN-Mq5mnZK2bjS1Q@mail.gmail.com>
Subject: Re: [PATCH v4 1/5] pagemap: check permissions and capabilities at
 open time
From: Mark Williamson <mwilliamson@undo-software.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>

(within the limits of my understanding of the mm code)
Reviewed-by: Mark Williamson <mwilliamson@undo-software.com>

On Tue, Jul 21, 2015 at 9:06 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> On Tue, Jul 14, 2015 at 06:37:35PM +0300, Konstantin Khlebnikov wrote:
>> This patch moves permission checks from pagemap_read() into pagemap_open().
>>
>> Pointer to mm is saved in file->private_data. This reference pins only
>> mm_struct itself. /proc/*/mem, maps, smaps already work in the same way.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>> Link: http://lkml.kernel.org/r/CA+55aFyKpWrt_Ajzh1rzp_GcwZ4=6Y=kOv8hBz172CFJp6L8Tg@mail.gmail.com
>
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
