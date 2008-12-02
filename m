Date: Tue, 2 Dec 2008 14:49:26 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] fs: shrink struct dentry
Message-ID: <20081202134926.GA3235@wotan.suse.de>
References: <20081201083343.GC2529@wotan.suse.de> <20081201175113.GA16828@totally.trollied.org.uk> <20081201180455.GJ10790@wotan.suse.de> <20081201193818.GB16828@totally.trollied.org.uk> <20081202070608.GA28080@wotan.suse.de> <20081202130410.GA24222@totally.trollied.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081202130410.GA24222@totally.trollied.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Levon <levon@movementarian.org>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, robert.richter@amd.com, oprofile-list@lists.sf.net
List-ID: <linux-mm.kvack.org>

On Tue, Dec 02, 2008 at 01:04:10PM +0000, John Levon wrote:
> On Tue, Dec 02, 2008 at 08:06:08AM +0100, Nick Piggin wrote:
> 
> > > Don't you even have a differential profile showing the impact of
> > > removing d_cookie? This hash table lookup will now happen on *every*
> > > userspace sample that's processed. That's, uh, a lot.
> > 
> > I don't know what you mean by every sample that's processed, but
> > won't the hash lookup only happen for the *first* time that a given
> > name is asked for a dcookie (ie. fast_get_dcookie, which, as I said,
> > should actually be moved to fs/dcookies.c)
> 
> I mis-read your changes.
> 
> > > (By all means make your change, but I don't get how it's OK to regress
> > > other code, and provide no evidence at all as to its impact.)
> > 
> > Tradeoffs are made all the time. This is obviously a good one, and
>                                            ^^^^^^^^^^^^^^^^^^^^
> 
> By all means make your change, but I don't get how it's OK to regress
> other code, and provide no evidence at all as to its impact.

Provide me the test case you used to justify bloating struct dentry
in the first place. Then I will test and return you the numbers
after my patch.

 
> > I provided evidence of the impact of the improvement in the common
> > case. I also acknowledge it can slow down the uncommon case, but
> > showed ways that can easily be improved. Do you want me to just try
> > to make an artificial case where I mmap thousands of tiny shared
> > libraries and try to overflow the hash and try to detect a difference?
> 
> You haven't even bothered to show that it hasn't affected normal
> oprofile use yet.
> 
> I can't believe I'm having to argue that you need to test your code. So
> I think I'll stop.

Code was tested. It doesn't affect my normal oprofile usage (it's
utterly within the noise, in case that wasn't obvious to you). But
what is "normal" for oprofile? You must have some test case in mind.

Can you go back and read the original mail for god's sake? I'm not
arguing against anything of the sort. To start with, the patch is an
RFC, and I cc'ed it to you as the oprofile maintainer I thought you
might help me by saying "oh that should be fine because it is so
uncommon", or "better test this crazy type of workload that might
slowdown".

And secondly, I acknowledged the slowdown possibility in the first
mail and I provided 2 good possibilities that most slowdown should
be able to be eliminated anyway if we should find one.


> > Did you add d_cookie? If so, then surely at the time you must have
> 
> It was added along with the rest of oprofile, so I don't have breakout
> numbers. I did have oprofile overhead numbers, though I doubt I could
> find them now.

No, I mean the overhead of adding d_cookie pointer to struct dentry
to get the d_cookie thing _directly_, rather than doing a data
structure lookup to get the value. So I'll repeat: you obviously must
have had some important case that showed really improved performance
from that d_cookie pointer to be able to justify the very significant
overhead. Please share it with me then I can test.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
