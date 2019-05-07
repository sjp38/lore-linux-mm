Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57DF5C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:15:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18D922053B
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:15:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="NsaoLR6A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18D922053B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B061C6B0006; Tue,  7 May 2019 13:15:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB6BC6B0007; Tue,  7 May 2019 13:15:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CB806B0008; Tue,  7 May 2019 13:15:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE656B0006
	for <linux-mm@kvack.org>; Tue,  7 May 2019 13:15:40 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id u14so2978143ljk.11
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:15:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=pAvQTClftltYLCbDqLCq0/xQYu65sVI0pkYjzVTBcB0=;
        b=TCnzqj4CBtkthjfBwKcKwdpcC+v8ygi31M61zQiDJNTmD7LJnuwRFuk93aR63nGTZy
         QqVZqzuxGemVEs3Uf8RsGLRe2g+4Kd4jWBjrylLVprlBMdKjohY6K+1jjulFMenFgI0n
         igb90Z96GL20HQgRTbv/vgejNYEYUa6GBADR7jPF+AnwIjEyM4rMfS/OIdfj39sCm8sl
         61bfFp31oaoJadlylMdmCoaKtm2mGxVe1AEKiGomor9QN5h9NDMVlC7vXqiUPsKTFHto
         6YqPXSlomLaXjK8IGJ2IGORKCwjyfyfVlWaO8f4kFI3a7L6KKE4x4G5NdfjLlObTnGGX
         YvlQ==
X-Gm-Message-State: APjAAAUbEJ7uQV67TvnDNJVCNHP8PNkr9151I0dx3btNvirBNWZHL1UY
	mFlcLrk+B7ETiV41Fwcv2zh+9D3hfdseVL3h91AT3nHO6TgLovCEJIO0LQfUTt+F6ReA6LvI8M/
	rKul4HG9dJYRkH1dU+QXlHys8jmtz4G+brZlk8f+ESXkMQAhDo71WGHdi5iU8Hs+kTA==
X-Received: by 2002:ac2:5a47:: with SMTP id r7mr18546958lfn.116.1557249339668;
        Tue, 07 May 2019 10:15:39 -0700 (PDT)
X-Received: by 2002:ac2:5a47:: with SMTP id r7mr18546921lfn.116.1557249338937;
        Tue, 07 May 2019 10:15:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557249338; cv=none;
        d=google.com; s=arc-20160816;
        b=cY5m46rU5M1JuWoEADaxY/IB4YnJfR2/P/w4PEGwZchx6uLwl68/sT9vuV41K6r4qX
         +oL77PObVsSmoiJVfW/wpoA8PWBP5prZqAldjh6sGD7CvLtKbCaEf+KkvYyxQJPQJNMM
         eVCeZ3hV7r9XQPwSWpiUmgKHOWfheMiOrSXjSWjHDKohuvuOKywavKDY/ZQwe4hpCS9O
         o+fdK0Il4I1TGxu/yg06LPJisCEoFBaOep+zRRmyEemLmywqVcwHE4Fy1x19u0ypgId/
         Q70m0lBbO2cqQEff/TPuy2UlKo9kFYkDQ/mZa1GJhfcmScG4bwBk4UKKC/w+CTH5A0Br
         ce3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=pAvQTClftltYLCbDqLCq0/xQYu65sVI0pkYjzVTBcB0=;
        b=fJFdBy8UwIEhZn7zKmRGoTAHfTlgAN5b24sH6ZxTn0X7JK0T9LlHTUTyVoAybo+nrY
         eTkaZ49S1AiC9YTvk08phkSLp/rvU9b6Ov4mEXV5AA9LvTIHyreweBKdaDi9IhYWHMbK
         XMfLKm23ounC5IwMCRObjj3jptVMbNxgvQ1yLjR5zGz0lcTxl8tamHvnTYP5C+1GuGMo
         6vuw6kVl0DQreXE/jRH5diWIOl5ROrBNfOPI4ttZEGOQHngTb5vq9y4kch7QSZSXZpWF
         iwT1Np9a9UqTJqkVncd3BYNI7hrgMoMx+dHbGyVAVn88bgPmnGVnmUWG4FIv1MPLyDNj
         NaeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=NsaoLR6A;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z16sor3849452lfj.42.2019.05.07.10.15.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 10:15:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=NsaoLR6A;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=pAvQTClftltYLCbDqLCq0/xQYu65sVI0pkYjzVTBcB0=;
        b=NsaoLR6Ao9J19zGZUHECQ1qcF7jO6hioHJJfXFH7MjyM/ZZTDUiryrhvQk2YIHQ681
         EBOTavV5RShPc+LyF7LHGtUfsXEm9A5iJNtu5FInwxpehCTg0ugf5fdz41X0mZTg1qa6
         tJJWZ6eAmCN37uHbershG6h8l0gVd8ZV+wf1o=
