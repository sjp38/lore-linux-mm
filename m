Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 7CCA66B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 05:21:49 -0400 (EDT)
Message-ID: <501A45FE.4040008@parallels.com>
Date: Thu, 2 Aug 2012 13:18:54 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [00/16] Sl[auo]b: Common code rework V8
References: <20120801211130.025389154@linux.com> <501A3F1E.4060307@parallels.com>
In-Reply-To: <501A3F1E.4060307@parallels.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On 08/02/2012 12:49 PM, Glauber Costa wrote:
> On 08/02/2012 01:11 AM, Christoph Lameter wrote:
>>
>> V7->V8:
>> - Do not use kfree for kmem_cache in slub.
>> - Add more patches up to a common
>>   scheme for object alignment.
>>
>> V6->V7:
>> - Omit pieces that were merged for 3.6
>> - Fix issues pointed out by Glauber.
>> - Include the patches up to the point at which
>>   the slab name handling is unified
>>
> 
> After applying v8, and proceeding with cache deletion + later insertion
> as I've previously laid down, I can still see the bug I mentioned here.
> 
> Again, I am doing nothing more than:
> 1) Creating a cache
> 2) Deleting that cache
> 3) Creating that cache again.
> 
> I am doing this in a synthetic function "mybug" called from memcg
> creation for convenience only (so don't get distracted by this in the
> backtrack). The machine boots okay, and seems to work for everything
> other than those late destructions. So maybe this is a problem that
> happens only after SLAB_FULL?
> 
> I am attaching the backtrace I've got with SLUB_DEBUG_ON. My first guess
> based on it would be a double free somewhere.
> 
Also worth mentioning, of course, that this test snippet works with the
SLAB without any problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
