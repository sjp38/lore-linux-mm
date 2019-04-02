Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C123C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 10:16:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63BA92082C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 10:16:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63BA92082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1F236B0279; Tue,  2 Apr 2019 06:16:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA87E6B027A; Tue,  2 Apr 2019 06:16:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B978A6B027B; Tue,  2 Apr 2019 06:16:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7F81D6B0279
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 06:16:16 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p88so5629867edd.17
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 03:16:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=K59ac77Cn2ebhel60fTdWNb2ZGVEdI+O62seUFEyKfc=;
        b=RABS1Z8FRK9f87jZ3ma2yB/GBOcPz0+Xa4VvTxkTDhUFiN5kS86zEwmXOJFu2koy9b
         XFJfjxEmuQbN/pFh8IP2YSKYCDqv4s7CEUYUMQTfPPAzSTjsF/wKU2aOS/nwaFDI+qEE
         HFfHdhWS1Pn93PYomkg6GFMA2FJUl7byWMLqC+5eFDz6dhIy2P+jF0DLH3hJj25MqmTg
         1p1Gcd+JMoWr3g8sKo0lDMkC+1caEqizGLq2/NJxxyXuQ9XZTgxHfqvZXD+pDPtmNf9G
         0reSHqYjUPO1kN0myRZmAVZN79sAJ+qkCXCXM4Xp0ZbWx35nCWR29n0Wo7AtmCgW1OB7
         nlgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAU7SY3iJop0cGjT7jMExHUW0S0nb9yWfeBrQ07gSidvq+sC3N63
	0vawN3Jj2t3S2L6ndQ8ppssZw02p2kvYDIQAjrfgonY7Z04qtTC8VbWAw19RHO0NIPt+wZE6W2S
	rBfFhOSYqULcj72Zm4wozsOOUATWgX7zZTxZFIunhT2L2uD49Xzt9d5s//++lCQ1hnw==
X-Received: by 2002:a17:906:5a57:: with SMTP id l23mr40035597ejs.34.1554200175969;
        Tue, 02 Apr 2019 03:16:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSCwfTuh4nlTOMOpheV7mwBElUx/iyd4ZU82etcABoGgo54spWl8oqH83D+YijVKFPV1XN
X-Received: by 2002:a17:906:5a57:: with SMTP id l23mr40035539ejs.34.1554200174761;
        Tue, 02 Apr 2019 03:16:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554200174; cv=none;
        d=google.com; s=arc-20160816;
        b=ws7xrhSvAu7Y+hPwkEccXJa27DOI2q5kK0c5wAivwkqKOtd/j9sJ81f22XwR0fl70d
         QJ+tA3fcUnsKxQ3vibeja3Eu79Nc5hDIHTIMltrDh2bcB6cSVIHIld4aEjqA4jACTIbX
         Lbt/pCR2yprCdE+lln2Hnb8gHEIxzfVUmyxj4GggfTReLRXbI43HuTD1ZpeH3UZYm9E7
         vkVtREtRQV6dMkMy4kkStEouIgbynGS7VE5wvNd0M4djkFP7foilLcOw9a8AmemNrLVD
         knCeR/L332VjwO8l3mPE+gbOLUVm9eLhNF2GswvzS/Sf1bxuuS66u/1z7sXOrnPrE/yy
         9YRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=K59ac77Cn2ebhel60fTdWNb2ZGVEdI+O62seUFEyKfc=;
        b=rF0583E/U0duuGyou/YLz2Nq81nxgZNDD14uY9AaM0YdPmlyvU9cU94K7ht/OLQmv2
         QtaoiJs3EFdY3SoG827pOkShZiJ4yEugQdniOsuYWDLj43vyHYYxX09P6Y0C4+rZ0+Qh
         Rzip4xw1bBenrOxjVZ+/BIPRSP2KMf6VgiBM6Z5Q1k9AsyEQfvvVHA0/NZH+80KPq16f
         iqVRGeBeFoTR9xkhg7nY19JPw8zxqUN0O0j5um7cxTqnslKa4QIEQddtmZpudnOo+R1l
         qoShQCVpXbe1XqhBSLQ9yt8CvCcLzv6tF5K1KrVzYed3kVDUP7pPWnmY0Kvdr5oCG5cN
         Iwhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j3si4542613eja.2.2019.04.02.03.16.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 03:16:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A291FAC4A;
	Tue,  2 Apr 2019 10:16:13 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 7179D1E42C7; Tue,  2 Apr 2019 12:16:13 +0200 (CEST)
Date: Tue, 2 Apr 2019 12:16:13 +0200
From: Jan Kara <jack@suse.cz>
To: bugzilla-daemon@bugzilla.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [Bug 203107] New: Bad page map in process during boot
Message-ID: <20190402101613.GF12133@quack2.suse.cz>
References: <bug-203107-13602@https.bugzilla.kernel.org/>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bug-203107-13602@https.bugzilla.kernel.org/>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Switching to email...

On Fri 29-03-19 20:46:22, bugzilla-daemon@bugzilla.kernel.org wrote:
> https://bugzilla.kernel.org/show_bug.cgi?id=203107
> 
>             Bug ID: 203107
>            Summary: Bad page map in process during boot
>            Product: File System
>            Version: 2.5
>     Kernel Version: 5.0.5
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: ext4
>           Assignee: fs_ext4@kernel-bugs.osdl.org
>           Reporter: echto1@gmail.com
>         Regression: No
> 
> Error occurs randomly at boot after upgrading kernel from 5.0.0 to 5.0.4.
> 
> https://justpaste.it/387uf

I don't think this is an ext4 error. Sure this is an error in file mapping
of libblkid.so.1.1.0 (which is handled by ext4) but the filesystem has very
little to say wrt how or which PTEs are installed. And the problem is that
invalid PTE (dead000000000100) is present in page tables. So this looks
more like a problem in MM itself. Adding MM guys to CC.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

