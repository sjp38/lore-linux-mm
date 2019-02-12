Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 271E7C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:25:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D553B21773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:25:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="r07WroLu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D553B21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 686388E0002; Tue, 12 Feb 2019 11:25:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 634DD8E0001; Tue, 12 Feb 2019 11:25:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D5C78E0002; Tue, 12 Feb 2019 11:25:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE0E8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:25:24 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h15so2774296pfj.22
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:25:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UXOmYu8ihitWY2xjw1h49duqO+1FiOv9LYVFGIUUlm4=;
        b=hQrcF/lygApNqgJTyO5nLpoiz5j7f3Yqbepuh4UJnn510F56XXffwZXqsABH3z538Z
         dArsTk38EnviVgvaPLwsZsoPrZwqFVbX9ad9jre3cSyqq22rzQ8YyMhzlZv8wpJSIQ1Q
         vWTkDrMkeQuDLBvggvjMmSPE9GsozvbLzTwud9sKwUXQ36BUsXFaK2yLIRuZccRoCuBA
         X+jhWF/+cruktwqIfDmtxjoLfQqmjoUO1j2s+Fua23Cnsm9+0kZIR2uXiyyTkf9j5u4N
         MG6aUxEkkgo/AsicXWFNW5H7wKKM26LPwpO6JmMomTejZSi0ySuX/Ddxdnwzmp4G/Ejs
         Bnfw==
X-Gm-Message-State: AHQUAuZKFhfqPHEIe9+VFrSsVEba7CP20jG+wYR8ekl47hjSYz63dIDr
	NsuXMGVXmYQOKUEVsLGE3iyd4NkGbLsuEfXz9HESy1Y0Q2dWhCHs914ErlLIaOXYqzSs3BYtWDp
	ysMHFGbPiINVsPMhE7UnPPXU1I/+5MGCAVC+XlR35hMld8T3krlO4KloWxX1g9THJfQ==
X-Received: by 2002:a17:902:b60a:: with SMTP id b10mr4524297pls.303.1549988723658;
        Tue, 12 Feb 2019 08:25:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbCGaYJpIlYLPoVSknuSDpyP1zAkE7ee3H4ylF2DleRzrMlh/fAN2pn0zgi5sz/bk1thJD/
X-Received: by 2002:a17:902:b60a:: with SMTP id b10mr4524259pls.303.1549988723017;
        Tue, 12 Feb 2019 08:25:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549988723; cv=none;
        d=google.com; s=arc-20160816;
        b=eWRitQdGxuGBkiaqi0HLvSTUPtUNZiGMwf5QGhOP8FtUDE9f+GtKsCvxJtsRq7412w
         YzQ974uNed3HK0UCj3SXZNM0OTt6nu7WU2K9Me/xjjiYr1S+tS9NOdmbvJ3qUUrt9w4s
         bP8D6wkrJ25SXcFyC5wfyAYdrKLpSFXuhGmLxpvw5H/hJl6Ii7lk2VRf96imUoCguRLq
         cOh8tMtLkBoNgX3j31QN0hZHPYCxcUdCTSxhpZPi51L7SlpCkJGNI14+41Xr3yYaGAtb
         Q+Yi0YtF6ZwF84Su6rTZ6EHCTw8PZC2YaDS2zc4mfFuEhGowOcaeJxrRhqzMvcIhRQBY
         yCLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=UXOmYu8ihitWY2xjw1h49duqO+1FiOv9LYVFGIUUlm4=;
        b=hUXEegiv3Hv/3OKyPG6f5sVdewRvl77ADu9+HvIVNO8HWnjFmu6IC7DN3q1srxjCqP
         QXkYcKfrZ3apVm0MVvdAG3ZxlFe7VBkI8KVGkpv97qHmpF7jt+QK/X5yAAXP5p0D+/fC
         w2upu40s1dITxgzoJKsA2pJr9xdZPPIFpBYKFxtuBZZgpqlNxdZPPLGoqQuJxfmHOiUN
         RePG99EcCmG9CnbBd9CgZFNoImelA4sZSDPdiQMxIn3aDFPNtVMfK7l16JxL8podQMC9
         U3BGdvnLLkw3vIyRqmNl74ArukOxSqI/6lNlZSHjTY43ze0o8I+1qlh5nbHoOamvd6IC
         TenQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=r07WroLu;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w6si12784828pfb.191.2019.02.12.08.25.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Feb 2019 08:25:23 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=r07WroLu;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=UXOmYu8ihitWY2xjw1h49duqO+1FiOv9LYVFGIUUlm4=; b=r07WroLuUGKY7tbmEpmGKMouH
	l4XuDa5cTYpIGJHzCnGsIDMOxApLPWobeKutP81TUk60VxFocAQo9VktnMwhwyirPAszsEOToYEWV
	f1dvw8MOJ/o+3JTur28G05u/h4LeaL3Hme+ialFLtDxlfduUtPNqAHrR6+7Wt96C1fyJk084Q3Ky9
	o/xfDBDKnykR9EF2MzerlPUFUHFe+EbXF6HuVT3o4gVeKgqMewudsWcCyHCK5SZaHSRhNp70ZmEDa
	LK/eMmCM4NCiM1BPT1NrguQn1OiQ08LbRRzT/ryAj2havV4Qn8q+5ADaPWKpJXPdBUUUrYrZDs2V6
	z4OZPExuw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtas2-0006bk-FB; Tue, 12 Feb 2019 16:25:18 +0000