X-Google-Smtp-Source: APXvYqxiQvbmBA0Sec/9CrcHnnOoqMAG6XhI6bxY83r8BsIJB3zJggzpovrO3pZislWlfsxMNDKvoQ==
X-Received: by 2002:a19:a554:: with SMTP id o81mr9022102lfe.117.1557249336869;
        Tue, 07 May 2019 10:15:36 -0700 (PDT)
Received: from mail-lj1-f179.google.com (mail-lj1-f179.google.com. [209.85.208.179])
        by smtp.gmail.com with ESMTPSA id f20sm3184792ljj.96.2019.05.07.10.15.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 10:15:35 -0700 (PDT)
Received: by mail-lj1-f179.google.com with SMTP id z1so2818122ljb.3
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:15:35 -0700 (PDT)
X-Received: by 2002:a2e:801a:: with SMTP id j26mr8769035ljg.2.1557249335169;
 Tue, 07 May 2019 10:15:35 -0700 (PDT)
MIME-Version: 1.0
References: <20190507053826.31622-1-sashal@kernel.org> <20190507053826.31622-62-sashal@kernel.org>
 <CAKgT0Uc8ywg8zrqyM9G+Ws==+yOfxbk6FOMHstO8qsizt8mqXA@mail.gmail.com>
 <CAHk-=win03Q09XEpYmk51VTdoQJTitrr8ON9vgajrLxV8QHk2A@mail.gmail.com> <20190507170208.GF1747@sasha-vm>
In-Reply-To: <20190507170208.GF1747@sasha-vm>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 7 May 2019 10:15:19 -0700
X-Gmail-Original-Message-ID: <CAHk-=wi5M-CC3CUhmQZOvQE2xJgfBgrgyAxp+tE=1n3DaNocSg@mail.gmail.com>
Message-ID: <CAHk-=wi5M-CC3CUhmQZOvQE2xJgfBgrgyAxp+tE=1n3DaNocSg@mail.gmail.com>
Subject: Re: [PATCH AUTOSEL 4.14 62/95] mm, memory_hotplug: initialize struct
 pages for the full memory section
To: Sasha Levin <sashal@kernel.org>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, LKML <linux-kernel@vger.kernel.org>, 
	stable <stable@vger.kernel.org>, Mikhail Zaslonko <zaslonko@linux.ibm.com>, 
	Gerald Schaefer <gerald.schaefer@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, 
	Michal Hocko <mhocko@suse.com>, Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, 
	Dave Hansen <dave.hansen@intel.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, 
	Pasha Tatashin <Pavel.Tatashin@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Sasha Levin <alexander.levin@microsoft.com>, linux-mm <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 7, 2019 at 10:02 AM Sasha Levin <sashal@kernel.org> wrote:
>
> I got it wrong then. I'll fix it up and get efad4e475c31 in instead.

Careful. That one had a bug too, and we have 891cb2a72d82 ("mm,
memory_hotplug: fix off-by-one in is_pageblock_removable").

All of these were *horribly* and subtly buggy, and might be
intertwined with other issues. And only trigger on a few specific
machines where the memory map layout is just right to trigger some
special case or other, and you have just the right config.

It might be best to verify with Michal Hocko. Michal?

              Linus

