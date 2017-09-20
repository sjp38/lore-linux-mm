Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE9406B0033
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 10:44:26 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f4so3039143wmh.7
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 07:44:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 63si1755019edj.517.2017.09.20.07.44.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Sep 2017 07:44:25 -0700 (PDT)
Date: Wed, 20 Sep 2017 16:43:57 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 6/6] fs-writeback: only allow one inflight and pending
 !nr_pages flush
Message-ID: <20170920144357.GG11106@quack2.suse.cz>
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <1505850787-18311-7-git-send-email-axboe@kernel.dk>
 <CAOQ4uxjxgtNvNFh936SK2+kbPvj5zDR_tx66u2s6jiOTSrRLUQ@mail.gmail.com>
 <eebaf6e6-63be-2759-67b2-62d980cdd8f8@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <eebaf6e6-63be-2759-67b2-62d980cdd8f8@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Amir Goldstein <amir73il@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, hannes@cmpxchg.org, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>

On Tue 19-09-17 22:13:25, Jens Axboe wrote:
> On 09/19/2017 09:10 PM, Amir Goldstein wrote:
> New version:
> 
> http://git.kernel.dk/cgit/linux-block/commit/?h=writeback-fixup&id=338a69c217cdaaffda93f3cc9a364a347f782adb

This looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

									Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
