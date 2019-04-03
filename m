Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C9FBC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:34:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB66C21473
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:34:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB66C21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 785F46B000A; Wed,  3 Apr 2019 04:34:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73C5A6B000C; Wed,  3 Apr 2019 04:34:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D8DB6B000D; Wed,  3 Apr 2019 04:34:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 287A66B000A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 04:34:07 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s27so7090880eda.16
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 01:34:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kPIT8oJLs4f7jECtWXniS/5onbdWye3Rz/zo11Pcp6M=;
        b=Dmy5VT2l7oAglkavI7dXlUKYb6Z2yOIGI7ooBQJRN8wJzUBgMBXnOHGESBl3Z0bDNF
         B7xgdrvIH4Hob9vBcAT2E6JaGFxwDfBk9rTxDr45/A1Wf8GtfHWmJIufIHEZpzTyFOSK
         0pTHlpDZm0A8x4zIISEJFtcIzC8E4UMPFWCFJqBGu+zAXZA/xrkGZVqVS15Fn137gGZs
         QEYiSZe62HVua0VSI2wESMZ+PketA7OEn+9Zvu3uA/gCy8G7AlBr0hGBhDav0KKglCMS
         UbtIU9Bx5DX0FiwUMNUSjPdykB5bQNQpzKtwVJKGSQgs/LHyND/L+nkhmJ/RTRJdjH5W
         UwOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVfPkN9KprrFwgd/1fHKAByXht95mGTbGjP62by9k0ZZOrVoVGF
	Kqk5LWpC/jEi70nrywzqAMzvhFJSn4B+oFXMK6JzzvByl9oZeIQW4lwYK83unqunaoaUAucrQw/
	wLxws40Lr+nZDfFOG58uf7/WHFVm9QpMwO17wbSq3cLaqQEYZt+BN1Iu9j9KzVY/2Zw==
X-Received: by 2002:a17:906:8381:: with SMTP id p1mr40511467ejx.169.1554280446742;
        Wed, 03 Apr 2019 01:34:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZHJwQh+CNXpUgA5sw5gOIk+SQUDyyQA8SOs7p+yjFJRQO3Qo2EPR44vZ3mdgAcqp/hC1b
X-Received: by 2002:a17:906:8381:: with SMTP id p1mr40511424ejx.169.1554280445989;
        Wed, 03 Apr 2019 01:34:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554280445; cv=none;
        d=google.com; s=arc-20160816;
        b=RgeMoktrptZkohjadSzTLh5L46kC6L0UnHrLtMAV954NNx6F0Gmt3/GOu7/JxSioIL
         y+h3m+iaKC1taZxHg+x4s4InCwrEyJhwi/30mFHO2MOilcYFPB4VchosL4qOA53eJLTS
         IQsSQCEcIjVqI+0jHUQrelr8ddFcweo22z44+49kvgv8F+1wSo4aATNXAm3V6DxynA0u
         dKldDnssWQVwY68LRprsT/gfaGw9VD0jBHMtWOt/yOHoqWNhLz2lpphcyYhN0kNyL4Kn
         LVUBNdfOlc6TZyoG7rNwBjCYC8ag+3SrubGieNOGdDD20Fj4DVfNsXOIAqeUTBWHDieo
         Ophg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kPIT8oJLs4f7jECtWXniS/5onbdWye3Rz/zo11Pcp6M=;
        b=pAbOXV0hDXroaInIbLYe5hXwyJWBjC/F1izN9Z9vs7GpmlaI3Uu2ZJOf4nHE2aom3A
         qF/KJ3iRmNlZO1zRQkGJlKjHKpn6udHfYzUKuJyoOhdpf8aLB2dUBzbS7wGsW2D1ZLMC
         7rU3gfBMGQ/sNif9PxO5SL0ngVGwZMDVxTERS0pJcZf/dKlFtkRLcUfoe2C33fWlzJtk
         QKnzpfHMv8aljbK7OS+SSbxBDP+VA0A+Xzz11zo6tKPm9Pm4P2yfwCoLN2YCP6khd2zI
         L8cSpa7/BhhUGP2cHwZxzOoHB1Spvt3Qp1dGa+gD4MxkVuF5aJENxZ6DloyZY8LFhV60
         RJOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id d27si304665edb.436.2019.04.03.01.34.05
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 01:34:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 4B04E47E3; Wed,  3 Apr 2019 10:34:00 +0200 (CEST)
Date: Wed, 3 Apr 2019 10:34:00 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Hildenbrand <david@redhat.com>, akpm@linux-foundation.org,
	dan.j.williams@intel.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
Message-ID: <20190403083359.vqbzy5krjfzfjedx@d104.suse.de>
References: <cc68ec6d-3ad2-a998-73dc-cb90f3563899@redhat.com>
 <efb08377-ca5d-4110-d7ae-04a0d61ac294@redhat.com>
 <20190329084547.5k37xjwvkgffwajo@d104.suse.de>
 <20190329134243.GA30026@dhcp22.suse.cz>
 <20190401075936.bjt2qsrhw77rib77@d104.suse.de>
 <20190401115306.GF28293@dhcp22.suse.cz>
 <20190402082812.fefamf7qlzulb7t2@d104.suse.de>
 <20190402124845.GD28293@dhcp22.suse.cz>
 <20190403080113.adj2m3szhhnvzu56@d104.suse.de>
 <20190403081232.GB15605@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403081232.GB15605@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 10:12:32AM +0200, Michal Hocko wrote:
> What does prevent calling somebody arch_add_memory for a range spanning
> multiple memblocks from a driver directly. In other words aren't you
> making  assumptions about a future usage based on the qemu usecase?

Well, right now they cannot as it is not exported.
But if we want to do it in the future, then yes, I would have to
be more careful because I made the assumption that hot-add/hot-remove
are working with the same granularity, which is the case right now.

Given said this, I think that something like you said before, giving
the option to the caller to specify whether it wants vmemmaps per the
whole hot-added range or per memblock is a reasonable thing to do.
That way, there will not be a problem working with different granularities
in hot-add/hot-remove operations and we would be on safe side.

-- 
Oscar Salvador
SUSE L3

