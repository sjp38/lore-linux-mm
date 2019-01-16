Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BB84C43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 14:27:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6287620675
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 14:27:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6287620675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F304D8E0006; Wed, 16 Jan 2019 09:27:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB4F48E0002; Wed, 16 Jan 2019 09:27:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7DE18E0006; Wed, 16 Jan 2019 09:27:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id A34B98E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:27:50 -0500 (EST)
Received: by mail-ua1-f69.google.com with SMTP id o13so455271uad.6
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 06:27:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=UQM6mniKlKxrnOmNQBuQkbxwhizn1F4ro8TFUMtXkmo=;
        b=EuR8SqpvchArZkFHqbe7qSN0XA0Vluqq4JbyD+h6EpnFgr96mcmU0oaZyJJsGjHoeN
         UKHGbYIUWCmNtWOOcopibm2i5ECXGccbFHnQOod2W7WFcpjAfgGE6aLAXSXYk1Hec5WD
         39uKlqdowPp/qscwhWLXaerbkAtoMJQExgT5K2rWBJsMtJwbJc0oMsJ56SpOdsmioJkQ
         msLJ92To/ANOeoiCkOshLapwDsHzYRiHYavU+PT1BnEr62dQ8LVnxksQoUYSSVZbOwKK
         Lc5lSSstG21rMoWgVYOKw8/AEIeLvnJHMJuNjF3FoFo7HjB7/HZG+X4g52Ox6Y8W8RGD
         8Cfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
X-Gm-Message-State: AJcUukdCJDCWEbxdVk5VdjUBacnE8uoYLv8TD2Hjgch7+joas0B/9EA3
	101GqV616Ada/udA2j/5gxEo1X4JxCfmCHxsjtvwLymMbFvPDue9Z8g/igkmzb/3jv56OiEJVBm
	gkJbNJkPWOJaAeYoyc7MeMH1EG/iuhsWQCiHz5klRbXO4ljA0OAKNQICff4lD8O1cogB/AfT8GX
	2xnzidxYKOZlmouGewdfn+V0mMLWyJFXpUn0Wx1Gs/e2ro2JUqui3/ZE+xtLols/kx4g4z92dps
	3jAeprMAq9zC2+ZeigYm1W1XD6iV8xx/cSZXRldIHMMrg+GnGz0wEi1PKRk9vJJBJqlAmag1OJf
	axDszEPNHvAH0mL/O2IUaYGHCS//xYYEiM0MjncAaoQo36je+WeEC0x0pIgQGBdmV3fykqjYFg=
	=
X-Received: by 2002:a67:de97:: with SMTP id r23mr3843344vsk.127.1547648870316;
        Wed, 16 Jan 2019 06:27:50 -0800 (PST)
X-Received: by 2002:a67:de97:: with SMTP id r23mr3843316vsk.127.1547648869506;
        Wed, 16 Jan 2019 06:27:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547648869; cv=none;
        d=google.com; s=arc-20160816;
        b=I/0bJVyxv5j461OjSibjLw/5hIeJEl+hO8gQ7IpHJlFacc1nVS9HXG+Ihn2ZaIvUZK
         h9fXNg6mV/p6fDLGrVidC0GVUqCkDv8lJNUpG3oa4IJvlffTco53KpWOFmn7xKp6+tM6
         TCd4nMLq27Eyt2Ax8/eZBVQC5z3SAXTpIpJum2WqGrgwNCJNl39U9McA+WWOq1sASfWm
         oo7OaNp7hLLH0PWZu6VpjO/W53SNsYoayUS+Lp1GkLSg0DkzAD2lyXTQ7zeNWC9WwENo
         mFkNQsM/XDuOA3dDXnX1ylGN/JoZb5IY8zZb55OY5dD2aTDBy0pskzI5BAMlljyQ8DhI
         3jTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=UQM6mniKlKxrnOmNQBuQkbxwhizn1F4ro8TFUMtXkmo=;
        b=IlIcsoiqHWpbwn3Sc6/Kh0Vkzbz0UvJ7ZR0bbLM87YD4ofBEuvWsdTuusSvo+9dCNw
         28eGLLZDnDsf0yxpSILUFmholmBtyE8MhKr3hVphQW7NrIPH3BWh0tJX5N4COlJMKDAO
         WKVDreki03FH4b7D8dWmZx47yE0BlnIj1o5cpaT9V+s0OTwK+jMtI+vQlJgb+3KHYRiK
         vWaT8dTnfxgU6J6CwGXpqS/jIYZY+S3iT0khQdfulLtz/bITatmU61AfR24H851GWaXR
         kioJuuRzxvoMM1l2u9IQUzF+7XSKtWtXgjo9jM/c0qmRaGHryHWHUvuBa4bYXIguNWV+
         3CrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v195sor43564367vkv.69.2019.01.16.06.27.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 06:27:49 -0800 (PST)
