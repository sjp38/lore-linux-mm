Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 821A76B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 14:02:41 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i124so2398218wmf.7
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 11:02:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5si9131747wrg.483.2017.10.02.11.02.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Oct 2017 11:02:39 -0700 (PDT)
Date: Mon, 2 Oct 2017 20:02:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] writeback: remove unused parameter from
 balance_dirty_pages()
Message-ID: <20171002180237.y4vyoqp6eik7vwld@dhcp22.suse.cz>
References: <20170927221311.23263-1-tahsin@google.com>
 <20171002075616.mro36ci7gk5k6vbc@dhcp22.suse.cz>
 <CAAeU0aPZ8BGSyrQeua=tUfme38frM-GxtmHrirveS0XdcnzWww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeU0aPZ8BGSyrQeua=tUfme38frM-GxtmHrirveS0XdcnzWww@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tahsin Erdogan <tahsin@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jeff Layton <jlayton@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Theodore Ts'o <tytso@mit.edu>, Nikolay Borisov <nborisov@suse.com>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>

On Mon 02-10-17 10:20:37, Tahsin Erdogan wrote:
> On Mon, Oct 2, 2017 at 12:56 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > balance_dirty_pages_ratelimited doesn't really need mapping as well. All
> > it needs is the inode and we already have it in callers. So would it
> > make sense to refactor a bit further and make its argument an inode?
> 
> My only concern is that, balance_dirty_pages_ratelimited() is an
> exported function so changing its signature could potentially break
> some drivers?

All in-kernel drivers would have to be updated of course but exported
symbols are not considered a stable API. It's not like we would want to
change this for no good reason so the change should be done only if
this makes sense in general. This is something for IO/FS guys to tell.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
