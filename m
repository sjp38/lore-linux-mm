Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9B89C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:32:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C457222DA
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:32:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C457222DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC97C8E0002; Thu, 14 Feb 2019 11:31:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D50848E0001; Thu, 14 Feb 2019 11:31:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C41CE8E0002; Thu, 14 Feb 2019 11:31:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 686C48E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:31:59 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id p52so2679909eda.18
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 08:31:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dGB9RBkZesdHOgFy6liuEtRqoMywJBqINem8etCnZ1Y=;
        b=Tv1tDuVuSCuzksSw2ghQGmcEu+Vwx8Ny003iWWFGR1tRauRs26kSe/jqGoCRn3U0Ob
         S6zlTg212VSPaAG8Yfnw/75hgX59Y/IWs5uqhiOiXXvQYYQd0KGmdN1CTaaV7eMunRnu
         XwoP0m5njsVuYN65ghvKoUNEU/PHPcXUV+678ETVm9xdAsGJcPbWo2r2i8Yzg7dFqFhK
         jOJ9oM03g4WjcQ6Dl4eWDX9lUUFtCG+EcmF+KsO2SgWDXgt8LyRdUn0hVh6xhs0wX7Hj
         6zf40B3xLZOK5GzupakZE0aEs0Z4XNUu84HUDBfFJcMrpkIjpH/TbRdJEBrHapmCeTT9
         y4tg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAuZefxYnZvxkMmAf40z0ekgxDb2tnDlRvjRZPeKbZ/aP/RH7A8EV
	9b7gYYoTV8tH/CXLK/0T/xndMgRqIf0Azzc7NbFmJeARGrZFKcfAZIsesw6M81yEyS96MET4est
	7c4ogpm2hQ3KmyEbOBBRTtWvkw70oygJqOTAYuWOjzWqGDsHtYafw0bl7byXZ5HKSbQ==
X-Received: by 2002:a17:906:49d4:: with SMTP id w20mr3487228ejv.191.1550161918910;
        Thu, 14 Feb 2019 08:31:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY/fY0rTg6zyGMErOwZkekXiu/7jzBXfQIBnwDZ/QmXn0tvFORuEhziahFL4e87dXNp5NYR
X-Received: by 2002:a17:906:49d4:: with SMTP id w20mr3487158ejv.191.1550161917716;
        Thu, 14 Feb 2019 08:31:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550161917; cv=none;
        d=google.com; s=arc-20160816;
        b=HDTnARSTbXKOFmuLpeZuctbAzgSj6ohIRQ/ZID2Qrt+pLkPJ3Qf9Xy36CGigl3qdmb
         cCMMyA6G7TWR/Vgfzej7nmHBnTqdY0H5hGQoYtd7q2mT0EogH1jChCPRrkDQADGjb89T
         5NOdY6ADD0EkIYf5TsaqfJ6hRiLpo8V7QyjQ3S1IOiqqmuk9fAJ3ofA6CnDSip/sBr0n
         YgJOOwYbeZR6un7mNeLt0itCDOYrByn/4qPN4VWXL9owD4dntTb5J7h7eKq5UyauOg9m
         OYXwogJKDUGJxfT9m66W5YeDd5gpvtXL2/a9AiAey7joLG4Psv/r8JAQXZVMsYvhesl6
         hVYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dGB9RBkZesdHOgFy6liuEtRqoMywJBqINem8etCnZ1Y=;
        b=J4uY60rybZEHKniyY9hfT4IQaXpUdSm65fCcOekI/JcDAq35JXxbLJTjXg03ajV5zu
         yjp/YPGDm+4PhFf8982P87V0yqHDbMsfkEu0Ea4RPLCibPE3LEQT3K6Mj6Co3vuElydb
         SJVYHmsEyG18eseb1tj1KhYgWyD8OcOn5vAeCBD/Uaq779LeE/QmKMb9+2rD7Z6okGSc
         SnNHNlE8bAbr90xzjGNh50sQ8wxcraoYX68RM6U4dIpjVu23/jPT7CraxxviXxSJ/hUL
         Aux/Lklmg/PpMM50spk2JqL7Qm1EV7ePHz/yiPfiw7lhGa0AboPpjbljqgqxZ2hzu6oP
         ws+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 12si1003615edx.436.2019.02.14.08.31.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 08:31:57 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E9F93AF63;
	Thu, 14 Feb 2019 16:31:56 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 0929E1E0900; Thu, 14 Feb 2019 17:31:56 +0100 (CET)
