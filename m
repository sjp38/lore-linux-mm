Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1E4CC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 19:00:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6640E217F5
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 19:00:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6640E217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 071338E0002; Fri, 15 Feb 2019 14:00:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F39E08E0001; Fri, 15 Feb 2019 14:00:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E02BA8E0002; Fri, 15 Feb 2019 14:00:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA3D8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:00:34 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id e5so7388021pgc.16
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 11:00:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rO5Gi17MchYKRoQ9JMkM2o6Ac/1ZRye6Gk/QCMk6MwI=;
        b=Eepk7rIkAqvA2F628s7Z250b+X7UoBjaKPRf5ZOoBoO+5g1BIvmZZ0E9njwqx+YDfY
         0qrEWo68msxsoC/OamwVmK19D0yf+lLXEOvVsuVv0aV6fDHkyVOqvMyUtgHM3RDX/TTQ
         WKKcv9Rk7rsxDtXjKxIfaDsQJJySIgcEgp7f0GMUmetxjAI4EdooV8GiyrPle0iU+OrE
         Du9f2zRfCsMkDLruXDanwhsmk/ReTUR3YVnKP+ndCNVAMJ6yG3mhufcYSELrrW8JYb3P
         dP5TdP/fXP02oFcVdgNxbv6bx/rumNYb9/P5Llqw2IfweMSzSW5LUBBcli5fF4kV+Y3Z
         5FVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAua2FqBbkKKFTQ+Gu31W7ei/5hlmXuYfGLH4nWD3PUrhLy5mSOMQ
	vLB6G9XOX9j6BtQL98viS414gOEyQqsbucw0USFLX5vvPI+lDHKuUrR4dF/f0AxNgwv3a41qpJV
	oEUOK5ZwUWyGhj9627IknG0yXiCl33nbG/fThxli0NdIecnp0G6IwZglyeL99l428mQ==
X-Received: by 2002:a63:1d1d:: with SMTP id d29mr6806411pgd.49.1550257234281;
        Fri, 15 Feb 2019 11:00:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia3I8NCgwvhm5X3eiVhCqXIhU2pIa1Zo05hpRqfaoTEXapqWNwk2JZMKHpngIENxQdkc2lI
X-Received: by 2002:a63:1d1d:: with SMTP id d29mr6806358pgd.49.1550257233554;
        Fri, 15 Feb 2019 11:00:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550257233; cv=none;
        d=google.com; s=arc-20160816;
        b=Oz5q2g5rd4nufudL7tD9+QfP7otqOSRGq7UqqF03+7WrUKMw7ErgTk9ybRTqyBMRS4
         V/Gy/ypFaBVpMCzrkDRVEbbnJoEukPoD8UaKT7hWPuyRyCTRNFvqY/dZX9aDR1pPY+Py
         s7Jsq5N4xFOOuY0hGWFFe/tHpPJ5G8JLLLTZaWG8622nkpJDookJT+RUUvo7gPpezALd
         tLfHt/F/H0AGBkp4PVKn7n3Co/fFaBgOlo1oLgJX5o43qXuEr0HdwFJgibXJTpsyzAq0
         QS5CRof8hEOPbskFzGds3t8KXm/0w4sd/UZvmMTt8IqrywGfSKEg75+p52Y046WD8n8N
         eOzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=rO5Gi17MchYKRoQ9JMkM2o6Ac/1ZRye6Gk/QCMk6MwI=;
        b=tIKSzHKWvY4/TB3cVkxoU0yrIEVbBlTfOJUc3EPycTfvcZujkPZgvdFbrzGVoTCfzm
         9WYaiw+Io7s4U+wfzfjQXQgLovc7oWtE2k9q6vVke48xL9QZeEfFHxP18ZzrB5x4CTS4
         uCfNce/VLzeYS9ivJtgtrin3prNnrWicGXCRva2h1Nh4ELK8Gkkgy2SgoJMaXfW4vFkb
         pB0Yk4UCGHQV8FyTRdGK5vs6xVUOFUFvCouuyed+YFWo91AYVVBTF5s7KKw2nrggPY32
         4wHzPsKRcudobaOEs/9inBtxNhqA6zqrwjoQWHV0+duiZhNdxdqYxjttARShvbIScste
         Enjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b5si5962563pgl.254.2019.02.15.11.00.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 11:00:33 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id A0BF8C84;
	Fri, 15 Feb 2019 19:00:32 +0000 (UTC)
Date: Fri, 15 Feb 2019 11:00:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Mark Brown <broonie@kernel.org>
Cc: "kernelci.org bot" <bot@kernelci.org>, tomeu.vizoso@collabora.com,
 guillaume.tucker@collabora.com, Dan Williams <dan.j.williams@intel.com>,
 matthew.hart@linaro.org, Stephen Rothwell <sfr@canb.auug.org.au>,
 khilman@baylibre.com, enric.balletbo@collabora.com, Nicholas Piggin
 <npiggin@gmail.com>, Dominik Brodowski <linux@dominikbrodowski.net>,
 Masahiro Yamada <yamada.masahiro@socionext.com>, Kees Cook
 <keescook@chromium.org>, Adrian Reber <adrian@lisas.de>,
 linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
 linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
 Michal Hocko <mhocko@suse.com>, Richard Guy Briggs <rgb@redhat.com>,
 "Peter Zijlstra (Intel)" <peterz@infradead.org>, Stephen Rothwell
 <sfr@canb.auug.org.au>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
Message-Id: <20190215110024.011197d86e3ab8642a9bbecf@linux-foundation.org>
In-Reply-To: <20190215185151.GG7897@sirena.org.uk>
References: <5c6702da.1c69fb81.12a14.4ece@mx.google.com>
	<20190215104325.039dbbd9c3bfb35b95f9247b@linux-foundation.org>
	<20190215185151.GG7897@sirena.org.uk>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Feb 2019 18:51:51 +0000 Mark Brown <broonie@kernel.org> wrote:

> On Fri, Feb 15, 2019 at 10:43:25AM -0800, Andrew Morton wrote:
> > On Fri, 15 Feb 2019 10:20:10 -0800 (PST) "kernelci.org bot" <bot@kernelci.org> wrote:
> 
> > >   Details:    https://kernelci.org/boot/id/5c666ea959b514b017fe6017
> > >   Plain log:  https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.txt
> > >   HTML log:   https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.html
> 
> > Thanks.
> 
> > But what actually went wrong?  Kernel doesn't boot?
> 
> The linked logs show the kernel dying early in boot before the console
> comes up so yeah.  There should be kernel output at the bottom of the
> logs.

OK, thanks.

Well, we have a result.  Stephen, can we please drop
mm-shuffle-default-enable-all-shuffling.patch for now?

