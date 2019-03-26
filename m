Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FF74C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:20:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10AAF20863
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:20:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10AAF20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BCFB6B0003; Tue, 26 Mar 2019 12:20:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76C2B6B0006; Tue, 26 Mar 2019 12:20:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 684C06B0010; Tue, 26 Mar 2019 12:20:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5756B0003
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:20:49 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p5so5507761edh.2
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:20:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+RqaqKFaDkoipj6c7EP4i4OyiQJhrt0DmQWk9zSsCmc=;
        b=LW/vF2xuFJFfYKps+PYw1A66CTPiqZex2JgpnucDVrO2asOn2XzF7N+jKB5poI54si
         rMLc6ufkQnqCMCLbCDMd9N5RK0iEbWPHhKZc1SdkBaG0SqF0/xhZxaliWv8sOjaglGAn
         bnDnhP3arr0sS63DfkXR6DW1g2oN4VELG1t6ZPpC68nBv4f7LTGorvOoFK2h1lr/6Qvj
         FxU7dEmhOUFt7SAslsDEbEGh6vhbXEQ8UcJ7EjP1msK/HySZJSToNuyL6C1njW4USU0n
         RtgsdoqVFoEZ6kZz3SO03t69qp2DKf92U4iXFhmZc0qpx2rfdB6KkHvV8tpaMiFVfska
         Iw4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUO4zyzXouhZjh3sphzLS/iivbbw7DaGEP9Ik+/NOd6I0YqOgEG
	DD6WWQwm1x3zP/x4ngjrx6g+eKIe/Ub6JtFqFoNT2ZStl2Paqp+LlVCyTr91LL6q49uaaELHdI3
	+wiNFq0EpbuWo3Y1awgOUVVGJEEcNR4c3/4XHr4FjyfFT2cL26bBPMu2PRoe0YeITkQ==
X-Received: by 2002:a17:906:d62:: with SMTP id s2mr17930014ejh.78.1553617248589;
        Tue, 26 Mar 2019 09:20:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZwhIv2BkBddjX4an+0uQVIzhyP0kam56Wo20a8KEL3l4lxlFbf1m0mKigxTnvXbs1NnTi
X-Received: by 2002:a17:906:d62:: with SMTP id s2mr17929962ejh.78.1553617247689;
        Tue, 26 Mar 2019 09:20:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617247; cv=none;
        d=google.com; s=arc-20160816;
        b=s2wnXtZ9ilPMGhyLCggG6z5WyXbEaCvBY6mTTLeIe6HP1JNAs6eN2nA45Q1DeF7yo9
         Gy3WXuiTp9UZ5KnaMZmuWOf1drSR7ZED0DCsCiveffrfuREM08VHSmzchvOUuRDXSGcS
         OlpiTv3Fxcenq7+YszSvQIgFa0kwpY39T2+FEzV6XNj4kGXZx4u/x9qhaKdqE+RU7LG2
         fvXDLbyGZu8IBSv1oGQeHgfYpOx1o3eZA5NWrgilY1hrLFsrYEVztxgjO00hIkU7lasc
         XTnr91HCzf6e6tBmgpdPDItZ77bB7hxYnVRjHkj2alLE4DstUU3GilkSxNWC3Sulj+IH
         +yYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+RqaqKFaDkoipj6c7EP4i4OyiQJhrt0DmQWk9zSsCmc=;
        b=V+/Udez8C5TGT3atyT1Oko375DrgXdeK7kCzoL0T7j6RpP+gieY+Ll6YWZETF2tk3s
         h6oIel2LCwy4xITfQwlNC5cPG6rTVdhmiXXadxs0W86peKr8opjt/zo4Qpdg4DmRbXxi
         z8NhuJE1NQZ8lD4ZXvtC5bPwa0NU3ACP/luCE0o+Wbo5TK3bvIuK4qkLuj5fyGH/73Nh
         yy01BaAb2EBaTGPRapshvk/shoBs+nJZoW8B3cp1C89EvBkVRrxxgsq40q8oRfBzKCv9
         4Eid2asV1m6xun58MyNs8yu3OsCnAxEqIdVXqhEL/PJLekcW1nz5TyKmpaC8+cUMhwFC
         ixNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n11si456791ejb.47.2019.03.26.09.20.47
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:20:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 458091596;
	Tue, 26 Mar 2019 09:20:46 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 51A8A3F614;
	Tue, 26 Mar 2019 09:20:44 -0700 (PDT)
