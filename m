Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB177C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:15:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8919820B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:15:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EjeDTuoK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8919820B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0878D6B0277; Tue,  6 Aug 2019 05:15:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 037EA6B0278; Tue,  6 Aug 2019 05:15:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E42AA6B0279; Tue,  6 Aug 2019 05:15:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC0D96B0277
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 05:15:42 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id x18so48662578otp.9
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 02:15:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Qt170Z0ZGX5pHCUBjbuaUEH0l38liAo84NzoTO4OrCA=;
        b=CxHHdpa3M8/OtF6Q8fTM/zWYNDxSB9BBU9UgGL5PtFHUf8A2QZUOarZ/A8IibWKaae
         U5ci7x+SVY50bhfgmu8CvaoU7BV9qJF7m/n8/aVPcFRa+2R0S9YRBEhAmi6FV0nAbklU
         zDBbv7J/7K/yKmp3QlfxRmtA3x53wufkttr1BPCVL1n1HbQKLjh+y2Of8OjJOI44W8jl
         AXppULOmEnhFjKS+7MlZ0NzTJvnCm4tjgHl+cKqkhhqa6NePt+RKAAuLRFD4Ml5ONIMU
         2oZa9y62V6Vy8Co8IlXnlayywP/nO4neKsrlLdJ1heT+6yDJHID3jLoOZtQLy7XoBnvF
         6iDw==
X-Gm-Message-State: APjAAAWZO8E3B/0Ww9S2SJ5sLhMNVJnjQmxM9q2Fo5AkhJECqiShcSps
	TKMtG12fBlyFOgIK9+CZ5/QEUhrZ+AYMsUuOJ9FUQM659j1svrHDapi8bt19nPH3GnxdUC8UpAO
	zWX04b7kuLN6oo2XelUt41LczVYvGfclBHibiRfOTZ0zHiumFaprvjT33MbzkIhNYcg==
X-Received: by 2002:a02:7f15:: with SMTP id r21mr3126548jac.120.1565082942198;
        Tue, 06 Aug 2019 02:15:42 -0700 (PDT)
X-Received: by 2002:a02:7f15:: with SMTP id r21mr3126493jac.120.1565082941389;
        Tue, 06 Aug 2019 02:15:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565082941; cv=none;
        d=google.com; s=arc-20160816;
        b=xGVjTyPI4ry5ElWeab+acwxWrmQhI3KjBB+DLcOcNojXKCrJXdNS7unVQ+LQWrXaL9
         6TBzhGoFQ8h31OBfUfz3ib2IkRpy8n5I5R+jXC5Az5MgmRhEP8y3zy79pUIRp3M6CQeJ
         SRCRIDrd1S5z3qIGUgA5vMTbSi7i43J3rGWn28o6fDcv/rUYsEWmLGCQSFTD1E/OxhCd
         UXE2hveddAjePhbBrGLRiRoaF5wnvMTio/LkeE/xRyBqb6ZgoWu8b2L+zkCGLdWSUMpN
         2tZcTm0itBiSKQO7KBVCOKmYIItccylk7cGvq+HOEnif3okAnY7UCD+4K8eJS23s6uoj
         LNIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Qt170Z0ZGX5pHCUBjbuaUEH0l38liAo84NzoTO4OrCA=;
        b=j8aMmdHOXMxbHi4rD4eb1ZpTPIj/u8HI999XKej/ND/6ktojnHv/eY/0xrj+d2uNAW
         4pXgee8XSrslAn2N6QSDueJkQ2E4k9BjWFQp9a1bM/+iMxHuKeqK0Zs8VP3OK5sV/ATr
         /Yl4Tu2YmxKoHn30GLd1P2+Gd4xGRJp7ITt/pKZEyuwbYf5xCes/LEwtfu6ZVUT4fcij
         FRdHVHpFDM3QGjVoObtHP01I0OVOvryIYZrZygxSKL3HLQT7cKpmShDRGDKoXGv5mGPn
         dsg3brqXyzCvp+pHNRoD/PjuHZlO2iIp9HsSbSmNCMrKjchFuYwrY3NEm42ypoR3ebSD
         7nwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EjeDTuoK;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q5sor14567346ioq.99.2019.08.06.02.15.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 02:15:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EjeDTuoK;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Qt170Z0ZGX5pHCUBjbuaUEH0l38liAo84NzoTO4OrCA=;
        b=EjeDTuoKIUk4tu/xlVDKi62mMgcFc0+rX/IkAA/Vlfmyvkwl9+CheFCKaLaz1vsgIK
         FrkGw4+rJO+Bh7tjJACkaOVTQmyjw+lDbMBRwaJjrH6qpBnbuYX+fevgWA+YzMzaCQMR
         ta7MCcvvolF03Dy7GfUHWbLQ0Q9iTXK+yPWSI5WqJd+2koNuIanDP88ig3NcvRfkp1Oh
         /p6ZNOqJK6Tk7lpbO6pTVJP2otaDTXs4A6diY6nXcISra9YG/a5ieh1TqW8tUgykQGwD
         zkz55e+SXee4RfL0GLx994rW9QTYA9RCDk3jdYa0NGzBTrnqcsNmshbFuhFBY1YdMRui
         5I9w==
