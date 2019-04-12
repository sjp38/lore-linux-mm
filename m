Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 027B8C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 20:43:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BD8C20850
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 20:43:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="l8WRr2vM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BD8C20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31F376B0273; Fri, 12 Apr 2019 16:43:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A8B86B0274; Fri, 12 Apr 2019 16:43:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 171296B0275; Fri, 12 Apr 2019 16:43:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id E8AF86B0273
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 16:43:54 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id b16so8831310iot.5
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 13:43:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=6AtluYqDW96uUvqwdMeng3c3OZl8GyvSWQybASn7yCE=;
        b=AEjpaDAP6lX7HgIi0XDYtss3PFnxPiH3YUiWw9gZwhhqXXVerJ+yC0aWfofs+4Rh1o
         mcVvONE0cBZyrZHSsORFRz70AUYS5LkLBp7BZsxtN+FT/SnOHhxgtPgzB5eQb84eBp+L
         vKrqIS94Yj75xVOcI6uH7tWnp18HThavzQOgqvpVpEWLlu3j1lmOn7YTyGP3/pKGanz5
         B6Iw68JH1/HrDnMekcm5/BeL97+3HSCTK+b4JpF03FYQPMomv2EaVxapBYxS08GhqPql
         85F7xzaeNq7PvFI2TPBRlTtOGy1oRwePu6c0A7oX7+uA2qpRYn+A7+M+RepxPoUtkG/+
         Avjg==
X-Gm-Message-State: APjAAAWs9MdVJb6+FeeVjdLqSVXwNGNtVc3zq1GFIZeN/xgnV7elcyKf
	zlMLaUpOcloEnpf0s4DVxobwSgwLms/KaLxDGhMBE7Gizsoz9zm9HoOxY/ChFGwoh+JGYrHgl+Y
	HxBmxLqCMq1vh2zMXUYN5uet7GrXbmBtDDh5N8KP9WcWAo4GcmXR683t7Dsj90Juw8Q==
X-Received: by 2002:a02:2b1d:: with SMTP id h29mr43723042jaa.76.1555101834586;
        Fri, 12 Apr 2019 13:43:54 -0700 (PDT)
X-Received: by 2002:a02:2b1d:: with SMTP id h29mr43722992jaa.76.1555101833489;
        Fri, 12 Apr 2019 13:43:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555101833; cv=none;
        d=google.com; s=arc-20160816;
        b=sZayB0am/Q2KzCBpEGlWFcur89p01uZN2KT71PTPw6UrcNL4sBu8nUB7uHEUcdksto
         8DpsXImnjDXy9zrgb/ZvtJd9oKHB8w2KvGKBHfVbaTzFgHep+gy3h4xBda0I19HGuGMR
         Dfyp7gMQJcp3koKo81v/Yeb7ihC7eBbp/h7MXUuml/raikD7YLDss3/tuekhqFKVMI9m
         4/JTknfcUu9oHsCrLyTzsf3W0o11X8G67K0/bVHg/15arpAqfkMNR/Mhekc2ClHVmHAv
         7giESC85ozDCHiRAoQ0sc4EuicAhlp81JylqNp66+BbasoLCy+lU8/iAk/u7I8ssC+PP
         aHNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=6AtluYqDW96uUvqwdMeng3c3OZl8GyvSWQybASn7yCE=;
        b=WXdgaOTA7GCqbXRceJw+D0biAPQwIZd+QOkCXQOybaQC1DDXPP2SRgSxR3pAFAoULv
         Oid4iR/JXPoA3ywTKu4fsHABIwLG1LHMiQvbQMNiZwrqEvarC5/+/vWXr7Oh5nat276h
         Q5L6vCjy2enKBXw8KfsfSopFNTutnAPOyKuEIIIL9HjjF8WLrtRRmLfgfVfkfXiAmjJd
         4l4ZaZsEfoAahEXzW4K1O5/wKOZKeiMV0/+MYqr2lh52hb5lcAIK9qZTH45E127fQ933
         xHVZWBA9M6/O8dxvgxuLnmQmuqhZYXLKgR7XvbuoROhV3qCnV6bgjF5ysnUYFLJmvew2
         UbPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=l8WRr2vM;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i9sor16486546itb.34.2019.04.12.13.43.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 13:43:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=l8WRr2vM;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6AtluYqDW96uUvqwdMeng3c3OZl8GyvSWQybASn7yCE=;
        b=l8WRr2vMDpGRPyZHyz5p/XxaN9PNEyEEOI9/aAx+t0l7VEJoScmzSpJaCSLBm6YVeZ
         DaBDzJva5WMpGVLNUHqbd9p61h0DPF1zme9QehX2kYOZ5eCH0w0oP4aFAbSVa9hGdlk5
         iEgJwRFMojRGw2rW5wogk+ih30D2fpXBqBcpHMjcg8w4no0+eN4LB63OvWW+dEXzpPjN
         +OoT0oVZNoffyq4tBExGn8VyMam6AkHkS+8yGbUmv9mjBhxwu6NWWRYd73xui4M7CN0c
         hHxl+JUOkvZ6dPYCHrykg/dQx9mtgboJM3OABohFlxjO8qgnXGB7vAQYULXW4C0OCBpF
         FwlA==
