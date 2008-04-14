Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3EL9LQo028376
	for <linux-mm@kvack.org>; Mon, 14 Apr 2008 17:09:21 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3EL9L7j245930
	for <linux-mm@kvack.org>; Mon, 14 Apr 2008 17:09:21 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3EL9KPY021399
	for <linux-mm@kvack.org>; Mon, 14 Apr 2008 17:09:20 -0400
Date: Mon, 14 Apr 2008 14:09:20 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
Message-ID: <20080414210920.GB6350@us.ibm.com>
References: <20080411234449.GE19078@us.ibm.com> <20080411234712.GF19078@us.ibm.com> <20080411234743.GG19078@us.ibm.com> <20080411234913.GH19078@us.ibm.com> <20080411235648.GA13276@suse.de> <20080412094118.GA7708@wotan.suse.de> <Pine.LNX.4.64.0804120325001.23255@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804120325001.23255@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Greg KH <gregkh@suse.de>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 12.04.2008 [03:26:35 -0700], Christoph Lameter wrote:
> On Sat, 12 Apr 2008, Nick Piggin wrote:
> 
> > Can you comment on the aspect of configuring various kernel hugetlb 
> > configuration parameters? Especifically, what directory it should go in?
> > IMO it should be /sys/kernel/*
> 
> Yes that would be more consistent. However, it will break the tools that 
> now access /sys/devices.

Since the ABI was undocumented, do we have any idea what those tools
would be? libnuma seems to have some references to sysfs but they result
in warnings, not errors, AFAICT (and I will add libnuma as a consumer of
the interfaces in question, in my patch to add the ABI documentation).

> Something like
> 
> /sys/kernel/node/<nodenr>/<numa setting>

Well, right now, the node devices are anchored in the right place, I
think, and represent a real non-global property (unlike the /sys/kernel
bits). My understanding is that Nick is wondering if
/sys/devices/system/node/nodeX/* should be read-only or if
kernel-changing attributes should also be placed there? You had a
similar question earlier, and we never really resolved it, beyond saying
this was the first attempt at adding a tunable in the directory :)

> and
> 
> /sys/kernel/memory/<global setting>

This is an interesting idea. However, moving the meminfo-like files into
this directory would probably require us obeying the sysfs rules (which
many of the /sys/devices/system/node files do not!) for
one-value-per-file, which would make meminfo lookup non-atomic/less
useful? So, what settings are you thinking go there?

Or, am I completely misunderstanding, and the settings you refer to in
both cases strictly hugetlb-related settings?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
