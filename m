Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6A16B000A
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 08:15:37 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g15-v6so1751905edm.11
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 05:15:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u42-v6si823564edm.404.2018.08.03.05.15.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 05:15:36 -0700 (PDT)
Subject: Re: [PATCH v6 1/5] mm/page_alloc: Move ifdefery out of
 free_area_init_core
References: <20180801122348.21588-1-osalvador@techadventures.net>
 <20180801122348.21588-2-osalvador@techadventures.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <34046682-9799-721f-32e2-9e808525da7d@suse.cz>
Date: Fri, 3 Aug 2018 14:15:33 +0200
MIME-Version: 1.0
In-Reply-To: <20180801122348.21588-2-osalvador@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net, akpm@linux-foundation.org
Cc: mhocko@suse.com, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, david@redhat.com, Oscar Salvador <osalvador@suse.de>

On 08/01/2018 02:23 PM, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> Moving the #ifdefs out of the function makes it easier to follow.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
