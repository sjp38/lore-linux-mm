Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36778C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 17:02:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D54A0206DD
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 17:02:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="vRjZAYQr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D54A0206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 776846B0010; Thu,  4 Apr 2019 13:02:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 726C86B0266; Thu,  4 Apr 2019 13:02:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EFC16B026B; Thu,  4 Apr 2019 13:02:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1624E6B0010
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 13:02:46 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id y7so2349234wrq.4
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 10:02:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=DuOGTJZ7sMG2u+bQoSBicKt7dBisbjP7T/Kfoz9vRWs=;
        b=rWwm/LkcEf4DWaEKLswSrRsuICCJ+asjtefeD3JtKqmO3ZQAToIUb69ty2rnuCaqMe
         Kcvn1rHNsi4TPPzCCAY1dCy/al7790yP1PPcMPUnf32RiXU+UfCs5V7qiE5ZkM7878KF
         Si//avMZBoK0mUQpzOxXXAQmZcR+vNKU3Z+yvzBTX7rUNcE6Ziox+NfHfaAzjBu33fPF
         AvtTyY4Su4nlFclCNNDoQ1t5tn6OYWLT+a9jTJ/fm83YUkFuRqWcBzPVkLp+Zlo5CJ85
         ViRAiu6bIKOIdlFgNlyq2U1JYEcj37O26DLAFgTSDnKz6pTqOk0uNLJmVr0dw4l3Pztt
         KKhg==
X-Gm-Message-State: APjAAAUmEV0Hn7GTO5dgZE3kAt1/JFtd2AOfe+z3xpWZ8f+o3JkO2rXe
	YgCoeFKyFN47eY/6dQI1ak7HaZbv+96/B98MLuJCeZuMruEiAsssTIHlsfLbhBs9xGSDMwuBgIe
	oTRw5QMvzgRGHK3fYdxL7P7yT9YvqqtWlsqg4AkZhV0Pd7Wc1VfimQKTEKZLECu8XOQ==
X-Received: by 2002:adf:fec3:: with SMTP id q3mr4997084wrs.173.1554397365564;
        Thu, 04 Apr 2019 10:02:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjPsnt+1Y2HVEX5plXjs6DOc9RfeqDiDQxB5J7K/8YAFrc3bDgSXajmePgE38WcSe9Y91l
X-Received: by 2002:adf:fec3:: with SMTP id q3mr4997013wrs.173.1554397364461;
        Thu, 04 Apr 2019 10:02:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554397364; cv=none;
        d=google.com; s=arc-20160816;
        b=UOiDgkz9bK7be4CEuB6SEcDJRNowj7pDyujhA+wXAn3BQbMgt0UyWE4sogJV1Sqe3k
         Wzo0YuLGCajGMsn9fpSVzNHcZSZO2dZpaWH2RBLPqTZTt3fnRx/x5f0hKjSrOUTFssgp
         7F+JGk8AJEyuVTmHorOJzPRhodIhR8W1jDxQvm1ow6rppuhzURW1txeSBj0lPPrGRRwz
         pyxPmlfsuzVq0p1ShVNRJXvbr53a3ipyOmW9aDU14FnhIt+w1OPAfZvQ5EckMbNgZNeT
         fResJ18pdECSXWtvoIlG6qVPen3CRyW71HNlr+SS70ldMIE5DrxRRN7hjYbKz/VSL/lR
         uQIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=DuOGTJZ7sMG2u+bQoSBicKt7dBisbjP7T/Kfoz9vRWs=;
        b=sm2ANqwzrfR6LUyBmEUBEUYe/E0QEPhi4A5ZFGsEw2sfR6xrS2hFFuekvV0L2WBrRn
         fe+pJhB3FICB1582h853r/+XuNQNWoQgQGRnaAeEneSirCMpjxD0e9Mo65W7yH5RG7s9
         6U5WWX3PVdKLOs/6/lBaP35Cskg+t1TikRT5HmjqUqAI2RQYa8vvAbo9gUBJl97d4lbS
         Sa5IoQ4lgyRkGyhCnmfxR0MGJTZJ9peFkfItANqf5b18tehtRlIApm54gwoQrl4zE5D/
         8KcsFuYSlenoaXrUb9lS8k33ck1VccEPIE8ZCtfHZiihGnafkZ+mhhp7ZyzCyhWsXEru
         SyxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=vRjZAYQr;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id s13si12998964wri.136.2019.04.04.10.02.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Apr 2019 10:02:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=vRjZAYQr;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=DuOGTJZ7sMG2u+bQoSBicKt7dBisbjP7T/Kfoz9vRWs=; b=vRjZAYQrTXWQj9Gw7oaVfV3o5
	m62U3bP3A8Ix76w10FOjTdTA9Hjz+DjEiA/6j1Q+0i79WdBTuGWJSWVvTZfy7egwrXoRmgkNiFARz
	UIHWXjpMaausOaNPwzR+EPjRGwR6jC4ApaYanMEl4aBW3HM/p1tvuoBdCx2dHmFbgSEsj8k4ALZVU
	HIX6RehcX1LUGtM1gHenrp9sERqiKs7v7eOiF92sb44r0OllXf6XvBSnLn1wMen+iFT0l9RrChfQQ
	aroUm8LQ8A2o0F2SEsdFT5esiQnGswOoDDXIDYKu3dgDIjiPqizlYn7K5JrtiOmHTSnc7dmL9aNt4
	J/5nZmFLg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hC5kD-0004sc-LX; Thu, 04 Apr 2019 17:01:41 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id D2AE92038C245; Thu,  4 Apr 2019 19:01:39 +0200 (CEST)
