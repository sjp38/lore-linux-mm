Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B73A5C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:13:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B9B7222BE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:13:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B9B7222BE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 043B48E0003; Wed, 13 Feb 2019 03:13:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE4D88E0001; Wed, 13 Feb 2019 03:13:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D855F8E0003; Wed, 13 Feb 2019 03:13:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7A78E8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 03:13:16 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c53so671399edc.9
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 00:13:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7UEmyJCWJjjhWN/eXJDKRv1/9V76E1Y+8rtVi34t7Q8=;
        b=G33OaAk2ms608Kid04LR5bjcLYyMYmICVuOmOTUq8jalEoMbckA+k9nu4ZXLHCNKZl
         A/cklxliAqssebn7jdISmEbPc7RTOq2nsRVocOjTEGrlOLAGMnWvzyEdGhAimvYFj/KL
         bSLTjUfyI6cKEojVMjpr0i9oMwPiHhnG8krvO1V6NrL/k6gWtETTZn2c/T5fCWmpgiRO
         c3NcSi+5PzdFwk2tHqCqkcELqWcLsOX3eh1ce1QMx/8DUicYxR4dJsA0YYQjTUXxUx8h
         uLsSzuSS18xAK8tagKifjhl9wl+t9qso8s8abQ7yFRh2glOxoN65Za0N6V1LLwbv3XOP
         FYNQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAuapd2y8npMk6pDIsEqfEZqkjl1HFB02te3IrlqBO8zIje7vqau1
	9woqWTej1jIO7fqrzp6o5IEEwEciUTgCMooHaa4FpnD4jS1nvTCGp18BafuFnhfY5JsTNvAhTfh
	k/U0+alPufUwsIHZBOCRpBkE50MSWz9C2jA/Wf21IdYR7iWG9i5Jtpm5nHDYpr3A=
X-Received: by 2002:a50:ee0d:: with SMTP id g13mr6607040eds.230.1550045596042;
        Wed, 13 Feb 2019 00:13:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IboPo9pksoH96sAPlDM5eqe6kigMAZUqwRh8HTNnc+nUbAVzOsw/PkmK5QANzmRdS3qhuuM
X-Received: by 2002:a50:ee0d:: with SMTP id g13mr6606996eds.230.1550045595226;
        Wed, 13 Feb 2019 00:13:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550045595; cv=none;
        d=google.com; s=arc-20160816;
        b=MnkQCrHY5nZgHLkiBq9bdyBsxWta90apClOTiMPM0MiAPyo3K5voRDuxKGmnJR89Ch
         LnG9chn0jEgjOqHCPgC5TOpEtZEu6zImL77aDuHy12MznWm4TqKyPWIRnbx4iVFsbJKA
         7LOcCr9RTcF+35erDo+axAYUAN9cIMt9yyeKKoPpVrMrnS61mrfgeSe93HMBruHxVwsV
         ZgnudNIlEIdkexOTNNyof5YgxUkL9aXqim0+1O55nxGipSscSArIwo/NeanbLf+vXnt9
         zrfTQIEthIFi0rtnH1+F/iwrI2na8u+obbaPJ+AUP5YignhHyfyEQAn/WnwITRg/RK3E
         1JLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7UEmyJCWJjjhWN/eXJDKRv1/9V76E1Y+8rtVi34t7Q8=;
        b=mLZRWIPOy4BrBcOtp5O9W69Sdybcio14E+jSBWwFkqc63yGj0w6Cbv5Rob7RO3Ref1
         JVdHitTp/8NufuzmODagQeknPUL+z2QkW3W6CftuMzIJWgRgUDs09uUDwJ8C+7G1T8B0
         rV7p1BJfW566NPJ1/UFVBtk3pEfU9DmACy9/hqlWGNFwJz8nLUjti/WSl8ZM9iyP+Unw
         gsy2quSJ93cnMCosS/HrWwHqOKgOiSizgdqKUrKMq+USoiBXLqx8Nt9iRIdW8fdWu2d9
         P9RCw9PmNXVNUaJXFuFnIUrl6qCxymrQ9WNpuuP1gN8g2gaHQ+5Z1UBokp7O9vCZ/WMa
         RSqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id f16si2460248eds.222.2019.02.13.00.13.15
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 00:13:15 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 6058E426F; Wed, 13 Feb 2019 09:13:14 +0100 (CET)
Date: Wed, 13 Feb 2019 09:13:14 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org,
	david@redhat.com, anthony.yznaga@oracle.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm,memory_hotplug: Explicitly pass the head to
 isolate_huge_page
Message-ID: <20190213081310.zfxwb3svoqsxnuyc@d104.suse.de>
References: <20190208090604.975-1-osalvador@suse.de>
 <20190212083329.GN15609@dhcp22.suse.cz>
 <20190212134546.gubfir6zzwrvmunr@d104.suse.de>
 <20190212144026.GY15609@dhcp22.suse.cz>
 <52f7a47c-4a8b-c06d-04c0-48d9bb43823b@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52f7a47c-4a8b-c06d-04c0-48d9bb43823b@oracle.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 04:13:05PM -0800, Mike Kravetz wrote:
> Well, commit 94310cbcaa3c ("mm/madvise: enable (soft|hard) offline of
> HugeTLB pages at PGD level") should have allowed migration of gigantic
> pages.  I believe it was added for 16GB pages on powerpc.  However, due
> to subsequent changes I suspsect this no longer works.

I will take a look, I am definitely interested in that.
Thanks for pointing it out Mike.

> 
> > This check doesn't make much sense in principle. Why should we bail out
> > based on a section size? We are offlining a pfn range. All that we care
> > about is whether the hugetlb is migrateable.
> 
> Yes.  Do note that the do_migrate_range is only called from __offline_pages
> with a start_pfn that was returned by scan_movable_pages.  scan_movable_pages
> has the hugepage_migration_supported check for PageHuge pages.  So, it would
> seem to be redundant to do another check in do_migrate_range.

Well, the thing is that if the gigantic page does not start at the very beginning
of the memblock, and we do find migrateable pages before it in scan_movable_pages(),
the range that we will pass to do_migrate_ranges() will contain the gigantic page.
So we need the check there to cover that case too, although I agree that the current
check is misleading.

I will think about it.

-- 
Oscar Salvador
SUSE L3

