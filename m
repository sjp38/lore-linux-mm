Return-Path: <SRS0=BwCX=U4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6E8CC5B577
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 19:06:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85564216FD
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 19:06:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85564216FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01DEC6B0003; Sat, 29 Jun 2019 15:06:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F362A8E0003; Sat, 29 Jun 2019 15:06:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E26A18E0002; Sat, 29 Jun 2019 15:06:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f79.google.com (mail-wr1-f79.google.com [209.85.221.79])
	by kanga.kvack.org (Postfix) with ESMTP id 9A6BA6B0003
	for <linux-mm@kvack.org>; Sat, 29 Jun 2019 15:06:52 -0400 (EDT)
Received: by mail-wr1-f79.google.com with SMTP id l9so3872965wrr.0
        for <linux-mm@kvack.org>; Sat, 29 Jun 2019 12:06:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=myFSFOownYHAiy1Yl2egmGV8Yzjo/yX7QKOXiNocZ2U=;
        b=L0yC8wz8B2VKJT6FbsnmpbTSFsJVt7mp8nCWN9sosDzl5mQevhasi9ofTgtQiXSJdn
         U2knEpoTiY/Lf/a0I8Sb7Hb6x53PyzUelPzfrLSmlqz1PBYKC1m+ZmOfM07XQ9/WLLmT
         pS4mLPzgc0U7pJsrsyKMZ2wHYCONgmCaAe06DeIo91i9BJgeq/otAxztaXSK3YTBy2dh
         si3LgjSQSvFZIMIgi+NRcYfo0evS7IpUzORMCq3oVId/QylbR/PFFK8ZX99AAysfim1Y
         eqvxZMRftzpzEty6lQY8E0OJiqjxvC22R6OUzU6/jgq9MzhNbGLWM/sJ8ITpzNA/x5Km
         lG8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: APjAAAUiprVTLv9ScZlEu0bknhmQ+7WGA/V1x+KOC2qelrEDYnvrs28b
	iVwMd2BkseI1BP+3xlpQlm1pwOas2tkv+Md07VWNSq/4RP288WR07H5p8mt3PlTQW1iPEzka97u
	aQZqTq97KNXDOtXZ11HVZqcP32Qkq3/XVyxi536uR4V8wbobIiEFM9xr7Xc9ViR5gEg==
X-Received: by 2002:a1c:9a46:: with SMTP id c67mr10974467wme.11.1561835212043;
        Sat, 29 Jun 2019 12:06:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwxppCp6lxTFGHB/SLqzTgUxcFdOvDKZTFu+HSmPKSBJvXJFfnptWIpX//BDunKY38qSUI
X-Received: by 2002:a1c:9a46:: with SMTP id c67mr10974447wme.11.1561835210889;
        Sat, 29 Jun 2019 12:06:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561835210; cv=none;
        d=google.com; s=arc-20160816;
        b=EzAb3cRi/vTdiqzd4uk6LnkpatEnucYim3VqTuWsZhu4vwRJEjplw+StrDgBvNUKDW
         MrKyy05p8yshwIoNpWSqUk99KRwkaPckwztzZItvPIk67DQn/va7EDZD1spQWjSH+rDj
         wz1LQCKq6wutGeS+PR2LkTZkGu6dJOSwAA896RA3Muq/hCHMRF5/scL24eHZ1KrPsGBA
         /LDZIVQhZ+m3yPgKiitc4jwVA8cPyQbmkQN/HgDoSnOV+LLa8wQc5cwA2DLwK88+Ot8h
         heNHIAn7Yw6LgLqhhdui8eMiX91JOvGJ9v3dKNtqOgsdz6A5pLjgy4OTjC1S3eUHcQfz
         fJxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=myFSFOownYHAiy1Yl2egmGV8Yzjo/yX7QKOXiNocZ2U=;
        b=nu3Pj0dfJ6CQdjX7T4eJwTsZgJsWJow+OG3CHlTwYjlj7Lb6tKZ3U2xe22Rp4qJUoN
         u1tML876aW9AN1/aGG7KQyFooS8BJTko5SQZBbUk5x5kyoJFC+tLbWyR4HP0odDq2YLm
         HAaEfxjt6JnVnYdZk0XM+mRnnI4pl1gO3WxUOfAQTs984klS1mprKQVTTqCLiEvxso8g
         T1kBWs8V13gJiam8u8BJQLEC3iW8HZYwpZQghyfl+hYyzEmEJewbZVuRnenznpQl5PCh
         VEZh6SuzT4djvXOM+zkx57IwReuI3e3VfHSU2d1HfDWCSeiQeyztz82yEwqkZ2N6wMci
         WhCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id d4si4186711wrj.445.2019.06.29.12.06.50
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 29 Jun 2019 12:06:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hhIg4-0007QN-HD; Sat, 29 Jun 2019 19:06:24 +0000
Date: Sat, 29 Jun 2019 20:06:24 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>,
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
	Hugh Dickins <hughd@google.com>, Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: shrink_dentry_list() logics change (was Re: [RFC PATCH v3 14/15]
 dcache: Implement partial shrink via Slab Movable Objects)
