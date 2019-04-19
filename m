Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15D51C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 18:33:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4CF3204EC
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 18:33:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="vKnIY9ql"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4CF3204EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F03EC6B0003; Fri, 19 Apr 2019 14:33:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8D656B0006; Fri, 19 Apr 2019 14:33:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D55626B0007; Fri, 19 Apr 2019 14:33:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id B3D7C6B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 14:33:03 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id x194so4546763ybg.12
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 11:33:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2l+yySfkbLjZ7A6AZC9+tOMoDXh431piIaB1MqjCE0s=;
        b=aHDESuEKKxia7110mv3o5A+7oCVE+BWWBGaE6YqmFFz2Edew+pVjB2f4gZ4SLgNbXX
         J4cLY92yoCVf+rJRPoxgt7IWqGtEq0s1C3umeWdu4MuoVaMfF1PHoOZsfdueHchVQ9Pm
         0KApLy7Q/hcTD/YNjMcITTpuzgsiwcqq8xgDeSA5vr/s3NDWNzrxy1MkIe6Ts7qQ4TU8
         rRbahRMax1fxtTF3MoxWr/Nn4pvWuJtIcYL0cQwc1yYMRJ0mM4AdrLlOB72Rw/J5ewfy
         RJVJxwZZAJIQ2hU71Z0CH0U2kOYhaLX2OUOFuUFHj+fpiayz+Nf8SkDoXv2EqX3w/oYP
         dhUw==
X-Gm-Message-State: APjAAAUBPj7tnrHr1db/u8A8ZKpecAIbsbnAEkJ7RM1KnLNcDKfoKcCI
	kGZHLt0IqkjQ7QGLjZMhCJ044gf6FFZ0Yl32SlQczPa0BCGAJ9P7XFqYJ8X59ZrH8SdWTPZ48ti
	FE1lL1SZcvEU5hYNVDVcnmJAmio9Ic9f10OCbweEa8pUWB/Eq8YTLx/CEGUWageY=
X-Received: by 2002:a25:34c1:: with SMTP id b184mr4525633yba.109.1555698783369;
        Fri, 19 Apr 2019 11:33:03 -0700 (PDT)
X-Received: by 2002:a25:34c1:: with SMTP id b184mr4525582yba.109.1555698782610;
        Fri, 19 Apr 2019 11:33:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555698782; cv=none;
        d=google.com; s=arc-20160816;
        b=CB0I6WHbmgkiievp+3/3M/XYgCWf+vAIiP2tr/wqwMF03eBZATrrVsfElBK7fcjRdt
         33Y4ApwpY7sOiLe9AAShaFac76n6Lxc6rWUYWhx5VMeYOHtQKGaqHz/HjZBHttXAgXyN
         5DNqot9JguORLRQWLtgXokFV+D9fqvjyYUoIpyuUHSL/Kiuk+CU2LtZtsVQNZuff3Jqy
         /gFvsHXJc2lPBxqv57vY27thPV3V8DZw2ZLWycRyegzmS+aAtEBXBFBB1WOFAfJqnfqC
         app2YsRZQdRQHmF2H2tw9MnFI8YJrXfmUN/GLZobcj5ZqMia+GQmVHyBdrTDJWtRgxHG
         qdzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=2l+yySfkbLjZ7A6AZC9+tOMoDXh431piIaB1MqjCE0s=;
        b=JrlSisEw2aSiNPp7lgVQX5aG12+XwJNbYTXORdvRGlrKOvI2I9BBhKcRZBBiVfEsDm
         BZiukopIksbeyaiam3AnVmk3Yinxrku4a9Ne5mfFV1mOxokccfHzfdd736P8Ywbfk+g9
         ebzdnqLFzPWvDm4RqjQC/L+cWYuNm4Q0ZOYZ2kZqN8oUGA1Ql5xbPGxVBTdvozhqM5K8
         LHXh2Y8kUk6rtou4y5nO7JLDPDDcEZig3myNy1QjK/n6EzGp01Lt2DJWobrnsZc99TC2
         e+7ooEcesHAsiKYr1Cq9LmMvj+hitYAVv0tHCNiNK2J8LdHXLcG4EoJ+Yt8nyXq0ANrF
         EICw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=vKnIY9ql;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 125sor2552725yby.89.2019.04.19.11.33.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Apr 2019 11:33:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=vKnIY9ql;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=2l+yySfkbLjZ7A6AZC9+tOMoDXh431piIaB1MqjCE0s=;
        b=vKnIY9qlcjEO4/xDKBuqisY4tcwNmuKVqmCCvxrmrgFg/BrWrtslw026dmHPjKt8wS
         4LVM9r4aXHdN2ms11Xc2uYNc1ZDRZcuugF886rirSgFnjYk+XrtDOr0jcGDN8Ou0v5p0
         2/EIxdHhlD4MfJkcokn63HtB+oVXq8znFxW6UI2IKtAjc7WHfQqBkj/Gf3QGxYnPd/Mo
         LIc9FlMJw9M1tZt1pkq9nvNGVbPpdO1CB7HbO3dFBlLZQtBGT+QrTcPN6a0yBEGMOXU6
         3kpRxeL5VYzfTbypmKGkQfsRJ44nBEy3Or1cSa9rOBpfKXk5yMlAPDj/5ikbY4sSiAUe
         H+vA==
