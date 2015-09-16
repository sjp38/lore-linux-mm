Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8D15D6B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 01:31:03 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so198718955pac.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 22:31:03 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id fm10si29576676pab.152.2015.09.15.22.31.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 22:31:02 -0700 (PDT)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 4421321B21
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 01:30:59 -0400 (EDT)
Message-ID: <55F8FE90.9090405@iki.fi>
Date: Wed, 16 Sep 2015 08:30:56 +0300
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: slab: convert slab_is_available to boolean
References: <1442339401-4145-1-git-send-email-kda@linux-powerpc.org>
In-Reply-To: <1442339401-4145-1-git-send-email-kda@linux-powerpc.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denis Kirjanov <kda@linux-powerpc.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 9/15/15 8:50 PM, Denis Kirjanov wrote:
> A good one candidate to return a boolean result
>
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
