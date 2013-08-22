Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id C4C386B0034
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 12:47:26 -0400 (EDT)
Date: Thu, 22 Aug 2013 16:47:25 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 00/16] slab: overload struct slab over struct page to
 reduce memory usage
In-Reply-To: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000140a6ec66e5-a4d245c0-76b6-4a8b-9cf0-d941ca9e08b0-000000@email.amazonses.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 22 Aug 2013, Joonsoo Kim wrote:

> And this patchset change a management method of free objects of a slab.
> Current free objects management method of the slab is weird, because
> it touch random position of the array of kmem_bufctl_t when we try to
> get free object. See following example.

The ordering is intentional so that the most cache hot objects are removed
first.

> To get free objects, we access this array with following pattern.
> 6 -> 3 -> 7 -> 2 -> 5 -> 4 -> 0 -> 1 -> END

Because that is the inverse order of the objects being freed.

The cache hot effect may not be that significant since per cpu and per
node queues have been aded on top. So maybe we do not be so cache aware
anymore when actually touching struct slab.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
