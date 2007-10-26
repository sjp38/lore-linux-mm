Date: Fri, 26 Oct 2007 09:27:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Add "removable" to /sysfs to show memblock removability
Message-Id: <20071026092737.419b6ff6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1193355147.9894.33.camel@dyn9047017100.beaverton.ibm.com>
References: <1193351756.9894.30.camel@dyn9047017100.beaverton.ibm.com>
	<1193352354.24087.85.camel@localhost>
	<1193355147.9894.33.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, melgor@ie.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 25 Oct 2007 16:32:26 -0700
Badari Pulavarty <pbadari@us.ibm.com> wrote:

> On Thu, 2007-10-25 at 15:45 -0700, Dave Hansen wrote:
> > On Thu, 2007-10-25 at 15:35 -0700, Badari Pulavarty wrote:
> > > 
> > > +static ssize_t show_mem_removable(struct sys_device *dev, char *buf)
> > > +{
> > > +       unsigned long start_pfn;
> > > +       struct memory_block *mem =
> > > +               container_of(dev, struct memory_block, sysdev);
> > > +
> > > +       start_pfn = section_nr_to_pfn(mem->phys_index);
> > > +       if (is_mem_section_removable(start_pfn, PAGES_PER_SECTION))
> > > +               return sprintf(buf, "True\n");
> > > +       else
> > > +               return sprintf(buf, "False\n");
> > > + 
> > 
> > Yeah, that's what I had in mind.  The only other thing I might suggest
> > would be to do a number instead of true/false here.  Just so that we
> > _can_ have scores in the future.  Otherwise fine with me.
> 
> Good point. Here is the updated version. Thanks for your suggestions.
> 
> Thanks,
> Badari
> 
> Each section of the memory has attributes in /sysfs. This patch adds 
> file "removable" to show if this memory block is removable. This
> helps user-level agents to identify section of the memory for hotplug 
> memory remove.
> 

Looks very nice :) 
Thank you for this work.

One point is ..why not is_mem_section_removable is not under
CONFIG_MEMORY_HOTREMOVE ?


Thanks,
-Kame















--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
