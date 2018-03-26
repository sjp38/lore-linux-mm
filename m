Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 265556B000D
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 11:21:17 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g66so11316252pfj.11
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 08:21:17 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id k3si6208588pgq.426.2018.03.26.08.21.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 08:21:16 -0700 (PDT)
Received: from epcas5p4.samsung.com (unknown [182.195.41.42])
	by mailout4.samsung.com (KnoxPortal) with ESMTP id 20180326152114epoutp043d7b84cb5dcd898d3e5cdca091b8d439~fgZSkclcr0565405654epoutp04e
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 15:21:14 +0000 (GMT)
Mime-Version: 1.0
Subject: RE: Re: [PATCH v2] mm/page_owner: ignore everything below the IRQ
 entry point
Reply-To: v.narang@samsung.com
From: Vaneet Narang <v.narang@samsung.com>
In-Reply-To: <CACT4Y+Yfx+fTHyQ=d3T68bwfgQQsmqd+e72V67kaAHajo536JA@mail.gmail.com>
Message-ID: <20180326141717epcms5p4064a0fd4f594b2ff434f9b05cd1ea5ad@epcms5p4>
Date: Mon, 26 Mar 2018 19:47:17 +0530
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
References: <CACT4Y+Yfx+fTHyQ=d3T68bwfgQQsmqd+e72V67kaAHajo536JA@mail.gmail.com>
	<1522058304-35934-1-git-send-email-maninder1.s@samsung.com>
	<CGME20180326100020epcas5p2b50b7541e66dccf4e49db634e5fe6b41@epcms5p4>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Maninder Singh <maninder1.s@samsung.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Kate Stewart <kstewart@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.com>, "vinmenon@codeaurora.org" <vinmenon@codeaurora.org>, "gomonovych@gmail.com" <gomonovych@gmail.com>, Ayush Mittal <ayush.m@samsung.com>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, AMIT SAHRAWAT <a.sahrawat@samsung.com>, PANKAJ MISHRA <pankaj.m@samsung.com>

Hi Dmitry,

>Every user of stack_depot should filter out irq frames, without that
>stack_depot will run out of memory sooner or later. so this is a
>change in the right direction.
> 
>Do we need to define empty version of in_irqentry_text? Shouldn't only
>filter_irq_stacks be used by kernel code?

We thought about this but since we were adding both the APIs filter_irq_stacks & in_irqentry_text 
in header file so we thought of defining empty definition for both as both the APIs are accessible
to the module who is going to include header file.

If you think empty definition of in_irqentry_text() is not requited then we will modify & resend the
patch.

Thanks & Regards,
Vaneet Narang
