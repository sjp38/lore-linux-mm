Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C02796B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 14:56:03 -0400 (EDT)
Date: Tue, 31 May 2011 14:55:29 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH V4] xen/balloon: Memory hotplug support for
 Xen balloon driver
Message-ID: <20110531185529.GA7734@dumpdata.com>
References: <20110524223657.GB29133@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110524223657.GB29133@router-fw-old.local.net-space.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
> Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

I just ran those two patches against v3.0-r1 (and under Xen as PV guests) and Andrew, if you want you can stick:

Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
