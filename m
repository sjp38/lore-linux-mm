Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B56F9C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 23:17:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72F63218DE
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 23:17:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ns64+bku"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72F63218DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 108158E0003; Tue, 26 Feb 2019 18:17:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E0A58E0001; Tue, 26 Feb 2019 18:17:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F10818E0003; Tue, 26 Feb 2019 18:17:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 959608E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 18:17:53 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m25so2257218edd.6
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 15:17:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=F/ZWUspDnO9H+N1b+3KaSbEisQ9DROKLGDc6Wk9zF/Q=;
        b=QBq8GAJt14Xyv93aFCr7dUQux1LIyxV6XZyFdR7t2RgDsMHs8yJ7JdBxCX5wKgKZxl
         hX56Xwd5l0SOk5oPqY/y98YFsehjPXypFTr3F3mppdYgaZ4jTxhKriLgQm3Mo3nJWI5F
         yRip+i2wTYT/g3W3oFkxt5ztTPXrAqzLb3OR7gVX7FMpUjRiDSwwn4Vpas8Kur0bAsZm
         WrjtDdOXLsfbgDOCq5hB8iGlT6oCruI5oxk9b/g8iP5dW/uanANXjLIiRoqGi2dlzgVQ
         T1LnWPALyGta/taePpK+FqlaStwf0hUUxGjDjdT6a9bhRT2olIRHcyfGZu8qbswHXLZd
         wrxw==
X-Gm-Message-State: AHQUAuYjqXBXgo6KKBMw8bPGrY/FN6vRAuqSnvuvr0mT9A5lU6UAs56t
	0DrPAj2AZql7jWPuJxmPgXB9k4WSY1JT7tsLSfrRQOD66cQa6RFgqiRL1OEFIKnNNCz6sOTeL9G
	k0EgYukJbif0OnkAdxRG5FXTyfr/t/XWmFXZSWmAApHXyRKP1jaJQ+Jp+JWMRH1rCwBm4sblYg4
	DBwj9fZEqajsWTa9CWtvn1OIzhArfMZr2O7VjxYJzzO4+9t74/sq3RVBFWoT46OlQHc5J8Ke89V
	LUszB5QRZgcZ+d5bNp3KtGW1Y3G9XNHPI7wWwgoDByVMCc8WC4fiT6yL6RRMJbmJ808Go4VCHrJ
	+XGz6AU+wUhRBD/LtUqJm1EE6vPUKoO64pDGNNLID4Cn8tpDvrUh2up1mAn341sLtiE8HVzExdA
	o
X-Received: by 2002:aa7:d58e:: with SMTP id r14mr10174762edq.39.1551223073045;
        Tue, 26 Feb 2019 15:17:53 -0800 (PST)
