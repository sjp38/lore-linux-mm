Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F679C10F03
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 14:16:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 313B320851
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 14:16:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="nOzc0ZgH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 313B320851
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A715B8E0003; Thu,  7 Mar 2019 09:16:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F9F38E0002; Thu,  7 Mar 2019 09:16:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 89C628E0003; Thu,  7 Mar 2019 09:16:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 42B7B8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 09:16:04 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id b12so16320321pgj.7
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 06:16:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=i3YjevPKe5ryG7PMnJzvSuvrHQ1PFxESlOhxwKo3nhU=;
        b=rjaknzBo/+TRx74Fr9UYfxu53FJk2ugk+MA5nd37/4d3jCd7poQxlmURUabzVX+aV1
         txdJjfchE1KRdh9LjEW4lXYIugjJ5i01fOBH3v6eKsVIFOxSeUP4YLbxKTl1jn4V9KvO
         NdH2tPztFIss+BM2VEbpLqAr1Ya8A7y3+bDnDfbHMc8k1802VD4uLQGiBSBCi23I6IL9
         YSUeuRS8J3ZtMvoL4OtZLTdIq7oXHcuuFSndz0yqMSN+ME1m4gWqBgGSd+09+jV9Afz7
         M+t3aw9x99V7fT+KLkxksPAxUYTW238ISVFYzDasuWA6ifjguVZPCABGvM2wxIDdmDdN
         jGWg==
X-Gm-Message-State: APjAAAU7IOOYssLqdIBY/11u/PeE8xMaAnywKvgDIaYOuCjs975NFqCM
	HiuxLoP6mx0GxAWPp0zPKrdPXC/iSnWFzBENmehiF9+6yqgUQDM5XgYzPaR96B9pnVxAr2HqTJp
	mejggxAzcq0vC39iniqkamQ5hF1usWRnPskcMKenR26xmz8DZfH61itpazzeH7qOevg2V4OaBLK
	5aXWGPJTqfwjWpb6b+BnZRWv5C6wGCI2Xmi/cwFR61E4Baz91zVNaY4EG2fKWXQWlU43DC1eFmz
	dg70iyk+fmfbztU0kC0PN6RPBLLjW7EBNfY4e54b9T9+/tsk2XriPmnLBEiNulK2dwjsZhrIBcH
	i12EbiM1IM98mLmIEejPf3FSjPYkb27nx4RQQ9hrRzN0K7kOGccWB8V2cPniCSFZU80CIeVlUiY
	i
X-Received: by 2002:a62:cf81:: with SMTP id b123mr13317360pfg.29.1551968163838;
        Thu, 07 Mar 2019 06:16:03 -0800 (PST)
X-Received: by 2002:a62:cf81:: with SMTP id b123mr13317278pfg.29.1551968162799;
        Thu, 07 Mar 2019 06:16:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551968162; cv=none;
        d=google.com; s=arc-20160816;
        b=zMlE4XDKgzEjJZ1ngwv7dv9wA2auNhO/Hjw3wnLGdba4vGacZg30JYSkPD7aVTAN7P
         RB5GUgjhLwdU1g3JfnWEB32hmVe1A6J36KuHPoClwkYvGyNjsmHEOJ9AgaTWZJJwVGiH
         byvuyngxYmCYFto+WZzNNB0SOlqXTZMS25a+MjeqeUfbPA0BawRWwSQz2ZOkfDiPAAyt
         T8mL02EpECfvlm+UowNSD53Kh59tv+9QiUy3bsC7/NiG/U5aZG6W10aqkTAR93f9Bb4t
         pNU5pz+8mljNAE0BvE4CMW1kegMF92G69uQZzdYopZkUSH4pS4z4axDpbJEyMOuN5+z5
         46Rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=i3YjevPKe5ryG7PMnJzvSuvrHQ1PFxESlOhxwKo3nhU=;
        b=MVseVacnT4ESZBdWTlgufalsJtvBx5oYNf9ZXLBtVWDX5inf83ggAiJRnctsI9R7Md
         am1u7lUWK5oi3SZTeJoFzx9HFt6icxSCbV/1DWuFk2KAynPe2x+AdWhl7rmADUxarvg3
         VgjTCjOo/Za8JKBKIayWpgQXrB9MVuMZX4eR4FN5dPZZT29lArZXFJzK+m1RZdL80Dso
         mGc/Wr4jFfDBit2TlGUYBW6pUOGd/j7Rdyo2eWhDzIn1hB2oc4/kdngEN3l5H0yfIWXA
         YszYbx51O/9sgwb8BXd5Hsmc6VwXpi3HOvq/delC5SjqqPQRmOGp8ADUN+aN1Z1QI2uz
         MaTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=nOzc0ZgH;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r3sor7531351plb.63.2019.03.07.06.16.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 06:16:02 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=nOzc0ZgH;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=i3YjevPKe5ryG7PMnJzvSuvrHQ1PFxESlOhxwKo3nhU=;
        b=nOzc0ZgH5uBvLhDiaQpMFbb/5GWPBuo71xtt4Bt1Q6e/NTXq2bifX2/B8e76Pc09FF
         vnCCNg+5x5cegGV2n3ASoANsCHcjsS/Wx4k3IVg6PV1Png88HX2afdBJSVTaDjpnfIbr
         Sp0OiyXIy8mN2vHPZM4lAabasxlbEOVk3mzPIImZQ62SBedija96gCyAMJYAGULpPRla
         +FBAzTxnVa03jndOInQ5jRZEsT2fWM/MQLRXM3j1BEyMAShatYombYd75IfkjuhUyLLx
         KIc7C3buq3ZKqoGbXOCqC0+zdffbKMsQKy5Z/QzkM7k+3RcObCv2ZrbynEEACj/teBLQ
         O61Q==
