Date: Sat, 14 Jul 2007 08:25:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/7] Generic Virtual Memmap support for SPARSEMEM
Message-Id: <20070714082537.b854b69e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0707131612530.26795@schroedinger.engr.sgi.com>
References: <exportbomb.1184333503@pinky>
	<E1I9LJY-00006o-GK@hellhawk.shadowen.org>
	<20070713235121.538ddcaf.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0707131541540.26109@schroedinger.engr.sgi.com>
	<20070714081210.1440db40.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0707131612530.26795@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: apw@shadowen.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, npiggin@suse.de, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jul 2007 16:17:32 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> > Note
> > >From memory hotplug development/enhancement view, I have following thinking now.
> >  
> >  1. memmap's section is *not* aligned to "big page size". We have to take care
> >     of this at adding support for memory_hotplug/unplug.
> 
> You can call the functions for virtual memmap allocation directly. They 
> are already generic and will call the page allocator instead of the 
> bootmem allocator if the system is already. They will give you the 
> properly aligned memory. Perhaps you can just change a few lines 
> in sparse_add_one_section to call the vmemmap functions instead?
> 
yes, I think so now. But we'll see warnings of "section mismatch".
Because this patch includes following.

==
func() {
	if()
		call_generic_func
	else
		call_boot_func.
}
==



> >  2. With an appropriate patch, we can allocate new section's memmap from
> >     itself. This will reduce possibility of memory hotplug failure becasue of
> >     large size kmalloc/vmalloc. And it guarantees locality of memmap.
> >     But maybe need some amount of work for implementing this in clean way.
> >     This will depend on vmemmap.
> 
> That is a good idea. Maybe do the simple approach first and then the other 
> one?
Yes, simple first. Above one will be an option for people who use 
big-section-size, like ia64.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
