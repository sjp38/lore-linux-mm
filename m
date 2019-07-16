Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2681CC76192
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 21:10:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B80B721743
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 21:10:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="e0Yoeza2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B80B721743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B5FC6B0003; Tue, 16 Jul 2019 17:10:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 367656B0005; Tue, 16 Jul 2019 17:10:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 256F78E0001; Tue, 16 Jul 2019 17:10:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E02E36B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 17:10:50 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 91so10797870pla.7
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 14:10:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mh9oJF2syVHb1Y2dxeqo0XnShiSGijbTMh9iTn7vFzo=;
        b=ngpSYb3Wum/3EU53XXwdBykUswgBwGlqi6fAKl/bNnaqREBFLOl27s4W8NcIY2lFGG
         h/r+5tJvOplkEl9s3KYkwPVnLOeAi0T7Ygm/KDN3k73SOiMXpqj3sc/oqieLIFc1BW0m
         y+45Sv8fQ9/lliNQS7Ai6q/RPf+CmzUMPBgVwqPgSGX6PigqhzvslwYvclBbdiYQCvov
         FLXrdckHfC668qmRGftzdsGZgji3M2OpxH+JiozUdxknitbv8PwDXq4COvLaONo5LClP
         9zVNf7FcFDfDRuIqfSNWCPulDp+vPe/66yD6VI2imu2TcVcbV62hllqy/KO5WMYqV66A
         TR8g==
X-Gm-Message-State: APjAAAVicEedFZlPzzd4uCew62R308WaF8Cz0JLBAOtKYMSAKvTvx2CY
	N3BBGIkyZH2qfYOT2XhFV8NefxIbu6UFedVasEkabQXGO7bAo9cUrQM8l8n20LBGVfCFppq+SpN
	PKbbd4TnF3Ef1AXKOpmsDuwd1vWn6XYr2K+jUwTTMG+Ck7CH/sQJ0IDpLTaoL+c7NFw==
X-Received: by 2002:a65:538d:: with SMTP id x13mr36560742pgq.190.1563311450427;
        Tue, 16 Jul 2019 14:10:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgqW/oVpdIXOawy5VRYoe4SabSF0hpUD6Sv1imwG2IvC8CnZvW2D4TQWeYs02UrFnzpQZ5
X-Received: by 2002:a65:538d:: with SMTP id x13mr36560688pgq.190.1563311449787;
        Tue, 16 Jul 2019 14:10:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563311449; cv=none;
        d=google.com; s=arc-20160816;
        b=HU2CpGnhnL3o/zZGMRfUQ5k/m2y0v8TGDjby53aOiUerYaIKqvPny+9P+WS7kzC/TM
         BMeKsYRBjY8QBXcxiX+ugxK47kbIdqCM8YjwOs5pvM4XEGThxqsCaO6KETO8KqwVr83a
         Q006OApkqiZT8vSrh35gk+XoozTnQj/aBlsnaKOopeL+PvTPj2NJl+0xWQepTohiG7Yq
         lt38E+aFVJaueOmz6+Czj2OPivG+qgVjjJh0jHvNu3AZbu0s9oDt3iNEFbW3HzKUvsre
         sxzD/fWruPJSCcV7z5KECNsvepdnqeai+We230RozplHY8/0lay88VR5VCn2xluBJ7aN
         9/pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=mh9oJF2syVHb1Y2dxeqo0XnShiSGijbTMh9iTn7vFzo=;
        b=OINs//rdHMl+p95XvatIdy4eOjAkk9QpqKM6NDYSCWf3WpnldVD+X2sBCv4m1HcKOe
         l5b7IENsMIpD2aeZNxZC8kCLv32GJuI4WR4sfWmNh9S0lf+kCfGNy6tMezGcfOs5Srpc
         LzJXO73JDQDRhXmbcNfaf4fpObY7X6nlBKg7X2PvpYWkQWRQ0aNQI8RBhTNbnDhA8qAO
         SopScY0A+HLZIAxxYWlLJq2cWQe25XLAbFF78qJHtWimjHENVcHcKHe18tF2aIs50TB4
         oX91/Gv5L5pH66dY2D8cNkueJLTJ7BD/oxKvG3TOlr2Cnj0y8tpOiI3FX8oqkhuc/j0d
         5KcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=e0Yoeza2;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e19si19389556pjp.49.2019.07.16.14.10.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 14:10:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=e0Yoeza2;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.64])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3B38E2173E;
	Tue, 16 Jul 2019 21:10:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563311449;
	bh=n+Bn+l+cocbUUKE1hcmyc7LxYuNmdQZj8ye7iFFZ9dM=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=e0Yoeza2yPveXA+92jY/2RqFilkK5CRv5gg5ToLsnbx6plgyhXBOJ40QVvCgMCLbm
	 lYqzvOyjpPLPYKWu9WnDxSmdsVrY9b+1SIob7lUgtImr2zBWWuaq5EKpNKHNLEUnYG
	 9D9M+OxP48NSnLTK0ZjW1kxvyv520Q3Jjyii9AuQ=
Date: Tue, 16 Jul 2019 14:10:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>, <linux-mm@kvack.org>,
 <linux-kernel@vger.kernel.org>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse
 <jglisse@redhat.com>, "Kirill A. Shutemov"
 <kirill.shutemov@linux.intel.com>, Mike Kravetz <mike.kravetz@oracle.com>,
 Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH] mm/hmm: Fix bad subpage pointer in try_to_unmap_one
Message-Id: <20190716141048.c94534a23e4c059dff34e3a1@linux-foundation.org>
In-Reply-To: <8dd86951-f8b0-75c2-d738-5080343e5dc5@nvidia.com>
References: <20190709223556.28908-1-rcampbell@nvidia.com>
	<20190709172823.9413bb2333363f7e33a471a0@linux-foundation.org>
	<05fffcad-cf5e-8f0c-f0c7-6ffbd2b10c2e@nvidia.com>
	<20190715150031.49c2846f4617f30bca5f043f@linux-foundation.org>
	<0ee5166a-26cd-a504-b9db-cffd082ecd38@nvidia.com>
	<8dd86951-f8b0-75c2-d738-5080343e5dc5@nvidia.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Jul 2019 17:38:04 -0700 Ralph Campbell <rcampbell@nvidia.com> wrote:

> I'm not surprised at the confusion. It took me quite awhile to 
> understand how migrate_vma() works with ZONE_DEVICE private memory.
>
> ...
> 
> I see Christoph Hellwig got confused by this too [1].

While making such discoveries, please prepare a patch which adds
comments which will help the next poor soul!

