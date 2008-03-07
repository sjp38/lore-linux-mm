Date: Fri, 7 Mar 2008 20:02:32 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [4/13] Prepare page_alloc for the maskable allocator
Message-ID: <20080307190232.GM7365@one.firstfloor.org>
References: <200803071007.493903088@firstfloor.org> <20080307090714.9493F1B419C@basil.firstfloor.org> <20080307181943.GA14779@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080307181943.GA14779@uranus.ravnborg.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Again - looks too big to inline..
> 
> But for both I do not know where they are used and how often.

For the mask allocator it is not that critical, but for the main
allocator it is on the very very hot page allocation/free path. That is why
I didn't want to out-of-line it.

Note I didn't change it, just moved it.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
