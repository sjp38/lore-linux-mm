Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 64DC96B000D
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 08:20:09 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r21-v6so1674891edp.23
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 05:20:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b24-v6si688003edj.131.2018.08.03.05.20.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 05:20:08 -0700 (PDT)
Subject: Re: [PATCH v6 2/5] mm: access zone->node via zone_to_nid() and
 zone_set_nid()
References: <20180801122348.21588-1-osalvador@techadventures.net>
 <20180801122348.21588-3-osalvador@techadventures.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d25e0b69-db84-5c64-bf26-e4e429e5f510@suse.cz>
Date: Fri, 3 Aug 2018 14:20:06 +0200
MIME-Version: 1.0
In-Reply-To: <20180801122348.21588-3-osalvador@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net, akpm@linux-foundation.org
Cc: mhocko@suse.com, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, david@redhat.com, Oscar Salvador <osalvador@suse.de>

On 08/01/2018 02:23 PM, osalvador@techadventures.net wrote:
> From: Pavel Tatashin <pasha.tatashin@oracle.com>
> 
> zone->node is configured only when CONFIG_NUMA=y, so it is a good idea to
> have inline functions to access this field in order to avoid ifdef's in
> c files.

Agreed.

> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
