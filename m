Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1B05B6B0008
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 13:47:03 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id m3so11400397iti.1
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 10:47:03 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id j195si11063764ioj.317.2018.03.06.10.47.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 10:47:02 -0800 (PST)
Date: Tue, 6 Mar 2018 12:47:01 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 19/25] slab: make kmem_cache_flags accept 32-bit object
 size
In-Reply-To: <20180305200730.15812-19-adobriyan@gmail.com>
Message-ID: <alpine.DEB.2.20.1803061246490.29393@nuc-kabylake>
References: <20180305200730.15812-1-adobriyan@gmail.com> <20180305200730.15812-19-adobriyan@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org


Acked-by: Christoph Lameter <cl@linux.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
