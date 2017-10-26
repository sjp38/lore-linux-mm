Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D92C6B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 10:34:04 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id g6so2944198pgn.11
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 07:34:04 -0700 (PDT)
Received: from BJEXCAS006.didichuxing.com ([36.110.17.22])
        by mx.google.com with ESMTPS id 202si3445071pgg.496.2017.10.26.07.34.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 07:34:03 -0700 (PDT)
Date: Thu, 26 Oct 2017 22:33:56 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: Re: [PATCH] bdi: add check before create debugfs dir or files
Message-ID: <20171026143336.GA13166@source.didichuxing.com>
References: <20171025152312.GA23944@source.didichuxing.com>
 <20171026135405.GC31161@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171026135405.GC31161@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-mm@kvack.org

On Thu, Oct 26, 2017 at 03:54:05PM +0200, Jan Kara wrote:
> On Wed 25-10-17 23:23:18, weiping zhang wrote:
> > we should make sure parents directory exist, and then create dir or
> > files under that.
> > 
> > Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
> 
> OK, this looks reasonable to me but instead of instead of just leaving
> debugfs in half-initialized state, we should rather properly tear it down,
> return error from bdi_debug_register() and handle it in
> bdi_register_va()...
> 
> 
At beginning I try to return error code to caller, then I find
bdi_register_owner's return value was not checked in device_add_disk,
so I think there may have some stories. But now, I found we must check
bdi_register_owner in device_add_disk, otherwise bdi may lead some
undefined behavior. blk_mq_debugfs_register also has same issue.

I will send new patch series to fix these issues.


--
weiping

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
