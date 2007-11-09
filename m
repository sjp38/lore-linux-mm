Date: Fri, 9 Nov 2007 11:58:20 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: about page migration on UMA
In-Reply-To: <6934efce0711091154x74fe4405q5a9e291b3d9780f0@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0711091156170.15914@schroedinger.engr.sgi.com>
References: <20071016191949.cd50f12f.kamezawa.hiroyu@jp.fujitsu.com>
 <20071016192341.1c3746df.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.0.9999.0710162113300.13648@chino.kir.corp.google.com>
 <20071017141609.0eb60539.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.0.9999.0710162232540.27242@chino.kir.corp.google.com>
 <20071017145009.e4a56c0d.kamezawa.hiroyu@jp.fujitsu.com>
 <02f001c8108c$a3818760$3708a8c0@arcapub.arca.com>
 <Pine.LNX.4.64.0710181825520.4272@schroedinger.engr.sgi.com>
 <6934efce0711091131n1acd2ce1h7bb17f9f3cb0f235@mail.gmail.com>
 <Pine.LNX.4.64.0711091136270.15605@schroedinger.engr.sgi.com>
 <6934efce0711091154x74fe4405q5a9e291b3d9780f0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: "Jacky(GuangXiang Lee)" <gxli@arca.com.cn>, linux-mm@kvack.org, Yasunori Goto <y-goto@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 9 Nov 2007, Jared Hulbert wrote:

> On 11/9/07, Christoph Lameter <clameter@sgi.com> wrote:
> > On Fri, 9 Nov 2007, Jared Hulbert wrote:
> >
> > > For extreme low power systems it would be possible to shut down banks
> > > in SDRAM chips that were not full thereby saving power.  That would
> > > require some defraging and migration to empty them prior to powering
> > > down those banks.
> >
> > Yes we have discussed ideas like that a couple of time. If you do have the
> > time then please make this work. You have my full support.
> 
> So I would like to make this migration controlled by userspace.  Are
> there mechanisms to allow that today?  If you give me a starting point
> I'll look into something like this.

Well one idea is to generate a sysfs file that can take a physical memory 
range? echo the range to the sysfs file. The kernel can then try to 
vacate the memory range.

I am ccing the memory hotplug developers. They may be able to help you 
better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
