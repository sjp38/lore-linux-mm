Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F299280298
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 04:55:09 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v14so3850716wmd.3
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 01:55:09 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id g7si513034edj.376.2018.01.17.01.55.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 01:55:08 -0800 (PST)
Date: Wed, 17 Jan 2018 10:55:07 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
Message-ID: <20180117095507.GM28161@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <alpine.DEB.2.20.1801162212080.2366@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1801162212080.2366@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

Hi Thomas,

thanks for your review, I'll work in your suggestions for the next post.

On Tue, Jan 16, 2018 at 10:20:40PM +0100, Thomas Gleixner wrote:
> On Tue, 16 Jan 2018, Joerg Roedel wrote:

> >  16 files changed, 333 insertions(+), 123 deletions(-)
> 
> Impressively small and well done !

Thanks :)

> Can you please make that patch set against
> 
>    git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git x86-pti-for-linus
> 
> so we immediately have it backportable for 4.14 stable? It's only a trivial
> conflict in pgtable.h, but we'd like to make the life of stable as simple
> as possible. They have enough headache with the pre 4.14 trees.

Sure, will do.

> We can pick some of the simple patches which make defines and inlines
> available out of the pile right away and apply them to x86/pti to shrink
> the amount of stuff you have to worry about.

This should be patches 4, 5, 7, 11, and I think 13 is also simple
enough. Feel free to take them, but I can also carry them forward if
needed.

Thanks,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
