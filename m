Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id EB7746B0044
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 13:40:16 -0500 (EST)
Date: Tue, 11 Dec 2012 13:39:37 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm/bootmem.c: remove unused wrapper function
 reserve_bootmem_generic()
Message-ID: <20121211183937.GA5168@cmpxchg.org>
References: <1355213523-15698-1-git-send-email-linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1355213523-15698-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, yinghai@kernel.org, hpa@zytor.com, davem@davemloft.net, eric.dumazet@gmail.com, tj@kernel.org, shangw@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 11, 2012 at 04:12:03PM +0800, Lin Feng wrote:
> Wrapper fucntion reserve_bootmem_generic() currently have no caller,
> so clean it up.
> 
> Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
