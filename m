Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BEF3C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 04:21:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 245FB20879
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 04:21:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 245FB20879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD2126B0275; Mon,  8 Apr 2019 00:21:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA88F6B0276; Mon,  8 Apr 2019 00:21:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BE4D6B0277; Mon,  8 Apr 2019 00:21:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7171C6B0275
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 00:21:11 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id e185so5092782oib.18
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 21:21:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=tILU93jPluV8AQsh1jvaP7I5f8WGs+HjCHykl3kw2tg=;
        b=B9H/lakEIH25nd5Ud/efCm8/7pscqpqKQu4NHGP+q1arNJNFmfVt/zYQxSxwFQ7lOt
         QCfwGqy5iqQKUUWf5Sm9d9bJNfnHKY8xbsfWSETKvgf/gf4xFmIIPQHqC1Kn4G72nQVi
         imBu6WubG3zI03STV9lScVJwy1Uuy5ozlhf/BNoBBgCk3qzr5IzAoAUfWYdHMbtZF9U7
         lsfctjo9WJFDRYy0DM0mqoRJFdR2hXUWsMuX9TfuDs8QadeTgdetEEgZSea51bEIy1N2
         nKbt0yeTC9FwnzSu/4ZsbpLs+JhKzoVEa5Wy32S5qt8GnyJ88FYXn1tnvaJ3Sl60sEuz
         VfVw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=fanglinxu@huawei.com
X-Gm-Message-State: APjAAAUYkAK6U0z7Zf77giOib/KWyFdnCaKsmMrPKu+E3M9y6O9nFYHM
	GTuADVhwOMqi9qeJQEfIifrjWCphMLSH1m9E+X9z5bnbmd5G8kz8G+PiE487boel7oobb4U4orR
	Sj9tZJXAZ9bp748bNT3LPnyCkajy2mdl84JgEiF9HvLoYADtexXycso74IHr242xUaQ==
X-Received: by 2002:aca:da43:: with SMTP id r64mr14511472oig.11.1554697271094;
        Sun, 07 Apr 2019 21:21:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwESmc/7aD3iDlG2f1cR2eCmqaUa6st2VRiBsRqHAht+RlMz6UCX9MYxbztmTzodTN3PYX2
X-Received: by 2002:aca:da43:: with SMTP id r64mr14511448oig.11.1554697270252;
        Sun, 07 Apr 2019 21:21:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554697270; cv=none;
        d=google.com; s=arc-20160816;
        b=Yt9fX9nXm0ORCQ+Fp8LS0i8iZT4CTpnwoUV3wjgHiEJQwhr7s6VOVkFRnkzM3VpdK6
         a96ZWusBI0242FCKOXPJ5Tz0WQikUtn41KZIKDhtbVE3UYmSmljLNOjHwsa8MLxmiakr
         qdbV1jbAOTVFlu60vJxb2QBa9bqN56m30z/tQirXVo/Q8XJjcGizdwKVX7o4Qj253EyO
         SzjkgFngFLcvIm3isnh3v/uaRGaXefMKY6Mct7to5LPDeyxfq01++Kyw0EwaMRdFpn+v
         X0Vhueebji5pZWfiSnaj0CtRYZ/Sv98OaeujaeHRmiv9o2Wext3t81iQGRKn8dYvE3Y9
         BrhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=tILU93jPluV8AQsh1jvaP7I5f8WGs+HjCHykl3kw2tg=;
        b=WF+n8SrQdbdXMtxEq18dSyp6VMjN3s6v2/Ph72J8uyz0L7qfnPxQC4O7350xTAl6BD
         wHM3bpaiguKWCK0h/miR4GbD4coIIkdHoSRue5td8rqHAYTDVB+Jd4SeWtMCNRl4jL8d
         TIFlRSS6v4FkKAaFjsttWbnHWQeKfNHQF9zguMSpKxE2Fav0NLYfqOey985ZJetxVNJz
         mex+k3Pac87LyhUm7s/eHtYVEcze1uFIuKFZjfITnEbuVuq+nag6rFDU/iZ301uP3EMl
         zMwotbPH+OUBjYW5M/Q3hZjtYLaUclOSDwh03NuSpcvU0bPvrVYF4/wpQCXduIuChpms
         vUyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=fanglinxu@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id g7si14311844otk.143.2019.04.07.21.21.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 21:21:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=fanglinxu@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id A7A9355B5584F68B9ED1;
	Mon,  8 Apr 2019 12:21:04 +0800 (CST)
