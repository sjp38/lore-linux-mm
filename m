Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 594D56B0033
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 11:49:46 -0400 (EDT)
Date: Fri, 6 Sep 2013 15:49:45 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [REPOST PATCH 2/4] slab: introduce helper functions to get/set
 free object
In-Reply-To: <1378447067-19832-3-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000140f3f6fe2d-ded4181c-05bf-47f9-8aa6-983102fdddc6-000000@email.amazonses.com>
References: <1378447067-19832-1-git-send-email-iamjoonsoo.kim@lge.com> <1378447067-19832-3-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 6 Sep 2013, Joonsoo Kim wrote:

> In the following patches, to get/set free objects from the freelist
> is changed so that simple casting doesn't work for it. Therefore,
> introduce helper functions.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
