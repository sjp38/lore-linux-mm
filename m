Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id DBF2A6B3053
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:58:22 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id u32so8757931qte.1
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 04:58:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h7si5549547qkb.218.2018.11.23.04.58.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 04:58:22 -0800 (PST)
Subject: Re: [PATCH v1] mm/memory_hotplug: drop "online" parameter from
 add_memory_resource()
References: <20181123123740.27652-1-david@redhat.com>
 <20181123125400.GL8625@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <a97fcf28-ef71-2b49-c25c-bc96cff8366b@redhat.com>
Date: Fri, 23 Nov 2018 13:58:16 +0100
MIME-Version: 1.0
In-Reply-To: <20181123125400.GL8625@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On 23.11.18 13:54, Michal Hocko wrote:
> On Fri 23-11-18 13:37:40, David Hildenbrand wrote:
>> User space should always be in charge of how to online memory and
>> if memory should be onlined automatically in the kernel. Let's drop the
>> parameter to overwrite this - XEN passes memhp_auto_online, just like
>> add_memory(), so we can directly use that instead internally.
> 
> Heh, I wanted to get rid of memhp_auto_online so much and now we have it
> in the core memory_hotplug. Not a win on my side I would say :/

That is actually a good point: Can we remove memhp_auto_online or is it
already some sort of kernel ABI?

(as it is exported via /sys/devices/system/memory/auto_online_blocks)

> On the other hand this can be seen as a cleanup because it removes that
> ambiguity that some callers might be unaware of the memhp_auto_online
> leading to a different behavior.

I would say this patch is a step into the right direction - remove the
flag from the interfaces, then drop it (eventually, as stated not sure
if that train has left the station).

> 
>> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
>> Cc: Juergen Gross <jgross@suse.com>
>> Cc: Stefano Stabellini <sstabellini@kernel.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Dan Williams <dan.j.williams@intel.com>
>> Cc: Oscar Salvador <osalvador@suse.de>
>> Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: David Hildenbrand <david@redhat.com>
>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Cc: Arun KS <arunks@codeaurora.org>
>> Cc: Mathieu Malaterre <malat@debian.org>
>> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 


-- 

Thanks,

David / dhildenb
