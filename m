Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3886FC04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 15:59:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE88E204FD
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 15:59:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="OzkQiwAz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE88E204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33C166B0003; Fri, 17 May 2019 11:59:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2ED326B0005; Fri, 17 May 2019 11:59:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DB446B0006; Fri, 17 May 2019 11:59:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D99756B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 11:59:42 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e20so4803389pfn.8
        for <linux-mm@kvack.org>; Fri, 17 May 2019 08:59:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=INvyXgRgpc11QEZcWPLU82BNdrovIrWqBF0OwWnNsfE=;
        b=Gx4nshKJKR8jgxFLG011oHvGzJQ0nTRkEjUS7t3g3tw4OKQlxkxNvjprV89GYH2QZz
         DggEEqHmC6ILmx9eK5tauB6bNtVIbBppEsyg2b16639uCaK4RaE4gNofBKp/gNZw8tK5
         LBSQlsJvTHQxO/xe8mfJn1bukugZLEuJidvno8OCzc4E52YeneMbRQd3hOY36wAI7a3B
         80Q1W37UQw1DaGUgcgdCbPe/s3z9RBvylGhUaWzgg7DtCTss+4LSOxG4mVmPjsri7Odw
         XInTTPQIiL+AQzy9LBTa7CFgcY1Zy34fpRD9GzyNQ3oA3JZ+gVThGw999qBqUdaJpQuT
         s6hg==
X-Gm-Message-State: APjAAAWp8M4lQ3IKi4IqH60XoxOqLhoF2BLfJKb/xStSez+O9IyetM0X
	OHZ9zd6RKxXtrYVxe7ZqytbqSVyJNy7cWHzvnaISHxqJETh+HsENnv2Is/CbPa4ziy6oF1LG03O
	9KIiX7UGsBYiDes/ajTG5wGQdkZnc82mMV31wFsizMLKqRsjlb+nyx9h7dptz+53gZw==
X-Received: by 2002:a17:902:ab98:: with SMTP id f24mr56528671plr.223.1558108782456;
        Fri, 17 May 2019 08:59:42 -0700 (PDT)
X-Received: by 2002:a17:902:ab98:: with SMTP id f24mr56528634plr.223.1558108781831;
        Fri, 17 May 2019 08:59:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558108781; cv=none;
        d=google.com; s=arc-20160816;
        b=TnBIwe6V8F+bIXnKb+ytwuwecamdFxGwlz11nK1IRU1nYX7HWCumCZ6X+oIh63viqn
         6wsov4iZgejfsx2Is+4kkhTG8FcsIyoJjP9yG7r8YNni4k6kgSzx9gTLAgfnq5gZcl8m
         KxZ2s1ziE5P8kBReasFcrs/yqhbeYe/ZEpBV59Mvj2IG3FArthajAjHe6LCBhEL05Yh2
         VlIpplJAOMLCX779YtsYcj7lYcTBiHFxjup68zczTQ7wx/EJETpk3ctY45UxqvwHshlp
         VwkmZXXrElxbWEdf+iKCR607BZ5HSVidnN/Y0E6amaN13293HiTUdNT++ABCtwFV+T8W
         ORjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=INvyXgRgpc11QEZcWPLU82BNdrovIrWqBF0OwWnNsfE=;
        b=gZTM++hjzy098+47cZs9p6sKiI+pdNdYr/wY8NOyjyLaOtHMw+M4N0NERNTsPKbAB6
         +YQS0dhMBx0FnuJJjVp7rO71M6hAsJpUNXkJmMCovF0K+enMiIMlCMZ5hFzecgje9ejH
         Vl/kgpjNJTi1OngMnnqWa+GGa/h3E/ausmBPLM0xAIldR9YH1wCw1o/wacxMN4hTG8xu
         vyB0ILmXU9WBA+2IVqUmHGyosAmpgnLfeKOoxqUDn8Zf468fZlPNVGWp8lAGPdNmMoi6
         6RpBzqQlVCKx2DNNcEGlMUu9olkaF/j/M6UY8E4umPjh4TxhfSyKKfeMkmxSMzKYWE+o
         YIgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=OzkQiwAz;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l96sor10113688plb.68.2019.05.17.08.59.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 08:59:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=OzkQiwAz;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=INvyXgRgpc11QEZcWPLU82BNdrovIrWqBF0OwWnNsfE=;
        b=OzkQiwAzJuMdG5Dif12dSl+nTEipCyWX7+SdFof6s8LaG66yLc+ruN0gDAGBN3TefY
         bbuIBXARgwmT4asXLVzMmCU0JRbt6/7DH9DwiCiJAnIJzLM1zPJP0ntHL5Ncxor2ZBxm
         kAshtNmIfG7mixRQlpwxZ/vwWgWZBCTFL4juE=
X-Google-Smtp-Source: APXvYqxjjymERosAhEH8xGgc+gUj/iwHDQd5pedl+FQfW0PvQNBci/Cem9LJMaQfelInYHey+/OBlA==
X-Received: by 2002:a17:902:7892:: with SMTP id q18mr12777643pll.163.1558108781558;
        Fri, 17 May 2019 08:59:41 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id z14sm6716152pfk.73.2019.05.17.08.59.40
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 17 May 2019 08:59:40 -0700 (PDT)
Date: Fri, 17 May 2019 08:59:39 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Kernel Hardening <kernel-hardening@lists.openwall.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-security-module <linux-security-module@vger.kernel.org>
Subject: Re: [PATCH 5/4] mm: Introduce SLAB_NO_FREE_INIT and mark excluded
 caches
Message-ID: <201905170858.CE4109E77@keescook>
References: <20190514143537.10435-5-glider@google.com>
 <201905161746.16E885F@keescook>
 <CAG_fn=W41zDac9DN9qVB_EwJG89f2cNBQYNyove4oO3dwe6d5Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=W41zDac9DN9qVB_EwJG89f2cNBQYNyove4oO3dwe6d5Q@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 10:34:26AM +0200, Alexander Potapenko wrote:
> On Fri, May 17, 2019 at 2:50 AM Kees Cook <keescook@chromium.org> wrote:
> >
> > In order to improve the init_on_free performance, some frequently
> > freed caches with less sensitive contents can be excluded from the
> > init_on_free behavior.
> Did you see any notable performance improvement with this patch?
> A similar one gave me only 1-2% on the parallel Linux build.

Yup, that's in the other thread. I saw similar. But 1-2% on a 5% hit is
a lot. ;)

-- 
Kees Cook

