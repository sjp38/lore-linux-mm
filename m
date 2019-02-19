Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6571C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 04:16:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE96B21773
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 04:16:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE96B21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4760D8E0003; Mon, 18 Feb 2019 23:16:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FDF18E0002; Mon, 18 Feb 2019 23:16:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29EEB8E0003; Mon, 18 Feb 2019 23:16:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D4C6F8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 23:16:54 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id p20so14004059plr.22
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 20:16:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DGrXzDdhAyqxNhRnyUd0mci9tW2F1GiN1ZUTb3CrkdM=;
        b=rhqJju1d6lPX4AYkMWUC18fr8eBgUQ2qjI0ZS/KChTWTEjRERPZUuaZJfTZCMezmWo
         rKPGnbb7PHWhsh9gSz73kX+KAKzHJ7GhWCx7DBO54YgxxXfnr8f3atluu3bSbq6dAZdK
         kf+20cpLzSGe+ptyEUtQXWyLgEvGBmebExgUuFylBufyzeR5VHohLQGMyNTnb3VVdvDi
         vmVkzpRGlr4GZDw2AXoaavf3NmAn+VHbCtf/s2cQowpo4GuwZcC+4sCwjjpxd3+F71qU
         02o5M4v9MsKROetHDN5tuHnYw3X+R2yFciayfoLuqmK4KSWKhhFoeLFDr4aw0eGpDCmA
         Yv5A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.139 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAuYpjX+gUryUbxBQkXBhVuP6gR/K0DZpGr6lsEWgR7vKpQOUIAGh
	TYDs2R8R74PYOBYXcmZWJCWnzVNojYJeW4I02RmQ1TeMXTk+8ZnsqzJuJfXNHg7Wv3QkuSIw4SG
	4+NUrV+fglAd0W0IObAAk8KdmnMFn3QEfOiy96e4Q70BP80tWgS6VflQoXwjld3w=
X-Received: by 2002:a63:8b43:: with SMTP id j64mr21837992pge.332.1550549814485;
        Mon, 18 Feb 2019 20:16:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYnVwB6RMJatyMOOUJlWz7fUHtzuaeQGE7bZkjCt6IFU8gus3t8RMIjEZQ6MhKqIz/dHK6r
X-Received: by 2002:a63:8b43:: with SMTP id j64mr21837958pge.332.1550549813755;
        Mon, 18 Feb 2019 20:16:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550549813; cv=none;
        d=google.com; s=arc-20160816;
        b=IVCOZK4GlyF70YWKeXh/pTwWMqPRyoa7ER+xJz+sJq0IoM4Bf7mkc5rn83w3OIZyXt
         nD+XFQrWkGOX/PPAXk6m3burdiwMPnHgvfIbpBxuoBnjC1zONI4qfN1E4YlQpnWZ9Chl
         MaiAAsQk2VBZNB5vzhaTCTkOBV6KY8AxJRR82FIWHsmaSpjugGIskcjlB6CbN6QD6uvx
         Tf1RwUmhrk+Yw3MjPH38t7kh793846z6msV+xSaDlC1uvr+iKT9k78F6reQxwvofsjQu
         rc4OQTLPg509wSeIuWefnwW3kZRwMDDot0em1BnaA6OZT7sX9p/mGIQRMglL/tK59WWN
         ipNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DGrXzDdhAyqxNhRnyUd0mci9tW2F1GiN1ZUTb3CrkdM=;
        b=rXcczGBoNsM9AmSYss/ku5/UT686y2IUU2Sa/jijnK1d+K11eEFMNlVd8Jvf9BBiST
         ymQ4ki++Dh8U53xh37lZnOvJ+E6ctZGBHqB455dyArtrbWqDVcck5sku3kOKgF9ub7nt
         +pDdnV+GBghSzANMBEzW/pC9hSRWc72VuCBqaxsGoA5I/aKeLbIy1h2FYqzyYepnqQm7
         a+qcHiHzKV/PCMA0j0icIRnTzr4IUpS4F33mZxJVbbDn2SejbjkVLr7EuBmM832ZpU1x
         2QJDlqzSQ6/5D+YSE99iwaK+QUk5TfzgTiv/gPIyDUjWegINedWhLtKIcKYYyPQj161x
         A2cA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.139 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail02.adl2.internode.on.net (ipmail02.adl2.internode.on.net. [150.101.137.139])
        by mx.google.com with ESMTP id 64si143146plk.172.2019.02.18.20.16.52
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 20:16:53 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.139 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.139;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.139 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail02.adl2.internode.on.net with ESMTP; 19 Feb 2019 14:46:51 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gvwpu-0004Pm-Je; Tue, 19 Feb 2019 15:16:50 +1100
Date: Tue, 19 Feb 2019 15:16:50 +1100
From: Dave Chinner <david@fromorbit.com>
To: Hugh Dickins <hughd@google.com>
Cc: Adam Borowski <kilobyte@angband.pl>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	Marcin Slusarz <marcin.slusarz@intel.com>
Subject: Re: tmpfs fails fallocate(more than DRAM)
Message-ID: <20190219041650.GB15503@dastard>
References: <20190218133423.tdzawczn4yjdzjqf@angband.pl>
 <20190218202534.btgdyr5p3rxoqot7@angband.pl>
 <alpine.LSU.2.11.1902181745010.1241@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1902181745010.1241@eggly.anvils>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 07:35:01PM -0800, Hugh Dickins wrote:
