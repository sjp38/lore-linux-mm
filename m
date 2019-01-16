Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3518FC43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 15:16:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E626720675
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 15:16:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="cz/mxUOt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E626720675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DD468E0006; Wed, 16 Jan 2019 10:16:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78C6E8E0002; Wed, 16 Jan 2019 10:16:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A3C38E0006; Wed, 16 Jan 2019 10:16:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2C18E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:16:00 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v2so4001961plg.6
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 07:16:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YQNeNEPB7cCk0rtvx5bb0DlYo5/NXbjHBFkyIlg5MyU=;
        b=n/ObOO9+4jc91FGM0ZqFpB/m4sapAZIK5n6+ihNA5gdRRhVMhSB5eKVgK1GKaC44G7
         edzpRzuO0PInF7f3XFVrx53ArQs0r4FQSWUpjB4GD78CDcZWLwgWA5g57ekeS40NExA2
         wRBkvntlPorjUlOtrlSYW+TrqryyVfh9405y8sGJ0LwIBdNdS1MwvyNjAZ/HPUx2cO0N
         F56fbj2DgzmDkv/ATetIKIsy4BDT8nCYVHSgJ2Iv5MJu8Z/xFAIiEIYUwU3HGXffwlUw
         ObYYnqGuYCXP/C7j4oEMWRz0W4nuvwjlQUwYnsDNjlCKgXw7FikJpWwvBOdsUx3+BuRM
         ZrPA==
X-Gm-Message-State: AJcUukerF2A++4FIcpkXp5rMaCvwxfSl43wl1eDi3DytWkd4daDXauWf
	S/4jn0SIwTpFFOJfaQ6LHmsioUbXRlNJjIxq/hvrTVFMJ4cPKOSI9QLvPRWadpMhEEYXXjMydg8
	V1MtmA8e/2+MYvS5GyacIBZ9PgbKtIrT8CZWhFslI71fwWEk/WBtPWOG77UTsNBiOGQ==
X-Received: by 2002:a63:e156:: with SMTP id h22mr9318330pgk.255.1547651759508;
        Wed, 16 Jan 2019 07:15:59 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5lXQGCFW/seIDoq1nPbdy66k7RHDffnLd7D0UNPPMkkEMP+Xd3gyMu1ZpxwpiTCIR5i+Fa
