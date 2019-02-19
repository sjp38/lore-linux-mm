Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FC19C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:01:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACF1A21738
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:01:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iU/xVmig"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACF1A21738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05C048E0003; Tue, 19 Feb 2019 07:01:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F250A8E0002; Tue, 19 Feb 2019 07:01:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC74D8E0003; Tue, 19 Feb 2019 07:01:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 969E98E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 07:01:21 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 23so4260134pgr.11
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 04:01:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/LG/yEoER1LLbq1ZVxXJDkWgtoKcYvIkZiPzXMpJeVo=;
        b=blF1TLR1qJWFIcJ9STZEvSpSHy0RNX7RAqUXwbAgWoSzUo9UYWsRJe07c1qLrZvj8P
         nGVQkgMioccWHob1epcNcQbGogm4sAFzNHmHlX7N8SBf9JeVL5nzSJTcEy8CZ5PjEY4R
         +0oknk9QBdOqAXbqN8rUs+QKYVMMxDE/GOuhHibzruxyxbnQtNhMOTyf02lciBFmcqCY
         5UvQJLzPe97n9GotyPfvlo4gBUaLC3+7CfHZVjSxntOf3vG0fcBuJDns7KtUTlorTgyw
         EBdCMWa/UqrSXQkah8ZPP5GRYvNrEI8lBy9CLNBvuKlo5aYgZrRMUVPb9nxGq3txmP2C
         yOvg==
X-Gm-Message-State: AHQUAuZ//PE+rC89JfB+9JliTBnyDnBrvdQHu23ee6IYDizevQdzt1Ao
	yEpFee5LuEIT696qxkVaSUWbVAVLjxKg0OdC9prOmgLf68NeHtxXosZutMu9T1ZOIIYDL9J8KD4
	5inLEX8Lz+LiTGdvS7x+/2oPRdD97AXijHnC0qFMi7tu9jqCDsmREP3SyVQFtnywHChaYm2kBt8
	qAuiBFRO1L+giPNF8/agP1w4hQl1GoCo1zuLDr9EMQ54gxl2IOiTF00TcVOfJu0c46XrnC5FBx5
	axos8xw/h7JKQrX5/tdpn4oPUEHdAnD2VGxQdKEu2ZJ86G4jMLzd3TUgEoFNGziJopeoYOmZ20m
	r0f5hzQnYq6qLmR2ZQ0Bdy4rvhh63bwh8LJtK6gBKyRihlVpAGmUtocLroGevwlahyCnaZiHRKj
	x
X-Received: by 2002:a63:4a11:: with SMTP id x17mr8301954pga.376.1550577681151;
        Tue, 19 Feb 2019 04:01:21 -0800 (PST)
X-Received: by 2002:a63:4a11:: with SMTP id x17mr8301883pga.376.1550577680194;
        Tue, 19 Feb 2019 04:01:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550577680; cv=none;
        d=google.com; s=arc-20160816;
        b=RGfCx7q6vbCVtdgzKc9iPcbt+DZblWI4pKlB0AsLCnBCY3+50alnRJY7gKdDMnaUp9
         7wuz8iXAVezkOFWIrNiJKzIV8sjU3EixmVKz77lmaiQ6KEN5WzFKFTgWpf/TjlDBruo1
         LD1UluDDPq7nudDmc6eRvfuFoe+ANfDWwmSGLZaRaN69oTbwPXSAdcvyn8rO1U63DoH9
         pD4rlmm9mRt1fvA6YUwhFe9sYT7hTdQh91DbGuYsx5KfTYm03VQFRMRciSHCBMnuvIJX
         1VVkzQGey8mMRQLn9IdzFxs0hP3oAN1pt5O+t33ofoBB1ehG1lQ1Vai1Ew9uQVAW1wBt
         FVdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/LG/yEoER1LLbq1ZVxXJDkWgtoKcYvIkZiPzXMpJeVo=;
        b=AHyNLvAHF0CcQcibz39j89rPkPyiP3OvZXyZHEWwITbDmLh6kMQd+r0n0X/W+YfKWO
         ek1FdFlnuyH17ACMDOKjAbnx6PK0LaO+AsXQd4Jgh+1ltHtNG3fwtCSMPubWiJgbVobP
         a6459fv86v8O2i1h+wKuFia6hPGHnqc11ao0LSMdvlWPKZc2Vrj1HSl9pUllzKgvyX7h
         fMsDkKBI1WB4u22IgGemCxCS1c+2ubZfQ2tX21H8WSx/cyzyzB6apXUq35oUgtTNW/5D
         ODzgf1aTIqj+YdoKg5D/gNebriy2DgOnuep+c5BlWgHQKDrRbgefxtjPhgtZk3Fowgkr
         Psyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="iU/xVmig";
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y5sor24233156pgv.77.2019.02.19.04.01.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 04:01:20 -0800 (PST)
Received-SPF: pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="iU/xVmig";
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=/LG/yEoER1LLbq1ZVxXJDkWgtoKcYvIkZiPzXMpJeVo=;
        b=iU/xVmigyl6P6JQ+57cD4HVDHnGSrProH0Bj7J/IpfGxTbo5jggrj2JEO3KEx0vnOA
         0U6lLcIN6jAKKai0MyqAA4vC3XPyGqdpr1dCMD0QHOYR6Ea6W9d8LCK6jdp6+YOJmnol
         sJPlA8QkFRIoZ3qaWBBHgf+fikdu8LMUkeB+fCYhd+SzBE0sDcrS+B7mpWE6tBcXvyiz
         NwPKXPltrdr05Or1JEujlgMfwxABSEVs7WRYJj4lOJ4v2npwW26pe+mGH7cMYhK7+Dbg
         G2yqOxYMRwm8uHIS2zFIdMNg1ov5kgoTBobqduB/kY/KKStgWeNih+p8NCLASz91DtQ1
         h0vQ==
