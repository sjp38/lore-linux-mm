Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 45F096B0253
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 11:22:12 -0500 (EST)
Received: by mail-io0-f180.google.com with SMTP id 9so122296658iom.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 08:22:12 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id 76si17813222iod.22.2016.02.26.08.22.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 26 Feb 2016 08:22:11 -0800 (PST)
Date: Fri, 26 Feb 2016 10:22:11 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 17/17] mm/slab: avoid returning values by reference
In-Reply-To: <1456466484-3442-18-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.20.1602261021520.24939@east.gentwo.org>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com> <1456466484-3442-18-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 26 Feb 2016, js1304@gmail.com wrote:

> Returing values by reference is bad practice. Instead, just use
> function return value.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
