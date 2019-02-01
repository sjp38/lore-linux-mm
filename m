Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9D89C282DA
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 12:38:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6906C20863
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 12:38:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GQmlKMug"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6906C20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0098D8E0002; Fri,  1 Feb 2019 07:38:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED4D48E0001; Fri,  1 Feb 2019 07:38:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4DFB8E0002; Fri,  1 Feb 2019 07:38:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5D8B88E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 07:38:18 -0500 (EST)
Received: by mail-lf1-f70.google.com with SMTP id d6so1113236lfk.1
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 04:38:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=FA5f7YY6n6QegB8E6sgW5d/K980UEuX80JV8baCFznE=;
        b=RUd7igr5Y2g7bEtrb9I3z67XaPIqZDmwgJ9qEo75XKiNOC/EG2KhRIOk6y8wjHZJqi
         CaXldRdJk+GPwAdDYk/RIJVrkV4jcLJHZgaTk2dVrOZYuAFYxJLvg5qUW71Yg90UHW3M
         JpJCe8lJSTWlCj0eDoyMoDl2nkXsDI+lt+YnCcsNNCu94uclrZsFlJ9hWYt54dKcatle
         dtGU7TtJSW8OQZsGAY6F3Y58gOQE2OCvynfrYKPDwTPl2HvDJYTl+imHzGRnLHk3QM3R
         NvKgfQlvIbzN7pX3FSq85WbbKsuRkudTNlhF04Ch7C/Pbo8xItKlS6SH+Lgpxke5FXbv
         DozQ==
X-Gm-Message-State: AHQUAuZS2TJtNMPxKKDiBE4uw/MG1uBXuph1u/ERdZVj1s3Y/2ErB9/j
	SKcuA5o5KUrWtXRwSsd04KVqzKQrZjkRgFq8lRd84H1YQszWVMtOTrwnuyHQJYsOBfpF7Vk8trm
	JymRc9syvgzdWxq+KsX9KRDEwzpvxOW8eJfWvXlRTSR05UKLGxSWgyKyuSNbZYxpX+lcJ7Lpuq/
	FUYm/K3+lvqfjrQkKyK0omOdyWk5RmF+7hKyUxmX9bYiqpYF9rG8InGbTrcpDOBufq+Q7KaZkbR
	JnKEcPzuOHaLYwrcAdOgXPe3W0Aftj5FfjIab4rOpa9vf623njAde23K0iR08xlRoQV28j0HxdJ
	mkZM+PhcsDjO3LKaXNDItSo4UpDnfqUgFOU2x/hoM+OCyTQnq5qq7VDp00LjHeSd955LQj4P86o
	4
X-Received: by 2002:ac2:533a:: with SMTP id f26mr448179lfh.40.1549024697545;
        Fri, 01 Feb 2019 04:38:17 -0800 (PST)
X-Received: by 2002:ac2:533a:: with SMTP id f26mr448129lfh.40.1549024696433;
        Fri, 01 Feb 2019 04:38:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549024696; cv=none;
        d=google.com; s=arc-20160816;
        b=LM9SgSUHDbz7mh7LygG2mJ891aCtTmM4dSqhL/3W7pzAwQwzH6jPalg1VjkBGkDi0t
         a4Wo/KEjHVqLUtVWpKHhz79qtnGAzO9Qdt3K9aE8TunQp7bmFGOlaPDE+sB24QQeuq9C
         /FO4/3EvS/KXMn8nY1wTuDZLylX7pTeiNekm2XJYMgdGmSc/+JoUZ+39gyG7xAAYQsBE
         ztwQGimmaYzGYf0U0gj2lOU51lKd7ajmJLUTTo/pWaTRDo1henmeRPxZ0XptH/YfXXZK
         cEUfnc9BlZ8a9tfYGhOLdXL8FY1ZwQnqGB82s9Upinsxukyda3TZeZtHATVCslHi9DYm
         oztA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=FA5f7YY6n6QegB8E6sgW5d/K980UEuX80JV8baCFznE=;
        b=XLgNST9tkwxpTsQ8k/56I20q18KsKfia6fQmOxqwROJpigIbetoaT7IeeFtSNwBUwZ
         JTyxmOtt5aTJ1T2ZkDw7sHngr4kzqxwl92QbFIthNXGa/kRX4GVsMSF5G8l0mLUxnIhk
         lzRoXuT4w5HpNwIuHfQO0CB5xIIGKLRvnxh3MTT1m5fTYYew1tSl5EVIvCqdpLHyiGps
         gFdkCNY8CkJfBcGHFXWfi70nTQL70932YV7IdObINdmigJBUX//BFt3EajN0joNT8lcw
         3ooERoUbhKKFW3XbBJy0i0FvOM/IHqsIU6Fv5X8FnDiYb3Z5mmO8V1jApetiWtXnKN7P
         dLIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GQmlKMug;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k4-v6sor5365636ljc.11.2019.02.01.04.38.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Feb 2019 04:38:16 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GQmlKMug;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=FA5f7YY6n6QegB8E6sgW5d/K980UEuX80JV8baCFznE=;
        b=GQmlKMugZ3bwsuMyb/P7aK4QpswXwaapZ4DsT1fvEZI+8XD1CmbdiMhQQwRT/xvM41
         FyfIcL0N8bcp4jvn7Rwk4vJw0vHXWdS7oie1el+Hqn231IBHDAw6eD5+PSU6PWH0Kbrr
         wm+pUxdv5ycyzateCY5dPVP85pDjE5NPJhuXBBI7CzvL35940bts/64hf3iffhDjUWvh
         aAfcvwWtLCX3818splV9Mc9NtipwQGWQLvOX+l8X2NO6NQvDm+wMZsoF4pTdPcv7ZRCS
         kdZcReWw7MN1tXv1r24u+YCF2/21n4WrFhEUHRDayakh1YVkONA2gIIQdAHiNaJw54K/
         eeLA==