Received-SPF: pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
X-Google-Smtp-Source: ALg8bN6VwI1ArYelHZvmR1PaA1MLFLrSrq7A9DMWJ0UBcwJmVEmORYrACtE6Zw/o+h9WHLVB78c6er2JrxSMrNC9Lxk=
X-Received: by 2002:a1f:2ed7:: with SMTP id u206mr3609173vku.72.1547648869025;
 Wed, 16 Jan 2019 06:27:49 -0800 (PST)
MIME-Version: 1.0
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com> <1547646261-32535-20-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1547646261-32535-20-git-send-email-rppt@linux.ibm.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 16 Jan 2019 15:27:35 +0100
Message-ID:
 <CAMuHMdWKPj-2Let44rmaVwh-b6kkGg+0cFPQ-+3k9LP86pB7NA@mail.gmail.com>
Subject: Re: [PATCH 19/21] treewide: add checks for the return value of memblock_alloc*()
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, 
	"David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, 
	Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, 
	Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, 
	Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, 
	Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, 
	Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, 
	Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, 
	Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, 
	"open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE BINDINGS" <devicetree@vger.kernel.org>, kasan-dev@googlegroups.com, 
	alpha <linux-alpha@vger.kernel.org>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-c6x-dev@linux-c6x.org, 
	"linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, 
	linux-mips@vger.kernel.org, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh list <linux-sh@vger.kernel.org>, arcml <linux-snps-arc@lists.infradead.org>, 
	linux-um@lists.infradead.org, USB list <linux-usb@vger.kernel.org>, 
	linux-xtensa@linux-xtensa.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, 
	Openrisc <openrisc@lists.librecores.org>, sparclinux <sparclinux@vger.kernel.org>, 
	"moderated list:H8/300 ARCHITECTURE" <uclinux-h8-devel@lists.sourceforge.jp>, 
	"the arch/x86 maintainers" <x86@kernel.org>, xen-devel@lists.xenproject.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116142735.jHK1XEDpt9Zd6uW8Bty_ragSVjTzchMA-XC1zTpfXSk@z>

Hi Mike,

On Wed, Jan 16, 2019 at 2:46 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> Add check for the return value of memblock_alloc*() functions and call
> panic() in case of error.
> The panic message repeats the one used by panicing memblock allocators with
> adjustment of parameters to include only relevant ones.
>
> The replacement was mostly automated with semantic patches like the one
> below with manual massaging of format strings.
>
> @@
> expression ptr, size, align;
> @@
> ptr = memblock_alloc(size, align);
> + if (!ptr)
> +       panic("%s: Failed to allocate %lu bytes align=0x%lx\n", __func__,

In general, you want to use %zu for size_t

> size, align);
>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

Thanks for your patch!

>  74 files changed, 415 insertions(+), 29 deletions(-)

I'm wondering if this is really an improvement?
For the normal memory allocator, the trend is to remove printing of errors
from all callers, as the core takes care of that.

> --- a/arch/alpha/kernel/core_marvel.c
> +++ b/arch/alpha/kernel/core_marvel.c
> @@ -83,6 +83,9 @@ mk_resource_name(int pe, int port, char *str)
>
>         sprintf(tmp, "PCI %s PE %d PORT %d", str, pe, port);
>         name = memblock_alloc(strlen(tmp) + 1, SMP_CACHE_BYTES);
> +       if (!name)
> +               panic("%s: Failed to allocate %lu bytes\n", __func__,

%zu, as strlen() returns size_t.

> +                     strlen(tmp) + 1);
>         strcpy(name, tmp);
>
>         return name;
> @@ -118,6 +121,9 @@ alloc_io7(unsigned int pe)
>         }
>
>         io7 = memblock_alloc(sizeof(*io7), SMP_CACHE_BYTES);
> +       if (!io7)
> +               panic("%s: Failed to allocate %lu bytes\n", __func__,

%zu, as sizeof() returns size_t.
Probably there are more. Yes, it's hard to get them right in all callers.

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

