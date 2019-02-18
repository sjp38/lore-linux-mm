Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF42EC10F01
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 19:05:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E4B7217D7
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 19:05:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="lvNDpOUK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E4B7217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 020178E0003; Mon, 18 Feb 2019 14:05:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F104B8E0002; Mon, 18 Feb 2019 14:05:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD7C28E0003; Mon, 18 Feb 2019 14:05:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9AA938E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 14:05:24 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 74so14377233pfk.12
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 11:05:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=g5AvimQGenRhlXMXqYl0ru8SXdeHWIlWf5DBX0KvNhk=;
        b=OPsSB2nJN4NcrnzNt2QIoekF6IA3MQVvo3Frci/aqeeV4dwlFAxol3BWQLTe0iEoyF
         LHEwP75ZWnHF1Rlko3FE+1kiitL2/zcaeeWXpgCUGUOvp/ktfLpmW7ffmCvBZuPrkJ9H
         jqoFoWcOOeIor43lB4GV7dgtp7kXkPbT13ydwRMpjJUh/Q2ieps81uDnJmn2rvKAtB2o
         vU5wIB/GfTKt+Gd29fabezshdvpuFdUOdR6Rdmvq3LnNfko3fJdlIQuW7xjV1V7nPwGj
         iFcHh1/9XkMouqWnZ4RGhuohr5BCr8O9EXD06CZ7cXvR/ctjqhJ28WA4alWfckwUABUa
         NWjA==
X-Gm-Message-State: AHQUAuZe3GWJVfW26rGGOhJk9FvNyF7dyGH9LeOs1aVBiaxaJqtkOXpm
	zYRk3SEcI1HJQbdjPoPj1BPyIIk2obrpwQ6ENN/Uwnma0FbqeQEnmFSb1w7+WDMjhohgfaQDoJi
	oI/gV+xhHXL1zvhERkcOnA2BcDPc+ku8P7Zk4cj7NajPh2oFGOuJKr+Oic7Nyov5dWA==
X-Received: by 2002:a17:902:e00d:: with SMTP id ca13mr303658plb.206.1550516724268;
        Mon, 18 Feb 2019 11:05:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iay8rqVh8oJv1/eSREK1jcs4sUA/pXnMoTIqhTmA/Gj8qK8QxDR6YNmdQ1uApp7ZolNI9/1
X-Received: by 2002:a17:902:e00d:: with SMTP id ca13mr303589plb.206.1550516723358;
        Mon, 18 Feb 2019 11:05:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550516723; cv=none;
        d=google.com; s=arc-20160816;
        b=l3WLbAQtCeKWwMpjR00PGY1yQDFO636XZF/cde+Dcof0KzHg3exVU8IytcaLWaZul8
         aBhi9D5VKFRJ5lbDl3QmWLNCP2ewR8tyJc2b8hY7fIzfzv5u3G4B62W4TwbSz/HdIIKU
         HNmytm7z5o8u84AFgj4Bv0WS4tiT4Aw56ey7Wq1bMO9czF90A0lhL6DHOlTjPmRTBOQ9
         GbRXStxCabVDDhhz8ktH/4KRT8JDXq1H9CPNplFfPhO4oYmmKa9YUaUnkCNgXIM7Xqre
         2pO+6DOLqfAft3L3m1qND/3ZcTjwsllit6zOjrPgDQisPcLaC7jURYF8/V+eeRwlBweT
         +7wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=g5AvimQGenRhlXMXqYl0ru8SXdeHWIlWf5DBX0KvNhk=;
        b=uKSZxl8LTkcJt/wLtsYmscxGK8uItOCO4audJXSeKfxfH4MHKN+EHyeNjBFBlPLCVE
         fBEuEcOh5A61ZHFUtcKfvoEyNq2feleDcEFuS+9BfU/C1Tqeo42nJNTetnJqVs01WCFT
         rHxJzX/tjs/m4p4dEGGRuYHWAZigQkNuYCncaha7euKvyTttt5/xff3noSO4jsv+PPPN
         5pDx/ULvuUP82Lrc/OVA7/Qtn7szYa0sthudt3tUhSsUa+RK4RDawWUUC8JKald/mjZZ
         qZiMGWjDOPS8CuGncoQ0rosbPHM9K8WJ10Vs8yqFSqNDBy1AcV7O3J5ejTolhxKkNx41
         SxDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=lvNDpOUK;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r4si12930119pgv.245.2019.02.18.11.05.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 11:05:23 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=lvNDpOUK;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=g5AvimQGenRhlXMXqYl0ru8SXdeHWIlWf5DBX0KvNhk=; b=lvNDpOUKSxwz3Oa9crOFBip3E
	h8WGDPoH8yvzlMcw1fKMJAuVSHRvXhKXAIsA8kUTTkbF6z3w2PtEjvOUBI2S2qXCuL/+BUdQCJkjw
	1QzZ60+E6fS2YDyyM2WWcwZyPt6D0zFSrzvXrtWrClBGqP1Y9Js/LvwO6vaGbtO1/eLnZR3KpGSnQ
	oZK5QEWJsd469BXVXZrYQeL5/s3bUpLk14ODkvZ06c56Z2kabdwOj+71ZSvlBDybIwYu1UAyxha2r
	T7FPtT/4OqSoJMyOlAnHZ4etjQq6Mef26hcsOUErr4zQGcTuQkHXLpTGnZodr12HsVznHYjP7fg6Y
	5UhUNu8rg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gvoEC-0003Lu-2r; Mon, 18 Feb 2019 19:05:20 +0000
