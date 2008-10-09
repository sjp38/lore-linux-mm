Date: Thu, 9 Oct 2008 13:44:34 -0600
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [rfc] approach to pull writepage out of reclaim
Message-ID: <20081009194434.GB25780@parisc-linux.org>
References: <20081009144103.GE9941@wotan.suse.de> <48EE3A07.9060205@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48EE3A07.9060205@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 09, 2008 at 12:06:15PM -0500, Christoph Lameter wrote:
> Nick Piggin wrote:
> 
> > So. Firstly, what I'm looking at is doing swap writeout from pdflush. This
> > patch does that (working in concept, but pdflush and background writeout
> > from dirty inode list isn't really up to the task, might scrap it and do the
> > writeout from kswap). But writeout from radix-tree should actually be able to
> > give better swapout pattern than LRU writepage as well.
> 
> Patch is missing from the message.

It's no longer acceptable to post descriptions of what you're about to
do?  You have to invest lots of time into creating a patch and testing that
it works before posting it (only to have it shot down because someone
disagrees with the design of your solution)?  Really?

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
