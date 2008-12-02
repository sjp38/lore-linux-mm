Date: Tue, 2 Dec 2008 13:04:10 +0000
From: John Levon <levon@movementarian.org>
Subject: Re: [patch][rfc] fs: shrink struct dentry
Message-ID: <20081202130410.GA24222@totally.trollied.org.uk>
References: <20081201083343.GC2529@wotan.suse.de> <20081201175113.GA16828@totally.trollied.org.uk> <20081201180455.GJ10790@wotan.suse.de> <20081201193818.GB16828@totally.trollied.org.uk> <20081202070608.GA28080@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081202070608.GA28080@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, robert.richter@amd.com, oprofile-list@lists.sf.net
List-ID: <linux-mm.kvack.org>

On Tue, Dec 02, 2008 at 08:06:08AM +0100, Nick Piggin wrote:

> > Don't you even have a differential profile showing the impact of
> > removing d_cookie? This hash table lookup will now happen on *every*
> > userspace sample that's processed. That's, uh, a lot.
> 
> I don't know what you mean by every sample that's processed, but
> won't the hash lookup only happen for the *first* time that a given
> name is asked for a dcookie (ie. fast_get_dcookie, which, as I said,
> should actually be moved to fs/dcookies.c)

I mis-read your changes.

> > (By all means make your change, but I don't get how it's OK to regress
> > other code, and provide no evidence at all as to its impact.)
> 
> Tradeoffs are made all the time. This is obviously a good one, and
                                           ^^^^^^^^^^^^^^^^^^^^

By all means make your change, but I don't get how it's OK to regress
other code, and provide no evidence at all as to its impact.

> I provided evidence of the impact of the improvement in the common
> case. I also acknowledge it can slow down the uncommon case, but
> showed ways that can easily be improved. Do you want me to just try
> to make an artificial case where I mmap thousands of tiny shared
> libraries and try to overflow the hash and try to detect a difference?

You haven't even bothered to show that it hasn't affected normal
oprofile use yet.

I can't believe I'm having to argue that you need to test your code. So
I think I'll stop.

> Did you add d_cookie? If so, then surely at the time you must have

It was added along with the rest of oprofile, so I don't have breakout
numbers. I did have oprofile overhead numbers, though I doubt I could
find them now.

john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
