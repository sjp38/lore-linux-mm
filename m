Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B289C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 18:14:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A681C20863
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 18:14:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=synopsys.com header.i=@synopsys.com header.b="JqJ4M5pL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A681C20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=synopsys.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E16C88E00B3; Fri,  8 Feb 2019 13:14:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC7758E00B1; Fri,  8 Feb 2019 13:14:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8F368E00B3; Fri,  8 Feb 2019 13:14:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8883D8E00B1
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 13:14:14 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 3so3263642pfn.16
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 10:14:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:newsgroups
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=hJXBCTeF+PhPitzrYxkUIfIxRHawGt5O2RQYs0/N8sk=;
        b=icPax7+4cY0k+cXwJTEKulkun2FVFiOZvMCgtNKS3ipR+yeNuICaUn5d9R8QvySfwr
         O/VOCY7xHW31sb/iU40IO9Bho/g2ivdsXyQvGRho1l7zG38I/0OBxfEXlyN1A1vY11HF
         Sm8DyJbCN60AuM7ENiobWOKTCOpB62G0YIGHjaWPg3ql5ibtrpbJpZuQGbO1xDjYvQvo
         FDVvQy68aVt79I83N9sbG6ja1ZjChahmt53nxUBjso7i4PHxo3h3Wphtldb0sVOlLa7l
         P2q1rtmMi1bRrvLf15sL0OqItAwagQdPBMPvLMk0e3s22bsa1Rq0h1CDACKDgUbbB+5f
         2KHQ==
X-Gm-Message-State: AHQUAub4hsI0XEMfQAGKSxl9csEMxa/n3MMRkCjkjrBvwET0Ot3w5ARo
	RTfoPwRclXsseDgNLJHJvcB9KeLaeUY/ucwb09kaYRUg7mpgJaEm4ULqV4M1kGAbZyjOQlpFYch
	+tD2ng5CSOYF7jNz9ckBWueqtpJzka9f/6DVSPIelm12XFdjoy1VhoPEXYJ3nKVYq7Q==
X-Received: by 2002:aa7:8286:: with SMTP id s6mr23135545pfm.63.1549649654114;
        Fri, 08 Feb 2019 10:14:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia5j9goSB7hgYv+buV+NETjiMQuZsWff+IiTcN7NvppE8bxI6G6/WTL02AfBzpGD3sGDuHb
X-Received: by 2002:aa7:8286:: with SMTP id s6mr23135485pfm.63.1549649653206;
        Fri, 08 Feb 2019 10:14:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549649653; cv=none;
        d=google.com; s=arc-20160816;
        b=nq5Cn4RgtGbWgyqPda+Dcb1qW2pIMJQ/giNiW5z9fYI4C190Ei/xucaAx0jyypvhj/
         v5pYMb7KCTa8MaU/TE42hHPatPlitTYo0fNDMzVtcoZnynFDR/weANBfWUi73kXNXsZg
         UwXFZExqx6Ven5ttRhaIemq4OVWpiApC5y7UvNbSj9YQ8pjTE8RbFVvHBtXDvUiLn+2A
         GmTVS2FsHIwm+EczPJRurq7Rtt+kNf9FRI4TyCLXcPfmttwStCXTVkH1ECqANKcKHux0
         ABB/JVqNY9zrBaJc4JapnAmwGTVO+G7+mprp79pCeru/ixymPq99Huu++bwNvwxspwoY
         qc9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references
         :newsgroups:cc:to:subject:dkim-signature;
        bh=hJXBCTeF+PhPitzrYxkUIfIxRHawGt5O2RQYs0/N8sk=;
        b=z+7AW8MCVAtS7Ai0JQROHICZVMR4hIkfYGDIF11jopvEHj38ahO0YaTTbk3rnv0y8Y
         eJUQCdwllN8HEEMl3tYRk5mfwVfxbmOPye6uk+iJtub5Th3qtw/EB7VETC1fJt8WYEI5
         lT2u49MJUciM+VeuRXaYwhBZav2jwo+6A97c4+pLNKJrHMhzpIcxkV8IBV9eUtG/B+OO
         oa7igTFkEiOcl/5kkPL0PZDOukVWo4rnU5iYlOoXRitcvz3NQr9m+2aA8FxyEpIKypDW
         rKlES7tal+nRkSwP6hrkPvyQf94h+TB270jNSD1zgO9H0VhpzBK45Hmow4Ft8U6rroVD
         BA5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=JqJ4M5pL;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.60.111 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id j91si3037655pld.395.2019.02.08.10.14.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 10:14:13 -0800 (PST)
