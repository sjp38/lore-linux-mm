Date: Thu, 4 Sep 2008 17:40:44 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Show memory section to node relationship in sysfs
Message-ID: <20080905004044.GA2768@kroah.com>
References: <20080904202212.GB26795@us.ibm.com> <1220566546.23386.65.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1220566546.23386.65.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 04, 2008 at 03:15:46PM -0700, Dave Hansen wrote:
> On Thu, 2008-09-04 at 13:22 -0700, Gary Hade wrote:
> > 
> > --- linux-2.6.27-rc5.orig/drivers/base/memory.c 2008-09-03 14:24:54.000000000 -0700
> > +++ linux-2.6.27-rc5/drivers/base/memory.c      2008-09-03 14:25:14.000000000 -0700
> > @@ -150,6 +150,22 @@
> >         return len;
> >  }
> > 
> > +/*
> > + * node on which memory section resides
> > + */
> > +static ssize_t show_mem_node(struct sys_device *dev,
> > +                       struct sysdev_attribute *attr, char *buf)
> > +{
> > +       unsigned long start_pfn;
> > +       int ret;
> > +       struct memory_block *mem =
> > +               container_of(dev, struct memory_block, sysdev);
> > +
> > +       start_pfn = section_nr_to_pfn(mem->phys_index);
> > +       ret = pfn_to_nid(start_pfn);
> > +       return sprintf(buf, "%d\n", ret);
> > +}
> 
> I only wonder if this is the "sysfs" way to do it.
> 
> I mean, we don't put a file with the PCI id of a device in the device's
> sysfs directory.  We put a symlink to its place in the bus tree.
> 
> Should we just link over to the NUMA node directory?  We have it there,
> so we might as well use it.

That sounds reasonable to me.  Someone is documenting this new addition
with an entry in Documentation/ABI/, right?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
