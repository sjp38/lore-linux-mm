Date: Mon, 16 Feb 2004 14:19:54 -0500 (EST)
From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: 2.6.3-rc3-mm1
In-Reply-To: <20040216095411.1592d09d.akpm@osdl.org>
Message-ID: <Pine.LNX.3.96.1040216141554.2146A-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Feb 2004, Andrew Morton wrote:

> Bill Davidsen <davidsen@tmr.com> wrote:
> >
> > > - Dropped the x86 CPU-type selection patches
> > 
> >  Was there a problem with this? Seems like a good start to allow cleaning 
> >  up some "but I don't have that CPU" things which embedded and tiny 
> >  systems really would like to eliminate.
> 
> I think it was a good change, and was appropriate to 2.5.x.  But for 2.6.x
> the benefit didn't seem to justify the depth of the change.

And will it be appropriate for 2.7? It really does give a start to
trimming code you don't want in a small kernel, and would have been nice
so people could use it for any processor specific additions to 2.6.

Not arguing, but it was a step to improve control of creeping unnecessary
archetecture support.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
