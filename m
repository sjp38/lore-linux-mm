Date: Thu, 25 Oct 2007 19:05:14 +0100
Subject: Re: [PATCH 2/2] Add mem_type in /syfs to show memblock migrate type
Message-ID: <20071025180514.GB20345@skynet.ie>
References: <1193327756.9894.5.camel@dyn9047017100.beaverton.ibm.com> <1193331162.4039.141.camel@localhost> <1193332042.9894.10.camel@dyn9047017100.beaverton.ibm.com> <1193332528.4039.156.camel@localhost> <1193333766.9894.16.camel@dyn9047017100.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1193333766.9894.16.camel@dyn9047017100.beaverton.ibm.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (25/10/07 10:36), Badari Pulavarty didst pronounce:
> On Thu, 2007-10-25 at 10:15 -0700, Dave Hansen wrote:
> > On Thu, 2007-10-25 at 10:07 -0700, Badari Pulavarty wrote:
> > > I agree with you that all I care about are the "movable" sections 
> > > for remove. But what we are doing here is, exporting the migrate type
> > > to user-space and let the user space make a decision on what type
> > > of sections to use for its use. For now, we can migrate/remove ONLY
> > > "movable" sections. But in the future, we may be able to
> > > migrate/remove
> > > "Reclaimable" ones. I don't know.
> > 
> > Right, and if that happens, we simply update the one function that makes
> > the (non)removable decision.
> > 
> > > I don't want to make decisions in the kernel for removability
> > 
> > Too late. :)  That's what the mobility patches are all about: having the
> > kernel make decisions that affect removability.  
> > 
> > >  - as
> > > it might change depending on the situation. All I want is to export
> > > the info and let user-space deal with the decision making.
> > 
> > That's a good point.  But, if we have multiple _removable_ pageblocks in
> > the same section, but with slightly different types, your patch doesn't
> > help.  The user will just see "Multiple", and won't be able to tell that
> > they can remove it. :(
> 
> So, what you would like to see is - instead of mem_type, you want 
> "mem_removable" and print "true/false". Correct ?
> 

That seems to be the suggestion all right.

> Mel/KAME - what do you think ? At least on ppc64 (where section size ==
> mobility group size), I prefer to see mobility type (more informative).
> But I am okay with returning boolean.
> 

I think Dave has a point so I would be happy with a boolean. We don't really
care what the type is, we care about if it can be removed or not.

It also occurs to me from the "can we remove it perspective" that you may
also want to check if the pageblock is entirely free or not. You can encounter
a pageblock that is "Unmovable" but entirely free so it could be removed.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
