Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8A93B6B009C
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 14:44:19 -0400 (EDT)
Date: Wed, 29 Jul 2009 11:25:01 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 3/4] hugetlb:  add private bit-field to kobject
 structure
Message-ID: <20090729182501.GA1699@suse.de>
References: <20090729181139.23716.85986.sendpatchset@localhost.localdomain>
 <20090729181158.23716.41437.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090729181158.23716.41437.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, andi@firstfloor.org, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, Jul 29, 2009 at 02:11:58PM -0400, Lee Schermerhorn wrote:
> PATCH/RFC 3/4 hugetlb:  add private bitfield to struct kobject
> 
> Against: 2.6.31-rc3-mmotm-090716-1432
> atop the previously posted alloc_bootmem_hugepages fix.
> [http://marc.info/?l=linux-mm&m=124775468226290&w=4]
> 
> For the per node huge page attributes, we want to share
> as much code as possible with the global huge page attributes,
> including the show/store functions.  To do this, we'll need a
> way to back translate from the kobj argument to the show/store
> function to the node id, when entered via that path.  This
> patch adds a subsystem/sysdev private bitfield to the kobject
> structure.  The bitfield uses unused bits in the same unsigned
> int as the various kobject flags so as not to increase the size
> of the structure. 
> 
> Currently, the bit field is the minimum required for the huge
> pages per node attributes [plus one extra bit].  The field could
> be expanded for other usage, should such arise.
> 
> Note that this is not absolutely required.  However, using this
> private field eliminates an inner loop to scan the per node
> hstate kobjects and eliminates scanning entirely for the global
> hstate kobjects.

Ick, no, please don't do that.  That's what the structure you use to
contain your kobject should be for, right?

Or are you for some reason using "raw" kobjects?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