Received: from huawei.com (10.66.68.70) by DGGEMS402-HUB.china.huawei.com
 (10.3.19.202) with Microsoft SMTP Server id 14.3.408.0; Mon, 8 Apr 2019
 12:20:55 +0800
From: Linxu Fang <fanglinxu@huawei.com>
To: <osalvador@suse.de>
CC: <akpm@linux-foundation.org>, <fanglinxu@huawei.com>, <linux-mm@kvack.org>,
	<mhocko@suse.com>, <pavel.tatashin@microsoft.com>, <vbabka@suse.cz>
Subject: Re: [PATCH V2] mm: fix node spanned pages when we have a node with only zone_movable
Date: Mon, 8 Apr 2019 12:18:48 +0800
Message-ID: <1554697128-17696-1-git-send-email-fanglinxu@huawei.com>
X-Mailer: git-send-email 2.8.1.windows.1
In-Reply-To: <20190405125430.vawudxjcxhbarseg@d104.suse.de>
References: <20190405125430.vawudxjcxhbarseg@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.66.68.70]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Uhmf, I have to confess that this whole thing about kernelcore and movablecore
> makes me head spin.

> I agree that clamping the range to the node's start_pfn/end_pfn is the right
> thing to do.

> On the other hand, I cannot figure out why these two statements from
> zone_spanned_pages_in_node() do not help in setting the right values.

> *zone_end_pfn = min(*zone_end_pfn, node_end_pfn);
> *zone_start_pfn = max(*zone_start_pfn, node_start_pfn);

> If I take one of your examples:

> Node 0:
> node_start_pfn=1        node_end_pfn=2822144
> DMA      zone_low=1        zone_high=4096
> DMA32    zone_low=4096     zone_high=1048576
> Normal   zone_low=1048576  zone_high=7942144
> Movable  zone_low=0        zone_high=0

> *zone_end_pfn should be set to 2822144, and so zone_end_pfn - zone_start_pfn
> should return the right value?
> Or is it because we have the wrong values before calling
> adjust_zone_range_for_zone_movable() and the whole thing gets messed up there?

> Please, note that the patch looks correct to me, I just want to understand
> why those two statements do not help here.


Of course, the following statements have similar functions as clamp

* zone_end_pfn = min (* zone_end_pfn, node_end_pfn);
* zone_start_pfn = max (* zone_start_pfn, node_start_pfn);

> Or is it because we have the wrong values before calling
> adjust_zone_range_for_zone_movable() and the whole thing gets messed up there?

Yes, we have the wrong values before calling adjust_zone_range_for_zone_movable() 
and the whole thing gets messed up there

Let's focus on the process of adjust_zone_range_for_zone_movable, in the last
conditional statement:

/* Check if this whole range is within ZONE_MOVABLE*/
} Other if (* zone_start_pfn >= zone_movable_pfn [nid])
* zone_start_pfn = zone_end_pfn;

For node 1, when zone_type is ZONE_NORMAL, if there is no clamp when entering 
adjustment_zone_range_for_zone_movable, then *zone_start_pfn does not satisfy the 
condition and will not be corrected, this is the root cause of BUG.

This fix only considers the minimum risk changes of this point without affecting
the results of other values, such as spanned pages, present pages and absent pages
of every node.

Perhaps, a series of optimizations can also be made. Thank you for your review.

