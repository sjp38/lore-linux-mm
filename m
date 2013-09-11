Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id ADF816B0031
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 10:22:26 -0400 (EDT)
Date: Wed, 11 Sep 2013 14:22:25 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [REPOST PATCH 3/4] slab: introduce byte sized index for the
 freelist of a slab
In-Reply-To: <20130911010434.GB24671@lge.com>
Message-ID: <000001410d66d62b-d6711e2e-31e4-49da-8d20-efba10fc6a54-000000@email.amazonses.com>
References: <1378447067-19832-1-git-send-email-iamjoonsoo.kim@lge.com> <1378447067-19832-4-git-send-email-iamjoonsoo.kim@lge.com> <00000140f3fed229-f49b95d4-7087-476f-b2c9-37846749aad6-000000@email.amazonses.com> <20130909043217.GB22390@lge.com>
 <00000141032dea11-c5aa9c77-b2f2-4cab-b7a0-d37665a6cec8-000000@email.amazonses.com> <20130910054342.GB24602@lge.com> <0000014109c372c6-5f3c49d4-ce8b-4760-b80d-a32e042ec09b-000000@email.amazonses.com> <20130911010434.GB24671@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 11 Sep 2013, Joonsoo Kim wrote:

> Anyway, could you review my previous patchset, that is, 'overload struct slab
> over struct page to reduce memory usage'? I'm not sure whether your answer is
> ack or not.

I scanned over it before but I was not able to see if it was correct on
first glance. I will look at it again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
