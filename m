Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
From: Nicholas Miell <nmiell@comcast.net>
In-Reply-To: <20080322071755.GP2346@one.firstfloor.org>
References: <20080318095715.27120788.akpm@linux-foundation.org>
	 <20080318172045.GI11966@one.firstfloor.org>
	 <20080318104437.966c10ec.akpm@linux-foundation.org>
	 <20080319083228.GM11966@one.firstfloor.org>
	 <20080319020440.80379d50.akpm@linux-foundation.org>
	 <a36005b50803191545h33d1a443y57d09176f8324186@mail.gmail.com>
	 <20080320090005.GA25734@one.firstfloor.org>
	 <a36005b50803211015l64005f6emb80dbfc21dcfad9f@mail.gmail.com>
	 <20080321172644.GG2346@one.firstfloor.org>
	 <a36005b50803212136s78dc2e4bx5ac715ebc7a6e48a@mail.gmail.com>
	 <20080322071755.GP2346@one.firstfloor.org>
Content-Type: text/plain
Date: Sat, 22 Mar 2008 00:24:55 -0700
Message-Id: <1206170695.2438.39.camel@entropy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Ulrich Drepper <drepper@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2008-03-22 at 08:17 +0100, Andi Kleen wrote:
> On Fri, Mar 21, 2008 at 09:36:51PM -0700, Ulrich Drepper wrote:
> > On Fri, Mar 21, 2008 at 10:26 AM, Andi Kleen <andi@firstfloor.org> wrote:
> > >  Concrete suggestions please.
> > 
> > I already spelled it out.  Add a new program header entry, point it to
> > a bit array large enough to cover all loadable segments.
> 
> Ah that's easy, the program header is already supported in the kernel code
> (PT_PRESENT_BITMAP)
> 
> The additional SHDR is just there for easier testing/migration.
> > 
> > It is not worth creating problems with this invalid extension just for
> 
> You still didn't say why it was invalid.
> 
> Anyways I disagree on the value of supporting old binaries. I believe
> it is important.
> 
> -Andi

Why not stick the bitmap in an xattr?

-- 
Nicholas Miell <nmiell@comcast.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
