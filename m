Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B09436B0022
	for <linux-mm@kvack.org>; Wed, 18 May 2011 03:25:12 -0400 (EDT)
Subject: Re: [PATCH V3] xen/balloon: Memory hotplug support for Xen balloon
 driver
From: Vasiliy G Tolstov <v.tolstov@selfip.ru>
Reply-To: v.tolstov@selfip.ru
In-Reply-To: <1305703309.7738.23.camel@dagon.hellion.org.uk>
References: <20110517214421.GD30232@router-fw-old.local.net-space.pl>
	 <1305701868.28175.1.camel@vase>
	 <1305703309.7738.23.camel@dagon.hellion.org.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 18 May 2011 11:24:54 +0400
Message-ID: <1305703494.28175.2.camel@vase>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi.kleen@intel.com" <andi.kleen@intel.com>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "jeremy@goop.org" <jeremy@goop.org>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, "pasik@iki.fi" <pasik@iki.fi>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, "wdauchy@gmail.com" <wdauchy@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, 2011-05-18 at 08:21 +0100, Ian Campbell wrote:
> On Wed, 2011-05-18 at 07:57 +0100, Vasiliy G Tolstov wrote:
> > On Tue, 2011-05-17 at 23:44 +0200, Daniel Kiper wrote:
> > > +	  Memory could be hotplugged in following steps:
> > > +
> > > +	    1) dom0: xl mem-max <domU> <maxmem>
> > > +	       where <maxmem> is >= requested memory size,
> > > +
> > > +	    2) dom0: xl mem-set <domU> <memory>
> > > +	       where <memory> is requested memory size; alternatively memory
> > > +	       could be added by writing proper value to
> > > +	       /sys/devices/system/xen_memory/xen_memory0/target or
> > > +	       /sys/devices/system/xen_memory/xen_memory0/target_kb on dumU,
> > > +
> > > +	    3) domU: for i in /sys/devices/system/memory/memory*/state; do \
> > > +	               [ "`cat "$i"`" = offline ] && echo online > "$i"; done
> > > +
> 
> > Very good. Is that possible to eliminate step 3 ? And do it automatic if
> > domU runs with specific xen balloon param?
> 
> When we faced the same question WRT VCPU hotplug we ended up using a
> udev rule. Presumably the same could be done here. In the VCPU case the
> rule is:
> 
> ACTION=="add", SUBSYSTEM=="cpu", RUN+="/bin/sh -c '[ ! -e /sys$devpath/online ] || echo 1 > /sys$devpath/online'"
> 
> Presumably the memory one will be broadly similar.
> 
> Ian.
> 

Ok. very good solution. Thank's.

-- 
Vasiliy G Tolstov <v.tolstov@selfip.ru>
Selfip.Ru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
