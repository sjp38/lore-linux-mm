Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 584196B4DB1
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 17:04:11 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id t4-v6so2770781plo.0
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 14:04:11 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r8-v6si5091075pgs.144.2018.08.29.14.04.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 Aug 2018 14:04:10 -0700 (PDT)
Date: Wed, 29 Aug 2018 14:04:04 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] fs/dcache: Make negative dentries easier to be
 reclaimed
Message-ID: <20180829210404.GA2925@bombadil.infradead.org>
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
 <1535476780-5773-3-git-send-email-longman@redhat.com>
 <20180828160150.9a45ee293c92708edb511eab@linux-foundation.org>
 <20180829175405.GA17337@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180829175405.GA17337@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On Wed, Aug 29, 2018 at 10:54:05AM -0700, Paul E. McKenney wrote:
> On Tue, Aug 28, 2018 at 04:01:50PM -0700, Andrew Morton wrote:
> > People often use the term "the foo() function".  I don't know why -
> > just say "foo()"!
> 
> For whatever it is worth...
> 
> I tend to use "The foo() function ..." instead of "foo() ..." in order
> to properly capitalize the first word of the sentence.  So I might say
> "The call_rcu() function enqueues an RCU callback." rather than something
> like "call_rcu() enqueues an RCU callback."  Or I might use some other
> trick to keep "call_rcu()" from being the first word of the sentence.

I tend to write 'Use call_rcu() to enqueue a callback." or "When
call_rcu() returns, the callback will have been enqueued".
