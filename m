Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 99C5C6B0038
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 10:30:52 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id yr2so617077wjc.4
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 07:30:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l66si11616098wrc.30.2017.01.13.07.30.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 07:30:51 -0800 (PST)
Subject: Re: [PATCH 4/4] lib/show_mem.c: teach show_mem to work with the given
 nodemask
References: <20170112131659.23058-1-mhocko@kernel.org>
 <20170112131659.23058-5-mhocko@kernel.org>
 <13903870-92bd-1ea2-aefc-0481c850da19@suse.cz>
 <20170113150834.GN25212@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <cfd77cec-bf73-5dc8-fdc3-77e50f2d8b3d@suse.cz>
Date: Fri, 13 Jan 2017 16:30:49 +0100
MIME-Version: 1.0
In-Reply-To: <20170113150834.GN25212@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

On 01/13/2017 04:08 PM, Michal Hocko wrote:
> I guess it should be sufficient to add cpuset_print_current_mems_allowed()
> in warn_alloc. This should give us the full picture without doing too
> much twiddling. What do you think?

Agree!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
