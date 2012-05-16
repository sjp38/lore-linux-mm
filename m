Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 4D4846B00F0
	for <linux-mm@kvack.org>; Wed, 16 May 2012 02:37:40 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so847059obb.14
        for <linux-mm@kvack.org>; Tue, 15 May 2012 23:37:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205142327580.19403@chino.kir.corp.google.com>
References: <1336663979-2611-1-git-send-email-js1304@gmail.com>
	<alpine.DEB.2.00.1205142327580.19403@chino.kir.corp.google.com>
Date: Wed, 16 May 2012 09:37:38 +0300
Message-ID: <CAOJsxLFao1nP92mUH7M6UsQu16UqzP_Vi3WasSkQw8Q8tFBDjg@mail.gmail.com>
Subject: Re: [PATCH] slub: fix a possible memory leak
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 15, 2012 at 9:28 AM, David Rientjes <rientjes@google.com> wrote:
> On Fri, 11 May 2012, Joonsoo Kim wrote:
>
>> Memory allocated by kstrdup should be freed,
>> when kmalloc(kmem_size, GFP_KERNEL) is failed.
>>
>> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
>
> Acked-by: David Rientjes <rientjes@google.com>
>
> kmem_cache_create() in slub would significantly be improved with a rewrite
> to have a clear error path and use of return values of functions it calls.

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
