Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F085A6B3040
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:54:03 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x15so5763903edd.2
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 04:54:03 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o24-v6si1605297ejz.181.2018.11.23.04.54.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 04:54:02 -0800 (PST)
Date: Fri, 23 Nov 2018 13:54:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm/memory_hotplug: drop "online" parameter from
 add_memory_resource()
Message-ID: <20181123125400.GL8625@dhcp22.suse.cz>
References: <20181123123740.27652-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181123123740.27652-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Fri 23-11-18 13:37:40, David Hildenbrand wrote:
> User space should always be in charge of how to online memory and
> if memory should be onlined automatically in the kernel. Let's drop the
> parameter to overwrite this - XEN passes memhp_auto_online, just like
> add_memory(), so we can directly use that instead internally.

Heh, I wanted to get rid of memhp_auto_online so much and now we have it
in the core memory_hotplug. Not a win on my side I would say :/
On the other hand this can be seen as a cleanup because it removes that
ambiguity that some callers might be unaware of the memhp_auto_online
leading to a different behavior.

> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: Juergen Gross <jgross@suse.com>
> Cc: Stefano Stabellini <sstabellini@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs
