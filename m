Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1715EC072B1
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 13:09:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0B3B20883
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 13:09:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0B3B20883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D5016B027D; Mon, 27 May 2019 09:09:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15E0D6B027E; Mon, 27 May 2019 09:09:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1A6C6B027F; Mon, 27 May 2019 09:09:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9306B027D
	for <linux-mm@kvack.org>; Mon, 27 May 2019 09:09:51 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l3so27972557edl.10
        for <linux-mm@kvack.org>; Mon, 27 May 2019 06:09:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:mail-followup-to:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=sliIN/6bT9A2L9h0yW4oubn7AriJkxfwz8z06mUi3Ro=;
        b=Z/2LDg/rZ929AKNKRx9Miwg3aP0tVkUWA0RPoCRvPy0LyWj4rZiLnxueyzv02UMtVq
         J0/90OtHsmzxPaPNf5xlf1UGA+vLM80XKfN+whYvroIT4uJ9NxO3qdeY3JI4sHI/jfk3
         PEEEYjUsRV9K3rIcOc8gOCYeXBhiUkUAN9qsangZqiR7DdbxvhOgUK7hqvqMjTcMrvl8
         3DAiLIxSA6Dq/vCG8yHWnGsiquLISwLghhJ2s1o1Hurpu4YO25W7LMa7Z0TGxSMjgDFz
         bv0pZ2SOleHYZ77otqQOf/m/aPMrKgtZ2OLjF9nqIVueTbYgFM1Q7GAG8EUWgk0CUqNt
         GlUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dsterba@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=dsterba@suse.cz
X-Gm-Message-State: APjAAAW0fwyN6yLSsSlHo8Xx2KNrtf5FdQx4hIxIS43R5pTyKBFsbwSW
	FpFD6owiTek5wqCD3qPRDMDT8A1LowSYenwt1pdQEzd5Kv3zu16kv6a77uVJeYaQLZATV0jx1Uz
	gglU/ir9mirCwYAcfMCHA76609Z6i7d0GEeGup+/EoeSiB5yJif0bGtdCvP84BQlWfw==
X-Received: by 2002:a50:9292:: with SMTP id k18mr17809644eda.301.1558962591215;
        Mon, 27 May 2019 06:09:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycebsT4hUByL3uhSlup3je6LTL/P51DTKm4wKCMGPdb5oDqTsnVOl+udPHyUcElyiesY5F
X-Received: by 2002:a50:9292:: with SMTP id k18mr17809542eda.301.1558962590240;
        Mon, 27 May 2019 06:09:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558962590; cv=none;
        d=google.com; s=arc-20160816;
        b=DjJ1lhfdiMH0Gd4ekKgcN49UWgDExLKnfB0iiJ1LKN9imz/pq2M/tiTwkmRBUlvHJX
         dc+3KKSFgR1sOzFzfLlaM9T4wtKaL0QmRqu2ySl7Xi18q244KrBHa1LatyK9Mrumov/n
         9AIZjyqKevxaNFjjnGKzJRjMskM4sGfL1iMTeGgo57ty/4xEKVcDivBhcrr+FWybgl1x
         WuLxI1dE9kJQ7v6ctTHHBy6nl7z0R2rc5wYn9clSSQqsl8T/lq1GpeJyMQG+DN1P1abd
         92Iuhr3BEZJRtv1QFBwzEjmP6Dv26msqS0sKXdCwH0TSPgF9xAGjqm4AP8Mb32bGde6r
         eb9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:reply-to:message-id:subject:cc:to:from:date;
        bh=sliIN/6bT9A2L9h0yW4oubn7AriJkxfwz8z06mUi3Ro=;
        b=InZAkHY78/LmpeqFgERzaAlFiZFjh9OsvaqdcadP5kiSL2vaF1cpCnPczj8no4rAgS
         Sm571Vg1+G9BlCxbBVgYqTGM5PB5zGP0X9RyTgdYATgksJG2mGImJ1CMOvGERTbi4Tvc
         JS8RYwvFKR7VtVL9ma6LpZqe3i0bWQDifaPuUXwI2zUBNrsQf+S4BiZ1pHqzkPTjLazM
         2n8hiNwsUvA4aqntRQjXZ9UUYymGpUQFSmEXCwrcU4J5+BmrCThSwebEXw+FLSCGJUnJ
         vF//CaeFc9xdx2iaCk1U1Hhle2EviPp3fxjAEj7Qx76CTxenDaoaghquBAxrgf0V1+tv
         8wpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dsterba@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=dsterba@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q6si9136633edd.141.2019.05.27.06.09.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 06:09:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of dsterba@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dsterba@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=dsterba@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E70CBAEBB;
	Mon, 27 May 2019 13:09:48 +0000 (UTC)
Received: by ds.suse.cz (Postfix, from userid 10065)
	id 7E694DA85C; Mon, 27 May 2019 15:10:42 +0200 (CEST)
Date: Mon, 27 May 2019 15:10:41 +0200
From: David Sterba <dsterba@suse.cz>
To: Juergen Gross <jgross@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-erofs@lists.ozlabs.org, devel@driverdev.osuosl.org,
	linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>,
	Gao Xiang <gaoxiang25@huawei.com>, Chao Yu <yuchao0@huawei.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, David Sterba <dsterba@suse.com>,
	Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Jaegeuk Kim <jaegeuk@kernel.org>, Mark Fasheh <mark@fasheh.com>,
	Joel Becker <jlbec@evilplan.org>,
	Joseph Qi <joseph.qi@linux.alibaba.com>, ocfs2-devel@oss.oracle.com
Subject: Re: [PATCH 2/3] mm: remove cleancache.c
Message-ID: <20190527131041.GH15290@twin.jikos.cz>
Reply-To: dsterba@suse.cz
Mail-Followup-To: dsterba@suse.cz, Juergen Gross <jgross@suse.com>,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-erofs@lists.ozlabs.org, devel@driverdev.osuosl.org,
	linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>,
	Gao Xiang <gaoxiang25@huawei.com>, Chao Yu <yuchao0@huawei.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, David Sterba <dsterba@suse.com>,
	Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Jaegeuk Kim <jaegeuk@kernel.org>, Mark Fasheh <mark@fasheh.com>,
	Joel Becker <jlbec@evilplan.org>,
	Joseph Qi <joseph.qi@linux.alibaba.com>, ocfs2-devel@oss.oracle.com
References: <20190527103207.13287-1-jgross@suse.com>
 <20190527103207.13287-3-jgross@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527103207.13287-3-jgross@suse.com>
User-Agent: Mutt/1.5.23.1 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 12:32:06PM +0200, Juergen Gross wrote:
> With the removal of tmem and xen-selfballoon the only user of
> cleancache is gone. Remove it, too.
> 
> Signed-off-by: Juergen Gross <jgross@suse.com>
> ---
>  Documentation/vm/cleancache.rst  | 296 ------------------------------------
>  Documentation/vm/frontswap.rst   |  10 +-
>  Documentation/vm/index.rst       |   1 -
>  MAINTAINERS                      |   7 -
>  drivers/staging/erofs/data.c     |   6 -
>  drivers/staging/erofs/internal.h |   1 -
>  fs/block_dev.c                   |   5 -

For the btrfs part:

>  fs/btrfs/extent_io.c             |   9 --
>  fs/btrfs/super.c                 |   2 -

Acked-by: David Sterba <dsterba@suse.com>

