Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1904C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 12:16:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88655218D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 12:16:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88655218D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A2138E00DC; Mon, 11 Feb 2019 07:16:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 251568E00C3; Mon, 11 Feb 2019 07:16:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 177998E00DC; Mon, 11 Feb 2019 07:16:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C6B5C8E00C3
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 07:16:02 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id z10so9320090edz.15
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 04:16:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=I7/yNyu+2IJ2q7QXlZvOhANxYDKHh2V3pd1syq+Xlyw=;
        b=UacXEJoViR74eWPm5sedor08pieA6ZvnXRvumkZvoYCFviLzpCa1wKaW2PE6CN6fKB
         upVIS/Dw/rOzJZVgmndObyNEl373blh6AO/pJmyuYeJWGO4SC1QS4R5877+NW9qjON8a
         rgiFOPUFei7YZOZ78t6nBLU1Y6VLqnKoOXZuXFNkUn5Cu3dkdIKACn6vZ/gb+DC6GG8w
         qir+RacgxteMF4/UFvT3lQ4frmB2kqMmSFIez31jiPSA0ax9OqJ2KiK3K/OHDxVRGkeJ
         qnoBKFbxGHIkIEe+02umJhntqTJXs5/x9XpQ77G5dUGWRFEh7qERDk7rfsO4MgrHf1q9
         yAqQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: AHQUAuar0qvG/MvKsxQkjMYRsrOxsNjf3x3YkikBKHJdCyPVO3AqvDxR
	W1iA4Xl2KhidoMlZ9r7rSI4it2S5JXxoKm8G3Z0ApMAnCIXTEz3IKxgJVl0SHFmULy171CMD1ET
	atJ4BTs2fdihIL48xVaVYj0qgDV/JlnwV21b7exaUpDSHGdcQzjxhcvol6EckYc2xSQ==
X-Received: by 2002:a50:88c1:: with SMTP id d59mr29018175edd.200.1549887362383;
        Mon, 11 Feb 2019 04:16:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IafDnLgsxJddOz8CTCGQwMPfZwMeF8Ammpy5LiC1eChHZDCNCtp71NhUnnpylppGZHLaiRd
X-Received: by 2002:a50:88c1:: with SMTP id d59mr29018125edd.200.1549887361564;
        Mon, 11 Feb 2019 04:16:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549887361; cv=none;
        d=google.com; s=arc-20160816;
        b=IAD1JF6Rcmb5Fdxf8N2/2sipjwQolGiWR9/jki12/DpGqeRJdXxlUy6+VOmyH7lQd6
         Pi2s9W4nE//X8GfO2YLzh7dl1PEbyokCkGZF6r/r8oszRLM7AcFUNySMHfhXm/5fa0Cw
         spkMBLyXfZA5Di8DDoqDS7Iok3gPJceGAAMw83UfWDn7uzfOZ4Xqv728dW8+XP1Hp8dp
         VYC/0/hLMWCZB0Jmsfxrvr+Xwu+dyaFSwzXGD+mb8HFaYfZqyvjGqMJ52mlTT8PaJBkl
         V9suAyoCx2I68pjnit5wvUsbbzR3EnSoaJc/cotnz4SdyA+gN1lb75APvxe2wObK/BeB
         i6Vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=I7/yNyu+2IJ2q7QXlZvOhANxYDKHh2V3pd1syq+Xlyw=;
        b=H0E248wkTjfTid81fcXGryv4EL6s6JehB6//Lz2hoEqfpj9ZUNqUj9BkjDr0rJ7Lay
         U16oV1m4nIY7L3F6C4XWVYyubPjAaEO9WHnATsbTnwyAalJSglB8fprUB406ngj74eEr
         H7RHixO/EfGz9UWcANdZdBP7QyPL1fAtK8HCQ8vt0A6IFrpf1i8rckzxt2ErYzPE9lCW
         /vLcri5RfE0NMU+JGlSIHMrgCsAiOm1nf6ScXiwF+bq5LnFLQWSfXS6p6PTujVXcOf4N
         +X0na69rihG3+/gBpgruUg3sp+fU5tx8z73kB34+9V/eMs2Y0W6ZDLgIJU/qea6WZkgC
         e8BA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b43si1636038edf.182.2019.02.11.04.16.01
        for <linux-mm@kvack.org>;
        Mon, 11 Feb 2019 04:16:01 -0800 (PST)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 49AA980D;
	Mon, 11 Feb 2019 04:16:00 -0800 (PST)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C41B23F557;
	Mon, 11 Feb 2019 04:15:58 -0800 (PST)
Date: Mon, 11 Feb 2019 12:15:56 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Qian Cai <cai@lca.pw>, Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	kasan-dev <kasan-dev@googlegroups.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux-MM <linux-mm@kvack.org>
Subject: Re: CONFIG_KASAN_SW_TAGS=y not play well with kmemleak
Message-ID: <20190211121554.GB165128@arrakis.emea.arm.com>
References: <b1d210ae-3fc9-c77a-4010-40fb74a61727@lca.pw>
 <CAAeHK+yzHbLbFe7mtruEG-br9V-LZRC-n6dkq5+mmvLux0gSbg@mail.gmail.com>
 <89b343eb-16ff-1020-2efc-55ca58fafae7@lca.pw>
 <CAAeHK+zxxk8K3WjGYutmPZr_mX=u7KUcCUYXHi+OgRYMfcvLTg@mail.gmail.com>
 <d8cdc634-0f7d-446e-805a-c5d54e84323a@lca.pw>
 <59db8d6b-4224-2ec9-09de-909c4338b67a@lca.pw>
 <CAAeHK+wsULxYXnGJnQXx9HjZMiU-5jb5ZKC+TuGQihc9L386Xg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+wsULxYXnGJnQXx9HjZMiU-5jb5ZKC+TuGQihc9L386Xg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 08, 2019 at 06:15:02PM +0100, Andrey Konovalov wrote:
> On Fri, Feb 8, 2019 at 5:16 AM Qian Cai <cai@lca.pw> wrote:
> > Kmemleak is totally busted with CONFIG_KASAN_SW_TAGS=y because most of tracking
> > object pointers passed to create_object() have the upper bits set by KASAN.
> 
> Yeah, the issue is that kmemleak performs a bunch of pointer
> comparisons that break when pointers are tagged.

Does it mean that the kmemleak API receives pointer aliases (i.e. same
object tagged with different values or tagged/untagged)?

-- 
Catalin

