Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04051C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 12:28:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BA96218D3
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 12:28:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BA96218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04D558E0002; Thu, 14 Feb 2019 07:28:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F18FD8E0001; Thu, 14 Feb 2019 07:28:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE23A8E0002; Thu, 14 Feb 2019 07:28:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 82F028E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 07:28:20 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d9so2441789edh.4
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 04:28:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=q1Pf2DPnxwvTQqkiHfBjsgr3/zWh5dw3+4HKpwaSgSY=;
        b=H0GyrJpmsBHrwABBKxGtqz9otmGzPBqrHWZcckiGDtS8c9vbuOaKjxItVJTas61CPe
         4K46nEMv0y2lBodWU6UYT1Ll2R3VQtkYwPOK2Vb61YCQHLsJPHweSwFxI24IDIkcHiwy
         rgiTIRP79zgnU6R7Cy5TLhSmn3I6eCK+lIp2V2KLhjXMC0PohCiAC7obwAfkA+HLlGMM
         WGFLCKOlf1Qoil4PMt+hKaWIOeHw8g/BpOEGU8cRy1MEOeCbEQqg1xLbQNFwPJzySiBK
         /q0lYTVg7y76ESnxQn59RHB4+rFZhcmTdFa3gKLGdEnEt6CeV+Hi3wsYpzqEMuOXI1DY
         cOZA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: AHQUAuatKdufCVXjX1mwEqrrcoRojKb46W5BIKqY/E1/IIDc8UGvnPep
	kaQj1QsCLvwYpxvUpq403uin1w7oa6aMIYLaa2bj74C/ZonhzUFQfGG/prEVXLdABjilJjvRHx1
	93pCLaNhEYHR3UzWAKEtWVIVcZCLGwAux6ENJ49iBCtElvS5HNvX6n5EvI7C5J1VdnA==
X-Received: by 2002:a17:906:7252:: with SMTP id n18-v6mr2615495ejk.192.1550147299938;
        Thu, 14 Feb 2019 04:28:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYPoCgES3qNsHRQI/y4e8nilDAZEowGsYjRX0Kyke79y7piwE18PJqCNElmB3h+8CQp7WmU
X-Received: by 2002:a17:906:7252:: with SMTP id n18-v6mr2615424ejk.192.1550147298800;
        Thu, 14 Feb 2019 04:28:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550147298; cv=none;
        d=google.com; s=arc-20160816;
        b=IKCdXzeXIW1OKQM3AzFpTerS+TCBoXAljG/DinJ78ZGnRq4418jFaKc3/ERMMJuLpm
         NsSq5HuxNOxvMQNfIRBiC/w6n3Sew764bsEOj9r478+uZhiHXG8dFvQVu/Puqh8S30iK
         FvU1pmmwl4uHT5IixsRKX6gmsoiLxx+HQsH2T5xVufpAPoEtvgdGs8zWLc6TIJHzzhSP
         vx8YMkEkb5LPuqAhuNZdZGIXn2ga6AkmXFeFLxPoDjHPr3eORELCJxqiPMM1FXbfw3l4
         O+gp0dtgzo1IefIHQD4zd9Pw/43pU/0smiIgqvLzq0TFfLYr7m0KuKznoqs9liKm5U5x
         VUiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=q1Pf2DPnxwvTQqkiHfBjsgr3/zWh5dw3+4HKpwaSgSY=;
        b=kOU3+UTQE2KsDuIUrkGv/DYcNpH9DymjIh7c//M+qCJzKXVmMP8+QHCvQUDu6IjcRD
         9hFNImOSYIIAqx7sA1b8EiGXpfjvCQ4X1ZHiAUshelpHpy0Z8uGoZHus5+4fXtJ4/ZWz
         eYswa95tDTIXQt5Z5vcdtkhi8Jrse82b7FVS3q/stX191sQAYPMKqapp1Srru2oDbbRN
         uTo88aTk7G9O8d7j18dWPtlYQmHW2KKave21pXIKB2Eu49JaIoUaCQ0e02l0KXt9xt68
         bBZUCBsIa6D8MsGBEW2/4ZIbRVAoimQCIIviy39pZf+iASAnPgsF66+MyhJFeaybI64L
         aw4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t24si992474ejr.13.2019.02.14.04.28.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 04:28:18 -0800 (PST)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E587CACA2;
	Thu, 14 Feb 2019 12:28:17 +0000 (UTC)
