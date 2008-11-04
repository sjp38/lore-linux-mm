Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mA4FdMOO007883
	for <linux-mm@kvack.org>; Tue, 4 Nov 2008 08:39:22 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA4Fdjsl032998
	for <linux-mm@kvack.org>; Tue, 4 Nov 2008 08:39:45 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA4FditT029836
	for <linux-mm@kvack.org>; Tue, 4 Nov 2008 08:39:45 -0700
Subject: Re: [linux-pm] [PATCH] hibernation should work ok with memory
	hotplug
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <200811041635.49932.rjw@sisk.pl>
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz>
	 <200811040954.34969.rjw@sisk.pl> <1225812111.12673.577.camel@nimitz>
	 <200811041635.49932.rjw@sisk.pl>
Content-Type: text/plain
Date: Tue, 04 Nov 2008 07:39:42 -0800
Message-Id: <1225813182.12673.587.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Nigel Cunningham <ncunningham@crca.org.au>, Matt Tolentino <matthew.e.tolentino@intel.com>, linux-pm@lists.osdl.org, Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@suse.cz, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-11-04 at 16:35 +0100, Rafael J. Wysocki wrote:
> On Tuesday, 4 of November 2008, Dave Hansen wrote:
> > On Tue, 2008-11-04 at 09:54 +0100, Rafael J. Wysocki wrote:
> > > To handle this, I need to know two things:
> > > 1) what changes of the zones are possible due to memory hotplugging
> > > (i.e.    can they grow, shring, change boundaries etc.)
> > 
> > All of the above. 
> 
> OK
> 
> If I allocate a page frame corresponding to specific pfn, is it guaranteed to
> be associated with the same pfn in future?

Page allocation is different.  Since you hold a reference to a page, it
can not be removed until you release that reference.  That's why every
normal alloc_pages() user in the kernel doesn't have to worry about
memory hotplug.

> > Why walk zones instead of pgdats? 
> 
> This is a historical thing rather than anything else.  I think we could switch
> to pgdats, but that would require a code rewrite that's likely to introduce
> bugs, while our image-creating code is really well tested and doesn't change
> very often.

OK, fair enough.  I just wanted you to know that there are options other
than zones.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
