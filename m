Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98D93C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:45:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40D7A20863
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:45:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="ZDbQf6wF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40D7A20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E795E6B0003; Mon, 25 Mar 2019 12:45:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E28BE6B0008; Mon, 25 Mar 2019 12:45:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEFD06B000A; Mon, 25 Mar 2019 12:45:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id AE5086B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 12:45:24 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id q12so10796386qtr.3
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 09:45:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=azszLIWADnCz8AeAgm8+58HpL8DqZnCAWctdIVFE5Zo=;
        b=TQSGlzMYoIvhRexgDF03ipulrj7W1424m2i1+vfiBUe2Jn1N8sTEDex9ISn+EWkPSf
         PdXR3vbNFatRxv0q1OTnhjrlF03OsngHzfOJ40+4e+mIV6CrfI/EsqeUhco/NKoI+9tr
         wxpI68FiX95ekkctjrVmvWL2OAaA+WirVre08Pi4lKMxi8rxWebkYnt0Bc4PdRrqSgf1
         itOy/7x6bwOSFgGzVq3J0TD2XWmldh3WGSmMSd9z0UsdlxeSGTV/Vpn84XtdIJqGBXah
         X87CSMV9RfOM3KIGHxuOXQnWcF3oSah3rpTvBNtHlmOLbKbOzvK4WY5Z0h9OA3nUg6Em
         DsWA==
X-Gm-Message-State: APjAAAUbizPrZsj3ie51DkwUP2pAebi9YA3iS9yILKpLkUWOjSmRhjNi
	CjdVY6ykmKg03tHxMuLIoI4n2MdXzXMDHpe5dzUbRsO7CwOb4qgvylCYb1RufLaPKzXg96t+U9f
	wGMlwEoh5dckdHfdfVYlVn0UMgLz3UQTIbJyFZt+AS8mzKI4drrPgamMZkOlQL0elpg==
X-Received: by 2002:a0c:d21a:: with SMTP id m26mr21379240qvh.100.1553532324504;
        Mon, 25 Mar 2019 09:45:24 -0700 (PDT)
X-Received: by 2002:a0c:d21a:: with SMTP id m26mr21379200qvh.100.1553532323954;
        Mon, 25 Mar 2019 09:45:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553532323; cv=none;
        d=google.com; s=arc-20160816;
        b=on6nY4uEyjxHs7CTUlCHWTn7X3viHF1mB1p139ygiegeCSLBle99IMIgkikjDatm0z
         AJqKAeOLn531Qoa/VyMpjTqc4hhmPusKy2Is+qkLpfW1lcAVh0g3ZpYMD18kxXoCotYh
         gR4GNzCDiREi2h+SgBDdrnZc6MIUB5oDrUre4ofNBmo+TzKToJwBwWsLu6s3aYvKCUvs
         wdQejzsgMQAJGb4zrNctasaMkBIxrt4VIpDyKcZhYc5Fd7JplsiJOR8DzwtIbtTZEKTZ
         w1LN3pZu9kDtHOL6EAF1EqoQQwF72a2K5GD5e+l2vZ5naHMkF3a7jgbTqlF7OnGrFwMW
         fBqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=azszLIWADnCz8AeAgm8+58HpL8DqZnCAWctdIVFE5Zo=;
        b=pI238cS8tzydJ+HOy0SOi8XM/n1UCS8XriJ2bsP+iRdvOyyzgboqkny1ENKkCa2dye
         g8CPXqAZ1oLYD0rgZ86lkyoVURgbwAYcg57Pqq3W082Gsgjs9MYoo+XhBGG00cjF/5TL
         ujxESLWaCWJCeS6M1v4+rN8lcdwRRqxYq4UOxOee5pYC4LIv/sXE+hj8JtI0YLr0u3PZ
         kb0zoHBus9acrfkKuOG7SK/3sfPLak1Jr/vhDyd5mhCYTQBsrS5EKBnC+oS3HC55nVjQ
         ddYXC+OV0A6ANi+Bwgr2USD8KcuVdxFwYdQHEyrOx9oB/RffdMHBlrqGYfmMWu9Nx5pu
         vw9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ZDbQf6wF;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n17sor13634539qta.70.2019.03.25.09.45.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 09:45:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ZDbQf6wF;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=azszLIWADnCz8AeAgm8+58HpL8DqZnCAWctdIVFE5Zo=;
        b=ZDbQf6wFJU+EYUfgK208d7q5xgEAsedfDWsH7HcS+TgxZe1Tssa2BPdsAG2/hwMAys
         rsvWpbV2F4p94YwmKTFIuX4ZYCNds18YVeb5XKR3N/q/IwU3EkNwJcTVzYn6EDh7fZln
         2OZxPHIHWfFGj7YZXdyCqHS05W2dh7149lXSg4/ukEQUMHL7D7Y6NtaabG2aYj9KasxM
         PHuOzwzg4iM4288xlpCX0Y7+myHdwiQDA5aQ9iytY8LSSCnI+uBbm/mNp75vQ71uvTOh
         1u0QcVedoEpv2k/lmslIikFO/JBL2Dw9XFQLEa1MLkr1UZsADEa008jT8NGlhOraW5UW
         A0zQ==
