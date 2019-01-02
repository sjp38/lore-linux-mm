Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28662C43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 21:46:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D26BD217D9
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 21:46:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ee3OGe78"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D26BD217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E1748E004A; Wed,  2 Jan 2019 16:46:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 669938E0002; Wed,  2 Jan 2019 16:46:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50A418E004A; Wed,  2 Jan 2019 16:46:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 25C4F8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 16:46:02 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id r191so22167277ybr.12
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 13:46:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=D0puuOBT2pD/XnAHjsSo/6sVuD3uUPGP+UfDkXMy5oA=;
        b=S57iZebdao0TK/WdGnVN1qPrCzBG8qzg4eXQmSAXx8JhZB2IJ04+onVF6Mo+Saxzze
         Vns/2BtCHaW0CtjBZNBHU39iSmPxjvD5JGv/IufRSj71a+G/O08TNFvKI+3UdnHG6kRO
         86V7ZiNmqBcp+jQvAAPAAMyYipDsAvr2Kb+bK8++bJ5WYuXB//p4oKzMKSiFM5IMkxi5
         NIewjH6/hSq0iFlb8RvQ2f6FyLukaETf7zAykjoWrOw+Zs4SCCxaLx0MfB8AIZQd+/I8
         Y0Vb/PuVmtiXPw3gGtpN82s2Oi2oCauofv53/U6c0ngpV4cg1dtj9DoEHgXlaPWm70jX
         ulUQ==
X-Gm-Message-State: AJcUukf2PzXx9d9cGZJ9cED6ZxRB3eEWB9zxtu/Yd+NaVXoIOODiA/Ew
	jevAgoBLB00nyCqJKgqpK2dFsfojXhJrfqAHgTHk2KVFEyJ3Om4wW/n2zHwiP8f/4l4gFzOdMmW
	tUcQH7aesNtcm3ZZ+ckKB6d+HyLSyKRTNj0azd5OhkCkUNV8K4Qpk7EC1pGajaRXP1OffMKGhZG
	sc5686twLwA+XBCqbe7CT3uMxmtGZxlqLEQFjf59nXLVYVvkJRlN/YCxv9Jt0dwXhc4gSZIYzjN
	nsmwjBhHkPDhblMVZMwUUBZzJIzfm28JbICgcDGokNslbxUHU/3EC/VXDXOfr8Vn7xDH74njprv
	IjowjOs1x+Y8o/nMmdyEeTwxewxAnZQMbnH2EG8NJnhoiNFPGD9lMQsDTO05N2KQ5/S/Dj9AtMg
	Y
X-Received: by 2002:a25:2d60:: with SMTP id s32mr35385210ybe.111.1546465561858;
        Wed, 02 Jan 2019 13:46:01 -0800 (PST)
X-Received: by 2002:a25:2d60:: with SMTP id s32mr35385194ybe.111.1546465561326;
        Wed, 02 Jan 2019 13:46:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546465561; cv=none;
        d=google.com; s=arc-20160816;
        b=P7MR3GoIIg2H3qsDzEla0cvVlLftJaPgNxe1ynaFdfa+9rKxPnhy1MWwZYBaTIBqY1
         TvjNBS/rjr067Er/lPmU2L2jRDQC4l58bS1820wj/Dh5pbggm2MGr+aXyG10ZgdUOD7l
         o93B0cYjkFKkKQv/ivM2cFfrE+Ur+tuw2Wb0z69Ci8rfe/H/9ibcK53YJMpVyujMyy2w
         JqbyiDceZi5K9F1yiUkaZVKaVgqHkQdxF7Nb+ld0uu/oKByCIgMkcbN/0zVU3Gh0JX0R
         +I2AzKeC3f7mWSMKpZAZZJNssDM8kdhoMMW3ZSRjYHzgCUGO8EDVbWLOv6e51e0NhBNM
         dq2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=D0puuOBT2pD/XnAHjsSo/6sVuD3uUPGP+UfDkXMy5oA=;
        b=kVsXUy6HroCUQKtVxKRdgyS4cUFxQDTzxpHdOnNiGS3BozrAWja7C8a+7CBfN7UGCe
         q986lvqfUTbH0U6CX6mcjwmgowrX3OnD+DqT6jlrRP2MC2MG/cEOD2zMHhAYGtLc+lUo
         loO8KJ9eBosmHO5Gyz9sQCOWlRUMlj0L5qfvzATGuE4S+YKxAqOWE08kwye+32djIMUn
         xH6jQq17kO+7lKlEOlVzFonp1n1WlTUp3XpTk9qqylIlc2N5sVLggX/BKxxLPUImXLNg
         gh9yIztuot0g7JXUT/+MifsxWXaSu9J/1pHI5jXgS7PpRztnuGxd/pBLjNzPXnT64Af8
         5+3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ee3OGe78;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c14sor10616757ybi.194.2019.01.02.13.46.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 13:46:01 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ee3OGe78;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=D0puuOBT2pD/XnAHjsSo/6sVuD3uUPGP+UfDkXMy5oA=;
        b=ee3OGe781HrG7cNNgDlY6Y1ESKVx3Ll3q10QZPrg1Xjsv1Nd/mY3Er7+cJRoosc5UL
         wNQARPudiXv0kWIpSJpH2iweIdt02p4syLpsPFNMu/a0k1jVhYRGevnNVbu84KD8vl1g
         ZCmzt+4y16g9hQ8Ye4yMw2Q97rc9tK5iyvFyP9NSUldVT5Od49FRffiFymyDFGyjSgHq
         SgP8iNEVAjRld8qaJ9sJ5w6nF2QRasvf5G0MXM2BQW26t/GJ+bLkhI5903g+hIBbZqMc
         JxEv8JMoLa+Sfe+Gkf2SRtP3V+T4u8BAUhGMmjm2VIbLaGml/VQo9tdZEe04Y4Sd1rtw
         NQjg==
X-Google-Smtp-Source: ALg8bN5KUmK006nxWFp+cGe1e5WwFZFAGFl5TmA+9HHeAe21bPxM8CMyXvoTB+ZS06qvz5c65I7kfuvaZGKXeriVjO4=
X-Received: by 2002:a5b:f01:: with SMTP id x1mr41195493ybr.464.1546465560576;
 Wed, 02 Jan 2019 13:46:00 -0800 (PST)
MIME-Version: 1.0
References: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com> <1546459533-36247-3-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1546459533-36247-3-git-send-email-yang.shi@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 2 Jan 2019 13:45:49 -0800
Message-ID:
 <CALvZod7X6FOMnZT48Q9Joh_nha6NMXntL3XqMDqRYFZ1ULgh=w@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: memcontrol: do not try to do swap when force empty
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102214549.TEIGJyuF9YNBiPGI0MRn8pdf6DG5Wdx8GranPl1Bz98@z>

On Wed, Jan 2, 2019 at 12:06 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
> The typical usecase of force empty is to try to reclaim as much as
> possible memory before offlining a memcg.  Since there should be no
> attached tasks to offlining memcg, the tasks anonymous pages would have
> already been freed or uncharged.

Anon pages can come from tmpfs files as well.

> Even though anonymous pages get
> swapped out, but they still get charged to swap space.  So, it sounds
> pointless to do swap for force empty.
>

I understand that force_empty is typically used before rmdir'ing a
memcg but it might be used differently by some users. We use this
interface to test memory reclaim behavior (anon and file).

Anyways, I am not against changing the behavior, we can adapt
internally but there might be other users using this interface
differently.

thanks,
Shakeel