X-Google-Smtp-Source: APXvYqxTuWsfhu6f6r5ali0UF2xMpp1330DZSyg/0vvk0URbiRBgcdOt0kyrcOvQjDDarprKxwZZVQ==
X-Received: by 2002:a25:858d:: with SMTP id x13mr4733139ybk.38.1555698782082;
        Fri, 19 Apr 2019 11:33:02 -0700 (PDT)
Received: from localhost ([2620:10d:c091:180::2162])
        by smtp.gmail.com with ESMTPSA id k123sm1811854ywa.57.2019.04.19.11.33.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 11:33:00 -0700 (PDT)
Date: Fri, 19 Apr 2019 11:32:58 -0700
From: Tejun Heo <tj@kernel.org>
To: Jiufei Xue <jiufei.xue@linux.alibaba.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
	joseph.qi@linux.alibaba.com, bo.liu@linux.alibaba.com
Subject: Re: [PATCH v3] fs/writeback: use rcu_barrier() to wait for inflight
 wb switches going into workqueue when umount
Message-ID: <20190419183258.GI374014@devbig004.ftw2.facebook.com>
References: <20190418020426.89259-1-jiufei.xue@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190418020426.89259-1-jiufei.xue@linux.alibaba.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 10:04:26AM +0800, Jiufei Xue wrote:
> synchronize_rcu() didn't wait for call_rcu() callbacks, so inode wb
> switch may not go to the workqueue after synchronize_rcu(). Thus
> previous scheduled switches was not finished even flushing the
> workqueue, which will cause a NULL pointer dereferenced followed below.
> 
> VFS: Busy inodes after unmount of vdd. Self-destruct in 5 seconds.  Have a nice day...
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000278
> [<ffffffff8126a303>] evict+0xb3/0x180
> [<ffffffff8126a760>] iput+0x1b0/0x230
> [<ffffffff8127c690>] inode_switch_wbs_work_fn+0x3c0/0x6a0
> [<ffffffff810a5b2e>] worker_thread+0x4e/0x490
> [<ffffffff810a5ae0>] ? process_one_work+0x410/0x410
> [<ffffffff810ac056>] kthread+0xe6/0x100
> [<ffffffff8173c199>] ret_from_fork+0x39/0x50
> 
> Replace the synchronize_rcu() call with a rcu_barrier() to wait for all
> pending callbacks to finish. And inc isw_nr_in_flight after call_rcu()
> in inode_switch_wbs() to make more sense.
> 
> Suggested-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Jiufei Xue <jiufei.xue@linux.alibaba.com>
> Cc: stable@kernel.org

Except for the documentation part that Andrew raised,

  Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

