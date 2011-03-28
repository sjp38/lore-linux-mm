Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BE84D8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 11:24:23 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2SFHcAb028703
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:17:38 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p2SFOIl9106388
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:24:18 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2SFOGuU017719
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:24:17 -0600
Subject: Re: [PATCH 1/3] mm: Optimize pfn calculation in online_page()
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110328092310.GB13826@router-fw-old.local.net-space.pl>
References: <20110328092310.GB13826@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 28 Mar 2011 08:24:13 -0700
Message-ID: <1301325853.31700.8284.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2011-03-28 at 11:23 +0200, Daniel Kiper wrote:
> If CONFIG_FLATMEM is enabled pfn is calculated in online_page()
> more than once. It is possible to optimize that and use value
> established at beginning of that function.
> 
> Signed-off-by: Daniel Kiper <dkiper@net-space.pl> 

Looks sensible to me.

Acked-by: Dave Hansen <dave@linux.vnet.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
