Return-Path: <SRS0=PcJq=O5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E554C43444
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 16:57:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 395E020815
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 16:57:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 395E020815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D96428E000B; Thu, 20 Dec 2018 11:57:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6C608E0001; Thu, 20 Dec 2018 11:57:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5AD88E000B; Thu, 20 Dec 2018 11:57:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9FCE48E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:57:43 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id z6so2439802qtj.21
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:57:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=5UbIDI6QU5NzVjjN0qX6yXGBQ6ZjXMG1WD/RiUKbPCk=;
        b=ei9mEqnO7a1nF3ECRasKJptSkhe5UZdabOHKogLvBUh5V+ma3gTCLJtxYVHZBv/lG8
         NSxB9eqkcUFi/xaieMwR8qfo+yL2wsrcl87n66n2k5K1wMyDX3DR38nc2hkhesjr3vhX
         YLpyUoLbk7CRoG+MVRZBIvvJv4qUesKZGDV1fJ7g40Ld3NYQojQpLZ34F1s+u+xQPRO9
         HvwoI8yUXC2IHCZlN1YC/s4Qa1q7Zperdr3WnjbPpKdht+OcOqMiqGguf+u6UfgdRHRb
         ur2g04drr0jK5E3RWDx1ToKqxHpwIn06oz3doptc6PrpXtIPg7WBq4gWr87fT2ur8NUu
         +zGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AA+aEWaOCOU1Kdr5wtU48arBLYioET1Ndph1knQztuw55f9Q7fElCJ9J
	g4U1+I1XCnDvotXRZOsm9LsBJRW2vH+71RGLlooBj4Kv59njL2RWCymW6TL95zhPaVlS7modpxY
	4TKiitEspQX6QNeWduieDcaf4AeAtMC0SGzqKRbyIH3dR90THOrCq378h5b3N8i1qUQ==
X-Received: by 2002:ac8:4141:: with SMTP id e1mr16813238qtm.96.1545325063462;
        Thu, 20 Dec 2018 08:57:43 -0800 (PST)
X-Google-Smtp-Source: AFSGD/VuyLHWPHZ/hhj44gG99DMEKTCOX6v0bk8BuNYnsI8YnoImVE0CwsddSgjIL2cWkcNpJ01L
X-Received: by 2002:ac8:4141:: with SMTP id e1mr16813202qtm.96.1545325062862;
        Thu, 20 Dec 2018 08:57:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545325062; cv=none;
        d=google.com; s=arc-20160816;
        b=K8e1D7b8oSgi6SkL2KFyYu2HRHbBuNvg9Bhh5hYKdlRe7/9rM7otHNDZEdP3pIDlLk
         Q+Rfs59Pp9gwmUPSZm1affUz82kopZ9yvrA4XcWP9tREP8vcrSN07txqlQLEVzo4oWWV
         0LWcrXVjT2X1FzsQSQoboWzQH61XU0Rs/fT0LpGMTx+vfReH9Z1fA6WszZs0lyZXhfgf
         AeVmYZFyJDCThlzeGnwpk+/xaTqdKcz3GgjwwJOqx8nChsGHVUWTjh3WP7q3EdPObUHQ
         vNZ6lD0OMVGTTHcCnUrvmCYnCfu+dSsgq6lg+7kL5m2195nmL+zlvA/+f2ngQIhA81DJ
         1+1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=5UbIDI6QU5NzVjjN0qX6yXGBQ6ZjXMG1WD/RiUKbPCk=;
        b=skT9TRH93gfJtBHScH8KQUQM9FnF2fgm7Cw/2I6R5wDjJZJ1BBQ7SBPYeYcykPlW+f
         tnsFZcOAalWP6iDDJxxacFH7T2NKNdAmxn0QiLO/Uf1Iy1EGo1q+0e+t80NmUEsyJbX4
         E89uvvtnnwvHk8jXwdycpdOma55cUbncWs7qYgL5eHoUylRJDeDNiRojYg2sMPwFIC86
         RGnoTuCs7ZHONzVmxcK90z/xbe2vHiYTQTP0S2CNj21rDsxOq5XFzfO4U2K8vGIMpA7X
         C8rbL41tJ95A2Eqk3RFifjBAGR6+gKLU2ijn4q6IEVtivphbeSF2rP77THMU5n3lhXtb
         KpHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t82si1134564qkl.141.2018.12.20.08.57.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 08:57:42 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E4E5B7F771;
	Thu, 20 Dec 2018 16:57:41 +0000 (UTC)
Received: from redhat.com (ovpn-123-95.rdu2.redhat.com [10.10.123.95])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D20A626FDC;
	Thu, 20 Dec 2018 16:57:40 +0000 (UTC)
Date: Thu, 20 Dec 2018 11:57:38 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Balbir Singh <bsingharora@gmail.com>,
	Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [HMM-v25 07/19] mm/ZONE_DEVICE: new type of ZONE_DEVICE for
 unaddressable memory v5
Message-ID: <20181220165738.GE3963@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
 <20170817000548.32038-8-jglisse@redhat.com>
 <CAA9_cmeag7n4yeiP6pYZSz80KyxqfwbsXJCWvyNE4PSaxCKA3A@mail.gmail.com>
 <20181220161538.GA3963@redhat.com>
 <CAPcyv4ipg7smdCZTLeEogKdsKJGrCpaDKaghbTjrM8wkZDaoSw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4ipg7smdCZTLeEogKdsKJGrCpaDKaghbTjrM8wkZDaoSw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 20 Dec 2018 16:57:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181220165738.qN1SYn3h5M7DZ6F6rS0gaud7O_Wc0pfXWiOJWON3PAw@z>

On Thu, Dec 20, 2018 at 08:47:39AM -0800, Dan Williams wrote:
> On Thu, Dec 20, 2018 at 8:15 AM Jerome Glisse <jglisse@redhat.com> wrote:
> [..]
> > > Rather than try to figure out how to forward declare pmd_t, how about
> > > just move dev_page_fault_t out of the generic dev_pagemap and into the
> > > HMM specific container structure? This should be straightfoward on top
> > > of the recent refactor.
> >
> > Fine with me.
> 
> I was hoping you would reply with a patch. I'll take a look...

Bit busy right now but i can do that after new years :)

Cheers,
Jérôme

