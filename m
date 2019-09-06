Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 186B1C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:41:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB713206B8
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:41:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="UHpvjhj/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB713206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79E646B0006; Fri,  6 Sep 2019 11:41:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 775B46B000D; Fri,  6 Sep 2019 11:41:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68BAA6B000E; Fri,  6 Sep 2019 11:41:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0003.hostedemail.com [216.40.44.3])
	by kanga.kvack.org (Postfix) with ESMTP id 492086B0006
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:41:16 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 01D5F824CA2D
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:41:16 +0000 (UTC)
X-FDA: 75904909710.02.train66_452fccbbeb33b
X-HE-Tag: train66_452fccbbeb33b
X-Filterd-Recvd-Size: 4160
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:41:15 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id v38so6693359edm.7
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 08:41:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=E/TcN7fOifPGax1Jq40PHMF0EK7SlDS08IkccSojTBY=;
        b=UHpvjhj/b+3iPmUiNVdPjXOFzdSR9u8eZg6v7FAfkypqULaESyzADB/3E0G1AkEkNR
         Lp8I3t1bftgwOcuzcW2n2byutpV5BbBWkG00d6zYMuBg0Wf4juih5hnIVQ30wERZkO42
         orJl08eujiOsHl+blX6Hkfe0UnzoOC8HeNQyn2zEw6FuD2liDmdKTiQwOCOOPWUUQUrq
         i0UfvMU0TYqLIyuRgY978I+xXrDXcSjX7hTdo9RtugdRgTB6Ij+Esu3cAjKLJTX0AxAF
         M0acuyTnKUC/IW05ASrd/FZQtsdbwbSCUpPxWnd4khMHCCnwBz2K2dMpQDeoOrFxf1IL
         qPxQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=E/TcN7fOifPGax1Jq40PHMF0EK7SlDS08IkccSojTBY=;
        b=O9XDdEhnHh5LUluDuDuGTzVS/nWppGJrBqBXYb2RaUPPjrtKTiYqSwXn9KaMOSpLuL
         a6jPIRp7zn1leU4e6A87IKM3mIQD+yANnZvZsi5qRhJLQFpWvOSJvWOj+OisXk3wfhtt
         N23fsIi3+rFcbdJsIQKqGJDP0UfbBY2bYb6+2605yhi4lXr2dnafCxtpOUt4D4r6nwnx
         Qz7wPuQ9soU3f8WgZZm34ZKfPY8Q/Qig7pJUvTkhOCAd+aTuMxk6qr1W9u8/V5RZgkN8
         D+5wqsWFCwzSt4tJgf5LkDoHzz4E88EN3urN0nCYMSeoa1cQqne6dD2fJifqhjdysD05
         0HCA==
X-Gm-Message-State: APjAAAW8ENMg104YQrRkVq1C6qEXtC5x2Xo55ifgODHzpv+61n3P9tlF
	6wLmasN8aUogpKrLBJ2Ml67BgFRW9I6gMbhe+p01fA==
X-Google-Smtp-Source: APXvYqxqjBbmqD7LIj2EqKBKAdltdsP4QbI+ZnJq02VDIJPVUgUjKlLGn6euHlVgtpT+xdsUOX7pyuDO609XO9GYCmk=
X-Received: by 2002:a17:906:bb0f:: with SMTP id jz15mr7785513ejb.264.1567784474126;
 Fri, 06 Sep 2019 08:41:14 -0700 (PDT)
MIME-Version: 1.0
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
 <20190821183204.23576-5-pasha.tatashin@soleen.com> <2e826560-4005-fa16-8bbb-fc0e25763dcc@arm.com>
In-Reply-To: <2e826560-4005-fa16-8bbb-fc0e25763dcc@arm.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Fri, 6 Sep 2019 11:41:03 -0400
Message-ID: <CA+CK2bDU9ZZbXsqfEzMV9JDRUq0vMRNHObpQ0q-YtwbEbq702w@mail.gmail.com>
Subject: Re: [PATCH v3 04/17] arm64, hibernate: rename dst to page in create_safe_exec_page
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

On Fri, Sep 6, 2019 at 11:17 AM James Morse <james.morse@arm.com> wrote:
>
> Hi Pavel,
>
> On 21/08/2019 19:31, Pavel Tatashin wrote:
> > create_safe_exec_page() allocates a safe page and maps it at a
> > specific location, also this function returns the physical address
> > of newly allocated page.
> >
> > The destination VA, and PA are specified in arguments: dst_addr,
> > phys_dst_addr
> >
> > However, within the function it uses "dst" which has unsigned long
> > type, but is actually a pointers in the current virtual space. This
> > is confusing to read.
>
> The type? There are plenty of places in the kernel that an unsigned-long is actually a
> pointer. This isn't unusual.
>
>
> > Rename dst to more appropriate page (page that is created), and also
> > change its time to "void *"
>
> If you think its clearer,
> Reviewed-by: James Morse <james.morse@arm.com>

Thank you for your review.

Pasha

