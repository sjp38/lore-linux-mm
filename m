Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29C6CC3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 15:48:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBB3122CE5
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 15:48:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="PZ0HD3Y2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBB3122CE5
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6541B6B0270; Mon, 19 Aug 2019 11:48:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DF256B0271; Mon, 19 Aug 2019 11:48:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CCDD6B0272; Mon, 19 Aug 2019 11:48:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0091.hostedemail.com [216.40.44.91])
	by kanga.kvack.org (Postfix) with ESMTP id 24C5B6B0270
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 11:48:31 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id C7682180AD7C1
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:48:30 +0000 (UTC)
X-FDA: 75839609580.25.road21_675b83f5ae331
X-HE-Tag: road21_675b83f5ae331
X-Filterd-Recvd-Size: 6628
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com [209.85.215.193])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:48:30 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id p3so1440859pgb.9
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 08:48:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZA8BuBvs/hbur5A2af1dfs7zv3Ei9mj0dJpknoIQZUk=;
        b=PZ0HD3Y2zeoBC2zq5xuE6l3mXjwan01XY4nhIVdOCwkGN+nwuKAXafYOLL1EcyeH6L
         guxT7lPZIguUFZz8+wh65JBURxJpLGAkfzG8A4uKNyblf1WUlIar4sSkLUZlLedc7l8b
         Kkifxp4sdWxzXyg1r6oIp0pGHz3JRXUbvzxL88zaZDD3rbw9QZOH2O8jylbRgCyFULyn
         wKS2Wl26+PuJ2MiEsDh0j3wJSSTGRF9csTjf/IM4s15buWx2GvmeIyTAk5en+TK7/LRz
         2LEWmnUgk8vMJCOoTOgvmeVN8Uy8gvIfiQNNMQg5e614Buy5U209kXTc52yI4yRoRBcD
         ip6w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=ZA8BuBvs/hbur5A2af1dfs7zv3Ei9mj0dJpknoIQZUk=;
        b=tDlIu0JJ+nJmnM1xyY2/7hvnlUg3L/uvncvgAYc5F/dIUWGhWKS+dCW6pWPM6iz8hM
         8xzohfaN6ceMENOLXsHKm879T/3UnHohSMYGPcXhKMDDjqf3G5hhwFettuS0KU1d9tah
         mUPdrAJJqnPr2T3Uv5jYVE5+17XNtLYjF3/V0v+F/YwVnhlwaD2dnXv6CeKww1mFvPIu
         IdCdEYvfLqp5p54buJpl65VOAAA7aP1/MDwJRPxiLG/BNHk8Xg6vd+ryv63eIqITc8Th
         4etMx+mh+WIcID8qUABz4v+XQHUtiQwA1lqGHNzncPQuSuUDYeZ79pQ+PfoeBHZVaBHh
         AeZQ==
X-Gm-Message-State: APjAAAWF9j4mgDr+JsotXwFCbAmLg776JjvxBnuQFpfw4NQcoLmo7/+H
	8FukvPlhPFY9g2SRaCGrMYbrY65oCoB1uRJGON9LkQ==
X-Google-Smtp-Source: APXvYqwo1Y//ODybWVzSFI9UN2sBOGCtICrz2FP1xF+itsQOS80vSVdDi/mfEKruFfUtKA1F2Hx+OmLOBRNDL+KKy/0=
X-Received: by 2002:a63:c442:: with SMTP id m2mr72019pgg.286.1566229708817;
 Mon, 19 Aug 2019 08:48:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190815154403.16473-1-catalin.marinas@arm.com> <20190815154403.16473-6-catalin.marinas@arm.com>
In-Reply-To: <20190815154403.16473-6-catalin.marinas@arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 19 Aug 2019 17:48:17 +0200
Message-ID: <CAAeHK+xxsMkt=pU+ChfMYLQU4TqeL0c-f4PdN_KLG7sq6yKX2w@mail.gmail.com>
Subject: Re: [PATCH v8 5/5] arm64: Relax Documentation/arm64/tagged-pointers.rst
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Szabolcs Nagy <szabolcs.nagy@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Dave P Martin <Dave.Martin@arm.com>, Dave Hansen <dave.hansen@intel.com>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 5:44 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> From: Vincenzo Frascino <vincenzo.frascino@arm.com>
>
> On AArch64 the TCR_EL1.TBI0 bit is set by default, allowing userspace
> (EL0) to perform memory accesses through 64-bit pointers with a non-zero
> top byte. However, such pointers were not allowed at the user-kernel
> syscall ABI boundary.
>
> With the Tagged Address ABI patchset, it is now possible to pass tagged
> pointers to the syscalls. Relax the requirements described in
> tagged-pointers.rst to be compliant with the behaviours guaranteed by
> the AArch64 Tagged Address ABI.
>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Andrey Konovalov <andreyknvl@google.com>
> Cc: Szabolcs Nagy <szabolcs.nagy@arm.com>
> Cc: Kevin Brodsky <kevin.brodsky@arm.com>
> Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
> Co-developed-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>

Acked-by: Andrey Konovalov <andreyknvl@google.com>

> ---
>  Documentation/arm64/tagged-pointers.rst | 23 ++++++++++++++++-------
>  1 file changed, 16 insertions(+), 7 deletions(-)
>
> diff --git a/Documentation/arm64/tagged-pointers.rst b/Documentation/arm64/tagged-pointers.rst
> index 2acdec3ebbeb..fd5306019e91 100644
> --- a/Documentation/arm64/tagged-pointers.rst
> +++ b/Documentation/arm64/tagged-pointers.rst
> @@ -20,7 +20,9 @@ Passing tagged addresses to the kernel
>  --------------------------------------
>
>  All interpretation of userspace memory addresses by the kernel assumes
> -an address tag of 0x00.
> +an address tag of 0x00, unless the application enables the AArch64
> +Tagged Address ABI explicitly
> +(Documentation/arm64/tagged-address-abi.rst).
>
>  This includes, but is not limited to, addresses found in:
>
> @@ -33,13 +35,15 @@ This includes, but is not limited to, addresses found in:
>   - the frame pointer (x29) and frame records, e.g. when interpreting
>     them to generate a backtrace or call graph.
>
> -Using non-zero address tags in any of these locations may result in an
> -error code being returned, a (fatal) signal being raised, or other modes
> -of failure.
> +Using non-zero address tags in any of these locations when the
> +userspace application did not enable the AArch64 Tagged Address ABI may
> +result in an error code being returned, a (fatal) signal being raised,
> +or other modes of failure.
>
> -For these reasons, passing non-zero address tags to the kernel via
> -system calls is forbidden, and using a non-zero address tag for sp is
> -strongly discouraged.
> +For these reasons, when the AArch64 Tagged Address ABI is disabled,
> +passing non-zero address tags to the kernel via system calls is
> +forbidden, and using a non-zero address tag for sp is strongly
> +discouraged.
>
>  Programs maintaining a frame pointer and frame records that use non-zero
>  address tags may suffer impaired or inaccurate debug and profiling
> @@ -59,6 +63,11 @@ be preserved.
>  The architecture prevents the use of a tagged PC, so the upper byte will
>  be set to a sign-extension of bit 55 on exception return.
>
> +This behaviour is maintained when the AArch64 Tagged Address ABI is
> +enabled. In addition, with the exceptions above, the kernel will
> +preserve any non-zero tags passed by the user via syscalls and stored in
> +kernel data structures (e.g. set_robust_list(), sigaltstack()).
> +
>
>  Other considerations
>  --------------------

