Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB0736B0038
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 07:43:25 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id s11so119968pgc.15
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 04:43:25 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id p21si24294509pgc.388.2017.11.28.04.43.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Nov 2017 04:43:24 -0800 (PST)
Date: Tue, 28 Nov 2017 13:43:13 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/2] x86/mm/kaiser: Remove unused user-mapped
 page-aligned section
Message-ID: <20171128124313.vezo4vkfucuezutl@hirez.programming.kicks-ass.net>
References: <cover.1511842148.git.jpoimboe@redhat.com>
 <666935452d5eef100464b7314be90fccd65e795c.1511842148.git.jpoimboe@redhat.com>
 <20171128092025.ggbnkx2j4uglbdax@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171128092025.ggbnkx2j4uglbdax@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Tue, Nov 28, 2017 at 10:20:25AM +0100, Peter Zijlstra wrote:
> On Mon, Nov 27, 2017 at 10:10:12PM -0600, Josh Poimboeuf wrote:
> > The '.data..percpu..user_mapped..page_aligned' section isn't used
> > anywhere.  Remove it and its related macros.
> 
> With my patches:
> 
>   arch/x86/events/intel/ds.c:DEFINE_PER_CPU_SHARED_ALIGNED_USER_MAPPED(struct debug_store, cpu_debug_store);
> 
> is the only user left of any of that.
> 
> I suppose we could just allocate a whole page for that and use
> kaiser_add_mapping() for it. Then we can remove all of
> DEFINE_.*_USER_MAPPED().

Or we could field it a spot in the cpu_entry_area I suppose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
