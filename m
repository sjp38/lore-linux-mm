Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE97DC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:10:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4242208E4
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:10:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="TR8pm1x+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4242208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5039A6B0003; Tue, 10 Sep 2019 05:10:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48E136B0006; Tue, 10 Sep 2019 05:10:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 354996B0007; Tue, 10 Sep 2019 05:10:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0219.hostedemail.com [216.40.44.219])
	by kanga.kvack.org (Postfix) with ESMTP id 0EF576B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:10:41 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id B7520824CA28
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:10:40 +0000 (UTC)
X-FDA: 75918440640.13.wash61_5d2d1cb1ed93e
X-HE-Tag: wash61_5d2d1cb1ed93e
X-Filterd-Recvd-Size: 3799
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:10:40 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id a23so14100585edv.5
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 02:10:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Iez8yZGFDi4oceFiuNT2xGD/UPWI8Mn1wAE4EZBiLGs=;
        b=TR8pm1x+5+93McH11wJzi98SRcpwX5O2y8OG42hvagT/7UHiVtW74HMGcwPXJf0w7w
         Cn/lBBy9lD0+a7/880e7d1bukGpYVoiffeuNMtO4uCUjgsaO1QDM5OXZ7vAjJXCmCZBf
         0C3LJWyRj++f193R8TKq7WnBTx9mP7PZ+ipVafA1tfCFnGBYz11HYgU5XTuffl9M0q77
         37d590kwYGCiNDXpAWRB06js2XfjxPKlJVcbyLIzRqjFCoI3DPkk3fEGVoCsNMEuxt+m
         vPhmqXKJXvkOAhLiQdPlCSlO3p1Z1SWiiL8Xcy+XjoSFfzFlXHja1JiLUV61MJ33GZkW
         hqwg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Iez8yZGFDi4oceFiuNT2xGD/UPWI8Mn1wAE4EZBiLGs=;
        b=nvhosdkqwjXTiM0n1vOSWZXHVzzN5Ywn2XZr2H3DSbSMKs6m0XPGHifo/zCSmPj1H7
         LY7QoYN5MmIHruuYTaRCmKGVjJItWUa8fHMKuB8VFh+kcuYRspKYDSnCxzKrC6vBn+zF
         UVLSABbj8Fw8gvcYNm9N3xWWEhdC4qTTSfiYBUAA8ZWrH7roRrXJ4M5G2pq1AkXHXipP
         eE9/O4G+uBmXdrBEKlwwHTJrTi+TkcMJ5YJJmwSnR6MJhzYm1Yc/7kg4GmkhoqwTzpaF
         knJE1uSUfLQn3spps5dF9+MadbDMHPcPmNTryILrn4ExGbLS3BZNtLyWoRSIaxX44rMU
         EOTA==
X-Gm-Message-State: APjAAAX9R/IXhgLdZTczcSFUHJtfY3CmNsKqC3vswrkyYXqaEzzflJOR
	3+lX217ogOWI/jxb0X+QI7L7o79p/cLNVPKNoOmSqA==
X-Google-Smtp-Source: APXvYqw+MTXYLCZAfKQw+KljBbFHBLzEFXSK8JFfP6Xtr05eeItHAJhmdBtQMKUlIJDozLSmFBiEb9Xc0kOqfyUvFTE=
X-Received: by 2002:aa7:dd17:: with SMTP id i23mr28774906edv.124.1568106637988;
 Tue, 10 Sep 2019 02:10:37 -0700 (PDT)
MIME-Version: 1.0
References: <20190909181221.309510-1-pasha.tatashin@soleen.com>
 <20190909181221.309510-5-pasha.tatashin@soleen.com> <e2ceb43a-d7bf-e0c6-c3ea-b83c95ba880d@suse.com>
In-Reply-To: <e2ceb43a-d7bf-e0c6-c3ea-b83c95ba880d@suse.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Tue, 10 Sep 2019 10:10:26 +0100
Message-ID: <CA+CK2bAsW0ExS2a2ZaGUmF2igKE7TM0qdCSYMaJn=0+pkM7ugQ@mail.gmail.com>
Subject: Re: [PATCH v4 04/17] arm64: hibernate: use get_safe_page directly
To: Matthias Brugger <mbrugger@suse.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, kexec mailing list <kexec@lists.infradead.org>, 
	LKML <linux-kernel@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
	Catalin Marinas <catalin.marinas@arm.com>, will@kernel.org, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, Marc Zyngier <marc.zyngier@arm.com>, 
	James Morse <james.morse@arm.com>, Vladimir Murzin <vladimir.murzin@arm.com>, 
	Bhupesh Sharma <bhsharma@redhat.com>, linux-mm <linux-mm@kvack.org>, 
	Mark Rutland <mark.rutland@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On 09/09/2019 20:12, Pavel Tatashin wrote:
> > create_safe_exec_page() uses hibernate's allocator to create a set of page
> > table to map a single page that will contain the relocation code.
> >
> > Remove the allocator related arguments, and use get_safe_page directly, as
> > it is done in other local functions in this file to simplify function
> > prototype.
> >
> > Removing this function pointer makes it easier to refactor the code later.
> >
> > Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
>
> Reviewed-by: Matthias Brugger <mbrugger@suse.com>
>

Thank you

