Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 4B8586B006C
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 11:35:49 -0400 (EDT)
Message-ID: <508FF3C8.3070305@parallels.com>
Date: Tue, 30 Oct 2012 19:35:36 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/2] kmem_cache: include allocators code directly into
 slab_common
References: <1351087158-8524-1-git-send-email-glommer@parallels.com> <1351087158-8524-2-git-send-email-glommer@parallels.com> <CAOJsxLHxo7zJk=aWrjmuaYsEkaChTCgXowtHxtuiabaOP3W3-Q@mail.gmail.com> <0000013a9444c6ba-d26e7627-1890-40da-ae91-91e7c4a3d7e9-000000@email.amazonses.com> <CAAmzW4O1EAFxHf1tRaFzg-opPLzMboAdo-vbUFkyo=ZdQp9rmw@mail.gmail.com> <0000013ab24cd7ac-1c5345d6-5fea-4459-942e-b6deccd1a6f1-000000@email.amazonses.com>
In-Reply-To: <0000013ab24cd7ac-1c5345d6-5fea-4459-942e-b6deccd1a6f1-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: andi@firstfloor.org, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, JoonSoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>

On 10/30/2012 07:31 PM, Christoph Lameter wrote:
> On Fri, 26 Oct 2012, JoonSoo Kim wrote:
> 
>> 2012/10/25 Christoph Lameter <cl@linux.com>:
>>> On Wed, 24 Oct 2012, Pekka Enberg wrote:
>>>
>>>> So I hate this patch with a passion. We don't have any fastpaths in
>>>> mm/slab_common.c nor should we. Those should be allocator specific.
>>>
>>> I have similar thoughts on the issue. Lets keep the fast paths allocator
>>> specific until we find a better way to handle this issue.
>>
>> Okay. I see.
>> How about applying LTO not to the whole kernel code, but just to
>> slab_common.o + sl[aou]b.o?
>> I think that it may be possible, isn't it?
> 
> Well.... Andi: Is that possible?
> 

FYI: In the next version of my series, there is a patch that puts
the common code in an inline function in mm/slab.h. Then the allocators
just call that function.

I think it is the best we can do for now, given all the constraints.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