X-Google-Smtp-Source: ALg8bN63OQuN/I7+5c4lLuO9nn/Jxyf+w53AUJkRrvBxfuBKIIADHNYPuQlrqZkogRtB1XtcmnGCFBz+O8XMsDRzXzM=
X-Received: by 2002:a2e:9849:: with SMTP id e9-v6mr31185303ljj.9.1549024695704;
 Fri, 01 Feb 2019 04:38:15 -0800 (PST)
MIME-Version: 1.0
References: <20190131030812.GA2174@jordon-HP-15-Notebook-PC>
 <1701923.z6LKAITQJA@phil> <CAFqt6zbxyMB3VCzbWo1rPdfKXLVTNx+RY0=guD5CRxD37gJzsA@mail.gmail.com>
 <1572595.mVW1PIlZyR@phil>
In-Reply-To: <1572595.mVW1PIlZyR@phil>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 1 Feb 2019 18:08:04 +0530
Message-ID: <CAFqt6zbMHG3htSsOwV3SaEEp1rMbFCoDD_3EacDk1hw_a1HJeQ@mail.gmail.com>
Subject: Re: [PATCHv2 1/9] mm: Introduce new vm_insert_range and
 vm_insert_range_buggy API
To: Heiko Stuebner <heiko@sntech.de>
Cc: hjc@rock-chips.com, Andrew Morton <akpm@linux-foundation.org>, 
	Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, 
	Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, 
	Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, 
	airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, 
	pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, 
	Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, 
	linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, 
	linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, 
	dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, 
	xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, 
	linux-media@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 6:04 PM Heiko Stuebner <heiko@sntech.de> wrote:
>
> Am Donnerstag, 31. Januar 2019, 13:31:52 CET schrieb Souptick Joarder:
> > On Thu, Jan 31, 2019 at 5:37 PM Heiko Stuebner <heiko@sntech.de> wrote:
> > >
> > > Am Donnerstag, 31. Januar 2019, 04:08:12 CET schrieb Souptick Joarder:
> > > > Previouly drivers have their own way of mapping range of
> > > > kernel pages/memory into user vma and this was done by
> > > > invoking vm_insert_page() within a loop.
> > > >
> > > > As this pattern is common across different drivers, it can
> > > > be generalized by creating new functions and use it across
> > > > the drivers.
> > > >
> > > > vm_insert_range() is the API which could be used to mapped
> > > > kernel memory/pages in drivers which has considered vm_pgoff
> > > >
> > > > vm_insert_range_buggy() is the API which could be used to map
> > > > range of kernel memory/pages in drivers which has not considered
> > > > vm_pgoff. vm_pgoff is passed default as 0 for those drivers.
> > > >
> > > > We _could_ then at a later "fix" these drivers which are using
> > > > vm_insert_range_buggy() to behave according to the normal vm_pgoff
> > > > offsetting simply by removing the _buggy suffix on the function
> > > > name and if that causes regressions, it gives us an easy way to revert.
> > > >
> > > > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > > > Suggested-by: Russell King <linux@armlinux.org.uk>
> > > > Suggested-by: Matthew Wilcox <willy@infradead.org>
> > >
> > > hmm, I'm missing a changelog here between v1 and v2.
> > > Nevertheless I managed to test v1 on Rockchip hardware
> > > and display is still working, including talking to Lima via prime.
> > >
> > > So if there aren't any big changes for v2, on Rockchip
> > > Tested-by: Heiko Stuebner <heiko@sntech.de>
> >
> > Change log is available in [0/9].
> > Patch [1/9] & [4/9] have no changes between v1 -> v2.
>
> I never seem to get your cover-letters, so didn't see that, sorry.

I added you in sender list for all cover-letters but it didn't reach
your inbox :-)
Thanks for reviewing and validating the patch.

>
> But great that there weren't changes then :-)
>
> Heiko
>
>

