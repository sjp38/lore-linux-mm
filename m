Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 358356B6DE1
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 04:05:09 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id o23so12124657pll.0
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 01:05:09 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d39si12195971pla.278.2018.12.04.01.05.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 01:05:08 -0800 (PST)
Date: Tue, 4 Dec 2018 04:05:04 -0500
From: Sasha Levin <sashal@kernel.org>
Subject: Re: [PATCH] mm, page_alloc: fix calculation of pgdat->nr_zones
Message-ID: <20181204090500.GR235790@sasha-vm>
References: <20181117022022.9956-1-richard.weiyang@gmail.com>
 <20181119094832.GC22247@dhcp22.suse.cz>
 <20181119133851.GM22247@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20181119133851.GM22247@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, dave.hansen@intel.com, linux-mm@kvack.org

On Mon, Nov 19, 2018 at 02:38:51PM +0100, Michal Hocko wrote:
>Forgot to mention that this should probably go to stable. Having an
>incorrect nr_zones might result in all sorts of problems which would be
>quite hard to debug (e.g. reclaim not considering the movable zone).
>I do not expect many users would suffer from this it but still this is
>trivial and obviously right thing to do so backporting to the stable
>tree shouldn't be harmful (last famous words).
>
>Cc: stable # since 4.13
>
>older tress would have to be checked explicitly.

While the final commit included Michal's response, it didn't have a
stable tag. Could someone confirm it should go in stable?

--
Thanks,
Sasha
