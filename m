Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CE1DA8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:23:28 -0400 (EDT)
Date: Tue, 29 Mar 2011 09:23:11 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 3/3] mm: Extend memory hotplug API to allow memory
 hotplug in virtual machines
Message-ID: <20110329132311.GA28815@dumpdata.com>
References: <20110328092507.GD13826@router-fw-old.local.net-space.pl>
 <20110328153735.d797c5b3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110328153735.d797c5b3.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> I merged your patch 1/3.
> 
> I skipped your patch 2/3, as the new macros appear to have no callers
> in this patchset.
> 
> I suggest that once we're happy with them, your patches 2 and 3 be
> merged up via whichever tree merges the Xen balloon driver changes. 
> That might be my tree, I forget :) Was anyone else thinking of grabbing
> them?

That would be. I can carry that pathces if this is easier for you.
Would need the Ack-by at some point from mm maintainers when the patches are
to everybody's satisfaction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
