Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 05BCB6B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 14:10:34 -0500 (EST)
Received: by mail-qg0-f43.google.com with SMTP id e89so32747816qgf.2
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 11:10:33 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id p9si11187258qai.60.2015.01.29.11.10.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 11:10:32 -0800 (PST)
Date: Thu, 29 Jan 2015 13:10:31 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm v2 1/3] slub: never fail to shrink cache
In-Reply-To: <20150129182141.GA25158@esperanza>
Message-ID: <alpine.DEB.2.11.1501291310140.9633@gentwo.org>
References: <cover.1422461573.git.vdavydov@parallels.com> <012683fc3a0f9fb20a288986fd63fe9f6d25e8ee.1422461573.git.vdavydov@parallels.com> <20150128135752.afcb196d6ded7c16a79ed6fd@linux-foundation.org> <20150129080726.GB11463@esperanza>
 <alpine.DEB.2.11.1501290954230.7725@gentwo.org> <20150129161739.GE11463@esperanza> <alpine.DEB.2.11.1501291021370.7986@gentwo.org> <20150129182141.GA25158@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 29 Jan 2015, Vladimir Davydov wrote:

> > Well we have to go through the chain of partial slabs anyways so its easy
> > to do the optimization at that point.
>
> That's true, but we can introduce a separate function that would both
> release empty slabs and optimize slab placement, like the patch below
> does. It would increase the code size a bit though, so I don't insist.

It would also change what slabinfo -s does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
