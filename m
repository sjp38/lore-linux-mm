Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 703D7C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 12:22:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B8BE222B1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 12:22:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B8BE222B1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C34C8E0002; Wed, 13 Feb 2019 07:22:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7737A8E0001; Wed, 13 Feb 2019 07:22:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6639C8E0002; Wed, 13 Feb 2019 07:22:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0E96A8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 07:22:47 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f11so946817edi.5
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 04:22:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jUWDdl+uoCnA9hMQKPr9F7+kF0SvNEzceNhWvrB01XE=;
        b=I/I+echspjk7kpdMMLHh9iu3WR2SSlvCG1aGhkI9B58WA/amfiW5hUKPhnWxjPGDTW
         ft7D4hOHqSaQyMxJSGKsOy76qGI9/HYD0TP8t/dJGIkQdDMmt4b0g18Xvff7jqdKZe9s
         f17eFnZDS1bOr3kFqTpOa9hRzvUxpeIo+Kh4bl4Fp61lct+E24obSUcn8IgDLmLopOFG
         NrlobhMXmx2dhGN9EyDi5J1GgkTDzHJDGO+GTs5I1a/2ETd5qACsxYQFOLpNP7BuqAJ3
         4YAbhs2g7hVGQj4RgciEeUsnVjC3q57Jlj4OSurPLsmleoCZCdCDidBGH4PIYvcp/S0m
         7zjA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuasweH2xCyV2Swm+yqf6TpG2GPa+vkCzP7MfO8WYXmXQ6+9B0Yn
	ygKEBvHNEb+8OM6IKZVJLxQoOQl8B8SoPK2ydj7/FvCvEaa1MMTz4V619UEhqafZaSliRy6AOII
	cfph3+D/XtCTMF3msc1QC5bW+7lXA2v1DAagV52D158yJ3i49MKjTLjtNlxmtSS4=
X-Received: by 2002:a50:b667:: with SMTP id c36mr198447ede.190.1550060566530;
        Wed, 13 Feb 2019 04:22:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ0kuib41I6i20XqIKySu1gGkVysIzSswVWu56nsIxyGkCbqKPld85/PjfkZAQ0JSOhczcn
X-Received: by 2002:a50:b667:: with SMTP id c36mr198407ede.190.1550060565635;
        Wed, 13 Feb 2019 04:22:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550060565; cv=none;
        d=google.com; s=arc-20160816;
        b=p9lXXn3mK915bsF9QZSOckyxlNx+jN+yNH6M2oIehywVyGnYqGGwgRHWaFi1qhJ7ci
         hpRR5GdpkytoJodPNEBEn3Tl4vuOhqJ6UYKE8sDNOp/vXSe+zpJyf3ElGF8uA9OTY02c
         obu51PpaVnoOQONexnKX/htpxx9Bvd89VTmihqEc6ePzS1opgCpnDF/Q9LuMPt8lIhd7
         IzyiXtpk99fu2BkwBv8R8lrdyE08puJMOHU65dj/WoLW8ffS/aB6NNuigch2qjCmFRRd
         OAmPfbZHVCroLt9sX0v+wZJpKyeNaHE9f8tKNkPXNYj2lQeJEzSQBok+hZXIrFSW5x6Q
         Mcdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jUWDdl+uoCnA9hMQKPr9F7+kF0SvNEzceNhWvrB01XE=;
        b=wZ/qjtE5c8gYsQyjVk20QpWF0hZboA5SyZdFNG8Q0HK6/qcYNJkW3/EUsugkxf6L4e
         mAy4umWmN03DVe/CmnV8zpF/l3rHlEbIwZ2Tz5RsW13uX+lipOodEwn5oeKHX9fXM5OI
         awqd44Sw+6fZES4ctCW4vI9yjmXaVkBfD7AWZ7NeBp8orvta9wz7SoCbw1opK5jiTM6G
         EVyhQT00ru9A2Vz+ShvelyiOCdnupfDIw0z50NLb2UVgz81ByQp0hKKjZuzSKbambqyh
         LysSf0MLmRXNc0koits42Ftw/BZitlXupwRjq+DExiooFgviUynpdZQfbwcUt3cmBUp3
         XGGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y16si2762090eje.300.2019.02.13.04.22.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 04:22:45 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 16DF7AE3D;
	Wed, 13 Feb 2019 12:22:45 +0000 (UTC)
Date: Wed, 13 Feb 2019 13:22:44 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Jann Horn <jannh@google.com>
Cc: Michael Kerrisk-manpages <mtk.manpages@gmail.com>,
	linux-man <linux-man@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>
Subject: Re: [PATCH] mmap.2: fix description of treatment of the hint
Message-ID: <20190213122244.GE4525@dhcp22.suse.cz>
References: <20190211163203.33477-1-jannh@google.com>
 <20190213114724.GA4525@dhcp22.suse.cz>
 <CAG48ez2-Y-QuYOHvcEiBcgFq46C-ZeCqZg9+7KRaOhE-AmQ4mw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez2-Y-QuYOHvcEiBcgFq46C-ZeCqZg9+7KRaOhE-AmQ4mw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-02-19 12:53:15, Jann Horn wrote:
> On Wed, Feb 13, 2019 at 12:47 PM Michal Hocko <mhocko@kernel.org> wrote:
> > On Mon 11-02-19 17:32:03, Jann Horn wrote:
> > > The current manpage reads to me as if the kernel will always pick a free
> > > space close to the requested address, but that's not the case:
> > >
> > > mmap(0x600000000000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
> > > -1, 0) = 0x600000000000
> > > mmap(0x600000000000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
> > > -1, 0) = 0x7f5042859000
> > >
> > > You can also see this in the various implementations of
> > > ->get_unmapped_area() - if the specified address isn't available, the
> > > kernel basically ignores the hint (apart from the 5level paging hack).
> > >
> > > Clarify how this works a bit.
> >
> > Do we really want to be that specific? What if a future implementation
> > would like to ignore the mapping even if there is no colliding mapping
> > already? E.g. becuase of fragmentation avoidance or whatever other
> > reason. If we are explicit about the current implementation we might
> > give a receipt to userspace to depend on that behavior.
> 
> You have a point. So I guess we want something like this?
> 
> "If another mapping already exists there, the kernel picks a new
> address that may or may not depend on the hint."

Yes, this sounds good to me.
-- 
Michal Hocko
SUSE Labs

