Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4D87C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 22:51:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D3DD2075C
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 22:51:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="udGtqzg6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D3DD2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B43EC6B0005; Tue, 19 Mar 2019 18:51:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF2F26B0006; Tue, 19 Mar 2019 18:51:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E1806B0007; Tue, 19 Mar 2019 18:51:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 568236B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 18:51:54 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u8so430249pfm.6
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:51:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=yAp+q49agDeOxIr3K1jrtyVFou1CeqqLCoEHJhnF1yg=;
        b=ibypbaUWJxcNLddV26qZY56AXGy/10iKTs99AS6l6D/xlc/06x8V8F8w/qwkfRbZfw
         sQnk/GsikqWxN1pJbwEcJyx34ewq2pseO0RX0prIaa85eC8ClVUdfc0rvhHNpuQJP+Wo
         QplrOQ8faCKMZL4kTxW58sHAi1K45+C3QScLcInVYei5JBk/AgZmxGFmu055/trk6hqt
         zNPj5II+LS0QZhktSEokdBuupCHPprNb2qTrndpjCT9PkpcdQ2VbgTBjlx1MP5RYEmJ/
         ETWUHuySHyLNv0aQt+f7YNX+bH6g+Q1Nm45XAghfhNTJDNYMIlqPgEtdFenwaHnKRFFE
         GdIA==
X-Gm-Message-State: APjAAAXOZHRdddtElF6p+/N1sxyQ0BDvMO76yvvun2h4JF7BCS7l41kM
	TNY1RtAeHFQ+vWkun9vdx4nvDWnm+LIqVMs13qowsPGL2bJPdxY40H68OT5YJYUOcqDaJtrfgyp
	KzuT9WhrmqtuZsn+IPELRDdyHy3C9hFjXuFDBnBFOkZ9uu8rNpfhDcpMb8rOL2Qk=
X-Received: by 2002:a17:902:b708:: with SMTP id d8mr4400615pls.322.1553035913913;
        Tue, 19 Mar 2019 15:51:53 -0700 (PDT)
X-Received: by 2002:a17:902:b708:: with SMTP id d8mr4400546pls.322.1553035912634;
        Tue, 19 Mar 2019 15:51:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553035912; cv=none;
        d=google.com; s=arc-20160816;
        b=Bk5oRal8YecBhcGZ/Lql8FXW9iaUHDXql6tboFvd/vioYbarQG+1B2PFgEcn9Nutxj
         NrW8k3VGWX0ypTOuAGRJXGqe3aGFvExfA3JdMmiFc1IcpIG6wHWwICAHuty36p7khU9V
         2qq1q5GTjKwOaPre6LuaGSxIWw6iuOT0+E/RoDK7+WaXJ492+49DRYhsb1JmCuTf72EG
         NOxMnYU5o+se4LG4OoYngSb+cQvcnT5VegByY6mVSi7zF3ftgD4e59bt2K78OtGda3+g
         ofQfIMuFPaXNK4fDQRJEgaS6FSBdKaVb3BKKaF4F7o7yqw74pUfUzyT9quE7t4R0pyyI
         J3bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=yAp+q49agDeOxIr3K1jrtyVFou1CeqqLCoEHJhnF1yg=;
        b=I29z8MlS4y0yz9p9H7kMfUy3m3tPvstWHIPRrHzUXxL6wLYyyMbwGs1d9LMGze9x4Z
         mntvEifAVyrj2OUz+Wa3ssm82P5+NRg/Lc42FAMCO+z+PWukckY9/DCL5ykVQ4RabHGm
         +NpBxOKSd5CvgI5CFES8RH/t124j5SjJXrNRp2a5MyCltiPzMyY77vgOjTvxtGoXCUO6
         /2bSwKEy5fU+4Km9fggn4eC7+2vHD+OSu9Zk18euKBlKdig/m5VpjlwtWrKtkC6bbU8W
         zIabxw2bXPnS2yY9h4ogCNHWlNvYsuMTCIlxWNcGCZJnljwclsz0LBgxnyF3bewteTOU
         Ln8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=udGtqzg6;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h7sor491426plb.46.2019.03.19.15.51.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 15:51:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=udGtqzg6;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=yAp+q49agDeOxIr3K1jrtyVFou1CeqqLCoEHJhnF1yg=;
        b=udGtqzg6Pe5kqOYN7GgQkm+Qaycc3mRpNgQ9FbYKZnQEXNG9W19HZsAoiNJ7Iow3Av
         608Sk43rqb8eo0zB5PRDYeaC3NpHccL/cZeXxuc8F0f9rnDs6KAVNJZWY0mpjB5tB0X5
         ye/zPST7ir902ux1ERoubm4t4b13T+fHN4hJepx19epv6YQG6M989fVCLSlPmib+7Lt5
         bSDvqtK7f5Wqxw+WNVOyVkZ3W0Z6QOmt0w5svukcQ0nDZ/lLKz0DH/G6PAmPQq2E0KIK
         YbRroR0swYibF7GHXcvWY3/jL/n4AEWqSkNFUq3wzwTvRY6dl1J5vkbDiW4T2aXprONQ
         tVkw==
X-Google-Smtp-Source: APXvYqxpBYZHXxI5ZiAmYBj4YPdhgYj3d3yenCYxuh9NFKurrYb21G7Nc9d0OjGpLdE+ntSPhjFEJQ==
X-Received: by 2002:a17:902:ea8c:: with SMTP id cv12mr4814581plb.123.1553035911561;
        Tue, 19 Mar 2019 15:51:51 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id z15sm82620pgc.25.2019.03.19.15.51.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Mar 2019 15:51:50 -0700 (PDT)
