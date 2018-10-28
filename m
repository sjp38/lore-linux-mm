Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB046B0349
	for <linux-mm@kvack.org>; Sun, 28 Oct 2018 06:23:50 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id t28-v6so4622171pfk.21
        for <linux-mm@kvack.org>; Sun, 28 Oct 2018 03:23:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 3-v6si17457195plp.173.2018.10.28.03.23.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 28 Oct 2018 03:23:48 -0700 (PDT)
Date: Sun, 28 Oct 2018 03:23:46 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: simplify get_next_ra_size
Message-ID: <20181028102346.GC25444@bombadil.infradead.org>
References: <1540707206-19649-1-git-send-email-hsiangkao@aol.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1540707206-19649-1-git-send-email-hsiangkao@aol.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gao Xiang <hsiangkao@aol.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>

On Sun, Oct 28, 2018 at 02:13:26PM +0800, Gao Xiang wrote:
> It's a trivial simplification for get_next_ra_size and
> clear enough for humans to understand.
> 
> It also fixes potential overflow if ra->size(< ra_pages) is too large.
> 
> Cc: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Gao Xiang <hsiangkao@aol.com>

Reviewed-by: Matthew Wilcox <willy@infradead.org>

I also considered what would happen with underflow (passing a 'max'
less than 16, or less than 2) and it would seem to do the right thing
in that case.
