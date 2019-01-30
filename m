Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58738C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 23:53:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F281E20B1F
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 23:53:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bK4TeC23"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F281E20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 876498E0002; Wed, 30 Jan 2019 18:53:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 826128E0001; Wed, 30 Jan 2019 18:53:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73B768E0002; Wed, 30 Jan 2019 18:53:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 48C158E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 18:53:26 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id w28so1368463qkj.22
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 15:53:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yHTmlSdsw0ddv0WZw6NQBaf+Lx/v0lncj03Huj6mH3Y=;
        b=DYJjPKKSq3WJoWf6vXbwKgFGUvx0kGAHBk7dTK1xCLApacmVlKQLBPO6Dh9DJJYCe4
         dInP9a+2tCFfu0iRgZifOim1d10Vw/n2Mpq/vdPMnIwa1oAv+oOZUrDWEics7j9K05nL
         PcmegepS54hC//th9/m3X2fR6Tj3DmyAwNnTSn1S76kOL/WEHO7E5y3f9BcqQAk8KIpP
         UODF7kb1Y43Sr3EsNuRm5Y1t9ivlrGNTBh4H3Pnj0SU6lpxlCo9ciSRfMqwiW74ZKfKn
         JEdGOBpcDREkB3+FXE+0tZcTYqrsPtfEA8kewVAdJnLf61vWnzBuOZXD36Fe6puJ2ga2
         SHnQ==
X-Gm-Message-State: AJcUukeKMqiAT7gRvG+oHL6qxivTBl+F7UYWmsbg+j+uQXHCPDqlIJ0v
	8+U1hCSQUVzHw3uy4Td48BwuFT5NoDXn0ul+n7KJlCMR9K5GEXPbHyhzYxc/eU0u2f+8EUfGA/k
	PPyuN1i8QzWc1aq2S9cUSaiCgoZNP06IvzOyGxTZzXtH9Xl1H3OadLjLtWQgCK94M1KDGbZMLVG
	4isDo9nS9ech0Bc4O6WSlnkcOKI8W2DIFkIUa24wHK7I27ICFA/RaFIwbnRt7nPeeOH2aA70oZ/
	6Fx0LRh8tuhGGElCM+Wo1eQeVTdd7WpULuWIdvUzSogHl/tpkDhwI9npUTgq50w5sx50a4SO3vk
	IXuPAIBsaO4FTKZli5F7Ht5PXZTE5YnGlyNySSmGYuoYZ/WC9OvR1G+EOK3kTYh/gCyydxZRpjj
	d
X-Received: by 2002:a37:a1c1:: with SMTP id k184mr30123967qke.155.1548892406025;
        Wed, 30 Jan 2019 15:53:26 -0800 (PST)
