Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56FFFC48BE2
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 06:33:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D8642070B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 06:33:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D8642070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6444B6B0003; Thu, 20 Jun 2019 02:33:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F5018E0002; Thu, 20 Jun 2019 02:33:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E4268E0001; Thu, 20 Jun 2019 02:33:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id F2D8E6B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 02:33:07 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id t4so764514wrs.10
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 23:33:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uLUPTxU2N+zCGOI+R+1Rpte7sIhhFJUQFrROi2j1rMg=;
        b=S0BcgQACCEvhaZO98LbtPdREVfEr6QX+qi1LFonOcvNeq8PYMcDSKIeEjHwI0Gizog
         lkZZ56LeVdX8OCXKJHrG/6wqLv8gDqGV6nlZrOY+CgksIdI9fQqftSVurJlNJlV51kAI
         9fnHM+B1OzHPLvGr3ZU/3g9d5ibmIrC/Rl1njZ/9cTAe9J2u5fuiyon0nGFkPX/5aQ6Y
         N3wwimHRS1Jw4O1ophJDvVC/GqVbVcd7UKoYTvc3GXMrzwe5nRI1/8k4KMZgSNr1CeO1
         thQM33sSnzc7wcKHwETY9l+0/sEoh+DptOXvuC4yv9mkHC/H9JPTwYHOMVE/hFa5WkDt
         AS+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXXX7IneX+Rsm3c4YmxtVKkejK+4tGv/OnCXzQPfYyydaDQi+Ze
	W15wJZiC97z1g+rn7/bljU8B2hvePXsGbREjm85SKGmX3p4fO4SewBcob+I89iRnJ0kYeFEUWWE
	ixK2BRB7uet2qFHyLjTmneDRV6AhSC8CJDeiogpSRvV3o1RG5wQUh7ycACwjKtyc51g==
X-Received: by 2002:a5d:4310:: with SMTP id h16mr25892870wrq.331.1561012387593;
        Wed, 19 Jun 2019 23:33:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztUxNNj9oR1l7A3/82QSlaQdCXWoHWnbqzN3Saao7cyyfu0OUE4js1tPV3wG2DwTW2xgn9
X-Received: by 2002:a5d:4310:: with SMTP id h16mr25892792wrq.331.1561012386617;
        Wed, 19 Jun 2019 23:33:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561012386; cv=none;
        d=google.com; s=arc-20160816;
        b=RnyGkE7Ne3IILwBfjMQ8jARx93K4XwRfISyTHM6binJOQ5aq3fbCTETfIdQKU7PQBp
         HcTimoq3b51+aZel0sPzDB2VfgFJy5/y0MxqT6+LogKZIME45eI7ILmOfZfpgd1FCigK
         8b31ZVyT/4LXvG20LjXbix8X+au8yAy0PQEl0a/Wf2KBmLC/NjJ7MmRaMwQFaJ8nEVj2
         9GXUL0sY3I5QV+C6iYRlraLMx9WXM7znF2uuKEx5Ah2V0etzjzBdYWEmduP7DkLgn9sq
         GR60xzpzWlsrhLVSlIyMGO2bgmpAClqUQh0OcWgEXDUyrQqYrhhikiJwzey8V+qSZtzi
         3xUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uLUPTxU2N+zCGOI+R+1Rpte7sIhhFJUQFrROi2j1rMg=;
        b=ywGCvnkvu9+FRKB0ZHe0bHr5uvEs0UbkBC9c4WVENSksY9LrZbNhhABmbDLkrvMFAg
         BLXmC2d7vqeN4LjIpR9z5D/r7bsuC/xUYxlLBrhqlpebcU56A1xZtaz4A10YXVELfySZ
         CbtBAfELCroEbw5RAtOCuTyVRAHE8Ee2hLaOxWhEYIYfvpWh1BDxjzrDmLdK/ntsKq+M
         TSPxBxHq43y91cZEYwlRA0DUU+4VWv/3gjXRyCYlmOOag/ZZDL7NS5gps0DdvTreBWhW
         F/E2ZH18sWkSPPCpjgACd6HgIWPnRUnnGHyZfob6jZMbShIbZI5xWSO1dD9PkNUom5jz
         wqfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 3si2620003wmc.43.2019.06.19.23.33.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 23:33:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 0877068B05; Thu, 20 Jun 2019 08:32:37 +0200 (CEST)
Date: Thu, 20 Jun 2019 08:32:36 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>,
	nouveau@lists.freedesktop.org,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>, linux-pci@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: dev_pagemap related cleanups v2
Message-ID: <20190620063236.GE20765@lst.de>
References: <20190617122733.22432-1-hch@lst.de> <CAPcyv4hBUJB2RxkDqHkfEGCupDdXfQSrEJmAdhLFwnDOwt8Lig@mail.gmail.com> <20190619094032.GA8928@lst.de> <20190619163655.GG9360@ziepe.ca> <CAPcyv4hYtQdg0DTYjrJxCNXNjadBSWQ5QaMJYsA-QSribKuwrQ@mail.gmail.com> <20190619181923.GJ9360@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619181923.GJ9360@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 03:19:23PM -0300, Jason Gunthorpe wrote:
> > Just make sure that when you backmerge v5.2-rc5 you have a clear
> > reason in the merge commit message about why you needed to do it.
> > While needless rebasing is top of the pet peeve list, second place, as
> > I found out, is mystery merges without explanations.
> 
> Yes, I always describe the merge commits. Linus also particular about
> having *good reasons* for merges.
> 
> This is why I can't fix the hmm.git to have rc5 until I have patches
> to apply..
> 
> Probbaly I will just put CH's series on rc5 and merge it with the
> cover letter as the merge message. This avoid both rebasing and gives
> purposeful merges.

Fine with me.  My series right now is on top of the rdma/hmm branch.
There is a trivial conflict that is solved by doing so, as my series
removes documentation that is fixed up there a bit.  There is another
trivial conflict with your pending series as they remove code next to
each other in hmm.git.

