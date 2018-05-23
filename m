Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E22C46B0006
	for <linux-mm@kvack.org>; Wed, 23 May 2018 04:16:13 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id x32-v6so13713482pld.16
        for <linux-mm@kvack.org>; Wed, 23 May 2018 01:16:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u6-v6si18515239pls.462.2018.05.23.01.16.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 May 2018 01:16:12 -0700 (PDT)
Date: Wed, 23 May 2018 10:16:09 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC] Checking for error code in __offline_pages
Message-ID: <20180523081609.GG20441@dhcp22.suse.cz>
References: <20180523073547.GA29266@techadventures.net>
 <20180523075239.GF20441@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523075239.GF20441@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: linux-mm@kvack.org, vbabka@suse.cz, pasha.tatashin@oracle.com, akpm@linux-foundation.org

On Wed 23-05-18 09:52:39, Michal Hocko wrote:
[...]
> Yeah, the current code is far from optimal. We
> used to have a retry count but that one was removed exactly because of
> premature failures. There are three things here
> 1) zone_movable should contain any bootmem or otherwise non-migrateable
>    pages
> 2) start_isolate_page_range should fail when seeing such pages - maybe
>    has_unmovable_pages is overly optimistic and it should check all
>    pages even in movable zones.
> 3) migrate_pages should really tell us whether the failure is temporal
>    or permanent. I am not sure we can do that easily though.

2) should be the most simple one for now. Could you give it a try? Btw.
the exact configuration that led to boothmem pages in zone_movable would
be really appreciated:
--- 
