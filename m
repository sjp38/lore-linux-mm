Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 666EEC43612
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 20:54:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17F802133F
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 20:54:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="coilP1y2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17F802133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BFC88E0002; Fri, 11 Jan 2019 15:54:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87A568E0001; Fri, 11 Jan 2019 15:54:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75DBB8E0002; Fri, 11 Jan 2019 15:54:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 43FE18E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 15:54:11 -0500 (EST)
Received: by mail-vk1-f198.google.com with SMTP id 202so3296475vkp.16
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 12:54:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=IrGK6kyFNDsbI2MCdBSCbW6jFZfGOqsBleTmUr3JpGg=;
        b=mVtZGS+pUnYwDnZswwz8tFTKS4pv6+1HPSHhKrCr5nfkoxLOhnVjZU5TuakDC+9CcP
         OCi6eh1m+216flEEsouTyLhuWA+oNMCLP2m9a8uKe4swlMsIOi9AffWJCiVcw4cnlet1
         cgjh4+uYnqV5YWXqSVEwWXqYS5g+cXHMr5rIzrtiRZq9X+QH9DN4Rde5i8uE1cfufEUI
         NScvYpgKoazjrXSSWc+8gQMX/3PEZPx/fVz3RdG+qC6CY2mND64tNmCMKTKBn261lolF
         dpz7/0fsmbo8oxAUbjy0D29JmjSLqt+/UJXbFDc5r+g82RbSfAxduQhXF/Q85IQXy0nW
         0dNA==
X-Gm-Message-State: AJcUukc57owgwDnqzwSSpHriE/ToI0tM9hQtKHXE2LAI7YYX7jJLmD8O
	9n7ZRREakyG6YPVKiwSs4cwQt29FRoY4KtPuQl2gSnToUPpEjHb/eCQxXUFQ/53IengWP2/udd2
	b6F8waWLHTLPGThGhylNMi0oRfgnJatb4jmz7ZTVRArMcUSLcxU2F4ZiOPZYwMI5rnOl7msz7j6
	A4xwE1Hi84Syn+8Pji1/ncH4TwwEDlonLW5WOeRZzX/nat6kYsiPoaK0Pun3q/0AIuCqSH52oMZ
	Syr1ARZV+CUTuiG8/Hj17h4O/a40j2/Pi++BfFipNdKHbN0ByzNcm9ZIbB/S8NkxkWmY09aY1Oh
	9Cslnz4iZi452LofglUmUmmrblx88qTJRM8xdcyyCGcs5au/HRR1mdtMSJoRwmgQw3TeTvrbZvD
	D
X-Received: by 2002:ab0:8d9:: with SMTP id o25mr6130181uaf.127.1547240050839;
        Fri, 11 Jan 2019 12:54:10 -0800 (PST)
