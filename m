Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D2DFC742D2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 21:21:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D39D52146E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 21:21:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="VyTzUkFw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D39D52146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59D188E0169; Fri, 12 Jul 2019 17:21:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54C218E0003; Fri, 12 Jul 2019 17:21:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 461888E0169; Fri, 12 Jul 2019 17:21:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7468E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 17:21:14 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d187so6414310pga.7
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 14:21:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=F1lNHfCed2lqUhBPAULxhJwb0vbJQ1dpTWKObGf7USA=;
        b=Z8j+YXlfZtF9aYcQJmZvgmP/0J4owgkXrhaKDEI+ioJRkadJ7NPajEXtfW1CatjfMa
         HF4XUUAgP/6eiZYsY3fA9hBhgE7KF9SddRQ0NmD+WamWs5T9oyGNKJC4/jbI1RapLz5M
         rRyu8Yn08wCO9Hu85JumbWxKMdu/pfMY4M52qz2JxhSpTFFDEt1gTr+93VRgxECb5IXa
         szghjySf8KydKe0Gr73A1JH//Yam2A0gH1yFBTkoXwSGU8Qrja4MrVnNULueH3kc3IZz
         lg9heZ41s0XhEQEbZofeC2GO79H1LwRatEuq7nDeCAVvxsRbsZ7VB5zOpducftJmqWti
         bO9w==
X-Gm-Message-State: APjAAAVZskJGHeC1okIlHgWD/m8b+oKIDfv5drCQRpHxObrM8VaZVlMB
	5LYifvm7rMhNHcaRz3t76vVLyXhnDHsRx92UNWWjusN5lwfrWlUETvzpZ1OHmb7hTT5zLxdTseD
	kJ8pXAbXJy9G6mPh4vBWs4DT4t9ES1NAmBxanMlVfQwdosbQ2EY5S64MZ5fPx7A0uww==
X-Received: by 2002:a63:f150:: with SMTP id o16mr4280586pgk.105.1562966473473;
        Fri, 12 Jul 2019 14:21:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1iuSG+MWrt/zATeiPNA+p/JgWymaJa2z0Ahr6mBB49jjFOlEwNeNj3ruYjhz0t7PXHiRz
X-Received: by 2002:a63:f150:: with SMTP id o16mr4280528pgk.105.1562966472670;
        Fri, 12 Jul 2019 14:21:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562966472; cv=none;
        d=google.com; s=arc-20160816;
        b=tTOX553AqTCj6sHaqGv0IZgSkNcu77DC9ZuJGZOOn2ZctU8sNtXjHwC3lcf3OItIbc
         hichRv2ePWFdajOOdjxCfQNdb01i2LB2FrvNG63RIGoRPc4PyVQjM9aCMI6qA5S8KXzT
         3pp8TVjdvUXZqZyMrzT0BgTZ0BEhbgoZoypKNkR+owkLOrMGjsEPgZudC222JH9qlS0X
         EEVnRCyomnn5v9GTItaFBUbC3v1CGBcrSoudNRUiTIZ44+JPDWRLHraHJ6bY4PLgmGnS
         3rNAroziVnrk/RlivO4lhti5fUmhB8yQsOrNLEB111DRfQ1/5CZxl9FFx89aF3rYuFPm
         yzog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=F1lNHfCed2lqUhBPAULxhJwb0vbJQ1dpTWKObGf7USA=;
        b=vFzrum0DZKY3exkr0tCv+XMuR12sy9iuSAAEnPdrxv7AP3sVc3LouyAYsEO/MYWw3u
         eOCQvBWKFREfY5NRCVLEc9lHBXWXAdDzePLmaEn2KKKKwicnVevIqKpQWAKX/zt6FhuO
         hGGSBUybxQN7KSQRqXNFGJ6Wxo/fSGhI8rC0G2eElSPHzeyb5pZwEsuSCt2M119xe5CW
         geV4T/k9jOLK/f6gZwNi3fysjmsSIOmSk960GO6/KuGumJPHPNM+ML8cUBW76rO9GU++
         fKoJA9M4LGj4AhdbjulkNGW1YhwrD1AOnLRJATiZG5Xz7Gm2kZxE8n4RMTUA0t/MFvKe
         wAqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=VyTzUkFw;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f20si9343855pfn.166.2019.07.12.14.21.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 14:21:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=VyTzUkFw;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.64])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0D7B42146E;
	Fri, 12 Jul 2019 21:21:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562966472;
	bh=UfhH+qwZBH+tVJt9XqklnwhR+TQu6aQMk7iJb9IF0v0=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=VyTzUkFwOSGD10Gtwey/oyOtWAAxst1dmhN6RE5AaeNaVvM/b/+22UD0qVzNQATrx
	 dPHaudNa72m9jBuShTX3SO2XmSAu0YvIf20RvuUJzXu6uGLkPVhYBUxVQX+cpHRr1l
	 o3nJ3wtiZtrUWIHvpVcShCPJAxXOCZ2SkkbIX73s=
Date: Fri, 12 Jul 2019 14:21:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, mhocko@suse.cz,
 stable@vger.kernel.org
Subject: Re: [PATCH RFC] mm: migrate: Fix races of __find_get_block() and
 page migration
Message-Id: <20190712142111.eac6322eea55f7e8f75b7b33@linux-foundation.org>
In-Reply-To: <20190712123935.GK13484@suse.de>
References: <20190711125838.32565-1-jack@suse.cz>
	<20190711170455.5a9ae6e659cab1a85f9aa30c@linux-foundation.org>
	<20190712091746.GB906@quack2.suse.cz>
	<20190712101042.GJ13484@suse.de>
	<20190712112056.GA24009@quack2.suse.cz>
	<20190712123935.GK13484@suse.de>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jul 2019 13:39:35 +0100 Mel Gorman <mgorman@suse.de> wrote:

> > So although I still think that just failing the migration if we cannot
> > invalidate buffer heads is a safer choice, just extending the private_lock
> > protected section does not seem as bad as I was afraid.
> > 
> 
> That does not seem too bad and your revised patch looks functionally
> fine. I'd leave out the tracepoints though because a perf probe would have
> got roughly the same data and the tracepoint may be too specific to track
> another class of problem. Whether the tracepoint survives or not and
> with a changelog added;
> 
> Acked-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Andrew, which version do you want to go with, the original version or
> this one that holds private_lock for slightly longer during migration?

The revised version looks much more appealing for a -stable backport. 
I expect any mild performance issues can be address in the usual
fashion.  My main concern is not to put a large performance regression
into mainline and stable kernels.  How confident are we that this is
(will be) sufficiently tested from that point of view?


