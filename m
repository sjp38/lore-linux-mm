Message-ID: <48EE6D4C.7080901@linux-foundation.org>
Date: Thu, 09 Oct 2008 15:45:00 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [rfc] approach to pull writepage out of reclaim
References: <20081009144103.GE9941@wotan.suse.de> <48EE3A07.9060205@linux-foundation.org> <20081009194434.GB25780@parisc-linux.org>
In-Reply-To: <20081009194434.GB25780@parisc-linux.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Matthew Wilcox wrote:
> On Thu, Oct 09, 2008 at 12:06:15PM -0500, Christoph Lameter wrote:
>> Nick Piggin wrote:
>>
>>> So. Firstly, what I'm looking at is doing swap writeout from pdflush. This
>>> patch does that (working in concept, but pdflush and background writeout
>>> from dirty inode list isn't really up to the task, might scrap it and do the
>>> writeout from kswap). But writeout from radix-tree should actually be able to
>>> give better swapout pattern than LRU writepage as well.
>> Patch is missing from the message.
> 
> It's no longer acceptable to post descriptions of what you're about to
> do?  You have to invest lots of time into creating a patch and testing that
> it works before posting it (only to have it shot down because someone
> disagrees with the design of your solution)?  Really?

The text says that a patch was included.... So I was expecting it....

But the problem you mention is real. Tried numerous times to get a conceptual
discussion going without a patch. Usually that does not lead to anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