X-Received: by 2002:a37:a1c1:: with SMTP id k184mr30123944qke.155.1548892405358;
        Wed, 30 Jan 2019 15:53:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548892405; cv=none;
        d=google.com; s=arc-20160816;
        b=w96WK3iDsf89CZFVaXm0Pk+eAS6U3NSp9gK0XAxXik9LJfOkX5mRC9ogE27GmJIoNl
         xyexBfP2OHxoOM5p0hPdw6tT/DG8zU923bBV4QQnef1lMzA+8tg540dDDsWtq6sQ7uD0
         iyUeHwUV1S++0pccPpUHvduWZFC/PxEZBXCrPqWN1UQEqPMPeuA8lIOgZFdD66UiEfo2
         2n6ujfxM4f6lU3/vcOUTRoowg8xL+Fyb6xO/DmaPc0puvC62jC1PjLowIhDY8eRoGTT/
         FgZgn5UxICHcQ2u/rcVXYCsTUoK6GTSP6ZZnymFbk/610ogUyb067MEmjv+VXSm4GWdP
         JaUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yHTmlSdsw0ddv0WZw6NQBaf+Lx/v0lncj03Huj6mH3Y=;
        b=J53I/UY2hvd3dNNVSKaujqiQfVlZTBlLt81G1HIxEsxhTD+UPDxmP/qsmS8g+NkCTp
         y0ir2XnMz3UwA7MoOnYmD3FEMMt5zWK/BL202qViQc1gbymJ7iqw7IIqVroPy8Y/qAby
         YxXPCVctvTupNClnjTTEfRK8ty4qaN6PB0otEfj2pm3CLSSXXpAXyM19d4EwCk/fSzCM
         N8DTs07Qe5cbP0FS/aK8zf2wLU5XodcKafyHsPyNEAydj40/hmxYQH0ZXlswsOFqc7Dh
         sowl0gf6w8QFZLhmtzt6htPNwLk3hizmGx/A3aEuUquakSgaGb/eI7gbp9SLOjPdmAmH
         tdKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bK4TeC23;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v28sor3282425qvf.30.2019.01.30.15.53.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 15:53:25 -0800 (PST)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bK4TeC23;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yHTmlSdsw0ddv0WZw6NQBaf+Lx/v0lncj03Huj6mH3Y=;
        b=bK4TeC23YsjsP8RNdRKPxHm1ViwVEHRD6VQtzGDNTmcZTErjiXAPaCF5azuC4F2rkC
         kYLbhBtHWvyDyAhDY02uEB6Zpw0kjXIHiTDSjqNitSW3exLUEtHNV8gbs0pZ8CKknGlZ
         cBx50IZSB3mHYo/gce5rIAlWQVq1cE0SY7EyXWosrf+7BS4DXcnGNYpi+6YaFAa7UFBY
         2Z+9okFNtpOOcvWqOz68sRKeuvbMx0oHNhcUgZOu8+y1pfuWnYRQzJblcGGGY8XokKS0
         aRe/2cK9DvDfKzFucfkjVYhv0reC1415nsQagi5tHgpJwt1Fs1Ovl4u3qXdQeNTvjtZt
         S7VQ==
X-Google-Smtp-Source: ALg8bN7l1pcTFadDQJBk1003WV7PL3Ec7DdZpdu4BhZ+NzS6ABGQhPB26K4s11LeGdULTR4OOaaLmo987JTe5Yg9c5w=
X-Received: by 2002:a0c:d29b:: with SMTP id q27mr30512882qvh.62.1548892405083;
 Wed, 30 Jan 2019 15:53:25 -0800 (PST)
MIME-Version: 1.0
References: <20190130174847.GD18811@dhcp22.suse.cz>
In-Reply-To: <20190130174847.GD18811@dhcp22.suse.cz>
From: Yang Shi <shy828301@gmail.com>
Date: Wed, 30 Jan 2019 15:53:13 -0800
Message-ID: <CAHbLzkpbWEVpeH9YsbBNy-Etfe0Pza5rPAe3b50sXq4rV4C+xQ@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] memory reclaim with NUMA rebalancing
To: Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-nvme@lists.infradead.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 9:48 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> Hi,
> I would like to propose the following topic for the MM track. Different
> group of people would like to use NVIDMMs as a low cost & slower memory
> which is presented to the system as a NUMA node. We do have a NUMA API
> but it doesn't really fit to "balance the memory between nodes" needs.
> People would like to have hot pages in the regular RAM while cold pages
> might be at lower speed NUMA nodes. We do have NUMA balancing for
> promotion path but there is notIhing for the other direction. Can we
> start considering memory reclaim to move pages to more distant and idle
> NUMA nodes rather than reclaim them? There are certainly details that
> will get quite complicated but I guess it is time to start discussing
> this at least.

I would be interested in this topic too.  We (Alibaba) do have some
usecases with using NVDIMM as NUMA node.  The node balancing (or
cold/hot data migration) is one of our needs to achieve optimal
performance for some workloads.  I also proposed a related topic.

Regards,
Yang

> --
> Michal Hocko
> SUSE Labs
>