X-Google-Smtp-Source: APXvYqwPFLUEovt7Ku8gsXn9f+OFSQuf4QYU0WTFTFWbzXz/Gzjw8CmzBUbXZsS5Pk5oCo1qq7772OyvE43vnbl9TBQ=
X-Received: by 2002:a17:902:8303:: with SMTP id bd3mr13313098plb.10.1551968161942;
 Thu, 07 Mar 2019 06:16:01 -0800 (PST)
MIME-Version: 1.0
References: <20190307075124.3424302-1-arnd@arndb.de>
In-Reply-To: <20190307075124.3424302-1-arnd@arndb.de>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 7 Mar 2019 15:15:50 +0100
Message-ID: <CAAeHK+zf8PWWURcrKe-G6HrpL=1w96fF+5zHkDr5AEJUOXAv=Q@mail.gmail.com>
Subject: Re: [PATCH] page flags: prioritize kasan bits over last-cpuid
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 7, 2019 at 8:51 AM Arnd Bergmann <arnd@arndb.de> wrote:
>
> ARM64 randdconfig builds regularly run into a build error, especially
> when NUMA_BALANCING and SPARSEMEM are enabled but not SPARSEMEM_VMEMMAP:
>
>  #error "KASAN: not enough bits in page flags for tag"
>
> The last-cpuid bits are already contitional on the available space,
> so the result of the calculation is a bit random on whether they
> were already left out or not.
>
> Adding the kasan tag bits before last-cpuid makes it much more likely
> to end up with a successful build here, and should be reliable for
> randconfig at least, as long as that does not randomize NR_CPUS
> or NODES_SHIFT but uses the defaults.
>
> Fixes: 2813b9c02962 ("kasan, mm, arm64: tag non slab memory allocated via pagealloc")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  include/linux/page-flags-layout.h | 14 ++++++++------
>  1 file changed, 8 insertions(+), 6 deletions(-)
>
> diff --git a/include/linux/page-flags-layout.h b/include/linux/page-flags-layout.h
> index 1dda31825ec4..9bc0751e68b2 100644
> --- a/include/linux/page-flags-layout.h
> +++ b/include/linux/page-flags-layout.h
> @@ -76,21 +76,23 @@
>  #define LAST_CPUPID_SHIFT 0
>  #endif
>
> -#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
> +#ifdef CONFIG_KASAN_SW_TAGS
> +#define KASAN_TAG_WIDTH 8
> +#else
> +#define KASAN_TAG_WIDTH 0
> +#endif
> +
> +#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT+KASAN_TAG_WIDTH \
> +       <= BITS_PER_LONG - NR_PAGEFLAGS
>  #define LAST_CPUPID_WIDTH LAST_CPUPID_SHIFT
>  #else
>  #define LAST_CPUPID_WIDTH 0
>  #endif
>
> -#ifdef CONFIG_KASAN_SW_TAGS
> -#define KASAN_TAG_WIDTH 8
>  #if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH+LAST_CPUPID_WIDTH+KASAN_TAG_WIDTH \
>         > BITS_PER_LONG - NR_PAGEFLAGS
>  #error "KASAN: not enough bits in page flags for tag"
>  #endif
> -#else
> -#define KASAN_TAG_WIDTH 0
> -#endif
>
>  /*
>   * We are going to use the flags for the page to node mapping if its in
> --
> 2.20.0
>

Reviewed-by: Andrey Konovalov <andreyknvl@google.com>

Thanks!