X-Google-Smtp-Source: APXvYqwiQL4vXAimAMwRkowPqhnWs+7hHq2sMXAcLz4kP+dHnzgADgyOtA2d67/2lCApFWzHDTaJIAZ1IcbvP+Ui+kc=
X-Received: by 2002:a24:41cd:: with SMTP id b74mr918494itd.100.1555101833048;
 Fri, 12 Apr 2019 13:43:53 -0700 (PDT)
MIME-Version: 1.0
References: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155440491334.3190322.44013027330479237.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAKv+Gu8ocQGxTAapfjb5WufhL=Qj54LythHcPHsyy+wUnVBnfA@mail.gmail.com>
 <CAPcyv4gUL8j+EaAZ556_NKXLgva++HgPBOeeAUNHN+DAWaewaQ@mail.gmail.com>
 <CAKv+Gu_M-V-3ahHTj10iyx=eC2pBzFg027NmdBX1x7nXrpqK7g@mail.gmail.com> <CAA9_cmeRqr=b-hmaxA0aLZE98YGS9hF8h8JGGp9K6c_qhLK3AQ@mail.gmail.com>
In-Reply-To: <CAA9_cmeRqr=b-hmaxA0aLZE98YGS9hF8h8JGGp9K6c_qhLK3AQ@mail.gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 12 Apr 2019 13:43:42 -0700
Message-ID: <CAKv+Gu_gzHH7onY4WUWV8SAYeVXfMK-W3CaxYZ706sPo6ATZpA@mail.gmail.com>
Subject: Re: [RFC PATCH 1/5] efi: Detect UEFI 2.8 Special Purpose Memory
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, "the arch/x86 maintainers" <x86@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, 
	Darren Hart <dvhart@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, 
	Andy Shevchenko <andy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Apr 2019 at 19:11, Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Tue, Apr 9, 2019 at 10:21 AM Ard Biesheuvel
> <ard.biesheuvel@linaro.org> wrote:
> >
> > On Tue, 9 Apr 2019 at 09:44, Dan Williams <dan.j.williams@intel.com> wrote:
> > >
> > > On Fri, Apr 5, 2019 at 9:21 PM Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> > > >
> > > > Hi Dan,
> > > >
> > > > On Thu, 4 Apr 2019 at 21:21, Dan Williams <dan.j.williams@intel.com> wrote:
> > > > >
> > > > > UEFI 2.8 defines an EFI_MEMORY_SP attribute bit to augment the
> > > > > interpretation of the EFI Memory Types as "reserved for a special
> > > > > purpose".
> > > > >
> > > > > The proposed Linux behavior for special purpose memory is that it is
> > > > > reserved for direct-access (device-dax) by default and not available for
> > > > > any kernel usage, not even as an OOM fallback. Later, through udev
> > > > > scripts or another init mechanism, these device-dax claimed ranges can
> > > > > be reconfigured and hot-added to the available System-RAM with a unique
> > > > > node identifier.
> > > > >
> > > > > A follow-on patch integrates parsing of the ACPI HMAT to identify the
> > > > > node and sub-range boundaries of EFI_MEMORY_SP designated memory. For
> > > > > now, arrange for EFI_MEMORY_SP memory to be reserved.
> > > > >
> > > > > Cc: Thomas Gleixner <tglx@linutronix.de>
> > > > > Cc: Ingo Molnar <mingo@redhat.com>
> > > > > Cc: Borislav Petkov <bp@alien8.de>
> > > > > Cc: "H. Peter Anvin" <hpa@zytor.com>
> > > > > Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> > > > > Cc: Darren Hart <dvhart@infradead.org>
> > > > > Cc: Andy Shevchenko <andy@infradead.org>
> > > > > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > > > > ---
> > > > >  arch/x86/Kconfig                  |   18 ++++++++++++++++++
> > > > >  arch/x86/boot/compressed/eboot.c  |    5 ++++-
> > > > >  arch/x86/boot/compressed/kaslr.c  |    2 +-
> > > > >  arch/x86/include/asm/e820/types.h |    9 +++++++++
> > > > >  arch/x86/kernel/e820.c            |    9 +++++++--
> > > > >  arch/x86/platform/efi/efi.c       |   10 +++++++++-
> > > > >  include/linux/efi.h               |   14 ++++++++++++++
> > > > >  include/linux/ioport.h            |    1 +
> > > > >  8 files changed, 63 insertions(+), 5 deletions(-)
> > > > >
> > > > > diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> > > > > index c1f9b3cf437c..cb9ca27de7a5 100644
> > > > > --- a/arch/x86/Kconfig
> > > > > +++ b/arch/x86/Kconfig
> > > > > @@ -1961,6 +1961,24 @@ config EFI_MIXED
> > > > >
> > > > >            If unsure, say N.
> > > > >
> > > > > +config EFI_SPECIAL_MEMORY
> > > > > +       bool "EFI Special Purpose Memory Support"
> > > > > +       depends on EFI
> > > > > +       ---help---
> > > > > +         On systems that have mixed performance classes of memory EFI
> > > > > +         may indicate special purpose memory with an attribute (See
> > > > > +         EFI_MEMORY_SP in UEFI 2.8). A memory range tagged with this
> > > > > +         attribute may have unique performance characteristics compared
> > > > > +         to the system's general purpose "System RAM" pool. On the
> > > > > +         expectation that such memory has application specific usage
> > > > > +         answer Y to arrange for the kernel to reserve it for
> > > > > +         direct-access (device-dax) by default. The memory range can
> > > > > +         later be optionally assigned to the page allocator by system
> > > > > +         administrator policy. Say N to have the kernel treat this
> > > > > +         memory as general purpose by default.
> > > > > +
> > > > > +         If unsure, say Y.
> > > > > +
> > > >
> > > > EFI_MEMORY_SP is now part of the UEFI spec proper, so it does not make
> > > > sense to make any understanding of it Kconfigurable.
> > >
> > > No, I think you're misunderstanding what this Kconfig option is trying
> > > to achieve.
> > >
> > > The configuration capability is solely for the default kernel policy.
> > > As can already be seen by Christoph's response [1] the thought that
> > > the firmware gets more leeway to dictate to Linux memory policy may be
> > > objectionable.
> > >
> > > [1]: https://lore.kernel.org/lkml/20190409121318.GA16955@infradead.org/
> > >
> > > So the Kconfig option is gating whether the kernel simply ignores the
> > > attribute and gives it to the page allocator by default. Anything
> > > fancier, like sub-dividing how much is OS managed vs device-dax
> > > accessed requires the OS to reserve it all from the page-allocator by
> > > default until userspace policy can be applied.
> > >
> >
> > I don't think this policy should dictate whether we pretend that the
> > attribute doesn't exist in the first place. We should just wire up the
> > bit fully, and only apply this policy at the very end.
>
> The bit is just a policy hint, if the kernel is not implementing any
> of the policy why even check for the bit?
>

