Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0228C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:37:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD3782086A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:37:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lBg4mAX3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD3782086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B2C56B0003; Tue, 14 May 2019 00:37:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33D6D6B0005; Tue, 14 May 2019 00:37:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 205D26B0007; Tue, 14 May 2019 00:37:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id F33A76B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 00:37:16 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g19so16533173qtb.18
        for <linux-mm@kvack.org>; Mon, 13 May 2019 21:37:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Tf3korJmRLD8o2Lf06LrqOczw1F6ZM2FyAdskXAP/yk=;
        b=Aw8wMaY4qMcsqH/FkzJOBGmDnz+d4xqASUCQeLvWpWqT97x+Ex4M/BdnEALzjyflH0
         +DfUCLbxcheuoJv+CRrfUdis+XKjaAT6lLqgEYP40Cogmgb7AtxFoXblpl14MNxv/194
         cPtsaISfRBv5MUt5APSKsSRgA5gb/WP6ux9NY2nxwachULMld3+LlEAozRGdc3iOFq4s
         4kN/Dl2yHNTOdeFZcPHQZHdPRXrEJ7SErZP+CXkFaEASHSQG57FEuX76fF3a/jA0A6xO
         opJXClJmUjL+90cgrF3w8coGCDeQ1GMaCmrBu5J3wrsZM8tDCxtMr8abcZn6tL+kXMgI
         IQHA==
X-Gm-Message-State: APjAAAUYGzG0z8+MNQncpM/H94G22G25wjcGS2UlH82IbPa54qWKSzIO
	HR9DdzBPy4+SjLRTL3PrPvEMM3e/pL9yVAqjIdHvOt7qOtU9CXoI+5RCg0VwyE0+E4M1eKTnxgA
	FUgbIQjXmBVqvOqSXw2dPz8gSc4/ClRuP4rYNm9yIpLx1TKsRsJfjcujC02vMbT2fHw==
X-Received: by 2002:a05:620a:1493:: with SMTP id w19mr26066742qkj.214.1557808636645;
        Mon, 13 May 2019 21:37:16 -0700 (PDT)
X-Received: by 2002:a05:620a:1493:: with SMTP id w19mr26066711qkj.214.1557808636086;
        Mon, 13 May 2019 21:37:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557808636; cv=none;
        d=google.com; s=arc-20160816;
        b=hkS+98bEKTc77mxju9sYEvg84CVhnl3BrU4jZZwFhV36rcycsZ/M6XjBYdQhwqXma3
         8+zIcPNslC3eTXMGyjvxA4Rj1nvqpOU1rysorL1jnGqdVpjn+9KSUsCP5arPZX94LXlc
         Vi1AZPwJWAABPZTmwg/UQf6odMshzXMITmq3+9qD1e/WVZcOWO+3lipJmaLhY8k1cHTv
         rVf46Qa8pMbsoSdjStVQsHnT7QQDMuqWD34ENBs+0nW1DKAcGS8826KilgSlN4lO3Gff
         taik14iNF1GUhGzASfnad5OOyx1P2V+OVKMa5Aoo2LnBUITckjjAbG+9G/sriaYmvNec
         ajEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Tf3korJmRLD8o2Lf06LrqOczw1F6ZM2FyAdskXAP/yk=;
        b=qx+qws/KRm93WBcie2rxtmdgf3PoZGWlsr61nRET/lHAHSeziKMtQwItkzHJmKw+bY
         w0WB5WhQjsJ3gJk/S4S8Nj/D7R4Fonn2hzNVh5xYpsjv/ZFVV06zyQ+8a3HORcRgJTBR
         ZHTu4DbU9RvqxWE/McUqQTcZhIBa3gjt13E+2u55E+T1v2d85ZcdCBMNPK/rHArF+98j
         nG8u7txggtIv3sS54QProi4/y4hiQbWKvWuP9+1rugo4WnPhDPyErSBdcmHTTMqW1pXU
         YjStCVSoGGsSrDx79oVWVBuTVTHzVtjm2zW3ZeLX5E0F1R88pgTxV0XPNWMaWrRJTU5S
         Eypw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lBg4mAX3;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s35sor20117513qtk.14.2019.05.13.21.37.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 May 2019 21:37:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lBg4mAX3;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Tf3korJmRLD8o2Lf06LrqOczw1F6ZM2FyAdskXAP/yk=;
        b=lBg4mAX3TS8PJBOsb+445RvCKsl4l9r5dT0BTkb/FL86zuZPgzqK0IYwRDoq8DS/wW
         bkN3AEQUlfMHlZU+0IVgdRfgFaOm6ajkuDV2FOR1rhtOAcMcbR1RfK+japxmOfw3PGr1
         1KkIg29RCtaWyEWi81wAsuTrGj7UFXSekgkO7QlV3qE02GyWhbmyKqhRfqgs+DR/k+CO
         xdanmaGLWE6F7ApSxivM8U+T/V/mz9LNfgVXI9ujMA77bvmfSG2ZBWbf2GcKqwClQ0Rj
         UHVn5SVbESeu1MTDsvNW1+ztooPYlK9Aop1IqrJ7HASDwOGZcC5O3Ly+tDFg9XW9YDEa
         2uaw==
