Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35F62C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 12:04:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00CE520857
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 12:04:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00CE520857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=gruss.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 719BD8E0002; Thu, 31 Jan 2019 07:04:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C6638E0001; Thu, 31 Jan 2019 07:04:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56CCC8E0002; Thu, 31 Jan 2019 07:04:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id ED9BD8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 07:04:19 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b7so1241619eda.10
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 04:04:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=FvQS4YPnZ/bQ6XznWHMvr42/u5olXB9zSvFbdP2NIbE=;
        b=OA5C/0OROe++pAESLG+NbWKeUz1sDF51RbGBKvYBpn67wn4SgRQvj4mdoLkVduAua0
         aII5Pr1ePvE20YKP/Yax3mURyQMJ3pEYpch3IztHk+lGbXdu+rXnvpnHKO378mjX3yoS
         OgS8grOEe4ZR3sFCG7B+HdSRLQQrHaZ7A3kMfEzNWe2SgrohXcD1cTZiv3Ce/umNlSVE
         /3QspPtLKCI+rAk5CFAsfWJEvANKHQbbwsSgk9FvUVkm9Zba7vtEtS672/NEr7Ipt0VL
         dmbGIjcjGaTFHfzLHWO2ntZX+r0YKi80IUHJxRoOC4V13EUMv0hwk3BWII/WpmhbqWE5
         RBEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of daniel@gruss.cc designates 80.82.209.135 as permitted sender) smtp.mailfrom=daniel@gruss.cc
X-Gm-Message-State: AJcUukc9fKIJiM0z1Qg9fHLAEUJKjySt32YcB4xAr32xpQvEGf3Z3ymZ
	J1ULdoRyj5REB4clkSxD68BSje+lyDjgspWiolpRuwFZO72T7RNGm3tctO6VdY8hjHPeyE5w7hj
	ZLZvWhzgSITQCtXuuDujgX4rROADpenLpwow+S0fP1Cwt+o1PkaHpfrzwVU4VXwU22Q==
X-Received: by 2002:aa7:cf88:: with SMTP id z8mr34608065edx.208.1548936259528;
        Thu, 31 Jan 2019 04:04:19 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4yG8BJO+dhly7Og+no7lrBGsvkd5B5MT8Ax2URGlfk4ntVng5E6eqEIbYJCYcXZMj7zPPs
X-Received: by 2002:aa7:cf88:: with SMTP id z8mr34608015edx.208.1548936258738;
        Thu, 31 Jan 2019 04:04:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548936258; cv=none;
        d=google.com; s=arc-20160816;
        b=gJO0SbO/Vj1BuSfGrFEq6QVQilU0VWnVcS1waEC5zeCyiet6Ctaftfo+83GGAv8DI5
         xagnAiWtp2Zu1oRELW89aTTF+RTHa6PfeSLwpmsHHY4d+Q3CWwYhhCehamb8XRKMiixl
         kTAyvs3yQix0PKgovhG6C6Rnj8JWv9hV8Dwe3hh3OhKx9XrJW0XM+x9pstOaQwrd3tAc
         jR6PWK5/sJjnMeU5xsWW0/UNpi4eRNzwukB/WJVB2kF41HBTnR/wLcJSKKzgo99zmu9Q
         +3RdDjW5DiW/2zd0PfztN0IHuaPU7nxarPVcVo+jx5FuL+GKmFyTupWlYySPmMKhZJQF
         p39A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=FvQS4YPnZ/bQ6XznWHMvr42/u5olXB9zSvFbdP2NIbE=;
        b=afWAu+o594GEcgHljHB0qzelov5g4fcQQ1fXhX6EtdRUfWIk7yvvFUZSNS+l+CVK4m
         S/ObJmY4HtMf3ThIaXOO8l/cZyzCCC77ScdEOT9/K2r3ICW+dhCYLT8Vrg/88rVxc4yI
         BfKy3sZQtRMkgUhVq+VMEfbJ5fsJNXegBNX4Ga+OgK/MFlpYzP/icPenSgGZsz9e2Xi8
         EFp+fA5UM8ucJN0fHxZoVMzZyD8Bn39g9MHx5a/4f21fbTudBTPZspQWHDW3JCzLgzMq
         Pc4M45ayKmozP6qBeq9Iea+DADxXM0A414Kp+BHf2FA4fKf3pwH1WHNf26itIMo6rL1D
         b1pQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of daniel@gruss.cc designates 80.82.209.135 as permitted sender) smtp.mailfrom=daniel@gruss.cc
Received: from mail.gruss.cc (gruss.cc. [80.82.209.135])
        by mx.google.com with ESMTP id z25si2141127ejr.144.2019.01.31.04.04.18
        for <linux-mm@kvack.org>;
        Thu, 31 Jan 2019 04:04:18 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel@gruss.cc designates 80.82.209.135 as permitted sender) client-ip=80.82.209.135;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of daniel@gruss.cc designates 80.82.209.135 as permitted sender) smtp.mailfrom=daniel@gruss.cc
Received: from [10.27.152.141] (unknown [129.27.152.126])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: lava@gruss.cc)
	by mail.gruss.cc (Postfix) with ESMTPSA id 3AC242A008D;
	Thu, 31 Jan 2019 12:04:17 +0000 (UTC)
Subject: Re: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT is
 set for the I/O
To: Vlastimil Babka <vbabka@suse.cz>,
 Andrew Morton <akpm@linux-foundation.org>,
 Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
 Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>,
 Jiri Kosina <jkosina@suse.cz>, Dominique Martinet <asmadeus@codewreck.org>,
 Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>,
 Kevin Easton <kevin@guarana.org>, Matthew Wilcox <willy@infradead.org>,
 Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>,
 "Kirill A . Shutemov" <kirill@shutemov.name>, Jiri Kosina <jikos@kernel.org>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-3-vbabka@suse.cz>
From: Daniel Gruss <daniel@gruss.cc>
Openpgp: preference=signencrypt
Autocrypt: addr=daniel@gruss.cc; prefer-encrypt=mutual; keydata=
 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
Message-ID: <aea9a09a-9d01-fd08-d210-96b94162aba6@gruss.cc>
Date: Thu, 31 Jan 2019 13:04:16 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190130124420.1834-3-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/30/19 1:44 PM, Vlastimil Babka wrote:
> Close that sidechannel by always initiating readahead on the cache if we
> encounter a cache miss for preadv2(RWF_NOWAIT); with that in place, probing
> the pagecache residency itself will actually populate the cache, making the
> sidechannel useless.

I fear this does not really close the side channel. You can time the
preadv2 function and infer which path it took, so you just bring it down
to the same as using mmap and timing accesses.
If I understood it correctly, this patch just removes the advantages of
preadv2 over mmmap+access for the attacker.


Cheers,
Daniel

