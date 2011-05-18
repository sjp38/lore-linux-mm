Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 669616B0012
	for <linux-mm@kvack.org>; Wed, 18 May 2011 11:12:05 -0400 (EDT)
Date: Wed, 18 May 2011 11:11:31 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH V3 0/2] mm: Memory hotplug interface changes
Message-ID: <20110518151131.GB4709@dumpdata.com>
References: <20110517213604.GA30232@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110517213604.GA30232@router-fw-old.local.net-space.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 17, 2011 at 11:36:04PM +0200, Daniel Kiper wrote:
> Hi,
> 
> Full list of futures:
>   - mm: Add SECTION_ALIGN_UP() and SECTION_ALIGN_DOWN() macro,
>   - mm: Extend memory hotplug API to allow memory hotplug in virtual
>     machines.
> 
> Those patches applies to Linus' git tree, v2.6.39-rc7 tag with a few
> prerequisite patches available at https://lkml.org/lkml/2011/5/2/296.

Are they in akpm tree?

Dave and David, you guys Acked them - are they suppose to go through your
tree(s) or Andrew's?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
