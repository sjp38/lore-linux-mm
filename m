Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id E7E9A6B006E
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 08:05:09 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id bm13so7469969qab.0
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 05:05:09 -0800 (PST)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id r6si22234986qay.111.2015.01.12.05.05.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Jan 2015 05:05:09 -0800 (PST)
Received: by mail-qg0-f41.google.com with SMTP id e89so17337438qgf.0
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 05:05:08 -0800 (PST)
Date: Mon, 12 Jan 2015 08:05:02 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH cgroup/for-3.19-fixes] cgroup: implement
 cgroup_subsys->unbind() callback
Message-ID: <20150112130502.GV25319@htj.dyndns.org>
References: <54B01335.4060901@arm.com>
 <20150110085525.GD2110@esperanza>
 <20150110214316.GF25319@htj.dyndns.org>
 <20150111205543.GA5480@phnom.home.cmpxchg.org>
 <20150112080114.GE2110@esperanza>
 <20150112112845.GS25319@htj.dyndns.org>
 <20150112125956.GF2110@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150112125956.GF2110@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Will Deacon <Will.Deacon@arm.com>

On Mon, Jan 12, 2015 at 03:59:56PM +0300, Vladimir Davydov wrote:
> I haven't dug deep into the cgroup core, but may be we could detach the
> old root in cgroup_kill_sb() and leave it dangling until the last
> reference to it has gone?

The root isn't the problem here.  Individual controllers are as
there's only one copy of each and we most likely don't want to carry
over child csses from one hierarchy to the next as the controller may
operate under a different set of rules.

> BTW, IIRC the problem always existed for kmem-active memory cgroups,
> because we never had kmem reparenting. May be, we could therefore just
> document somewhere that kmem accounting is highly discouraged to be used
> in the legacy hierarchy and merge these two patches as is to handle page
> cache and swap charges? We won't break anything, because it was always
> broken :-)

If we're going that route, I think it'd be better to declare hierarchy
lifetime rules as essentially opaque to userland and destroy
hierarchies only when all its children, dead or alive, are gone.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
