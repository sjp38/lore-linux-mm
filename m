Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8A7CC10F01
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 08:33:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D0C420880
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 08:33:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D0C420880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE86E8E0004; Wed, 20 Feb 2019 03:33:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E96E48E0002; Wed, 20 Feb 2019 03:33:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D86DC8E0004; Wed, 20 Feb 2019 03:33:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9537D8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 03:33:49 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x47so9505372eda.8
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 00:33:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YXmb+bLy81GuGo+3FFlRZFO6CxGptGjONLz1PHTLW9c=;
        b=XlDFHAT0VwuGYj5aQaxKrPHzmlS15LNPjmWZPPS6+ar0HYLtaeMrpCVtFSo/MFF9GJ
         45B9JNkawypwH5cLAyv6GPQc4DMQ8toQr6h9BNbkc1d7S0i+CKMMgQ9gvBamvojdI3mF
         tRqgYMpA8ngM4qE37j9F4WsskpHQrr7cnNbrbvhlhhNzY4AL0DROcOsflXQwhA1jzzsW
         mQ+zjP+Ltr3BGKYBm9GaTKrI/t51sW+Xu71zaGJatHGaBwf7R7SbD8PxqPO4t+sPHIWd
         t7p50LecsDj7gxvUwhpq4t5p85NtXv9Xcr1A4B3x6CuHY4+cf3AcS2V3e0AYjDv3/ehE
         pGcg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAuaO7aF8vtJ9xBcBo/71d5yeLHfMIkqe3lhbHXcX2NAcch3aIG1a
	ys329EBVP4bfgHOkX655IL31oGUJSlJWsuOCWIZjmcorjkhQEyWQYQh7MPBVhQoZ9iMnnqHmAT6
	9HO1WlZUHMOdURuuUsu877roat0/ybUeWTSG+p4t93qNcgfzyHoAhnM1IponfFiO5og==
X-Received: by 2002:aa7:c3d3:: with SMTP id l19mr15322303edr.117.1550651629157;
        Wed, 20 Feb 2019 00:33:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYiOd36B4fElLRBJJQlUWtvcUYrujj4sTP1cvfGOcG3khjIKbdeg0uczqP01fRyr/7ano3/
X-Received: by 2002:aa7:c3d3:: with SMTP id l19mr15322262edr.117.1550651628275;
        Wed, 20 Feb 2019 00:33:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550651628; cv=none;
        d=google.com; s=arc-20160816;
        b=y7+yFrmLApA2wvfZhB8trmOwQhNW47x2LxrVcrd2PmoykNV6iwn4u3yOYOKGL6LGWI
         rCDpgLo//im3Bmt+bu90PAhLAUlK0A3yQrSPXBKenzvNuf6qiLceaC6cq6ejHUbFME90
         Y8HkJBTS5PjZJUhDMz2sdAecSkp6y7UkNTdASSCIfokoE7SQcmfHFlufGAJGQUyN6SDm
         LbBX5YMp/+KxwKl+lHzkN78bAV+JuCTwPga4JXUDRFnG9jHfg5jRofw4uBuvx4NXC7h/
         UciLoUEL9hm2YcTwUWGzcIHLbfF5ps01fFhaCekDneVbeQBDQJ65CZvRo+Z+uKmCM/DS
         atLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YXmb+bLy81GuGo+3FFlRZFO6CxGptGjONLz1PHTLW9c=;
        b=d2e08PJ9YePvoxH19HPSLTxI3FxHeWKTGdw1otNg3n2To6u5ZRBDjosd8QNnUZ0RxN
         zwJV1czlfCm+Dm0mC4xxkFDS/ymiAPI3I53+C8v08YzG+ppmiakOJPxzyd5/FrbW0MxG
         OcnQTzz7XwxR1qg2yB9No4h5l4khKSr2vXroAhL6gOIcqD0NQqcAkwcAhrwcoG3+ItTL
         nE/LelJjDG1GWhTIWFD3ckrv4JIVG5NCxM63bWJ205uLdWx0hhq6Ov2kLSDTKmZrq6Iu
         WNDYyj1yqyFWpTlFTewECb+DkjOShFLrCDemoUDsowyKHZjR0IzcPNSooJIVzHdNaXrH
         KxgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id m10si5478128edp.79.2019.02.20.00.33.48
        for <linux-mm@kvack.org>;
        Wed, 20 Feb 2019 00:33:48 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 79CB2432B; Wed, 20 Feb 2019 09:33:47 +0100 (CET)
Date: Wed, 20 Feb 2019 09:33:47 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Oscar Salvador <OSalvador@suse.com>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>, lkp@01.org,
	Michal Hocko <mhocko@suse.com>, rong.a.chen@intel.com
Subject: Re: [RFC PATCH] mm, memory_hotplug: fix off-by-one in
 is_pageblock_removable
Message-ID: <20190220083343.g5hdxxmekqsjwo63@d104.suse.de>
References: <20190218052823.GH29177@shao2-debian>
 <20190218181544.14616-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218181544.14616-1-mhocko@kernel.org>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 07:15:44PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>

> Fixes: efad4e475c31 ("mm, memory_hotplug: is_mem_section_removable do not pass the end of a zone")
> Reported-by: <rong.a.chen@intel.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Looks good to me.
I glanced quickly over the memhotplug code and I did not see any other place
that could trigger the same problem.

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

