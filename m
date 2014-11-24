Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8264B6B0038
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 13:21:51 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id l18so13414842wgh.16
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 10:21:51 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h9si24147100wjr.139.2014.11.24.10.21.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Nov 2014 10:21:50 -0800 (PST)
Date: Mon, 24 Nov 2014 13:21:27 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm, gfp: escalatedly define GFP_HIGHUSER and
 GFP_HIGHUSER_MOVABLE
Message-ID: <20141124182127.GA7604@phnom.home.cmpxchg.org>
References: <1416847427-2550-1-git-send-email-nasa4836@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1416847427-2550-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, sasha.levin@oracle.com, n-horiguchi@ah.jp.nec.com, andriy.shevchenko@linux.intel.com, rientjes@google.com, vdavydov@parallels.com, fabf@skynet.be, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jianyu Zhan <jianyu.zhan@emc.com>

On Tue, Nov 25, 2014 at 12:43:47AM +0800, Jianyu Zhan wrote:
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

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
