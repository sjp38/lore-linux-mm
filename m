Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2832C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:49:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81BD12084B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:49:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81BD12084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19FF36B000A; Wed,  3 Apr 2019 13:49:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12DA36B000C; Wed,  3 Apr 2019 13:49:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F37606B027B; Wed,  3 Apr 2019 13:49:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9916B000A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:49:22 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id h12so13478024wrx.23
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:49:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=IXX7H07x0qVGMSb+Zrza7jNHJu1+IltRuSWsNvh53z4=;
        b=eg1nkDJlj+M+RiRTn9utlSUqwIPlN2dI6lAlS0aef3KbmduE7DJmEZCaDKa6VaAA42
         iUfhl3hJCipO6O2AFq1CS6At1jl+txnJfULqAH//wwIGMMYkn6Y9+Daap7W/yKRMmr7s
         U40XyftXc9ox9b7siSMpxPwB59ctxFN6zA3Et1oRyHpR+NtcF5dMrR+TA2ME4KKf4vAb
         9xOYtuzexJFhPYqUX5R1YYh+NQFiAtdTDeJqegtwt/6xur6J0y9MCC55oKQmDHLxKRtU
         nFwJYNzeNpFEI1/xeHs//yaejF1I7d5yi5+jdbLHqqDl6n2/oGYHVJyntt/NcZ1c8/Vx
         6PTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: APjAAAXenNaaX2mxFaATbNCZenPIzoYAOE/D8E+6dKi0gSCnxJEk+Qio
	5NF1IRGG7oenvwP2zePtV9S/MoAZLynD8wJ+GsYQxdKYTi5X3HwBg1/WAYOyKXIjXMHYjAzdTni
	CdXtxZ+tJl/+kFp/r9y9rAKmIPGFuGVucBPUFH1Kau72N9hh9vy7ZbjHD/g7lgz6xCQ==
X-Received: by 2002:a1c:730c:: with SMTP id d12mr937401wmb.47.1554313762113;
        Wed, 03 Apr 2019 10:49:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwv9D9EtHKv4abP3bD3c+DRZkvIzbzgpsSNaX2fzasdAnx23xsDkDUzSkJCt232kJ0MxdGW
X-Received: by 2002:a1c:730c:: with SMTP id d12mr937356wmb.47.1554313761167;
        Wed, 03 Apr 2019 10:49:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554313761; cv=none;
        d=google.com; s=arc-20160816;
        b=nTmpco2atY86VpcicK35WuX3/eQdJyqaC67jdP3b4liVF8QuaZdk6eGKAQSrRRn93w
         TiQKKiUHxWg0Hg5n0+8sadc6xH49K8DO1ja+ygkkj/bn1lVq+J2GW4NhKViOORuL2L+F
         eXgrAfVwB72CVOpjeQTlM0Dah7GkRrcRTfnI17yjki/u2TO5mLtnAKqLNVK0HyOMeO0V
         y8uiyFwWlxsJgBsgZkoonKI+pL+GASq6fbvNpjkX6W/PVQPkVx4HWlwzgAYK2WjtwqoY
         OdkVseIW+OnjC/4fzOmxo/gYqTPYINBwB1ciZIQx9TSwP6NeQasH0kRrWBXsY8gcXFPP
         JoOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=IXX7H07x0qVGMSb+Zrza7jNHJu1+IltRuSWsNvh53z4=;
        b=JQq4Tu7KFvv0NGJQj5zVnv3on4HYbie8nGJ86ZCFhH8EtwNYlK4r9d1mA1AqxjL6RV
         PHUqG1BRdRc0TPnVCc7c0d9Wl3/71rkpUiK1Fiq/8/nFdoTE1zi8wQZEciXiK6lcx4vS
         hVg31nUoE6grnKvWVbyLPo5h1+I+q1bFEqzfUGpnwxkxe6sijfHfDUtR+6553PcDNYiR
         uKkRxkrpkPBjkButkQJbIbazK4lu5zf2LQGZBHyKtOxFCaVYZkFh5x93B4fzWlBA0irn
         XWhwGHK5T5k4cm8rtBxrkYT7En0JhcVdaMjzW0zRLSwRk2fbpkPILk+DJ9d2gVXxJwEp
         KpIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id o1si10583414wrm.383.2019.04.03.10.49.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 10:49:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hBk0N-0004qz-VD; Wed, 03 Apr 2019 17:48:56 +0000
Date: Wed, 3 Apr 2019 18:48:55 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: "Tobin C. Harding" <tobin@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>, Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>, Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC PATCH v2 14/14] dcache: Implement object migration
Message-ID: <20190403174855.GT2217@ZenIV.linux.org.uk>
References: <20190403042127.18755-1-tobin@kernel.org>
 <20190403042127.18755-15-tobin@kernel.org>
 <20190403170811.GR2217@ZenIV.linux.org.uk>
 <20190403171920.GS2217@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403171920.GS2217@ZenIV.linux.org.uk>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 06:19:21PM +0100, Al Viro wrote:
> On Wed, Apr 03, 2019 at 06:08:11PM +0100, Al Viro wrote:
> 
> > Oh, *brilliant*
> > 
> > Let's do d_invalidate() on random dentries and hope they go away.
> > With convoluted and brittle logics for deciding which ones to
> > spare, which is actually wrong.  This will pick mountpoints
> > and tear them out, to start with.
> > 
> > NAKed-by: Al Viro <viro@zeniv.linux.org.uk>
> > 
> > And this is a NAK for the entire approach; if it has a positive refcount,
> > LEAVE IT ALONE.  Period.  Don't play this kind of games, they are wrong.
> > d_invalidate() is not something that can be done to an arbitrary dentry.
> 
> PS: "try to evict what can be evicted out of this set" can be done, but
> you want something like
> 	start with empty list
> 	go through your array of references
> 		grab dentry->d_lock
> 		if dentry->d_lockref.count is not zero
> 			unlock and continue
> 		if dentry->d_flags & DCACHE_SHRINK_LIST
> 			ditto, it's not for us to play with
>                 if (dentry->d_flags & DCACHE_LRU_LIST)
>                         d_lru_del(dentry);
> 		d_shrink_add(dentry, &list);
> 		unlock
> 
> on the collection phase and
> 	if the list is not empty by the end of that loop
> 		shrink_dentry_list(&list);
> on the disposal.

Note, BTW, that your constructor is wrong - all it really needs to do
is spin_lock_init() and setting ->d_lockref.count same as lockref_mark_dead()
does, to match the state of dentries being torn down.

__d_alloc() is not holding ->d_lock, since the object is not visible to
anybody else yet; with your changes it *is* visible.  However, if the
assignment to ->d_lockref.count in __d_alloc() is guaranteed to be
non-zero to non-zero, the above should be safe.