Date: Tue, 26 Mar 2019 16:20:41 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, mhocko@kernel.org,
	cl@linux.com, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] kmemleaak: survive in a low-memory situation
Message-ID: <20190326162038.GH33308@arrakis.emea.arm.com>
References: <20190326154338.20594-1-cai@lca.pw>
 <20190326160536.GO10344@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326160536.GO10344@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 09:05:36AM -0700, Matthew Wilcox wrote:
> On Tue, Mar 26, 2019 at 11:43:38AM -0400, Qian Cai wrote:
> > Unless there is a brave soul to reimplement the kmemleak to embed it's
> > metadata into the tracked memory itself in a foreseeable future, this
> > provides a good balance between enabling kmemleak in a low-memory
> > situation and not introducing too much hackiness into the existing
> > code for now.
> 
> I don't understand kmemleak.  Kirill pointed me at this a few days ago:
> 
> https://gist.github.com/kiryl/3225e235fea390aa2e49bf625bbe83ec
> 
> It's caused by the XArray allocating memory using GFP_NOWAIT | __GFP_NOWARN.
> kmemleak then decides it needs to allocate memory to track this memory.
> So it calls kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
> 
> #define gfp_kmemleak_mask(gfp)  (((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
>                                  __GFP_NORETRY | __GFP_NOMEMALLOC | \
>                                  __GFP_NOWARN | __GFP_NOFAIL)
> 
> then the page allocator gets to see GFP_NOFAIL | GFP_NOWAIT and gets angry.
> 
> But I don't understand why kmemleak needs to mess with the GFP flags at
> all.

Originally, it was just preserving GFP_KERNEL | GFP_ATOMIC. Starting
with commit 6ae4bd1f0bc4 ("kmemleak: Allow kmemleak metadata allocations
to fail"), this mask changed, aimed at making kmemleak allocation
failures less verbose (i.e. just disable it since it's a debug tool).

Commit d9570ee3bd1d ("kmemleak: allow to coexist with fault injection")
introduced __GFP_NOFAIL but this came with its own problems which have
been previously reported (the warning you mentioned is another one of
these). We didn't get to any clear conclusion on how best to allow
allocations to fail with fault injection but not for the kmemleak
metadata. Your suggestion below would probably do the trick.

> Just allocate using the same flags as the caller, and fail the original
> allocation if the kmemleak allocation fails.  Like this:
> 
> +++ b/mm/slab.h
> @@ -435,12 +435,22 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
>         for (i = 0; i < size; i++) {
>                 p[i] = kasan_slab_alloc(s, p[i], flags);
>                 /* As p[i] might get tagged, call kmemleak hook after KASAN. */
> -               kmemleak_alloc_recursive(p[i], s->object_size, 1,
> -                                        s->flags, flags);
> +               if (kmemleak_alloc_recursive(p[i], s->object_size, 1,
> +                                        s->flags, flags))
> +                       goto fail;
>         }
>  
>         if (memcg_kmem_enabled())
>                 memcg_kmem_put_cache(s);
> +       return;
> +
> +fail:
> +       while (i > 0) {
> +               kasan_blah(...);
> +               kmemleak_blah();
> +               i--;
> +       }
> +	free_blah(p);
> +       *p = NULL;
>  }
>  
>  #ifndef CONFIG_SLOB
> 
> 
> and if we had something like this, we wouldn't need kmemleak to have this
> self-disabling or must-succeed property.

We'd still need the self-disabling in place since there are a few other
places where we call kmemleak_alloc() from.

-- 
Catalin

