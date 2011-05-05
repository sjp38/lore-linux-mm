Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AD44A900001
	for <linux-mm@kvack.org>; Thu,  5 May 2011 14:50:40 -0400 (EDT)
Date: Thu, 5 May 2011 14:42:02 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH V2] xen/balloon: Memory hotplug support for Xen balloon
 driver
Message-ID: <20110505184202.GB10142@dumpdata.com>
References: <20110502220148.GI4623@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110502220148.GI4623@router-fw-old.local.net-space.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 03, 2011 at 12:01:48AM +0200, Daniel Kiper wrote:
> Memory hotplug support for Xen balloon driver. It should be
> mentioned that hotplugged memory is not onlined automatically.
> It should be onlined by user through standard sysfs interface.
> 
> This patch applies to Linus' git tree, v2.6.39-rc5 tag with a few
> prerequisite patches available at https://lkml.org/lkml/2011/5/2/339
> and at https://lkml.org/lkml/2011/3/28/98.

The patch looks good. How do I use it? Should the writeup or the
Kconfig include a little section on how to online the memory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
