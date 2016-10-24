Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D185D6B0274
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:56:57 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c78so36970116wme.4
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:56:57 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 186si13706597wmz.89.2016.10.24.11.56.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 11:56:56 -0700 (PDT)
Date: Mon, 24 Oct 2016 14:56:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Stable 4.4 - NEEDS REVIEW - 3/3] mm: filemap: fix
 mapping->nrpages double accounting in fuse
Message-ID: <20161024185650.GC28326@cmpxchg.org>
References: <20161024152605.11707-1-mhocko@kernel.org>
 <20161024152605.11707-4-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161024152605.11707-4-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Stable tree <stable@vger.kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

This one looks good to me.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
