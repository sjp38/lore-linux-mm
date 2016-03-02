Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id CA27B828F2
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 09:17:39 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id n186so87891406wmn.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 06:17:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id km6si43324671wjc.1.2016.03.02.06.17.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 06:17:38 -0800 (PST)
Subject: Re: [PATCH mmotm] mm, sl[au]b: print gfp_flags as strings in
 slab_out_of_memory()
References: <1456859312-26207-1-git-send-email-vbabka@suse.cz>
 <alpine.DEB.2.10.1603011439390.24913@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D6F5FE.6050709@suse.cz>
Date: Wed, 2 Mar 2016 15:17:34 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1603011439390.24913@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 03/01/2016 11:41 PM, David Rientjes wrote:
> On Tue, 1 Mar 2016, Vlastimil Babka wrote:
>
>> We can now print gfp_flags more human-readable. Make use of this in
>> slab_out_of_memory() for SLUB and SLAB. Also convert the SLAB variant it to
>> pr_warn() along the way.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Christoph Lameter <cl@linux.com>
>> Cc: Pekka Enberg <penberg@kernel.org>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Acked-by: David Rientjes <rientjes@google.com>

Thanks.

> Although I've always been curious about the usefulness of these out of
> memory calls in the first place.  They are obviously for debugging, but
> have they actually helped to diagnose anything?

Uh no idea, maybe other SL*B maintainers have more experience. But what 
did prompt me to write this patch is that I've recently have actually 
seen the output of those in some (presumably linux-mm) thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
