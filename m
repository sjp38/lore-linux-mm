Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 486708D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:26:50 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2UEBFRF020502
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 08:11:15 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2UEQOvo067742
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 08:26:25 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2UEQMaj011338
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 08:26:23 -0600
Subject: Re: [PATCH 3/3] mm: Extend memory hotplug API to allow memory
 hotplug in virtual machines
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110329183242.GE30387@router-fw-old.local.net-space.pl>
References: <20110328092507.GD13826@router-fw-old.local.net-space.pl>
	 <1301329524.31700.8440.camel@nimitz>
	 <20110329183242.GE30387@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Wed, 30 Mar 2011 07:26:16 -0700
Message-ID: <1301495176.21454.3736.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2011-03-29 at 20:32 +0200, Daniel Kiper wrote:
> > Your stuff already extracted the free stuff very nicely.  I think now we
> > just need to separate out the totalram_pages/totalhigh_pages bits from
> > the num_physpages/max_mapnr ones.
> 
> What do you think about __online_page_increment_counters()
> (totalram_pages and totalhigh_pages) and
> __online_page_set_limits() (num_physpages and max_mapnr) ??? 

I think there's a point when "online_page" in there becomes unnecessary,
but those sound OK to me.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
