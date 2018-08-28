Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E4B7F6B488E
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 19:01:53 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r20-v6so2037866pgv.20
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 16:01:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 7-v6si2077834pgq.637.2018.08.28.16.01.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 16:01:52 -0700 (PDT)
Date: Tue, 28 Aug 2018 16:01:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] fs/dcache: Make negative dentries easier to be
 reclaimed
Message-Id: <20180828160150.9a45ee293c92708edb511eab@linux-foundation.org>
In-Reply-To: <1535476780-5773-3-git-send-email-longman@redhat.com>
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
	<1535476780-5773-3-git-send-email-longman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>


Another pet peeve ;)

On Tue, 28 Aug 2018 13:19:40 -0400 Waiman Long <longman@redhat.com> wrote:

>  /**
> + * list_lru_add_head: add an element to the lru list's head
> + * @list_lru: the lru pointer
> + * @item: the item to be added.
> + *
> + * This is similar to list_lru_add(). The only difference is the location
> + * where the new item will be added. The list_lru_add() function will add

People often use the term "the foo() function".  I don't know why -
just say "foo()"!

> + * the new item to the tail as it is the most recently used one. The
> + * list_lru_add_head() will add the new item into the head so that it

Ditto.

"to the head"

> + * will the first to go if a shrinker is running. So this function should

"will be the"

> + * only be used for less important item that can be the first to go if

"items"

> + * the system is under memory pressure.
> + *
> + * Return value: true if the list was updated, false otherwise
> + */
