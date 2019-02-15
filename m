Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E017C10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:16:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38B372190C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:16:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MCF5Gbp2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38B372190C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD0438E0003; Fri, 15 Feb 2019 12:16:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5A728E0001; Fri, 15 Feb 2019 12:16:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 948C98E0003; Fri, 15 Feb 2019 12:16:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 51BA78E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:16:22 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id cg18so7326422plb.1
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:16:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ooGmETeAMfU5WngSU05Ee1Ynx92AHDeGIIebdL4CHw0=;
        b=WbgQ3yEeOb2bEo+8aM5nPBdSgvFBhbDw5kcGnUdsaupr8ZC+R/rUQ3XYIhx1Y2yLPI
         3MostISwEAz2GwVtJxFT44wE3Jy3n0ENKvmNP7J976Uzo4ztSMq6BAyGaSLnVteMMijA
         9/f/Pn1iT8DAqHtIdZkI6NaoSJkISx6qMyh4K3WNpj4SMTwTPYC0lpnCz50hWuhtF5Q/
         hVEr5Le3yU5aaaNrHPOY+I1MVHbARwXrEAnQO9Yu7dj3IOmAIGH+aQRY4jg9hJCNowDn
         o/G5kDje7zlU9N7rHWXfQpnj+UhpzaG4HOALHeBf8mCBTyS7qzAfgm9SLTupP1dI692t
         wz0w==
X-Gm-Message-State: AHQUAuZmw8c3Vb60kReaIANn/MMntSbRMH6B1mmHxE67pcyrMTa2ChgY
	ou4yT1cwMUVVwT3HvRMF0GKjIxnE1QE1+mSyZCK2u9Ug1SGEV6Puhuyk4jD88V3FXWE00ZU6/UX
	+wrAwIJoTqvZrYRqskeQw4D38v87BypxsAYSwsWDDhVz21IRC3Xy1SUl7uW5XPXB36g==
X-Received: by 2002:a63:2c7:: with SMTP id 190mr9655081pgc.367.1550250981947;
        Fri, 15 Feb 2019 09:16:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY4QT3pYZIaCPTqTuKPrfsx0hv/jiD+AZJyQ/wXt/j/c9UfSu6LMAy9q/sNoLBm1eguS225
X-Received: by 2002:a63:2c7:: with SMTP id 190mr9655037pgc.367.1550250981276;
        Fri, 15 Feb 2019 09:16:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550250981; cv=none;
        d=google.com; s=arc-20160816;
        b=kjsQ07L2MdDJiJPECc4kTzhLtj8iu1kZCGY72RTI55kIdmRJDB9gHqIFbyLtnBpthF
         tcj8NW2YG82TbV/1JCsYIIjtYA9ZCqqReMjqEG7k3pyT50V+sidYQXgrPnNft1sRBkoK
         6YwhWbEacbOK9AlMDAJhty6qixkDen3r8Pl10me856ERzVW3usiSt6iUYNKYiv2PYnff
         Jd8uizXU8/M4xDwIojrYQFY3ZVmFotd5jBD9er6hPqbg4zsHsweb6XmT2qZ2IEtgnb79
         4ywAY4iaLM0hWM5B9CosbomCiZf991/mryr8CQPZYdRdrAasU9kWNp3La4G2iK2ZsMye
         kISg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ooGmETeAMfU5WngSU05Ee1Ynx92AHDeGIIebdL4CHw0=;
        b=LzdjQzJjj6w2d7AEwFMVDYA+hJI1JeZ+muf4+AANUohFKZaMLZDJuJ/VmJKMQCCvQ3
         YyEwZ+/62WZCakl+JX2PlTwyscf/9bhTtz7OaMw1CAhH8hE3S3pPQ68dPaNT4S7sCeG+
         CXqydga84osOZK/1FI5KAT/DhrSD+25h6txFiV4lpMsxS7oZjPcfkY10k4bvv5Fc3aeS
         0A3kaCbrKOWSbkqCwVsB6hh9fVOBcEIx06RnhfvCkE8Q+7F1SmWbqqgdo58h4QPrTtZe
         auQFdHE6Ffnk8xzMsnpojBhOjtKE9KGWxHe3kvfa2AZk7FRLhUz+47+eJuQoswrwMHzY
         KSRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MCF5Gbp2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s66si6022964pgs.115.2019.02.15.09.16.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 09:16:21 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MCF5Gbp2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=ooGmETeAMfU5WngSU05Ee1Ynx92AHDeGIIebdL4CHw0=; b=MCF5Gbp2jwQST1+kskq7BCogZ
	yLJ04gp3VEiMQK5dNfjFJzV5Il16yADz8CfgwZlbi4tFduPzcyOpCByjun9FojEiNArJiTjErZdXQ
	gH5HF3YWG5E/2GT7PnyXmTjuLz26bF+GIOsZ9kv84p+RQsZSe4BW0o7YAcilSiMJGjjxIsQDge9cz
	fmd4rAxHh9FZFxzpB85JSvHZVbc0fQOutDIHDrbXHIV9Tq853kzjgrLNK6zQXOND1xAvTseyLAB7R
	XyZfjNEV3pCHZrncBG2pqy7TNEPcOuM5GBw2cmKlw/9x5DMSDM+OFMuhAKBeTez27HuK8p5g+iNuw
	+DZVLTgng==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1guh63-0004um-DE; Fri, 15 Feb 2019 17:16:19 +0000
Date: Fri, 15 Feb 2019 09:16:19 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Dave Watson <davejwatson@fb.com>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Maged Michael <magedmichael@fb.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [LSF/MM TOPIC] Improve performance of fget/fput
Message-ID: <20190215171619.GI12668@bombadil.infradead.org>
References: <20190215163852.6ls6bchssazma6bm@davejwatson-mba.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190215163852.6ls6bchssazma6bm@davejwatson-mba.local>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 04:38:05PM +0000, Dave Watson wrote:
> There might also be ways to rearrange the file* struct or fd table so
> that we're not taking so many cache misses for sockfd_lookup_light,
> since for sockets we don't use most of the file* struct at all.

I don't think there's too much opportunity to rearrange the fd table.
We go from task_struct->files_struct->fdtable->fd[i].  I have a plan
to use the Maple Tree data structure I'm currently working on to change
that to task_struct->files_struct->maple_node->fd[i], but it'll be
the same number of cache misses.

