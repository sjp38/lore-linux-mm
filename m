Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D060C76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 07:42:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2C5E20818
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 07:42:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2C5E20818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D1EC6B0005; Wed, 17 Jul 2019 03:42:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 782716B0008; Wed, 17 Jul 2019 03:42:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6981C6B000A; Wed, 17 Jul 2019 03:42:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1CD8A6B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 03:42:15 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i9so17461134edr.13
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 00:42:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4EqQzUppwD1WSlTl6uK3i9sKV2Ui182eWhsL/VEZGEw=;
        b=QxVYFP1rvHArooXG/uIkxuN5Q0R0c0DHTaC1UYlgP7CHwuKLOJScLfI3FynkqaO+mA
         JuqtJijDNIxhjkrCa+tIzbYJd4QYpjKFv7b13+gJxS3SBzetjK2KsoCgYivDWSJtRBrJ
         9AKr85ILhpUWX27bZ4l0BDcbaRvGeddV/oPldKKRFYco4EQXrDmWTr4rw7uqKGtaqhfM
         0t673jX4IbP+NQniyH4HJIi8eVYoVmyEOFXuNC8BFx1szvCotQMYfplRozN3S2eGXx5X
         tasCPFYrigE9Je/2esoQyzjZ6tVzSKhyPspyMmQb3L3dL8eMZB4uZ+D9WqoW+hz7r0bU
         gfRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAW8toh8OnVs71oZi7bDPZBz+rqtCUhsFZr5Au07tm6WiiTgl4U1
	48JWZhNwEPQBISlDrvyjD+1qkeKe80Y0OdzPwsLT+RMN0SyS3t1vZ8vlwwJqKqSe2LX4/j0xSUG
	sf8DleltcgI58VJEnWuOGcR1Fv4P1UjXynt7ZnO2zkoaAR7fy5jrMGWLm+ovwnU1d9w==
X-Received: by 2002:aa7:d5cf:: with SMTP id d15mr33588491eds.67.1563349334644;
        Wed, 17 Jul 2019 00:42:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVTZlS3Y0OIKQ75hqvxSpJA7WXhJJfaisUuygS2TQpaDq/nWpsq2/vpgyEx8O5cdYwMDkl
X-Received: by 2002:aa7:d5cf:: with SMTP id d15mr33588453eds.67.1563349333921;
        Wed, 17 Jul 2019 00:42:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563349333; cv=none;
        d=google.com; s=arc-20160816;
        b=U0+q60yxUa7zFkK1JCO0CzmbHXT4LecqLUBV87L5m1pfdl9jRRQHD0Tehw00dVCpH5
         P9KxnDe98mKmbF9h9hnqGgok12erjI06tSi8FXsIpRnjymo/j0Rta+hSXymE1G9A245W
         Y0BgEYsZptcU9KEq3ImKXBj3NQfTPkRLmp7TvMv8WkD/Glu/8XvAmKW6bwlLjyF7QwIE
         DVfBCW7Dglc6pRC39PVTZ+3uWSYkUfgK2GGuIJnXlV9KraK4gC80sW/qws2XnjfxqfwE
         hYmsYxflL9ILl3T8cGCRvB2AhaAQ6kELBBqGERzgZUvkFXae7ULlQydBNdCmnPMWTpjT
         DFrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4EqQzUppwD1WSlTl6uK3i9sKV2Ui182eWhsL/VEZGEw=;
        b=Se/D667TMAUN8o5b5RwNZI+f9v5o41ayOP/LcCHPzuHb3V7+vND119w66/RDRS7giJ
         WhkBdfNrcAGE532chPeAkUmoO7ZyAQgU8pVOGcV/hrxK1mVDgctoB5YUTaYdQo7/Q775
         RdLrHha9FLsUvJU+RHzaqsdx1O2Bti+vU0uskTqSZpbtQ0ZK/nxhZdWN4PBaZ15ml7+H
         ecNhE4oKYdzHUoiEypMqOQGCNJoOG8ojz2pssqStAhMtEvUSH8TJTiAl2jZYK60/5OXH
         8Zq8+LKKagjtqbInzM/IeIUo7W7WzkVtogHYZSrQSF6RCdymAHFUemZ7P3rqbOru61dM
         0DhA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c17si13815810eds.77.2019.07.17.00.42.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 00:42:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 26CBCAF46;
	Wed, 17 Jul 2019 07:42:13 +0000 (UTC)
