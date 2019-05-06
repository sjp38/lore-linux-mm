Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBB8AC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 15:31:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93E3D205ED
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 15:31:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FRIaQzP6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93E3D205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F23F6B0005; Mon,  6 May 2019 11:31:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37ACF6B0006; Mon,  6 May 2019 11:31:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F3F46B0007; Mon,  6 May 2019 11:31:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id EDD216B0005
	for <linux-mm@kvack.org>; Mon,  6 May 2019 11:31:40 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id h16so2103971qke.11
        for <linux-mm@kvack.org>; Mon, 06 May 2019 08:31:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/mMrXRGNFAUnlBanOG6lIKcQ2qXCGdgFD/lAGVp5Ijk=;
        b=TvgQ9VFpyr2YhDTUNVVFMIG+A5uhIVVOYNQCayC43bf+SCQtpjyFTy+LODvygD8EN8
         wSnqjT+BadWMWD0tjiZlLQ3nYahud6gZf33NYoK52x2AiJFqWP9H4Nz3RkBmCZMBGd1N
         XLlcC9PfFQbGawOJuKXZuGjbXLqopYhwU+n5EAyj1DKilDYfG4UjOfk3gyaXBspgzK/K
         UYClKj3GHiouGSGda0A4IjeILTf7gFOgiiJCx7rAueq+xH9XgxO+s0d/XbptP0GpvPF7
         r2OtdzDSWNN3Fzp/oJY4qL++HMZnh5qwS448fA4pf/izsb8tQKiYrLetel7E9MMeySnG
         PutQ==
X-Gm-Message-State: APjAAAWlxleULXt0GFkwWtK+YPVZbj4UW0/zHSqp5WOy/xblnSB1wuH/
	yFLzPXjujAOm3qUzSqXVIdRNUQJv3QWVq1r/2w0psjXMfrfbpSaQZAR3Pzl4z5jPMjnNIPxIMQ6
	iuQagKVI3aw4Bs8RYEgpUbJXrqQwqT9JQTfS7uHO24wc6GrtWEg71F9JZdflas9g=
X-Received: by 2002:aed:3aa1:: with SMTP id o30mr22350753qte.218.1557156700700;
        Mon, 06 May 2019 08:31:40 -0700 (PDT)
X-Received: by 2002:aed:3aa1:: with SMTP id o30mr22350702qte.218.1557156700135;
        Mon, 06 May 2019 08:31:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557156700; cv=none;
        d=google.com; s=arc-20160816;
        b=x57pt89kJJwBtfCm21AnduFAH+lrsc1yI4QrMyjzw9MX9kfmh5k/mIinyWCSQhbULA
         wXBvdg+XgqSTwGKwix6IKdV0glAgdkUAzcI90Cq0qtbKGfc0G1+uJN5moOHrgegeWSvZ
         tbeKv0mLm4IOfqbLm8hACOCq0KL6rTb4oKKcDZYqgQUN/saFM++qSvlnC0w7sUsRB6uU
         88AdQkCaz5v5qyP+60XOGMrfA9l8PhZhwSuhXOcIRyzvmjUSUsUGwimpZo1i4dNJX0Ai
         Rt8chJYKL43tchTruX9AnafYkDWK0KG4qO3NeKJkYfOVfvyHGNFo1yiF7W4pqMoYn5eb
         ZCww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=/mMrXRGNFAUnlBanOG6lIKcQ2qXCGdgFD/lAGVp5Ijk=;
        b=AQNzuwRdB9MPbzA27xUFOqOKG+u3aTBlLY15BQgh6gFQ4RbI8oPBBxkgaCSAeFx7c1
         bdVI55reAqc5RCUJnAgyvktQff/3J21zAz20mva78yo4E2nKGmBMr1sRo5+IQIWJbUZa
         fplVreGY73ym2GyfK3zRLwy4ZAWXu2XAEkJfkfVL/kllXnJZY32qj4G5eU8NG/yaIiPJ
         aD9MdwHk2h/cx/3dYpCPDee3yGAmMtrz6LH+Dq4Hytz2aKMjIWvMps3d2jtboZLUaHxO
         YOL9ZRb408jVN3r/1AbJsysuS6VSKwaFTAlzXCByCWWDFKk6gTo20pFiXVyTddATI+/7
         X/0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FRIaQzP6;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g3sor4537509qkl.132.2019.05.06.08.31.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 08:31:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FRIaQzP6;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=/mMrXRGNFAUnlBanOG6lIKcQ2qXCGdgFD/lAGVp5Ijk=;
        b=FRIaQzP6E02iKd/LRHknHIfMWsLyZYkm7mpr7xtkI8lziTP9HO5aTcwhKoD1xeJl+l
         LJ5TWqUWRpPULfLDQ9x/PvLI5fli0XeL3MsSie5TvrfsMET3Gl/9HMhkwF9I6MGhefTC
         +gQHztuD1M1KJvNefAKO4hi80EI7Zmczpw9BRff78wgif9vAQD6UC77vsuLAYMTmC8ky
         PucMrqf1nYZa4O/5oYWE5H/aUL/nMIMP4kg02NZtu1kM9CcwNXJ8MGolpZcRcAF2l6fe
         NRtM3OQwINXRd/oH77hQYjy5vvN13HvU4vu1AbegJZQ9u58BrtL5QNj8ukEvJhpVB0yy
         1IbQ==
X-Google-Smtp-Source: APXvYqz67LjvUcpWVy+9a/kdXG2DHFPz1tKZL6bzzKYk6SLWXPGaCHybrhcqtu/dXg/05cYZG9tUGA==
X-Received: by 2002:a37:6c84:: with SMTP id h126mr21101343qkc.168.1557156699748;
        Mon, 06 May 2019 08:31:39 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::3:34f3])
        by smtp.gmail.com with ESMTPSA id t55sm6952498qth.59.2019.05.06.08.31.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 08:31:38 -0700 (PDT)
Date: Mon, 6 May 2019 08:31:36 -0700
From: Tejun Heo <tj@kernel.org>
To: Jiufei Xue <jiufei.xue@linux.alibaba.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
	joseph.qi@linux.alibaba.com, bo.liu@linux.alibaba.com
Subject: Re: [PATCH v4 RESEND] fs/writeback: use rcu_barrier() to wait for
 inflight wb switches going into workqueue when umount
Message-ID: <20190506153136.GM374014@devbig004.ftw2.facebook.com>
References: <20190429024108.54150-1-jiufei.xue@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190429024108.54150-1-jiufei.xue@linux.alibaba.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 29, 2019 at 10:41:08AM +0800, Jiufei Xue wrote:
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
> Acked-by: Tejun Heo <tj@kernel.org>
> Cc: stable@kernel.org

Andrew, I think it'd probably be best to route this through -mm.

Thanks!

-- 
tejun

