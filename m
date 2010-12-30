Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A51806B00B4
	for <linux-mm@kvack.org>; Thu, 30 Dec 2010 17:04:19 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1561521Ab0L3WEG (ORCPT <rfc822;linux-mm@kvack.org>);
	Thu, 30 Dec 2010 23:04:06 +0100
Date: Thu, 30 Dec 2010 23:04:06 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH R2 1/7] mm: Add add_registered_memory() to memory hotplug API
Message-ID: <20101230220406.GB17191@router-fw-old.local.net-space.pl>
References: <20101229170212.GF2743@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1012291643290.6040@chino.kir.corp.google.com> <20101230123013.GA12765@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1012301048550.12995@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1012301048550.12995@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Dec 30, 2010 at 10:49:29AM -0800, David Rientjes wrote:
> On Thu, 30 Dec 2010, Daniel Kiper wrote:
>
> > > Looks like this patch was based on a kernel before 2.6.37-rc4 since it
> > > doesn't have 20d6c96b5f (mem-hotplug: introduce {un}lock_memory_hotplug())
> >
> > As I wrote in "[PATCH R2 0/7] Xen memory balloon driver with memoryhotplug
> > support" this patch applies to Linux kernel Ver. 2.6.36.
> >
>
> I'd suggest posting patches against the latest -git.

Thx, next patch will be based on latest rc.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
