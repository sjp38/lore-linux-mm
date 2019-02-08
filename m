Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE701C4151A
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 22:40:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A061B21908
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 22:40:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A061B21908
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E9E98E00A4; Fri,  8 Feb 2019 17:40:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29A538E00A1; Fri,  8 Feb 2019 17:40:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1639F8E00A4; Fri,  8 Feb 2019 17:40:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C87378E00A1
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 17:40:50 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id f125so3553283pgc.20
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 14:40:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MgOw0ojzYkv8yZw2lPhuJ0z1ajdAi18wj0P+A59qibw=;
        b=bDGrAmUpi5pJoG7IMZeAuK47msBSY+Pcz+59fks9lR3UFJ+iQDMaI9n0ENAlQZnYCn
         fmzsuau+oZrpmHunnV3gdPltMbVOpVfjDQNOlEnTyory7DnEXPRRMwfdl+ui/0fP9PfG
         9EF3mGZzH//KhP/IuxQz6Jf+gt3kB3ogd2TART4RSRy1n39nCM2Vqz95jDdzq3PuiyuJ
         5yEDIbr7+nJsfO+paBdQaOKN4bpbw/Qxv5AJz1plgCv7ocJV/uq4OgvXusZXZk24mT7N
         5gH6jqcFYB3NWX+qixEcI3wsawamrMExVxpWQLiwj4RvZGz64sZ3fGgV4Dyas69qud8N
         d4og==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuazRNrbkCqH/iOToR4bOFwHob/vF4XMQvGtizEsM23S1fOEzINf
	t+38siWebjajKcQws69u5k1KXYMaUDef2K4VIV8Es6L1B5LVLg3Plc+ywXwNDEwnGehAMG2jaJv
	jB/W8aWlCIvA5hA/tMbk3K/z026WlRe/nRzWVUTrHuTegawv2B8XgotYbZFtTbkTwkA==
X-Received: by 2002:a17:902:b489:: with SMTP id y9mr25577207plr.193.1549665650485;
        Fri, 08 Feb 2019 14:40:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY85V1qnfKpGRNUaWSF/SkZb2HIhuc5AxFFS9l6/z2XaNJ8I+m3ovYcVbbD+1sPyOgbEenP
X-Received: by 2002:a17:902:b489:: with SMTP id y9mr25577149plr.193.1549665649651;
        Fri, 08 Feb 2019 14:40:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549665649; cv=none;
        d=google.com; s=arc-20160816;
        b=i8xjSvrMrq7ei/KldBfgrMveHxi6LspUPuNQ0mlg5FR4UlDS7ObI7b1zJlhxsRli+B
         1EaCl+Qa80NP2Gj34J68NyhUH3zHkTx1Z8/uRWTRtU5O7Wp815Xnco55Le7xlY9TaKsH
         6yhQXtVT9Us9nIytKNO0EnHrWfQQN/fSBt1yyktvs08YNBqRq/4ts056mseaAHqklDlj
         nkRggq+ypZyKBPpzg8w5FwXPjH5sfJ/numAP12Ay2fLQ0WAVgBE/9f0/cN3GgI2lrHBV
         1kF5gNdzdniAfibqhcoOHIGubd0Ul1VvCl13GMtExTzf4por0YDs6LDPI3Kp5J6W7xVM
         M++w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=MgOw0ojzYkv8yZw2lPhuJ0z1ajdAi18wj0P+A59qibw=;
        b=n3SLwJmWerwcZqkZb8RhGWE8sXA+vQoJKR6JEeqpJMoWfJG8k0ysC0hGuEAu0XFHTc
         zRfyns6iC7x9PvlA8eUWsFi52+U1/JRU6pzFtz5TBKARsDcCP3qi4j4J0ku81y6vpVPF
         niZNzLFm2qIe7bAc5MSAhQtTsAop3N/jkFysdYj8H6FkCTAclTcLAFVCzKRDzC9r7dqM
         k3CxFiSjywedVQH2IL6dCiRKhBkBtqnotIaSYs1wd8MULhDI2XTnbs+5pSAEJCa1o238
         M4E+VWV0uYMviRCacr15xbcmQbxy/wHjl00EaxEmOJhTf3iU1FNv9vvx9uwyYw3APoCd
         56Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b11si3566332pla.405.2019.02.08.14.40.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 14:40:49 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 7ADF6CA08;
	Fri,  8 Feb 2019 22:40:48 +0000 (UTC)
Date: Fri, 8 Feb 2019 14:40:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org,
 linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] memblock: update comments and kernel-doc
Message-Id: <20190208144047.66254b6d08edfea462e6466a@linux-foundation.org>
In-Reply-To: <1549626347-25461-1-git-send-email-rppt@linux.ibm.com>
References: <1549626347-25461-1-git-send-email-rppt@linux.ibm.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri,  8 Feb 2019 13:45:47 +0200 Mike Rapoport <rppt@linux.ibm.com> wrote:

> * Remove comments mentioning bootmem
> * Extend "DOC: memblock overview"
> * Add kernel-doc comments for several more functions
> 
> ...
>
> @@ -1400,6 +1413,19 @@ phys_addr_t __init memblock_phys_alloc_range(phys_addr_t size,
>  	return memblock_alloc_range_nid(size, align, start, end, NUMA_NO_NODE);
>  }
>  
> +/**
> + * memblock_phys_alloc_range - allocate a memory block from specified MUMA node
> + * @size: size of memory block to be allocated in bytes
> + * @align: alignment of the region and block's size
> + * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
> + *
> + * Allocates memory block from the specified NUMA node. If the node
> + * has no available memory, attempts to allocated from any node in the
> + * system.
> + *
> + * Return: physical address of the allocated memory block on success,
> + * %0 on failure.
> + */
>  phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid)
>  {
>  	return memblock_alloc_range_nid(size, align, 0,

copy-n-paste!

--- a/mm/memblock.c~memblock-update-comments-and-kernel-doc-fix
+++ a/mm/memblock.c
@@ -1414,7 +1414,7 @@ phys_addr_t __init memblock_phys_alloc_r
 }
 
 /**
- * memblock_phys_alloc_range - allocate a memory block from specified MUMA node
+ * memblock_phys_alloc_try_nid - allocate a memory block from specified MUMA node
  * @size: size of memory block to be allocated in bytes
  * @align: alignment of the region and block's size
  * @nid: nid of the free area to find, %NUMA_NO_NODE for any node

