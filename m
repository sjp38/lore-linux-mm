Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2975C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 13:40:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C92B2171F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 13:40:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C92B2171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD58C8E0003; Thu, 28 Feb 2019 08:40:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B84338E0001; Thu, 28 Feb 2019 08:40:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9BAB8E0003; Thu, 28 Feb 2019 08:40:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 511D68E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 08:40:57 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id a21so8660266eda.3
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 05:40:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Dz51opm0vTa+oa6TetCzbCIeT/g8kJB9ycKdpiyu/1s=;
        b=kFyX7/1NUE9LLNnPkmYZrIcH2HfbuIQYfionDmw7mlY2J8/onYExiRSHyXniHYtI7F
         aNUmgafVWQ8oaRAqKpGGx580Y5mt//xqZEb6JRG3qaUImSAQYkc+oLC+pGE/u7y8u97P
         KsZKHnosMIxkNjpwz7dOn8alxlGs0FPlghOIEjuyV68cYX1Cbx2QKTS3maBveWrTugvO
         YOzMIKpcZYMepaOea6PG0jGPIGzk6lLdWNTKptAUWMIoMeqV+XW+/H2eUmn8MdabvirA
         VVBI4jbzqjjyBicJbMmY4whG+rhBTbycXpK/mca8b+mFm7iB/5ZaWxmQIIIfMcXT2hZU
         7eNA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAuaTg+iCyvio/SzaUmZ0A7FgGJJLEp+sEGdvlgwA/IYZw0YTImR9
	D9rWhvwpyC2cXj7bR0DzmZWjazPqt3OvErZdlKDfYs3FC5HCB0Dz+vp/V5XgxH/lqBPyVKN2lat
	TaF0ugb5lV4KAmsV2zaHxWs4SW/fQdIH2bLjY2nt2jbxIb8YwOK3qaZ7maxdYnQE=
X-Received: by 2002:a50:c352:: with SMTP id q18mr6880776edb.175.1551361256800;
        Thu, 28 Feb 2019 05:40:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IboEEW21q0Mj1CAhs5EILkWcwtK5qQrnOp805VGKdjOcGYXIOetv5JACabL8L8jfuiyOnwj
X-Received: by 2002:a50:c352:: with SMTP id q18mr6880702edb.175.1551361255635;
        Thu, 28 Feb 2019 05:40:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551361255; cv=none;
        d=google.com; s=arc-20160816;
        b=OoNS1pwdZmb9MBuiEtnTJWGnM7gZyoHPXsWQ7u77SwyRiRkMhbYeQBSmjLGeqdLi6E
         cE35WT/64YPwOIsYj3/LbZANhlgHesYU3hkI7MwHGuci7RpTDHsDq93NERKnbhxwODiR
         08iPeab0vBsXaAUCO4AbyOg+T/zUWuG6RGix89BVFd5pHTFCX+QcmBOynf/lVrSC7zc8
         870SrhkWdUwz8QIYTKkjdHRKdWUpwp5Vtp3ZdqzCzT/bKg3CvS/BGFZ6wSRon/qmc7C9
         eqFpXFBkhTrUUgFEq58fuxeWhkgYVYY8QN34sF+FOO/A6Mi9lMMgWbe123yv8RoL/xrI
         7+ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Dz51opm0vTa+oa6TetCzbCIeT/g8kJB9ycKdpiyu/1s=;
        b=WvIy2juMWVgYfYbK+DWMfE4C1hRPMGY2oOCJdchptnUMd89EUa+w7Z7p/SgHyZIomW
         Evcp3tfsAALw46IibX6FzS33WHJ8UDiHip0WQ55meU0CnMUQCu9gmaYt0BhGjDxE1dT7
         Kf3hqZyI6WJ8HY4rr1bWz09V1HtMqRKoK2KF0zmG015xly4uq7k4e36E4X0XNo08RwEn
         TEnCKAhaOhK3/7KTOdFxX16hmOC0H+mQY6Fp483Pm5bCChCR7ybv8hlf5eUXQ4hfDd8h
         JDvRVKzHyG8rlBd2iHKeexiEXqoqqlXgcW2f3vXCHf1NA5cMinfYfMrcwfEE2g5Dp5Dz
         s+kA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id c52si4176985edb.145.2019.02.28.05.40.55
        for <linux-mm@kvack.org>;
        Thu, 28 Feb 2019 05:40:55 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 698364407; Thu, 28 Feb 2019 14:40:54 +0100 (CET)
Date: Thu, 28 Feb 2019 14:40:54 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, david@redhat.com,
	mike.kravetz@oracle.com
Subject: Re: [RFC PATCH] mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
Message-ID: <20190228133951.outlsq7swhp3nffr@d104.suse.de>
References: <20190221094212.16906-1-osalvador@suse.de>
 <20190228092154.GV10588@dhcp22.suse.cz>
 <20190228094104.wbeaowsx25ckpcc7@d104.suse.de>
 <20190228095535.GX10588@dhcp22.suse.cz>
 <20190228101949.qnnzgdhyn6deevnm@d104.suse.de>
 <20190228121115.GA10588@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190228121115.GA10588@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 01:11:15PM +0100, Michal Hocko wrote:
> On Thu 28-02-19 11:19:52, Oscar Salvador wrote:
> > On Thu, Feb 28, 2019 at 10:55:35AM +0100, Michal Hocko wrote:
> > > You seemed to miss my point or I am wrong here. If scan_movable_pages
> > > skips over a hugetlb page then there is nothing to migrate it and it
> > > will stay in the pfn range and the range will not become idle.
> > 
> > I might be misunterstanding you, but I am not sure I get you.
> > 
> > scan_movable_pages() can either skip or not a hugetlb page.
> > In case it does, pfn will be incremented to skip the whole hugetlb
> > range.
> > If that happens, pfn will hold the next non-hugetlb page.
> 
> And as a result the previous hugetlb page doesn't get migrated right?
> What does that mean? Well, the page is still in use and we cannot
> proceed with offlining because the full range is not isolated right?

I might be clumsy today but I still fail to see the point of concern here.

Let us start from the beginning.
start_isolate_page_range() will mark the range as isolated unless we happen to have
unmovable pages within it (for the exercise here, that would be non-migreateable hugetlb
pages).

If we pass that point, it means that all hugetlb pages found can really be migrated.
Leter, scan_movable_pages() will scan them, and it will only take those that are
in use (active), as are the ones that we are interested in.
We will skip those who are not being used (non-active).

If it happens that we skip a hugetlb page and we return the next non-hugetlb page
to be migrated, do_migrate_range() will proceed as usual, eventually we will
break the main loop due to having being scanned the whole range, etc.

If it happens that the whole range spans a gigantic hugetlb and it is not in use,
we will skip the whole range, and we will break the main loop by returning "0".
Eitherway, I do not see how this changes the picture.

-- 
Oscar Salvador
SUSE L3

