Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA1D6B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 15:54:46 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p46so4642376wrb.1
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 12:54:46 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id r5si1812983edh.46.2017.10.02.12.54.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 02 Oct 2017 12:54:44 -0700 (PDT)
Date: Mon, 2 Oct 2017 15:54:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] writeback: remove unused parameter from
 balance_dirty_pages()
Message-ID: <20171002195425.GA18075@cmpxchg.org>
References: <20170927221311.23263-1-tahsin@google.com>
 <20171002075616.mro36ci7gk5k6vbc@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171002075616.mro36ci7gk5k6vbc@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tahsin Erdogan <tahsin@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jeff Layton <jlayton@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Theodore Ts'o <tytso@mit.edu>, Nikolay Borisov <nborisov@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 02, 2017 at 09:56:16AM +0200, Michal Hocko wrote:
> On Wed 27-09-17 15:13:11, Tahsin Erdogan wrote:
> > "mapping" parameter to balance_dirty_pages() is not used anymore.
> > 
> > Fixes: dfb8ae567835 ("writeback: let balance_dirty_pages() work on the matching cgroup bdi_writeback")
> 
> balance_dirty_pages_ratelimited doesn't really need mapping as well. All
> it needs is the inode and we already have it in callers. So would it
> make sense to refactor a bit further and make its argument an inode?

It's nicer to keep this a "page cache" interface, as its primary
callsites are in mm/memory.c and mm/filemap.c:

	$ git grep -c 'inode' mm/filemap.c mm/memory.c 
	mm/filemap.c:38
	$ git grep -c 'mapping' mm/filemap.c mm/memory.c 
	mm/filemap.c:260
	mm/memory.c:93

> > Signed-off-by: Tahsin Erdogan <tahsin@google.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
