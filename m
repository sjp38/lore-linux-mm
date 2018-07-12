Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6CAEA6B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 12:56:19 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id q18-v6so17690205pll.3
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 09:56:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l10-v6si22249608pgb.510.2018.07.12.09.56.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Jul 2018 09:56:18 -0700 (PDT)
Date: Thu, 12 Jul 2018 09:56:05 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v7 3/6] fs/dcache: Add sysctl parameter neg-dentry-limit
 as a soft limit on negative dentries
Message-ID: <20180712165605.GB3475@bombadil.infradead.org>
References: <1531413965-5401-1-git-send-email-longman@redhat.com>
 <1531413965-5401-4-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1531413965-5401-4-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On Thu, Jul 12, 2018 at 12:46:02PM -0400, Waiman Long wrote:
> +int neg_dentry_limit;
> +EXPORT_SYMBOL_GPL(neg_dentry_limit);

Why are you exporting it?  What module needs this?
