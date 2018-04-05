Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE1D6B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 02:10:19 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u5so4662231wrc.23
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 23:10:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q11si5220197wra.428.2018.04.04.23.10.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Apr 2018 23:10:17 -0700 (PDT)
Date: Thu, 5 Apr 2018 08:10:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1 v2] vmscan: Support multiple kswapd threads per
 node
Message-ID: <20180405061015.GU6312@dhcp22.suse.cz>
References: <1522878594-52281-1-git-send-email-buddy.lumpkin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522878594-52281-1-git-send-email-buddy.lumpkin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Buddy Lumpkin <buddy.lumpkin@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, riel@surriel.com, mgorman@suse.de, willy@infradead.org, akpm@linux-foundation.org

On Wed 04-04-18 21:49:54, Buddy Lumpkin wrote:
> v2:
> - Make update_kswapd_threads_node less racy
> - Handle locking for case where CONFIG_MEMORY_HOTPLUG=n

Please do not repost with such a small changes. It is much more
important to sort out the big picture first and only then deal with
minor implementation details. The more versions you post the more
fragmented and messy the discussion will become.

You will have to be patient because this is a rather big change and it
will take _quite_ some time to get sorted.

Thanks!
-- 
Michal Hocko
SUSE Labs
