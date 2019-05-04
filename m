Return-Path: <SRS0=c8nW=TE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F31EC43219
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 19:42:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B760820652
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 19:42:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="eC+KXDyy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B760820652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64FBF6B0003; Sat,  4 May 2019 15:42:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 600BE6B0006; Sat,  4 May 2019 15:42:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F0256B0007; Sat,  4 May 2019 15:42:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1516C6B0003
	for <linux-mm@kvack.org>; Sat,  4 May 2019 15:42:13 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id u1so509064plk.10
        for <linux-mm@kvack.org>; Sat, 04 May 2019 12:42:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bWe+s64qLZIT8UOHJ03/sna3dE0MqHE8qjTUU4lqDwo=;
        b=HDRG0XqYX2P8y0KsnMESgA9NTFeZFAiraLxqAIBTuGYQK/U4ChSTGxUxp/fWEFxdun
         RZ3WzqCU59bkP59NcevvAdNK2/JamM2c2LGoZeuu4R0j4bHcu/T+SA3BJx56/ujK4DJC
         pNs44oCtEOo05xe5+hlMDxdlLaY5UPsZ4t3SeJoIj4xHXwbrz49hC0Ev3cu3+QSHfm2P
         avYfsAZCR0wOBxoA5pXf2yAjhlUdoLutwtbFquz/xP0fsoRUbPCqwwT6LBg49sVMjAHO
         /54+IFngKe1NWMKOyeIrj6tA2xJsRsOgRCtA5g7yxozg0BsrH+G5uwXYJbhIJTaK3N5M
         bDRw==
X-Gm-Message-State: APjAAAVAlEEy4a9qHzze3ttqViO9nYkiWZqydieaS0s0FD5a8A5Mnx4V
	fZb7Rt7tT+KWB1c7MMWzjsuBmY3xPQEvGzFbvAqTx1qHi1irZblsl9OoifZh0RLs95MZvZVhRbg
	r8xMXlu3GmCvXb5kCplzuB/2gypoWCyMS5PA1azar4Bi+MKnjungH8zdXDyJITrNKeg==
X-Received: by 2002:a65:60ca:: with SMTP id r10mr20794491pgv.64.1556998932642;
        Sat, 04 May 2019 12:42:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8ziHT7Vj/cfZPoZJiIafcLURy76jxt9XgL004kAZBUeQS/Tuw2PHyxSFzuiPmkyRwOgJt
X-Received: by 2002:a65:60ca:: with SMTP id r10mr20794451pgv.64.1556998931772;
        Sat, 04 May 2019 12:42:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556998931; cv=none;
        d=google.com; s=arc-20160816;
        b=VmHFGQIsdpRn7MSRyY+1TNK36K6aXui0kUARByV6/2H2I/1S4UHhaaibfHrv3uNw8W
         MRXoQ4pA6DncCqis6dWS7cEc5hYw0P9M0opwrl4bn/mmhADsBqQm+iZuT/8cz0X8qOOo
         zpGeZXS5FLl0yJ5Kwyt4AKU7Dowh4YLj5nexu2Pq9TLm0y/0U+71Gho50SWXtXML0jA3
         ow3J45azgcV3zgLS1/HF9DDWWbhAp7+611Z9lhmNMafHwyQWwjwtsd+e93l0Nr3XhOd2
         8uP4uXP7MhGAHPycuB1Qbq6+orlS6Y1mBxYFep8svl2UWnij2NP/3GsCmZf6+pxgt8LC
         15fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bWe+s64qLZIT8UOHJ03/sna3dE0MqHE8qjTUU4lqDwo=;
        b=Il4PFP44qHTriKLqZIEe4/mIaYCArPwW4M48REtXj5bh+Bq3zzFTWFvqjOoQ+iaKnT
         EdnPODJYGD1LrbK830HbUKSmNT/PoIHE8PMf3Tcl2e7dBINkJcjQUAZO/T4fyXTqzheY
         u/6iLuAqtT3e5yAKy4N5OfYF4701jUev47eHak7qhWWHa675jGmqKWzR8/ACI8xARIkS
         RTrRoXHJc2QNzdU3r27SY2aq+mutXCFoAz2AcBNYyIw4+Lbpvg5eb4rH5o4tkKYI1PFO
         WCu0OMvqVrlv+GMZAyHxhN+KXAe22JRaJtcNd9hLxz/1LKbpWS2lM18tW5rv+5gkBGXl
         y91A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=eC+KXDyy;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e22si8549409pgi.66.2019.05.04.12.42.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 04 May 2019 12:42:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=eC+KXDyy;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=bWe+s64qLZIT8UOHJ03/sna3dE0MqHE8qjTUU4lqDwo=; b=eC+KXDyyCPKC4fKPCzLudAZsL
	wT8xze2iYVhDX69i8J5+fbIEgnCCqQnI0hLxqxRTbNngIgZlK+WDhXvgiyoFmpB7EHaPj3qk+0fNj
	dKUU+9ADvXOZBlPR7B4aLjA0M8Q1uTaH+PiyrLQ9X++mL5TCZE6Gs3/GVaVcB3iGxSDlVvZUOIs5j
	uX/hXJDW3QsCmPTXaYqp+tB/iWAoPuK63IqraHwaP76b2Vij/lQsBmeo1u9DUaTytCAOuVY0aeeKc
	TmAA86m5B8NdAC2TxH1XYap8weexEMb6B33/o7vWMEhsQtz6FFS50buBR0bVEFDnKKEuDaQx196wI
	StQbK4JPA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hN0Xx-0002XB-TW; Sat, 04 May 2019 19:42:09 +0000
