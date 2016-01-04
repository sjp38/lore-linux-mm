Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id C8EEE6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 17:08:04 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id f206so2894188wmf.0
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 14:08:04 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id iu6si147927477wjb.116.2016.01.04.14.08.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Jan 2016 14:08:03 -0800 (PST)
Date: Mon, 4 Jan 2016 22:07:43 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v2] ARM: mm: flip priority of CONFIG_DEBUG_RODATA
Message-ID: <20160104220743.GP19062@n2100.arm.linux.org.uk>
References: <20151202202725.GA794@www.outflux.net>
 <20151223195129.GP2793@atomide.com>
 <567B04AB.6010906@redhat.com>
 <20151223212911.GR2793@atomide.com>
 <alpine.LFD.2.20.1512231637110.3603@knanqh.ubzr>
 <20151224001121.GS2793@atomide.com>
 <20151224003406.GA8644@n2100.arm.linux.org.uk>
 <CAGXu5j+MrX-OvnVTYH0hqF2XgZW10PQOviyN=e5heejLsXewVA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5j+MrX-OvnVTYH0hqF2XgZW10PQOviyN=e5heejLsXewVA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Tony Lindgren <tony@atomide.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Laura Abbott <labbott@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Laura Abbott <labbott@fedoraproject.org>

On Mon, Jan 04, 2016 at 12:34:28PM -0800, Kees Cook wrote:
> On Wed, Dec 23, 2015 at 4:34 PM, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
> > On Wed, Dec 23, 2015 at 04:11:22PM -0800, Tony Lindgren wrote:
> >> * Nicolas Pitre <nicolas.pitre@linaro.org> [151223 13:45]:
> >> > We fixed a bunch of similar issues where code was located in the .data
> >> > section for ease of use from assembly code.  See commit b4e61537 and
> >> > d0776aff for example.
> >>
> >> Thanks hey some assembly fun for the holidays :) I also need to check what
> >> all gets relocated to SRAM here.
> >>
> >> In any case, seems like the $subject patch is too intrusive for v4.5 at
> >> this point.
> >
> > Given Christmas and an unknown time between that and the merge window
> > actually opening, I decided Tuesday would be the last day I take any
> > patches into my tree - and today would be the day that I drop anything
> > that causes problems.
> >
> > So, I've already dropped this, so tomorrow's linux-next should not have
> > this change.
> >
> > You'll still see breakage if people enable RODATA though, but that's no
> > different from previous kernels.
> 
> Ugh, sorry for the breakage.
> 
> Should this patch stay as-is and people will fix their various RODATA
> failures during the next devel window, or should I remove the "default
> y if CPU_V7"?

I think we'll keep it as-is, and have another go with it at -rc1 time,
when people have ample chance to then queue up fixes.

They'll have had notice of it, so there's no excuse folk can't work on
the problem in the mean time.  (But, of course, they won't...)

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
