Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88BE5C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:27:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A40220811
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:27:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="nj/UAzBo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A40220811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8979C6B0003; Tue, 23 Apr 2019 05:27:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 820636B0006; Tue, 23 Apr 2019 05:27:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C1BA6B0007; Tue, 23 Apr 2019 05:27:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4366B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 05:27:46 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id m128so14978456itm.6
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 02:27:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=f/iLXaVA4u+TazdBjYinG9bUUB+MWLz5zrXVIQCfKNM=;
        b=hnLuNfUKGPVnnHApEtVJiPYcLiPzl8tqpSe9Eic5EQm3JKZ93X50rZTLDra5DWzGjX
         bjKYJCWWF/Xx5XchTWEKD2/WtphWYhyR+my3mCYKaE20TPEGcjJXDKIPewqOevb64NH2
         6eVzaHe3JExZyTmMSOrvXuTLthSd/ZaKs+JYb+2WUtCpkhBnvPsJkzN3Vn+u4QkKbj1E
         bs70JXry/CtMrGRUmvEnbSQpXVenWWqJpYuQ8HKt3Q28A/QkzXzMUXS+078fZfRpTRTY
         QqBPD0VCnuQAYsL1TD7MMQwi/lIjqdGHIZ+813hzMzM6kp+lLzpTShvSaEL46jO5dSDI
         muKg==
X-Gm-Message-State: APjAAAUYoaFdsPhpfr7pjT5WvIlSECoaKyXBNXlP2YmeKY2jl3ft6y+4
	ZSqltAPbAO+f6teoN6rljvIIUNzeZsJ6U83MVSZTh1edb2YyoHEmWXNPT5SkZT8Yvc8WxJDlFpA
	W9rY7fTRQwJWNZhTiJ8nJUmgAZkkjHcJqiMwleJOKWuTYSqHPprTF+Ng/FWWnjzYqFg==
X-Received: by 2002:a24:57cf:: with SMTP id u198mr1388455ita.162.1556011665964;
        Tue, 23 Apr 2019 02:27:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyA1lFJN/94W5Zq2pvxLk8N6bs66JQIRz31gjr6fMvKlJGIxxicjTuM39kzjqyLG9l7NHVP
X-Received: by 2002:a24:57cf:: with SMTP id u198mr1388411ita.162.1556011664928;
        Tue, 23 Apr 2019 02:27:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556011664; cv=none;
        d=google.com; s=arc-20160816;
        b=teYNRi2BIkdXju/nm9k4+W4HMN4yPPlA0SB/SomjUHb4hsqMcD0/lLSda+4tZsnDcl
         cViAppv/trJUD53YUX0ukYrNyrG5XvvmjzDTyJuJGqP8t+dxa0v47MsJoBvX9L9W309q
         POyDPcv/Fr/jMTwrd2mceMxju+UudM/jxqsJkS7dgVVHFAdpr7KVh66NJeoEuLVErEb/
         7OcSaaCFfw13aDrpY3gwNlJ9KM6x+pEhG/Akm8fWAy/y9V+Qesm/24uGvQdQCw752XcH
         toAyNzpxb/JSdM7MCd9m5L10eUBxYYN+Mrj6UR24p16XDIHoTKpJgfiM+O67Xsttl1d7
         p5ZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=f/iLXaVA4u+TazdBjYinG9bUUB+MWLz5zrXVIQCfKNM=;
        b=gtf3cL2uuOSKWBuMy3wvnXpwICkb0bqC8jCwiJ2eVtsDwzU8d9Y0hZTj5DmLymtFIl
         Ki/9+C4r2P7T0AhyUM26Ct8fB3RFMo3bXCiTTqFyM2pentUQ9GZm83ydymGH6gOqgWSl
         R26KJsmEXmqujJCyYgIFS1b/Mb+7NTw2p+9UPHE048zfZJKCY3kp6XVBRNMRG1TuTlX9
         SPo+qwpPAou8MD2Za+giM5YnX7Ev+wtuiw+vA70Rqcwnr0QbEzoZZy6sx2p2/W0Y9KWZ
         wsclRK3bPcIbRk5JEimCPDntlsp4KofwP1emZuqAlXlcMymcs1OPV2mGEMa+wJuYHnTa
         OXwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b="nj/UAzBo";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id u10si9746398ita.57.2019.04.23.02.27.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 02:27:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b="nj/UAzBo";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=f/iLXaVA4u+TazdBjYinG9bUUB+MWLz5zrXVIQCfKNM=; b=nj/UAzBo31hclTqz5KOaLs3kN
	9+Wb0SdOYy0J9KD+QyJt7yQ9LGkIckSf3t6Viqscs1prUQ4Nt0h+LzExLOrhIw4owyz+uu7FAHuG3
	C71Ebgg/MAqlvq9jb6UjD/kM1r8gJIbubPgfyoRFrQF2yz+qPrZJsT/XWTY7IlvtHtNy8J3fwaByD
	EwipeXzyx6RcPe7VVCz2UCcTO/i/sdll1PXi3cBGsw3ByxE0j39YXUg26M35ZBMoWBEL2hNXhm/vB
	E+Vg6nFM30vsFHp2cPMVfjZedrFAK5S3nGHSEHY4WDip3zj+r68oY4/UkvjhHmLcExsJDw0t9dw27
	scs2myCjQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIrho-0001lo-VN; Tue, 23 Apr 2019 09:27:13 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id E48FE29B47DCE; Tue, 23 Apr 2019 11:27:10 +0200 (CEST)
Date: Tue, 23 Apr 2019 11:27:10 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, kirill@shutemov.name,
	ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz,
	Matthew Wilcox <willy@infradead.org>, aneesh.kumar@linux.ibm.com,
	benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, hpa@zytor.com,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Michel Lespinasse <walken@google.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
	paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 21/31] mm: Introduce find_vma_rcu()
Message-ID: <20190423092710.GI11158@hirez.programming.kicks-ass.net>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-22-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190416134522.17540-22-ldufour@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:45:12PM +0200, Laurent Dufour wrote:
> This allows to search for a VMA structure without holding the mmap_sem.
> 
> The search is repeated while the mm seqlock is changing and until we found
> a valid VMA.
> 
> While under the RCU protection, a reference is taken on the VMA, so the
> caller must call put_vma() once it not more need the VMA structure.
> 
> At the time a VMA is inserted in the MM RB tree, in vma_rb_insert(), a
> reference is taken to the VMA by calling get_vma().
> 
> When removing a VMA from the MM RB tree, the VMA is not release immediately
> but at the end of the RCU grace period through vm_rcu_put(). This ensures
> that the VMA remains allocated until the end the RCU grace period.
> 
> Since the vm_file pointer, if valid, is released in put_vma(), there is no
> guarantee that the file pointer will be valid on the returned VMA.

What I'm missing here, and in the previous patch introducing the
refcount (also see refcount_t), is _why_ we need the refcount thing at
all.

My original plan was to use SRCU, which at the time was not complete
enough so I abused/hacked preemptible RCU, but that is no longer the
case, SRCU has all the required bits and pieces.

Also; the initial motivation was prefaulting large VMAs and the
contention on mmap was killing things; but similarly, the contention on
the refcount (I did try that) killed things just the same.

So I'm really sad to see the refcount return; and without any apparent
justification.

