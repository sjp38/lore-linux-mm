Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 225ABC76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 09:07:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E154920818
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 09:07:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E154920818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E1D96B0006; Wed, 17 Jul 2019 05:07:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C16A6B0008; Wed, 17 Jul 2019 05:07:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67F788E0001; Wed, 17 Jul 2019 05:07:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9746B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 05:07:31 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b3so17576268edd.22
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 02:07:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=dKbjvEEsZeKXu8dFwTk9UFax82MLa5C29eCKzaf2UJw=;
        b=I3nXjwgksgabuhyx2rfRVwNPbiwcMWUTjr0nA+UuhE/YNTgUkfQG1axljlZVPLMBw9
         oIE/efUe/s2FpNJawZkq90PSNAbKNyw0zzy0amW+vFWN8UgNaEj07FrXCR0xnty1l60A
         Z4wp5g0eGvbjX2272lAjjTzpUY3yIwCxTW2d0Ck7SnTFXm0gQ6Eh3OKI7rsOsPEB4E1e
         WvnKoTtZ3gKjag4oScviMT0V1rK1uH0nMpkLheU/blh0zlzLGIMEOdbUkLvuap16kQ6J
         zL1+swsSwCnMGJlKvEYFZACxf4+iLKT4QW0HlEVHEdNS6IVrLcu+9Pk/sAxJgz6WJjwU
         7Exw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAV/dEIL9iHjIhmeq1alArx5jCHm444Hd8SCZDRKwm7RHiwLao3h
	WImZm8RO0xef25KMNbDfLzvFeRBBY8NrV5EBmdzSMkLXTAmE45M4onV54p9x+Pa7JSalF2F13Z0
	pkIf1fciRQO5mv/jwHBrhSDn1Z9JYz8DoUWgASFC9HY4TSsQewnHk32dvsdNIhYjzRg==
X-Received: by 2002:a50:b561:: with SMTP id z30mr33765857edd.87.1563354450762;
        Wed, 17 Jul 2019 02:07:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycLE9/Yq851klX7aHo4W2VYmsb43/nEeilWmqT7y9WxiW9JQxDLxNh8wDMs9XA7L49vc8r
X-Received: by 2002:a50:b561:: with SMTP id z30mr33765794edd.87.1563354449980;
        Wed, 17 Jul 2019 02:07:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563354449; cv=none;
        d=google.com; s=arc-20160816;
        b=Z2WMSC5aYV9mbeBDt7I6IaPJq3IDFX6bZy+zhKL9RCJBZloW4ua6wZi93cPLWUtycr
         W0kwuyiZ1pm483NcHpbkD3UOuyzWKHxdbfuElHy2dK0IaGiMqkiy0dKeS8kgqbpfYOiB
         GTXis7WlJW3m4nb4H8tYUb82BGRoX29ZoJuuYFk3NXMABQ1DZ3gPwkX9jTj0WALm1+w6
         ZmEpnMccYmv5O/J2mU6Y/QtmZLM7edS5c6Vq5I9+FdsUioewYpOYX5v4NV0yGiqyHg47
         rPuQwA+CI9knvizj1Zenhx8SZRC6aeKqKZCUj8/by2pTlrwQoWXBnnz7HkQYLgjnX3/H
         esoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=dKbjvEEsZeKXu8dFwTk9UFax82MLa5C29eCKzaf2UJw=;
        b=0499FEkCCmUurE65FtnLtf4IjNN2KI1tnvDCWbdUqrzu7jp5/JkHbLOaDM2Hw1AAXF
         IxF4rX/gzveFCDoafuGFouYTwl4lZmqK2BCHO550Ly8+q5EYkaoqrQDGEx6fR0r757AV
         RZrXhvJ2M936exH91RPW+FLegBsKujVZwbajsPnblv73FySarrRv0bvPRcrwdxGg21zi
         BakX963xJLBDj+52QdlgO6yTjInv/HjGpl5rR8L/Atq/Cp8iEGy2bOQ+O61IDKPZFisu
         tSbKZWzno4bC5OtN3IA+Zws73Yl5x1TFdFb3faCUC9gNnX1eEYy8D4G0vLHKy7pIFiVX
         vEhA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e57si14193369edd.263.2019.07.17.02.07.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 02:07:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 394AAAF47;
	Wed, 17 Jul 2019 09:07:29 +0000 (UTC)
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
Subject: [PATCH v2 0/2] Fixes for sub-section hotplug
Date: Wed, 17 Jul 2019 11:07:23 +0200
Message-Id: <20190717090725.23618-1-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

v2 -> v1: Go the easy way and just adapt the check (Dan/Aneesh)

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
           The problem is that since deactivation of the section occurs later
           on in sparse_remove_section, so the pfn_valid()->pfn_section_valid()
           check will always return true for every sub-section chunk.
           In order to avoid that, let us adapt the check and skip the whole
           range to be removed.
           The user visible effect of this is that we are always left with,
           at least, PAGES_PER_SECTION spanned, even if we got to remove all
           memory linked to a zone/node

Oscar Salvador (2):
  mm,sparse: Fix deactivate_section for early sections
  mm,memory_hotplug: Fix shrink_{zone,node}_span

 mm/memory_hotplug.c | 8 ++++----
 mm/sparse.c         | 5 +++--
 2 files changed, 7 insertions(+), 6 deletions(-)

-- 
2.12.3

