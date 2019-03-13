Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D145AC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:06:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CAD62147C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:06:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CAD62147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BEA98E0004; Wed, 13 Mar 2019 12:06:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26CD78E0001; Wed, 13 Mar 2019 12:06:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1836C8E0004; Wed, 13 Mar 2019 12:06:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C95F38E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:06:09 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id z24so2620813pfn.7
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 09:06:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Y/PodYzGOlVK5mGi8NP8ZympBH85b5fPVHvZPiIjrz0=;
        b=egkRh/6pwIiMDERsctiIFoXxHLXI/rK4BpBajvSTDqpOYmWZ81sKm4x4Uz0jGiLHuk
         nMdVjrl4eJXB1phz3QnkFwI1pbWs9Cw1sNhjRO6C5h7dQspm7jmuRw49uw2SMn9k1qJy
         CFVMrfC7NcJFG4Xy6qX8/Ou6vmSVFc/ybYV6wM+5sD2jpuv3sfkOzkcC+jMeqFiWjDZg
         o8ls6xf+medQTw1QwLc6X+2TuDg8Luk7dLgrxdZjimJBBm5z9ILpAk5Kcs5/2WWgdP8A
         k3gwmv5J6lKlyN7BWn40ZcGE2c7lwjzmLn/IXEfq7eWfvCUxh4VbsLBvo3bDczEg1bJT
         yGkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVMgQiDgHN0ifBJ4xLQBeotJgp3c7dq16z8QzMxm92xx4btSey3
	AHl3o0E9DeXYjzN8Kt0fUfUKLDvdePwNFHNUB2/jakCoFpd367MnwV94ipmqSVH/P7Lko8knE02
	lRWDI436e6l1aR7NytYLZHhKlbG5jvKIvuSn46axnp3k4J1ow+d8e0laAJ133w1xVAQ==
X-Received: by 2002:a17:902:6686:: with SMTP id e6mr46302069plk.208.1552493169354;
        Wed, 13 Mar 2019 09:06:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynmFpiRxAYFfNvoK34rLzhF5jNRngmuPc4lcH89eSX+1r3F0WutsK8zhIrrDdAYOPhdl4z
X-Received: by 2002:a17:902:6686:: with SMTP id e6mr46301988plk.208.1552493168284;
        Wed, 13 Mar 2019 09:06:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552493168; cv=none;
        d=google.com; s=arc-20160816;
        b=0xtwaXNpien+kfuGqemLJzdZkJt0USesRyUbFBDwlPg5R6IuvoclImm0ZuqDXh6JXt
         pnm7Q3lijnBRQjCpSc0AqlWWLG4nihyLS7HcYMaXLgxnmte+LAZybE5sKZ6OjfYukuI1
         aXQQw4VBlOB9gOR3huAtbiwtka/0XWukBgLUdq0X93DICq5s3NX3dFYqpwQZCaEdjZ7J
         A2745YCzP+fu74eCgFAVZhMgH8bK2mbGRQFhfmmjmJjX3z/wueF2P0qF4ehKX2cmfNtQ
         Zb5DielcJZY8codNcRC4WMofKiEu/oy5SDwM7oUe8HqSsNGpWidiVNfgyOMJAN5jp2Ev
         8Qdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=Y/PodYzGOlVK5mGi8NP8ZympBH85b5fPVHvZPiIjrz0=;
        b=DG2KGnfn9YIqEzjGg18UF705ixDeoxO5+NFkMNAD5rubKtJsDEzOOT0ZOLGBRfLj3c
         QJ1z9BNxvNJjHWNkBrG9CUFRmuVsefved02gSVvH+cyIaKukDPvlpntU9bshmXFqzOgB
         CmWpvX2UKdOD3SYiNrLSl1qqWMdaq0v7K1PsBjmVLXa6PaMm+LFzfflMRuE+9x15fpAa
         HqdJUQLqjAefmm0AnkA/qeRrmDZ3jixjHdUz0lJyumnMiZ7GPGSqL3c66MhrJSF2GI4v
         ONYm7CSILiKgvzOiKWqJdQMQSuuWdgxAsAbvZUc24/JB7hQrb8PwZoHoNR44nz9F89o5
         6orA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g5si10200322pgk.402.2019.03.13.09.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 09:06:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 9909EE9C;
	Wed, 13 Mar 2019 16:06:07 +0000 (UTC)
