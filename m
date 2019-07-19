Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14297C76191
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 02:53:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A06AB2173B
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 02:53:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="hx7Bkmfm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A06AB2173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14B266B0005; Thu, 18 Jul 2019 22:53:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FD368E0003; Thu, 18 Jul 2019 22:53:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F057C8E0001; Thu, 18 Jul 2019 22:53:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id C767F6B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 22:53:55 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id h26so16386281otr.21
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 19:53:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=CJrorFZPwH37FCb9+E44SyJ7wOVMUUfXLYvFlvXaXe0=;
        b=OKmyrm2frkJr7qa08km39n6uRs3+HDwDRIzpEMYQ52vS/JyA9MkN9KLpKcxJT16ByG
         CaueWahZBggr7CjNSqJrBSm6JzP/XZLKJx4pDZA+nRP1HP+22MmiI8iVm7lvQg94aH/w
         50G0z0mk1Qyqteu2C4KObd7PvutBURXaRBFkeeMs08qSLWtZX/Jhv0qny8HvxFSgIRnx
         VSoVK/P6mogjVBB5NlViyQGgvrglxWtQ4fwRd+ftMl1z265Azu5rsZVfEEx1rZWXCnZ7
         LLiYLob7Lp//PjH6yWfw9QIpU38tY0UNa2e+Qp3FrWOFdD5rs7obYvLjTEBXuEiGRXYw
         90zQ==
X-Gm-Message-State: APjAAAXi+JwzQx7o9lLKNEslz7Orgy0MDae27dOuF85Xfu+D2a3RcHLY
	pGmxP0yIpAioJ/4q8IvsHE3ZWOyOfoFLiBa9HI94bdsKMhjaDtsTUsEwUbk1uNvdAs8s8GqNU2r
	u75rD7+3rKp5ZAntpXxXbZOmI+cB5Og3Y0jwvqLfLD7ffbqqM/9FDJr5g/0CyhdFXBw==
X-Received: by 2002:a9d:7f94:: with SMTP id t20mr38325737otp.370.1563504835424;
        Thu, 18 Jul 2019 19:53:55 -0700 (PDT)
X-Received: by 2002:a9d:7f94:: with SMTP id t20mr38325695otp.370.1563504834718;
        Thu, 18 Jul 2019 19:53:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563504834; cv=none;
        d=google.com; s=arc-20160816;
        b=WKz79WeBt7rQ6a3tj2zy3V3Zpj/OBF+2JtYQbL7/damCtR7luGILixbITpDsnJr6IX
         BXuWEuf+95l41N5CxAxEFysoozXqrGORNdbOVn0MLmbAgE0gfe9uJ4EkqYWZ668iH+E7
         zGmeJzuWuCKl1IJRmjmWXt8En6t0BNgpuu0vqC3F/rwGXNHWAoB2ciHlrgiQabMhVurV
         4R2nO2jCkuTRnFP/9ynBFx5ts5TMGLIYDPKfSzJ59nEUhDVmHZ+sSJgxs4wNfNcXypJC
         n9vxr6UBSO1/koeQKxjsZVsL6xV6nNUm0G6AeEvBMNpN9ysfXTpf9BBMLUXKkHJ9wwfu
         Grhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=CJrorFZPwH37FCb9+E44SyJ7wOVMUUfXLYvFlvXaXe0=;
        b=DQC0xVwih1NmTZo3WhsUuyJJGzdbyT8Zz6eELnTXWN3GhGygxFy8VE/kxvILxDI7Zo
         RR7etGTY1P5yyBvHpo47i7DF2blZhMylVL1eQSgJwfU39pn1kgcwUanwrbbiig6Lgt2M
         NqvSF2yVELNp+/hN5UJFI/hp/tCycWyDquMfc2qqmsxwu8qTxeQcpdXrg3Shks8/Z+eu
         gtWf+f++wQoWABJgb7YTJ4bTt2e8Fao1A/rFcbDo98ygiuXqbDnpSqki6zzywOwhwM2n
         wBAZ5WD4HnhQfsuH5oY3EjxIBcGIW+5UVJwZvMS8MYc7YkoUGVf8wNG3gfpWUf6JXhWd
         jqLg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=hx7Bkmfm;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x83sor13100946oig.102.2019.07.18.19.53.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jul 2019 19:53:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=hx7Bkmfm;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CJrorFZPwH37FCb9+E44SyJ7wOVMUUfXLYvFlvXaXe0=;
        b=hx7Bkmfmhute9V7A5GdZv3mR0B7Qdq8/cBFx7PPc2khFtfbftkq0XrGQstJDy/sJFe
         s0qWF3WLaOukww8Byf/RVNOjNdso0toZjMrByDkwHq6zIwh1M9xPKx9zmnlhZZWck/fQ
         qvh/Oo8Adr0ZVZ+7JjP1PXhTKgADmHYE/eqCbcAOAdu+b1Z9JJmeG4tN0LRowGiXZlmr
         9cef5oh65H24J79rwgwDO469Iq56UUCY41e/L1dvT1blrQlxYNStCHooPGJegyBHnxZG
         n0MhvR3m0OjkOjBYEwCr0YwmTkZVWD8JuHcXKgmAWW62FF5N0ROLCTxtW2/FIL+Q0Asq
         YxHA==
