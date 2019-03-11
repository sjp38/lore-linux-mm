Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D10FC43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 15:37:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11F4221741
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 15:37:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="dfus4mt5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11F4221741
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 385078E0003; Mon, 11 Mar 2019 11:37:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3350B8E0002; Mon, 11 Mar 2019 11:37:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 223908E0003; Mon, 11 Mar 2019 11:37:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC7378E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 11:37:33 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id h127so2534653oib.20
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 08:37:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0nwzrNUkZdLhL4GU/3no0VIgP0MMMf4JZZpBu04oIkM=;
        b=NqGUuvG0n1hz1ryKZ7SD5QD8Hci/XXtmfgIhQdYnfW5if4UZ/Kji5YjKTf10fcW7uL
         3Iyh4w3VC7zXENd8bVpDoRdru3ytasdhas1RnIV19YC7x81vetFoM0Yn92CqV3dNDAFc
         F7tAvmBhfFfrOAA1hTMenRXzYx9ZNyL879Qjs0VAIidYVER6D/supAlghKuJa94doS+s
         DRHbuednyZY/8f+nnZgDFBi9oHg0O3d60CblKgYz/bqWfmeo+QzQvlfev8mczerVDgN7
         vbHPz2+6YfLU13fxqnM0/9rQO5jF/2J5XOAn1V2bomCvUtDIL3eZF0CasysihhFEem4z
         Jz8g==
X-Gm-Message-State: APjAAAW2wKs0cflCD9sY91DorUrzb+dfVSvKyN8OTUHYWJvP5rYURYJB
	atS/oOCYXKR2wIsRt/sCIeSlo5u1Vj1UgI3cSuecHLzExI5uoficu069A2kyVjTw71amsipngBH
	v0daPEZH+sAWSy75ytAgk5AReuJrE8uLPqHFAsdOJ3o8JKFmu4SZZyeRwWWn+HfWIEw+tYJ3dsC
	dyRKrGYDuP3l9x/PgEUDh40XZVHNTHNuSV6WlDwaOzr7VnZBGbIt+TAlI2URdxjY4JmQ2wO5rJY
	KkFj3eVSLh4P7Q78msx58v1arL0NaQ+jDE2em6UJ5QQJwZ1LDn0XXwT+RqSrGJPaWqmHC1lDsLZ
	DUy7cHizYKdIKUjwu4g2gFnM1xQ2qTlTpPKOTuK08q78fKWZCXGJnnhEeJIJEifEuDf3TTUE1zo
	g
X-Received: by 2002:aca:3746:: with SMTP id e67mr182825oia.103.1552318653456;
        Mon, 11 Mar 2019 08:37:33 -0700 (PDT)
X-Received: by 2002:aca:3746:: with SMTP id e67mr182772oia.103.1552318652377;
        Mon, 11 Mar 2019 08:37:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552318652; cv=none;
        d=google.com; s=arc-20160816;
        b=irlWoheIq1fxYsxva173K2sDR2gInpvgQ2or0AZxElhq4yQe5Ls1C4oqPb3lS/gYrU
         5/vcqrMC+TkIbUPZTUCD3t3CB8HzGikxLzHzTfBuu72iZ7MaJAXbBfBmfvkU9/v5nBxv
         pZMkq4iZR0dnDu3DBNxyj/4MJxAwsT+A9/VIK87CGnjLkpgIjuqOjDY4y5iYlmcfNSDL
         ciCrWJjCDUS7tlAN+sltyv7baRpJjEIIjToeWIz7q3GAfOiZ1KBL6eMa2kqBJ+gScpPJ
         tTjxkIJ/zP/9g+3PbD6pYADRudhC0K7LE70/Aj7xdejMc+xDZD71k6QATmrEPG0ERh4L
         Mpzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0nwzrNUkZdLhL4GU/3no0VIgP0MMMf4JZZpBu04oIkM=;
        b=JF4Qmzd5xgGF9E5vVXJDlJ1PLCvMC6On9DTmcrspxeTRfpxRTWNE5mVajteGK1b397
         7WjxVPyepR47/k8jsRF01Th2HCnAqYsQFegJMFISRfVttdT1o9WDEPni2qkYDQVRKM4U
         hYXyF/w9IONI7yCUWGc7N2zbv6A1mH5jCqT2bR+gDopfcf2Md9IyKM8ChcIlx9tCsTPV
         okghc63es5kqqZWgwkWAHijlcWc+FaLr50S+L+tOBRKFUuU5fA1tKuaa52Ty8zRQMn9M
         EbZqEPKaI2PBr2qCMpWPSsLNOmMRccWsHuA6QwUG+PsCHEb4ubzyHMy+5Nd2DfC8V0xv
         lf8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=dfus4mt5;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d131sor2619884oia.142.2019.03.11.08.37.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 08:37:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=dfus4mt5;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0nwzrNUkZdLhL4GU/3no0VIgP0MMMf4JZZpBu04oIkM=;
        b=dfus4mt55MPaTu+8O+JGITBbo/hAy7cBajAyCQ3rVyNtPAOov7e0i5ZHB9hEdPracO
         CmgSLLK8qxK+IDgPco+656DoVH9BWmCyTGeqVQEb+PYVuDPPu1zqt90G/qC2vO4NTnGy
         SWVz5k3AEvTVMNm7JN8VlvgZ7+V65sX55gltafBgJlONegL7ycEzr6LFYKQs1xwSHzY+
         12TaAuixNwXCjWHaOZ0nVE5EOM/uSP1pxD68fn/8MsWaOUfTvGabmb/bI8TR2bepkBJm
         r8jnWq9IT6ONmId53iHbT7jTqqtlLRdh2MgO1o56fCNG1Q0hpN6+fuCJBtVKdcR5XuX3
         0Brg==
