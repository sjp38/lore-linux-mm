Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB4C26B0253
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 18:27:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 63so360974500pfx.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 15:27:10 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id w4si5102695pfw.47.2016.08.02.15.27.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 15:27:09 -0700 (PDT)
Received: by mail-pa0-x22b.google.com with SMTP id iw10so67088459pac.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 15:27:09 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] x86/mm: Add barriers and document switch_mm()-vs-flush synchronization follow-up
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <88fb045963d1e51cd14c05c9c4d283a1ccd29c80.1470151425.git.aquini@redhat.com>
Date: Tue, 2 Aug 2016 15:27:06 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <746D30E7-2F58-42DB-95D8-D50922CAEB7E@gmail.com>
References: <88fb045963d1e51cd14c05c9c4d283a1ccd29c80.1470151425.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Andy Lutomirski <luto@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org

Rafael Aquini <aquini@redhat.com> wrote:

> While backporting 71b3c126e611 ("x86/mm: Add barriers and document =
switch_mm()-vs-flush synchronization")
> we stumbled across a possibly missing barrier at flush_tlb_page().

I too noticed it and submitted a similar patch that never got a response =
[1].

Regards,
Nadav

[1] https://lkml.org/lkml/2016/7/15/598

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
