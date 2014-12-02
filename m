Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4879A6B0069
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 10:18:36 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id bs8so30114903wib.1
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 07:18:35 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h10si36622843wiv.42.2014.12.02.07.18.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Dec 2014 07:18:35 -0800 (PST)
Date: Tue, 2 Dec 2014 10:18:29 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/3] mm: memory: remove ->vm_file check on shared
 writable vmas
Message-ID: <20141202151829.GC8401@phnom.home.cmpxchg.org>
References: <1417474682-29326-1-git-send-email-hannes@cmpxchg.org>
 <1417474682-29326-2-git-send-email-hannes@cmpxchg.org>
 <20141202085825.GA9092@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141202085825.GA9092@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Dec 02, 2014 at 09:58:25AM +0100, Jan Kara wrote:
> On Mon 01-12-14 17:58:01, Johannes Weiner wrote:
> > The only way a VMA can have shared and writable semantics is with a
> > backing file.
>   OK, one always learns :) After some digging I found that MAP_SHARED |
> MAP_ANONYMOUS mappings are in fact mappings of a temporary file in tmpfs.
> It would be worth to mention this in the changelog I believe. Otherwise
> feel free to add:
>   Reviewed-by: Jan Kara <jack@suse.cz>

Thanks, Jan.  I updated the changelog to read:

Shared anonymous mmaps are implemented with shmem files, so all VMAs
with shared writable semantics also have an underlying backing file.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
