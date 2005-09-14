Date: Wed, 14 Sep 2005 18:44:56 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: VM balancing issues on 2.6.13: dentry cache not getting shrunk enough
Message-ID: <20050914224456.GA32082@thunk.org>
References: <20050911105709.GA16369@thunk.org> <20050913084752.GC4474@in.ibm.com> <20050913215932.GA1654338@melbourne.sgi.com> <200509141101.16781.ak@suse.de> <4327EA6B.6090102@colorfullife.com> <20050914024313.1e70f2a3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050914024313.1e70f2a3.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Manfred Spraul <manfred@colorfullife.com>, ak@suse.de, dgc@sgi.com, bharata@in.ibm.com, dipankar@in.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 14, 2005 at 02:43:13AM -0700, Andrew Morton wrote:
> Manfred Spraul <manfred@colorfullife.com> wrote:
> >
> > One tricky point are directory dentries: As far as I see, they are 
> >  pinned and unfreeable if a (freeable) directory entry is in the cache.
> >
> 
> Well.  That's the whole problem.
> 
> I don't think it's been demonstrated that Ted's problem was caused by
> internal fragementation, btw.  Ted, could you run slabtop, see what the
> dcache occupancy is?  Monitor it as you start to manually apply pressure? 
> If the occupancy falls to 10% and not many slab pages are freed up yet then
> yup, it's internal fragmentation.

The next time I can get my machine into that state, sure, I'll try it.
I used to be able to reproduce it using normal laptop usage patterns
(Lotus notes running under wine, kernel builds, apt-get upgrade's,
openoffice, firefox, etc.)  about twice a week with 2.6.13-rc5, but
with 2.6.13, it happened once or twice, but since then I haven't been
able to trigger it.  (Predictably, not after I posted about it on
LKML.  :-/)

I've been trying a few things in the hopes of deliberately triggering
it, but so far, no luck.  Maybe I should go back to 2.6.13-rc5 and see
if I have an easier time of reproducing the failure case.

						- Ted
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
