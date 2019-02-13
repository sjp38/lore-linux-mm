Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06885C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 12:33:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C22E8222B2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 12:33:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C22E8222B2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C1298E0002; Wed, 13 Feb 2019 07:33:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5700F8E0001; Wed, 13 Feb 2019 07:33:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 488C48E0002; Wed, 13 Feb 2019 07:33:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E47478E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 07:33:43 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x15so965503edd.2
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 04:33:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QByGILMX/Z+FlJqKUcPqFLFkmugMVUtixdSqBjfRFRQ=;
        b=opm2EGhTArSbi/KYrcSNodCxRKn2HSJsENfu3/B6G29Ytx/AHBb87Flc92a5+UyP4l
         YQWvHNoeR9b8ECkCWWwz6rMSlIiqfYpU4+czRSh71/b5qlnYrR7YPNZGClewoVSsyjBs
         zdC2JgVF9JERDl6d7To1gSgVW+czH//2RX2ofcYnt6st0D0JUeRfcQdlHEWnloqHTCsS
         qRYNBIdy0dZRh+UUPYotM7wTzsxYDDHSyaOnfvGnumNb/WealTD4YygiJc1fW19rXhoe
         mMNH945qN9LZ7CgmYgs6/u+0Ua7oXazJZr9d7F/zclXQx1cSBKhxo3uYRLEsNz10/2t7
         3liQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZTtSrNXGqFi8j3ke0PpEvt6G3HOa9nBt8TpcXhJI0aqXd1d5sx
	K0ChjhsdxIa20M6qvxxkcTBGvNyY5ZQzL6xgrKMDgrIX8WENPJ4IQtzWbF0XgJ8Im8F+C/hR/rg
	V+wFXL2oGPCwATuvHo2TF9G/SgjBdW9ckNaSexTEB76XfbGGCGebEwmNnUmDbEzk=
X-Received: by 2002:a17:906:7e57:: with SMTP id z23mr203053ejr.222.1550061223403;
        Wed, 13 Feb 2019 04:33:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbAh7x29WNQSSl2Ub0AFwNr0zXb4xUPjgNbL/8PdKPByZKlup4TMNWBe0nfVjmVljyYrnd7
X-Received: by 2002:a17:906:7e57:: with SMTP id z23mr202990ejr.222.1550061222397;
        Wed, 13 Feb 2019 04:33:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550061222; cv=none;
        d=google.com; s=arc-20160816;
        b=Fz3i879pVzBaQWO/kmVBwCrNY5ewoYlT7VihF/BKy5Ap7QU5vJt5GTxkvLKBkkpqF2
         Y4Ow9vor8Yanw4VjyxU4LF4/USuzykZKT4PwTRJ6CvwLNXBdwhTgqMIxlPMDtwnAjN10
         Ui2pHcxzFmC0q0LxeRLwsI+2AjBceLayWYAiinauYdIhPfNuwj6pogs5jdJCanGn9ahf
         z9WG6V7nGod3anIHu6N43QXdhlD1j7r7/C6OrohQCW75pS4mkYrYyVPNuD0eGEtEocEI
         Hx5hwW2X2Cl+lmfOnQ3wnqjZPzlDW4re5YBPuvlckYhLM5sb7cZ7bNl5T8hmJJV8vCSQ
         u41Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QByGILMX/Z+FlJqKUcPqFLFkmugMVUtixdSqBjfRFRQ=;
        b=tsKreLUn0hDIzsH/HFfLKc+E2vyzlEtx+MuNQfi+Eu6YJTub8crSiTdzTRUINcZU0A
         c5UxeXW5uAkmsbewtKm2PG66DO7JdNpueiIjSt+zn36o8XAELtpYod6qMr8ytLDBlbLl
         QqhPmsopCgYbsetwxhZaVkZHd5cRn01XARr8zr5grBF7r/liuih+80dgRt/WAlVtHFZl
         LA9LmJ+KXV2oQ72j6aC4J2qpa9CLWmUHajrX731Vgh0WXmKnDlFTrt+quuEWtGPz+Dra
         RKGydANMusKSGvPCRchDnLT1rcFZbC5xuyKw8aD8wlqNADVh0dOpLZ86LM8tVVBORa43
         YTCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l1si1151083ejs.32.2019.02.13.04.33.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 04:33:42 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E819DAFB8;
	Wed, 13 Feb 2019 12:33:41 +0000 (UTC)
Date: Wed, 13 Feb 2019 13:33:39 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, akpm@linux-foundation.org,
	david@redhat.com, anthony.yznaga@oracle.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm,memory_hotplug: Explicitly pass the head to
 isolate_huge_page
Message-ID: <20190213123339.GG4525@dhcp22.suse.cz>
References: <20190208090604.975-1-osalvador@suse.de>
 <20190212083329.GN15609@dhcp22.suse.cz>
 <20190212134546.gubfir6zzwrvmunr@d104.suse.de>
 <20190212144026.GY15609@dhcp22.suse.cz>
 <52f7a47c-4a8b-c06d-04c0-48d9bb43823b@oracle.com>
 <20190213081310.zfxwb3svoqsxnuyc@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213081310.zfxwb3svoqsxnuyc@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-02-19 09:13:14, Oscar Salvador wrote:
> On Tue, Feb 12, 2019 at 04:13:05PM -0800, Mike Kravetz wrote:
> > Well, commit 94310cbcaa3c ("mm/madvise: enable (soft|hard) offline of
> > HugeTLB pages at PGD level") should have allowed migration of gigantic
> > pages.  I believe it was added for 16GB pages on powerpc.  However, due
> > to subsequent changes I suspsect this no longer works.
> 
> I will take a look, I am definitely interested in that.
> Thanks for pointing it out Mike.
> 
> > 
> > > This check doesn't make much sense in principle. Why should we bail out
> > > based on a section size? We are offlining a pfn range. All that we care
> > > about is whether the hugetlb is migrateable.
> > 
> > Yes.  Do note that the do_migrate_range is only called from __offline_pages
> > with a start_pfn that was returned by scan_movable_pages.  scan_movable_pages
> > has the hugepage_migration_supported check for PageHuge pages.  So, it would
> > seem to be redundant to do another check in do_migrate_range.
> 
> Well, the thing is that if the gigantic page does not start at the very beginning
> of the memblock, and we do find migrateable pages before it in scan_movable_pages(),
> the range that we will pass to do_migrate_ranges() will contain the gigantic page.
> So we need the check there to cover that case too, although I agree that the current
> check is misleading.

Why isn't our check in has_unmovable_pages sufficient?
-- 
Michal Hocko
SUSE Labs

