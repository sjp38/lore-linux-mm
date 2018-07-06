Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BD116B0003
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 18:28:28 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n8-v6so8464922wmh.0
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 15:28:28 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id i10-v6si7272863wrq.11.2018.07.06.15.28.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 15:28:26 -0700 (PDT)
Date: Fri, 6 Jul 2018 23:28:14 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
Message-ID: <20180706222814.GE30522@ZenIV.linux.org.uk>
References: <1530905572-817-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530905572-817-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>

On Fri, Jul 06, 2018 at 03:32:45PM -0400, Waiman Long wrote:

> With a 4.18 based kernel, the positive & negative dentries lookup rates
> (lookups per second) after initial boot on a 2-socket 24-core 48-thread
> 64GB memory system with and without the patch were as follows: `
> 
>   Metric                    w/o patch  neg_dentry_pc=0  neg_dentry_pc=1
>   ------                    ---------  ---------------  ---------------
>   Positive dentry lookup      584299       586749	   582670
>   Negative dentry lookup     1422204      1439994	  1438440
>   Negative dentry creation    643535       652194	   641841
> 
> For the lookup rate, there isn't any signifcant difference with or
> without the patch or with a zero or non-zero value of neg_dentry_pc.

Sigh...  What I *still* don't see (after all the iterations of the patchset)
is any performance data on workloads that would be likely to feel the impact.
Anything that seriously hits INCLUDE_PATH, for starters...
