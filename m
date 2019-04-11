Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53286C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:02:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E15D920850
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:02:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E15D920850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7275A6B0269; Thu, 11 Apr 2019 17:02:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FB476B026A; Thu, 11 Apr 2019 17:02:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C5956B026B; Thu, 11 Apr 2019 17:02:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0C09C6B0269
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:02:28 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id u6so4665109wml.3
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:02:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=s2kDOh4+4o/ycl6bfZaVx+gCb5FUYfGdzxsgCA0Qeak=;
        b=Ko4My816qOw7MM2ucTJJfn3OfSUw1TA8sfHOs038wB2UnLhDnOvAuASM1WNqvMZQDB
         NTOnA3SZmTZe/u6Ue/aSfBBlE22Jfr2aJNzEVoKUd6DrwHvMjKqqgA9FTYIo81cclMBs
         k6vJNy1cZhGitzt/B5HzQ0iXK+n5SdnwvmNkFztMQQpuUUMyhGtXfm1UNPjiNAqjxSCh
         lUWwbaFxLak7RV5AraJceitMXL4N7ThR+GeKMObRIfCyCQ4gB65CVRZFM5FGQ3bG3NaE
         RNKxnbzxYOyu3otdcGHh0Pwsxo/dP9jYLOlkHVjQaQ76xH7Z7WqkihtkMOQ/LfFevCAH
         OnuQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: APjAAAUP60kce7vgB+0/IfY/ykTV3Q+TRfic3rHcUMGWdkjEV0oLhyxu
	lSUcKYD8tu3QC6QD5oYNp1Gwd9xJfafh4iueBdQ9c9utzi+pCXmAn4UeJreGNvga+jUXC+30OnI
	YfeoascQAvbFJClLGbZxhJ3GBONU04qWrA0VElAUdBLddFVmnTrmHHkfoNmtLo40YKw==
X-Received: by 2002:a5d:458f:: with SMTP id p15mr32232793wrq.188.1555016547547;
        Thu, 11 Apr 2019 14:02:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxvncTZNF2akm8w/MVV+LoNW61njLUgs0n6GghRS14ei9AK2PlQqGU5ZZ49HH0R8qRdhZM
X-Received: by 2002:a5d:458f:: with SMTP id p15mr32232759wrq.188.1555016546767;
        Thu, 11 Apr 2019 14:02:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555016546; cv=none;
        d=google.com; s=arc-20160816;
        b=w/GKNUJC3Rqr+wVJblRHkgPncqBHtrxXAuWBm9Am31lwC4OCqvsgZr7rA/m+LRJ3xW
         12H1JL/v5CaxXV/cQKBa+5Y1nLDqYUsNPLnxyseiWofdOv6x8+7RsDsRNwMNsDd/WPi8
         GYOSEajT0N1DrejWAP+3Se6Ay7YnPNYdP6aM6/pGH8W+RDInnJdDCh10RXCTm/f0lEC6
         VEu6HCduR5gGU5deit3zYmv6pkrAD4E82D0+09UaPOTrPV92cEq42C0bGetUmxdDextH
         Ajp8ci5Y/NHdy+AVDxBGa8tZ7gXbTLg6rmBTcncXmTo5bUCdV97pPTgxamLqMI+1S8m2
         EG/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=s2kDOh4+4o/ycl6bfZaVx+gCb5FUYfGdzxsgCA0Qeak=;
        b=v8MBegHt9AX/7Fra7+3tuXyLiyFgFu3pIiaT8EL5kxjCQRDCPiE6Ms7hyREDZCikfS
         CIjiY1IAZakrmkah9MxG05xK7MiBkDQ/1iMrMPNhkZ/hRWnulKPRzB/Q4MFD+QjXLGTR
         IaGyuV/JcS5AKx0mjjFpRAKfNF+0gaHyQazhACEKu0pl5ijcRdKKA8xuVs41FqfIsgpd
         asYQadYHDJK/7LSdE9/GV5j3s5Xgxf3vZS0eZMoK0q8B5nvQAFRBGK/C0U2A6wrYhnMP
         GQB0XTU2nDgEZdysMZYwtpyKOlpbkAdYtM6eBUvTq3LnLUyzIxOm0SXjl7XQZwzOHybs
         LZfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id g193si3674777wme.159.2019.04.11.14.02.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Apr 2019 14:02:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hEgpc-0002tG-Ba; Thu, 11 Apr 2019 21:02:00 +0000
