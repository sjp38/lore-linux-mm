Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39C33C46460
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:18:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC04120B7C
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:18:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="P13JV0rm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC04120B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A67726B0006; Tue,  7 May 2019 13:18:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A177F6B0007; Tue,  7 May 2019 13:18:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DF6B6B0008; Tue,  7 May 2019 13:18:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 58A226B0006
	for <linux-mm@kvack.org>; Tue,  7 May 2019 13:18:09 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 93so7837308plf.14
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:18:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=xt9ukkJvDmf42/+1FX7EomlPuDAXRZaZI20EEYYs5jM=;
        b=ooBTaWyyMSlwfgCherpURb0JOcpSOOa0ylmIP7ayJnaYRsEQexKNckET5SccTEZGIF
         2fJL8nRNX4uZA8JvYFStGk3KAXLqxq3cKqORhYg14AZBgllvNjGnmZffQVvO/FOKdq4G
         BePWCu/1NrI6qJYsm7EfSDNaZmQQpWD13/VWMK9bM5GxahP2LWBxEYd2lm+ou6iC8Szh
         Hu53BASJcUczrmySi+huWcb6SmqaF+aXFnExpxLLbWdrbqiI5dREf3w4QK8HA4wQGxEc
         DUsthPZEQdJRipITRK4Dx+60u9SVn6jGij0kzc/Fu+rgSTpHA8Iu7qAdrdfLHYVldY+V
         alDQ==
X-Gm-Message-State: APjAAAU08/zjApdXtKX4QUfI8RpBWrIIzS+UZeE04Xpq9eMj0bmXnwvi
	P1PLulzpLfqrQUOFpgBCsgyqjsDge6dMubNTWxWbPTEgrf0/d7eeMjI4Hysp46YepOaC0JAxsPz
	3S5WMhYmgVMD8Ypr5EFXrxFLqr6EygupEhL152IiXDjydcT4tgYyYnqN8EzZYFtMJ5Q==
X-Received: by 2002:a65:5647:: with SMTP id m7mr30938168pgs.348.1557249489014;
        Tue, 07 May 2019 10:18:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSQKQBAZFs+cCWDocv99gN9yYIVAigQRi7u9JbdsYvAnaDmi1AG13NDEUJOR3Pj4kcCPpe
X-Received: by 2002:a65:5647:: with SMTP id m7mr30938121pgs.348.1557249488385;
        Tue, 07 May 2019 10:18:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557249488; cv=none;
        d=google.com; s=arc-20160816;
        b=PjF3oWk7e2tMZpmLFm3cZrAwSo5eO4Nc+oPoN07L/1trnuFcTmFjo8+aOZrl/yZ1Ci
         h0MIqtfXA6aXmBxg8r7O3CH82+eMkREkWAuJsa+zCTbrl8rh3USVZbrRyGTgzVHY/Mui
         bLZ3vbDCjt1o4HGmeDmFK9vu3lLTRcMupxslIXBbhg7uqJR8bvX4X60pb+blHFBPf554
         OA8Cd3FqRy72anS3oWllc3XxpQg47NMlEhJ30rtzh0LmYzuyIGjCppa/Dvn/gr+NwUe/
         CqE9YoCIDrKlFZxJEM5bK8CHBD+FT6mGL7tMU61qEzHgzKJUn1cp3WXRaCmw2LBvrSYo
         dW8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=xt9ukkJvDmf42/+1FX7EomlPuDAXRZaZI20EEYYs5jM=;
        b=0uT5g56EjsNCy+i3S2kUez+KpoU+sc3jx6Kwev8sCM4r4xqo+sIkTWEQPiwD7FUtEB
         CCLP/90bGri2LUZkgj5pmdZJxMicmeX35bbAomGfYChSmFCNcoY52+X2PfPV1RA0MTTk
         YKf3N/pIRoL3YlieHlOBpk/3/9aJAkWHy/HlU+eDfUpC/YLnS5DutU7yYE44iUBtFAqY
         uCjnAevK8SirkvVYRtOJi63GTQYuy234rvMpU262eQzpOAJV6OUW4wCc+xS7rar+4mRM
         1f1sqoXnTIQD2C/TKK6JTMnGw5Ci7n6cLHBp1dT528tKHEQmf47nZvo+bD7Nv+GEt0rz
         uUsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=P13JV0rm;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d25si19270178pgb.229.2019.05.07.10.18.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 10:18:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=P13JV0rm;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BEFAB206A3;
	Tue,  7 May 2019 17:18:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557249488;
	bh=xt9ukkJvDmf42/+1FX7EomlPuDAXRZaZI20EEYYs5jM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=P13JV0rmV+5jHlhlN519NNBjhELHn7/LNhU9HK1HfT551G7PtkVA1vPvH2NhGGovl
	 iugCemv8wI3IXV48UKY55GgEdHi8U98lXAlBJmVdJj7X9uwf6oOshqmXdQw6+mYpFP
	 HToXiAVL+O2CLBxNhwDl2wZ+Ki/mNA2aVcJX1aoI=
Date: Tue, 7 May 2019 13:18:06 -0400
From: Sasha Levin <sashal@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	stable <stable@vger.kernel.org>,
	Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Pasha Tatashin <Pavel.Tatashin@microsoft.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Sasha Levin <alexander.levin@microsoft.com>,
	linux-mm <linux-mm@kvack.org>
Subject: Re: [PATCH AUTOSEL 4.14 62/95] mm, memory_hotplug: initialize struct
 pages for the full memory section
Message-ID: <20190507171806.GG1747@sasha-vm>
References: <20190507053826.31622-1-sashal@kernel.org>
 <20190507053826.31622-62-sashal@kernel.org>
 <CAKgT0Uc8ywg8zrqyM9G+Ws==+yOfxbk6FOMHstO8qsizt8mqXA@mail.gmail.com>
 <CAHk-=win03Q09XEpYmk51VTdoQJTitrr8ON9vgajrLxV8QHk2A@mail.gmail.com>
 <20190507170208.GF1747@sasha-vm>
 <CAHk-=wi5M-CC3CUhmQZOvQE2xJgfBgrgyAxp+tE=1n3DaNocSg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CAHk-=wi5M-CC3CUhmQZOvQE2xJgfBgrgyAxp+tE=1n3DaNocSg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 10:15:19AM -0700, Linus Torvalds wrote:
>On Tue, May 7, 2019 at 10:02 AM Sasha Levin <sashal@kernel.org> wrote:
>>
>> I got it wrong then. I'll fix it up and get efad4e475c31 in instead.
>
>Careful. That one had a bug too, and we have 891cb2a72d82 ("mm,
>memory_hotplug: fix off-by-one in is_pageblock_removable").
>
>All of these were *horribly* and subtly buggy, and might be
>intertwined with other issues. And only trigger on a few specific
>machines where the memory map layout is just right to trigger some
>special case or other, and you have just the right config.
>
>It might be best to verify with Michal Hocko. Michal?

Michal, is there a testcase I can plug into kselftests to make sure we
got this right (and don't regress)? We care a lot about memory hotplug
working right.

--
Thanks,
Sasha

