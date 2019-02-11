Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 478BFC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:53:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E80F021B68
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:53:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E80F021B68
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=iogearbox.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 871398E0126; Mon, 11 Feb 2019 14:53:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8215D8E0125; Mon, 11 Feb 2019 14:53:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 711AC8E0126; Mon, 11 Feb 2019 14:53:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6928E0125
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:53:41 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id f5so43401wrt.13
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:53:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=k2FZFo7KLfZViZS6bx1ThopOO/ZHFQU/rDtH/UdkK68=;
        b=fUs204Uxi2UMgknHK3jBXf1TrZUHPKiJG8NLJqnou2q3WyZM0EfBRtXEY9reP6iUqo
         8BqlPmLQyppT2buqyurk6voP84NT6jUHWfsEWR/LxW+rmE3PqvLOh+nQnR3AqK1JMAlw
         lL7dDqHnbcYPpf35BXdQg5iblklbsSktj6iFT7G+Iz6wJHBbKt6/7ywIxq85BDqqhp3r
         lPkaazjBIb3XJk9j/ABxFotEZMzCLCZ2133ee3boND42lOGCpZfRzTShFBV5zcbIg9Db
         rrHLUI/d5HdJBsUYVgbjD5soLR7DrD7eUB52uWd/jkNy7RpnXO86zWv0FSo12s35xmdS
         GNbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of daniel@iogearbox.net designates 213.133.104.62 as permitted sender) smtp.mailfrom=daniel@iogearbox.net
X-Gm-Message-State: AHQUAubtxuxwkqGLY6tz4G/blpGlOdljEdDa6NP0DhlSqRLS07L9sNET
	vK9yGahqezzKuhzOmPw7zlaN34h2rdywjOe+9rLYsbqdM9kIqwkX+J8S8dcoEqdNjWekjSH3DyV
	MQeGqlr0jmT5fc90kJstEGx4n3WKc4pq532PJ+yX3uarizM/W2S/AG3r8uIYEo07h7A==
X-Received: by 2002:a1c:7016:: with SMTP id l22mr935983wmc.70.1549914820739;
        Mon, 11 Feb 2019 11:53:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ3nCtXl+mRWhuS6KlXDRyDnEuqRjrrL9G6dd626cBbMCiY2Ydje/A16bbWxMdEwaz6zknh
X-Received: by 2002:a1c:7016:: with SMTP id l22mr935930wmc.70.1549914819875;
        Mon, 11 Feb 2019 11:53:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549914819; cv=none;
        d=google.com; s=arc-20160816;
        b=dhX6v9qKxX2h3ytjwTTAZtrKIuVkh4kZLAUBOaHaQk5NTT/IIvF4vMdRMLSy6pm6CQ
         0Z1H9uF9q38QPDaV8D9YkD5iMQrL5kCKGJ5k+j2XjzSFfFaUoHFRZuBGBkKbXgOuegmm
         X9exKdnWgFLMck3bkKAaqaircpNEaTbtC/TP4dWSHaKIGNRRjBZ+leALZ6LEnvSOcuMw
         WepW27R2j4E9zak4aU05VjnjWCSy+r9yKFuJUN946oFmaNuicoDLsDeAdLS8zbX7EhcZ
         T7S1iioHcGnmPEC+Bm7zA4HewRkj5yLMWXy6xYvr7S3dVQgvmO0faESd7D0anLyBkmKf
         Y/Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=k2FZFo7KLfZViZS6bx1ThopOO/ZHFQU/rDtH/UdkK68=;
        b=zXAyHS08WBgkBw6XHDgLJRmCed3luxTFBBN87ZEwjLOgwMpEWNINJvMcCngoB3aM+s
         5RBCtgY0foKWo9qQIQqOrxYpWnsbR6j93u0V6X8nuF82QR2B/8iucXQ32KYqf6CnIpAM
         6NXLdE6h+/A49wVsr3GEBAtoqpuew/H1PuxakCCMqO9p+57jf3hdX1YG6jxzSqlPvLsM
         1s4gJ09/EQTx0qG6I3YL5KzspFk2MIEWJPRltm7gVcXvNfdlDHe8Mw2u/zakQTo1rP3I
         MjVXNyBhA5ms+rJtrFkLJ29V10gL244C6unEVHv0T+k+AN9kwm5pet75Uaistmm7AfQh
         LaDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of daniel@iogearbox.net designates 213.133.104.62 as permitted sender) smtp.mailfrom=daniel@iogearbox.net
Received: from www62.your-server.de (www62.your-server.de. [213.133.104.62])
        by mx.google.com with ESMTPS id c7si7725657wrt.340.2019.02.11.11.53.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 11:53:39 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel@iogearbox.net designates 213.133.104.62 as permitted sender) client-ip=213.133.104.62;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of daniel@iogearbox.net designates 213.133.104.62 as permitted sender) smtp.mailfrom=daniel@iogearbox.net
Received: from [78.46.172.3] (helo=sslproxy06.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.89_1)
	(envelope-from <daniel@iogearbox.net>)
	id 1gtHe5-0001mx-V5; Mon, 11 Feb 2019 20:53:38 +0100
Received: from [178.197.249.40] (helo=linux.home)
	by sslproxy06.your-server.de with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.89)
	(envelope-from <daniel@iogearbox.net>)
	id 1gtHe5-000VgN-PE; Mon, 11 Feb 2019 20:53:37 +0100
Subject: Re: [PATCH v2] xsk: share the mmap_sem for page pinning
To: akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
 Bjorn Topel <bjorn.topel@intel.com>,
 Magnus Karlsson <magnus.karlsson@intel.com>, netdev@vger.kernel.org,
 Davidlohr Bueso <dbueso@suse.de>
References: <20190207053740.26915-1-dave@stgolabs.net>
 <20190207053740.26915-2-dave@stgolabs.net>
 <20190211161529.uskq5ca7y3j5522i@linux-r8p5>
From: Daniel Borkmann <daniel@iogearbox.net>
Message-ID: <ec544ae4-4671-de96-69c2-2f438f048a83@iogearbox.net>
Date: Mon, 11 Feb 2019 20:53:37 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.3.0
MIME-Version: 1.0
In-Reply-To: <20190211161529.uskq5ca7y3j5522i@linux-r8p5>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Authenticated-Sender: daniel@iogearbox.net
X-Virus-Scanned: Clear (ClamAV 0.100.2/25357/Mon Feb 11 11:38:50 2019)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/11/2019 05:15 PM, Davidlohr Bueso wrote:
> Holding mmap_sem exclusively for a gup() is an overkill.
> Lets share the lock and replace the gup call for gup_longterm(),
> as it is better suited for the lifetime of the pinning.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Bjorn Topel <bjorn.topel@intel.com>
> Cc: Magnus Karlsson <magnus.karlsson@intel.com>
> CC: netdev@vger.kernel.org
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>

Applied, thanks!

