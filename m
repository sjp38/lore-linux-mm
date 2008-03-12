Received: by wa-out-1112.google.com with SMTP id m33so3104081wag.8
        for <linux-mm@kvack.org>; Wed, 12 Mar 2008 09:40:37 -0700 (PDT)
Message-ID: <6934efce0803120940x49707de7icb66d9cb6950ea86@mail.gmail.com>
Date: Wed, 12 Mar 2008 09:40:37 -0700
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [patch 0/7] [rfc] VM_MIXEDMAP, pte_special, xip work
In-Reply-To: <200803121633.34539.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080311104653.995564000@nick.local0.net>
	 <20080311213525.a5994894.akpm@linux-foundation.org>
	 <200803121633.34539.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, npiggin@nick.local0.net, Linus Torvalds <torvalds@linux-foundation.org>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>  2. VM_MIXEDMAP allows us to support mappings where you actually do want
>    to refcount _some_ pages in the mapping, but not others. I haven't
>    actually seen his code, but I understand Jared requires this for his
>    filesystem that can migrate pages between RAM and XIP/NVRAM
>    transparently. Obviously the filesystem isn't finished yet, but
>    Jared is relying on these changes for it to work.

So the filesystem I'm working on right now isn't that cool...  It's
just a readonly XIP filesystem.  But it does need VM_MIXEDMAP.

The problem was that VM_PFNMAP required pfn mapped pages to be
contiguous.  My filesystem wants to allow a mixed of struct page and
pfn mapped pages within a given vma.  VM_MIXEDMAP allows that to
happen.

But VM_MIXEDMAP is one of those foundation pieces that will allow us
to move on and do the cool migrate from RAM to NVM magic.  You can't
transparently migrate pages when you are tied down to the VM_PFNMAP
rules.  It'd be more like migrating vma chunks, yuck.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
