Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2E6C26B006E
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 10:25:44 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id q59so2391595wes.10
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 07:25:43 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cr7si6982704wjc.35.2015.01.22.07.25.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 07:25:42 -0800 (PST)
Date: Thu, 22 Jan 2015 10:25:35 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: uninitialized "ret" variables
Message-ID: <20150122152535.GB27368@phnom.home.cmpxchg.org>
References: <20150122133044.GA23668@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150122133044.GA23668@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

Hi Dan,

On Thu, Jan 22, 2015 at 04:30:44PM +0300, Dan Carpenter wrote:
> We recently re-arranged the code in these functions and now static
> checkers complain that "ret" is uninitialized.  Oddly enough GCC is fine
> with this code.
> 
> Fixes: d1ebc463cf89 ('mm: page_counter: pull "-1" handling out of page_counter_memparse()')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

This code was again re-arranged in -mm, and that

  ret = page_counter_memparse()

is now happening unconditionally, so I think it should be fine.  The
latest mmots snapshot (mmots-2015-01-21-16-38) has it.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
