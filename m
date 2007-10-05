Date: Fri, 5 Oct 2007 10:21:28 -0700
From: Mark Gross <mgross@linux.intel.com>
Subject: Re: Hotplug memory remove
Message-ID: <20071005172128.GA19681@linux.intel.com>
Reply-To: mgross@linux.intel.com
References: <1191253063.29581.7.camel@dyn9047017100.beaverton.ibm.com> <20071002011447.7ec1f513.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071002011447.7ec1f513.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Badari Pulavarty <pbadari@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 02, 2007 at 01:14:47AM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 01 Oct 2007 08:37:43 -0700
> Badari Pulavarty <pbadari@gmail.com> wrote:
> > 1) Other than remove_memory(), I don't see any other arch-specific
> > code that needs to be provided. Even remove_memory() looks pretty
> > arch independent. Isn't it ?
> > 
> Yes, maybe arch independent. Current codes is based on assumption
> that some arch may needs some code before/after hotremove.
> If no arch needs, we can merge all. 
> 
> > 2) I copied remove_memory() from IA64 to PPC64. When I am testing
> > hotplug-remove (echo offline > state), I am not able to remove
> > any memory at all. I get different type of failures like ..
> > 
> > memory offlining 6e000 to 6f000 failed
> > 
> I'm not sure about this...does this memory is in ZONE_MOVABLE ?
> If not ZONE_MOVABLE, offlining can be fail because of not-removable
> kernel memory. 

How could I mark a nid's worth of memory as ZONE_MOVABLE?  I've been
reading through this code and it appears to somewhat arbitrarily choose
some portion of the memory to be ZONE_MOVABLE per pxm and some kernel
parameters.  But I'm having a hard time finding the proper place to set
up the nodes.

btw: I'm trying to finish up that power managed memory experiment where we
set up numa PXM's marking fbdims we want to fiddle with power state on.


--mgross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
