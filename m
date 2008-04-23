Date: Wed, 23 Apr 2008 10:37:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
Message-Id: <20080423103717.e3afddc6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080423004804.GA14134@wotan.suse.de>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
	<20080422045205.GH21993@wotan.suse.de>
	<20080422165608.7ab7026b.kamezawa.hiroyu@jp.fujitsu.com>
	<20080422094352.GB23770@wotan.suse.de>
	<Pine.LNX.4.64.0804221215270.3173@schroedinger.engr.sgi.com>
	<20080423004804.GA14134@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Apr 2008 02:48:04 +0200
Nick Piggin <npiggin@suse.de> wrote:

> On Tue, Apr 22, 2008 at 12:16:07PM -0700, Christoph Lameter wrote:
> > On Tue, 22 Apr 2008, Nick Piggin wrote:
> > 
> > > No, it need not be under IO or in some unstable state. Christoph just
> > > said that migration can't handle !uptodate pages, and I'm very
> > > curious as to why not, and what is in place to prevent that from
> > > happening.
> > 
> > We just assumed that the page was in an unstable state since it was under 
> > I/O.
> 
> A !uptodate page isn't necessarily under IO. But even if you are assuming
> it is in an unstable state, I don't see any code that would prevent it
> from trying to migrate an !uptodate page.
> 
> Anyway, here is my proposed (uncompiled, untested) fix. Score 1 for my
> buffer invariant checks if I'm right ;)
> 
Thank you!, I'll test this.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
