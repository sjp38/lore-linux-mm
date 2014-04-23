Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id F38FD6B0070
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 22:51:39 -0400 (EDT)
Received: by mail-qc0-f173.google.com with SMTP id r5so349071qcx.4
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 19:51:39 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id gq5si17841624qab.95.2014.04.22.19.51.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Apr 2014 19:51:39 -0700 (PDT)
Message-ID: <53572AAA.4070207@zytor.com>
Date: Tue, 22 Apr 2014 19:51:22 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: Why do we set _PAGE_DIRTY for page tables?
References: <5356FCC1.6060807@zytor.com> <CA+55aFwsPs12_57YEBHdb4ti1BXSuDX_RPSf6S4JSRLGK_2X7Q@mail.gmail.com>
In-Reply-To: <CA+55aFwsPs12_57YEBHdb4ti1BXSuDX_RPSf6S4JSRLGK_2X7Q@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/22/2014 07:48 PM, Linus Torvalds wrote:
> On Tue, Apr 22, 2014 at 4:35 PM, H. Peter Anvin <hpa@zytor.com> wrote:
>> I just noticed this:
>>
>> #define _PAGE_TABLE     (_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |       \
>>                          _PAGE_ACCESSED | _PAGE_DIRTY)
>> #define _KERNPG_TABLE   (_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED |   \
>>                          _PAGE_DIRTY)
>>
>> Is there a reason we set _PAGE_DIRTY for page tables?  It has no
>> function, but doesn't do any harm either (the dirty bit is ignored for
>> page tables)... it just looks funny to me.
> 
> I think it just got copied, and at least the A bit does matter even in
> page tables (well, it gets updated, I don't know how much that
> "matters"). So the fact that D is ignored is actually the odd man out.
> 

Yes, not setting the A bit means the hardware will take an assist to set
the bit for us, which is a waste of time if we don't care about it.  The
D bit is the one which made me wonder; I thought either it was just copy
& paste, or that it got set to make it more analogous with large pages.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
