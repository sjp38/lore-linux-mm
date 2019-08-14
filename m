Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A20DC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 14:28:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C751F2083B
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 14:28:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C751F2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 623206B0005; Wed, 14 Aug 2019 10:28:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5ACFD6B000A; Wed, 14 Aug 2019 10:28:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49B5D6B000C; Wed, 14 Aug 2019 10:28:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0232.hostedemail.com [216.40.44.232])
	by kanga.kvack.org (Postfix) with ESMTP id 256BD6B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 10:28:37 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C35A32DFF
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:28:36 +0000 (UTC)
X-FDA: 75821264232.18.look11_855f6f73b0358
X-HE-Tag: look11_855f6f73b0358
X-Filterd-Recvd-Size: 2412
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:28:36 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1A8C1AEE9;
	Wed, 14 Aug 2019 14:28:35 +0000 (UTC)
Date: Wed, 14 Aug 2019 16:28:34 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Arun KS <arunks@codeaurora.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v1 2/4] mm/memory_hotplug: Handle unaligned start and
 nr_pages in online_pages_blocks()
Message-ID: <20190814142834.GD17933@dhcp22.suse.cz>
References: <20190809125701.3316-1-david@redhat.com>
 <20190809125701.3316-3-david@redhat.com>
 <20190814140805.GA17933@dhcp22.suse.cz>
 <ddb10470-8d6e-c8bd-4877-197621219612@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ddb10470-8d6e-c8bd-4877-197621219612@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 14-08-19 16:17:03, David Hildenbrand wrote:
> On 14.08.19 16:08, Michal Hocko wrote:
> > On Fri 09-08-19 14:56:59, David Hildenbrand wrote:
> >> Take care of nr_pages not being a power of two and start not being
> >> properly aligned. Essentially, what walk_system_ram_range() could provide
> >> to us. get_order() will round-up in case it's not a power of two.
> >>
> >> This should only apply to memory blocks that contain strange memory
> >> resources (especially with holes), not to ordinary DIMMs.
> > 
> > I would really like to see an example of such setup before making the
> > code hard to read. Because I am not really sure something like that
> > exists at all.
> 
> I don't have a real-live example at hand (founds this while exploring
> the code), however, the linked commit changed it without stating why it
> would be safe to do so.

Then just drop the change. It is making the code a real head scratcher,
and more so after the next patch. I am pretty sure that things would
easily and quickly blow up if we had ranges like that.
-- 
Michal Hocko
SUSE Labs

