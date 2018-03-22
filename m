Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 75A8B6B000D
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 03:09:48 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s6so3707944pgn.3
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 00:09:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o12si3974712pgc.381.2018.03.22.00.09.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Mar 2018 00:09:47 -0700 (PDT)
Date: Thu, 22 Mar 2018 08:09:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] fs: use memalloc_nofs API while shrinking superblock
Message-ID: <20180322070943.GV23100@dhcp22.suse.cz>
References: <20180321224429.15860-1-rgoldwyn@suse.de>
 <20180321224429.15860-3-rgoldwyn@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180321224429.15860-3-rgoldwyn@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, david@fromorbit.com, Goldwyn Rodrigues <rgoldwyn@suse.com>

On Wed 21-03-18 17:44:28, Goldwyn Rodrigues wrote:
> From: Goldwyn Rodrigues <rgoldwyn@suse.com>
> 
> The superblock shrinkers are responsible for pruning dcache and icache.
> which evicts the inode by calling into local filesystem code. Protect
> allocations under memalloc_nofs_save/restore().

This is just wrong. PF_MEMALLOC_NOFS implies GFP_NOFS. Have a look at
current_gfp_context. Shrinkers really do not and should not care about
it.
-- 
Michal Hocko
SUSE Labs
