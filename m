Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 873E6C3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 06:47:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D31F22CE9
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 06:47:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D31F22CE9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0918C6B0003; Fri, 30 Aug 2019 02:47:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 043016B0006; Fri, 30 Aug 2019 02:47:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9B0B6B0008; Fri, 30 Aug 2019 02:47:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0067.hostedemail.com [216.40.44.67])
	by kanga.kvack.org (Postfix) with ESMTP id C526B6B0003
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 02:47:27 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 65769824CA3F
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 06:47:27 +0000 (UTC)
X-FDA: 75878162934.22.pigs25_5e2a5ba582323
X-HE-Tag: pigs25_5e2a5ba582323
X-Filterd-Recvd-Size: 1818
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 06:47:26 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9A6BAB04C;
	Fri, 30 Aug 2019 06:47:25 +0000 (UTC)
Date: Fri, 30 Aug 2019 08:47:24 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: Re: [PATCH v2 3/6] mm/memory_hotplug: Process all zones when
 removing memory
Message-ID: <20190830064724.GT28313@dhcp22.suse.cz>
References: <20190826101012.10575-1-david@redhat.com>
 <20190826101012.10575-4-david@redhat.com>
 <20190829153936.GJ28313@dhcp22.suse.cz>
 <c01ceaab-4032-49cd-3888-45838cb46e11@redhat.com>
 <20190829162704.GL28313@dhcp22.suse.cz>
 <b5a9f070-b43a-c21d-081b-9926b2007f5c@redhat.com>
 <20190830060100.GP28313@dhcp22.suse.cz>
 <18aed12d-0611-7d35-2994-075d09269513@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <18aed12d-0611-7d35-2994-075d09269513@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 30-08-19 08:20:32, David Hildenbrand wrote:
[...]
> Regarding shrink_zone_span(), I suspect it was introduced by
>
> d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")

zone shrinking code is much older - 815121d2b5cd5. But I do not think
this is really needed for Fixes tag.

-- 
Michal Hocko
SUSE Labs