Date: Sat, 4 May 2019 12:42:09 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	"Barror, Robert" <robert.barror@intel.com>
Subject: Re: Hang / zombie process from Xarray page-fault conversion
 (bisected)
Message-ID: <20190504194209.GB16963@bombadil.infradead.org>
References: <CAPcyv4hwHpX-MkUEqxwdTj7wCCZCN4RV-L4jsnuwLGyL_UEG4A@mail.gmail.com>
 <20190311150947.GD19508@bombadil.infradead.org>
 <CAPcyv4jG5r2LOesxSx+Mdf+L_gQWqnhk+gKZyKAAPTHy1Drvqw@mail.gmail.com>
 <20190312043754.GD23020@dastard>
 <CAPcyv4i+z0RT7rTw+4w-h8dOyscVk1g3F+cu2pKHqqJjTgU++A@mail.gmail.com>
 <20190315022604.GO26298@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190315022604.GO26298@dastard>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 15, 2019 at 01:26:04PM +1100, Dave Chinner wrote:
> On Thu, Mar 14, 2019 at 12:34:51AM -0700, Dan Williams wrote:
> > On Mon, Mar 11, 2019 at 9:38 PM Dave Chinner <david@fromorbit.com> wrote:
> > >
> > > On Mon, Mar 11, 2019 at 08:35:05PM -0700, Dan Williams wrote:
> > > > On Mon, Mar 11, 2019 at 8:10 AM Matthew Wilcox <willy@infradead.org> wrote:
> > > > >
> > > > > On Thu, Mar 07, 2019 at 10:16:17PM -0800, Dan Williams wrote:
> > > > > > Hi Willy,
> > > > > >
> > > > > > We're seeing a case where RocksDB hangs and becomes defunct when
> > > > > > trying to kill the process. v4.19 succeeds and v4.20 fails. Robert was
> > > > > > able to bisect this to commit b15cd800682f "dax: Convert page fault
> > > > > > handlers to XArray".
> > > > > >
> > > > > > I see some direct usage of xa_index and wonder if there are some more
> > > > > > pmd fixups to do?
> > > > > >
> > > > > > Other thoughts?
> > > > >
> > > > > I don't see why killing a process would have much to do with PMD
> > > > > misalignment.  The symptoms (hanging on a signal) smell much more like
> > > > > leaving a locked entry in the tree.  Is this easy to reproduce?  Can you
> > > > > get /proc/$pid/stack for a hung task?
> > > >
> > > > It's fairly easy to reproduce, I'll see if I can package up all the
> > > > dependencies into something that fails in a VM.
> > > >
> > > > It's limited to xfs, no failure on ext4 to date.
> > > >
> > > > The hung process appears to be:
> > > >
> > > >      kworker/53:1-xfs-sync/pmem0
> > >
> > > That's completely internal to XFS. Every 30s the work is triggered
> > > and it either does a log flush (if the fs is active) or it syncs the
> > > superblock to clean the log and idle the filesystem. It has nothing
> > > to do with user processes, and I don't see why killing a process has
> > > any effect on what it does...
> > >
> > > > ...and then the rest of the database processes grind to a halt from there.
> > > >
> > > > Robert was kind enough to capture /proc/$pid/stack, but nothing interesting:
> > > >
> > > > [<0>] worker_thread+0xb2/0x380
> > > > [<0>] kthread+0x112/0x130
> > > > [<0>] ret_from_fork+0x1f/0x40
> > > > [<0>] 0xffffffffffffffff
> > >
> > > Much more useful would be:
> > >
> > > # echo w > /proc/sysrq-trigger
> > >
> > > And post the entire output of dmesg.
> > 
> > Here it is:
> > 
> > https://gist.github.com/djbw/ca7117023305f325aca6f8ef30e11556
> 
> Which tells us nothing. :(

Nothing from a filesystem side, perhaps, but I find it quite interesting.

We have a number of threads blocking in down_read() on mmap_sem.  That
means a task is holding the mmap_sem for write, or is blocked trying
to take the mmap_sem for write.  I think it's the latter; pid 4650
is blocked in munmap().  pid 4673 is blocking in get_unlocked_entry()
and will be holding the mmap_sem for read while doing so.

Since this is provoked by a fatal signal, it must have something to do
with a killable or interruptible sleep.  There's only one of those in the
DAX code; fatal_signal_pending() in dax_iomap_actor().  Does rocksdb do
I/O with write() or through a writable mmap()?  I'd like to know before
I chase too far down this fault tree analysis.

My current suspicion is that we have a PMD fault being not-woken by a PTE
modification, and the evidence seems to fit, but I don't quite see it yet.

(I meant to ask Dan about this while we were in San Juan, but with all
the other excitement, it slipped my mind).

