Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53182C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 20:44:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 080B72084F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 20:44:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="MKT4yReb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 080B72084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AF278E0003; Thu, 28 Feb 2019 15:44:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 937B08E0001; Thu, 28 Feb 2019 15:44:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 825D28E0003; Thu, 28 Feb 2019 15:44:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 150428E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 15:44:26 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id z71so3604782ljb.18
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 12:44:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0VA5nzNT5SRcMaUMBhDsz42bvVihu0EYjwSEkOG9g5Q=;
        b=eeZAUhI78Kn/F57mpoaqnXLDX26FI4X+gmnORC3nDlTba/Z8rBbHpj0Udt53DEy6SK
         G2wtElrx3T6ffcqwTiKqtrUte/EF7bzRATsqhRTKIIhRN2ZTrTbadQ4IjymN7Onb1XQu
         XwZh/+Vkcz/PIVFhnHoBLMoUwYYYki+82fmSThWYFsXpde1uqu5VTu58MCNxRRL5/zNf
         mO+zFas25fmfUoCcpqG+375crNx2NzjjepHZe07batzxcyd4BiCR23lgKleyI4BGzP+f
         CcVt5pX1pGdnkL/UWVflHcLUvZMUTt+N1TouQwwcb9/300TfBhprcR/5RE2/GUQ5JEPA
         NkeA==
X-Gm-Message-State: APjAAAVEUKGVU9JOHQmBHYM4u7CHIUpTWZ/B9ypWAahAZuH+odB88r8f
	UvzRQLUPSOMgiqBGthJPAPDd2tLwiOVIR+fJD1qZbLCsW/DwzBdrz/TBrzel9KnonI9vkHNMgLi
	Q0K1RX2vmna/CSePD0JKE7r9osqxrHUSjsL9uUlUtmz0cG1tYemTvQCvlqkAKaJYs2ShyhJWDXz
	dRs8+7zE4k3Clx1BsMzJ0OIeuAIX9ajBbmDpoIN791u3UB67lCPCOgFMHnmXGrW8ptcLbJfq3X9
	SuYwvPjVfIw/D8iF1wjCxgLUwSytHlwNA9EAbzovqLozfPuh6Iq38WkBOa4YE91LCTt8Kj6dV3Z
	jWcXiV+38LZvEY3P3nVymfrA5FjvoCeAIf+kT5/rzTNI82NnhenznKyNYeyQlyICDMeiaGpjGww
	w
X-Received: by 2002:a19:c616:: with SMTP id w22mr826181lff.31.1551386665094;
        Thu, 28 Feb 2019 12:44:25 -0800 (PST)
X-Received: by 2002:a19:c616:: with SMTP id w22mr826137lff.31.1551386664058;
        Thu, 28 Feb 2019 12:44:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551386664; cv=none;
        d=google.com; s=arc-20160816;
        b=t7vui6A0YUhxRFyR1qX2lKF2blMcYlUpKfXxF7BWLuf8mkP8l/eJu/c0hOnKx4iEvU
         6EVH8ThkdikIZDgaaqfOsJvaspfR0EMp5G+W9fZ7w5l918a2lfdIOoHeJgh1iN+tmyBb
         uMrdJ3KXkaV6n7qMgwWhlmXCGWdon8iR7KvHDJaVJcQPt+ZsbuTvy0J57H+Cm5gAg4Qw
         jcUYCqqDGEr4rjyFcqxzXKjcoiFfmP6vcIomlKaUcT6VyOTs1CnkRgieJ2dqDra6+YWS
         y6uZkvU/aCMjixT1kjOg4ZTQUiRUsBherxnGG2+JgiNHUHqnniZkhRBqW/x4McUkUm9H
         gM7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0VA5nzNT5SRcMaUMBhDsz42bvVihu0EYjwSEkOG9g5Q=;
        b=FV4gl2l07gvhkDuvcXaf/9lS7WK6D364uOt7OleXI3UcWZAZWQRHpy2/koqSNkQ3q7
         HVqVVBqDMLUljErdek4o3OYeiWSglAy+LpZCxi/JhjTZRsNRiEhtmYOCGjwUhan4abRT
         yZJGeVVPKGere89E+R7kbbgxYlvrtzONkLlAjOJ+vQDUGZnz3wlInn5Vh2txW+CxMd9+
         tGkIVMAGN32vt7GfuoK+yMPdjOhUuRNyEaP0gbt0ZO8PrEIiBOJnV4FrcfCLE65Skffx
         ANvFsYJH8d5f2akCMz5xGlCqpkQqGiLpci3Ujn26vatkrXvmcdMFOSJ2nUHYky+Skbzg
         cZgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=MKT4yReb;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m19sor12242900ljg.23.2019.02.28.12.44.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 12:44:24 -0800 (PST)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=MKT4yReb;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0VA5nzNT5SRcMaUMBhDsz42bvVihu0EYjwSEkOG9g5Q=;
        b=MKT4yRebQ3XFwrUgwZj0QnrXisDJlO0UL9Q7vtfrKVi31aTJqkFhmffN4noz3wl8I7
         pwB5dNW0mTF7qpEuFPA4c8BoOCxpMB0G7qFHbP9Fb2QTeJ407bwlyj8py0jYNEOPbk/w
         JP7OB8Bm79VW37NCiFqhk7JvkyN68p3U2b4wc=
