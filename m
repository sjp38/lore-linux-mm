Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id A7E926B0088
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 16:20:42 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id r2so20497871igi.3
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 13:20:42 -0800 (PST)
Received: from resqmta-po-12v.sys.comcast.net ([2001:558:fe16:19:250:56ff:feb0:855])
        by mx.google.com with ESMTPS id m10si1119007icf.102.2014.12.04.13.20.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 13:20:41 -0800 (PST)
Date: Thu, 4 Dec 2014 15:20:40 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC v2] percpu: Add a separate function to merge free areas
In-Reply-To: <20141204211912.GG4080@htj.dyndns.org>
Message-ID: <alpine.DEB.2.11.1412041520270.14925@gentwo.org>
References: <547E3E57.3040908@ixiacom.com> <20141204175713.GE2995@htj.dyndns.org> <5480BFAA.2020106@ixiacom.com> <alpine.DEB.2.11.1412041426230.14577@gentwo.org> <20141204205202.GP29748@ZenIV.linux.org.uk> <alpine.DEB.2.11.1412041514250.14832@gentwo.org>
 <20141204211912.GG4080@htj.dyndns.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Leonard Crestez <lcrestez@ixiacom.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sorin Dumitru <sdumitru@ixiacom.com>

On Thu, 4 Dec 2014, Tejun Heo wrote:

> Docker usage is pretty wide-spread now, making what used to be
> siberia-cold paths hot enough to cause actual scalability issues.
> Besides, we're now using percpu_ref for things like aio and cgroup
> control structures which can be created and destroyed quite
> frequently.  I don't think we can say these are "weird" use cases
> anymore.

Well then lets write a scalable percpu allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
