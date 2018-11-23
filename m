Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E0F096B30FD
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 08:23:20 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x98-v6so5802691ede.0
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:23:20 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v16si3705004edq.63.2018.11.23.05.23.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 05:23:19 -0800 (PST)
Subject: Re: [PATCH v1] mm/memory_hotplug: drop "online" parameter from
 add_memory_resource()
References: <20181123123740.27652-1-david@redhat.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <60a53b1b-bfbc-79d1-6151-e0779577ab6c@suse.com>
Date: Fri, 23 Nov 2018 14:23:16 +0100
MIME-Version: 1.0
In-Reply-To: <20181123123740.27652-1-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On 23/11/2018 13:37, David Hildenbrand wrote:
> User space should always be in charge of how to online memory and
> if memory should be onlined automatically in the kernel. Let's drop the
> parameter to overwrite this - XEN passes memhp_auto_online, just like
> add_memory(), so we can directly use that instead internally.
> 
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

Acked-by: Juergen Gross <jgross@suse.com>


Juergen