X-Google-Smtp-Source: APXvYqyjTqYQy6/PxMq02AIu8eFPY2s+f57lXs8eQrjKVYBUf1xnrwK6UMe17NJfCUl9zwiTNSuS21XnD59flVZT8bI=
X-Received: by 2002:a5d:915a:: with SMTP id y26mr2567809ioq.207.1565082941167;
 Tue, 06 Aug 2019 02:15:41 -0700 (PDT)
MIME-Version: 1.0
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
 <20190806073525.GC11812@dhcp22.suse.cz> <20190806074137.GE11812@dhcp22.suse.cz>
 <CALOAHbBNV9BNmGhnV-HXOdx9QfArLHqBHsBe0cm-gxsGVSoenw@mail.gmail.com> <20190806090516.GM11812@dhcp22.suse.cz>
In-Reply-To: <20190806090516.GM11812@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 6 Aug 2019 17:15:05 +0800
Message-ID: <CALOAHbDO5qmqKt8YmCkTPhh+m34RA+ahgYVgiLx1RSOJ-gM4Dw@mail.gmail.com>
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

On Tue, Aug 6, 2019 at 5:05 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 06-08-19 16:57:22, Yafang Shao wrote:
> > On Tue, Aug 6, 2019 at 3:41 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Tue 06-08-19 09:35:25, Michal Hocko wrote:
> > > > On Tue 06-08-19 03:19:00, Yafang Shao wrote:
> > > > > In the node reclaim, may_shrinkslab is 0 by default,
> > > > > hence shrink_slab will never be performed in it.
> > > > > While shrik_slab should be performed if the relcaimable slab is over
> > > > > min slab limit.
> > > > >
> > > > > Add scan_control::no_pagecache so shrink_node can decide to reclaim page
> > > > > cache, slab, or both as dictated by min_unmapped_pages and min_slab_pages.
> > > > > shrink_node will do at least one of the two because otherwise node_reclaim
> > > > > returns early.
> > > > >
> > > > > __node_reclaim can detect when enough slab has been reclaimed because
> > > > > sc.reclaim_state.reclaimed_slab will tell us how many pages are
> > > > > reclaimed in shrink slab.
> > > > >
> > > > > This issue is very easy to produce, first you continuously cat a random
> > > > > non-exist file to produce more and more dentry, then you read big file
> > > > > to produce page cache. And finally you will find that the denty will
> > > > > never be shrunk in node reclaim (they can only be shrunk in kswapd until
> > > > > the watermark is reached).
> > > > >
> > > > > Regarding vm.zone_reclaim_mode, we always set it to zero to disable node
> > > > > reclaim. Someone may prefer to enable it if their different workloads work
> > > > > on different nodes.
> > > >
> > > > Considering that this is a long term behavior of a rarely used node
> > > > reclaim I would rather not touch it unless some _real_ workload suffers
> > > > from this behavior. Or is there any reason to fix this even though there
> > > > is no evidence of real workloads suffering from the current behavior?
> > >
> > > I have only now noticed that you have added
> > > Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external fragmentation event occurs")
> > >
> > > could you be more specific how that commit introduced a bug in the node
> > > reclaim? It has introduced may_shrink_slab but the direct reclaim seems
> > > to set it to 1.
> >
> > As you said, the direct reclaim path set it to 1, but the
> > __node_reclaim() forgot to process may_shrink_slab.
>
> OK, I am blind obviously. Sorry about that. Anyway, why cannot we simply
> get back to the original behavior by setting may_shrink_slab in that
> path as well?

You mean do it as the commit 0ff38490c836 did  before ?
I haven't check in which commit the shrink_slab() is removed from
__node_reclaim().
But I think introduce a flag can make it more robust, otherwise we
have to modify shrink_node() and there will be more changes.

Thanks
Yafang

