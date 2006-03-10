From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [ck] Re: [PATCH] mm: yield during swap prefetching
Date: Fri, 10 Mar 2006 20:11:03 +1100
References: <200603081013.44678.kernel@kolivas.org> <4410AFD3.7090505@bigpond.net.au> <20060310090121.GA15315@rhlx01.fht-esslingen.de>
In-Reply-To: <20060310090121.GA15315@rhlx01.fht-esslingen.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200603102011.04317.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Mohr <andi@rhlx01.fht-esslingen.de>
Cc: Peter Williams <pwil3058@bigpond.net.au>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ck@vds.kolivas.org, Helge Hafting <helge.hafting@aitel.hist.no>
List-ID: <linux-mm.kvack.org>

On Friday 10 March 2006 20:01, Andreas Mohr wrote:
> Hi,
>
> On Fri, Mar 10, 2006 at 09:44:35AM +1100, Peter Williams wrote:
> > I'm working on a patch to add soft and hard CPU rate caps to the
> > scheduler and the soft caps may be useful for what you're trying to do.
> >  They are a generalization of your SCHED_BATCH implementation in
> > staircase (which would have been better called SCHED_BACKGROUND :-)
>
> Which SCHED_BATCH? ;) I only know it as SCHED_IDLEPRIO, which, come to
> think of it, is a better name, I believe :-)
> (renamed due to mainline introducing a *different* SCHED_BATCH mechanism)

Just to clarify what Andreas is saying: I was forced to rename my SCHED_BATCH 
to SCHED_IDLEPRIO which is a more descriptive name anyway. That is in my 
2.6.16-rc based patches. SCHED_BATCH as you know is now used to mean "don't 
treat me as interactive" so I'm using this policy naming in 2.6.16- based 
patches.

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
