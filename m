Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CC36C74A4B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 07:54:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30D2E208E4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 07:54:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="S1s804xx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30D2E208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FCB28E00AA; Thu, 11 Jul 2019 03:54:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 886658E0032; Thu, 11 Jul 2019 03:54:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 727428E00AA; Thu, 11 Jul 2019 03:54:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4588E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 03:54:44 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id a11so817874vso.9
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 00:54:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=/raghnzRvb/GTCn5s+eX/MH0OP3DJ+YurwG6MlEbgYs=;
        b=X0b41DxVVuwwMa6fj4E/SUCudiRiE9HLWhAjH2CRr1URfMCX3dBNMwy+XZFrQU2eMd
         9DJOP/GfSrIfKcHVKyZxe6XDDhoqElP1gaQCL4gV13BUlqOQsBwEVbyDcpuBRz1gty5+
         G+I3pPtSvyljKj3jrnB3mWHiP6bm1qfBncMzH/K3IJVlNzxlnavnpfyQ/e+CSEl0PHr5
         F3SEiv0b0NJrPNANGoUY6ekIUmpncaPt44XEACXxg19VLPZSEbUwp725o6nmlmS0prNk
         IorqWkTFRYZoudpc65xTKaXAg5XTUesra+DDCqO2dqzVd6CT2+qKnF5ZCPmLfcnuJHgC
         nCuA==
X-Gm-Message-State: APjAAAX0l7ezM81OSt9cf2H3E+vvKCLwmJ6vAVt4olhJlW0mE3+nd1Wr
	k4Cnx4mTXpYngSW25jpMDk+WqfNFUsaJS+lG9DEwfGMy7KHxh+QtaXqw/ioqigDk9RrFLERR2ks
	MUpqCyUP6noDzZAfO7NYYA7Jc776wOkwK37DOqf85KmqWJNCmmRQGzzTxDFZmpB0=
X-Received: by 2002:ab0:c16:: with SMTP id a22mr2083283uak.73.1562831683788;
        Thu, 11 Jul 2019 00:54:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTzSscH8Kg6knIdW4pWP/MBnxLzB70kZ46pvm4hwJRTmb+YdmeyWrPdy+LAx5WedqQ//UQ
X-Received: by 2002:ab0:c16:: with SMTP id a22mr2083229uak.73.1562831683163;
        Thu, 11 Jul 2019 00:54:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562831683; cv=none;
        d=google.com; s=arc-20160816;
        b=TaI81W7YjhNyxSS1OpdZhnE0GeWcKZpDp3gMFxPnDw/H04Y9Lig+1MgUEDbbe9epbK
         XWor3neJDu/TxUVYvujEfx6Rprxbe01pXgqVg5P49HK52e7fe4HwtKZ9DbGL3cTu0CAV
         oCqD17TNZhcBAAku/po/eXuHNpV81aLLvmeIoDglcSzjYxbfrlemkUy9tz1mSN2/dVoT
         durDOj6ZsDJbpxgF2XLUp25IOEPBvxCLqM8KoCSRpHJegY4YtorgHrrcFlU/9OiS11VY
         CjBBzgsiZHmHL7ug1188RHMoVQ80R6UwIbFe09f99jdWLzrpQyto+mkDgYADDtEP3Ity
         Femw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=/raghnzRvb/GTCn5s+eX/MH0OP3DJ+YurwG6MlEbgYs=;
        b=roPTuI5AU4Ct8IDZHL55/iuqIXW0kJkP6Ku1swwS2g86/+IaoXc2YF+v3Aas/MwDuV
         NsY6O4GCTepOPV4dS41vgvgj3lGzQr+QGg6jDszclNTBHQBFH+nSuaMIDrR81s1Qjvhv
         531vh7vZd5w4zQiQed9goZCMkHQp9+u1Hny3aL60rtu9cxiqWRY1HpvlmlwlorCJPr2c
         MxIbDYvYw4pJJUCIpHakF/2mZBflTh1rr7NrAWqc8RNgcgcCgPWljHTBMB8HUJoEp4uj
         aUTqxSLE8jLTop64SUCwZcdN5/3wNh1JkYMJXZMTatLZMZkIneLsOmbOcUYakeMXdZsc
         MNVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=S1s804xx;
       spf=pass (google.com: domain of 0100016be006fbda-65d42038-d656-4d74-8b50-9c800afe4f96-000000@amazonses.com designates 54.240.9.46 as permitted sender) smtp.mailfrom=0100016be006fbda-65d42038-d656-4d74-8b50-9c800afe4f96-000000@amazonses.com
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id c25si1184958uan.130.2019.07.11.00.54.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 Jul 2019 00:54:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016be006fbda-65d42038-d656-4d74-8b50-9c800afe4f96-000000@amazonses.com designates 54.240.9.46 as permitted sender) client-ip=54.240.9.46;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=S1s804xx;
       spf=pass (google.com: domain of 0100016be006fbda-65d42038-d656-4d74-8b50-9c800afe4f96-000000@amazonses.com designates 54.240.9.46 as permitted sender) smtp.mailfrom=0100016be006fbda-65d42038-d656-4d74-8b50-9c800afe4f96-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1562831682;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=/raghnzRvb/GTCn5s+eX/MH0OP3DJ+YurwG6MlEbgYs=;
	b=S1s804xxXUY5juLFlYYlfbAezptOQ8Mctf3XXVrbJQvH3Hs4Kbfw8gHYyQtPNCVc
	4yMBk5bErvJMP5O7Y4kCKVwGM9fMi5ANqZeQmMMhuc8x6/9fDsLvGd/xIMx6N53vVWI
	r1T3ZLe62J6Q0NDHeTRNIrl33sAZktlvfUfGBGQg=
Date: Thu, 11 Jul 2019 07:54:42 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Nicholas Piggin <npiggin@gmail.com>
cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, 
    linux-sh@vger.kernel.org
Subject: Re: [RFC PATCH] mm: remove quicklist page table caches
In-Reply-To: <20190711030339.20892-1-npiggin@gmail.com>
Message-ID: <0100016be006fbda-65d42038-d656-4d74-8b50-9c800afe4f96-000000@email.amazonses.com>
References: <20190711030339.20892-1-npiggin@gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.07.11-54.240.9.46
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Jul 2019, Nicholas Piggin wrote:

> Remove page table allocator "quicklists". These have been around for a
> long time, but have not got much traction in the last decade and are
> only used on ia64 and sh architectures.

I also think its good to remove this code. Note sure though if IA64
may still have a need of it. But then its not clear that the IA64 arch is
still in use. Is it still maintained?

> Also it might be better to instead make more general improvements to
> page allocator if this is still so slow.

Well yes many have thought so and made attempts to improve the situation
which generally have failed. But even the fast path of the page allocator
seems to bloat more and more. The situation is deteriorating instead of
getting better and as a result lots of subsystems create their own caches
to avoid the page allocator.

