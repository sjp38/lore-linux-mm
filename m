Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0682D8E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 14:11:37 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id s22so15768551pgv.8
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 11:11:36 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 38si33085015pln.313.2018.12.26.11.11.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 26 Dec 2018 11:11:35 -0800 (PST)
Date: Wed, 26 Dec 2018 11:11:18 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: compaction.c: Propagate return value upstream
Message-ID: <20181226191118.GB20878@bombadil.infradead.org>
References: <20181226190750.9820-1-pakki001@umn.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181226190750.9820-1-pakki001@umn.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aditya Pakki <pakki001@umn.edu>
Cc: kjlu@umn.edu, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Yang Shi <yang.shi@linux.alibaba.com>, Johannes Weiner <hannes@cmpxchg.org>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 26, 2018 at 01:07:49PM -0600, Aditya Pakki wrote:
>  {
> +	return
>  	proc_dointvec_minmax(table, write, buffer, length, ppos);
> -
> -	return 0;

Don't do this.  If you're going to return something, it should be on the same
line as the return statement.

ie:

+	return proc_dointvec_minmax(table, write, buffer, length, ppos);
