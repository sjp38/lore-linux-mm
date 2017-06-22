Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 32FDC6B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 02:50:53 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z1so1941746wrz.10
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 23:50:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i96si555265wri.344.2017.06.21.23.50.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 23:50:52 -0700 (PDT)
Date: Thu, 22 Jun 2017 08:50:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm/memory_hotplug: remove duplicate call for
 set_page_links
Message-ID: <20170622065050.GB14308@dhcp22.suse.cz>
References: <20170616092335.5177-1-richard.weiyang@gmail.com>
 <20170616092335.5177-2-richard.weiyang@gmail.com>
 <20170616103350.e065a9838bb50c2dc70a41d8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170616103350.e065a9838bb50c2dc70a41d8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org

On Fri 16-06-17 10:33:50, Andrew Morton wrote:
> On Fri, 16 Jun 2017 17:23:35 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:
> 
> > In function move_pfn_range_to_zone(), memmap_init_zone() will call
> > set_page_links for each page.
> 
> Well, no.  There are several types of pfn's for which
> memmap_init_zone() will not call
> __init_single_page()->set_page_links().  Probably the code is OK, as
> those are pretty screwy pfn types.  But I'd like to see some
> confirmation that this patch is OK for all such pfns, now and in the
> future?

Yes it work properly for the hotplugable memory. If not then it is
memmap_init_zone to be fixed rather than duplicate the thig outside of
this function.

Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
