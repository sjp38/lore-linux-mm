Subject: Re: faults and signals
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20061010020427.GA15822@wotan.suse.de>
References: <20061009140354.13840.71273.sendpatchset@linux.site>
	 <20061009140447.13840.20975.sendpatchset@linux.site>
	 <1160427785.7752.19.camel@localhost.localdomain>
	 <452AEC8B.2070008@yahoo.com.au>
	 <1160442685.32237.27.camel@localhost.localdomain>
	 <452AF546.4000901@yahoo.com.au>
	 <1160445510.32237.50.camel@localhost.localdomain>
	 <1160445601.32237.53.camel@localhost.localdomain>
	 <20061010020427.GA15822@wotan.suse.de>
Content-Type: text/plain
Date: Tue, 10 Oct 2006 12:07:32 +1000
Message-Id: <1160446052.32237.55.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-10-10 at 04:04 +0200, Nick Piggin wrote:
> On Tue, Oct 10, 2006 at 12:00:01PM +1000, Benjamin Herrenschmidt wrote:
> > 
> > > Yes. Tho it's also fairly easy to just add an argument to the wrapper
> > > and fix all archs... but yeah, I will play around.
> > 
> > Actually, user_mode(ptregs) is standard, we could add a ptregs arg to
> > the wrapper... or just get rid of it and fix archs, it's not like it was
> > that hard. There aren't that many callers :)
> > 
> > Is there any reason why we actually need that wrapper ?
> 
> Not much reason. If you go through and fix up all callers then
> that should be fine.

I suppose I can do that... I'll give it a go once all your new stuff is
in -mm and I've started adapting SPUfs to it :)

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
