Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id A53F2828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 10:23:44 -0500 (EST)
Received: by mail-io0-f174.google.com with SMTP id g73so261840110ioe.3
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 07:23:44 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id g74si13391766ioi.70.2016.01.14.07.23.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jan 2016 07:23:44 -0800 (PST)
Date: Thu, 14 Jan 2016 09:23:43 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 03/16] mm/slab: remove the checks for slab implementation
 bug
In-Reply-To: <1452749069-15334-4-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.20.1601140923150.2145@east.gentwo.org>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com> <1452749069-15334-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 14 Jan 2016, Joonsoo Kim wrote:

> Some of "#if DEBUG" are for reporting slab implementation bug
> rather than user usecase bug. It's not really needed because slab
> is stable for a quite long time and it makes code too dirty. This
> patch remove it.

Maybe better convert them to VM_BUG_ON() or so?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
