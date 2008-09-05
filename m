Date: Fri, 05 Sep 2008 11:29:19 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] Show memory section to node relationship in sysfs
In-Reply-To: <20080905020729.GG26795@us.ibm.com>
References: <48C06FB4.1040100@us.ibm.com> <20080905020729.GG26795@us.ibm.com>
Message-Id: <20080905112632.6756.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Nish Aravamudan <nish.aravamudan@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> On Thu, Sep 04, 2008 at 04:31:00PM -0700, Badari Pulavarty wrote:
> > Nish Aravamudan wrote:
> >> On 9/4/08, Gary Hade <garyhade@us.ibm.com> wrote:
> >>   
> >>> Show memory section to node relationship in sysfs
> >>>
> >>>  Add /sys/devices/system/memory/memoryX/node files to show
> >>>  the node on which each memory section resides.
> >>>     
> >>
> >> I think this patch needs an additional bit for Documentation/ABI
> >> (might be other parts of /sys/devices/system/memory missing from
> >> there).
> >>
> >>   
> > Yes. I added Documentation/ABI for "removable". We should update it for  
> > this too.
> >> Also, I wonder if it might not make more sense to use a symlink here? That is
> >>
> >> /sys/devices/system/memory/memoryX/node -> /sys/devices/system/node/nodeY ?
> >>
> >>   
> > Makes sense. Since we already have "node/nodeY", we might as well make  
> > use of it
> > instead of duplicating it.
> >> And then we could, potentially, have symlinks returning from the node
> >> side to indicate all memory sections on that node (might be handy for
> >> node offline?):
> >>
> >> /sys/devices/system/node/nodeX/memory1 -> /sys/devices/system/memory/memoryY
> >> /sys/devices/system/node/nodeX/memory2 -> /sys/devices/system/memory/memoryZ
> >>
> >>   
> > I don't think we need both. Gary wants to do "node removal/offline" and  
> > wants
> > to find out all the memory sections that belong to nodeX. May be this is a
> > a better interface. This way, we can quickly get through all the memory  
> > sections without looking at all the sections. Gary ?
> 
> Yes, either way would work fine but I think symlinks in the
> /sys/devices/system/node/nodeX directories would make the
> script or program driven memory section offlining complete
> a little more quickly.  However, if we do this we might want to
> make the symlink names to match the memory section directory names.
>   /sys/devices/system/node/nodeX/memoryY -> /sys/devices/system/memory/memoryY
>   /sys/devices/system/node/nodeX/memoryZ -> /sys/devices/system/memory/memoryZ

Agree. I think this is better way.


Thanks.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
