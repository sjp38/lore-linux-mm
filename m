Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4B96B6DEA
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 04:11:17 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id v4so7712887edm.18
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 01:11:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x1-v6sor4207952ejf.13.2018.12.04.01.11.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 01:11:15 -0800 (PST)
Date: Tue, 4 Dec 2018 09:11:14 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, page_alloc: fix calculation of pgdat->nr_zones
Message-ID: <20181204091114.cqzepljxxrulju4v@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181117022022.9956-1-richard.weiyang@gmail.com>
 <20181119094832.GC22247@dhcp22.suse.cz>
 <20181119133851.GM22247@dhcp22.suse.cz>
 <20181204090500.GR235790@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204090500.GR235790@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, dave.hansen@intel.com, linux-mm@kvack.org

On Tue, Dec 04, 2018 at 04:05:04AM -0500, Sasha Levin wrote:
>On Mon, Nov 19, 2018 at 02:38:51PM +0100, Michal Hocko wrote:
>> Forgot to mention that this should probably go to stable. Having an
>> incorrect nr_zones might result in all sorts of problems which would be
>> quite hard to debug (e.g. reclaim not considering the movable zone).
>> I do not expect many users would suffer from this it but still this is
>> trivial and obviously right thing to do so backporting to the stable
>> tree shouldn't be harmful (last famous words).
>> 
>> Cc: stable # since 4.13
>> 
>> older tress would have to be checked explicitly.
>
>While the final commit included Michal's response, it didn't have a
>stable tag. Could someone confirm it should go in stable?
>

I think Michal wants it into stable.

>--
>Thanks,
>Sasha

-- 
Wei Yang
Help you, Help me
