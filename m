Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0128DC4151A
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 08:03:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAB1F2087F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 08:03:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAB1F2087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 559CC8E0003; Thu, 31 Jan 2019 03:03:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50AA48E0001; Thu, 31 Jan 2019 03:03:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F97B8E0003; Thu, 31 Jan 2019 03:03:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1548E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 03:03:17 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id e68so1792717plb.3
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 00:03:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6LEW96Msf5PX2GkuUJG3PyFf3DL5tddgkiwqzrNMTBk=;
        b=mDI/Hbuu5Mlc+ZeiWwbdCMxvJgx2U8cYdqxso77aEerB0OQWtjZ5fgjLewYt6MN/No
         QVI6P+ao4zGz+zJh3L4pwe11PrCmIXOQzyxzxGbAF7TpSC4ZqrTLowQU12Jwxv742tni
         kpXUQ3mhrCBJThctVNUn2HhqKt6pc4sJ2pK7Fu76xTkacXD3Yo2lM4W38d9LzPDVWmK6
         ixIEKIgj+32kLgarI4N32uKR3MiA599k34cJVIK6PxMqgAGzIXYh/sfVTMayu7FGQW6s
         xPF3CdhjUrsJX/DLqvfa5ZkHPTKbjvOYmkeX0BQMM+T9/sDAfGyHlqBroLYZ8szblAfI
         FqDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AJcUukf/Jc3C3RIwrTYjnV6mAjP1RIaFZqiZ4RUFIzzlXuR0WPvfQN1f
	+mZJzr3KNa2WvIiYPEwnMoGhccSfZ2JvktivJzEHUy3VS2PUZtIKjvHWyXFWvlFLOneK9sQ4rdM
	8qTnPwm0fbvUiWBDHSahlRR/C/CQkWgEoGug1dlw23vu3kbTLDCKgFaBUx4UlDT8A2Q==
X-Received: by 2002:a62:a1a:: with SMTP id s26mr34105697pfi.31.1548921796730;
        Thu, 31 Jan 2019 00:03:16 -0800 (PST)
X-Google-Smtp-Source: ALg8bN62FE8rbkcoZgEoGE1FZbqi0PHJd8yOkLbDC+6d77BVCteaXPaBS19If8+8vLt4p1McE86e
X-Received: by 2002:a62:a1a:: with SMTP id s26mr34105659pfi.31.1548921795932;
        Thu, 31 Jan 2019 00:03:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548921795; cv=none;
        d=google.com; s=arc-20160816;
        b=nB2zfDVcsj8unjn0rKLALhnEGRVyT/V3l1FJKmVCCK764Hy5dVfAYb28uR5IaaikxS
         lChx26euoKlUu5IQKqRRVc47pMKjx2H/0deKElrUR3oqMZCGIxgsPmaTzMlQvJdm9NiK
         zPS8O3l6/ccl1IuVTFzW6eUi7dipJ1fpDeY9l45MEt1l4rVGb7Yc4rZ/IfkEiZHHpVX1
         5fW8vPhnaX6HkYJNziAnaVnojqf2+Ugl7HpjVYo0o47+izzsdg2RshaEcZ9r+5H5ae1v
         DwBSIVbAUjMK4YjQLgiT1MK8Zr48UHR3nt3nE2yPg48VQ9TBphSd+4iEMQLpyTQEeL8Q
         9KPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6LEW96Msf5PX2GkuUJG3PyFf3DL5tddgkiwqzrNMTBk=;
        b=BlUQgImm0cL7Zn57awl6B2lW1bnYmj7aE4RtC/tbvLgMIQmgyghpoOLiX8wTcHDCdJ
         nR4txbkPcrWYiqY6XFXHm0bZ6P/UJiSXaIG4H7CXEu/KSCPhYUXbLvMPEOwxhivc/o3e
         NJ3Pjft5vxz3QjnuoMJq4o9zPgQlhqnfKkfFdSGYtEZ3NBEbAudMo+TUivVtnY8Joc2E
         XrqcyCNSD+Aowz65Us2oy+XDG7KWe57f2DhYsUf7Z/eQsMt2EyyGjiRcxCL4sqMf2HkA
         PBwjAq/3fuy4XjVjuxrsAa6W+QKuwuJ+yYWQCegnZjSULun1yrX260dgzW6vnaUs+QvO
         pr2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id u69si4118291pfj.219.2019.01.31.00.03.15
        for <linux-mm@kvack.org>;
        Thu, 31 Jan 2019 00:03:15 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 9B27A40EC; Thu, 31 Jan 2019 09:03:14 +0100 (CET)
Date: Thu, 31 Jan 2019 09:03:14 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, dan.j.williams@intel.com,
	Pavel.Tatashin@microsoft.com, david@redhat.com,
	linux-kernel@vger.kernel.org, dave.hansen@intel.com
Subject: Re: [RFC PATCH v2 0/4] mm, memory_hotplug: allocate memmap from
 hotadded memory
Message-ID: <20190131080311.qiqi2tj4iromzzap@d104.suse.de>
References: <20190122103708.11043-1-osalvador@suse.de>
 <20190130215159.culyc2wcgocp5l2p@d104.suse.de>
 <20190131072319.GN18811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190131072319.GN18811@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 08:23:19AM +0100, Michal Hocko wrote:
> On Wed 30-01-19 22:52:04, Oscar Salvador wrote:
> > On Tue, Jan 22, 2019 at 11:37:04AM +0100, Oscar Salvador wrote:
> > > I yet have to check a couple of things like creating an accounting item
> > > like VMEMMAP_PAGES to show in /proc/meminfo to ease to spot the memory that
> > > went in there, testing Hyper-V/Xen to see how they react to the fact that
> > > we are using the beginning of the memory-range for our own purposes, and to
> > > check the thing about gigantic pages + hotplug.
> > > I also have to check that there is no compilation/runtime errors when
> > > CONFIG_SPARSEMEM but !CONFIG_SPARSEMEM_VMEMMAP.
> > > But before that, I would like to get people's feedback about the overall
> > > design, and ideas/suggestions.
> > 
> > just a friendly reminder if some feedback is possible :-)
> 
> I will be off next week and will not get to this this week.

Sure, it can wait.
In the meantime I will take the chance to clean up a couple of things.

Thanks
-- 
Oscar Salvador
SUSE L3

