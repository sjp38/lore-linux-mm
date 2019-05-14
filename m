Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2685C04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 20:27:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46B95216F4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 20:27:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="H7eAox2h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46B95216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C34C46B0005; Tue, 14 May 2019 16:27:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBEB76B0006; Tue, 14 May 2019 16:27:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5EB36B0007; Tue, 14 May 2019 16:27:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 680B96B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 16:27:26 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id t1so79515pfa.10
        for <linux-mm@kvack.org>; Tue, 14 May 2019 13:27:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=FdcqEhjkS2H6UUI5e9J+DP4sAVa4fL2kVmRIomgO5qA=;
        b=bO8V0ZuaCscdsomjsYb85KDDoNFFsUqPeewRMYVXUzTsxXgP+bQ6Ko9ZQ9HXJRt0En
         q+L72UuNDAugKpJu0ncw2G2TrWetv2GhOZyzQewhAedxIgmkqDupV/zZVSlp7RdWTWT7
         M/QZQ9SsZM+xLY0W/FTukW5B+kMBneQnCDtvle8AHLmwU/8/i2wkWNEVXwfvMCdRhCX4
         lfeorortCCxS+LvHIhgw04duJPgsWWgKRhSrMhoXdU27O3usHuY8qAinEU/LSr3uidxu
         aTh137U9zuS+fea9ZOYryLkrYyU/8mLHLg6sI+sVcSe78+azJAuiA1WP+V1zq0LFYIIl
         qKvA==
X-Gm-Message-State: APjAAAUclsmHObo99vmToDztXGFNg2l98Ddr+hoQQ04coVbEi0hP1FtD
	PGqDMcwIec9ca88T4i6L66CnD1irkLXt3SNnJa2oJH7JoQxgHnKxXdnpKrBoNxJxPO7Z7wHY0uQ
	1w3BTe4dE6rAk/9Kow78zzSUsoIX/GIyv1C6ckehReOL30yEsT3yJqebogOMWuBsWHQ==
X-Received: by 2002:a17:902:f085:: with SMTP id go5mr31699256plb.53.1557865645924;
        Tue, 14 May 2019 13:27:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/6q/wMDvmUNNP/KIn89Seoe5UYvZQekJno/pmotsDTA1E2nw9nCwFqOXBmfFdjGSqFCY8
