Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 564CCC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:26:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25E8524AF3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:26:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25E8524AF3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B33696B0270; Tue,  4 Jun 2019 03:26:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE3A56B0273; Tue,  4 Jun 2019 03:26:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AB3F6B0274; Tue,  4 Jun 2019 03:26:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5F5376B0270
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 03:26:37 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id u2so6605861wrr.3
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 00:26:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LhtWa/W6MWsc83ZFA/wV3MjdIk5QMFvtMTN+/TqTIAA=;
        b=d1uSGAWdffP0GL8ME4XPw756uROebaLI0bRxck656JZR9eT1NKtP16f1JX5gP9g82L
         PXQ27fkxJd5dIppCZLpWMk8/e7ZS0t3Cz9Kpq+NYIak888OWU/HVladbelNgFDDE+B7W
         ldpJirJRcW2VxZiAeCVEVn3fM9VNIk3G0bvuLLJGQGVhW/eLJNamlZeSkQDtTWAPq9jB
         3M+MXHLbxZclehz6i/oCCuvHQHaT7fDEj357yvCXWpHQM5BNWkDrdRYIFUZpZJUNtqCm
         cijqzAEDRVNuep97Cbw3XMgZ+x7QSc102/Y8wJKn6mvUUUPGjIecI+cHSHGQUyA8Cphl
         +arg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVU4sH0hy6mOIunOajGH8Wr/Y3zk3ItTatDsyFI3ZZR1FvpojJp
	IcH0iuOjuAPH7K+LGfICn4lQlFgbgzQGX2KI1HDXtgsBJB0UdSIsH8Qw6VE91qAkvAsT7lXnfTu
	NOO4dtRPnfGaZP8tonfRzu1tAc1NDzSnbk48CNJU1eCIVIUCaz71eZC2jmAChC1aw/g==
X-Received: by 2002:adf:ce11:: with SMTP id p17mr19206356wrn.58.1559633196915;
        Tue, 04 Jun 2019 00:26:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHwjMf37Ot2e4GMc2d15ZOd40Hq5ow6QTuYmI4vzP3N59ljjke93bgMNHOyst3gk7qCIxz
X-Received: by 2002:adf:ce11:: with SMTP id p17mr19206310wrn.58.1559633196230;
        Tue, 04 Jun 2019 00:26:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559633196; cv=none;
        d=google.com; s=arc-20160816;
        b=BCjyUo3AvBbJLeArZZsJKMmNajnJ+XotZxE0C8+0z9wO8V/5uXUeRlGm+oGjNM8ozz
         lJ+2wFVSjW8eTjRdr/n8HgcgSg0HKt25Pxgrl2AFXRVG2FU6SRQhyp8cMw5xRv3Mhv4A
         NSuqa0y9cpjydys4YcYEEeqrqUweO3muAb/1raJTCOMXzzJ2XpmlWpNSTe1VZaAfuKHP
         oHTPy2y5tWbk6G0L7e15rOJe/pDKn4sZNG43dsknpsySNPWlkvzp3UESnfmWq4mIP3QE
         fmshY2AGsAi/Q4hJ/VE8YI/SZMCgL4aSCzWhkTVWAgzqAa7OHs/xolr21LyaDvDPyzuJ
         NzVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LhtWa/W6MWsc83ZFA/wV3MjdIk5QMFvtMTN+/TqTIAA=;
        b=TS00i+SH02OnUZATowPxGDa/NXfeDa9S4EdPrqCGMoLxzA+8W00JkanDcPXYrpiylL
         jxT0XUUV5ZszPNmyMhCdIOF+QMx8fY23QYV853t0CaMkS5rxkwBxu+G2XiiJCkzGKg6k
         HUMZ50u7EVXkzSU7d7nTz2Iu0pOudDrJaevfE7lABk+Tf8vxFOXhHwwZ4wK3YfhoATSU
         Cap0jLL9veIXdmnKxMu0+FOIetMoQpyLdkQg0QObxeXv+ODdft2OUtzdCsbzy4f+6jWb
         3ICqezVChOwY530lrXiDcDeVoEsE3A3iZ7i1Ggrwg1Yqd2yuHqCGvlthYrsOxYWyraSF
         bvPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 188si2433864wmd.156.2019.06.04.00.26.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 00:26:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 89A2368B02; Tue,  4 Jun 2019 09:26:10 +0200 (CEST)
Date: Tue, 4 Jun 2019 09:26:10 +0200
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>,
	sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	Linux-MM <linux-mm@kvack.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 03/16] mm: simplify gup_fast_permitted
Message-ID: <20190604072610.GE15680@lst.de>
References: <20190601074959.14036-1-hch@lst.de> <20190601074959.14036-4-hch@lst.de> <CAHk-=whusWKhS=SYoC9f9HjVmPvR5uP51Mq=ZCtktqTBT2qiBw@mail.gmail.com> <20190603074121.GA22920@lst.de> <CAHk-=wg5mww3StP8HqPN4d5eij3KmEayM743v-nDKAMgRe2J6g@mail.gmail.com> <CAHk-=wjU3ycY2FvhKmYmOTi95L0qSi9Hj+yrzWTAWepW-zdBOA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wjU3ycY2FvhKmYmOTi95L0qSi9Hj+yrzWTAWepW-zdBOA@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 10:02:10AM -0700, Linus Torvalds wrote:
> On Mon, Jun 3, 2019 at 9:08 AM Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > The new code has no test at all for "nr_pages == 0", afaik.
> 
> Note that it really is important to check for that, because right now we do

True.  The 0 check got lost.  I'll make sure we do the right thing for
the next version.

