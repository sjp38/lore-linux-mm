Date: Fri, 16 Feb 2007 11:58:57 -0500 (EST)
From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: [KJ] [PATCH] is_power_of_2 in ia64mm
In-Reply-To: <45D5D47F.3000303@student.ltu.se>
Message-ID: <Pine.LNX.4.64.0702161157450.32716@CPE00045a9c397f-CM001225dbafb6>
References: <1171627435.6127.0.camel@wriver-t81fb058.linuxcoe>
 <45D5C789.1090607@student.ltu.se> <jeire2nnik.fsf@sykes.suse.de>
 <45D5D47F.3000303@student.ltu.se>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Knutsson <ricknu-0@student.ltu.se>
Cc: Andreas Schwab <schwab@suse.de>, Vignesh Babu BM <vignesh.babu@wipro.com>, Kernel Janitors List <kernel-janitors@lists.osdl.org>, linux-mm@kvack.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 16 Feb 2007, Richard Knutsson wrote:

> Andreas Schwab wrote:
> > Richard Knutsson <ricknu-0@student.ltu.se> writes:
> >
> >
> > > Vignesh Babu BM wrote:
> > >
> > > > @@ -175,7 +176,7 @@ static int __init hugetlb_setup_sz(char *str)
> > > >  		tr_pages = 0x15557000UL;
> > > >   	size = memparse(str, &str);
> > > > -	if (*str || (size & (size-1)) || !(tr_pages & size) ||
> > > > +	if (*str || !is_power_of_2(size) || !(tr_pages & size) ||
> > > >  		size <= PAGE_SIZE ||
> > > >  		size >= (1UL << PAGE_SHIFT << MAX_ORDER)) {
> > > >  		printk(KERN_WARNING "Invalid huge page size specified\n");
> > > >
> > > >
> > > As we talked about before; is this really correct?
> > > !is_power_of_2(0) == true while (0 & (0-1)) == 0.
> >
> > size == 0 is also covered by the next two conditions, so the
> > overall value does not change.
> >
> Yes, but is it meant to state that 'size' is not a power of two?
> Otherwise, imho, it should be left as-is.

i think the above change is fine.  as long as the final, overall
semantics of the condition are identical, then there's no problem.

rday

-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
