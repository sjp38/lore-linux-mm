Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 09DA46B0005
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 08:49:23 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id d10-v6so2386483pgv.8
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 05:49:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r7-v6si3270596pgn.326.2018.07.04.05.49.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 05:49:21 -0700 (PDT)
Date: Wed, 4 Jul 2018 14:49:19 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [memcg:akpm/pending-review/mm 42/55] mm/memcontrol.c:4416:3:
 error: implicit declaration of function 'mem_cgroup_id_remove'; did you mean
 'mem_cgroup_under_move'?
Message-ID: <20180704124919.GN22503@dhcp22.suse.cz>
References: <201807041949.qoclZxnX%fengguang.wu@intel.com>
 <20180704113001.GK22503@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180704113001.GK22503@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, kbuild-all@01.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed 04-07-18 13:30:01, Michal Hocko wrote:
> Please ignore this build error. I am playing with a new mm git tracking
> and the patch 0day pointed at is missing memcg-remove-memcg_cgroup-id-from-idr-on-mem_cgroup_css_alloc-failure.patch
> dependency because Andrew marked that one for review so it is in a
> different branch.

Should be fixed now.
-- 
Michal Hocko
SUSE Labs
