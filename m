Message-ID: <41D99743.5000601@sgi.com>
Date: Mon, 03 Jan 2005 13:04:35 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: page migration
References: <41D98556.8050605@sgi.com> <1104776733.25994.11.camel@localhost>
In-Reply-To: <1104776733.25994.11.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Marcello Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

> 
>>I'd like to see this order of patches become the new order for the memory
>>hotplug patch.  That way, I won't have to pull the migration patches out
>>of the hotplug patch every time a new one comes out (I need the migration
>>code, but not the hotplug code for a project I am working on.)
>>
>>Do you suppose this can be done???
> 
> 
> Absolutely.  I was simply working them in the order that they were
> implemented.  But, if we want the migration stuff merged first, I have
> absolutely no problem with putting it first in the patch set.  
> 
> Next time I publish a tree, I'll see what I can do about producing
> similar rollups to what you have, with migration broken out from
> hotplug.
> 

Cool.  Let me know if I can help at all with that.

Once we get that done I'd like to pursure getting the migration patches 
proposed for -mm and then mainline.  Does that make sense?

(perhaps it will make the hotplug patch easier to accept if we can get the 
memory migration stuff in first).

Of course, the "standalone" memory migration stuff makes most sense on NUMA, 
and there is some minor interface changes there to support that (i. e. consider:

migrate_onepage(page);

vs

migrate_onepage_node(page, node);

what the latter does is to call alloc_pages_node() instead of
page_cache_alloc() to get the new page.)

This is all to support NUMA process and memory migration, where the
required function is to move a process >>and<< its memory from one
set of nodes to another.  (I should have a patch for these initial
interface changes later this week.)

But the real question I am wrestling with at the moment is the following:

"Which approach to a NUMA process and memory migration facility would be more 
likely to get into the mainline kernel:

(1)  One based on the existing memory migration patches, or

(2)  something simpler just written for the NUMA process and memory
      migration case."

My preference would be to build on top of the existing code
from the hotplug project.  But the key goal here is to get the code
into the mainline.  I am a little concerned that the hotlug memory migration
code will be regarded as too complicated to get in, and I don't want that
to hold up the NUMA process and memory migration facility, which is what I am
working on and we (well, SGI) specifically need.

Suggestions?

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
