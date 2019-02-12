Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D00BC282D7
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 01:26:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7ED0214DA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 01:26:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="kTOcJz2Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7ED0214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 691528E0009; Mon, 11 Feb 2019 20:26:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63F878E0004; Mon, 11 Feb 2019 20:26:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5069F8E0009; Mon, 11 Feb 2019 20:26:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1DB5B8E0004
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 20:26:23 -0500 (EST)
Received: by mail-vs1-f71.google.com with SMTP id 185so425036vsd.2
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:26:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=tjplqgKWE3Hxn72OdOjfAgA2B9kW+HOJdNRvmQcqtBU=;
        b=OjC2nUeTkv2oOU3WTaNAiZ4C82dbKc9DteqVmBtdTyRDz6SbGqhucqohNUpDzK/1mS
         yJsB4Hancfa5bvRN4Uw/L3GFB49qACRtknBdJ/GA1Xokc/hHx81S5TbMs3CrD1I1WFnY
         foZeUplut03188wVASTp9avLlnc2/pPTkp7zOd2ELka+RplVfGy0tLzQQLyce2KghCrg
         zgnroAxRKG3BiQFaCwpaVIaOXD1iQHNFXK0xPECFfy9LzwTHK9OcACB7sS9Umwo+ZhMP
         4BNpKX8+kIvr/mgxAembigoMT8KRIc8VnzcQZyukrBusgpDTtbjO3CjBhUnZMjoK8iRl
         kThw==
X-Gm-Message-State: AHQUAua6raEN1NyvIqzsHnWeqd3ttfdgsRR/n21I03LOd17vzLHG+cnB
	/twNKylnpRKtgYc1hOZomXZJpFVWKOpxlsI9VpFgUaT/e4fwZFzmkaaxwqKbx2/SY9DbSQmdA27
	sgZpZy6GeycvfVmF1+qZ/3Au/ktcva0cF9IyqZi3Q8/VPwwhLEN7YNabltOY4UZ60ibM2zgoty9
	mmuLn46ZPzbld6tHHjOzqzurwDwIoApSDHufh2NUVakdpdSYkFD4r3Ld396VMpVEb9mWlQ3Wz/l
	tCK/S+u1fGaLyT61w5oedzjzX/+xXwGrMjWc+B7NtHiLCdHvN8+xd7OtYc16bT6MsGajmRhiTRp
	tJ5WV3a1CBVOvQ1qkN8OssGzQsyNoD7UedxilJsET+oBZV27DYGvdKPm7qqlvN1iuJbaPmrpWIa
	2
X-Received: by 2002:ab0:729a:: with SMTP id w26mr528541uao.12.1549934782743;
        Mon, 11 Feb 2019 17:26:22 -0800 (PST)
X-Received: by 2002:ab0:729a:: with SMTP id w26mr528524uao.12.1549934781975;
        Mon, 11 Feb 2019 17:26:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549934781; cv=none;
        d=google.com; s=arc-20160816;
        b=Q4y2q8VVbuhrWg0JaGQfItgGA9zfh2rBR2cDq22Hl36xuPQwJYyStc0la95pWuB7ZA
         0OMLXsj2tHytJbWzY0AIPJVXL5/vBZIfailMKh+XSWyWei/lCLB0MV7U7zgdBJfYBfPs
         gNHfMaQ1IPWpWr+bebzT6vn6c1l0K8WxVxqaOdKdg4ZBrjEvOhk8mG+djeauscAIZhWO
         D5CUuTMoywGicL11DDdb53s7GFeqRna1wYxfREXk+weGLQS3g320QkggpwpjJZ6w8EPj
         drRXNHnNwuMW26EDh9PdbN6fWmHvkOWpBcvfOUQ65oQkfLkvdeC+kecEu7EP1yF/3mD4
         SRcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=tjplqgKWE3Hxn72OdOjfAgA2B9kW+HOJdNRvmQcqtBU=;
        b=o1Eqltj4KyCouo9EbjFe4X0CYbsl2EppY3xaKLtNPzd4UdinjUYE8Bv3fVnIRSNR2U
         EuQ8Ke4SM48YBmQIVvyYQOhupLcnc5JzoAQiotTlBR28HwoBt8KYL7vngMi6IV1HCAmE
         wE3IiXz0Zi7JQaGJSPaItE3SSUNiXKBe5qDrHLcr3+RKe+TXlhDNIoXCuEgQUlpak/9T
         DzXhrz7Y1/gJLsXrdHfDMsMr8aR3WBr5W04O/cEZYN6xqS5qZ44W3pNUCW0ZgyEOR/t/
         nEh9f1G4uyu3BdhA1eUZbjyq2lBKDH2hFi0RA2azGajH/X3dU3u7r7pas8k94JCUwMK8
         1dcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=kTOcJz2Z;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g7sor5105247vso.55.2019.02.11.17.26.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 17:26:21 -0800 (PST)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=kTOcJz2Z;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=tjplqgKWE3Hxn72OdOjfAgA2B9kW+HOJdNRvmQcqtBU=;
        b=kTOcJz2ZF73lKlesFnKYD0iEmI0plfu6EuXCcoJ6kJKDZPfjpJGUSCp3DuhQ6OELVg
         5HhafM/ks7gDn02lvD5VacZAtMTrAu5New5ehqSGe1dBNc+0ZaBWBxgdfn5RgePWCruq
         I4VRoypIEvm6GzpzCYX3K/JnpeK7DLkQ7GF4c=
