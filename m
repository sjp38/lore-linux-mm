Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5DFF86B000A
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 09:02:01 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r21-v6so1706585edp.23
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 06:02:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b24-v6si765027edj.131.2018.08.03.06.01.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 06:01:59 -0700 (PDT)
Subject: Re: [PATCH v6 4/5] mm/page_alloc: Inline function to handle
 CONFIG_DEFERRED_STRUCT_PAGE_INIT
References: <20180801122348.21588-1-osalvador@techadventures.net>
 <20180801122348.21588-5-osalvador@techadventures.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9af245b8-bf2d-4d32-053d-22d8596101b3@suse.cz>
Date: Fri, 3 Aug 2018 15:01:57 +0200
MIME-Version: 1.0
In-Reply-To: <20180801122348.21588-5-osalvador@techadventures.net>
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
> Let us move the code between CONFIG_DEFERRED_STRUCT_PAGE_INIT
> to an inline function.
> Not having an ifdef in the function makes the code more readable.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