Date: Thu, 11 Apr 2019 22:02:00 +0100
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
	linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC PATCH v3 14/15] dcache: Implement partial shrink via Slab
 Movable Objects
Message-ID: <20190411210200.GH2217@ZenIV.linux.org.uk>
References: <20190411013441.5415-1-tobin@kernel.org>
 <20190411013441.5415-15-tobin@kernel.org>
 <20190411023322.GD2217@ZenIV.linux.org.uk>
 <20190411024821.GB6941@eros.localdomain>
 <20190411044746.GE2217@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411044746.GE2217@ZenIV.linux.org.uk>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 05:47:46AM +0100, Al Viro wrote:

> Note, BTW, that umount coming between isolate and drop is not a problem;
> it call shrink_dcache_parent() on the root.  And if shrink_dcache_parent()
> finds something on (another) shrink list, it won't put it to the shrink
> list of its own, but it will make note of that and repeat the scan in
> such case.  So if we find something with zero refcount and not on
> shrink list, we can move it to our shrink list and be sure that its
> superblock won't go away under us...

Aaaarrgghhh...  No, we can't.  Look: we get one candidate dentry in isolate
phase.  We put it into shrink list.  umount(2) comes and calls
shrink_dcache_for_umount(), which calls shrink_dcache_parent(root).
In the meanwhile, shrink_dentry_list() is run and does __dentry_kill() on
that one dentry.  Fine, it's gone - before shrink_dcache_parent() even
sees it.  Now shrink_dentry_list() holds a reference to its parent and
is about to drop it in
                dentry = parent;
                while (dentry && !lockref_put_or_lock(&dentry->d_lockref))
                        dentry = dentry_kill(dentry);
And dropped it will be, but... shrink_dcache_parent() has finished the
scan, without finding *anything* with zero refcount - the thing that used
to be on the shrink list was already gone before shrink_dcache_parent()
has gotten there and the reference to parent was not dropped yet.  So
shrink_dcache_for_umount() plows past shrink_dcache_parent(), walks the
tree and complains loudly about "busy" dentries (that parent we hadn't
finished dropping), and then we proceed with filesystem shutdown.
In the meanwhile, dentry_kill() finally gets to killing dentry and
triggers an unexpected late call of ->d_iput() on a filesystem that
has already been far enough into shutdown - far enough to destroy the
data structures needed for that sucker.

The reason we don't hit that problem with regular memory shrinker is
this:
                unregister_shrinker(&s->s_shrink);
                fs->kill_sb(s);
in deactivate_locked_super().  IOW, shrinker for this fs is gone
before we get around to shutdown.  And so are all normal sources
of dentry eviction for that fs.

Your earlier variants all suffer the same problem - picking a page
shared by dentries from several superblocks can run into trouble
if it overlaps with umount of one of those.

Fuck...  One variant of solution would be to have per-superblock
struct kmem_cache to be used for dentries of that superblock.
However,
	* we'd need to prevent them getting merged
	* it would add per-superblock memory costs (for struct
kmem_cache and associated structures)
	* it might mean more pages eaten by the dentries -
on average half a page per superblock (more if there are very
few dentries on that superblock)

OTOH, it might actually improve the memory footprint - all
dentries sharing a page would be from the same superblock,
so the use patterns might be more similar, which might
lower the fragmentation...

Hell knows...  I'd like to hear an opinion from VM folks on
that one.  Comments?

