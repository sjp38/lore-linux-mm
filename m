Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C3226B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 04:16:03 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id v14so12126373wmd.3
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 01:16:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6si12193918wrp.295.2018.01.30.01.16.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 01:16:02 -0800 (PST)
Date: Tue, 30 Jan 2018 10:16:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory hotplug not increasing the total RAM
Message-ID: <20180130091600.GA26445@dhcp22.suse.cz>
References: <20180130083006.GB1245@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130083006.GB1245@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bharata B Rao <bharata@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, pasha.tatashin@oracle.com

On Tue 30-01-18 14:00:06, Bharata B Rao wrote:
> Hi,
> 
> With the latest upstream, I see that memory hotplug is not working
> as expected. The hotplugged memory isn't seen to increase the total
> RAM pages. This has been observed with both x86 and Power guests.
> 
> 1. Memory hotplug code intially marks pages as PageReserved via
> __add_section().
> 2. Later the struct page gets cleared in __init_single_page().
> 3. Next online_pages_range() increments totalram_pages only when
>    PageReserved is set.

You are right. I have completely forgot about this late struct page
initialization during onlining. memory hotplug really doesn't want
zeroying. Let me think about a fix.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
