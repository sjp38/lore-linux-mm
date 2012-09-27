Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id A63616B0078
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 10:53:43 -0400 (EDT)
Date: Thu, 27 Sep 2012 14:53:42 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/4] slub: move slub internal functions to its header
In-Reply-To: <1348756660-16929-4-git-send-email-glommer@parallels.com>
Message-ID: <0000013a08380e96-c8b9c80e-438a-46c6-b992-67bef9082a41-000000@email.amazonses.com>
References: <1348756660-16929-1-git-send-email-glommer@parallels.com> <1348756660-16929-4-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 27 Sep 2012, Glauber Costa wrote:

> The functions oo_order() and oo_objects() are used by the slub to
> determine respectively the order of a candidate allocation, and the
> number of objects made available from it. I would like a stable visible
> location outside slub.c so it can be acessed from slab_common.c.

Patch looks okay but it worries me that we export this internal stuff.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
