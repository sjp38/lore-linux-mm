Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA80AC4151A
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 09:52:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92C282177E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 09:52:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92C282177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36BED8E0003; Tue, 29 Jan 2019 04:52:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F3078E0001; Tue, 29 Jan 2019 04:52:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A2358E0003; Tue, 29 Jan 2019 04:52:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C3C278E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 04:52:34 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 82so16453355pfs.20
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 01:52:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=e5JIdfOLXA7vK5jRrayApluVxSs2X8eqtZM51YBaQSk=;
        b=L5xpyNi6q1/MwcDRaPkikzH3MJAllQR+AqBRL5ohw0yRQ5wVadpeLH/B3PZFHg1uRQ
         QBNIJcK6fmMBvhpPMNJCXQhy4pD8xgal7njQnjz4DGarye3zFzNgs+/eCtRMCFFlQo5G
         NfsdvojEow7uzopFzTM9DLiciP7axZ4ie8sV4lpTpsqgPxbqBjHl6/JAKpLTzykUfBWR
         wVUVOV8+sHEAFl+1E9mN15Lb1roIDRGgPNBzFCy5l0zJ3NjEuUeh7LcuK7WINvXl3ziE
         c73YjI119TY/ab7L6DgxqNglrCjjTdaUM9c/ZVV4BxtzuG1e4xJZhQqGrZ2KCU6Nhh/i
         cjPg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AJcUukfaaN1uX2oSnqDdUDpIR7JkI8yL3KAKuZO/+u5roOZKJmdUI5eg
	7l1FjdkmTfrmcwaemdzJsr9yMby78jTWx58f1FHDFMqTChn6GZErb2UuzFWuJ5gZbplK5QycFRV
	npQ9mfW9j/255SugfXHyJQYs+5aaSYVZ6noruXnFDfFyXWVHxSHc8ZuiIRuUDbCk=
X-Received: by 2002:a63:2bc4:: with SMTP id r187mr22883916pgr.306.1548755554487;
        Tue, 29 Jan 2019 01:52:34 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4mWRjX+GCMnFmvvezH5oXmj/myeIh+lPUB9SUWHDfuabca5gvTvvbFhW9RGnUgKNFO/F2V
X-Received: by 2002:a63:2bc4:: with SMTP id r187mr22883887pgr.306.1548755553664;
        Tue, 29 Jan 2019 01:52:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548755553; cv=none;
        d=google.com; s=arc-20160816;
        b=sJSlZZrbVa7H/vKorKzaxSQH1Ci0rodIjbl4R5SSEP0ThzrW0qc6pOmvkgYen6Gr/j
         AXKi21FE8JgkStqN/nc6FVN0KZS4X/NCETJGrmwHS7b5fbKDZrRFzrVcJg3X8PA5xLAs
         f+pFs6tXg2JUI4JjoJwO2gZXeb5i0ZRzVPBCOsTTQgNf1gu5bjBYohQpWq1pKw97mRGc
         yVC1+t3XARWDdpzCSBnbunbraTN7Xp2krqpnaGH/Lm0FCkSgVkGq/hk68yocyDgX7sCM
         dXD1D+PlgJxzqm/FarjkfBkyUBfplYHTFrG1Q4Hrzb5keP4ehH1UzpdzIv0ftPlhZ2WN
         kmBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=e5JIdfOLXA7vK5jRrayApluVxSs2X8eqtZM51YBaQSk=;
        b=GCRyzLIWP1D8/YN5h+RTkEfjQkqIRDyscm27ziLveSfOQhAU43WscLvhGfhoBTLg4l
         00xa4vr32UvGYTPdOWt0/kpqbkn/weqnBTfIC3Z0ZrwK03jzPFDcfWTvTXhwg5YMH8oM
         mqoensUxPwg54NNWhzOHRVBlC8YtqG5Y/WmkFNlOB2Mx9RIMVo57jtOCwcc4p3yWCfi/
         DgMeFHMGR0oLv0JDTZmcV8VZ7mf/UDeq4f2Sxkb9HzV66D1oSNcooJS9B8elc8swNgdh
         h6yGbQOfJMkAucGJJUxTmIsSYqC/MfcZBlE85N/3nyfChNffmNICI3Eb254iAsQuEn4S
         +4Gg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id j65si34744650pge.444.2019.01.29.01.52.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 01:52:33 -0800 (PST)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43phcK6Xzfz9s9h;
	Tue, 29 Jan 2019 20:52:17 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas
 <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S.
 Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert
 Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao
 <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens
 <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner
 <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michal Simek
 <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek
 <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger
 <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King
 <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck
 <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato
 <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org,
 kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org,
 linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org,
 linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org,
 linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org,
 sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp,
 x86@kernel.org, xen-devel@lists.xenproject.org, Christophe Leroy
 <christophe.leroy@c-s.fr>, Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH v2 02/21] powerpc: use memblock functions returning virtual address
In-Reply-To: <1548057848-15136-3-git-send-email-rppt@linux.ibm.com>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com> <1548057848-15136-3-git-send-email-rppt@linux.ibm.com>
Date: Tue, 29 Jan 2019 20:52:17 +1100
Message-ID: <871s4vssdq.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mike Rapoport <rppt@linux.ibm.com> writes:

> From: Christophe Leroy <christophe.leroy@c-s.fr>
>
> Since only the virtual address of allocated blocks is used,
> lets use functions returning directly virtual address.
>
> Those functions have the advantage of also zeroing the block.
>
> [ MR:
>  - updated error message in alloc_stack() to be more verbose
>  - convereted several additional call sites ]
>
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/powerpc/kernel/dt_cpu_ftrs.c |  3 +--
>  arch/powerpc/kernel/irq.c         |  5 -----
>  arch/powerpc/kernel/paca.c        |  6 +++++-
>  arch/powerpc/kernel/prom.c        |  5 ++++-
>  arch/powerpc/kernel/setup_32.c    | 26 ++++++++++++++++----------
>  5 files changed, 26 insertions(+), 19 deletions(-)

LGTM.

Acked-by: Michael Ellerman <mpe@ellerman.id.au>

cheers