X-Received: by 2002:ab0:8d9:: with SMTP id o25mr6130169uaf.127.1547240049864;
        Fri, 11 Jan 2019 12:54:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547240049; cv=none;
        d=google.com; s=arc-20160816;
        b=B8XPX0xiNKqIw35Bd1vYuak0vodPOi9dn87UG6E6JgWbgOjx5lIEAxYfoo/tPczau3
         omYb7reudJuWOhxuXYVBq7cHccGAJaPSUicB0feFHHrn9oCf3lQC7KD1+fhUqPfmjMXt
         nJgyGnyoBqOkI+Egpnz8PGjEEh7fUg4YvYEmPNysUzRj6wC1XsQwzHPTObwtjE/YxQLs
         dd0SPphag3326i7uuybiAlE5LvLrP6FMIWTkThtmRTPSsLYe7XrGSLixKZEAGt/rRzc2
         T07qlIyiBa2UC5RaLWj7D+YGGintWvvQp3pGtl0/lpKOt2RoajCs9E63//xvctycaJ89
         ioGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=IrGK6kyFNDsbI2MCdBSCbW6jFZfGOqsBleTmUr3JpGg=;
        b=gjnFF4KZi9IJ8i59oaXH8iac64XHjAwwgUDtk/eNYdlnWtRGs6WYMKcARpHjD34TuI
         WZ9JtXU1o/GuZboZjnIEE+RLWkTMLTiUDXu2NfkwE2RlNIXGXJe28Yc7GK/wbizv+myd
         9W5sDGlaeUiUkvXOb9jKbEgO0+vVqR7X4BJFjt9C7idF8J+ieK7Arco1Y5WjduTp/ZTv
         mEOptAZ6MC2vDVYEuD6cHWfyVxHBZtbdUjC69YJb70/wvOYuyUIsUFd3EvU0iHmZ1IR0
         FjnQyBWxSdE3GkCj4KzTPd8WVtlCo65pQ293bw12BMHfnWbjQDZIymauy9K6EL2eoQRS
         OcFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=coilP1y2;
       spf=pass (google.com: domain of baicar.tyler@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=baicar.tyler@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f79sor45703897vsf.85.2019.01.11.12.54.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 12:54:09 -0800 (PST)
Received-SPF: pass (google.com: domain of baicar.tyler@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=coilP1y2;
       spf=pass (google.com: domain of baicar.tyler@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=baicar.tyler@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=IrGK6kyFNDsbI2MCdBSCbW6jFZfGOqsBleTmUr3JpGg=;
        b=coilP1y26oGDU6wUS+fvN+jrkiGu9WFMDZmv/ZTZS4As1As/sXkyZcPN1kkVUWzLv0
         gn9FkVbwV1XaU+FmX4S4bEP/vpeiaCrQ/8Y0ChNe40IqQpny5tjNB3De3QKHqsdXNbDs
         busvGNR8zIJ1kH/KF7mkgRq3BwD+k/LguR2H9c9f63QITZcue+wI0Vppi0mLwKO/eMe2
         n+oeM9Jg+b7Hr46BKGYfFWG2x2bfHEJkwqoTReKmFJQFoW68COjPW1x+ojLubeLl2gNF
         NmZZxG4GJAXADSi8BzIwJn8yh7+KEap8o9c5Hu+901WZLLOIVDLlo+I1O7sx79YT+kjw
         s1ZA==
X-Google-Smtp-Source: ALg8bN6W78g9CdT1Dp2WH+89xHb0aWAx6jqcwxO/2B2w6wWik+vga3B0ClPW1DAI0zjaquedPgoA3wRvjxOjOAPnvXA=
X-Received: by 2002:a67:e242:: with SMTP id w2mr6715610vse.134.1547240049549;
 Fri, 11 Jan 2019 12:54:09 -0800 (PST)
MIME-Version: 1.0
References: <20181203180613.228133-1-james.morse@arm.com> <20181203180613.228133-11-james.morse@arm.com>
 <20181211183634.GO27375@zn.tnic> <56cfa16b-ece4-76e0-3799-58201f8a4ff1@arm.com>
 <CABo9ajArdbYMOBGPRa185yo9MnKRb0pgS-pHqUNdNS9m+kKO-Q@mail.gmail.com>
 <20190111120322.GD4729@zn.tnic> <CABo9ajAk5XNBmNHRRfUb-dQzW7-UOs5826jPkrVz-8zrtMUYkg@mail.gmail.com>
 <0939c14d-de58-f21d-57a6-89bdce3bcb44@arm.com>
In-Reply-To: <0939c14d-de58-f21d-57a6-89bdce3bcb44@arm.com>
From: Tyler Baicar <baicar.tyler@gmail.com>
Date: Fri, 11 Jan 2019 15:53:56 -0500
Message-ID:
 <CABo9ajB9TAkycLbe++yyDibXx33MntNV_Hy27JSXCVsvP6rf7g@mail.gmail.com>
Subject: Re: [PATCH v7 10/25] ACPI / APEI: Tell firmware the estatus queue
 consumed the records
To: James Morse <james.morse@arm.com>
Cc: Borislav Petkov <bp@alien8.de>, Linux ACPI <linux-acpi@vger.kernel.org>, 
	kvmarm@lists.cs.columbia.edu, 
	arm-mail-list <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org, 
	Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, 
	Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, 
	Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, 
	Fan Wu <wufan@codeaurora.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111205356.NBzldR9foRm304AFALsGJ9z7GhQ-RbNrAy1iULrmjmE@z>

On Fri, Jan 11, 2019 at 1:09 PM James Morse <james.morse@arm.com> wrote:
> On 11/01/2019 15:32, Tyler Baicar wrote:
> > On Fri, Jan 11, 2019 at 7:03 AM Borislav Petkov <bp@alien8.de> wrote:
> >> On Thu, Jan 10, 2019 at 04:01:27PM -0500, Tyler Baicar wrote:
> >>> On Thu, Jan 10, 2019 at 1:23 PM James Morse <james.morse@arm.com> wrote:
> >>>>>>
> >>>>>> +    if (is_hest_type_generic_v2(ghes) && ghes_ack_error(ghes->generic_v2))
> >>>>>
> >>>>> Since ghes_ack_error() is always prepended with this check, you could
> >>>>> push it down into the function:
> >>>>>
> >>>>> ghes_ack_error(ghes)
> >>>>> ...
> >>>>>
> >>>>>       if (!is_hest_type_generic_v2(ghes))
> >>>>>               return 0;
> >>>>>
> >>>>> and simplify the two callsites :)
> >>>>
> >>>> Great idea! ...
> >>>>
> >>>> .. huh. Turns out for ghes_proc() we discard any errors other than ENOENT from
> >>>> ghes_read_estatus() if is_hest_type_generic_v2(). This masks EIO.
> >>>>
> >>>> Most of the error sources discard the result, the worst thing I can find is
> >>>> ghes_irq_func() will return IRQ_HANDLED, instead of IRQ_NONE when we didn't
> >>>> really handle the IRQ. They're registered as SHARED, but I don't have an example
> >>>> of what goes wrong next.
> >>>>
> >>>> I think this will also stop the spurious handling code kicking in to shut it up
> >>>> if its broken and screaming. Unlikely, but not impossible.
>
> [....]
>
> >>> Looks good to me, I guess there's no harm in acking invalid error status blocks.
>
> Great, I didn't miss something nasty...
>
>
> >> Err, why?
> >
> > If ghes_read_estatus() fails, then either there was no error populated or the
> > error status block was invalid.
> > If the error status block is invalid, then the kernel doesn't know what happened
> > in hardware.
>
> What do we mean by 'hardware' here? We're receiving a corrupt report of
> something via memory.

By Hardware here I meant whatever hardware was reporting the error.

> The GHESv2 ack just means we're done with the memory. I think it exists because
> the external-agent can't peek into the CPU to see if its returned from the
> notification.
>
>
> > I originally thought this was changing what's acked, but it's just changing the
> > return value of ghes_proc() when ghes_read_estatus() returns -EIO.
>
> Sorry, that will be due to my bad description.
>
>
> >> I don't know what the firmware glue does on ARM but if I'd have to
> >> remain logical - which is hard to do with firmware - the proper thing to
> >> do would be this:
> >>
> >>         rc = ghes_read_estatus(ghes, &buf_paddr);
> >>         if (rc) {
> >>                 ghes_reset_hardware();
> >
> > The kernel would have no way of knowing what to do here.
>
> Is there anything wrong with what we do today? We stamp on the records so that
> we don't processes them again. (especially if is polled), and we tell firmware
> it can re-use this memory.
>
> (I think we should return an error, or print a ratelimited warning for corrupt
> records)

Agree, the print is already present in ghes_read_estatus.

> >>         }
> >>
> >>         /* clear estatus and bla bla */
> >>
> >>         /* Now, I'm in the success case: */
> >>          ghes_ack_error();
> >>
> >>
> >> This way, you have the error path clear of something unexpected happened
> >> when reading the hardware, obvious and separated. ghes_reset_hardware()
> >> clears the registers and does the necessary steps to put the hardware in
> >> good state again so that it can report the next error.
> >>
> >> And the success path simply acks the error and does possibly the same
> >> thing. The naming of the functions is important though, to denote what
> >> gets called when.
>
> I think this duplicates the record-stamping/acking. If there is anything in that
> memory region, the action for processed/copied/ignored-because-its-corrupt is
> the same.
>
> We can return on ENOENT out earlier, as nothing needs doing in that case. Its
> what the GHES_TO_CLEAR spaghetti is for, we can probably move the ack thing into
> ghes_clear_estatus(), that way that thing means 'I'm done with this memory'.
>
> Something like:
> -------------------------
> rc = ghes_read_estatus();
> if (rc == -ENOENT)
>         return 0;

We still should be returning at least the -ENOENT from ghes_read_estatus().
That is being used by the SEA handling to determine if an SEA was properly
reported/handled by the host kernel in the KVM SEA case.

Here are the relevant functions:
https://elixir.bootlin.com/linux/latest/source/drivers/acpi/apei/ghes.c#L797
https://elixir.bootlin.com/linux/latest/source/arch/arm64/mm/fault.c#L723
https://elixir.bootlin.com/linux/latest/source/virt/kvm/arm/mmu.c#L1706

>
> if (!rc) {
>         ghes_do_proc() and friends;
> }
>
> ghes_clear_estatus();
>
> return rc;
> -------------------------
>
> We would no longer return errors from the ack code, I suspect that can only
> happen for a corrupt gas, which we would have caught earlier as we rely on the
> mapping being cached.

