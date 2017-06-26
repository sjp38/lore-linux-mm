Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BE19F6B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 11:27:37 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c81so711382wmd.10
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:27:37 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j63si245665edb.381.2017.06.26.08.27.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 26 Jun 2017 08:27:36 -0700 (PDT)
Date: Mon, 26 Jun 2017 11:27:28 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: document highmem_is_dirtyable sysctl
Message-ID: <20170626152728.GA13340@cmpxchg.org>
References: <20170626093200.18958-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170626093200.18958-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Alkis Georgopoulos <alkisg@gmail.com>, Michal Hocko <mhocko@suse.com>

On Mon, Jun 26, 2017 at 11:32:00AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> It seems that there are still people using 32b kernels which a lot of
> memory and the IO tend to suck a lot for them by default. Mostly because
> writers are throttled too when the lowmem is used. We have
> highmem_is_dirtyable to work around that issue but it seems we never
> bothered to document it. Let's do it now, finally.
> 
> Cc: Alkis Georgopoulos <alkisg@gmail.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