Date: Thu, 14 Feb 2019 17:31:56 +0100
From: Jan Kara <jack@suse.cz>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@ozlabs.org, aneesh.kumar@linux.vnet.ibm.com, jack@suse.cz,
	erhard_f@mailbox.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] powerpc/64s: Fix possible corruption on big endian due
 to pgd/pud_present()
Message-ID: <20190214163156.GB23000@quack2.suse.cz>
References: <20190214062339.7139-1-mpe@ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214062339.7139-1-mpe@ellerman.id.au>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 14-02-19 17:23:39, Michael Ellerman wrote:
> In v4.20 we changed our pgd/pud_present() to check for _PAGE_PRESENT
> rather than just checking that the value is non-zero, e.g.:
> 
>   static inline int pgd_present(pgd_t pgd)
>   {
>  -       return !pgd_none(pgd);
>  +       return (pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
>   }
> 
> Unfortunately this is broken on big endian, as the result of the
> bitwise && is truncated to int, which is always zero because
> _PAGE_PRESENT is 0x8000000000000000ul. This means pgd_present() and
> pud_present() are always false at compile time, and the compiler
> elides the subsequent code.
> 
> Remarkably with that bug present we are still able to boot and run
> with few noticeable effects. However under some work loads we are able
> to trigger a warning in the ext4 code:

Wow, good catch. I wouldn't believe there are so few bad effects from
such a major breakage! :)

								Honza

> 
>   WARNING: CPU: 11 PID: 29593 at fs/ext4/inode.c:3927 .ext4_set_page_dirty+0x70/0xb0
>   CPU: 11 PID: 29593 Comm: debugedit Not tainted 4.20.0-rc1 #1
>   ...
>   NIP .ext4_set_page_dirty+0x70/0xb0
>   LR  .set_page_dirty+0xa0/0x150
>   Call Trace:
>    .set_page_dirty+0xa0/0x150
>    .unmap_page_range+0xbf0/0xe10
>    .unmap_vmas+0x84/0x130
>    .unmap_region+0xe8/0x190
>    .__do_munmap+0x2f0/0x510
>    .__vm_munmap+0x80/0x110
>    .__se_sys_munmap+0x14/0x30
>    system_call+0x5c/0x70
> 
> The fix is simple, we need to convert the result of the bitwise && to
> an int before returning it.
> 
> Thanks to Jan Kara and Aneesh for help with debugging.
> 
> Fixes: da7ad366b497 ("powerpc/mm/book3s: Update pmd_present to look at _PAGE_PRESENT bit")
> Cc: stable@vger.kernel.org # v4.20+
> Reported-by: Erhard F. <erhard_f@mailbox.org>
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
> ---
>  arch/powerpc/include/asm/book3s/64/pgtable.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
> index c9bfe526ca9d..d8c8d7c9df15 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -904,7 +904,7 @@ static inline int pud_none(pud_t pud)
>  
>  static inline int pud_present(pud_t pud)
>  {
> -	return (pud_raw(pud) & cpu_to_be64(_PAGE_PRESENT));
> +	return !!(pud_raw(pud) & cpu_to_be64(_PAGE_PRESENT));
>  }
>  
>  extern struct page *pud_page(pud_t pud);
> @@ -951,7 +951,7 @@ static inline int pgd_none(pgd_t pgd)
>  
>  static inline int pgd_present(pgd_t pgd)
>  {
> -	return (pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
> +	return !!(pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
>  }
>  
>  static inline pte_t pgd_pte(pgd_t pgd)
> -- 
> 2.20.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

