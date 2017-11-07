Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 27BE06B029B
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 04:18:49 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id f31so3607560lfi.3
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 01:18:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j7sor143294lfk.70.2017.11.07.01.18.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Nov 2017 01:18:47 -0800 (PST)
Date: Tue, 7 Nov 2017 12:18:44 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 2/3] mm: memcontrol: implement lruvec stat functions on
 top of each other
Message-ID: <20171107091844.qiz5lvmdykbinwqx@esperanza>
References: <20171103153336.24044-1-hannes@cmpxchg.org>
 <20171103153336.24044-2-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171103153336.24044-2-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Fri, Nov 03, 2017 at 11:33:35AM -0400, Johannes Weiner wrote:
> The implementation of the lruvec stat functions and their variants for
> accounting through a page, or accounting from a preemptible context,
> are mostly identical and needlessly repetitive.
> 
> Implement the lruvec_page functions by looking up the page's lruvec
> and then using the lruvec function.
> 
> Implement the functions for preemptible contexts by disabling
> preemption before calling the atomic context functions.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h | 44 ++++++++++++++++++++++----------------------
>  1 file changed, 22 insertions(+), 22 deletions(-)

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
