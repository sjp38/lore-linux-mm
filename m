Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E924C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 22:35:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CE1D2171F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 22:35:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="OYNxeNql"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CE1D2171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC94D6B0003; Mon, 15 Jul 2019 18:35:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D52FB6B0006; Mon, 15 Jul 2019 18:35:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF3F36B0007; Mon, 15 Jul 2019 18:35:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 87E576B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 18:35:29 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h3so11309855pgc.19
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 15:35:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=37KY7xtCT4JwMNGlmpLvOULhQh/leviQmr+khEKjShY=;
        b=W+cf79d9sNwBiOw8y/efApzXSosAOYeOk5DLJ0ix3UrJ8zk/70ZQ3moxIlaMCGj7kH
         6oMJ0y3qTP+01I5Jm6iMf6XrZF08q3K1QGElSBgmHyXROF9ln04F5qyPcK/H7EIxju5W
         YV+xx1grDZ5Hww176V6GbEjVXNeQqRL+1gscct2y+EbCR2gD+n1dmpCzC1AEO4wna4mi
         ksg1weY1yna5dSvgEVYIEnuMRBKc7c17vU8EyMvq1OmwSK73qPydAiFmFw2n2XV0pZmM
         H4UiiXAFE6+2xX/eclHEUpFrnZSaonfvb3J3m5LgDwGyIlYHXla90UE57NZss8OvQmvj
         8WYw==
X-Gm-Message-State: APjAAAX4ceAW6QCmS3eS1m2wOZBiUgipGMd2P9+ar8CqBPA215lUFX5p
	fuNPG3jqvGECxN+tOVtP1LBlCGc+JSjDSRfMXbFDO6e9hww//aKkISfJxOdZCqii4OyvQSmxtl4
	CnS5sLz2mUdjxcC+IRyiSY9gopDBJ18x8D1p2gWTtIOxCil+jG5+Ukn3ulVDdQ0nOtA==
X-Received: by 2002:a17:90a:3463:: with SMTP id o90mr32580215pjb.15.1563230129190;
        Mon, 15 Jul 2019 15:35:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuqlrdJ93EOiaUuAbK+W68M9fkiAYf8L1YJIL+dLwJX73N8pjft4BrywjWMhV8cGgF+SMf
X-Received: by 2002:a17:90a:3463:: with SMTP id o90mr32580159pjb.15.1563230128526;
        Mon, 15 Jul 2019 15:35:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563230128; cv=none;
        d=google.com; s=arc-20160816;
        b=LQshxawQR9DYAKAaRy9j+aeMymfJjaRqoW5p2WI2XV29kv/wpbgc+i8LBLDQxDQD8w
         tRUPjD6Ex6Plir15Ir+NFR04rQmWe8dZPbktH9csm+QvnXLAGJ5QI5gVp6sTF/O/pAfp
         nkeJqbhBFO4qgZ0tGqL007s+YB8YwyW2Kkgu9cmtjXU1z9nF3cKAqQezinzMrf1dq+Jp
         4UcZVEiKF29mMvY+PeOyALjGx+D+OBZerU3OWlc7rk2+zHyg3C9u9FLETnaoJcI+2GcO
         pm5JPEBy8dFb4OhG46GBKHsNq9d4R3w6lISsAzr0jsBSLVuuqy23u7+1MeVUQHX0eY0N
         zbCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=37KY7xtCT4JwMNGlmpLvOULhQh/leviQmr+khEKjShY=;
        b=H0yyxUIN5vvq7g1pGHAlMbtMGTzbdLBPpqZAfYiz/u7vwAmVMfBCyOqO7lg7IGrmnO
         eb9QMZCJHk8cYFg1rTfhQtCe09J75PygE6+IRKl0S/XUNldl2qoBgliKSY5R7vMzRp+M
         SIsLpU6lu0V/6/nHPLi7zj+sZutbPZM6/ATmQArJj0sqs3ly/X5kZFqZqFKydG/iUz3f
         p7pwPuMxrjUGEeGbkUb5KJC725r6swly0fXTnZ0QAWR8k00TGwc4fpXNICIIUwIbCll2
         vlRu/74IsHcrvaXVDfaGI3nSB0QFREcURlnBWP3uMmbfY6PKSPIZ1Sx9IUfptLaJ87tK
         DdMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OYNxeNql;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id cn1si17298751plb.204.2019.07.15.15.35.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 15:35:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OYNxeNql;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B77DC2086C;
	Mon, 15 Jul 2019 22:35:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563230128;
	bh=Dhp2+rAmaJRqgQ4W9zWGRLoTJ1hk6O5nwAes/tP0jXQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=OYNxeNqlSp4DM+68xBXNHVmmuaMCEc7vAD+ioCjOMRuJnlCWj5Z4QFMkH+09l0tju
	 vVg15F6qj1fwZhkSrafpF5PiJWeixRExiJuHx8RGfkobzmc90Tff/7ld+JpcFve56S
	 li8bTQVcIwkIthO4FJwMEpLAxdLXovL3EGbCQ+3w=
Date: Mon, 15 Jul 2019 15:35:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Roman Gushchin <guro@fb.com>
Cc: Chris Down <chris@chrisdown.name>, Johannes Weiner <hannes@cmpxchg.org>,
 Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Dennis Zhou
 <dennis@kernel.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "cgroups@vger.kernel.org"
 <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH] mm: Proportional memory.{low,min} reclaim
Message-Id: <20190715153527.86a3f6e65ecf5d501252dbf1@linux-foundation.org>
In-Reply-To: <20190128215230.GA32069@castle.DHCP.thefacebook.com>
References: <20190124014455.GA6396@chrisdown.name>
	<20190128210031.GA31446@castle.DHCP.thefacebook.com>
	<20190128214213.GB15349@chrisdown.name>
	<20190128215230.GA32069@castle.DHCP.thefacebook.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2019 21:52:40 +0000 Roman Gushchin <guro@fb.com> wrote:

> > Hmm, this isn't really a common situation that I'd thought about, but it
> > seems reasonable to make the boundaries when in low reclaim to be between
> > min and low, rather than 0 and low. I'll add another patch with that. Thanks
>
> It's not a stopper, so I'm perfectly fine with a follow-up patch.

Did this happen?


I'm still trying to get this five month old patchset unstuck :(.  The
review status is: 

[1/3] mm, memcg: proportional memory.{low,min} reclaim
Acked-by: Johannes
Reviewed-by: Roman

[2/3] mm, memcg: make memory.emin the baseline for utilisation determination
Acked-by: Johannes

[3/3] mm, memcg: make scan aggression always exclude protection
Reviewed-by: Roman


I do have a note here that mhocko intended to take a closer look but I
don't recall whether that happened.

I could

a) say what the hell and merge them or
b) sit on them for another cycle or
c) drop them and ask Chris for a resend so we can start again.

