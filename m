Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CE31C28CC1
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 18:43:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17B2023F61
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 18:43:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="jegnb+b+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17B2023F61
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A44436B0266; Wed, 29 May 2019 14:43:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F3A46B026A; Wed, 29 May 2019 14:43:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90B0B6B026B; Wed, 29 May 2019 14:43:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 588906B0266
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:43:11 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i8so2515803pfo.21
        for <linux-mm@kvack.org>; Wed, 29 May 2019 11:43:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=EfGbBMHYGMmn9vTu990IJy1DO6Nzjk593nZn1dz4oVk=;
        b=AR4ALnd3GZHTRI6T84lRmCDrhKwMuvROwQ9PCuo15JljblCx4lnUfCecGFBNshYXsb
         l/bFUF/LG4EWSwxWR7woqasKDJJTnLmuBt2O7bScxbU1HddklMMpSP7Jy/ODzpKJ418y
         tP1KRUGOjRqyh0lQIrTidlpGEATFDk94kornm9OmXyq54HTqwF9H+zWVQgrlbKiMO+W2
         IUuLvH5hUCmIH1EsZaxKsCnm6jjp5+nlexALlVyya4TOORdmM3rWave9uZXOkXFftmRB
         OEsQcVoX0+oS7m45POSpPWujvw9333dE+EV/MAtSsZI1I5Icy63CnmagrETNaHbTeLpE
         Z3pQ==
X-Gm-Message-State: APjAAAXXtS4qJWqQR6irNGadQsvatRXpCfTshR7FfFcvRY28tzejm9c5
	cpVfS/8APloliepKMzqco2pVegCmpqDSgramh1hUk+cijnxnDBIWgjNbGLGigT062zBkeR8Qlgf
	xBLHQTt9Do8OTSxe0M+ziy9brISruGF2CN9o5bPi18bysxyzF60i3i6byqMgsVCVjWw==
X-Received: by 2002:a17:902:7883:: with SMTP id q3mr68633219pll.89.1559155390888;
        Wed, 29 May 2019 11:43:10 -0700 (PDT)
X-Received: by 2002:a17:902:7883:: with SMTP id q3mr68633154pll.89.1559155390086;
        Wed, 29 May 2019 11:43:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559155390; cv=none;
        d=google.com; s=arc-20160816;
        b=V7bSr2JEog1VsC6p3yxvgu8YwTwrmfv5VKadrfb5YZV+YiuxnPUZ8AxSwP3GVYTnqo
         qe0ak2+wxS5JfuLHKFzqqT0L/6XUbwl3jb+hSjN8eCwoHHoxKwtCPBlVHfdkzDUZedi4
         EQoxwP9iFmP1EJRHsx87s/vk94LODfbPNetkhEogo/1B/uhEW1RzDigLDPzhK/ySnj3r
         90L1+1PmNxssQz5x2bNYoby2xCpYvOZk0B9+8PhxQWtzdnTMMtRMr2Q87+9fqzpjZv0p
         a1Td55rggKejO4FWbZlSHsuwfcOX+Pcd4Buo+FZOpo6xCXxn149YC+DiE562q5PwOot2
         2+dA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=EfGbBMHYGMmn9vTu990IJy1DO6Nzjk593nZn1dz4oVk=;
        b=ilWsQzlco9I3Hxhd7jtQcRl4u4pX3uzMhxHn/uNT5CYGZqn0royXtPCF1UTfKa8hZG
         yZ7MvDa8Vv8cOf8ruRJtSo8UpFlaDPByzwN8kH9UCWRCUAE656pcBvaT7DVeIKcq37L1
         jR5hUXeo9CSnyo/1EbMWGWiRTKE5gD1FpwRFSdEbcR7A5geJUW89Xut9aTwTQye86/YW
         /smmdZDMQxwup5UyqBC7pSB9fAieKsBZ1HQAHZk3D9xq2nHzQ/WJemFmBbmiSLqv0Sn7
         47QdtBY9rDL7I3jx0U3iZmHT48GNpPbNrWXROuYMAV43OBuJ9T9jyIuV5OT33Vn9jW57
         S5RA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=jegnb+b+;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ba12sor223435plb.64.2019.05.29.11.43.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 11:43:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=jegnb+b+;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=EfGbBMHYGMmn9vTu990IJy1DO6Nzjk593nZn1dz4oVk=;
        b=jegnb+b+gX//d0vhP3uQvq7x+sAF3QEmogXo39wiwjaOrMNfZo1hXe3LqWwdyTlEGP
         sLjJiDBuOiQ5XbLD/BthT+9Q0e3xSRma3rzkzRLE/SH7g1hdl3RHi25rlwNs1z+/ZU5g
         y/2mNWS5Qnps3vAMakm3FhuP5d/GjDu0t652o=
