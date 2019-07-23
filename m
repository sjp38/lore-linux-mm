Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88DB0C41517
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 18:19:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EB0E218B0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 18:19:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="pAq+kDaH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EB0E218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFC4B8E0019; Tue, 23 Jul 2019 14:19:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAC7B8E0002; Tue, 23 Jul 2019 14:19:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC1608E0019; Tue, 23 Jul 2019 14:19:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 89D4D8E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 14:19:06 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i27so26747223pfk.12
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 11:19:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Ijp19dCgszxKeKL+XBVnkeWJUgHPZc8389ax86PIYT8=;
        b=S3d5J938cXTnmYIU5PCfZhQXJBYGASc+xzvVL4MKFNC7OJKfnfbijCc4QY+NNTJKOW
         xV6D/COwHxU25QN4+tZd6/CJ7OYvIlmkr1HapM963EJ/R/gTX02Bxv2e3QOtiPOalO/T
         Gmz5QkXT91l/+HJOhDgTXnN7GX+2yWg3UNrKAjgs+/ucCUvtuSYYW30CWWNJFx09yU5d
         Soay8HclEvQqjJx4DtOMMHhnvptBdZ1sT95jIOuiDDpVknNI/B1z77mrfXvVuiDL4T+w
         82LTtbmO1nLshNegmRZyMTLdlDCikWNSssbNbQ/bYMqrqqjRYG9/aVjgSqC/fejcYOAO
         5j8g==
X-Gm-Message-State: APjAAAWliuC8CVhqVbWCuiMnH0vV0dlr0G/tkKKRR/uvlbkFOZFmtIGq
	ktat/UgE9YCiMjF45BDfD3ok86brc1GDc0OTYFQfsimDLf8+HCvS0jTxIqAucGVbpoYuM+9n6sf
	NHOFRstxBv5a08mkXr6qv7ltR2gJtT2HL6oF+V6OJKgkpDBVjUhS5bNn/gdwXQouUog==
X-Received: by 2002:a62:5c01:: with SMTP id q1mr7172695pfb.53.1563905946244;
        Tue, 23 Jul 2019 11:19:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwojOuqwr6MRCFm3XHp2pGmsEnVNbQkiwFVKpqFokYqwWUl21yfITQ7OCggHp5y4IqQys/U
X-Received: by 2002:a62:5c01:: with SMTP id q1mr7172667pfb.53.1563905945620;
        Tue, 23 Jul 2019 11:19:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563905945; cv=none;
        d=google.com; s=arc-20160816;
        b=H34WHW9I9NzLUFl3jWtwP34VpHQEG4Q2+yiwdzE/OOwKOIVqfTm3fjVjcQpYBFfcR+
         aTQOF/RdSrMduyaebJNgFM4k+K2LecOtmtEz9aOZ7uZl/Q7f7yIP10+9psVxURxMF41Q
         2HQPETTAZNq0AwOWCTG8AEh+eBLuS8e7UWaODR/VX3KEeMoXiuNNRuz9W62DWAB82Mp2
         T33LX4KTna5h6kF84WNR94c14wKcHKIa67d8SmTLXHLOut8GukwdrxmApT40JElwk0LO
         XaTVpvr1FDp0ibMgfx7Bu1yTYk2BRnJ/z1F4fS+S1RszXmEKlU6y2ieoOr7RErQbKLXc
         U2Fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=Ijp19dCgszxKeKL+XBVnkeWJUgHPZc8389ax86PIYT8=;
        b=PwIGFL0xfnhyp/mEGwdk5ETfv3ndVtKfu0TUSXJ5tFOZvOj2GC7kYOZpLit30WIg/4
         FgmMozjJkRMqo6mTpk4+QNT869yWiSsLaZlmV59HTE6fH4v6exZtBBhfu5Rr5cWlvaoO
         MC3y/Y2B+2KwuBrcZAFqD4TrByAsb+mvgXlKyIUrLGMg3plqOvQ0A8HJVrObhqwMg24K
         dm8PH47pzpBH6uCd6vRLBvScdiLlQsOWKMQF42+MK27Z99fT3RlkAt4XzA852ylxPmkG
         yNSCQiwC9wnIyoezQsoPSaE3KUaafEfw596HSW8OdtyAm3yTSlLMvzLEOnWvXNW8hE7N
         7trQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=pAq+kDaH;
       spf=pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jlayton@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c11si13127281pjq.0.2019.07.23.11.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 11:19:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=pAq+kDaH;
       spf=pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jlayton@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 624C62084D;
	Tue, 23 Jul 2019 18:19:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563905945;
	bh=Awat9gsewjbgPYbV/sg1258A8MvYYSlvsfznyoqnKc8=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=pAq+kDaHErUf7z0A9YeuslsNjOOpqTeBmy2yWZ/WPZnlJXKuWhoBj4PA0sRvyshLP
	 rBChVn4/w7vvs9e33FUkKT96KV42rbexeF9eW4c084faYM+yuugLVh0sxDslZE8WMd
	 CiJwB7vdVBFo4aBCYavOSAWt1sD0ejfSPloUQMLU=
