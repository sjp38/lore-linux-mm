Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8FA6C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:18:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8145D217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:18:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="PLyL6gIP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8145D217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B2336B0003; Tue, 19 Mar 2019 20:18:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1613F6B0006; Tue, 19 Mar 2019 20:18:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 027C46B0007; Tue, 19 Mar 2019 20:18:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id C8FA36B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 20:18:04 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id 35so666645qty.12
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:18:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=61guGX+RCOxqlNVmjmOxyrOINzQAxJ4tq4R2MDhbZPI=;
        b=Ob6rwuVtER2erLHEdNoBcM3VvJfVsxYUddXifkfwRV7loRpn0nDmbR7lB17J9kxE5v
         k7s8g+BdS297bitEkPkL1DTUpm/dvQo30Gy3Uxcq0WhQF/iDoVnc+czynqVVEddP1ibG
         FsuOCu5pcnG8nR04BfwTEys3vmXdf2ulvOX8psRi3ZBK4NjpU4X3tjl4H2NGhbQbdffn
         /YNa7HOSnSQ1cDlwimidPnWUXH4dn1vIekaVlLXzsYIagd667+pK8lcCu0bvZ4e0W7ym
         6gs925SmQWSavmIK9cRTmzvB7gmXcFFFA8qycdhbv/5iczjiNafMLErHnu48r0SzHR1O
         J/Ow==
X-Gm-Message-State: APjAAAVQG0SsDEVuRbRJGqz0fHHH04YTQEaEkDFze2mclYnaMsQEonab
	8lYk1AyeY+Mu62sLSZGcBBMj//ap09lLwi9iTHsY9hIA2oHJIUvtA+WalMkbrPMoEEhCNyAOShz
	/TsfNTARIzWPNDbIzRrt3FoOgt5UO8SoM0BOUoHkAXaJJGL0cSNuskC8gdkp7oWsweA==
X-Received: by 2002:aed:3f50:: with SMTP id q16mr4338452qtf.237.1553041084601;
        Tue, 19 Mar 2019 17:18:04 -0700 (PDT)
X-Received: by 2002:aed:3f50:: with SMTP id q16mr4338421qtf.237.1553041083941;
        Tue, 19 Mar 2019 17:18:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553041083; cv=none;
        d=google.com; s=arc-20160816;
        b=aqTPEKTrBiTKK4yXbo9LagLC5zrsq1MLv69D8Sv9V5wkibn4zh04Zr3fS0fcxy3Ap6
         pF+1nPRFmUbdFeyLZs6pVd3nSkvSMEixOvjjxfB06TmGUbXl+4RmD6WM9UWmkcpA8fL1
         JHR3Jeui5PTP9AWXPMt9RqARX95nnH1s5bIsKKN49+XBGJ35N90KDUI4FaKuR5gI5u7x
         mqiftnKuuD03WON1pxBsYexoidxKfybBI6iWK4DgZ4K0YeDrBRg0YyIEwS8rGxQ7m/p7
         7tfSbvlEPSts7rXaw9wkHLfRhyA5Y2I5IdzJ5mE2NMGM9AKayBvNuszo1qIqplSsu4TW
         b7kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=61guGX+RCOxqlNVmjmOxyrOINzQAxJ4tq4R2MDhbZPI=;
        b=vUcYzdVuYqVr2qDmSIh9nRm8Dj4t5xGU36iKSrVik/A/AkkSpUDQUpGQRKAQwzX6wW
         pmUG9+wYskxB7TLnBvJB5StS9CG/BYBWJUSvnIT+LG9UC9VVj60sZaPMQvmLXLTgCHIa
         kdv6GXQoEySsQyPoCgSsom1m/JF90esQQxx4f0hI8MyKrN2KhUjGOEmm1ghljEKcgLkT
         R359fKKiOZHzslKBkG1G92aPAUps9M1uHR/GeOujnlNjbFfz0L+9iA8o1zDApetesW9D
         LAJRpQcWLpO1cOCE6MbmFZPDDia6hcXwfz6Ulpwe5vOOogQnHRdTCIpMcjSNx+a25Yip
         PKjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=PLyL6gIP;
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 7sor376476qvd.55.2019.03.19.17.18.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 17:18:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=PLyL6gIP;
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=61guGX+RCOxqlNVmjmOxyrOINzQAxJ4tq4R2MDhbZPI=;
        b=PLyL6gIPvRDdEvovwInmmo73mvwHtNFkX5jFbIKyw3sYZGOdBS29B0PgM26Bi9l+Zy
         1hzKaEV0ucbNB9DZzSowftXVX8kt9lNVKwQ3wUh+nqcfKeAEiOS15EsT7dxsXtJtRohu
         zER+SnoUAul3YFgOndVNbdAY3uwMjhQohswvA=
X-Google-Smtp-Source: APXvYqzq6P7dJ2VLlMed8i4RrtPCj0WODYKQg9LkBpDyuV0F50P/wdTbX71M7hQ46N2WOc9JRrmy7Mk7c2CAX1Mv+mQ=
X-Received: by 2002:a0c:9319:: with SMTP id d25mr4099941qvd.99.1553041083440;
 Tue, 19 Mar 2019 17:18:03 -0700 (PDT)
MIME-Version: 1.0
References: <20190319183751.rWqkf%akpm@linux-foundation.org> <20190319191721.GC30433@dhcp22.suse.cz>
In-Reply-To: <20190319191721.GC30433@dhcp22.suse.cz>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Wed, 20 Mar 2019 08:17:52 +0800
Message-ID: <CANMq1KAoya365L9+iGD7Uu34r_9zbbRjSHjB7L_8vi=avTtLnQ@mail.gmail.com>
Subject: Re: + mm-add-sys-kernel-slab-cache-cache_dma32.patch added to -mm tree
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, mm-commits@vger.kernel.org, 
	Yong Wu <yong.wu@mediatek.com>, Yingjoe Chen <yingjoe.chen@mediatek.com>, 
	Huaisheng Ye <yehs1@lenovo.com>, Matthew Wilcox <willy@infradead.org>, 
	Will Deacon <will.deacon@arm.com>, Vlastimil Babka <vbabka@suse.cz>, Tomasz Figa <tfiga@google.com>, 
	stable@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Robin Murphy <robin.murphy@arm.com>, David Rientjes <rientjes@google.com>, 
	Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, 
	Matthias Brugger <matthias.bgg@gmail.com>, Joerg Roedel <joro@8bytes.org>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hsin-Yi Wang <hsinyi@chromium.org>, hch@infradead.org, 
	Christoph Lameter <cl@linux.com>, Levin Alexander <Alexander.Levin@microsoft.com>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 3:18 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 19-03-19 11:37:51, Andrew Morton wrote:
> > From: Nicolas Boichat <drinkcat@chromium.org>
> > Subject: mm: add /sys/kernel/slab/cache/cache_dma32
> >
> > A previous patch in this series adds support for SLAB_CACHE_DMA32 kmem
> > caches.  This adds the corresponding /sys/kernel/slab/cache/cache_dma32
> > entries, and fixes slabinfo tool.
>
> I believe I have asked and didn't get a satisfactory answer before IIRC. Who
> is going to consume this information?

No answer from me, but as a reminder, I added this note on the patch
(https://patchwork.kernel.org/patch/10720491/):
"""
There were different opinions on whether this sysfs entry should
be added, so I'll leave it up to the mm/slub maintainers to decide
whether they want to pick this up, or drop it.
"""

> --
> Michal Hocko
> SUSE Labs

