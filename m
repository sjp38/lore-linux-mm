Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8142B6B01D3
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 08:21:17 -0400 (EDT)
Received: by bwz4 with SMTP id 4so1938833bwz.14
        for <linux-mm@kvack.org>; Tue, 22 Jun 2010 05:21:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1277208351.29532.5.camel@e102109-lin.cambridge.arm.com>
References: <AANLkTimb7rP0rS0OU8nan5uNEhHx_kEYL99ImZ3c8o0D@mail.gmail.com>
	<1277189909-16376-1-git-send-email-sankar.curiosity@gmail.com>
	<4C20702C.1080405@cs.helsinki.fi>
	<1277196403-20836-1-git-send-email-sankar.curiosity@gmail.com>
	<20100622113135.GB20140@linux-sh.org>
	<1277208351.29532.5.camel@e102109-lin.cambridge.arm.com>
Date: Tue, 22 Jun 2010 15:21:14 +0300
Message-ID: <AANLkTin9ssqksoAvafRdsogmfrDUhShHCF9aCUb7CtCl@mail.gmail.com>
Subject: Re: [PATCH] kmemleak: config-options: Default buffer size for
	kmemleak
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Paul Mundt <lethal@linux-sh.org>, Sankar P <sankar.curiosity@gmail.com>, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, lrodriguez@atheros.com, rnagarajan@novell.com, teheo@novell.com, linux-mm@kvack.org, paulmck@linux.vnet.ibm.com, mingo@elte.hu, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 22, 2010 at 3:05 PM, Catalin Marinas
<catalin.marinas@arm.com> wrote:
> The defconfig change for this specific platform may be a better option
> but I thought defconfigs are to provide a stable (and maybe close to
> optimal) configuration without all the debugging features enabled
> (especially those slowing things down considerably).

The defconfig change was definitely not a clean solution to this
problem. Better bake the fix in Kconfig proper even if it means
dependency on CONFIG_SH or something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
