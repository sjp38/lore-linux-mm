Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCFF1C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 14:58:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 940C9213A2
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 14:58:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hsRJrUHq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 940C9213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 299B88E000D; Mon, 25 Feb 2019 09:58:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2485B8E000B; Mon, 25 Feb 2019 09:58:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10F328E000D; Mon, 25 Feb 2019 09:58:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id AEC438E000B
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 09:58:29 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id z4so4933042wrq.1
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 06:58:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:cc:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=uJhUITq2u/XnWyfYZi+lNHkONgXV3v19wgzLCI81/Oo=;
        b=kGhi8XhRaFrTIeU3pYbeMkFgrvLXBHtSX46omoF2H5MNdI4XpI6tXP2QJ0Z0fl1DLH
         FXdFfUYuVLMprIK3jHwLmZ4NToXu7/QXPqMTBoCbWFV2nz22liGwJ/wSPJ+zflZZzLnr
         GFuQ4nWAbuJI9H4sIZysHTSMnCrn5Fp0NfsZZim9wBFhDhfdUQlspuXaIDwT5+2oIqvm
         T32e7ZPH/sY9FzCBcIh+S2lFMRD0yrds3YP3TtBO4/v8t4I/2JLLr+N6N2srhFReWHPG
         U9vCoyDMaoKyh9NfKzik1CD4Ukl+Ki+dlwRTnmkw5jLBLmOXL3OFIRL7cLrWwQUH0qwG
         /WFA==
X-Gm-Message-State: AHQUAuaL11uEVNMWS+XjT4nNU0qp0Liv0MC8F5elI1/WCoUrcnkdXPQA
	cCKtDBau4CvXSQ0Tn3BQC7SzDsNEbN4ZXLxgAtvXQRueZhy2tzR13NxwaJZEzpB9buT15kcU6Tz
	XmRGSGOgdihD6xj5sw+9fH8IHFq8gAuGvfxvkJIWWM9UpATkgye9+bFeoZE1WLROjH8eS/9LEW9
	vp69RaC1uD7RIEqSk2haEZ8Npa2WvHIF4ZCQlhVtYU2OCSsqupj39cJiTXrmjF2CatApREA7xnC
	ElkpYZcROiS/GEfM3HpC9rtJQXwtf4l/sKb3StBzj72WAQfmWbPCtkjQ/ZVUGZLPcMWqNCJl33U
	J+OR28Wfh4WBDO1204DyJHtUR45ulcNeB82C5ggXTTYrUF3nes//QpQU4mzhF8QlrWgc1lT071T
	Q
X-Received: by 2002:a1c:2dc9:: with SMTP id t192mr9605754wmt.119.1551106709195;
        Mon, 25 Feb 2019 06:58:29 -0800 (PST)
