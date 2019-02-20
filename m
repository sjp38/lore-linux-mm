Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10407C10F0B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 15:03:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A77AC21904
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 15:03:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qZiFOjmG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A77AC21904
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18E618E001F; Wed, 20 Feb 2019 10:03:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 117CF8E0002; Wed, 20 Feb 2019 10:03:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF8538E001F; Wed, 20 Feb 2019 10:03:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A1EA18E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 10:03:01 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id o67so445758pfa.20
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 07:03:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=oZBfBU4jWxNSshmOOtCHrGGSxVl/3qP/1xb30w4GIow=;
        b=diYWzh3bM/nXRoj3IWyEzwXWasbEYt1YFPBQW/mYxVbUkriiD52gxvvls+wQh179xc
         NIf5tJXUOPij125GnWYggDOKeKKAzWtGkv3a1myr6ZdI3hgqjWyVNzR44r/lL7mVWNt0
         /OeyxUz3MAVbePVVKlCoI1Qks6KQ+kXz12qFvvoVslpvZa3maGD7XeFtonJ3R2+CsWBI
         GLzzm8zSxjUcpawL/cHpke6pmocyCsskGqknCnUQoJY0asU3a/2Qacj6bR4R02ALJX8i
         NC27gLEbO7mHUGMjgqiZ4fzDTjjpIQHhg6V6WwCyLvUnWx3Xay+BWy3hN4wV1Oduhccr
         G7lg==
X-Gm-Message-State: AHQUAubK7dqXUeqDbrpxw7yi9ccgTqesB37ppeoXwRPxgEC0OAGnjvaW
	0d55M+8iJSqSvqILQbsZRUAb6A+YxW9NROZgm+MxPZ8o2YyyiPSHA9y5xtz2EWUmM2dVKKLGUFP
	4Gro3DThEZNlrqwA1c06tv5+Y1JY9RYQn/j4/XXxTHbWqqOzLfIPo1x+iqcyTry+QHw==
X-Received: by 2002:a63:4665:: with SMTP id v37mr30175593pgk.425.1550674981097;
        Wed, 20 Feb 2019 07:03:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYQbnT5VOMqsBWAwKIpynpqvnBciRhXUde4c67Ybk8H5J3Yc5OH4hoaw72ySt0F82Ork655
X-Received: by 2002:a63:4665:: with SMTP id v37mr30175506pgk.425.1550674980029;
        Wed, 20 Feb 2019 07:03:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550674980; cv=none;
        d=google.com; s=arc-20160816;
        b=PnffKQYxYz61N2vONJvoF4ruOfYPL3a7szgHCypwK05MU3Ml6cAoWWU8deaA1zphdN
         TrREq7H8BVvO2X+7ZeQkRVAQTWYMPPJVqzTkmxAvm3kuVGjlg5CZo9tOrLQvYsuxyyfg
         bpAReJAgRKzggg0oBL6agF0DySWroVvo6aDU1wzz583+RKu6fyRPmMD4XbqJpJ+P1YDX
         dyfwQoNnvhgumaiK0Ju6a7uJa3isKo+09CWe0YXHGOUrmNaSkuq389+Ded60h5pEtuXf
         nK0NfMd75pnzBLJgCKsAiVrw0kIWGSkXIUNiRP5sB8N1H5UT22qtpyfeTxu8HIPF12dM
         kwVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=oZBfBU4jWxNSshmOOtCHrGGSxVl/3qP/1xb30w4GIow=;
        b=Nl4Q893776+4fOeqipD9K+U+Kf3UQ4qL7clau+auYmhpfOCGG35zl0nkHKOMvrXRoU
         VKnkFqamnLaXIImtwHWwkPmLs/6IbGbdt7YNLIdQV9sIe9Bjx0TwuYS6LiNjBIFfxL0l
         aRUYeSJ6KgIlANFUdxqw7Bjxe3VdBRNcEVywDULQKH+SnnxaRtZG2m5GXQuCkdKbMWN+
         AEIicT7c9O7qPWNPDEZQpuAQcjX8bTZxOj/9OE/JvHx8I7bjE9KDdhEgoCxdwN6z2JYT
         MQSE4jDVmrxSTI110MlJuRrULYvlZU83AynOyC53IVPDcxzXnSBSF6VHdzvKyXwGG3rp
         +gyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qZiFOjmG;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k62si18623601pfc.208.2019.02.20.07.02.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Feb 2019 07:03:00 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qZiFOjmG;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=oZBfBU4jWxNSshmOOtCHrGGSxVl/3qP/1xb30w4GIow=; b=qZiFOjmGGXLVTNULdyIQOXN6j
	qkQrNwxu5hyCOtMVdQ3zUyEW8qoQaD05FL0B+v8rv8OS5B5Inv+lLU0GITzVKL3d8/w5GQxV2lrdL
	HIdeMo1PpxLAtqhg+CmHpPmiULTPbmeJXR0/ydG3/rxopoY7aA9SwOP4wElpS1FRulpa26wYdKbLs
	g2pTzTNz1zwloHDjfcWLkjauRC7zQlFHyVJjibJPIJaKzifpuy95SOmRHPXloeWUTZ1zlP9kOiC7Q
	hhFYP7riOX85dKjb75YnVopzw7RBdtOtIXyqTZ1k3lxOcOtKDVHXVw71d6Bwbg/vzC6ULoPGhsIBs
	RCeOIDBBQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gwTOf-0005pU-N1; Wed, 20 Feb 2019 15:02:53 +0000
Date: Wed, 20 Feb 2019 07:02:53 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, aneesh.kumar@linux.vnet.ibm.com,
	akpm@linux-foundation.org, npiggin@gmail.com,
	linux-arch@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux@armlinux.org.uk,
	heiko.carstens@de.ibm.com, riel@surriel.com, tony.luck@intel.com
Subject: Re: [PATCH v6 06/18] asm-generic/tlb: Conditionally provide
 tlb_migrate_finish()
Message-ID: <20190220150253.GH12668@bombadil.infradead.org>
References: <20190219103148.192029670@infradead.org>
 <20190219103233.207580251@infradead.org>
 <20190219124738.GD8501@fuggles.cambridge.arm.com>
 <20190219134147.GZ32494@hirez.programming.kicks-ass.net>
 <20190220144705.GH7523@fuggles.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190220144705.GH7523@fuggles.cambridge.arm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 02:47:05PM +0000, Will Deacon wrote:
> On Tue, Feb 19, 2019 at 02:41:47PM +0100, Peter Zijlstra wrote:
> > On Tue, Feb 19, 2019 at 12:47:38PM +0000, Will Deacon wrote:
> > > Fine for now, but I agree that we should drop the hook altogether. AFAICT,
> > > this only exists to help an ia64 optimisation which looks suspicious to
> > > me since it uses:
> > > 
> > >     mm == current->active_mm && atomic_read(&mm->mm_users) == 1
> > > 
> > > to identify a "single-threaded fork()" and therefore perform only local TLB
> > > invalidation. Even if this was the right thing to do, it's not clear to me
> > > that tlb_migrate_finish() is called on the right CPU anyway.
> > > 
> > > So I'd be keen to remove this hook before it spreads, but in the meantime:
> > 
> > Agreed :-)
> > 
> > The obvious slash and kill patch ... untested
> 
> I'm also unable to test this, unfortunately. Can we get it into next after
> the merge window and see if anybody reports issues?

While I do have a pair of Itanium systems in my basement, neither are
sn2 machines, which was the only sub-architecture that implemented
tlb_migrate_finish().  I see NASA decomissioned Columbia in 2013, and
I imagine most sn2 machines have been similarly scrapped.

