Date: Mon, 3 Nov 2008 12:51:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hibernation should work ok with memory hotplug
Message-Id: <20081103125108.46d0639e.akpm@linux-foundation.org>
In-Reply-To: <200810291325.01481.rjw@sisk.pl>
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz>
	<200810291325.01481.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: pavel@suse.cz, linux-kernel@vger.kernel.org, linux-pm@lists.osdl.org, Matt Tolentino <matthew.e.tolentino@intel.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Oct 2008 13:25:00 +0100
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> On Wednesday, 29 of October 2008, Pavel Machek wrote:
> > 
> > hibernation + memory hotplug was disabled in kconfig because we could
> > not handle hibernation + sparse mem at some point. It seems to work
> > now, so I guess we can enable it.
> 
> OK, if "it seems to work now" means that it has been tested and confirmed to
> work, no objection from me.

yes, that was not a terribly confidence-inspiring commit message.

3947be1969a9ce455ec30f60ef51efb10e4323d1 said "For now, disable memory
hotplug when swsusp is enabled.  There's a lot of churn there right
now.  We'll fix it up properly once it calms down." which is also
rather rubbery.  

Cough up, guys: what was the issue with memory hotplug and swsusp, and
is it indeed now fixed?

Thanks.


> 
> > Signed-off-by: Pavel Machek <pavel@suse.cz>
> > 
> > 
> > diff -ur linux/mm/Kconfig linux.tmp/mm/Kconfig
> > --- linux/mm/Kconfig	2008-10-27 10:10:59.000000000 +0100
> > +++ linux.tmp/mm/Kconfig	2008-10-29 10:02:41.000000000 +0100
> > @@ -128,12 +128,9 @@
> >  config MEMORY_HOTPLUG
> >  	bool "Allow for memory hot-add"
> >  	depends on SPARSEMEM || X86_64_ACPI_NUMA
> > -	depends on HOTPLUG && !HIBERNATION && ARCH_ENABLE_MEMORY_HOTPLUG
> > +	depends on HOTPLUG && ARCH_ENABLE_MEMORY_HOTPLUG
> >  	depends on (IA64 || X86 || PPC64 || SUPERH || S390)
> >  
> > -comment "Memory hotplug is currently incompatible with Software Suspend"
> > -	depends on SPARSEMEM && HOTPLUG && HIBERNATION
> > -
> >  config MEMORY_HOTPLUG_SPARSE
> >  	def_bool y
> >  	depends on SPARSEMEM && MEMORY_HOTPLUG
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
