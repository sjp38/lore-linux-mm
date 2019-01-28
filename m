Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F048C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:05:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D30F2175B
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:05:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l+K36/RD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D30F2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9FDD8E0002; Mon, 28 Jan 2019 11:05:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C77BD8E0001; Mon, 28 Jan 2019 11:05:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B67368E0002; Mon, 28 Jan 2019 11:05:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 89E998E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:05:16 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id k69so9680403ywa.12
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 08:05:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=D0XIA/6Qh8GnZZaGo5cB5eBgXybV2IxRZOPzdvJrX0c=;
        b=JDZhrFKKZoD3vCjYlKr0lZ0xOwX7FdmqXQEARvNP1MHs/0An7QvctSa/3pZcsqtryS
         HCxhT/J+jO3mPPhbCWVWE42LPbyp5mS0Amd55/zqDuQRVt96y2KBNI88l2oIxl5+5WjP
         BSzwSu9ppwKXQtdkNW6cxhJwDkbiR3VqTVxWvSDIl8MHoYSzhipJxFMh+bp/R2kthvCg
         kR4anzaEQ8jlTRUhz20BnaAr+AeJnxycW490SJ3LxDzXmeQt32cideOcYodHhH/f9nRV
         hm4J3U1UxTLwcbNghfvXFlryB2C0U4z4h7cFXsb92KHwGSVixjcKqtid9WL3k3Q1pKMR
         X8tQ==
X-Gm-Message-State: AJcUukd1sfljUaE0NRM01frbEEgpKfZ1af3o+M5qt0iMtJQXSmiipIQM
	6/GyLnN/nOdZuzICoHwnFTQFkTfvGBdt+le+EaanYwjsvOS+kgYnSx8Qfmdpxd9ulEWGp3Nsso4
	Ve7sGrsdK3Do5nPL/YeIryAHbg7PcNKfHHDTwelSujru+nE/Sm/TKwPlJJdvvljTfo5B6K5Ak4O
	TA2ExNI8/0yWb0dur2COXRhDj/dBJiHptqZPxTdhaD2vHvBPtlKiBHXl8ZF+71uOtWbys/jOTuN
	P18xGPRV8I5JtNJxFckYy1W/Tz9spl3qUV272MGaXI1p/PybMpeydjWIIeAD6szmvJyXeonHAV+
	BhVdnAf7DmFfTz0OKIS9ABRrPNMLKNYa/j+RXrvB+xYkGgLxJHwJ0z2vXa9PtXnml+YU4xBCZg=
	=
X-Received: by 2002:a25:1682:: with SMTP id 124mr11919035ybw.346.1548691516134;
        Mon, 28 Jan 2019 08:05:16 -0800 (PST)
