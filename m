Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CD45C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:10:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B25120679
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:10:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B25120679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9BA08E0005; Wed, 19 Jun 2019 02:10:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4AAB8E0003; Wed, 19 Jun 2019 02:10:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A14008E0005; Wed, 19 Jun 2019 02:10:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 566D58E0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:10:28 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k22so24669725ede.0
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:10:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Rozr/ImJR2c8yWhDDNCj/WHVelt/TnoaDO4kaX4HCQ4=;
        b=L489z1Oy9+sA3i9i+GodVDGeFsMgIU2ctQB270KMMIb6q0ZKaABByDSWVqfvFVNZGJ
         SgfNhZ9KcpWk7ipagnxl9ypR4Pg0aJIl2Lc6nPETt2jZ8Nh8AGltX7fofNiQnp908Wm4
         jNRmD9TKxFrFvSBKcIX/nrgcfhxeaoQ6N64JtTOSXJGRSh4mAHKjh4qDcf+kstHx3hN9
         KmZOLTWzgtyD9d2k/p/qmpsOlnBJEA0jVVq2lZ+ZgCLmIbaPvwvJm8+ojw0ahiL5XBD+
         IGKxH8SvpTFkrtd30AI7oqLR46+POB4PLT+DwTGzBgM9/fljxKrc1xb177X2kFxgknwR
         H2fg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAUJjOaMjXxDkpqJXCAzSiLXJvS/HfPqpu+C2oixIhe6prc+LRV6
	jq0WSB1A6sL/TdptVvSdykDFlwnxdYSVSF1XDP3J/JglGCqx7MMDtyZ8j/LcxuWtuUulY4jMonl
	snbpNiXHbljJDQ60Dcs+OVgbKD2IRyDs7nyY6YSmKzmcK68JbZi5q8KFneBRpzXap3A==
X-Received: by 2002:a17:906:15d0:: with SMTP id l16mr55748843ejd.234.1560924627903;
        Tue, 18 Jun 2019 23:10:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzyLF17PqqcGR2pKGP1zFxg4Dmkq1X4KLlxThU1L2zNW3sp/W02At6H13AzYQx1i9Ag2Nok
X-Received: by 2002:a17:906:15d0:: with SMTP id l16mr55748785ejd.234.1560924627007;
        Tue, 18 Jun 2019 23:10:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560924627; cv=none;
        d=google.com; s=arc-20160816;
        b=DbB5hushacTrF6U+jKq7NIoOCXWM/qAGlhv8AZd9jY6SM7fssSdyOFvh/XNAWEtO6j
         fde3JsdWQYv1uGqKVUGCFoofQZaax0vW3hDYmAc3OAvKaFUmSjbZsaCRssbutrMPsHwL
         E6ePWLrcbU8p8LjV3AHSxmTsqWxKRHzQRTOji/Ak6uud0Xk1dmb0Hbf1fcVTtUVd3BRl
         hsrsmV9GPEGcgbDAzHeZnr2KP9/DlF9Uvxx/hCsbDvkfXNyzewAmZsEDjQJLDFu0MzBL
         usc5BY1Xt+pG4iXbupr3QHViVg11KGjDqJ74Cr/ssYgFou0jSVkCnfsSNyhQ/4oz3znW
         SZXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Rozr/ImJR2c8yWhDDNCj/WHVelt/TnoaDO4kaX4HCQ4=;
        b=0l4h632IygdXYmWEe5xowRuwNDmUoK34/OL+zsB0komRWIG/FoWbI2eDttxNO6qTEE
         ZEWGMfsVo25C7WKuv45xYThsYIS7poNwHRnVzLEwbM2cy+9Aw1LriFwy0S0eWYv2/+G3
         3Ot/9ll2way7aC/12w2bCX+k0QeorQR1IN/yRIvKzQW4dcwyIc+57VGdJzmHXYemG34C
         M4AQ3oqHTFhjUYkoG5pzeFTGxnR9wRgx3mQwJdMzNSYKExXVM1T2HzIOGXg3zjbqyrKm
         x/Wo0cvKSInXN7j0QNU3Ohu/ph6Yv0dpTL1zXX3YaVC1HDZkguPhRir6uEbg5LwdIZDu
         YaZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y10si12967821edc.151.2019.06.18.23.10.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:10:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 46FE0AFC3;
	Wed, 19 Jun 2019 06:10:26 +0000 (UTC)
Date: Wed, 19 Jun 2019 08:10:25 +0200
From: Michal Hocko <mhocko@suse.com>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>,
	Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org,
	akpm@linux-foundation.org, anshuman.khandual@arm.com
Subject: Re: [PATCH v2] mm/sparse: set section nid for hot-add memory
Message-ID: <20190619061025.GA5717@dhcp22.suse.cz>
References: <20190618005537.18878-1-richardw.yang@linux.intel.com>
 <20190618074900.GA10030@linux>
 <20190618083212.GA24738@richard>
 <93d7ea6c-135e-7f12-9d75-b3657862dea0@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <93d7ea6c-135e-7f12-9d75-b3657862dea0@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 18-06-19 10:40:06, David Hildenbrand wrote:
> On 18.06.19 10:32, Wei Yang wrote:
> > On Tue, Jun 18, 2019 at 09:49:48AM +0200, Oscar Salvador wrote:
> >> On Tue, Jun 18, 2019 at 08:55:37AM +0800, Wei Yang wrote:
> >>> In case of NODE_NOT_IN_PAGE_FLAGS is set, we store section's node id in
> >>> section_to_node_table[]. While for hot-add memory, this is missed.
> >>> Without this information, page_to_nid() may not give the right node id.
> >>>
> >>> BTW, current online_pages works because it leverages nid in memory_block.
> >>> But the granularity of node id should be mem_section wide.
> >>
> >> I forgot to ask this before, but why do you mention online_pages here?
> >> IMHO, it does not add any value to the changelog, and it does not have much
> >> to do with the matter.
> >>
> > 
> > Since to me it is a little confused why we don't set the node info but still
> > could online memory to the correct node. It turns out we leverage the
> > information in memblock.
> 
> I'd also drop the comment here.
> 
> > 
> >> online_pages() works with memblock granularity and not section granularity.
> >> That memblock is just a hot-added range of memory, worth of either 1 section or multiple
> >> sections, depending on the arch or on the size of the current memory.
> >> And we assume that each hot-added memory all belongs to the same node.
> >>
> > 
> > So I am not clear about the granularity of node id. section based or memblock
> > based. Or we have two cases:
> > 
> > * for initial memory, section wide
> > * for hot-add memory, mem_block wide
> 
> It's all a big mess. Right now, you can offline initial memory with
> mixed nodes. Also on my list of many ugly things to clean up.
> 
> (I even remember that we can have mixed nodes within a section, but I
> haven't figured out yet how that is supposed to work in some scenarios)

Yes, that is indeed the case. See 4aa9fc2a435abe95a1e8d7f8c7b3d6356514b37a.
How to fix this? Well, I do not think we can. Section based granularity
simply doesn't agree with the reality and so we have to live with that.
There is a long way to remove all those section size assumptions from
the code though.

-- 
Michal Hocko
SUSE Labs

