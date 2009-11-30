Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3F2BE600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 06:05:19 -0500 (EST)
Subject: Re: [PATCH v2 10/12] Maintain preemptability count even for
 !CONFIG_PREEMPT kernels
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1259578793.20516.130.camel@laptop>
References: <1258985167-29178-1-git-send-email-gleb@redhat.com>
	 <1258985167-29178-11-git-send-email-gleb@redhat.com>
	 <1258990455.4531.594.camel@laptop> <20091123155851.GU2999@redhat.com>
	 <alpine.DEB.2.00.0911231128190.785@router.home>
	 <20091124071250.GC2999@redhat.com>
	 <alpine.DEB.2.00.0911240906360.14045@router.home>
	 <20091130105612.GF30150@redhat.com>  <20091130105812.GG30150@redhat.com>
	 <1259578793.20516.130.camel@laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 30 Nov 2009 12:05:14 +0100
Message-ID: <1259579114.20516.136.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, 2009-11-30 at 11:59 +0100, Peter Zijlstra wrote:
> On Mon, 2009-11-30 at 12:58 +0200, Gleb Natapov wrote:
> > On Mon, Nov 30, 2009 at 12:56:12PM +0200, Gleb Natapov wrote:
> > > On Tue, Nov 24, 2009 at 09:14:03AM -0600, Christoph Lameter wrote:
> > > > On Tue, 24 Nov 2009, Gleb Natapov wrote:
> > > > 
> > > > > On Mon, Nov 23, 2009 at 11:30:02AM -0600, Christoph Lameter wrote:
> > > > > > This adds significant overhead for the !PREEMPT case adding lots of code
> > > > > > in critical paths all over the place.
> > > > > I want to measure it. Can you suggest benchmarks to try?
> > > > 
> > > > AIM9 (reaim9)?
> > > Below are results for kernel 2.6.32-rc8 with and without the patch (only
> > > this single patch is applied).
> > > 
> > Forgot to tell. The results are average between 5 different runs.
> 
> Would be good to also report the variance over those 5 runs, allows us
> to see if the difference is within the noise.

Got pointed to the fact that there is a stddev column right there.

Must be Monday or something ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
