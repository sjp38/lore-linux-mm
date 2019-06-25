Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C624C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 13:23:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA912208CA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 13:23:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HA4KA6zk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA912208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2E996B0003; Tue, 25 Jun 2019 09:23:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE94E8E0003; Tue, 25 Jun 2019 09:23:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCD608E0002; Tue, 25 Jun 2019 09:23:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id AB0AC6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 09:23:07 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id j140so5148321vke.10
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 06:23:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XeB/3xDQrxxJuVXFQuMuJo5SBnSx0zSjynbT8yHXjaw=;
        b=e25grDlnJFy0riRcEwefp13dinvmYSSbGj/xhg8I/ySUepq99CIc4zUY2xflqEP8N7
         I7FyPjFO6k6j9ZI7keURkdsa0g0kjoT+tjAUC/RGCalBYGxjcjLxyhULJLiMapjybcme
         38S9Mc/VkwzTst/xK0I/9EWpl9b7ti8TRsB3nV5+XjVSYIIWp/Y+d0w6jNsq37gjFhI4
         +XVmAevXB/jaLQZ/IZMUGBVFEJuPDMmYZ1y6/9Pv46qGFruPnz5zs1JjDmgY9BPdur5B
         ya+GoqyDKj22Hn2qvhg1iwGhN/6UrCqzcQzr+N1kPgzAclKeGznJx0nZZc/ZZ9kzMD16
         g+PQ==
X-Gm-Message-State: APjAAAVfraCZDREedMDkWhCmvUVWqy6Y8u+Pgz3fq0l2IlRQJvEHcDnl
	bXrUxhFeJ9UAdhqAMlrTsnHPpxBNfhpwK8bJD53GCY4tOQPGs8rEyug9U3/2OVRJJA6/DbqjYq4
	QwlWV5WBbxwZ1tYlZtPxN2pk/6DAnBXC7RnoSwYyygkEcKZzzXL8SxRt4hqzx8UeqTw==
X-Received: by 2002:ab0:2746:: with SMTP id c6mr5272585uap.76.1561468987284;
        Tue, 25 Jun 2019 06:23:07 -0700 (PDT)
