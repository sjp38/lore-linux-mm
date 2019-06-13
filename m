Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1957C31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:24:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97E082175B
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:24:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97E082175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45A286B000A; Thu, 13 Jun 2019 16:24:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40C486B000C; Thu, 13 Jun 2019 16:24:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FB658E0001; Thu, 13 Jun 2019 16:24:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 107016B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:24:30 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id f22so31520ioj.9
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:24:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=zvcMD02FpQPsXeNxcEP4PcaHF/GbYyh00HOu0cSh09k=;
        b=KHJFtvoKZ9ya3r3NIBsbOyh8uN2ZBwBRffZb4nI0xiJ3092kafuRs0Wm/rqAoyWT8p
         iba4/Qu7HKkmDyc17ZAoNFuykAiJe3WCHfwAbbK8IbJdNDEhCQZBtWS3tBmPOllZCkyr
         qaPUjs0XB6kMohIpwUqi2i3DUCc+F0nv4eShlfsTp9RajKdLCqq6IEQMBgp/4RtJcDgB
         7OEEZf/OapBdbeOLsBgvj2NzM8U+w+N49eWLzENoNFx/jt4QHui2Em34ysS+07ctsMRW
         SQhVjY8qiVdJD5vJk9B7w/vdTJxg2A/JrtoDfkIqL8ms2nF+vJzlDsfwxnPH0VFOEqG6
         VxPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: APjAAAXB1jWkCtqk+vrcr4hUk07Jl37ez1FX1VOzBxYK/4nKSD3Ieo3f
	tbrJ1vjWxYru+chsgRP12L+nKsNeDIE127jX4V/Z88MnufSnIU4DgfR9+z81P8waoOi7FeunSEH
	Dk5T5pMuclRfxQWJ9tdRvMQoQ2oWNleOstObBIP3rU9UDYP9e8Ib7Oo7I/aEGJoXXJw==
X-Received: by 2002:a05:6602:22cc:: with SMTP id e12mr3805093ioe.192.1560457469802;
        Thu, 13 Jun 2019 13:24:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqqj+TW18VNCK8yHtVSLLd2k+pvPNg4EFcz7d6UPbnVXyN+VGhs8HZU3LwRjbUuE4EIOsM
X-Received: by 2002:a05:6602:22cc:: with SMTP id e12mr3805024ioe.192.1560457469043;
        Thu, 13 Jun 2019 13:24:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560457469; cv=none;
        d=google.com; s=arc-20160816;
        b=TAQrgHB0zrD4IvPoc96cvRwCQ810VgX4eSprNW2ebZLn3zFEvWrY2aV100MA6iX8Uc
         PzTvXZGZyopGxwmKw4cxe/ONbEUTUjFoPjqdDHnx5ktISjHmkQQA3ArPCrqKobwEbyVG
         6fccqmvy2gLyzVGw09Wqvv2hEd3hJ2eYhs3aKklgsnN1R2844oRZU9jiPU61NGIbZj/s
         B0svXbXGqQnk8cFdbnPDmuMsoaZ04qLswlaSZSgfPSSisJK0qGMjvEwCIzj8Z0S2+kQq
         AqT4DmLuEbwQKpBKwymn8pc4KEn5Ede9cBJE2AgGsNUEF4btKAa4XOKOn3Du40AdnARI
         2Esg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=zvcMD02FpQPsXeNxcEP4PcaHF/GbYyh00HOu0cSh09k=;
        b=q++zJS8+91EtYZIhqNA6vc3rNTVktkKMr3kZdRUhj9v1598mJFFd/tMneXpS5jGotU
         0J2JRm3zh8x0pfdCHdLQV6xRyeWGnLwpkzOr6XvXFcnpfeHHYji6VEd6vcizxaCtSEuG
         mMxGFUuq+sKWqdbE3Mo6JwAhl/4VRdGKUmBHSMlWCikEqX7hKiqondflIbIPMp7XeFS5
         JSR8ImFq0dsQgpNxEZKYR0n8/dG4hg9v4yDyFrAk4B+22pkbR0uYDrzf9plorSqynKQv
         eNQjQKsGVOcZSTJe4J/Pv0drU6lUSYOH9nEaPUOZrJQ3apz/g8Vj1COYiMYe4ZUQOT4j
         uPcg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id d28si1070379jaa.64.2019.06.13.13.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 13:24:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from s01061831bf6ec98c.cg.shawcable.net ([68.147.80.180] helo=[192.168.6.132])
	by ale.deltatee.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1hbWGl-00047r-81; Thu, 13 Jun 2019 14:24:24 -0600
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-nvdimm <linux-nvdimm@lists.01.org>,
 nouveau@lists.freedesktop.org,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
 Linux MM <linux-mm@kvack.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
 Ben Skeggs <bskeggs@redhat.com>, linux-pci@vger.kernel.org,
 Andrew Morton <akpm@linux-foundation.org>
