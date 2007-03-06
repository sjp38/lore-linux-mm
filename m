Date: Tue, 6 Mar 2007 07:54:04 -0800
From: Mark Gross <mgross@linux.intel.com>
Subject: Re: [RFC] [PATCH] Power Managed memory base enabling
Message-ID: <20070306155404.GA22725@linux.intel.com>
Reply-To: mgross@linux.intel.com
References: <20070305181826.GA21515@linux.intel.com> <20070306102628.4c32fc65.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070306102628.4c32fc65.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-pm@lists.osdl.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, mark.gross@intel.com, neelam.chandwani@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, Mar 06, 2007 at 10:26:28AM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 5 Mar 2007 10:18:26 -0800
> Mark Gross <mgross@linux.intel.com> wrote:
> 
> > It implements a convention on the 4 bytes of "Proximity Domain ID"
> > within the SRAT memory affinity structure as defined in ACPI3.0a.  If
> > bit 31 is set, then the memory range represented by that PXM is assumed
> > to be power managed.  We are working on defining a "standard" for
> > identifying such memory areas as power manageable and progress committee
> > based.  
> > 
> 
> This usage of bit 31 surprized me ;)
It was not my first choice but, adding a new flag bit takes the ACPI
standards committee to rubber stamp the notion.  That is a work in
progress.  The "architects" are pondering the nuances and implications
of this subject as we speak.  I'm sure something wonderful is forth
coming.

We are trying to get this code out there to enable OSV support for a
product with a first generation of power managed memory coming out this
summer in the ATCA form factor, the MPCBL0050.

Its my hope that this convention will not be disruptive or create too
much legacy once the ACPI committee catches up with this technology.
Its not expected to be a problem, as there is only one publicly
available platform rolling out this year with it.

> I think some vendor(sgi?) now using 4byte pxm...

I don't know if SGI has any system that use all 4 bytes of PXM.  I did
notice that until recently the ACPI code in Linux only used the first
byte of that field calling the upper bytes as reserved.  This should be
the first code in Linux to overload the meeting of this bit.


> no problem ? and othre OSs will handle this ?
>
I hope there is no problem. I posted this RFC to find out ;)

I don't know if any other OS's know about this type of memory.  

--mgross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
