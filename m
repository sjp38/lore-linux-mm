Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id B24136B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 01:45:53 -0500 (EST)
Received: by mail-oi0-f51.google.com with SMTP id m82so54190611oif.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 22:45:53 -0800 (PST)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id h9si1512158oev.25.2016.03.09.22.45.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 22:45:52 -0800 (PST)
Received: by mail-oi0-x232.google.com with SMTP id d205so54216822oia.0
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 22:45:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrXV34q4ViE46sHN6QxucmxoBYN0xKz4p7H9Cr=7VpwQUA@mail.gmail.com>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
 <1442903021-3893-4-git-send-email-mingo@kernel.org> <CALCETrXV34q4ViE46sHN6QxucmxoBYN0xKz4p7H9Cr=7VpwQUA@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 9 Mar 2016 22:45:33 -0800
Message-ID: <CALCETrUijqLwS98M_EnW5OH=CSv_SwjKGC5FkAxFEcWiq0RM2A@mail.gmail.com>
Subject: Re: [PATCH 03/11] x86/mm/hotplug: Don't remove PGD entries in remove_pagetable()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

On Fri, Feb 12, 2016 at 11:04 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Mon, Sep 21, 2015 at 11:23 PM, Ingo Molnar <mingo@kernel.org> wrote:
>> So when memory hotplug removes a piece of physical memory from pagetable
>> mappings, it also frees the underlying PGD entry.
>>
>> This complicates PGD management, so don't do this. We can keep the
>> PGD mapped and the PUD table all clear - it's only a single 4K page
>> per 512 GB of memory hotplugged.
>
> Ressurecting an ancient thread: I want this particular change to make
> it (much) easier to make vmapped stacks work correctly.  Could it be
> applied by itself?
>

It's incomplete.  pageattr.c has another instance of the same thing.
I'll see if I can make it work, but I may end up doing something a
little different.

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
