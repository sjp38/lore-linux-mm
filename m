Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 8D4CF6B005A
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 10:14:47 -0400 (EDT)
Message-ID: <501A8B51.6020801@parallels.com>
Date: Thu, 2 Aug 2012 18:14:41 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [15/16] Shrink __kmem_cache_create() parameter lists
References: <20120801211130.025389154@linux.com> <20120801211204.342096542@linux.com> <501A381F.9040703@parallels.com> <alpine.DEB.2.00.1208020910450.23049@router.home>
In-Reply-To: <alpine.DEB.2.00.1208020910450.23049@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On 08/02/2012 06:11 PM, Christoph Lameter wrote:
> On Thu, 2 Aug 2012, Glauber Costa wrote:
> 
>> On 08/02/2012 01:11 AM, Christoph Lameter wrote:
>>> +		if (!s->name) {
>>> +			kmem_cache_free(kmem_cache, s);
>>> +			s = NULL;
>>> +			goto oops;
>>> +		}
>>> +
>> This is now only defined when CONFIG_DEBUG_VM. Now would be a good time
>> to fix that properly by just removing the ifdef around the label.
> 
> I disagree with randomly adding checks to production code. These are
> things useful for debugging but should not increase the cahce footprint of
> the kernel in production system.
> 
> 
Read again, this has nothing to do with adding code to production kernel.
You are actually jumping to a non-existant label when CONFIG_DEBUG_VM,
so this is a build failure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
