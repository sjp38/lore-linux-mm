Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 41D466B025F
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 18:34:36 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id p2so337476613vkg.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 15:34:36 -0700 (PDT)
Received: from mail-ua0-x22a.google.com (mail-ua0-x22a.google.com. [2607:f8b0:400c:c08::22a])
        by mx.google.com with ESMTPS id o40si1467136uao.51.2016.08.02.15.34.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 15:34:35 -0700 (PDT)
Received: by mail-ua0-x22a.google.com with SMTP id k90so139950523uak.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 15:34:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <746D30E7-2F58-42DB-95D8-D50922CAEB7E@gmail.com>
References: <88fb045963d1e51cd14c05c9c4d283a1ccd29c80.1470151425.git.aquini@redhat.com>
 <746D30E7-2F58-42DB-95D8-D50922CAEB7E@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 2 Aug 2016 15:34:14 -0700
Message-ID: <CALCETrU88S73w5SrNZbZUX3nuv1QnwfdGf2vhmYvrdSHMfiq6w@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: Add barriers and document switch_mm()-vs-flush
 synchronization follow-up
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Rafael Aquini <aquini@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Andy Lutomirski <luto@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Aug 2, 2016 at 3:27 PM, Nadav Amit <nadav.amit@gmail.com> wrote:
> Rafael Aquini <aquini@redhat.com> wrote:
>
>> While backporting 71b3c126e611 ("x86/mm: Add barriers and document switch_mm()-vs-flush synchronization")
>> we stumbled across a possibly missing barrier at flush_tlb_page().
>
> I too noticed it and submitted a similar patch that never got a response [1].
>
> Regards,
> Nadav
>
> [1] https://lkml.org/lkml/2016/7/15/598
>

Yeah, sorry, I've been busy.  I'll try to get to this soon.

-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
