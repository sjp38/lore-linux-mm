Subject: Re: keyboard and USB problems (Re: 2.6.2-rc1-mm2)
From: john stultz <johnstul@us.ibm.com>
In-Reply-To: <20040123195439.GA7878@ucw.cz>
References: <20040123013740.58a6c1f9.akpm@osdl.org>
	 <20040123160152.GA18073@ss1000.ms.mff.cuni.cz>
	 <20040123161946.GA6934@ucw.cz> <1074886056.12447.36.camel@localhost>
	 <20040123195439.GA7878@ucw.cz>
Content-Type: text/plain
Message-Id: <1074888902.12442.51.camel@localhost>
Mime-Version: 1.0
Date: Fri, 23 Jan 2004 12:15:03 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vojtech Pavlik <vojtech@suse.cz>
Cc: Andrew Morton <akpm@osdl.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2004-01-23 at 11:54, Vojtech Pavlik wrote:
> On Fri, Jan 23, 2004 at 11:27:41AM -0800, john stultz wrote:
> > Well, loops_per_jiffy is actually being measured correctly as we're
> > using the acpi pm timesource to time udelay(). However there is a loss
> > of resolution using the slower time source, so udelay(1) might take
> > longer then 1 us. 
> 
> Longer udelay shouldn't cause trouble. Shorter one definitely would.

Hmm. 

> > If that is going to cause problems, then we'll need to pull out the
> > use-pmtmr-for-delay_pmtmr patch. I guess our only option is then to use
> > the TSC for delay_pmtrm() (as a loop based delay fails in other cases).
> > I'll write that up and send it your way, Andrew. 
> 
> I've seen the PM timer breaking the mouse operation rather badly in the
> past, the lost-sync check was triggering for many people when the PM
> timer was used. This implies time inacurracy in the range of 0.5
> seconds. Could that happen somehow?

Not in a way that I yet understand. Do you see similar problems with
folks using clock=pit?

thanks
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