X-Received: by 2002:aa7:d58e:: with SMTP id r14mr10174723edq.39.1551223072022;
        Tue, 26 Feb 2019 15:17:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551223072; cv=none;
        d=google.com; s=arc-20160816;
        b=G7j6Qtjcicfz+Q/Csu7kdVvgwlCcNAbXracPAwy+gEm1+MqjkYmQkPYL0uvD3rFh57
         DJOy4lYyfgS+Z3P+xMAU4TwLWQVk1mqsdbZufrvVoVBOoD/9L76y7Sp9xdxOxaFr7naT
         6itWwai8iaaPAtiftH5Tb6/hMRjQT1F7dkQ2Opu+DXKI+I0b7WOeVFsyeXsDiHJQUX93
         tMGJAGXTg4MInWNIKPg8CT8416Ie/TCENw7SB5TCqZdhrdBUwJwVYhdNvNVBZbiJuLtf
         wAaO8O4COjHvLpb86VkKaw6zEkyEaLcEzL7rvB23pZ96ancHMa7rT+B8d1qm3gyV171z
         BN9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=F/ZWUspDnO9H+N1b+3KaSbEisQ9DROKLGDc6Wk9zF/Q=;
        b=nqXQWO+2SYpa0MEeKu6mCcehqczo0v0SGxoxOeso7xBCQjA8PaRvCDWlm6Z86mbpST
         h/+DZgt3c7IDK5w+Gop4w2coFTGNPOAIxtK6o8VB92JlSG7nmSlxuonw/I3SJQiVTI7t
         nDMlUWKGL/9FA/wTuCYirCZHI6u8LkChKZyVuBpDe2cLTE1J6y4ZMGhKC4G/Nyf4aPio
         cznbgKVdiLJb052oO18SsGkq9BGQOlfkfGBCzmwJk3AKizP0YMej5mjEv7v7vZAEhatY
         rrV+D3SVUdLzFvM1ucuocRseYBXsBzTBQfkTrhEKCts73t8aZSEZpfsCXoGud6cLMUpR
         8Z8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ns64+bku;
       spf=pass (google.com: domain of luc.vanoostenryck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=luc.vanoostenryck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e18sor7718275ede.16.2019.02.26.15.17.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 15:17:52 -0800 (PST)
Received-SPF: pass (google.com: domain of luc.vanoostenryck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ns64+bku;
       spf=pass (google.com: domain of luc.vanoostenryck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=luc.vanoostenryck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=F/ZWUspDnO9H+N1b+3KaSbEisQ9DROKLGDc6Wk9zF/Q=;
        b=Ns64+bkuLm12DoKtMqYvm9spiyuFy91esqRW620Tr8a7c6yO/zBoKktXkM25pJWO7N
         KYZHrHySgbKp0ukEqgvOhVKztZuddf20j5XWcS8omSkG42v0aRxVNYrlBxPtJ5MKsME7
         ICL0xa9DMOfylbdIxpEwAZmOFNWw8UhcTBw6asiXQj4RekvDc6+JweuyVSjAgI3eHELu
         vrpNWsBvdmFuFoBrNOxVtfbPgEBXp3J4Y4DdxNVAhdJW9HKxxO6kJVWQ6cQR3MOt6yFp
         sJZMlrFYPfy5nxUdukFrBbjcMPSYdZIfmqc7x6DDDKYm9VEv7xqnU2PBR6i514uULX4k
         dhBw==
X-Google-Smtp-Source: AHgI3IY1BbDU8p0Py+W8Y6W1UeY89PQP3LwkVqNuoCAqT9ACsIxnL06lQwM6hryAvvVGWelTdqrUAA==
X-Received: by 2002:a50:ca41:: with SMTP id e1mr3769377edi.73.1551223071600;
        Tue, 26 Feb 2019 15:17:51 -0800 (PST)
Received: from ltop.local ([2a02:a03f:4034:3c00:69ad:1253:f4b5:5458])
        by smtp.gmail.com with ESMTPSA id fy6sm2459233ejb.52.2019.02.26.15.17.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 15:17:50 -0800 (PST)
Date: Wed, 27 Feb 2019 00:17:49 +0100
From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-arch <linux-arch@vger.kernel.org>,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v10 00/12] arm64: untag user pointers passed to the kernel
Message-ID: <20190226231747.z3lc6yr6xmrw5q2z@ltop.local>
References: <cover.1550839937.git.andreyknvl@google.com>
 <2ad5f897-25c0-90cf-f54f-827876873a0a@intel.com>
 <CAAeHK+xCi2MxaykYWCz9mwbOzNpjrFcHex7B-VXektNNWBT+Hw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+xCi2MxaykYWCz9mwbOzNpjrFcHex7B-VXektNNWBT+Hw@mail.gmail.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 06:18:25PM +0100, Andrey Konovalov wrote:
> On Fri, Feb 22, 2019 at 11:55 PM Dave Hansen <dave.hansen@intel.com> wrote:
> >
> > On 2/22/19 4:53 AM, Andrey Konovalov wrote:
> > > The following testing approaches has been taken to find potential issues
> > > with user pointer untagging:
> > >
> > > 1. Static testing (with sparse [3] and separately with a custom static
> > >    analyzer based on Clang) to track casts of __user pointers to integer
> > >    types to find places where untagging needs to be done.
> >
> > First of all, it's really cool that you took this approach.  Sounds like
> > there was a lot of systematic work to fix up the sites in the existing
> > codebase.
> >
> > But, isn't this a _bit_ fragile going forward?  Folks can't just "make
> > sparse" to find issues with missing untags.
> 
> Yes, this static approach can only be used as a hint to find some
> places where untagging is needed, but certainly not all.
> 
> > This seems like something
> > where we would ideally add an __tagged annotation (or something) to the
> > source tree and then have sparse rules that can look for missed untags.
> 
> This has been suggested before, search for __untagged here [1].
> However there are many places in the kernel where a __user pointer is
> casted into unsigned long and passed further. I'm not sure if it's
> possible apply a __tagged/__untagged kind of attribute to non-pointer
> types, is it?
> 
> [1] https://patchwork.kernel.org/patch/10581535/

It's something that should need to be added to sparse since it's
different from what sparse already have (the existing __bitwise and
concept of address-space doesn't seem to do the job here).

-- Luc Van Oostenryck

