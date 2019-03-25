Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41B52C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 07:40:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0651120879
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 07:40:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0651120879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 966686B0003; Mon, 25 Mar 2019 03:40:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EDDC6B0005; Mon, 25 Mar 2019 03:40:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78F6A6B0007; Mon, 25 Mar 2019 03:40:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 287806B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 03:40:35 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c40so2172257eda.10
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 00:40:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=f7thCgmH7nVeQfePsQrlJ+8nVFZJhioPrlVouQttNcA=;
        b=YVx2F86NoR4WRYIjWLRcn92O6LIdE2PWfAplQT4hu/kMTqdFTodh6+C7VkriRgGsS6
         R5T3/jXvBFuI+gGVCL692JRmiWRZ+VBHKk1xxtdp0sVhAzB/RFxRktUbJlG6lWGs14rt
         a/CHdDtmfI/zfNmXZ8Ss2aDCv/7TO0lPivZjnUfeLyLepG3k8r2fCg7GCTnQv9pQzn3v
         TLHYRhd6NcvBug8MYRm6lhqLYqlegx69jUG5SozQlN91jLlATSpuTD3xCxfbFtQR4tuG
         JsvbQpqvdNeTvf51ICtIaEDsqF5DtLEx+Pe4Cjk36D6G5VuEPyb7zdu6eGc6XWqeLz7c
         p5rg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWIf5EmRkGs0WjaXx6R6t3ZsRE96BtPVLyjgprspPzd80gCZCzN
	vFW0kYzEMzxoitDJBM6z9E+D5+Etvp6PNRp3L9hgr5tuL4uOONAdL5BKuZDusQdh+J3Eo+hCi9d
	Ja1anjarjsaye+c0nQAqRMuPg9wDrPjeXlUWSOo9o9DM72Pe13xj8VeNyWGC/e58=
X-Received: by 2002:a50:91eb:: with SMTP id h40mr14937484eda.285.1553499634674;
        Mon, 25 Mar 2019 00:40:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz440CiKfYpAlh1XFrlscPz9z9J7Hyv+ifMXtI4BvRkdzOpnupVvtW4jS8IQOjDglTCToJ5
X-Received: by 2002:a50:91eb:: with SMTP id h40mr14937456eda.285.1553499633795;
        Mon, 25 Mar 2019 00:40:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553499633; cv=none;
        d=google.com; s=arc-20160816;
        b=RVi7DdVohyUxdRUQaK78Evc/WWBulbmPk1EeAVLZFXfYH0duJCO1LcXyF0hD7d6gp5
         s2i8kv0GpJXXVg/Ea3UIUbd0GjPFPwB+DEGUlD4ZINNJJEpSSZNjUFR0VLDwM07o4Cff
         Ej/sLuTny4Z/0iY47ZKDRYy4402I+nTy6fttGAyBL9hmL+qqVjrmvfSylLwD9/dVJr78
         yLeAEJhVdtltkaSEcQmasYOOnzgX9w4qaxDuCxuKl90a6tyVXNem0TyMpQbetENE+T//
         Pz7dNYry+FYMHVWem36QT/DWA5pPodNC5Ts0iS6YCVkO3jdc+wzY3acVzYBSrEky+xUY
         vzFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=f7thCgmH7nVeQfePsQrlJ+8nVFZJhioPrlVouQttNcA=;
        b=TCGHcj/uaOwhb3jbmPC+bjhq9ZYwKCYWHSLnGYuHzhEE7L+EuaAeaQQnY9YLzK0zdJ
         rKCLNSJwKaQd2gaFbIOEA3LOjX+lnEOO9KNYPu6dtuwnIXsujdYyZEeNM1lqZoYFytbD
         WKSS+teREdKSRig8mylJ3syYSZ6T8lLFUh8f8MMyuow8ouBtRJPATIzAkyNtnp7uvNaG
         0/NuQOxiMWelDzZ7gWrLMEEAq2kKJ/XVPXCngVNhOP4HYGlMLYwBu7hHoZ7rnR5ooPXu
         0OSaIwaHiC7HpVyXGMhdCN67midLHxYIYH7HDjXnxXjacDg038lXyIAQy/Tm1mUCdyvu
         xbEg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id w8si841018edt.335.2019.03.25.00.40.33
        for <linux-mm@kvack.org>;
        Mon, 25 Mar 2019 00:40:33 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id CA41746C3; Mon, 25 Mar 2019 08:40:32 +0100 (CET)
Date: Mon, 25 Mar 2019 08:40:32 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
	pavel.tatashin@microsoft.com, jglisse@redhat.com,
	Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com,
	linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>
Subject: Re: [PATCH v2 4/5] mm, memory-hotplug: Rework
 unregister_mem_sect_under_nodes
Message-ID: <20190325074027.vhybenecc6hk7kxs@d104.suse.de>
References: <20181127162005.15833-1-osalvador@suse.de>
 <20181127162005.15833-5-osalvador@suse.de>
 <45d6b6ed-ae84-f2d5-0d57-dc2e28938ce0@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45d6b6ed-ae84-f2d5-0d57-dc2e28938ce0@arm.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 24, 2019 at 12:18:26PM +0530, Anshuman Khandual wrote:
> Hello Oscar,

Hi Anshuman,

> Passing down node ID till unregister_mem_sect_under_nodes() solves the problem of
> querying struct page for nid but the current code assumes that the pfn range for
> any given memory section can have different node IDs. Hence it scans over the
> section and try to remove all possible node <---> memory block sysfs links.
> 
> I am just wondering is that assumption even correct ? Can we really have a memory
> section which belongs to different nodes ? Is that even possible.

Yes, current code assumes that, but looking at when we init sections at boot
stage, it seems like a 1:1 map to me.

E.g, in memory_present(), we do encode the nid in section's section_mem_map
field to use that later on in sparse_init(), and get the node we should allocate
the data structures from.

And in memory_present() itself, in case we do not use page's flags field,
we end up using the section_to_node_table[] table, which is clearly a 1:1 map.

So, I might be wrong here, but I think that we do not really have nodes mixed
in a section.

-- 
Oscar Salvador
SUSE L3

