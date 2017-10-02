Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6CC736B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 13:20:41 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id r13so1488223lfe.19
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 10:20:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n37sor3425340wrf.22.2017.10.02.10.20.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Oct 2017 10:20:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171002075616.mro36ci7gk5k6vbc@dhcp22.suse.cz>
References: <20170927221311.23263-1-tahsin@google.com> <20171002075616.mro36ci7gk5k6vbc@dhcp22.suse.cz>
From: Tahsin Erdogan <tahsin@google.com>
Date: Mon, 2 Oct 2017 10:20:37 -0700
Message-ID: <CAAeU0aPZ8BGSyrQeua=tUfme38frM-GxtmHrirveS0XdcnzWww@mail.gmail.com>
Subject: Re: [PATCH] writeback: remove unused parameter from balance_dirty_pages()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jeff Layton <jlayton@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Theodore Ts'o <tytso@mit.edu>, Nikolay Borisov <nborisov@suse.com>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>

On Mon, Oct 2, 2017 at 12:56 AM, Michal Hocko <mhocko@kernel.org> wrote:
> balance_dirty_pages_ratelimited doesn't really need mapping as well. All
> it needs is the inode and we already have it in callers. So would it
> make sense to refactor a bit further and make its argument an inode?

My only concern is that, balance_dirty_pages_ratelimited() is an
exported function so changing its signature could potentially break
some drivers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
