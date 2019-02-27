Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 627BEC00319
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 21:32:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28FED20663
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 21:32:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28FED20663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7A688E0006; Wed, 27 Feb 2019 16:32:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2A6B8E0001; Wed, 27 Feb 2019 16:32:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A41B98E0006; Wed, 27 Feb 2019 16:32:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6569B8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 16:32:12 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id u12so7522192edo.5
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 13:32:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=EL4WBc+QHYJmrrDir69Cl7DD1KVpPrBr23JxqcuYE+s=;
        b=ePpiFOZn+zlAGWNgEil/kCoD11G9gF04aGTKzf/h/tU92yNVHU3hlruQVIDo8apLe5
         p/QG6ZlZprRJa6oku74Zw7VBfK8XObb1db5eS2pTgUqqIXLrjdDyz3d2QvPE4uiCQQuL
         WtzDN+nJWhVAFCKIvsVZdB/hsdbjVOYO06gveLYbKqlzP6e9DYY8y9PXrz0IJjfjcxDf
         D8gKbia+gXLWAOHJWqBw+2cbickubIffYmcvmIfjT5PsKRYYncEwt4Y74Kj8V37QmRZG
         1x/YW4jOffG7n/rK8o1Kd7qN/B3Z/72tK+E6Ze+Uj3WTuFeOUpqsuQDRl5UL7gK3KANA
         xnmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAubiN/5YJokzC9IYNwV1eFyZ0QuKM7yjBxPRdz1i7M/MCJV1VQJz
	oMXRAe4nPHfCgw2SplPF/NGAAt7Q1HZTKEfE6+RL9MtT6iQocmRfWraokrFaioNXqAd9IeCl7TS
	s5oLwXk7HbmHSQ+5utWUs+P9XXopCfRReBGFyBNjvKUwcOazuoIa0gPT01zryY8TllQ==
X-Received: by 2002:a50:b7ca:: with SMTP id i10mr3968075ede.37.1551303131962;
        Wed, 27 Feb 2019 13:32:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYwBNPJTMSF2A0ykV7kmmC/58sWmP8toBxeMd8h1RnpFEks1nyPFbN/oDZTRvaecElwDjbs
X-Received: by 2002:a50:b7ca:: with SMTP id i10mr3968015ede.37.1551303130784;
        Wed, 27 Feb 2019 13:32:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551303130; cv=none;
        d=google.com; s=arc-20160816;
        b=g9ZWhYHUB79fQJB3t623if16m/JVvi/LGkjJZ5braCEJSurIWwpN4ERp1X0X8egfR3
         vIsa7499+Reng6Vjh+1HQ05Y5HVNtOyNks44/h10PX2xTBety+YQwG0majhWvfJBMAha
         zqssVWr2LD9mx5tbj+mT5XFHjESAHVIyPEJTdwBTJNop4TIWHiPNzNYmDAERdVOWGnYo
         4yT1JwWOSnR2it4qEhwWzoYjxlWTumJLRVXqJJf1SQMAV1BOj/DzI2F98GS9xiWoyA7K
         FPRWBgmj9029gIxRlMLk99HMmPSBKxc9F9da/OvYOW7NErdjFQBvbLP/BDf2av4InOCf
         i1wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=EL4WBc+QHYJmrrDir69Cl7DD1KVpPrBr23JxqcuYE+s=;
        b=qHlr/2lI4ThR8ZojePcYz/3C2KM7BvwotxVGyzbL/vyJRuAY6f1tRu2jxNfS+Yn8SM
         DsI23OO78+1vb7nERykqeX/jzqrkgOlct0AzJaCDbfcQwd5a1G4Oj0AM29WekP6V330L
         ZSIT758AqzUhj/b5S2O7a8yauG34kuVJwJ245Ux//aNBZ+PzXqpikOLGPPjplT/IGXC2
         XfqGL1+Of2RExkZbU6tzkBPC9nhbFIhi323DzvG/ZyabSWvg/chKOndroqT4CqtENFTo
         sK4nHOy1bIuYjHo61y1YAId/7BfIgRyilsp184UHJbYKo49htFEBiRwjVa7Pom8taZzZ
         kKSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id bz3si3624150ejb.63.2019.02.27.13.32.10
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 13:32:10 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 90D6C43ED; Wed, 27 Feb 2019 22:32:09 +0100 (CET)
Date: Wed, 27 Feb 2019 22:32:09 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org, hughd@google.com, kirill@shutemov.name,
	vbabka@suse.cz, joel@joelfernandes.org, jglisse@redhat.com,
	yang.shi@linux.alibaba.com, mgorman@techsingularity.net
Subject: Re: [PATCH] mm,mremap: Bail out earlier in mremap_to under map
 pressure
Message-ID: <20190227213205.5wdjucqdgfqx33tr@d104.suse.de>
References: <20190226091314.18446-1-osalvador@suse.de>
 <20190226140428.3e7c8188eda6a54f9da08c43@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226140428.3e7c8188eda6a54f9da08c43@linux-foundation.org>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 02:04:28PM -0800, Andrew Morton wrote:
> How is this going to affect existing userspace which is aware of the
> current behaviour?

Well, current behavior is not really predictable.
Our customer was "surprised" that the call to mremap() failed, but the regions
got unmapped nevertheless.
They found it the hard way when they got a segfault when trying to write to those
regions when cleaning up. 

As I said in the changelog, the possibility for false positives exists, due to
the fact that we might get rid of several vma's when unmapping, but I do not
expect existing userspace applications to start failing.
Should be that the case, we can revert the patch, it is not that it adds a lot
of churn.

> And how does it affect your existing cleanup code, come to that?  Does
> it work as well or better after this change?

I guess the customer can trust more reliable that the maps were left untouched.
I still have my reserves though.

We can get as far as move_vma(), and copy_vma() can fail returning -ENOMEM.
(Or not due to the "too small to fail" ?)

-- 
Oscar Salvador
SUSE L3

