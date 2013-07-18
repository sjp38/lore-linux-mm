Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 190B96B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 11:28:26 -0400 (EDT)
Message-ID: <51E80973.9000308@intel.com>
Date: Thu, 18 Jul 2013 08:27:47 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
References: <1374097503-25515-1-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1374097503-25515-1-git-send-email-toshi.kani@hp.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com

On 07/17/2013 02:45 PM, Toshi Kani wrote:
> +CONFIG_ARCH_MEMORY_PROBE is supported on powerpc only. On x86, this config
> +option is disabled by default since ACPI notifies a memory hotplug event to
> +the kernel, which performs its hotplug operation as the result. Please
> +enable this option if you need the "probe" interface on x86.

There's no prompt for this and no way to override what you've done here
without hacking Kconfig/.config files.

It's also completely wrong to say "CONFIG_ARCH_MEMORY_PROBE is supported
on powerpc only."  It works just fine on x86.  In fact, I was just using
it today without ACPI being around.

I'd really prefer you don't do this.  Do you really have random
processes on your system poking at random sysfs files and then
complaining when things break?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