X-Google-Smtp-Source: AHgI3Ib1M++s36GF8s5BUbyz4KitfWuhepEEovqAsdvOsLF+fH9MbFhWU1KQGVN9EIwOgK9P8AHK0g==
X-Received: by 2002:a67:7a44:: with SMTP id v65mr505892vsc.190.1549934781105;
        Mon, 11 Feb 2019 17:26:21 -0800 (PST)
Received: from mail-vk1-f182.google.com (mail-vk1-f182.google.com. [209.85.221.182])
        by smtp.gmail.com with ESMTPSA id a68sm12010111vsd.24.2019.02.11.17.26.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 17:26:20 -0800 (PST)
Received: by mail-vk1-f182.google.com with SMTP id t127so225483vke.8
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:26:19 -0800 (PST)
X-Received: by 2002:a1f:4982:: with SMTP id w124mr512476vka.4.1549934779282;
 Mon, 11 Feb 2019 17:26:19 -0800 (PST)
MIME-Version: 1.0
References: <cover.1549927666.git.igor.stoppa@huawei.com> <CAGXu5j+n3ky2dOe4F+VyneQsM4VJbGPUw+DO55NkxxPhKzKHag@mail.gmail.com>
 <25bf3c63-c54c-f7ea-bec1-996a2c05d997@gmail.com> <CAGXu5jLqmYRUVLb7-jPsN4onO5UNH+D6qOF=9TOiVjJa-=DnZQ@mail.gmail.com>
 <CAH2bzCRZ5xYOT0R8piqZx4mSGj1_8fNG=Ce4UU8i6F7mYD9m9Q@mail.gmail.com>
In-Reply-To: <CAH2bzCRZ5xYOT0R8piqZx4mSGj1_8fNG=Ce4UU8i6F7mYD9m9Q@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 11 Feb 2019 17:26:06 -0800
X-Gmail-Original-Message-ID: <CAGXu5jLRJZuWjnwEuK=7AMeCrj-eioVGksPL9dE9pbzHM=+Rmg@mail.gmail.com>
Message-ID: <CAGXu5jLRJZuWjnwEuK=7AMeCrj-eioVGksPL9dE9pbzHM=+Rmg@mail.gmail.com>
Subject: Re: [RFC PATCH v4 00/12] hardening: statically allocated protected memory
To: "igor.stoppa@gmail.com" <igor.stoppa@gmail.com>
Cc: Igor Stoppa <igor.stoppa@huawei.com>, Ahmed Soliman <ahmedsoliman@mena.vt.edu>, 
	linux-integrity <linux-integrity@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 5:08 PM igor.stoppa@gmail.com
<igor.stoppa@gmail.com> wrote:
>
>
>
> On Tue, 12 Feb 2019, 4.47 Kees Cook <keescook@chromium.org wrote:
>>
>> On Mon, Feb 11, 2019 at 4:37 PM Igor Stoppa <igor.stoppa@gmail.com> wrote:
>> >
>> >
>> >
>> > On 12/02/2019 02:09, Kees Cook wrote:
>> > > On Mon, Feb 11, 2019 at 3:28 PM Igor Stoppa <igor.stoppa@gmail.com> wrote:
>> > > It looked like only the memset() needed architecture support. Is there
>> > > a reason for not being able to implement memset() in terms of an
>> > > inefficient put_user() loop instead? That would eliminate the need for
>> > > per-arch support, yes?
>> >
>> > So far, yes, however from previous discussion about power arch, I
>> > understood this implementation would not be so easy to adapt.
>> > Lacking other examples where the extra mapping could be used, I did not
>> > want to add code without a use case.
>> >
>> > Probably both arm and x86 32 bit could do, but I would like to first get
>> > to the bitter end with memory protection (the other 2 thirds).
>> >
>> > Mostly, I hated having just one arch and I also really wanted to have arm64.
>>
>> Right, I meant, if you implemented the _memset() case with put_user()
>> in this version, you could drop the arch-specific _memset() and shrink
>> the patch series. Then you could also enable this across all the
>> architectures in one patch. (Would you even need the Kconfig patches,
>> i.e. won't this "Just Work" on everything with an MMU?)
>
>
> I had similar thoughts, but this answer [1] deflated my hopes (if I understood it correctly).
> It seems that each arch needs to be massaged in separately.

True, but I think x86_64, x86, arm64, and arm will all be "normal".
power may be that way too, but they always surprise me. :)

Anyway, series looks good, but since nothing uses _memset(), it might
make sense to leave it out and put all the arch-enabling into a single
patch to cover the 4 archs above, in an effort to make the series even
smaller.

-- 
Kees Cook

