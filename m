Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BCA8C282CF
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:08:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A4792173C
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:08:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="wOXE9mls"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A4792173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96BAE8E0009; Mon, 28 Jan 2019 11:08:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F2B38E0001; Mon, 28 Jan 2019 11:08:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BAF88E0009; Mon, 28 Jan 2019 11:08:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4816E8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:08:39 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id t17so9678877ywc.23
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 08:08:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=d0rb+admgqujxz8uCtJLl0Rf7qV1TQ5qEBaCJcsbcKE=;
        b=Q6glWkDqaIww5f1g7XMGjKuyRXk61FrNwOkzGaX8OfCH68R9xIn6f/hB68YbQC+qIU
         5LSY0t7JsDdQLEg5pHZgp9ZisC3YBAT5fz1bdrPpPZSXiRg/Q6xWw3tdCW6I3I2u2ru4
         83wn9qYLZzrsSef7bafwKoKmeXzo6oZXHviJ8EUsNIVXhkSzBWpvOXgTIW89LsEeWxr+
         CUSQwSDFlfwuVf6R3/FlFiyRE+1bbb3Lxo+J1fO+0HUhtMynzFGXyswqK2BLinIeFZFr
         54vEUcCKp9OoNNvJQ16ES8iaym/uzhqdqNfYLJMJ47fme66OyP0Svfh9QZ/+LwWefJ8h
         xrcA==
X-Gm-Message-State: AJcUukf+Jsi1HTbeuQHPLnjEZkVH/OrHXlrTHHYGkV8SAdPbnW8Rq7zD
	PBRYTrpd4T6P+G+rhvUvkgzbNd30cBF7iP0XU3VnldE2nToDLHT2XV1Wz8OZHMWKyDta0UWstW2
	v8ppcL8JYDVNduxsiWcvAu3lJhSnOu/s72e4mVibvqatJseGk2ozdyASQ5B0nA21h9F0/liykd9
	9QQqL1ia3cK3sApqTjvD6bICDcoy2r78JWr9moW03RMlfxFzXWF8/7YXG7/5b/C2+v04PSqhpYN
	LrSWGR0iY9gMCoJIypnjdRt21RYcPTKHUB/vjOxV5OqhhcVWSAtk1yDYpqv9/yKYExpannJhk4K
	JhKnUizqAVcQ37HANyKI4JL2ZdqlbiCM9WXGnItKU6iVLkVdIh64U2Cu8CNnZXbMhJ7Iws3POa0
	r
X-Received: by 2002:a0d:c281:: with SMTP id e123mr21934075ywd.118.1548691719044;
        Mon, 28 Jan 2019 08:08:39 -0800 (PST)
X-Received: by 2002:a0d:c281:: with SMTP id e123mr21934028ywd.118.1548691718534;
        Mon, 28 Jan 2019 08:08:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548691718; cv=none;
        d=google.com; s=arc-20160816;
        b=GIOL04+nA9g9Mb99+rnSZ7InKrsghS4ABQ5Ie9Kf0VXu5tqdHHmww3zdP7ft5Aztv5
         Au4lSnyzBvnzI6v5Slpk+NfS1CT6VXwp1YmcFp5/1LIqmAKc82fO7cxpBn+nlGrxNHTC
         9XD9dtpEttMJTxjGAn9hMIDE4YD2xhe0C3lwlQFw5AhDQuVVe14QNXNNk94yiXToNFqm
         MMsKa3PUYMpH4LQFzcqw+hWeiabNH1stceQWwsCGXpLsSrmMsBi8vQOzbBAZImVDPB7R
         LDOcC6F5gIPApC1gTOAlZI67hZ1TXhua3zC29pE21RtmSc2S5OErME/XTbvybzrVUD3L
         a7mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=d0rb+admgqujxz8uCtJLl0Rf7qV1TQ5qEBaCJcsbcKE=;
        b=uZk3d+tc2RJ15gVWPAKUKVw4ZaEZgFS9Tj5UM2QyPLuObojplsbrhHpyDbSpAsZTgM
         9zJpQDzBHvV1M4ctv2Lg/FDtFhX61Zfc6Eg0tXFrdbpqZGiFnKlwrnW9kum/gISCbR2R
         5HFhsn7vSuKqrYuzdJR3alwW2vwRfXbpR9Es6uV+Z9Xf5Sq1qzD/S9LJC/YYExfdvYne
         rbH68AMJImlxisAU/09vBIBMn3zSjCJWwpTc8l71SM3HeBrQBKn8t0JBt6IBRDDZts6p
         LfAnPFRklJZzOVnTUYaBafsP190FGFox4z6BGMHIB5nkqWATpMOzcjrzSjuZJcHmkN1b
         I3iQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=wOXE9mls;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x137sor4415178ywg.141.2019.01.28.08.08.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 08:08:38 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=wOXE9mls;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=d0rb+admgqujxz8uCtJLl0Rf7qV1TQ5qEBaCJcsbcKE=;
        b=wOXE9mlsqSzCnNKDjZ4de5VkO420siVjvekQdDBL2INCdraE6pj5XAX+vhi4jyxdXW
         yDCJyDgEAeh+fT7R6wF1MjXjTejgF8pb5/MfAurddLddFBlZXOSuoxuE233Qi3HjVSqo
         4GoZCjUBcPzKXWpUw1LcvBnU5kU3ubaHiZQclCUtzFKiL4hJHZ/MOAOwguW0MY2W+ZrX
         F6zCrCUEuwRXz/80NBnkgnrbHR9sL0VgmzPbZNQjiwerNp2Q9J13nCdAoPxwwD5K51g+
         tpnGlywKwCDWKUuQeurnWePHgElLGsMvJeWbyO0eh+ZkjFYyh1NP/o3GlX9dOCEavRlk
         xU1w==
