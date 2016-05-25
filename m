Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5D41F6B026E
	for <linux-mm@kvack.org>; Wed, 25 May 2016 17:49:40 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id n2so35129510wma.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 14:49:40 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id p10si13892462wjp.70.2016.05.25.14.49.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 14:49:39 -0700 (PDT)
Date: Wed, 25 May 2016 22:49:35 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v9] fs: clear file privilege bits when mmap writing
Message-ID: <20160525214935.GI14480@ZenIV.linux.org.uk>
References: <20160114212201.GA28910@www.outflux.net>
 <CALYGNiNN+QYpd-FhM+4WXd=-1UYrhR7kpefbN8mpjh4gSbDO4A@mail.gmail.com>
 <CAGXu5j+cwZQfnSPQNjb=VVzZfJH8n=iZUCM+vz_a6nPku5tQ2g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5j+cwZQfnSPQNjb=VVzZfJH8n=iZUCM+vz_a6nPku5tQ2g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Andy Lutomirski <luto@amacapital.net>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, Willy Tarreau <w@1wt.eu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, May 25, 2016 at 02:36:57PM -0700, Kees Cook wrote:

> Hm, this didn't end up getting picked up. (This jumped out at me again
> because i_mutex just vanished...)
> 
> Al, what's the right way to update the locking in this patch?

->i_mutex is dealt with just by using lock_inode(inode)/unlock_inode(inode);
I hadn't looked at the rest of the locking in there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
