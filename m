Date: Fri, 17 Oct 2008 16:06:26 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch][rfc] mm: have expand_stack honour VM_LOCKED
In-Reply-To: <20081017135528.GA6694@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0810171545001.11791@blonde.site>
References: <20081017050120.GA28605@wotan.suse.de> <Pine.LNX.4.64.0810171416090.3111@blonde.site>
 <20081017135528.GA6694@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Oct 2008, Nick Piggin wrote:
> 
> How do critical apps reserve and lock a required amount of stack? I
> thought there might be cases where failing to lock pages could cause
> problems there.

I'd have thought that an app that was desperate to avoid even minor
faults would be mlocking all the stack it might ever need later on:
not extending its stack with (one or more) minor faults but relying
on those to prevent minor faults on the gaps.

Ah, you think it might mlock the stack it already has, then touch a
lower address, and expect that to fault in the intervening pages:
well, I suppose it might expect that, but we've never done it,
so we'd have been causing it unnoticed problems for many years.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
