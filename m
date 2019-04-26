Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE4E9C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:00:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A40ED2084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:00:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A40ED2084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 200B76B0005; Fri, 26 Apr 2019 10:00:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AE386B0006; Fri, 26 Apr 2019 10:00:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09E576B0008; Fri, 26 Apr 2019 10:00:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id AB1DA6B0005
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 10:00:15 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f17so1583585edq.3
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 07:00:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=H2flw9eCBEpoYow0Xezt/5+j93sDrzHoEIgiNlgVlVo=;
        b=DOmTwGtogwUcjhFzyU4TKrl3NGf2CMoxtkHpVDHPrl6bIwODf6cVTrCFO91U265EdM
         eFp60lr0sjQ9+KntoWP5mjlg+YDwLjps46a4gJDoSogbVCwCjLFhXECZuqBp0tUHQydT
         ME8KeHII0+rT6ludJ8+MA/mRP5Q90s6tGg8hLDL60SS4S/osL8awytazmkEpZUwD+e2H
         J/vxo5u2mYGLt/82gmz7cOdYCphEhgHZXzVSQxgvwbsjW8tQlilijgDRa4mr9elhWlgc
         i/5Pk90HGA/dNDHh01/ZvwFkhKiEmf/SB7sPz3+zE886+vijJX5D9NIXrnKuN7YekopD
         FwiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVkPBrd0KN+YpoOPm9PFNbUO6T6taQskK9hLoo/Z927xLlO22FR
	v+entX8oJFIRADNYC78WLIfVnzQFNh2KegNwO/XDaXuuHACVB9pXU6kQPAnQKqKWHHa1Ek3EzS8
	DLW+H57uhIxyoOO1Oi0fS/bRWRnmkmMp00b0mcHj6JUMHSXwZwBciR7YXvimotQd+Xg==
X-Received: by 2002:a50:8e95:: with SMTP id w21mr28535061edw.154.1556287215281;
        Fri, 26 Apr 2019 07:00:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTcQT/rqKLjZpMYt/Ni9AR9lxg+OK90Jat26H9r4zovnUF182iYYaD2YiAImIK1FTISnZ+
X-Received: by 2002:a50:8e95:: with SMTP id w21mr28535000edw.154.1556287214354;
        Fri, 26 Apr 2019 07:00:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556287214; cv=none;
        d=google.com; s=arc-20160816;
        b=KKh29lc5COT2VHL6V8ZbpooWaVpL6Tc5sBUAETxeH2wH14TcU0jLL56cQnxHnVna72
         t2vzQ/N0tKoSIJveXKxfAIJ9ege18X8UH6iEBYkFPwG/nqY/q1tTWziolAXVxiNZ0YWU
         tagHjmd/ca35CI6PyJC9eRf5N+gXaGVaDhOqFxtMhmPYStPkfmGJywzoJshQ1JP/xTHW
         ux8X0pepuKErqpCpATpgEWwZUzXzW1oIetzhtHaWaB8MJw2DAMdC5ktYE+NUfDBqUKbf
         62ItKRxLxXIMgV+5EOCcYcbfB3+bcjIk5M7Az+yFSaq4DLwcY+n4Q8tvM5/ONYXLjDEq
         P0Gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=H2flw9eCBEpoYow0Xezt/5+j93sDrzHoEIgiNlgVlVo=;
        b=iejzIVrZEE5zDjbUmYt1cu/Ul9GTXI0bNIldkXwgMU1b3EJ112qtLA9r6spFmv0Zc4
         fYhikwklSc0GwaENJI6DBgg8NsJZWibJipakspFRQlHvju8UqpCJwPiBcSyRi0DEuBmB
         mlEpxtzV4OQNd6Fg31p30AEyKrxpeJY5HU/S2IAVTQTRTJWJOrh83EZnLTUwt/KVXZFR
         ie/CtlnZtDIaVcNzMnDFyb7JOd+cyM1Otx6eh2qrZQ5taPnj6l0J2QHSK2f5bTzXhdq1
         fr+3TGp8flsEo7Pj0S2aGULSesypPTcoBpiJECfHtkI08jiV7+eZuE9DioxfaDifGPUg
         ROZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b89si1934754edf.309.2019.04.26.07.00.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 07:00:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DA69FAFFB;
	Fri, 26 Apr 2019 14:00:13 +0000 (UTC)
Date: Fri, 26 Apr 2019 16:00:11 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org,
	david@redhat.com
Subject: Re: [PATCH v6 04/12] mm/hotplug: Prepare shrink_{zone, pgdat}_span
 for sub-section removal
Message-ID: <20190426140011.GB30513@linux>
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552635609.2015392.6246305135559796835.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190426135907.GA30513@linux>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190426135907.GA30513@linux>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 26, 2019 at 03:59:12PM +0200, Oscar Salvador wrote:
> On Wed, Apr 17, 2019 at 11:39:16AM -0700, Dan Williams wrote:
> > @@ -417,10 +417,10 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
> >  	 * it check the zone has only hole or not.
> >  	 */
> >  	pfn = zone_start_pfn;
> > -	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SECTION) {
> > +	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SUB_SECTION) {
> >  		ms = __pfn_to_section(pfn);
> >  
> > -		if (unlikely(!valid_section(ms)))
> > +		if (unlikely(!pfn_valid(pfn)))
> >  			continue;
> >  
> >  		if (page_zone(pfn_to_page(pfn)) != zone)
> > @@ -485,10 +485,10 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
> >  	 * has only hole or not.
> >  	 */
> >  	pfn = pgdat_start_pfn;
> > -	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SECTION) {
> > +	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SUB_SECTION) {
> >  		ms = __pfn_to_section(pfn);
> >  
> > -		if (unlikely(!valid_section(ms)))
> > +		if (unlikely(!pfn_valid(pfn)))
> >  			continue;
> >  
> >  		if (pfn_to_nid(pfn) != nid)
> 
> The last loop from shrink_{pgdat,zone}_span can be reworked to unify both
> in one function, and both functions can be factored out a bit.
> Actually, I do have a patch that does that, I might dig it up.
> 
> The rest looks good:
> 
> Reviewed-by: Oscar Salvador <osalvador@suse.de>

I mean of course besides Ralph's comment.

-- 
Oscar Salvador
SUSE L3

