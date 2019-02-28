Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFB1EC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 21:01:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61AE620C01
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 21:01:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61AE620C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B75218E0003; Thu, 28 Feb 2019 16:01:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B24478E0001; Thu, 28 Feb 2019 16:01:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A15018E0003; Thu, 28 Feb 2019 16:01:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 428D78E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 16:01:42 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id i22so9060340eds.20
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 13:01:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FuRHuyMDrl1cSR4D8Guj9sIHBIuPMlCf6W3u7nHcSco=;
        b=XucH0vXGKCd0fObp2OXahPE6u2JMCYUlH3s6CeiZBcFm6K+VouTirrF6pAK8y87dsc
         oEbzqi2VyUOH5w7DDomlksC+C27D6Px66MzRZKEYsd/u0mAw6XQyb0usfzuIsT3vpjsf
         4f56zoiWRYWN/1Rjbi5FUETJhjf1K1Dv1sMQn2UG4OwnQZX548lcSq7+tpH2/sV0M+y+
         HJ+fEYxfVUAYx920cFgaImVs9y7t4XPtTwxfI0+bx/8KnxcdJ0QSQF0+iFn31CtQe+3X
         l7Ny7mYO84rtR+YMIntIoSQj3EQrdIXSi7B4h8TVuhcxzz29VeuzmMeItQu+0uHqkLoX
         beqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWIhR4FlT7u1gc6KOuo298fDAeT2WgUqySjIeW63p0gW622HTZs
	lTjPQMCaHfcUpk1I8JC9zHFvQW9UCBqDMrH9flpqDqDiQXvxVgT3mlpLr+lLYTLUPk9PInksqBA
	ruNSk7JGJxKJUFRB93VNDxFA/b1h5oLeydk0lyajuFfDlp1asBNF/4yqM/Wzi7qxgcQ==
X-Received: by 2002:a17:906:b30c:: with SMTP id n12mr545444ejz.49.1551387701829;
        Thu, 28 Feb 2019 13:01:41 -0800 (PST)
X-Google-Smtp-Source: APXvYqwAscchw51bjxXKUw1R4xd+kQmYNomr/ZaX3ncnFd7ETnfsQnodRtplaQV9+Hb1OBbkfCOP
X-Received: by 2002:a17:906:b30c:: with SMTP id n12mr545399ejz.49.1551387700831;
        Thu, 28 Feb 2019 13:01:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551387700; cv=none;
        d=google.com; s=arc-20160816;
        b=ReNg7MP36Mv8rI1BQdx2kiezIS5PPJqhvWzuw8Zjg7O958Ins+9bPxMt2iptUZBGiD
         Tr+9X98C2ipYJPIfiRgbHE2dJmJgALPM0OMDqQ94rILZyL8djkRxa6QzPdkq6Bjs59nm
         ThGCQ70Xttgxs5AsY5fi4OCb406vNyBycHTYrfa+lLJkSCoDsJINb/fKOkIrzDexWKPZ
         sux9QL86GuxMR8hlII4AVRNO02Yz9GheLHDdcVrxX6Htc7+/pT5CBUlwV2/LvzUt9JyB
         UFbkrP+nfxCoL3sG8q97kn3olt/dysB9M8TOWZT41ilrltxNfkLzBdGzipMQopwiDsSq
         owAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FuRHuyMDrl1cSR4D8Guj9sIHBIuPMlCf6W3u7nHcSco=;
        b=wLggpB+DuiDkh65DSCGpcNtZOF8epmnw9EpV3HivkMxLJMs6F8PvLhAm1CJA9rSvwP
         FHWZuz7smQuf9B6KdwBISyGJPHuD487pyunTrdB/UJENjDa2fnaUhYSi+NXiLK9X+WPp
         MDbF3RL0zWou6ePbAjF+C0ww3KgBoyPolYjtjSdDxmNhmH+gp/a8a/23aVXmKXnT1EkA
         5cWcX76eWJU9uDH/KnsSqnULAECpdm4n4mZ3EbGvC6PWd27Czo3pHj6Xrm3YMt8d2cLv
         45FygoOJBVfgTzlA1zuEbITRVeYJVavUvaBrIkIhSrCqNanR7udtftuPDJwLtAeRFDGE
         w9XQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id c3si2633445ejm.98.2019.02.28.13.01.40
        for <linux-mm@kvack.org>;
        Thu, 28 Feb 2019 13:01:40 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id B4FDC4410; Thu, 28 Feb 2019 22:01:39 +0100 (CET)
Date: Thu, 28 Feb 2019 22:01:39 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, david@redhat.com,
	mike.kravetz@oracle.com
Subject: Re: [RFC PATCH] mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
Message-ID: <20190228210135.3tzfhv763o2gzohw@d104.suse.de>
References: <20190221094212.16906-1-osalvador@suse.de>
 <20190228092154.GV10588@dhcp22.suse.cz>
 <20190228094104.wbeaowsx25ckpcc7@d104.suse.de>
 <20190228095535.GX10588@dhcp22.suse.cz>
 <20190228101949.qnnzgdhyn6deevnm@d104.suse.de>
 <20190228121115.GA10588@dhcp22.suse.cz>
 <20190228133951.outlsq7swhp3nffr@d104.suse.de>
 <20190228140817.GD10588@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190228140817.GD10588@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 03:08:17PM +0100, Michal Hocko wrote:
> On Thu 28-02-19 14:40:54, Oscar Salvador wrote:
> > On Thu, Feb 28, 2019 at 01:11:15PM +0100, Michal Hocko wrote:
> > > On Thu 28-02-19 11:19:52, Oscar Salvador wrote:
> > > > On Thu, Feb 28, 2019 at 10:55:35AM +0100, Michal Hocko wrote:
> > > > > You seemed to miss my point or I am wrong here. If scan_movable_pages
> > > > > skips over a hugetlb page then there is nothing to migrate it and it
> > > > > will stay in the pfn range and the range will not become idle.
> > > > 
> > > > I might be misunterstanding you, but I am not sure I get you.
> > > > 
> > > > scan_movable_pages() can either skip or not a hugetlb page.
> > > > In case it does, pfn will be incremented to skip the whole hugetlb
> > > > range.
> > > > If that happens, pfn will hold the next non-hugetlb page.
> > > 
> > > And as a result the previous hugetlb page doesn't get migrated right?
> > > What does that mean? Well, the page is still in use and we cannot
> > > proceed with offlining because the full range is not isolated right?
> > 
> > I might be clumsy today but I still fail to see the point of concern here.
> 
> No, it's me who is daft. I have misread the patch and seen that also
> page_huge_active got removed. Now it makes perfect sense to me because
> active pages are still handled properly.

Heh, no worries.
Glad we got the point, I was just scratching my head like a monkey.

> I will leave the decision whether to split up the patch to you.

On a second thought, I will split it up.
One of the changes is merely to remove a redundant check, while the other is
actually the one that enables the system to be able to proceed with gigantic
pages, so not really related.

> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

-- 
Oscar Salvador
SUSE L3