Date: Wed, 20 Mar 2019 07:51:44 +0900
From: Minchan Kim <minchan@kernel.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, lizefan@huawei.com,
	hannes@cmpxchg.org, axboe@kernel.dk, dennis@kernel.org,
	dennisszhou@gmail.com, mingo@redhat.com, peterz@infradead.org,
	akpm@linux-foundation.org, corbet@lwn.net, cgroups@vger.kernel.org,
	linux-mm@kvack.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@android.com
Subject: Re: [PATCH v5 0/7] psi: pressure stall monitors v5
Message-ID: <20190319225144.GA80186@google.com>
References: <20190308184311.144521-1-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190308184311.144521-1-surenb@google.com>
User-Agent: Mutt/1.10.1+60 (6df12dc1) (2018-08-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 10:43:04AM -0800, Suren Baghdasaryan wrote:
> This is respin of:
>   https://lwn.net/ml/linux-kernel/20190206023446.177362-1-surenb%40google.com/
> 
> Android is adopting psi to detect and remedy memory pressure that
> results in stuttering and decreased responsiveness on mobile devices.
> 
> Psi gives us the stall information, but because we're dealing with
> latencies in the millisecond range, periodically reading the pressure
> files to detect stalls in a timely fashion is not feasible. Psi also
> doesn't aggregate its averages at a high-enough frequency right now.
> 
> This patch series extends the psi interface such that users can
> configure sensitive latency thresholds and use poll() and friends to
> be notified when these are breached.
> 
> As high-frequency aggregation is costly, it implements an aggregation
> method that is optimized for fast, short-interval averaging, and makes
> the aggregation frequency adaptive, such that high-frequency updates
> only happen while monitored stall events are actively occurring.
> 
> With these patches applied, Android can monitor for, and ward off,
> mounting memory shortages before they cause problems for the user.
> For example, using memory stall monitors in userspace low memory
> killer daemon (lmkd) we can detect mounting pressure and kill less
> important processes before device becomes visibly sluggish. In our
> memory stress testing psi memory monitors produce roughly 10x less
> false positives compared to vmpressure signals. Having ability to
> specify multiple triggers for the same psi metric allows other parts
> of Android framework to monitor memory state of the device and act
> accordingly.
> 
> The new interface is straight-forward. The user opens one of the
> pressure files for writing and writes a trigger description into the
> file descriptor that defines the stall state - some or full, and the
> maximum stall time over a given window of time. E.g.:
> 
>         /* Signal when stall time exceeds 100ms of a 1s window */
>         char trigger[] = "full 100000 1000000"
>         fd = open("/proc/pressure/memory")
>         write(fd, trigger, sizeof(trigger))
>         while (poll() >= 0) {
>                 ...
>         };
>         close(fd);
> 
> When the monitored stall state is entered, psi adapts its aggregation
> frequency according to what the configured time window requires in
> order to emit event signals in a timely fashion. Once the stalling
> subsides, aggregation reverts back to normal.
> 
> The trigger is associated with the open file descriptor. To stop
> monitoring, the user only needs to close the file descriptor and the
> trigger is discarded.
> 
> Patches 1-6 prepare the psi code for polling support. Patch 7 implements
> the adaptive polling logic, the pressure growth detection optimized for
> short intervals, and hooks up write() and poll() on the pressure files.
> 
> The patches were developed in collaboration with Johannes Weiner.
> 
> The patches are based on 5.0-rc8 (Merge tag 'drm-next-2019-03-06').
> 
> Suren Baghdasaryan (7):
>   psi: introduce state_mask to represent stalled psi states
>   psi: make psi_enable static
>   psi: rename psi fields in preparation for psi trigger addition
>   psi: split update_stats into parts
>   psi: track changed states
>   refactor header includes to allow kthread.h inclusion in psi_types.h
>   psi: introduce psi monitor
> 
>  Documentation/accounting/psi.txt | 107 ++++++
>  include/linux/kthread.h          |   3 +-
>  include/linux/psi.h              |   8 +
>  include/linux/psi_types.h        | 105 +++++-
>  include/linux/sched.h            |   1 -
>  kernel/cgroup/cgroup.c           |  71 +++-
>  kernel/kthread.c                 |   1 +
>  kernel/sched/psi.c               | 613 ++++++++++++++++++++++++++++---
>  8 files changed, 833 insertions(+), 76 deletions(-)
> 
> Changes in v5:
> - Fixed sparse: error: incompatible types in comparison expression, as per
>  Andrew
> - Changed psi_enable to static, as per Andrew
> - Refactored headers to be able to include kthread.h into psi_types.h
> without creating a circular inclusion, as per Johannes
> - Split psi monitor from aggregator, used RT worker for psi monitoring to
> prevent it being starved by other RT threads and memory pressure events
> being delayed or lost, as per Minchan and Android Performance Team
> - Fixed blockable memory allocation under rcu_read_lock inside
> psi_trigger_poll by using refcounting, as per Eva Huang and Minchan
> - Misc cleanup and improvements, as per Johannes
> 
> Notes:
> 0001-psi-introduce-state_mask-to-represent-stalled-psi-st.patch is unchanged
> from the previous version and provided for completeness.

Please fix kbuild test bot's warning in 6/7
Other than that, for all patches,

Acked-by: Minchan Kim <minchan@kernel.org>

