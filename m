Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A82CC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 09:45:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC40C21473
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 09:45:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YFwBKChN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC40C21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E42C6B0008; Tue,  9 Apr 2019 05:45:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 494CE6B000C; Tue,  9 Apr 2019 05:45:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D0996B000D; Tue,  9 Apr 2019 05:45:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25F626B0008
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 05:45:57 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id x8so6279537ybp.14
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 02:45:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=R/XsV/8Ukf+RUb49ThZY9ILm7j6ClSjMvZz7QocK+HA=;
        b=BN2YaHiHr+LXg78tZExCaXyYn0O1khByikjMxnlQtJjmgTsU2q2WUe005ozEM3a24R
         e+G6pQECpVakOaZy6OCj7i237ouvjwxs9dOh6ZbQbu8TpQ0PlIQUROzuQXmqaTnEnif8
         xk2bv4LJ+MCGFKOy3Nu5srfbfUE12W9NWeziov7Q19skiC5KEHp8rrcZARobtNHCSfuE
         1MaG2C8Lf3qWYahenzy1zKZhWZv6K8rtFSXjaB9xfGauZmBbYmSHK8Vpcgrf8WIfgIkr
         Ir/OcT0HXuyn61u+Gl806DfS2Mu+r9t7YyyWB1EbSdyDNMVmBnenoCRwHSNxTE9GzI2D
         dqKA==
X-Gm-Message-State: APjAAAWWmLKbctgOmSzspUhRyJB/GVulBXUA0clGiEJbkhI7L/bnhhiX
	/XH/lou4VFLUpwpnGFwwR0Nz95l5f4c+6Ub/MwTy+BXLOQbagzYtJn267nLO5o47VflbKK01/IT
	yBYKAE/soKx4zVPhSYt3Ay5zJZBTrEBl4Fw1wx8l8Ik/HrhFRscLH89p/JGiTZk7C9g==
X-Received: by 2002:a25:690b:: with SMTP id e11mr1894016ybc.19.1554803156890;
        Tue, 09 Apr 2019 02:45:56 -0700 (PDT)
X-Received: by 2002:a25:690b:: with SMTP id e11mr1893995ybc.19.1554803156349;
        Tue, 09 Apr 2019 02:45:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554803156; cv=none;
        d=google.com; s=arc-20160816;
        b=FWvBCzKGXFdhzeP3oPskX2geI4PPM0qSRHXSlDEJc5WkC7n1NlIS3RxmysoK1+dv3Y
         2znpCfrTMQAyQMjGRRJfav6zW8HUB/FUovTjZybSWdFbCWxhuVZc0L3LQkJRTrnNDITt
         gQBAdbYxwlDLajo2aFbX+gpjMVWbSgJdkNvshsRX6I+ld7HCPpUICYNlr2xJRFmtDucI
         Vs4YLweg7ay+AJSVjlIFKvUKSnVKH74kND8rKg9O+xQ5IZ+7h5vC5uCc/miQzFd0F6Or
         RVhnB+udxXVPBsgu8kvpGAMA/IhDiQ73jk8SxLAVgKP3b2NuVoa6dvHq+gPSbTWtmAWh
         p8Vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=R/XsV/8Ukf+RUb49ThZY9ILm7j6ClSjMvZz7QocK+HA=;
        b=JUxvLGvuap3Y1QogKsj4eH8pjFmrDufLoAHKOIOdsMvhuk8XZ8AmIlaieLrfdLfHX3
         UFAJR5ZfNGjxrHlgCEb559pa0USjew/l5QVaNvqZOoAiGbvVGY8+08XursY4HBT8bVJ2
         V3resHtWt9wV0N5V6TH3TsM5JUHLgGlV8PXHkrpVVzngC7txnHnmqVUtFB+84jNk6ANP
         agQPOmI0dC7B07zTlPmL9isP1RrlHAsRN4NKBjzrjUBQDnlcu0M0FUtYFrJnOuUck/jj
         Mkshd0X6NOuBTBlRgCUGbth15pELSW90LKW8QYO4ecmFM7gOFA4JGYwCUffUdkYsuvL3
         JUJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YFwBKChN;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s65sor11205673yws.39.2019.04.09.02.45.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Apr 2019 02:45:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YFwBKChN;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=R/XsV/8Ukf+RUb49ThZY9ILm7j6ClSjMvZz7QocK+HA=;
        b=YFwBKChNbe2wytzY/L8eWK4QM5OTjdY+L4TgcIt1zqs62ELypAhX0hrGMYQL7rTIhv
         APlq1ddNN60yokmEYfGZ2qpyRY0pUSJJTzK7hnpojESQcDJfyDJWOvCM/Tey2NUFFfh2
         DcM6XMhF+ERgV1CixQfLDY+5Xg39IksSeAZuxJVLG/DrhCoBurdhUF6t9SbopOa1l/iO
         KwweQEoDHT9hRuoLUOheexXmyHdIzG/7HZJhPElSJzCWaSb6XcnL5Y2lVRY3Ol5G8YDA
         vV4Yk/Qese19NNqyAi8/PN5bVvssulEL3PdPxJ8AR6NlV6mPyaoZUmC+cqFOYnU5LPvx
         p/mA==
X-Google-Smtp-Source: APXvYqyYiaKcnKgqhX+qkMz4o1eVUn7fFoT5hup3soRtdbX+cnIwOC5hTX3zXmfMPpAWheWNjA58ueRCLXSP5kW7aKk=
X-Received: by 2002:a81:4fd5:: with SMTP id d204mr27576554ywb.186.1554803155937;
 Tue, 09 Apr 2019 02:45:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190406183508.25273-1-urezki@gmail.com> <20190406183508.25273-2-urezki@gmail.com>
 <20190408231905.GA31139@tower.DHCP.thefacebook.com>
In-Reply-To: <20190408231905.GA31139@tower.DHCP.thefacebook.com>
From: Uladzislau Rezki <urezki@gmail.com>
Date: Tue, 9 Apr 2019 11:45:45 +0200
Message-ID: <CA+KHdyVRL7hWw8mLvpHj46NCnZ_Cttkw1+ycjR-XP=ohEAnJuQ@mail.gmail.com>
Subject: Re: [PATCH v4 1/3] mm/vmap: keep track of free blocks for vmap allocation
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Matthew Wilcox <willy@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>, 
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, 
	Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, 
	Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Roman.

>
> Reviewed-by: Roman Gushchin <guro@fb.com>
>
> Thanks!
I appreciate your effort in reviewing to make it better.

Thank you!

-- 
Uladzislau Rezki

