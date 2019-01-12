Return-Path: <SRS0=vc3H=PU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84E57C43387
	for <linux-mm@archiver.kernel.org>; Sat, 12 Jan 2019 16:50:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16BFF20836
	for <linux-mm@archiver.kernel.org>; Sat, 12 Jan 2019 16:50:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="t05Y81Bu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16BFF20836
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A99A8E0003; Sat, 12 Jan 2019 11:50:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 957D88E0002; Sat, 12 Jan 2019 11:50:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 823908E0003; Sat, 12 Jan 2019 11:50:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4CBD48E0002
	for <linux-mm@kvack.org>; Sat, 12 Jan 2019 11:50:54 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id 124so9189399ybb.9
        for <linux-mm@kvack.org>; Sat, 12 Jan 2019 08:50:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=VaO7ZxXFClP1+k1Rrf7irHfcf76KrsN+FQv9UEeh0gk=;
        b=t3gNLcLjRQBOCKyDdJ57V/Q4MuNqJqniPQq1gMtj2RvjpuvfIJBkkWoctazwoArMGe
         J2fVx8hZ5vv7ZrmmGg/YnzU71cFRuNRsm5xI4m8ThP8n4+CQy5zDgJ8+zEYl4uHoLuDL
         EGmBFNj0NeH34dEspFgualJ3CQwdE5qvQiZ7RvaJ6qCs4Nbb8TXc+Qin13oRBuTi93J4
         9tqIxgK5FectVLi/uDq8wOJSbyFrmUCDxu2ddKSIzAQhQV5irpjtiklK7jiGZbBxim2f
         6m1PciRcaftoV2MDrMPrnTmnzrolRIF3ey5UIMkTSawq6uU51D3V7QQeRyrvIdgoUIoq
         phGA==
X-Gm-Message-State: AJcUukf/xRsQxZ/CBpaZzJHsdHZx+D3OpbEfT5zMC8G3qWvy+5qcLueJ
	RdwwgiZb/HrFzrx635WyS5n7+v7jX6iPxdorCfC4gyCs0jZJPg3Uz/avMRfkAABNOT461T0L6eB
	cUUr1l9g/o0qcqjLRGTdduMjXQVEXxVzHE4hoCxdbdpZFuiknP3uzZ3otdfUCPe3qmxC7sQbDu/
	h3Rhi8pHvz/ZqkIN00hMEG0aYF9rvpakgrW2wD8MNCBtWeG66XnRH/EsNVtabHVci5bwbg2XSCj
	+f77PY1aNFjaeYLTNRaq2fLbi2sqagpCn2QjaOJJ+QAs3IUf7dP0Jn1Opq/cd1d0IkPMw5TOyWM
	lSLGweY89GSEn/l/20MeU4wI8kD+nuxpMnkbRazrlqPfpP/388hTW4Dkd8Qq/wJswzBmRUaU+qT
	E
X-Received: by 2002:a81:85c5:: with SMTP id v188mr18331902ywf.51.1547311854075;
        Sat, 12 Jan 2019 08:50:54 -0800 (PST)
X-Received: by 2002:a81:85c5:: with SMTP id v188mr18331880ywf.51.1547311853523;
        Sat, 12 Jan 2019 08:50:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547311853; cv=none;
        d=google.com; s=arc-20160816;
        b=ytc6I+b/L4yXQETuiO3cR23taFC4FcU2IULlRJJRcqxf69Pvja9R/ixvTF9SN2Ue8I
         IqfpqMatry46YPKVhyyOAGB6ctzJi0GWSKpUuZV28MYPBh/iPMdd36W5eW3IrRLCEX9Z
         HDR4WBgPIKAxa5JyWVgh/rAgHSkLPNwj58RvNTPIezfrs99FyPRtXPVLYtqpgDasfWG/
         hjqddiy29JUxD6Abw3Sic1v/m6ORANGvCbsv1IF6zKqxBrh3AZ9s73Xwqy5IMTrh3UzP
         k/k9NtUtKSeqGlmxkmF2rAzUm6X9ypJZdyEf2kX1dMd/HUNKkS8elCbdfiIA6Ossu5tF
         nAjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=VaO7ZxXFClP1+k1Rrf7irHfcf76KrsN+FQv9UEeh0gk=;
        b=jc7Igh2RjxwECWDL4O19L6/IVyxzYO6+49pE7N8E72tDD2fciWQeHbbl6Wl7VNv+RB
         kpjrmdla2M1hvHv36yAYqxhCEgwkgX1m4hTTK1fGI2fuvis/daHDcDLJAVQ4LFUsa8N6
         2xykjSOckZXXIs8j0CChCuYhuFlkmUbfZqUyvmbGZOLGF6DUMQZi61ACvx76b3jcoZy+
         zKR3tqjO+1perq/cXGAoDlMceAZQoZge0UUOMmZz2+ke9krUwLD0VGMEbHZF5nKNrDSM
         /hI2QHF0vCvuSXsTjR8vCK8PyOz6G+tDu71z1DvXHyg076G7byGF4S63R1OL5gn2kG/b
         gdnw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=t05Y81Bu;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x74sor14676916ywx.165.2019.01.12.08.50.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 12 Jan 2019 08:50:53 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=t05Y81Bu;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VaO7ZxXFClP1+k1Rrf7irHfcf76KrsN+FQv9UEeh0gk=;
        b=t05Y81BuMZSuJ3Qf03/s29f5cEJAeohwbr5hZJc2RrcPRO6eHvSCEwsoBZ8TncZdL9
         PmSFv57lPf98jmd7DJUXckoKesFwgGPp40VY4Gblne/wQyqG/r/MqToljc9zsCz0qxKp
         aRnm5M1tt5gMo/vHEU2zJp8W2o3GF8OgA4ajXs0FGG40PWe6hFw+ca4OkI60pLBD3kWB
         2n2BGWP7tzRyD26c8OTdhD2D0L1F4/eMN6vCzDo06ugdYINGlLUAp76YatbfknmKYRpH
         RxNfLgU6S5LVmaxnqLCcIX5XK4x4ZS2dNEqHJe3KNImCAkYzyXEhDG7xdyu1Mm9rEMYB
         k3cg==
