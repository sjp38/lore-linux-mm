Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A2D7F900015
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 14:33:30 -0500 (EST)
Received: by pdjz10 with SMTP id z10so2611648pdj.13
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 11:33:30 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id yk5si3254171pbb.141.2015.02.04.11.33.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Feb 2015 11:33:29 -0800 (PST)
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 9059C207A2
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 14:33:26 -0500 (EST)
Message-ID: <54D27403.90000@iki.fi>
Date: Wed, 04 Feb 2015 21:33:23 +0200
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] LLVMLinux: Correct size_index table before replacing
 the bootstrap kmem_cache_node.
References: <1422970639-7922-1-git-send-email-daniel.sanders@imgtec.com> <1422970639-7922-2-git-send-email-daniel.sanders@imgtec.com>
In-Reply-To: <1422970639-7922-2-git-send-email-daniel.sanders@imgtec.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Sanders <daniel.sanders@imgtec.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2/3/15 3:37 PM, Daniel Sanders wrote:
> This patch moves the initialization of the size_index table slightly
> earlier so that the first few kmem_cache_node's can be safely allocated
> when KMALLOC_MIN_SIZE is large.

The patch looks OK to me but how is this related to LLVM?

- Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
