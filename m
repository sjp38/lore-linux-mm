Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 260206B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 02:34:46 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u70so20248276pfa.2
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 23:34:46 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 32si279613plg.399.2017.10.24.23.34.43
        for <linux-mm@kvack.org>;
        Tue, 24 Oct 2017 23:34:44 -0700 (PDT)
Date: Wed, 25 Oct 2017 15:34:35 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v4 7/7] block: Assign a lock_class per gendisk used for
 wait_for_completion()
Message-ID: <20171025063435.GQ3310@X58A-UD3R>
References: <1508908272-15757-1-git-send-email-byungchul.park@lge.com>
 <1508908272-15757-8-git-send-email-byungchul.park@lge.com>
 <20171025060123.6mugpdpje6hx32nx@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171025060123.6mugpdpje6hx32nx@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: peterz@infradead.org, axboe@kernel.dk, johan@kernel.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

On Wed, Oct 25, 2017 at 08:01:24AM +0200, Ingo Molnar wrote:
> Beyond the #ifdef reduction I mentioned in the other thread, there's four other 
> things I noticed that need to be fixed in this patch:
> 
>  - Please write out 'minor' instead of the 'm' abbreviation that is meaningless. 
>    'm' is only used for trivial wrappers, but this wrapper is not trivial - so 
>    proper canonical variable names should be used.
> 
>  - Since __key and __name is already double underscores that is customary for
>    macros to avoid variable name shadowing, why is 'ret' not such a name?
> 
>  - But, 'ret' is the typical name used for integer returns, not for pointers! 
>    Please check the gendisk code for what the typical name for gendisk pointers
>    is and use that instead of making up new, weird patterns ...
> 
>  - The "(complete)"#minor"("#id")" generated name is pretty bad. Firstly 
>    "complete" is a verb (or adjective), while lock(dep) symbol names should be 
>    nouns! But even "completion" is pretty opaque, how about "gendisk_completion"?
> 
> More careful patches please!

I am sorry for that. I will do my best not to repeat them.

And I re-spined ASAP to make you able to review with the latest version
only including all your suggestions at the previous version.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