X-Received: by 2002:a25:1682:: with SMTP id 124mr11918984ybw.346.1548691515565;
        Mon, 28 Jan 2019 08:05:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548691515; cv=none;
        d=google.com; s=arc-20160816;
        b=wfsesG0KGvCHOEIL+IfRO6azXVN/6HXC/Jp0OTCFndwKIkEbYaxp//OX/3iuv/gbD6
         Ku8g90IrHc/HMk2cfiFxs0+ZLjwzNHzyAsXjQIvnn1TWlFhFWn3K/1ujtGyoAeGvsvUD
         jQv8nXedVJc3b4ay6iJH+3BsIJmzbMeq9BTE8uxIZCH62X4KQ7kqbU3QzhI9z3JLXU2t
         8ckGwbq27otIIisJMbJ+Awsp9UTRwlOakZdIQ48kU7jpm5H1qn3Aw6seEp278W1bZPkI
         RXTxX5mAOrH5TQuSUYyMrl21vAuoLjFdbNID446Xt94gjmc0HYWXCDWQLa9+qLMbiljf
         dnqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=D0XIA/6Qh8GnZZaGo5cB5eBgXybV2IxRZOPzdvJrX0c=;
        b=0Uk170FKEJlPG6wS+VhiGjWpkwehDDpwV5KfiDErQvZLPHZjFNS9/eyvj59MROJk7r
         QCJVVtvwvDgdDQ8hLX/f05ddc960PfPjgBy5w8sRloUk5PZRbF+giPOx0mxNoRv/wJ4U
         hPDVG8I3m2fVxyKMRx6yDLqAKRUG6C5MpwzW/P0fSlrEik3PoL08Qcv6ihC/4Klr0u3Z
         dNPhGPtecVX802tc/26G+RxWDPXCpQF7opbb6MJELpVsPvFOuQMaU2mZwE2jAsdA2y9m
         +NC7R0vuK3J44NOOvjIdjssbzcL7TlVZkRlPEXz94rtZ4Sj0aYu1m59WuS6Cl80I+ssc
         vKEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="l+K36/RD";
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d197sor4392084ywa.51.2019.01.28.08.05.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 08:05:15 -0800 (PST)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="l+K36/RD";
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=D0XIA/6Qh8GnZZaGo5cB5eBgXybV2IxRZOPzdvJrX0c=;
        b=l+K36/RDCfBLXWyfwDofaL0N6kncsH8J9nemOl65EBSWfBsCNapxwp3eNjnoplOTEg
         5K6WRkAL0/ukREfK8WDnsPdxifoTXD0UigcTjP4F8EqcZ6Prk6QeaR6FSyVSmh1LCQuR
         wbq/fKfQRplDMddZCczhcb2GLUV6Y5PmhcFFPM4CBO/CjzJ5rlOb+Jz/AOPBigxYRaOf
         zfGSfdkMTqAVYZvMk1U9ZwSf9VJ+yMd3aGmeTjyA+GkmgO8wjEzamAYjwk8OMjpEgg/D
         AzJtY400kLlnBy6R0JGDR5ehBi+hS47pxRDGQjoam2KKUhP3Uw93irXgqvzxYQ/q6fFW
         zlJA==
X-Google-Smtp-Source: ALg8bN7bUpeHV836lzz3aJ6Sgr6OtwzyPs6fkMCKJBakdwydEIqxML/o9OUDhLodzTvZNikuzUjKAA==
X-Received: by 2002:a81:2cc4:: with SMTP id s187mr21940591yws.67.1548691515076;
        Mon, 28 Jan 2019 08:05:15 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::7:a62a])
        by smtp.gmail.com with ESMTPSA id d3sm18681834ywh.58.2019.01.28.08.05.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 08:05:13 -0800 (PST)
Date: Mon, 28 Jan 2019 08:05:12 -0800
From: Tejun Heo <tj@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
	Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190128160512.GR50184@devbig004.ftw2.facebook.com>
References: <20190123223144.GA10798@chrisdown.name>
 <20190124082252.GD4087@dhcp22.suse.cz>
 <20190124160009.GA12436@cmpxchg.org>
 <20190124170117.GS4087@dhcp22.suse.cz>
 <20190124182328.GA10820@cmpxchg.org>
 <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <CALvZod6LFY+FYfBcAX0kLxV5KKB1-TX2cU5EDyyyjvHOtuWWbA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
In-Reply-To: <CALvZod6LFY+FYfBcAX0kLxV5KKB1-TX2cU5EDyyyjvHOtuWWbA@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190128160512.ZLUJ5_-k-ibejR_v6N5Y9R4SMxX02SuNJ41zfVgWFrU@z>

Hello, Shakeel.

On Mon, Jan 28, 2019 at 07:59:33AM -0800, Shakeel Butt wrote:
> Why not make this configurable at the delegation boundary? As you
> mentioned, there are jobs who want centralized workload manager to
> watch over their subtrees while there can be jobs which want to
> monitor their subtree themselves. For example I can have a job which
> know how to act when one of the children cgroup goes OOM. However if
> the root of that job goes OOM then the centralized workload manager
> should do something about it. With this change, how to implement this
> scenario? How will the central manager differentiates between that a
> subtree of a job goes OOM or the root of that job? I guess from the
> discussion it seems like the centralized manager has to traverse that
> job's subtree to find the source of OOM.
> 
> Why can't we let the implementation of centralized manager easier by
> allowing to configure the propagation of these notifications across
> delegation boundary.

I think the right way to achieve the above would be having separate
recursive and local counters.

Thanks.

-- 
tejun