Date: Thu, 4 Apr 2019 19:01:39 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de,
	ak@linux.intel.com, liran.alon@oracle.com, keescook@google.com,
	konrad.wilk@oracle.com,
	Juerg Haefliger <juerg.haefliger@canonical.com>,
	deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
	tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
	jcm@redhat.com, boris.ostrovsky@oracle.com,
	kanth.ghatraju@oracle.com, joao.m.martins@oracle.com,
	jmattson@google.com, pradeep.vincent@oracle.com,
	john.haxby@oracle.com, tglx@linutronix.de,
	kirill.shutemov@linux.intel.com, hch@lst.de,
	steven.sistare@oracle.com, labbott@redhat.com, luto@kernel.org,
	dave.hansen@intel.com, aaron.lu@intel.com,
	akpm@linux-foundation.org, alexander.h.duyck@linux.intel.com,
	amir73il@gmail.com, andreyknvl@google.com,
	aneesh.kumar@linux.ibm.com, anthony.yznaga@oracle.com,
	ard.biesheuvel@linaro.org, arnd@arndb.de, arunks@codeaurora.org,
	ben@decadent.org.uk, bigeasy@linutronix.de, bp@alien8.de,
	brgl@bgdev.pl, catalin.marinas@arm.com, corbet@lwn.net,
	cpandya@codeaurora.org, daniel.vetter@ffwll.ch,
	dan.j.williams@intel.com, gregkh@linuxfoundation.org, guro@fb.com,
	hannes@cmpxchg.org, hpa@zytor.com, iamjoonsoo.kim@lge.com,
	james.morse@arm.com, jannh@google.com, jgross@suse.com,
	jkosina@suse.cz, jmorris@namei.org, joe@perches.com,
	jrdr.linux@gmail.com, jroedel@suse.de, keith.busch@intel.com,
	khlebnikov@yandex-team.ru, logang@deltatee.com,
	marco.antonio.780@gmail.com, mark.rutland@arm.com,
	mgorman@techsingularity.net, mhocko@suse.com, mhocko@suse.cz,
	mike.kravetz@oracle.com, mingo@redhat.com, mst@redhat.com,
	m.szyprowski@samsung.com, npiggin@gmail.com, osalvador@suse.de,
	paulmck@linux.vnet.ibm.com, pavel.tatashin@microsoft.com,
	rdunlap@infradead.org, richard.weiyang@gmail.com, riel@surriel.com,
	rientjes@google.com, robin.murphy@arm.com, rostedt@goodmis.org,
	rppt@linux.vnet.ibm.com, sai.praneeth.prakhya@intel.com,
	serge@hallyn.com, steve.capper@arm.com, thymovanbeers@gmail.com,
	vbabka@suse.cz, will.deacon@arm.com, willy@infradead.org,
	yang.shi@linux.alibaba.com, yaojun8558363@gmail.com,
	ying.huang@intel.com, zhangshaokun@hisilicon.com,
	iommu@lists.linux-foundation.org, x86@kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org,
	Khalid Aziz <khalid@gonehiking.org>
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20190404170139.GA4038@hirez.programming.kicks-ass.net>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190404074323.GO4038@hirez.programming.kicks-ass.net>
 <b414bacc-2883-1914-38ec-3d8f4a032e10@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b414bacc-2883-1914-38ec-3d8f4a032e10@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 09:15:46AM -0600, Khalid Aziz wrote:
> Thanks Peter. I really appreciate your review. Your feedback helps make
> this code better and closer to where I can feel comfortable not calling
> it RFC any more.
> 
> The more I look at xpfo_kmap()/xpfo_kunmap() code, the more I get
> uncomfortable with it. As you pointed out about calling kmap_atomic from
> NMI context, that just makes the kmap_atomic code look even worse. I
> pointed out one problem with this code in cover letter and suggested a
> rewrite. I see these problems with this code:

Well, I no longer use it from NMI context, but I did do that for a
while. We now have a giant heap of magic in the NMI path that allows us
to take faults from NMI context (please don't ask), this means we can
mostly do copy_from_user_inatomic() now.

> 1. When xpfo_kmap maps a page back in physmap, it opens up the ret2dir
> attack security hole again even if just for the duration of kmap. A kmap
> can stay around for some time if the page is being used for I/O.

Correct.

> 2. This code uses spinlock which leads to problems. If it does not
> disable IRQ, it is exposed to deadlock around xpfo_lock. If it disables
> IRQ, I think it can still deadlock around pgd_lock.

I've not spotted that inversion yet, but then I didn't look at the lock
usage outside of k{,un}map_xpfo().

> I think a better implementation of xpfo_kmap()/xpfo_kunmap() would map
> the page at a new virtual address similar to what kmap_high for i386
> does. This avoids re-opening the ret2dir security hole. We can also
> possibly do away with xpfo_lock saving bytes in page-frame and the not
> so sane code sequence can go away.

Right, the TLB invalidation issues are still tricky, even there :/

