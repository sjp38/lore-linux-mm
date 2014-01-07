Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id ED35F6B0035
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 18:12:21 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id z20so157542yhz.36
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 15:12:21 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id 25si12228933yhd.102.2014.01.07.15.12.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jan 2014 15:12:20 -0800 (PST)
Message-ID: <52CC89B4.4060300@zytor.com>
Date: Tue, 07 Jan 2014 15:11:48 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/5] mm: create generic early_ioremap() support
References: <1389062120-31896-1-git-send-email-msalter@redhat.com> <1389062120-31896-2-git-send-email-msalter@redhat.com>
In-Reply-To: <1389062120-31896-2-git-send-email-msalter@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Salter <msalter@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, patches@linaro.org, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>

On 01/06/2014 06:35 PM, Mark Salter wrote:
> 
> There is one difference from the existing x86 implementation which
> should be noted. The generic early_memremap() function does not return
> an __iomem pointer and a new early_memunmap() function has been added
> to act as a wrapper for early_iounmap() but with a non __iomem pointer
> passed in. This is in line with the first patch of this series:
> 

This makes a lot of sense.  However, I would suggest that we preface the
patch series with a single patch changing the signature for the existing
x86 function, that way this change becomes bisectable.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
