Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 66FCC6B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 10:57:13 -0500 (EST)
Received: by igcto18 with SMTP id to18so34493889igc.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 07:57:13 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id x77si6432208iod.113.2015.12.02.07.57.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 02 Dec 2015 07:57:12 -0800 (PST)
Date: Wed, 2 Dec 2015 09:57:11 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm/slab: use list_first_entry_or_null()
In-Reply-To: <7e551749f5a50cef15a33320d6d33b9d0b0986bd.1449070964.git.geliangtang@163.com>
Message-ID: <alpine.DEB.2.20.1512020956010.28955@east.gentwo.org>
References: <7e551749f5a50cef15a33320d6d33b9d0b0986bd.1449070964.git.geliangtang@163.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2 Dec 2015, Geliang Tang wrote:

> Simplify the code with list_first_entry_or_null().

Looks like there are two code snippets here in slab.c that
could become a function or so. So this could be improved upon by creating
a function called get_first_slab() or so.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
