Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD7DCC04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 14:28:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88D5320862
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 14:28:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88D5320862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A56C6B0005; Wed, 15 May 2019 10:28:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02E586B0006; Wed, 15 May 2019 10:28:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEA816B0007; Wed, 15 May 2019 10:28:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id B966B6B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 10:28:34 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id a64so2420509qkf.8
        for <linux-mm@kvack.org>; Wed, 15 May 2019 07:28:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Hzs6yrUCFcHOdFexksEy5jtAZllxhwQ36OKZUIdddQU=;
        b=lxPZU4Bwlw+t9c7tC6aHPB8+++IAgPYixkn97L9gs2/tGod6EhjEySBTmknc7+kqB6
         gD0pFLof/JbRBUFhyAVEuMh7vqdF3sGezhQWN/lgX4qZxiHLENBB4W9X6r2gUyNOMmko
         BIikqOfLaiixuMQ213Or//r2UETtJ96hY3JIXXDX8PtK1ZGJxyX10/R9aByV5ql+brPu
         xLX4YkvFxSJ2tQkNsuH2fOM5GGtRxZAO0RyPF2Du4nAG0HmetYCKsl3cOKpvG43pmp6l
         nlwCoXdfR6QOHk3p91sQGCRuR4R08BnS6RMbREYdr9Ay1bS2R6doUzcXA9QGOVqSFiIY
         e4fA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWki1JU2x0COSblxQrZpmRZIzHI5sMrDoSzPGpeFjdkL7puubYB
	G+PEsbHnJSgpiZhU9TyU0lR2TB/Di/EBrnxewTlawJ0bVKiv9ROkmDNXQfgmLqL+AUagf7s18y+
	BUCKkmEoJpl0rkYpLPSL3AfEvKbQSnU7eaD846f5qhOgXfIBpa/ZiaZvctksl6gtuQg==
X-Received: by 2002:a0c:bb96:: with SMTP id i22mr34815373qvg.129.1557930514567;
        Wed, 15 May 2019 07:28:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvKzwX1IfrIHsa9l0Bbx67irnX9U7BOsr0aZNEMcs0CWbFyveeq+b/z7svOG8hqqIdYt/o
X-Received: by 2002:a0c:bb96:: with SMTP id i22mr34815320qvg.129.1557930513829;
        Wed, 15 May 2019 07:28:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557930513; cv=none;
        d=google.com; s=arc-20160816;
        b=aRZ2uZpJLuDbNVXjuN9q6nnqi5ybWeS23+naW9b/oLTDdBJGCLwWojSLwKNthjUKfJ
         h+ekEULr3YNGnGvPA084M3UuCLauCRizGHXZ9KxRW4gfnCrsOaP9B85LtjkA1+90V7wn
         2Rks57cMx6iBRk3zolHZXl057FLjzUCp0+0IUbfbE8j3EqkToV4ujW1gI9CToVWdjNGF
         rP63nSMSb/M0F/ZbOUQ+TWoTb+9KdsSfrvz90+5jTqoR0jPfvS3AJm1cky1u9oJXHRwo
         XVypbwFp6KGokXRuNquRVSQy677ZIWJhAyK3hIcZGZ/fZh9ODbAFtntOcOhJtIRjchcT
         9J0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Hzs6yrUCFcHOdFexksEy5jtAZllxhwQ36OKZUIdddQU=;
        b=O4RCGlxI41AOALkdlVHo1c5LIfroBm4oBKHgmgXPG/bHR3JUXBha6mURIzC3P2ElOh
         bwPoGfoBmbr+Lav7BhsMoSr0jW7vC1t8S6kcyRjyr2IRXZ9E4T23tRsrhyH4HM0R2prc
         4gDsBqvj96EeIDwZnBfUc8DRkYokjWUU4zsk47TmeLzzYK96qIO8bOU/ayHpTHuMSIJx
         rW3TgLSzCDWy+7OMIaWJyM7lxylO76rjFdA8hY3csO/KB1B/WVhTV6V3H2pMZmon/uT9
         F+/5C7fufNr0rAA7PsL3E0Situr4ULAQuLFttj1x5muhcA1a4fuDlr5Iam+3P5cSTQ+w
         yyAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t6si197575qkm.207.2019.05.15.07.28.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 07:28:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 139C88553A;
	Wed, 15 May 2019 14:28:33 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.159])
	by smtp.corp.redhat.com (Postfix) with SMTP id 147181001DD7;
	Wed, 15 May 2019 14:28:31 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Wed, 15 May 2019 16:28:30 +0200 (CEST)
Date: Wed, 15 May 2019 16:28:28 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: use down_read_killable for locking mmap_sem in
 access_remote_vm
Message-ID: <20190515142828.GA18892@redhat.com>
References: <155790847881.2798.7160461383704600177.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155790847881.2798.7160461383704600177.stgit@buzz>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Wed, 15 May 2019 14:28:33 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> @@ -4348,7 +4348,9 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
>  	void *old_buf = buf;
>  	int write = gup_flags & FOLL_WRITE;
>  
> -	down_read(&mm->mmap_sem);
> +	if (down_read_killable(&mm->mmap_sem))
> +		return 0;
> +

I too think that "return 0" looks a bit strange even if correct, to me
"return -EINTR" would look better.

But I won't insist, this is cosmetic.

Acked-by: Oleg Nesterov <oleg@redhat.com>

