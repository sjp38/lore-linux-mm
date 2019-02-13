Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4182DC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 21:37:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A07B222A4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 21:37:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A07B222A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92E9D8E0002; Wed, 13 Feb 2019 16:37:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B55A8E0001; Wed, 13 Feb 2019 16:37:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7552F8E0002; Wed, 13 Feb 2019 16:37:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 310068E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:37:57 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 59so2645568plc.13
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 13:37:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cg/NbuZPWYwRbvqjjoz8GBNDa9Gssm1gttPEG1rygE4=;
        b=FibbCDfzBG4RFTx8fzM6mY+ekUbZxIA/UjByNJabih7DwGK1H6IB+E5Ho9o7r/5p4l
         UJFDdi4peUEm/30NpLn2EdFYNGKMYC2QryUEuItDYPp1CbfOYTH6qEnUUZqthEM6Ltlx
         dUNYxReunwuHbk/mlseGjYPzIJ2+zPkQbpd3AApmPe9h2HKJJN87SuX9m7iqS+53lX5O
         HzF4EtnUWQHQrA7S0dSFSXFVn21ZBaK8RcU4U3DVlO0sKe0xJh6+ImLn1iGcXAhElvHH
         AlO9xgdDL5fn+GOLO12Q0asNf7/SqXZbdrMwxTrUFAIEmdaHjS3pYzEvLVCNKp/6/I26
         edQg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuaxzDDZPUSkhzg2M/WqkUNqega52rIihvmceRVTSIx1UYXPVG8Z
	5HOZaVa99zPTe6l3cek+M0jgqfKgpz2liHH3FKvoQLAS2LqWmO/ZB65ZqyPBuROSqS9r9ddmYjn
	uvf6vAicNT25FawYnVNhTmvR1lbU1G9Cv2NNlKOF8rbi//wDjkTYc3hrVDfXlaeY60w==
X-Received: by 2002:aa7:8109:: with SMTP id b9mr314854pfi.140.1550093876859;
        Wed, 13 Feb 2019 13:37:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYOGitrRUQADxzEWq1RUW4oIkEd4jAkUbnr0j5yoqixMK5qTGWQrnWIpV2w/3VvgJxjfC+h
X-Received: by 2002:aa7:8109:: with SMTP id b9mr314810pfi.140.1550093876100;
        Wed, 13 Feb 2019 13:37:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550093876; cv=none;
        d=google.com; s=arc-20160816;
        b=orBzi+nvRShDPwaZ1GGPzTo5CJp7bkRvfXmjDhvUtU3GzbRtIApqzKnGGlSKgxAOBV
         XSgzTgRWi3sfwQqdhWzm3Kt4R+9OCAiHMw0jTGMKpl5t1MudOlI28igRn9lSPYs9XsZh
         YdA/iirleaGbnO4y9kT/LLOSaIBAIcVkozpQRb76UpDgD2bz31u7jgM/CaRAY5++kQv4
         ZBFyUrcsrDOGDAReueNS5/Ffm0vGqqsVsJA/1WvkIH2213y0KQ3nq3z/p3P1/1/ghrMc
         R/H1ml7VgbvY/kS+pxSd6mQjgydMr+umJrp6TtgVZLabhDT1HJTELYiYZc5UpQLVmyh5
         95MQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=cg/NbuZPWYwRbvqjjoz8GBNDa9Gssm1gttPEG1rygE4=;
        b=tzVLO7biCEXpiKW6l3qQaAG+nhjVzFqWr8Ds/KUTACnAXLCQEENwZTxwBjhrDmSTTE
         rNnPZlr43gqKZb3/o4QwNuChIEWUpWGGsOXz7V52j5ioC+GRIZRJBbFdMQhAmmEVaC6P
         yIUx5XjjG5lW35DYdvZRSElCujPj4YIvkE8JPy5d1RF0ArCQaNNjHSFwIZBUeAu+/Q9R
         Mrgz6mrcUwHrov+rfE+Kq+PUerOgsAlmwPVVWNg2jp9LPakPWRHXa6aT2RGFbtd96GAX
         3hHAF5fbJ7HoE4hTDeioI/uAIEmxBFxAYOS33m0iZYMEZCl5shElHFi58QLCOZijS8te
         CBwg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q16si407786pgh.185.2019.02.13.13.37.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 13:37:56 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 798361389;
	Wed, 13 Feb 2019 21:37:55 +0000 (UTC)
Date: Wed, 13 Feb 2019 13:37:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Chris Metcalf
 <chris.d.metcalf@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>,
 linux-mm@kvack.org, Guenter Roeck <linux@roeck-us.net>, Tejun Heo
 <tj@kernel.org>
Subject: Re: [PATCH] mm/swap.c: workaround for_each_cpu() bug on UP kernel.
Message-Id: <20190213133754.dae63726a93ba818e114cdb9@linux-foundation.org>
In-Reply-To: <20190213124334.GH4525@dhcp22.suse.cz>
References: <1549533189-9177-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20190212101109.GB7584@dhcp22.suse.cz>
	<82168e14-8a89-e6ac-1756-e473e9c21616@i-love.sakura.ne.jp>
	<20190212112117.GT15609@dhcp22.suse.cz>
	<20190212112954.GV15609@dhcp22.suse.cz>
	<20190212130620.c43e486c4f13c811e3d4a513@linux-foundation.org>
	<20190213124334.GH4525@dhcp22.suse.cz>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Feb 2019 13:43:34 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> Since for_each_cpu(cpu, mask) added by commit 2d3854a37e8b767a ("cpumask:
> introduce new API, without changing anything") did not evaluate the mask
> argument if NR_CPUS == 1 due to CONFIG_SMP=n, lru_add_drain_all() is
> hitting WARN_ON() at __flush_work() added by commit 4d43d395fed12463
> ("workqueue: Try to catch flush_work() without INIT_WORK().")
> by unconditionally calling flush_work() [1].
> 
> Workaround this issue by using CONFIG_SMP=n specific lru_add_drain_all
> implementation. There is no real need to defer the implementation to the
> workqueue as the draining is going to happen on the local cpu. So alias
> lru_add_drain_all to lru_add_drain which does all the necessary work.
> 

I assume that warning comes out a LOT of times under the correct
circumstances.

Tejun, I think a WARN_ON_ONCE() would be better.

