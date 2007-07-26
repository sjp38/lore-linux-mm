Date: Thu, 26 Jul 2007 23:00:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: 2.6.23-rc1-mm1:  boot hang on ia64 with memoryless nodes
Message-Id: <20070726230031.d804aa60.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1185458007.7653.1.camel@localhost>
References: <20070711182219.234782227@sgi.com>
	<20070713151431.GG10067@us.ibm.com>
	<Pine.LNX.4.64.0707130942030.21777@schroedinger.engr.sgi.com>
	<1185310277.5649.90.camel@localhost>
	<Pine.LNX.4.64.0707241402010.4773@schroedinger.engr.sgi.com>
	<1185372692.5604.22.camel@localhost>
	<1185378322.5604.43.camel@localhost>
	<1185390991.5604.87.camel@localhost>
	<Pine.LNX.4.64.0707251231570.8820@schroedinger.engr.sgi.com>
	<1185398337.5604.96.camel@localhost>
	<1185458007.7653.1.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: clameter@sgi.com, linux-ia64@vger.kernel.org, kxr@sgi.com, akpm@linux-foundation.org, linux-mm@kvack.org, bob.picco@hp.com, mel@skynet.ie, eric.whitney@hp.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Jul 2007 09:53:27 -0400
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> On Wed, 2007-07-25 at 17:18 -0400, Lee Schermerhorn wrote: 
> > On Wed, 2007-07-25 at 12:38 -0700, Christoph Lameter wrote:
> > > (ccing Andy who did the work on the config stuff)
> > > 
> > > On Wed, 25 Jul 2007, Lee Schermerhorn wrote:
> > > 
> > > > I tried to deselect SPARSEMEM_VMEMMAP.  Kconfig's "def_bool=y" wouldn't
> > > > let me :-(.  After hacking the Kconfig and mm/sparse.c to allow that,
> > > > boot hangs with no error messages shortly after "Built N zonelists..."
> > > > message.
> > > 
> > > I get a similar hang here and see the system looping in softirq / hrtimer 
> > > code.
> > > 
> > > > Backed off to DISCONTIGMEM+VIRTUAL_MEMORY_MAP, and saw same hang as with
> > > > (SPARSMEM && !SPARSEMEM_VMEMMAP).   
> > > 
> > > So its not related to SPARSE VMEMMAP? General VMEMMAP issue on IA64?
> > 
> > This hang is different from the one I see with SPARSE VMEMMAP -- no
> > "Unable to handle kernel paging request..." message.  Just hangs after
> > "Built N zonelists..."  and some message about "color" that I didn't
> > capture.  Next time [:-(]...
> 
> The "color" message was actually:
> 
> Console:  colour dummy device 80x25
> 
> So, now I'm wondering if I'm hitting the "Regression in serial
> console..." issue, and the system was actually booting--I just didn't
> see any output.  If so, the "Unable to handle kernel paging request..."
> hang might well be a problem with SPARSEMEM_VMEMMAP...
> 
About SPARSEMEM_VMEMMAP try this:
http://lkml.org/lkml/2007/7/26/161

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
