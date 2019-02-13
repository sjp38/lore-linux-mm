Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7E10C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 11:50:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB9C0222C0
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 11:50:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB9C0222C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 594F68E0002; Wed, 13 Feb 2019 06:50:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5451A8E0001; Wed, 13 Feb 2019 06:50:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45BF38E0002; Wed, 13 Feb 2019 06:50:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0895F8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:50:18 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id a10so1528844plp.14
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 03:50:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Kui5WOpRF9qlymJME7YO5OR0a8PHLf6pPkGrspoBfXg=;
        b=oWSoCQDdHsNi8DZuh8IFx4br2veUnfOhyhm6RGnAhkLEr5Y+0WK21rC56TZgFVIPT8
         J63iLO2Zqq1+w+gfFB0QfP5UYb7/dKpUAupUCtmjlGnZ/S2dOKMuTQ625wgcACo2XDm6
         CaZ2kOUkPOK68X4ACx15fiVBD7Z/Dd3WxCJZcNPEHTAian2fjuPQokfEhf4tWa4GRVY8
         l3noyMhdHp3Ql0SXAZ91cdC/M1Yu7rdXjnAyFap9AdFfLnrBYw8+6FLPZLhVSN6viIGh
         uUSqkgcu8v59c12DIIHhDgHeJWlxH89grt1on/IePR3qAoDY3hL4qOrGuQT6D6FbE6jQ
         0ncQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAub1rwPD6zj+4C+BVIwrq64RssyRQPJlyzG88tpHVD2zZerB2L4V
	H7eJOJZ6UDM7lIg2Hgt+xaE0B8VcJP3I7UCZD5/t0ROKbd2Y/vy4pia8+NiNIh4VvNwUk0Zq5HT
	iAI5hOTPxXRBHb/N/wqb8xnbByEr9DYbxZqW86ETNXMx5IWZpFEbH+o+B3h4trsE=
X-Received: by 2002:a17:902:bf06:: with SMTP id bi6mr73957plb.167.1550058617714;
        Wed, 13 Feb 2019 03:50:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYwEmoq/A8AlWrigKrzQSFNDGQIb3rCplaxvEBGdKnuToBTzn53H5a5ucfXxFJ6KBHGoVD7
X-Received: by 2002:a17:902:bf06:: with SMTP id bi6mr73898plb.167.1550058617051;
        Wed, 13 Feb 2019 03:50:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550058617; cv=none;
        d=google.com; s=arc-20160816;
        b=XWU0Sf8G2w4g5F+iEo7hzKlv3Qh3EagMfz4BQY4TgeyaYt8Ll7pIUrhpr3DsXyZGhX
         AuZiOLHaGy3PaP6iE9Nyr/FGqYxa19Cux1bjlPqFClrUD5rs4Hl9wUIlwadJ9fgBoEF0
         M1UOM2iTBm8KsCC369dQ1kzZPkBbmi/53Prv6OWxDp74J0Biy63nBKnI0trajDTxoB9s
         SU/cke9rsAe4aV2XgMtsS6YO4Zggi8gmS25qSnKpFKC8y/sYCYALYXOShXpnlMd9eb8f
         +AlpIbFaokynk+Lhk4/wLnaXnRIuxZ/RHlHAHO3U4D1U9H0oQfs0CwgPb4F8Cmdawi62
         MbkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Kui5WOpRF9qlymJME7YO5OR0a8PHLf6pPkGrspoBfXg=;
        b=veU0JwXvQB+Uwou/SNZCbNE6Y7Vuk373NJzs/nlhWUEgvHs+UTfAFDONSgWirnS7oh
         N0+j2JctSBZm/6uqSYnWFjgGFinUpKZMH4ttGtL4wSJTZv2/SeNS2au2gd3cRpjk9/f1
         bHtiFBsPbEqcR0uvurvYNJn+jSVWEUGz2GB73bWzzJHS0Z9vRCW9OfvNlVwWHulyGtr+
         RCAp3EzJi+fMXlLyIH5ru0XPd2k2EF1Lkeo5Igiv6SA+g4snITIPjjzg1xicY3G1JT2N
         +38d2O3JzG2D50rL8Rtzg5vBJ33zP/n/JLHkw0OFpc1fKMH1IYQuVOBCBJ4m94810K6K
         kiOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z188si15260215pgb.330.2019.02.13.03.50.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 03:50:17 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6C746ABAC;
	Wed, 13 Feb 2019 11:50:15 +0000 (UTC)
Date: Wed, 13 Feb 2019 12:50:14 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, Pingfan Liu <kernelfans@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>, x86@kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org,
	linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v3 2/2] mm: be more verbose about zonelist initialization
Message-ID: <20190213115014.GC4525@dhcp22.suse.cz>
References: <20190212095343.23315-3-mhocko@kernel.org>
 <20190213094315.3504-1-mhocko@kernel.org>
 <20190213103231.GN32494@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213103231.GN32494@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-02-19 11:32:31, Peter Zijlstra wrote:
> On Wed, Feb 13, 2019 at 10:43:15AM +0100, Michal Hocko wrote:
> > @@ -5259,6 +5261,11 @@ static void build_zonelists(pg_data_t *pgdat)
> >  
> >  	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
> >  	build_thisnode_zonelists(pgdat);
> > +
> > +	pr_info("node[%d] zonelist: ", pgdat->node_id);
> > +	for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
> > +		pr_cont("%d:%s ", zone_to_nid(zone), zone->name);
> > +	pr_cont("\n");
> >  }
> 
> Have you ran this by the SGI and other stupid large machine vendors?

I do not have such a large machine handy. The biggest I have has
handfull (say dozen) of NUMA nodes.

> Traditionally they tend to want to remove such things instead of adding
> them.

I do not insist on this patch but I find it handy. If there is an
opposition I will not miss it much.
-- 
Michal Hocko
SUSE Labs

