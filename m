Message-ID: <48EE3A07.9060205@linux-foundation.org>
Date: Thu, 09 Oct 2008 12:06:15 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [rfc] approach to pull writepage out of reclaim
References: <20081009144103.GE9941@wotan.suse.de>
In-Reply-To: <20081009144103.GE9941@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> So. Firstly, what I'm looking at is doing swap writeout from pdflush. This
> patch does that (working in concept, but pdflush and background writeout
> from dirty inode list isn't really up to the task, might scrap it and do the
> writeout from kswap). But writeout from radix-tree should actually be able to
> give better swapout pattern than LRU writepage as well.

Patch is missing from the message.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
