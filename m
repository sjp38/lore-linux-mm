Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26C17C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 18:17:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4E1C21874
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 18:17:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Zi5ZwJ9P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4E1C21874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54ADC6B0003; Thu, 21 Mar 2019 14:17:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D4B56B0006; Thu, 21 Mar 2019 14:17:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 375136B0007; Thu, 21 Mar 2019 14:17:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 13D5A6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 14:17:50 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 75so19579077qki.13
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 11:17:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=nq8thke8AAguuyUY8uu9Lf6Dq379TbWozTWnKwSQ0mI=;
        b=rExaAl5SHMF5BnF+vJ1lbC2UUCTkO0sBZDOx2HAtzoBGHDQs/Ve3xpWacl/XYC8C5O
         MWw9d81UE8vi1UkI9frFkALCSrCne3UHc8Asz8KFiIh/hD8o7aQqHuA58Msmea7Q5sUa
         WKdPa62cEDy7KYgH/+JWzkNd+lnI1HGLjuo2DG+X17EcxMWqXF+qTZk8UIKkgCcOQpoR
         rSd9WerMudNl28Fq1/KR02tQ6uLlh6tdSAPftor95RjBeGVVIMvfD2YEy8HJ+95Azt55
         55eqLgdiytoL0fs77+h23a1ggw+UPLsdnF54DziAnhCS8ono905pd49x3Y5feasygiX3
         OpoA==
X-Gm-Message-State: APjAAAWW54aVkhSO5ho0JjcZg2JkBULuWYcquUCsziekoKt/W9ETZJC7
	4hzJry6vPr39J5qbNEBZ2uGbv5lC/N0cHjlwVZatmlFQ+p2jKS1Y1DC+V2nBEFuU5ZLNKffZh3r
	AFAv6oVIsN0lnHLIh5UoZ1Y7qdJdqE4kE8+xsTQm5eqzdkXQFy1Mjw8KJAIJDNELH2Q==
X-Received: by 2002:ae9:eb4e:: with SMTP id b75mr4042224qkg.121.1553192269703;
        Thu, 21 Mar 2019 11:17:49 -0700 (PDT)
X-Received: by 2002:ae9:eb4e:: with SMTP id b75mr4042164qkg.121.1553192268965;
        Thu, 21 Mar 2019 11:17:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553192268; cv=none;
        d=google.com; s=arc-20160816;
        b=sDBa0CkrWTLxsr8V5WOm7dXHgeKru7dnREV9mnD5/dkgu4R1tjdk8ruGJjO4nE4jCR
         sSxiYZ1y4CclWCi2FvObwwPJUdt7/MNWM+drUTGtpewB6TWYpJjPDU6805YUCxMXfguM
         xfdYWhqaKTD9neryLmc/M3F+jQlfTHj+svf0W8HxF6VYkshCHOky/HV2MKVcKFDWFvsg
         O0M6YFZFIl7hwLK9QfDxjW6swV/Ox4HTHVp69ELhfH2AXK/L9PIfvmBoZVyzPY3dIlFF
         3EE1D0XCcbJKlNnorCEi2vXFO4dz8vJmR24PlUWXjNC7c8WtXxtKge3YDEuDr4Lv5FYc
         Zuyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=nq8thke8AAguuyUY8uu9Lf6Dq379TbWozTWnKwSQ0mI=;
        b=O8A6mrtVGNwLtlT1QwtsAUj/QNvZ0sfr6bspkBz3xjKLAonNIA21IfGCeDUfUdLkpL
         yw02dal0ghjN+F5wgLPXDY/jJvK65ETcTDJF7fCeqJ7XyVq7BX0ww3rs3FmJNzjJcP86
         TIwg/W+oBXue9C4zVTtYLm47kvYJjuEj23kb6s9n6dot8KXPyIqZwk8t31QD6qsjPrpH
         A5kD7GiCwydncUaolcQxX19W21VtWTkuwMZpOvuUnaEdGJNhzOuXMXbGaRSGyz1f2IFD
         Imvu/sU3IHeNlKALxP1NQRnxjmmDnQL/2/Pe7ek02m12DLM+KBwSvH+7uVtxomP4MX/2
         tiZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Zi5ZwJ9P;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a18sor1533369qtb.45.2019.03.21.11.17.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Mar 2019 11:17:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Zi5ZwJ9P;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=nq8thke8AAguuyUY8uu9Lf6Dq379TbWozTWnKwSQ0mI=;
        b=Zi5ZwJ9PlIvYa8DSIECnCbalBEUOgpuIjs0WSCG2SBnJE3ZhZkUFul6HDdWAPJOpm/
         piNYKFb/BK51xfBlq6w+3wwCe3eqEhGAPLmvFGltK1Ht4S5KdIAAixYx9+nSOYDvcd3I
         D0/DmsQB8QLDsVb+5TTjidvoroLdSDYNPAnrCx1lr9OIGPoqFzmcl6K0eVH6kXQPcmFW
         s1xCXBYk3n8A0Q27DgEkin8ZicHNgBWqWB5bU7lRwF7qCFB98N1fFnDWM6mB/yQFmjbC
         lr8JiyF6yc9sdanvfv0IorpMOnScmhIiiOwlQx9Z9LilQEymcGGTYGhk345mlqW1hRrE
         RNrw==
X-Google-Smtp-Source: APXvYqzH4lZLJtvN18IQVcBYAAWDGWi+UZTAC3zqVsSviENEchLNO0/tfVB35Kl8u2oUO+FPu+1H4A==
X-Received: by 2002:ac8:3113:: with SMTP id g19mr4420688qtb.356.1553192268668;
        Thu, 21 Mar 2019 11:17:48 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id y17sm3021889qtf.72.2019.03.21.11.17.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 11:17:48 -0700 (PDT)
Message-ID: <1553192266.26196.16.camel@lca.pw>
Subject: Re: [PATCH] kmemleak: powerpc: skip scanning holes in the .bss
 section
From: Qian Cai <cai@lca.pw>
To: Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton
	 <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 kvm-ppc@vger.kernel.org,  linuxppc-dev@lists.ozlabs.org, Michael Ellerman
 <mpe@ellerman.id.au>
Date: Thu, 21 Mar 2019 14:17:46 -0400
In-Reply-To: <20190321171917.62049-1-catalin.marinas@arm.com>
References: <20190321171917.62049-1-catalin.marinas@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-03-21 at 17:19 +0000, Catalin Marinas wrote:
> The commit 2d4f567103ff ("KVM: PPC: Introduce kvm_tmp framework") adds
> kvm_tmp[] into the .bss section and then free the rest of unused spaces
> back to the page allocator.
> 
> kernel_init
>   kvm_guest_init
>     kvm_free_tmp
>       free_reserved_area
>         free_unref_page
>           free_unref_page_prepare
> 
> With DEBUG_PAGEALLOC=y, it will unmap those pages from kernel. As the
> result, kmemleak scan will trigger a panic when it scans the .bss
> section with unmapped pages.
> 
> This patch creates dedicated kmemleak objects for the .data, .bss and
> potentially .data..ro_after_init sections to allow partial freeing via
> the kmemleak_free_part() in the powerpc kvm_free_tmp() function.
> 
> Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)
> Reported-by: Qian Cai <cai@lca.pw>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>

Tested-by: Qian Cai <cai@lca.pw>

