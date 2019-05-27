Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBD78C04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 14:02:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A110C205ED
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 14:02:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CJ2irMJK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A110C205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 381C16B027D; Mon, 27 May 2019 10:02:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30B456B027E; Mon, 27 May 2019 10:02:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D3886B027F; Mon, 27 May 2019 10:02:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id AF7056B027D
	for <linux-mm@kvack.org>; Mon, 27 May 2019 10:02:50 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id d11so3191266lji.21
        for <linux-mm@kvack.org>; Mon, 27 May 2019 07:02:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=nCMqcLWyCA+4Q/MEIIgUaDC50B6QNtxtBMlc97ZOozY=;
        b=AXM8BVLQkqAQM4fuaI02Q1Q8kYC8+ZyO8Dx17BnCOudwlxRCw9N2eKcUMcolunYjhp
         1ISlGf96YWLucZu4yb2OoKcdB8JyEhBczDZCXVrDupj1hI2CwvrAbt+3Odb4/LjAaPhF
         JHL3YhiwMV6SkMDHDnWMZiiwBb2ElrFh2/IjOsPI8WQ+l5bsvxLRCSCX1KupfIwFOihe
         ksYLV2oIPVI9zZknD8eKdZMm/nawAnRyipDx3Ze0yrEwo60aypIHiByQs0KNcCgckDxQ
         ONTL0auI9iEKgZg/4J0wl9QvUgHhU9mVz421Uo8Om+0e8Btdk44o8qlIzlnqxCkqK6nt
         cicw==
X-Gm-Message-State: APjAAAUz58xvjWx2EqsiAxF0JlZGPePY9cPDc1e05eCz1UrHHVgOUG5E
	5fJBDQqOnRe8vm1zuw/QrXuZOPje7tGe+MimDajATC63fBp7H71VIY4NLHfFkdDZnN3QD2alxKs
	vBQSZg+R15eVn6lSyXrtfJlkrhyBVl2sMZxMV7Qc0XHUSY/WX1hIQp52k+zKktqRRAg==
X-Received: by 2002:a2e:9f41:: with SMTP id v1mr23591141ljk.66.1558965769910;
        Mon, 27 May 2019 07:02:49 -0700 (PDT)
X-Received: by 2002:a2e:9f41:: with SMTP id v1mr23591100ljk.66.1558965769171;
        Mon, 27 May 2019 07:02:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558965769; cv=none;
        d=google.com; s=arc-20160816;
        b=s2TSqWlp+wEeQgllmL+jYXZJq0hAJRWiTbYj2kq78XO6MVJkAz8BJB0Bq6AtLRE0bw
         s+7CiI9KkmVe5HDRozTrRlt3cSw9GoXKDS3gyE7pyOdQRwHHYENXjs1P1oo2uD3dS32Y
         DZDJyktMe+vzLSX4pAcxWnfzzl3jK412aM3HZfDoJcJG0u7nLk/W2FVidIqiEOIYcI5Z
         vVRObjzeR0wZu2cFzZ138Fg0EZ2oI7d6snTs3gds9ZG+xcppyaYAt/IqtdXxIscMnlYt
         YZlEwVCOcDCn1tBEmGjnWnveBKpbdIfbVJSiML8iiXtZ1BRwKrDV+f1n6lQ2OoCvZLXG
         GgRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=nCMqcLWyCA+4Q/MEIIgUaDC50B6QNtxtBMlc97ZOozY=;
        b=UlyI9luJ+K9h9ndUGvIvA8wUo0LU0qWaIbftyxgqi/xH03AHWIJZe9zQl8REmtXfuy
         PzWYf5S+OGLT4Cr9zfFwH02eNmWJKjklL0nqRmGMAkuUkjVKE3oVviw5l8s9u5CdJB3m
         uvBu3cX3zglVxBvLtAhOrp/jE+KvSigx7gQ6nlWy9QQ9Auz3ClxtCnUFWj6jwFiCSyQO
         Y89QssAUFJH5YBwtCle1wYrD+jZ0PEaZOs6lO5S0KHy9X+9RWTkY+PzNj9/5KfzWwZRs
         4QaMm9Q4J7f2TkU0akpzoMy2hNnMgZa5+RjqTVaNQ3aR9a7CZCn3/c7nXP+EWvxiYhkL
         mMmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CJ2irMJK;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l22sor5407981ljg.23.2019.05.27.07.02.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 07:02:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CJ2irMJK;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=nCMqcLWyCA+4Q/MEIIgUaDC50B6QNtxtBMlc97ZOozY=;
        b=CJ2irMJKh684KUcwCc9e3mRWyJ3si0NiJuPS8075E4MvXvGMVcYFMOXShhgQ6jQ65m
         5ZT8nQuRaOztT3vV1jR1mOBIKUw3uFP111pf95gc1AWajJpwzTjYYE3a8pNrNFx8YM3G
         qF+VgZDKakhfXS6vsoAA15xxhlI70teCFJXoQOhdt+aB+nwDh+M1AUnaMOaH2u4iowZF
         M9RDJ51+OJf4FjpByIo02Fg5yIq6EfeQVZk5SdkqFnA4eQFbHfJ3XquqOWlYbMC024Gc
         vgdX3QYfA4UtbUxk8wiLe15FW8s3SdFjoTNbTQfmI/ASsEOrqluE4QTc3bmQiVdMTCm3
         diYQ==
X-Google-Smtp-Source: APXvYqzXY+tlQxq7QCiBnJ+JYYpe6XAxMrsHVoWpLgb9r76XvPQ1r14R5z8LOJLwEgnfZ3qF0GJRWg==
X-Received: by 2002:a2e:81d9:: with SMTP id s25mr21926270ljg.139.1558965768729;
        Mon, 27 May 2019 07:02:48 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id r62sm2335963lja.48.2019.05.27.07.02.47
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 27 May 2019 07:02:47 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Mon, 27 May 2019 16:02:40 +0200
To: Steven Rostedt <rostedt@goodmis.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Roman Gushchin <guro@fb.com>, Hillf Danton <hdanton@sina.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 4/4] mm/vmap: move BUG_ON() check to the unlink_va()
Message-ID: <20190527140240.6lzhunbc4py573yl@pc636>
References: <20190527093842.10701-1-urezki@gmail.com>
 <20190527093842.10701-5-urezki@gmail.com>
 <20190527085927.19152502@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527085927.19152502@gandalf.local.home>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > Move the BUG_ON()/RB_EMPTY_NODE() check under unlink_va()
> > function, it means if an empty node gets freed it is a BUG
> > thus is considered as faulty behaviour.
> 
> Can we switch it to a WARN_ON(). We are trying to remove all BUG_ON()s.
> If a user wants to crash on warning, there's a sysctl for that. But
> crashing the system can make it hard to debug. Especially if it is hit
> by someone without a serial console, and the machine just hangs in X.
> That is very annoying.
> 
> With a WARN_ON, you at least get a chance to see the crash dump.
Yes we can. Even though it is considered as faulty behavior it is not
a good reason to trigger a BUG. I will fix that.

Thank you!

--
Vlad Rezki 

