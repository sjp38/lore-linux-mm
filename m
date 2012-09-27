Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id E71CF6B006C
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 10:48:28 -0400 (EDT)
Date: Thu, 27 Sep 2012 14:48:27 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/4] move slabinfo processing to common code
In-Reply-To: <1348756660-16929-1-git-send-email-glommer@parallels.com>
Message-ID: <0000013a0833408c-117f7b98-4f5f-4db8-a3a3-1b9ca2ff1ce8-000000@email.amazonses.com>
References: <1348756660-16929-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On Thu, 27 Sep 2012, Glauber Costa wrote:

> This patch moves on with the slab caches commonization, by moving
> the slabinfo processing to common code in slab_common.c. It only touches
> slub and slab, since slob doesn't create that file, which is protected
> by a Kconfig switch.

Thanks. That was also something on my todo list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
