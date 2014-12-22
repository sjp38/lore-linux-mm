Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4076B0071
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 17:27:42 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id hl2so4663841igb.17
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 14:27:41 -0800 (PST)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com. [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id qf10si14065935icb.72.2014.12.22.14.27.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Dec 2014 14:27:41 -0800 (PST)
Received: by mail-ie0-f177.google.com with SMTP id rd18so5103219iec.36
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 14:27:40 -0800 (PST)
Date: Mon, 22 Dec 2014 14:27:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] proc: task_mmu: show page size in
 /proc/<pid>/numa_maps
In-Reply-To: <5495A698.4050707@linux.intel.com>
Message-ID: <alpine.DEB.2.10.1412221422120.11431@chino.kir.corp.google.com>
References: <c97f30472ec5fe79cb8fa8be66cc3d8509777990.1419079617.git.aquini@redhat.com> <5495A698.4050707@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Rafael Aquini <aquini@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, oleg@redhat.com, linux-mm@kvack.org

On Sat, 20 Dec 2014, Dave Hansen wrote:

> I sometimes wonder what 'numa_maps' purpose is any if we should have
> _some_ kind of policy about what goes in there vs. smaps.  numa_maps
> seems to be turning in to smaps, minus the \n. :)
> 

It seems like an interface, similar to the one proposed by Ulrich, that 
described the NUMA topology would have obsoleted numa_maps and you could 
only rely on smaps to determine locality.  There's existing userspace 
dependencies on numa_maps already, though, so owell.

I had to fix numa_maps output when autonuma was merged for a much more 
subtle difference at 
http://marc.info/?l=git-commits-head&m=139113691614467 so I know some 
people actually parse this and care quite a bit about its accuracy, it's a 
shame it can't be deprecated in favor of adding the necessary information 
to smaps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
