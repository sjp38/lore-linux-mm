Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B7ABC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 03:41:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26DC7218E2
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 03:41:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26DC7218E2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80C788E0003; Tue, 26 Feb 2019 22:41:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7938B8E0001; Tue, 26 Feb 2019 22:41:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65B788E0003; Tue, 26 Feb 2019 22:41:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1FEEB8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 22:41:42 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id j10so8759999pfn.13
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 19:41:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YbTgbV6sTylqUpmi6+JD2hqhVJSSZOXNeT9CJHELQ9Q=;
        b=X7XaebVS19mUpIaaVbqcWhzgPDfROdZlbO8HF4q11eccoPWYJIGlfESzbI8y602wqR
         wnz7hY04boYfF+Uv9veDLI4Rldd7ifgds8Mh9xnF1/SpLGBSbZ9MicVbs+fwOnco0wSq
         al0KzERnXLYiT0WcDmzayREddMAacBX9QOPvYHL5gUgOgW24i5jSWzBXjobEJ1txVKNZ
         sbDawvwhi/Nvy0FSd8oGNcntZjGpKbhwinjhRpvK9007GbnQ9fjmvyD1w2BNqmo73sh3
         yfR+qCkZ6aJ90a0EyPm87ukrQ6LrQGDkr7TmIoqMcx3sT/uMOpjUp2/oLjaAEmNXAZfB
         YT8g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAub7c/Tx/YFUgaZx1ZvkJiWfqTEVQntBimU5Ys+Gk5jlHomKehSt
	SxUps76pqgqoM27my4GmhNVPDnP8ejJvYQEhD9fg5wFQHELZJNy7i9LhqmNcJRNKYblUcZXeQMz
	W8/fa3ZQX9LhamKjeXQq/zvC1MJUV7acORxXfWJyeEROfdWjj5XgQWhxTCW4S/5I=
X-Received: by 2002:a17:902:7298:: with SMTP id d24mr16082164pll.39.1551238901644;
        Tue, 26 Feb 2019 19:41:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZJnrN4hqn+dM7bSsYNN+5bAK9P7CGmY1P6+xZOXKdw0OG4elq0i2NKlqQPeEcb581uQy0T
X-Received: by 2002:a17:902:7298:: with SMTP id d24mr16082080pll.39.1551238900239;
        Tue, 26 Feb 2019 19:41:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551238900; cv=none;
        d=google.com; s=arc-20160816;
        b=RU8ZERQBDhUDYxJ6zoO1NjWGHxLEC+Z3j/ELkwoNYFpmAmWOW4MhcaWDo1A0HWra7u
         gGx37I4gWFPHBnwcQN8d+wYA2Cc3tvG+jrB+UrRhtdKPlCLRq/uBUc9e5xT4aO2kwRwT
         0SNoiKytTXIyEGQTIbiQDtSediGC77z9GH1ucaFNxybNA4m8AmU9yVW9ABsDlY4M39mV
         QJD9KoyShxDdcRLlAhU3/3010v9T9CNC03fwim6jJORwwiKz/BEr5yYI79j08H2geQFK
         NUJ+fqyt6IDBtH5JXFJ3JWFZlUEywdQSdOu//GOv+cLsUqYD/H69nl2iwVDiz5m7WNUi
         iCEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YbTgbV6sTylqUpmi6+JD2hqhVJSSZOXNeT9CJHELQ9Q=;
        b=kx686YefvJbQ2R18nPKKtoSM8f643y+BcfI4oEKod2ySf5KB+a0kiC9BiShLj8Fzo3
         74e399eVpPxXVRLTKKWhh5B0tepTUNirriOzv49cydxOrdNm0jVFQmi+hwhJJx3+eAqs
         rQsfVUguZ9X6iIzkwvfCkhtL/3fvIRtudHFSAhigRrInuJKgkU/wrQixsjVl9eLHZo1b
         ZUElYz+KezGINM0MRux9JJtIQcecUdeGpA6rt8rs0f2MVUYsWg+Uy9SHqgJP2PkLaVaX
         ShByBJqXpdfZAzsDAB/mflgd3xJwdorl+jrBtMx6xj4bWtPWrxL60DFKVBeLPfkcpWVb
         dvAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id 37si10967655pgu.58.2019.02.26.19.41.38
        for <linux-mm@kvack.org>;
        Tue, 26 Feb 2019 19:41:40 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.145;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail06.adl6.internode.on.net with ESMTP; 27 Feb 2019 14:11:37 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gyq69-0007LM-7I; Wed, 27 Feb 2019 14:41:33 +1100
