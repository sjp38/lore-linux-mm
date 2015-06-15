Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9322B6B0038
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 15:47:06 -0400 (EDT)
Received: by ykfl8 with SMTP id l8so65378369ykf.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 12:47:06 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id a141si5289868yka.128.2015.06.15.12.47.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 12:47:05 -0700 (PDT)
Date: Mon, 15 Jun 2015 15:47:04 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] jbd2: get rid of open coded allocation retry loop
Message-ID: <20150615194704.GF5003@thunk.org>
References: <1434377854-17959-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434377854-17959-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 15, 2015 at 04:17:34PM +0200, Michal Hocko wrote:
> insert_revoke_hash does an open coded endless allocation loop if
> journal_oom_retry is true. It doesn't implement any allocation fallback
> strategy between the retries, though. The memory allocator doesn't know
> about the never fail requirement so it cannot potentially help to move
> on with the allocation (e.g. use memory reserves).
> 
> Get rid of the retry loop and use __GFP_NOFAIL instead. We will lose the
> debugging message but I am not sure it is anyhow helpful.
> 
> Do the same for journal_alloc_journal_head which is doing a similar
> thing.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Thanks, applied.

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
