Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70F30C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:08:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 283A320840
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:08:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="S7rUKC1h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 283A320840
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9D366B000A; Wed, 24 Jul 2019 14:08:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4CC36B000C; Wed, 24 Jul 2019 14:08:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3AB98E0003; Wed, 24 Jul 2019 14:08:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 941946B000A
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:08:39 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p34so42230382qtp.1
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 11:08:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ZLdMBcqFGKnya02V6xTsnoJZW3Z9hdAyMDyBEEBYZwk=;
        b=T0Yx16dW7SxKEUihzLXC5MgeL/K+3qpzkK9kusEjeELQALS/V8Ofp7OqEFgeeL9zaO
         dH4rd5nIcKO0gR5SVqjeYpVZfhKStWfroILwwhHDipjqtUj7C29/aSDR2oNTsFBv4nt9
         cpTuuuGjbUfkXcLZ0s8AdbcpYSyNyqVx/Eb+czGJrXUpxLI35ybLqiRkPq0AD6Dvsc/5
         zqNM4NXR5cgxyWYFgGvYmgQOBMeWf+u+2GsWD55kSOAWHEOE7zXx2pE11IRcTUhmEaxn
         RZmJLn2swa/zOB/p0DqoHu9rx09QVdKNw2SGyXJ/WXfdKnQlfSyrCQtYBYYy/nUQ7l5p
         eQRg==
X-Gm-Message-State: APjAAAUjW1IJWXmz83SR55Haet1Bdq2ofY3pmwA9XNvpQuXehXNzhlZA
	A3zWnfQRc3JTzKrPiwzpeXo7AGGcRe/msFwdD4eHFGr+PfwdFCjIa0ZVb3Gfs16oDtsJxTNnXAU
	Q5W5rFM+TMjjey2yExfM4c2zT2nQNc4OPGFxEB71z9orZvAM00kd01ZozzG8yXZNe5g==
X-Received: by 2002:aed:3ac1:: with SMTP id o59mr58209701qte.260.1563991719329;
        Wed, 24 Jul 2019 11:08:39 -0700 (PDT)
X-Received: by 2002:aed:3ac1:: with SMTP id o59mr58209646qte.260.1563991718601;
        Wed, 24 Jul 2019 11:08:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563991718; cv=none;
        d=google.com; s=arc-20160816;
        b=HTxUU3Lx+ouT0NNPSQclDTYtOxmd6727mAvffkyTqGouViG6wHQ3X2NxenNIpD62sW
         FP7Jya1aviozgcWQqyHH7iJM739wFvHujaUsoKDX/tO2+Mm4rhXFlplOaCDBBPbIIByJ
         j4ZIvYoznyteGiQfAM3MLdlscpA4TCIL1Q0ffkFd7/vcUsYiogVgCOANMhnld1yGRGiL
         fKzXI7YyzlOAf90V71EhkN4QUVAH+hiRkkNdJE+7khH6TiWNE1Go0FhmPvVWVvM67myK
         by/fVyyZ5oaFsIQ305h7BkAsdBBuvouyHLaJv6ay9IXD6nx3bqVkKQYWdQo2yyRzgyFO
         6RBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ZLdMBcqFGKnya02V6xTsnoJZW3Z9hdAyMDyBEEBYZwk=;
        b=jxevDfNcp+1Ff26yXVjQexj3VYhla3R6fQufp1xoXrzxPXARDK2+Pt1g3SNTs0TDR6
         Kv2iflLjVg5OEEdfpJS0oylV/AeHZa1LUZyO05JeCC4XXY5L2oKAT3SAIZJMoi4H4mqq
         JmpXbYE2dBfh6++zmgHVyYSxqAe7EwwQpB8jpZFvMk9V2ApzBtncGbPGv/rpJYpkt87y
         3xwYK0f84W39WuSLXAKC/Uaxxl8gWrM3CLUKU+DDnLGF35dddFYswFdJOBnpKI7wJebh
         GymhQCXGkkkICpjEL3Xp+qggV3rA3pWztH+5jcse79HxUngAOW/1ES2LkUKAiES0Y4vK
         EF5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=S7rUKC1h;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r67sor26895352qkd.55.2019.07.24.11.08.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 11:08:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=S7rUKC1h;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ZLdMBcqFGKnya02V6xTsnoJZW3Z9hdAyMDyBEEBYZwk=;
        b=S7rUKC1hP1+ZhH3UP11jol99wjJrkdHFHWPmbPAsoHGA2OkbYAPGgChi4JgYRiKTlA
         ivkNkOjRFM1AWz0SOCeFg5IZu82LX7zT++0UHabmT6tlcapyF4hoi2yEd0kJkX0Zlhuy
         G5oemA8Fh1PR4M52mRNWhYmvibd37x0ivsWhY4xHbfKNpzeW6GAUBSsZmYlfnypzgdEv
         ff4NbVY5PS4zXE2RFmZUCL7xJBpQvmsMEiwwnmerSY+eEnHKSvxQQLgDJjkdMEzRg93N
         trKhYFepum43PWTaenbut+z5hDtDVd/KJNIZMG3RMka+hN7laWuvWymC+OG9kplFGJNI
         o0eA==
