Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F0A5C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:08:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C98E2084B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:08:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C98E2084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCF706B000E; Wed,  3 Apr 2019 13:08:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7F2D6B0010; Wed,  3 Apr 2019 13:08:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6F046B026A; Wed,  3 Apr 2019 13:08:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C4DA6B000E
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:08:43 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id u18so13512173wrp.19
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:08:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=szulT7NfpOOAl6Q5NRLBlwod2VyZhZp2orgKdKl2/8M=;
        b=a7uzyJAluhIBSCcDASP/faWYyshKSFNyJOPobMXvlR9i9IqC+fF4k6ezCbL3ZqIhhY
         tGYy0ghcoZPjCEJbwJbhr82s5nQ7478lPxOPf1VUVogo54Z+AVw3BulatmKmOnC59qyq
         KSUHSEwLzeAAzi0lEulkCwMwFHEuXiz6c1teGb5JroHdv/FlKhQ+L0kc7Co1odgtpeoI
         H6w5ovgAL/HcRa4CH1AdQzN0qz+5d0HchVTrny7aP64vIOEWMY7xnNkOerhN96e/M7QX
         cr4qUPQmb8ZTPw2INEN8KYytqw5Nrn8uTR9WTltvXXa354jhPwLF+4Vp+vIxJ7aRMxcR
         FDzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: APjAAAVCUYB1iP6cagF8zEh+q6ssKhX01ow7Z6bSBBUoXQuHZ49W/2D0
	V7PJbU94PeoBcJJstcivSFYVSciorc4nQi+Px2DxpIC3Qyxy4+PRRI/51wEqv0MqbuyBeXK5Z9/
	MFVMbIEdZ3K0DhuXaHd9WSpjzwO7lApNf8w4ehE0tWi34btAbeWrnVHNokDsWc2LMrg==
X-Received: by 2002:a1c:7f10:: with SMTP id a16mr765409wmd.30.1554311322898;
        Wed, 03 Apr 2019 10:08:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5orWa1p25wp6tlv5OLGrMU+W7KKguqAbDuxeoE8Rl4iYNRGvx0y3bW2kC3IDs0dzNsNo8
X-Received: by 2002:a1c:7f10:: with SMTP id a16mr765364wmd.30.1554311321926;
        Wed, 03 Apr 2019 10:08:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554311321; cv=none;
        d=google.com; s=arc-20160816;
        b=BFG+oFcXCMDmZABTTvJGMXMH6vdoDSskok+TaZfwvF6/ydcMQXD6gRA6Ff2Y5YVtiI
         NcKSJkaohSE2PwHIVeG3NJurMP/V9z4igOiV9W681jVi+5uWnZz+j8LYDOmV0mfgpTyU
         eG3qBSgBXry1LSzZ4mun7MdcHnQdIAC8taVlkOz1A7ooo9BEDp85zcGLUVETnEE+7YiE
         5OhB+BWDCQlmE+knMLkTRl8Ku4L+8sTfo9fH0FBCzsTgWOt+gTr8b8J4126imAtXEPkH
         3sqj0WGknRqz5BDY7pzN8vlhT3zbmx4zA8cP6Cp+6/L+SQQMK0+egjqvkoYUZPJ1Gzer
         zdMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=szulT7NfpOOAl6Q5NRLBlwod2VyZhZp2orgKdKl2/8M=;
        b=k8NmbQW51xf8XK6eJ4rd6I42GBiFExWQVYUNh1ZKx7BOZS0aEVtPpOcxgbCADXK/7S
         SDHgo6q2zDTfT22dP0y8i1je41TstG2UVFuFXLsQU/E9Ve7nwFqlhfbfhc5nz+PBZwOn
         F9rgZQGSeDfSda99mIRd7IDENXs1i/w3aO6fkQYIfX7/6vHpopuPRWZs/OxhhvW6smSk
         rD7UeXUhP3/Wgg+EPvYf4y80qZ3SQqD/cVnAlNLK3wVEyo0kw6LTFuq75KNjmNRMhv+9
         5iE+FxaPzdkkxf8RrkmD0Tt7JJkhYu/4ZdnEyJEituQ80eSsqYRWR7hiwI3d2csactYn
         eqDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id y8si11006676wrn.405.2019.04.03.10.08.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 10:08:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hBjMx-0003uc-II; Wed, 03 Apr 2019 17:08:11 +0000
Date: Wed, 3 Apr 2019 18:08:11 +0100
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
Message-ID: <20190403170811.GR2217@ZenIV.linux.org.uk>
References: <20190403042127.18755-1-tobin@kernel.org>
 <20190403042127.18755-15-tobin@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403042127.18755-15-tobin@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 03:21:27PM +1100, Tobin C. Harding wrote:
> The dentry slab cache is susceptible to internal fragmentation.  Now
> that we have Slab Movable Objects we can defragment the dcache.  Object
> migration is only possible for dentry objects that are not currently
> referenced by anyone, i.e. we are using the object migration
> infrastructure to free unused dentries.
> 
> Implement isolate and migrate functions for the dentry slab cache.

> +		/*
> +		 * Three sorts of dentries cannot be reclaimed:
> +		 *
> +		 * 1. dentries that are in the process of being allocated
> +		 *    or being freed. In that case the dentry is neither
> +		 *    on the LRU nor hashed.
> +		 *
> +		 * 2. Fake hashed entries as used for anonymous dentries
> +		 *    and pipe I/O. The fake hashed entries have d_flags
> +		 *    set to indicate a hashed entry. However, the
> +		 *    d_hash field indicates that the entry is not hashed.
> +		 *
> +		 * 3. dentries that have a backing store that is not
> +		 *    writable. This is true for tmpsfs and other in
> +		 *    memory filesystems. Removing dentries from them
> +		 *    would loose dentries for good.
> +		 */
> +		if ((d_unhashed(dentry) && list_empty(&dentry->d_lru)) ||
> +		    (!d_unhashed(dentry) && hlist_bl_unhashed(&dentry->d_hash)) ||
> +		    (dentry->d_inode &&
> +		     !mapping_cap_writeback_dirty(dentry->d_inode->i_mapping))) {
> +			/* Ignore this dentry */
> +			v[i] = NULL;
> +		} else {
> +			__dget_dlock(dentry);
> +		}
> +		spin_unlock(&dentry->d_lock);
> +	}
> +	return NULL;		/* No need for private data */
> +}
> +
> +/*
> + * d_migrate() - Dentry migration callback function.
> + * @s: The dentry cache.
> + * @v: Vector of pointers to the objects to migrate.
> + * @nr: Number of objects in @v.
> + * @node: The NUMA node where new object should be allocated.
> + * @private: Returned by d_isolate() (currently %NULL).
> + *
> + * Slab has dropped all the locks. Get rid of the refcount obtained
> + * earlier and also free the object.
> + */
> +static void d_migrate(struct kmem_cache *s, void **v, int nr,
> +		      int node, void *_unused)
> +{
> +	struct dentry *dentry;
> +	int i;
> +
> +	for (i = 0; i < nr; i++) {
> +		dentry = v[i];
> +		if (dentry)
> +			d_invalidate(dentry);

Oh, *brilliant*

Let's do d_invalidate() on random dentries and hope they go away.
With convoluted and brittle logics for deciding which ones to
spare, which is actually wrong.  This will pick mountpoints
and tear them out, to start with.

NAKed-by: Al Viro <viro@zeniv.linux.org.uk>

And this is a NAK for the entire approach; if it has a positive refcount,
LEAVE IT ALONE.  Period.  Don't play this kind of games, they are wrong.
d_invalidate() is not something that can be done to an arbitrary dentry.