X-Google-Smtp-Source: APXvYqwfTG3XIJMOd6zYoiaFB7RBS7dBO5NkBZzvNoiLPcwO6oj+MdoMhskIOXV2jg011+rwltFZBuP69xupYjsUk54=
X-Received: by 2002:aca:fc50:: with SMTP id a77mr24717405oii.0.1563504834412;
 Thu, 18 Jul 2019 19:53:54 -0700 (PDT)
MIME-Version: 1.0
References: <1563495160-25647-1-git-send-email-bo.liu@linux.alibaba.com>
In-Reply-To: <1563495160-25647-1-git-send-email-bo.liu@linux.alibaba.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 18 Jul 2019 19:53:42 -0700
Message-ID: <CAPcyv4jR3vscppooTFBEU=Kp4CNVfthNNz1pV6jxwyg2bmdBjg@mail.gmail.com>
Subject: Re: [PATCH] mm: fix livelock caused by iterating multi order entry
To: Liu Bo <bo.liu@linux.alibaba.com>
Cc: stable <stable@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, 
	Matthew Wilcox <willy@infradead.org>, Peng Tao <tao.peng@linux.alibaba.com>, 
	Sasha Levin <sashal@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ add Sasha for -stable advice ]

On Thu, Jul 18, 2019 at 5:13 PM Liu Bo <bo.liu@linux.alibaba.com> wrote:
>
> The livelock can be triggerred in the following pattern,
>
>         while (index < end && pagevec_lookup_entries(&pvec, mapping, index,
>                                 min(end - index, (pgoff_t)PAGEVEC_SIZE),
>                                 indices)) {
>                 ...
>                 for (i = 0; i < pagevec_count(&pvec); i++) {
>                         index = indices[i];
>                         ...
>                 }
>                 index++; /* BUG */
>         }
>
> multi order exceptional entry is not specially considered in
> invalidate_inode_pages2_range() and it ended up with a livelock because
> both index 0 and index 1 finds the same pmd, but this pmd is binded to
> index 0, so index is set to 0 again.
>
> This introduces a helper to take the pmd entry's length into account when
> deciding the next index.
>
> Note that there're other users of the above pattern which doesn't need to
> fix,
>
> - dax_layout_busy_page
> It's been fixed in commit d7782145e1ad
> ("filesystem-dax: Fix dax_layout_busy_page() livelock")
>
> - truncate_inode_pages_range
> This won't loop forever since the exceptional entries are immediately
> removed from radix tree after the search.
>
> Fixes: 642261a ("dax: add struct iomap based DAX PMD support")
> Cc: <stable@vger.kernel.org> since 4.9 to 4.19
> Signed-off-by: Liu Bo <bo.liu@linux.alibaba.com>
> ---
>
> The problem is gone after commit f280bf092d48 ("page cache: Convert
> find_get_entries to XArray"), but since xarray seems too new to backport
> to 4.19, I made this fix based on radix tree implementation.

I think in this situation, since mainline does not need this change
and the bug has been buried under a major refactoring, is to send a
backport directly against the v4.19 kernel. Include notes about how it
replaces the fix that was inadvertently contained in f280bf092d48
("page cache: Convert find_get_entries to XArray"). Do you have a test
case that you can include in the changelog?

