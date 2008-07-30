Subject: Re: [PATCH 6/7] mlocked-pages:  patch reject resolution and event
	renames
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080730133004.9c0dacbd.akpm@linux-foundation.org>
References: <20080730200618.24272.31756.sendpatchset@lts-notebook>
	 <20080730200655.24272.39854.sendpatchset@lts-notebook>
	 <20080730133004.9c0dacbd.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 30 Jul 2008 17:03:02 -0400
Message-Id: <1217451782.7676.21.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, riel@surriel.com, Eric.Whitney@hp.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, 2008-07-30 at 13:30 -0700, Andrew Morton wrote:
> On Wed, 30 Jul 2008 16:06:55 -0400
> Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:
> 
> > Reworked to resolve patch conflicts introduced by other patches,
> > including rename of unevictable lru/mlocked pages events.
> 
> I hope I was supposed to drop
> vmstat-unevictable-and-mlocked-pages-vm-events.patch - it was getting
> 100% rejects.  After dropping it, everything applied.  Dunno if it
> compiles yet.

Yeah.  I did state that explicitly in the cover message.  In upper case,
even!  I had applied all of these patches in my copy of the mmotm tree
and it does compile.  Of course, you've probably added a few patches
that I don't have in the meantime.

> 
> I have a feeling that I merged all these patches too soon - the amount
> of rework has been tremendous.  Are we done yet?

By merging them, we did find problems on platforms and configurations
that I can't easily test.  Most of the rework has served to simplify the
resulting code, IMO.

As for being done, I don't know.  Depends on whether anyone else finds
issues with other configs or platforms that haven't tested these series
yet.  And, I'm continuing to review the current patches.

I did run the mmotm-080729 series for over 20 hours last night under a
fairly heavy stress load on one of my ia64 systems.  No errors, no
leaked pages, ...  Looks pretty good.  Until the next test comes
along...

So, as I mentioned, I've rebuilt with today's fixes applied to
mmotm-080730 and will test more tomorrow.  [We just moved our lab across
state lines and my test systems are just coming on-line.]  I'll keep an
eye on the mmotm site and try to stay current with that.

Thanks for applying these.
Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
