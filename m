Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEF07C282D8
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 00:37:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C87720B1F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 00:37:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C87720B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4E1F8E0002; Wed, 30 Jan 2019 19:37:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFD108E0001; Wed, 30 Jan 2019 19:37:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC7388E0002; Wed, 30 Jan 2019 19:37:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 792168E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 19:37:20 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id q64so1076053pfa.18
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 16:37:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=Ba/ZquchCI/MsVbe5dlaq3EKgO5oor9re6645PZ1Yf4=;
        b=NUfIHJgLWJ1XzZYLnx7nKeTe3J9/yT7nbdPNxa08lF9inK3MCnUIUAAZakqtHkEzpw
         eWu9l5s/ZgW2jfpoxiIbQK/eZUOlWzs1dKnUObsKPBYI1O8umv/92iF1DwewrsGA/up/
         MK9al7QpVWoO7lYFk0IgZ0CpCUPwpy2e2evnbUUTUgOFoEJYuubSaP5ckONSfvWEz9bW
         PlQBfH3ppLsrtPxqNRCxiiLca7UVEN4ZXnJkWpOXhjaG7Rtz2VFPLdImdc6loIpmqkZu
         7dCF2E13GvOKgcd4Ebduqnll4soYU9oTf+CY+Plx6ybyCF7RgSty6QHtP29MmIH+0vCl
         /l9g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AJcUukeuid1jQ1/L8ShzsUC98UO9XtWWemXXrgfugWOBQALWhjhBDpBJ
	pd3/bsrt2XV4GVGKp2A+zmvlBRr15NU6biANUSecVnpbjOwz0eDFUKQhe6zUJ8C532aqTAlHivH
	qz1ajs//rFkojinclWrYArAc1vQuq2u94rBvLJkLpnrncPFEWBhBDs7Ja7FKFKxo=
X-Received: by 2002:a63:6346:: with SMTP id x67mr29435962pgb.183.1548895040134;
        Wed, 30 Jan 2019 16:37:20 -0800 (PST)
X-Google-Smtp-Source: ALg8bN783I7ov1zS3dqnnGxJG1cH8bQT4r6stZToSXEd54jGZXS+pVZCq+XM02lj6s0XHVMDxMyh
X-Received: by 2002:a63:6346:: with SMTP id x67mr29435920pgb.183.1548895039178;
        Wed, 30 Jan 2019 16:37:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548895039; cv=none;
        d=google.com; s=arc-20160816;
        b=wKMKGmAg3aEbiK3mXYB3Xxdz7Kpgss4qSHcpNWdAt+6OCnjzN42HwDE/Ip+cuqK/CZ
         UehqsVMdlK8ZDRN+ioNulFn96kbkW9aKYffdclPlOaS8jGkRgmrysTn4sIfKVSnhjI8B
         rD4rLCOJtPVFu8k/USjIccBJHBzZ8v8Yt8HIxS56n/+xa7wPivFXXn76qx6Foxf2/zV3
         uCb8oshYOqJAc2EINAzi/9C/Vsr/OHvFqUWNM0SsttBU8SXcsgaBqvEdUDwwqwclWm/x
         5W03/PtsIHrAVZ0DB2VScjEzxBxCvodgtbza7xdUMwyVRjTk6UBlHc/ATOKK3AXNPc+s
         V61g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=Ba/ZquchCI/MsVbe5dlaq3EKgO5oor9re6645PZ1Yf4=;
        b=I9Lg/6klgSJfaUodkdGdILa33GCGzv26j6kiVK0MQfyBp+x1JCHJhKlj4ndMutMbs0
         2nIew356eFUgC/lN+vQKLgrZm9tvaPn12QmYeUZyo0E5n1RhFHdyDhfMwiiC9j+t9Uo+
         S9/clpDkRj8ZM3i7ENAPhF1wT+NBtQUShMRWZ+iw37boLUqN+yRUiLsnkGiIScsmDDCb
         +1qJkUIw1qvcT8i54PZnAsnTryGrtDUH+JecBy6s4IttkRN+5dOJMV2CVT0juaY4fRKP
         v+y7xBr3KUsy/L8VVYviWLftT8yXToBsc8GRm4uIIyJZZurBrrvWQIuzNmev3jmmvGfF
         Z21A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id u131si2866372pgc.287.2019.01.30.16.37.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 16:37:18 -0800 (PST)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43qhBt41SKz9sDB;
	Thu, 31 Jan 2019 11:37:10 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] mm: Prevent mapping slab pages to userspace
In-Reply-To: <20190125173827.2658-1-willy@infradead.org>
References: <20190125173827.2658-1-willy@infradead.org>
Date: Thu, 31 Jan 2019 11:37:10 +1100
Message-ID: <87bm3xpsqx.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Matthew Wilcox <willy@infradead.org> writes:

> It's never appropriate to map a page allocated by SLAB into userspace.
> A buggy device driver might try this, or an attacker might be able to
> find a way to make it happen.
>
> Signed-off-by: Matthew Wilcox <willy@infradead.org>
> ---
>  mm/memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/memory.c b/mm/memory.c
> index e11ca9dd823f..ce8c90b752be 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1451,7 +1451,7 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
>  	spinlock_t *ptl;
>  
>  	retval = -EINVAL;
> -	if (PageAnon(page))
> +	if (PageAnon(page) || PageSlab(page))
>  		goto out;
>  	retval = -ENOMEM;
>  	flush_dcache_page(page);


Thanks for turning this into an actual patch.

cheers