> On Mon, 18 Feb 2019, Adam Borowski wrote:
> > I searched a bit for references that would suggest failed fallocates need to
> > be undone, and I can't seem to find any.  Neither POSIX nor our man pages
> > say a word about semantics of interrupted fallocate, and both glibc's and
> > FreeBSD's fallback emulation don't rollback.
> 
> To me it was self-evident: with a few awkward exceptions (awkward because
> they would have a difficult job to undo, and awkward because they argue
> against me!), a system call either succeeds or fails, or reports partial
> success.  If fallocate() says it failed (and is not allowed to report
> partial success), then it should not have allocated.  Especially in the
> case of RAM, when filling it up makes it rather hard to unfill (another
> persistent problem with tmpfs is the way it can occupy all of memory,
> and the OOM killer go about killing a thousand processes, but none of
> them help because the memory is occupied by a tmpfs, not by a process).
> 
> Now that you question it (did I not do so at the time? I thought I did),
> I try fallocate() on btrfs and ext4 and xfs.  btrfs and xfs behave as I
> expect above, failing outright with ENOSPC if it will not fit;

If only it were that simple. :/

XFS can do partial allocation and fail - it all depends on how many
extent allocations are required before ENOSPC is actually hit. e.g.
if you ask for 10GB and there is only 5GB free, it should fail
straight away. However, if there's 20GB free in 1GB chunks, it will
loop allocating 1GB extents. If something else is allocating at the
same time, the fallocate could get to, say, 8GB allocated and then
hit ENOSPC.

In which case, we'll return the ENOSPC error, but we'll also leave
the 8GB of space already allocated to the file there. i.e. it
doesn't clean up after itself.

The reason for this is that we don't know after we've performed
allocations what regions of the preallocated range were actually
allocated by the preallocation. i.e. fallocate can be run over a
range that already contains some extents - it simply skips over
regions that are already allocated. hence we don't know what we are
supposed to clean up, and so we leave the corpse lying around for
someone else to deal with (e.g. by sparsifying the file again).

> whereas
> ext4 proceeds to fill up the filesystem, leaving it full when it says
> that it failed.

This is much the same behaviour as XFS - you see it more easily with
ext4 because it has much smaller maximum extent size (128MB) than
XFS (8GB) and so needs to iterate multiple allocations sooner than
XFS or btrfs need to.

I'm not sure what btrfs does

> Looks like I had a choice of models to follow: the
> ext4 model would have been easier to follow, but risked OOM.

fallocate() gives you the rope to choose what is best for the
filesystem - it doesn't specify behaviour on failure precisely
because it can be very difficult (not to mention complex!) for
filesystems to unwind partial failures....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

