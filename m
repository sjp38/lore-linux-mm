Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 609156B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 06:28:50 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id j7so7193008qaq.5
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 03:28:50 -0800 (PST)
Received: from mail-qa0-x22c.google.com (mail-qa0-x22c.google.com. [2607:f8b0:400d:c00::22c])
        by mx.google.com with ESMTPS id q16si22042294qan.37.2015.01.12.03.28.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Jan 2015 03:28:49 -0800 (PST)
Received: by mail-qa0-f44.google.com with SMTP id w8so7174396qac.3
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 03:28:48 -0800 (PST)
Date: Mon, 12 Jan 2015 06:28:45 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH cgroup/for-3.19-fixes] cgroup: implement
 cgroup_subsys->unbind() callback
Message-ID: <20150112112845.GS25319@htj.dyndns.org>
References: <54B01335.4060901@arm.com>
 <20150110085525.GD2110@esperanza>
 <20150110214316.GF25319@htj.dyndns.org>
 <20150111205543.GA5480@phnom.home.cmpxchg.org>
 <20150112080114.GE2110@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150112080114.GE2110@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Will Deacon <Will.Deacon@arm.com>

Hello, Vladimir.

On Mon, Jan 12, 2015 at 11:01:14AM +0300, Vladimir Davydov wrote:
> Come to think of it, I wonder how many users actually want to mount
> different controllers subset after unmount. Because we could allow

It wouldn't be a common use case but, on the face of it, we still
support it.  If we collecctively decide that once a sub cgroup is
created for any controller no further hierarchy configuration for that
controller is allowed, that'd work too, but one way or the other, the
behavior, I believe, should be well-defined.  As it currently stands,
the conditions and failure mode are opaque to userland, which is never
a good thing.

> mounting the same subset perfectly well, even if it includes memcg. BTW,
> AFAIU in the unified hierarchy we won't have this problem at all,
> because by definition it mounts all controllers IIRC, so do we need to
> bother fixing this in such a complicated manner at all for the setup
> that's going to be deprecated anyway?

There will likely be a quite long transition period and if and when
the old things can be removed, this added cleanup logic can go away
with it.  It depends on how complex the implementation would get but
as long as it isn't too much and stays mostly isolated from the saner
paths, I think it's probably the right thing to do.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