X-Google-Smtp-Source: ALg8bN6XzD17LVLAX7m/kSOcIUQ121Lu7vVxRfY/g+CIrLDeBR87sI3stQrULnEovy6QxqBn0V1BYoxbhWieErSfFEc=
X-Received: by 2002:a81:60c4:: with SMTP id u187mr18077076ywb.345.1547311853069;
 Sat, 12 Jan 2019 08:50:53 -0800 (PST)
MIME-Version: 1.0
References: <1547288798-10243-1-git-send-email-anshuman.khandual@arm.com>
 <20190112121230.GQ6310@bombadil.infradead.org> <ddd59fdc-3d8f-4015-e851-e7f099193a1b@c-s.fr>
 <20190112154944.GT6310@bombadil.infradead.org>
In-Reply-To: <20190112154944.GT6310@bombadil.infradead.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Sat, 12 Jan 2019 08:50:42 -0800
Message-ID:
 <CALvZod5XfFujzzMC0n2dZmofjof0juWw45RF4475CAEu9nAv3Q@mail.gmail.com>
Subject: Re: [PATCH] mm: Introduce GFP_PGTABLE
To: Matthew Wilcox <willy@infradead.org>
Cc: Christophe Leroy <christophe.leroy@c-s.fr>, Anshuman Khandual <anshuman.khandual@arm.com>, 
	mark.rutland@arm.com, Michal Hocko <mhocko@suse.com>, linux-sh@vger.kernel.org, 
	peterz@infradead.org, catalin.marinas@arm.com, 
	Dave Hansen <dave.hansen@linux.intel.com>, will.deacon@arm.com, 
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	kvmarm@lists.cs.columbia.edu, linux@armlinux.org.uk, 
	Ingo Molnar <mingo@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, 
	marc.zyngier@arm.com, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	"Kirill A. Shutemov" <kirill@shutemov.name>, Thomas Gleixner <tglx@linutronix.de>, 
	linux-arm-kernel@lists.infradead.org, ard.biesheuvel@linaro.org, 
	robin.murphy@arm.com, steve.capper@arm.com, christoffer.dall@arm.com, 
	james.morse@arm.com, aneesh.kumar@linux.ibm.com, 
	Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190112165042.fhurqC50sXa7_uBJmqIiD7R0ZHQzWu9387eUcj7TmYs@z>

On Sat, Jan 12, 2019 at 7:50 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Sat, Jan 12, 2019 at 02:49:29PM +0100, Christophe Leroy wrote:
> > As far as I can see,
> >
> > #define GFP_KERNEL_ACCOUNT (GFP_KERNEL | __GFP_ACCOUNT)
> >
> > So what's the difference between:
> >
> > (GFP_KERNEL_ACCOUNT | __GFP_ZERO) & ~__GFP_ACCOUNT
> >
> > and
> >
> > (GFP_KERNEL | __GFP_ZERO) & ~__GFP_ACCOUNT
>
> Nothing.  But there's a huge difference in the other parts of that same
> file where GFP_ACCOUNT is _not_ used.
>
> I think this unification is too small to bother with.  Something I've
> had on my todo list for some time and have not done anything about
> is to actually unify all of the architecture pte/pmd/... allocations.
> There are tricks some architectures use that others would benefit from.

Can you explain a bit more on this? If this is too low priority on
your todo list then maybe me or someone else can pick that up.

Shakeel

