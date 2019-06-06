Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7BBEC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 15:33:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A692B2083E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 15:33:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A692B2083E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CAD26B0279; Thu,  6 Jun 2019 11:33:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 154086B027A; Thu,  6 Jun 2019 11:33:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 06A106B027D; Thu,  6 Jun 2019 11:33:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C62E06B0279
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 11:33:08 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h2so4243198edi.13
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 08:33:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mmt/E7aXpF2yVikwDiwnsiQemQn+69zKar7C6j0HgQo=;
        b=JxiKq2NHeo6IfXEYfYSAvqOlGN2IA8thi/PuarDZn0quozTgrT0yTKjsciAzobnO2F
         q6C0hQUKXe1m3YHQxUzB9wJAJD2d9WzhRYlA5A/yzmZxuUt+tuYLn9TkccKpVtf/uF5F
         DOS0OuEzdNhNS4sUlVbuhZCgmQ6VvyX3sZOy6aA92K3eWcoSIrC9EVMZWDvfUC6zHw8D
         /Egw4nWOCe0rHELUNWaZR3nmtiBMIgcYybt2gAEchMaq9qXeBh5NEfQtAsxkSz/Alduc
         lWDA3Tt73WndrwU+cD2V9ew8eXm9ChSd8WjMbJQMFy8otmCQqNCWCP65U3QyTY/Ng3Vm
         Jo0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAWbJyC3qfe0HPm1eFzdFlSuvuvsKjZmkwTuO5t7VZzToZSf9LPN
	Xy5CZbTsTehmqcD/EnH0tQ/Ievqrr4NHoLQXZS6qNrRuS3rhfQ5eF39B9KOjjitA4/fdCR7FQh0
	UT2SJQZC/RP1hyEp54OBUDOOL6wYeTRtRA4aqswyc0WGbqkTNa5qkIG+IEIH8/sIPkQ==
X-Received: by 2002:a50:e61a:: with SMTP id y26mr51779144edm.292.1559835188324;
        Thu, 06 Jun 2019 08:33:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMCbqj/b93Dn6z/yjWw6vOQ0ioBIj0JKLAEW+V8XFcZBOBE8P1btbD/FUytu8ve/t2jKZe
X-Received: by 2002:a50:e61a:: with SMTP id y26mr51779050edm.292.1559835187527;
        Thu, 06 Jun 2019 08:33:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559835187; cv=none;
        d=google.com; s=arc-20160816;
        b=y50VcdGN2NC/C1Gn+4ASY/ApqENDfGyUlcW2TO4A3HbfCqtpmV6BaSeOghghHgxqjU
         UdgwwMADytnQ/XUnTXd2egPHCI/qCGkzDkzB/rGfbGB8RQSt5zoFb0ToWm+ixgEdpDcX
         FLbtaMaCN7usGqM1wbwFpX4SnVNupqqjweLrs0M4YcoIvI700UpDglBmAJ8+WG9SfGHd
         cn90bq8ZdADH9zzdcxbmgvEP49M4foy58+PopBV8OEYyTm1x3Yk7TdE88gBNUcU2yLIg
         FeWnJKbg3DUoI9vgu9YM+j6Y7snTdRjQj1AwbTsR7UZ1eXV2tAdmJfTko8s5yj7oQFXn
         6kbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mmt/E7aXpF2yVikwDiwnsiQemQn+69zKar7C6j0HgQo=;
        b=IWA7PEhyL78R4Y8ecbsUOqtfJpj1QcGXeGBtbEBdOBkmZq1fnXf7TXjHFBBLRpxrDD
         i1ajtc7disRbAAhcYx+ugDjdX6+3egxkJpYectKQbiNvuA/550z/bRw2AbbAQk3K4/w7
         uEnBgpR+v0Ay5MpOUjIUiZ8GV5m81GrQjjNKFOPMntpwPofu/sEkkzDQrPcEVUY5qLUS
         e4XqKquzAxyQX/c53GQGikeLRkW9jM7WRT2zixG61Z7Tji/Ug4d3vp/iTER2YT7K7uEi
         LGHXWPjdDl9BLrDr5K4on+e9XQS370Rz6f066xKqyatQt4ghWpV+OqNmaing9k6P1ULB
         DJGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z22si113288eji.108.2019.06.06.08.33.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 08:33:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B8F9DAE65;
	Thu,  6 Jun 2019 15:33:06 +0000 (UTC)
Date: Thu, 6 Jun 2019 17:33:05 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Bharath Vedartham <linux.bhar@gmail.com>,
	Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Subject: Re: [PATCH v4 0/3] mm: improvements in shrink slab
Message-ID: <20190606153305.GB12311@dhcp22.suse.cz>
References: <1559816080-26405-1-git-send-email-laoar.shao@gmail.com>
 <20190606111755.GB15779@dhcp22.suse.cz>
 <CALOAHbDYKL2kSfaf9Z_E=TyNQtGaAUfxG8MkSXb1g0VSkcYzNA@mail.gmail.com>
 <20190606144439.GA12311@dhcp22.suse.cz>
 <CALOAHbBuF07j1Nt2tAg6Hd2ucse6O9PLhY-yr_K-56zerst=iQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbBuF07j1Nt2tAg6Hd2ucse6O9PLhY-yr_K-56zerst=iQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 06-06-19 23:03:12, Yafang Shao wrote:
> On Thu, Jun 6, 2019 at 10:44 PM Michal Hocko <mhocko@suse.com> wrote:
> 
> > On Thu 06-06-19 22:18:41, Yafang Shao wrote:
[...]
> > > The reason I expose node reclaim details to userspace is because the user
> > > can set node reclaim details now.
> >
> > Well, just because somebody _can_ enable it doesn't sound like a
> > sufficient justification to expose even more implementation details of
> > this feature. I am not really sure there is a strong reason to touch the
> > code without a real usecase behind.
> >
> >
> Got it.
> 
> So should we fix the bugs in node reclaim path then?

I am all for fixing bugs, I am just nervous to expose even more internal
implementation details to the userspace if there is no _real_ usecase
requiring it.
-- 
Michal Hocko
SUSE Labs