X-Received: by 2002:ab0:2746:: with SMTP id c6mr5272562uap.76.1561468986691;
        Tue, 25 Jun 2019 06:23:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561468986; cv=none;
        d=google.com; s=arc-20160816;
        b=jYuUL6/lLRIgyxcgn4Rc+TOtEbHagkB7+jscAFgAkB05GS15ZlirQP/9w3TFrN+c/j
         KjqHRxm2g7Rzmd+kZc3pOg/I44kRXNognLR1Eg608HWW0US+eho7vyosOmEWFVo7bIj6
         d4cxjvR/dLP9ADVzObf03sUCjh63lkq2i5vXH6YJ/zKuhy81O05/IrAXEStDBxPat3pL
         XzSzRXoNm1NgpkcU1HjX0O3Pew6wyI7g/WsI3wZehQCILCFN2rlTROoUKxTTwQbtLvUw
         OmjFdU37Tr5bHixPjupHLPx0Ma46fKsUHN59UiGuX9pyIr0B8sT4CHAYX/2C6w94JNed
         Lyaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XeB/3xDQrxxJuVXFQuMuJo5SBnSx0zSjynbT8yHXjaw=;
        b=T4VFFB9kmpYEOoPIig0PBwBi2mJ6xHrxDMVlOdFPWSNwtFnYDIcfeGZ5yiKwprCVmU
         6HHn4dSkeq8OIMUu1YlgkdaHa0PeJarOek8CRMsYjNwtb0leZ3DNpICnPZVvz0WJXCud
         k1VMnqfP8PnmpGkEXJ2ORnFtdGfnf8pPJH4Ap33M2vP2dR6zsLm56vQn95Ta0FnUgVKi
         2fbOGy8SuNS9naTVDCxBLv8eNcRtikGFBf6ic+6SvqyMaoJlqK1JZzBsByGFIywsKLaY
         3/6L7O0Js37Un5oHIwXEvi60cMWVGtS3UiAAfoq/bAYpoJk8F7D+1m/Yqb8uRIYxsrne
         Rm+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HA4KA6zk;
       spf=pass (google.com: domain of huang.ying.caritas@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=huang.ying.caritas@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n18sor7339204vsj.47.2019.06.25.06.23.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 06:23:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of huang.ying.caritas@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HA4KA6zk;
       spf=pass (google.com: domain of huang.ying.caritas@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=huang.ying.caritas@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XeB/3xDQrxxJuVXFQuMuJo5SBnSx0zSjynbT8yHXjaw=;
        b=HA4KA6zkysUzhZVkwFh4OrxP/8T3QPuOgjRD3vYHXG832tEUmSoTTS7BnO0sHK99ja
         kqvusqbmQ7LQiIPAV5SPR8rzIGQzaNyZ78LptqlRxpdXnsoWCbq6H4D57Yp84Dis7PZy
         4xHpT7f5PH0MXqGj4VR/n8p10ggV0pK7ZLFFLIZpXudnqfw8DH9sfhT6058yZewp1j9c
         tRNw0vTvMfORORGaZpwa9vPNCChsM6LEreYd2duZ18A/n1E6xLBlrCQ3oeIwja9yauqB
         sG0p0KznNz/R8IkY5rS+s+ex7/frp+LvLmPL0s10LGaQguXEJE1dV9a9JuHD6O15BAzQ
         kugA==
X-Google-Smtp-Source: APXvYqx40wlnI/l2eAlCn1M4FsahOIj+i3MEKX6XnIqju5PViEYX0OKmV1myRuSbh1hnW99Fcegyvb7X7mVHShwTTZY=
X-Received: by 2002:a05:6102:3c8:: with SMTP id n8mr164074vsq.135.1561468986495;
 Tue, 25 Jun 2019 06:23:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190624025604.30896-1-ying.huang@intel.com> <20190624140950.GF2947@suse.de>
In-Reply-To: <20190624140950.GF2947@suse.de>
From: huang ying <huang.ying.caritas@gmail.com>
Date: Tue, 25 Jun 2019 21:23:22 +0800
Message-ID: <CAC=cRTNYUxGUcSUvXa-g9hia49TgrjkzE-b06JbBtwSn2zWYsw@mail.gmail.com>
Subject: Re: [PATCH -mm] autonuma: Fix scan period updating
To: Mel Gorman <mgorman@suse.de>
Cc: Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
	LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, jhladky@redhat.com, lvenanci@redhat.com, 
	Ingo Molnar <mingo@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 10:25 PM Mel Gorman <mgorman@suse.de> wrote:
>
> On Mon, Jun 24, 2019 at 10:56:04AM +0800, Huang Ying wrote:
> > The autonuma scan period should be increased (scanning is slowed down)
> > if the majority of the page accesses are shared with other processes.
> > But in current code, the scan period will be decreased (scanning is
> > speeded up) in that situation.
> >
> > This patch fixes the code.  And this has been tested via tracing the
> > scan period changing and /proc/vmstat numa_pte_updates counter when
> > running a multi-threaded memory accessing program (most memory
> > areas are accessed by multiple threads).
> >
>
> The patch somewhat flips the logic on whether shared or private is
> considered and it's not immediately obvious why that was required. That
> aside, other than the impact on numa_pte_updates, what actual
> performance difference was measured and on on what workloads?

The original scanning period updating logic doesn't match the original
patch description and comments.  I think the original patch
description and comments make more sense.  So I fix the code logic to
make it match the original patch description and comments.

If my understanding to the original code logic and the original patch
description and comments were correct, do you think the original patch
description and comments are wrong so we need to fix the comments
instead?  Or you think we should prove whether the original patch
description and comments are correct?

Best Regards,
Huang, Ying

