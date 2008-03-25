Date: Tue, 25 Mar 2008 12:01:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Bugme-new] [Bug 10318] New: WARNING: at arch/x86/mm/highmem_32.c:43
 kmap_atomic_prot+0x87/0x184()
In-Reply-To: <47E9482B.7050005@cosmosbay.com>
Message-ID: <Pine.LNX.4.64.0803251159500.17356@schroedinger.engr.sgi.com>
References: <bug-10318-10286@http.bugzilla.kernel.org/>
 <20080325105750.ff913a83.akpm@linux-foundation.org> <47E9482B.7050005@cosmosbay.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org, pstaszewski@artcom.pl, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 25 Mar 2008, Eric Dumazet wrote:

> If kzalloc() or __get_free_pages(__GFP_ZERO) is not allowed from softirq then
> many usages are illegal.

There is clearly no problem for GFP_KERNEL. The only issue could arise for 
GFP_HIGHMEM|__GFP_ZERO. I thought we had dealt with these false positives 
a while back?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
