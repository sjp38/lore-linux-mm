Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id EE0B76B0072
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 10:35:14 -0400 (EDT)
Message-ID: <5087FC97.6080100@parallels.com>
Date: Wed, 24 Oct 2012 18:35:03 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/2] kmem_cache: include allocators code directly into
 slab_common
References: <1351087158-8524-1-git-send-email-glommer@parallels.com> <1351087158-8524-2-git-send-email-glommer@parallels.com> <0000013a932d456c-8f0cbbce-e3f7-4f2a-b051-7b093a8cfc7e-000000@email.amazonses.com>
In-Reply-To: <0000013a932d456c-8f0cbbce-e3f7-4f2a-b051-7b093a8cfc7e-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>

On 10/24/2012 06:29 PM, Christoph Lameter wrote:
> On Wed, 24 Oct 2012, Glauber Costa wrote:
> 
>> Because of that, we either have to move all the entry points to the
>> mm/slab.h and rely heavily on the pre-processor, or include all .c files
>> in here.
> 
> Hmm... That is a bit of a radical solution. The global optimizations now
> possible with the new gcc compiler include the ability to fold functions
> across different linkable objects. Andi, is that usable for kernel builds?
> 

In general, it takes quite a lot of time to take all those optimizations
for granted. We still live a lot of time with multiple compiler versions
building distros, etc, for quite some time.

I would expect the end result for anyone not using such a compiler to be
a sudden performance drop when using a new kernel. Not really pleasant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
