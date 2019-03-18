Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 741A7C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 13:42:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D5F420863
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 13:42:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D5F420863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF4446B0005; Mon, 18 Mar 2019 09:42:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC9B06B0006; Mon, 18 Mar 2019 09:42:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBABC6B0007; Mon, 18 Mar 2019 09:42:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A23E6B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:42:46 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l19so313847edr.12
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 06:42:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zjQi+9WqYpVnuIzbFCKzrTAxjEnz0vXipHf4nqAU0hU=;
        b=BDWMzSXRTI7wrHT6Wa1ON/LIEPyder488yNQpdIvF6D+eODRgwYRa/SLzNO7pMhnGV
         7z7Ex0oM3kBRMztimBqj9hnoCInwdlcvYfI6Pm6tWXK8dbZQeU2WwfBOUzD+xE1V0zcG
         r/p7I/En0Jz3HJjF5+jrqYvg0csIpi7hFwc28WnwwP2BKii9KUgZkCFmtnQ86Gpww1qq
         OP4ABD7nDY8CxDzSTkX7Rm1go6jXJbU8xLao1ZR0tKbu1yCt0ip+xSb5rhhZXmBoUaN2
         vBFL8MIgsOBDNnMoiCi8dg2DWIQcXi8PEbIkZ5Q0rK3xzCYPTDWUrYz2Dq22qbbdquXS
         Ba2Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXuUlrBnB5Ak1WEhR9c/lr/Ojg+w1jepgwERtSsfpKHcYo3+jyt
	GpD5TX1pdtZ1ur1GQMpdxTlIZOGb2mXWH/tOusAjPCCmD+wmYIJFkPB2vrGWcwDOd2Qle5jUhqO
	1MKLh90+Bn3T/JjJ/YbL1BNDshqsKJSjshRlcg/N5WEcomdowYLxqgUN/gmpllsA=
X-Received: by 2002:a17:906:4a48:: with SMTP id a8mr2426783ejv.57.1552916565998;
        Mon, 18 Mar 2019 06:42:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4LqCk/yw/A9kpVGCqOaakSASekJFXc3cjddqwiowjhlBlSZyu58J8PBwoy5w1p/+z0DEp
X-Received: by 2002:a17:906:4a48:: with SMTP id a8mr2426732ejv.57.1552916564936;
        Mon, 18 Mar 2019 06:42:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552916564; cv=none;
        d=google.com; s=arc-20160816;
        b=V3UOCa0C/Mc3xsNJcxAfH2wpNx0XF/o2j7BHlArq2FjQijTmQBJkkVlIiQWgkzkljI
         ZItmfc7uRla/Dwh3ElGDu4xByxXt9JcDQumdNs4PeIWvRS1pFdbzuOfajF3ve9EvJf81
         Qj5UrxRYsAL9tqXq2m1OgITNQcePqOBFvFbcNd/KOnhEVIGot8dAE27AFG+0T7f1oT13
         IhN9Yx67WasLs0m7Tp5uS2pxax4DrCS3UxwRD102LIkUZZEne5O+GXblUpguUse8uc+s
         5QmSwZzdSiYVxpdessycd9WohQ3MQwL0L5kuOJhZ6lwjv5T8BkttdgQgr8F/UpoDGlCH
         3Iew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zjQi+9WqYpVnuIzbFCKzrTAxjEnz0vXipHf4nqAU0hU=;
        b=COYQ7xkzmAwOCDBqCgp9WhLlr2vAOHEvt9A8995i791nNZ2fDatoQ6adw8FXh88Nyy
         VrnLl2px9tUOTj2GxRIJLTEOzvab86TUK2adIgmLKaraQ2TQeSuDnQ6sxLrYDpaZaE2E
         nRfI2ZwKTpu0oqRghp44DzG+TyUAIKmyGNpT42DKMDbCEHSG95FbGPXxNK0Yxn3pDgSU
         pxDparl5QUK+Drxn/B4iPtT3YhovoxUa88D1NypI7rqGLGY87bKm5maZAfLxYevialZz
         NqXyVxyj7zPdwYidnmJPgi0JegzRctg4JUiS2RiUYW5asGD/ATg8MCwuV/e9wYzxtjjp
         yWQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y12si1548883edh.407.2019.03.18.06.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 06:42:44 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 83D40AD70;
	Mon, 18 Mar 2019 13:42:43 +0000 (UTC)
Date: Mon, 18 Mar 2019 14:42:42 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"minchan@kernel.org" <minchan@kernel.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: Re: [External] Re: mm/cma.c: High latency for cma allocation
Message-ID: <20190318134242.GI8924@dhcp22.suse.cz>
References: <SG2PR02MB3098E44824F5AA69BC04F935E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190318130757.GG8924@dhcp22.suse.cz>
 <SG2PR02MB309886996889791555D5B53EE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <SG2PR02MB309886996889791555D5B53EE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Please do not use html emails to the mailing list and try to fix your
email client to not break quoating. Fixed for this email]

On Mon 18-03-19 13:28:50, Pankaj Suryawanshi wrote:
> On Mon 18-03-19 12:58:28, Pankaj Suryawanshi wrote:
> > > Hello,
> > >
> > > I am facing issue of high latency in CMA allocation of large size buffer.
> > >
> > > I am frequently allocating/deallocation CMA memory, latency of allocation is very high.
> > >
> > > Below are the stat for allocation/deallocation latency issue.
> > >
> > > (390100 kB),  latency 29997 us
> > > (390100 kB),  latency 22957 us
> > > (390100 kB),  latency 25735 us
> > > (390100 kB),  latency 12736 us
> > > (390100 kB),  latency 26009 us
> > > (390100 kB),  latency 18058 us
> > > (390100 kB),  latency 27997 us
> > > (16 kB), latency 560 us
> > > (256 kB), latency 280 us
> > > (4 kB), latency 311 us
> > >
> > > I am using kernel 4.14.65 with android pie(9.0).
> > >
> > > Is there any workaround or solution for this(cma_alloc latency) issue ?
> > 
> > Do you have any more detailed information on where the time is spent?
> > E.g. migration tracepoints?
> > 
> > Hello Michal,
> 
> I have the system(vanilla kernel) with 2GB of RAM, reserved 1GB for CMA. No swap or zram.
> Sorry, I don't have information where the time is spent.
> time is calculated in between cma_alloc call.
> I have just cma_alloc trace information/function graph.

Then please collect that data because it is really hard to judge
anything from the numbers you have provided.
-- 
Michal Hocko
SUSE Labs

