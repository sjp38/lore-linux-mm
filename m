Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 808D96B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 12:33:24 -0500 (EST)
Received: by wevk48 with SMTP id k48so34833080wev.0
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 09:33:24 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p5si23651349wjo.25.2015.03.02.09.33.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 09:33:23 -0800 (PST)
Date: Mon, 2 Mar 2015 12:33:15 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] memcg: disable hierarchy support if bound to the
 legacy cgroup hierarchy
Message-ID: <20150302173315.GA24664@phnom.home.cmpxchg.org>
References: <131af5f5ee0eec55d0f94a785db4be04baf01f51.1424356325.git.vdavydov@parallels.com>
 <421fb6bbff04eb70b8ad82b51efd373f0b4d170f.1424356325.git.vdavydov@parallels.com>
 <20150302171323.GM17694@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150302171323.GM17694@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Mar 02, 2015 at 12:13:23PM -0500, Tejun Heo wrote:
> On Thu, Feb 19, 2015 at 05:34:47PM +0300, Vladimir Davydov wrote:
> > If the memory cgroup controller is initially mounted in the scope of the
> > default cgroup hierarchy and then remounted to a legacy hierarchy, it
> > will still have hierarchy support enabled, which is incorrect. We should
> > disable hierarchy support if bound to the legacy cgroup hierarchy.
> > 
> > Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> 
> Johannes, Michal, can you guys pick this up?

Yup, will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
