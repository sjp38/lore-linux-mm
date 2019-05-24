Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E16CC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 16:52:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1DA92070D
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 16:52:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1DA92070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mit.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7446C6B000C; Fri, 24 May 2019 12:52:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F4986B000E; Fri, 24 May 2019 12:52:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BCF96B0010; Fri, 24 May 2019 12:52:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0D4E96B000C
	for <linux-mm@kvack.org>; Fri, 24 May 2019 12:52:30 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id q2so3991769wrr.18
        for <linux-mm@kvack.org>; Fri, 24 May 2019 09:52:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=00FYUQsTgLdct/PTzOD2ukpt6YbR5pt7UAxi9i6WxxA=;
        b=BXpfaaSnueljEyCg37ucQo++rv73juf+4HVXwuH9cufmFME7uV0/rRJ+N1MvRQjLsA
         IsytnUhqte28+cGurQNIbQIvckm3M6sD+6OaQlAqXmS5x9MVcyZcYAtdEdKFTssu5vgn
         kfdHBa2BNZe5LNpuE6W+shSVJ7Ib3ewPU7x+IayCFq4XmhPde+EYUKNML4T4loaiDea9
         ichMJrsZdDfmFFJ6Do1abFmca4ExitIrEWyduvfYKT2AVvEeew/WIbLxNSLRTSoIv2NN
         enxMxAXtJhH1FSPRmfAD8KzIzzBoUunSxC2s9VqbbuoVnOUYHVVpiHDnIBlMUdpnqOQG
         rA+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
X-Gm-Message-State: APjAAAX9qrkNML8yznK0p6cm+Cu0jcU5s4LrL7r1MO3j5DcapcUJwAQ5
	OkzTGcdlSLboeYGqgj/peUCHpf6UvewZcmfw9GJ5XQqGjQUle0NchyN4R53QCAR2p5YlYum9+Nm
	FTwPo4THcOUSfjp9iIagiHDCgx4t6zi7o3+1iJZWotrt5CnG8Lxypyix3Gl5NQzLeLQ==
X-Received: by 2002:a1c:a817:: with SMTP id r23mr580365wme.21.1558716749518;
        Fri, 24 May 2019 09:52:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyn9wLwgAumPIWU6sDmLG39U3J8u2P9eDvTrUjZ+T694YtT78Nkgp+XMNwmX/pVlSXDHCAo
X-Received: by 2002:a1c:a817:: with SMTP id r23mr580334wme.21.1558716748828;
        Fri, 24 May 2019 09:52:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558716748; cv=none;
        d=google.com; s=arc-20160816;
        b=kYShr5WC/35axY0vdvBGRAiC3uktD6+pUsY3pKjSHATR0wKVOmu/JK+59PyjeK0UJf
         s/JwP/moyAWIV8Zn+2ociGIc31AM8heoIBCSxDqA8inytLpEsE70C92pmaxxDGawUPU4
         ADJiW/6By4MGlEg8J9ccplIbxIHSVSofzpQ4YLPZ8xBCv1euvU4Rk2+uR2M+NR9VT4IG
         eQ233QBCSETDzstviedp7OWlwh0qJ6sU/so+9p3L/VRgxYKCrtHTnweQ6NqW9V6M1Xl/
         7qKdRrWJpR+e71VXpjYSDkolXmdruEVBn1kaOYNimnEL1d46a1Ncdc0IIaTde+xjPZJo
         UvZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=00FYUQsTgLdct/PTzOD2ukpt6YbR5pt7UAxi9i6WxxA=;
        b=WJKpE+lG/70lpq0X+39o5uETJaaVVLFLAs5so2yBJDe9QwC3cxYJy+biDqPWGJKJjH
         Lw3oiCNTBB0vJiQp5PmAkEQaoWCl/89ewSGSrEFQjUn9pa2kLE6vVVIr/MXa07GuNOiE
         l3GIK4D9Xqbd47wiL54wOdQkU6WlLPozPg/Xn6MxBQE8mN8G+9kcyoFsdN5/f85CgGwY
         cw0QkNxv7TI84r88/XMuA4UJ6JN0hIO5mfbAtjVaQPnhaM4lNQRu0/rgsnLGpaaYuhPc
         jiD3g5/XofqQcjtdlglFHoe7EIQ6dmfmYJvEf01QcfyKniIQ6ha78dDOsXdAdGGA1wjO
         0lSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu. [18.9.28.11])
        by mx.google.com with ESMTPS id t8si2467655wrv.130.2019.05.24.09.52.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 09:52:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) client-ip=18.9.28.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from callcc.thunk.org (guestnat-104-133-0-109.corp.google.com [104.133.0.109] (may be forged))
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id x4OGqDtZ028397
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Fri, 24 May 2019 12:52:16 -0400
Received: by callcc.thunk.org (Postfix, from userid 15806)
	id 421D9420481; Fri, 24 May 2019 12:52:13 -0400 (EDT)
Date: Fri, 24 May 2019 12:52:13 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: Sahitya Tummala <stummala@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Kirill Tkhai <ktkhai@virtuozzo.com>, Michal Hocko <mhocko@suse.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Vladimir Davydov <vdavydov.dev@gmail.com>,
        Yafang Shao <laoar.shao@gmail.com>, Roman Gushchin <guro@fb.com>,
        Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org,
        Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@kernel.org>,
        linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/vmscan.c: drop all inode/dentry cache from LRU
Message-ID: <20190524165213.GB2765@mit.edu>
Mail-Followup-To: Theodore Ts'o <tytso@mit.edu>,
	Sahitya Tummala <stummala@codeaurora.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>, Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Yafang Shao <laoar.shao@gmail.com>, Roman Gushchin <guro@fb.com>,
	Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org,
	linux-kernel@vger.kernel.org
References: <1558685161-860-1-git-send-email-stummala@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1558685161-860-1-git-send-email-stummala@codeaurora.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 01:36:01PM +0530, Sahitya Tummala wrote:
> This is important for the scenario where FBE (file based encryption)
> is enabled. With FBE, the encryption context needed to en/decrypt a file
> will be stored in inode and any inode that is left in the cache after
> drop_caches is done will be a problem. For ex, in Android, drop_caches
> will be used when switching work profiles.
> 
> Signed-off-by: Sahitya Tummala <stummala@codeaurora.org>

Instead of making a change to vmscan.c, it's probably better to
migrate to the new fscrypt key-management framework, which solves this
problem with an explicit FS_IOC_REMOVE_ENCRYPTION_KEY ioctl.  This
allows the system to remove all inodes that were made available via a
single key without having nuking all other inodes --- this would make
it much faster after a user logs out of ChromeOS, for example:

See:

	https://patchwork.kernel.org/patch/10952019/

							- Ted