Message-ID: <d7cd46333eb1a29fb7e0e078dc4fef7646fe2a8c.camel@kernel.org>
Subject: Re: [PATCH] mm: check for sleepable context in kvfree
From: Jeff Layton <jlayton@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,  viro@zeniv.linux.org.uk,
 lhenriques@suse.com, cmaiolino@redhat.com, Christoph Hellwig <hch@lst.de>
Date: Tue, 23 Jul 2019 14:19:03 -0400
In-Reply-To: <20190723181124.GM363@bombadil.infradead.org>
References: <20190723131212.445-1-jlayton@kernel.org>
	 <3622a5fe9f13ddfd15b262dbeda700a26c395c2a.camel@kernel.org>
	 <20190723175543.GL363@bombadil.infradead.org>
	 <f43c131d9b635994aafed15cb72308b32d2eef67.camel@kernel.org>
	 <20190723181124.GM363@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.4 (3.32.4-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-07-23 at 11:11 -0700, Matthew Wilcox wrote:
> On Tue, Jul 23, 2019 at 02:05:11PM -0400, Jeff Layton wrote:
> > On Tue, 2019-07-23 at 10:55 -0700, Matthew Wilcox wrote:
> > > > HCH points out that xfs uses kvfree as a generic "free this no matter
> > > > what it is" sort of wrapper and expects the callers to work out whether
> > > > they might be freeing a vmalloc'ed address. If that sort of usage turns
> > > > out to be prevalent, then we may need another approach to clean this up.
> > > 
> > > I think it's a bit of a landmine, to be honest.  How about we have kvfree()
> > > call vfree_atomic() instead?
> > 
> > Not a bad idea, though it means more overhead for the vfree case.
> > 
> > Since we're spitballing here...could we have kvfree figure out whether
> > it's running in a context where it would need to queue it instead and
> > only do it in that case?
> > 
> > We currently have to figure that out for the might_sleep_if anyway. We
> > could just have it DTRT instead of printk'ing and dumping the stack in
> > that case.
> 
> I don't think we have a generic way to determine if we're currently
> holding a spinlock.  ie this can fail:
> 
> spin_lock(&my_lock);
> kvfree(p);
> spin_unlock(&my_lock);
> 
> If we're preemptible, we can check the preempt count, but !CONFIG_PREEMPT
> doesn't record the number of spinlocks currently taken.


Ahh right...that makes sense.

Al also suggested on IRC that we could add a kvfree_atomic if that were
useful. That might be good for new callers, but we'd probably need a
patch like this one to suss out which of the existing kvfree callers
would need to switch to using it.

I think you're quite right that this is a landmine. That said, this
seems like something we ought to try to clean up.
-- 
Jeff Layton <jlayton@kernel.org>

