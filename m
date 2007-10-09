Date: Tue, 09 Oct 2007 19:51:59 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: Hotplug memory remove
In-Reply-To: <20071009101003.cb9fdc9f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071008190123.GC31906@linux.intel.com> <20071009101003.cb9fdc9f.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20071009193217.4270.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: mgross@linux.intel.com, pbadari@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> > > One idea is to ignore memory of some PXMs specified by kerenel boot param.
> > > Later, you can hot-add specified PXM memory as MOVABLE.
> > > Then, boot sequence will be
> > > --
> > >    bootstrap , ignore some memory here.
> > >    init memory, driver, etc
> > >    hot-add ignored memory
> > >    online hot-added memory by user scripts. (from rc script ?)
> > > --y
> > > For doing this, we need
> > >  - a switch to hot-add memory as MOVABLE (will be easy patch)
> > >  - a code for ignoring memory at boot but remember them for later hotadd
> > >    (maybe needs arch specific codes)
> > >  - a code for hot add memory before rc script (initcall is suitable ?) 
> > > 
> > > Needs some amount of arch-specific codes, but maybe simple.
> > > Why I recommend above is it will be complex to avoid some PXM's memory
> > > to be used as bootmem or for some other purpose(slab, hash, etc...).
> > 
> > I have the boot memory allocations or off-lineable-memory taken care of.
> > I can see how the above would work, but I worry that it feels a bit
> > hackish.   
> > 
> > BTW Is this how memory hot remove is expected to be used?
> > 
> I think above is a simple way to go. How about you ? > Goto-san.
> I don't want to make memory-initialization too complicated.

Hmm. At first, I agreed with you. But I'm a bit worry about it too now.

When movable-memory is specified by boot option, I guess something
wrong case will occur like followings.

  ex) Movable node is specified by boot-option as "movable_node=2" on 
      4 node box.

    1) boot up with 2 movable node and 2 non-movable node.
    2) remove those 2 nodes physically.
    3) system must be removed by some reasons.
    4) system can't boot up due to only 2 MOVABLE nodes!

It depends how "movable area" is specified. please take care.

Bye.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
