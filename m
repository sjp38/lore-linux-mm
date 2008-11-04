Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mA40qaZL007090
	for <linux-mm@kvack.org>; Mon, 3 Nov 2008 17:52:36 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA40qn05076380
	for <linux-mm@kvack.org>; Mon, 3 Nov 2008 17:52:49 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA40qmTt016323
	for <linux-mm@kvack.org>; Mon, 3 Nov 2008 17:52:48 -0700
Subject: Re: [PATCH] hibernation should work ok with memory hotplug
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <200811040129.35335.rjw@sisk.pl>
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz>
	 <200811040005.12418.rjw@sisk.pl> <1225753819.12673.518.camel@nimitz>
	 <200811040129.35335.rjw@sisk.pl>
Content-Type: text/plain
Date: Mon, 03 Nov 2008 16:52:47 -0800
Message-Id: <1225759967.12673.521.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Andrew Morton <akpm@linux-foundation.org>, pavel@suse.cz, linux-kernel@vger.kernel.org, linux-pm@lists.osdl.org, Matt Tolentino <matthew.e.tolentino@intel.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-11-04 at 01:29 +0100, Rafael J. Wysocki wrote:
> > Since zone *ranges* overlap, you can't tell to which zone a page belongs
> > simply from its address.  You need to ask the 'struct page'.
> 
> Understood.
> 
> This means that some zones may contain some ranges of pfns that correspond
> to struct pages in another zone, correct?

Yup, that's correct.

The patch looks good to me.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