Received-SPF: pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.60.111 as permitted sender) client-ip=198.182.60.111;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=JqJ4M5pL;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.60.111 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from mailhost.synopsys.com (dc2-mailhost2.synopsys.com [10.12.135.162])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtprelay.synopsys.com (Postfix) with ESMTPS id 402CA10C1086;
	Fri,  8 Feb 2019 10:14:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=synopsys.com; s=mail;
	t=1549649652; bh=R//ocag1WxtYv6NHWUUVIFiK8K/XKiF+nwhlmb4Zf4w=;
	h=Subject:To:CC:References:From:Date:In-Reply-To:From;
	b=JqJ4M5pLaiGOeK0Xc/NXRKt/8PKH3MrupvPrg5LrGVsZtdXzzLqF8EGghpmlxSwvA
	 CcY5945qv9BhLzevhLZXhzjQh0Y9EW1rG0bRCvwBbRfSl0Zeqiq43aLtD8OM9fdiI3
	 aiHfkfX82DhnOcyswoF0VJCLYn5IAx2us946z6Wl0lXkX8FvbKEidRks8gUaONZxsn
	 qmnFJwLAFAnmbdLnlpQsBe440g0/o71y/Dk9jtmepGSyJ7uS6iZt8Tg6l64V4x8cSf
	 OGjrPlAg6cTq9D7ZwOPoSPCCd7Boyov4klwk22+tznQO2dHbaAzba4lX3n4cV8N3G/
	 m7GRYvF9fEmMg==
Received: from US01WXQAHTC1.internal.synopsys.com (us01wxqahtc1.internal.synopsys.com [10.12.238.230])
	(using TLSv1.2 with cipher AES128-SHA256 (128/128 bits))
	(No client certificate requested)
	by mailhost.synopsys.com (Postfix) with ESMTPS id BC6CDA0090;
	Fri,  8 Feb 2019 18:14:11 +0000 (UTC)
Received: from IN01WEHTCA.internal.synopsys.com (10.144.199.104) by
 US01WXQAHTC1.internal.synopsys.com (10.12.238.230) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Fri, 8 Feb 2019 10:11:57 -0800
Received: from IN01WEHTCB.internal.synopsys.com (10.144.199.105) by
 IN01WEHTCA.internal.synopsys.com (10.144.199.103) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Fri, 8 Feb 2019 23:41:59 +0530
Received: from [10.10.161.59] (10.10.161.59) by
 IN01WEHTCB.internal.synopsys.com (10.144.199.243) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Fri, 8 Feb 2019 23:41:53 +0530
Subject: Re: [PATCH v2 0/3] Replace opencoded set_mask_bits
To: Vineet Gupta <vineet.gupta1@synopsys.com>,
	<linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>,
	Andrew Morton <akpm@linux-foundation.org>
CC: <linux-snps-arc@lists.infradead.org>, <linux-mm@kvack.org>,
	<peterz@infradead.org>, <mark.rutland@arm.com>
Newsgroups: gmane.linux.kernel,gmane.linux.kernel.arc,gmane.linux.kernel.mm
References: <1548275584-18096-1-git-send-email-vgupta@synopsys.com>
From: Vineet Gupta <vineet.gupta1@synopsys.com>
Openpgp: preference=signencrypt
Autocrypt: addr=vgupta@synopsys.com; keydata=
 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
 hhqBJlyU6MVUa6vZNv8E
Message-ID: <c8f00c90-2e09-e825-1a1f-056294cafbea@synopsys.com>
Date: Fri, 8 Feb 2019 10:11:47 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <1548275584-18096-1-git-send-email-vgupta@synopsys.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.10.161.59]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/23/19 12:33 PM, Vineet Gupta wrote:
> Hi,
> 
> Repost of [1] rebased on 5.0-rc3 + accumulated Acked-by/Reviewed-by.
> No code changes since v1.
> 
> Please consider applying.
> 
> [1] http://lists.infradead.org/pipermail/linux-snps-arc/2019-January/005201.html
> 
> Thx,
> -Vineet

Ping ! @Peter, @Arnd are you happy with this. If so, Andrew can you please add
this via mm tree or do i need to pester the respective maintainers !

Thx,
-Vineet

> 
> Vineet Gupta (3):
>   coredump: Replace opencoded set_mask_bits()
>   fs: inode_set_flags() replace opencoded set_mask_bits()
>   bitops.h: set_mask_bits() to return old value
> 
>  fs/exec.c              | 7 +------
>  fs/inode.c             | 8 +-------
>  include/linux/bitops.h | 2 +-
>  3 files changed, 3 insertions(+), 14 deletions(-)
> 

