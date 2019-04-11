Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA134C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 04:48:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BE832133D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 04:48:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BE832133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 060526B0005; Thu, 11 Apr 2019 00:48:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00F3C6B0006; Thu, 11 Apr 2019 00:48:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1A546B0007; Thu, 11 Apr 2019 00:48:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 916836B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 00:48:11 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id m13so2841936wrr.17
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 21:48:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=gNEYZxJSUlroleIJ0CX8yJKGRd/Vk8bbcuwBkaN+1Oo=;
        b=NaUULQ/wtdUKAP1FXcKh6webAHJibQl92pfjDV/Kf3iRQlnBAWHZUixlgLfqXU5WY4
         AErevqWgcpKFks1ZREf3215ZKZn5QJW1dTwCcR/41qQw5JvG2VwGRDBsTjIyKhUPJbfl
         uHvetkeIj0T20TaCOaiz0gEpsq6FHjNCWsduYgXllbh2qedK+U9FfKeddDTQAknjcfQA
         fPMYMepoxItNVNXgTPwrmQofLlyM1SKqIXQW7zt1qn1Ca4BvXd59KS8E8y13kLKuUTVe
         9l/URCTywS/ZiRvSEPk+NjpfGx5Y8o5iwc3rMYSU5zQYW6IgEVmr/tasJnGvUCxXZQNs
         AkTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: APjAAAWM7iP+KOaYuhn57KoC+0EO5vAfIUJlmSvz5JZNKjZ9bG1oFH3E
	YExuB6D8nTT1+Ey84enbdracxhJl1gutrrzDkKTnnsw0m9pYhT43/3aBAse8xq/ep3Z4ihwvpOp
	/oNtmc+nWwKdWxbFG+qv5Hv3OrtmCqPEs4vsydd3+GpXqpXxj/WCh6/hhp2hTPiAsVQ==
X-Received: by 2002:a7b:c111:: with SMTP id w17mr5033390wmi.6.1554958091132;
        Wed, 10 Apr 2019 21:48:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtzFGN2hT25/4eY/mCRwmWBhQWKABfEknK4t9H8zIhReu7YYxLHoKuDGUSzg2lZUOxx26f
X-Received: by 2002:a7b:c111:: with SMTP id w17mr5033362wmi.6.1554958090297;
        Wed, 10 Apr 2019 21:48:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554958090; cv=none;
        d=google.com; s=arc-20160816;
        b=f6jNFoD18svPaCH0wE7N/zihZe0oAWpa8VVRR0d3Pj5oISUpHxJVTgZEnS0GXK41V2
         +mb412sOOwB2+FclItrEefRqxXaZEJVA6zso3gjFFD/sElHYCM2zeNETwJPSQwDJ2guF
         NpElr97wuAmX/0iSmDLYG/dZA+eTnNMKjRuWFNFw2wODF+bu3J9EQnM2PiAjsFoZPf4r
         HHvN0rH6OSzf3Nfp71mhQelw5v44bPdcuRX2cyl6SaFD9G9NX1BEq4rOpkDepOcuGsAN
         2fz8JuQNkDrLcndwkUG6iAnAs2Xz006lvZlQNrPNoogLoU2QjHhlsBDJCVbsCArvLmaW
         kXgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=gNEYZxJSUlroleIJ0CX8yJKGRd/Vk8bbcuwBkaN+1Oo=;
        b=biE5PHkrZUplnuaXd01xLZvAmN3KJ9qz6DcXxoqMOpJm7uTBbXM02tEugBvCI+pbVV
         pe5Dak6NLtmT7ObQlvWCWeX4bO4+Bmv+JzLx4RVl5N6z1zJEh5UrKvp7pvk9K8Dn6nwW
         FVhZYc8MWosLXtYB15AvstQ03rgsxjFeDWaG5TkuhZZmNcgVWLbeN+7tuUVsxJBZpk9R
         qE6wfzTUeu4jT7C2qd/tgfPOSKnRZIN9Ow/lDMfW/0nKXgDngCApIjG/iNoB8Hkdjo4G
         xSg5ITDez23lNvrbLmxHUplbPaQSiAtN49O5Uqe2xN45M2BxBoymDjRp9wZBTAHJh2cY
         T8nA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id v75si2470398wmf.197.2019.04.10.21.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 10 Apr 2019 21:48:10 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hERco-0005NN-UV; Thu, 11 Apr 2019 04:47:47 +0000
