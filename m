Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 8788F6B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 10:44:23 -0400 (EDT)
Date: Mon, 22 Oct 2012 14:44:22 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] slab: commonize slab_cache field in struct page
In-Reply-To: <1350914737-4097-2-git-send-email-glommer@parallels.com>
Message-ID: <0000013a88ee7ed0-50126a71-b26c-4a32-add4-82965a795578-000000@email.amazonses.com>
References: <1350914737-4097-1-git-send-email-glommer@parallels.com> <1350914737-4097-2-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On Mon, 22 Oct 2012, Glauber Costa wrote:

> The naming used by slab, "slab_cache", is less confusing, and it is
> preferred over slub's generic "slab".

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
