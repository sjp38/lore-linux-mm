Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FAF2C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 07:41:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2880F217F5
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 07:41:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="Mf9scPfn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2880F217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A09768E0004; Tue, 26 Feb 2019 02:41:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E10F8E0002; Tue, 26 Feb 2019 02:41:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A8CD8E0004; Tue, 26 Feb 2019 02:41:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 34EDB8E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 02:41:43 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id j7so5960780wrs.20
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 23:41:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=WGRK7XUOculPeJLrz4JzavGSjbEwTXAS4iVpUNRRB/k=;
        b=sRq7D3Ugto7Kjwhdec2Ljnvcjp7Y4rR5Nq/WY0oamhuV60TIjAgxKLXL/2/pV2EnnZ
         RPNpKkBiZNc1xXgr4AL0l9WvWiC/iDH4TfR4nZJxuTGlxiJv2OrmcmdXkTXHAqICj2/M
         FvE4ZU1k79Uack/GAvRcNYqyjtpxXCe5h4srs3o+r3R1Kd7iizV3oLC5D4SCFNtk9hlH
         P9CT+mtwyC2GI2Yu4tUE9ljWrfHlAfBqW0dsElq1tKmGoR7mdKxJakKvRgHBSDQ2VjbM
         a8Cu63tQ0bmTLQvtbXfkd2zb9Hv6DRoHMnH/co2N+ipXzV+5EBlSYlxNdRCfv50PsfID
         sy5Q==
X-Gm-Message-State: AHQUAuYuRP/s8dgM3DPWGX+BdlzYdbwlknp/0KJ0vOGoZyANMm85tQOc
	Z5VQ5W8WgAIcGzD+zqsb0id5FjOhBd4Ay0ZH30uVHUtfNgzVpvV2w/yUeGIOWXczj68l9EeOnrP
	jV5t+mg95PJA+E40rtwAqw1boLJZ3do3dDPEs0ktrN1P+e446SlVRCHLR5pRfLVcSLw==
X-Received: by 2002:adf:efc4:: with SMTP id i4mr16771511wrp.42.1551166902729;
        Mon, 25 Feb 2019 23:41:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibj+M+FzOva2L2LeJib9cWYYNVj6emtP1nB0+pAgLv2ebRuZKZSyo24/XwRssdmLie0v/4g
X-Received: by 2002:adf:efc4:: with SMTP id i4mr16771446wrp.42.1551166901658;
        Mon, 25 Feb 2019 23:41:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551166901; cv=none;
        d=google.com; s=arc-20160816;
        b=AEqftShxzANoOQVOqt/tUThoLkcTNVGDGf1FTxjZ5ZxJb6rCA6cVfApApevZjrwrtR
         FVre/gC6E5WYzYB+Snorv8AM2GxByMvqzDyYbRiCgQTwRFTi9iEfnjTt+ZSayL+bvDuN
         /dbXQ5XkPnJBD8Xf2VWmGI1uchIyE8nSYPiv53CW3CrXwrxfCWUsoPfiE4U/SOwJ2Ik0
         Pp14hpmZY5NNWT5+67eazTegpVILyPAKWhB0l2ns4c5cODulDqQgXiWm8tEFU6pGbVUe
         yI153jk6erZkYKTyD4WPrlC3DOhRoOq2AIwGlwAplwZx4Kc68ZVc9kUmUU+vZGsEATXp
         3XzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=WGRK7XUOculPeJLrz4JzavGSjbEwTXAS4iVpUNRRB/k=;
        b=SWFFAKXFyqks54AunVWIC3QgjtkHjUkIzAujjfhkyVXvyOXF5NFDJVehtO6ahzaU14
         zjv+ii2e2Tey8L0pW0Hk1q47BGykswvTgx08DB2C0r/oPKbu7f3QaPVp3KShMr7/1doT
         MjQQmq2GQMOiqKdR1PhxWoRgHovKuH0cxEaccImzcP97VD+SwfHWLkoWe6EVey/3Usz+
         p/MHuO/Pni8uKXTrxUjS3nzY/f+9Kyms+OGBqv/qLR6JxQryVe+bmQFDJ4ovCIbROcHv
         g3mB26jOyvIMosktzwxoa3hrK4eXYvxLY6PKj3ISZ0Pa4xd7WYI/onweSe8bus9rIFHC
         sZig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=Mf9scPfn;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id g26si6516512wmk.34.2019.02.25.23.41.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 23:41:41 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=Mf9scPfn;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 447rNh1F9pz9v4sW;
	Tue, 26 Feb 2019 08:41:40 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=Mf9scPfn; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id Cd1Gi_BCb91v; Tue, 26 Feb 2019 08:41:40 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 447rNg73TSz9v4sS;
	Tue, 26 Feb 2019 08:41:39 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551166900; bh=WGRK7XUOculPeJLrz4JzavGSjbEwTXAS4iVpUNRRB/k=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=Mf9scPfnJq09iY94lCFQ4KLoJsu5oZjihynYNCNo0d4O0zHKSHG2imdiP1aNhn1iT
	 Ifj4GwyDtCF9LCXiD7brdSw9C+UzOdMC6wKC3+TeaD8qCDiHLMAbbKB/VZYammHSMJ
	 odpD4WN1Bx8dRVCx8EjBema8ZUAKvwA40SLmBCFE=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id DBBD08B90F;
	Tue, 26 Feb 2019 08:41:40 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 3gTK6PjDqmLx; Tue, 26 Feb 2019 08:41:40 +0100 (CET)
