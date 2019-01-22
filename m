Return-Path: <SRS0=7n0b=P6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D93DC282C5
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 22:51:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23FD920870
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 22:51:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Mdh/az/u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23FD920870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68E368E0003; Tue, 22 Jan 2019 17:51:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63D358E0001; Tue, 22 Jan 2019 17:51:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 507B28E0003; Tue, 22 Jan 2019 17:51:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1EEEA8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 17:51:19 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id n50so291767qtb.9
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 14:51:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=o/XBYHY6SKkDwEIlSoffdYinDoT8V1LONeQ2d/odNaQ=;
        b=VOvtALhMbtVwjazN/e1PL1mhSaL29QpUdo+Q3xoP+FUS6V8ul84/cilLdxvv2Kzy07
         QttyGE+C5i9q4QReaPe4CuZye4BpaiiONDchl38rNuN2hhhJOiJI49OQoGvrSCROM5nm
         4AiAO9QxCcLr1kH5IGuVEc/dqqBp6HQM2i1cDVYkqRULE/qMUHWJx+OhwhlLedgEQdq9
         8KJZrv4IvCT4W/vWh6h2QfNJZ74fb/uspnHxDc39VdYSq8LeGhxysfzWPePs3PoO4xRp
         G8x4XNHEqhI4PeQ1gShLPTrp4slaoRFCsTbL6goH5s7DCy4CQIAvNAyNiBbGTqmWGEnD
         /tcw==
X-Gm-Message-State: AJcUukd6vzuB8rDQuJJeE5U4UPseZ7qWVIQFFWydOmulO+vTURNEw8D+
	lKXUAOK43G8sMUe0oZlEIGQzzO6u714MrKToWBonn7crb+pHTYd5rz+W82naOhDtTdkOOAbNeqC
	s3zKFRRhjXGNw+IoewhANp5hX4D7JI5U1J/CCwgP3TYCnIQgSsUolB1ZJHE0Z47DZ+WEksRlqAm
	UzO64OWDMc1h6b2JlESJV/fLuiQyyIxUdGcb/ThKne5CinDKABtxvPPfIn63mdvt5SOGo8NWGcM
	AA/VBXD4vOBQOwX2aTjkgB9012fl8DHVSbP53cvDpVO+1gNcd2rruvppWT64o+1HLqnk5fv/CQ8
	rAqQLNwpo+Bzx3BkzWkGEJNRMEqo9BIBpv91O0jDqlgr3WAjV16d6VJI8joa7a+o6F2tvxHvz6m
	5
X-Received: by 2002:ac8:2487:: with SMTP id s7mr32806657qts.116.1548197478881;
        Tue, 22 Jan 2019 14:51:18 -0800 (PST)
