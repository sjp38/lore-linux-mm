Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1586B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 07:34:03 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id b9so3755225wra.1
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 04:34:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v106si6896470wrc.184.2018.01.30.04.34.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 04:34:02 -0800 (PST)
Date: Tue, 30 Jan 2018 13:34:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/swap.c: make functions and their kernel-doc agree
Message-ID: <20180130123400.GD26445@dhcp22.suse.cz>
References: <3b42ee3e-04a9-a6ca-6be4-f00752a114fe@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3b42ee3e-04a9-a6ca-6be4-f00752a114fe@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>

On Mon 29-01-18 16:43:55, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix some basic kernel-doc notation in mm/swap.c:
> - for function lru_cache_add_anon(), make its kernel-doc function name
>   match its function name and change colon to hyphen following the
>   function name

This is pretty much an internal function to the MM. It shouldn't have
any external callers. Why do we need a kernel doc at all?

> - for function pagevec_lookup_entries(), change the function parameter
>   name from nr_pages to nr_entries since that is more descriptive of
>   what the parameter actually is and then it matches the kernel-doc
>   comments also

I know what is nr_pages because I do expect pages to be returned. What
are entries? Can it be something different from pages?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
