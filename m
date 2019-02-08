Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34FD6C282CB
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 22:49:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED566218DA
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 22:49:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED566218DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C24B8E00A7; Fri,  8 Feb 2019 17:49:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9719D8E00A1; Fri,  8 Feb 2019 17:49:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 860338E00A7; Fri,  8 Feb 2019 17:49:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4482B8E00A1
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 17:49:47 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id p20so3765693plr.22
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 14:49:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2lSHGXZfH4k0xznVbv6PnmIyJYLA9fItLH6w1A69cmo=;
        b=Wh9tgCLjUef9ypuPTivTwFK/r9JjTh4+vPwyeFGbyd4x4h3s060S3n/gRyW8uqMjti
         HjVrqZkRnhlhNLJhMJSLIO/vMxlm0D3pSLrOfG9uwybm/lVtoHwISRSx839KDm/dR+UM
         OnfzXoxYFReF5M8K8Y7qTSpqO2oMKsKFFy1m2D2+e0DXiaAjNDYc+k2cPIIT6JXWNK8n
         ir+UfW2FcIWuII6VY6ONjgxMCru9vzMwVIQl4ztAGZK4cIIXx2qQNz2roYNU3hW3sg+B
         ns/SeI1a/DAIFMCN3+jKA0c4lUnZ1Sp4xPu+xvNE5iZEIXxQ6iPAqQRihNpAkmiEEU1D
         LRXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuZ7oi8eDeUtu66Cz/mDBGPfq/OLpKbKRaLTe+tMUV57CcMOsouC
	8ovUA1269lje/eMXxo8v/zrLuz8a94Lit13sKtBlQnZqX334MOOMfnrd/7brkU8zW6qPyooeF1j
	tziWCon6Ky6X7aDQ7TxwUVk7ed+SK+nWXtxX+gAtHg9Hp2EuByGn9tafgAJufE+arrw==
X-Received: by 2002:a17:902:50e3:: with SMTP id c32mr25300816plj.318.1549666186935;
        Fri, 08 Feb 2019 14:49:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYqXm1LSjJ98hD11XmZ5Nk/sYgsgsAxjjH3LTr7+km3ph7C85b5XGp4SAZLR7uyiZLctPLj
X-Received: by 2002:a17:902:50e3:: with SMTP id c32mr25300768plj.318.1549666186163;
        Fri, 08 Feb 2019 14:49:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549666186; cv=none;
        d=google.com; s=arc-20160816;
        b=x9OnEcdikT3LQnvThejs164aOZicTtMAEUGXariB43P1K//bvV8w08FPQVnLpm6Xq4
         QcHuYpYJKCVyV5iz+dLxd7u1qbdhbIC/GXmyvFPEGzrdbuBs/ATuME4wNk/HysVQFUC3
         s/2lIG/m/DJYoKNZh+aZfpRNd7YJYQIwz1o0b0DDk5j5kMnmmYC5V0ZIMEbqPIyHD9Fk
         26oSkHLiOgHVrBAHR+0QHiV1onH1Ewdz5XtZ7j4XYVIObJ5o4hlVdzXTVXdLCfGOo0tF
         Xh7GWb1nIoikVzmeGaKxEpkOBpcygiSVZVvhgjD/aAfiebarDiaLQPbX9GODL6+B1WWQ
         6p1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=2lSHGXZfH4k0xznVbv6PnmIyJYLA9fItLH6w1A69cmo=;
        b=nGKbX8K1OlUU5+6VIvc0lYLNphhpzyKRKEmhY2N+bUq1ujJFVfMJRiXzUxn1d6akqu
         UWi5UT5FQIRlQ81f+WHr8r0OV82QFzEvJByGp1EtKPQCVb5Upri7dq8wCIUyDTlQko7P
         QYp4TqnXg5I3gS3Cu2MCJYT6dABAP59Dp4u+YTziEndVnD8Hsfq6GaBEj6pWc/GEAx2K
         DLi65/uKNa9f0e+M4IxSUEbdDK1riS132MXcI1iO02sT/OgRMmR2G0QcCoJS7pW4I00T
         gz2ea9HPJhCh3Rr/bHu7nzrakRrqC1vhtYkCOLI2WWi/Of8VRcVRVM7cVyI+EjKs55x0
         +GHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id az12si3358356plb.78.2019.02.08.14.49.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 14:49:46 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 83684C36C;
	Fri,  8 Feb 2019 22:49:45 +0000 (UTC)
