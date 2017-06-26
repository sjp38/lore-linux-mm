Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 08AD66B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 03:46:40 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 77so26328wmm.13
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 00:46:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 101si12391604wrc.396.2017.06.26.00.46.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 00:46:38 -0700 (PDT)
Date: Mon, 26 Jun 2017 09:46:35 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC PATCH 0/4] mm/hotplug: make hotplug memory_block alligned
Message-ID: <20170626074635.GB11534@dhcp22.suse.cz>
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170625025227.45665-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org

On Sun 25-06-17 10:52:23, Wei Yang wrote:
> Michal & all
> 
> Previously we found the hotplug range is mem_section aligned instead of
> memory_block.
> 
> Here is several draft patches to fix that. To make sure I am getting your
> point correctly, I post it here before further investigation.

This description doesn't explain what the problem is and why do we want
to fix it. Before diving into the code and review changes it would help
a lot to give a short introduction and explain your intention and your
assumptions you base your changes on.

So please start with a highlevel description first.

> Willing to see your comments. :-)
> 
> Wei Yang (4):
>   mm/hotplug: aligne the hotplugable range with memory_block
>   mm/hotplug: walk_memroy_range on memory_block uit
>   mm/hotplug: make __add_pages() iterate on memory_block and split
>     __add_section()
>   base/memory: pass start_section_nr to init_memory_block()
> 
>  drivers/base/memory.c  | 34 ++++++++++++----------------------
>  include/linux/memory.h |  4 +++-
>  mm/memory_hotplug.c    | 48 +++++++++++++++++++++++++-----------------------
>  3 files changed, 40 insertions(+), 46 deletions(-)
> 
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
