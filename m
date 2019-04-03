Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8FC7C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 18:25:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72EC020700
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 18:25:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72EC020700
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF4286B000A; Wed,  3 Apr 2019 14:25:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E79E56B0269; Wed,  3 Apr 2019 14:25:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D42BB6B026A; Wed,  3 Apr 2019 14:25:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 831476B000A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 14:25:19 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id e6so26047wrs.1
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 11:25:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=QsEsqZIJDEiA5mPa+vu0/y83h0JGwyblEvsQ1cxdW9k=;
        b=IEed8Bh6TASsJLy8RYhZQWG2TY0jngaB7xqnXjN2Wdg+7sSmem+kLBtYHT1Xqk2Eb0
         D/trarNiO217HaBLULTfaxNorgvEsAc1zWCCrPB7BxGHwFQ2N0UzrN/ce3cFmhg8Vl1k
         YM89d1RlxgVmMvYSCv+QXCX3jiMEAasL/egkOIrGLtyCfFEOwSAAUG+FFbFemLrGbeyy
         fo4nTYjBQt73F9Uir9+aQnbSozfHU+SpA6obcF7ZKsgtWQpaBsPaFTrf+e84ZeljG++0
         uVQfnT5TdzPh7JD/EEbTLkJC4TdLvkDWfHTgu++I2woHTM9meXcb4PMZduD2JorDHjgn
         10xA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: APjAAAX3oRnv3z/+gXOi3je+ZQRKaTefz8yg63pxCRqyvkmyozBwxdFU
	TpTopYFWGAZ9WXs0DKICe5znSHldxFipF3PD/4i6hiJro/K7iZifWXiraIrn8bUUuPL1ySPZtjF
	a+nQkvWwqjtjPpXRzp1RuCk6m4eYHLJe1W71Ge83OWFgikbDObsXOAU/KqxB+91r21A==
X-Received: by 2002:a5d:52cc:: with SMTP id r12mr700681wrv.163.1554315919076;
        Wed, 03 Apr 2019 11:25:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+gElLBmZ2df5x7rm/tl6g1iTKQzeT/GXViTIS+I1gjM9SiEL0IFR9ghY7DfeQ0TpCaXX9
X-Received: by 2002:a5d:52cc:: with SMTP id r12mr700630wrv.163.1554315918121;
        Wed, 03 Apr 2019 11:25:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554315918; cv=none;
        d=google.com; s=arc-20160816;
        b=s5szOPPJQsqYqgXXDuc8jyVf5lK1i63lqoHS16rHEeDcF1BjfGPVkoPjsdoJ3alW96
         dMo4VsN7kR5DbjwScog0ZZ4Z0YIRNSj5hucD800guxRtqPR2s7Dsx7atj0U84PHF/KHA
         oFDpuaa+Rz9LWchDubfOs83ZZ5ilxPKysCjX1sEs0pzqJ/muCybg0kNNcfa3uklIrKF/
         ONaIc99VYAF69qhQwyDulWSAUt9WIbfN/PaDHa6tOg6vSBZb6QLhB9Ob3wEYKPs19Cm9
         bN3scDQUBENlpPSnygeyazguVtygUArOy1BwSeWFgN72lc+gTtKmf9dQsgGjvzHovlO6
         hFYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=QsEsqZIJDEiA5mPa+vu0/y83h0JGwyblEvsQ1cxdW9k=;
        b=olTsBOcezNbaIJnynrsvFmSPoVS+ZmshRlG+xRe6549dbA/tc9bvD9CydPNqTlS21+
         HiS+3AOlgdPhorE4T+3PXk0Xv85hFKrksn2r+D0WGhMZ2ou5r230MV7TrOMT46g+nTTM
         mNPfRkromal9xNTGxXYaEPvfIkqdjU2DouPMNgs/CyZDkJKPx3xfT9/OgAipENC8ym96
         Vx2PpwJ/LMtixKJnlt4iG/eJa6erVKvnWLAIUoSyMdg3t8XyhQgyL+ev06atPkqOmjGv
         pFMJB0Fi7rMfg3SiZArOSWEsQ2klZycVhhbdlbP69XefiGkO/nDpIJoFDE9oB7k63USR
         79TA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id o11si10673625wru.232.2019.04.03.11.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 11:25:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hBkZC-0005dH-Oh; Wed, 03 Apr 2019 18:24:54 +0000
Date: Wed, 3 Apr 2019 19:24:54 +0100
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
Message-ID: <20190403182454.GU2217@ZenIV.linux.org.uk>
References: <20190403042127.18755-1-tobin@kernel.org>
 <20190403042127.18755-15-tobin@kernel.org>
 <20190403170811.GR2217@ZenIV.linux.org.uk>
 <01000169e458534a-3c6a5d6f-3054-4c64-b5f9-7f46c811eeac-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000169e458534a-3c6a5d6f-3054-4c64-b5f9-7f46c811eeac-000000@email.amazonses.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 05:56:27PM +0000, Christopher Lameter wrote:
> On Wed, 3 Apr 2019, Al Viro wrote:
> 
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
> Well could you help us figure out how to do it the right way? We (the MM
> guys) are having a hard time not being familiar with the filesystem stuff.
> 
> This is an RFC and we want to know how to do this right.

If by "how to do it right" you mean "expedit kicking out something with
non-zero refcount" - there's no way to do that.  Nothing even remotely
sane.

If you mean "kick out everything in this page with zero refcount" - that
can be done (see further in the thread).

Look, dentries and inodes are really, really not relocatable.  If they
can be evicted by memory pressure - sure, we can do that for a given
set (e.g. "everything in that page").  But that's it - if memory
pressure would _not_ get rid of that one, there's nothing to be done.
Again, all VM can do is to simulate shrinker hitting hard on given
bunch (rather than buggering the entire cache).  If filesystem (or
something in VFS) says "it's busy", it bloody well _is_ busy and
won't be going away until it ceases to be such.

