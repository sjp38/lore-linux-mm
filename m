Date: Tue, 9 Oct 2007 10:10:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Hotplug memory remove
Message-Id: <20071009101003.cb9fdc9f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071008190123.GC31906@linux.intel.com>
References: <1191253063.29581.7.camel@dyn9047017100.beaverton.ibm.com>
	<20071002011447.7ec1f513.kamezawa.hiroyu@jp.fujitsu.com>
	<20071005172128.GA19681@linux.intel.com>
	<20071006094115.8b488e55.kamezawa.hiroyu@jp.fujitsu.com>
	<20071008190123.GC31906@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mgross@linux.intel.com
Cc: pbadari@gmail.com, linux-mm@kvack.org, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Mon, 8 Oct 2007 12:01:23 -0700
Mark Gross <mgross@linux.intel.com> wrote:
> > > How could I mark a nid's worth of memory as ZONE_MOVABLE?  I've been
> > > reading through this code and it appears to somewhat arbitrarily choose
> > > some portion of the memory to be ZONE_MOVABLE per pxm and some kernel
> > > parameters.  But I'm having a hard time finding the proper place to set
> > > up the nodes.
> > > 
> > It's not available now.
> 
> Thats a usability challenge.  What use scenarios do you have for memory
> unplug then?  I'd like to mimic your stuff if I can.
> 
For us (fujitsu), we'll have to implement node-unplug, but not yet.
If we can, we can use node-hotplug/node-unplug (of hotplugged node).
This can be used from our hardware console's GUI.
(For us, specifing hot-removable memory by node-id (at boot) is enough.)

I know there is requirements for removing memory which is available at boot
time. But I'm not sure that what information the firmware shows about
hot-removable memory now. 

Specifying MOVABLE zone in precie address range at boot time is ideal but
I'm afraid that it makes memory init code too complicated. Hmm...



> > 
> > One idea is to ignore memory of some PXMs specified by kerenel boot param.
> > Later, you can hot-add specified PXM memory as MOVABLE.
> > Then, boot sequence will be
> > --
> >    bootstrap , ignore some memory here.
> >    init memory, driver, etc
> >    hot-add ignored memory
> >    online hot-added memory by user scripts. (from rc script ?)
> > --y
> > For doing this, we need
> >  - a switch to hot-add memory as MOVABLE (will be easy patch)
> >  - a code for ignoring memory at boot but remember them for later hotadd
> >    (maybe needs arch specific codes)
> >  - a code for hot add memory before rc script (initcall is suitable ?) 
> > 
> > Needs some amount of arch-specific codes, but maybe simple.
> > Why I recommend above is it will be complex to avoid some PXM's memory
> > to be used as bootmem or for some other purpose(slab, hash, etc...).
> 
> I have the boot memory allocations or off-lineable-memory taken care of.
> I can see how the above would work, but I worry that it feels a bit
> hackish.   
> 
> BTW Is this how memory hot remove is expected to be used?
> 
I think above is a simple way to go. How about you ? > Goto-san.
I don't want to make memory-initialization too complicated.
 
> > If your firmware (efi?) doesn't show memory for hot removal at boot time,
> > this idea will be simpler..
> 
> how so?  
>
just hot-add hot-removable memory after boot by some scripts which affects 
the firmware.

I'm glad to hear question about making use of memory-hot-removal in these days :)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
