Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D469BC31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:17:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9238F205F4
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:17:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9238F205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E5C46B0003; Wed, 19 Jun 2019 05:17:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36F9F8E0002; Wed, 19 Jun 2019 05:17:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 237878E0001; Wed, 19 Jun 2019 05:17:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C6AAE6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 05:17:01 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f19so25261328edv.16
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:17:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=igz9KIGCVujcWh+HCJrRAHpfyplXv/mllZ8Zg5oq+NQ=;
        b=Ed2P5GEEA0axJWH/iaXlciR555qtLgg3s7lBCT2z2WQ9cZOBZMPPDMb9rR7vsp3H4q
         hifjkICwm3u6zA4hPgiAGjjrAR3lLwCmttcBSatIUPZ62Gfd43dPv0O4bBIIdN8oeYBK
         cwE+QCe24Z2v90syhHGmoHwrfoyE8h04iDps6LmlhsBhrS/GczxAA+w6sWPRO6/JwvXo
         MUGB37LG0NU8A+DNup8jEH7j5AW1FBxzykCn3ubjtRBosIMGfJHmp4EF3Hq5UanSIzXr
         qss3D0dMAYeuJB+SNOTLAb1iEOiXA301H7KEJepVBsgLU6h9I4cqlUMdqhGeRfLf5Hm8
         gHrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAV+QhAeURRHSq6g+x9wtdtJXvXMVoXFGwbR0cEO4MLCW+y/0CL2
	a/PQChouzGkNOz0pfRn5CWpLHFjSL1kze2U0qzhYJKzajxxIKyRR3IKZWSQ5E6209ehC9Jb1tL4
	KsBN6ypK4WtKLYvrYCMVEo6HVXL5kUn8D/j1CCm9hNZ+fsOjk4I4rI7/wqNIgMdpAqw==
X-Received: by 2002:a50:86b7:: with SMTP id r52mr104500411eda.100.1560935821380;
        Wed, 19 Jun 2019 02:17:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7fb57YOHgm0DYLX/UgjE75KP+fUbhqVAB8L72S529EgwO9mj5z67l9M/NFcRTEcEcl/5n
X-Received: by 2002:a50:86b7:: with SMTP id r52mr104500347eda.100.1560935820695;
        Wed, 19 Jun 2019 02:17:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560935820; cv=none;
        d=google.com; s=arc-20160816;
        b=wiqUxK5hR9xbIGqMNqpMxcbSgeN2Fn7/CPlyGUCJOu1XUezeofiTLxvmUAx57LeT4p
         IgRqkMCVg+KuxvuOo7zA6+NDw3nRFxeX0CUEnx30z93oH+W3uBD/e9AFfa+jnZF76Ce/
         RT7AtjMNWImCAXkU5qUg4Wss8gIpHAewuDogLsNSK76Hn/amAWVvGGc7HDS6S/S8FAdP
         AxEtsDaJx8bj2zKALpNeMt3tFSIUn4DipBCFjJkpxmaA03ajzHbw+HqsSOo0XCm7X2Le
         kH6qePM/vKIQwJ8BuaUHU5UvceQgLwf2JS45ZepHlsPLGZmocBCxSpO7vj0/brmKuakW
         GCwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=igz9KIGCVujcWh+HCJrRAHpfyplXv/mllZ8Zg5oq+NQ=;
        b=vLexsaE7WxvE8bM52Qt+3LaG46LXxGbhfVQGhCNHn2oYFA4ZY9Fnd5HW+T0QTlE0YE
         MbRpvAS6KEaDS010mQGzgUtHdvD5/P/S8wxYQFm9UzmHnhItybvNW3eelKf5NiDcj6D8
         sIpa14H4XjZqg1tlDucnDcFUy1ifL1WoA3NlQzhaF7x13FTMW+eZLZek0a1pUcqNDRUY
         3BcnitEjnqo4S8nZbqOr+iYuMz21Qn/haYz2imRADXfRY9xgixs7HGydXVUK+DSyMQGO
         jsahOUV06p7FcBXeQYREf2jyL/Tyb7J3AMCV48LzLgjJDJH2elhQGDwPVJu+9toT9d3j
         +hPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z2si720028edh.303.2019.06.19.02.17.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 02:17:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B1FA9ADCF;
	Wed, 19 Jun 2019 09:16:59 +0000 (UTC)
