Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCED8C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 17:34:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62FA920685
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 17:34:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="sd6erl5p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62FA920685
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 024F06B0005; Tue, 19 Mar 2019 13:34:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEE346B0006; Tue, 19 Mar 2019 13:34:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDCA26B0007; Tue, 19 Mar 2019 13:34:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id A9C066B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 13:34:10 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id v1so4817709oif.12
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 10:34:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Z8tMgR2jQ7qbI4Vk8rLBRaN7IkiS+UfqkL6XnvCw5WA=;
        b=sP6CpAyW/VgsKDyDR8uVEiSYf/Sz5MgaQ3oLhZrCBy3/ozQqNfSHRS182eEVUGi87g
         j2Gzc4qXntzvj/I0vsNEtwl616aAQ+n6l0i4+ckAwILOzAFEdqzyb4CFb816stFsvS+k
         /zvxdSl1jsn/ZEItr2kqyFJLcPkDTeCMDGD5eTC/YVdGqZMikb2z2TMjsvLv7cyE+Kgx
         bnNLOSej0fyri4TVt5urq9kC5purQ0AbQBYPqGN7G2ROauV/qMV04BQRLECd9ez7ZeVW
         SEagL6UDJb63+SjWSkOPYqB39GAivqgrHCrQoB9Plg2F5dEA505KUPQnPqaUpSo2D2Ja
         L3XQ==
X-Gm-Message-State: APjAAAXVomoEis6R3U7gOqnvT28ESM4cqjM0ua5hhx0hIGZnKUiVc+PL
	zDbkGomZveaX4YN7fkDEUJea4KinKAhFylbUX9AiJlwO3xbzqETLqHPTy5hIKX8wabADy+RVQ0j
	a4re0RAXGJY0PF+GaXmfj5abr/CQlJDDdo5CTRgOgh0K48/wPDBWh9xRncrf7U+13yw==
X-Received: by 2002:aca:edc7:: with SMTP id l190mr2349127oih.92.1553016850285;
        Tue, 19 Mar 2019 10:34:10 -0700 (PDT)
X-Received: by 2002:aca:edc7:: with SMTP id l190mr2349083oih.92.1553016849435;
        Tue, 19 Mar 2019 10:34:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553016849; cv=none;
        d=google.com; s=arc-20160816;
        b=rBGk9skjP3ZWE8TT0F3jSSG9QWPdpG2Bn44lpO1f3LMLwvVLHHKNduirDMqyJqX3eH
         p1e9LgeRK36mivqAZekmgzLYrRaYThXluJEKAkMTAGPxcQOTSwaaOEvtGHlHFt6uqCs8
         gAU/pJd+iq4NiH11QOE/uymto+Jd1/uhWLFxQccKsgkjk8gXDWdGY9RlsQlAxEDFNjtJ
         igU6FAWKR72fPJKeZ99uR5M+vrufuLWHvIDWsz9I98X/7LfkXxqD3dHDpotGNB1/4mQv
         c8pLgk6xLqaPl+5JOT9gEe+Ud4EQbg8FAWdEk01TaZTJAi0uof8UoLl1/QKA12ST4EgN
         8rIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Z8tMgR2jQ7qbI4Vk8rLBRaN7IkiS+UfqkL6XnvCw5WA=;
        b=w0l3cTHckvnZp8OJF5VIEwzFrt451sjxpQxRjD2DiBcg75y8X1GcPni0b/EM1yxKhi
         9B8alUZ4D/5ePX7jbXCkGTIwd5d/0bGh+5SbmwyCIe9huxElnhndN0/Ym+HlPo+E9qjk
         NIZVTIOvxMeDMdwSj8rp23cybJSnMJ3AVA73lpZMOOf7uD6g3x8D7Cdlz1pMHOGR0pnA
         d8QCtduB+lUqjpKvF83Wnk4enGwUVG9FSZb44Pjex+8ynQcx1sV75X+bCkt1/aTWxtn0
         EduqGTUoH7cJnIxZDQjf73B5hZTrurL3695F86Y3wqExZzVjaCQe+fRna4eQnTgXhtEx
         CyAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=sd6erl5p;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j21sor7920246otn.49.2019.03.19.10.34.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 10:34:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=sd6erl5p;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Z8tMgR2jQ7qbI4Vk8rLBRaN7IkiS+UfqkL6XnvCw5WA=;
        b=sd6erl5p90ODa4X9rLL5PNnefwn2xpM5rzFHYDKW1il9SN+IjS81qvSWCiqL2a5zsG
         e6/jqjSFEdTp8yJcUzeafS4mbluGKJ4a2IEWQLXByCp6ERcA/W36tCuRJ+bO4jSRRVHG
         bYGgHwt85rtSYnJCptdiIpLo8DyJdLTM+daZgZOPO76M1mdIgUnPenogjSrtepNx9zXD
         BrgRfsSSEqFrGZ8DgZzweqxKmbP0iE4cXKRoW88XW0rlbWBXBp+SKGA/Ja2UsxehsCg/
         6CAHyNXw+DiwWe5PE1T/se5S+4uD2ijnKv0u1xqCInsGYhemYbH2NfHic9scwW78vL5i
         BK9A==
