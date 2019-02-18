Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F0C3C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 20:25:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF9B2217F5
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 20:25:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF9B2217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=angband.pl
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 710F98E0003; Mon, 18 Feb 2019 15:25:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 697848E0002; Mon, 18 Feb 2019 15:25:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55F9D8E0003; Mon, 18 Feb 2019 15:25:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id ED7128E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 15:25:38 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id e18so4549385wrw.10
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 12:25:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=/o+HfYey199WuzQnAMYXwDkJBF7TikKP4T5zC9/SIeM=;
        b=SS/VZBQE2RYbyY2PUKZt1UfMu4QZhzvgcfqsBJ8HQWtOVyAN+/W1Fmj15nL4l4lNij
         OO6GsrvLhMpLJL+hvp0HPBVuhpAAcyGqSRgaisWp36HKACpGy6fOstRrAc+4OAroQd/x
         UA9oa2Cdf/nWUQwR7+hE7m0T3wnDGM62ogA8lBAoJyKAYyXqRRodUwsRA9KTs428q4nM
         lkpkexjTbOP6KZhmIB2w/hiffQy7PsOMCUUtqGHdGYa32yZcLuk5JxHo1vdXwZyqpRGr
         vnVQ9BugN3Al6Brkweu7i919FegM3r99RXY6PoLDGIcOoaMn2O0m82izBaQkRlrL+ckm
         zzFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kilobyte@angband.pl designates 2001:41d0:602:dbe::8 as permitted sender) smtp.mailfrom=kilobyte@angband.pl
X-Gm-Message-State: AHQUAuagKlAS52UrjVpVlAvvfqwRZcSJXsrSG3W6Qlb0aFoMQ8C6ZAs3
	swoeZUa0ebSNNuxxobI0XAABBiGx/EvOxtjnibOvQ4uMie92Ri0Rk6LJckYhGt4zQBFijIESSMp
	d1Qo5HD54SPwSCD8GG4aJo5Z+Au+qiVfonmNYlZsBAYpNlDseFbLP3ctVYApau/EfRQ==
X-Received: by 2002:a7b:c0d5:: with SMTP id s21mr378265wmh.153.1550521538372;
        Mon, 18 Feb 2019 12:25:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY5IMhn1R+HMig1MhOZ2sRQ2tQhu2gc3sd83XwtM1fumsVhrINiCK1sjZfQdRtBeSITA8UZ
X-Received: by 2002:a7b:c0d5:: with SMTP id s21mr378211wmh.153.1550521537269;
        Mon, 18 Feb 2019 12:25:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550521537; cv=none;
        d=google.com; s=arc-20160816;
        b=BBq+GQv7ZGP/JExebU7dqj/YnPcr5bBJ5IrO2isGc1rt5pAjkJ4+ql2SjFEzclZvZ5
         rdCDS1UjTxcF6xvZxzWrSpIZg2Vn2VKDcMG6iItN8TeWxBjjlCeacs2cQ3kkVCcaOsGO
         Bi/WADZZ8QUlgjmP6mmZ5pPcaRnZJmWndaEX4EUE3yA5n3pagmz0WRVh4Ez++o/flQCJ
         XFWwR4dU/ktmrU7VUJtRjIksYaTOfBxg6aecL8ikmc+NAocvU9MgnbinSZprQTYCfwkI
         Fste521BtfMDce9Hk3JkeqjSQEnKqiAQlgY2h+D0gRbvm9KrYa8eXcz6VS5zItSW+skC
         mVMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=/o+HfYey199WuzQnAMYXwDkJBF7TikKP4T5zC9/SIeM=;
        b=0b9NFPK/z4hTfjGnJwqgFJk7wL1SmdoIfykAIQ3wjK79+25H/jYfZEgINEbvvK+esU
         V8jNq85v+OSpNZLchTmL+DMei4nq8u4v2zlY4J9SVDFM6swhUa9stkcP9/WKwXavWkZv
         eySFEMyDjeL4C8ctQPFqLvHi+Jgu9VRQdpk9F3rtHcE43btrrCe2kL4sG35rkD3/PnMU
         kuwyqGkc6REhdFDfDTrZSsFK5aJletW4QLMwFshzbosgpcsgaDyukGfqdCt6MEmrKawd
         JpjIvfn2VnipWhtF6TrHiCaXGoTPBpwrmiKDxzpV1nPcTjYmtAQst4TXLXmGriliv/L8
         SpQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kilobyte@angband.pl designates 2001:41d0:602:dbe::8 as permitted sender) smtp.mailfrom=kilobyte@angband.pl
Received: from tartarus.angband.pl (tartarus.angband.pl. [2001:41d0:602:dbe::8])
        by mx.google.com with ESMTPS id f1si6151897wrw.88.2019.02.18.12.25.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 12:25:37 -0800 (PST)
Received-SPF: pass (google.com: domain of kilobyte@angband.pl designates 2001:41d0:602:dbe::8 as permitted sender) client-ip=2001:41d0:602:dbe::8;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kilobyte@angband.pl designates 2001:41d0:602:dbe::8 as permitted sender) smtp.mailfrom=kilobyte@angband.pl
Received: from kilobyte by tartarus.angband.pl with local (Exim 4.89)
	(envelope-from <kilobyte@angband.pl>)
	id 1gvpTq-0000Ai-Dk; Mon, 18 Feb 2019 21:25:34 +0100
