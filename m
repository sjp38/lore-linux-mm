Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.9 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81278C5B577
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 23:12:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A3FE2133F
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 23:12:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JSk4Hdvq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A3FE2133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84B576B0005; Thu, 27 Jun 2019 19:12:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FAC18E0003; Thu, 27 Jun 2019 19:12:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EA768E0002; Thu, 27 Jun 2019 19:12:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 37FDF6B0005
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 19:12:21 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id k19so2113343pgl.0
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 16:12:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=3K8ZEEArtsKiEJ5I7k4SQLYx/luEOe5+arx+qBgdSFA=;
        b=Ie7mPMel/yd4aC5KRVeiltiT56y1PNpcf9FWj+32DoFmiTt9roW5SP/TW9I7BjIPcx
         YbuAjjAaAmQHjC50iZl470AurUdpTXYLq7D2JwffFraRUduinZ5xApYs58ybghnYglOz
         UV41b5/cBd2+xxtrPcXvCsOEjcyanQoKnTjEH6ttzvxkAqjvdb7HIO+P2LJuru/zJhNo
         GTekOe/1VaoRrKk+JfYO2pBQqgLfZEISTanuC5lXBFl8RafPosvfDIb1JpputtG+4h3h
         eqytfCWnxny1tVznBgGx0dIqRjaGEzkf4qhGhDe13OY4Si2qiwis9PLuppZqJfifX8Hd
         GMIQ==
X-Gm-Message-State: APjAAAUHfBEn8uwqKFyLqxYM0KivIRC/Z2s4noS2L+wCOpI2LVDVL1mT
	djOB8ix+UIc0mUyACxtk8Cwkiw+xkIsLflEQB2I6RzMApgJbQybpwg1WLLlKvBBIEr3Rgk1TT0x
	lEGByEALYhSUD4WH/qXJpvt9Jud8C9ozElZ3cjDsGEKvg9/E02Gf/ZnMZ9a5nxBQ=
X-Received: by 2002:a17:90a:8a8e:: with SMTP id x14mr8832163pjn.103.1561677140740;
        Thu, 27 Jun 2019 16:12:20 -0700 (PDT)
X-Received: by 2002:a17:90a:8a8e:: with SMTP id x14mr8832065pjn.103.1561677139600;
        Thu, 27 Jun 2019 16:12:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561677139; cv=none;
        d=google.com; s=arc-20160816;
        b=kjmlXawusDOoPBhe9onRkX7fEsGv+KPJ+ewInQBjxt9TbaZKi7ELo/SesverqvO+8P
         yop+aq2dU7C0sIAwKnk3oK434g5uxvMNSvgZHxXUfM6AzIH8ZhMt/WcRvipm1jnEnYkF
         uq7VUK4H/EVvpit2Wk3WNqEVt6atq7YL4Z7qocYMAoSIwYQkdn3VcU2ZXWNEhKzzrbAg
         0D3ChfKBqiNDONM9cFVQ5N7o+kWQ7Ry+4kZPa+jijHe67cjDJOW6l+DdndWG3u+Vrezy
         S7/eUCGBbRG3BKRa2C88K+Yj+UDrItqCalcak2k+Mi0jI3TGlCciym9oppPfPxoAxp9B
         3LPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:sender:dkim-signature;
        bh=3K8ZEEArtsKiEJ5I7k4SQLYx/luEOe5+arx+qBgdSFA=;
        b=mpFuu195b9r3vuBYCKLn2FtpGQlBXKwepebdi8MzO2kzz22M/v3lqmgeCV8m/Xe+FI
         UN3nsyfi4KTqYdgde4l7YoJqCZmsbxxvVQ0McScwSaN57L3N3K7JmbpniPopirXkpmop
         gpzA0Bbo2Kc7tCB30KXOObxgWDhhQH4w+VNJgvFIBEqJdNGZyCB/FankgWpCbfMdKBrh
         uBotwf8iiqATBNf35z/V4DS/iyvf/pXjLlminZmvaqyN/2+KYRGtYvyIz1G4RlbzWCFa
         4WV67PPSk8V7PawGkUQMEX7PudDvm/STa8Cx8RNyKi5y7YamAYfEUJN9sUDEkbKFOMHO
         wqbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JSk4Hdvq;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j11sor232607pjn.7.2019.06.27.16.12.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 16:12:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JSk4Hdvq;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=3K8ZEEArtsKiEJ5I7k4SQLYx/luEOe5+arx+qBgdSFA=;
        b=JSk4HdvqruT+eRFKcMzKF4cuqUMKAFW0JmLoEPitz4V9TYrtKEJX4lFAYbPrn+53Sr
         iScOFwvbVbYQmM0y8f/WY1EJOSMQYHxuToZnJjChnKzKTZFqMoTt5HBG3WLdxnDjc38m
         a64MaJrlM59WDcPpUi603vXqz1z5jxeJIA6WVnx3wdmiGFtIrrhJJl0wbw+/zI2tItVS
         2WFm+5OmdgiY+zckFV8E0k+HtY/mr56quNTtxkI5cjogi4SpVGiwHjZQIAKP68nearBn
         gle5TBra9FVnkjUV0vdkG42M04Pu3Ydc95ZQLipUDBCMbx1qIczM3Mj5HCiYQLeXM6f9
         0MUQ==
X-Google-Smtp-Source: APXvYqxtn9cf+kC5zwOASaw1d/Oo8w/GiSK/V2r2g0NRoYK4Nj3w5dEEjSiS3BxhR2Cs1b8xLtShlA==
X-Received: by 2002:a17:90a:fa18:: with SMTP id cm24mr8869128pjb.120.1561677138694;
        Thu, 27 Jun 2019 16:12:18 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id x23sm154864pfo.112.2019.06.27.16.12.13
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 27 Jun 2019 16:12:17 -0700 (PDT)
Date: Fri, 28 Jun 2019 08:12:11 +0900
From: Minchan Kim <minchan@kernel.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 0/5] Introduce MADV_COLD and MADV_PAGEOUT
Message-ID: <20190627231211.GA33052@google.com>
References: <20190627115405.255259-1-minchan@kernel.org>
 <20190627180601.xcppuzia3gk57lq2@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190627180601.xcppuzia3gk57lq2@box>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 27, 2019 at 09:06:01PM +0300, Kirill A. Shutemov wrote:
> On Thu, Jun 27, 2019 at 08:54:00PM +0900, Minchan Kim wrote:
> > - Problem
> > 
> > Naturally, cached apps were dominant consumers of memory on the system.
> > However, they were not significant consumers of swap even though they are
> > good candidate for swap. Under investigation, swapping out only begins
> > once the low zone watermark is hit and kswapd wakes up, but the overall
> > allocation rate in the system might trip lmkd thresholds and cause a cached
> > process to be killed(we measured performance swapping out vs. zapping the
> > memory by killing a process. Unsurprisingly, zapping is 10x times faster
> > even though we use zram which is much faster than real storage) so kill
> > from lmkd will often satisfy the high zone watermark, resulting in very
> > few pages actually being moved to swap.
> 
> Maybe we should look if we do The Right Thing™ at system-wide level before
> introducing new API? How changing swappiness affects your workloads? What
> is swappiness value in your setup?

It was 100. Even, I tried 150 and 200 with simple hack of swappiness.
However, it caused too excessive swpout.

Anyway, systen-level tune is generally good but if process has hint, that
should work better and that's why advise API is.