X-Google-Smtp-Source: APXvYqwzgOn/nZ0ayGb5IqIAEXhqaIOpkNKvk+7zxMCPkmOTNxfkdseeIENR3VAu8FM7ml93AzeEPa6VcEXGk835FT4=
X-Received: by 2002:a9d:2c23:: with SMTP id f32mr2407745otb.353.1553016848952;
 Tue, 19 Mar 2019 10:34:08 -0700 (PDT)
MIME-Version: 1.0
References: <20190129165428.3931-1-jglisse@redhat.com> <20190313012706.GB3402@redhat.com>
 <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
 <20190318170404.GA6786@redhat.com> <20190319094007.a47ce9222b5faacec3e96da4@linux-foundation.org>
 <20190319165802.GA3656@redhat.com> <20190319101249.d2076f4bacbef948055ae758@linux-foundation.org>
 <20190319171847.GC3656@redhat.com>
In-Reply-To: <20190319171847.GC3656@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 19 Mar 2019 10:33:57 -0700
Message-ID: <CAPcyv4iesGET_PV-QcdBbxJGgmJ_HhoGczyvb=0+SnLkFDhRuQ@mail.gmail.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Alex Deucher <alexander.deucher@amd.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 10:19 AM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Tue, Mar 19, 2019 at 10:12:49AM -0700, Andrew Morton wrote:
> > On Tue, 19 Mar 2019 12:58:02 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
[..]
> > Also, the discussion regarding [07/10] is substantial and is ongoing so
> > please let's push along wth that.
>
> I can move it as last patch in the serie but it is needed for ODP RDMA
> convertion too. Otherwise i will just move that code into the ODP RDMA
> code and will have to move it again into HMM code once i am done with
> the nouveau changes and in the meantime i expect other driver will want
> to use this 2 helpers too.

I still hold out hope that we can find a way to have productive
discussions about the implementation of this infrastructure.
Threatening to move the code elsewhere to bypass the feedback is not
productive.

>
> >
> > What is the review/discussion status of "[PATCH 09/10] mm/hmm: allow to
> > mirror vma of a file on a DAX backed filesystem"?
>
> I explained that this is needed for the ODP RDMA convertion as ODP RDMA
> does supported DAX today and thus i can not push that convertion without
> that support as otherwise i would regress RDMA ODP.
>
> Also this is to be use by nouveau which is upstream and there is no
> reasons to not support vma that happens to be mmap of a file on a file-
> system that is using a DAX block device.
>
> I do not think Dan had any comment code wise, i think he was complaining
> about the wording of the commit not being clear and i proposed an updated
> wording that he seemed to like.

Yes, please resend with the updated changelog and I'll ack.

