Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6C97B6B000D
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 03:08:13 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id az5-v6so4746743plb.14
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 00:08:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z3-v6si734873plb.114.2018.03.22.00.08.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Mar 2018 00:08:12 -0700 (PDT)
Date: Thu, 22 Mar 2018 08:08:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] fs: Perform writebacks under memalloc_nofs
Message-ID: <20180322070808.GU23100@dhcp22.suse.cz>
References: <20180321224429.15860-1-rgoldwyn@suse.de>
 <20180321224429.15860-2-rgoldwyn@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180321224429.15860-2-rgoldwyn@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, david@fromorbit.com, Goldwyn Rodrigues <rgoldwyn@suse.com>

On Wed 21-03-18 17:44:27, Goldwyn Rodrigues wrote:
> From: Goldwyn Rodrigues <rgoldwyn@suse.com>
> 
> writebacks can recurse into itself under low memory situations.
> Set memalloc_nofs_save() in order to make sure it does not
> recurse.

How? We are not doing writeback from the direct reclaim context.
-- 
Michal Hocko
SUSE Labs
