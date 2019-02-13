Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 195EFC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 12:25:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2D30222B1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 12:25:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2D30222B1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 810998E0002; Wed, 13 Feb 2019 07:25:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BFDB8E0001; Wed, 13 Feb 2019 07:25:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D6F28E0002; Wed, 13 Feb 2019 07:25:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 17CDD8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 07:25:02 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id 39so951054edq.13
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 04:25:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BggUPnLW3w8iELDZgir5DIUI9DI0D6do6qhGA6Ydcew=;
        b=dp0+45Rcs+w7I3tax9EXxGxpYfic59O6KjMwaAK8BH25GErGAiRe0F5o1GjtiK7ojs
         zVBD7PdfHuKjHQDknaXU7aarQAitZHmMplJAuWh892p92FH6aeHdBOOcbPfnWOPi9HGz
         d91lZC7ZdnQ+QBOjahOha2c0ZkbhpB0LYq3VRZRkKl3QCtuSyjnn4tLPVgm3j4XK8XO4
         gvQGxOoXzqeEUpojcu6/3KbVLZJOnh8McfM34CbkJfLrhLeQ1Fjufd9cxADmerYhav7n
         6tB3767kCF1Zfy9HX3A3J3KlQUYRZ5PebXGewXf8KE8WipF5epvME+GLhPF6sZX3T4hd
         KF9w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYJKarOIEMsa7FfJAzdPG61Ol0HEgv88vojUAx3UBBYEfL/xg3v
	abcSVR6EW5GdfHJxSkdUL8W7yV3BNwNviYWH20cLQ7KoAeIOQukOcin6S2DhWw5oMQWetp2eRix
	iFA6W5t8XBsf1FfzMOWBZ0nBjkRkoYe0zB3ItNdPz7BZI3kZio0XZyrtlDHnPjDc=
X-Received: by 2002:a50:971b:: with SMTP id c27mr172747edb.171.1550060701618;
        Wed, 13 Feb 2019 04:25:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib1QACOH6QrkznBguhxiPVGMna+0La5FkL8jz79mUX/Pma4Elq+mUoxTU+V42tTw0F7ZrKA
X-Received: by 2002:a50:971b:: with SMTP id c27mr172695edb.171.1550060700637;
        Wed, 13 Feb 2019 04:25:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550060700; cv=none;
        d=google.com; s=arc-20160816;
        b=KrJRPejCKQk/t10NuE/Te0yvykcOoc3bbLuJOS1vGlP8PVRYJKIQ91kRhHrvCr8EaS
         SRV71nVVg3GNibeBGv7UlhVBYcreyuNZNC+uFbY5VkW2jP2dWRDeN06WDPUNXXAlLhPz
         s4BhI0qoQeaPGPzleiwD9XyXPXFziQU4MKqyVQbJQ1Jc7IqlHTemqOwxRw12jPl9SXd3
         YEYGCckAsFkN5nXfmbu4GQvqUGX/JTGA2R81d5CPNwJSDVNXa/8NdXKWaxzhUZjummL1
         bijrpWsQK8zjf3VLsrD7iNPCmFG06llNJ1Jj677rufw4b4TWIjf3NIA0UB5NsVIqCnk6
         5pIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BggUPnLW3w8iELDZgir5DIUI9DI0D6do6qhGA6Ydcew=;
        b=cI3d7ds4gXtaxqag2kOpnwjsSTQ4eZcSic8DgRl7acJf+y+U7688DHgpBczYhkVImN
         czXqJeuTAcdvkRNWYrwN4KFvGh8nzQHQuJCHROfrwqI6SHPAcAUF4WnBsACYlU+I3z44
         MRgL8kRhVnAxVq7HbguRV5cSaZCgzYEHzyfkLNZF9Od8MmrkiZX8yBtFEvrelMlStH59
         9lUp00rbMbWNyyQO3RwgA3PDT05RgpgvifRJuTIvugks/TgUHgCmBYcPgEZeTQ9edztx
         kSGsZoSrkrmuEjJMBXbU0Zlf5IPFIrfYptfeIaguM/T/19u9uVbxRdkQ3ccwMWLoq9v2
         aQyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c5si331783edv.451.2019.02.13.04.25.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 04:25:00 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A07F8AC7A;
	Wed, 13 Feb 2019 12:24:59 +0000 (UTC)
Date: Wed, 13 Feb 2019 13:24:58 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: gregkh@linuxfoundation.org, linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Hugh Dickins <hughd@google.com>, Liu Bo <bo.liu@linux.alibaba.com>,
	stable@vger.kernel.org
Subject: Re: [PATCH] mm: Fix the pgtable leak
Message-ID: <20190213122458.GF4525@dhcp22.suse.cz>
References: <20190213112900.33963-1-minchan@kernel.org>
 <20190213120330.GD4525@dhcp22.suse.cz>
 <20190213121200.GA52615@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213121200.GA52615@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-02-19 21:12:00, Minchan Kim wrote:
> On Wed, Feb 13, 2019 at 01:03:30PM +0100, Michal Hocko wrote:
> > On Wed 13-02-19 20:29:00, Minchan Kim wrote:
> > > [1] was backported to v4.9 stable tree but it introduces pgtable
> > > memory leak because with fault retrial, preallocated pagetable
> > > could be leaked in second iteration.
> > > To fix the problem, this patch backport [2].
> > > 
> > > [1] 5cf3e5ff95876, mm, memcg: fix reclaim deadlock with writeback
> > > [2] b0b9b3df27d10, mm: stop leaking PageTables
> > > 
> > > Fixes: 5cf3e5ff95876 ("mm, memcg: fix reclaim deadlock with writeback")
> > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Cc: Michal Hocko <mhocko@suse.com>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Cc: Hugh Dickins <hughd@google.com>
> > > Cc: Liu Bo <bo.liu@linux.alibaba.com>
> > > Cc: <stable@vger.kernel.org> [4.9]
> > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > 
> > Thanks for catching this dependency. Do I assume it correctly that this
> > is stable-4.9 only?
> 
> I have no idea how I could find it automatically that a stable patch of
> linus tree is spread out with several stable trees(Hope Greg has an
> answer). I just checked 4.4 longterm kernel and couldn't find it in there.

See http://lkml.kernel.org/r/20190115174036.GA24149@dhcp22.suse.cz

But my question was more about "this is a stable only thing"? It was not
obvious from the subject so I wanted to be sure that I am not missing
anything.
-- 
Michal Hocko
SUSE Labs

