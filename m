Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id E43606B003D
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 11:10:17 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id gq1so1920997obb.18
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 08:10:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 25si1331793yhd.277.2014.01.08.08.10.15
        for <linux-mm@kvack.org>;
        Wed, 08 Jan 2014 08:10:16 -0800 (PST)
Message-ID: <1389197388.29144.37.camel@deneb.redhat.com>
Subject: Re: [PATCH v2 1/5] mm: create generic early_ioremap() support
From: Mark Salter <msalter@redhat.com>
Date: Wed, 08 Jan 2014 11:09:48 -0500
In-Reply-To: <52CC89B4.4060300@zytor.com>
References: <1389062120-31896-1-git-send-email-msalter@redhat.com>
	 <1389062120-31896-2-git-send-email-msalter@redhat.com>
	 <52CC89B4.4060300@zytor.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, patches@linaro.org, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Dave Young <dyoung@redhat.com>

On Tue, 2014-01-07 at 15:11 -0800, H. Peter Anvin wrote:
> On 01/06/2014 06:35 PM, Mark Salter wrote:
> > 
> > There is one difference from the existing x86 implementation which
> > should be noted. The generic early_memremap() function does not return
> > an __iomem pointer and a new early_memunmap() function has been added
> > to act as a wrapper for early_iounmap() but with a non __iomem pointer
> > passed in. This is in line with the first patch of this series:
> > 
> 
> This makes a lot of sense.  However, I would suggest that we preface the
> patch series with a single patch changing the signature for the existing
> x86 function, that way this change becomes bisectable.

Ok, that sounds like a good idea. I'm uncertain how best to coordinate
with Dave Young's patch series to avoid conflicts. His first patch does
the signature change (and adds the early_memunmap function but that
isn't used anywhere):

 https://lkml.org/lkml/2013/12/20/143

Any thoughts on how best to avoid potential merge conflicts here?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
