Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0E13782F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 17:52:11 -0500 (EST)
Received: by wmww144 with SMTP id w144so18213309wmw.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 14:52:10 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id hi4si234548wjc.65.2015.11.05.14.52.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 14:52:09 -0800 (PST)
Date: Thu, 5 Nov 2015 17:52:00 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151105225200.GA5432@cmpxchg.org>
References: <20151027122647.GG9891@dhcp22.suse.cz>
 <20151027154138.GA4665@cmpxchg.org>
 <20151027161554.GJ9891@dhcp22.suse.cz>
 <20151027164227.GB7749@cmpxchg.org>
 <20151029152546.GG23598@dhcp22.suse.cz>
 <20151029161009.GA9160@cmpxchg.org>
 <20151104104239.GG29607@dhcp22.suse.cz>
 <20151104195037.GA6872@cmpxchg.org>
 <20151105144002.GB15111@dhcp22.suse.cz>
 <20151105205522.GA1067@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151105205522.GA1067@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Nov 05, 2015 at 03:55:22PM -0500, Johannes Weiner wrote:
> On Thu, Nov 05, 2015 at 03:40:02PM +0100, Michal Hocko wrote:
> > This would be true if they moved on to the new cgroup API intentionally.
> > The reality is more complicated though. AFAIK sysmted is waiting for
> > cgroup2 already and privileged services enable all available resource
> > controllers by default as I've learned just recently.
> 
> Have you filed a report with them? I don't think they should turn them
> on unless users explicitely configure resource control for the unit.

Okay, verified with systemd people that they're not planning on
enabling resource control per default.

Inflammatory half-truths, man. This is not constructive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