Message-ID: <20190629190624.GU17978@ZenIV.linux.org.uk>
References: <20190411013441.5415-1-tobin@kernel.org>
 <20190411013441.5415-15-tobin@kernel.org>
 <20190411023322.GD2217@ZenIV.linux.org.uk>
 <20190411024821.GB6941@eros.localdomain>
 <20190411044746.GE2217@ZenIV.linux.org.uk>
 <20190411210200.GH2217@ZenIV.linux.org.uk>
 <20190629040844.GS17978@ZenIV.linux.org.uk>
 <20190629043803.GT17978@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190629043803.GT17978@ZenIV.linux.org.uk>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 29, 2019 at 05:38:03AM +0100, Al Viro wrote:

> PS: the problem is not gone in the next iteration of the patchset in
> question.  The patch I'm proposing (including dput_to_list() and _ONLY_
> compile-tested) follows.  Comments?

FWIW, there's another unpleasantness in the whole thing.  Suppose we have
picked a page full of dentries, all with refcount 0.  We decide to
evict all of them.  As it turns out, they are from two filesystems.
Filesystem 1 is NFS on a server, with currently downed hub on the way
to it.  Filesystem 2 is local.  We attempt to evict an NFS dentry and
get stuck - tons of dirty data with no way to flush them on server.
In the meanwhile, admin tries to unmount the local filesystem.  And
gets stuck as well, since umount can't do anything to its dentries
that happen to sit in our shrink list.

I wonder if the root of problem here isn't in shrink_dcache_for_umount();
all it really needs is to have everything on that fs with refcount 0
dragged through __dentry_kill().  If something had been on a shrink
list, __dentry_kill() will just leave behind a struct dentry completely
devoid of any connection to superblock, other dentries, filesystem
type, etc. - it's just a piece of memory that won't be freed until
the owner of shrink list finally gets around to it.  Which can happen
at any point - all they'll do to it is dentry_free(), and that doesn't
need any fs-related data structures.

The logics in shrink_dcache_parent() is
	collect everything evictable into a shrink list
	if anything found - kick it out and repeat the scan
	otherwise, if something had been on other's shrink list
		repeat the scan

I wonder if after the "no evictable candidates, but something
on other's shrink lists" we ought to do something along the
lines of
	rcu_read_lock
	walk it, doing
		if dentry has zero refcount
			if it's not on a shrink list,
				move it to ours
			else
				store its address in 'victim'
				end the walk
	if no victim found
		rcu_read_unlock
	else
		lock victim for __dentry_kill
		rcu_read_unlock
		if it's still alive
			if it's not IS_ROOT
				if parent is not on shrink list
					decrement parent's refcount
					put it on our list
				else
					decrement parent's refcount
			__dentry_kill(victim)
		else
			unlock
	if our list is non-empty
		shrink_dentry_list on it
in there...

