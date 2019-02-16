Return-Path: <SRS0=AfK9=QX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4C68C10F00
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 10:55:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C7E2222E3
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 10:55:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gTSYYkp1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C7E2222E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 963678E0002; Sat, 16 Feb 2019 05:55:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9128E8E0001; Sat, 16 Feb 2019 05:55:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8296F8E0002; Sat, 16 Feb 2019 05:55:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 443478E0001
	for <linux-mm@kvack.org>; Sat, 16 Feb 2019 05:55:18 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id k10so9558243pfi.5
        for <linux-mm@kvack.org>; Sat, 16 Feb 2019 02:55:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1Ubpr1Ey/DmY/KE61Qrh0yzi4L35UYNNw5PJu00uODc=;
        b=lJLmaRMRQUYknSjrmxnmf81/iHCYXOYpcBcuIA/3wrdJwUDWgO7mfybhDbZjHyQ7qI
         f2FAirjoR+pKDCQhfUwtK09o07QLZujwlA+FLYFL/9+C2DrS4fFHqou2Idw4bRr3syQc
         xQweVGhA83iExrhzk5u+oAizV5SMnfGpXk/bCpys6xQ37yoGYvZoC0J7Z5anxMJ26Vrs
         yiywK2JDxDB20QMRVN6JQVxAY/Ytwsq3mDM0wKuYg/mtKWrK38UTBysGgQAnb8V+G1xJ
         ZNHLvpScPBchJVaeh7P6HfrZC9L69EPPBYUCGfuohC7BN7qSk6cB022C3Sum6DGzX7sz
         jETQ==
X-Gm-Message-State: AHQUAuaqePG7YC+Ks8B4QKPkC1hgky7EcpfFJ1Z4YXyLQhjEOkXXCREz
	8qJ6eyQ5JeZKinp4bq7q39ExGlu89IYLc5a14eVHS62+KGhHSb0VAE4dJUV11Wu14Y/qtP4pIaB
	37Uylo1w/BbCbB2g/cdl2VpDsQpbAQT2BiVZ0ndyzoCIiLgtQ3G2CGnnAtLSb53KPlsXRFDuLPv
	oVxD8E+mYO8mHdTfZz+vXWuArNfrt5PEUD8f3Ct8UJpL/D6mGrG4qXNZQUSjotMAZbtZONJRaSL
	W37wONJmnmnDzJVJPvtTIg4tqbDVmH3fmHK7Z2qIsNk3QF3f8W5yuABeJj3G1jEpJAv2vjH6d0g
	mdkk+vhsjUOCUsAn6UIG8p3Hgk2W53eMu3Ao2DBmmbAVenGUy9KM2wcWKw1RxQqF3G68SYne0FD
	V
X-Received: by 2002:a62:57dd:: with SMTP id i90mr14356966pfj.154.1550314517675;
        Sat, 16 Feb 2019 02:55:17 -0800 (PST)
