Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 575A86B036F
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 18:19:49 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i131so1055342wmf.3
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 15:19:49 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id hn4si390193wjb.133.2016.11.17.15.19.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 15:19:48 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id g23so558308wme.1
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 15:19:48 -0800 (PST)
Date: Fri, 18 Nov 2016 02:19:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/9] mm: khugepaged: close use-after-free race during
 shmem collapsing
Message-ID: <20161117231945.GA8358@node>
References: <20161117191138.22769-1-hannes@cmpxchg.org>
 <20161117191138.22769-2-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161117191138.22769-2-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Nov 17, 2016 at 02:11:30PM -0500, Johannes Weiner wrote:
> When a radix tree iteration drops the tree lock, another thread might
> swoop in and free the node holding the current slot. The iteration
> needs to do another tree lookup from the current index to continue.
> 
> [kirill.shutemov@linux.intel.com: re-lookup for replacement]
> Fixes: f3f0e1d2150b ("khugepaged: add support of collapse for tmpfs/shmem pages")
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
