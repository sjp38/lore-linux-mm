Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C01C86B0941
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 06:19:58 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 4so2682780plc.5
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 03:19:58 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a59-v6si28086142plc.48.2018.11.16.03.19.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 03:19:57 -0800 (PST)
Date: Fri, 16 Nov 2018 12:19:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/5] mm, memory_hotplug: drop pointless block alignment
 checks from __offline_pages
Message-ID: <20181116111954.GG14706@dhcp22.suse.cz>
References: <20181116083020.20260-1-mhocko@kernel.org>
 <20181116083020.20260-4-mhocko@kernel.org>
 <1542364443.3020.3.camel@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542364443.3020.3.camel@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador <osalvador@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 16-11-18 11:34:03, Oscar Salvador wrote:
> On Fri, 2018-11-16 at 09:30 +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > This function is never called from a context which would provide
> > misaligned pfn range so drop the pointless check.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> I vaguely remember that someone reported a problem about misaligned
> range on powerpc.
> Not sure at which stage was (online/offline).
> Although I am not sure if that was valid at all.

If we are talking about the same thing then this was about partial
memblock initialized (aka struct pages were not initialized).

> Reviewed-by: Oscar Salvador <osalvador@suse.de>

Thanks!

-- 
Michal Hocko
SUSE Labs
