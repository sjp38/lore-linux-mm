Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 249FAC7618F
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 20:28:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB0F820659
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 20:28:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="qlBsdqb1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB0F820659
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 472CB6B0005; Tue, 16 Jul 2019 16:28:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 423856B0006; Tue, 16 Jul 2019 16:28:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 312488E0001; Tue, 16 Jul 2019 16:28:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0F89A6B0005
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 16:28:27 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id p62so4807419vsd.6
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 13:28:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=UjTFcdnVd7s1YEwLwLvsfGG9sPlxZRXqbP8Kb8AL9ZQ=;
        b=rybAcy90rJTixG7FhOD+j9HNnPy5x4HUK4aN47rvZWw76zpXNmu+h51cr1/HAygZnb
         Ws4mcCFpMArFmEMUFkzLlzUumNO8bi2imI/aBTzDcnSpSJQOVqHkgIMjeDPc4YddnOvY
         +XqqX87FgLHqF/nErDxeIz9pnjQzgcBklCmyFKeOhWsz8pB+7Q/Ceqm+VDRsokw8nbgS
         pKklKuRPo8V+jo2O8AIvxvW4ErPA4zF2yFicYNx87cXdvRcl+1GGvBtFGMxxl9NuM16O
         KFaHqK3OQ1cjvxp5Ag2vR+QfI36bYzyLl58AMksgvzDwSQD300o4t0q6ZfmNlR2TyYlV
         i41g==
X-Gm-Message-State: APjAAAXL+xnUbspe+H6I0LWKXhICSJAP12aMm7PCcGSmKzEAHyVhkAwh
	RmJHrbF2i8KZU7zl4cax7XV4DcT3olUsSTITirtc3AIUwGytJi5/7s4PQRTY0LacruGPCFBywm7
	uLmHH3QLsBxpeP9jBA2Y+bOLKH/RuDFeKRL/LmnaJcUwL/lRFr7i4rf8PqS/7oEkWsw==
X-Received: by 2002:a67:f759:: with SMTP id w25mr22131969vso.235.1563308906765;
        Tue, 16 Jul 2019 13:28:26 -0700 (PDT)
X-Received: by 2002:a67:f759:: with SMTP id w25mr22131851vso.235.1563308905507;
        Tue, 16 Jul 2019 13:28:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563308905; cv=none;
        d=google.com; s=arc-20160816;
        b=VDnlP2Scza6xlDnTYXWl6CKxpZrwixK5OGN4bUP5d+JlBM+uzw/h4aNnooECPGU/uc
         hXB3YmkAr7l+6WmDLmZsJ7f5hQc3u0Zpa7MO9jMn//bZfKpv3cSjZkywK9oGHG4YN31h
         2emo4Z1xCoaYsWRk6ikcjly5PPVut5S5JtTcddhDmuH94ZVXDgCO/ioJazF40u96ctNU
         yZ6CA0eHgt5lxshRsSCWkqVx0VcbO+lLuRhzuoOGiTCUcH98AlOOye3CbGCN7ekWwsE7
         OD66fi08YcTEtrG0mbmeB3jqXj8GTtaUnJNdXbAAlaeYzs0difNkhuBcczN6NGtNNQ9O
         m6QQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=UjTFcdnVd7s1YEwLwLvsfGG9sPlxZRXqbP8Kb8AL9ZQ=;
        b=yNiu6od6RX0bKk/lxdx3EOKIKe2N9HjCSL92L9xt6A6RnO2P0RjV2NfvSkySZxxB/H
         pI21M7uPqkvgUoKMJY7ybwpH1kLgsWKWpMRxfgsNIVNQuSHS36c9EofdBd0TjEWk0RAm
         PSUh6hNfB0Pb62jaVVNf0T4ItUGaLW/oEC3oHkqWUAFj8xy+WmP5DjrF0PWnFLiFjznn
         iOSjv06K/abnl6PcJOFhCNoYucIO03PManQ/R85azXM6ZA296AAPzx//o7mnjJlvBBPE
         hYcFBBgceyLdACPH8AxMeP/9rM5Sjm+aolQO948cLolcuJiz9G2ZPERhgR24FHlfQi9y
         mqUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=qlBsdqb1;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t1sor10774358vsj.93.2019.07.16.13.28.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 13:28:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=qlBsdqb1;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=UjTFcdnVd7s1YEwLwLvsfGG9sPlxZRXqbP8Kb8AL9ZQ=;
        b=qlBsdqb1KQr1ExF9/YzSOXtCovLJ6CtV2qWiLG5wJnwV6nQg/i/H3R52CVt5c8Eqf9
         B+0hnD2r1zE9RSTzJqiOVJKUZw+0WE9TYUFtaEWwEhnTVO9bSsoplLU0CCfoD+gVwEv+
         Y6oKIZgbWJJ61IRNuXDVJ0O33dnXn7Y2+FQ+VKXZsQmDvvadhPyoBILBFvw82/Dhd2BR
         9wQNkdx/4Pu0YNVqj1+tHaUj+F7dFFakpniLUPA4c1L4/3wwTr9QqzJEbdnf6oEN4h4y
         NbzX9f/M9fQO0j924PX3RRr86L9XAahk1cmcPOeou7pE9t/F76sCsYK29AGBT+cOOSGM
         Q1CA==
