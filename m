Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BDD216B0371
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 18:21:37 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u144so1131643wmu.1
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 15:21:37 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id zl8si4952474wjb.48.2016.11.17.15.21.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 15:21:36 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id m203so535741wma.3
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 15:21:36 -0800 (PST)
Date: Fri, 18 Nov 2016 02:21:34 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/9] mm: khugepaged: fix radix tree node leak in shmem
 collapse error path
Message-ID: <20161117232134.GB8358@node>
References: <20161117191138.22769-1-hannes@cmpxchg.org>
 <20161117191138.22769-3-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161117191138.22769-3-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Nov 17, 2016 at 02:11:31PM -0500, Johannes Weiner wrote:
> The radix tree counts valid entries in each tree node. Entries stored
> in the tree cannot be removed by simpling storing NULL in the slot or
> the internal counters will be off and the node never gets freed again.
> 
> When collapsing a shmem page fails, restore the holes that were filled
> with radix_tree_insert() with a proper radix tree deletion.
> 
> Fixes: f3f0e1d2150b ("khugepaged: add support of collapse for tmpfs/shmem pages")
> Reported-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
