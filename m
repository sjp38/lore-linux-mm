Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 70F646B000A
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 11:17:50 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id w126-v6so1579027qka.11
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:17:50 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id a1-v6si1456962qvh.212.2018.07.26.08.17.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 08:17:49 -0700 (PDT)
Date: Thu, 26 Jul 2018 11:17:42 -0400
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: Re: [PATCH v3 3/5] mm/page_alloc: Inline function to handle
 CONFIG_DEFERRED_STRUCT_PAGE_INIT
Message-ID: <20180726151742.ebjghfe27n7eoxq6@xakep.localdomain>
References: <20180725220144.11531-1-osalvador@techadventures.net>
 <20180725220144.11531-4-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180725220144.11531-4-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, Oscar Salvador <osalvador@suse.de>

On 18-07-26 00:01:42, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> Let us move the code between CONFIG_DEFERRED_STRUCT_PAGE_INIT
> to an inline function.
> Not having an ifdef in the function makes the code more readable.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Acked-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
