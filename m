Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4F86B0010
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 03:10:25 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l3so3362750wmc.3
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 00:10:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b5si2296474wrb.301.2018.03.22.00.10.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Mar 2018 00:10:23 -0700 (PDT)
Date: Thu, 22 Mar 2018 08:10:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] fs: Use memalloc_nofs_save in generic_perform_write
Message-ID: <20180322071022.GW23100@dhcp22.suse.cz>
References: <20180321224429.15860-1-rgoldwyn@suse.de>
 <20180321224429.15860-4-rgoldwyn@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180321224429.15860-4-rgoldwyn@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, david@fromorbit.com, Goldwyn Rodrigues <rgoldwyn@suse.com>

On Wed 21-03-18 17:44:29, Goldwyn Rodrigues wrote:
> From: Goldwyn Rodrigues <rgoldwyn@suse.com>
> 
> Perform generic_perform_write() under memalloc_nofs because any allocations
> should not recurse into fs writebacks.

Why? What is the deadlock scenario?
-- 
Michal Hocko
SUSE Labs