X-Google-Smtp-Source: APXvYqx8BSAvMkaR3wy2NivfcuCgXjFmOhNmRIjDK4T8nCSa7DOvd2utZH77Ki+v2aCCiXzIQgMuAA==
X-Received: by 2002:a67:d39e:: with SMTP id b30mr21307008vsj.212.1563308904667;
        Tue, 16 Jul 2019 13:28:24 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id g66sm5590218vkh.7.2019.07.16.13.28.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 13:28:23 -0700 (PDT)
Message-ID: <1563308901.4610.12.camel@lca.pw>
Subject: Re: [PATCH] Revert "kmemleak: allow to coexist with fault injection"
From: Qian Cai <cai@lca.pw>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, catalin.marinas@arm.com, 
	dvyukov@google.com, rientjes@google.com, willy@infradead.org, 
	akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Tue, 16 Jul 2019 16:28:21 -0400
In-Reply-To: <20190716200715.GA14663@dhcp22.suse.cz>
References: <1563299431-111710-1-git-send-email-yang.shi@linux.alibaba.com>
	 <1563301410.4610.8.camel@lca.pw>
	 <a198d00d-d1f4-0d73-8eb8-6667c0bdac04@linux.alibaba.com>
	 <1563304877.4610.10.camel@lca.pw> <20190716200715.GA14663@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-07-16 at 22:07 +0200, Michal Hocko wrote:
> On Tue 16-07-19 15:21:17, Qian Cai wrote:
> [...]
> > Thanks to this commit, there are allocation with __GFP_DIRECT_RECLAIM that
> > succeeded would keep trying with __GFP_NOFAIL for kmemleak tracking object
> > allocations.
> 
> Well, not really. Because low order allocations with
> __GFP_DIRECT_RECLAIM basically never fail (they keep retrying) even
> without GFP_NOFAIL because that flag is actually to guarantee no
> failure. And for high order allocations the nofail mode is actively
> harmful. It completely changes the behavior of a system. A light costly
> order workload could put the system on knees and completely change the
> behavior. I am not really convinced this is a good behavior of a
> debugging feature TBH.

While I agree your general observation about GFP_NOFAIL, I am afraid the
discussion here is about "struct kmemleak_object" slab cache from a single call
site create_object(). 

> 
> > Otherwise, one kmemleak object allocation failure would kill the
> > whole kmemleak.
> 
> Which is not great but quite likely a better than an unpredictable MM
> behavior caused by NOFAIL storms. Really, this NOFAIL patch is a
> completely broken behavior. There shouldn't be much discussion about
> reverting it. I would even argue it shouldn't have been merged in the
> first place. It doesn't have any acks nor reviewed-bys while it abuses
> __GFP_NOFAIL which is generally discouraged to be used.

Again, it seems you are talking about GFP_NOFAIL in general. I don't really see
much unpredictable MM behavior which would disrupt the testing or generate
false-positive bug reports when "struct kmemleak_object" allocations with
GFP_NOFAIL apart from some warnings. All I see is that kmemleak stay alive help
find real memory leaks.

