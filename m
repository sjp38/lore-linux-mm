Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85B06C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 15:20:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 371912184D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 15:20:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="AuKf2ntI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 371912184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFC4C8E0003; Tue, 26 Feb 2019 10:20:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DABCC8E0001; Tue, 26 Feb 2019 10:20:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9B7F8E0003; Tue, 26 Feb 2019 10:20:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5F58E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 10:20:27 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id e31so12327562qtb.22
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:20:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=ldR12rhIAH27PJULJ/GQ8uBA7E5Qmh6QabaMRAf2POs=;
        b=AZi9dd0DB8y/X3DNmq6pSeDdiDroil1UinUsWYCSZLRoc1QnH/nCpeY9BoN4NIVkR8
         wt+GORDMRdu4RHnB+SLzZ8pJUGdEJE9+KUzHhU2MDGAtFzDd29/c8t0s5iDtCeqLbNG7
         GxzZzIRRQ3Hg7PGe33uMWDVpgyZJDvl8GnO/5+HTs91l9zyGUzBVXSIjr0LjTCb8AUXj
         3780hO3JdvDXBIXUGkVbv45Pxnlyvd1iJwyR/GJEApMC1GJElxXElqvXz7Jifmrd5Aze
         eFh05Q/4EAineHOdzCmEWFj90NYp0NR8HFMejVhZIoJ72+O6ZPBLdcWEAuTrDv3HmrHp
         voXg==
X-Gm-Message-State: AHQUAuZWGJR2u8qpCl9T0LAaE5nYlM7zQpJpWydJDDzHXeCJP6Tuxk5C
	Ovm3/oRx5cpA629ihxrsR1IR//vrIBNEjFZ48Dr7swfmVfaF7UU6hPYKQudvPp9/Sd+pxAitjcd
	R5VGnQsvNm+093gcXINt1WM2JsXnD5YHRvBujo+kj63hZpy1MUlNjCGbOJO+sdk4=
X-Received: by 2002:a37:d612:: with SMTP id t18mr17097742qki.215.1551194427438;
        Tue, 26 Feb 2019 07:20:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYflAFY4qmoHXDtW+PONyBFP+k9Yt0yLTWfQu3M0rDgjQn02Qqlak8a7KLva0LWvrM9/WMS
X-Received: by 2002:a37:d612:: with SMTP id t18mr17097701qki.215.1551194426905;
        Tue, 26 Feb 2019 07:20:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551194426; cv=none;
        d=google.com; s=arc-20160816;
        b=jPM488IWrt5bAIaXCHvvj7c7W5/ui0R0w1xR+z7BC9YOK7rosrxodV6Vg0CaLEO8n7
         LO0bW55adgOHUVQK77iHRqijm1keIxHhu4wRenDD4XStyGTqDyqo27Au3Ra+UshYdbX4
         OTA7QpepPyOx8TvL/Ro0OuncHI8KiuvaB2tbZDj69GIolLUgk/EzXEAzbCasIAtDEtdw
         RUKBYmxgJa835U44MMuk2TbJeHWjRWa97ARr06lD0kxhWwoTFpJ3flbr4b0BB2a4DI1l
         CtVFej1LwJritl/vGAGay3n7gt5cKUNRUSrPKk/vc2GY4Nkfln/9qw31inf5meKUKyE9
         +9UQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=ldR12rhIAH27PJULJ/GQ8uBA7E5Qmh6QabaMRAf2POs=;
        b=GGDMv1zDxkLaskwB3vpfpn/18MWZsQC+klvdvyFGBZHhEZcVQYL+4w0yyvO3QYSmDn
         K8SWY/h2ZjXXDYgw4mdA5BGkKZzpTEQ3EkF320ck419hVtYQePteKwO8St60JPv2xUfa
         os+5r5jlLzl3arGPWIfsda77m79GEwTYNKDZWb4X1V7GlwFe2J/8clezODtw48g2sqra
         lk/CL0MS0uDvfbvyRnbGAA9hju7R1Ch6CTikimG7FQVji0IscqA07Fbf1Re6+2KGMuz+
         njS33SvrmbVMU+C61V9+oxNiCp5M7DRKltUjIL5RlCqWgp7sljgXcMF9j1UdN78isb1M
         umpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=AuKf2ntI;
       spf=pass (google.com: domain of 010001692a648c57-4215863f-7d66-4086-90ba-2c0832117e3c-000000@amazonses.com designates 54.240.9.99 as permitted sender) smtp.mailfrom=010001692a648c57-4215863f-7d66-4086-90ba-2c0832117e3c-000000@amazonses.com
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id d9si3963324qve.12.2019.02.26.07.20.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Feb 2019 07:20:26 -0800 (PST)
Received-SPF: pass (google.com: domain of 010001692a648c57-4215863f-7d66-4086-90ba-2c0832117e3c-000000@amazonses.com designates 54.240.9.99 as permitted sender) client-ip=54.240.9.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=AuKf2ntI;
       spf=pass (google.com: domain of 010001692a648c57-4215863f-7d66-4086-90ba-2c0832117e3c-000000@amazonses.com designates 54.240.9.99 as permitted sender) smtp.mailfrom=010001692a648c57-4215863f-7d66-4086-90ba-2c0832117e3c-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1551194426;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=ldR12rhIAH27PJULJ/GQ8uBA7E5Qmh6QabaMRAf2POs=;
	b=AuKf2ntIA9HPKaIu6QHuET2pwbeDm8YRYNCayFlsQcWOUWhXuasu/4vC1q4UB3qZ
	rtmd0Lb+fBOVLu4LWop1juy6Li32yURC4RFjZuJHHbkx08q1Xsfy36HU5UQgSv6M3iH
	5MN2vLKMfrwUMTk//vyTFd3DatFCg/CPTE2o7Raw=
Date: Tue, 26 Feb 2019 15:20:26 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Vlastimil Babka <vbabka@suse.cz>
cc: Dave Chinner <david@fromorbit.com>, Ming Lei <ming.lei@redhat.com>, 
    "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, 
    Jens Axboe <axboe@kernel.dk>, Vitaly Kuznetsov <vkuznets@redhat.com>, 
    Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>, 
    Alexander Duyck <alexander.h.duyck@linux.intel.com>, 
    Aaron Lu <aaron.lu@intel.com>, 
    Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, 
    linux-block@vger.kernel.org
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via
 page_frag_alloc
In-Reply-To: <5ad2ef83-8b3a-0a15-d72e-72652b807aad@suse.cz>
Message-ID: <010001692a648c57-4215863f-7d66-4086-90ba-2c0832117e3c-000000@email.amazonses.com>
References: <20190225040904.5557-1-ming.lei@redhat.com> <20190225043648.GE23020@dastard> <5ad2ef83-8b3a-0a15-d72e-72652b807aad@suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.26-54.240.9.99
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2019, Vlastimil Babka wrote:

> What about kmem_cache_create() with align parameter? That *should* be
> guaranteed regardless of whatever debugging is enabled - if not, I would
> consider it a bug.

It definitely guarantees that. What would be the point of the alignment
parameter otherwise?

