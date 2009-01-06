Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BD0FA6B00AB
	for <linux-mm@kvack.org>; Tue,  6 Jan 2009 11:16:38 -0500 (EST)
Message-ID: <496383E0.50102@ftml.net>
Date: Tue, 06 Jan 2009 10:16:32 -0600
From: Roman Kononov <kononov@ftml.net>
MIME-Version: 1.0
Subject: Re: [patch] mm: fix lockless pagecache reordering bug (was Re: BUG:
 soft lockup - is this XFS problem?)
References: <20090105041959.GC367@wotan.suse.de> <20090105064838.GA5209@wotan.suse.de> <49623384.2070801@aon.at> <20090105164135.GC32675@wotan.suse.de> <alpine.LFD.2.00.0901050859430.3057@localhost.localdomain> <20090105180008.GE32675@wotan.suse.de> <alpine.LFD.2.00.0901051027011.3057@localhost.localdomain> <20090105201258.GN6959@linux.vnet.ibm.com> <alpine.LFD.2.00.0901051224110.3057@localhost.localdomain> <20090105215727.GQ6959@linux.vnet.ibm.com> <20090106020550.GA819@wotan.suse.de>
In-Reply-To: <20090106020550.GA819@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Klotz <peter.klotz@aon.at>, stable@kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Christoph Hellwig <hch@infradead.org>, Roman Kononov <kernel@kononov.ftml.net>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 2009-01-05 20:05 Nick Piggin said the following:
> Subject: mm lockless pagecache barrier fix
>  static inline void *radix_tree_deref_slot(void **pslot)
>  {
> -	void *ret = *pslot;
> +	void *ret = rcu_dereference(*pslot);
>  	if (unlikely(radix_tree_is_indirect_ptr(ret)))
>  		ret = RADIX_TREE_RETRY;
>  	return ret;

3 systems are working fine for a few hours with the patch. They would 
fail within 20 minutes without it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
