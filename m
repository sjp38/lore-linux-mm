Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89295C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:32:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 503E32087F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:32:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 503E32087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5A2E6B0005; Thu, 18 Apr 2019 18:32:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D0AC76B0006; Thu, 18 Apr 2019 18:32:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFB256B0007; Thu, 18 Apr 2019 18:32:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 88C6C6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 18:32:23 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id w9so2271935plz.11
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 15:32:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GEiCuoZAYbdPKxpNyGlQYH3PW/YRxUU2QkJ7WI7n6r0=;
        b=HIv5Jq2YClG43pDwaRjYbe1DxjkU1L6dD0vNW0MHsnGxjFLmDhdyiIDlGf0KmtD0CI
         mM0Kzq9pUhU5qyeVu5rEBPOAuBG8ndZykqwwyNhJ1plPGle4/PMC+jVrswFdtL7+lbbB
         r+CgqmsuwySwVSIDZNPg1+gpM/QrYqCnsS3XOjA7j1BDaBBNcGI6uWTm+OrjsOgzE7I4
         VjPwu1mL4YP8cEN3hjTvSQMSp5QGr1Mq9m0xeBfKblr9LnduFrEDIUUUSU3ug7QWpJUV
         RurHSoFMm9rA8YFjHLBSKo7DurP1KWFnUl5msuiaA5nKoasZ86dGb/SqjcNzWIyhKfJH
         pQLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAUJ5IRp8QtKnPtBlRIP/5/SWGHCY5LFHeqxzRiXf/1qLuNV4cbW
	tWmPGT4pWhleoseHBUrIQZb+G3/FL+Y0X8xVjpNlsWdOI4KY71fRFw01jtpUb92eT1rS9AD4m8d
	t8D9K6O8OfVudyzN1mnQUmOvkvXTdQBHf7N4KG61uLko16nuUqXlpt0Ehpadw/WQlag==
X-Received: by 2002:a63:2bc8:: with SMTP id r191mr474080pgr.72.1555626743211;
        Thu, 18 Apr 2019 15:32:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx786WWRJui2chgPQlpwweuVMb2S2gyzUVYS4M+bTH+ES8rPHGi1zj9/mscXZk2L4iNpR51
X-Received: by 2002:a63:2bc8:: with SMTP id r191mr474026pgr.72.1555626742527;
        Thu, 18 Apr 2019 15:32:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555626742; cv=none;
        d=google.com; s=arc-20160816;
        b=OMbGtiGiCatpWC7mgBBRKcR8I/FeOMrUsDco3C3HrV0wy5hNBmzmff4OlB9H7bfUwA
         DccFqrfeLIaDDhIDlxnDbaU7TQYbr+xInVVhJkv8sWE/HuBtNUlpGAmo+YHwR/up06sX
         tWIFQTX2BHNIAN+XnSe1cn7lm/pL5SlU4dr+/FFk6gFPIgXb17dJuhIe7+HSNDumSHGZ
         M5/9De2kbYMHCtMmp/HaFbCJIyc12/Y4CXRq3LYiHrHfZZ5WbPWigLABO1dbycJX/x5j
         M6LyYXxVrt9IXyotnwkuIC8XpTLP+fhU07adACgGMfIaaoTLFkn0h6dalqW0YbUN6xw4
         bIcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=GEiCuoZAYbdPKxpNyGlQYH3PW/YRxUU2QkJ7WI7n6r0=;
        b=alQH5ED7jBETLUbX4PXjoMaE/c0w7/WdvkXAN7nSn1LU0+B1wn1SH1nLkHuLFTqJkk
         ZBB+4TNeWY2sy+IxhOmUfo5Ga7LwDfBT3Z0o6qIajp75bdaSZ7l3YVgHXoci1PhPXNQr
         fL8VE5zE0Sd7cojOfj7DqEWCrY2XrG2yKOotiCbc+S7ulJehWBCFhXUuxIaD2TJcliY1
         tu9wbWFKbTgIoDLLskivBlWf9NY4QKATKy9LN6ePFVZF+3TRHDTAf4Y9n1yamqM4jfMe
         OMUQZLkWNVJU6KRQrJHGoMMUqqMIVsiNlkRoq46X4d8OFEcedToIa8AkgshjQtDr2JsV
         tmJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 25si2948452pgx.421.2019.04.18.15.32.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 15:32:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 0F0AB1C58;
	Thu, 18 Apr 2019 22:32:22 +0000 (UTC)
Date: Thu, 18 Apr 2019 15:32:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Jiufei Xue <jiufei.xue@linux.alibaba.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org,
 joseph.qi@linux.alibaba.com, bo.liu@linux.alibaba.com
Subject: Re: [PATCH v3] fs/writeback: use rcu_barrier() to wait for inflight
 wb switches going into workqueue when umount
Message-Id: <20190418153221.6f7314787bddde5f32b8513c@linux-foundation.org>
In-Reply-To: <20190418020426.89259-1-jiufei.xue@linux.alibaba.com>
References: <20190418020426.89259-1-jiufei.xue@linux.alibaba.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Apr 2019 10:04:26 +0800 Jiufei Xue <jiufei.xue@linux.alibaba.com> wrote:

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
> ...
>
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
>
> ...
>
> @@ -901,7 +902,7 @@ static void bdi_split_work_to_wbs(struct backing_dev_info *bdi,
>  void cgroup_writeback_umount(void)
>  {
>  	if (atomic_read(&isw_nr_in_flight)) {
> -		synchronize_rcu();
> +		rcu_barrier();
>  		flush_workqueue(isw_wq);
>  	}
>  }

it would be nice to have a comment here explaining why the barrier is
being performed.

