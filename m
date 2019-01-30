Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC06EC282D4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 07:54:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E4DA20882
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 07:54:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E4DA20882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D8EA8E0002; Wed, 30 Jan 2019 02:54:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 185868E0001; Wed, 30 Jan 2019 02:54:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 076FA8E0002; Wed, 30 Jan 2019 02:54:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B9D5B8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 02:54:46 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id l45so9031223edb.1
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 23:54:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4+yCoHTjz/Dv2oTXa5X77cG+WLvuWaZd9S3y3pGNVpA=;
        b=mRDxKTXizc2Hq3MWF19E8kXOAEB+gK9rfyIDnR7XV7JZnyr9Q27cbgeQLNz76Km1xB
         Usq7To5EVwiwo01mNCFQtVBWA/Xr8Pp9cu8BegRgckPncMXIeB94lyELjQ/c+Zp60Uno
         9Iiu9BKShIBWiZttpkeSDOcu05sgnVeeezeK6AQZb0X/eQngu3VHJmHSvi0gkU1LTgcx
         THxKXPpBl8RRuFvOFHb9jhoSn6UNjYMscZziXyAMle+Yw544dWzkNYjtSGkzBfR4bK7E
         gGORIIHLmqKeKGtvGuusP9WkiTMEUoksfYLOznGAceRTJgZCa5KayYvA9vLBlmRCPFHi
         9bHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AJcUukcYL9v8hxPmSoL3FqnrtcPT9eMIOoPeLZVa66dwMQsIxwG9H1SD
	OQunc6NscmUUHkJU3nuCEs2z3icNHTupUnTD56mlUTByiWW6bUTMgx4pD9Lg6ZFAxL4i8DFtQAV
	0QscF+5/WjprecUfOE1h5EbwrzIRt3pCD9GiYO4EHbOueHXHDQ6epCeRN/AYldNJRfQ==
X-Received: by 2002:a50:95ce:: with SMTP id x14mr28465328eda.204.1548834886313;
        Tue, 29 Jan 2019 23:54:46 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4jFgiDfUoMIOTSKaKyqBvRL6oi9hhASlSYKOB8K5n+08PQkW0gn1QI+IRRpx7SEdI3FiXT
X-Received: by 2002:a50:95ce:: with SMTP id x14mr28465297eda.204.1548834885601;
        Tue, 29 Jan 2019 23:54:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548834885; cv=none;
        d=google.com; s=arc-20160816;
        b=soLnQOfK4llb8ApHuXfFgxsmQm/IvhK3THf/I6OTECbUQta7XUCMpw0Zr1a6Iuhzme
         BUV4bg2Etgj/KQzUtqznEqinqCF9hEFKYEiE/3U2IZtjimimwPq2u1R/00e9BW9dHwa7
         0+iclfRvWe9U3hjzFCdE1wy/AsoLTbUaE7lTUMwIpWmZbB/2X9nonmP+1ZI5jRuWLK/X
         oOIVOi/wx0a6yUyC5ugslDzJSxVKlKFp09X2Mz4rK6zcSd5HOi1+EGcvw0XTmR3/BXhF
         r4VxZvGGDyUz7PsnJTaUwO1y7kVi8kYqLZSn9WzdQmVuhs4nGxnpqrshM3cxCyE7jA9q
         9TYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4+yCoHTjz/Dv2oTXa5X77cG+WLvuWaZd9S3y3pGNVpA=;
        b=WXTff4HhRVDrWwrgDNxj1TljNVwxDQY/kGylXWLzC393as/KK6YejT3Jde1hPFF3sa
         LYDty7S2wR031AH853C3zOpXPXSmseTh7Oe8E7RA9Yf+ZMmH3/NbZauUlnnaokANbmPd
         0W/dd6hgVMWklDvDKvEnXhm4PskZ5aefbB68HoXZ3qDfu4Z1CjNj4GpzK+kBtzBQT4H7
         I881m/Lb8JIzGbxG0llj2mPGr1WvRmTaSoeXJgbGC7u38IFxLIFLWWYCJT8/ws/tsglq
         SzK9me9SrlyBfxADhb+WSKRZNMH7KEen0i29isLSzfJoUYjFcUVw6bvElFML8YTWzUH1
         GRqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id s26si600519edi.121.2019.01.29.23.54.45
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 23:54:45 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 3C38840CF; Wed, 30 Jan 2019 08:54:45 +0100 (CET)
Date: Wed, 30 Jan 2019 08:54:45 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com,
	linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 1/2] mm, memory_hotplug: is_mem_section_removable do not
 pass the end of a zone
Message-ID: <20190130075445.czrecevdvjgxed75@d104.suse.de>
References: <20190128144506.15603-1-mhocko@kernel.org>
 <20190128144506.15603-2-mhocko@kernel.org>
 <20190129090605.lenisalq2zxtck3u@d104.suse.de>
 <20190129091224.GG18811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129091224.GG18811@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 10:12:24AM +0100, Michal Hocko wrote:
> Yes, those pages should be unreachable because they are out of the zone.
> Reasons might be various. The memory range is not mem section aligned,
> or cut due to mem parameter etc.

I see, thanks.

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

