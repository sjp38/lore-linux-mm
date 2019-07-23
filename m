Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAC78C76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 20:07:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C0DC229ED
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 20:07:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="VX9USo4G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C0DC229ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24B656B0003; Tue, 23 Jul 2019 16:07:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FC7E6B0006; Tue, 23 Jul 2019 16:07:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C5178E0002; Tue, 23 Jul 2019 16:07:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD5D36B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 16:07:31 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 30so26639924pgk.16
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:07:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZntkhR/MjdnyK0PhxheS9Wlw6tPL8jPh6o65Whx0Y5w=;
        b=EGBXYJrCF/7EcNklK8hzYJ0Isexw3FVMj22SZRI9u6ONis0S0q9tXvCh3Pgy5vUS83
         PW6jAqsoUhFoX63dDg6Z2mqYAGFzMBG8ra3gFgZncohN1EdiXpH+zlAkVu3oDHFJ3qPi
         QWHR0YBOiLHDKoKx8Sgk50nhlMfBDeEn4QUVQ7Xj5x8raGilFH+ujNx+CHSgoWaJYCPL
         884A8g1iC7uLxJSFptPEWvtcvNEDgglJaYiiE+84Bay4SaGKqOTra6E89Yb+QREkRRvN
         saSAtOwGfFoOBj3NQG7gGsb1G8ux7fa3Fd8J36Z9iW+7f2YibgKJpOr5epHuXWnNS6em
         mcyg==
X-Gm-Message-State: APjAAAWc0eEoNOH2Cu8pllPQwUkqVhB9O0htiwaHz8Nrg105cuxPYnfs
	dAlwxU5X/8oxDFUG2Bxyifijj1lOxujGCJRwdmIFfvZ3e7Skb0xesJEqDZ2TunS557+HWL9ObWI
	VFI+tSLrruirSDGyJgLjE/Jcy9Cq9/4EgakzGJtrDcmlt6ZDVBftx9zS3VRRmF8yyuQ==
X-Received: by 2002:a62:e315:: with SMTP id g21mr7748299pfh.225.1563912451427;
        Tue, 23 Jul 2019 13:07:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAGuzt0l/DJuJsm2Qc+5KHwQCW1/R2bCPoJTipw4sks3B2FtJbUX49klcoFYYAoVu6jk9M
X-Received: by 2002:a62:e315:: with SMTP id g21mr7748237pfh.225.1563912450759;
        Tue, 23 Jul 2019 13:07:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563912450; cv=none;
        d=google.com; s=arc-20160816;
        b=WDJ6Es6SQBsuOlOycGrMYv8gcj/trvUxxYo5D57ixQ5LEUQn+vOBLIpH28w2vmZeiG
         UjsRT7Co+Xx1KIKiLUQEeOks5hzObKXfq+yo7XKH48Wj7TB2hsZxd11gr2tPioO6l6pm
         Ezw5as2qL5mmktIhwcPH0aKAddPP49yvjHtGvq85Hh/GWVibpuiKrW9awKzXeEfBktQI
         6wde6AeO49LR7EyQiG2x4zQSX42tLlBK0RrsdLlEBHs+y+B0bkgXPwIqTvD0t9loV5hR
         u80J794CLXdNzASxBYxf6Tw+swzXTfsmV4DtO+agvuYpjcNAVlypwvrOmrz8XKGyMXZ9
         VBLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ZntkhR/MjdnyK0PhxheS9Wlw6tPL8jPh6o65Whx0Y5w=;
        b=cKz85cNMYxr0mvhE5rG0MBRHY2RQGBVuGORhVfVuZPec16awgCOI0Wilgw2oX81Lxj
         y5gMX+QMPjbHC3hqmFBBcszAiZxqh7cqesBkT8JYul4dHu9vjmUGXmh1oqBVS/lj4ArB
         jqZbK1LFqigTWhDrExp+GymGD8HnJbRFzx9cSQexvIfDlWQh21m7Iac3185QGJyWm8Z7
         1phRs54/3gN4bbF3LQXUKpmsGEzj61dmQmOVggYjU/B37cqtPN61XA2DauPtADKSrz92
         IgefHoRk/NrFhjo0k51KaZdj3mfs793DHWziXjkUfpxc5cyAsq7um9PAgdr7Vo4Q6DpO
         I9SQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=VX9USo4G;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g127si3234668pgc.128.2019.07.23.13.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 13:07:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=VX9USo4G;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.64])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0D4F32084D;
	Tue, 23 Jul 2019 20:07:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563912450;
	bh=aJAwIMG/PcNFQKUZTnI3xqTnmOSc6qBWaaEdBvulUpA=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=VX9USo4Gy2dVgkf+TNz6HITq9P3GchWQKOUSzY/le0qD3BWAE3Fbfj7zdKjsmUOzb
	 Dd1tT7mXRLQHqbUBmsJ2jqrXD2UEQHY2yKfHn0GeQXCYvKA/9zMzwnYY5F7fXbovHX
	 FImaoH6ldCnadpDFM15AqXu4eNYu4RKODmNdv8DM=
Date: Tue, 23 Jul 2019 13:07:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org, Tejun Heo
 <tj@kernel.org>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner
 <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/backing-dev: show state of all bdi_writeback in
 debugfs
Message-Id: <20190723130729.522976a1f075d748fc946ff6@linux-foundation.org>
In-Reply-To: <156388617236.3608.2194886130557491278.stgit@buzz>
References: <156388617236.3608.2194886130557491278.stgit@buzz>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Jul 2019 15:49:32 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:

> Currently /sys/kernel/debug/bdi/$maj:$min/stats shows only root bdi wb.
> With CONFIG_CGROUP_WRITEBACK=y there is one for each memory cgroup.
> 
> This patch shows here state of each bdi_writeback in form:
> 
> <global state>
> 
> Id: 1
> Cgroup: /
> <root wb state>
> 
> Id: xxx
> Cgroup: /path
> <cgroup wb state>
> 
> Id: yyy
> Cgroup: /path2
> <cgroup wb state>

Why is this considered useful?  What are the use cases.  ie, why should
we add this to Linux?

> mm/backing-dev.c |  106 +++++++++++++++++++++++++++++++++++++++++++++++-------
> 1 file changed, 93 insertions(+), 13 deletions(-)

No documentation because it's debugfs, right?

I'm struggling to understand why this is a good thing :(.  If it's
there and people use it then we should document it for them.  If it's
there and people don't use it then we should delete the code.

