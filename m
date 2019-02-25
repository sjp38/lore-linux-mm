Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B61BBC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:11:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 813DC2087C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:11:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 813DC2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09D438E000D; Mon, 25 Feb 2019 15:11:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04D308E000C; Mon, 25 Feb 2019 15:11:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA4E98E000D; Mon, 25 Feb 2019 15:11:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A32C68E000C
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:11:27 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 27so3157268pgv.14
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 12:11:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fdfJqYf6fQiL8j/rxMjQKxwFPpwZJcqxwtIDtcFiAh0=;
        b=AioN/YaQ7hI2+iQYXtbvjAkD9VCQwLyJOnwHRx3FZ4zT5U5qAAjhqW7u6IhJyjlqVU
         fOf0F4hd4XNbJ9jHTU57J0gR3Z+CxOmnw6+m39b1sLIL5LBctwyp/Kp5/iKGrCp3k5Hd
         GycIpfv2KrNNP7YHm7P2zhp2Ze9Eo91nbdyhsxqzHpimpaNajzDHSlltpV8x+GwTHkhU
         oMbvC6Hl7raAaZkIvA5/WRlDt/fWxY2526hJqTqnj/y2egKhXJPyXFd2wMjxTigIcU63
         4WIrp734iOio3Q1qtpVnH1d4QKeIIanu++JYg/f0H1kwpksjwBbX4q/Y769NGVGYXdki
         tvBg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAub5yMtxhxz3fZyiAe/FgC/4xYX2YSkrIi/XNLRwbqEsiAlsl1HR
	Fcv8vOhws1xNp4kLZ67ot7PkQmk3bqZq84bcAz+Q1X2aEcAM8Aw+NSJI9YyJirAm3+mPUewW4rU
	bklGKyvJETIVO+ItfxkyxFLbvB0JpdyixBk51oJNgl6OAXvGll7TIG/DiX8jkxgQ=
X-Received: by 2002:a62:59d0:: with SMTP id k77mr21919893pfj.211.1551125487321;
        Mon, 25 Feb 2019 12:11:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IamJyBngcH/hjP8iSOoU93+v7rScFJ2OioqWJQB5/ajZeOT4e+n2X+toeohasj4HM9v4K5g
X-Received: by 2002:a62:59d0:: with SMTP id k77mr21919805pfj.211.1551125486255;
        Mon, 25 Feb 2019 12:11:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551125486; cv=none;
        d=google.com; s=arc-20160816;
        b=v/Rzdj7J4vKolr5CNiFesd2XqJ0YxuBJrhfaroDX7bnWfyD56/ixFnueYWagcPnNly
         D7sSnywv16JRk+ohn2q0zYuLDBfNobRlKQPRUH05ERLtiCkIRTIYaBebzgS41UL2xNRp
         cZ7kIh3WWi4Do4uivj1LHWZIcrF0cclX6JKfE3W/slxhxU1C+hT5kvrsNCAa7R4NDITy
         td98KsIFSMac9cMOb2634tWCvGrRcoo9BEb9Q6YdqmaKsrkOlqsfrrbIcn5TdVMpK8FV
         eqdcOhs/jPmE7q9notu85jP6rCZuzWvhV0tYN1j5BrZ8J+EXrUAm+paF5wPul3huZZGm
         HTqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fdfJqYf6fQiL8j/rxMjQKxwFPpwZJcqxwtIDtcFiAh0=;
        b=Ip0t5HYwg8FWSbcvMMsfKpCsP0YxPVvYV1T6WqF3CLKcM2M/qUiPL0aT0O+XRYyUfY
         Ae4YZyFPGSP/nfL6d08glYiaWMXWbFqueg1nVDdx4u2a7oqkPnV0/QNgGqpcSf6mIsxi
         IXTtROoBQuDQqW6lAI+Clsfbih32SX+BYUH6XGzGjKCjGS1tTuRe3/t8qVQlfawNb1j/
         mCIm+EoDx9+ndczllNb2c/P0Zl/NTBeDWsB0yLuKkZlZe6htt9wyyxjzNCTr+snX3g3o
         +TmB8yJ6iQzJEjF4gCZtRkaAhErRUan/atQoGCy2lsdi1F7GpzWUScPxNLdsT8u5aPN5
         P27w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id p4si10582172pli.159.2019.02.25.12.11.25
        for <linux-mm@kvack.org>;
        Mon, 25 Feb 2019 12:11:26 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.131;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail07.adl2.internode.on.net with ESMTP; 26 Feb 2019 06:41:23 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gyMaw-0005N6-L2; Tue, 26 Feb 2019 07:11:22 +1100
Date: Tue, 26 Feb 2019 07:11:22 +1100
From: Dave Chinner <david@fromorbit.com>
To: Ming Lei <ming.lei@redhat.com>
Cc: "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org,
	Jens Axboe <axboe@kernel.dk>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>,
	Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org,
	linux-block@vger.kernel.org
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
Message-ID: <20190225201122.GF23020@dastard>
References: <20190225040904.5557-1-ming.lei@redhat.com>
 <20190225043648.GE23020@dastard>
 <20190225084623.GA8397@ming.t460p>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190225084623.GA8397@ming.t460p>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 04:46:25PM +0800, Ming Lei wrote:
> On Mon, Feb 25, 2019 at 03:36:48PM +1100, Dave Chinner wrote:
> > On Mon, Feb 25, 2019 at 12:09:04PM +0800, Ming Lei wrote:
> > > XFS uses kmalloc() to allocate sector sized IO buffer.
> > ....
> > > Use page_frag_alloc() to allocate the sector sized buffer, then the
> > > above issue can be fixed because offset_in_page of allocated buffer
> > > is always sector aligned.
> > 
> > Didn't we already reject this approach because page frags cannot be
> 
> I remembered there is this kind of issue mentioned, but just not found
> the details, so post out the patch for restarting the discussion.

As previously discussed, the only solution that fits all use cases
we have to support are a slab caches that do not break object
alignment when slab debug options are turned on.

> > reused and that pages allocated to the frag pool are pinned in
> > memory until all fragments allocated on the page have been freed?
> 
> Yes, that is one problem. But if one page is consumed, sooner or later,
> all fragments will be freed, then the page becomes available again.

Ah, no, your assumption about how metadata caching in XFS works is
flawed. Some metadata ends up being cached for the life of the
filesystem because it is so frequently referenced it never gets
reclaimed. AG headers, btree root blocks, etc.  And the XFS metadata
cache hangs on to such metadata even under extreme memory pressure
because if we reclaim it then any filesystem operation will need to
reallocate that memory to clean dirty pages and that is the very
last thing we want to do under extreme memory pressure conditions.

If allocation cannot reuse holes in pages (i.e. works as a proper
slab cache) then we are going to blow out the amount of memory that
the XFS metadata cache uses very badly on filesystems where block
size != page size. 

> > i.e. when we consider 64k page machines and 4k block sizes (i.e.
> > default config), every single metadata allocation is a sub-page
> > allocation and so will use this new page frag mechanism. IOWs, it
> > will result in fragmenting memory severely and typical memory
> > reclaim not being able to fix it because the metadata that pins each
> > page is largely unreclaimable...
> 
> It can be an issue in case of IO timeout & retry.

This makes no sense to me. Exactly how does filesystem memory
allocation affect IO timeouts and any retries the filesystem might
issue?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

