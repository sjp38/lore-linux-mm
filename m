Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CDD86B0006
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 11:23:39 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n78so13398692pfj.4
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:23:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j7-v6si14411953plk.506.2018.04.24.08.23.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 08:23:37 -0700 (PDT)
Date: Tue, 24 Apr 2018 09:23:31 -0600
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: per-NUMA memory limits in mem cgroup?
Message-ID: <20180424152331.GI17484@dhcp22.suse.cz>
References: <5ADA26AB.6080209@windriver.com>
 <20180422124648.GD17484@dhcp22.suse.cz>
 <5ADDFBD1.7010009@windriver.com>
 <20180424132721.GF17484@dhcp22.suse.cz>
 <5ADF498C.1@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5ADF498C.1@windriver.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Friesen <chris.friesen@windriver.com>
Cc: "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Tue 24-04-18 11:13:16, Chris Friesen wrote:
[...]
> Reading the docs on the memory controller it does seem a bit tricky.  I had
> envisioned some sort of "is there memory left in this group" check before
> "approving" the memory allocation, but it seems it doesn't really work that
> way.

No, your memory will be usually eaten by the page cache.

-- 
Michal Hocko
SUSE Labs