Date: Fri, 8 Feb 2019 14:49:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Roman Gushchin <guro@fb.com>, Michal
 Hocko <mhocko@kernel.org>, Chris Mason <clm@fb.com>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org"
 <linux-fsdevel@vger.kernel.org>, "linux-xfs@vger.kernel.org"
 <linux-xfs@vger.kernel.org>, "vdavydov.dev@gmail.com"
 <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 1/2] Revert
 "mm: don't reclaim inodes with many attached pages"
Message-Id: <20190208144944.082a771e84f02a77bad3e292@linux-foundation.org>
In-Reply-To: <20190208125049.GA11587@quack2.suse.cz>
References: <20190130041707.27750-1-david@fromorbit.com>
	<20190130041707.27750-2-david@fromorbit.com>
	<25EAF93D-BC63-4409-AF21-F45B2DDF5D66@fb.com>
	<20190131013403.GI4205@dastard>
	<20190131091011.GP18811@dhcp22.suse.cz>
	<20190131185704.GA8755@castle.DHCP.thefacebook.com>
	<20190131221904.GL4205@dastard>
	<20190207102750.GA4570@quack2.suse.cz>
	<20190207213727.a791db810341cec2c013ba93@linux-foundation.org>
	<20190208095507.GB6353@quack2.suse.cz>
	<20190208125049.GA11587@quack2.suse.cz>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Feb 2019 13:50:49 +0100 Jan Kara <jack@suse.cz> wrote:

> > > Has anyone done significant testing with Rik's maybe-fix?
> > 
> > I will give it a spin with bonnie++ today. We'll see what comes out.
> 
> OK, I did a bonnie++ run with Rik's patch (on top of 4.20 to rule out other
> differences). This machine does not show so big differences in bonnie++
> numbers but the difference is still clearly visible. The results are
> (averages of 5 runs):
> 
> 		 Revert			Base			Rik
> SeqCreate del    78.04 (   0.00%)	98.18 ( -25.81%)	90.90 ( -16.48%)
> RandCreate del   87.68 (   0.00%)	95.01 (  -8.36%)	87.66 (   0.03%)
> 
> 'Revert' is 4.20 with "mm: don't reclaim inodes with many attached pages"
> and "mm: slowly shrink slabs with a relatively small number of objects"
> reverted. 'Base' is the kernel without any reverts. 'Rik' is a 4.20 with
> Rik's patch applied.
> 
> The numbers are time to do a batch of deletes so lower is better. You can see
> that the patch did help somewhat but it was not enough to close the gap
> when files are deleted in 'readdir' order.

OK, thanks.

I guess we need a rethink on Roman's fixes.   I'll queued the reverts.


BTW, one thing I don't think has been discussed (or noticed) is the
effect of "mm: don't reclaim inodes with many attached pages" on 32-bit
highmem machines.  Look why someone added that code in the first place:

: commit f9a316fa9099053a299851762aedbf12881cff42
: Author: Andrew Morton <akpm@digeo.com>
: Date:   Thu Oct 31 04:09:37 2002 -0800
: 
:     [PATCH] strip pagecache from to-be-reaped inodes
:     
:     With large highmem machines and many small cached files it is possible
:     to encounter ZONE_NORMAL allocation failures.  This can be demonstrated
:     with a large number of one-byte files on a 7G machine.
:     
:     All lowmem is filled with icache and all those inodes have a small
:     amount of highmem pagecache which makes them unfreeable.
:     
:     The patch strips the pagecache from inodes as they come off the tail of
:     the inode_unused list.
:     
:     I play tricks in there peeking at the head of the inode_unused list to
:     pick up the inode again after running iput().  The alternatives seemed
:     to involve more widespread changes.
:     
:     Or running invalidate_inode_pages() under inode_lock which would be a
:     bad thing from a scheduling latency and lock contention point of view.

I guess I shold have added a comment.  Doh.