Date: Mon, 18 Feb 2019 21:25:34 +0100
From: Adam Borowski <kilobyte@angband.pl>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	Hugh Dickins <hughd@google.com>
Cc: Marcin =?utf-8?Q?=C5=9Alusarz?= <marcin.slusarz@intel.com>
Subject: Re: tmpfs fails fallocate(more than DRAM)
Message-ID: <20190218202534.btgdyr5p3rxoqot7@angband.pl>
References: <20190218133423.tdzawczn4yjdzjqf@angband.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190218133423.tdzawczn4yjdzjqf@angband.pl>
X-Junkbait: aaron@angband.pl, zzyx@angband.pl
User-Agent: NeoMutt/20170113 (1.7.2)
X-SA-Exim-Connect-IP: <locally generated>
X-SA-Exim-Mail-From: kilobyte@angband.pl
X-SA-Exim-Scanned: No (on tartarus.angband.pl); SAEximRunCond expanded to false
X-Bogosity: Ham, tests=bogofilter, spamicity=0.009755, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hugh, it turns out this problem is caused by your commit
1aac1400319d30786f32b9290e9cc923937b3d57:

On Mon, Feb 18, 2019 at 02:34:23PM +0100, Adam Borowski wrote:
> There's something that looks like a bug in tmpfs' implementation of
> fallocate.  If you try to fallocate more than the available DRAM (yet
> with plenty of swap space), it will evict everything swappable out
> then fail, undoing all the work done so far first.
> 
> The returned error is ENOMEM rather than POSIX mandated ENOSPC (for
> posix_allocate(), but our documentation doesn't mention ENOMEM for
> Linux-specific fallocate() either).
> 
> Doing the same allocation in multiple calls -- be it via non-overlapping
> calls or even with same offset but increasing len -- works as expected.

I don't quite understand your logic there -- it seems to be done on purpose?

#   tmpfs: quit when fallocate fills memory
#   
#   As it stands, a large fallocate() on tmpfs is liable to fill memory with
#   pages, freed on failure except when they run into swap, at which point
#   they become fixed into the file despite the failure.  That feels quite
#   wrong, to be consuming resources precisely when they're in short supply.

The page cache is just a cache, and thus running out of DRAM is in no way a
failure (as long as there's enough underlying storage).  Like any other
filesystem, once DRAM is full, tmpfs is supposed to start writeout.  A smart
filesystem can mark zero pages as SWAP_MAP_FALLOC to avoid physically
writing them out but doing so the naive hard way is at least correct.
    
#   Go the other way instead: shmem_fallocate() indicate the range it has
#   fallocated to shmem_writepage(), keeping count of pages it's allocating;
#   shmem_writepage() reactivate instead of swapping out pages fallocated by
#   this syscall (but happily swap out those from earlier occasions), keeping
#   count; shmem_fallocate() compare counts and give up once the reactivated
#   pages have started to coming back to writepage (approximately: some zones
#   would in fact recycle faster than others).

It's a weird inconsistency: why should space allocated in a previous call
act any different from that we allocate right now?
    
#   This is a little unusual, but works well: although we could consider the
#   failure to swap as a bug, and fix it later with SWAP_MAP_FALLOC handling
#   added in swapfile.c and memcontrol.c, I doubt that we shall ever want to.

It breaks use of tmpfs as a regular filesystem.  In particular, you don't
know that a program someone uses won't try to create a big file.  For
example, Debian buildds (where I first hit this problem) have setups such
as:
< jcristau> kilobyte: fwiw x86-csail-01.d.o has 75g /srv/buildd tmpfs, 8g ram, 89g swap

Using tmpfs this way is reasonable: traditional filesystems spend a lot of
effort to ensure crash consistency, and even if you disable journaling and
barriers, they will pointlessly write out the files.  Most builds can
succeed in far less than 8GB, not touching the disk even once.

[...]

> This raises multiple questions:
> * why would fallocate bother to prefault the memory instead of just
>   reserving it?  We want to kill overcommit, but reserving swap is as good
>   -- if there's memory pressure, our big allocation will be evicted anyway.

I see that this particular feature is not coded yet for swap.

> * why does it insist on doing everything in one piece?  Biggest chunk I
>   see to be beneficial is 1G (for hugepages).

At the moment, a big fallocate evicts all other swappable pages.  Doing it
piece by piece would at least allow swapping out memory it just allocated
(if we don't yet have a way to mark it up without physically writing
zeroes).

> * when it fails, why does it undo the work done so far?  This can matter
>   for other reasons, such as EINTR -- and fallocate isn't expected to be
>   atomic anyway.

I searched a bit for references that would suggest failed fallocates need to
be undone, and I can't seem to find any.  Neither POSIX nor our man pages
say a word about semantics of interrupted fallocate, and both glibc's and
FreeBSD's fallback emulation don't rollback.


But, as my understanding seems to go nearly the opposite way as your commit
message, am I getting it wrong?  It's you not me who's a mm regular...


Meow!
-- 
⢀⣴⠾⠻⢶⣦⠀
⣾⠁⢠⠒⠀⣿⡁
⢿⡄⠘⠷⠚⠋⠀ Have you accepted Khorne as your lord and saviour?
⠈⠳⣄⠀⠀⠀⠀

