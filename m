Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FFB6C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 21:01:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E4C5217F5
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 21:01:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="oVKMpM2e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E4C5217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB7D26B0003; Wed,  7 Aug 2019 17:01:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8F7F6B0006; Wed,  7 Aug 2019 17:01:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A4FA6B0007; Wed,  7 Aug 2019 17:01:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 675266B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 17:01:33 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h27so57470726pfq.17
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 14:01:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9Bqfh4I9+7QrHMf7ofuM1/JRfKOR22mvXehSEW2OYNI=;
        b=IV6CQkcvx0iQvV+D7wL0DGMIwkL9yuLHGdEeJCVVJwDp5AUGhUjQnuCul/Ts2I007c
         MhSb0L5OD/uOPh0aZ1FD4LUobQ7S0rKhvotcrJbprSCO2E3R42ncHQN+SgXi2HUUNTcH
         psTShZfmAOcOZmKGqrK6pFvHCPhlaS9pcWEBCalpj3hpLcNSUf6AAFSP784+3TVhPT+Y
         fK7TOuHoFdVHG1Z5blwRd6TKdppzlQriAU1dOv4jrGSL1myhaAA6/4nxt9tyL/x2L7yc
         GTuxfTvi27xRpS7r5UzMTlzSH8f+xyYmcsPZJ0rvUEWxwjjXj716RYVxMJ2TcmWvFbK/
         C0ng==
X-Gm-Message-State: APjAAAXOEGsm1pzdMcCIoB3YbXZLpjwDjetEpw55e0WB5FiUbIkG5bHA
	QOdMuB1nI3YVkdywmqHrWMy8rQNfR7pLBcmdLlJC7rv5L7jtwTZGKkZGnklwhIPaqyd/3lCz9jK
	HEO2kvptYaS3pYhh6YP8RzIOsxYrncoayYVxBx8kb1cKgiyMjZWWvFCCIleN312pzUQ==
X-Received: by 2002:a63:5f09:: with SMTP id t9mr9462587pgb.351.1565211692775;
        Wed, 07 Aug 2019 14:01:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZSryOo3JNbFJZqzsmwUhHs/pxLlsC5tk8pa2NnFnBoskLOvbT7nG2G8ER9xvIpl0sVEyi
X-Received: by 2002:a63:5f09:: with SMTP id t9mr9462526pgb.351.1565211691907;
        Wed, 07 Aug 2019 14:01:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565211691; cv=none;
        d=google.com; s=arc-20160816;
        b=v+g+Z0vzqGxYgKuO4crjX3xc3GWyg13WN6fz0dcb7eomEtvNExpOdBP9F1x5kWHhui
         jJMOYSb1bpjrAXolPIGOuhwfeluDPnSauWHIONVC4ORRbL8ZYhGehG4wdGyEBbqkrV5V
         MY7Q4avWVEMnIye2XxmZTxE2BoyguC86p3PT81htluK4tSxc3sL8cF7ceED8Yu5WNUYw
         wigtPBAflRkV/ZjMq45JbTBsTj6tnYztzC0+Dd/Q3I4cOoogWvsbORYZtcW44Zu0LZM8
         aMVbxYhiq0X5s/0hga4MxJFPfW0tn31ZZLrM4LyCeWvX4Fof4xHZnZnaU5Pd6mTtr0Pk
         7V4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9Bqfh4I9+7QrHMf7ofuM1/JRfKOR22mvXehSEW2OYNI=;
        b=HsoRkePgmDTEdCU/mE+2u8t7rilYzuF44qYARuRL0uDNsgapcEK1VO/bsyLpePOCSz
         AtHUQPHH5VYXS8pQpF/ylHJ7cMNq9IUSm64tzQSUMWmlO7UdrGTqBr3nnSUmB2TQopTe
         29h9avBgwxEq7H5psPvOEzrZU3cYAmb34ZsHnufJMl3WMIIQOu/9TSuAp5CqKfyhIfhR
         EWjMAoz8/sPhirtKQA6CvMMR2/421Y/OL2Ev17ZaJibW+Wxqg/zqTYeKQDfNDsqAK7Q0
         IjBjzrmdK7nGJPeyBgsx/+sHpdL9g/adjTeMXlxjGigTcE/KBm0RWaiNATyQf6XrCrGY
         Q4uA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=oVKMpM2e;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w8si11212577pgp.414.2019.08.07.14.01.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 14:01:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=oVKMpM2e;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 42E452173C;
	Wed,  7 Aug 2019 21:01:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565211691;
	bh=+qBbfBSMAH7Y3GHuWbe+rylHpzCgkxGkF76I78EmJxY=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=oVKMpM2eI1851tBovePX/3oFkhm0jedmWGpX0lOJRCyhVvcrHTCVgDWE9WFHNn1rP
	 WFubGz9PQLZVC6YbI6q6EFc8Pfl349VJXeEIbnTNvRnETpfhuKci6P9uqPrkNuoWI2
	 OZaLmDlzO29vPnGG+m4zGuD1EldUfhdTABKXMH6k=
Date: Wed, 7 Aug 2019 14:01:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Suren Baghdasaryan
 <surenb@google.com>, Vlastimil Babka <vbabka@suse.cz>, "Artem S. Tashkinov"
 <aros@gmx.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm
 <linux-mm@kvack.org>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
Message-Id: <20190807140130.7418e783654a9c53e6b6cd1b@linux-foundation.org>
In-Reply-To: <20190807205138.GA24222@cmpxchg.org>
References: <d9802b6a-949b-b327-c4a6-3dbca485ec20@gmx.com>
	<ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
	<20190805193148.GB4128@cmpxchg.org>
	<CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com>
	<398f31f3-0353-da0c-fc54-643687bb4774@suse.cz>
	<20190806142728.GA12107@cmpxchg.org>
	<20190806143608.GE11812@dhcp22.suse.cz>
	<CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com>
	<20190806220150.GA22516@cmpxchg.org>
	<20190807075927.GO11812@dhcp22.suse.cz>
	<20190807205138.GA24222@cmpxchg.org>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Aug 2019 16:51:38 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> However, eb414681d5a0 ("psi: pressure stall information for CPU,
> memory, and IO") introduced a memory pressure metric that quantifies
> the share of wallclock time in which userspace waits on reclaim,
> refaults, swapins. By using absolute time, it encodes all the above
> mentioned variables of hardware capacity and workload behavior. When
> memory pressure is 40%, it means that 40% of the time the workload is
> stalled on memory, period. This is the actual measure for the lack of
> forward progress that users can experience. It's also something they
> expect the kernel to manage and remedy if it becomes non-existent.
> 
> To accomplish this, this patch implements a thrashing cutoff for the
> OOM killer. If the kernel determines a sustained high level of memory
> pressure, and thus a lack of forward progress in userspace, it will
> trigger the OOM killer to reduce memory contention.
> 
> Per default, the OOM killer will engage after 15 seconds of at least
> 80% memory pressure. These values are tunable via sysctls
> vm.thrashing_oom_period and vm.thrashing_oom_level.

Could be implemented in userspace?
</troll>

