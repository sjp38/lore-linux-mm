Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9192EC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 13:50:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3475621904
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 13:50:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3475621904
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B45978E0003; Mon, 18 Feb 2019 08:50:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF4AA8E0002; Mon, 18 Feb 2019 08:50:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BD268E0003; Mon, 18 Feb 2019 08:50:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 41A318E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 08:50:05 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x47so7041197eda.8
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 05:50:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AmtIYxHGO95oC80/w/8i8Vgy1OhQOA9y359cVv2MQCs=;
        b=SiXfq9bcwT0Df4/ViXGBi6ddLskLn4od74xF83OvQOjxchXp4Cg7lm5i+tdUJXJu9G
         iBdy4iTy8JQPyrZT39svdRMnMmDfWD4mp/GGU5sawNoDW8eVQVx8fI6LNRz3m7Eo6CX3
         e++d7+3lw6jPAQ0TYgoBC1UV2VvPvQDv0Hcvnd8t5GQNTICAKob9Z62z6upbmHqaJbyC
         wHHqrpfeN6xt9zgDneqfKaAiLR5X+Z1zBPXR8tGINp/+fWR9HCXXxc0EN+CTqYnRfh+a
         GV6LOw1aKulXQVlBpQI3n7yrWHh7SxQZMWG3H6z9bZl/mqt8poxHxAB3JggC5yToDELU
         KOIg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubmHrev2oBNxUMjGVJJ1poxIj0z/7Wan33Q6FzWYi2B/3HXoPyw
	kfXoS5xclwCCD0FQmvTyPUp5Tt+HgP3l2Lb5FrLLZX9Qo5GifBBOv0xWNr5Q9mN8duqcYpCG1gL
	hPkxzqUiCZLGWFR/3kUw4Av9djOSSJwPIic0gEgVsnSVjnr6QUk+BGO+gmtECpbI=
X-Received: by 2002:a17:906:70cf:: with SMTP id g15mr16088068ejk.223.1550497804794;
        Mon, 18 Feb 2019 05:50:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaOuCNGou/GrxE2rFVJzBRHCoBHDk+0V9FrXtyQA6miHoHvmBYdA2EUBdsiS9V+1usX45lb
X-Received: by 2002:a17:906:70cf:: with SMTP id g15mr16088027ejk.223.1550497803923;
        Mon, 18 Feb 2019 05:50:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550497803; cv=none;
        d=google.com; s=arc-20160816;
        b=r7DaQ3vT62PTSmZTtGv/2cXCmXnoUfVe9Cb8KHH0omwj9bOec0UoBSXh8prwxPCjg6
         6ubLfc1jZ3n68IEmjfrisSFOypLMv8lezfQMNuiO6ZP6kc50XPaTT9yAZZZotP66SuDo
         4R7wTns24b6+gfPmiN3xwZkGRwmCi19qhFKLDjjPz1kGw0LhnagbpwrzPVw7VjRHwWay
         182BNA98qrbU0CO2H5ldNX95wNB1lOn07TBxDSricnjTUPt22YDl2KMRPZNnyxQuDvX5
         WYGaJ9Andszz4zI5driY6DOBjFs9/kAwa+emvCE4PjiUVDovp7eEYCwlB4BeT2GlbRUE
         ip+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AmtIYxHGO95oC80/w/8i8Vgy1OhQOA9y359cVv2MQCs=;
        b=VAxzGnBIVrG7MIVNrqlmy+2FSoKbjAqZpotAVG+8xLJXtgwNuvIOxAJN9SE3uB55PG
         q0QOnl9xtAW+ZINdQbkMHkOD6I+tOlj2nOXbjdqct9pWDgWkn64r4WasZp0xJKtKJvxf
         rG6jCsX4nChzRhTfd8ICjbpKwL3nycQMsYMy6C57AzIozvBq/hEgVXISGQ8dqYSW21eh
         vQe0Y51ChjiXG8KCCZS/u00TbylgLbRnrQ/1or/BYgjy77N5Ox7uD4ltpadYvxbJg5Wh
         LwbF9BUq+6eq22wy1nncMHDji6yS5RXoLrJ5OqH1dV0Y/iN0APQ5wncdFQoUSP34EtuL
         /TuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w1-v6si68630ejf.184.2019.02.18.05.50.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 05:50:03 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 63490B015;
	Mon, 18 Feb 2019 13:50:03 +0000 (UTC)
Date: Mon, 18 Feb 2019 14:50:02 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Lars Persson <lists@bofh.nu>
Cc: Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org,
	lersek@redhat.com, alex williamson <alex.williamson@redhat.com>,
	aarcange@redhat.com, rientjes@google.com, kirill@shutemov.name,
	mgorman@techsingularity.net, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm: page_mapped: don't assume compound page is huge
 or THP
Message-ID: <20190218135002.GR4525@dhcp22.suse.cz>
References: <eabca57aa14f4df723173b24891f4a2d9c501f21.1543526537.git.jstancek@redhat.com>
 <c440d69879e34209feba21e12d236d06bc0a25db.1543577156.git.jstancek@redhat.com>
 <CADnJP=vsum7_YYWBpknpahTQFAzm7G40_E2dLMB_poFEhPKEfw@mail.gmail.com>
 <997509746.100933786.1549350874925.JavaMail.zimbra@redhat.com>
 <CADnJP=t25=AcVq7z3w8iG1+ywnSNN4Vbow3-7tOai+qnyD5ACQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADnJP=t25=AcVq7z3w8iG1+ywnSNN4Vbow3-7tOai+qnyD5ACQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000052, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 18-02-19 14:43:58, Lars Persson wrote:
> On Tue, Feb 5, 2019 at 8:14 AM Jan Stancek <jstancek@redhat.com> wrote:
> > Hi,
> >
> > are you using THP (CONFIG_TRANSPARENT_HUGEPAGE)?
> >
> > The changed line should affect only THP and normal compound pages,
> > so a test with THP disabled might be interesting.
> >
> > >
> > > The breakage consists of random processes dying with SIGILL or SIGSEGV
> > > when we stress test the system with high memory pressure and explicit
> > > memory compaction requested through /proc/sys/vm/compact_memory.
> > > Reverting this patch fixes the crashes.
> > >
> > > We can put some effort on debugging if there are no obvious
> > > explanations for this. Keep in mind that this is 32-bit system with
> > > HIGHMEM.
> >
> > Nothing obvious that I can see. I've been trying to reproduce on
> > 32-bit x86 Fedora with no luck so far.
> >
> 
> Hi
> 
> Thanks for looking in to it. After some deep dive in MM code, I think
> it is safe to say this patch was innocent.
> 
> All traces studied so far points to a missing cache coherency call in
> mm/migrate.c:migrate_page that is needed only for those evil MIPSes
> that lack I/D cache coherency. I will send a write-up to linux-mips
> about this. Basically for a non-mapped page it does only a copy of
> page data and metadata but no flush_dcache_page() call will be done.
> This races with subsequent use of the page.

Please make sure to cc linux-mm for the patch
-- 
Michal Hocko
SUSE Labs

