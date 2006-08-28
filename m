Date: Mon, 28 Aug 2006 10:32:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 2/7] ia64 generic PAGE_SIZE
In-Reply-To: <1156785773.5913.38.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0608281029550.27837@schroedinger.engr.sgi.com>
References: <20060828154413.E05721BD@localhost.localdomain>
 <20060828154414.38AEDAA2@localhost.localdomain>
 <Pine.LNX.4.64.0608281003070.27677@schroedinger.engr.sgi.com>
 <1156785773.5913.38.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Aug 2006, Dave Hansen wrote:

> Yes and no.  First of all, 15 of the 24 architectures use the Kconfig
> default of 4k pages.  Anybody adding an architecture with 4k pages only
> has to include asm-generic/page.h in their arch, and they don't add
> *anything* to Kconfig.  If they want completely fixed page sizes other
> than 4k, they only add '|| ARCH' on one line in the Kconfig.

Lets keep the arch specific stuff out of mm/Kconfig.

> There are a couple of ways to go about enabling the configurable page
> sizes.  One is to do what I did, hand have all of the architectures
> enumerated in mm/Kconfig.  The other is to have something along the
> lines of:
> 
>         choice
>                 prompt "Kernel Page Size"
>                 depends on ARCH_CHOOSES_PAGE_SIZE
>         	...
>         
> Then in arch/{ia64,...}/Kconfig, have
>         
>         config ARCH_CHOOSES_PAGE_SIZE
>         	def_bool y


How about having definitions like ARCH_SUPPORTS_4/8/16k_PAGESIZE
and ARCH_DEFAULT_4/8/16k_PAGESIZE and use those in mm/Kconfig. That way 
you keep the arch specific stuff out. Each arch just sets up whatever
it supports.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
