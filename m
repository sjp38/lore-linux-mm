Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88BE3C3A5A4
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 17:58:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BB4E2339E
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 17:58:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="IBueXC/o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BB4E2339E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E378B6B0006; Wed, 28 Aug 2019 13:58:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0ECE6B0008; Wed, 28 Aug 2019 13:58:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFE2D6B000D; Wed, 28 Aug 2019 13:58:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0098.hostedemail.com [216.40.44.98])
	by kanga.kvack.org (Postfix) with ESMTP id AD8146B0006
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 13:58:13 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 5290181C5
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 17:58:13 +0000 (UTC)
X-FDA: 75872595666.03.glue92_d86625fb0c23
X-HE-Tag: glue92_d86625fb0c23
X-Filterd-Recvd-Size: 4431
Received: from mail-oi1-f193.google.com (mail-oi1-f193.google.com [209.85.167.193])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 17:58:12 +0000 (UTC)
Received: by mail-oi1-f193.google.com with SMTP id v12so367797oic.12
        for <linux-mm@kvack.org>; Wed, 28 Aug 2019 10:58:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=tK5THlH7NqfDItCUjzopiqfECSLNe3u1Nqtw0AYmMVQ=;
        b=IBueXC/olKJzB5vkgN7R06mcGGzgzCsySyIoqFzMQQeswkJAHKqFm+qVQ5Q/mM2Viu
         zMz1KIwbGEYS6VOP2ibBFyCNrAXohuSwim7uGYeBOM127IrM3XRf1yt9rJ+GHWQq+xby
         Qc9uu+kA2eAXXs7BwohGVmINAWOvSq+nfdDJ7Y8/cZH7Zjv7WKps8+dAr7a87Jg8U7go
         y6wsL5nd8ng2CHv6pSTiVZcRNiB8QywcWIY3rsDRn9ebc9S69ai7ItW57QzlHO290kDA
         /eZVRciXkxX0EBDYL1nGG9xnDi802eQ8QjILYMSICbvd2i1N6UMg++8x6WAxh9mniN+W
         DZgw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=tK5THlH7NqfDItCUjzopiqfECSLNe3u1Nqtw0AYmMVQ=;
        b=g6yeoXzvQPMn6NWx5/Kc3jafkeRdTfHWv6Vpan5hnNpnwYRooih4JaMqwPxEKXdmqf
         Lh95JhuXkxIM55Xsecb4dIGYAEKhxpdOkZ1eCqQ2Bg3hUzR0Fq3S60r2lIUMyOccKF2b
         rtUsw6R/QCtuXVtQUfV4Zn/N9LIwJJC/EjrNbxIRhb1iVExG6ASqCvvWCDRxgOi340BC
         Abi0fQuDVc4+evgb+HDnBJhSGGe4XjnOgxba/glCbPxu38/fhDGaxJdpozxD/EEFoxUT
         zdwlm1U35m2uPKeVsKXfks6ALLPMPN2Dap+MqOvXeoyfP4YweAw+hwfS6zVlJbzQP8ek
         kwQQ==
X-Gm-Message-State: APjAAAVK5zMtgzOsd2MkijTVLwsyroRLrpZmEQrKm97OLd+bJMdwmGfd
	JFv63iLoGlO80Weo40NcDfPQKfLLqhBkCshx1ho7iQ==
X-Google-Smtp-Source: APXvYqz0MlmHPcbvq/+RV6BUWyxran0z3juZutp6BvdDm8/FPvPCOgrtXXF42MKgXKq3VxKiHhatdFzdm45AKBpnZPA=
X-Received: by 2002:a05:6808:b3a:: with SMTP id t26mr3719696oij.67.1567015091735;
 Wed, 28 Aug 2019 10:58:11 -0700 (PDT)
MIME-Version: 1.0
References: <20190826233240.11524-1-almasrymina@google.com> <20190828112340.GB7466@dhcp22.suse.cz>
In-Reply-To: <20190828112340.GB7466@dhcp22.suse.cz>
From: Mina Almasry <almasrymina@google.com>
Date: Wed, 28 Aug 2019 10:58:00 -0700
Message-ID: <CAHS8izPPhPoqh-J9LJ40NJUCbgTFS60oZNuDSHmgtMQiYw72RA@mail.gmail.com>
Subject: Re: [PATCH v3 0/6] hugetlb_cgroup: Add hugetlb_cgroup reservation limits
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, shuah <shuah@kernel.org>, 
	David Rientjes <rientjes@google.com>, Shakeel Butt <shakeelb@google.com>, 
	Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, khalid.aziz@oracle.com, 
	open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	linux-kselftest@vger.kernel.org, cgroups@vger.kernel.org, 
	Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, =?UTF-8?Q?Michal_Koutn=C3=BD?= <mkoutny@suse.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 4:23 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 26-08-19 16:32:34, Mina Almasry wrote:
> >  mm/hugetlb.c                                  | 493 ++++++++++++------
> >  mm/hugetlb_cgroup.c                           | 187 +++++--
>
> This is a lot of changes to an already subtle code which hugetlb
> reservations undoubly are.

For what it's worth, I think this patch series is a net decrease in
the complexity of the reservation code, especially the region_*
functions, which is where a lot of the complexity lies. I removed the
race between region_del and region_{add|chg}, refactored the main
logic into smaller code, moved common code to helpers and deleted the
duplicates, and finally added lots of comments to the hard to
understand pieces. I hope that when folks review the changes they will
see that! :)

> Moreover cgroupv1 is feature frozen and I am
> not aware of any plans to port the controller to v2.

Also for what it's worth, if porting the controller to v2 is a
requisite to take this, I'm happy to do that. As far as I understand
there is no reason hugetlb_cgroups shouldn't be in cgroups v2, and we
see value in them.

> That all doesn't
> sound in favor of this change. Mike is the maintainer of the hugetlb
> code so I will defer to him to make a decision but I wouldn't recommend
> that.
> --
> Michal Hocko
> SUSE Labs

