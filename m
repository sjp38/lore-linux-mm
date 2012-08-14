Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 5F5676B0068
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 10:23:54 -0400 (EDT)
Date: Tue, 14 Aug 2012 14:23:53 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: Use __do_krealloc to do the krealloc job
In-Reply-To: <1344948921-17633-1-git-send-email-elezegarcia@gmail.com>
Message-ID: <000001392584f1a0-401c6058-361e-4d4f-ab94-70c7770b5763-000000@email.amazonses.com>
References: <1344948921-17633-1-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>

On Tue, 14 Aug 2012, Ezequiel Garcia wrote:

> Without this patch we can get (many) kmem trace events
> with call site at krealloc().

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