X-Google-Smtp-Source: APXvYqwh4a0o8vAEeDVZY6kolyij7RZoaYa1MYOibq43kvFPp4BJjJKs9M6IS2Pmf3oMCR3z5OP/uvmiygdphi38f9o=
X-Received: by 2002:ac8:5409:: with SMTP id b9mr27316238qtq.326.1557808635902;
 Mon, 13 May 2019 21:37:15 -0700 (PDT)
MIME-Version: 1.0
References: <1557505420-21809-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190513080929.GC24036@dhcp22.suse.cz> <c3c26c7a-748c-6090-67f4-3014bedea2e6@linux.alibaba.com>
 <20190513214503.GB25356@dhcp22.suse.cz>
In-Reply-To: <20190513214503.GB25356@dhcp22.suse.cz>
From: Yang Shi <shy828301@gmail.com>
Date: Mon, 13 May 2019 21:36:59 -0700
Message-ID: <CAHbLzkpUE2wBp8UjH72ugXjWSfFY5YjV1Ps9t5EM2VSRTUKxRw@mail.gmail.com>
Subject: Re: [v2 PATCH] mm: vmscan: correct nr_reclaimed for THP
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Huang Ying <ying.huang@intel.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, 
	kirill.shutemov@linux.intel.com, Hugh Dickins <hughd@google.com>, 
	Shakeel Butt <shakeelb@google.com>, william.kucharski@oracle.com, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 2:45 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 13-05-19 14:09:59, Yang Shi wrote:
> [...]
> > I think we can just account 512 base pages for nr_scanned for
> > isolate_lru_pages() to make the counters sane since PGSCAN_KSWAPD/DIRECT
> > just use it.
> >
> > And, sc->nr_scanned should be accounted as 512 base pages too otherwise we
> > may have nr_scanned < nr_to_reclaim all the time to result in false-negative
> > for priority raise and something else wrong (e.g. wrong vmpressure).
>
> Be careful. nr_scanned is used as a pressure indicator to slab shrinking
> AFAIR. Maybe this is ok but it really begs for much more explaining

I don't know why my company mailbox didn't receive this email, so I
replied with my personal email.

It is not used to double slab pressure any more since commit
9092c71bb724 ("mm: use sc->priority for slab shrink targets"). It uses
sc->priority to determine the pressure for slab shrinking now.

So, I think we can just remove that "double slab pressure" code. It is
not used actually and looks confusing now. Actually, the "double slab
pressure" does something opposite. The extra inc to sc->nr_scanned
just prevents from raising sc->priority.

> than "it should be fine". This should have happened when THP swap out
> was implemented...
>
> --
> Michal Hocko
> SUSE Labs
>