Date: Mon, 18 Feb 2019 11:05:19 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>, Rong Chen <rong.a.chen@intel.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	linux-kernel@vger.kernel.org,
	Linux Memory Management List <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>, LKP <lkp@01.org>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [LKP] efad4e475c [ 40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
Message-ID: <20190218190519.GV12668@bombadil.infradead.org>
References: <20190218085510.GC7251@dhcp22.suse.cz>
 <4c75d424-2c51-0d7d-5c28-78c15600e93c@intel.com>
 <20190218103013.GK4525@dhcp22.suse.cz>
 <20190218140515.GF25446@rapoport-lnx>
 <20190218152050.GS4525@dhcp22.suse.cz>
 <20190218152213.GT4525@dhcp22.suse.cz>
 <20190218164813.GG25446@rapoport-lnx>
 <20190218170558.GV4525@dhcp22.suse.cz>
 <20190218175726.GU12668@bombadil.infradead.org>
 <20190218181155.GC4525@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218181155.GC4525@dhcp22.suse.cz>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 07:11:55PM +0100, Michal Hocko wrote:
> On Mon 18-02-19 09:57:26, Matthew Wilcox wrote:
> > On Mon, Feb 18, 2019 at 06:05:58PM +0100, Michal Hocko wrote:
> > > +	end_pfn = min(start_pfn + nr_pages,
> > > +			zone_end_pfn(page_zone(pfn_to_page(start_pfn))));
> > >  
> > >  	/* Check the starting page of each pageblock within the range */
> > > -	for (; page < end_page; page = next_active_pageblock(page)) {
> > > -		if (!is_pageblock_removable_nolock(page))
> > > +	for (; start_pfn < end_pfn; start_pfn = next_active_pageblock(start_pfn)) {
> > > +		if (!is_pageblock_removable_nolock(start_pfn))
> > 
> > If you have a zone which contains pfns that run from ULONG_MAX-n to ULONG_MAX,
> > end_pfn is going to wrap around to 0 and this loop won't execute.
> 
> Is this a realistic situation to bother?

How insane do you think hardware manufacturers are ... ?  I don't know
of one today, but I wouldn't bet on something like that never existing.

> > I think
> > you should use:
> > 
> > 	max_pfn = min(start_pfn + nr_pages,
> > 			zone_end_pfn(page_zone(pfn_to_page(start_pfn)))) - 1;
> > 
> > 	for (; start_pfn <= max_pfn; ...)
> 
> I do not really care strongly, but we have more places were we do
> start_pfn + nr_pages and then use it as pfn < end_pfn construct. I
> suspect we would need to make a larger audit and make the code
> consistent so unless there are major concerns I would stick with what
> I have for now and leave the rest for the cleanup. Does that sound
> reasonable?

Yes, I think so.  There are a number of other places where we can wrap
around from ULONG_MAX to 0 fairly easily (eg page offsets in a file on
32-bit machines).  I started thinking about this with the XArray and
rapidly convinced myself we have a problem throughout Linux.

