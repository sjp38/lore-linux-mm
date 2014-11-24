Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id BE67C6B00E3
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 14:01:42 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id y19so13050730wgg.14
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 11:01:42 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id et8si13469929wib.84.2014.11.24.11.01.42
        for <linux-mm@kvack.org>;
        Mon, 24 Nov 2014 11:01:42 -0800 (PST)
Date: Mon, 24 Nov 2014 21:01:27 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, gfp: escalatedly define GFP_HIGHUSER and
 GFP_HIGHUSER_MOVABLE
Message-ID: <20141124190127.GA5027@node.dhcp.inet.fi>
References: <1416847427-2550-1-git-send-email-nasa4836@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1416847427-2550-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, sasha.levin@oracle.com, n-horiguchi@ah.jp.nec.com, andriy.shevchenko@linux.intel.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, fabf@skynet.be, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jianyu Zhan <jianyu.zhan@emc.com>

On Tue, Nov 25, 2014 at 12:43:47AM +0800, Jianyu Zhan wrote:
> GFP_USER, GFP_HIGHUSER and GFP_HIGHUSER_MOVABLE are escalatedly
> confined defined, also implied by their names:
> 
> GFP_USER                                  = GFP_USER
> GFP_USER + __GFP_HIGHMEM                  = GFP_HIGHUSER
> GFP_USER + __GFP_HIGHMEM + __GFP_MOVABLE  = GFP_HIGHUSER_MOVABLE

Looks reasonable.

Acked-by: Kirill A. Shutemov <kirill@linux.intel.com>

But I would prefer to have GPF_HIGHUSER movable by default and
GFP_HIGHUSER_UNMOVABLE to opt out.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
