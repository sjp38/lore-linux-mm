Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 743446B006E
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 03:13:51 -0400 (EDT)
Received: by mail-ea0-f169.google.com with SMTP id k11so536521eaa.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 00:13:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1210171407430.20712@chino.kir.corp.google.com>
References: <1350473811-16264-1-git-send-email-glommer@parallels.com>
	<alpine.DEB.2.00.1210171407430.20712@chino.kir.corp.google.com>
Date: Wed, 31 Oct 2012 09:13:49 +0200
Message-ID: <CAOJsxLHUU3zD3HOJ8htJMd_nUqQV0ronmjy3iMNkbburZ-3VWw@mail.gmail.com>
Subject: Re: [PATCH v5] slab: Ignore internal flags in cache creation
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org

On Thu, Oct 18, 2012 at 12:07 AM, David Rientjes <rientjes@google.com> wrote:
> On Wed, 17 Oct 2012, Glauber Costa wrote:
>
>> Some flags are used internally by the allocators for management
>> purposes. One example of that is the CFLGS_OFF_SLAB flag that slab uses
>> to mark that the metadata for that cache is stored outside of the slab.
>>
>> No cache should ever pass those as a creation flags. We can just ignore
>> this bit if it happens to be passed (such as when duplicating a cache in
>> the kmem memcg patches).
>>
>> Because such flags can vary from allocator to allocator, we allow them
>> to make their own decisions on that, defining SLAB_AVAILABLE_FLAGS with
>> all flags that are valid at creation time.  Allocators that doesn't have
>> any specific flag requirement should define that to mean all flags.
>>
>> Common code will mask out all flags not belonging to that set.
>>
>> [ v2: leave the mask out decision up to the allocators ]
>> [ v3: define flags for all allocators ]
>> [ v4: move all definitions to slab.h ]
>>
>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>> Acked-by: Christoph Lameter <cl@linux.com>
>> CC: David Rientjes <rientjes@google.com>
>> CC: Pekka Enberg <penberg@cs.helsinki.fi>
>
> Acked-by: David Rientjes <rientjes@google.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
