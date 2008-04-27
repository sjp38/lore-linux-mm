Message-ID: <48144ED0.5040805@cs.helsinki.fi>
Date: Sun, 27 Apr 2008 13:00:48 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: slub: Dump list of objects not freed on kmem_cache_close()
References: <Pine.LNX.4.64.0804251221170.5971@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0804251221170.5971@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Dump a list of unfreed objects if a slab cache is closed but
> objects still remain.
> 
> [Untested (straight use of the logic from process_slab()), may conflict 
> with the other patch you just committed]
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

It conflicted with the free_list() cleanup but I fixed that up. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