Date: Wed, 27 Feb 2019 14:41:33 +1100
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
Message-ID: <20190227034133.GL23020@dastard>
References: <20190225043648.GE23020@dastard>
 <5ad2ef83-8b3a-0a15-d72e-72652b807aad@suse.cz>
 <20190225202630.GG23020@dastard>
 <20190226022249.GA17747@ming.t460p>
 <20190226030214.GI23020@dastard>
 <20190226032737.GA11592@bombadil.infradead.org>
 <20190226045826.GJ23020@dastard>
 <20190226093302.GA24879@ming.t460p>
 <20190226204550.GK23020@dastard>
 <20190227015054.GC16802@ming.t460p>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190227015054.GC16802@ming.t460p>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 09:50:55AM +0800, Ming Lei wrote:
> On Wed, Feb 27, 2019 at 07:45:50AM +1100, Dave Chinner wrote:
> > On Tue, Feb 26, 2019 at 05:33:04PM +0800, Ming Lei wrote:
> > > On Tue, Feb 26, 2019 at 03:58:26PM +1100, Dave Chinner wrote:
> > > > On Mon, Feb 25, 2019 at 07:27:37PM -0800, Matthew Wilcox wrote:
> > > > > On Tue, Feb 26, 2019 at 02:02:14PM +1100, Dave Chinner wrote:
> > > > > > > Or what is the exact size of sub-page IO in xfs most of time? For
> > > > > > 
> > > > > > Determined by mkfs parameters. Any power of 2 between 512 bytes and
> > > > > > 64kB needs to be supported. e.g:
> > > > > > 
> > > > > > # mkfs.xfs -s size=512 -b size=1k -i size=2k -n size=8k ....
> > > > > > 
> > > > > > will have metadata that is sector sized (512 bytes), filesystem
> > > > > > block sized (1k), directory block sized (8k) and inode cluster sized
> > > > > > (32k), and will use all of them in large quantities.
> > > > > 
> > > > > If XFS is going to use each of these in large quantities, then it doesn't
> > > > > seem unreasonable for XFS to create a slab for each type of metadata?
> > > > 
> > > > 
> > > > Well, that is the question, isn't it? How many other filesystems
> > > > will want to make similar "don't use entire pages just for 4k of
> > > > metadata" optimisations as 64k page size machines become more
> > > > common? There are others that have the same "use slab for sector
> > > > aligned IO" which will fall foul of the same problem that has been
> > > > reported for XFS....
> > > > 
> > > > If nobody else cares/wants it, then it can be XFS only. But it's
> > > > only fair we address the "will it be useful to others" question
> > > > first.....
> > > 
> > > This kind of slab cache should have been global, just like interface of
> > > kmalloc(size).
> > > 
> > > However, the alignment requirement depends on block device's block size,
> > > then it becomes hard to implement as genera interface, for example:
> > > 
> > > 	block size: 512, 1024, 2048, 4096
> > > 	slab size: 512*N, 0 < N < PAGE_SIZE/512
> > > 
> > > For 4k page size, 28(7*4) slabs need to be created, and 64k page size
> > > needs to create 127*4 slabs.
> > 
> > IDGI. Where's the 7/127 come from?
> > 
> > We only require sector alignment at most, so as long as each slab
> > object is aligned to it's size, we only need one slab for each block
> > size.
> 
> Each slab has fixed size, I remembered that you mentioned that the meta
> data size can be 512 * N (1 <= N <= PAGE_SIZE / 512).
> 
> https://marc.info/?l=linux-fsdevel&m=155115014513355&w=2

nggggh. 

*That* *is* *not* *what* *I* *said*.

That is *what you said* and I said that was wrong and the actual
sizes needed were:

dgc> It is not. On a 64k page size machine, we use sub page slabs for
dgc> metadata blocks of 2^N bytes where 9 <= N <= 15..

Please do the maths. I shoul dnot have to do it for you.

Also, please don't confusing sector-in-LBA alignment with /memory
buffer/ alignment. i.e. you're assuming that these 2kB IOs at
different sector offsets like the following:

 0	0.5	1.0	1.5	2.0	2.5	3.0	3.5	4.0
 +-------+-------+-------+-------+-------+-------+-------+-------+
 +ooooooooooooooooooooooooooooooo+
	 +ooooooooooooooooooooooooooooooo+
		 +ooooooooooooooooooooooooooooooo+
			 +ooooooooooooooooooooooooooooooo+
				 +ooooooooooooooooooooooooooooooo+

require a memory buffer alignment that matches the sector-in-LBA
alignment. This is wrong - the memory alignment constraint is
usually a hardware DMA engine limitation and has nothing to do with
the LBA the IO will place/retreive the data in/from.

i.e. An aligned 2kB slab will only allocate 2kB slab objects like so:

 0	0.5	1.0	1.5	2.0	2.5	3.0	3.5	4.0
 +-------+-------+-------+-------+-------+-------+-------+-------+
 +ooooooooooooooooooooooooooooooo+
				 +ooooooooooooooooooooooooooooooo+

and these memory buffers will always have 512 byte alignment. This
meets the memory alignemnt requirements of all hardware (which is
512 byte alignment or smaller), and so we only need one slab per
size.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