Date: Tue, 12 Feb 2019 08:25:18 -0800
From: Matthew Wilcox <willy@infradead.org>
To: "Paul E. McKenney" <paulmck@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	kbuild test robot <lkp@intel.com>,
	Suren Baghdasaryan <surenb@google.com>, kbuild-all@01.org,
	Johannes Weiner <hannes@cmpxchg.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [linux-next:master 6618/6917] kernel/sched/psi.c:1230:13:
 sparse: error: incompatible types in comparison expression (different
 address spaces)
Message-ID: <20190212162518.GO12668@bombadil.infradead.org>
References: <201902080231.RZbiWtQ6%fengguang.wu@intel.com>
 <20190208151441.4048e6968579dd178b259609@linux-foundation.org>
 <20190209074407.GE4240@linux.ibm.com>
 <20190212013606.GJ12668@bombadil.infradead.org>
 <20190212155610.GJ4240@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212155610.GJ4240@linux.ibm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 07:56:10AM -0800, Paul E. McKenney wrote:
> On Mon, Feb 11, 2019 at 05:36:06PM -0800, Matthew Wilcox wrote:
> > radix_tree_iter_resume is, happily, gone from my xarray-conv tree.
> > __radix_tree_lookup, __radix_tree_replace, radix_tree_iter_replace and
> > radix_tree_iter_init are still present, but hopefully not for too much
> > longer.  For example, __radix_tree_replace() is (now) called only from
> > idr_replace(), and there are only 12 remaining callers of idr_replace().
> 
> Will this reduce the number of uses of rcu_dereference_raw()?  Or do they
> simply migrate into Xarray?

Unlike the radix tree (which let you do whatever awful locking scheme you
wanted), the XArray requires that you use the spinlock embedded in the
root of the data structure to protect against simultaneous modification.
So all dereferences within the XArray code look like this:

(if either under lock, or rcu lock held):
        return rcu_dereference_check(node->slots[offset],
                                                lockdep_is_held(&xa->xa_lock));

(if we know the lock is held):
        return rcu_dereference_protected(node->slots[offset],
                                                lockdep_is_held(&xa->xa_lock));

The XArray API doesn't expose slot pointers to its clients.  It hides them
inside the xa_state's pointer to the current xa_node.