X-Google-Smtp-Source: APXvYqzpr7CoVb5BM/Pz1u+mLgd3ASb0jPnJQzj1N/X5EKbeo05UJH/jb1NCHGZzD/mmLzqv8VLj5Q==
X-Received: by 2002:a17:902:7c08:: with SMTP id x8mr5907075pll.159.1559155389784;
        Wed, 29 May 2019 11:43:09 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id q6sm393246pfg.7.2019.05.29.11.43.08
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 11:43:08 -0700 (PDT)
Date: Wed, 29 May 2019 11:43:08 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	James Morris <jmorris@namei.org>, Jann Horn <jannh@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Laura Abbott <labbott@redhat.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Matthew Wilcox <willy@infradead.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Sandeep Patil <sspatil@android.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Marco Elver <elver@google.com>, kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org, linux-security-module@vger.kernel.org
Subject: Re: [PATCH v5 2/3] mm: init: report memory auto-initialization
 features at boot time
Message-ID: <201905291142.E415379F2@keescook>
References: <20190529123812.43089-1-glider@google.com>
 <20190529123812.43089-3-glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529123812.43089-3-glider@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 02:38:11PM +0200, Alexander Potapenko wrote:
> Print the currently enabled stack and heap initialization modes.
> 
> The possible options for stack are:
>  - "all" for CONFIG_INIT_STACK_ALL;
>  - "byref_all" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL;
>  - "byref" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF;
>  - "__user" for CONFIG_GCC_PLUGIN_STRUCTLEAK_USER;
>  - "off" otherwise.
> 
> Depending on the values of init_on_alloc and init_on_free boottime
> options we also report "heap alloc" and "heap free" as "on"/"off".
> 
> In the init_on_free mode initializing pages at boot time may take some
> time, so print a notice about that as well.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> Suggested-by: Kees Cook <keescook@chromium.org>

Looks good to me!

Acked-by: Kees Cook <keescook@chromium.org>

> To: Andrew Morton <akpm@linux-foundation.org>
> To: Christoph Lameter <cl@linux.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: James Morris <jmorris@namei.org>
> Cc: Jann Horn <jannh@google.com>
> Cc: Kostya Serebryany <kcc@google.com>
> Cc: Laura Abbott <labbott@redhat.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Nick Desaulniers <ndesaulniers@google.com>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Cc: Sandeep Patil <sspatil@android.com>
> Cc: "Serge E. Hallyn" <serge@hallyn.com>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Cc: Marco Elver <elver@google.com>
> Cc: kernel-hardening@lists.openwall.com
> Cc: linux-mm@kvack.org
> Cc: linux-security-module@vger.kernel.org
> ---
>  init/main.c | 24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
> 
> diff --git a/init/main.c b/init/main.c
> index 66a196c5e4c3..9d63ff1d48f3 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -520,6 +520,29 @@ static inline void initcall_debug_enable(void)
>  }
>  #endif
>  
> +/* Report memory auto-initialization states for this boot. */
> +void __init report_meminit(void)
> +{
> +	const char *stack;
> +
> +	if (IS_ENABLED(CONFIG_INIT_STACK_ALL))
> +		stack = "all";
> +	else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL))
> +		stack = "byref_all";
> +	else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF))
> +		stack = "byref";
> +	else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_USER))
> +		stack = "__user";
> +	else
> +		stack = "off";
> +
> +	pr_info("mem auto-init: stack:%s, heap alloc:%s, heap free:%s\n",
> +		stack, want_init_on_alloc(GFP_KERNEL) ? "on" : "off",
> +		want_init_on_free() ? "on" : "off");
> +	if (want_init_on_free())
> +		pr_info("Clearing system memory may take some time...\n");
> +}
> +
>  /*
>   * Set up kernel memory allocators
>   */
> @@ -530,6 +553,7 @@ static void __init mm_init(void)
>  	 * bigger than MAX_ORDER unless SPARSEMEM.
>  	 */
>  	page_ext_init_flatmem();
> +	report_meminit();
>  	mem_init();
>  	kmem_cache_init();
>  	pgtable_init();
> -- 
> 2.22.0.rc1.257.g3120a18244-goog
> 

-- 
Kees Cook

