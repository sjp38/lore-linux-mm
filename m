Received: by fk-out-0910.google.com with SMTP id z22so3366165fkz.6
        for <linux-mm@kvack.org>; Mon, 28 Jul 2008 09:17:33 -0700 (PDT)
Message-ID: <488DF119.2000004@gmail.com>
Date: Mon, 28 Jul 2008 18:17:29 +0200
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mm: unify pmd_free() implementation
References: <> <1217260287-13115-1-git-send-email-righi.andrea@gmail.com> <alpine.LFD.1.10.0807280851130.3486@nehalem.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.10.0807280851130.3486@nehalem.linux-foundation.org>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Mon, 28 Jul 2008, Andrea Righi wrote:
>> Move multiple definitions of pmd_free() from different include/asm-* into
>> mm/util.c.
> 
> But this is horrible, because it forces a totally unnecessary function 
> call for that empty function.
> 
> Yeah, the function will be cheap, but the call itself will not be (it's a 
> C language barrier and basically disables optimizations around it, causing 
> thigns like register spill/reload for no good reason).
> 
> 		Linus

yep! clear.

Ok, in this case wouldn't be better at least to define pud_free() as:

static inline pud_free(struct mm_struct *mm, pmd_t *pmd)
{
}

in include/asm-generic/pgtable-nopmd.h, just to avoid the warning
on x86 without PAE?

Thanks for the explanation,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
