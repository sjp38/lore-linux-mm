Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id E28F26B0038
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 15:56:26 -0400 (EDT)
Received: by wigg3 with SMTP id g3so88758812wig.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 12:56:26 -0700 (PDT)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id bp4si23837830wjb.14.2015.06.15.12.56.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 12:56:25 -0700 (PDT)
Received: by wiga1 with SMTP id a1so88844396wig.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 12:56:24 -0700 (PDT)
Date: Mon, 15 Jun 2015 21:56:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] jbd2: get rid of open coded allocation retry loop
Message-ID: <20150615195622.GA16138@dhcp22.suse.cz>
References: <1434377854-17959-1-git-send-email-mhocko@suse.cz>
 <20150615194704.GF5003@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150615194704.GF5003@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 15-06-15 15:47:04, Theodore Ts'o wrote:
> On Mon, Jun 15, 2015 at 04:17:34PM +0200, Michal Hocko wrote:
> > insert_revoke_hash does an open coded endless allocation loop if
> > journal_oom_retry is true. It doesn't implement any allocation fallback
> > strategy between the retries, though. The memory allocator doesn't know
> > about the never fail requirement so it cannot potentially help to move
> > on with the allocation (e.g. use memory reserves).
> > 
> > Get rid of the retry loop and use __GFP_NOFAIL instead. We will lose the
> > debugging message but I am not sure it is anyhow helpful.
> > 
> > Do the same for journal_alloc_journal_head which is doing a similar
> > thing.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Thanks, applied.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
