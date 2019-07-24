Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 271BAC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:01:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC9CF21926
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:01:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="dPDOwqvv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC9CF21926
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80E968E000F; Wed, 24 Jul 2019 14:01:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E5BB8E0005; Wed, 24 Jul 2019 14:01:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FAC68E000F; Wed, 24 Jul 2019 14:01:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 528988E0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:01:56 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id r58so42220496qtb.5
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 11:01:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=NHrhrhDMfOD8855Z/WzNY5buipYXjy+AC0JGYKIcbF8=;
        b=USgsgCbHyHIf1C254Ei0tiAngnEfw8fnWkPhlsjiIbxlb3OmzvBsjWRuYZFd6DN1j4
         bhvBi46IqjQOy3RGlNXquwvujqDxqGeIAizgrWoJoeHf5s8GkgutXh9vgoJo2OWSVbmz
         a1LoCpnXddj4S6YAX42JcUToihI+Dxlm9KCgfS9bSuWOwrsU62t4jUvp44a2Xd+qZodq
         txerCNtsGDGTPGlASnA43kognJTUXgC8xOSHb6aYfCW/gGo8uCxUzaElTONE0w2cEE+B
         0DJLtJ51vp4gSYbPyPwAoI3WHGtUU+ou+ioaRoWYWX503tYyBg3PW5qKgh1D5jNe59N1
         Yz5Q==
X-Gm-Message-State: APjAAAWOfTPHPvcrq39Co/D/O67AMMQVnzPb6A+obQy22ksMAOxr/YGL
	388X47IvYMQj0uwFEeRaw+SJZL4NZz2+obSqdYDrqLunfD8PsubOM4xcq1pgwZF7HnzoazGxf2h
	SNm/boCYnXqRitX41mD4/D7rNdHPldj6sSTed9X3pPbb+VtRnLuPGixzR1gixiegG+w==
X-Received: by 2002:a37:a2d1:: with SMTP id l200mr56191603qke.330.1563991316128;
        Wed, 24 Jul 2019 11:01:56 -0700 (PDT)
X-Received: by 2002:a37:a2d1:: with SMTP id l200mr56191553qke.330.1563991315513;
        Wed, 24 Jul 2019 11:01:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563991315; cv=none;
        d=google.com; s=arc-20160816;
        b=0Wu3dC4hZ0M/HquoyRcDS1KT7MmetXHuHB0xvmhY6/P2tlFNCDv3yrrm1FfB3JQDTO
         0n75Fygu1I7N8/dBVJduqe3tglKbwhyseg69Kf0IE+uhBh3Ceh6VOpKElSP7tCAOidtV
         4MgGSz3aa4ztBz0qAceg92dBZRv2gWVA/biDLlfntqVsQ6x9FWgnOYX9mqbS27qaqDcX
         IcSlNoUabOe0EOk9vWXys25WMLgE+DP2ftpeiGCQurdPj+A1AAWd9sAypGeUs/Lz1kzc
         b7fcydtWEqL/6rQwssfOkkheVHlYkmv1C4kbKRd7RD0m1em4vfDacZuG/6jkRYV/HAhK
         gMew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=NHrhrhDMfOD8855Z/WzNY5buipYXjy+AC0JGYKIcbF8=;
        b=oRuBVPWTy8wv6drLECw6JCugIhcGQ9WrF7L2dZtSXttP1amDMjoPjLb6tPtcz68if2
         v725aBtBybFFZUfLVyDvuRxszWsCLa6xpHedg7cPwveof/Hqe5ZAgIb01CNjhWrt5mId
         cqVxIVSRYHo4B4b6pQ/cD9jbVZGkuBATu3Kmu7NwKo5L8GX38Nuo1LVNQj0ICCOQrSCN
         y7ZsiRyFY83qTLtSU89ufHaOE0iyDsg77yuhAgKBVOnVRLHoSysTbLsTyqAWtKq4ma/L
         ZNcTc8hqRd4+FGPka3pb9Gnd0cHxBF78q/nA/jTPDSs/4jKvL8iSalv0zo20FVW89AMw
         cHkA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=dPDOwqvv;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b17sor40259827qvh.43.2019.07.24.11.01.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 11:01:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=dPDOwqvv;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=NHrhrhDMfOD8855Z/WzNY5buipYXjy+AC0JGYKIcbF8=;
        b=dPDOwqvvcar2QZyrIWmnpS9kSbPHrR/wGiHoOguWcVWXL2QB4EbGlIpDh3GEhsu5Ui
         n8DvGZHMQ345DUYe/IKC+YM0nSeJddxkNt+S0YsC7V+nopWE6ScCmbBtAr9p8b7zuqMS
         yY6K83rBY7uS/1zb8JLsSuLsaZshzgZRKjMl6YdJRTawKHyG7IfOhH0vdHKybWcVN7ax
         GxFiQtZPpBb9p7N9LWeYpM2uz0JC6GufyTb6S7aDM2vJh8BzaSTgMbXeFslyg867My9K
         zrKo9Xi9joxNJiWv358sWE53cKRje+sKwuovXQ00SzRkhk+wqTRybQ1JEfewFmBiBsMW
         xDjQ==
X-Google-Smtp-Source: APXvYqwh9oIClfhj+Xu8Ca6v+JnH5wuP+h6Sc8J95We/ArJyD9/rby1kOqJsMt32kMVWN+JOLxYozw==
X-Received: by 2002:a0c:f193:: with SMTP id m19mr60859511qvl.20.1563991315101;
        Wed, 24 Jul 2019 11:01:55 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id r4sm32015444qta.93.2019.07.24.11.01.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Jul 2019 11:01:54 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hqLaL-0003Qv-NY; Wed, 24 Jul 2019 15:01:53 -0300
Date: Wed, 24 Jul 2019 15:01:53 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: Michal Hocko <mhocko@suse.com>, Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>
Subject: Re: [PATCH] mm/hmm: replace hmm_update with mmu_notifier_range
Message-ID: <20190724180153.GE28493@ziepe.ca>
References: <20190723210506.25127-1-rcampbell@nvidia.com>
 <20190724070553.GA2523@lst.de>
 <20190724152858.GB28493@ziepe.ca>
 <20190724153305.GA10681@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724153305.GA10681@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 05:33:05PM +0200, Christoph Hellwig wrote:
> On Wed, Jul 24, 2019 at 12:28:58PM -0300, Jason Gunthorpe wrote:
> > Humm. Actually having looked this some more, I wonder if this is a
> > problem:
> 
> What a mess.
> 
> Question: do we even care for the non-blocking events?  The only place
> where mmu_notifier_invalidate_range_start_nonblock is called is the oom
> killer, which means the process is about to die and the pagetable will
> get torn down ASAP.  Should we just skip them unconditionally?  nouveau
> already does so, but amdgpu currently tries to handle the non-blocking
> notifications.

I think the issue is the pages need to get freed to make the memory
available without becoming entangled in risky locks and deadlock.

Presumably if we go to the 'torn down ASAP' things get more risky that
the whole thing deadlocks?

I'm guessing a bit, but I *think* non-blocking here really means
something closer to WQ_MEM_RECLAIM, ie you can't do anything that would
become entangled with locks in the allocator that are pending on OOM??

(if so we really should call this reclaim not non-blocking)

ie for ODP umem_rwsem is held by threads while calling into kmalloc,
so when we go to do the exit_mmap we still do the
invalidate_range_start and can still end up blocked on a lock that is
held by a thread waiting for kmalloc to return.

Would be nice to know if this guess is right or not.

Jason

