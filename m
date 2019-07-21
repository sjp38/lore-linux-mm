Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDC4BC76196
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 21:09:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CFCA2085A
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 21:09:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hOxpb6w1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CFCA2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D71A26B0005; Sun, 21 Jul 2019 17:09:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D23776B0006; Sun, 21 Jul 2019 17:09:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BED678E0001; Sun, 21 Jul 2019 17:09:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 87BF16B0005
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 17:09:07 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y22so18597902plr.20
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 14:09:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=m+ymzWwJthSyMsIrAZa5UVM+lb+OeBZIRhgzMglbtss=;
        b=nlea2XOlZxL61HOZi/HOAlli5HfwqPY2tC94Vnynwr/vxO0j1bbduJuqqcrXkj3i2/
         7z5bQVNXQNvVyEm89lcjvKsj4cG68YdaKPb1w8BggFtz4jx7f7wP99y8E6gGSkIE0Ad1
         DAHPSOO4X2umn8nPbXfXJWscLqnxRBBGeyk/EyJyoQQJX30HpirqSvoOLxuvaSGK688U
         wUrslXsUJwXuOrKmjtU0iALNeN8V8uqpq4TWv4FGwoBZCI54gfXjmS2bZtMhAyatsY0M
         XrjMr5/33rBxZ3ZisT7zlUFpoWTZxhYuuFZ2zWAGcUgL91Lwun1Nm8Y97xWx7FUqcqKt
         pTeA==
X-Gm-Message-State: APjAAAWZAXhxAFUJqzPlc62xjliHxR6ABA2Yb35/+4oKJBVAj8PngUIU
	lhfk760yrJHXi/4KkRIPY6zVD9eyufp3c65a3hsOO/cX751d2doOrIxyL1173pqGNeR+bEMsX7g
	723rZbgxatrvhuI4pvwkYCM9IL5EFB8f0AD3H14WSt6Dvq7rl2IuqDhnNi4+E6+tCnw==
X-Received: by 2002:a65:6495:: with SMTP id e21mr68928806pgv.359.1563743347171;
        Sun, 21 Jul 2019 14:09:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcYNkW8LwgKZOKEnDCu/AyhF0bsgMgYkMsRzqKJ+2GMdayerkJmZs5a8d6KUUWxQ77Oe49
X-Received: by 2002:a65:6495:: with SMTP id e21mr68928758pgv.359.1563743346370;
        Sun, 21 Jul 2019 14:09:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563743346; cv=none;
        d=google.com; s=arc-20160816;
        b=a91cYy+KwD6IvO7Pi7TZqJF8ouapj4kFC3fZrWKosLBEdCc73SJSIr2k4Kqw2qTZ+j
         biOJUBBSchuXjfiohlojAhzf3sIthZfuk2Gtj/uOxKQO70tbP2Hg3xQtDtIJbt+aSD4n
         2UoCr6jSipwH1ymyVj8YRXdc5bSVmIKuX5s8ksncnjKaNz7Iw8wlCeInZTefn5hKBc74
         qIvO02oc3X54CoDI8KxPke2R98KFv5NNUS4ix1JI9RGiIzblSm1AK7ESVP0fxvO4mNfy
         S5vA/xgcFSe4uKigWQomaAIFoBLUS/SfhOGDCnqcg66exjGqL0nyjG2PnKxCV0yhWp9V
         dK+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=m+ymzWwJthSyMsIrAZa5UVM+lb+OeBZIRhgzMglbtss=;
        b=pzrxCoFHe16DJzfJhHrUKWdrD+cv0YPRATYhkvYuj0kMYdj6L1Ax29OLMZMW74ax8F
         uJo0uYnp2NWAq+BUHu74GdF1P1X/k9915rKBN0kQFQhvna3gUIsbgEmUqDDsYKAKhgsP
         9lpAkR/STg1ZWKXJ9BvNN2Par/+nfv5ALeu/pTfMVN/VNtd/61X3cPTTy+mrcU02KjMk
         Ap3mkPPoegO/ZTy3ace86kiY+ayY63bJFt5ph+mqGIzADZWweOj6jsi1256MKY0/3Scl
         6N9xdLrnn4ew6+A9ApkejXbynivPWTu/ZVHsNQKa4W2mZq8mKAqpxNVXhN1jRYvngt3J
         Lapw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hOxpb6w1;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t5si6110323plr.124.2019.07.21.14.09.06
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 21 Jul 2019 14:09:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hOxpb6w1;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=m+ymzWwJthSyMsIrAZa5UVM+lb+OeBZIRhgzMglbtss=; b=hOxpb6w1+7znVOU/LYcc4TCsi
	AU34x9DctQ72CdFA2SbXaxcS1FbGoIVqML8MnXJToxuML6SZi8848XN5DS9AVL0Z9wQgsUK2KRVeI
	Wz7K+4anU/cZMplgZTFu8tTBeFDdLQlK+4EzYTlmpy18b/zeZMWzGbE65oBnEfAvV8IKyijqNY5Kz
	B1UEaYbbU2KZci/M3mW5svS0g1vE2DZjApbLyiTi9LrqIkXtIvvBRXC3Hu/WKpOP6J4pBN/jLFKkT
	nwP8xiN5kn2rcd2USEhk/o97boU6FKRBx8S2WJNurFZKhP65CJgPUJfkVoDYo/kddkcDF3S5fnxNx
	q3ODFsGGQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hpJ4P-00031q-HE; Sun, 21 Jul 2019 21:08:37 +0000
Date: Sun, 21 Jul 2019 14:08:37 -0700
From: Matthew Wilcox <willy@infradead.org>
To: "Paul E. McKenney" <paulmck@linux.ibm.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, aarcange@redhat.com,
	akpm@linux-foundation.org, christian@brauner.io,
	davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jasowang@redhat.com,
	jglisse@redhat.com, keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: Re: RFC: call_rcu_outstanding (was Re: WARNING in __mmdrop)
Message-ID: <20190721210837.GC363@bombadil.infradead.org>
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <20190721081933-mutt-send-email-mst@kernel.org>
 <20190721131725.GR14271@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190721131725.GR14271@linux.ibm.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2019 at 06:17:25AM -0700, Paul E. McKenney wrote:
> Also, the overhead is important.  For example, as far as I know,
> current RCU gracefully handles close(open(...)) in a tight userspace
> loop.  But there might be trouble due to tight userspace loops around
> lighter-weight operations.

I thought you believed that RCU was antifragile, in that it would scale
better as it was used more heavily?

Would it make sense to have call_rcu() check to see if there are many
outstanding requests on this CPU and if so process them before returning?
That would ensure that frequent callers usually ended up doing their
own processing.

