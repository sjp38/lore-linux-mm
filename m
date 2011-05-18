Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1FE906B0012
	for <linux-mm@kvack.org>; Wed, 18 May 2011 11:06:55 -0400 (EDT)
Date: Wed, 18 May 2011 11:06:30 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] Re: [PATCH V3] xen/balloon: Memory hotplug support
 for Xen balloon driver
Message-ID: <20110518150630.GA4709@dumpdata.com>
References: <20110517214421.GD30232@router-fw-old.local.net-space.pl>
 <1305701868.28175.1.camel@vase>
 <1305703309.7738.23.camel@dagon.hellion.org.uk>
 <1305703494.28175.2.camel@vase>
 <20110518103543.GA5066@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110518103543.GA5066@router-fw-old.local.net-space.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: Vasiliy G Tolstov <v.tolstov@selfip.ru>, "jeremy@goop.org" <jeremy@goop.org>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, Ian Campbell <Ian.Campbell@eu.citrix.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "wdauchy@gmail.com" <wdauchy@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "andi.kleen@intel.com" <andi.kleen@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>

> Here is proper udev rule:
> 
> SUBSYSTEM=="memory", ACTION=="add", RUN+="/bin/sh -c '[ -f /sys$devpath/state ] && echo online > /sys$devpath/state'"
> 
> Konrad, could you add it to git comment and Kconfig help ???

I am going to be lazy and ask you to resend this patch with that udev rule mentioned in it :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
