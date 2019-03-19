Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C222C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 13:00:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D75E2146E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 13:00:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D75E2146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1ED06B0005; Tue, 19 Mar 2019 09:00:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECB366B0006; Tue, 19 Mar 2019 09:00:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBA6D6B0007; Tue, 19 Mar 2019 09:00:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9CA816B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 09:00:47 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o27so8159441edc.14
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 06:00:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=WTpD4Rjkiz4VWEZvoYQaOav34nY+rRzhR8yPpNRPNCg=;
        b=Hi/Cij9JOWE4VAwK7k6Fjhjmcy5FsCs2vQJDKMG6Sm4OCsrLtmtMg+LMd0CrvLKLPQ
         8y7BXfXfCR1R+kAr3l8f9ntY3ge7HmbN5EkRn+Np/EMD0wswbTd1F/0OZQ6XooLVbp9n
         CbH2myiXcbW9HB1sm3itl6Zsi2aamVGub5XwNt7UAje9E/O1CWWFdbX9/8krQP2u1L37
         dzoFzkPcHPbGS/axFHLc931lmLsf7z5AlDhnuAe1kqlWk4eM3Y/NxBTKAF0ufEgddCBI
         dVa1aO+hR1Aa2RKAiIWuQurOu/3mBK5iBtpYcG5UYIzSPIvB43RRLBMjCnm0Razon/BP
         rgig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of metan@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=metan@suse.de
X-Gm-Message-State: APjAAAX8J3vgRfE8vfiBhOyQb636SGRFS9HhivXNZC6O+4zNRW3r6VYb
	zF+dbMxrql69ChjN4hu2z9pYFlEKvrJcxec6p1YBlvrnx58G9DjZq1gUK+aWg7R4W6+Vv+UqQUi
	VLC5pKGye66RBRICuasUz5dXQMsx9U4/IDfoWXH39UglBnSYK1f39dbvMG4pgTJ8=
X-Received: by 2002:aa7:c419:: with SMTP id j25mr16552646edq.195.1553000447213;
        Tue, 19 Mar 2019 06:00:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyP7mIzSI2x5i1+7bDRsn+A/hvT4nmaBifl7mH2Leb7wTkPSIOjVgl2Q60X1MYwti0bZPrS
X-Received: by 2002:aa7:c419:: with SMTP id j25mr16552605edq.195.1553000446255;
        Tue, 19 Mar 2019 06:00:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553000446; cv=none;
        d=google.com; s=arc-20160816;
        b=M99eSXC+c9Uci49MSo+mpMATHL5Xry4y96OR/aAEFHIx6oEIAj1axnq1cWTty52UL9
         Bi5QQmoOVbtLO1w6CYQ14wxtDUlOWH5poQUcGtG2gmZCu8k2y2DEGWLFmvr75gWAqWH7
         98fah9q3OKgvLyLtrIIOEXS1qTRktOJnS6OGbE3DkUYYOOKPOoLY7lH7qQetnJIn3t9Z
         VRne64FAKjEbumjW0u0i/7oDmrSBlkx//ZjScgtn2hKmE/GFgyuyb76LBNOvJb1LtCin
         cLQvijztNqP3yFGAh84PYE6j4XPTw37eBzw0y24JMUdPTEOIbhT3PT7Td/p/9zsp3UXy
         8yFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=WTpD4Rjkiz4VWEZvoYQaOav34nY+rRzhR8yPpNRPNCg=;
        b=mtHoypmEHlYN5qudA7xQMJaPq8q5KIlzhAlxuoHEq4u11aGPo37eOPzYHwm23uZm1m
         5FtF0UshI9ZxjCGU1vBlmyqn4XqPh67gSfFtJ5Jtjb4+WCOPGAxQayjMALK//la0lHWe
         xYyU5mHh8j8d2W3tLysEAvES5tg/QKU6OHzu+p7bSjdpwke9oWm9CujU3oso9H6TSsmS
         UnFoY8Nuv3Nos4pi1Uz8+3mGefZVTPQVTuYAfUMcr89cNpN5zBxJolOoQY4R9zF4DmpU
         /2kYniiy79qD3DzQkJ8KXWcS8TpeVFqdIspbbE0yDNEhG6Ag6tq89zq85zhNuiyCzDA2
         gKOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of metan@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=metan@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o4si2344301eda.121.2019.03.19.06.00.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 06:00:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of metan@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of metan@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=metan@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DCC40AD0A;
	Tue, 19 Mar 2019 13:00:44 +0000 (UTC)
Date: Tue, 19 Mar 2019 13:59:59 +0100
From: Cyril Hrubis <chrubis@suse.cz>
To: Qian Cai <cai@lca.pw>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, ltp@lists.linux.it,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: mbind() fails to fail with EIO
Message-ID: <20190319125958.GF6204@rei>
References: <20190315160142.GA8921@rei>
 <1552925316.26196.5.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1552925316.26196.5.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!
> I am too lazy to checkout the repository and compile the whole thing
> just to be able to reproduce. If you can make it a standalone program
> without LTP markups, I'd be happy to take a look.

Sigh, I've spend last few years so working on the testsuite so that you
can compile and run a single test from the checked out repository, we
even have howto for that in the README.md.

https://github.com/linux-test-project/ltp/#quick-guide-to-running-the-tests

It shuld be really easy, so can you please give it a try?

-- 
Cyril Hrubis
chrubis@suse.cz

