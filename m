Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 763326B0032
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 00:59:35 -0400 (EDT)
Received: by laka10 with SMTP id a10so24658349lak.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 21:59:34 -0700 (PDT)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com. [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id lv3si1383977lac.87.2015.06.16.21.59.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 21:59:34 -0700 (PDT)
Received: by lblr1 with SMTP id r1so23704706lbl.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 21:59:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150616142935.b8f679650e35534e75806399@linux-foundation.org>
References: <20150609200021.21971.13598.stgit@zurg>
	<20150615055649.4485.92087.stgit@zurg>
	<20150616142935.b8f679650e35534e75806399@linux-foundation.org>
Date: Wed, 17 Jun 2015 07:59:33 +0300
Message-ID: <CALYGNiNrEPffQwhjhqB6jor5b8w6BQ=KnAa3LrxQ6QFKERH_mQ@mail.gmail.com>
Subject: Re: [PATCH v4] pagemap: switch to the new format and do some cleanup
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mark Williamson <mwilliamson@undo-software.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux API <linux-api@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Wed, Jun 17, 2015 at 12:29 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 15 Jun 2015 08:56:49 +0300 Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>
>> This patch removes page-shift bits (scheduled to remove since 3.11) and
>> completes migration to the new bit layout. Also it cleans messy macro.
>
> hm, I can't find any kernel version to which this patch comes close to
> applying.

This patchset applies to  4.1-rc8 and current mmotm without problems.
I guess you've tried pick this patch alone without previous changes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
