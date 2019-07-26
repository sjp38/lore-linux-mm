Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FC4AC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 15:45:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 211B220838
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 15:45:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="o+Sw+Ft9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 211B220838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADAB36B0007; Fri, 26 Jul 2019 11:45:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8A808E0003; Fri, 26 Jul 2019 11:45:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 950C28E0002; Fri, 26 Jul 2019 11:45:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 728386B0007
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 11:45:35 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x7so47792779qtp.15
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 08:45:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=0XvBgQp2/E+/Ic94KFJvx3PoeHBC2K6bMN+dYGtrzrU=;
        b=kS0oYxWAZB+7fevVRC/YaZDjcI0By2Z3kKsYsCuGE37g6nSzTpmBGMVKLStNtZtv3K
         08CMscX3aOhwK+Wzu7i7lklgaBATjlqbbrkS2BPVaQEOXEah2+ODKJQn7CIcIxEFgNKc
         URtDtrtm9k3SwLBpPIqiKIfP4PAlaNe+rY8B+nVP999ekh2GhivI+hPh248WfIzDBfUp
         TFvIzaSdWioAbEP0aTkglLnaXlTIVCEjEVNzU5ANxtkymVPsPM6r+rp/bjlLPgWx4bsB
         equxPPUyRe7jK+CV0tUNMKFZTM1gF/n6Zu13bDeSDBHopf1Jd2mrJtgWsM3GYWoRIF0x
         G41g==
X-Gm-Message-State: APjAAAVsRRtQvNnJn7iNEu9NpgWI8MpccDYMwPC7Pu/L26TBhL0jHqTt
	qDHFfZ5LlUtUDjjaMHjGLfQcFW0dgd8huJh2UmOcrcmyP4ByedGhbtpLd+mZQbg7WRxZ65szv5j
	GNz1dndC44WupQ4EN7n1lTDEt0NH703uWoDu5qFw8NRHr3xYUOPimDAiZjsjsOMe4CA==
X-Received: by 2002:ae9:f019:: with SMTP id l25mr64462774qkg.473.1564155935241;
        Fri, 26 Jul 2019 08:45:35 -0700 (PDT)
X-Received: by 2002:ae9:f019:: with SMTP id l25mr64462720qkg.473.1564155934558;
        Fri, 26 Jul 2019 08:45:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564155934; cv=none;
        d=google.com; s=arc-20160816;
        b=B8ylOT0wuDt1Jzj85iZpA49QUASCBypNWHHvmKPwIPgRy2eisJ5u17VDSXZcsgO7nH
         aTbmJ0aHQ+vVINBz8ARVg6mxQJYSjQ/f5kDyGhdbT6sJci0zzy7/GEMd73g251JrgiLD
         XKifB8ZHIJwA2Q1fqFRWJYb3/tWf4D0jRvZt5f1MFrtmoxDNUs06r+Vcw15UjZfnFUzv
         TZxmj2g7orcQ9Q+KyQgmwYkdWZJf1eJGiumW/woarpeQr4c1oZSOom8XQJHFZx06IdcK
         VF82NVmx2VNvAYRjTmc5SNRwn2JpddKGtMuz+zt7yTgeKszsPfQewRNFWdUHfzUt4dQ3
         9zRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0XvBgQp2/E+/Ic94KFJvx3PoeHBC2K6bMN+dYGtrzrU=;
        b=MOor8y6eErM4WMx1+sJcDFbGWUh4jNH3v6SC98iQW4fHhgiDG1zU/C4ELG/LC/LFm0
         pk30tf2OCVAFw+7YKHL1YRelHL02nL/eUxuKRp3ORUwxjl+SeGU3qjWj/x2KGwzE6QSZ
         c8TAy2cmBmxvxnQKzdWuxyp+6oCWamUYU47Xr2ZoO9lp1Hz5RXww73z3SSdPDNtknzwG
         HPP4Nab4gyd6dZ4qFml0qF5WvO7XmEjAhV0B4wx2dBbDRulCVrXOl9uY7U3RwTuKCf60
         n5AVKzC7ipKSuYFndyK0HDBmecG2Gl8y5DVYArOa24PCTPuy9Q8nlrsIVPwFWH8uwB1x
         2vLg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=o+Sw+Ft9;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v31sor12459765qtj.59.2019.07.26.08.45.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 08:45:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=o+Sw+Ft9;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=0XvBgQp2/E+/Ic94KFJvx3PoeHBC2K6bMN+dYGtrzrU=;
        b=o+Sw+Ft9tBTCMfQnjjV7hQQHUdyNoWUSjIb4imOvsb2LbKFd1Q5NbuyDRu/AsB0VyP
         URzry2DDvBoWY/MzinDkwxqdipoU7eQxWimCd8F9Wq4pH2nxNhL0VEiztP0eXgfDnVhe
         qmeSCQ2RfaMf6HFkHqhsbZs1xw/iQNrwM9UEb0q7YJO4WRAfVYJT1pLZHckgpLWDFEW5
         ezBU84Ow58+f91moEdhmpcwYTGEj4uyoRch1AjlQz/y6ZgqBFNCIZvJUNmWtnVdWYvE1
         CtR3H87yaXERTd9RsoCTTWIViWcACY1Iwet3M5jz6s3WZSDa8csEbMTwgddUyXEsLr51
         dtdw==
X-Google-Smtp-Source: APXvYqz8sQPW4m3GzwcT9XhmjAeoy2UAD2U4rkt48bJMq/KWyyCMGm6hjyKnT+STDp46Ymz4NgJRKg==
X-Received: by 2002:aed:33e6:: with SMTP id v93mr67774336qtd.157.1564155934207;
        Fri, 26 Jul 2019 08:45:34 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id a23sm22076094qtp.22.2019.07.26.08.45.32
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Jul 2019 08:45:33 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hr2PU-0007qj-F6; Fri, 26 Jul 2019 12:45:32 -0300
Date: Fri, 26 Jul 2019 12:45:32 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	nouveau@lists.freedesktop.org
Subject: Re: [PATCH v2 0/7] mm/hmm: more HMM clean up
Message-ID: <20190726154532.GA29678@ziepe.ca>
References: <20190726005650.2566-1-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190726005650.2566-1-rcampbell@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 05:56:43PM -0700, Ralph Campbell wrote:
> Here are seven more patches for things I found to clean up.
> This was based on top of Christoph's seven patches:
> "hmm_range_fault related fixes and legacy API removal v3".
> I assume this will go into Jason's tree since there will likely be
> more HMM changes in this cycle.
>
> Changes from v1 to v2:
> 
> Added AMD GPU to hmm_update removal.
> Added 2 patches from Christoph.
> Added 2 patches as a result of Jason's suggestions.
> 
> Christoph Hellwig (2):
>   mm/hmm: replace the block argument to hmm_range_fault with a flags
>     value
>   mm: merge hmm_range_snapshot into hmm_range_fault
> 
> Ralph Campbell (5):
>   mm/hmm: replace hmm_update with mmu_notifier_range
>   mm/hmm: a few more C style and comment clean ups
>   mm/hmm: remove hugetlbfs check in hmm_vma_walk_pmd
>   mm/hmm: remove hmm_range vma

For all of these:

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

I've applied this to hmm.git, excluding:

>   mm/hmm: make full use of walk_page_range()

Pending further discussion.

Based on last cycle I've decided to move good patches into linux-next
earlier and rely on some rebase if needed. This is to help Andrew's
workflow.

So, if there are more tags/etc please continue to send them, I will
sort it..

Thanks,
Jason

