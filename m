Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id BA6686B0003
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 07:30:18 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id z13-v6so13592580wrq.3
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 04:30:18 -0700 (PDT)
Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc. [2a01:7a0:2:106d:670::1])
        by mx.google.com with ESMTPS id 196-v6si1140918wmu.166.2018.08.07.04.30.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 07 Aug 2018 04:30:17 -0700 (PDT)
Date: Tue, 7 Aug 2018 13:30:13 +0200
From: Florian Westphal <fw@strlen.de>
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
Message-ID: <20180807113013.su4vjj46vh5fkiqx@breakpoint.cc>
References: <20180731140520.kpotpihqsmiwhh7l@breakpoint.cc>
 <e5b24629-0296-5a4d-577a-c25d1c52b03b@suse.cz>
 <20180801083349.GF16767@dhcp22.suse.cz>
 <e5c5e965-a6bc-d61f-97fc-78da287b5d94@icdsoft.com>
 <20180802085043.GC10808@dhcp22.suse.cz>
 <85c86f17-6f96-6f01-2a3c-e2bad0ccb317@icdsoft.com>
 <5b5e872e-5785-2cfd-7d53-e19e017e5636@icdsoft.com>
 <20180807110951.GZ10003@dhcp22.suse.cz>
 <20180807111926.ibdkzgghn3nfugn2@breakpoint.cc>
 <20180807112641.GB10003@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180807112641.GB10003@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Florian Westphal <fw@strlen.de>, Georgi Nikolov <gnikolov@icdsoft.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 07-08-18 13:19:26, Florian Westphal wrote:
> > Michal Hocko <mhocko@kernel.org> wrote:
> > > > I can't reproduce it anymore.
> > > > If i understand correctly this way memory allocated will be
> > > > accounted to kmem of this cgroup (if inside cgroup).
> > > 
> > > s@this@caller's@
> > > 
> > > Florian, is this patch acceptable
> > 
> > I am no mm expert.  Should all longlived GFP_KERNEL allocations set ACCOUNT?
> 
> No. We should focus only on those that are under direct userspace
> control and it can be triggered by an untrusted user.

In that case patch is fine and we will need similar patches for
nf_tables_api.c .
