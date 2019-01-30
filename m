Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F26AC282D8
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:24:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB34C2087F
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:24:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="fj+J85eH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB34C2087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65F378E0013; Wed, 30 Jan 2019 14:24:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60EDD8E0001; Wed, 30 Jan 2019 14:24:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FDE38E0013; Wed, 30 Jan 2019 14:24:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1FFCD8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:24:58 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id z22so274961oto.11
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 11:24:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=i77S7MM2CpsPk8Esja5BnOxATbCo+ICNnWSU2cpIjQw=;
        b=mXspPorqhYWgG+xZtNTjgk8P2I/6FWZxuDDZvz3ZHkP8C+fUhF3RRaCaevy2zA7mhH
         0W9v9YSq+xdgYTG6c1gMGx+fOgHfa2EIYMvZs8EmFrnVwDjErPxftpqvo1otWoZooXpl
         +S+TSGsBwwYMI42egfhoqrNh3BKEeHrYGYIBJFQ1SbVtnJE5DnZZiUYw/WN1U1AREybL
         OOeyeq3q20Ju07Nf3XS+j7G5+JVhd1/ysT66iCX8LZ1swwLIYKkv7ZrlAXdVvsow+jgo
         iaqAp+fv7wk6zEll1Xuie0D+v0f84WoLyYwpaPiqJjezqVxN4kQJwTeqN/iWN7ly331X
         zAtA==
X-Gm-Message-State: AHQUAubBugEKbjplsT+toa8n3fyTKZ8/1r/8zwCT6NC0Xrb5HuiSASsm
	6Mg4C/bVBlIwasYfo74VyCaRmYPlo2pQIlUlBH5ICYbP7rcaxdynRtuvbKMnxuYEhWMadUPozlm
	mtkBUfKwc/C3LXPLWt5us9LxN+niy3f2ZuSW4gqR7+alzs1eYlbZ8UH75K6Zv2pR6+RYupybNfP
	fCCv98Qtqd6nbya6wuV6w/xcasPFkgbnxpUn2Z3AlRP34tOGwPYFF/U+QQ1Br/JHicXXH3aJ0FU
	T7hF9vhV5vp2gcL5D9R5sBbGCy64R2MvxDlwP7k2//hSOQ3Vbwagin2tJeUnEvcC4bic2M+uxri
	3L6tkQKNFvCr9GVpW+baz8wmuuz7MXI9fVroAGaXeKBJABZhsvr0+gDdZTe1MNsmxyeTODswnEs
	9
X-Received: by 2002:aca:ebd4:: with SMTP id j203mr13533586oih.222.1548876297736;
        Wed, 30 Jan 2019 11:24:57 -0800 (PST)
X-Received: by 2002:aca:ebd4:: with SMTP id j203mr13533568oih.222.1548876297221;
        Wed, 30 Jan 2019 11:24:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548876297; cv=none;
        d=google.com; s=arc-20160816;
        b=Ts/fkYwZMkPnNqTX9muUip51eS0iPyuHEpY0vguWrgDE9CArjpq/VGQaVT5rXX9rmX
         uoGnQda0e76FdxXhrttZcS8FCXIg6tqgTSkVvKkEaBhne3ShGIflm9azPQ0umrbLjcSC
         t3OuiHlYWn+IcEpPMHeVk7F4oQ7CmbBUKJ9gy9B0ErvTJHa1AbOYblzNE6dWNXyzkUaK
         u4ceDcI4pAS86GLw1FILNsXoY1HcBlz/bxRFmxRZVO6faBXxbo3lsP91CPzFfc/AL1rP
         FVszp2f/gakQ/ClZa0EZdRMRT2YIlB6Kz6YsW17LpNnOEj+RRi6pXJJWAV/L5UutadTW
         RuCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=i77S7MM2CpsPk8Esja5BnOxATbCo+ICNnWSU2cpIjQw=;
        b=a8khrrW95Yb3zItshNMQrOmHbitTwetdVqpVVD/3jqopQuC5a4oUkxdrxQTxdNnNkH
         gW7LW0ZKS16QBomlQFYTAKk6h1GBluF/M0sPL26Y5UCo/3ijiJ4pieJSJggSEvgcy4Ki
         tsbSXC6dYRqppJCOceqXd9DQusFOPzg//DFErPilsoZEFNm14FrQi94F4aPMip7Rwf/L
         d7bSJJMF96ZNJHUCSRcV5jsudZbqtLUR1DCEo9S1cBD7DAeX2kS0VYuwg6uzWxWoihjo
         1WKoBlKynyAjeEHlyhh0j7uGlH0ES1Dw7mjVPMVBIYwYHKBUiE+An8jeNbrMeUSUzDbK
         CDRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=fj+J85eH;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 78sor1141715oii.101.2019.01.30.11.24.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 11:24:56 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=fj+J85eH;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=i77S7MM2CpsPk8Esja5BnOxATbCo+ICNnWSU2cpIjQw=;
        b=fj+J85eHmmoDBgqOie71luR9HCN7N5yxqMUZTXmbCvylkuNUhNhR9aP2OBfmz4e57x
         ObuZ+bH8XJBallVWeFkvS27MtjgEtvXK7gzbMPnYJN1M3d54tClnvpRBbXmiXoTrJft5
         zZA6EtWwp4I5Te3oZAFukFzeyWqP8u132Cndei6rw9f3F0l2+BjFbn/SsTiw1J6QixON
         2ZpZX3CRVKW8fpYso+kKCEiKb4FSThUZLemrz3rnhobIqo4ZzF6Rck0Ja9Q2wcVR4zae
         RPVOqWcB/GRvQGfFI5LGTAFiY/GOjlyhVfxKWPkQ+wFf4vNsKQdFXzMEhUqgP4RD0bn8
         93+w==
X-Google-Smtp-Source: AHgI3IZy2xBWKDGay61UfSFE8lBEuhM3cL4TF0tWmWTh4+NSpuIIIbDYmsWFLAlQDMDos1K4aM97n9Aqtj/nK8hqWfc=
X-Received: by 2002:aca:d78b:: with SMTP id o133mr12545316oig.232.1548876296664;
 Wed, 30 Jan 2019 11:24:56 -0800 (PST)
MIME-Version: 1.0
References: <154882453052.1338686.16411162273671426494.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154882454628.1338686.46582179767934746.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190130191117.GH18811@dhcp22.suse.cz>
In-Reply-To: <20190130191117.GH18811@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 30 Jan 2019 11:24:45 -0800
Message-ID: <CAPcyv4iEmPGtK5=7ah_0Fyeu17y26TwifDMRYruZtD07nCxD+A@mail.gmail.com>
Subject: Re: [PATCH v9 3/3] mm: Maintain randomization of page free lists
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Kees Cook <keescook@chromium.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 11:11 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 29-01-19 21:02:26, Dan Williams wrote:
> > When freeing a page with an order >= shuffle_page_order randomly select
> > the front or back of the list for insertion.
> >
> > While the mm tries to defragment physical pages into huge pages this can
> > tend to make the page allocator more predictable over time. Inject the
> > front-back randomness to preserve the initial randomness established by
> > shuffle_free_memory() when the kernel was booted.
> >
> > The overhead of this manipulation is constrained by only being applied
> > for MAX_ORDER sized pages by default.
>
> I have asked in v7 but didn't get any response. Do we really ned per
> free_area random pool? Why a global one is not sufficient?

Ah, yes, sorry, overlooked that feedback. A global one is sufficient.
Will rework.

