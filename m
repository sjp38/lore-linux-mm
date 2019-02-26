Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14C80C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 20:45:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE0FC21873
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 20:45:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE0FC21873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E6B68E0003; Tue, 26 Feb 2019 15:45:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7944C8E0001; Tue, 26 Feb 2019 15:45:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6830C8E0003; Tue, 26 Feb 2019 15:45:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 26A3E8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 15:45:56 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id y1so10459811pgo.0
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:45:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BTHbR4e02YAu/p3GqWhqWuWcW/tE3O+ocT8mTIwfhEY=;
        b=Tob78FtyT9OI1fkNBEtj1kgZZ2K2/c6AtsuMtDqqhD87JmtyYych0w1KR0IZ4fu+m0
         VJ9zNpAT8/14V87m60YNkGzvr0Wp1qryC8bgPDMwglvu8fcBgUOg1zFIDHk0QKVJEPul
         /nnOsyqwt+q7yhoRh4qT6+/RUw1TL+DbQ6ITF3PhsvLL8Mczew2A8VA1YXnyffZDTXWF
         NGk2SncQMzl9qkHwUzpLqWihCf261IHFlLqTbJJDKBSQFoNHmF5L3b4vHFXDnxeKPUqv
         eI66glN6rKTZ+KjnprtLD5yB0xHZJf11RnS0/qq8NSbM9i3VvTST0sLGk5jJ0Es6CKkx
         rv8A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.139 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAuZWto5uiATaZmSz51F3n4xRZMQ7ftM3DGH588XGMa36TxobSO7H
	cmc8ruGSi6qEZBwsXD1ke2T1Um8RsMrzZZf6DxjdMPnLPgxzgPNzE58nCCpRLb9WhNp/cWESLkc
	wgEXbO+nFALx6eB3HbiIMyd41nbIF/YRQfHK/UNnjlIBnOsTL0uPdbmjz0jD4TG0=
X-Received: by 2002:a62:138f:: with SMTP id 15mr27863052pft.219.1551213955582;
        Tue, 26 Feb 2019 12:45:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IamDcPk7fpk896jSPh3GYv85XOMLZlrEF/qBHZb+PzNL9UKRwaCbiy2M4IV64L3vfZHsGQA
X-Received: by 2002:a62:138f:: with SMTP id 15mr27862979pft.219.1551213954414;
        Tue, 26 Feb 2019 12:45:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551213954; cv=none;
        d=google.com; s=arc-20160816;
        b=o/VyQGdFjRJwkIqYWnBXHZHI3cLA9vjuuimL8/hxAIBfZfqwcqpFjpoQjaVRxWUBOz
         WM2yw358IJhHGE39Oub6yS93mjxmGUcQ928ejwcyrr3kF/rdXp4nIhdPhKTSX0rVcEz3
         5i0GKhOdkIiOQ6hzyGIT8Vy4r9MW/52AaLqPcclTxu+GtjodbtyNAEHXPJqEl3TnbvoX
         HaIGlA8O/AhhyJAKVXI9WRjtpmkk/j3/J/JEjPLyx98kqijK3oBTxSdqYq7iII1f7gtv
         NwgwoinZPepy4XOORkbnKj4v+ZJplNp9Zw74wU7fEpZD2EKkdzesoU1E6m5berfX77ei
         80WQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BTHbR4e02YAu/p3GqWhqWuWcW/tE3O+ocT8mTIwfhEY=;
        b=EVEPQ9n32fIifP4LbDbVaQP6vXxwv9ZohJ4mtb3xjKgeaZFaMZaK2KNAKy+38DX5aL
         7d0Ji+BeBWw9i3pzx6wfYASD7ZYNxj3e9Y3pCQPcGd3lxKyZiDChWhndwg2vhVgMjbOy
         KF3/uHczwPGZZStA2yeQSBQmgsRYdMRDAF+LYiAUeyXao9auCOlodxYioX3cxDc23nay
         SDCve4KuEC2A4CgibWPt/fMPAT0Jnp3+nYpeI2RUZIYlg48N+lE3uLYaARDjXv6+5Ffv
         heKdRKYggMeUUi0XeKfOHXWhrEFkbGjek39wbWZXUUa04gTe67UIYMxsYFG0CbPraVN1
         uYjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.139 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail02.adl2.internode.on.net (ipmail02.adl2.internode.on.net. [150.101.137.139])
        by mx.google.com with ESMTP id 71si2868789plf.436.2019.02.26.12.45.53
        for <linux-mm@kvack.org>;
        Tue, 26 Feb 2019 12:45:54 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.139 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.139;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.139 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail02.adl2.internode.on.net with ESMTP; 27 Feb 2019 07:15:51 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gyjbq-0006v4-Kr; Wed, 27 Feb 2019 07:45:50 +1100
