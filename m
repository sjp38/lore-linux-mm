Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 9F78D6B0044
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 14:36:04 -0500 (EST)
Date: Mon, 4 Feb 2013 19:36:03 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: REN2 [07/13] Common constants for kmalloc boundaries
In-Reply-To: <CALF0-+VGnhL0B5nuqJUYCEzKRxzzxJAWzT2x1SumVRmVapdLRg@mail.gmail.com>
Message-ID: <0000013ca6b54403-b790cbb7-3b4f-465e-a95e-6c9e708bacd3-000000@email.amazonses.com>
References: <20130110190027.780479755@linux.com> <0000013c25e260c8-aeaa555f-3466-4c01-8e81-9891429850b2-000000@email.amazonses.com> <CALF0-+VGnhL0B5nuqJUYCEzKRxzzxJAWzT2x1SumVRmVapdLRg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Tim Bird <tim.bird@am.sony.com>

On Sat, 2 Feb 2013, Ezequiel Garcia wrote:

> I mean: why do we need to maintain 32 bytes as the smallest kmalloc cache?

SLABs metadata structures do not allow smaller caches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
