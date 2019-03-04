Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4A39C4360F
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 13:48:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7058C2075B
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 13:48:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7058C2075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3F368E0003; Mon,  4 Mar 2019 08:48:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CED648E0001; Mon,  4 Mar 2019 08:48:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB6468E0003; Mon,  4 Mar 2019 08:48:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6852A8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 08:48:15 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x13so2681246edq.11
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 05:48:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9l3RGCTTjmJbph6q/td2aX3wHDvyI8VFS91Jhy8HNiM=;
        b=fJscChCQi7ntn10Ize2poG5FCzNZb32yX1Zy2Hx/jiE/V4LFk7PODspSxK9915eP6g
         yomww3GjVbYlJTTIi64Pg67Nky/ul5Q4CCAz8BbEwSdbJO/97+PpMsiYUbBBjxdXD3zJ
         S4L6mHPySbn1aDdVz+gzrduAJ2QXTgwFElPULmi2QHpkb2+gtDnAElk1pcHby4DKljVU
         jFgLJ3dIJj/T8Ibjsc0ycG90s8Fw9Hv6qtunZu8wMfJzP1Gzh2Ffn4XnzFYyGlCWNeVX
         eMP7kflJFxIb3DbJYJkDSXyArwzPkmh0Lvnf/d3ZWlxv0ojThp/g5vU0XCqHoo8InYUR
         /ksQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWPut+IKstni+IBpy/PFUhXaOhHY8nf8NKjhis7IkIpx/3mxr6h
	wZRm+UyUTY7uvaNmi5LJa5xs4RqyaKf/1IAbj2cBB35YZug9DrhwMDnEpx2WMGq0e3GXHO2lghR
	YDaEAqWxw4tiiMCLNkaDCZms2KJpgCWoJeHGj0uub2iOX4rACzcUW/H8EoxJjUX4=
X-Received: by 2002:a17:906:3050:: with SMTP id d16mr12933639ejd.200.1551707294942;
        Mon, 04 Mar 2019 05:48:14 -0800 (PST)
X-Google-Smtp-Source: APXvYqytWziXMWLVsHqaTmCjyXv32uHTGQRfQu4+QvwzUHVxU/QUJBhuLbTnZmqkXUGYHuXlf2ME
X-Received: by 2002:a17:906:3050:: with SMTP id d16mr12933582ejd.200.1551707293880;
        Mon, 04 Mar 2019 05:48:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551707293; cv=none;
        d=google.com; s=arc-20160816;
        b=sULsGqO51PVg40QScJ+dbmOsKCe+m619c5UrczXuJjZ1EtVlgqJqGa9u0WHi/a1Ob6
         3bkRPhqpyZuyX7ugb/2QrzaCCfhlKR+9tIJVVmnZjUjWNQ/VgNbhtmtCjHCbJziLmnlJ
         +w3nPC/JzqGjd6LSrHkJA5V6+tsCBIY5IKbydaz3CXRkCvg9XiCX+KXgnFKmuFLNaZpN
         BhB/lrIxv/xlHVR4jjQB9R9g+NbSXDVGkNPOu8gTy2RZzFJJjbjweoGA/f/rJXu+10sK
         +7hKRZY4B9zKERQiRqmCV4LBHrJfJqi94qjXBTVy41K3g9GTLARydRAYwoNOlPYBXMRo
         MyTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9l3RGCTTjmJbph6q/td2aX3wHDvyI8VFS91Jhy8HNiM=;
        b=0BSjOWfcB2It4p4Q88ufXoj97sT5MfO4D27gq9TBiRFpv3MFJblGIzJ/wK+YgZLGHx
         Aap+iAJvwmDnW0wJQenZDQg9idXZ8RxqVN25PufUbVV+LPLz7m2h78aBAa+s61KNq9HK
         25+lp2yBq3+sCs9IhaLwkW6iTjiuU4EX2m8mxdEf9UanuN73gr3iXvtR58QoCjSS172+
         STjmE95k1weqDEQyzuhEFyoAdQtBNAxjSE7IrlnwI72Sf6/XlC7B/fSehbxibW5fzQGk
         QTvnE6aYakfTqZrz66Mbk4mYX/hCqmni4y/0DpQJBeXY7TXzuw7sGmW74gMujsfTw1N2
         DFBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id y23si1868657ejm.129.2019.03.04.05.48.13
        for <linux-mm@kvack.org>;
        Mon, 04 Mar 2019 05:48:13 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 7704E446F; Mon,  4 Mar 2019 14:48:12 +0100 (CET)
Date: Mon, 4 Mar 2019 14:48:12 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Jing Xiangfeng <jingxiangfeng@huawei.com>, mhocko@kernel.org,
	hughd@google.com, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
Message-ID: <20190304134809.2aprjskb6z6gv6c5@d104.suse.de>
References: <388cbbf5-7086-1d04-4c49-049021504b9d@oracle.com>
 <alpine.DEB.2.21.1902241913000.34632@chino.kir.corp.google.com>
 <8c167be7-06fa-a8c0-8ee7-0bfad41eaba2@oracle.com>
 <13400ee2-3d3b-e5d6-2d78-a770820417de@oracle.com>
 <alpine.DEB.2.21.1902251116180.167839@chino.kir.corp.google.com>
 <5C74A2DA.1030304@huawei.com>
 <alpine.DEB.2.21.1902252220310.40851@chino.kir.corp.google.com>
 <e2bded2f-40ca-c308-5525-0a21777ed221@oracle.com>
 <20190226143620.c6af15c7c897d3362b191e36@linux-foundation.org>
 <086c4a4b-a37d-f144-00c0-d9a4062cc5fe@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <086c4a4b-a37d-f144-00c0-d9a4062cc5fe@oracle.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 04:03:23PM -0800, Mike Kravetz wrote:
> I was just going to update the comments and send you a new patch, but
> but your comment got me thinking about this situation.  I did not really
> change the way this code operates.  As a reminder, the original code is like:
> 
> NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
> 
> if (nid == NUMA_NO_NODE) {
> 	/* do something */
> } else if (nodes_allowed) {
> 	/* do something else */
> } else {
> 	nodes_allowed = &node_states[N_MEMORY];
> }
> 
> So, the only way we get to that final else if if we can not allocate
> a node mask (kmalloc a few words).  Right?  I wonder why we should
> even try to continue in this case.  Why not just return right there?
> 
> The specified count value is either a request to increase number of
> huge pages or decrease.  If we can't allocate a few words, we certainly
> are not going to find memory to create huge pages.  There 'might' be
> surplus pages which can be converted to permanent pages.  But remember
> this is a 'node specific' request and we can't allocate a mask to pass
> down to the conversion routines.  So, chances are good we would operate
> on the wrong node.  The same goes for a request to 'free' huge pages.
> Since, we can't allocate a node mask we are likely to free them from
> the wrong node.
> 
> Unless my reasoning above is incorrect, I think that final else block
> in __nr_hugepages_store_common() is wrong.
> 
> Any additional thoughts?

Could not we kill the NODEMASK_ALLOC there?
__nr_hugepages_store_common() should be called from a rather shallow stack,
and unless I am wrong, the maximum value we can get for a nodemask_t is 128bytes
(1024 NUMA nodes).

-- 
Oscar Salvador
SUSE L3

