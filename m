Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EAADA6B0012
	for <linux-mm@kvack.org>; Wed, 18 May 2011 11:20:43 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4IF6k8L008610
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:06:46 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p4IFKViP027344
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:20:33 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4IFKTKR031013
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:20:31 -0600
Subject: Re: [PATCH V3 0/2] mm: Memory hotplug interface changes
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110518151131.GB4709@dumpdata.com>
References: <20110517213604.GA30232@router-fw-old.local.net-space.pl>
	 <20110518151131.GB4709@dumpdata.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Wed, 18 May 2011 08:20:23 -0700
Message-ID: <1305732023.9566.7.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2011-05-18 at 11:11 -0400, Konrad Rzeszutek Wilk wrote:
> Dave and David, you guys Acked them - are they suppose to go through your
> tree(s) or Andrew's? 

-mm is the appropriate place.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
