Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 031AF6B2F69
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 08:07:41 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o21so2368472edq.4
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:07:40 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t20-v6si39606ejj.104.2018.11.23.05.07.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 05:07:39 -0800 (PST)
Message-ID: <1542978439.6030.1.camel@suse.de>
Subject: Re: [PATCH v1] mm/memory_hotplug: drop "online" parameter from
 add_memory_resource()
From: Oscar Salvador <osalvador@suse.de>
Date: Fri, 23 Nov 2018 14:07:19 +0100
In-Reply-To: <20181123123740.27652-1-david@redhat.com>
References: <20181123123740.27652-1-david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Fri, 2018-11-23 at 13:37 +0100, David Hildenbrand wrote:
> Signed-off-by: David Hildenbrand <david@redhat.com>

Thanks ;-)

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3
