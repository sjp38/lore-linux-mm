Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28202C76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 08:46:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5E3E2173B
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 08:46:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5E3E2173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 262636B0003; Tue, 16 Jul 2019 04:46:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EC506B0005; Tue, 16 Jul 2019 04:46:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B4468E0001; Tue, 16 Jul 2019 04:46:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B323B6B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 04:46:40 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n3so15585350edr.8
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 01:46:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vaF5OF7TCjYW/p4yrqs60hUqDUu4Ea5ofCamdXCCX04=;
        b=AtoA/dX07qetwwuCrHQhfJD6DSFmD1+11cHsNndLKKCp5wNd4ulZQNecprZ8Ott6CH
         ImM/QfYiiynHT2GZyyncIL+oraOg9jcDQkb48TKe8Xzu+WHtQlWSPEqdj9Uya3PxA5XK
         0tO0fE0MrRnS9qiZesfs4xXAivd3GF+yL5zLkdnyupkVFhY6L5MCS3Zj7WssJWDRv0Yb
         rzzuT9CqG5r/OhcjQIIGFf+vh84cZYH6I07gD2zYHdOshgwQpYlynKcyZ/tGL8zl8vMo
         y+EP8EV6dCdOq2NE8lKT9+8NZbx/GzoB84hoKRLfhofNQIwWOmiiafI67slAuyZOTgzS
         8rjA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWxzJvWq616LPmVUokg7n0WjOcwbwKCPb/FHu1ci6zpym8B4/GQ
	mvL9CLCkGyM9Hb49JNeQUYKlrkaH2fPyipuhxLxp9yJx9x1bI6uvUW87FZotTdqRSSIVgXtc2PW
	zJZU8m/oFEGTN+13vab77wVVR/X05KR2zA4O4gdjFN4w6aKak1b17yjsbw26aGcJHDg==
X-Received: by 2002:a50:b362:: with SMTP id r31mr28543707edd.14.1563266800297;
        Tue, 16 Jul 2019 01:46:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtew/JAh1ORZJs6qV/cETx3gsUBdUUYK5c7omyHixxf0pVCPmoOYgg4/F5UxPdj6QTpZKx
X-Received: by 2002:a50:b362:: with SMTP id r31mr28543654edd.14.1563266799358;
        Tue, 16 Jul 2019 01:46:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563266799; cv=none;
        d=google.com; s=arc-20160816;
        b=JjymwcA8O82wuWE3XcboF0o0wSacNmwyAXV1QbTymGTZN0YKc57ThAmYNkVeVmCZRE
         3/dAORNLfUDlfLOv4r634MLMJVo4zuSjagrBzSSqUakghNtfnKLpjUZgZB3SexdUiEaN
         2yF3mEcwIrHsgSoS+XT5LCj8gS0C0fzJbjUiVWVuBzEOqpqGiYdrY8zmuaOXmN5UM3jQ
         drcRMUyv2CMKNv7PCrlrgHS0YMcB+eaIDvhbyKBtHZ8zuP+0hxwzR6c4KXlcW5Tb7mZq
         4t3pfcZ8yZJ0bkUPRoEOtgjWPXnrsJsBxEH4//oxK22Z4PZ4inHbFsdy1JJBTQR9y2SL
         +JgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vaF5OF7TCjYW/p4yrqs60hUqDUu4Ea5ofCamdXCCX04=;
        b=1CWu8P6kHCW7kMBFJVQY/WkJTbMIFm2Ca17UJM+T0Dw9Cpl8jVmr7t53BMwq57tjaX
         dH/TBSQxHkmNTkg/ErZisHtSMM/2qfayX8JJVkYm54hNmAdJf7e0oQep3n4sGHmdJsr+
         69lLnbUg91UN7MRa2Yivf/iq0aN7AO/KcFAG4EZ9LzDbfPbHF/6gb0IiCEIxytkdCj6O
         604rGv17EveAomfTw9rpnNnSoW8RDdqQ5GUF35IPO4qyTBdjosW7+ynyAlICncpEaX/Q
         Recij/D32w8bN+TkwBcBV1pCK+DkTUOrApiZEl4/QtQIaPr8BZnK26KAk/KuZSdi6S0s
         XmoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r54si12138718eda.172.2019.07.16.01.46.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 01:46:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 51E92AFCE;
	Tue, 16 Jul 2019 08:46:38 +0000 (UTC)
Date: Tue, 16 Jul 2019 10:46:34 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: Re: [PATCH v3 10/11] mm/memory_hotplug: Make
 unregister_memory_block_under_nodes() never fail
Message-ID: <20190716084626.GA12394@linux>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-11-david@redhat.com>
 <20190701085144.GJ6376@dhcp22.suse.cz>
 <20190701093640.GA17349@linux>
 <20190701102756.GO6376@dhcp22.suse.cz>
 <d450488d-7a82-f7a9-c8d3-b69a0bca48c6@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d450488d-7a82-f7a9-c8d3-b69a0bca48c6@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 15, 2019 at 01:10:33PM +0200, David Hildenbrand wrote:
> On 01.07.19 12:27, Michal Hocko wrote:
> > On Mon 01-07-19 11:36:44, Oscar Salvador wrote:
> >> On Mon, Jul 01, 2019 at 10:51:44AM +0200, Michal Hocko wrote:
> >>> Yeah, we do not allow to offline multi zone (node) ranges so the current
> >>> code seems to be over engineered.
> >>>
> >>> Anyway, I am wondering why do we have to strictly check for already
> >>> removed nodes links. Is the sysfs code going to complain we we try to
> >>> remove again?
> >>
> >> No, sysfs will silently "fail" if the symlink has already been removed.
> >> At least that is what I saw last time I played with it.
> >>
> >> I guess the question is what if sysfs handling changes in the future
> >> and starts dropping warnings when trying to remove a symlink is not there.
> >> Maybe that is unlikely to happen?
> > 
> > And maybe we handle it then rather than have a static allocation that
> > everybody with hotremove configured has to pay for.
> > 
> 
> So what's the suggestion? Dropping the nodemask_t completely and calling
> sysfs_remove_link() on already potentially removed links?
> 
> Of course, we can also just use mem_blk->nid and rest assured that it
> will never be called for memory blocks belonging to multiple nodes.

Hi David,

While it is easy to construct a scenario where a memblock belongs to multiple
nodes, I have to confess that I yet have not seen that in a real-world scenario.

Given said that, I think that the less risky way is to just drop the nodemask_t
and do not care about calling sysfs_remove_link() for already removed links.
As I said, sysfs_remove_link() will silently fail when it fails to find the
symlink, so I do not think it is a big deal.


-- 
Oscar Salvador
SUSE L3

