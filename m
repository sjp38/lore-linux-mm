Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7B7EE6B0253
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 11:06:32 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id xg9so37417368igb.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 08:06:32 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id h6si5267695igv.10.2016.02.26.08.06.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 26 Feb 2016 08:06:31 -0800 (PST)
Date: Fri, 26 Feb 2016 10:06:30 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 04/17] mm/slab: activate debug_pagealloc in SLAB when
 it is actually enabled
In-Reply-To: <1456466484-3442-5-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.20.1602261006160.24939@east.gentwo.org>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com> <1456466484-3442-5-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>


Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
