Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA154C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 15:00:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70C202171F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 15:00:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70C202171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 075AA8E0003; Thu, 28 Feb 2019 10:00:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 026348E0001; Thu, 28 Feb 2019 10:00:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E30E68E0003; Thu, 28 Feb 2019 10:00:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8A33E8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 10:00:05 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id h37so6966400eda.7
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 07:00:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=WZtE3jqlEz5tjK8PnDeQtjsI8CK27gTSj1aFd5gmWyQ=;
        b=Tlsx9OXy7n0ZRhZuKvJSYw3R+TdRWlHbrZB7lNp89HREXbPe/D1TFgED8AITV/q8j7
         WD9cXOpkTG2bYN6uFgq9L0sDz2Jw6iDu+Ps0y9dXJDJo99WY2fxdCbu1f8dsKox+VUhd
         H86Q+Y+EDPtceuQc0joD12sITf3Pa6ketVmk8sNdMcwMDkR+VYzB+E08fiNbW1DR4pIr
         vNGq4EXrmwgSghqST9P8VTjr6LAp3/QuJ+QNndYjdZPsrQVb9dYpPmHSqraeYCWzyAWt
         q5Viv4aGIaNC2FM8FbTlFc3AnnQ03FfWkI2FyJZ4nES+PH4/ZrWmiyFbX0CEB1wrBlHb
         O1bA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAWBIwh+1J666n1vlejr5H0MRgT9XIZZ4pFFhdLCc98G88gGt9Z0
	xYQV/3THexsl4d/S9SSXO6vJDnuZMT3wbVn+aJbbCfcyZgp88ia4aMKjJsBznWvXYwiProSfiHs
	zZQ58OXZoZkq/dpFug5ox+1xFxF1kQBlaezBWPGlp+9B+YsDQP7niXAzYEdGIWOwxzQ==
X-Received: by 2002:a50:b56c:: with SMTP id z41mr35530edd.160.1551366005140;
        Thu, 28 Feb 2019 07:00:05 -0800 (PST)
X-Google-Smtp-Source: APXvYqx0bPXF7Lype8iX52x8eVHmA3p/8H2hr9RiFJ+11fC9oLcN/ZxS6czpJyHpzaMRmxCEHjNL
X-Received: by 2002:a50:b56c:: with SMTP id z41mr35458edd.160.1551366004082;
        Thu, 28 Feb 2019 07:00:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551366004; cv=none;
        d=google.com; s=arc-20160816;
        b=EDON/DVwL4a6O8p0+Dlfj/icnOVa4aHE779eszP/Eq/9XIPBrzCsve7tkf9N4AS6Qi
         3keJJyrvNzjIVnPxcgte/7GnprUXCOVLiAbnTq4s1876iS3vnRBSk0a5bD2oXbrPG6O9
         PDBVV9sGhZmhbne/gd8JJZWgv+6SwWKgsEg4SOm1V/mhjFTSUZ+eZ9fwWW+eiquBL3MC
         hOj8UxcHhm3tuHv43fMvpJ77EOXJl5T70GUdIuoJxGP5R/TEHtsoEcxIKlsJNZgu7GmP
         Iw4mXLpFBoHKV63a1Ge9qW7h2Fjzh+jYF8ICEOfn67LP3phpiO4+MQD4irPDnDyPsqMe
         zMcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=WZtE3jqlEz5tjK8PnDeQtjsI8CK27gTSj1aFd5gmWyQ=;
        b=g75pt6HuppWW5xs18H+aLKKcY7joIKd1pVX3phPqNygECy7cXHnkvuixLBewrC1eQE
         uowK5LI21rIMVt0V6hlSzqLw+XCbsFAMYS6wagshUnPUWOXL2AEgQEctjITRLTucrrZo
         txPMUI1l2a1taL7UswxoaceIodN+12OV4Blm6Q+nqIQxOTy70DoHJkQr6l/ILHGFVoLj
         KjbO3brfvMIigUICeqWIf0c2tUvcd3lHBm7YGDovZPlaKpOii7EIcCXh0i9pQrM6Y4wl
         ogbpz6EsmYdV5IyLhVeY0fBnj8+GG/5jQKjQDXOgji8jdHHEm53zer/jog/YP2iEoGL8
         INcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f10si3681208ejq.167.2019.02.28.07.00.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 07:00:04 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 35B55AE30;
	Thu, 28 Feb 2019 15:00:03 +0000 (UTC)
Subject: Re: [PATCH 1/3] mm: refactor __vunmap() to avoid duplicated call to
 find_vm_area()
To: Roman Gushchin <guroan@gmail.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>,
 Johannes Weiner <hannes@cmpxchg.org>, kernel-team@fb.com,
 Roman Gushchin <guro@fb.com>
References: <20190225203037.1317-1-guro@fb.com>
 <20190225203037.1317-2-guro@fb.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <dfc87917-c206-ccd1-64f0-c45b86f52cda@suse.cz>
Date: Thu, 28 Feb 2019 16:00:02 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190225203037.1317-2-guro@fb.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/25/19 9:30 PM, Roman Gushchin wrote:
> __vunmap() calls find_vm_area() twice without an obvious reason:
> first directly to get the area pointer, second indirectly by calling
> remove_vm_area(), which is again searching for the area.
> 
> To remove this redundancy, let's split remove_vm_area() into
> __remove_vm_area(struct vmap_area *), which performs the actual area
> removal, and remove_vm_area(const void *addr) wrapper, which can
> be used everywhere, where it has been used before.
> 
> On my test setup, I've got 5-10% speed up on vfree()'ing 1000000
> of 4-pages vmalloc blocks.
> 
> Perf report before:
>   22.64%  cat      [kernel.vmlinux]  [k] free_pcppages_bulk
>   10.30%  cat      [kernel.vmlinux]  [k] __vunmap
>    9.80%  cat      [kernel.vmlinux]  [k] find_vmap_area
>    8.11%  cat      [kernel.vmlinux]  [k] vunmap_page_range
>    4.20%  cat      [kernel.vmlinux]  [k] __slab_free
>    3.56%  cat      [kernel.vmlinux]  [k] __list_del_entry_valid
>    3.46%  cat      [kernel.vmlinux]  [k] smp_call_function_many
>    3.33%  cat      [kernel.vmlinux]  [k] kfree
>    3.32%  cat      [kernel.vmlinux]  [k] free_unref_page
> 
> Perf report after:
>   23.01%  cat      [kernel.kallsyms]  [k] free_pcppages_bulk
>    9.46%  cat      [kernel.kallsyms]  [k] __vunmap
>    9.15%  cat      [kernel.kallsyms]  [k] vunmap_page_range
>    6.17%  cat      [kernel.kallsyms]  [k] __slab_free
>    5.61%  cat      [kernel.kallsyms]  [k] kfree
>    4.86%  cat      [kernel.kallsyms]  [k] bad_range
>    4.67%  cat      [kernel.kallsyms]  [k] free_unref_page_commit
>    4.24%  cat      [kernel.kallsyms]  [k] __list_del_entry_valid
>    3.68%  cat      [kernel.kallsyms]  [k] free_unref_page
>    3.65%  cat      [kernel.kallsyms]  [k] __list_add_valid
>    3.19%  cat      [kernel.kallsyms]  [k] __purge_vmap_area_lazy
>    3.10%  cat      [kernel.kallsyms]  [k] find_vmap_area
>    3.05%  cat      [kernel.kallsyms]  [k] rcu_cblist_dequeue
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Matthew Wilcox <willy@infradead.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