X-Google-Smtp-Source: APXvYqzBBm1yK2JYH5eWv9lzdZCgL9Lkv88x06FsAmXGa8ej5GpmBjOnhYOz2GJz3sxj58nqy26GwNPGX1VWzB93b3g=
X-Received: by 2002:a2e:850a:: with SMTP id j10mr555683lji.102.1551386663347;
 Thu, 28 Feb 2019 12:44:23 -0800 (PST)
MIME-Version: 1.0
References: <20190226091314.18446-1-osalvador@suse.de> <20190226140428.3e7c8188eda6a54f9da08c43@linux-foundation.org>
 <20190227213205.5wdjucqdgfqx33tr@d104.suse.de> <5edcfeb8-4f53-0fe6-1e5b-c1e485f91d0d@suse.cz>
In-Reply-To: <5edcfeb8-4f53-0fe6-1e5b-c1e485f91d0d@suse.cz>
From: Joel Fernandes <joel@joelfernandes.org>
Date: Thu, 28 Feb 2019 12:44:11 -0800
Message-ID: <CAEXW_YQFDJUjHmjE+aF6RkBxO8fzF2j5M1Tufj12MUuvouyOsA@mail.gmail.com>
Subject: Re: [PATCH] mm,mremap: Bail out earlier in mremap_to under map pressure
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Oscar Salvador <osalvador@suse.de>, Andrew Morton <akpm@linux-foundation.org>, 
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, 
	"Kirill A. Shutemov" <kirill@shutemov.name>, jglisse@redhat.com, 
	Yang Shi <yang.shi@linux.alibaba.com>, mgorman@techsingularity.net
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 12:06 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 2/27/19 10:32 PM, Oscar Salvador wrote:
> > On Tue, Feb 26, 2019 at 02:04:28PM -0800, Andrew Morton wrote:
> >> How is this going to affect existing userspace which is aware of the
> >> current behaviour?
> >
> > Well, current behavior is not really predictable.
> > Our customer was "surprised" that the call to mremap() failed, but the regions
> > got unmapped nevertheless.
> > They found it the hard way when they got a segfault when trying to write to those
> > regions when cleaning up.
> >
> > As I said in the changelog, the possibility for false positives exists, due to
> > the fact that we might get rid of several vma's when unmapping, but I do not
> > expect existing userspace applications to start failing.
> > Should be that the case, we can revert the patch, it is not that it adds a lot
> > of churn.
>
> Hopefully the only program that would start failing would be a LTP test
> testing the current behavior near the limit (if such test exists). And
> that can be adjusted.
>

IMO the original behavior is itself probably not a big issue because
if userspace wanted to mremap over something, it was prepared to lose
the "over something" mapping anyway. So it does seem to be a stretch
to call the behavior a "bug". Still I agree with the patch that mremap
should not leave any side effects after returning error.

thanks,

 - Joel

