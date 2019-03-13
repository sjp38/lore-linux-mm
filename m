Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87925C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 09:19:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13C922171F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 09:19:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Bq7+4Znd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13C922171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 529EB8E0003; Wed, 13 Mar 2019 05:19:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B3248E0001; Wed, 13 Mar 2019 05:19:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37ACE8E0003; Wed, 13 Mar 2019 05:19:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE068E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 05:19:07 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id z131so954598itb.2
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 02:19:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KzxQSaJbsqgdV04fsK2ylmeyEWpxrxzz2n7IfMtSZqI=;
        b=bi3LZKLIlzbDPptIJu5hUzazcz7TQB1uzil3iy8QHOV5H8eQNz0vmsG38TdXjSeMRn
         rtDjBJujpjyr3NgcZF+RLrt3+5Yt5BBfigdzuTxaAIlwlWb6z2fUGZr6zYlS29G/d9+i
         r/dr9xVKU/KGrBSZFASNVwSCJDTglPS7BqEm1zWCQX9SP73k5iw53a0cMMBgXd1Rsjpr
         tuSdEXJzZncBXxJlOq6J2+87b8zV5BDDZdbwLG1MWpvfn6nGmujzzaq39mmckSKX7W3l
         ijnN+UgLfC3o96z5MKP5zhSkk3Req+BUcLIVJDf2nLy1y8jm96ZdVLwb5ToyfVFtTr0F
         FQ4g==
X-Gm-Message-State: APjAAAUK+ufrdcE8YxSZSzmg4GT9T+Q/stu7XN5sFN2BL4EDxa90v7qO
	r6aMOqJOszqnnGK7pAmDMoi4q3pfSXJQ/rg8VdjJXUSLEmbFUIwBMBLL2jOnjmnwJh2dGWXy0nR
	36QRHBBnb+1hTcpLvqNp9C7SZ25F9jWw9NwiB3O4DxM5o8cnGO1xsm6SGRkr8WChkwA==
X-Received: by 2002:a05:660c:12c2:: with SMTP id k2mr1027379itd.17.1552468746777;
        Wed, 13 Mar 2019 02:19:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQdPYQnlgjl7ietGK/75hnAq7c065QgHJ6x0kgH1DNbLxyQLLnR96JzPQCcjksW1l5PE0x
X-Received: by 2002:a05:660c:12c2:: with SMTP id k2mr1027359itd.17.1552468745781;
        Wed, 13 Mar 2019 02:19:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552468745; cv=none;
        d=google.com; s=arc-20160816;
        b=xG8vWmFi5lDKt7DTPYTLbdhC5Z0kuWWx/F7LFIdlv8z63E3O50WQCf6/fi0wSCF9PS
         q69y0KURL0bV7jeh5dmmq8lyxA5O6uItw8uv0HavJqQs0DQK/bjlrESHw/zzD3xBsZKp
         apzhDB8/e/0Ze5e4ZiDbI9KySbISmD5yMYsn5q7LMMbg3L55E0rk5Elnm32QRkJONXP0
         Ftd63vkViQGofUOwvT2vvssgcUAxuCi8guilILTinVZKl/sxn/EI8buf1OoQRmmyApG4
         HJksu1u0fIAG0jjIIKR1Wi9ZOVlbBda9/35zCVDYi/QJ6ffrJp2ip9GsYwpF3sCtPwom
         6F8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=KzxQSaJbsqgdV04fsK2ylmeyEWpxrxzz2n7IfMtSZqI=;
        b=qiRU3nYrRqG1z2uozP02fyRH+n7Rnk7dyRpzs+3Q/gKinh3+5Bf8v6C7cKXyKOjAdC
         AJE0JsWo6xzHTE8y8GaFfo7P4MEqyjYuiccX0Dp5nLXkrUe7t81ZlL9MYeiJxjnQYr02
         0rxXZP1+u+MPazQvpGFgDl+KrGRBv4DQtqCOqwzt+o/BTaNeErQhx/wEX8CWyZWqRfTv
         L0p9/axA3x5kHMeM5WJo+bsnSOoCJtX62qIP9gGD8y75wMWm3cyXTPT37mmNRgTl44jo
         b1+Z9MmVFeqGrpyl+aM4rCa3BhTVxlAMP5LqcHxL5lTP/4oDcN45fYdtSoZqIoZOmfQk
         6a3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Bq7+4Znd;
       spf=temperror (google.com: error in processing during lookup of peterz@infradead.org: DNS error) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id c27si4334023jaf.121.2019.03.13.02.19.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 02:19:00 -0700 (PDT)