X-Google-Smtp-Source: APXvYqwUzTMumUJkRcDKG6xtSQmWo4U+Bj6Wqtwauep26jP3J3afdhjk6Grvu3NaAT1z/S6zquFp/9jlKhkG4wekzyk=
X-Received: by 2002:aca:c3cb:: with SMTP id t194mr200300oif.70.1552318651813;
 Mon, 11 Mar 2019 08:37:31 -0700 (PDT)
MIME-Version: 1.0
References: <CAPcyv4he0q_FdqqiXarp0bXjcggs8QZX8Od560E2iFxzCU3Qag@mail.gmail.com>
 <CAHk-=wjvmwD_0=CRQtNs5RBh8oJwrriXDn+XNWOU=wk8OyQ5ew@mail.gmail.com>
 <CAPcyv4hafLUr2rKdLG+3SHXyWaa0d_2g8AKKZRf2mKPW+3DUSA@mail.gmail.com> <CAHk-=wiTM93XKaFqUOR7q7133wvzNS8Kj777EZ9E8S99NbZhAA@mail.gmail.com>
In-Reply-To: <CAHk-=wiTM93XKaFqUOR7q7133wvzNS8Kj777EZ9E8S99NbZhAA@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 11 Mar 2019 08:37:19 -0700
Message-ID: <CAPcyv4hMZMuSEtUkKqL067f4cWPGivzn9mCtv3gZsJG2qUOYvg@mail.gmail.com>
Subject: Re: [GIT PULL] device-dax for 5.1: PMEM as RAM
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, 
	"Luck, Tony" <tony.luck@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 10, 2019 at 5:22 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Sun, Mar 10, 2019 at 4:54 PM Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > Unfortunately this particular b0rkage is not constrained to nvmem.
> > I.e. there's nothing specific about nvmem requiring mc-safe memory
> > copy, it's a cpu problem consuming any poison regardless of
> > source-media-type with "rep; movs".
>
> So why is it sold and used for the nvdimm pmem driver?
>
> People told me it was a big deal and machines died.
>
> You can't suddenly change the story just because you want to expose it
> to user space.
>
> You can't have it both ways. Either nvdimms have more likelihood of,
> and problems with, machine checks, or it doesn't.
>
> The end result is the same: if intel believes the kernel needs to
> treat nvdimms specially, then we're sure as hell not exposing those
> snowflakes to user space.
>
> And if intel *doesn't* believe that, then we're removing the mcsafe_* functions.
>
> There's no "oh, it's safe to show to user space, but the kernel is
> magical" middle ground here that makes sense to me.

I don't think anyone is trying to claim both ways... the mcsafe memcpy
is not implemented because NVDIMMs have a higher chance of
encountering poison, it's implemented because the pmem driver affords
an error model that just isn't possible in other kernel poison
consumption paths. Even if this issue didn't exist there would still
be a rep; mov based mcsafe memcpy for the driver to use on the
expectation that userspace would prefer EIO to a reboot for
kernel-space consumed poison.

That said, I agree with the argument that a kernel mcsafe copy is not
sufficient when DAX is there to arrange for the bulk of
memory-mapped-I/O to be issued from userspace.

Another feature the userspace tooling can support for the PMEM as RAM
case is the ability to complete an Address Range Scrub of the range
before it is added to the core-mm. I.e at least ensure that previously
encountered poison is eliminated. The driver can also publish an
attribute to indicate when rep; mov is recoverable, and gate the
hotplug policy on the result. In my opinion a positive indicator of
the cpu's ability to recover rep; mov exceptions is a gap that needs
addressing.

