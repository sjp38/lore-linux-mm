Date: Sun, 23 Mar 2008 14:25:17 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
Message-ID: <20080323132517.GB4580@ucw.cz>
References: <a36005b50803191545h33d1a443y57d09176f8324186@mail.gmail.com> <20080320090005.GA25734@one.firstfloor.org> <a36005b50803211015l64005f6emb80dbfc21dcfad9f@mail.gmail.com> <20080321172644.GG2346@one.firstfloor.org> <a36005b50803212136s78dc2e4bx5ac715ebc7a6e48a@mail.gmail.com> <20080322071755.GP2346@one.firstfloor.org> <1206170695.2438.39.camel@entropy> <20080322091001.GA7264@one.firstfloor.org> <1206180991.2438.43.camel@entropy> <20080322142949.GB10687@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080322142949.GB10687@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Nicholas Miell <nmiell@comcast.net>, Ulrich Drepper <drepper@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 2008-03-22 15:29:49, Andi Kleen wrote:
> On Sat, Mar 22, 2008 at 03:16:31AM -0700, Nicholas Miell wrote:
> > 
> > *sigh* this is probably true
> 
> Actually it is a relatively weak argument assuming the standard
> 4k xattrs, but still an issue.
> 
> The other stronger argument against it is that larger xattrs tend to be
> outside the inode so you would have another seek again.
> 
> > > and a mess to manage (a lot of tools don't know about them)
> > 
> > At this point in time, all tools that don't support xattrs are
> > defective,
> 
> Good joke.
> 
> > I just have an instinctive aversion towards the kernel mucking around in
> > ELF objects -- for one thing, you're going to have to blacklist
> > cryptographically signed binaries.
> 
> What signed binaries? 
> 
> Anyways there are two ways to deal with this:
> 
> - Run the executable through a little filter that zeroes the bitmap before
> computing the checksum.  That is how rpm -V deals with prelinked binaries which 
> have a similar issue. You can probably reuse the scripts from rpm.

Is this good idea? Attacker can send you binary with the bitmap
inverted, it is now slow on your system and signature matches.

...might be important for benchmarks... 'here, see, Oracle is slow.
Feel free to verify the signature'.

...ok, I guess it is not too serious, because it is similar to
fragmentation....
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
