Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D8FBC43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:42:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D50E220838
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:42:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="YXvpaoqM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D50E220838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 775CE6B000D; Fri,  6 Sep 2019 11:42:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74DB16B000E; Fri,  6 Sep 2019 11:42:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68AC66B026C; Fri,  6 Sep 2019 11:42:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0244.hostedemail.com [216.40.44.244])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8386B000D
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:42:09 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E1C74181AC9AE
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:42:08 +0000 (UTC)
X-FDA: 75904911936.03.army43_4ce154aafc846
X-HE-Tag: army43_4ce154aafc846
X-Filterd-Recvd-Size: 3605
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:42:08 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id s49so6735655edb.1
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 08:42:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=a7CpqJIrowSUHG+Dch68wvi3kLH0yuCv0IJ23idpZx0=;
        b=YXvpaoqMtouskhiUthoVXPDwKUE0Kz84re4KCST1uCTAdZjSEPNsCxH3wZatPhfpAw
         CglvxirjKsFI5Yaogq+8Ur9COKORkUDCdZBoiH2khsNLfib9n6ch/6NaZBqtk841aAnl
         ozo71ho8eyrOMjQ8i2QLUDxeMChNm4iPTNqqGriW7BgshzdhNnDzVrR9LB77Vlua9nQa
         fSy1556Hyav/y2lp862IG9hXSaRGsJvWVxnFEpaev+aNCrLuZV8Oi+N9IY/txQmMvXPy
         ncjCg4DJh1LDJlanwQwRvadO7ctDS66Q74Yg250aQFjMHJ5ZldxRx3JoU2pkerbWZTki
         DhlA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=a7CpqJIrowSUHG+Dch68wvi3kLH0yuCv0IJ23idpZx0=;
        b=VUQfzN4/gto2g/6LQUN/gO0vB8CJTKKshaBHfLUBOhQN2dIOV5ulHE0hKWrVkzjw8w
         3y+BI88l+cjCxF0AN6le0BxEneeGbHfWwkQm5vDr5zjNp+rDnzQkvLm5FuZBJVEEclnH
         JMGM+obO/A6gETLMQzR48JvYd5sdyf1lolDoZ0dkbn58baMWL3zig8mVdRPWZydRE9uE
         sGelKKo+JOyECAiMCjynlZ0vhfjYNsKiFrQpibkyZZjpRG/Nca8Lvy73vr0rSEgn+BuM
         qhTXYaKvPZS9BdUvpy+wAJ3nWBpzVOzWh3hs9KBt9mToSMZnQ4JcQ501vuv0rvkBXuQc
         TOeQ==
X-Gm-Message-State: APjAAAUTh3wQCZc5lu3SHQ3YMi7IhE2GxxRuTewBSOb6sI+BAoh7FVt4
	hnVDbvcGpg/aJFQry1YKO01JpODieJqDuL0+7LF3Fg==
X-Google-Smtp-Source: APXvYqxdjX49MkF9aNw2e1jsftF5aJXCE4yDWZCKUgUZ6wavoi1VTf853eLT2XTzHK8gYqwDuQeOUszbmnukR+qEv0k=
X-Received: by 2002:a05:6402:17ae:: with SMTP id j14mr10239541edy.219.1567784527097;
 Fri, 06 Sep 2019 08:42:07 -0700 (PDT)
MIME-Version: 1.0
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
 <20190821183204.23576-4-pasha.tatashin@soleen.com> <99aba737-a959-e352-74d8-a2aff3ae5a88@arm.com>
In-Reply-To: <99aba737-a959-e352-74d8-a2aff3ae5a88@arm.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Fri, 6 Sep 2019 11:41:56 -0400
Message-ID: <CA+CK2bDj18EkjznFg7rbSSEtDDRpTioyrWfu+EWChH=8zktrNw@mail.gmail.com>
Subject: Re: [PATCH v3 03/17] arm64, hibernate: remove gotos in create_safe_exec_page
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
> > Usually, gotos are used to handle cleanup after exception, but
> > in case of create_safe_exec_page there are no clean-ups. So,
> > simply return the errors directly.
>
> Reviewed-by: James Morse <james.morse@arm.com>

Thank you.

Pasha

