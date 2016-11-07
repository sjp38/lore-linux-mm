Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 14DDC6B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 14:52:48 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id b66so52980420ywh.2
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 11:52:48 -0800 (PST)
Received: from mail-yb0-x234.google.com (mail-yb0-x234.google.com. [2607:f8b0:4002:c09::234])
        by mx.google.com with ESMTPS id q2si2529636ywb.270.2016.11.07.11.52.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 11:52:47 -0800 (PST)
Received: by mail-yb0-x234.google.com with SMTP id d59so22926902ybi.1
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 11:52:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1611071324380.19249@east.gentwo.org>
References: <1477939010-111710-1-git-send-email-thgarnie@google.com>
 <alpine.DEB.2.10.1610311625430.62482@chino.kir.corp.google.com>
 <CAJcbSZHic9gfpYHFXySZf=EmUjztBvuHeWWq7CQFi=0Om7OJoA@mail.gmail.com>
 <alpine.DEB.2.10.1611021744150.110015@chino.kir.corp.google.com>
 <alpine.DEB.2.20.1611031531380.13315@east.gentwo.org> <CAJcbSZHaN8zVf4_MdpmofNCY719YfRsRq+PjLR-a+M4QGyCnGw@mail.gmail.com>
 <alpine.DEB.2.20.1611071324380.19249@east.gentwo.org>
From: Thomas Garnier <thgarnie@google.com>
Date: Mon, 7 Nov 2016 11:52:46 -0800
Message-ID: <CAJcbSZE+TsP4i7GisocejQMwbVYv+AH8GY1JA8+o4Zt8ropCKw@mail.gmail.com>
Subject: Re: [PATCH v2] memcg: Prevent memcg caches to be both OFF_SLAB & OBJFREELIST_SLAB
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>

On Mon, Nov 7, 2016 at 11:28 AM, Christoph Lameter <cl@linux.com> wrote:
> On Mon, 7 Nov 2016, Thomas Garnier wrote:
>
>> I am not sure that is possible. kmem_cache_create currently check for
>> possible alias, I assume that it goes against what memcg tries to do.
>
> What does aliasing have to do with this? The aliases must have the same
> flags otherwise the caches would not have been merged.
>

I assume there might be cases where the parent cache and the new memcg
cache are compatible for merge (same flags and size). We can bypass
that by adding SLAB_NEVER_MERGE but I am not sure what is the
consequence of that.

>> Separate the changes in two patches might make sense:
>>
>>  1) Fix the original bug by masking the flags passed to create_cache
>>  2) Add flags check in kmem_cache_create.
>>
>> Does it make sense?
>
> Sure.
>

Great, I will send both patches.

>> > I also want to make sure that there are no other callers that specify
>> > extraneou flags while we are at it.
>> I will review as many as I can but we might run into surprises (quick
>> boot on defconfig didn't show anything). That's why having two
>> different patches might be useful.
>
> These surprises can be caught later ... Just make sure that the core works
> fine with this. You cannot audit all drivers.
>

Okay, I will.



-- 
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
