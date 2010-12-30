Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D1B0D6B00A9
	for <linux-mm@kvack.org>; Thu, 30 Dec 2010 13:49:42 -0500 (EST)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id oBUIndSY014751
	for <linux-mm@kvack.org>; Thu, 30 Dec 2010 10:49:39 -0800
Received: from pzk28 (pzk28.prod.google.com [10.243.19.156])
	by hpaq3.eem.corp.google.com with ESMTP id oBUInXWE002163
	for <linux-mm@kvack.org>; Thu, 30 Dec 2010 10:49:38 -0800
Received: by pzk28 with SMTP id 28so2558539pzk.16
        for <linux-mm@kvack.org>; Thu, 30 Dec 2010 10:49:33 -0800 (PST)
Date: Thu, 30 Dec 2010 10:49:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH R2 1/7] mm: Add add_registered_memory() to memory hotplug
 API
In-Reply-To: <20101230123013.GA12765@router-fw-old.local.net-space.pl>
Message-ID: <alpine.DEB.2.00.1012301048550.12995@chino.kir.corp.google.com>
References: <20101229170212.GF2743@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1012291643290.6040@chino.kir.corp.google.com> <20101230123013.GA12765@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Dec 2010, Daniel Kiper wrote:

> > Looks like this patch was based on a kernel before 2.6.37-rc4 since it
> > doesn't have 20d6c96b5f (mem-hotplug: introduce {un}lock_memory_hotplug())
> 
> As I wrote in "[PATCH R2 0/7] Xen memory balloon driver with memoryhotplug
> support" this patch applies to Linux kernel Ver. 2.6.36.
> 

I'd suggest posting patches against the latest -git.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
