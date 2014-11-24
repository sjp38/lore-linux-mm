Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 23CD06B006E
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 16:34:38 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id h15so3916759igd.8
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 13:34:37 -0800 (PST)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com. [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id m8si13450igt.42.2014.11.24.13.34.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 13:34:37 -0800 (PST)
Received: by mail-ie0-f173.google.com with SMTP id y20so9743587ier.18
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 13:34:36 -0800 (PST)
Date: Mon, 24 Nov 2014 13:34:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, gfp: escalatedly define GFP_HIGHUSER and
 GFP_HIGHUSER_MOVABLE
In-Reply-To: <1416847427-2550-1-git-send-email-nasa4836@gmail.com>
Message-ID: <alpine.DEB.2.10.1411241334210.21237@chino.kir.corp.google.com>
References: <1416847427-2550-1-git-send-email-nasa4836@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, sasha.levin@oracle.com, n-horiguchi@ah.jp.nec.com, andriy.shevchenko@linux.intel.com, hannes@cmpxchg.org, vdavydov@parallels.com, fabf@skynet.be, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jianyu Zhan <jianyu.zhan@emc.com>

On Tue, 25 Nov 2014, Jianyu Zhan wrote:

> GFP_USER, GFP_HIGHUSER and GFP_HIGHUSER_MOVABLE are escalatedly
> confined defined, also implied by their names:
> 
> GFP_USER                                  = GFP_USER
> GFP_USER + __GFP_HIGHMEM                  = GFP_HIGHUSER
> GFP_USER + __GFP_HIGHMEM + __GFP_MOVABLE  = GFP_HIGHUSER_MOVABLE
> 
> So just make GFP_HIGHUSER and GFP_HIGHUSER_MOVABLE escalatedly defined
> to reflect this fact. It also makes the definition clear and texturally
> warn on any furture break-up of this escalated relastionship.
> 
> Signed-off-by: Jianyu Zhan <jianyu.zhan@emc.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
