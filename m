Subject: Re: Fw: [Lhms-devel] Making hotremovable attribute with memory
	section[0/4]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20040816153613.E6F7.YGOTO@us.fujitsu.com>
References: <20040816153613.E6F7.YGOTO@us.fujitsu.com>
Content-Type: text/plain
Message-Id: <1092699350.1822.43.camel@nighthawk>
Mime-Version: 1.0
Date: Mon, 16 Aug 2004 16:35:50 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <ygoto@us.fujitsu.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Martin J. Bligh" <mbligh@aracnet.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2004-08-16 at 15:56, Yasunori Goto wrote:
> I made new patches for Memory hotplug. 
> Dave Hansen-san recommeded me I should forward these to LKML
> or linux-mm.
> So, I'll forword these.

I think I suggested that you forward _one_ ;)

In any case, the question of the day is, does anyone have any
suggestions on how to create 2 separate pools for pages: one
representing hot-removable pages, and the other pages that may not be
removed?

Yasunori's patch takes the approach of creating a new free_area struct
inside each zone.  Another approach might be to actually create new
'struct zones' for the new areas.  The new zones one seems cleaner to
me, but the implementation might end up rippling in to a lot of
different areas of code.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
