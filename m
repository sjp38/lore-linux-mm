Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 27F4D6B0044
	for <linux-mm@kvack.org>; Sun, 25 Mar 2012 22:00:17 -0400 (EDT)
Message-ID: <4F6FCDAD.4060701@cn.fujitsu.com>
Date: Mon, 26 Mar 2012 10:00:13 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 6/6] workqueue: use kmalloc_align() instead of hacking
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com> <1332238884-6237-7-git-send-email-laijs@cn.fujitsu.com> <20120320154619.GA5684@google.com> <4F6944D9.5090002@cn.fujitsu.com> <alpine.DEB.2.00.1203210842200.20382@router.home>
In-Reply-To: <alpine.DEB.2.00.1203210842200.20382@router.home>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/21/2012 09:45 PM, Christoph Lameter wrote:
> On Wed, 21 Mar 2012, Lai Jiangshan wrote:
> 
>> Yes, I don't want to build a complex kmalloc_align(). But after I found
>> that SLAB/SLUB's kmalloc-objects are natural/automatic aligned to
>> a proper big power of two. I will do nothing if I introduce kmalloc_align()
>> except just care the debugging.
> 
> They are not guaranteed to be aligned to the big power of two! There are
> kmalloc caches that are not power of two. Debugging and other
> necessary meta data may change alignment in both SLAB and SLUB. SLAB needs
> a metadata structure in each page even without debugging that may cause
> alignment issues.

"Debugging and other necessary meta data" are handled in special way in my patches.
(You have already checked the patches.)

Normally, as I said, SLAB/SLUB's kmalloc-objects are natural/automatic aligned,
and my patch does not touch the general cases. Sorry for my bad reply.


> 
>> And kmalloc_align() can be used in the following case:
>> o	a type object need to be aligned with cache-line for it contains a frequent
>> 	update-part and a frequent read-part.
>> o	The total number of these objects in a given type is not much, creating
>> 	a new slab cache for a given type will be overkill.
>>
>> This is a RFC patch and it seems mm gurus don't like it. I'm sorry I
>> bother all of you.
> 
> Ideas are always welcome. Please do not get offended by our problems with
> your patch.
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
