Return-Path: <SRS0=mZRB=PG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45B5EC43612
	for <linux-mm@archiver.kernel.org>; Sat, 29 Dec 2018 09:18:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5DC021902
	for <linux-mm@archiver.kernel.org>; Sat, 29 Dec 2018 09:18:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linaro.org header.i=@linaro.org header.b="cikA1iQy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5DC021902
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 334A08E005C; Sat, 29 Dec 2018 04:18:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E3C88E005B; Sat, 29 Dec 2018 04:18:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FC0D8E005C; Sat, 29 Dec 2018 04:18:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id E9EDD8E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 04:18:11 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id q207so24822554iod.18
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 01:18:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XLkqG3nKcd0lTsqiWLlqAWjPHPJTG5QkaExKzZNJIQQ=;
        b=kLG0Y37EUkgXe6gOkFwL3hAHLqHnHBgYEvjjdNIyMoPuvXz///8BIcRkGALrWacnm4
         6QKodhkkdhM0z1x+NvZfHW7inE6xhWlQ9MXJ32OkY4xl3sOc1+aUtH0gu5Mj6PEwgnum
         reCXp0zE1WmQyi0NSTw49vV65Szi3prlvWtGmfUpgCnNhxWaGCoREs7MJCA0Q3vS/XB0
         PlRje3bJxoL94HpXo6C2+1Q8ARKxkaIi6Q5tNCBmtvCKZgPItdvveo1xwR+7PckIvRvR
         nl2+z1vax8Dj3/wNUanWoNFpFYTaQPC/OU1jhnJkjAvd/1dvhgzieDPDz6Ebu+zgw2MV
         jAdA==
X-Gm-Message-State: AA+aEWaHz/Z9d/Vzljx5z0ZJdf6xioZgYEB2v9u4VycUOD8whzal139W
	HwgE0nMsc2DwkaJrFcDwUzPRSWmkuu3UcyOjYhWjacVZeZneXcSDQxhXobwtRCohtfnLwyidZj6
	SG96jXTxF7DYsMB5eZlWtQoxPYLcjj6I78FWq42i9Sdh44v5NUL+UWo7Ut7TObvp8lgQFmX1zZu
	eqn61hGBdFHKW4bZjGqElF7c5j+03NuBWHeLMYThPZ+YKQZjc7bPPh2Z5EFLpJ/w95FoRCfbM/G
	C53dLyYKeSRbNUhKKOkXbyP0YZ3pAk3sMjPuMfwu+u+S7eZcr+n7ho4TYZBN7XdcLmm9b4uMAiF
	wmY9GPENIUEWpPZ78aqcw2m7zP5OzugpT1BPzRaA0d+mHFIPkzfoljmhmEiGKBTOHJwpf3xXiFH
	O
X-Received: by 2002:a24:b518:: with SMTP id v24mr21571527ite.159.1546075091699;
        Sat, 29 Dec 2018 01:18:11 -0800 (PST)
X-Received: by 2002:a24:b518:: with SMTP id v24mr21571504ite.159.1546075090899;
        Sat, 29 Dec 2018 01:18:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546075090; cv=none;
        d=google.com; s=arc-20160816;
        b=wyt4HCM0OkIKiaCHiStVgSwpX8PWV74crDzR067TrphhcXSDeYA/ne1MxUDYiwwMOW
         B3lEX3Fbi8kBViFHM+vQYs6zUkN52jjbR8I65m7L2KA+73R8ZWHWiIv05/jPyZBw/1ib
         8tOF/6zRujQs0gqPuE5UqlqcldSZ1B+Oag0PSeaMZ5UNEOfEdF4nGu0t6efiDftiu4QF
         EbbvCyJ1QG6KlVUyF5aiJAp8SqaUVvo3BvTWEZf5S0Z+jqyGzVjJ6CNs1gbWPFMmlxga
         LxGCwq4Qi5Dy2yfZG1UJZJTLzrASN4Gc33rlukBHGwlNq8HnocKAq9uQ4XV9v/6QxE1d
         0nbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XLkqG3nKcd0lTsqiWLlqAWjPHPJTG5QkaExKzZNJIQQ=;
        b=BdPttSV698MruWWjq8SJL6D80W8G5EVtdtcCmnaCNLDC7KueyBjUW078PEx2kWjjwr
         zEmtvET4PR53bzu7F/q3/dzjwBAaBrpIIqlksafe1+EwzZolqOcqk7fMEIWOzUqDBsFM
         AVCxz7X9tks1cz+8UIlUop+i+VLy0XLGTgssHspskR0qx3ivFC/rmqRlHMCkdbTF551N
         vOhosLHFQDeMVLKeFu+wXGprp9vX9sPL0ghRlL5UQUteo7NcsMfRK8UOqZPpgl9OFRH7
         ga3P9AjNi6vOInJBb/WkxLK1AUp2whamDOb+XzyqhRGEpHVim8Ov9qT2/dRsXuH108zB
         PtXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=cikA1iQy;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m143sor45223190itm.23.2018.12.29.01.18.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Dec 2018 01:18:10 -0800 (PST)
