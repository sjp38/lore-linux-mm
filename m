Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id A39256B026F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 08:35:19 -0400 (EDT)
Received: by wikq8 with SMTP id q8so3636339wik.1
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 05:35:19 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bw2si40833418wjc.127.2015.10.19.05.35.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 05:35:18 -0700 (PDT)
Date: Mon, 19 Oct 2015 08:35:08 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/12] mm: rename mem_cgroup_migrate to
 mem_cgroup_replace_page
Message-ID: <20151019123508.GA26353@cmpxchg.org>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
 <alpine.LSU.2.11.1510182152560.2481@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1510182152560.2481@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

On Sun, Oct 18, 2015 at 09:54:26PM -0700, Hugh Dickins wrote:
> After v4.3's commit 0610c25daa3e ("memcg: fix dirty page migration")
> mem_cgroup_migrate() doesn't have much to offer in page migration:
> convert migrate_misplaced_transhuge_page() to set_page_memcg() instead.
> 
> Then rename mem_cgroup_migrate() to mem_cgroup_replace_page(), since its
> remaining callers are replace_page_cache_page() and shmem_replace_page():
> both of whom passed lrucare true, so just eliminate that argument.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
