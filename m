Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8DD0C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:58:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABB49208C3
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:58:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dfOb3Fvj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABB49208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 416686B0271; Tue,  6 Aug 2019 04:58:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C7326B0272; Tue,  6 Aug 2019 04:58:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28FE46B0273; Tue,  6 Aug 2019 04:58:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 029EC6B0271
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 04:58:00 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id d204so34163057oib.9
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 01:57:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=gE0o1u+Kp3vsV3cubSr1zZnXWybJYFzA8GFpX6alo2g=;
        b=PHHPfJQwydMqgJJvV9ukkiqKydS/6peBB3GMve4RBtzXThDn7YM+x7Q54+BO1GCgEY
         3GTyUBqnTAcgGlNZf3mnrwoNvEvSNzA+liS15XSLqG+lnFUdrtYDsMaGjhvVgLVbdGrB
         RSKQlzhoIq8OdFN7S0gsUFff6y56Eqg4p4Gje7UCVJG1eI5cFXL1xtiTwrznamXpHcg3
         9ORdwoRM2O8gLrhAyahLGgA0SAqWPSEVc1oQ8jzC1aQ1lf2/qPMxNQNscfih1jo7tq2Z
         LZa+uNew3J/kxPcID+1i8qTHqqGZwWOQt+7d9eff9+Nw9vLkkBtZ41/PupqS2rdmughh
         FhkQ==
X-Gm-Message-State: APjAAAWZ5XxMd9iFPyZI/tSXgKQN+bKpEyTVr8PfEI6VF7eqdCo8uU6l
	Dr1YGElwbJ0Lph8F6aZPHcSdKxUsV9HxNeOHa+GhFBvTtyAo/FudqPHYcfKfd+oAUpXqcKRJEy8
	ItGOg8nT39fyvLYg4T/C72R7R4G852DvQAUzW7SiLrNfbC076Ihz1OXy9hK5iDW0ttw==
X-Received: by 2002:a05:6602:c7:: with SMTP id z7mr2594707ioe.130.1565081879615;
        Tue, 06 Aug 2019 01:57:59 -0700 (PDT)
X-Received: by 2002:a05:6602:c7:: with SMTP id z7mr2594676ioe.130.1565081879067;
        Tue, 06 Aug 2019 01:57:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565081879; cv=none;
        d=google.com; s=arc-20160816;
        b=OewF+UZ1ZfeK+uOGqZ97XMxBnjY6gu7VLjS9T9YmXIZFu1kfOAa6gn+7t++t74NAo/
         ZA9FwPQ4RVc6ZnLD9flxCfQsErGliAUR0WbzSL7PhsUQtLltKTT0vnSWK+E4fLhV+pf6
         ghXe/AxRn0ZqQD7vyfbsHGFtSjFzXd64kw9mIUZtndbj/rm+uX0B+xnZOK2Xbc3LNqaC
         DGlxh5Kt5aQcu5iDsqnwb2SUkeE4M60g0V76B+3E8d2Z4sNS0ni1bzMP8uxqjUNO4hsP
         hrbMLSxNQ6KJKWfuT6i2in1zFSkqWbYa2jKYjjgmlMO0uW7aiqH2mlmu0BygC/orvZ/B
         wUHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=gE0o1u+Kp3vsV3cubSr1zZnXWybJYFzA8GFpX6alo2g=;
        b=tdwfnwiW4v+Z5/ViyyItfw6525b2XauQPBfL7AiYE+kRivm56M1yYGf3H6pRjg7drY
         GCtY1KTCAEapGCmYLIN5cuRSB8il6k63n71IAFdaU/oJ9010549SQjbzZq7NFbbE/ryN
         noSC4YmvgYs940qO0Z5rDgIPut/Ln5ai6WH8pyX0IaQcPvrqI510uCWetojJawBMU8pF
         VSDna1uBYYENv/IE6C50EEtjZFnxpskd1l3OnWxa2bXv3YmuvBdOHZvhJSzgUI7dGaWr
         MAW7DJvAApMAm0N1PqhMQpYPvvblFs4Fs1OVIv0cqj2giQMgKfpylD+A2Cm/eOjnlYis
         l39A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dfOb3Fvj;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x12sor58373577iom.3.2019.08.06.01.57.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 01:57:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dfOb3Fvj;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gE0o1u+Kp3vsV3cubSr1zZnXWybJYFzA8GFpX6alo2g=;
        b=dfOb3Fvjjkm059hxUGPKs9bxGY6uhwu7/RFqrA46WGAw+/aDVq0VBC+EutdH9jCUOk
         OYGWdgHinGykJCe9C8+peda3Fp1hpfey9SdZ2sZXABrhnElJYH1flwyaSCQwU2GsXIgY
         j2RnJeGDK0NG5pbt8wr8jv7BsdRkPNZ1ZkiRcitKabQR6wgFwb8ngL1+jOe6yp5odEso
         S7hDwkH5W2tsHyxCeBngCPYU2yqcbXeoGdzzgiFuceJxf1a/K39cJXgBSidAyFc2fbCG
         6uJtOZConUW7JqauzekxIoMxc/HwIda1dXIeXd8OD2RXiwLwqza0NggupV2QUMbnfrW7
         g+CQ==
