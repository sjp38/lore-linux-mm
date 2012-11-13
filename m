Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 6B14B6B005A
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 19:49:54 -0500 (EST)
Date: Mon, 12 Nov 2012 19:49:47 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/4] bootmem: remove not implemented function call,
 bootmem_arch_preferred_node()
Message-ID: <20121113004947.GA10092@cmpxchg.org>
References: <1352737915-30906-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1352737915-30906-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Nov 13, 2012 at 01:31:52AM +0900, Joonsoo Kim wrote:
> There is no implementation of bootmeme_arch_preferred_node() and
> call for this function will makes compile-error.
> So, remove it.
> 
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