Because I would like things like the EFI memory map dumping code etc
to report the bit regardless of whether we are honoring it or not.

> >
> > > > Instead, what I would prefer is to implement support for EFI_MEMORY_SP
> > > > unconditionally (including the ability to identify it in the debug
> > > > dump of the memory map etc), in a way that all architectures can use
> > > > it. Then, I think we should never treat it as ordinary memory and make
> > > > it the firmware's problem not to use the EFI_MEMORY_SP attribute in
> > > > cases where it results in undesired behavior in the OS.
> > >
> > > No, a policy of "never treat it as ordinary memory" confuses the base
> > > intent of the attribute which is an optional hint to get the OS to not
> > > put immovable / non-critical allocations in what could be a precious
> > > resource.
> > >
> >
> > The base intent is to prevent the OS from using memory that is
> > co-located with an accelerator for any purpose other than what the
> > accelerator needs it for. Having a Kconfigurable policy that may be
> > disabled kind of misses the point IMO. I think 'optional hint' doesn't
> > quite capture the intent.
>
> That's not my understanding, and an EFI attribute is the wrong
> mechanism to meet such a requirement. If this memory is specifically
> meant for use with a given accelerator then it had better be marked
> reserved and the accelerator driver is then responsible for publishing
> the resource to the OS if at all.
>
> You did prompt me to go back and re-read the wording in the spec. It
> still seems clear to me that the attribute is an optional hint not a
> hard requirement. Whether the OS honors an optional hint is an OS
> policy and I fail to see why the OS should bother to detect the bit
> without implementing any associated policy.
>

Because not taking a hint is not the same thing as pretending it isn't
there to begin with.

> > > Moreover, the interface for platform firmware to indicate that a
> > > memory range should never be treated as ordinary memory is simply the
> > > existing "reserved" memory type, not this attribute. That's the
> > > mechanism to use when platform firmware knows that a driver is needed
> > > for a given mmio resource.
> > >
> >
> > Reserved memory is memory that simply should never touched at all by
> > the OS, and on ARM, we take care never to map it anywhere.
>
> That's not a guarantee, at least on x86. Some shipping persistent
> memory platforms describe it as reserved and then the ACPI NFIT
> further describes what that reserved memory contains and how the OS
> can use it. See commit af1996ef59db "ACPI: Change NFIT driver to
> insert new resource".

The UEFI spec is pretty clear about the fact that reserved memory
shouldn't ever be touched by the OS. The fact that x86 platforms exist
that violate this doesn't mean we should abuse it in other ways as
well.