Received-SPF: pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=cikA1iQy;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XLkqG3nKcd0lTsqiWLlqAWjPHPJTG5QkaExKzZNJIQQ=;
        b=cikA1iQyu/ElwFNIcKp6x3njQ+21za/IdwN9/TWcy4YtWYsw3rtw2UlWHeEnzYIRVl
         uS03VYntlBat/fOJjfTEBUqYv4x6S/NawTSU99ox32X+4C+4HnlN/N5BOMxdBlimrBpe
         wgOKVtxnmbE35E90cv597ZE2ldQTfk0CjmxU8=
X-Google-Smtp-Source: AFSGD/VdgZ6uJMg3u74ZS49D4rnRTJiBWbcr2UDALfLGoZf36WFiM3iMcGvFT0QnGY53/0hlliQ355LRfC/vU3Rb9v4=
X-Received: by 2002:a24:edc4:: with SMTP id r187mr21614405ith.158.1546075090440;
 Sat, 29 Dec 2018 01:18:10 -0800 (PST)
MIME-Version: 1.0
References: <20181226023534.64048-1-cai@lca.pw> <CAKv+Gu_fiEDffKq_fONBYTOdSk-L7__+LgNEyVaNF3FGzBfAow@mail.gmail.com>
 <403405f1-b702-2feb-4616-35fc3dc3133e@lca.pw> <CAKv+Gu_e=NkKZ5C+KzBmgg2VMXNKPqXcPON8heRd0F_iW+aaEQ@mail.gmail.com>
 <20181227190456.0f21d511ef71f1b455403f2a@linux-foundation.org>
In-Reply-To: <20181227190456.0f21d511ef71f1b455403f2a@linux-foundation.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Sat, 29 Dec 2018 10:17:58 +0100
Message-ID:
 <CAKv+Gu98AOB2LfQGMUHNc_B0MBvd3gATvtPypQaV1vgTcf87ww@mail.gmail.com>
Subject: Re: [PATCH -mmotm] efi: drop kmemleak_ignore() for page allocator
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Qian Cai <cai@lca.pw>, Ingo Molnar <mingo@kernel.org>, 
	Catalin Marinas <catalin.marinas@arm.com>, Linux-MM <linux-mm@kvack.org>, 
	linux-efi <linux-efi@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181229091758.23Q3ZOsVdLy5pH_TIHixJzf8uj0GL62zsKTsp-INzU0@z>

On Fri, 28 Dec 2018 at 04:04, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Wed, 26 Dec 2018 16:31:59 +0100 Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
>
> > Please stop sending EFI patches if you can't be bothered to
> > test/reproduce against the EFI tree.
>
> um, sorry, but that's a bit strong.  Finding (let alone fixing) a bug
> in EFI is a great contribution (thanks!) and the EFI maintainers are
> perfectly capable of reviewing and testing the proposed fix.  Or of
> fixing the bug by other means.
>

Qian did spot some issues recently, which was really helpful. But I
really think that reporting all issues you find against the -mmotm
tree because that happens to be your preferred tree for development is
not the correct approach.

> Let's not beat people up for helping us in a less-than-perfect way, no?

Fair enough. But asking people to ensure that an issue they found
actually exists on the subsystem tree in question is not that much to
ask, is it?