Date: Wed, 13 Mar 2019 09:06:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ralph Campbell
 <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, linux-fsdevel
 <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
Message-Id: <20190313090604.968100351b19338cacbfa3bc@linux-foundation.org>
In-Reply-To: <20190313001018.GA3312@redhat.com>
References: <20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
	<CAA9_cmd2Z62Z5CSXvne4rj3aPSpNhS0Gxt+kZytz0bVEuzvc=A@mail.gmail.com>
	<20190307094654.35391e0066396b204d133927@linux-foundation.org>
	<20190307185623.GD3835@redhat.com>
	<CAPcyv4gkxmmkB0nofVOvkmV7HcuBDb+1VLR9CSsp+m-QLX_mxA@mail.gmail.com>
	<20190312152551.GA3233@redhat.com>
	<CAPcyv4iYzTVpP+4iezH1BekawwPwJYiMvk2GZDzfzFLUnO+RgA@mail.gmail.com>
	<20190312190606.GA15675@redhat.com>
	<CAPcyv4g-z8nkM1B65oR-3PT_RFQbmQMsM-J-P0-nzyvvJ8gVog@mail.gmail.com>
	<20190312145214.9c8f0381cf2ff2fc2904e2d8@linux-foundation.org>
	<20190313001018.GA3312@redhat.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Mar 2019 20:10:19 -0400 Jerome Glisse <jglisse@redhat.com> wrote:

> > You're correct.  We chose to go this way because the HMM code is so
> > large and all-over-the-place that developing it in a standalone tree
> > seemed impractical - better to feed it into mainline piecewise.
> > 
> > This decision very much assumed that HMM users would definitely be
> > merged, and that it would happen soon.  I was skeptical for a long time
> > and was eventually persuaded by quite a few conversations with various
> > architecture and driver maintainers indicating that these HMM users
> > would be forthcoming.
> > 
> > In retrospect, the arrival of HMM clients took quite a lot longer than
> > was anticipated and I'm not sure that all of the anticipated usage
> > sites will actually be using it.  I wish I'd kept records of
> > who-said-what, but I didn't and the info is now all rather dissipated.
> > 
> > So the plan didn't really work out as hoped.  Lesson learned, I would
> > now very much prefer that new HMM feature work's changelogs include
> > links to the driver patchsets which will be using those features and
> > acks and review input from the developers of those driver patchsets.
> 
> This is what i am doing now and this patchset falls into that. I did
> post the ODP and nouveau bits to use the 2 new functions (dma map and
> unmap). I expect to merge both ODP and nouveau bits for that during
> the next merge window.
> 
> Also with 5.1 everything that is upstream is use by nouveau at least.
> They are posted patches to use HMM for AMD, Intel, Radeon, ODP, PPC.
> Some are going through several revisions so i do not know exactly when
> each will make it upstream but i keep working on all this.
> 
> So the guideline we agree on:
>     - no new infrastructure without user
>     - device driver maintainer for which new infrastructure is done
>       must either sign off or review of explicitly say that they want
>       the feature I do not expect all driver maintainer will have
>       the bandwidth to do proper review of the mm part of the infra-
>       structure and it would not be fair to ask that from them. They
>       can still provide feedback on the API expose to the device
>       driver.

The patchset in -mm ("HMM updates for 5.1") has review from Ralph
Campbell @ nvidia.  Are there any other maintainers who we should have
feedback from?

>     - driver bits must be posted at the same time as the new infra-
>       structure even if they target the next release cycle to avoid
>       inter-tree dependency
>     - driver bits must be merge as soon as possible

Are there links to driver patchsets which we can add to the changelogs?

> Thing we do not agree on:
>     - If driver bits miss for any reason the +1 target directly
>       revert the new infra-structure. I think it should not be black
>       and white and the reasons why the driver bit missed the merge
>       window should be taken into account. If the feature is still
>       wanted and the driver bits missed the window for simple reasons
>       then it means that we push everything by 2 release ie the
>       revert is done in +1 then we reupload the infra-structure in
>       +2 and finaly repush the driver bit in +3 so we loose 1 cycle.
>       Hence why i would rather that the revert would only happen if
>       it is clear that the infrastructure is not ready or can not
>       be use in timely (over couple kernel release) fashion by any
>       drivers.

I agree that this should be more a philosophy than a set of hard rules.

