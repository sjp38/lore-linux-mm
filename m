Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id C436C6B0253
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 07:01:55 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so97313262wic.1
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 04:01:55 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id t10si26599354wiv.82.2015.08.18.04.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 04:01:54 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so104923002wic.1
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 04:01:53 -0700 (PDT)
Date: Tue, 18 Aug 2015 13:01:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC -v2 7/8] btrfs: Prevent from early transaction abort
Message-ID: <20150818110151.GI5033@dhcp22.suse.cz>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
 <1438768284-30927-8-git-send-email-mhocko@kernel.org>
 <20150818104031.GF5033@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150818104031.GF5033@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, Jan Kara <jack@suse.cz>

On Tue 18-08-15 12:40:31, Michal Hocko wrote:
[...]
> @@ -4867,9 +4865,7 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
>  		return NULL;
>  
>  	for (i = 0; i < num_pages; i++, index++) {
> -		p = find_or_create_page(mapping, index, GFP_NOFS);
> -		if (!p)
> -			goto free_eb;
> +		p = find_or_create_page(mapping, index, GFP_NOFS|__GFP_NOFAIL);
>  
>  		spin_lock(&mapping->private_lock);
>  		if (PagePrivate(p)) {

Same here. find_or_create_page might return NULL.
---