Date: Wed, 27 Feb 2019 07:45:50 +1100
From: Dave Chinner <david@fromorbit.com>
To: Ming Lei <ming.lei@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org, Jens Axboe <axboe@kernel.dk>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>,
	Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org,
	linux-block@vger.kernel.org
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
Message-ID: <20190226204550.GK23020@dastard>
References: <20190225040904.5557-1-ming.lei@redhat.com>
 <20190225043648.GE23020@dastard>
 <5ad2ef83-8b3a-0a15-d72e-72652b807aad@suse.cz>
 <20190225202630.GG23020@dastard>
 <20190226022249.GA17747@ming.t460p>
 <20190226030214.GI23020@dastard>
 <20190226032737.GA11592@bombadil.infradead.org>
 <20190226045826.GJ23020@dastard>
 <20190226093302.GA24879@ming.t460p>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226093302.GA24879@ming.t460p>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 05:33:04PM +0800, Ming Lei wrote:
> On Tue, Feb 26, 2019 at 03:58:26PM +1100, Dave Chinner wrote:
> > On Mon, Feb 25, 2019 at 07:27:37PM -0800, Matthew Wilcox wrote:
> > > On Tue, Feb 26, 2019 at 02:02:14PM +1100, Dave Chinner wrote:
> > > > > Or what is the exact size of sub-page IO in xfs most of time? For
> > > > 
> > > > Determined by mkfs parameters. Any power of 2 between 512 bytes and
> > > > 64kB needs to be supported. e.g:
> > > > 
> > > > # mkfs.xfs -s size=512 -b size=1k -i size=2k -n size=8k ....
> > > > 
> > > > will have metadata that is sector sized (512 bytes), filesystem
> > > > block sized (1k), directory block sized (8k) and inode cluster sized
> > > > (32k), and will use all of them in large quantities.
> > > 
> > > If XFS is going to use each of these in large quantities, then it doesn't
> > > seem unreasonable for XFS to create a slab for each type of metadata?
> > 
> > 
> > Well, that is the question, isn't it? How many other filesystems
> > will want to make similar "don't use entire pages just for 4k of
> > metadata" optimisations as 64k page size machines become more
> > common? There are others that have the same "use slab for sector
> > aligned IO" which will fall foul of the same problem that has been
> > reported for XFS....
> > 
> > If nobody else cares/wants it, then it can be XFS only. But it's
> > only fair we address the "will it be useful to others" question
> > first.....
> 
> This kind of slab cache should have been global, just like interface of
> kmalloc(size).
> 
> However, the alignment requirement depends on block device's block size,
> then it becomes hard to implement as genera interface, for example:
> 
> 	block size: 512, 1024, 2048, 4096
> 	slab size: 512*N, 0 < N < PAGE_SIZE/512
> 
> For 4k page size, 28(7*4) slabs need to be created, and 64k page size
> needs to create 127*4 slabs.

IDGI. Where's the 7/127 come from?

We only require sector alignment at most, so as long as each slab
object is aligned to it's size, we only need one slab for each block
size.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

