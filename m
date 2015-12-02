Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id D8EED6B0257
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 11:57:50 -0500 (EST)
Received: by wmec201 with SMTP id c201so262980975wme.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 08:57:50 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s191si444850wmb.97.2015.12.02.08.57.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 08:57:49 -0800 (PST)
Date: Wed, 2 Dec 2015 11:57:42 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: fix kerneldoc on mem_cgroup_replace_page
Message-ID: <20151202165742.GA23344@cmpxchg.org>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
 <alpine.LSU.2.11.1510182152560.2481@eggly.anvils>
 <alpine.LSU.2.11.1512020130410.32078@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1512020130410.32078@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

On Wed, Dec 02, 2015 at 01:33:03AM -0800, Hugh Dickins wrote:
> Whoops, I missed removing the kerneldoc comment of the lrucare arg
> removed from mem_cgroup_replace_page; but it's a good comment, keep it.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Thanks!

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
