Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 160766B0253
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 14:05:18 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id p63so31760834wmp.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 11:05:18 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id u187si5648910wmu.82.2016.02.12.11.05.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Feb 2016 11:05:17 -0800 (PST)
Received: by mail-wm0-x232.google.com with SMTP id g62so31905366wme.0
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 11:05:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1442903021-3893-4-git-send-email-mingo@kernel.org>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org> <1442903021-3893-4-git-send-email-mingo@kernel.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 12 Feb 2016 11:04:57 -0800
Message-ID: <CALCETrXV34q4ViE46sHN6QxucmxoBYN0xKz4p7H9Cr=7VpwQUA@mail.gmail.com>
Subject: Re: [PATCH 03/11] x86/mm/hotplug: Don't remove PGD entries in remove_pagetable()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Sep 21, 2015 at 11:23 PM, Ingo Molnar <mingo@kernel.org> wrote:
> So when memory hotplug removes a piece of physical memory from pagetable
> mappings, it also frees the underlying PGD entry.
>
> This complicates PGD management, so don't do this. We can keep the
> PGD mapped and the PUD table all clear - it's only a single 4K page
> per 512 GB of memory hotplugged.

Ressurecting an ancient thread: I want this particular change to make
it (much) easier to make vmapped stacks work correctly.  Could it be
applied by itself?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