X-Google-Smtp-Source: AHgI3IZIhLtBpykbTg6j8A/bl1aKD6Q13H0vmWwXiKvP/FU0TZwarjAbPGHY9e/NaBzjEBvj6uDodA==
X-Received: by 2002:a63:6605:: with SMTP id a5mr2454975pgc.372.1550577678304;
        Tue, 19 Feb 2019 04:01:18 -0800 (PST)
Received: from localhost ([203.219.252.113])
        by smtp.gmail.com with ESMTPSA id o2sm20849302pgq.29.2019.02.19.04.01.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 04:01:17 -0800 (PST)
Date: Tue, 19 Feb 2019 23:01:14 +1100
From: Balbir Singh <bsingharora@gmail.com>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Segher Boessenkool <segher@kernel.crashing.org>, erhard_f@mailbox.org,
	jack@suse.cz, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, aneesh.kumar@linux.vnet.ibm.com
Subject: Re: [PATCH] powerpc/64s: Fix possible corruption on big endian due
 to pgd/pud_present()
Message-ID: <20190219120114.GK31125@350D>
References: <20190214062339.7139-1-mpe@ellerman.id.au>
 <20190216105511.GA31125@350D>
 <20190216142206.GE14180@gate.crashing.org>
 <20190217062333.GC31125@350D>
 <87ef86dd9v.fsf@concordia.ellerman.id.au>
 <20190217215556.GH31125@350D>
 <87imxhrkdt.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87imxhrkdt.fsf@concordia.ellerman.id.au>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 11:49:18AM +1100, Michael Ellerman wrote:
> Balbir Singh <bsingharora@gmail.com> writes:
> > On Sun, Feb 17, 2019 at 07:34:20PM +1100, Michael Ellerman wrote:
> >> Balbir Singh <bsingharora@gmail.com> writes:
> >> > On Sat, Feb 16, 2019 at 08:22:12AM -0600, Segher Boessenkool wrote:
> >> >> On Sat, Feb 16, 2019 at 09:55:11PM +1100, Balbir Singh wrote:
> >> >> > On Thu, Feb 14, 2019 at 05:23:39PM +1100, Michael Ellerman wrote:
> >> >> > > In v4.20 we changed our pgd/pud_present() to check for _PAGE_PRESENT
> >> >> > > rather than just checking that the value is non-zero, e.g.:
> >> >> > > 
> >> >> > >   static inline int pgd_present(pgd_t pgd)
> >> >> > >   {
> >> >> > >  -       return !pgd_none(pgd);
> >> >> > >  +       return (pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
> >> >> > >   }
> >> >> > > 
> >> >> > > Unfortunately this is broken on big endian, as the result of the
> >> >> > > bitwise && is truncated to int, which is always zero because
> >> >> 
> >> >> (Bitwise "&" of course).
> >> >> 
> >> >> > Not sure why that should happen, why is the result an int? What
> >> >> > causes the casting of pgd_t & be64 to be truncated to an int.
> >> >> 
> >> >> Yes, it's not obvious as written...  It's simply that the return type of
> >> >> pgd_present is int.  So it is truncated _after_ the bitwise and.
> >> >>
> >> >
> >> > Thanks, I am surprised the compiler does not complain about the truncation
> >> > of bits. I wonder if we are missing -Wconversion
> >> 
> >> Good luck with that :)
> >> 
> >> What I should start doing is building with it enabled and then comparing
> >> the output before and after commits to make sure we're not introducing
> >> new cases.
> >
> > Fair enough, my point was that the compiler can help out. I'll see what
> > -Wconversion finds on my local build :)
> 
> I get about 43MB of warnings here :)
>

I got about 181M with a failed build :(, but the warnings pointed to some cases
that can be a good project for cleanup

For example

1. 
static inline long regs_return_value(struct pt_regs *regs)
{
        if (is_syscall_success(regs))
                return regs->gpr[3];
        else
                return -regs->gpr[3];
}

In the case of is_syscall_success() returning false, we should ensure that
regs->gpr[3] is negative and capped within a certain limit, but it might
be an expensive check

2.
static inline void mark_hpte_slot_valid(unsigned char *hpte_slot_array,
                                        unsigned int index, unsigned int hidx)
{
        hpte_slot_array[index] = (hidx << 1) | 0x1;
}

hidx is 3 bits, but the argument is unsigned int. The caller probably does a
hidx & 0x7, but it's not clear from the code

3. hash__pmd_bad (pmd_bad) and hash__pud_bad (pud_bad) have issues similar to what was found,
but since the the page table indices are below 32, the macros are safe :)

And a few more, but I am not sure why I spent time looking at possible issues,
may be I am being stupid or overly pessimistic :)

Balbir


