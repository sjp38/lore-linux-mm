Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id D568D82F90
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 15:01:51 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l126so160437368wml.0
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 12:01:51 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id q72si53302004wmd.52.2015.12.23.12.01.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Dec 2015 12:01:50 -0800 (PST)
Date: Wed, 23 Dec 2015 20:01:32 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v2] ARM: mm: flip priority of CONFIG_DEBUG_RODATA
Message-ID: <20151223200132.GW8644@n2100.arm.linux.org.uk>
References: <20151202202725.GA794@www.outflux.net>
 <20151223195129.GP2793@atomide.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151223195129.GP2793@atomide.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Lindgren <tony@atomide.com>
Cc: Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Nicolas Pitre <nico@linaro.org>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel-hardening@lists.openwall.com, linux-arm-kernel@lists.infradead.org, Laura Abbott <labbott@fedoraproject.org>

On Wed, Dec 23, 2015 at 11:51:29AM -0800, Tony Lindgren wrote:
> Also all omap3 boards are now oopsing in Linux next if PM is enabled:

I'm not sure that's entirely true.  My LDP3430 works fine with this
change in place, and that has CONFIG_PM=y.  See my nightly build/boot
results, which includes an attempt to enter hibernation.  Remember
that last night's results are from my tree plus arm-soc's for-next.

Maybe there's some other change in linux-next which, when combined
with this change, is provoking it?

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