X-Received: by 2002:a17:902:f085:: with SMTP id go5mr31699218plb.53.1557865645237;
        Tue, 14 May 2019 13:27:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557865645; cv=none;
        d=google.com; s=arc-20160816;
        b=l+ODj9KjtjjoOfyYnq/sBzNOrA1oFt3IgMXZKxjMOl9pcfROZw4Exi9Em8LIeSD7EG
         eXIF6ngUkTqB84wQreqxq72jBWPLdUyGq4BWUp45Y3dZ66mSPkjbjwNAAtjFCwmf1YTB
         PDOna9HrAKU73mwKaVuSZIUrQ3fcOqWnW7HkiSxN48JyoJJPnkO++iqTd/v9r9EfSkCi
         FPhVKavSDeJbCiK4yQCHiOAr5BUoGmMv/M6vz4X/hy/iEnqgPZvggwNwxVicnb1crEGj
         wW1bzlhk+oQ1Zf0PMePQpnfXdjgyF/9j3IU4PA1G1T3/+p05f2vajLGPrHhTmODcXouB
         fPoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=FdcqEhjkS2H6UUI5e9J+DP4sAVa4fL2kVmRIomgO5qA=;
        b=IYHybIH2Rv+at3ryBhaYR6GeIub9aO0WMoy5uPK/yjUZ1rFI05kg9T6W+QNpoyeDzT
         M2nU+1UgM2Yet3OYxTZa4KcSbPf/ckZJ4DUzPu+ql6dOwHEvvlwnAxl/iel8yZJXPvFg
         7jAfAxEF4hjYU9fZRg17+YgSCHOjD5DVpgEF3i8GQJ2C3Yf0TPZRIQlrhMIfqkMStL2m
         XzWPa7Lc6UZHjzfKfZgg35i0KllDGbRO1avLY9okfhIaaA7ViQCWFgmnBicS4MjRWkWf
         N0k4k4wYKoFussAT+DpQ2Tb2x+ekPhxGyzoskX2BJ7aoOCTZuQ6DiH/wjxQMtmQGGSSE
         omhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=H7eAox2h;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s14si19294pfa.91.2019.05.14.13.27.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 13:27:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=H7eAox2h;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f44.google.com (mail-wm1-f44.google.com [209.85.128.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8F2FD21882
	for <linux-mm@kvack.org>; Tue, 14 May 2019 20:27:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557865644;
	bh=DzocNwMVi5SAbWmRTGaV0IjOHUG4WEPp/2+M4ioUzgA=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=H7eAox2hSzIAWyeZKe5RK68sRQU/pkz/MU1gJXfJmQJwc8b9Y2i+bnIi6WWU9vdvc
	 FSSl9o0Ds5GeA/th5W2//Zn9ZeQyIyYwOhETDLySSfAJFdoU9sT0kQQWo4hIcLuOnO
	 JwlV8WuVYZF14qijOoItC6HIVEGbP7RGFDKPU0Uw=
Received: by mail-wm1-f44.google.com with SMTP id c66so3165719wme.0
        for <linux-mm@kvack.org>; Tue, 14 May 2019 13:27:24 -0700 (PDT)
X-Received: by 2002:a1c:eb18:: with SMTP id j24mr21736258wmh.32.1557865643024;
 Tue, 14 May 2019 13:27:23 -0700 (PDT)
MIME-Version: 1.0
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-19-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrWUKZv=wdcnYjLrHDakamMBrJv48wp2XBxZsEmzuearRQ@mail.gmail.com>
 <20190514070941.GE2589@hirez.programming.kicks-ass.net> <b8487de1-83a8-2761-f4a6-26c583eba083@oracle.com>
 <B447B6E8-8CEF-46FF-9967-DFB2E00E55DB@amacapital.net> <4e7d52d7-d4d2-3008-b967-c40676ed15d2@oracle.com>
 <CALCETrXtwksWniEjiWKgZWZAyYLDipuq+sQ449OvDKehJ3D-fg@mail.gmail.com>
 <e5fedad9-4607-0aa4-297e-398c0e34ae2b@oracle.com> <20190514170522.GW2623@hirez.programming.kicks-ass.net>
In-Reply-To: <20190514170522.GW2623@hirez.programming.kicks-ass.net>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 14 May 2019 13:27:11 -0700
X-Gmail-Original-Message-ID: <CALCETrVRBC6DY9QXwksqLYP+LWD1PDw8nQyE03PbytDQ4+=LXQ@mail.gmail.com>
Message-ID: <CALCETrVRBC6DY9QXwksqLYP+LWD1PDw8nQyE03PbytDQ4+=LXQ@mail.gmail.com>
Subject: Re: [RFC KVM 18/27] kvm/isolation: function to copy page table
 entries for percpu buffer
To: Peter Zijlstra <peterz@infradead.org>
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>, Andy Lutomirski <luto@kernel.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, jan.setjeeilers@oracle.com, 
	Liran Alon <liran.alon@oracle.com>, Jonathan Adams <jwadams@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 10:05 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> On Tue, May 14, 2019 at 06:24:48PM +0200, Alexandre Chartre wrote:
> > On 5/14/19 5:23 PM, Andy Lutomirski wrote:
>
> > > How important is the ability to enable IRQs while running with the KVM
> > > page tables?
> > >
> >
> > I can't say, I would need to check but we probably need IRQs at least for
> > some timers. Sounds like you would really prefer IRQs to be disabled.
> >
>
> I think what amluto is getting at, is:
>
> again:
>         local_irq_disable();
>         switch_to_kvm_mm();
>         /* do very little -- (A) */
>         VMEnter()
>
>                 /* runs as guest */
>
>         /* IRQ happens */
>         WMExit()
>         /* inspect exit raisin */
>         if (/* IRQ pending */) {
>                 switch_from_kvm_mm();
>                 local_irq_restore();
>                 goto again;
>         }
>

What I'm getting at is that running the kernel without mapping the
whole kernel is a horrible, horrible thing to do.  The less code we
can run like that, the better.

