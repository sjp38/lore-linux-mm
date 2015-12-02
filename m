Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 929296B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 10:58:25 -0500 (EST)
Received: by igcmv3 with SMTP id mv3so120586784igc.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 07:58:25 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id g14si18839839igt.29.2015.12.02.07.58.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 02 Dec 2015 07:58:25 -0800 (PST)
Date: Wed, 2 Dec 2015 09:58:24 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm/slab: use list_for_each_entry in
 cache_flusharray
In-Reply-To: <22e322cb81d99e70674e9f833c5b6aa4e87714c6.1449070964.git.geliangtang@163.com>
Message-ID: <alpine.DEB.2.20.1512020958130.28955@east.gentwo.org>
References: <7e551749f5a50cef15a33320d6d33b9d0b0986bd.1449070964.git.geliangtang@163.com> <22e322cb81d99e70674e9f833c5b6aa4e87714c6.1449070964.git.geliangtang@163.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2 Dec 2015, Geliang Tang wrote:

> Simplify the code with list_for_each_entry().

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
