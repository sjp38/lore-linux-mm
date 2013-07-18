Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id D08676B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 12:27:46 -0400 (EDT)
Message-ID: <1374164815.24916.84.camel@misato.fc.hp.com>
Subject: Re: [PATCH] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 18 Jul 2013 10:26:55 -0600
In-Reply-To: <51E80973.9000308@intel.com>
References: <1374097503-25515-1-git-send-email-toshi.kani@hp.com>
	 <51E80973.9000308@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com

On Thu, 2013-07-18 at 08:27 -0700, Dave Hansen wrote:
> On 07/17/2013 02:45 PM, Toshi Kani wrote:
> > +CONFIG_ARCH_MEMORY_PROBE is supported on powerpc only. On x86, this config
> > +option is disabled by default since ACPI notifies a memory hotplug event to
> > +the kernel, which performs its hotplug operation as the result. Please
> > +enable this option if you need the "probe" interface on x86.
> 
> There's no prompt for this and no way to override what you've done here
> without hacking Kconfig/.config files.
> 
> It's also completely wrong to say "CONFIG_ARCH_MEMORY_PROBE is supported
> on powerpc only."  It works just fine on x86.  In fact, I was just using
> it today without ACPI being around.

This statement has been there in the document (no change), and I
consider "supported" and "may work" are two different things.

> I'd really prefer you don't do this.  Do you really have random
> processes on your system poking at random sysfs files and then
> complaining when things break?

I am afraid that the "probe" interface does not provide the level of
quality suitable for regular users.  It takes any value and blindly
extends the page table.  Also, we are not aware of the use of this
interface on x86.  Would you elaborate why you need this interface on
x86?  Is it for your testing, or is it necessary for end-users?  If the
former, can you modify .config file to enable it?

Thanks,
-Toshi   



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
