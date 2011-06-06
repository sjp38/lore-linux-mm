Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7436B0078
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 10:57:26 -0400 (EDT)
Date: Mon, 6 Jun 2011 10:56:44 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH V4] mm: Extend memory hotplug API to allow memory hotplug
 in virtual machines
Message-ID: <20110606145644.GB29243@dumpdata.com>
References: <20110524222733.GA29133@router-fw-old.local.net-space.pl>
 <20110602122607.3122e23b.akpm@linux-foundation.org>
 <20110605163806.GA12527@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110605163806.GA12527@router-fw-old.local.net-space.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: Andrew Morton <akpm@linux-foundation.org>, ian.campbell@citrix.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> > Is there any propsect that the other virtualisation schemes will use
> > this facility?  If not, why not?
> 
> I think about that. Even I put a project proposal for GSoC 2011 (you
> could find more details here

Plus .. I remember reading on LWN something about this year's Linux MMU conference
and Red Hat's guys wanting to leverage a generic implemenation for the ballooning
and make it more "self-aware" for KVM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
