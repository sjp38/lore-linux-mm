Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A7F716B2A3C
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 02:34:23 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id w7-v6so13462558plp.9
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 23:34:23 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n11-v6si20637945plg.87.2018.11.21.23.34.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 23:34:22 -0800 (PST)
Date: Thu, 22 Nov 2018 08:34:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 201699] New: kmemleak in memcg_create_kmem_cache
Message-ID: <20181122073420.GB18011@dhcp22.suse.cz>
References: <20181116175005.3dcfpyhuj57oaszm@esperanza>
 <433c2924.f6c.16724466cd8.Coremail.bauers@126.com>
 <20181119083045.m5rhvbsze4h5l6jq@esperanza>
 <6185b79c.9161.1672bd49ed1.Coremail.bauers@126.com>
 <375ca28a.7433.16735734d98.Coremail.bauers@126.com>
 <20181121091041.GM12932@dhcp22.suse.cz>
 <5fa306b3.7c7c.1673593d0d8.Coremail.bauers@126.com>
 <556CF326-C3ED-44A7-909B-780531A8D4FF@bytedance.com>
 <20181121162747.GR12932@dhcp22.suse.cz>
 <7348A2DF-87E8-4F88-B270-7FB71DB5C8CB@bytedance.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7348A2DF-87E8-4F88-B270-7FB71DB5C8CB@bytedance.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?5q6154aK5pil?= <duanxiongchun@bytedance.com>
Cc: dong <bauers@126.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu 22-11-18 10:56:04, 段熊春 wrote:
> After long time dig, we find their lots of offline but not release memcg object in memory eating lots of memory.
> Why this memcg not release? Because the inode pagecache use  some page which is charged to those memcg,

As already explained these objects should be reclaimed under memory
pressure. If they are not then there is a bug. And Roman has fixed some
of those recently.

Which kernel version are you using?
-- 
Michal Hocko
SUSE Labs
