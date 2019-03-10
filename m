Return-Path: <SRS0=tu4S=RN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CFDCC43381
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 20:02:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB6A520652
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 20:02:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="ewyfIUGw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB6A520652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 948EB8E0006; Sun, 10 Mar 2019 16:02:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91EE28E0002; Sun, 10 Mar 2019 16:02:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8377F8E0006; Sun, 10 Mar 2019 16:02:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 163CB8E0002
	for <linux-mm@kvack.org>; Sun, 10 Mar 2019 16:02:04 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id h14so649236lja.11
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 13:02:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=RwbjVaBjZI45PpSmnw9Xlin3P9fcUPM1xOoSmpv1WFs=;
        b=Tqg9i/lJh4R7MUmxin/kH4X2msKZQe8AiMDqaTNdrNapH2sQxxYzMryPK/xMRuimuN
         PhBHQtd9wpCfgmeecgzLyeEwPWP/ALGigfWJLvpRejWwNoBdJM5xDMcm9zd/e5+hnqDy
         sAGZiJA8v2edZPd8AGARdLxrvBP+4e7q9cgoPorXfluerSaFSAtHY4kzIQS3Fonzg+SJ
         iew6wZveNRBgHtUqsIuEbjGlF7VrxsaebnzHaYy81Xz7aNkxd3ObrBadGVOP0nwBqE0h
         B4gpXyXDOT3Oc9pLBVeUuV+msuw3CZ75zc+URy1hUa4ea2Sul1MZJLI0dbsqE6N7VEqR
         735Q==
X-Gm-Message-State: APjAAAVlh7nRzGFz5Uyb+EO1r6mi3AoV9Ws0+v9yJyQvNy8BzQ8p2E8Z
	JH7zC7C+fjmvJvoIPk+Fv387ZAadLTUwHXqga3JUG873jQ2HFRM7OJ+LFknACU0Ot4mA1rFK145
	7kg7X9Lpso3Um+nmlTUPHBr4u2DFPQQdYiSuJiNGTNTx6CTLfFsvNDe+szqrJFb/Vpwmx/LAxfQ
	gIRC6kDNayK0HUUE+L92VhAc/0GNZ7GTcqty3A9dE/my6WgtAl2aijsAJSca/F758hrHROLYYlX
	lvLQoklSik5B7BvNCN6SQSa5eVFWjUXgZWb0A8n7QqqYkGWvrCYlPql2/39pVC+k0+THzeGGa1h
	v1K5AuPX+T0LaFBRg0wk4YC6qWthepKNAy4qxpXQVTbE9869QdYuA6jBGUEFXsF9mm55tm6P6A2
	m
X-Received: by 2002:a2e:251:: with SMTP id 78mr14616352ljc.90.1552248123130;
        Sun, 10 Mar 2019 13:02:03 -0700 (PDT)
