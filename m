Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5025C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 01:13:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81CA42085B
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 01:13:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81CA42085B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F073B8E0002; Thu, 31 Jan 2019 20:13:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB5E68E0001; Thu, 31 Jan 2019 20:13:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCCCE8E0002; Thu, 31 Jan 2019 20:13:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A90918E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 20:13:10 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 12so3755058plb.18
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 17:13:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Mh7IzmtpzO8PQ8plIMa+H7DtF/qqOloAmU1YTRWw8j8=;
        b=W38/xrMEUjz3fyqbQEPJBFqT4t2WnNgCUd7L1GmOD/5pV8ZMaK+D7g6TnRI0c5EcNZ
         lHARe9HHGG34vurmUvU9wTE8xi13/UXQ6bvoHx+6cVFHDxp9u7JKthBkMbcIdnSSlo34
         cGepqkabg+a+NJhWG5k0ZHmbjvrStKntwKi5cw2QIyJ0hCKfXw1wW6IeuiaVnNZX/3s1
         GXfD0wj/B3Qdv/H/Zqz0cTB9vadd/LiFCtytQ0bbWN51FceC+Jk/gBHcphDL3+p3BVbA
         j8wJ7ZBKmEpyaXQOMG3y8Y3r3eHcj+mVwQUl9CUbkX1bx5elM0o7EJ8t4EIIALoFmhs6
         HmcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukeCnUSsi/moQVvoEMRuDy7+/nv3BLo9slJxiGY41lTJNtpwhwXd
	kDjBzvXRZYn2CyujBYT1V800vYPwlwBe23XkdI+BPDnZZonMZwlgOMVGXapHe8KLjNI57dMWZd7
	C7tlG4Y6HCCwpXnvMmo+KJn9/ldT4I2O2nS0I4Q/+t7u4QlMZeWLJ0DgnCqbKmx7+Cg==
X-Received: by 2002:a63:d904:: with SMTP id r4mr33842409pgg.207.1548983590193;
        Thu, 31 Jan 2019 17:13:10 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5lnVdA7clOfmA7mXkuBRBw4+SfUP1NpHiK60rlR0IC/+6D5rJQTY3tBf8qblC6KpRp/Pr3
X-Received: by 2002:a63:d904:: with SMTP id r4mr33842375pgg.207.1548983589597;
        Thu, 31 Jan 2019 17:13:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548983589; cv=none;
        d=google.com; s=arc-20160816;
        b=OvSUuC+YTDDaeB03nnXO/sGeIU4Qw/P2y2+3nvetlwLqxdNfcK7yhZLegNFOy1GbDP
         3qX93lhEUx9qY5az8ybPTNjfmUyrd31G2ywyNvFr9g85RTtPuwaV0Zez95L8U5s6w48Z
         d9wxgyGSt+AzyK6LJBN7GG8anneagXrB1peb6GgfbCRHe46IcHFdBwerXEUnABonoejq
         EGWlxmx4cjh3cdz2WCzPeCUoF/YffJ8oAr+aDPGBQ+U7agRBZ0Ij7OVgwyQZaJFn3tED
         gFhdV/TCmcBEzDVjgm4b1xNDFcnLpYh9ZAvSFxvg6YkJkGuu41NXQptLZ/NrfZpa6SeH
         Idsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=Mh7IzmtpzO8PQ8plIMa+H7DtF/qqOloAmU1YTRWw8j8=;
        b=N3M3a60QjffP+1L8nlgim1Ur2O7ePimUI0U8BDd533Pn4HlENu5iSR25EiazPya4+J
         GoN+NuH2bkczcCap4coaC/NGOot742pYUrzt3m4H/gYIYse6+mB06SO18b8JswTJFSrS
         TfSsf3eNwqfMJ1jlXsUn6YO1b1dH+ZBGGWXNkO+SHQUVNDG6TBS+wrO804kHvR2u0Lsx
         5uIjQJEn/3i2s9+t3xsesBgMGnXa3i4U6Y7fjSP6c5m40WoCSg6IRrqdCGzMIYiQwuwA
         6UQJs9pc6ndezGDwEtGWSF1p/ufM1zmNbM112uDNLoFptvFVb9toLd44K3vHLHCvr8Rf
         N5BA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n13si5258657pgp.307.2019.01.31.17.13.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 17:13:09 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id AB8BE4FF5;
	Fri,  1 Feb 2019 01:13:08 +0000 (UTC)
Date: Thu, 31 Jan 2019 17:13:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: "Tobin C. Harding" <me@tobin.cc>
Cc: "Tobin C. Harding" <tobin@kernel.org>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/slab: Increase width of first /proc/slabinfo column
Message-Id: <20190131171306.55710d0820deb12282873fab@linux-foundation.org>
In-Reply-To: <20190201005838.GA8082@eros.localdomain>
References: <20190201004242.7659-1-tobin@kernel.org>
	<20190201005838.GA8082@eros.localdomain>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Feb 2019 11:58:38 +1100 "Tobin C. Harding" <me@tobin.cc> wrote:

> On Fri, Feb 01, 2019 at 11:42:42AM +1100, Tobin C. Harding wrote:
> [snip]
> 
> This applies on top of Linus' tree
> 
> 	commit e74c98ca2d6a ('gfs2: Revert "Fix loop in gfs2_rbm_find"')
> 
> For this patch I doubt very much that it matters but for the record I
> can't find mention in MAINTAINERS which tree to base work on for slab
> patches.  Are mm patches usually based of an mm tree or do you guys work
> off linux-next?

It's usually best to work off current mainline and I handle the
integration stuff.

