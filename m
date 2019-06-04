Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68D36C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 08:50:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26F062486D
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 08:50:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="s+BZYPLT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26F062486D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACC346B0266; Tue,  4 Jun 2019 04:50:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7D9C6B0269; Tue,  4 Jun 2019 04:50:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96AFC6B026B; Tue,  4 Jun 2019 04:50:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 770C36B0266
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 04:50:51 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id b5so2518073itj.5
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 01:50:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=T3hHFGqrMn1+Csc7ogJAJELfMmtCK4b/mNGsWqPXMSs=;
        b=quxRe47Ksa7FUj1uOnmBWopdGbSVqbNjojszxKlIqQLvLQutAA9AMKIbriRs/uQuNz
         VAP5tUKJs9CHrsUWfs0UNhwvk7pcMWAll7QaS/b3ZMfbDc42A4WOTK7myEOx4arUgKFn
         XO2NcHxP6uwIgivwPsrC+N8M+x3GB8iIKCbKR+s2ko5PvmN6Rr6scMGmbHwNkIeTcMr5
         HKDhZ8nCYf1wikw7MA0QdT7FolArmCOzwsURk4GJrjurN9Cgb1Z/MnCXtmCSxmXGWU0l
         D5Dasc5rCJgyfI7npUVnCkJf36shQKzontElTZyKIrQ++70sdvilRO1QKwFpbQ/9r0Fg
         LtqQ==
X-Gm-Message-State: APjAAAXBrXqroDzwC+EJ/1jAEUHPTg5TqM4KlajUh094tYlW2uklxV8p
	yhApJA/Wki3lvsnAqZLngOuSFydvut/eadxZuAmgFdxQas+hsryuIOjO7weZve5azlILyzMGPgv
	++SoPGUSrqfQmzhDvRgRsWMwRUNQyunB1TG4TenBHxJglZQaoaKiOpsWD2Jhsx0SSeg==
X-Received: by 2002:a05:6602:59:: with SMTP id z25mr10818016ioz.186.1559638251169;
        Tue, 04 Jun 2019 01:50:51 -0700 (PDT)
X-Received: by 2002:a05:6602:59:: with SMTP id z25mr10818007ioz.186.1559638250619;
        Tue, 04 Jun 2019 01:50:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559638250; cv=none;
        d=google.com; s=arc-20160816;
        b=CkIr4P15quSoxS+jAidgGF1HqdlCoQvXoDYuKcs9IQNHLJeIOxx2Dt6t55eDoCq5xx
         bF9vp0KUZprYh5efyPFhDOWvA7+IL4qEjIHhUHLOBinmXeRxPwju38n0d1ISrt+tVCEM
         rLziDSoIDY+28RupKr1vTq4qnypC/d3Q3Q2RelRtfg28+vHKwUx9/BaAjKau0AIEzQNY
         nmn8PbaKUbKm2DvidbzxmG7FD1MNsrRuu5Cieq1+Y/mzKlR2z97zaLufP82qjmcABA12
         5XX3krwEvnmBSbBJL74lSOwkiQpdT6d7v48ySMR2jmXFi7XwGU9lf2P7ZEGa+J/PKCBB
         cC9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=T3hHFGqrMn1+Csc7ogJAJELfMmtCK4b/mNGsWqPXMSs=;
        b=T55B+LLxQNFkcsRdEprXNpIbf/+Pk+iV+V8DBxG8sTMFQXQ8QwUneMnfsTZxK4fuXX
         WSJ0AToMgktvnd2UAelzfBbjWCmQ9yesrEQ1WJtmxLOx2Ly/SyH/qNumOnULRa522nAZ
         j15RKAmzTtNMpllLiEUHQE8VIGtrFLZ4girkTi/1+HamnCFlnlojNgDif4oOJcgQijWx
         uoDsonrjk/gsTqpg5yEiSVqkv5P8kV/82uZhEyg3IrsEjJRAL4UWOgyWiXvgynMNmGWH
         F3kqj9o6sIF5BsA2iPgUpV6kZ+pWADQoa8lHZnJTb7X4Qq7/7WktQXDjXVjm8uVC6Znx
         tSig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=s+BZYPLT;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g11sor9892301jao.13.2019.06.04.01.50.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 01:50:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=s+BZYPLT;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=T3hHFGqrMn1+Csc7ogJAJELfMmtCK4b/mNGsWqPXMSs=;
        b=s+BZYPLTRv9v6rWK+5uRT0LvtuHd27GSQqarKWyjG4BSEOqHjud5FUNVi/8iI3dkem
         9Drf+GABFNUsxGyrX+qJXJWnu/vozq02OmSZ1BqWSkOcGYhR/roexxgha4TMNMFN1zYM
         VaFgUnwre/5yA0nUzztImy0YlNyFGjXOQPgWh25UqIjKz+XRbjHig/+sxfaP/NSrhIUO
         CRUJhlPJ2y0QEOm4de4tNcGrXeYX3diaMyzQcIDusACY4/IB7o6U1cHfAdwJDfart49j
         3w0dS2vtWAZu0qsYojxtpJUZr0SrVK9caR49lxGzFz7ekq4VDcmmoTu9Fl5ALhw3GcoQ
         j4xQ==
X-Google-Smtp-Source: APXvYqw2d+Pigp+yuoJfD957oHtsC9aPSPUuB2VxrEocEVkZT5Yq3MSS4N88NNppLN6LiDVtF65M6ErW0QGe0lmhFo4=
X-Received: by 2002:a02:5489:: with SMTP id t131mr18326627jaa.70.1559638250407;
 Tue, 04 Jun 2019 01:50:50 -0700 (PDT)
MIME-Version: 1.0
References: <1559633160-14809-1-git-send-email-kernelfans@gmail.com> <bb4fe1fe-dde0-b86b-740a-4b3dfa81d6f0@linux.ibm.com>
In-Reply-To: <bb4fe1fe-dde0-b86b-740a-4b3dfa81d6f0@linux.ibm.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 4 Jun 2019 16:50:39 +0800
Message-ID: <CAFgQCTvu7vcp0DqG43XxFQmoOOqXWbCfRDNcWUDm7vro5GmdtA@mail.gmail.com>
Subject: Re: [PATCH] mm/gup: remove unnecessary check against CMA in __gup_longterm_locked()
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, 
	Ira Weiny <ira.weiny@intel.com>, Dan Williams <dan.j.williams@intel.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Mike Rapoport <rppt@linux.ibm.com>, 
	John Hubbard <jhubbard@nvidia.com>, Keith Busch <keith.busch@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 4, 2019 at 4:30 PM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> On 6/4/19 12:56 PM, Pingfan Liu wrote:
> > The PF_MEMALLOC_NOCMA is set by memalloc_nocma_save(), which is finally
> > cast to ~_GFP_MOVABLE.  So __get_user_pages_locked() will get pages from
> > non CMA area and pin them.  There is no need to
> > check_and_migrate_cma_pages().
>
>
> That is not completely correct. We can fault in that pages outside
> get_user_pages_longterm at which point those pages can get allocated
> from CMA region. memalloc_nocma_save() as added as an optimization to
> avoid unnecessary page migration.
Yes, you are right.

Thanks,
  Pingfan