Date: Wed, 17 Jul 2019 09:42:10 +0200
From: Oscar Salvador <osalvador@suse.de>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, david@redhat.com,
	pasha.tatashin@soleen.com, mhocko@suse.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] mm,memory_hotplug: Fix shrink_{zone,node}_span
Message-ID: <20190717074210.GB22253@linux>
References: <20190715081549.32577-1-osalvador@suse.de>
 <20190715081549.32577-3-osalvador@suse.de>
 <87tvbne0rd.fsf@linux.ibm.com>
 <1563225851.3143.24.camel@suse.de>
 <87o91tcj9t.fsf@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87o91tcj9t.fsf@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 11:08:54AM +0530, Aneesh Kumar K.V wrote:
> Oscar Salvador <osalvador@suse.de> writes:
> 
> > On Mon, 2019-07-15 at 21:41 +0530, Aneesh Kumar K.V wrote:
> >> Oscar Salvador <osalvador@suse.de> writes:
> >> 
> >> > Since [1], shrink_{zone,node}_span work on PAGES_PER_SUBSECTION
> >> > granularity.
> >> > The problem is that deactivation of the section occurs later on in
> >> > sparse_remove_section, so pfn_valid()->pfn_section_valid() will
> >> > always return
> >> > true before we deactivate the {sub}section.
> >> 
> >> Can you explain this more? The patch doesn't update section_mem_map
> >> update sequence. So what changed? What is the problem in finding
> >> pfn_valid() return true there?
> >
> > I realized that the changelog was quite modest, so a better explanation
> >  will follow.
> >
> > Let us analize what shrink_{zone,node}_span does.
> > We have to remember that shrink_zone_span gets called every time a
> > section is to be removed.
> >
> > There can be three possibilites:
> >
> > 1) section to be removed is the first one of the zone
> > 2) section to be removed is the last one of the zone
> > 3) section to be removed falls in the middle
> >  
> > For 1) and 2) cases, we will try to find the next section from
> > bottom/top, and in the third case we will check whether the section
> > contains only holes.
> >
> > Now, let us take the example where a ZONE contains only 1 section, and
> > we remove it.
> > The last loop of shrink_zone_span, will check for {start_pfn,end_pfn]
> > PAGES_PER_SECTION block the following:
> >
> > - section is valid
> > - pfn relates to the current zone/nid
> > - section is not the section to be removed
> >
> > Since we only got 1 section here, the check "start_pfn == pfn" will make us to continue the loop and then we are done.
> >
> > Now, what happens after the patch?
> >
> > We increment pfn on subsection basis, since "start_pfn == pfn", we jump
> > to the next sub-section (pfn+512), and call pfn_valid()-
> >>pfn_section_valid().
> > Since section has not been yet deactivded, pfn_section_valid() will
> > return true, and we will repeat this until the end of the loop.
> >
> > What should happen instead is:
> >
> > - we deactivate the {sub}-section before calling
> > shirnk_{zone,node}_span
> > - calls to pfn_valid() will now return false for the sections that have
> > been deactivated, and so we will get the pfn from the next activaded
> > sub-section, or nothing if the section is empty (section do not contain
> > active sub-sections).
> >
> > The example relates to the last loop in shrink_zone_span, but the same
> > applies to find_{smalles,biggest}_section.
> >
> > Please, note that we could probably do some hack like replacing:
> >
> > start_pfn == pfn 
> >
> > with
> >
> > pfn < end_pfn
> 
> Why do you consider this a hack? 
> 
>  /* If the section is current section, it continues the loop */
> 	if (start_pfn == pfn)
> 		continue;

I did not consider this a hack, but I really did not like to adapt that
to the sub-section case as it seemed more natural to 1) deactivate
sub-section and 2) look for the next one.
So we would not need these checks.

I might have bored at that time and I went for the most complex way to fix
it.

I will send v2 with the less intrusive check.

> 
> The comment explains that check is there to handle the exact scenario
> that you are fixing in this patch. With subsection patch that check is
> not sufficient. Shouldn't we just fix the check to handle that?
> 
> Not sure about your comment w.r.t find_{smalles,biggest}_section. We
> search with pfn range outside the subsection we are trying to remove.
> So this should not have an impact there?

Yeah, I overlooked the code.

-- 
Oscar Salvador
SUSE L3

