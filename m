Message-ID: <429F631E.6020401@engr.sgi.com>
Date: Thu, 02 Jun 2005 14:50:54 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: Avoiding external fragmentation with a placement policy Version
 12
References: <20050531112048.D2511E57A@skynet.csn.ul.ie> <429E20B6.2000907@austin.ibm.com> <429E4023.2010308@yahoo.com.au> <423970000.1117668514@flay> <429E483D.8010106@yahoo.com.au> <434510000.1117670555@flay> <429E50B8.1060405@yahoo.com.au> <429F2B26.9070509@austin.ibm.com>
In-Reply-To: <429F2B26.9070509@austin.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jschopp@austin.ibm.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

> In summary here are the reasons I see to run with Mel's patch:
> 
> 1. It really helps with medium-large allocations under memory pressure.
> 2. Page migration defrag will need it.
> 3. Memory hotplug remove will need it.
> 

Could someone point me at the "Page migration defrag" patch, or
describe what this is.  Does this depend on the page migration
patches from memory hotplug to move pages or is it something
different?

Thanks,
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