Received-SPF: temperror (google.com: error in processing during lookup of peterz@infradead.org: DNS error) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Bq7+4Znd;
       spf=temperror (google.com: error in processing during lookup of peterz@infradead.org: DNS error) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=KzxQSaJbsqgdV04fsK2ylmeyEWpxrxzz2n7IfMtSZqI=; b=Bq7+4Zndp7tTjNamrCv1IFoTS
	sY2LOFDg0fpvuUMjw6ms0dt7lKbF3tt1fjChxjzHCVmXCEElHpFsnz5bTt2+FyQSLIxPNEYbe5cbR
	VBz8e5t1nIQkUiBz7ILKnAPB2bywmeBCdpRU4a5IWO7Fjti9gQcPVbFH/zGhglDag2ZoozU+TJa8P
	dBjyy+DYaa1tVGqAfSgvE6wIFgJE+3mwHI/sf7TY9eApm28xIB3yPbF3TyLmj+UUsxtZlhtcuo4vl
	T6UEQ6z4YJJvgyC9zQbENyHWLpN1NA1hZzksIxUyHNOcMa9GwAqu0aGBtFb9mmWHNnClTjOUcUn1M
	vM2173Qag==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h402D-0007do-9r; Wed, 13 Mar 2019 09:18:49 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 1C2252028B0F8; Wed, 13 Mar 2019 10:18:45 +0100 (CET)
Date: Wed, 13 Mar 2019 10:18:44 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Qian Cai <cai@lca.pw>, Jason Gunthorpe <jgg@mellanox.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] mm/debug: add a cast to u64 for atomic64_read()
Message-ID: <20190313091844.GA24390@hirez.programming.kicks-ass.net>
References: <20190310183051.87303-1-cai@lca.pw>
 <20190311035815.kq7ftc6vphy6vwen@linux-r8p5>
 <20190311122100.GF22862@mellanox.com>
 <1552312822.7087.11.camel@lca.pw>
 <CAK8P3a0QB7+oPz4sfbW_g2EGZZmC=LMEnkMNLCW_FD=fEZoQPA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK8P3a0QB7+oPz4sfbW_g2EGZZmC=LMEnkMNLCW_FD=fEZoQPA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 03:20:04PM +0100, Arnd Bergmann wrote:
> On Mon, Mar 11, 2019 at 3:00 PM Qian Cai <cai@lca.pw> wrote:
> >
> > On Mon, 2019-03-11 at 12:21 +0000, Jason Gunthorpe wrote:
> > > On Sun, Mar 10, 2019 at 08:58:15PM -0700, Davidlohr Bueso wrote:
> > > > On Sun, 10 Mar 2019, Qian Cai wrote:
> > >
> > > Not saying this patch shouldn't go ahead..
> > >
> > > But is there a special reason the atomic64*'s on ppc don't use the u64
> > > type like other archs? Seems like a better thing to fix than adding
> > > casts all over the place.

s64 if anything, atomic stuff is signed (although since we have -fwrapv
it doesn't matter one whit).

> > A bit of history here,
> >
> > https://patchwork.kernel.org/patch/7344011/#15495901
> 
> Ah, I had already forgotten about that discussion.
> 
> At least the atomic_long part we discussed there has been resolved now
> as part of commit b5d47ef9ea5c ("locking/atomics: Switch to generated
> atomic-long").
> 
> Adding Mark Rutland to Cc, maybe he has some ideas of how to use
> the infrastructure he added to use consistent types for atomic64()
> on the remaining 64-bit architectures.

A quick count shows there's only 5 definitions of atomic64_t in the
tree, it would be trivial to align them on type.

$ git grep "} atomic64_t"
arch/arc/include/asm/atomic.h:} atomic64_t;
arch/arm/include/asm/atomic.h:} atomic64_t;
arch/x86/include/asm/atomic64_32.h:} atomic64_t;
include/asm-generic/atomic64.h:} atomic64_t;
include/linux/types.h:} atomic64_t;

Note that the one used in _most_ cases, is the one from linux/types.h,
and that is using 'long'. The others, all typically on ILP32 platforms,
obviously must use long long.

I have no objection to changing the types.h one to long long or all of
them to s64. It really shouldn't matter at all.

