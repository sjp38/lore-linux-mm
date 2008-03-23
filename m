Date: Sun, 23 Mar 2008 18:08:27 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
Message-ID: <20080323170827.GB5082@one.firstfloor.org>
References: <20080320090005.GA25734@one.firstfloor.org> <a36005b50803211015l64005f6emb80dbfc21dcfad9f@mail.gmail.com> <20080321172644.GG2346@one.firstfloor.org> <a36005b50803212136s78dc2e4bx5ac715ebc7a6e48a@mail.gmail.com> <20080322071755.GP2346@one.firstfloor.org> <1206170695.2438.39.camel@entropy> <20080322091001.GA7264@one.firstfloor.org> <1206180991.2438.43.camel@entropy> <20080322142949.GB10687@one.firstfloor.org> <20080323132517.GB4580@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080323132517.GB4580@ucw.cz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Andi Kleen <andi@firstfloor.org>, Nicholas Miell <nmiell@comcast.net>, Ulrich Drepper <drepper@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Is this good idea? Attacker can send you binary with the bitmap
> inverted, it is now slow on your system and signature matches.

The first run will fix up any missing bits in the bitmap. Right 
now it cannot get rid of unnecessary pages though unless you
disable early_fault.

> ...might be important for benchmarks... 'here, see, Oracle is slow.
> Feel free to verify the signature'.
> 
> ...ok, I guess it is not too serious, because it is similar to
> fragmentation....

It is actually far better than fragmentation because the bitmap
loader does IO always in big chunks -- not much seeking will go on. 
The only problem is some wasted mmeory and more IO bandwidth
usage (but typically binaries are not bigger than a few MB so 
it's not too dramatic)

So in summary I don't think it's an issue.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
