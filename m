Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A52C86B30BC
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 08:05:49 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id w15so5745885edl.21
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:05:49 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t18si5311747edt.367.2018.11.23.05.05.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 05:05:48 -0800 (PST)
Date: Fri, 23 Nov 2018 14:05:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm/memory_hotplug: drop "online" parameter from
 add_memory_resource()
Message-ID: <20181123130546.GN8625@dhcp22.suse.cz>
References: <20181123123740.27652-1-david@redhat.com>
 <20181123125400.GL8625@dhcp22.suse.cz>
 <a97fcf28-ef71-2b49-c25c-bc96cff8366b@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a97fcf28-ef71-2b49-c25c-bc96cff8366b@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Fri 23-11-18 13:58:16, David Hildenbrand wrote:
> On 23.11.18 13:54, Michal Hocko wrote:
> > On Fri 23-11-18 13:37:40, David Hildenbrand wrote:
> >> User space should always be in charge of how to online memory and
> >> if memory should be onlined automatically in the kernel. Let's drop the
> >> parameter to overwrite this - XEN passes memhp_auto_online, just like
> >> add_memory(), so we can directly use that instead internally.
> > 
> > Heh, I wanted to get rid of memhp_auto_online so much and now we have it
> > in the core memory_hotplug. Not a win on my side I would say :/
> 
> That is actually a good point: Can we remove memhp_auto_online or is it
> already some sort of kernel ABI?
> 
> (as it is exported via /sys/devices/system/memory/auto_online_blocks)

I have tried and there was a pushback [1]. That led to a rework of the
sysfs semantic of onlining btw. The biggest objection against removing was
that the userspace might be too slow to online memory and memmaps could
eat the available memory and trigger OOM. That is why I've started
working on the self hosted memmpas but failed to finish it. Fortunatelly
Oscar is brave enough to continue in that work.

[1] http://lkml.kernel.org/r/20170227092817.23571-1-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs
