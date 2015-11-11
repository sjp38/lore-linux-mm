Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 564CC6B0253
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 11:03:40 -0500 (EST)
Received: by wmdw130 with SMTP id w130so118738344wmd.0
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 08:03:39 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id r81si31760717wmg.13.2015.11.11.08.03.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 08:03:39 -0800 (PST)
Received: by wmww144 with SMTP id w144so50578778wmw.0
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 08:03:38 -0800 (PST)
Date: Wed, 11 Nov 2015 17:03:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151111160336.GD1432@dhcp22.suse.cz>
References: <20151022143349.GD30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510220939310.23718@east.gentwo.org>
 <20151022151414.GF30579@mtj.duckdns.org>
 <20151023042649.GB18907@mtj.duckdns.org>
 <20151102150137.GB3442@dhcp22.suse.cz>
 <201511052359.JBB24816.FHtFOJOSLOVMQF@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1511051144240.28554@east.gentwo.org>
 <20151106001648.GA18183@mtj.duckdns.org>
 <20151111154424.GC1432@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151111154424.GC1432@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

With the full changelog and the vmstat update for the reference.
---