X-Received: by 2002:a2e:251:: with SMTP id 78mr14616328ljc.90.1552248122271;
        Sun, 10 Mar 2019 13:02:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552248122; cv=none;
        d=google.com; s=arc-20160816;
        b=tPqsTAyhV8YrXKF6f5l7dUbOgNBFbW5MVXEhM+XOGjf6b14WC39gYhCAHjb3PptaOc
         HrD+gTd89sTJ6nnx2O7Qvs7/+Hp6ErKCB8avF9UwIpkGGUvGAF0+Yq8WAHCNBp2W/QZn
         sjrYRaoYwaaxfoLmxcN0WAr5ceVLz79IWE+iiAX2Gjs87MwH5pi1MVQObBGuCm9MzURP
         VnJKtN1YNXXcnZyvQWAe20RmeN5bqdEp5tpQn+7snC8+YiZemiTBikasakrqB0vUNlf7
         Re/AwTsGq5pAkWFAsYqyurLgaGn69TQD507yMTtedlshBHrlpgwKT1Jil9bqHxnUBSgQ
         VXZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=RwbjVaBjZI45PpSmnw9Xlin3P9fcUPM1xOoSmpv1WFs=;
        b=qQmeRfzw13Fg7751Dvwakt9zE/rej6H4Kic3hKUXRuYH4forhs0uJybgicCWphGE9t
         KtDPJ11OS2towSLCaMxep9JAP7S7cwaXyDXeg7izP4omZ/rjtXB9GGa6nnRYXTc3F3Pz
         SFmbEy9HWmh17U5R61Pw6XcpAhhXK6P6Q8o/BZPWn698G+NjMtDeie7QxASB9HJUb3IY
         c3mXc1Iail/ZXpGMuSC9XKJ7NBplJyBVp+2FHyd8/MSo6yE9LunmqQqBefbbQ+1mI7Gc
         02MGDrF21IFjK4vsqOK/A4yCVIcXrQpj6/f30RY+vak7sCHbrCIdPBV6y5C3mMEZQfx9
         dzAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=ewyfIUGw;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v87sor1325085lje.22.2019.03.10.13.02.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 10 Mar 2019 13:02:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=ewyfIUGw;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RwbjVaBjZI45PpSmnw9Xlin3P9fcUPM1xOoSmpv1WFs=;
        b=ewyfIUGwAK2fYQ0/fgJSxZvDXnRz/KigyMZQj+N5yGgaFqZxUL+cfJsHlOyxSc+d8w
         r5M7lHrUm9YEBxmcstuML6Xz/zsJYfmknk2kx+lyrYsY/LWN1M/PoNRgKYFkKXTbLwuQ
         e3tfBZKnQNUPLaadV6RptIF3zc1xiEs0OaTQ4=
X-Google-Smtp-Source: APXvYqx9ouNujF+oQhUSY7gZxXw1y3MKn57gGwhnjT2IdbzTLqPPsLv76Djt4b2wrwB5Hl7m56NEGw==
X-Received: by 2002:a2e:9e57:: with SMTP id g23mr14417033ljk.124.1552248120811;
        Sun, 10 Mar 2019 13:02:00 -0700 (PDT)
Received: from mail-lf1-f51.google.com (mail-lf1-f51.google.com. [209.85.167.51])
        by smtp.gmail.com with ESMTPSA id u15sm661063lja.73.2019.03.10.13.01.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Mar 2019 13:02:00 -0700 (PDT)
Received: by mail-lf1-f51.google.com with SMTP id f16so1829547lfk.12
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 13:01:59 -0700 (PDT)
X-Received: by 2002:ac2:5542:: with SMTP id l2mr13312531lfk.136.1552248119399;
 Sun, 10 Mar 2019 13:01:59 -0700 (PDT)
MIME-Version: 1.0
References: <CAPcyv4he0q_FdqqiXarp0bXjcggs8QZX8Od560E2iFxzCU3Qag@mail.gmail.com>
In-Reply-To: <CAPcyv4he0q_FdqqiXarp0bXjcggs8QZX8Od560E2iFxzCU3Qag@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 10 Mar 2019 13:01:43 -0700
X-Gmail-Original-Message-ID: <CAHk-=wjvmwD_0=CRQtNs5RBh8oJwrriXDn+XNWOU=wk8OyQ5ew@mail.gmail.com>
Message-ID: <CAHk-=wjvmwD_0=CRQtNs5RBh8oJwrriXDn+XNWOU=wk8OyQ5ew@mail.gmail.com>
Subject: Re: [GIT PULL] device-dax for 5.1: PMEM as RAM
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 10, 2019 at 12:54 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> Hi Linus, please pull from:
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm
> tags/devdax-for-5.1
>
> ...to receive new device-dax infrastructure to allow persistent memory
> and other "reserved" / performance differentiated memories, to be
> assigned to the core-mm as "System RAM".

I'm not pulling this until I get official Intel clarification on the
whole "pmem vs rep movs vs machine check" behavior.

Last I saw it was deadly and didn't work, and we have a whole "mc-safe
memory copy" thing for it in the kernel because repeat string
instructions didn't work correctly on nvmem.

No way am I exposing any users to something like that.

We need a way to know when it works and when it doesn't, and only do
it when it's safe.

                    Linus

