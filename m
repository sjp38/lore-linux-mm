Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED64FC43140
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 19:00:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B30FF20838
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 19:00:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="E1edasld"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B30FF20838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 646976B0006; Fri,  6 Sep 2019 15:00:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61E996B0007; Fri,  6 Sep 2019 15:00:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 534596B0008; Fri,  6 Sep 2019 15:00:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0241.hostedemail.com [216.40.44.241])
	by kanga.kvack.org (Postfix) with ESMTP id 32E696B0006
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:00:19 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id D20A062EB
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 19:00:18 +0000 (UTC)
X-FDA: 75905411316.21.ants02_3cdad36f5fc41
X-HE-Tag: ants02_3cdad36f5fc41
X-Filterd-Recvd-Size: 3846
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 19:00:18 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id f2so880428edw.3
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 12:00:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=LrjX9gD4VIauKO9U5B9UI5Q0lIvPgAd5pEYZKOh182w=;
        b=E1edasldtuMUUwkDEeQ56lGV0qKHCc+ezSSI7PED72qKwm8givcI1UCheonDF+81rU
         DZOhA3PS5YT2Z+lRz68MmcNRorzwGoqu0KRyVhZh73RM5K5J8t3dDYLms/P0kTbvPtec
         7X0KIeg9UYHi7xjL3yLM/8gmOM3hLlwYmIHLEfMReHliOIdzcdvn9E3msksKAtQuGev3
         ToWGr15CVcoDF6P+lIE/dr4tO9E1aQqZPQUs26CFG4bEXIw89ZNUvP34ZpJRGdaObYaM
         GKhb6NJJySchkPl9O+1tmmIYBIgS1VoHFBQ5g7ReLTaEQvcU+kkN7J8ip6j/ozSYTNfg
         lfGg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=LrjX9gD4VIauKO9U5B9UI5Q0lIvPgAd5pEYZKOh182w=;
        b=RbIi7e0Lhtj+nk0iuDQrXzBKxnBgrF3c8vKOSK7c6aDi5rLR6n4SksrA3hqzJleTZx
         P0NikDL34WuNZwtiV/1Rjic9HyxVxBcoEQIRafy9TvO9mFvSZ9jE/WN7X2JlJfw3SJ3G
         vJyaJkNI5vm9Rfr+cbl8JbMx5ZgAsigC6j2m0zmnl5vlhqCCy/8oo8+2Z0n9fxlf5i1I
         PDd196HHbeXnCISyaKLMC6g2uJ25AGnh7Fi0F0YGV1fUGVfRuKw4+EgvAIpbal06Yb+q
         sC4Lsom/dglPC3ENp4kCOD/0osZOI9WR1OG3JaaZ4CLAzdKHiMJLXzgj1XgXeu36MjOo
         Uy4w==
X-Gm-Message-State: APjAAAXT0lACT8DnOcoG6mrU3J0rKY/KMaMVz0ocu9LE20dPHhpIs4Eg
	DwxoRctNh4IWY77lMJD2D1GTf5SaHYjJLSHYyRaDgw==
X-Google-Smtp-Source: APXvYqySdTqXeFzwKDdERIUW6O7satVNK6R7jE0J4FvXnhmNRURLOur3h+Xuy9x0CmE+4eeQW35qwli0Re25EqwHAFE=
X-Received: by 2002:a17:906:bb0f:: with SMTP id jz15mr8571853ejb.264.1567796416697;
 Fri, 06 Sep 2019 12:00:16 -0700 (PDT)
MIME-Version: 1.0
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
 <20190821183204.23576-10-pasha.tatashin@soleen.com> <2d9f7511-ce65-d5ca-653e-f4d43994a32d@arm.com>
In-Reply-To: <2d9f7511-ce65-d5ca-653e-f4d43994a32d@arm.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Fri, 6 Sep 2019 15:00:05 -0400
Message-ID: <CA+CK2bAkimTmsj-iGVq6AkMMNAb7+J5wm-Ra-qovS+3Ou5j33w@mail.gmail.com>
Subject: Re: [PATCH v3 09/17] arm64, trans_pgd: add trans_pgd_create_empty
To: James Morse <james.morse@arm.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, kexec mailing list <kexec@lists.infradead.org>, 
	LKML <linux-kernel@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
	Catalin Marinas <catalin.marinas@arm.com>, will@kernel.org, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, Marc Zyngier <marc.zyngier@arm.com>, 
	Vladimir Murzin <vladimir.murzin@arm.com>, Matthias Brugger <matthias.bgg@gmail.com>, 
	Bhupesh Sharma <bhsharma@redhat.com>, linux-mm <linux-mm@kvack.org>, 
	Mark Rutland <mark.rutland@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 6, 2019 at 11:20 AM James Morse <james.morse@arm.com> wrote:
>
> Hi Pavel,
>
> On 21/08/2019 19:31, Pavel Tatashin wrote:
> > This functions returns a zeroed trans_pgd using the allocator that is
> > specified in the info argument.
> >
> > trans_pgds should be created by using this function.
>
> This function takes the allocator you give it, and calls it once.
>
> Given both users need one pgd, and have to provide the allocator, it seems strange that
> they aren't trusted to call it.
>
> I don't think this patch is necessary.
>
> Let the caller pass in the pgd_t to the helpers.

Ok.

Thank you,
Pasha