Date: Thu, 14 Feb 2019 13:28:16 +0100
From: Michal Hocko <mhocko@suse.com>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org,
	akpm@linux-foundation.org, kirill@shutemov.name,
	kirill.shutemov@linux.intel.com, vbabka@suse.cz,
	will.deacon@arm.com, dave.hansen@intel.com
Subject: Re: [RFC 0/4] mm: Introduce lazy exec permission setting on a page
Message-ID: <20190214122816.GD4525@dhcp22.suse.cz>
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <20190213112135.GA9296@c02tf0j2hf1t.cambridge.arm.com>
 <20190213153819.GS4525@dhcp22.suse.cz>
 <0b6457d0-eed1-54e4-789b-d62881bea013@arm.com>
 <20190214083844.GZ4525@dhcp22.suse.cz>
 <20190214101936.GD9296@c02tf0j2hf1t.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214101936.GD9296@c02tf0j2hf1t.cambridge.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 14-02-19 10:19:37, Catalin Marinas wrote:
> On Thu, Feb 14, 2019 at 09:38:44AM +0100, Michal Hocko wrote:
> > On Thu 14-02-19 11:34:09, Anshuman Khandual wrote:
> > > On 02/13/2019 09:08 PM, Michal Hocko wrote:
> > > > Are there any numbers to show the optimization impact?
> > > 
> > > This series transfers execution cost linearly with nr_pages from migration path
> > > to subsequent exec access path for normal, THP and HugeTLB pages. The experiment
> > > is on mainline kernel (1f947a7a011fcceb14cb912f548) along with some patches for
> > > HugeTLB and THP migration enablement on arm64 platform.
> > 
> > Please make sure that these numbers are in the changelog. I am also
> > missing an explanation why this is an overal win. Why should we pay
> > on the later access rather than the migration which is arguably a slower
> > path. What is the usecase that benefits from the cost shift?
> 
> Originally the investigation started because of a regression we had
> sending IPIs on each set_pte_at(PROT_EXEC). This has been fixed
> separately, so the original value of this patchset has been diminished.
> 
> Trying to frame the problem, let's analyse the overall cost of migration
> + execute. Removing other invariants like cost of the initial mapping of
> the pages or the mapping of new pages after migration, we have:
> 
> M - number of mapped executable pages just before migration
> N - number of previously mapped pages that will be executed after
>     migration (N <= M)
> D - cost of migrating page data
> I - cost of I-cache maintenance for a page
> F - cost of an instruction fault (handle_mm_fault() + set_pte_at()
>     without the actual I-cache maintenance)
> 
> Tc - total migration cost current kernel (including executing)
> Tp - total migration cost patched kernel (including executing)
> 
>   Tc = M * (D + I)
>   Tp = M * D + N * (F + I)
> 
> To be useful, we want this patchset to lead to:
> 
>   Tp < Tc
> 
> Simplifying:
> 
>   M * D + N * (F + I) < M * (D + I)
>   ...
>   F < I * (M - N) / N
> 
> So the question is, in a *real-world* scenario, what proportion of the
> mapped executable pages would still be executed from after migration.
> I'd leave this as a task for Anshuman to investigate and come up with
> some numbers (and it's fine if it's just in the noise, we won't need
> this patchset).

Yeah, betting on accessing only a smaller subset of the migrated memory
is something I figured out. But I am really missing a usecase or a
larger set of them to actually benefit from it. We have different
triggers for a migration. E.g. numa balancing. I would expect that
migrated pages are likely to be accessed after migration because
the primary reason to migrate them is that they are accessed from a
remote node. Then we a compaction which is a completely different story.
It is hard to assume any further access for migrated pages here. Then we
have an explicit move_pages syscall and I would expect this to be
somewhere in the middle. One would expect that the caller knows why the
memory is migrated and it will be used but again, we cannot really
assume anything.

This would suggest that this depends on the migration reason quite a
lot. So I would really like to see a more comprehensive analysis of
different workloads to see whether this is really worth it.

Thanks!
-- 
Michal Hocko
SUSE Labs