X-Received: by 2002:a62:57dd:: with SMTP id i90mr14356918pfj.154.1550314516651;
        Sat, 16 Feb 2019 02:55:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550314516; cv=none;
        d=google.com; s=arc-20160816;
        b=ggkJBOZiIX1qgFZF/aNSvWe5Gx6w7BODCGsJkPRzXj1Q4jKujGy9FWptC/95i/wMde
         N9guXTRcM3olgcBPRxNtrzqw2qS9fTG+qtAKWTZ7jFXtTHkbw2AGV6rah24KYSat6nJP
         x3fy2puwor5Ce9bCMf/nOgARWVC3Og/Iz8fQwvDWA1hnYrXHvd2nLIItYXf+WOmAQ5sJ
         XVu8Hhe6pwmOmofqo0nK30E3U11sARgVC5JYKySB3iHmhJ+ZmiIyRfSabcGx+dbORGty
         aZ2boxqxxQpXnUtYOIePRgeQ8rkBW+JkpxlkFv/hSw2pGB0hQp8H2ITYpZ3S8FfaPJzS
         v06A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=1Ubpr1Ey/DmY/KE61Qrh0yzi4L35UYNNw5PJu00uODc=;
        b=MzEKcmLi2oSQHQe7n3hxNAAnJDLWxAAXqnidjRD78Nevpr/Z13jXCRc5NhlTo0m8FM
         k5r8aEyfCI+E37pRFtLyW1gs87ncuKocIEtgo+PkUVs7v0JPlHvEouq3WWLPtjFaX380
         td/3Ve3yTvtRRdcpejbnbAY+FccICVTAc57MTX3saWSrXF+6F+TpY+aGkShweFbJ1uVh
         irT64knvPPdwo0pkHQUli7lY39gNehph1sDe8XrePI5V1FCQPtgYy60ORnbqK2Lo2dh8
         PQnnZPj08A3f82oIHS2g4FbDaS4Ioz3+2yMK2hK+j/R93E5evGr79/RDXyR0exR+z+uc
         GsRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gTSYYkp1;
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b10sor12417027plm.14.2019.02.16.02.55.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 16 Feb 2019 02:55:16 -0800 (PST)
Received-SPF: pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gTSYYkp1;
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=1Ubpr1Ey/DmY/KE61Qrh0yzi4L35UYNNw5PJu00uODc=;
        b=gTSYYkp1t3MnTZM0YoT8ot7TKpB/68aT35/5SpKN4og5QIhe8orF0G0hFRBEdlhzSZ
         QUI97HjYOShyGwqv/RBr4sBgk9vJyWEO/KhEYRDTdKe6kqbIepfy1i+jNqeQgQT5i9nx
         GUT3mzRHk+JnWlSPY2PQ4JzIm2C4WlnViSb8R+UVlPdqwnIYhtEjM3wD/9jy4iHCKAmO
         d82k+tDkXgOQBBQWmicHzH0OcQPf3Q7Xzm0PhQK0a7GDmXsghgaioI8raZ1m0wk67uD8
         2i1TAfvSNY8TgWPw0OuZRv8Wh3Gf7KjwfDCTRQYBPrTOEheaKTZfu7uTA3x1GSXnyf7M
         GtXw==
X-Google-Smtp-Source: AHgI3IaJGJ4E5JLUuz+5RAh+KUilztY5KioLABGSyqMSqji8EHYOrI10oopn/wpXsFIzfD3Hl7vpJg==
X-Received: by 2002:a17:902:2dc3:: with SMTP id p61mr14670803plb.166.1550314515841;
        Sat, 16 Feb 2019 02:55:15 -0800 (PST)
Received: from localhost (123-243-232-193.tpgi.com.au. [123.243.232.193])
        by smtp.gmail.com with ESMTPSA id p12sm17159170pfj.81.2019.02.16.02.55.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Feb 2019 02:55:15 -0800 (PST)
Date: Sat, 16 Feb 2019 21:55:11 +1100
From: Balbir Singh <bsingharora@gmail.com>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@ozlabs.org, aneesh.kumar@linux.vnet.ibm.com, jack@suse.cz,
	erhard_f@mailbox.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] powerpc/64s: Fix possible corruption on big endian due
 to pgd/pud_present()
Message-ID: <20190216105511.GA31125@350D>
References: <20190214062339.7139-1-mpe@ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214062339.7139-1-mpe@ellerman.id.au>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 05:23:39PM +1100, Michael Ellerman wrote:
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

Not sure why that should happen, why is the result an int? What
causes the casting of pgd_t & be64 to be truncated to an int.

> _PAGE_PRESENT is 0x8000000000000000ul. This means pgd_present() and
> pud_present() are always false at compile time, and the compiler
> elides the subsequent code.
> 
> Remarkably with that bug present we are still able to boot and run
> with few noticeable effects. However under some work loads we are able
> to trigger a warning in the ext4 code:
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

Care to put a big FAT warning, so that we don't repeat this again
(as in authors planning on changing these bits). 

Balbir Singh.
  

