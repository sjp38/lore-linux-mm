Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8F4E96B0259
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 11:10:26 -0500 (EST)
Received: by mail-oi0-f42.google.com with SMTP id m82so42673666oif.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 08:10:26 -0800 (PST)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id t204si7351777oie.133.2016.02.25.08.10.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 08:10:26 -0800 (PST)
Message-ID: <1456419790.15454.6.camel@hpe.com>
Subject: Re: [PATCH] x86/mm: fix slow_virt_to_phys() for X86_PAE again
From: Toshi Kani <toshi.kani@hpe.com>
Date: Thu, 25 Feb 2016 10:03:10 -0700
In-Reply-To: <1456394292-9030-1-git-send-email-decui@microsoft.com>
References: <1456394292-9030-1-git-send-email-decui@microsoft.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dexuan Cui <decui@microsoft.com>, gregkh@linuxfoundation.org, akpm@linux-foundation.org, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, driverdev-devel@linuxdriverproject.org, jasowang@redhat.com
Cc: olaf@aepfle.de, apw@canonical.com, kys@microsoft.com, haiyangz@microsoft.com

On Thu, 2016-02-25 at 01:58 -0800, Dexuan Cui wrote:
> "d1cd12108346: x86, pageattr: Prevent overflow in slow_virt_to_phys() for
> X86_PAE"
> was unintentionally removed by the recent
> "34437e67a672: x86/mm: Fix slow_virt_to_phys() to handle large PAT bit".
> 
> And, the variable 'phys_addr' was defined as "unsigned long" by mistake
> -- it should
> be "phys_addr_t".
> 
> As a result, Hyper-V network driver in 32-PAE Linux guest can't work
> again.
> 
> Fixes: "commmit 34437e67a672: x86/mm: Fix slow_virt_to_phys() to handle
> large PAT bit"
> Signed-off-by: Dexuan Cui <decui@microsoft.com>
> Cc: Toshi Kani <toshi.kani@hpe.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: K. Y. Srinivasan <kys@microsoft.com>
> Cc: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: gregkh@linuxfoundation.org
> Cc: linux-mm@kvack.org
> Cc: olaf@aepfle.de
> Cc: apw@canonical.com
> Cc: jasowang@redhat.com
> Cc: stable@vger.kernel.org

Thanks for the fix and adding the comment to explain the trick! A The change
looks good to me.

Reviewed-by: Toshi Kani <toshi.kani@hpe.com>

-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
