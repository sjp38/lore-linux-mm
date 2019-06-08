Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68A26C28CC5
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 11:33:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3E092146E
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 11:33:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="cQto6lY1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3E092146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46F366B026A; Sat,  8 Jun 2019 07:33:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 421326B026C; Sat,  8 Jun 2019 07:33:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30FC86B026D; Sat,  8 Jun 2019 07:33:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 113C46B026A
	for <linux-mm@kvack.org>; Sat,  8 Jun 2019 07:33:09 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g30so4285311qtm.17
        for <linux-mm@kvack.org>; Sat, 08 Jun 2019 04:33:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2lXGspEHCJbsk8rcUX58kNgJSDj9yX2lNCrXRKPLPfY=;
        b=BkwD+wId9v9emK3vUF8EumSj5C7dCcAltkRs3JfqTPPjroP1dnNqtoXOuw7yvH71OG
         +Rh0Iq8mewEdyLnymajYcPeWvnL8dL20Sp89rBcwefMQg4T8yuR7AYOV8t4jfYIiT3VP
         ogBddIKpOCbWiMuAOVXQR9DIOtKkdmucSj2zhnPson19SCuM+JdKUnCpm+ZiptOZJXGF
         QJ4WQGyZY12nQNlvSuNPFaVdTQpLAIZLkaD48czzZDCrKPCM2kgTFHjjWqRammu9479o
         vO8+yosxeQmvWR2/9tB9Z/zVxLFxYoUXz5Ex7C9IN9CmGVnlCnoc6la5pLIC9WLZcvC5
         35bg==
X-Gm-Message-State: APjAAAUt7cdDpRD/Iqf0IjIulo8/KhzZJodbl2iCCHCAmnR2AEmkNkPQ
	SXnbgMUNnoyxx3uRjS+f3FCqDVfPsOFdO93J8w3VbciHAqH+vzISEEt/oOvNkWSO+1wMN0agy1t
	Q0b+ZAOtFr8RZIilpLB957kXgyQVY9dM8cCADSzlvVAC6Ii79JEsq/rPAjPm5tU152g==
X-Received: by 2002:aed:23ac:: with SMTP id j41mr24055188qtc.200.1559993588856;
        Sat, 08 Jun 2019 04:33:08 -0700 (PDT)
X-Received: by 2002:aed:23ac:: with SMTP id j41mr24055114qtc.200.1559993587701;
        Sat, 08 Jun 2019 04:33:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559993587; cv=none;
        d=google.com; s=arc-20160816;
        b=um1+WSQfiveLFe3F6ONDY5WcOtqf4+w7StIAl5pmfbPDbWYYL/i4HqYVCNy96a+sBP
         vQcpL5DLj9elscYfQB6qstJLfFkrA1mMkYgUDAXST6DCSKRomOYtldcBlWBWdMtQq27H
         ZPhE1Y6rgdtBiFHqMZUhxRgANU6FDmPLGI7DQnXZ/aeQkdDAHmtUDSUZa4D1G/A+KnMW
         bWkgy0i7Xruxak90ka5s60Uu5BA51SMWKcHdIqLj5OkrRJbZ+mplkcvwVVGlLjDZ9Dog
         vWrX9O6NuJB1qC8F5fTD3KQSa/Ffa3kUu/1/AQrOlT1I+gnAsbvO6Jc88I+Idt3CuSq5
         2AEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2lXGspEHCJbsk8rcUX58kNgJSDj9yX2lNCrXRKPLPfY=;
        b=o5rcpVhDYLxUWybokKCA1VjdHbsh6lB+cge71zusmAxpM5S6M1USKHMnA8uOiEqqTk
         v2afsYvt2CLipvNdTyknhgIHNFzpw5Ud/3fTUve0QHd/4msy/BWzMfb3vtOZVjOAmQPO
         KxDqCPZs1Rpxqvi8dyRLhBvlNlgEjTGpnA9GRI77ndqN/VQqOv0/g7/X0RIMR+zF/xqx
         Prv+l5jqsDaiejftRGV6bTVQ58909cKvH6m02YarPi7Dv411sFNA/NzFXezt4trrrkEj
         n1+TgF5zwuzLq2/kT5H+DfsfA09ihDKLpQexhgzSoY1N9I3jZRgCJk7nvLSZn07z64Es
         nSXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=cQto6lY1;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e32sor3871082qvd.40.2019.06.08.04.33.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 08 Jun 2019 04:33:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=cQto6lY1;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=2lXGspEHCJbsk8rcUX58kNgJSDj9yX2lNCrXRKPLPfY=;
        b=cQto6lY11nB7CtyFVsb4EWl/wSLEbWjYy53473tDxhVa+M8kUBtzMhsyB4GzDkwDxV
         q+kMV3+bqlucZoGG+l3NUydWUmA01Kdk2/AmaOWjogGX9cZ5VHeo4NXfNrqxa9973eio
         jEWacea/Hw5cMfA8v2U6v7fZH/FxhaA8zRa/sqGqp9oG8OkETGNmhyB3dR63HPNpwJq3
         bTef+d3XCAUCKnqZ2kfsu5R+6/Una6mdshi9VfoOWhgkoKLdvmGi1Faluq9FD8FSmrwe
         Lml1z8nOCaJ2hrr3JC/PpvYRD94dpvVxrBx2HEhfbkPIJl6PJI/3BtMNPyc9TsLDPXIT
         qE0Q==
X-Google-Smtp-Source: APXvYqxyYPohAHdX/cPPDfW1JlnojtSPLPS5vSeQSfnXomKNh388kBmPHyLX8ufWHVYbMbkJEo8bCw==
X-Received: by 2002:a0c:c164:: with SMTP id i33mr30155410qvh.37.1559993587190;
        Sat, 08 Jun 2019 04:33:07 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id i55sm3386912qtc.21.2019.06.08.04.33.05
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 08 Jun 2019 04:33:06 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZZar-0003rc-2C; Sat, 08 Jun 2019 08:33:05 -0300
Date: Sat, 8 Jun 2019 08:33:05 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [PATCH v2 hmm 01/11] mm/hmm: fix use after free with struct hmm
 in the mmu notifiers
Message-ID: <20190608113305.GA12419@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-2-jgg@ziepe.ca>
 <20190608084948.GA32185@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190608084948.GA32185@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 08, 2019 at 01:49:48AM -0700, Christoph Hellwig wrote:
> I still think sruct hmm should die.  We already have a structure used
> for additional information for drivers having crazly tight integration
> into the VM, and it is called struct mmu_notifier_mm.  We really need
> to reuse that intead of duplicating it badly.

Probably. But at least in ODP we needed something very similar to
'struct hmm' to make our mmu notifier implementation work.

The mmu notifier api really lends itself to having a per-mm structure
in the driver to hold the 'struct mmu_notifier'..

I think I see other drivers are doing things like assuming that there
is only one mm in their world (despite being FD based, so this is not
really guarenteed)

So, my first attempt would be an api something like:

   priv = mmu_notififer_attach_mm(ops, current->mm, sizeof(my_priv))
   mmu_notifier_detach_mm(priv);

 ops->invalidate_start(struct mmu_notififer *mn):
   struct p *priv = mmu_notifier_priv(mn);

Such that
 - There is only one priv per mm
 - All the srcu stuff is handled inside mmu notifier
 - It is reference counted, so ops can be attached multiple times to
   the same mm

Then odp's per_mm, and struct hmm (if we keep it at all) is simply a
'priv' in the above.

I was thinking of looking at this stuff next, once this series is
done.

Jason

