Date: Fri, 23 Jan 2004 22:10:51 +0100
From: Vojtech Pavlik <vojtech@suse.cz>
Subject: Re: keyboard and USB problems (Re: 2.6.2-rc1-mm2)
Message-ID: <20040123211051.GB12647@ucw.cz>
References: <20040123013740.58a6c1f9.akpm@osdl.org> <20040123160152.GA18073@ss1000.ms.mff.cuni.cz> <20040123161946.GA6934@ucw.cz> <1074886056.12447.36.camel@localhost> <20040123195439.GA7878@ucw.cz> <1074888902.12442.51.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1074888902.12442.51.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: john stultz <johnstul@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 23, 2004 at 12:15:03PM -0800, john stultz wrote:

> > > If that is going to cause problems, then we'll need to pull out the
> > > use-pmtmr-for-delay_pmtmr patch. I guess our only option is then to use
> > > the TSC for delay_pmtrm() (as a loop based delay fails in other cases).
> > > I'll write that up and send it your way, Andrew. 
> > 
> > I've seen the PM timer breaking the mouse operation rather badly in the
> > past, the lost-sync check was triggering for many people when the PM
> > timer was used. This implies time inacurracy in the range of 0.5
> > seconds. Could that happen somehow?
> 
> Not in a way that I yet understand. Do you see similar problems with
> folks using clock=pit?

Yes, I do. However in several cases using clock=pit cured the problem.
In other cases the problem was cured by killing a battery applet in X.

-- 
Vojtech Pavlik
SuSE Labs, SuSE CR
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
