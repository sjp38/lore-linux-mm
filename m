Date: Fri, 20 Feb 2004 21:17:32 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040220211732.A10079@infradead.org>
References: <20040216190927.GA2969@us.ibm.com> <200402200007.25832.phillips@arcor.de> <20040220120255.GA1269@us.ibm.com> <200402201535.47848.phillips@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200402201535.47848.phillips@arcor.de>; from phillips@arcor.de on Fri, Feb 20, 2004 at 03:37:26PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: paulmck@us.ibm.com, "Stephen C. Tweedie" <sct@redhat.com>, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 20, 2004 at 03:37:26PM -0500, Daniel Phillips wrote:
> It does, thanks for the catch.  Please bear with me for a moment while I 
> reroll this, then hopefully we can move on to the more interesting discussion 
> of whether it's worth it.  (Yes it is :)

What about to the more interesting question who needs it.  It think this
whole discussion who needs what and which approach is better is pretty much
moot as long as we don't have an intree users.

Instead of wasting your time on different designs you should hurry of
getting your filesystems encumbrance-reviewed, cleaned up and merged -
with intree users we have a chance of finding the right API.  And your
newly started dicussion shows pretty much that with only out of tree users
we'll never get a sane API.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
