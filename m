Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2431AC76191
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 08:16:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8F0E20C01
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 08:16:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8F0E20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0D156B0007; Mon, 15 Jul 2019 04:15:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BFBA6B000A; Mon, 15 Jul 2019 04:15:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 886606B000C; Mon, 15 Jul 2019 04:15:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3B7BF6B0007
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 04:15:59 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d27so13086748eda.9
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 01:15:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=LcQu5sXrADpGlBt7XsSkAfGqKjB7SlMJkZ5oG2OAAWU=;
        b=X2YpFvrYJP+oamH4jOZIeMsWoZSZLKMtmQggmD3x2r9SV8b6kCSvtARnyCZTQ5aSdC
         jmX+zpzORQt7t+JQbmL1R4Owb3iw4t06v+F1FuksUheOiJytijlCpiRM93Gg94BmZjQE
         ct47lq+bZEWWYsInw74wYr22tgiz3k1jeCNnQKKO8AjAkqUoh8lD310srNLgM1dZszmc
         osPdH+uLwcqIqn7irudBccOu0oS07Sq4JYlFkSrhr5OYd1tyMZ9CQVM2xABGsZvxlNzB
         +BgBrCl6Ms/d9Sua46OQ1n4qYqErw1Hc1cSVhTpQSmMWjMC6UUZ0fUPzBwWRHIAZ7J6a
         dJxA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXmmde7QIjJ+4WpEO21CWaSXXPRnMqOgcuchcfT/FeQkoqgqvdK
	su1ZzNIwUxjxyzSpfDbMPprvYub0bP2aNmIUHOJMwZy/tH2jTS3zvnTLGyE1KqS2WOD1j05q816
	/d1VqV0qePdazYnsdV/ou/1JupXZJvtGL8Z0wl2LLPZ2W6oMFLomFBKH1FDjOSC1YKA==
X-Received: by 2002:a50:8eea:: with SMTP id x39mr21790126edx.49.1563178558817;
        Mon, 15 Jul 2019 01:15:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnoH1sZBXIwD5DDaUqYxJuxN6pShJ1IXJZiJfem6Qq05KLhRGmoXooh+N8t/kH1iglk6AK
X-Received: by 2002:a50:8eea:: with SMTP id x39mr21790066edx.49.1563178558030;
        Mon, 15 Jul 2019 01:15:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563178558; cv=none;
        d=google.com; s=arc-20160816;
        b=Vkr0cLomDsZRo7ldUKoI9p80nTRa9l87It3a7NKzApqDjFWBt7OxH7clj6+48QIuqP
         kuzQS2+2sv3mY+L0yh4HDoLfHE0a5BuQDnLrOusm7ZZ7CFxm2ejI4h9bFsDkJeJxFRvz
         +NtqhJPaVoaeXjQ7OGJCM5zZc5/nQ5cy4hQgdyNx+6bf/PWRDkicq0iQx6XhW/NmNKsX
         wANjoCTc64Ogz20TWkvlBp0k2v0UckppBR0JURo8sOkej0qIgw9eZqUNuXR2UIiIQMF3
         4aZOqVsxAC3RsXSSFMhVKwrsWT0EKBsMm24hNKIO+g8QOd+9aInujiDKGcuK0EE9R68L
         zGbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=LcQu5sXrADpGlBt7XsSkAfGqKjB7SlMJkZ5oG2OAAWU=;
        b=JdC6MvkaJeIy/gJce7a7UJHer8JPTbxlJKr2MKGBf4enTTy1/KlU0dz4BodPVWT88U
         Psy5jyHwVTfB7sSYh15cphcW7WlNA6CPiqQi7LnALuk/6qCeNnwOIwUXK04Xk78zsw4b
         agtBWSg3w2YaDi9e7X+7pFpdzeNGa0bi4cdsYC2gt1ZcCZXyCd9tne/6I4A0C1nH7yGR
         Qzl9yM1mqiWMSu8+CNeFreLpl+GwBXviGmUPKIt7tZf4YBFC8U3IHW0Suf38Cf/PbcAY
         OMmCGKGhiKLGh7BfNhXukG28KXZgcGWnnT8nhQ6Bj+SmSJt9QdfVYeGmaDu0O2fgqicW
         JMJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d16si10182984ede.18.2019.07.15.01.15.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 01:15:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 72429AFE0;
	Mon, 15 Jul 2019 08:15:57 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com,
	david@redhat.com,
	pasha.tatashin@soleen.com,
	mhocko@suse.com,
	aneesh.kumar@linux.ibm.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 0/2] Fixes for sub-section hotplug
Date: Mon, 15 Jul 2019 10:15:47 +0200
Message-Id: <20190715081549.32577-1-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

these two patches address a couple of issues I found while working on my
vmemmap-patchset.
The issues are:

	1) section_deactivate mistakenly zeroes ms->section_mem_map and then
	   tries to check whether the section is an early section, but since
	   section_mem_map might have been zeroed, we will return false
	   when it is really an early section.
	   In order to fix this, let us check whether the section is early
	   at function entry, so we do not neet check it again later.

	2) shrink_{node,zone}_span work on sub-section granularity now.
	   The problem is that deactivation of the section occurs later on
	   in sparse_remove_section, so the pfn_valid()->pfn_section_valid()
	   check will always return true.
	   The user visible effect of this is that we are always left with,
	   at least, PAGES_PER_SECTION spanned, even if we got to remove all
	   memory linked to a zone.
	   In order to fix this, decouple section_deactivate() from
	   sparse_remove_section, and let __remove_section first call
	   section_deactivate(), so then __remove_zone()->shrink_{zone,node}
	   will find the right information.

Actually, both patches could be merged in one, but I went this way to make it
more smooth.

Once this have been merged (unless there is a major controvery), I plan to send
out a patch refactoring shrink_{node,zone}_span, since right now it is a bit
messy.

Oscar Salvador (2):
  mm,sparse: Fix deactivate_section for early sections
  mm,memory_hotplug: Fix shrink_{zone,node}_span

 include/linux/memory_hotplug.h |  7 ++--
 mm/memory_hotplug.c            |  6 +++-
 mm/sparse.c                    | 76 +++++++++++++++++++++++++++++-------------
 3 files changed, 62 insertions(+), 27 deletions(-)

-- 
2.12.3

