Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F6C9C00319
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 21:40:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC1AF222A4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 21:40:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC1AF222A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CE0D8E0002; Wed, 13 Feb 2019 16:40:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57D388E0001; Wed, 13 Feb 2019 16:40:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 446C58E0002; Wed, 13 Feb 2019 16:40:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6C98E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:40:57 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 2so2602797pgg.21
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 13:40:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1ASkPVZxGm4nKTysc/3TBDLOdrLfMW5lbf6W/p2mbtw=;
        b=hCdB+x08+3AhVqXE/q9x7SrPD9qPdZ7PHAja2asLdfNw4j9QZj2Mb8LG70Ydrp6QyJ
         2uRF5Ny84y3aI7XBcOFeUPdjdvcacEUrhf5dsWLMemoIVj82cDaDRwafYY47ZOO5jkN7
         GGPcJVGlHEkKkYVphDUQElO/YaDUiRc5NZ/duUBeB0oynLE+55qVP5Qw0dFasQ7Onx65
         uOnJDAoQYyJobm6capK0yY5VyVgBT2wz+QfSDjVVP0GS0hvr/HSpm2STvj1WZBeR/iEd
         yrnG+z5E0LKdfT2RkW3xLaZCnC5Ne/5bkyV4rXI1g0aOcWKEktcnQAnZ0RvFZ0bXAkoS
         chuA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAubZ7DgBntCL3LkmsB9i8U8gR3FV6G07tUpGcZNvII1ncjTHnzvq
	FNdOfsyEcJiBEL/0aZlEf4wTxGrN3tnB1udyFugfXWD06Ne3jh6y3qr9W0nO+l3k8ie8qsD29v8
	1gbUBGOVXJRJWDeZi4Qe9F+Ng6/i+2Q6+XcemwouT+WxkHW814ZgvDpO2D44YPAv99Q==
X-Received: by 2002:a17:902:a415:: with SMTP id p21mr319944plq.7.1550094056733;
        Wed, 13 Feb 2019 13:40:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbfDqhfQloXfCrhsYV9nQ4kVbGaokZHyg3o0Ov7kUGCnd3og3W6CvLVaxDZL3o0djis9upF
X-Received: by 2002:a17:902:a415:: with SMTP id p21mr319889plq.7.1550094055934;
        Wed, 13 Feb 2019 13:40:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550094055; cv=none;
        d=google.com; s=arc-20160816;
        b=qSgzikQPaK7yiTZ1QyM/bAeRkDJ6Fjc5ObZv/Cc3JgYUcpDoH1TkIoF7VMgr4M2zUw
         4cj0c68smp5I1SzC7PgNrDtP7FSN7Q9aZLOdJpiqLWzdKkk0WHA/jE4F1bz5cE85uoU4
         2W1y1z9UUgKttKoY++/Bz+r9TvbLRrBbxetzIau8lkpdS3BYQUKaZGKFaixGWFPXO4+9
         N6ZYIJIMEG6A65ukp4npXe6sSqGgLN4waxcLzglPcvcto4VDDKbCrJV4bwAwWLH41cBw
         /R5voCVjgGrF+c8BwsQrcvBVQ2nHU0jdc97BpzuyGeeFt8bQHz1mbDp58wm3k5XDbVec
         z5rQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=1ASkPVZxGm4nKTysc/3TBDLOdrLfMW5lbf6W/p2mbtw=;
        b=MuvYOqx7lw3mF0UvprIK4xsN+yXswJ2ZpxX2m4GxhNtnEzY1boBcql8pJkQMBXG/H9
         go4q56fE7UDtI6kF4rlGpkfaQBd2amIFhA9LiIX4hFcD5psF+zirEnPFq7eMdbN+GlEH
         gKyM93vV6vHzE0m3XmabE8H/ScTLGYm8SUP/SlC3yjvY1E7O5pHSzbLGx1zD5Br26HKZ
         4/ky6/DxAdqHvjzXPcRhPQxyqfATeME5ezrOdVNCuBB9YHYt3Lu7C27zvzZPjNbHcGUx
         gK+9IniF+B85hUdWKmzF9q+APUbg1fKuOx/RSR1pw64f96fuCO/GaRl+SrsaAU/n1EGY
         IZcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s87si411852pfi.185.2019.02.13.13.40.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 13:40:55 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 558871389;
	Wed, 13 Feb 2019 21:40:55 +0000 (UTC)
Date: Wed, 13 Feb 2019 13:40:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Jann Horn <jannh@google.com>
Cc: Linux-MM <linux-mm@kvack.org>, kernel list
 <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Vlastimil
 Babka <vbabka@suse.cz>, Pavel Tatashin <pavel.tatashin@microsoft.com>,
 Oscar Salvador <osalvador@suse.de>, Mel Gorman
 <mgorman@techsingularity.net>, Aaron Lu <aaron.lu@intel.com>, Network
 Development <netdev@vger.kernel.org>, Alexander Duyck
 <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH] mm: page_alloc: fix ref bias in page_frag_alloc() for
 1-byte allocs
Message-Id: <20190213134053.3198c33f926f51163dd78256@linux-foundation.org>
In-Reply-To: <CAG48ez2Qo7N-+=y=eFhzw9HfYS3HODAY-zLaubFMGyXEV_nwpg@mail.gmail.com>
References: <20190213204157.12570-1-jannh@google.com>
	<20190213125906.eae96c18fe585e060aaf0ef7@linux-foundation.org>
	<CAG48ez2Qo7N-+=y=eFhzw9HfYS3HODAY-zLaubFMGyXEV_nwpg@mail.gmail.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Feb 2019 22:11:58 +0100 Jann Horn <jannh@google.com> wrote:

> > This is probably more a davem patch than a -mm one.
> 
> Ah, sorry. I assumed that I just should go by which directory the
> patched code is in.
> 
> You did just add it to the -mm tree though, right? So I shouldn't
> resend it to davem?

Yes, please send to Dave.  I'll autodrop the -mm copy if/when it turns
up in -next.

