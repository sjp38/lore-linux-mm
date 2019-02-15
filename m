Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D71BAC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 09:28:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2C662192D
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 09:27:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2C662192D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F26A8E0002; Fri, 15 Feb 2019 04:27:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A2A48E0001; Fri, 15 Feb 2019 04:27:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 292668E0002; Fri, 15 Feb 2019 04:27:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C3DE28E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 04:27:49 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b3so3709032edi.0
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 01:27:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YijIa7NE+xsB570xjfMDqrLN8BlzFmSKjX5wGZcY10w=;
        b=rdzXSDA+uF+APTvu7GE1K/Fkuge+f2gHscTnKPaYDUQfrX3937gKdazccuAZa5WhJ8
         vXHg8ujNk3KILpAAk4bJDNF6klsAFKncFwXEGxWPCsEP9SABVHatxRobPthWePjiNZza
         yN8MXPfkjb0iWDwFPVgxWtuuD8oTppwGQ3YWfOQUXvtfTiOvWps24AXfu9ogrhDwqAFu
         YR7vUQb69lMMZljdJFOFIhZcjFT4GtCVdqOd4RtB58uQfnqUqpwfg2gRvxiHSeSWcmog
         XSfBCa9/vNQ68PbrBp+U4SKpMnFsB5j54kVhJ/9bxoa4Mnyk3mcdUKUT/Rw3CZ7QNi0T
         ZH8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: AHQUAuZ+V/MTa/+Pbdfz0YwjbiL4htXEHlOly09iL91wz/t8goxjnini
	UDY+qcVJ8mwmUr441uMR/CYD5cC0FsKebIf4UX11nwp3wEOm0IZ1ay11OFDfE36CMaUmF0Ad+QI
	Jx08MZvCMRdsF233tDBNClm3P1hGyurvQtv4kk4M0nyANzmyEmGmb9pL+twBcmVISXQ==
X-Received: by 2002:a50:9b50:: with SMTP id a16mr6472837edj.135.1550222869267;
        Fri, 15 Feb 2019 01:27:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibiu1I+aoQItFsUWJA2EZLhGD+wcs3n9zdk8DUAtVJqBC/rIUVZLCp5ntQ1EVvMr/3idwPs
X-Received: by 2002:a50:9b50:: with SMTP id a16mr6472798edj.135.1550222868266;
        Fri, 15 Feb 2019 01:27:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550222868; cv=none;
        d=google.com; s=arc-20160816;
        b=cz1kZdCV7qRuQFIY9STHHwfvyw7OM3+fvkA9EWRHKMQ7TvEDDiwD5SXnWHXv9y0V4D
         C5i+w0ElXcE3ZIHirpy0zaZFgm4ri6Qw5xW11SR2EO1aQUceG+SDtjNPSewvZC0GdvXY
         O2EMGtyiNY0M5vwT3KEv7uD3TooBVTk3FXz1XAm6MinfsC0oTTSbhShMHPPdEWSSOYz0
         j6PPR/WhRPf/HRp/R5o8xnaoAzyQyRVRh5aZ/HFLXAi/S7S9GSdLkfiS2BXQhms1CSfd
         4TwEccwUAds8ms0W+V6p0oBTO8d0tBT9y+1vv140VRudX5r8IrknQun/dbO1h2Loz0S9
         xt6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YijIa7NE+xsB570xjfMDqrLN8BlzFmSKjX5wGZcY10w=;
        b=KZ4sotucb3HGhDRx8XD+QtOSZFS0e6JG+VssH0TU8WKB25HtybSVDOvJEZaF9bVNQd
         9o/h9Dol9kjjVwMZmFwloiSNds6lgp8C0HzvwgDsrrFn9jyriDLh/OebkBMDI1FuqVFM
         31v5Ux3nToOq0dE9tc6n9f61cm1TtY/MxEUTfgP1Rh8I9qb2VSleGkDVQSZzJRFX36Ir
         dSuMrNujEmJAg8G0qmMIvUzl5cYVJzAxiaZvY7HGOvAcJuml87l3O+vta2Wiye/5Bbjv
         KcugqNYVSlprzdF0RKf5PyAei8OZrHVG2/cDYKXBR5lE+BPvgnVsDA65arQBAMIRf9KJ
         NmVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i18si218985edg.44.2019.02.15.01.27.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 01:27:48 -0800 (PST)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8EAC8ACFA;
	Fri, 15 Feb 2019 09:27:47 +0000 (UTC)
Date: Fri, 15 Feb 2019 10:27:46 +0100
From: Michal Hocko <mhocko@suse.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org,
	akpm@linux-foundation.org, kirill@shutemov.name,
	kirill.shutemov@linux.intel.com, vbabka@suse.cz,
	will.deacon@arm.com, dave.hansen@intel.com
Subject: Re: [RFC 0/4] mm: Introduce lazy exec permission setting on a page
Message-ID: <20190215092746.GU4525@dhcp22.suse.cz>
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <20190213112135.GA9296@c02tf0j2hf1t.cambridge.arm.com>
 <20190213153819.GS4525@dhcp22.suse.cz>
 <0b6457d0-eed1-54e4-789b-d62881bea013@arm.com>
 <20190214083844.GZ4525@dhcp22.suse.cz>
 <20190214101936.GD9296@c02tf0j2hf1t.cambridge.arm.com>
 <20190214122816.GD4525@dhcp22.suse.cz>
 <d2646840-f2f0-3618-889a-54cfef6cb455@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d2646840-f2f0-3618-889a-54cfef6cb455@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 15-02-19 14:15:58, Anshuman Khandual wrote:
> On 02/14/2019 05:58 PM, Michal Hocko wrote:
> > It is hard to assume any further access for migrated pages here. Then we
> > have an explicit move_pages syscall and I would expect this to be
> > somewhere in the middle. One would expect that the caller knows why the
> > memory is migrated and it will be used but again, we cannot really
> > assume anything.
> 
> What if the caller knows that it wont be used ever again or in near future
> and hence trying to migrate to a different node which has less expensive and
> slower memory. Kernel should not assume either way on it but can decide to
> be conservative in spending time in preparing for future exec faults.
> 
> But being conservative during migration risks additional exec faults which
> would have been avoided if exec permission should have stayed on followed
> by an I-cache invalidation. Deferral of the I-cache invalidation requires
> removing the exec permission completely (unless there is some magic which
> I am not aware about) i.e unmapping page for exec permission and risking
> an exec fault next time around.
> 
> This problem gets particularly amplified for mixed permission (WRITE | EXEC)
> user space mappings where things like NUMA migration, compaction etc probably
> gets triggered by write faults and additional exec permission there never
> really gets used.

Please quantify that and provide us with some _data_

> > This would suggest that this depends on the migration reason quite a
> > lot. So I would really like to see a more comprehensive analysis of
> > different workloads to see whether this is really worth it.
> 
> Sure. Could you please give some more details on how to go about this and
> what specifically you are looking for ?

You are proposing an optimization without actually providing any
justification. The overhead is not removed it is just shifted from one
path to another. So you should have some pretty convincing arguments
to back that shift as a general win. You can go an test on wider range
of workloads and isolate the worst/best case behavior. I fully realize
that this is tedious. Another option would be to define conditions when
the optimization is going to be a huge win and have some convincing
arguments that many/most workloads are falling into that category while
pathological ones are not suffering much.

This is no different from any other optimizations/heuristics we have.

Btw. have you considered to have this optimization conditional based on
the migration reason or vma flags?
-- 
Michal Hocko
SUSE Labs