X-Google-Smtp-Source: APXvYqwyqN1SmdoxO8BNg708b3bvqvBy5e7BsLNFvrI9L6R6ElZeTlrOFSa7GssTU28fSAH0U/YXsNRayrnRchybewU=
X-Received: by 2002:ac8:2396:: with SMTP id q22mr22096706qtq.382.1553532323693;
 Mon, 25 Mar 2019 09:45:23 -0700 (PDT)
MIME-Version: 1.0
References: <20190317183438.2057-1-ira.weiny@intel.com> <20190317183438.2057-2-ira.weiny@intel.com>
 <CAA9_cmffz1VBOJ0ykBtcj+hiznn-kbbuotu1uUhPiJtXiFjJXg@mail.gmail.com> <20190325061941.GA16366@iweiny-DESK2.sc.intel.com>
In-Reply-To: <20190325061941.GA16366@iweiny-DESK2.sc.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 25 Mar 2019 09:45:12 -0700
Message-ID: <CAPcyv4hPxoX1+u=fjzCeVYOd9Bck9d=A9SQ-mjzeMA2tf9B9dA@mail.gmail.com>
Subject: Re: [RESEND 1/7] mm/gup: Replace get_user_pages_longterm() with FOLL_LONGTERM
To: Ira Weiny <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, John Hubbard <jhubbard@nvidia.com>, 
	Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Peter Zijlstra <peterz@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	"David S. Miller" <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Rich Felker <dalias@libc.org>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Ralf Baechle <ralf@linux-mips.org>, 
	James Hogan <jhogan@kernel.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, 
	Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mips@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, 
	linux-rdma <linux-rdma@vger.kernel.org>, 
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 7:21 AM Ira Weiny <ira.weiny@intel.com> wrote:
[..]
> > > @@ -1268,10 +1246,14 @@ static long check_and_migrate_cma_pages(unsigned long start, long nr_pages,
> > >                                 putback_movable_pages(&cma_page_list);
> > >                 }
> > >                 /*
> > > -                * We did migrate all the pages, Try to get the page references again
> > > -                * migrating any new CMA pages which we failed to isolate earlier.
> > > +                * We did migrate all the pages, Try to get the page references
> > > +                * again migrating any new CMA pages which we failed to isolate
> > > +                * earlier.
> > >                  */
> > > -               nr_pages = get_user_pages(start, nr_pages, gup_flags, pages, vmas);
> > > +               nr_pages = __get_user_pages_locked(tsk, mm, start, nr_pages,
> > > +                                                  pages, vmas, NULL,
> > > +                                                  gup_flags);
> > > +
> >
> > Why did this need to change to __get_user_pages_locked?
>
> __get_uer_pages_locked() is now the "internal call" for get_user_pages.
>
> Technically it did not _have_ to change but there is no need to call
> get_user_pages() again because the FOLL_TOUCH flags is already set.  Also this
> call then matches the __get_user_pages_locked() which was called on the pages
> we migrated from.  Mostly this keeps the code "symmetrical" in that we called
> __get_user_pages_locked() on the pages we are migrating from and the same call
> on the pages we migrated to.
>
> While the change here looks funny I think the final code is better.

Agree, but I think that either needs to be noted in the changelog so
it's not a surprise, or moved to a follow-on cleanup patch.