Date: Wed, 19 Jun 2019 11:16:58 +0200
From: Michal Hocko <mhocko@suse.com>
To: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.de>,
	Wei Yang <richardw.yang@linux.intel.com>, linux-mm@kvack.org,
	akpm@linux-foundation.org, anshuman.khandual@arm.com
Subject: Re: [PATCH v2] mm/sparse: set section nid for hot-add memory
Message-ID: <20190619091658.GL2968@dhcp22.suse.cz>
References: <20190618005537.18878-1-richardw.yang@linux.intel.com>
 <20190619062330.GB5717@dhcp22.suse.cz>
 <20190619075347.GA22552@linux>
 <a52a196a-9900-0710-a508-966e725eae03@redhat.com>
 <20190619090405.GJ2968@dhcp22.suse.cz>
 <361b8e87-7c30-c492-cfa9-e068c5f55bf9@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <361b8e87-7c30-c492-cfa9-e068c5f55bf9@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 19-06-19 11:07:30, David Hildenbrand wrote:
> On 19.06.19 11:04, Michal Hocko wrote:
> > On Wed 19-06-19 10:51:47, David Hildenbrand wrote:
> >> On 19.06.19 09:53, Oscar Salvador wrote:
> >>> On Wed, Jun 19, 2019 at 08:23:30AM +0200, Michal Hocko wrote:
> >>>> On Tue 18-06-19 08:55:37, Wei Yang wrote:
> >>>>> In case of NODE_NOT_IN_PAGE_FLAGS is set, we store section's node id in
> >>>>> section_to_node_table[]. While for hot-add memory, this is missed.
> >>>>> Without this information, page_to_nid() may not give the right node id.
> >>>>
> >>>> Which would mean that NODE_NOT_IN_PAGE_FLAGS doesn't really work with
> >>>> the hotpluged memory, right? Any idea why nobody has noticed this
> >>>> so far? Is it because NODE_NOT_IN_PAGE_FLAGS is rare and essentially
> >>>> unused with the hotplug? page_to_nid providing an incorrect result
> >>>> sounds quite serious to me.
> >>>
> >>> The thing is that for NODE_NOT_IN_PAGE_FLAGS to be enabled we need to run out of
> >>> space in page->flags to store zone, nid and section. 
> >>> Currently, even with the largest values (with pagetable level 5), that is not
> >>> possible on x86_64.
> >>> It is possible though, that somewhere in the future, when the values get larger
> >>> (e.g: we add more zones, NODE_SHIFT grows, or we need more space to store
> >>> the section) we finally run out of room for the flags though.
> >>>
> >>> I am not sure about the other arches though, we probably should audit them
> >>> and see which ones can fall in there.
> >>>
> >>
> >> I'd love to see NODE_NOT_IN_PAGE_FLAGS go.
> > 
> > NODE_NOT_IN_PAGE_FLAGS is an implementation detail on where the
> > information is stored.
> 
> Yes and no. Storing it per section clearly doesn't allow storing node
> information on smaller granularity, like storing in page->flags does.
> 
> So no, it is not only an implementation detail.

Let me try to put it differently. NODE_NOT_IN_PAGE_FLAGS is not about
storing the mapping per section. You can do what ever other data
structure. NODE_NOT_IN_PAGE_FLAGS is in fact about telling that it is
not in page->flags.

> > I cannot say how much it is really needed now but
> > I can see there will be a demand for it in a longer term because
> > page->flags space is scarce and very interesting storage. So I do not
> > see it go away I am afraid.
> Depends on how performance-critical pfn_to_nid() is. I can't tell.

page_to_node is used in many important code paths. Not in the hotest
ones I believe but many of them are quite hot I would say.

-- 
Michal Hocko
SUSE Labs