X-Google-Smtp-Source: ALg8bN4RMJBWBGwdTY3r88jgG3etUuaEixGDkGVTMtKvivTJl1EKc4QuLJQ7/1dgTKj1KyPF3jcfX2IZmpCtemH2i6o=
X-Received: by 2002:a81:ee07:: with SMTP id l7mr21449063ywm.489.1548691718003;
 Mon, 28 Jan 2019 08:08:38 -0800 (PST)
MIME-Version: 1.0
References: <20190123223144.GA10798@chrisdown.name> <20190124082252.GD4087@dhcp22.suse.cz>
 <20190124160009.GA12436@cmpxchg.org> <20190124170117.GS4087@dhcp22.suse.cz>
 <20190124182328.GA10820@cmpxchg.org> <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com> <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com> <CALvZod6LFY+FYfBcAX0kLxV5KKB1-TX2cU5EDyyyjvHOtuWWbA@mail.gmail.com>
 <20190128160512.GR50184@devbig004.ftw2.facebook.com>
In-Reply-To: <20190128160512.GR50184@devbig004.ftw2.facebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 28 Jan 2019 08:08:26 -0800
Message-ID:
 <CALvZod5Rrr6ENW5yLNzniFeFmGB=mDRH+guNLmcayTX-_xDAGw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Chris Down <chris@chrisdown.name>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, kernel-team@fb.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000273, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190128160826.yytwanux6qdjbOOVa6n660Z9jFH68bIz-ECg6_6Ams0@z>

Hi Tejun,

On Mon, Jan 28, 2019 at 8:05 AM Tejun Heo <tj@kernel.org> wrote:
>
> Hello, Shakeel.
>
> On Mon, Jan 28, 2019 at 07:59:33AM -0800, Shakeel Butt wrote:
> > Why not make this configurable at the delegation boundary? As you
> > mentioned, there are jobs who want centralized workload manager to
> > watch over their subtrees while there can be jobs which want to
> > monitor their subtree themselves. For example I can have a job which
> > know how to act when one of the children cgroup goes OOM. However if
> > the root of that job goes OOM then the centralized workload manager
> > should do something about it. With this change, how to implement this
> > scenario? How will the central manager differentiates between that a
> > subtree of a job goes OOM or the root of that job? I guess from the
> > discussion it seems like the centralized manager has to traverse that
> > job's subtree to find the source of OOM.
> >
> > Why can't we let the implementation of centralized manager easier by
> > allowing to configure the propagation of these notifications across
> > delegation boundary.
>
> I think the right way to achieve the above would be having separate
> recursive and local counters.
>

Do you envision a separate interface/file for recursive and local
counters? That would make notifications simpler but that is an
additional interface.

Shakeel

