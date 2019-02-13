Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B36D5C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 11:27:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BC632070D
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 11:27:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BC632070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18B578E0002; Wed, 13 Feb 2019 06:27:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 111018E0001; Wed, 13 Feb 2019 06:27:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F19CF8E0002; Wed, 13 Feb 2019 06:27:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 93ACD8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:27:33 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id u19so864874eds.12
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 03:27:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=BCV6CTHpDJTmmb+R3vkluxUBhHXsiIaPsOO9jAvnwyY=;
        b=qhltygdVQl4hD1g7y9j3TyxPwqwldAv0R0qw3/CCfNGNioUZxATDv4unVJT2f8+ycE
         EA1gU6cRq9BTtdQew77KIMUlhYKqkkpdWIMXhU5bNoYPY4dCVfmj7WSL7WigMO29iEQF
         wtNuiOiJsSWSdI2Eh/ia2t7FD+at73Vv1WntvxDWmbjcVmV0g4QDCqs/RLGsqJvKWpWs
         hdNgbHAX/2Dd3SuMvzJbjok4dhMSpSnWiW5EBlzREgzKeKctYQ9mrjb7Vh26rm7kDgoO
         5MosFo59+imM5OeNUSZ1/7vP+XRc+t3wobK7lSg8FxZvtf5dV3O+X/Hf9cb8DQ+Z3p9Y
         X2Lw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAubSqu1sY1HpxVqXLCHKAUF6HQX082H8jBfW3cZfN+Ajqe/L5CMd
	Hw1DdP+Ny7PZfk+4VKaSmr+nojq+u3LeD45t7oXvhzxh5BDHF9jYYtRoGqK/KpasT2rmTEjPeOh
	CzB0+t6MSzGHvAhBTxRcGp2JoMTmAcUJcOv6WYUQfjTGqONu1+joMBlPsVrnVs5WUxA==
X-Received: by 2002:a17:906:11d5:: with SMTP id o21mr6201132eja.85.1550057253065;
        Wed, 13 Feb 2019 03:27:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ3GBF0ypSM9YykzBURdp5ocXxXb5moONh0leubsBlXz7P6z6b4RfMBTVd2FWjdUUpk2YFe
X-Received: by 2002:a17:906:11d5:: with SMTP id o21mr6201084eja.85.1550057251976;
        Wed, 13 Feb 2019 03:27:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550057251; cv=none;
        d=google.com; s=arc-20160816;
        b=cG1f+9c1iAZf5SWZ6l8w3HlyDimOzMholqQBD6eWSC+YC3sqbdBfPXM8unFzRn9QiH
         UeiHZTy928BOcLn9EOGe2gLq05YMhKDXklMaMmY5RgbAd3EWr98FY+krWU0neewQn3LS
         igAXmQgDx7LXYYX0u/T9aLxcv2YscDxjd/trzMxa2Khl4GUmQR3RCBj2zr+Be5GTXyH1
         LBqr3VZbPwIylPVGSqbfWFj93JmKh/ql9YdFsqJpeqrsVR8YVX9dRAxUVSEvZcYNF9wU
         crBdjU3hwDA4bS94v8A1Fq9zbAt/ix/D2Srmqzmy9sItQAN6o96+1o4sqRhj6h/kWsjR
         KC5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=BCV6CTHpDJTmmb+R3vkluxUBhHXsiIaPsOO9jAvnwyY=;
        b=jphrCBQ/trC8/JCqfbNKz3TSqTpL4cgF/w/ENjRa7xRj7WuLyd/2Ad+1d/3betbfIz
         V/0molxV/ngnviA92w+C01C2CnU606D9xIZNZL3BRudYOm6Zc6CW8sejRCBbidRjasWL
         41Jrkiwk0FojSRyNtrxlTQrcToIU8+2MG0pFSeuF3X5WH9VixEHzt19EQj4UyfIGRil8
         wOUjVUCwbI/+l0dOO6YevtTm9tNWL3E5W6xB7wjEUDGheKODjQ5gGv+vF2f6BCDsEBIJ
         9j+wC3tKHPLWfUhviW8Ewp7mu6jp6VgO63NqTqyhiJL4PdMy7QhIu8/05JMuapaogbhn
         wwpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k18si522205edx.210.2019.02.13.03.27.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 03:27:31 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2EF02ABAC;
	Wed, 13 Feb 2019 11:27:31 +0000 (UTC)
Subject: Re: [PATCH] hugetlb: allow to free gigantic pages regardless of the
 configuration
To: Alexandre Ghiti <aghiti@upmem.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: linux-riscv@lists.infradead.org, hch@infradead.org,
 Alexandre Ghiti <alex@ghiti.fr>
References: <20190117183953.5990-1-aghiti@upmem.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <16a6209c-868b-8fd5-a70a-6e0e1ecb62d4@suse.cz>
Date: Wed, 13 Feb 2019 12:27:29 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190117183953.5990-1-aghiti@upmem.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/17/19 7:39 PM, Alexandre Ghiti wrote:
> From: Alexandre Ghiti <alex@ghiti.fr>
> 
> On systems without CMA or (MEMORY_ISOLATION && COMPACTION) activated but
> that support gigantic pages, boottime reserved gigantic pages can not be
> freed at all. This patchs simply enables the possibility to hand back
> those pages to memory allocator.
> 
> This commit then renames gigantic_page_supported and
> ARCH_HAS_GIGANTIC_PAGE to make them more accurate. Indeed, those values
> being false does not mean that the system cannot use gigantic pages: it
> just means that runtime allocation of gigantic pages is not supported,
> one can still allocate boottime gigantic pages if the architecture supports
> it.
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>

I'm fine with the change, but wonder if this can be structured better in a way
which would remove the duplicated "if (MEMORY_ISOLATION && COMPACTION) || CMA"
from all arches, as well as the duplicated
gigantic_page_runtime_allocation_supported()

something like:

- "select ARCH_HAS_GIGANTIC_PAGE" has no conditions, it just says the arch can
support them either at boottime or runtime (but runtime is usable only if other
conditions are met)
- gigantic_page_runtime_allocation_supported() is a function that returns true
if ARCH_HAS_GIGANTIC_PAGE && ((MEMORY_ISOLATION && COMPACTION) || CMA) and
there's a single instance, not per-arch.
- code for freeing gigantic pages can probably still be conditional on
ARCH_HAS_GIGANTIC_PAGE

BTW I wanted also to do something about the "(MEMORY_ISOLATION && COMPACTION) ||
CMA" ugliness itself, i.e. put the common parts behind some new kconfig
(COMPACTION_CORE ?) and expose it better to users, but I can take a stab on that
once the above part is settled.

Vlastimil

