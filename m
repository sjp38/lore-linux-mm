Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id B10226B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 04:56:05 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l68so21160263wml.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 01:56:05 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id i1si3634675wmd.89.2016.03.10.01.56.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 01:56:04 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id n205so2815546wmf.2
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 01:56:04 -0800 (PST)
Date: Thu, 10 Mar 2016 10:56:01 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 03/11] x86/mm/hotplug: Don't remove PGD entries in
 remove_pagetable()
Message-ID: <20160310095601.GA9677@gmail.com>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
 <1442903021-3893-4-git-send-email-mingo@kernel.org>
 <CALCETrXV34q4ViE46sHN6QxucmxoBYN0xKz4p7H9Cr=7VpwQUA@mail.gmail.com>
 <CALCETrUijqLwS98M_EnW5OH=CSv_SwjKGC5FkAxFEcWiq0RM2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUijqLwS98M_EnW5OH=CSv_SwjKGC5FkAxFEcWiq0RM2A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>


* Andy Lutomirski <luto@amacapital.net> wrote:

> On Fri, Feb 12, 2016 at 11:04 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> > On Mon, Sep 21, 2015 at 11:23 PM, Ingo Molnar <mingo@kernel.org> wrote:
> >> So when memory hotplug removes a piece of physical memory from pagetable
> >> mappings, it also frees the underlying PGD entry.
> >>
> >> This complicates PGD management, so don't do this. We can keep the
> >> PGD mapped and the PUD table all clear - it's only a single 4K page
> >> per 512 GB of memory hotplugged.
> >
> > Ressurecting an ancient thread: I want this particular change to make
> > it (much) easier to make vmapped stacks work correctly.  Could it be
> > applied by itself?
> >
> 
> It's incomplete.  pageattr.c has another instance of the same thing.
> I'll see if I can make it work, but I may end up doing something a
> little different.

If so then mind picking up (and fixing ;-) tip:WIP.x86/mm in its entirety? It's 
well tested so shouldn't have too many easy to hit bugs. Feel free to rebase and 
restructure it, it's a WIP tree.

I keep getting distracted with other things but I'd hate if this got dropped on 
the floor.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
