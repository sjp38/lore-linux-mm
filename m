Date: Tue, 19 Oct 2004 00:17:09 +0900 (JST)
Message-Id: <20041019.001709.41629797.taka@valinux.co.jp>
Subject: Re: [Lhms-devel] CONFIG_NONLINEAR for small systems
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <4173D219.3010706@shadowen.org>
References: <4173D219.3010706@shadowen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: apw@shadowen.org
Cc: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Andy,

What version of kernel are you using?
I recommend linux-2.6.9-rc4-mm1 for your purpose, as it has eliminated
bitmaps for free pages to simplify managing buddy allocator.
This may help you.

> Following this email will be a series of patches which provide a
> sample implementation of a simplified CONFIG_NONLINEAR memory model. 
> The first two cleanup general infrastructure to minimise code 
> duplication.  The third introduces an allocator for the numa remap space 
> on i386.  The fourth generalises the page flags code to allow the reuse 
> of the NODEZONE bits.  The final three are the actual meat of the 
> implementation for both i386 and ppc64.
> 
> 050-bootmem-use-NODE_DATA
> 060-refactor-setup_memory-i386
> 080-alloc_remap-i386
> 100-cleanup-node-zone
> 150-nonlinear
> 160-nonlinear-i386
> 170-nonlinear-ppc64
> 
> As has been observed the CONFIG_DISCONTIGMEM implementation
> is inefficient space-wise where a system has a sparse intra-node memory
> configuration. For example we have systems where node 0 has a
> 1GB hole within it. Under CONFIG_DISCONTIGMEM this results in the
> struct page's for this area being allocated from ZONE_NORMAL and
> never used; this is particularly problematic on these 32bit systems
> as we are already under severe pressure in this zone.
> 
> The generalised CONFIG_NONLINEAR memory model described at OLS
> seemed provide more than enough decriptive power to address this
> issue but provided far more functionality that was required.
> Particularly it breaks the identity V=P+c to allow compression of
> the kernel address space, which is not required on these smaller systems.
> 
> This patch set is implemented as a proof-of-concept to show
> that a simplified CONFIG_NONLINEAR based implementation could provide
> sufficient flexibility to solve the problems for these systems.
> 
> In the longer term I'd like to see a single CONFIG_NONLINEAR
> implementation which allowed these various features to be stacked in
> combination as required.
> 
> Thoughts?
> 
> -apw
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
> Use IT products in your business? Tell us what you think of them. Give us
> Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
> http://productguide.itmanagersjournal.com/guidepromo.tmpl
> _______________________________________________
> Lhms-devel mailing list
> Lhms-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/lhms-devel
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
