Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9146B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 12:02:37 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id dm2so82635653obb.2
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 09:02:37 -0800 (PST)
Received: from mail-ob0-x233.google.com (mail-ob0-x233.google.com. [2607:f8b0:4003:c01::233])
        by mx.google.com with ESMTPS id to8si11896346oec.46.2016.02.26.09.02.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 09:02:36 -0800 (PST)
Received: by mail-ob0-x233.google.com with SMTP id jq7so82763837obb.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 09:02:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1602261013140.24939@east.gentwo.org>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1456466484-3442-13-git-send-email-iamjoonsoo.kim@lge.com>
	<alpine.DEB.2.20.1602261013140.24939@east.gentwo.org>
Date: Sat, 27 Feb 2016 02:02:36 +0900
Message-ID: <CAAmzW4ORSVsS_iji3gAcvepFqd3wsq0bXnxYOqnrYPH5ePykzA@mail.gmail.com>
Subject: Re: [PATCH v2 12/17] mm/slab: do not change cache size if debug
 pagealloc isn't possible
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-02-27 1:13 GMT+09:00 Christoph Lameter <cl@linux.com>:
> On Fri, 26 Feb 2016, js1304@gmail.com wrote:
>
>> We can fail to setup off slab in some conditions.  Even in this case,
>> debug pagealloc increases cache size to PAGE_SIZE in advance and it is
>> waste because debug pagealloc cannot work for it when it isn't the off
>> slab.  To improve this situation, this patch checks first that this cache
>> with increased size is suitable for off slab.  It actually increases cache
>> size when it is suitable for off-slab, so possible waste is removed.
>
> Maybe add some explanations to the code? You tried to simplify it earlier
> and make it understandable. This makes it difficult to understand it.

There is some explanation above the changed stuff although it doesn't
appear in the patch. And, this patch doesn't change any condition for it.
What this patch does is checking if it is suitable for off slab cache
in advance.
Before this patch, it is checked after increasing size and if it isn't
suitable for off slab cache, it cannot be used for debug_pagealloc with
increased size.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
