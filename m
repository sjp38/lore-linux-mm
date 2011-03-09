Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DACDA8D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 09:01:49 -0500 (EST)
Date: Wed, 9 Mar 2011 14:01:25 +0000
From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Subject: Re: [PATCH R4 0/7] xen/balloon: Memory hotplug support for Xen
 balloon driver
In-Reply-To: <20110308214429.GA27331@router-fw-old.local.net-space.pl>
Message-ID: <alpine.DEB.2.00.1103091359290.2968@kaball-desktop>
References: <20110308214429.GA27331@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: Ian Campbell <Ian.Campbell@eu.citrix.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi.kleen@intel.com" <andi.kleen@intel.com>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "jeremy@goop.org" <jeremy@goop.org>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, "v.tolstov@selfip.ru" <v.tolstov@selfip.ru>, "pasik@iki.fi" <pasik@iki.fi>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, "wdauchy@gmail.com" <wdauchy@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 8 Mar 2011, Daniel Kiper wrote:
> Hi,
> 
> I am sending next version of memory hotplug
> support for Xen balloon driver patch. It applies
> to Linus' git tree, v2.6.38-rc8 tag. Most of
> suggestions were taken into account. Thanks for
> everybody who tested and/or sent suggestions
> to my work.
> 
> There are a few prerequisite patches which fixes
> some problems found during work on memory hotplug
> patch or add some futures which are needed by
> memory hotplug patch.
> 
> Full list of fixes/futures:
>   - xen/balloon: Removal of driver_pages,
>   - xen/balloon: HVM mode support,
>   - xen/balloon: Migration from mod_timer() to schedule_delayed_work(),
>   - xen/balloon: Protect against CPU exhaust by event/x process,
>   - xen/balloon: Minor notation fixes,
>   - mm: Extend memory hotplug API to allow memory hotplug in virtual guests,
>   - xen/balloon: Memory hotplug support for Xen balloon driver.
> 
> Additionally, I suggest to apply patch prepared by Steffano Stabellini
> (https://lkml.org/lkml/2011/1/31/232) which fixes memory management
> issue in Xen guest. I was not able boot guest machine without
> above mentioned patch.

after some discussions we came up with a different approach to fix the
issue; I sent a couple of patches a little while ago:

https://lkml.org/lkml/2011/2/28/410

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