X-Received: by 2002:ac8:2487:: with SMTP id s7mr32806636qts.116.1548197478341;
        Tue, 22 Jan 2019 14:51:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548197478; cv=none;
        d=google.com; s=arc-20160816;
        b=QVjPPN4aro9xsyM03Tm66aA9b+7Y5zv47DjtSG3qZA+94rN9thb/mg52uagekXJuWG
         6EdWdA5ukEIpBZrI0vrGtEdmDjFN2hHSa3Z0GC6jnKnucO3AI/JhiRF9BEmFJgv1m+m2
         ZNGRlRjaUW6yqojQrY0yoNE6ObMhPLvahLhhb3xowbUhLW+gZCC+d+znTN/MqBSfJg21
         CoLeRVNGWgonEMHZBmAOQ4h6SLBLgszREg7zzwNMdMkXp4AsIMv2hp0/uNzeVjODC//M
         8ciPfFmHCZzEjhPedc6lsEvTwbp1xgo5CUoginbC6VrrSfNNWrpGf6CxTla+G6zm+uKG
         S4ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=o/XBYHY6SKkDwEIlSoffdYinDoT8V1LONeQ2d/odNaQ=;
        b=EEU0hjAjtJnWzoeHl3U1P2NJelYfACfAWXRS61s9M72Qxvw5gwtrVOZuYgMJHjfqCc
         lx4qHWzUct6GYBZxbgLFr4KGQRzZeNL6weouStAvMbLYMFzQD7QKbV3dAgKLDw6i9Qzn
         Ay0kelRsVTfpitXxU9cZOwfvzRsQE6X5sDwKrA8SIvaKh7bAwy+lYU/NEG9YK+jev52L
         GqGZsIxl650vyqlQ8RcOnxmi0vN9uA3B4+GazpR//RfNsnduH9Jtfw/mFdIwLYa6PF4Q
         MoBwq384Ki6O/cCrX5rP0LurkSfjhHHr9Tq2xn0Rb+d+8JSML2cfVTDfWDyh4/OYh5Dk
         3GYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="Mdh/az/u";
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p16sor114152754qtn.60.2019.01.22.14.51.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 Jan 2019 14:51:18 -0800 (PST)
Received-SPF: pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="Mdh/az/u";
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=o/XBYHY6SKkDwEIlSoffdYinDoT8V1LONeQ2d/odNaQ=;
        b=Mdh/az/ur8N3P0fSSYxO41aX78d92rObeQskl7lbc4hS9DeDf73UVzUUoQnLrUd0Bd
         Zatbb+NMZBOeS3NFGPdYahMoTBb07Iq5+kNvUVnquujE7C9y5uRKH0RP9h9mCLl90VY+
         XomJsnQMp5EEdrxsr8xxLlc1SHbxLsUMdNl0o=
X-Google-Smtp-Source: ALg8bN7Zt15oTdh/04iq08N8IN0vyYu7i10byl+0WgPF5QJSa0QzavTsyex2nrnJhE4cip6lVIqoJK0xipouBFaKmWQ=
X-Received: by 2002:ac8:6b18:: with SMTP id w24mr33380556qts.144.1548197477728;
 Tue, 22 Jan 2019 14:51:17 -0800 (PST)
MIME-Version: 1.0
References: <20181210011504.122604-1-drinkcat@chromium.org>
 <CANMq1KAmFKpcxi49wJyfP4N01A80B2d-2RGY2Wrwg0BvaFxAxg@mail.gmail.com> <20190111102155.in5rctq5krs4ewfi@8bytes.org>
In-Reply-To: <20190111102155.in5rctq5krs4ewfi@8bytes.org>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Wed, 23 Jan 2019 06:51:05 +0800
Message-ID:
 <CANMq1KCq7wEYXKLZGCZczZ_yQrmK=MkHbUXESKhHnx5G_CMNVg@mail.gmail.com>
Subject: Re: [PATCH v6 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page tables
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Will Deacon <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, 
	Mel Gorman <mgorman@techsingularity.net>, 
	Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, 
	lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, 
	Tomasz Figa <tfiga@google.com>, Yingjoe Chen <yingjoe.chen@mediatek.com>, hch@infradead.org, 
	Matthew Wilcox <willy@infradead.org>, Hsin-Yi Wang <hsinyi@chromium.org>, stable@vger.kernel.org, 
	Joerg Roedel <joro@8bytes.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190122225105.VeZdpNfdywguRJvcBCMpwNwG0HP4XBBiD5izEy3kwvI@z>

Hi Andrew,

On Fri, Jan 11, 2019 at 6:21 PM Joerg Roedel <joro@8bytes.org> wrote:
>
> On Wed, Jan 02, 2019 at 01:51:45PM +0800, Nicolas Boichat wrote:
> > Does anyone have any further comment on this series? If not, which
> > maintainer is going to pick this up? I assume Andrew Morton?
>
> Probably, yes. I don't like to carry the mm-changes in iommu-tree, so
> this should go through mm.

Gentle ping on this series, it seems like it's better if it goes
through your tree.

Series still applies cleanly on linux-next, but I'm happy to resend if
that helps.

Thanks!

> Regards,
>
>         Joerg

