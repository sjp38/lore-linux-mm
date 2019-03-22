Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9ED07C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 20:00:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DA5521874
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 20:00:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="C8EnG3Nn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DA5521874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED0AB6B0005; Fri, 22 Mar 2019 16:00:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E80626B0006; Fri, 22 Mar 2019 16:00:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D98FB6B0007; Fri, 22 Mar 2019 16:00:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8CB6B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 16:00:06 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h15so3065760pgi.19
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 13:00:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=g9JaNDMvFMAM62vwNPQ5/TuvcMvCk3Ftabzyp8bNxns=;
        b=CWXlL/CxlEM+q3/XJcB49nE1wJLSMXAj1KFPPPkLMGfTIM2AW0iNvYBng08fLKkXbO
         YSSp2IZXazlsghdLn7uTgZ/2iN7AOn8vmDk5Az5fig+MwK+dfd+NEcI8UYe/Gt2cuwlL
         CvxrVPunLbRxpltuEOK0NbR9V2mY3L1mldJnNkSEqdqXSYJtsNxPdy6OxSvDxmUq0oeJ
         y/6gHTCE1gSY1NLO70+WJwTAb4Nmgr2nB/HVTjcr8I9iM9ogAp82wkpHOvt+ulEeOgzZ
         bI8cCABOicE7/vfp2IuBInx8beXrVXM5aoOD5dts1x6S8eTqjDIEXmi0IJdoUN/WPQdW
         IaEw==
X-Gm-Message-State: APjAAAUuDzhe+6MEbmFjT3dlyb9C1IGWYCCJUNBDSnPll24Dnl/V7iod
	TwUGpQ2LjRkwhxdRgCFIHKk3OniXrIPLpQsx73gsA3qR/yYhZ4ic3ao8v5X3JEdBuXI6RWbua7E
	B9VSLKSB7IXR1AjdiT8lt5ZTYs5n0icyK6/gyKHez7LQn/n+Alva4ZTzOGsTsS6dkdA==
X-Received: by 2002:a62:b508:: with SMTP id y8mr11127149pfe.140.1553284806204;
        Fri, 22 Mar 2019 13:00:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1m8XGGTugMMZymcZo7Fub6lZK7c3D4BSWOe9hBa/iPfTV4VCsBGzK3HtqztJsIvqPGwGF
X-Received: by 2002:a62:b508:: with SMTP id y8mr11127070pfe.140.1553284805379;
        Fri, 22 Mar 2019 13:00:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553284805; cv=none;
        d=google.com; s=arc-20160816;
        b=aKNVkWsa9PaJPC1TKaTrqrpQymbKcskcu/0ULBIn7/zMYEPmP/+2g05VF+xUOsVqF5
         jWZWEDhPVVNitYRjkDA+NsFpMAFAISffqjXLJ1ycS2yC0DliGGvYqVpJlNxRc2GN0JIQ
         dskeKYSPmRt1PraJWHRzZRR6TMsQEmn0CvaX9MoRPikzg1ZJPpydksvutpdz9kxVkbME
         /7tQrFq84KNiUeVGCapVHWztwyN6VUHdziWKXTAKmRaQ88ADDTxyotZ8GpkGWJxcZ4kA
         E0N/laocXxCbgUqUNwUV3hkracieQW+Pvz/Nyzc58e9f17cc+W5NEAt7dArpbFhjIe8k
         yGIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=g9JaNDMvFMAM62vwNPQ5/TuvcMvCk3Ftabzyp8bNxns=;
        b=n0TxfuPtyaNTB6ECCd5SLlYStnZEngKQte/k+WXERbdICtB0ZjX2ZFnghYwt5mYFcb
         pwStG0TSdsP7DuMrSuY+BHjM69XJDU2VhwdrFqaTYdpMll+H3Q8NjOTdf/dIBcQbs/4d
         S7zGq+LncDkP2FrVyII/cL1v90NHno6CtrN1dxOUs0qFb36d/9RKqf+qbKFsGm13Nm2t
         DEE4objpMSDrZKiwvENuU1v1zCwVRH7jcBe/G3NP/YOzbFpn6h/kj8/H4rwRhI3LU8pf
         25ip3BhbxiXhP3zN9fF3X2Q1t1k9nWINyM5gqWZgYN6nvp6YbRyFQhGxiPIjFfkmLBDr
         dZRw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=C8EnG3Nn;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p2si7355592pfi.103.2019.03.22.13.00.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Mar 2019 13:00:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=C8EnG3Nn;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=g9JaNDMvFMAM62vwNPQ5/TuvcMvCk3Ftabzyp8bNxns=; b=C8EnG3NnF9HDBrR9KjLd3Cgs3
	qelf1PoSRZODZcqvXFU818UL1qu/MYwjZRO2SG4YJpU4Lt3au0J6lIFX7Vhnumuf7tjgGwc+2uPmj
	5USHOk+FWSovAuXjVECU1KCiieD4ku3KdPJDWUrOYoKg+3qxyTgopM0zVfhHCG2lQ7jyOiutHW37+
	39n82yFF7h6rwyL+wVlFuxdoCZaP3gyMWSE3iCAhgFgnQ49l3yBEQTh3ph2lpPlQq16tMd6CCLAt7
	63lQ+jeXbpsQJUtXJkfoNGmIAHWd9FfkWNWR35DARY48p9lrbjyD8zjCRJV1c9t0LTa+QEjZYUr+3
	Kik8ykoSQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h7QK6-0003HC-Uc; Fri, 22 Mar 2019 19:59:26 +0000
Date: Fri, 22 Mar 2019 12:59:26 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Christopher Lameter <cl@linux.com>
Cc: Waiman Long <longman@redhat.com>, Oleg Nesterov <oleg@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, selinux@vger.kernel.org,
	Paul Moore <paul@paul-moore.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>
Subject: Re: [PATCH 2/4] signal: Make flush_sigqueue() use free_q to release
 memory
Message-ID: <20190322195926.GB10344@bombadil.infradead.org>
References: <20190321214512.11524-1-longman@redhat.com>
 <20190321214512.11524-3-longman@redhat.com>
 <20190322015208.GD19508@bombadil.infradead.org>
 <20190322111642.GA28876@redhat.com>
 <d9e02cc4-3162-57b0-7924-9642aecb8f49@redhat.com>
 <01000169a686689d-bc18fecd-95e1-4b3e-8cd5-dad1b1c570cc-000000@email.amazonses.com>
 <93523469-48b0-07c8-54fd-300678af3163@redhat.com>
 <01000169a6ea5e46-f845b8db-730b-436e-980c-3e4273ad2e34-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000169a6ea5e46-f845b8db-730b-436e-980c-3e4273ad2e34-000000@email.amazonses.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 07:39:31PM +0000, Christopher Lameter wrote:
> On Fri, 22 Mar 2019, Waiman Long wrote:
> 
> > >
> > >> I am looking forward to it.
> > > There is also alrady rcu being used in these paths. kfree_rcu() would not
> > > be enough? It is an estalished mechanism that is mature and well
> > > understood.
> > >
> > In this case, the memory objects are from kmem caches, so they can't
> > freed using kfree_rcu().
> 
> Oh they can. kfree() can free memory from any slab cache.

Only for SLAB and SLUB.  SLOB requires that you pass a pointer to the
slab cache; it has no way to look up the slab cache from the object.

