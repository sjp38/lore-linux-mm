Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 403086B002B
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 02:57:08 -0500 (EST)
Message-ID: <50CED055.1030401@parallels.com>
Date: Mon, 17 Dec 2012 11:57:09 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Ren [03/12] Common kmalloc slab index determination
References: <20121213211413.134419945@linux.com> <0000013b9648d9d2-d4e9b7b0-d7d3-47ed-aca0-6397e1f8d98a-000000@email.amazonses.com>
In-Reply-To: <0000013b9648d9d2-d4e9b7b0-d7d3-47ed-aca0-6397e1f8d98a-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On 12/14/2012 02:00 AM, Christoph Lameter wrote:
> Extract the function to determine the index of the slab within
> the array of kmalloc caches as well as a function to determine
> maximum object size from the nr of the kmalloc slab.
> 
> This is used here only to simplify slub bootstrap but will
> be used later also for SLAB.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com> 

I remember having acked this already?

In any case, I scanned for changes since your last submission, and I
don't see anything significant.

So Acked-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
