Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 741F26B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 15:20:28 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1582868Ab1ESTTr (ORCPT <rfc822;linux-mm@kvack.org>);
	Thu, 19 May 2011 21:19:47 +0200
Date: Thu, 19 May 2011 21:19:47 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [Xen-devel] Re: [PATCH V3] xen/balloon: Memory hotplug support for Xen balloon driver
Message-ID: <20110519191947.GA27202@router-fw-old.local.net-space.pl>
References: <20110517214421.GD30232@router-fw-old.local.net-space.pl> <1305701868.28175.1.camel@vase> <1305703309.7738.23.camel@dagon.hellion.org.uk> <1305703494.28175.2.camel@vase> <20110518103543.GA5066@router-fw-old.local.net-space.pl> <20110518150630.GA4709@dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110518150630.GA4709@dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, Vasiliy G Tolstov <v.tolstov@selfip.ru>, "jeremy@goop.org" <jeremy@goop.org>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, Ian Campbell <Ian.Campbell@eu.citrix.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "wdauchy@gmail.com" <wdauchy@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "andi.kleen@intel.com" <andi.kleen@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>

On Wed, May 18, 2011 at 11:06:30AM -0400, Konrad Rzeszutek Wilk wrote:
> > Here is proper udev rule:
> >
> > SUBSYSTEM=="memory", ACTION=="add", RUN+="/bin/sh -c '[ -f /sys$devpath/state ] && echo online > /sys$devpath/state'"
> >
> > Konrad, could you add it to git comment and Kconfig help ???
>
> I am going to be lazy and ask you to resend this patch with that udev rule mentioned in it :-)

OK. However, David Rientjes has some objections to "Extend memory
hotplug API to allow memory hotplug in virtual machine" patch
and I will do that after clarifying/solving some issues.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
