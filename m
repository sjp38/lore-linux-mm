Date: Mon, 28 Jul 2008 08:53:46 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm: unify pmd_free() implementation
In-Reply-To: <1217260287-13115-1-git-send-email-righi.andrea@gmail.com>
Message-ID: <alpine.LFD.1.10.0807280851130.3486@nehalem.linux-foundation.org>
References: <> <1217260287-13115-1-git-send-email-righi.andrea@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Righi <righi.andrea@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 28 Jul 2008, Andrea Righi wrote:
>
> Move multiple definitions of pmd_free() from different include/asm-* into
> mm/util.c.

But this is horrible, because it forces a totally unnecessary function 
call for that empty function.

Yeah, the function will be cheap, but the call itself will not be (it's a 
C language barrier and basically disables optimizations around it, causing 
thigns like register spill/reload for no good reason).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
