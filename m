Date: Sat, 20 May 2006 15:54:01 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 4/6] Have x86_64 use add_active_range() and
 free_area_init_nodes
Message-Id: <20060520155401.3048be0d.akpm@osdl.org>
In-Reply-To: <200605210017.59984.ak@suse.de>
References: <20060508141030.26912.93090.sendpatchset@skynet>
	<200605202327.19606.ak@suse.de>
	<20060520144043.22f993b1.akpm@osdl.org>
	<200605210017.59984.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: mel@csn.ul.ie, davej@codemonkey.org.uk, tony.luck@intel.com, bob.picco@hp.com, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen <ak@suse.de> wrote:
>
>  
> > Well, it creates arch-neutral common code, teaches various architectures
> > use it.  It's the sort of thing we do all the time.
> > 
> > These things are opportunities to eliminate crufty arch code which few
> > people understand and replace them with new, clean common code which lots
> > of people understand.  That's not a bad thing to be doing.
> 
> I'm not fundamentally against that, but so far it seems to just generate lots of 
> new bugs?  I'm not sure it's really worth the pain.
> 

It is a bit disproportionate.  But in some ways that's a commentary on the
current code.   All this numa/sparse/flat/discontig/holes-in-zones/
virt-memmap/ stuff is pretty hairy, especially in its initalisation.

I'm willing to go through the pain if it ends up with something cleaner
which more people understand a little bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
