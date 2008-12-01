Date: Mon, 1 Dec 2008 19:38:18 +0000
From: John Levon <levon@movementarian.org>
Subject: Re: [patch][rfc] fs: shrink struct dentry
Message-ID: <20081201193818.GB16828@totally.trollied.org.uk>
References: <20081201083343.GC2529@wotan.suse.de> <20081201175113.GA16828@totally.trollied.org.uk> <20081201180455.GJ10790@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081201180455.GJ10790@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, robert.richter@amd.com, oprofile-list@lists.sf.net
List-ID: <linux-mm.kvack.org>

On Mon, Dec 01, 2008 at 07:04:55PM +0100, Nick Piggin wrote:

> On Mon, Dec 01, 2008 at 05:51:13PM +0000, John Levon wrote:
> > On Mon, Dec 01, 2008 at 09:33:43AM +0100, Nick Piggin wrote:
> > 
> > > I then got rid of the d_cookie pointer. This shrinks it to 192 bytes. Rant:
> > > why was this ever a good idea? The cookie system should increase its hash
> > > size or use a tree or something if lookups are a problem.
> > 
> > Are you saying you've made this change without even testing its
> > performance impact?
> 
> For oprofile case (maybe if you are profiling hundreds of vmas and
> overflow the 4096 byte hash table), no. That case is uncommon and
> must be fixed in the dcookie code (as I said, trivial with changing
> data structure). I don't want this pointer in struct dentry
> regardless of a possible tiny benefit for oprofile.

Don't you even have a differential profile showing the impact of
removing d_cookie? This hash table lookup will now happen on *every*
userspace sample that's processed. That's, uh, a lot.

(By all means make your change, but I don't get how it's OK to regress
other code, and provide no evidence at all as to its impact.)

john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