X-Received: by 2002:a63:e156:: with SMTP id h22mr9318249pgk.255.1547651758361;
        Wed, 16 Jan 2019 07:15:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547651758; cv=none;
        d=google.com; s=arc-20160816;
        b=G+BjKyg/zn9JhvWTlwrgV1eMsIdDGb1hZin+vZi/solC7hmeZ1I7bOUYxcL8rIQ2va
         utJs5w/el+8FPwkzkCZYVwZkzRc68t7tRssmwfjkwWaXoyEp8MSf79ZlvCoyg4LWGPgw
         HXg3iADEU3/ELwo1K7AAa8mw1RXgCm/WG4PzrhAHORaNvxb+V0xdO1crR7XXVKS5Hdv8
         R2vU56mlI8Hddhgb2Y2KhfdUiRpIejOczqXn1H0bWMGwXz4aVz3KsBUtFI89hHR5chA1
         BG6rT4DtORkfZho7nI9sKJqlL4An/IEV2riXu0apD7UZqyNiWh2clbEQ5rZuARBvoG3D
         +Blw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YQNeNEPB7cCk0rtvx5bb0DlYo5/NXbjHBFkyIlg5MyU=;
        b=Fg+8HYCGmXIAdA6lFAKgyzNeOw+Z+NzgJ3ePPqwpPmNHm6IMLhNOqf2qLYh3xV22KW
         9dtWlSBkIRXnHLEUZX5P5p9+4jQIYz1wfKRrgFbvP8rt9KpivR0YoAEfOtmNh6qTMbHH
         1Q1220pxMIRnM7k05IKmr80XAc1zMRlAKKkVH8O21CC5Vwo6JjwiaLlcdygn8+AEWN86
         +Unl7HIkFsBJ8jbzOw5NG4DTdpWX0JrGFk7OB/rb/xxzwMxi0Go+w9jJsPRhIYffs8ym
         gKMemtpv1KXk/aETuLNZYwlWA0OCfcFgj4PzJ1KlodvGDI/sNVIdAFR/seTSxkx8PTJi
         L7Sw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="cz/mxUOt";
       spf=pass (google.com: domain of robh+dt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=robh+dt@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x9si6326963pll.131.2019.01.16.07.15.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 07:15:58 -0800 (PST)
Received-SPF: pass (google.com: domain of robh+dt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="cz/mxUOt";
       spf=pass (google.com: domain of robh+dt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=robh+dt@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-qk1-f179.google.com (mail-qk1-f179.google.com [209.85.222.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C7BC8214C6
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 15:15:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1547651757;
	bh=FhtIDYW+wCB2HQTzHX9fQ0IjelhfkG3XvKPLXhG6y4I=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=cz/mxUOt5OPnW7gLDOlDXsidNDxUeirqp6gmfNlKRRpsmh39V120d3h0URx45MOLt
	 DcV1s5ZwrPOb5SF0FG3BFDcMuL1jE6ByFG6CHSa/1yAGt6BVMPzeP2TKkcMQmFpGmV
	 OjdU5HmwWicT6qUQ+YNcMKL0fWY75CX8xRFTxFWM=
Received: by mail-qk1-f179.google.com with SMTP id a1so3940059qkc.5
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 07:15:57 -0800 (PST)
X-Received: by 2002:a37:7682:: with SMTP id r124mr6995371qkc.79.1547651756813;
 Wed, 16 Jan 2019 07:15:56 -0800 (PST)
MIME-Version: 1.0
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com> <1547646261-32535-9-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1547646261-32535-9-git-send-email-rppt@linux.ibm.com>
From: Rob Herring <robh+dt@kernel.org>
Date: Wed, 16 Jan 2019 09:15:45 -0600
X-Gmail-Original-Message-ID: <CAL_Jsq+7=yiOYS0Nq7euXK4qghjAu9-mzruW0Jt1N146gK+DCQ@mail.gmail.com>
Message-ID:
 <CAL_Jsq+7=yiOYS0Nq7euXK4qghjAu9-mzruW0Jt1N146gK+DCQ@mail.gmail.com>
Subject: Re: [PATCH 08/21] memblock: drop __memblock_alloc_base()
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, 
	Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, 
	"David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, 
	Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, 
	Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, 
	Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, 
	Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, 
	Richard Weinberger <richard@nod.at>, Russell King <linux@armlinux.org.uk>, 
	Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, 
	Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, 
	devicetree@vger.kernel.org, kasan-dev@googlegroups.com, 
	linux-alpha@vger.kernel.org, 
	"moderated list:ARM/FREESCALE IMX / MXC ARM ARCHITECTURE" <linux-arm-kernel@lists.infradead.org>, linux-c6x-dev@linux-c6x.org, 
	linux-ia64@vger.kernel.org, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-m68k@lists.linux-m68k.org, 
	linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, 
	SH-Linux <linux-sh@vger.kernel.org>, arcml <linux-snps-arc@lists.infradead.org>, 
	linux-um@lists.infradead.org, Linux USB List <linux-usb@vger.kernel.org>, 
	linux-xtensa@linux-xtensa.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, 
	Openrisc <openrisc@lists.librecores.org>, sparclinux@vger.kernel.org, 
	"moderated list:H8/300 ARCHITECTURE" <uclinux-h8-devel@lists.sourceforge.jp>, x86@kernel.org, 
	xen-devel@lists.xenproject.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116151545.Kpiq5EroF1cdTQIAuKUN_jeRyLdxDhwFvEqQO0Zudj0@z>

On Wed, Jan 16, 2019 at 7:45 AM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> The __memblock_alloc_base() function tries to allocate a memory up to the
> limit specified by its max_addr parameter. Depending on the value of this
> parameter, the __memblock_alloc_base() can is replaced with the appropriate
> memblock_phys_alloc*() variant.
>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/sh/kernel/machine_kexec.c |  3 ++-
>  arch/x86/kernel/e820.c         |  2 +-
>  arch/x86/mm/numa.c             | 12 ++++--------
>  drivers/of/of_reserved_mem.c   |  7 ++-----
>  include/linux/memblock.h       |  2 --
>  mm/memblock.c                  |  9 ++-------
>  6 files changed, 11 insertions(+), 24 deletions(-)

Acked-by: Rob Herring <robh@kernel.org>