Received: from PO15451 (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id BEEB88B794;
	Tue, 26 Feb 2019 08:41:39 +0100 (CET)
Subject: Re: [PATCH 1/5] mm/resource: return real error codes from walk
 failures
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: mhocko@suse.com, tiwai@suse.de, keith.busch@intel.com,
 linux-mm@kvack.org, paulus@samba.org, baiyaowei@cmss.chinamobile.com,
 zwisler@kernel.org, dave.jiang@intel.com, linux-nvdimm@lists.01.org,
 ying.huang@intel.com, bp@suse.de, thomas.lendacky@amd.com,
 jglisse@redhat.com, bhelgaas@google.com, dan.j.williams@intel.com,
 vishal.l.verma@intel.com, akpm@linux-foundation.org, fengguang.wu@intel.com,
 linuxppc-dev@lists.ozlabs.org
References: <20190225185727.BCBD768C@viggo.jf.intel.com>
 <20190225185730.D8AA7812@viggo.jf.intel.com>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <87f914ce-c9e8-7fc5-d048-702fa809013f@c-s.fr>
Date: Tue, 26 Feb 2019 08:41:39 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190225185730.D8AA7812@viggo.jf.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 25/02/2019 à 19:57, Dave Hansen a écrit :
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> walk_system_ram_range() can return an error code either becuase
> *it* failed, or because the 'func' that it calls returned an
> error.  The memory hotplug does the following:
> 
> 	ret = walk_system_ram_range(..., func);
>          if (ret)
> 		return ret;
> 
> and 'ret' makes it out to userspace, eventually.  The problem
> s, walk_system_ram_range() failues that result from *it* failing
> (as opposed to 'func') return -1.  That leads to a very odd
> -EPERM (-1) return code out to userspace.
> 
> Make walk_system_ram_range() return -EINVAL for internal
> failures to keep userspace less confused.
> 
> This return code is compatible with all the callers that I
> audited.
> 
> This changes both the generic mm/ and powerpc-specific
> implementations to have the same return value.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Reviewed-by: Bjorn Helgaas <bhelgaas@google.com>
> Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Dave Jiang <dave.jiang@intel.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Vishal Verma <vishal.l.verma@intel.com>
> Cc: Tom Lendacky <thomas.lendacky@amd.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: linux-nvdimm@lists.01.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Fengguang Wu <fengguang.wu@intel.com>
> Cc: Borislav Petkov <bp@suse.de>
> Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
> Cc: Takashi Iwai <tiwai@suse.de>
> Cc: Jerome Glisse <jglisse@redhat.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: Keith Busch <keith.busch@intel.com>
> ---
> 
>   b/arch/powerpc/mm/mem.c |    2 +-

walk_system_ram_range() was droped in commit 
https://git.kernel.orghttps://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit/?id=26b523356f49a0117c8f9e32ca98aa6d6e496e1a

Christophe

>   b/kernel/resource.c     |    4 ++--
>   2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff -puN arch/powerpc/mm/mem.c~memory-hotplug-walk_system_ram_range-returns-neg-1 arch/powerpc/mm/mem.c
> --- a/arch/powerpc/mm/mem.c~memory-hotplug-walk_system_ram_range-returns-neg-1	2019-02-25 10:56:47.452908034 -0800
> +++ b/arch/powerpc/mm/mem.c	2019-02-25 10:56:47.458908034 -0800
> @@ -189,7 +189,7 @@ walk_system_ram_range(unsigned long star
>   	struct memblock_region *reg;
>   	unsigned long end_pfn = start_pfn + nr_pages;
>   	unsigned long tstart, tend;
> -	int ret = -1;
> +	int ret = -EINVAL;
>   
>   	for_each_memblock(memory, reg) {
>   		tstart = max(start_pfn, memblock_region_memory_base_pfn(reg));
> diff -puN kernel/resource.c~memory-hotplug-walk_system_ram_range-returns-neg-1 kernel/resource.c
> --- a/kernel/resource.c~memory-hotplug-walk_system_ram_range-returns-neg-1	2019-02-25 10:56:47.454908034 -0800
> +++ b/kernel/resource.c	2019-02-25 10:56:47.459908034 -0800
> @@ -382,7 +382,7 @@ static int __walk_iomem_res_desc(resourc
>   				 int (*func)(struct resource *, void *))
>   {
>   	struct resource res;
> -	int ret = -1;
> +	int ret = -EINVAL;
>   
>   	while (start < end &&
>   	       !find_next_iomem_res(start, end, flags, desc, first_lvl, &res)) {
> @@ -462,7 +462,7 @@ int walk_system_ram_range(unsigned long
>   	unsigned long flags;
>   	struct resource res;
>   	unsigned long pfn, end_pfn;
> -	int ret = -1;
> +	int ret = -EINVAL;
>   
>   	start = (u64) start_pfn << PAGE_SHIFT;
>   	end = ((u64)(start_pfn + nr_pages) << PAGE_SHIFT) - 1;
> _
> 