References: <20190613094326.24093-1-hch@lst.de>
 <CAPcyv4jBdwYaiVwkhy6kP78OBAs+vJme1UTm47dX4Eq_5=JgSg@mail.gmail.com>
 <283e87e8-20b6-0505-a19b-5d18e057f008@deltatee.com>
 <CAPcyv4hx=ng3SxzAWd8s_8VtAfoiiWhiA5kodi9KPc=jGmnejg@mail.gmail.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <d0da4c86-ef52-b981-06af-b37e3e0515ee@deltatee.com>
Date: Thu, 13 Jun 2019 14:24:20 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hx=ng3SxzAWd8s_8VtAfoiiWhiA5kodi9KPc=jGmnejg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-SA-Exim-Connect-IP: 68.147.80.180
X-SA-Exim-Rcpt-To: akpm@linux-foundation.org, linux-pci@vger.kernel.org, bskeggs@redhat.com, jgg@mellanox.com, jglisse@redhat.com, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, nouveau@lists.freedesktop.org, linux-nvdimm@lists.01.org, hch@lst.de, dan.j.williams@intel.com
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: dev_pagemap related cleanups
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019-06-13 2:21 p.m., Dan Williams wrote:
> On Thu, Jun 13, 2019 at 1:18 PM Logan Gunthorpe <logang@deltatee.com> wrote:
>>
>>
>>
>> On 2019-06-13 12:27 p.m., Dan Williams wrote:
>>> On Thu, Jun 13, 2019 at 2:43 AM Christoph Hellwig <hch@lst.de> wrote:
>>>>
>>>> Hi Dan, Jérôme and Jason,
>>>>
>>>> below is a series that cleans up the dev_pagemap interface so that
>>>> it is more easily usable, which removes the need to wrap it in hmm
>>>> and thus allowing to kill a lot of code
>>>>
>>>> Diffstat:
>>>>
>>>>  22 files changed, 245 insertions(+), 802 deletions(-)
>>>
>>> Hooray!
>>>
>>>> Git tree:
>>>>
>>>>     git://git.infradead.org/users/hch/misc.git hmm-devmem-cleanup
>>>
>>> I just realized this collides with the dev_pagemap release rework in
>>> Andrew's tree (commit ids below are from next.git and are not stable)
>>>
>>> 4422ee8476f0 mm/devm_memremap_pages: fix final page put race
>>> 771f0714d0dc PCI/P2PDMA: track pgmap references per resource, not globally
>>> af37085de906 lib/genalloc: introduce chunk owners
>>> e0047ff8aa77 PCI/P2PDMA: fix the gen_pool_add_virt() failure path
>>> 0315d47d6ae9 mm/devm_memremap_pages: introduce devm_memunmap_pages
>>> 216475c7eaa8 drivers/base/devres: introduce devm_release_action()
>>>
>>> CONFLICT (content): Merge conflict in tools/testing/nvdimm/test/iomap.c
>>> CONFLICT (content): Merge conflict in mm/hmm.c
>>> CONFLICT (content): Merge conflict in kernel/memremap.c
>>> CONFLICT (content): Merge conflict in include/linux/memremap.h
>>> CONFLICT (content): Merge conflict in drivers/pci/p2pdma.c
>>> CONFLICT (content): Merge conflict in drivers/nvdimm/pmem.c
>>> CONFLICT (content): Merge conflict in drivers/dax/device.c
>>> CONFLICT (content): Merge conflict in drivers/dax/dax-private.h
>>>
>>> Perhaps we should pull those out and resend them through hmm.git?
>>
>> Hmm, I've been waiting for those patches to get in for a little while now ;(
> 
> Unless Andrew was going to submit as v5.2-rc fixes I think I should
> rebase / submit them on current hmm.git and then throw these cleanups
> from Christoph on top?

Whatever you feel is best. I'm just hoping they get in sooner rather
than later. They do fix a bug after all. Let me know if you want me to
retest the P2PDMA stuff after the rebase.

Thanks,

Logan