Date: Thu, 11 Apr 2019 05:47:46 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: "Tobin C. Harding" <me@tobin.cc>
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
Subject: Re: [RFC PATCH v3 14/15] dcache: Implement partial shrink via Slab
 Movable Objects
Message-ID: <20190411044746.GE2217@ZenIV.linux.org.uk>
References: <20190411013441.5415-1-tobin@kernel.org>
 <20190411013441.5415-15-tobin@kernel.org>
 <20190411023322.GD2217@ZenIV.linux.org.uk>
 <20190411024821.GB6941@eros.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411024821.GB6941@eros.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 12:48:21PM +1000, Tobin C. Harding wrote:

> Oh, so putting entries on a shrink list is enough to pin them?

Not exactly pin, but __dentry_kill() has this:
        if (dentry->d_flags & DCACHE_SHRINK_LIST) {
                dentry->d_flags |= DCACHE_MAY_FREE;
                can_free = false;
        }
        spin_unlock(&dentry->d_lock);
        if (likely(can_free))
                dentry_free(dentry);
and shrink_dentry_list() - this:
                        if (dentry->d_lockref.count < 0)
                                can_free = dentry->d_flags & DCACHE_MAY_FREE;
                        spin_unlock(&dentry->d_lock);
                        if (can_free)
                                dentry_free(dentry);
			continue;
so if dentry destruction comes before we get around to
shrink_dentry_list(), it'll stop short of dentry_free() and mark it for
shrink_dentry_list() to do just dentry_free(); if it overlaps with
shrink_dentry_list(), but doesn't progress all the way to freeing,
we will
	* have dentry removed from shrink list
	* notice the negative ->d_count (i.e. that it has already reached
__dentry_kill())
	* see that __dentry_kill() is not through with tearing the sucker
apart (no DCACHE_MAY_FREE set)
... and just leave it alone, letting __dentry_kill() do the rest of its
thing - it's already off the shrink list, so __dentry_kill() will do
everything, including dentry_free().

The reason for that dance is the locking - shrink list belongs to whoever
has set it up and nobody else is modifying it.  So __dentry_kill() doesn't
even try to remove the victim from there; it does all the teardown
(detaches from inode, unhashes, etc.) and leaves removal from the shrink
list and actual freeing to the owner of shrink list.  That way we don't
have to protect all shrink lists a single lock (contention on it would
be painful) and we don't have to play with per-shrink-list locks and
all the attendant headaches (those lists usually live on stack frame
of some function, so just having the lock next to the list_head would
do us no good, etc.).  Much easier to have the shrink_dentry_list()
do all the manipulations...

The bottom line is, once it's on a shrink list, it'll stay there
until shrink_dentry_list().  It may get extra references after
being inserted there (e.g. be found by hash lookup), it may drop
those, whatever - it won't get freed until we run shrink_dentry_list().
If it ends up with extra references, no problem - shrink_dentry_list()
will just kick it off the shrink list and leave it alone.

Note, BTW, that umount coming between isolate and drop is not a problem;
it call shrink_dcache_parent() on the root.  And if shrink_dcache_parent()
finds something on (another) shrink list, it won't put it to the shrink
list of its own, but it will make note of that and repeat the scan in
such case.  So if we find something with zero refcount and not on
shrink list, we can move it to our shrink list and be sure that its
superblock won't go away under us...

