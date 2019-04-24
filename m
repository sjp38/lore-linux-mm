Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E84A5C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 16:28:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A469C218B0
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 16:28:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="bF9FyrEw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A469C218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E8B86B0005; Wed, 24 Apr 2019 12:28:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3974A6B0006; Wed, 24 Apr 2019 12:28:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25F7A6B0007; Wed, 24 Apr 2019 12:28:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0704A6B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 12:28:15 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id t67so11058514qkd.15
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 09:28:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=YW5yk4iqJIXJrcqAFRbBRT9RX/ir7l/OVfuDBnw+neg=;
        b=DTIlEDgv32Y1b55rdhQ9JNjBTY/WZ95To9j3O9pLJjJJjqHzDxEh6HBq8veYx7rQYI
         OOCczSLqyg4c/UCwyIf8BlZiYvA46htFWg0RXoV1cXTubbF8BVpYUr3vHtWQncug8Jba
         tTNnMPkX3ZouyJfzwgLUULG9szW5VDzglCxfjVZjIzldYAIMxoppICNYJmTYNv3OT87r
         lgmfpbqLc50r3X2aT7Em8F7+ozdhtKxiH5I+n7LMRJZc29pnrZvMP+mLn+i+RfCcuDQ0
         LsjW8ZvH00pcem1z5u+DrOEZcqHhsqw8utYRR7qUJU5Cd7L7y+w9EvH2+RmRYgq3fSzl
         Awcg==
X-Gm-Message-State: APjAAAUh8DbOmg4/oTgN4mxIzc5bNIyIXuSBtE0vkKr8t68bt0v/4u2l
	dqR23NiaMJpeHqI3zF7aXm/HGQFZVp7a0hOa7A36H1jrjvF8QnXZvm5zvTUKKUmS6Z2eYaKo0N/
	3GoK4RQIu5k+nKBebASMWBCacw8aqMglki6zGfM4wRVp3/z8p0c45+NTZDXE4pvI=
X-Received: by 2002:ac8:1187:: with SMTP id d7mr20320989qtj.28.1556123294711;
        Wed, 24 Apr 2019 09:28:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCo6UHti66AFwdtqNi1/ULqdmvsckU+Del63T2BUmAyChT6AJRU1K+zf5hNVXWnfXv+Pmh
X-Received: by 2002:ac8:1187:: with SMTP id d7mr20320932qtj.28.1556123294100;
        Wed, 24 Apr 2019 09:28:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556123294; cv=none;
        d=google.com; s=arc-20160816;
        b=aybGKRructpBaJZFzk+o5NLS+e9AVRNLogve4L7/Nl3y+AdzsDieCJsG0zeWp9xwOR
         +99gU7Btwua0VlzIa6pyvSygoOoDi2wSnv9CeoIDI/fzjG/tCpje2y07LaP/iRo+7w1e
         l1Df5dv2eIAHPru7hNF9sSFxhR2MKHrDLm6qpImyuqsqzNinALL/vDJ91S3ybixLl/l7
         /l9JZhxx44HbBM2jzZt8pEJSVZXAEDyenbI0DTtLelZFrDIb6CkhwTynjyS9mF6hGosv
         9zAWz4lrPHbVyi8arZ/fficIMVVHLtvgqdaE8YlD5z29igy5kIiQDMY2ygE4kyYoZ5l1
         CBGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=YW5yk4iqJIXJrcqAFRbBRT9RX/ir7l/OVfuDBnw+neg=;
        b=KB07rTO/WoIpCGuQoCFJpJcJ01AWkcUu5eme+sIGQGvEEQO6/383lDacf6i1c+4+pC
         gEaguxh8S2ZydppGNu20A9ZIzUmGdlEdt31bGxbyVMxXCArHWM+Sce2wVziue7ZJXVJO
         lSoj2dTovRLuZHZPg12fYTYUXT2Z1bwLupJOKIKWlfOkN684yAXObaoMk0bcnELhmND3
         XWjfeaw/RidOJrFP8C6c437imKD0JELju+CgflGHcLRJ9xqcw0aNs5p4jc+9BfA+KK1I
         ck5yHqtnMzVq3RXL9Sx1P+EMOJyDb6VvHXPMxKznCv3zqnH7cN9H3cQ9NG1igeXpThgT
         XknQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=bF9FyrEw;
       spf=pass (google.com: domain of 0100016a502d17bc-8b2811c6-0291-44c0-8505-5eba8d32c504-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=0100016a502d17bc-8b2811c6-0291-44c0-8505-5eba8d32c504-000000@amazonses.com
Received: from a9-36.smtp-out.amazonses.com (a9-36.smtp-out.amazonses.com. [54.240.9.36])
        by mx.google.com with ESMTPS id u17si1672459qvi.206.2019.04.24.09.28.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 24 Apr 2019 09:28:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016a502d17bc-8b2811c6-0291-44c0-8505-5eba8d32c504-000000@amazonses.com designates 54.240.9.36 as permitted sender) client-ip=54.240.9.36;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=bF9FyrEw;
       spf=pass (google.com: domain of 0100016a502d17bc-8b2811c6-0291-44c0-8505-5eba8d32c504-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=0100016a502d17bc-8b2811c6-0291-44c0-8505-5eba8d32c504-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1556123293;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=YW5yk4iqJIXJrcqAFRbBRT9RX/ir7l/OVfuDBnw+neg=;
	b=bF9FyrEwOhQNzholR5NyuI56Z1TsOamsXnTxBgSa7420fSUjfdX61afD7ffAv7l4
	WxVMBoMKUKV535+EqTCN5yyaK1TeodtCuX723L/Ihjb9Romn6CcVh0nbRXUVOfe5W0K
	KKrajDnI8LwGkpLcgl1+i6SfTEaJxAj1sSpBajYw=
Date: Wed, 24 Apr 2019 16:28:13 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Johannes Weiner <hannes@cmpxchg.org>
cc: Shakeel Butt <shakeelb@google.com>, lsf-pc@lists.linux-foundation.org, 
    Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, 
    Rik van Riel <riel@surriel.com>, Roman Gushchin <guro@fb.com>
Subject: Re: [LSF/MM TOPIC] Proactive Memory Reclaim
In-Reply-To: <20190423173128.GA3601@cmpxchg.org>
Message-ID: <0100016a502d17bc-8b2811c6-0291-44c0-8505-5eba8d32c504-000000@email.amazonses.com>
References: <CALvZod4V+56pZbPkFDYO3+60Xr0_ZjiSgrfJKs_=Bd4AjdvFzA@mail.gmail.com> <20190423173128.GA3601@cmpxchg.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.24-54.240.9.36
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Could we retitle this "Improve background reclaim"?

This is a basic function of the VM that we seek to improve. It is already
proactive by predicting reclaim based on the LRU. We have tried to improve
that a couple of times over the years. This is bringing new ideas to the
table but its not something entirely new.