X-Google-Smtp-Source: APXvYqziPeGcB5LCSD+BGdmedq44yvaZbzyjSzgxslV3Q3XyVq172HDFOAoMXjQs929XN2SDXhtvtWbAhqiYpyLzB6U=
X-Received: by 2002:a02:c519:: with SMTP id s25mr2991620jam.11.1565081878798;
 Tue, 06 Aug 2019 01:57:58 -0700 (PDT)
MIME-Version: 1.0
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
 <20190806073525.GC11812@dhcp22.suse.cz> <20190806074137.GE11812@dhcp22.suse.cz>
In-Reply-To: <20190806074137.GE11812@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 6 Aug 2019 16:57:22 +0800
Message-ID: <CALOAHbBNV9BNmGhnV-HXOdx9QfArLHqBHsBe0cm-gxsGVSoenw@mail.gmail.com>
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Daniel Jordan <daniel.m.jordan@oracle.com>, Mel Gorman <mgorman@techsingularity.net>, 
	Christoph Lameter <cl@linux.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 6, 2019 at 3:41 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 06-08-19 09:35:25, Michal Hocko wrote:
> > On Tue 06-08-19 03:19:00, Yafang Shao wrote:
> > > In the node reclaim, may_shrinkslab is 0 by default,
> > > hence shrink_slab will never be performed in it.
> > > While shrik_slab should be performed if the relcaimable slab is over
> > > min slab limit.
> > >
> > > Add scan_control::no_pagecache so shrink_node can decide to reclaim page
> > > cache, slab, or both as dictated by min_unmapped_pages and min_slab_pages.
> > > shrink_node will do at least one of the two because otherwise node_reclaim
> > > returns early.
> > >
> > > __node_reclaim can detect when enough slab has been reclaimed because
> > > sc.reclaim_state.reclaimed_slab will tell us how many pages are
> > > reclaimed in shrink slab.
> > >
> > > This issue is very easy to produce, first you continuously cat a random
> > > non-exist file to produce more and more dentry, then you read big file
> > > to produce page cache. And finally you will find that the denty will
> > > never be shrunk in node reclaim (they can only be shrunk in kswapd until
> > > the watermark is reached).
> > >
> > > Regarding vm.zone_reclaim_mode, we always set it to zero to disable node
> > > reclaim. Someone may prefer to enable it if their different workloads work
> > > on different nodes.
> >
> > Considering that this is a long term behavior of a rarely used node
> > reclaim I would rather not touch it unless some _real_ workload suffers
> > from this behavior. Or is there any reason to fix this even though there
> > is no evidence of real workloads suffering from the current behavior?
>
> I have only now noticed that you have added
> Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external fragmentation event occurs")
>
> could you be more specific how that commit introduced a bug in the node
> reclaim? It has introduced may_shrink_slab but the direct reclaim seems
> to set it to 1.

As you said, the direct reclaim path set it to 1, but the
__node_reclaim() forgot to process may_shrink_slab.

Thanks
Yafang

