Message-ID: <4238845E.5060304@colorfullife.com>
Date: Wed, 16 Mar 2005 20:09:18 +0100
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: Fw: [PATCH] NUMA Slab Allocator
References: <20050315204110.6664771d.akpm@osdl.org> <42387C2E.4040106@colorfullife.com> <273220000.1110999247@[10.10.2.4]>
In-Reply-To: <273220000.1110999247@[10.10.2.4]>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Christoph Lameter <christoph@lameter.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:

>That'd be my inclination .... but OTOH, we do that for pagecache OK.
>
The page cache doesn't have a global hash table.

> Dunno, 
>I'm torn. Depends if there's locality on the file access or not, I guess.
>Is there any *harm* in doing it node local .... perhaps creating a node
>mem pressure imbalance (OTOH, there's loads of stuff that does that anyway ;-))
>
>  
>
The harm is slower kmem_cache_free and a lower hit ratio for the per-cpu 
caches: kmem_cache_free must identify and return wrong node objects, and 
due to these returns, the per-cpu array is more often empty in 
kmem_cache_alloc.

IIRC someone from SGI wrote that they have seen bad performance in 
fork-bomb tests on large cpu count systems which might be caused by 
inter-node traffic on the mm_struct structure and that they think that a 
numa aware allocator would help. As far as I know no tests were done to 
very that assumption.

--
    Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
