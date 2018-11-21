Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 36EA76B2683
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 11:27:51 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x15so3258643edd.2
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 08:27:51 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l16-v6si2028707ejq.174.2018.11.21.08.27.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 08:27:49 -0800 (PST)
Date: Wed, 21 Nov 2018 17:27:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 201699] New: kmemleak in memcg_create_kmem_cache
Message-ID: <20181121162747.GR12932@dhcp22.suse.cz>
References: <bug-201699-27@https.bugzilla.kernel.org/>
 <20181115130646.6de1029eb1f3b8d7276c3543@linux-foundation.org>
 <20181116175005.3dcfpyhuj57oaszm@esperanza>
 <433c2924.f6c.16724466cd8.Coremail.bauers@126.com>
 <20181119083045.m5rhvbsze4h5l6jq@esperanza>
 <6185b79c.9161.1672bd49ed1.Coremail.bauers@126.com>
 <375ca28a.7433.16735734d98.Coremail.bauers@126.com>
 <20181121091041.GM12932@dhcp22.suse.cz>
 <5fa306b3.7c7c.1673593d0d8.Coremail.bauers@126.com>
 <556CF326-C3ED-44A7-909B-780531A8D4FF@bytedance.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <556CF326-C3ED-44A7-909B-780531A8D4FF@bytedance.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?5q6154aK5pil?= <duanxiongchun@bytedance.com>
Cc: dong <bauers@126.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed 21-11-18 17:36:51, ae(R)uc??ae?JPY wrote:
> hi alli 1/4 ?
> 
> In same casei 1/4 ? I think ita??s may be a problema??
> 
> if I create a virtual netdev device under mem cgroup(like ip link add ve_A type veth peer name ve_B).after that ,I destroy this mem cgroupa??

Which object is charged to that memcg? If there is no relation to any
task context then accounting to a memcg is problematic.

-- 
Michal Hocko
SUSE Labs