X-Received: by 2002:a1c:2dc9:: with SMTP id t192mr9605733wmt.119.1551106708380;
        Mon, 25 Feb 2019 06:58:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551106708; cv=none;
        d=google.com; s=arc-20160816;
        b=RkM/Bx00jNE4jluO5jAwkScdLt2vaPJzyermUMbjzK0NE+Jem90v8/vAohjY33Onja
         i20FjJ7koQl/Q6AGegkV40GYrZspYRAa/k5YKTtBM48nGXft2GwwqzZifraHGONIg2/l
         j/N4OxlFrl3CEt5V03vmy7V7A8mb7Le2VaHvOgIwWOQDj6Fjfq3hPjPh5Gr7Dgplv32y
         1e/LkqJxITZcfhJ4nrc7EJaDV8+C6UPbw1PM/5xbpobt552EJvghG1VCUGiKFLj8Svyo
         pcGLvB35LdmRh7R7+iBSp/v3riaglIpb6NRL6hpzhxSaqWVkfuDsVcvt2+M+orFZJCuj
         e9rQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject:cc
         :dkim-signature;
        bh=uJhUITq2u/XnWyfYZi+lNHkONgXV3v19wgzLCI81/Oo=;
        b=dMwUmx0i/lYPtIah+f4+9hCKT5C9TOqYZSun2UejG7CZWRVBc4aK967HuDazYMVf+Q
         uNyiJQGB+IdCvkreMUZ/f8sPewHfibxPRjM5GwPSWw/xRrYIZFVbOfzYqR3Zai7B785j
         qh+Ei69Te56nRmhJUfm8RuDSlVVzsaBXHl6np/jb6XVbHnJjGbnE4mGlGAkyvUc+Jg9z
         ATQHZdMLAmJSn1wSNt6InjDvhIJSY3SYkxD5B3dAIuOSEKIpJxHcJIEIkA23wEDp15X2
         KkerZqiBxqtqzYy+/Ez1wKu7DMe+9ZfPDLYB8jHc58y4BrRKHu6tbx9KXck3cgvjNZcA
         v/cw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hsRJrUHq;
       spf=pass (google.com: domain of mtk.manpages@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mtk.manpages@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h3sor5220415wmf.7.2019.02.25.06.58.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 06:58:28 -0800 (PST)
Received-SPF: pass (google.com: domain of mtk.manpages@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hsRJrUHq;
       spf=pass (google.com: domain of mtk.manpages@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mtk.manpages@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=cc:subject:to:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=uJhUITq2u/XnWyfYZi+lNHkONgXV3v19wgzLCI81/Oo=;
        b=hsRJrUHqOx5Jlx3YGRAjnati9Bl0au83O6Rm8zHr4mzAqjRqFPDmPg23DEFSO/SGzC
         QLUtbEASaN7YylB41NayEL38IAGg+SKRLYs5pqRmBECx5SILW37QFRGjsZitRU9jwXZX
         M0CyLQ8YlWG0pJ6+IsPM43VMFYBVNGM/xag4vktcYEfr+B4tnsBfeChwjH0JXOazb/V5
         odRWf5MQWAkfVGvvGPN+jWSPOW9X7ufLzlBnkI9FNMg0HidXVcMqvKQ13mVCkCIE0kk1
         ReD3/K9oA5Vz/j9r8ndYtmBypd36Qyjf0RrymyuRbKGuZichrjrdJhy003nHstEeiBzd
         QjJQ==
X-Google-Smtp-Source: AHgI3IY1zwkE49Y08r3OQl+GAkuCSBCw7KkAmFJpkoI7RDoXlWmjXI6KEWnxFJx/m14ebPHHePF6rg==
X-Received: by 2002:a1c:2082:: with SMTP id g124mr10380838wmg.59.1551106707958;
        Mon, 25 Feb 2019 06:58:27 -0800 (PST)
Received: from [10.0.21.20] ([95.157.63.22])
        by smtp.gmail.com with ESMTPSA id j41sm29447436wre.9.2019.02.25.06.58.27
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 06:58:27 -0800 (PST)
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-mm@kvack.org,
 Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mmap.2: fix description of treatment of the hint
To: Jann Horn <jannh@google.com>
References: <20190214161836.184044-1-jannh@google.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <c81aa639-a9da-f9b2-cb08-5915d63ba833@gmail.com>
Date: Mon, 25 Feb 2019 15:58:26 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190214161836.184044-1-jannh@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/14/19 5:18 PM, Jann Horn wrote:
> The current manpage reads to me as if the kernel will always pick a free
> space close to the requested address, but that's not the case:
> 
> mmap(0x600000000000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
> -1, 0) = 0x600000000000
> mmap(0x600000000000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
> -1, 0) = 0x7f5042859000
> 
> You can also see this in the various implementations of
> ->get_unmapped_area() - if the specified address isn't available, the
> kernel basically ignores the hint (apart from the 5level paging hack).
> 
> Clarify how this works a bit.
> 
> Signed-off-by: Jann Horn <jannh@google.com>

Thanks, Jann. Patch applied. And thanks for the review, Michal.

Cheers,

Michael

> ---
> changed in v2:
>  - be less specific about what the kernel does when the requested address
>    is unavailable to avoid constraining future behavior changes
>    (Michal Hocko)
> 
>  man2/mmap.2 | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index fccfb9b3e..dbcae59be 100644
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -71,7 +71,12 @@ If
>  .I addr
>  is not NULL,
>  then the kernel takes it as a hint about where to place the mapping;
> -on Linux, the mapping will be created at a nearby page boundary.
> +on Linux, the kernel will pick a nearby page boundary (but always above
> +or equal to the value specified by
> +.IR /proc/sys/vm/mmap_min_addr )
> +and attempt to create the mapping there.
> +If another mapping already exists there, the kernel picks a new address that
> +may or may not depend on the hint.
>  .\" Before Linux 2.6.24, the address was rounded up to the next page
>  .\" boundary; since 2.6.24, it is rounded down!
>  The address of the new mapping is returned as the result of the call.
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

