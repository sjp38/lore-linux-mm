Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 832B26B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 10:42:20 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id p6so1357021qcv.1
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 07:42:20 -0800 (PST)
Received: from mail-qg0-x231.google.com (mail-qg0-x231.google.com. [2607:f8b0:400d:c04::231])
        by mx.google.com with ESMTPS id 4si17724555qal.124.2015.01.19.07.42.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 07:42:19 -0800 (PST)
Received: by mail-qg0-f49.google.com with SMTP id i50so1446007qgf.8
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 07:42:19 -0800 (PST)
Date: Mon, 19 Jan 2015 10:42:15 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH -mm v2 3/7] cgroup: release css->id after css_free
Message-ID: <20150119154215.GA10570@htj.dyndns.org>
References: <cover.1421664712.git.vdavydov@parallels.com>
 <4d7447a920522c1085ff96c08b2be71e0eb5d896.1421664712.git.vdavydov@parallels.com>
 <20150119143001.GH8140@htj.dyndns.org>
 <20150119151854.GA28598@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150119151854.GA28598@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Chinner <david@fromorbit.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jan 19, 2015 at 06:18:54PM +0300, Vladimir Davydov wrote:
> Could you please elaborate this? I mean, what problems do you think can
> arise if we release css->id a little bit (one grace period) later?
> 
> Of course, I can introduce yet another id per memcg, but I think we have
> css->id to avoid code duplication in controllers.

lol, my brainfart.  Never mind.  I thought you were moving it to
offline.  Please feel free to add my acked-by.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
