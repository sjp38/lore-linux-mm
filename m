Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8EEF16B0257
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 10:29:51 -0500 (EST)
Received: by iofh3 with SMTP id h3so4138031iof.3
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 07:29:51 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id b19si5385917igr.56.2015.11.10.07.29.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 10 Nov 2015 07:29:51 -0800 (PST)
Date: Tue, 10 Nov 2015 09:29:50 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] tools/vm: fix Makefile multi-targets
In-Reply-To: <1447162326-30626-2-git-send-email-sergey.senozhatsky@gmail.com>
Message-ID: <alpine.DEB.2.20.1511100929290.8480@east.gentwo.org>
References: <1447162326-30626-1-git-send-email-sergey.senozhatsky@gmail.com> <1447162326-30626-2-git-send-email-sergey.senozhatsky@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Tue, 10 Nov 2015, Sergey Senozhatsky wrote:

> Build all of the $(TARGETS), not just the first one.

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
