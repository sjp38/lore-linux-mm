Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E452DC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:05:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7585520700
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:05:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7585520700
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D73606B000A; Wed,  3 Apr 2019 15:05:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D547A6B000E; Wed,  3 Apr 2019 15:05:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C398B6B0010; Wed,  3 Apr 2019 15:05:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 78FF16B000A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 15:05:40 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id t20so48946wmi.1
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 12:05:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=OEYJTk4ERbxR3Ks/Z8SoPrEsQATOWMET3H09eKVbTkg=;
        b=bUQ9BmcFKfSgpN68sPr9vzKtz/ecduCXxkA/YmAu8xrtAdR+2oO/DBDAuEG9uWIgcU
         IcEUrumOicIPDHtQ78BmDHy1q8YLohtskvzHaIUpkn3t8OVaQxi2Aw48LhxNGGHFgLkA
         Vt/0pDMsRaGcwAp4WPrir0h21wAkyIzPdrMy7NxRC7/JpwZP+MX/U2NXPNrtJ5e8uONm
         XiQ6TWRYdBcHbQaFErr3QDPA2gQwgq1yF4asBfbm6+ZNK1YX4sD0WZewkta+5N9FUH3+
         pZCwhbr7cPQvVsbirfQRhAABjUXHsBJtc51NcaGP2aWC07mg/v+9k89sGakrue3dLbT+
         AFJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: APjAAAX0bZTk8WNYeHdN99i8uMHytJ2KrIaAuE9oA1IPhxpqS4zAaO62
	J6kp92rWBU8DxbsPmQDAKg4HHoYt/0mDQw5qPqnVc8dtT4FteD7CE+0ROqfgFcSdwWiwl3ZYj4O
	c7cR8rSWSBVAMPEX+wT+fUJ8Mwp95XyJ20uMQaEBNlrIdAEvUa2ZMOjwJhVEoa7HzHQ==
X-Received: by 2002:adf:ef0c:: with SMTP id e12mr846250wro.170.1554318339947;
        Wed, 03 Apr 2019 12:05:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvBadZh5ndL/sAcr851EVC7dAB+rd8y2mOll/dAmT9DWHU55LEu1023D2z0OieEAKWebi/
X-Received: by 2002:adf:ef0c:: with SMTP id e12mr846201wro.170.1554318339118;
        Wed, 03 Apr 2019 12:05:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554318339; cv=none;
        d=google.com; s=arc-20160816;
        b=r3ml3eeJpEySza2wmcbo/syRdlFtyZ5VnJ3qzfGD3mXcBfYyrYLWJNqYB850LwUvRa
         zR6PDodJbtlwf8ed56klP/11/L0e3w6fMk3YslIKozwzL7GUv+7yEQZyLBAsyZBKJ75S
         /RulJma3SyfpQKAG/ZEg2vtxm9WCREa+9/B/QNTt3zGUF7Oee3Z28xU6ENHhrJH+NXrW
         5UgxJHvuyJvYr8Vs6dHEA87CrNwEMU6+0Odv7PmjpfG7E2bFgQY/9bmSt8qTUHTEXLsU
         IzkrmH/sqUhDx26t4jBwmA6ulDf3SwFpZdH9jQUp7WLekL5mMu59EhG3CkdYWoEXq8qX
         /GYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=OEYJTk4ERbxR3Ks/Z8SoPrEsQATOWMET3H09eKVbTkg=;
        b=pOb4cSuSgQROHagc7mrVgfB3ODzHJvOTgFyes9L0MvQN3y9R7S9O2HyF56Kgd16FSm
         0DycrRjb9gUJaJ+xE2J9fUbTp6q5jHoFEjwLQCDONUSwCxkXByOxSs1Am5UXOSuw957U
         ET/ER9mrrFmQwaJbBh9kgsZGAq/CYpdpnNwypnhU003m2Tzjt3ZZrxaLaaoNhoFzOK+/
         ppQmDl24hEbT2Pmg/9ZdQAtR1I7Cdv3ukF1PA2myksT0eAlUrt5tNmUy2eejXIP36Eja
         wNyDDdyELaJifWp/MQ8v/DAF2w8XT2wqYzDrWzQQ8FiAW11cacr1Sb5abbUSpIo810no
         4Y2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id k4si9845121wmi.131.2019.04.03.12.05.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 12:05:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hBlCK-0006a6-NT; Wed, 03 Apr 2019 19:05:20 +0000
Date: Wed, 3 Apr 2019 20:05:20 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: Christopher Lameter <cl@linux.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
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
Message-ID: <20190403190520.GW2217@ZenIV.linux.org.uk>
References: <20190403042127.18755-1-tobin@kernel.org>
 <20190403042127.18755-15-tobin@kernel.org>
 <20190403170811.GR2217@ZenIV.linux.org.uk>
 <01000169e458534a-3c6a5d6f-3054-4c64-b5f9-7f46c811eeac-000000@email.amazonses.com>
 <20190403182454.GU2217@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403182454.GU2217@ZenIV.linux.org.uk>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 07:24:54PM +0100, Al Viro wrote:

> If by "how to do it right" you mean "expedit kicking out something with
> non-zero refcount" - there's no way to do that.  Nothing even remotely
> sane.
> 
> If you mean "kick out everything in this page with zero refcount" - that
> can be done (see further in the thread).
> 
> Look, dentries and inodes are really, really not relocatable.  If they
> can be evicted by memory pressure - sure, we can do that for a given
> set (e.g. "everything in that page").  But that's it - if memory
> pressure would _not_ get rid of that one, there's nothing to be done.
> Again, all VM can do is to simulate shrinker hitting hard on given
> bunch (rather than buggering the entire cache).  If filesystem (or
> something in VFS) says "it's busy", it bloody well _is_ busy and
> won't be going away until it ceases to be such.

FWIW, some theory: the only kind of long-term reference that can
be killed off by memory pressure is that from child to parent.
Anything else (e.g. an opened file, current directory, mountpoint,
etc.) is out of limits - it either won't be going away until
the thing is not pinned anymore (close, chdir, etc.) *or*
it really shouldn't be ("VM wants this mountpoint dentry freed,
so just dissolve the mount" is a bloody bad idea for obvious
reasons).

Stuff in somebody's shrink list is none of our business - somebody
else is going to try and evict it anyway; if it can be evicted,
it will be.

Anything with zero refcount that isn't in somebody else's
shrink list is fair game.

Directories with children could, in principle, be helped along -
we could try shrink_dcache_parent() on them, which might end
up leaving them with zero refcount.  However, it's not cheap
and if you pick the root dentry of a filesystem, it'll try to
evict everything on it that can be evicted, be it in this page
or not.  And there's no promise that it will end up evictable
after that.

So from the correctness POV
	* you can kick out everything with zero refcount not
on shrink lists.
	* you _might_ try shrink_dcache_parent() on directory
dentries, in hope to drive their refcount to zero.  However,
that's almost certainly going to hit too hard and be too costly.
	* d_invalidate() is no-go; if anything, you want something
weaker than shrink_dcache_parent(), not stronger.

For anything beyond "just kick out everything in that page that
happens to have zero refcount" I would really like to see the
stats - how much does it help, how costly it is _and_ how much
of the cache does it throw away (see above re running into a root
dentry of some filesystem and essentially trimming dcache for
that fs down to the unevictable stuff).

