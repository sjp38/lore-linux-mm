Message-ID: <3D2C9900.EF65CE2E@zip.com.au>
Date: Wed, 10 Jul 2002 13:28:48 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Optimize out pte_chain take three
References: <3D2C9288.51BBE4EB@zip.com.au> <Pine.LNX.4.44L.0207101712120.14432-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> ...
> Any way out of this chicken&egg situation ?

Well yes.  We can say "this is a sound design, and we
believe we can make it work well.  Let's merge it and
get going on it".

That's perfectly legitimate and sensible.  But it would be
better to not have to go this route just through lack of tools
or effort.   Probably, this is what we'll end up doing :(   But
we'll be much, much better off long term if we have those tests.

How do the BSD and proprietary kernel developers evaluate
their VMs?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
