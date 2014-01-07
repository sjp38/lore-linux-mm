Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f175.google.com (mail-ve0-f175.google.com [209.85.128.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA566B006E
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 12:24:09 -0500 (EST)
Received: by mail-ve0-f175.google.com with SMTP id jx11so363622veb.20
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 09:24:09 -0800 (PST)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id b20si22723860veu.98.2014.01.07.09.24.07
        for <linux-mm@kvack.org>;
        Tue, 07 Jan 2014 09:24:07 -0800 (PST)
Date: Tue, 7 Jan 2014 17:23:38 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2 3/5] arm: add early_ioremap support
Message-ID: <20140107172338.GB6234@arm.com>
References: <1389062120-31896-1-git-send-email-msalter@redhat.com>
 <1389062120-31896-4-git-send-email-msalter@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389062120-31896-4-git-send-email-msalter@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Salter <msalter@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "patches@linaro.org" <patches@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Russell King <linux@arm.linux.org.uk>, Will Deacon <Will.Deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>

On Tue, Jan 07, 2014 at 02:35:18AM +0000, Mark Salter wrote:
> This patch uses the generic early_ioremap code to implement
> early_ioremap for ARM. The ARM-specific bits come mostly from
> an earlier patch from Leif Lindholm <leif.lindholm@linaro.org>
> here:
> 
>   https://lkml.org/lkml/2013/10/3/279
> 
> Signed-off-by: Mark Salter <msalter@redhat.com>
> Tested-by: Leif Lindholm <leif.lindholm@linaro.org>
> CC: linux-arm-kernel@lists.infradead.org
> CC: Russell King <linux@arm.linux.org.uk>
> CC: Catalin Marinas <catalin.marinas@arm.com>
> CC: Will Deacon <will.deacon@arm.com>
> CC: Arnd Bergmann <arnd@arndb.de>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
