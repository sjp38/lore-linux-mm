Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89D10C3A5A6
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 07:22:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 605E6206BB
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 07:22:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 605E6206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 002386B0005; Tue, 27 Aug 2019 03:22:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1B626B0006; Tue, 27 Aug 2019 03:22:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E32A56B000A; Tue, 27 Aug 2019 03:22:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0130.hostedemail.com [216.40.44.130])
	by kanga.kvack.org (Postfix) with ESMTP id BFF116B0005
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 03:22:45 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 56AE482437D7
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 07:22:45 +0000 (UTC)
X-FDA: 75867365490.04.linen09_52379aaf4b245
X-HE-Tag: linen09_52379aaf4b245
X-Filterd-Recvd-Size: 1873
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 07:22:44 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A0F24B087;
	Tue, 27 Aug 2019 07:22:43 +0000 (UTC)
Date: Tue, 27 Aug 2019 09:22:42 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alastair D'Silva <alastair@d-silva.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richardw.yang@linux.intel.com>,
	David Hildenbrand <david@redhat.com>, Qian Cai <cai@lca.pw>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] mm: don't hide potentially null memmap pointer in
 sparse_remove_section
Message-ID: <20190827072242.GT7538@dhcp22.suse.cz>
References: <20190827053656.32191-1-alastair@au1.ibm.com>
 <20190827053656.32191-3-alastair@au1.ibm.com>
 <20190827062445.GO7538@dhcp22.suse.cz>
 <befab2a0a9f160f8af8c1a412068060636a7a64c.camel@d-silva.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <befab2a0a9f160f8af8c1a412068060636a7a64c.camel@d-silva.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 27-08-19 17:00:16, Alastair D'Silva wrote:
[...]
> The NULL check was added in commit:
> 95a4774d055c ("memory-hotplug: update mce_bad_pages when removing the
> memory")
> where memmap was originally inited to NULL, and only conditionally
> given a value.
> 
> With this in mind, since that situation is no longer true, I think we
> could instead drop the NULL check.

This would be much more preferable to the original patch.

-- 
Michal Hocko
SUSE Labs

