Return-Path: <SRS0=FJsX=XK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CC06C4CEC7
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 21:38:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23740214DE
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 21:38:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="apS9vQuM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23740214DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 895CF6B0008; Sun, 15 Sep 2019 17:38:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 849A46B000A; Sun, 15 Sep 2019 17:38:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64B586B000C; Sun, 15 Sep 2019 17:38:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0086.hostedemail.com [216.40.44.86])
	by kanga.kvack.org (Postfix) with ESMTP id 46ECD6B0008
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 17:38:36 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E92A8824CA3F
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 21:38:35 +0000 (UTC)
X-FDA: 75938469390.15.chair28_4b073747fc720
X-HE-Tag: chair28_4b073747fc720
X-Filterd-Recvd-Size: 3432
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 21:38:35 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id q12so1262827pff.9
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 14:38:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=Zo435XJyX1bpVOOHXwPV4uWYj4585Ad4T3dwyk9iQBE=;
        b=apS9vQuM+nyi+pTFjOA6vggWXSkRtfqgt6CtOE6zLQt0J4MDkpvxLGenxAaNvfGCBu
         40ISP0O70fCIZQd+Ekho/Ctny3LuLMnHQk1F/KPPApOGMpftC3/zbljQqQw21/zMfn56
         SlfcgTljTciiJ1OG1AOBB6p5rxIIceF8KrtuxdwmDed3zdz/gtiF21dptyjepYcKGB6C
         upoEAKrNO9dVvyNdGorxD9grkpDQvF4mdz+2xyL5MY+hnX9JIQIM8z4QqUqfmLX9CO9I
         uEqp5ZbacaWHFbSpzC2BNbBiTxOfiqeDiCLHuePEedSD6Vjbqkr3CdqDAQ+XZZDk7kTG
         rKqQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=Zo435XJyX1bpVOOHXwPV4uWYj4585Ad4T3dwyk9iQBE=;
        b=fdaGe/RclRHQ90GwZjneP9JeTX/ze/d2r+6hkYJNqGSI+xCgZblAQQOUq9D/Pd4KDC
         m6iXfBXHcp8dG0L+r/zjoI+UqLt46nKQDjMr9if9/inma0rbGICxmuhjZx65qmRkdafu
         OTylr7R65CZN7wobZB7OvtKKCaI+1ydv16rW8fwnk1vs4ljhPs4+lCUSuP70picIU1Rd
         EYdClBDKJsLBXBjxjrf71LNhC3sys2zvCOJ89HYF2UULzWcY/9P5gW4GwR/1JxeQ/Kio
         xxPG/uIDi9jd7uHQS09aDd8TZcihRDc8vB6a/K3/xTf7TRb072GienQIXoL8pnEakPzJ
         QDcA==
X-Gm-Message-State: APjAAAUFdqhb6ZuHevJZcxUy19lefQsRjgcZe3mXmTAvlAsX+F8Iu/R8
	4IO3AIKTSqrOapKmNMWA502dHA==
X-Google-Smtp-Source: APXvYqw1ARgEFVmt+QDLxtWvIcZOKj0fu7MaTaZ1QI/bvgVgbu2fbkvM8XEGc6raOZ0YXRFCLVWvbg==
X-Received: by 2002:a62:2f85:: with SMTP id v127mr65402991pfv.68.1568583514459;
        Sun, 15 Sep 2019 14:38:34 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id r13sm12826494pgp.63.2019.09.15.14.38.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 14:38:33 -0700 (PDT)
Date: Sun, 15 Sep 2019 14:38:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Pengfei Li <lpf.vector@gmail.com>
cc: akpm@linux-foundation.org, vbabka@suse.cz, cl@linux.com, 
    penberg@kernel.org, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, guro@fb.com
Subject: Re: [RESEND v4 4/7] mm, slab: Return ZERO_SIZE_ALLOC for zero sized
 kmalloc requests
In-Reply-To: <20190915170809.10702-5-lpf.vector@gmail.com>
Message-ID: <alpine.DEB.2.21.1909151423290.211705@chino.kir.corp.google.com>
References: <20190915170809.10702-1-lpf.vector@gmail.com> <20190915170809.10702-5-lpf.vector@gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000778, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Sep 2019, Pengfei Li wrote:

> This is a preparation patch, just replace 0 with ZERO_SIZE_ALLOC
> as the return value of zero sized requests.
> 
> Signed-off-by: Pengfei Li <lpf.vector@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

