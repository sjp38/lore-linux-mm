Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DA5AC48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 18:31:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 613482086D
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 18:31:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="EH3y4zD2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 613482086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EAAD6B0005; Tue, 25 Jun 2019 14:31:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09ABD8E0003; Tue, 25 Jun 2019 14:31:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFA158E0002; Tue, 25 Jun 2019 14:31:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD4F86B0005
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 14:31:16 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id 133so23425921ybl.8
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 11:31:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3tJadmfIaP+3cUt4e6djg3uYwSGFYlA4L4PJ/03vX94=;
        b=gz2kuuJX7U571OjdL7ViocLmqB7FVqjssqWDDljTcAvRZfxRSod048BXeICW7fsHWi
         DwbyOMuRHje4Xh739yOPOmkNxJvpcC/bm/419Un9vVGkaC8KR+3DMQd8RLRaKS15k3NR
         8gi0v+9defsPqA7+hLWMnIlL7Hds0i0JOwWlu3hWeYK3mMVymRvjMR43Md4sY1tyIHNK
         4VukpwIFu+RVAjyz+74xL4acKrYsVC+I7Amh0AbqE9l+BEGRtD1ko1sZ5+Bjmq0zf017
         sWVAknlemu6Yfp52cXy+6kkpZyi0zuKUD7vzmtLCNt6/U/ByhRSjqg52bd5TJpS18SmU
         0cyA==
X-Gm-Message-State: APjAAAU4n/FqypJ+rPV9z6Z8xZafiLRfpCPwSA/1OUl7FBEN15NgHBZM
	4EFYHwQmrABZhmZDa/KiSwKm+o68daYeUa7CUxmapaXe9nF4IQRhvVq0ysEqg1FY1weUYpGjmKy
	IQu8bHHG/hnWMk71qwCxxkx+ePTYcR9EOPA/1JzJ0FfSvtdW2j7N0K717/DMAVfBaAQ==
X-Received: by 2002:a81:924a:: with SMTP id j71mr72315ywg.5.1561487476605;
        Tue, 25 Jun 2019 11:31:16 -0700 (PDT)
X-Received: by 2002:a81:924a:: with SMTP id j71mr72281ywg.5.1561487476103;
        Tue, 25 Jun 2019 11:31:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561487476; cv=none;
        d=google.com; s=arc-20160816;
        b=irwmzSiP7Y5Z7RBkAhF4GgenhY9GhPIi2ojNk5Ho3p/Iow5yquSD+ohqORy9dUEHX5
         f6d6VJNDl0Va87X5J704N/T/wUG+uZIgsjtWeggCad4sEEvmYKMHbOGQOME2w/euQiDK
         0G5fZNxJJer0ANAx2rivX641YqgHGJfjXMBC1BtH5TlUl88Ov7wzabj/7KthwWvEeKfc
         sVoRgrOWDW2IwwBbovlr2LqT+bhIZNP6L8QEBXhjC3Dn3m14rf/wFyB4rD46s1moFPXq
         FTNQME9eA9MEN49y/Ty60fZLPDrNCX0Vthe+S3mxHQL+0r1moASVotclPvOmRvMztXCa
         fHCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3tJadmfIaP+3cUt4e6djg3uYwSGFYlA4L4PJ/03vX94=;
        b=YlxswQWRsN5d1KBBTHpvplP/CnFcCxD1Wabq+4fonje16RMvj6MFHmhL3FguMHfmkG
         /o0cKFnpvxKuFQdo9H8YWhOEjHZaAUkNP0Z4jgA2LJAUM9+6SAZ4PJoM+ietL68vm6JI
         hxdBlgTFqyhdXUpyRCROYD9SNKxfPB7bsttNnExjlHoupdhDYCIuBZ39VhdtcjqJwji/
         TKaAZyVarRWSM4Z80QASOk0Ujn9l4qcWCckxZHF5z+PoDls1LIYIxf+R123bynXwjG3B
         /MvqSTw7kV7ZFFL+1JXRirxO4Bl7tin1zcN2RcBW0R5y6/otr+a+CpDPiD0S8ZEkheC4
         EJ3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EH3y4zD2;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 189sor7679619ybi.56.2019.06.25.11.31.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 11:31:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EH3y4zD2;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3tJadmfIaP+3cUt4e6djg3uYwSGFYlA4L4PJ/03vX94=;
        b=EH3y4zD22YVqGG+RHMfFEthpglof2dKKJrLZODUIcgdQyL6wvrwdMmPysZQFNoc2BK
         03B4jdpd9RdUOnaQHMk/k7zYWHUxDFiMN85zh3eBas/KoFrA9RJ4Oh4Pay55XRPXrnUI
         kRlCCKZ1Q4xVqcRZg8cDczj/dp10i2E+bDt59cYKTPiX6rijpqiPa6Ng7hdxL8GVQzUO
         zK9o82cg7pIIab6+dGP9KB9qKEPh3aSRQEHXkMhIV0F1KB7EmBXM4kjp3LTaDvVnAmAq
         kYmt9k9R+v75ZAK5NW6TNMmnsYyEtKQ58mOIhfE0GXIPY85W1HBMHmw6ubXTAGPWdpdB
         i4lQ==
X-Google-Smtp-Source: APXvYqwNG1kh+k/L+YnZbCVrDwBuWFG+WXRj+Yr7jmS6YTLtMJlpnmTuApTpCOI2UGQ8fp1IdBSvPwZbls9jENi5vd4=
X-Received: by 2002:a25:943:: with SMTP id u3mr82067600ybm.293.1561487475490;
 Tue, 25 Jun 2019 11:31:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190611231813.3148843-1-guro@fb.com> <20190611231813.3148843-7-guro@fb.com>
In-Reply-To: <20190611231813.3148843-7-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 25 Jun 2019 11:31:04 -0700
Message-ID: <CALvZod6wR7th1JF407-_i9PfbCzAiakU7mD2HBshH+jW9db1bw@mail.gmail.com>
Subject: Re: [PATCH v7 06/10] mm: don't check the dying flag on kmem_cache creation
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Kernel Team <kernel-team@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Waiman Long <longman@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 4:18 PM Roman Gushchin <guro@fb.com> wrote:
>
> There is no point in checking the root_cache->memcg_params.dying
> flag on kmem_cache creation path. New allocations shouldn't be
> performed using a dead root kmem_cache,

Yes, it's the user's responsibility to synchronize the kmem cache
destruction and allocations.

> so no new memcg kmem_cache
> creation can be scheduled after the flag is set. And if it was
> scheduled before, flush_memcg_workqueue() will wait for it anyway.
>
> So let's drop this check to simplify the code.
>
> Signed-off-by: Roman Gushchin <guro@fb.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

