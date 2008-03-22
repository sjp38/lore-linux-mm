Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
From: Nicholas Miell <nmiell@comcast.net>
In-Reply-To: <20080322091001.GA7264@one.firstfloor.org>
References: <20080318104437.966c10ec.akpm@linux-foundation.org>
	 <20080319083228.GM11966@one.firstfloor.org>
	 <20080319020440.80379d50.akpm@linux-foundation.org>
	 <a36005b50803191545h33d1a443y57d09176f8324186@mail.gmail.com>
	 <20080320090005.GA25734@one.firstfloor.org>
	 <a36005b50803211015l64005f6emb80dbfc21dcfad9f@mail.gmail.com>
	 <20080321172644.GG2346@one.firstfloor.org>
	 <a36005b50803212136s78dc2e4bx5ac715ebc7a6e48a@mail.gmail.com>
	 <20080322071755.GP2346@one.firstfloor.org>
	 <1206170695.2438.39.camel@entropy>
	 <20080322091001.GA7264@one.firstfloor.org>
Content-Type: text/plain
Date: Sat, 22 Mar 2008 03:16:31 -0700
Message-Id: <1206180991.2438.43.camel@entropy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Ulrich Drepper <drepper@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2008-03-22 at 10:10 +0100, Andi Kleen wrote:
> > Why not stick the bitmap in an xattr?
> 
> xattrs are too small for potentially large binaries

*sigh* this is probably true

> and a mess to manage (a lot of tools don't know about them)

At this point in time, all tools that don't support xattrs are
defective, but this is still probably true.

I just have an instinctive aversion towards the kernel mucking around in
ELF objects -- for one thing, you're going to have to blacklist
cryptographically signed binaries.


-- 
Nicholas Miell <nmiell@comcast.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
