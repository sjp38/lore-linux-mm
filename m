Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5E6FC43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 08:21:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8921C2192D
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 08:21:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8921C2192D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04E8E8E0003; Sun, 17 Feb 2019 03:21:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F183B8E0001; Sun, 17 Feb 2019 03:21:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDED88E0003; Sun, 17 Feb 2019 03:21:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 96C8D8E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 03:21:41 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id v16so10200676plo.17
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 00:21:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:in-reply-to:to
         :from:cc:subject:message-id:date;
        bh=j/UvSGfSztz0OHdmLB77Qf8RScU3j8nSJQ5qAVHUHkE=;
        b=Adsew9SgA1WWQWJIj8ATtHPXsClul1lnyuxrgtmjYScc86y09CGftkA642yIdqY1ZI
         Ni3i5FbW4QPLrEeJbxR40FaaYsQyy2FCW3L4rrbMGlN4A2nYluc3PYUl8vXJObNs8eao
         Yz/A73/oy7p14gV3clvZBqRmdSirUb1XUNRgJ24ci2+2Wjmmjs7uzvSLzTJyQ/pPaK2w
         H//M+1kM3ytZcy0+xFy0Y2zDbTDq+O5c7syllPsyCvUhLeZY/fHYVKvwpe1whNLClkK2
         Fr1swYI7lwpDpI6DcCXemZGXE41d5JaU0sY34uepbErMbv936NiFsC/0AVYJ/zaEimCh
         Dedw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of michael@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=michael@ozlabs.org
X-Gm-Message-State: AHQUAuYWkA4jp0Aw4AgMed7GnUc1FR0/kgjYO0oYbHjF34RqHbse5JT5
	QUEghefk44pRsagF5hDjRiR0eoYNEpAFVbjz27MUFzFojGi7qnJD09TunUZi46s/Nde8SuU8OCM
	3Vosi38R+S+Udg8l2tOsCgmE38V1PyZzbRUy1V6PnzTzUnlulMg9DHVlHyTmyPuA=
X-Received: by 2002:a17:902:6508:: with SMTP id b8mr19487377plk.17.1550391701246;
        Sun, 17 Feb 2019 00:21:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZxn8GEt9peJTworpMQn8Al74rRmHUOY9s9GZfGtYqWhhQzd2cnGUpXEfWCl8aQusLb7wSF
X-Received: by 2002:a17:902:6508:: with SMTP id b8mr19487318plk.17.1550391700177;
        Sun, 17 Feb 2019 00:21:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550391700; cv=none;
        d=google.com; s=arc-20160816;
        b=LRIM1p1FAGn0BMkrM3OyV/M+R5OW4aCNAMDrG3dizT5cKgaATeKG6tcKy41vKKaBF4
         KNXgQBm86xemZHLVGTvcugMX1rl+AHtb7mZodKWkpNcTb2WWBeToiCeo3k3jVA3Kb+tN
         nNox67dwyjafvOZjD5X8FFb1M6xSLBIlJs3rq3FSfo7bPyNanLuWW95bbKDyzWyNr0wg
         HZiB+BJke38oORW4Wv3QW44+qHmBeBD/ftd2MvRQmPM6dgOhSN2M3rQ/ZbEkeXnniPxS
         sFviflFBg2dqp0fu+XyCxrnPo+9k7Ttklh3D+3N6650gFf/wnxNcfhaTsdD2IC+FlrUj
         sNWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:message-id:subject:cc:from:to:in-reply-to;
        bh=j/UvSGfSztz0OHdmLB77Qf8RScU3j8nSJQ5qAVHUHkE=;
        b=jpHbunGJPp6cuy0hwlJUEZY9hBWL2pjX2h1oa+g/ij62JID1EGtGAMm+XgpjfV1scp
         XkZ05uPTSxtTdFd+PNDIT+hDRxlXLDXxy+clKgaSjZWWbmLG7curIy8Ei27ZIiG1tzm6
         UkSvoux3p3Ngpv729h9JAnlKoZxGgH6EvfdLzgH4FfY1H2R8zeWHR/878aF/9RhxuI17
         lli/SBvqbCt9kGDRlJpVh+K6UzVUQ/xIEZxO8b17SbZF/SLo1WyzZqJ+oYNH4byEp4fb
         WVyCr/YmrVVRmjY7ctb+uSfH8vYGyns2FuZERDh/ZfQTO966/f+ahLzXrumtmrb+CFAy
         KttA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of michael@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=michael@ozlabs.org
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id i33si10580399pld.329.2019.02.17.00.21.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Feb 2019 00:21:40 -0800 (PST)
Received-SPF: pass (google.com: domain of michael@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of michael@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=michael@ozlabs.org
Received: by ozlabs.org (Postfix, from userid 1034)
	id 442Khx2lFLz9sDX; Sun, 17 Feb 2019 19:21:37 +1100 (AEDT)
X-powerpc-patch-notification: thanks
X-powerpc-patch-commit: a58007621be33e9f7c7bed5d5ff8ecb914e1044a
X-Patchwork-Hint: ignore
In-Reply-To: <20190214062339.7139-1-mpe@ellerman.id.au>
To: Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@ozlabs.org
From: Michael Ellerman <patch-notifications@ellerman.id.au>
Cc: linux-mm@kvack.org, erhard_f@mailbox.org, jack@suse.cz, aneesh.kumar@linux.vnet.ibm.com, linux-kernel@vger.kernel.org
Subject: Re: powerpc/64s: Fix possible corruption on big endian due to pgd/pud_present()
Message-Id: <442Khx2lFLz9sDX@ozlabs.org>
Date: Sun, 17 Feb 2019 19:21:37 +1100 (AEDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-02-14 at 06:23:39 UTC, Michael Ellerman wrote:
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

Applied to powerpc fixes.

https://git.kernel.org/powerpc/c/a58007621be33e9f7c7bed5d5ff8ecb9

cheers