X-Google-Smtp-Source: APXvYqyUhibTemqaI03gwtS61w99gAgQQ5F/eG0mK+lhyla7PrZjk1HOKK+XfNVnKzTJUkkmUlG2cg==
X-Received: by 2002:a37:f511:: with SMTP id l17mr50579291qkk.99.1563991718206;
        Wed, 24 Jul 2019 11:08:38 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id s25sm20315125qkm.130.2019.07.24.11.08.37
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Jul 2019 11:08:37 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hqLgr-0003X8-9P; Wed, 24 Jul 2019 15:08:37 -0300
Date: Wed, 24 Jul 2019 15:08:37 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>
Subject: Re: [PATCH] mm/hmm: replace hmm_update with mmu_notifier_range
Message-ID: <20190724180837.GF28493@ziepe.ca>
References: <20190723210506.25127-1-rcampbell@nvidia.com>
 <20190724070553.GA2523@lst.de>
 <20190724152858.GB28493@ziepe.ca>
 <20190724175858.GC6410@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724175858.GC6410@dhcp22.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 07:58:58PM +0200, Michal Hocko wrote:
> On Wed 24-07-19 12:28:58, Jason Gunthorpe wrote:
> > On Wed, Jul 24, 2019 at 09:05:53AM +0200, Christoph Hellwig wrote:
> > > Looks good:
> > > 
> > > Reviewed-by: Christoph Hellwig <hch@lst.de>
> > > 
> > > One comment on a related cleanup:
> > > 
> > > >  	list_for_each_entry(mirror, &hmm->mirrors, list) {
> > > >  		int rc;
> > > >  
> > > > -		rc = mirror->ops->sync_cpu_device_pagetables(mirror, &update);
> > > > +		rc = mirror->ops->sync_cpu_device_pagetables(mirror, nrange);
> > > >  		if (rc) {
> > > > -			if (WARN_ON(update.blockable || rc != -EAGAIN))
> > > > +			if (WARN_ON(mmu_notifier_range_blockable(nrange) ||
> > > > +			    rc != -EAGAIN))
> > > >  				continue;
> > > >  			ret = -EAGAIN;
> > > >  			break;
> > > 
> > > This magic handling of error seems odd.  I think we should merge rc and
> > > ret into one variable and just break out if any error happens instead
> > > or claiming in the comments -EAGAIN is the only valid error and then
> > > ignoring all others here.
> > 
> > The WARN_ON is enforcing the rules already commented near
> > mmuu_notifier_ops.invalidate_start - we could break or continue, it
> > doesn't much matter how to recover from a broken driver, but since we
> > did the WARN_ON this should sanitize the ret to EAGAIN or 0
> > 
> > Humm. Actually having looked this some more, I wonder if this is a
> > problem:
> > 
> > I see in __oom_reap_task_mm():
> > 
> > 			if (mmu_notifier_invalidate_range_start_nonblock(&range)) {
> > 				tlb_finish_mmu(&tlb, range.start, range.end);
> > 				ret = false;
> > 				continue;
> > 			}
> > 			unmap_page_range(&tlb, vma, range.start, range.end, NULL);
> > 			mmu_notifier_invalidate_range_end(&range);
> > 
> > Which looks like it creates an unbalanced start/end pairing if any
> > start returns EAGAIN?
> > 
> > This does not seem OK.. Many users require start/end to be paired to
> > keep track of their internal locking. Ie for instance hmm breaks
> > because the hmm->notifiers counter becomes unable to get to 0.
> > 
> > Below is the best idea I've had so far..
> > 
> > Michal, what do you think?
> 
> IIRC we have discussed this with Jerome back then when I've introduced
> this code and unless I misremember he said the current code was OK.

Nope, it has always been broken.

> Maybe new users have started relying on a new semantic in the meantime,
> back then, none of the notifier has even started any action in blocking
> mode on a EAGAIN bailout. Most of them simply did trylock early in the
> process and bailed out so there was nothing to do for the range_end
> callback.

Single notifiers are not the problem. I tried to make this clear in
the commit message, but lets be more explicit.

We have *two* notifiers registered to the mm, A and B:

A invalidate_range_start: (has no blocking)
    spin_lock()
    counter++
    spin_unlock()

A invalidate_range_end:
    spin_lock()
    counter--
    spin_unlock()

And this one:

B invalidate_range_start: (has blocking)
    if (!try_mutex_lock())
        return -EAGAIN;
    counter++
    mutex_unlock()

B invalidate_range_end:
    spin_lock()
    counter--
    spin_unlock()

So now the oom path does:

invalidate_range_start_non_blocking:
 for each mn:
   a->invalidate_range_start
   b->invalidate_range_start
   rc = EAGAIN

Now we SKIP A's invalidate_range_end even though A had no idea this
would happen has state that needs to be unwound. A is broken.

B survived just fine.

A and B *alone* work fine, combined they fail.

When the commit was landed you can use KVM as an example of A and RDMA
ODP as an example of B

Jason

