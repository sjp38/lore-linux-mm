Date: Wed, 26 Mar 2008 19:54:38 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
Message-ID: <20080326185438.GA27154@one.firstfloor.org>
References: <20080321172644.GG2346@one.firstfloor.org> <a36005b50803212136s78dc2e4bx5ac715ebc7a6e48a@mail.gmail.com> <20080322071755.GP2346@one.firstfloor.org> <1206170695.2438.39.camel@entropy> <20080322091001.GA7264@one.firstfloor.org> <a36005b50803232120j63fb08d8p4a6cfdc8df2a3f21@mail.gmail.com> <1206335761.2438.63.camel@entropy> <a36005b50803241242r2a9b38c5s57d9ac6b084021fa@mail.gmail.com> <20080325075403.GH2170@one.firstfloor.org> <a36005b50803261115s6a3aa889w42fd4890c124ee01@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a36005b50803261115s6a3aa889w42fd4890c124ee01@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, Nicholas Miell <nmiell@comcast.net>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 26, 2008 at 11:15:49AM -0700, Ulrich Drepper wrote:
> On Tue, Mar 25, 2008 at 12:54 AM, Andi Kleen <andi@firstfloor.org> wrote:
> >  There is still the additional seek.
> 
> You've been proposing and implementing a solution which needs an
> additional seek.  Don't use double standards.

You're wrong. I am implementing a solution that allows two 
methods -- one (SHDR) that needs an seek (but an continuous one
so it's likely served from the track buffer) but has some advantages 
and another one (PHDR) that does not require a seek.

You two are arguing a method that always requires the seek
and has a couple of other drawbacks as earlier discussed too.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
