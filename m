Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93A5BC3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 06:01:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A7BC2186A
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 06:01:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A7BC2186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 067A26B000D; Fri, 30 Aug 2019 02:01:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F32916B000E; Fri, 30 Aug 2019 02:01:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E21236B0010; Fri, 30 Aug 2019 02:01:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0243.hostedemail.com [216.40.44.243])
	by kanga.kvack.org (Postfix) with ESMTP id BADB46B000D
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 02:01:03 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 5F1A71F21B
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 06:01:03 +0000 (UTC)
X-FDA: 75878046006.22.fork51_7d96f0953c42c
X-HE-Tag: fork51_7d96f0953c42c
X-Filterd-Recvd-Size: 1992
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 06:01:02 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A4AB4B682;
	Fri, 30 Aug 2019 06:01:01 +0000 (UTC)
Date: Fri, 30 Aug 2019 08:01:00 +0200
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
Message-ID: <20190830060100.GP28313@dhcp22.suse.cz>
References: <20190826101012.10575-1-david@redhat.com>
 <20190826101012.10575-4-david@redhat.com>
 <20190829153936.GJ28313@dhcp22.suse.cz>
 <c01ceaab-4032-49cd-3888-45838cb46e11@redhat.com>
 <20190829162704.GL28313@dhcp22.suse.cz>
 <b5a9f070-b43a-c21d-081b-9926b2007f5c@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b5a9f070-b43a-c21d-081b-9926b2007f5c@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 29-08-19 18:59:31, David Hildenbrand wrote:
> On 29.08.19 18:27, Michal Hocko wrote:
[...]
> > No rush, really... It seems this is quite unlikely event as most hotplug
> > usecases simply online memory before removing it later on.
> > 
> 
> I can trigger it reliably right now while working/testing virtio-mem, so
> I finally want to clean up this mess :) (has been on my list for a long
> time). I'll try to hunt for the right commit id's that broke it.

f1dd2cd13c4b ("mm, memory_hotplug: do not associate hotadded memory to
zones until online")

-- 
Michal Hocko
SUSE Labs

