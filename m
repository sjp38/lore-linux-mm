Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id AFB8B6B4D91
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 16:34:35 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id b17-v6so4239454wrq.0
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 13:34:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h13-v6sor3610993wrv.32.2018.08.29.13.34.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Aug 2018 13:34:34 -0700 (PDT)
Date: Wed, 29 Aug 2018 22:34:32 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH] mm/page_alloc: Clean up check_for_memory
Message-ID: <20180829203432.GA24978@techadventures.net>
References: <20180828210158.4617-1-osalvador@techadventures.net>
 <20180828143530.4b681bf9e0b3c03519fbe943@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180828143530.4b681bf9e0b3c03519fbe943@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@suse.com, vbabka@suse.cz, Pavel.Tatashin@microsoft.com, sfr@canb.auug.org.au, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>, Lai Jiangshan <laijs@cn.fujitsu.com>

On Tue, Aug 28, 2018 at 02:35:30PM -0700, Andrew Morton wrote:
> > First, we should only set N_HIGH_MEMORY in case we have
> > CONFIG_HIGHMEM.
> 
> Why?  Just a teeny optimization?

Hi Andrew,

Optimization was not really my point here, my point was to make
the code less subtle and more clear.
One may wonder why we set N_HIGH_MEMORY unconditionally when
__only__ CONFIG_HIGHMEM matters for this case, and why we set 
N_NORMAL_MEMORY __only__ for CONFIG_HIGHMEM when we should not care
about that at all.

I do not really expect a big impact here, mainly because check_for_memory
is only being used during boot.

-- 
Oscar Salvador
SUSE L3
