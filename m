Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mA5GN0Hi025386
	for <linux-mm@kvack.org>; Wed, 5 Nov 2008 09:23:00 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA5GNk5k118546
	for <linux-mm@kvack.org>; Wed, 5 Nov 2008 09:23:46 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA5GNjE3006984
	for <linux-mm@kvack.org>; Wed, 5 Nov 2008 09:23:46 -0700
Subject: Re: [linux-pm] [PATCH] hibernation should work ok with memory
	hotplug
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1225876205.6755.55.camel@nigel-laptop>
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz>
	 <20081103125108.46d0639e.akpm@linux-foundation.org>
	 <1225747308.12673.486.camel@nimitz>  <200811032324.02163.rjw@sisk.pl>
	 <1225751665.12673.511.camel@nimitz> <1225771353.6755.16.camel@nigel-laptop>
	 <1225782572.12673.540.camel@nimitz> <1225783837.6755.33.camel@nigel-laptop>
	 <1225785224.12673.564.camel@nimitz> <1225876205.6755.55.camel@nigel-laptop>
Content-Type: text/plain
Date: Wed, 05 Nov 2008 08:23:43 -0800
Message-Id: <1225902223.12673.616.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nigel Cunningham <ncunningham@crca.org.au>
Cc: Matt Tolentino <matthew.e.tolentino@intel.com>, linux-pm@lists.osdl.org, Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@suse.cz, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-11-05 at 20:10 +1100, Nigel Cunningham wrote:
> In your example above, zone_start_pfn will be 1, won't it? If that's the
> case, I shouldn't need to subtract ARCH_PFN_OFFSET to get the right
> index within the zone and avoid the same wastage that ARCH_PFN_OFFSET
> avoids with mem_map.

Yeah, I don't think the first zone will ever start before
ARCH_PFN_OFFSET.

If the code just deals with starting at any random zone_start_pfn and
going to any other random zone_end_pfn without any waste, then it should
be fine in the presence of ARCH_PFN_OFFSET.  The only trouble is if it
assumes memory to start at 0x0.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
