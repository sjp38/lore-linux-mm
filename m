Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53F9FC169C4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 00:56:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0A902082E
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 00:56:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0A902082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 690358E0006; Tue, 29 Jan 2019 19:56:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63F518E0001; Tue, 29 Jan 2019 19:56:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52EF48E0006; Tue, 29 Jan 2019 19:56:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 09EB08E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 19:56:39 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id h10so15541888plk.12
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 16:56:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kpZCUx9ClJPoMpcr+0g9fjYq6DZPkV+eAry+CUsiC1s=;
        b=K9jZr0nR2/kTGbgYNkQadtPWZa23W5Ym9ZcBCzmY+KzSKldYHNZdLYekcMeGgopbxs
         PGjTMDEJgdclC/Pj5C3uBZ9llNoFdmfQmwqPu5UGwvrFtDxjKmaQULx9lLmWwdG2QFHo
         Q7gax2sPSfDrJigUDOXhba7bfbl51SOEZYiFMr1pE1yUa/YaGMeA6o8tR3ZJDNOzVtNx
         JuA0SwsmR5iI1OlGzp5KuIbSbKqEgG65ROSNmEnnW7e7fazXWCcpL8MjGY0n/HzqW3uX
         tiJY5KZPXBwQnkWseFnGYdIDU4G1Z1foGDDyO8rraqQFs2osYQmFcIbAxR4mltbpJldo
         3BsA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukcCe5BgLO8/uLHcuAhkIPbemc+1Vkhsn4Vzj9taw85R2YyYUQ4c
	AdW8V1N4QN2rjw6K9Y5uZAL1ULAz7SVcA2AAUg6LZGnyBvpCqMYDlo5Ppt8DujovjP539rEuUI+
	3U524gzKp+JlnSm5PlRTDhKGbcjXcnD54UbyhxwprGdP+LgrsoMD/GqTI2O00oGS7Mg==
X-Received: by 2002:a17:902:a50a:: with SMTP id s10mr26913499plq.278.1548809798601;
        Tue, 29 Jan 2019 16:56:38 -0800 (PST)
X-Google-Smtp-Source: ALg8bN694FbRDZ6JRc0Hnwdoy9IEAHVF4rU6qXPYfYH8dO6cOXQ0a+HcQO9HSh22TSaIBPABcMBr
X-Received: by 2002:a17:902:a50a:: with SMTP id s10mr26913469plq.278.1548809797811;
        Tue, 29 Jan 2019 16:56:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548809797; cv=none;
        d=google.com; s=arc-20160816;
        b=fRMpDe5Q429e3bHDxXUvANN10ACjLBhem8w8DcpdEDztGnLdCWsjPMOQq8iWAFx/uV
         5IpmIzi3NM89p8QrEos/CfLoZmDHJ744ChNnx5TZLvV6ynnmGjxzP6DMWSJIaqpiIyl9
         6IkB3W9bFWtbEMFKUjoEuUHUwH9dR7+ZjhoacfaJORIBo5FF+nZBlP8dfXo4WmPoJjqs
         BEBXTS3pmVF8DBVlRcDk4alWyU+zOSF4YlDFLRB8k5W2NX5D1ojl4/8ukL8BDDbgj+yk
         tJEnZ85GYLoJBWLpJa1544U0DWHFA1nyYQoDq5kyM1EyZDbT5gtrhHGyQq8/b2Z5EJFZ
         H7xA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=kpZCUx9ClJPoMpcr+0g9fjYq6DZPkV+eAry+CUsiC1s=;
        b=VzcH28TwjyEpBGd+UiV71nKsry09C8PRfZnoYzPsAuDkkN2x6vSzJ1R9Alo+RuRXK1
         H+irzZ6w3a6lAmbviQGBE96ZURts8+PMeOB7RxBGgvk+mTGjh7W7ckBIlDrCK1RQ4ISg
         +/xVa0Z3ym24eCre913zUNU+qxeLVg+69acqvXM9pR8BsM/mi4yDjS6fIavHPksDdXYS
         aiRGHo2QN48z1PK+ehrXLI554wluDXfSEAUvFiAoRqYgoJpga/8C9phUXMmnqA6jTqAl
         KLjpiUp6dXbpSvBiL0jElhB4emDk7g2CNMOZ0enN8IdjW0fCcj+qmAW5hPNQFf6tDSEO
         j8BQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f17si30863146pff.171.2019.01.29.16.56.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 16:56:37 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 38E1D359D;
	Wed, 30 Jan 2019 00:56:37 +0000 (UTC)
Date: Tue, 29 Jan 2019 16:56:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Jan Kara <jack@suse.cz>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, <linux-fsdevel@vger.kernel.org>,
 <linux-mm@kvack.org>
Subject: Re: [PATCH] vfs: Avoid softlockups in drop_pagecache_sb()
Message-Id: <20190129165636.34a1dc779efdbb9eff4bcf8b@linux-foundation.org>
In-Reply-To: <20190114085343.15011-1-jack@suse.cz>
References: <20190114085343.15011-1-jack@suse.cz>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jan 2019 09:53:43 +0100 Jan Kara <jack@suse.cz> wrote:

> When superblock has lots of inodes without any pagecache (like is the
> case for /proc), drop_pagecache_sb() will iterate through all of them
> without dropping sb->s_inode_list_lock which can lead to softlockups
> (one of our customers hit this).
> 
> Fix the problem by going to the slow path and doing cond_resched() in
> case the process needs rescheduling.
> 
> ...
>
> --- a/fs/drop_caches.c
> +++ b/fs/drop_caches.c
> @@ -21,8 +21,13 @@ static void drop_pagecache_sb(struct super_block *sb, void *unused)
>  	spin_lock(&sb->s_inode_list_lock);
>  	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
>  		spin_lock(&inode->i_lock);
> +		/*
> +		 * We must skip inodes in unusual state. We may also skip
> +		 * inodes without pages but we deliberately won't in case
> +		 * we need to reschedule to avoid softlockups.
> +		 */
>  		if ((inode->i_state & (I_FREEING|I_WILL_FREE|I_NEW)) ||
> -		    (inode->i_mapping->nrpages == 0)) {
> +		    (inode->i_mapping->nrpages == 0 && !need_resched())) {
>  			spin_unlock(&inode->i_lock);
>  			continue;
>  		}
> @@ -30,6 +35,7 @@ static void drop_pagecache_sb(struct super_block *sb, void *unused)
>  		spin_unlock(&inode->i_lock);
>  		spin_unlock(&sb->s_inode_list_lock);
>  
> +		cond_resched();
>  		invalidate_mapping_pages(inode->i_mapping, 0, -1);
>  		iput(toput_inode);
>  		toput_inode = inode;

Are we sure there's no situation in which a large number of inodes can
be in the "unusual state", leading to the same issue?

