Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 63C186B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 03:24:49 -0400 (EDT)
Received: by wgbdq12 with SMTP id dq12so4146428wgb.26
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 00:24:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <000001392584f1a0-401c6058-361e-4d4f-ab94-70c7770b5763-000000@email.amazonses.com>
References: <1344948921-17633-1-git-send-email-elezegarcia@gmail.com>
	<000001392584f1a0-401c6058-361e-4d4f-ab94-70c7770b5763-000000@email.amazonses.com>
Date: Tue, 4 Sep 2012 10:24:47 +0300
Message-ID: <CAOJsxLH9dFgH0BAE7WBcV7R1u6A4jbP5xwkQnHCKWuSKYdX6pw@mail.gmail.com>
Subject: Re: [PATCH] mm: Use __do_krealloc to do the krealloc job
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>, David Rientjes <rientjes@google.com>

On Tue, 14 Aug 2012, Ezequiel Garcia wrote:
>> Without this patch we can get (many) kmem trace events
>> with call site at krealloc().

On Tue, Aug 14, 2012 at 5:23 PM, Christoph Lameter <cl@linux.com> wrote:
> Acked-by: Christoph Lameter <cl@linux.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
